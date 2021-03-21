;***************************************************************************************************
;*                                                                                                 *
;*             Flash Utility for updating the Monitor Code on the C02 Pocket SBC V1.01             *
;*                                                                                                 *
;*               Utility requires the new image is loaded into RAM located at $1000                *
;*                                                                                                 *
;*              This utility defaults to the new Monitor image size of 6KB only                    *
;*              The image is written to EEPROM starting at address $E000                           *
;*                                                                                                 *
;*      NOTE: A system coldstart is performed once the image has been written to EEPROM            *
;*            Utility uses BIOS routines to interact with User - I/O to console routines           *
;*                                                                                                 *
;***************************************************************************************************
;
        .INCLUDE        C02Header.asm   ;Include the Header for all equates, routines, etc.
;
;***************************************************************************************************
;
M_FLASH         ;Monitor Flash Utility start at $0800
;
                LDA     #$00            ;Get Flash Utility intro message
                JSR     PROMPT          ;Send to console
;
                LDA     #$18            ;Get upper value for 6KB ($1800)
                STA     LENH            ;Store in Length high byte
                STZ     LENL            ;Zero Length low byte
;
                LDA     #$E0            ;Get ROM start address high byte
                STA     TGTH            ;Store in Target high byte
                STZ     TGTL            ;Zero Target low byte
;
                LDA     #$10            ;Get RAM start address MS location
                STA     SRCH            ;Store in Source high byte
                STZ     SRCL            ;Zero Source low byte
;
                LDA     #$01            ;Get Confirm message
                JSR     PROMPT          ;Send to console
                JSR     CONTINUE        ;Prompt User to continue (y/n)?
;
                LDA     #$02            ;Get Writing EEPROM message
                JSR     PROMPT          ;Send to console
OC_LOOP         LDA     OCNT            ;Check output buffer count
                BNE     OC_LOOP         ;Loop back until buffer sent
;
;Xfer byte write code to RAM for execution
                LDX     #BYTE_WRE-BYTE_WRS+1 ;Get length of byte write code
BYTE_XFER       LDA     BYTE_WRS-1,X    ;Get code
                STA     BURN_BYTE-1,X   ;Write code to RAM
                DEX                     ;Decrement index
                BNE     BYTE_XFER       ;Loop back until done
;
;Wait for 1/2 second for RAM/ROM access to settle
                LDA     #$32            ;Set milliseconds to 50(*10 ms)
                LDX     #$00            ;Zero out
                LDY     #$00            ;Zero out
                JSR     B_SET_DLY       ;Set Delay parameters
                JSR     B_EXE_MSDLY     ;Call delay for 1/2 second
;
COMPLP          LDA     LENL            ;Get low byte of length
                ORA     LENH            ;OR in High byte of length
                BEQ     QUITMV          ;If zero, nothing to compare/write
                JSR     BURN_BYTE       ;Else Burn a byte to EEPROM
                LDA     (SRCL)          ;Else load source
                CMP     (TGTL)          ;Compare to target
                BEQ     CMP_OK          ;If compare is good, continue
;
; Image write failed - just send a message and coldstart SBC
                LDA     #$04            ;Get Write failed message
                JSR     PROMPT          ;Send to console
                BRA     COLD_START      ;Show for 5 seconds and coldstart
;
CMP_OK          JSR     UPD_STL         ;Update pointers
                BRA     COMPLP          ;Loop back until done
;
QUITMV          LDA     #$03            ;Get write complet message
                JSR     PROMPT          ;Send to console
;
;Wait for 5 seconds before doing a Coldstart of the SBC
COLD_START      LDA     #$01            ;Set milliseconds to 1(*10 ms)
                LDX     #$01            ;Set 16-bit High multipler
                LDY     #$F4            ;to 500 decimal
                JSR     B_SET_DLY       ;Set Delay parameters
                JSR     B_EXE_LGDLY     ;Call long delay for 5 seconds
;
                JMP     B_COLDSTRT      ;Coldstart SBC
;
;Routines to update pointers for memory operations. UPD_STL subroutine: Increments Source
; and Target pointers. UPD_TL subroutine: Increments Target pointers only, then drops into
; decrement Length pointer. Used by multiple Memory operation commands.
UPD_STL         INC     SRCL            ;Increment source low byte
                BNE     UPD_TL          ;Check for rollover
                INC     SRCH            ;Increment source high byte
UPD_TL          INC     TGTL            ;Increment target low byte
                BNE     DECLEN          ;Check for rollover
                INC     TGTH            ;Increment target high byte
;
;DECLEN subroutine: decrement 16-bit variable LENL/LENH
DECLEN          LDA     LENL            ;Get length low byte
                BNE     SKP_LENH        ;Test for LENL = zero
                DEC     LENH            ;Else decrement length high byte
SKP_LENH        DEC     LENL            ;Decrement length low byte
                RTS                     ;Return to caller
;
;Continue routine: called by commands to confirm execution, when No is confirmed, return address
;is removed from stack and the exit goes back to the Monitor input loop.
;Short version prompts for (Y/N) only.
CONTINUE        LDA     #$05            ;Get msg "cont? (Y/N)" to terminal
SH_CONT         JSR     PROMPT          ;Send to terminal
TRY_AGN         JSR     RDCHAR          ;Get keystroke from terminal
                CMP     #$59            ;"Y" key?
                BEQ     DOCONT          ;if yes, continue/exit
                CMP     #$4E            ;if "N", quit/exit
                BEQ     DONTCNT         ;Return if not ESC
                LDA     #$07            ;Get Beep code
                JSR     B_CHROUT        ;Send to console
                BRA     TRY_AGN         ;Loop back, try again
DONTCNT         PLA                     ;Else remove return address
                PLA                     ;discard it,
DOCONT          RTS                     ;Return
;
;PROMPT routine: Send indexed text string to terminal. Index is contained in A reg.
; String buffer address is stored in variable PROMPTL/PROMPTH. (placing here saves some space).
PROMPT          ASL     A               ;Multiply by two for msg table index
                TAY                     ;Xfer to index
                LDA     MSG_TABLE,Y     ;Get low byte address
                STA     PROMPTL         ;Store in Buffer pointer
                LDA     MSG_TABLE+1,Y   ;Get high byte address
                STA     PROMPTH         ;Store in Buffer pointer
;
PROMPT2         LDA     (PROMPTL)       ;Get string data
                BEQ     DOCONT          ;If null character, exit (borrowed RTS)
                JSR     B_CHROUT        ;Send character to terminal
                INC     PROMPTL         ;Increment low byte index
                BNE     PROMPT2         ;Loop back for next character
                INC     PROMPTH         ;Increment high byte index
                BRA     PROMPT2         ;Loop back and continue printing
;
BYTE_WRS        SEI                     ;Disable interrupts
                LDA     (SRCL)          ;Get source byte
                STA     (TGTL)          ;Write to target byte
                LDA     (TGTL)          ;Read target byte (EEPROM)
                AND     #%01000000      ;Mask off bit 6 - toggle bit
BYTE_WLP        STA     TEMP3           ;Store in Temp location
                LDA     (TGTL)          ;Read target byte again (EEPROM)
                AND     #%01000000      ;Mask off bit 6 - toggle bit
                CMP     TEMP3           ;Compare to last read (toggles if write mode)
                BNE     BYTE_WLP        ;Branch back if not done
                CLI                     ;Re-enable interrupts
BYTE_WRE        RTS                     ;Return to caller
;
;RDCHAR subroutine: Waits for a keystroke to be entered.
; if keystroke is a lower-case alphabetical, convert it to upper-case
RDCHAR          JSR     B_CHRIN         ;Request keystroke input from terminal
                CMP     #$61            ;Check for lower case value range
                BCC     AOK             ;Branch if < $61, control code/upper-case/numeric
                SBC     #$20            ;Subtract $20 to convert to upper case
AOK             RTS                     ;Character received, return to caller
;
;Messages used
;
MSG_00  .DB     $0D,$0A
        .DB     "C02 Flash Utility Version 1.00"
        .DB     $0D,$0A
        .DB     "This will update the C02Monitor code image"
        .DB     $0D,$0A
        .DB     "Make sure you have loaded the new image to $1000 before continuing"
        .DB     $0D,$0A
        .DB     "This utility will overwrite the 6KB Monitor space from $E000 to $F7FF"
        .DB     $0D,$0A
        .DB     $00
;
MSG_01  .DB     "Make sure you know what you are doing!"
        .DB     $0D,$0A
        .DB     "The C02 Pocket SBC will Coldstart when completed!"
        .DB     $0D,$0A
        .DB     $00
;
MSG_02  .DB     $0D,$0A
        .DB     "Writing image to EEPROM...."
        .DB     $00
;
MSG_03  .DB     $0D,$0A
        .DB     "Image update completed! Will restart SBC in 5 seconds."
        .DB     $00
;
MSG_04  .DB     $0D,$0A,$0A
        .DB     "Error updating Monitor image!"
        .DB     $0D,$0A
        .DB     "Possible Write Protect Jumper or hardware error!"
        .DB     $0D,$0A
        .DB     "The C02 Pocket SBC will Coldstart now."
        .DB     $0D,$0A
        .DB     $00
;
MSG_05  .DB     "Would you like to continue? (y/n)"
        .DB     $00
;
MSG_TABLE       ;Message table: contains message addresses sent via the PROMPT routine
        .DW     MSG_00, MSG_01, MSG_02, MSG_03, MSG_04, MSG_05
;
        .END    ;End of User program

