;==================================================================================
;
; sLoad - S-record Loader - S180221
; 68k-MBC - HW ref: A091020, A091020-R140221 (or following HW revisions unless stated otherwise)
;
; REQUIRED: IOS S310121 (or following SW revisions unless stated otherwise)
;
; Assemble with the Easy68K editor/assembler.
;
;
; Easy68K can be downloaded here: 
; http://web.archive.org/web/20200113112413/http://www.easy68k.com/files/SetupEASy68K.exe
;
;
; CREDITS:
;
; The basic code to decode the S-record stream was taken from here:
; https://www.retrobrewcomputers.org/doku.php?id=builderpages:plasmo:kuno
;
;
;
;---------------------------------------------------------------------------------
;
;
;
; CHANGELOG:
;
;
; S091020           First revision;
;
;
;==================================================================================
;
; sLoad loads a 68008 executable in Motorola S-record format and executes it. 
;
; Please note that the source is relative to a 512KB RAM configuration. This works 
; on a 128KB RAM configuration too because the 128KB RAM is mirrored in the 0x00000 - 0xF7FFF 
; address range (Bank 0) on both the Lite and the Full HW configuration of the 68k-MBC.
; The only difference between the 512KB and 128KB RAM configuration is the value of the 
; highest allowed address for the user program, and this value is changed by the loader at runtime.
; 
; If the 1024KB RAM configuration is detected, the loader copy itself (the code is relocatable) 
; in the upper area of Bank 1 (0x80000 - 0xFFFFF) starting from 0xF8000 (the address range 
; 0xFC000 - 0xFFFFF is reserved for I/O for the Full HW configuration of the 68k-MBC).
;
; The following S-record types are recognized and allowed: S0, S1, S2, S5, S8.
;
; The S0 and S5 are simply ignored and no check is performed.
; The S8 type must be the last one and activates the jump to the loaded
; binary.
;
; The starting address (the address where sLoad jumps after the loading) is 
; that one contained in the S8 record.
;
; sLoad supports only upper case chars inside the S-record stream.
;
; sLoad checks for errors in the S-record stream, and if the S-record streams attempts 
; to overwrite it (illegal address error).
;
;---------------------------------------------------------------------------------
; 
;  Physical memory layout (not in scale) - 128KB RAM:
;
;  +---------------+
;  !    0x00000    !    Free area available for the user executable 
;  !  -----------  !
;  !    0x1BFFF    !
;  +---------------+
;  !    0x1C000    !    sLoad (local data area + program + reserved area)
;  !  -----------  !    
;  !    0x1FFFB    !
;  +---------------+
;  !    0x1FFFC    !    I/O address space "mirrored area" for Lite HW configuration (4 bytes)
;  !  -----------  !    
;  !    0x1FFFF    !
;  +---------------+
; 
; The available physical memory area for the user program is from address 0x00000 to 
; 0x1BFFF (114.688 bytes).
;
;---------------------------------------------------------------------------------
; 
;  Physical memory layout (not in scale) - 512KB RAM:
;
;  +---------------+
;  !    0x00000    !    Free area available for the user executable 
;  !  -----------  !
;  !    0x7BFFF    !
;  +---------------+
;  !    0x7C000    !    sLoad (local data area + program + reserved area)
;  !  -----------  !    
;  !    0x7FFFB    !
;  +---------------+
;  !    0x7FFFC    !    I/O address space "mirrored area" for Lite HW configuration (4 bytes)
;  !  -----------  !    
;  !    0x7FFFF    !
;  +---------------+
; 
; The available physical memory area for the user program is from address 0x00000 to 
; 0x7BFFF (507.904 bytes).
;
;---------------------------------------------------------------------------------
;
;
;  Physical memory layout (not in scale) - 1024KB RAM:
;
;  +---------------+
;  !    0x00000    !    Free area available for the user executable 
;  !  -----------  !
;  !    0xF7FFF    !
;  +---------------+
;  !    0xF8000    !    sLoad (local data area + program + reserved area)
;  !  -----------  !    after runtime relocation
;  !    0xFBFFF    !
;  +---------------+
;  !    0xFC000    !    I/O address space for Full HW configuration (16KB)
;  !  -----------  !    
;  !    0xFFFFF    !
;  +---------------+
; 
; 
; The available physical memory area for the user program is from address 0x00000 to 
; 0xF7FFF (1.015.808 bytes).
; 
;==================================================================================
;
; IOS equates
IOBASE      EQU     $ffffc              ; Address base for the I/O ports
EXCWR_PORT  EQU     IOBASE+0            ; Address of the EXECUTE WRITE OPCODE write port
EXCRD_PORT  EQU     IOBASE+0            ; Address of the EXECUTE READ OPCODE read port
STOPC_PORT  EQU     IOBASE+1            ; Address of the STORE OPCODE write port
SERRX_PORT  EQU     IOBASE+1            ; Address of the SERIAL RX read port 
SYSFLG_PORT EQU     IOBASE+2            ; Address of the SYSFLAGS read port
SERTX_OPC   EQU     $01                 ; SERIAL TX opcode

; Assembler switches
SLOAD       EQU     0                   ; SLOAD = 0 for normal binary generation, 
                                        ; SLOAD = 1 for sLoad loading (for testing using a previous sLoad)

; Common ASCII codes
cr          EQU     13
lf          EQU     10
sp          EQU     32
esc         EQU     $1B
eos         EQU     0

; Others equates
RAMCHK1     EQU     $55                 ; RAM check test pattern 1
RAMCHK2     EQU     $AA                 ; RAM check test pattern 2

; RAM references
            IFEQ    SLOAD
START512    EQU     $7c000              ; sLoad Starting address (128/512/1024KB RAM) for normal binary generation
            ENDC
            IFNE    SLOAD
START512    EQU     $7b000              ; Sload Starting address (512KB/1024KB RAM only, change to $1b000 for 128KB)
                                        ;  for testing using a previous working sLoad
            ENDC
STACK512    EQU     $7fffa              ; Stack bottom (512KB RAM)- (must be even!)
                                        ; NOTE: This leaves 4 bytes reserved for I/O address overlapping mirrored
                                        ;       from the upper address space (0x7fffc - 0x7ffff mirrored 
                                        ;       from 0xffffc - 0xfffff) for the Lite HW configuration.
MAXADDR512  EQU     START512-1          ; Maximum allowed RAM address for loading (512KB RAM address space)
MAXADDR1024 EQU     $F7FFF              ; Maximum allowed RAM address for loading (1024KB RAM address space)

            ORG     START512            ; sLoad Starting address

start:
    lea     STACK512,sp                 ; Set the stack
    lea     Msg1(pc),a1                 ; Print a message
    bsr     puts
    bsr     checkRam                    ; Size the RAM and check for Lite/Full HW configuration
    cmp.b   #2,d0                       ; Found 1024KB RAM?
    bne     Ram512                      ; No, jump
    move.l  #(relBlckEnd-relBlck),d0    ; Yes, D0 = bytes to relocate
    lea     relBlck,a0                  ; Set source address in A0
    lea     start1024,a1                ; Set destination address in A1
copyLoop:                               ; Relocate (copy) the code block frm relBlck: to relBlckEnd:
                                        ; to the RAM starting at start1024:
    move.b  (a0)+,(a1)+
    dbra    d0, copyLoop
    lea     end1024>>1<<1,sp            ; Update the SP for the 1024KB RAM configuration (must be even!)
    move.l  #MAXADDR1024,a2             ; Set the maximum allowed address for the loaded program
    jmp     start1024                   ; Jump to the relocated code.
                                        ; Execution continue at the next instruction (relBlck:) 
                                        ; relocated at address start1024
relBlck:
    lea     Msg8(pc),a1                 ; Print 1024KB message
    bsr     puts
    bra     printHwCfg                  ; Print HW configuration message
    
Ram512:
    cmp.b   #1,d0                       ; Found 512KB RAM?
    bne     Ram128                      ; No, jump
    lea     Msg7(pc),a1                 ; Yes, print 512KB message
    bsr     puts
    move.l  #MAXADDR512,a2              ; Set the maximum allowed address for the loaded program
    bra     printHwCfg                  ; Print HW configuration message
    
Ram128:
    lea     Msg6(pc),a1                 ; Print 128KB message
    bsr     puts
    move.l  #MAXADDR512&$1ffff,a2       ; Set the maximum allowed address for the loaded program
printHwCfg:
    move.b  LiteHwFlg(pc),d0            ; D0.B = Lite/full flag
    cmp.b   #1,d0                       ; Found Lite HW configuration?
    beq     printLiteCfg                ; Yes, jump
    lea     Msg10(pc),a1                ; No, print Full HW configuration message
    bsr     puts
    bra     waitMsg                     ; Wait the input stream
    
printLiteCfg:
    lea     Msg9(pc),a1                 ; Print Lite HW configuration message
    bsr     puts
 
waitMsg:    
    lea     Msg1b(pc),a1                ; Print a message
    bsr     puts
    bsr     flush                       ; Flush input buffer if not empty
    clr.l   d5                          ; Clear errors flag D5
cmd:
    bsr     cinq                        ; Get character input    
    bsr     putc                        ; Print it     
    cmp.b   #'S',d0                     ; S record?
    beq     doSload
    moveq   #3,d5                       ; Set error flag D5 = illegal char
    bra     d5Err

Scmd:
    bsr     cinq                        ; Get character input
    bsr     putc
    cmp.b   #$d,d0                      ; CR?
    bne     chkSR
    moveq   #lf,d0
    bsr     putc
    tst.b   d5
    beq     cmd                         ; Jump if no errors
d5Err:
    ;
    ; Analyze the error flag D5 and print a message accordingly
    ;
    cmp.b   #1,d5                       ; D5 error 1: RAM write verify failed
    beq     d5Err1
    cmp.b   #2,d5                       ; D5 error 2: Checksum error
    beq     d5Err2
    cmp.b   #3,d5                       ; D5 error 3: Illegal character
    beq     d5Err3
    bra     abort                       ; Unknown error
                 
chkSR:   
    ;
    ; Read chars until it is a start of an S-record 
    ;     
    cmp.b   #'S',d0                     ; S record?
    beq     doSload
    bra     Scmd                    
doSload:
    bsr     cinq                        ; Get 2nd character
    bsr     putc
    cmp.b   #'0',d0                     ; S0 record?
    beq     Scmd                        ; Ignore all the contents till the CR
    cmp.b   #'1',d0                     ; S1 record
    beq     doS1
    cmp.b   #'2',d0                     ; S2 record?
    beq     doS2
    cmp.b   #'5',d0                     ; S5 record?
    beq     Scmd                        ; Ignore all the contents till the CR
    cmp.b   #'8',d0                     ; S8 record?
    beq     doS8
    bra     error3                      ; Unknown S-record type

doS1:
    ;
    ; 2-byte address field
    ;
    clr.l   d4
    moveq   #1,d2                       ; Get Srecord byte count
    bsr     char2hex
    add.b   d1,d4                       ; Accumulate checksum
    move.w  d1,d3
    subq    #4,d3                       ; Don't count CRC byte for 2-byte address       
    moveq   #3,d2                       ; Get 2-byte starting address
    bsr     char2hex
    add.b   d1,d4                       ; Accumulate checksum, lower address
    ror.w   #8,d1       
    add.b   d1,d4                       ; Accumulate checksum, higher address
    ror.w   #8,d1                       ; Restore D1
    move.l  d1,a0
srdata:
    moveq   #1,d2                       ; Get byte data
    bsr     char2hex
    add.b   d1,d4                       ; Accumulate checksum
    move.b  d1,(a0)                     ; Store value to destination (no need to check address because is only 16 bit wide)
    cmp.b   (a0)+,d1                    ; Write verify
    beq     srdatax
    moveq   #1,d5                       ; D5 = 1 -> RAM write verify failed
srdatax:    
    dbra    d3,srdata
    not.b   d4                          ; D4 = checksum expected
    moveq   #1,d2
    bsr     char2hex
    cmp.b   d1,d4
    beq     Scmd
    moveq   #2,d5                       ; D5 = 2 -> Checksum error
    bra     Scmd
doS2:
    ;
    ; 3-byte address field
    ;
    clr.l   d4
    move.W  #1,d2                       ; Get Srecord byte count
    bsr     char2hex
    add.b   d1,d4                       ; Accumulate checksum
    move.W  d1,d3
    sub.W   #5,d3                       ; Don't count CRC byte for 3-byte address       
    move.W  #5,d2                       ; Get 3-byte starting address
    bsr     char2hex
    add.b   d1,d4                       ; Accumulate checksum, lower address
    ror.l   #8,d1       
    add.b   d1,d4                       ; Accumulate checksum, middle address
    ror.l   #8,d1
    add.b   d1,d4                       ; Accumulate checksum, upper address
    ror.l   #8,d1
    ror.l   #8,d1                       ; Restore D1
    move.l  d1,a0
srdata2:
    move.w  #1,d2                       ; Get byte data
    bsr     char2hex
    add.b   d1,d4                       ; Accumulate checksum
    bsr     ckcAddr                     ; Check the address in A0 before store it
    move.b  d1,(a0)                     ; Store value to destination
    cmp.b   (a0)+,d1                    ; Write verify
    beq     srdata2x
    move.b  #1,d5                       ; D5 = 1 -> RAM write verify failed
srdata2x:
    dbra    d3,srdata2
    not.b   d4                          ; D4 = checksum expected
    move.w  #1,d2
    bsr     char2hex
    cmp.b   d1,d4
    beq     Scmd
    move.b  #2,d5                       ; D5 = 2 -> Checksum error
    bra     Scmd    
    
dos8:
    ;
    ; S8 must be the last one of the S-records stream.
    ; After the correct reception of the S8 record, jump to the 
    ; starting address of the loaded program.
    ;
    ; 3-byte address field
    ;
    clr.l   d4
    move.W  #1,d2                       ; Get Srecord byte count
    bsr     char2hex
    add.b   d1,d4                       ; Accumulate checksum
    move.W  d1,d3
    sub.W   #5,d3                       ; Don't count CRC byte for 3-byte address       
    move.W  #5,d2                       ; Get 3-byte starting address
    bsr     char2hex
    add.b   d1,d4                       ; Accumulate checksum, lower address
    ror.l   #8,d1       
    add.b   d1,d4                       ; Accumulate checksum, middle address
    ror.l   #8,d1
    add.b   d1,d4                       ; Accumulate checksum, upper address
    ror.l   #8,d1
    ror.l   #8,d1                       ; Restore D1
    move.l  d1,a0
    not.b   d4                          ; D4 = checksum expected
    move.w  #1,d2
    bsr     char2hex
    cmp.b   d1,d4
    beq     endS8                       ; End of S-record stream. Jump to the loaded program
    move.b  #2,d5                       ; D5 = 2 -> Checksum error
    bra     Scmd

endS8:    
    ;
    ; Flush input buffer and print the received starting address, than jump to it
    ;
    lea     Msg2(pc),a1
    bsr     puts
    lea     Msg4(pc),a1
    bsr     puts
    bsr     flush                       ; Flush input buffer if not empty 
    lea     Msg5(pc),a1
    bsr     puts
    lea     Msg2(pc),a1                 ; Print starting address
    bsr     puts
    lea     Msg3(pc),a1
    bsr     puts
    move.l  a0,d6
    bsr     printHex24
    lea     crlf(pc),a1
    bsr     puts
    bsr     ckcAddr                     ; Check the starting address in A0
    lea     crlf(pc),a1
    bsr     puts
    jmp     (a0)                        ; Jump to the loaded program
    
; =========================================================================== ;
;  
; Subroutine to get prescribed number of characters in D2+1, 
; convert to hex and put in D1.
;
; =========================================================================== ;
char2hex:
    clr.l   d1                          ; Important to clear all d1 when start
c2h1:
    bsr.s   cinq                        ; Get input character in d0
    bsr     putc
    bsr.s   asc2hex
    cmp.b   #$FF,d0
    bne     c2h1_1
    moveq   #3,d5                       ; D5 = 3-> Illegal character
    bra     d5Err                       ; Jump to print the error
    
c2h1_1:
    lsl.l   #4,d1                       ; Shift left previous value by 4
    add.b   d0,d1                       ; Apend to existing value
    dbra    d2,c2h1
    rts
    
; =========================================================================== ;
;
; Check for valid ascii representation of hexdecimal.
; D0 contains input, return 0xFF if invalid, otherwise hex value.
;
; =========================================================================== ;
asc2hex:
    cmp.b   #'f',d0     
    bhi     aschex9                     ; Not valid, >'f'
    cmp.b   #'a'-1,d0
    bhi     aschex1                     ; 'f'> valid >'a'
    cmp.b   #'F',d0     
    bhi     aschex9                     ; Not valid, >'F'
    cmp.b   #'A'-1,d0
    bhi     aschex3                     ; 'F'> valid >'A'
    cmp.b   #'9',d0
    bhi     aschex9                     ; Not valid >'9'
    cmp.b   #'0'-1,d0
    bhi     aschex2                     ; '9'> valid >'0'
aschex9:
    moveq   #-1,d0                      ; Return 0xFF in not hex
    bra     aschex0
aschex3:
    sub.b   #$37,d0
    bra     aschex0
aschex2:
    sub.b   #$30,d0
    bra     aschex0
aschex1:
    sub.b   #$57,d0                     ; 'a'-'f'
aschex0:    
    rts

; =========================================================================== ;
;
; Read a char from the serial port or wait for it.
; D0.B returns the char.
;
; =========================================================================== ;
cinq:
getc:    
    move.b  (SYSFLG_PORT).l,d0          ; D0.B = SYSFLAG
    btst    #2,d0                       ; Rx char ready? (bit2 = 1?)
    beq     getc                        ; No, jump and wait for a char (Z = 1)
    move.b  (SERRX_PORT).l,d0           ; Yes, read it into D0.B
    rts

; =========================================================================== ;
;
; Send a string to the serial port, A1 = pointer to the string.
;
; =========================================================================== ;
strout:
puts:
    MOVE.l  d0,-(sp)                    ; Save d0
puts1:
    move.b  (a1)+,d0                    ; D0.B = current char to print
    cmp.b   #eos,d0                     ; Is it an eos?
    beq     puts_end                    ; Yes, jump
    move.b  #SERTX_OPC,(STOPC_PORT).l   ; Write SERIAL TX opcode to IOS
    move.b  d0,(EXCWR_PORT ).l          ; Print current char
    bra     puts1
    
puts_end:
    MOVE.l  (sp)+,d0                    ; Restore d0
    rts
    
; =========================================================================== ;
;
; Send a char to the serial port, D0.B = char to send.
;
; =========================================================================== ;
putc:
    move.b  #SERTX_OPC,(STOPC_PORT).l   ; Write SERIAL TX opcode to IOS
    move.b  d0,(EXCWR_PORT ).l          ; Print current char
    rts
    
; =========================================================================== ;
;
; Error3: Illegal S-record type
;
; =========================================================================== ;
error3:    
    lea     Msg2(pc),a1                 ; Print an error message
    bsr     puts
    lea     EMsg5(pc),a1
    bsr     puts
    bra     abort
    
; =========================================================================== ;
;
; D5 error 1: RAM write verify failed
;
; =========================================================================== ;
d5Err1:
    lea     Msg2(pc),a1                 ; Print an error message
    bsr     puts
    lea     EMsg6(pc),a1
    bsr     puts
    bra     abort

; =========================================================================== ;
;
; D5 error 2: Checksum error
;
; =========================================================================== ;
d5Err2:
    lea     Msg2(pc),a1                 ; Print an error message
    bsr     puts
    lea     EMsg7(pc),a1
    bsr     puts
    bra     abort
    
; =========================================================================== ;
;
; D5 error 3: Illegal character
;
; =========================================================================== ;
d5Err3:    
    lea     Msg2(pc),a1                 ; Print an error message
    bsr     puts
    lea     EMsg8(pc),a1
    bsr     puts
    bra     abort
    
; =========================================================================== ;
;
; Print the least significant nibble of D7.B as an hex digit.
;
; =========================================================================== ;
printHex4:
    andi    #$0f,d7
    cmp.b   #9,d7                       ; Digit > 9?
    bcs     digit9                      ; No, jump
    addi.b  #7,d7                       ; Yes, adds A-F ASCII displacement
digit9:
    addi    #48,d7
    move.b  #SERTX_OPC,(STOPC_PORT).l   ; Write SERIAL TX opcode to IOS
    move.b  d7,(EXCWR_PORT ).l          ; Print current char
    rts

; =========================================================================== ;
;
; Print the value in D6.B as a 2 digits hex number.
; The content of D6 remains untouched.
;
; =========================================================================== ;
printHex8:            
    move.b  d6,d7
    ror.b   #4,d7
    bsr     printHex4                   ; Print MSD as hex digit
    move.b  d6,d7
    bsr     printHex4                   ; Print LSD as hex digit
    rts
                 
; =========================================================================== ;
;
; Print the value in D6.W as a 4 digits hex number.
; The content of D6 remains untouched.
;
; =========================================================================== ;
printHex16: 
    ror.l   #8,d6
    bsr     printHex8                   ; Print MSB as 2 hex digit
    rol.l   #8,d6
    bsr     printHex8                   ; Print LSB as 2 hex digit
    rts
            
; =========================================================================== ;
;
; Print the value in D6 (only the rightmost 3 bytes are significant) as 
; a 6 digits hex number.
; The content of D6 remains untouched.
;
; =========================================================================== ;
printHex24: 
    swap    d6
    bsr     printHex8                   ; Print LSB of MSW as 2 hex digit
    swap    d6
    bsr     printHex16                  ; Print LSW as 4 hex digit
    rts           

; =========================================================================== ;
;
; Print the value in D6 as an 8 digits hex number.
; The content of D6 remains untouched.
;
; =========================================================================== ;
printHex32: 
    swap    d6
    bsr     printHex16                  ; Print MSW as 4 hex digit
    swap    d6
    bsr     printHex16                  ; Print LSW as 4 hex digit
    rts  

; =========================================================================== ;
;
; Check that the address in A0 is inside the allowed RAM address space.
; If not an error is printed and the load is aborted.
; The content of A0 remains untouched.
;
; =========================================================================== ;
ckcAddr:
    cmp.l   a2,a0                       ; A0 > A2? (current storage address > 
                                        ; max allowed storage address?)
    bhi     ckcAddrKO                   ; Yes, jump
    rts                                 ; No, return

ckcAddrKO:
    ; Print an error message and halt
    lea     Msg2(pc),a1
    bsr     puts
    lea     EMsg3(pc),a1
    bsr     puts
    move.l  a0,d6
    bsr     printHex24
    lea     crlf(pc),a1
    bsr     puts
    bra     abort
    
; =========================================================================== ;
;
; Flush input buffer (on MCU side).
;
; =========================================================================== ;
flush:
    move.b  (SYSFLG_PORT).l,d0          ; D0.B = SYSFLAG
    btst    #2,d0                       ; Rx char ready? (bit2 = 1?)
    beq     flushed                     ; No, jump (Z = 1)
    move.b  (SERRX_PORT).l,d0           ; Yes, read it into D0.B
    bra     flush
flushed:
    rts

; =========================================================================== ;
;
; Abort the loader.
; Prints a message and halt.
;
; =========================================================================== ;
abort:
    lea     EMsg4(pc),a1
    bsr     puts
    ;
    ; Halt the CPU and set the HALT output pin active.
    ; To do that we intentionally cause a double exception error loading an illegal address 
    ; in the Address Error Ecception vector ($0C) and in the Privilege Vialation Exception 
    ; vector ($20), and than generating a privilege violation exception with the instruction 
    ; STOP $0700 that sets to 0 the protected mode bit inside the System Staus Register (SSR)
    ;
    move.l  #1,$20.l                    ; Store an illegal address (any odd number) in the Privilege Excption vector
    move.l  #1,$c.l                     ; Store an illegal address (any odd number) in the Address Error Excption vector 
    stop    #$0700                      ; Halt the CPU with a double exception error
    
; =========================================================================== ;
;
; Size the available RAM (128KB/512KB/1024KB) and check for Lite/Full HW configuration.
;
; Returns in D0.B a code giving the amount of the RAM: 0 = 128KB, 1 = 512KB, 
; 2 = 1024KB and updates the LiteHwFlg flag.
;
; Used registers: A0, D0.B
;
; =========================================================================== ;
checkRam:
    ;
    ; Check for Lite/Full HW configuration
    ;
    move.b  (SYSFLG_PORT).l,d0          ; D0.B = SYSFLAGS IOS register
    btst    #3,d0                       ; Lite HW configuration detected? (bit3 = 1?)
    bne     checkRam512                 ; Yes, jump and continue the check for 512KB (Z = 0)
    lea     LiteHwFlg(pc),a0            ; No, update the LiteHwFlg flag for Full HW cofiguration
    clr.b   (a0)
    ;
    ; Check for 1024KB RAM
    ;
    move.b  #RAMCHK1,Addr1024           ; Store RAMCHK1 into RAM
    move.b  Addr1024,d0                 ; Read it into D0
    cmp.b   #RAMCHK1,d0                 ; Equal to the original value?
    bne     checkRam512                 ; No, jump and continue the check for 512KB (Z = 0)
    move.b  #RAMCHK2,Addr1024           ; Yes, store RAMCHK2 into RAM
    move.b  Addr1024,d0                 ; Read it into D0
    cmp.b   #RAMCHK2,d0                 ; Equal to the original value?
    bne     checkRam512                 ; No, jump and continue the check for 512KB (Z = 0)
    move.b  #2,d0                       ; Yes, set the value for 1024KB RAM found...
    rts                                 ; ...and return

checkRam512:
    ;
    ; Check for 128KB/512KB RAM
    ;
    move.b  #RAMCHK1,Addr128            ; Store RAMCHK1 into RAM in the first 128KB block
    move.b  Addr512,d0                  ; Read it from a mirrored location into D0
    cmp.b   #RAMCHK1,d0                 ; Equal to the original value?
    bne     found512                    ; No, jump
    move.b  #RAMCHK2,Addr128            ; Yes, store RAMCHK2 into RAM in the first 128KB block
    move.b  Addr512,d0                  ; Read it from a mirrored location into D0
    cmp.b   #RAMCHK2,d0                 ; Equal to the original value?
    bne     found512                    ; No, jump
    clr.b   d0                          ; Yes, set the value for 128KB RAM found...
    rts                                 ; ...and return

found512:
    ;
    ; Found 512KB RAM
    ;
    move.b  #1,d0                       ; Set the value for 512KB RAM found...
    rts                                 ; ...and return

; =========================================================================== ;

LiteHwFlg   DC.B    1                   ; Lite HW configuration flag (1 = Lite config, 0 = Full config)   
crlf        DC.B    cr, lf, eos
Msg1        DC.B    'sLoad - S-record Loader - S180221', cr, lf, eos
Msg1b       DC.B    'Waiting input stream...', cr, lf, lf, eos
Msg2        DC.B    cr, lf
            DC.B    'sLoad: ', eos
Msg3        DC.B    'Starting Address: 0x', eos
Msg4        DC.B    'Flushing input buffer...', eos
Msg5        DC.B    ' done', eos
Msg6        DC.B    '128KB', eos
Msg7        DC.B    '512KB', eos
Msg8        DC.B    '1024KB', eos
Msg9        DC.B    ' - Lite HW configuration', cr, lf, eos
Msg10       DC.B    ' - Full HW configuration', cr, lf, eos
EMsg3       DC.B    'Illegal Address 0x', eos
EMsg4       DC.B    'sLoad: Loader aborted - System halted', cr, lf, eos
EMsg5       DC.B    'Illegal S-record type!', cr, lf, eos
EMsg6       DC.B    'RAM write verify failed!', cr, lf, eos
EMsg7       DC.B    'Checksum error!', cr, lf, eos
EMsg8       DC.B    'Illegal character!', cr, lf, eos

relBlckEnd:                             ; End of the code/data block to be relocated for the
                                        ; 1024K RAM configuration

            ORG     MAXADDR1024+1       ; Start of the Sload code after runtime relocation (1024KB RAM
                                        ;  configuration only)
            
start1024   DS.B    $3fff               ; sLoad area after runtime relocation (1024KB RAM configuration)
end1024:    
        
            ORG     $1aff0
Addr128     DS.B    1                   ; Test byte for 128KB/512KB RAM check

            ORG     $7aff0
Addr512     DS.B    1                   ; Test byte for 128KB/512KB RAM check

            ORG     $fbff0
Addr1024    DS.B    1                   ; Test byte for 1024KB RAM check

            END     start


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
