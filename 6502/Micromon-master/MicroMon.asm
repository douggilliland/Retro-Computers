;
;**************************************************************************************************
;*                     Micromon Version 1.2 (c)2013-2019 by Kevin E. Maier                        *
;*             Extendable Mini BIOS and Monitor for 65C02 CPU - 26th February 2019                *
;*                                                *                                               *
;*  Uses 1.75KB EEPROM - JMP table page at $FF00  *  Basic functions include:                     *
;*     Default I/O page is 256 bytes at $FE00     *  - Byte/Text memory search                    *
;*        Default assembly start at $F800         *   - CPU register display/modify               *
;*                                                *  - Memory fill, move, compare, display        *
;*  C02BIOS 1.2L (c)2013-2019                     *  - Macro init/run                             *
;*  - BIOS in pages $FD, $FF                      *  - Execute code at $XXXX                      *
;*  - Full duplex interrupt-driven/buffered I/O   *  - Reset System                               *
;*  - extendable BIOS structure with soft vectors *                                               *
;*  - soft config parameters for 65C51 UART       *   Note default HW system memory map as:       *
;*  - monitor cold/warm start soft vectored       *    - RAM - $0000 - $7FFF                      *
;*  - Panic routine via NMI trigger               *    - ROM - $8000 - $FFFF (less I/O page)      *
;*  - fully relocatable code (sans page $FF)      *    - I/O - $FE00 - $FEFF                      *
;**************************************************************************************************
                PL      66              ;Page Length
                PW      132             ;Page Width (# of char/line)
                CHIP    W65C02S         ;Enable WDC 65C02 instructions
                PASS1   OFF             ;Set ON when used for debug
;**************************************************************************************************
;                                       Page Zero definitions
;**************************************************************************************************
;Page Zero from $00 to $CF available for user routines
;
PGZERO_ST       .EQU    $D0             ;Start of Page Zero usage
;
;Buffer used by the default Monitor code
INBUFF          .EQU    PGZERO_ST+0     ;4 byte buffer for HEX input ($D0-$D3)
;
;16-bit variables:
HEXDATAH        .EQU    PGZERO_ST+4     ;Hexadecimal input
HEXDATAL        .EQU    PGZERO_ST+5
BUFADRL         .EQU    PGZERO_ST+6     ;Input address
BUFADRH         .EQU    PGZERO_ST+7
COMLO           .EQU    PGZERO_ST+8     ;User command address
COMHI           .EQU    PGZERO_ST+9
INDEXL          .EQU    PGZERO_ST+10    ;Index for address
INDEXH          .EQU    PGZERO_ST+11
TEMPL           .EQU    PGZERO_ST+12    ;Index for word temp value used by Memdump
TEMPH           .EQU    PGZERO_ST+13
PROMPTL         .EQU    PGZERO_ST+14    ;Prompt string address
PROMPTH         .EQU    PGZERO_ST+15
SRCL            .EQU    PGZERO_ST+16    ;Source address for memory operations
SRCH            .EQU    PGZERO_ST+17
TGTL            .EQU    PGZERO_ST+18    ;Target address for memory operations
TGTH            .EQU    PGZERO_ST+19
LENL            .EQU    PGZERO_ST+20    ;Length address for memory operations
LENH            .EQU    PGZERO_ST+21
;
;8-bit variables and constants:
BUFIDX          .EQU    PGZERO_ST+22    ;Buffer index
BUFLEN          .EQU    PGZERO_ST+23    ;Buffer length
INDEX           .EQU    PGZERO_ST+24    ;Temp Indexing
TEMP1           .EQU    PGZERO_ST+25    ;Temp value - Code Conversion routines
TEMP2           .EQU    PGZERO_ST+26    ;Temp value - Memory routines
CMDFLAG         .EQU    PGZERO_ST+27    ;Command Flag - used by RDLINE
SPAREM1         .EQU    PGZERO_ST+28    ;Spare byte 1
SPAREM2         .EQU    PGZERO_ST+29    ;Spare byte 2
SPAREM3         .EQU    PGZERO_ST+30    ;Spare byte 3
SPAREM4         .EQU    PGZERO_ST+31    ;Spare byte 4
;
;BIOS variables, pointers, flags located at top of Page Zero.
BIOS_PG0        .EQU    PGZERO_ST+32    ;Start of BIOS page zero use
;
;BRK handler routine
PCL             .EQU    BIOS_PG0+0      ;Program Counter Low index
PCH             .EQU    BIOS_PG0+1      ;Program Counter High index
PREG            .EQU    BIOS_PG0+2      ;Temp Status reg
SREG            .EQU    BIOS_PG0+3      ;Temp Stack ptr
YREG            .EQU    BIOS_PG0+4      ;Temp Y reg
XREG            .EQU    BIOS_PG0+5      ;Temp X reg
AREG            .EQU    BIOS_PG0+6      ;Temp A reg
;
;6551 IRQ handler pointers and status
ICNT            .EQU    BIOS_PG0+7      ;Input buffer count
IHEAD           .EQU    BIOS_PG0+8      ;Input buffer head pointer
ITAIL           .EQU    BIOS_PG0+9      ;Input buffer tail pointer
OCNT            .EQU    BIOS_PG0+10     ;Output buffer count
OHEAD           .EQU    BIOS_PG0+11     ;Output buffer head pointer
OTAIL           .EQU    BIOS_PG0+12     ;Output buffer tail pointer
STTVAL          .EQU    BIOS_PG0+13     ;6551 BIOS status byte
SPAREB1         .EQU    BIOS_PG0+14     ;Spare byte 1
SPAREB2         .EQU    BIOS_PG0+15     ;Spare byte 2
;
;**************************************************************************************************
;Character input buffer address: $0200-$027F, Character output buffer address: $0280-$02FF
;Managed by full-duplex IRQ service routine.
;
IBUF            .EQU    $0200           ;INPUT BUFFER  128 BYTES - BIOS use only
OBUF            .EQU    $0280           ;OUTPUT BUFFER 128 BYTES - BIOS use only
;
;**************************************************************************************************
SOFTVEC         .EQU    $0300           ;Start of soft vectors
;
;The Interrupt structure is vector based. During startup, Page $03 is loaded from ROM.
; The soft vectors are structured to allow inserting additional routines either before
; or after the core routines. This allows flexibility and changing of routine priority.
;
;The main set of vectors occupy the first 16 bytes of Page $03. The ROM handler for
; NMI, BRK and IRQ jump to the first 3 vectors. The following 3 vectors are loaded with
; returns to the ROM handler for each. The following 2 vectors are the cold and warm
; entry points for the Monitor. After the basic initialization, the monitor is entered.
;
;The following vector set allows inserts for any of the above vectors.
; there are a total of 4 Inserts which occupy 8 bytes.
;
NMIVEC0         .EQU    SOFTVEC         ;NMI Interrupt Vector
BRKVEC0         .EQU    SOFTVEC+2       ;BRK Interrupt Vector
IRQVEC0         .EQU    SOFTVEC+4       ;INTERRUPT VECTOR
;
NMIRTVEC0       .EQU    SOFTVEC+6       ;NMI Return Handler
BRKRTVEC0       .EQU    SOFTVEC+8       ;BRK Return Handler
IRQRTVEC0       .EQU    SOFTVEC+10      ;IRQ Return Handler
;
CLDMNVEC0       .EQU    SOFTVEC+12      ;Cold Monitor Entry Vector
WRMMNVEC0       .EQU    SOFTVEC+14      ;Warm Monitor Entry Vector
;
VECINSRT0       .EQU    SOFTVEC+16      ;1st Vector Insert
VECINSRT1       .EQU    SOFTVEC+18      ;2nd Vector Insert
VECINSRT2       .EQU    SOFTVEC+20      ;3rd Vector Insert
VECINSRT3       .EQU    SOFTVEC+22      ;4th Vector Insert
;
;**************************************************************************************************
SOFTCFG         .EQU SOFTVEC+24         ;Start of hardware config parameters
;Soft Config values below are loaded from ROM and are the default I/O setup
; configuration data that the INIT_65xx routines use. As a result, you can write a
; routine to change the I/O configuration data and use the standard ROM routine
; to initialize the I/O without restarting or changing ROM. A Reset (cold or coded)
; will reinitialize the I/O with the ROM default I/O configuration.
; There are a total of 16 Bytes configuration data reserved starting at $0318
LOAD_6551       .EQU    SOFTCFG         ;6551 SOFT config data start
;**************************************************************************************************
;
;Search Buffer is 16 bytes in length
; Used to hold search string for text and hex data
SRCHBUFF        .EQU    $330            ;Located in Page $03 following HW config data
;
;I/O Page Base Address
IOPAGE          .EQU    $FE00           ;Start of I/O addresses
;
;ACIA device address:
SIOBase         .EQU    IOPAGE+$20      ;6551 Base HW address
SIODAT          .EQU    SIOBase+0       ;ACIA data register
SIOSTAT         .EQU    SIOBase+1       ;ACIA status register
SIOCOM          .EQU    SIOBase+2       ;ACIA command register
SIOCON          .EQU    SIOBase+3       ;ACIA control register
;**************************************************************************************************
                .ORG    $F800           ;Target address range $F800 through $FDFF will be used
;**************************************************************************************************
;                                       START OF MONITOR CODE
;**************************************************************************************************
;The following 16 functions are provided by the Monitor and available via the JMP
; $FF00 RDLINE (read line of Ascii characters from console)
; $FF03 RDCHAR (read Ascii character from console)
; $FF06 HEXIN2 (get 2 HEX characters from console)
; $FF09 HEXIN4 (get 4 HEX characters from console)
; $FF0C BIN2ASC (convert one byte to 2 Ascii characters)
; $FF0F ASC2BIN (convert 2 Ascii characters to one byte)
; $FF12 DOLLAR (print $ sign to console)
; $FF15 PRBYTE (print byte in A reg to console as HEX)
; $FF18 PRWORD (print word in A/Y reg to console as HEX)
; $FF1B PRASC (print Ascii character to console)
; $FF1E PROMPT (send msg # to console)
; $FF21 PROMPT2 (send text string tp console terminate with null)
; $FF24 CONTINUE (prompt to continue execution)
; $FF27 CROUT (send CR/LF to console)
; $FF2A SPC (send Ascii space to console)
; $FF2D BSOUT (send Ascii backspace to console and clear previous character)
;**************************************************************************************************
;                                       This is the Monitor Cold start vector
;**************************************************************************************************
MONITOR         LDA     #$14            ;Get intro msg
                JSR     PROMPT          ;Send to terminal
;
;**************************************************************************************************
;                       Command input loop - Monitor Warm start vector
;**************************************************************************************************
;
NMON            LDX     #$FF            ;Initialize Stack pointer
                TXS                     ;Xfer to stack
                STZ     CMDFLAG         ;Clear Command flag
                LDA     #$15            ;Get prompt msg
                JSR     PROMPT          ;Send to terminal
;
CMON            JSR     RDCHAR          ;Wait for keystroke (converts to upper-case)
                LDX     #MONTAB-MONCMD-1 ;Get command list count
CMD_LP          CMP     MONCMD,X        ;Compare to command list
                BNE     CMD_DEC         ;Check for next command and loop
                PHA                     ;Save keystroke
                TXA                     ;Xfer Command index to A reg
                ASL     A               ;Multiply keystroke value by 2
                TAX                     ;Get monitor command processor address from table MONTAB
                PLA                     ;Restore key (some commands send keystroke to terminal)
                JSR     DOCMD           ;Call selected monitor command processor as a subroutine
                BRA     NMON            ;Command processed, branch and wait for next command
DOCMD           JMP     (MONTAB,X)      ;Execute CMD from Table
;
CMD_DEC         DEX                     ;Decrement index count
                BPL     CMD_LP          ;If more to check, loop back
                JSR     BEEP            ;Beep for error,
                BRA     CMON            ;re-enter monitor
;
;**************************************************************************************************
;                                       Basic Subroutines used by multiple routines
;**************************************************************************************************
;ASC2BIN subroutine: Convert 2 ASCII HEX digits to a binary (byte) value.
; Enter: A register = high digit, Y register = low digit
; Return: A register = binary value
ASC2BIN         JSR     BINARY          ;Convert high digit to 4-bit nibble
                ASL     A               ;Shift to high nibble
                ASL     A
                ASL     A
                ASL     A
                STA     TEMP1           ;Store it in temp area
                TYA                     ;Get Low digit
                JSR     BINARY          ;Convert low digit to 4-bit nibble
                ORA     TEMP1           ;OR in the high nibble
                RTS                     ;Return to caller
;
BINARY          SEC                     ;Set carry for subtraction
                SBC     #$30            ;Subtract $30 from ASCII HEX digit
                CMP     #$0A            ;Check for result < 10
                BCC     BNOK            ;Branch if 0-9
                SBC     #$07            ;Else, subtract 7 for A-F
BNOK            RTS                     ;Return to caller
;
;BIN2ASC subroutine: Convert byte in A register to two ASCII HEX digits.
; Return: A register = high digit, Y register = low digit
BIN2ASC         PHA                     ;Save A Reg on stack
                AND     #$0F            ;Mask off high nibble
                JSR     ASCII           ;Convert nibble to ASCII HEX digit
                TAY                     ;Move to Y Reg
                PLA                     ;Get character back from stack
                LSR     A               ;Shift high nibble to lower 4 bits
                LSR     A
                LSR     A
                LSR     A
;
ASCII           CMP     #$0A            ;Check for 10 or less
                BCC     ASOK            ;Branch if less than 10
                ADC     #$06            ;Add $06+Carry = $07
ASOK            ADC     #$30            ;Add $30 for ASCII
                RTS                     ;Return to caller
;
;UPD_STL subroutine: Increments Source and Target pointers
;UPD_TL subroutine: Increments Target pointers only
; then drops into decrement length pointer. Used by multiple commands
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
;INCINDEX subroutine: increment 16 bit variable INDEXL/INDEXH
INCINDEX        INC     INDEXL          ;Increment index low byte
                BNE     SKP_IDX         ;If not zero, skip high byte
                INC     INDEXH          ;Increment index high byte
SKP_IDX         RTS                     ;Return to caller
;
;SETUP subroutine: Request HEX address input from terminal
SETUP           JSR     CHROUT          ;Send command keystroke to terminal
                JSR     SPC             ;Send [SPACE] to terminal
                BRA     HEXIN4          ;Request a 1-4 digit HEX address input from terminal
;
;HEX input subroutines:
; Request 1 to 4 ASCII HEX digits from terminal, then convert digits into a binary value
; HEXIN2 - returns value in A reg and Y reg only (Y reg always $00)
; HEXIN4 - returns values in A reg, Y reg and INDEXL/INDEXH
; For 1 to 4 digits entered, HEXDATAH and HEXDATAL contain the output
; Variable SCNT will contain the number of digits entered
; HEX2 - Prints MSG# in A reg then calls HEXIN2
; HEX4 - Prints MSG# in A reg then calls HEXIN4
;
HEX4            JSR     PROMPT          ;Print MSG # from A reg
HEXIN4          LDX     #$04            ;Set for number of characters allowed
                JSR     HEXINPUT        ;Convert digits
                STY     INDEXH          ;Store to INDEXH
                STA     INDEXL          ;Store to INDEXL
                RTS                     ;Return to caller
;
HEX2            JSR     PROMPT          ;Print MSG # from A reg
HEXIN2          LDX     #$02            ;Set for number of characters allowed
;
;HEXINPUT subroutine: request 1 to 4 HEX digits from terminal,
; then convert ASCII HEX to HEX
; Setup RDLINE subroutine parameters:
HEXINPUT        JSR     DOLLAR          ;Send "$" to console
                JSR     RDLINE          ;Request ASCII HEX input from terminal
                CPX     #$00            ;Check for no input
                BEQ     HINEXIT         ;Exit if none
                STZ     HEXDATAH        ;Clear Upper HEX byte, Lower HEX byte updated
                LDY     #$02            ;Set index for 2 bytes
ASCLOOP         PHY                     ;Save it to stack
                LDA     INBUFF-1,X      ;Read ASCII digit from buffer
                TAY                     ;Xfer to Y Reg (LSD)
                DEX                     ;Decrement input count
                BEQ     NO_UPNB         ;Branch if no upper nibble
                LDA     INBUFF-1,X      ;Read ASCII digit from buffer
                BRA     DO_UPNB         ;Branch to include upper nibble
NO_UPNB         LDA     #$30            ;Load ASCII "0" (MSD)
DO_UPNB         JSR     ASC2BIN         ;Convert ASCII digits to binary value
                PLY                     ;Get index from stack
                STA     HEXDATAH-1,Y    ;Write byte to indexed HEX input buffer location
                CPX     #$00            ;Any more digits?
                BEQ     HINDONE         ;If not, exit
                DEY                     ;Else, decrement to next byte set
                DEX                     ;Decrement index count
                BNE     ASCLOOP         ;Loop back for next byte
HINDONE         LDX     BUFIDX          ;Get input count
                LDY     HEXDATAH        ;Get High Byte
                LDA     HEXDATAL        ;Get Low Byte
HINEXIT         RTS                     ;And return to caller
;
;RDLINE subroutine: Store keystrokes in buffer until [RETURN] key it struck.
; Used only for Hex entry, so only (0-9,A-F) are accepted entries
; Lower-case alpha characters are converted to upper-case.
; On entry, X reg = buffer length.
; [BACKSPACE] key removes keystrokes from buffer.
; [ESCAPE] key aborts then re-enters monitor.
RDLINE          STX     BUFLEN          ;Store buffer length
                STZ     BUFIDX          ;Zero buffer index
RDLOOP          JSR     RDCHAR          ;Get character from terminal, convert LC2UC
                CMP     #$1B            ;Check for ESC key
                BEQ     RDNULL          ;If yes, exit back to Monitor
NOTESC          CMP     #$0D            ;Check for C/R
                BEQ     EXITRD          ;Exit if yes
                CMP     #$08            ;Check for Backspace
                BEQ     RDBKSP          ;If yes handle backspace
                CMP     #$30            ;Check for '0' or higher
                BCC     INPERR          ;Branch to error if less than '0'
                CMP     #$47            ;Check for 'G' ('F'+1)
                BCS     INPERR          ;Branch to error if 'G' or higher
                LDY     BUFIDX          ;Get the current buffer index
                CPY     BUFLEN          ;Compare to length for space
                BCC     STRCH           ;Branch to store in buffer
INPERR          JSR     BEEP            ;Else, error, send Bell to terminal
                BRA     RDLOOP          ;Branch back to RDLOOP
STRCH           STA     INBUFF,Y        ;Store keystroke in buffer
                JSR     CHROUT          ;Send keystroke to terminal
                INC     BUFIDX          ;Increment buffer index
                BRA     RDLOOP          ;Branch back to RDLOOP
RDBKSP          LDA     BUFIDX          ;Check if buffer is empty
                BEQ     INPERR          ;Branch if yes
                DEC     BUFIDX          ;Else, decrement buffer index
                JSR     BSOUT           ;Send Backspace to terminal
                BRA     RDLOOP          ;Loop back and continue
EXITRD          LDX     BUFIDX          ;Get keystroke count
                BNE     AOK             ;If data entered, normal exit
                BBS7    CMDFLAG,AOK     ;Branch if CMD flag active
RDNULL          JMP     (WRMMNVEC0)     ;Quit to Monitor warm start
;
;RDCHAR subroutine: Waits for a keystroke to be entered.
; if keystroke is a lower-case alphabetic, convert to upper-case
RDCHAR          JSR     CHRIN           ;Request keystroke input from terminal
                CMP     #$61            ;Check for lower case value range
                BCC     AOK             ;Branch if < $61, control code, upper-case or numeric
                SBC     #$20            ;Else, subtract $20 to convert to upper case
AOK             RTS                     ;Return to caller
;
;BEEP subroutine: Send ASCII [BELL] to terminal
BEEP            PHA                     ;Save A reg on Stack
                LDA     #$07            ;Get ASCII [BELL] character
                BRA     SENDIT          ;Branch to send
;
;SPC subroutines: Send a Space to terminal 1,2 or 4 times
SPC4            JSR     SPC2            ;Send 4 Spaces to terminal
SPC2            JSR     SPC             ;Send 2 Spaces to terminal
SPC             PHA                     ;Save character in A reg
                LDA     #$20            ;Get ASCII Space
                BRA     SENDIT          ;Branch to send
;
;DOLLAR subroutine: Send "$" to terminal
DOLLAR          PHA                     ;Save A reg on Stack
                LDA     #$24            ;Get ASCII "$"
                BRA     SENDIT          ;Branch to send
;
;BSOUT subroutine: send a Backspace to terminal
BSOUT           JSR     BSOUT2          ;Send an ASCII backspace
                JSR     SPC             ;Send space to clear out character
BSOUT2          PHA                     ;Save A reg on Stack
                LDA     #$08            ;Get an ASCII backspace
                BRA     SENDIT          ;Branch and send, then return
;
;Send CR,LF to terminal
CR2             JSR     CROUT           ;Send LF,CR to terminal
CROUT           PHA                     ;Save A reg
                LDA     #$0D            ;Get ASCII Return
                JSR     CHROUT          ;Send to terminal
                LDA     #$0A            ;Get ASCII Linefeed
SENDIT          JSR     CHROUT          ;Send to terminal
                PLA                     ;Restore A reg
                RTS                     ;Return to caller
;
;GLINE subroutine: Send a horizontal line to terminal
GLINE           LDX     #$4F            ;Load index for 79 decimal
                LDA     #$7E            ;Get "~" character
GLINEL          JSR     CHROUT          ;Send to terminal (draw a line)
                DEX                     ;Decrement count
                BNE     GLINEL          ;Branch back until done
                RTS                     ;Return to caller
;
;Routines to output 8/16-bit Binary Data and Ascii characters
;
; PRASC subroutine: Print A-reg as ASCII (Printable ASCII values = $20 - $7E), else print "."
PRASC           CMP     #$7F            ;Check for first 128
                BCS     PERIOD          ;If = or higher, branch
                CMP     #$20            ;Check for control characters
                BCS     ASCOUT          ;If space or higher, branch and print
PERIOD          LDA     #$2E            ;Else, print a "."
ASCOUT          JMP     CHROUT          ;Send byte in A-Reg, then return
;
;PRBYTE subroutine:
; Converts a single Byte to 2 HEX ASCII characters and sends to console
; on entry, A reg contains the Byte to convert/send
; Register contents are preserved on entry/exit
PRBYTE          PHA                     ;Save A register
                PHY                     ;Save Y register
PRBYT2          JSR     BIN2ASC         ;Convert A reg to 2 ASCII Hex characters
                JSR     CHROUT          ;Print high nibble from A reg
                TYA                     ;Transfer low nibble to A reg
                JSR     CHROUT          ;Print low nibble from A reg
                PLY                     ;Restore Y Register
                PLA                     ;Restore A Register
                RTS                     ;And return to caller
;
;PRINDEX subroutine:
; Used by Memory Dump and Text Entry routines
; Prints a $ sign followed by the current value of INDEXH/L
PRINDEX         JSR     DOLLAR          ;Print a $ sign
                LDA     INDEXH          ;Get Index high byte
                LDY     INDEXL          ;Get Index low byte
;
;PRWORD subroutine:
; Converts a 16-bit word to 4 HEX ASCII characters and sends to console
; on entry, A reg contains High Byte, Y reg contains Low Byte
; Register contents are preserved on entry/exit
PRWORD          PHA                     ;Save A register
                PHY                     ;Save Y register
                JSR     PRBYTE          ;Convert and print one HEX character (00-FF)
                TYA                     ;Get Low byte value
                BRA     PRBYT2          ;Finish up Low Byte and exit
;
;Continue routine, called by commands to confirm execution
; when No is confirmed, return address removed from stack
; and the exit goes back to the monitor loop.
; Short version prompts for (Y/N) only.
CONTINUE        LDA     #$00            ;Get msg "cont? (Y/N)" to terminal
                BRA     SH_CONT         ;Branch down
CONTINUE2       LDA     #$01            ;Get short msg "(Y/N)" only
SH_CONT         JSR     PROMPT          ;Send to terminal
TRY_AGN         JSR     RDCHAR          ;Get keystroke from terminal
                CMP     #$59            ;"Y" key?
                BEQ     DOCONT          ;if yes, continue/exit
                CMP     #$4E            ;if "N", quit/exit
                BEQ     DONTCNT         ;Quit if "N"
                JSR     BEEP            ;Else, send Beep to console
                BRA     TRY_AGN         ;Loop back, try again
DONTCNT         PLA                     ;Else remove return address
                PLA                     ;and discard, then return
DOCONT          RTS                     ;Return
;
;**************************************************************************************************
;                                       Monitor command processors
;**************************************************************************************************
;
;[(] INIMACRO command: Initialize keystroke input buffer:
; initializes buffer head/tail pointers and resets buffer count to zero.
; input buffer appears empty so command macro starts at the head of the buffer.
INIMACRO        STZ     ICNT            ;Zero Input buffer count
                STZ     ITAIL           ;Zero Input buffer tail pointer
MACINI          STZ     IHEAD           ;Zero Input buffer head pointer
DONEFILL        RTS                     ;Return to caller
;
;[)] RUNMACRO command: Run monitor command macro. This will indicate that there
; are 128 keystrokes in the keystroke input buffer. The monitor will process these
; as if they were received from the terminal (typed-in by the user). Because the
; last keystroke stored in the keystroke buffer was ")", this will loop continuously.
; Use [BREAK] to exit macro.
RUNMACRO        LDA     #$7F            ;Set keystroke buffer tail pointer to $7F
                STA     ITAIL           ;Push tail pointer to end
                INC     A               ;Increment to $80 for buffer count (full)
                STA     ICNT            ;Make count show as full
                BRA     MACINI          ;Finish up by branching
;
;[C] Compare one memory range to another and display any addresses which do not match
;[M] Move routine also starts here for parameter input, then branches to MOVER below
;[F] Fill routine uses this section as well for parameter input but requires a fill byte value
; Uses source, target and length input parameters. errors in compare are shown in target space
;
FM_INPUT        LDA     #$05            ;Send "val: " to terminal
                JSR     HEX2            ;Use short cut version for print and input
                TAX                     ;Xfer fill byte to X reg
                JSR     CONTINUE        ;Handle continue prompt
FILL_LP         LDA     LENL            ;Get length low byte
                ORA     LENH            ;OR in length high byte
                BEQ     DONEFILL        ;Exit if zero
                TXA                     ;Get fill byte
                STA     (TGTL)          ;Store in target location
                JSR     UPD_TL          ;Update Target/Length pointers
                BRA     FILL_LP         ;Loop back until done
;
CPMVFL          STA     TEMP2           ;Save command character
                JSR     CHROUT          ;Print command character (C/M/F)
                CMP     #$46            ;Check for F - fill memory
                BNE     PRGE_E          ;If not continue normal parameter input
                LDA     #$03            ;Get msg " addr:"
                BRA     F_INPUT         ;Branch to handle parameter input
PRGE_E          LDA     #$06            ;Send " src:" to terminal
                JSR     HEX4            ;Use short cut version for print and input
                STA     SRCL            ;Else, store source address in variable SRCL,SRCH
                STY     SRCH            ;Store high address
                LDA     #$07            ;Send " tgt:" to terminal
F_INPUT         JSR     HEX4            ;Use short cut version for print and input
                STA     TGTL            ;Else, store target address in variable TGTL,TGTH
                STY     TGTH            ;Store high address
                LDA     #$04            ;Send " len:" to terminal
                JSR     HEX4            ;Use short cut version for print and input
                STA     LENL            ;ELSE, store length address in variable LENL,LENH
                STY     LENH            ;Store high address
;All input parameters for Source, Target and Length entered
                LDA     TEMP2           ;Get Command character
                CMP     #$46            ;Check for fill memory
                BEQ     FM_INPUT        ;Handle the remaining input
                CMP     #$4D            ;Check for Move
                BEQ     MOVER           ;Branch if yes
;
COMPLP          LDA     LENL            ;Get low byte of length
                ORA     LENH            ;OR in High byte of length
                BEQ     QUITMV          ;If zero, nothing to write
                LDA     (SRCL)          ;Else load source
                CMP     (TGTL)          ;Compare to source
                BEQ     CMP_OK          ;If compare is good, continue
                JSR     SPC2            ;Send 2 spaces
                JSR     DOLLAR          ;Print $ sign
                LDA     TGTH            ;Get high byte of address
                LDY     TGTL            ;Get Low byte of address
                JSR     PRWORD          ;Print word
                JSR     SPC             ;Add 1 space for formatting
CMP_OK          JSR     UPD_STL         ;Update pointers
                BRA     COMPLP          ;Loop back until done
;
;Parameters for move memory entered and validated.
; now make decision on which direction to do the actual move.
; if overlapping, move from end to start, else from start to end.
MOVER           JSR     CONTINUE        ;Prompt to continue move
                SEC                     ;Set carry flag for subtract
                LDA     TGTL            ;Get target lo byte
                SBC     SRCL            ;Subtract source lo byte
                TAX                     ;Move to X reg temporarily
                LDA     TGTH            ;Get target hi byte
                SBC     SRCH            ;Subtract source hi byte
                TAY                     ;Move to Y reg temporarily
                TXA                     ;Xfer lo byte difference to A reg
                CMP     LENL            ;Compare to lo byte length
                TYA                     ;Xfer hi byte difference to A reg
                SBC     LENH            ;Subtract length lo byte
                BCC     RIGHT           ;If carry is clear, overwrite condition exists
;Move memory block first byte to last byte, no overwrite condition, do the move
MVNO_LP         LDA     LENL            ;Get length low byte
                ORA     LENH            ;OR in length high byte
                BEQ     QUITMV          ;Exit if zero bytes to move
                LDA     (SRCL)          ;Load source data
                STA     (TGTL)          ;Store as target data
                JSR     UPD_STL         ;Update Source/Target/Length variables
                BRA     MVNO_LP         ;Branch back until length is zero
;
;Move memory block last byte to first byte
; avoids overwrite in source/target overlap
RIGHT           LDX     LENH            ;Get the length hi byte count
                CLC                     ;Clear carry flag for add
                TXA                     ;Xfer High page to A reg
                ADC     SRCH            ;Add in source hi byte
                STA     SRCH            ;Store in source hi byte
                CLC                     ;Clear carry for add
                TXA                     ;Xfer High page to A reg 
                ADC     TGTH            ;Add to target hi byte
                STA     TGTH            ;Store to target hi byte
                INX                     ;Increment high page value for use below in loop
                LDY     LENL            ;Get length lo byte
                BEQ     MVPG            ;If zero no partial page to move
                DEY                     ;Else, decrement page byte index
                BEQ     MVPAG           ;If zero, no pages to move
MVPRT           LDA     (SRCL),Y        ;Load source data
                STA     (TGTL),Y        ;Store to target data
                DEY                     ;Decrement index
                BNE     MVPRT           ;Branch back until partial page moved
MVPAG           LDA     (SRCL),Y        ;Load source data
                STA     (TGTL),Y        ;Store to target data
MVPG            DEY                     ;Decrement page count
                DEC     SRCH            ;Decrement source hi page
                DEC     TGTH            ;Decrement target hi page
                DEX                     ;Decrement page count
                BNE     MVPRT           ;Loop back until all pages moved
QUITMV          RTS                     ;Return to caller
;
;[D] HEX/TEXT DUMP command:
; Display in HEX followed by TEXT the contents of 256 consecutive memory addresses
MDUMP           SMB7    CMDFLAG         ;Set Command flag
                JSR     SETUP           ;Request HEX address input from terminal
                CPX     #$00            ;Check for new address entered
                BNE     LINED           ;Branch if new address entered
                LDA     TEMPL           ;Else, point to next consecutive memory page
                STA     INDEXL          ;address saved during last memory dump
                LDA     TEMPH           ;xfer high byte of address
                STA     INDEXH          ;save in pointer
LINED           JSR     DMPGR           ;Send address offsets to terminal 
                JSR     GLINE           ;Send horizontal line to terminal
                JSR     CROUT           ;Send CR,LF to terminal
                LDX     #$10            ;Set line count for 16 rows
DLINE           JSR     SPC4            ;Send 4 Spaces to terminal
                JSR     PRINDEX         ;Print INDEX value
                JSR     SPC2            ;Send 2 Spaces to terminal
                LDY     #$00            ;Initialize line byte counter
GETBYT          LDA     (INDEXL),Y      ;Read indexed byte
                JSR     PRBYTE          ;Display byte as a HEX value
                JSR     SPC             ;Send a Space to terminal
                INY                     ;Increment index
                CPY     #$10            ;Check for all 16
                BNE     GETBYT          ;loop back until 16 bytes have been displayed
                JSR     SPC             ;Send a space
GETBYT2         LDA     (INDEXL)        ;Read indexed byte
                JSR     PRASC           ;Print ASCII character
                JSR     INCINDEX        ;Increment index
                DEY                     ;Decrement count (from 16)
                BNE     GETBYT2         ;loop back until 16 bytes have been displayed
                JSR     CROUT           ;else, send CR,LF to terminal
                LDA     INDEXL          ;Get current index low
                STA     TEMPL           ;Save to temp1 low
                LDA     INDEXH          ;Get current index high
                STA     TEMPH           ;Save to temp1 high
                DEX                     ;Decrement line count
                BNE     DLINE           ;Branch back until all 16 done
                JSR     GLINE           ;Send horizontal line to terminal
;DMPGR subroutine: Send address offsets to terminal
DMPGR           LDA     #$02            ;Get msg for "addr:" to terminal
                JSR     PROMPT          ;Send to terminal
                JSR     SPC2            ;Add two additional spaces
                LDX     #$00            ;Zero index count
MDLOOP          TXA                     ;Send "00" - "0F", separated by 1 Space, to terminal
                JSR     PRBYTE          ;Print byte value
                JSR     SPC             ;Add a space
                INX                     ;Increment the count
                CPX     #$10            ;Check for 16
                BNE     MDLOOP          ;Loop back until done
;Print the ASCII text header "0123456789ABCDEF"
                JSR     SPC             ;Send a space
                LDX     #$00            ;Zero X reg for "0"
MTLOOP          TXA                     ;Xfer to A reg
                JSR     BIN2ASC         ;Convert Byte to two ASCII digits
                TYA                     ;Xfer the low nibble character to A reg
                JSR     CHROUT          ;Send least significant HEX to terminal
                INX                     ;Increment to next HEX character
                CPX     #$10            ;Reach $10 yet?
                BNE     MTLOOP          :branch back till done
                JMP     CROUT           ;Do a CR/LF and return
;
;[G] GO command: Begin executing program code at a specified address
; Prompts the user for a start address, places it in COMLO/COMHI
; If no address entered, uses default address at COMLO/COMHI
; Loads the A,X,Y registers from presets and does a JSR to the routine
; Upon return, registers are saved back to presets for display later
; Also saves the stack pointer and status register upon return
; Stack pointer is not changed due to constant IRQ service routines
GO              SMB7    CMDFLAG         ;Set Command flag
                JSR     SETUP           ;Get HEX address (Areg/Yreg contains 16-bit value)
                CPX     #$00            ;Check if an address is entered
                BEQ     EXEC_GO         ;If not, just setup registers and execute
                STA     COMLO           ;Save entered address to pointer low byte
                STY     COMHI           ;Save entered address to pointer hi byte
;Preload all 65C02 MPU registers from monitor's preset/result variables
EXEC_GO         LDA     PREG            ;Load processot status register preset
                PHA                     ;Push it to the stack
                LDA     AREG            ;Load A-Reg preset
                LDX     XREG            ;Load X-Reg preset
                LDY     YREG            ;Load Y-Reg preset
                PLP                     ;Pull the processor status register
;Call user program code as a subroutine
                JSR     DOCOM           ;Execute code at specified address
;Store all 65C02 MPU registers to monitor's preset/result variables: store results
                PHP                     ;Save the processor status register to the stack
                STA     AREG            ;Store A-Reg result
                STX     XREG            ;Store X-Reg result
                STY     YREG            ;Store Y-Reg result
                PLA                     ;Get the processor status register
                STA     PREG            ;Store the result
                TSX                     ;Xfer stack pointer to X-reg
                STX     SREG            ;Store the result
                CLD                     ;Clear BCD mode in case of sloppy user code ;-)
TXT_EXT         RTS                     ;Return to caller
DOCOM           JMP     (COMLO)         ;Execute the command
;
;[T] LOCATE TEXT STRING command: search memory for an entered text string.
; Memory range scanned is $0400 through $FFFF (specified in SENGINE subroutine).
; SRCHTXT subroutine: request 1 - 16 character text string from terminal, followed by Return.
; [ESCAPE] aborts, [BACKSPACE] erases last keystroke. String will be stored in SRCHBUFF.
SRCHTXT         LDA     #$08            ;Get msg " find text:"
                JSR     PROMPT          ;Send to terminal
                LDX     #$00            ;Initialize index/byte counter
STLOOP          JSR     CHRIN           ;Get input from terminal
                CMP     #$0D            ;Check for C/R
                BEQ     SRCHRDY         ;Branch to search engine
                CMP     #$1B            ;Check for ESC
                BEQ     TXT_EXT         ;Exit to borrowed RTS
                CMP     #$08            ;Check for B/S
                BNE     STBRA           ;If not, store character into buffer
                TXA                     ;Xfer count to A reg
                BEQ     STLOOP          ;Branch to input if zero
                JSR     BSOUT           ;Else, send B/S to terminal
                DEX                     ;Decrement index/byte counter
                BRA     STLOOP          ;Branch back and continue
STBRA           STA     SRCHBUFF,X      ;Store character in buffer location
                JSR     CHROUT          ;Send character to terminal
                INX                     ;Increment counter
                CPX     #$10            ;Check count for 16
                BNE     STLOOP          ;Loop back for another character
                BRA     SRCHRDY         ;Branch to search engine
;
;[H] LOCATE BYTE STRING command: search memory for an entered byte string.
; Memory range scanned is $0400 through $FFFF (specified in SENGINE subroutine).
; SRCHBYT subroutine: request 0 - 16 byte string from terminal, each byte followed by Return.
; [ESCAPE] aborts. HEX data will be stored in SRCHBUFF.
SRCHBYT         SMB7    CMDFLAG         ;Set Command flag
                LDA     #$09            ;Get msg " find bin:"
                JSR     PROMPT          ;Send to terminal
                LDX     #$00            ;Initialize index
SBLOOP          PHX                     ;Save index on stack
                JSR     HEXIN2          ;Request HEX byte
                JSR     SPC             ;Send space to terminal
                PLX                     ;Restore index from stack
                LDY     BUFIDX          ;Get # of characters entered 
                BEQ     SRCHRDY         ;Branch if no characters
                STA     SRCHBUFF,X      ;Else, store in buffer
                INX                     ;Increment index
                CPX     #$10            ;Check for 16 (max)
                BNE     SBLOOP          ;Loop back until done/full
SRCHRDY         STX     INDEX           ;Save input character count
                CPX     #$00            ;Check buffer count
                BEQ     TXT_EXT         ;Exit if no bytes in buffer
                LDA     #$0C            ;Else, get msg "Searching.."
                JSR     PROMPT          ;Send to terminal
;
;SENGINE subroutine: Scan memory range $0400 through $FFFF for exact match to string
; contained in buffer SRCHBUFF (1 to 16 bytes/characters). Display address of first
; byte/character of each match found until the end of memory is reached.
; This is used by monitor text/byte string search commands
SENGINE         LDA     #$04            ;Init address to $0400: skip $0000 through $03FF
                STA     INDEXH          ;Store high byte
                STZ     INDEXL          ;Zero low byte
SENGBR2         LDX     #$00            ;Initialize buffer index
SENGBR3         LDA     (INDEXL)        ;Read current memory location
                CMP     SRCHBUFF,X      ;Compare to search buffer
                BEQ     SENGBR1         ;Branch for a match
                JSR     SINCPTR         ;Else, increment address pointer, test for end of memory
                BRA     SENGBR2         ;Loop back to continue
SENGBR1         JSR     SINCPTR         ;Increment address pointer, test for end of memory
                INX                     ;Increment buffer index
                CPX     INDEX           ;Compare buffer index to address index
                BNE     SENGBR3         ;Loop back until done
                SEC                     ;Subtract buffer index from memory addr pointer
                LDA     INDEXL          ;Get current address for match lo byte
                SBC     INDEX           ;Subtract from buffer index
                STA     INDEXL          ;Save it back to lo address pointer
                LDA     INDEXH          ;Get current address for match hi byte
                SBC     #$00            ;Subtract carry flag
                STA     INDEXH          ;Save it back to hi address pointer
                LDA     #$0B            ;Get msg "found"
                JSR     PROMPT          ;Send to terminal
                LDA     #':'            ;Get Ascii colon
                JSR     CHROUT          ;Send to console
                JSR     PRINDEX         ;Print Index address
                LDA     #$0D            ;Get msg "(n)ext? "
                JSR     PROMPT          ;Send to terminal
                JSR     RDCHAR          ;Get input from terminal
                CMP     #$4E            ;Check for "(n)ext"
                BNE     NCAREG          ;Exit if not requesting next
                JSR     SINCPTR         ;Increment address pointer, test for end of memory
                BRA     SENGBR2         ;Branch back and continue till done
;
;Increment memory address pointer. If pointer high byte = 00 (end of searchable ROM memory)
; send "not found" to terminal then return to monitor 
SINCPTR         JSR     INCINDEX        ;Increment Index pointer
                LDA     INDEXH          ;Check for wrap to $0000
                BNE     NCAREG          ;If not, return
                PLA                     ;Else, Pull return address from stack
                PLA                     ;and exit with msg
                LDA     #$0A            ;Get msg "not found"
                BRA     PROMPT          ;Send msg to terminal and exit
;
;[P] Processor Status command: Display then change PS preset/result
PRG             LDA     #$0E            ;Get MSG # for Processor Status register
                BRA     REG_UPT         ;Finish register update
;
;[S] Stack Pointer command: Display then change SP preset/result
SRG             LDA     #$0F            ;Get MSG # for Stack register
                BRA     REG_UPT         ;Finish Register update
;
;[Y] Y-Register command: Display then change Y-reg preset/result
YRG             LDA     #$10            ;Get MSG # for Y Reg
                BRA     REG_UPT         ;Finish register update
;
;[X] X-Register command: Display then change X-reg preset/result
XRG             LDA     #$11            ;Get MSG # for X Reg
                BRA     REG_UPT         ;Finish register update
;
;[A] A-Register command: Display then change A-reg preset/result
ARG             LDA     #$12            ;Get MSG # for A reg
;
REG_UPT         PHA                     ;Save MSG # to stack
                TAX                     ;Xfer to X reg
                JSR     PROMPT          ;Print Register message
                LDA     PREG-$0E,X      ;Read Register (A,X,Y,S,P) preset/result
                JSR     PRBYTE          ;Display HEX value of register
                JSR     SPC             ;Send a Space to terminal
                JSR     HEXIN2          ;Get up to 2 HEX characters
                PLX                     ;Get MSG # from stack
                STA     PREG-$0E,X      ;Write register (A,X,Y,S,P) preset/result
NCAREG          RTS                     ;Return to caller
;
;[R] REGISTER command: Display contents of all preset/result memory locations
PRSTAT          JSR     CHROUT          ;Send "R" to terminal
PRSTAT1         LDA     #$13            ;Get Header msg
                JSR     PROMPT          ;Send to terminal
                LDA     PCH             ;Get PC high byte
                LDY     PCL             ;Get PC low byte
                JSR     PRWORD          ;Print 16-bit word
                JSR     SPC             ;Send 1 space
;
                LDX     #$04            ;Set for count of 4
REGPLOOP        LDA     PREG,X          ;Start with A reg variable
                JSR     PRBYTE          ;Print it
                JSR     SPC             ;Send 1 space
                DEX                     ;Decrement count
                BNE     REGPLOOP        ;Loop back till all 4 are sent
;
                LDA     PREG            ;Get Status register preset
                LDX     #$08            ;Get the index count for 8 bits
SREG_LP         LDY     #$30            ;Get Ascii "zero"
                ASL     A               ;Shift bit into carry
                PHA                     ;Save Current status
                BCC     SRB_ZERO        ;If clear, print a zero
                INY                     ;Else increment Y reg to Ascii "one"
SRB_ZERO        TYA                     ;Transfer Ascii character to A reg
                JSR     CHROUT          ;Send to console
                PLA                     ;Restore current status
                DEX                     ;Decrement bit count
                BNE     SREG_LP         ;Branch back until all bits are printed
                JMP     CROUT           ;Send CR/LF and return
;
;PROMPT routine: Send indexed text string to terminal. Index is A reg
; string buffer address is stored in variable PROMPTL, PROMPTH
PROMPT          ASL     A               ;Multiply by two for msg table index
                TAY                     ;Xfer to index
                LDA     MSG_TABLE,Y     ;Get low byte address
                STA     PROMPTL         ;Store in Buffer pointer
                LDA     MSG_TABLE+1,Y   ;Get high byte address
                STA     PROMPTH         ;Store in Buffer pointer
;
PROMPT2         LDA     (PROMPTL)       ;Get string data
                BEQ     NCAREG          ;If null character, exit (borrowed RTS)
                JSR     CHROUT          ;Send character to terminal
                INC     PROMPTL         ;Increment low byte index
                BNE     PROMPT2         ;Loop back for next character
                INC     PROMPTH         ;Increment high byte index
                BRA     PROMPT2         ;Loop back and continue printing
;RESET routine: resets Micromon/BIOS - calls COLD Start
RESET           LDA     #$16            ;Get msg "Reset"
                JSR     PROMPT          ;Print message
                JSR     CONTINUE2       ;Prompt Y/N?
                JMP     COLDSTRT        ;Restart Micromon
;
;**************************************************************************************************
;                                       START OF MONITOR DATA
;**************************************************************************************************
;Monitor command & jump table
; There are two parts to the monitor command and jump table;
; first is the list of commands, which are one byte each. Alpha command characters are upper case
; second is the 16-bit address table that correspond to the routines for each command character
;
MONCMD          .DB     $12             ;[CNTRL-R] Reset
                .DB     $28             ;( Init Macro
                .DB     $29             ;) Run Macro
                .DB     $41             ;A Display/Edit A register
                .DB     $43             ;C Compare memory block
                .DB     $44             ;D Display Memory contents in HEX/TEXT
                .DB     $46             ;F Fill memory block
                .DB     $47             ;G Go execute at <addr>
                .DB     $48             ;H Hex byte string search
                .DB     $4D             ;M Move memory block
                .DB     $50             ;P Display/Edit CPU status reg
                .DB     $52             ;R Display Registers
                .DB     $53             ;S Display/Edit stack pointer
                .DB     $54             ;T Text character string search
                .DB     $58             ;X Display/Edit X register
                .DB     $59             ;Y Display/Edit Y register
;
MONTAB          .DW     RESET           ;[CNTL-R] $12 Reset
                .DW     INIMACRO        ;( $28 Clear keystroke input buffer, reset buffer pointer
                .DW     RUNMACRO        ;) $29 Run keystroke macro from start of keystroke buffer
                .DW     ARG             ;A $41 Examine/change ACCUMULATOR preset/result
                .DW     CPMVFL          ;C $43 Compare memory command
                .DW     MDUMP           ;D $44 HEX/TEXT dump from specified memory address
                .DW     CPMVFL          ;F $46 Fill a specified memory range with a specified value
                .DW     GO              ;G $47 Begin program code execution at a specified address
                .DW     SRCHBYT         ;H $48 Search memory for a specified byte string
                .DW     CPMVFL          ;M $4D Copy memory range to a specified target address
                .DW     PRG             ;P $50 Examine/change PROC STATUS REGISTER preset/result
                .DW     PRSTAT          ;R $52 Display all preset/result contents
                .DW     SRG             ;S $53 Examine/change STACK POINTER preset/result
                .DW     SRCHTXT         ;T $54 Search memory for a specified text string
                .DW     XRG             ;X $58 Examine/change X-REGISTER preset/result
                .DW     YRG             ;Y $59 Examine/change Y-REGISTER preset/result
;
;**************************************************************************************************
;               C02Monitor message strings used with PROMPT routine, terminated with $00
;
MSG_00          .DB     " cont?"
MSG_01          .DB     "(y/n)"
                .DB     $00
MSG_02          .DB     $0D,$0A
                .DB     "   "
MSG_03          .DB     " addr:"
                .DB     $00
MSG_04          .DB     " len:"
                .DB     $00
MSG_05          .DB     " val:"
                .DB     $00
MSG_06          .DB     " src:"
                .DB     $00
MSG_07          .DB     " tgt:"
                .DB     $00
MSG_08          .DB     " find txt:"
                .DB     $00
MSG_09          .DB     " find bin:"
                .DB     $00
MSG_0A          .DB     "not "
MSG_0B          .DB     "found"
                .DB     $00
MSG_0C          .DB     $0D,$0A
                .DB     "search- "
                .DB     $00
MSG_0D          .DB     $0D,$0A
                .DB     "(n)ext? "
                .DB     $00
MSG_0E          .DB     "SP:$"
                .DB     $00
MSG_0F          .DB     "SR:$"
                .DB     $00
MSG_10          .DB     "YR:$"
                .DB     $00
MSG_11          .DB     "XR:$"
                .DB     $00
MSG_12          .DB     "AC:$"
                .DB     $00
MSG_13          .DB     $0D,$0A
                .DB     "   PC  AC XR YR SP NV-BDIZC",$0D,$0A
                .DB     "; "
                .DB     $00
MSG_14          .DB     "Micromon V1.2"
                .DB     $0D,$0A
                .DB     "K.E. Maier"
                .DB     $07
                .DB     $00
MSG_15          .DB     $0D,$0A
                .DB     ";-"
                .DB     $00
MSG_16          .DB     "RESET "
                .DB     $00
;
MSG_TABLE       ;Message table: contains address words of each message
                .DW     MSG_00
                .DW     MSG_01
                .DW     MSG_02
                .DW     MSG_03
                .DW     MSG_04
                .DW     MSG_05
                .DW     MSG_06
                .DW     MSG_07
                .DW     MSG_08
                .DW     MSG_09
                .DW     MSG_0A
                .DW     MSG_0B
                .DW     MSG_0C
                .DW     MSG_0D
                .DW     MSG_0E
                .DW     MSG_0F
                .DW     MSG_10
                .DW     MSG_11
                .DW     MSG_12
                .DW     MSG_13
                .DW     MSG_14
                .DW     MSG_15
                .DW     MSG_16
;
;**************************************************************************************************
;END OF MONITOR DATA
;**************************************************************************************************
;START OF BIOS CODE
;**************************************************************************************************
;C02BIOS version used here is 1.2L (6551 is only supported I/O device)
;
;Contains the base BIOS routines in top 1KB of EEPROM
; - Page $FD <256 bytes for 6551 BIOS
; - Page $FE reserved for HW (any decoded mix required for needed hardware devices)
; - Page $FF JMP table, CPU startup, 40 bytes Soft Vectors and HW Config data
; - does I/O init and handles NMI/BRK/IRQ pre-/post-processing routines.
; - sends BIOS message string to console
;**************************************************************************************************
; The following 8 functions are provided by BIOS and available via the JMP
; Table as the last 8 entries from $FF30 - $FF45 as:
; $FF30 BEEP (send audible beep to console)
; $FF33 CHRIN_NW (character input from console, no waiting)
; $FF36 CHRIN (character input from console)
; $FF39 CHROUT (character output to console)
; $FF3C INITCFG (initialize soft config values at $0300 from ROM)
; $FF3F INITCON (initialize 65C51 console 19.2K, 8-N-1 RTS/CTS)
; $FF42 MONWARM (warm start Monitor - jumps to page $03)
; $FF45 MONCOLD (cold start Monitor - jumps to page $03)
;**************************************************************************************************
; Character In and Out routines for Console I/O buffer
;**************************************************************************************************
;
;CHROUT subroutine: takes the character in the ACCUMULATOR and places it in the xmit buffer
; and checks to see if XMIT interrupt is enabled (page $00 flag), if not it enables the chip
; and sets the flag to show it's on. The character sent in the A reg is preserved on exit
; transmit is IRQ driven / buffered with a fixed size of 128 bytes
;
; - 8/10/2014 - modified this routine to always set the Xmit interrupt active with each
; character placed into the output buffer. There appears to be a highly intermittant bug in both
; the 6551 and 65C51 where the Xmit interrupt turns itself off, the code itself is not doing it.
; The I/O and service routines now appear to work in a stable manner on all 6551 and 65C51.
;
CHROUT          PHY                     ;save Y reg
OUTCH           LDY     OCNT            ;get character output count in buffer
                BMI     OUTCH           ;check against limit, loop back if full
                LDY     OTAIL           ;Get index to next spot
                STA     OBUF,Y          ;and place in buffer
                INC     OTAIL           ;Increment Tail pointer
                RMB7    OTAIL           ;Strip off bit 7, 128 bytes only
                INC     OCNT            ;Increment character count
                LDY     #$05            ;Get mask for xmit on
                STY     SIOCOM          ;Turn on xmit irq
OUTC2           PLY                     ;Restore Y reg
                RTS                     ;Return
;
;CHRIN No Waiting subroutine: Check for a character, if none exists, set carry and exit.
; else get character to A reg and return
CHRIN_NW        CLC                     ;Clear carry for no character
                LDA     ICNT            ;Get character count
                BNE     GET_CH          ;Get the character and return
                RTS                     ;and return to caller
;CHRIN subroutine: Wait for a keystroke from input buffer, return with keystroke in A Reg
; receive is IRQ driven and buffered with a fixed size of 128 bytes
CHRIN           LDA     ICNT            ;Get character count
                BEQ     CHRIN           ;If zero (no character, loop back)
GET_CH          PHY                     ;Save Y reg
                LDY     IHEAD           ;Get the buffer head pointer
                LDA     IBUF,Y          ;Get the character from the buffer
                INC     IHEAD           ;Increment head pointer
                RMB7    IHEAD           ;Strip off bit 7, 128 bytes only
                DEC     ICNT            ;Decrement the buffer count
                PLY                     ;Restore Y Reg
                SEC                     ;Set Carry flag for character available
                RTS                     ;Return to caller with character in A reg
;
;**************************************************************************************************
;                                       BRK/IRQ Interrupt service routine
;**************************************************************************************************
;
;The pre-process routine located in page $FF soft-vectors to here:
; The following routines handle BRK and IRQ.
; The BRK handler saves CPU details for register display
; An ASCII null character ($00) is also handled here (send break)
;
;6551 handler
; The 6551 IRQ routine handles both transmit and receive via IRQ
; - each has it's own 128 circular buffer
; - Xmit IRQ is controlled by the handler and the CHROUT routine
;
BREAKEY         CLI                     ;Enable IRQ (BRK sets interrupt flag)
BRKINSTR0       PLY                     ;Restore Y reg
                PLX                     ;Restore X Reg
                PLA                     ;Restore A Reg
                STA     AREG            ;Save A Reg
                STX     XREG            ;Save X Reg
                STY     YREG            ;Save Y Reg
                PLA                     ;Get Processor Status
                STA     PREG            ;Save in PROCESSOR STATUS preset/result
                TSX                     ;Xfrer STACK pointer to X reg
                STX     SREG            ;Save STACK pointer
                PLX                     ;Pull Low RETURN address from STACK then save it
                STX     PCL             ;Store program counter Low byte
                PLY                     ;Pull High RETURN address from STACK then save it
                STY     PCH             ;Store program counter High byte
                BBR4    PREG,DO_NULL    ;Check for BRK bit set
;
; The following subroutine is contained in the base Monitor code
; This call does a register display. Other code can be added if required
;
                JSR     PRSTAT1         ;Display CPU status
DO_NULL         LDA     #$00            ;Clear all PROCESSOR STATUS REGISTER bits
                PHA
                PLP
                STZ     ITAIL           ;Zero out input buffer / reset pointers
                STZ     IHEAD
                STZ     ICNT
WARMVEC         JMP     (WRMMNVEC0)     ;Done BRK service process, re-enter monitor
;Full duplex IRQ handler
;
INTERUPT0       LDA     SIOSTAT         ;Get status register, xfer irq bit to n flag
                BPL     REGEXT          ;if bit7 clear no 6551 irq, exit, else
ASYNC           BIT     #%00001000      ;check receive bit
                BNE     RCVCHR          ;get received character
                BIT     #%00010000      ;check xmit bit
                BNE     XMTCHR          ;send xmit character
;no bits on means CTS went high
                ORA     #%00010000      ;add CTS high mask to current status
IRQEXT          STA     STTVAL          ;update status value
REGEXT          JMP     (IRQRTVEC0)     ;handle next irq or return
;
BUFFUL          LDA     #%00001100      ;buffer overflow flag
                BRA     IRQEXT          ;branch to exit
;
RCVCHR          LDA     SIODAT          ;get character from 6551
                BEQ     BREAKEY         ;If null character, handle BRK routine
;
RCV0            LDY     ICNT            ;get buffer counter
                BMI     BUFFUL          ;check against limit, branch if full
                LDY     ITAIL           ;room in buffer
                STA     IBUF,Y          ;store into buffer
                INC     ITAIL           ;Increment tail pointer
                RMB7    ITAIL           ;Strip off bit 7, 128 bytes only
                INC     ICNT            ;increment character count
                LDA     SIOSTAT         ;get 6551 status reg
                AND     #%00010000      ;check for xmit
                BEQ     REGEXT          ;exit
;
XMTCHR          LDA     OCNT            ;any characters to xmit?
                BEQ     NODATA          ;no, turn off xmit
OUTDAT          LDY     OHEAD           ;get pointer to buffer
                LDA     OBUF,Y          ;get the next character
                STA     SIODAT          ;send the data
                INC     OHEAD           ;Increment head pointer
                RMB7    OHEAD           ;Strip off bit 7, 128 bytes only
                DEC     OCNT            ;Decrement counter
                BNE     REGEXT          ;If not zero, exit and continue normal stuff
NODATA          LDY     #$09            ;get mask for xmit off / rcv on
                STY     SIOCOM          ;turn off xmit irq bits
                BRA     REGEXT          ;exit
;
;**************************************************************************************************
;                                       END OF BIOS CODE
;**************************************************************************************************
                .ORG    $FE00           ;Reserved for I/O page - do NOT put code here
;**************************************************************************************************
;
;START OF TOP PAGE - DO NOT MOVE FROM THIS ADDRESS!!
                .ORG    $FF00           ;JMP Table, HW Vectors, Cold Init and Vector handlers
;JUMP Table starts here:
; - BIOS calls are from the top down - total of 8
; - Monitor calls are from the bottom up - total of 16
; - Reserved calls are in the shrinking middle
;
                JMP     RDLINE
                JMP     RDCHAR
                JMP     HEXIN2
                JMP     HEXIN4
                JMP     BIN2ASC
                JMP     ASC2BIN
                JMP     DOLLAR
                JMP     PRBYTE
                JMP     PRWORD
                JMP     PRASC
                JMP     PROMPT
                JMP     PROMPT2
                JMP     CONTINUE
                JMP     CROUT
                JMP     SPC
                JMP     BSOUT
;
                JMP     BEEP
                JMP     CHRIN_NW
                JMP     CHRIN
                JMP     CHROUT
                JMP     INIT_SOFT
                JMP     INIT_6551
WMBV            JMP     (WRMMNVEC0)
CDBV            JMP     (CLDMNVEC0)
;
COLDSTRT        CLD                     ;Clear decimal mode in case of software call
                SEI                     ;Disable Interrupt for same reason as above
                LDX     #$00            ;Index for length of page
PAGE0_LP        STZ     $00,X           ;Zero out Page Zero
                DEX                     ;Decrement index
                BNE     PAGE0_LP        ;Loop back till done
                DEX                     ;LDX #$FF ;-)
                TXS                     ;Set Stack Pointer
                JSR     INIT_SOFT       ;Init default Vectors/HW Config to $0300
                JSR     INIT_6551       ;Init I/O - Console
;
;Send BIOS init msg to console
; - note: X reg is zero on return from INIT_6551
BMSG_LP         LDA     BIOS_MSG,X      ;Get BIOS init msg
                BEQ     CDBV            ;If zero, msg done, goto cold start monitor
                JSR     CHROUT          ;Send to console
                INX                     ;Increment Index
                BRA     BMSG_LP         ;Loop back until done
;
INIT_SOFT       SEI                     ;Disable Interrupts
                LDX     #$28            ;Set count for 40 bytes
DATA_XFLP       LDA     VEC_TABLE-1,X   ;Get ROM table data
                STA     SOFTVEC-1,X     ;Store in Soft table location
                DEX                     ;Decrement count
                BNE     DATA_XFLP       ;Loop back till done
                CLI                     ;Re-enable interupts
                RTS                     ;Return to caller
;
;Init the 65C51
INIT_6551       SEI                     ;Disable Interrupts
                STZ     SIOSTAT         ;write to status reg, reset 6551
                STZ     STTVAL          ;zero status pointer
                LDX     #$02            ;Get count of 2
INIT_6551L      LDA     LOAD_6551-1,X   ;Get Current config parameters for 6551
                STA     SIOBase+1,X     ;Write to the 6551
                DEX                     ;Decrement count
                BNE     INIT_6551L      ;Loop back until done
                CLI                     ;Re-enable Interrupts
RET             RTS                     ;Return to caller
;
;This is the ROM start for the BRK/IRQ handler
IRQ_VECTOR      PHA                     ;Save A Reg
                PHX                     ;Save X Reg
                PHY                     ;Save Y Reg
                TSX                     ;Get Stack pointer
                LDA     $0100+4,X       ;Get Status Register
                AND     #$10            ;Mask for BRK bit set
                BNE     DO_BRK          ;If set, handle BRK
                JMP     (IRQVEC0)       ;Jump to Soft vectored IRQ Handler
DO_BRK          JMP     (BRKVEC0)       ;Jump to Soft vectored BRK Handler
;
;This is the standard return for the IRQ/BRK handler routines
IRQ_EXIT0       PLY                     ;Restore Y Reg
                PLX                     ;Restore X Reg
                PLA                     ;Restore A Reg
NMIHNDLR0       RTI                     ;Return from IRQ/BRK routine
;
;**************************************************************************************************
;                                       START OF PANIC ROUTINE
;**************************************************************************************************
; The Panic routine is for debug of system problems, i.e., a crash
; The basic idea is to have an NMI trigger button which is manually operated
; when the system crashes or malfunctions, press the NMI (panic) button
; The NMI vectored routine will perform the following tasks:
; Save all CPU registers in page $00
; Zero I/O buffer pointers
; Call the ROM routines to init the vectors and config data (page $03)
; Call ROM routines to init the 6551 console
; Restart the Monitor via warm start vector
; No memory is cleared except the required pointers to restore the system
; - suggest invoking the Register command afterwards to get the details saved.
;
NMI_VECTOR      SEI                     ;Disable interrupts
                STA     AREG            ;Save A Reg
                STX     XREG            ;Save X Reg
                STY     YREG            ;Save Y Reg
                PLA                     ;Get Processor Status
                STA     PREG            ;Save in PROCESSOR STATUS preset/result
                TSX                     ;Get Stack pointer
                STX     SREG            ;Save STACK POINTER
                PLA                     ;Pull RETURN address from STACK
                STA     PCL             ;Store Low byte
                PLA                     ;Pull high byte
                STA     PCH             ;Store High byte
                LDX     #$06            ;Get count of 6
PAN_LP1         STZ     ICNT-1,X        ;Zero out console I/O pointers
                DEX                     ;Decrement index
                BNE     PAN_LP1         ;Branch back till done
                JSR     INIT_SOFT       ;Xfer default Vectors/HW Config to $0300
                JSR     INIT_6551       ;Init I/O - Console
                JMP     (NMIRTVEC0)     ;Jump to NMI Return Vector
;
;**************************************************************************************************
;START OF BIOS DEFAULT VECTOR DATA AND HARDWARE CONFIGURATION DATA
;
;The default location for the NMI/BRK/IRQ Vector data is at location $0300
; details of the layout are listed at the top of the source file
; there are 8 main vectors and 4 vector inserts
;
;The default location for the hardware configuration data is at location $0320
; it is mostly a freeform table which gets copied from ROM to page $03
; the default size for the config table is 16 bytes, 14 bytes are freeform
;Vector table data for default ROM handlers
;
VEC_TABLE       .DW     NMI_VECTOR      ;NMI Location in ROM
                .DW     BRKINSTR0       ;BRK Location in ROM
                .DW     INTERUPT0       ;IRQ Location in ROM
                .DW     NMIHNDLR0       ;NMI return handler in ROM
                .DW     IRQ_EXIT0       ;BRK return handler in ROM
                .DW     IRQ_EXIT0       ;IRQ return handler in ROM
                .DW     MONITOR         ;Monitor Cold start
                .DW     NMON            ;Monitor Warm start
;
;Vector Inserts (total of 4)
; as NMI/BRK/IRQ and the Monitor are vectored, all can be extended
; by using these reserved vectors.
                .DW     $FFFF           ;Insert 0 Location
                .DW     $FFFF           ;Insert 1 Location
                .DW     $FFFF           ;Insert 2 Location
                .DW     $FFFF           ;Insert 3 Location
;
CFG_TABLE       ;Configuration table for hardware devices
;
CFG_6551        .DB     $09             ;Default 65C51 Cmd reg, Rcv IRQ enabled
                .DB     $1F             ;Default 65C51 Ctl reg, (19.2K, 8-N-1)
;
;Reserved for additional I/O devices (14 bytes total)
                .DB     $FF,$FF,$FF,$FF,$FF,$FF
                .DB     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
;
;END OF BIOS VECTOR DATA AND HARDWARE DEFAULT CONFIGURATION DATA
;**************************************************************************************************
;BIOS init message - sent before jumping to the monitor coldstart vector
BIOS_MSG        .DB     $0D,$0A         ;BIOS startup message
                .DB     "65C02 "
                .DB     "BIOS V1.2L"
                .DB     $0D,$0A         ;Add CR/LF
                .DB     #$00            ;Terminate string
;
                .ORG    $FFFA           ;65C02 Hardware Vectors
                .DW     NMIVEC0         ;NMI
                .DW     COLDSTRT        ;RESET
                .DW     IRQ_VECTOR      ;IRQ
;**************************************************************************************************
                .END