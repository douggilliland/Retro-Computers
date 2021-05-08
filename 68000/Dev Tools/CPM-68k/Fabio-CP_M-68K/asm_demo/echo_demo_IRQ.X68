;==================================================================================
;
; 68k-MBC - HW ref: A091020, A091020-R140221 (or following HW revisions unless stated otherwise)
;
; Echo demo using CPU interrupt on char available on serial 1
;
; REQUIRED: IOS S310121 (or following SW revisions unless stated otherwise)
;
; Assemble with the Easy68K editor/assembler.
;
;
;
; WARNING: This demo can be uploaded into the target board (68k-MBC) only using the sLoad 
;          boot option of IOS since the loading address is not compatible with the the IOS loading 
;          parameters for the AUTOBOOT.BIN file.
;
;
;
; NOTE 1: When using the CPU interrupt the IOS opcode operations must be treated as atomic 
;         operations, so CPU interrupts must be disabled before and re-enabled after
;  
; NOTE 2: This demo can run only on the Full HW configuration option board, as the IRQ are required
;         (Lite HW configuration option doesn't support CPU IRQ)
;
; NOTE 3: Note how the IO-OP led behavior is changed when IRQ are enabled. Now the IO-OP led
;         is normally off as no polling is done, and blinks only when an IRQ occurs.
;
; Easy68K can be downloaded here: 
; http://web.archive.org/web/20200113112413/http://www.easy68k.com/files/SetupEASy68K.exe
;
;==================================================================================

; IOS equates
IOBASE      EQU     $FFFFC              ; Address base for the I/O ports
EXCWR_PORT  EQU     IOBASE+0            ; Address of the EXECUTE WRITE OPCODE write port
EXCRD_PORT  EQU     IOBASE+0            ; Address of the EXECUTE READ OPCODE read port
STOPC_PORT  EQU     IOBASE+1            ; Address of the STORE OPCODE write port
SER1RX_PORT EQU     IOBASE+1            ; Address of the SERIAL 1 RX read port 
SYSFLG_PORT EQU     IOBASE+2            ; Address of the SYSFLAGS read port
SER2RX_PORT EQU     IOBASE+3            ; Address of the SERIAL 2 RX read port
USRLED_OPC  EQU     $00                 ; USER LED opcode
SER1TX_OPC  EQU     $01                 ; SERIAL 1 TX opcode
SETIRQ_OPC  EQU     $02                 ; SETIRQ opcode
SELDISK_OPC EQU     $09                 ; SELDISK opcode
SELTRCK_OPC EQU     $0A                 ; SELTRACK opcode
SELSECT_OPC EQU     $0B                 ; SELSECT opcode
WRTSECT_OPC EQU     $0C                 ; WRITESECT opcode
SER2TX_OPC  EQU     $10                 ; SERIAL 2 TX opcode
ERRDSK_OPC  EQU     $85                 ; ERRDISK opcode
RDSECT_OPC  EQU     $86                 ; READSECT opcode
SDMOUNT_OPC EQU     $87                 ; SDMOUNT opcode
FLUSHBF_OPC EQU     $88                 ; FLUSHBUFF opcode

; Common ASCII codes
cr          EQU     $0d                 ; Carriage return
lf          EQU     $0a                 ; Line feed
eos         EQU     0                   ; End of string


            ORG     $40*4               ; Vector 0x40 (Serial 1 Rx ISR vector)
            DC.L    RxISR

            ORG     $0400
            
    ;
    ; Serial 1 Rx ISR
    ;
RxISR:     
    move.l  d0,-(sp)                    ; Save D0
    move.b  (SER1RX_PORT).l,RxChar      ; Yes, read it and save
    move.b  #1,RxFlag                   ; Set the valid char flag
RxISRend:    
    move.l  (sp)+,d0                    ; Restore D0
    rte
    
    ;
    ; Start of program
    ;        
start:
    ; NOTE: the SSP is already set at $1000 by the IOS load routine
    move.b  (SYSFLG_PORT).l,d0          ; D0.B = SYSFLAGS IOS register
    btst    #3,d0                       ; Lite HW configuration detected? (bit3 = 1?)
    bne     LiteHW                      ; Yes, jump
    lea     Msg2,a1                     ; No, Print a message
    bsr     puts
    andi    #$a01f,sr                   ; Enable CPU IRQ (I2 = I1 = I0 = 0)
    lea     Msg4,a1                     ; Print a message
    bsr     puts
    move.b  #SETIRQ_OPC,(STOPC_PORT).l  ; Write SETIRQ opcode to IOS
    move.b  #1,(EXCWR_PORT).l           ; Enable IPL1 activation from IOS on serial 1 Rx
    lea     Msg3,a1                     ; Print a message
    bsr     puts
    lea     Msg1,a1                     ; Print a message and the prompt
    bsr     puts
loop:
    bsr     getc                        ; Read or wait a char
    bsr     putc                        ; Print it
    jmp     loop                        ; For ever...
    
LiteHW:
    lea     Msg5,a1                     ; Print a message...
    bsr     puts
    bsr     abort                       ; ...and abort
    
; =========================================================================== ;
;
; Send a string to the serial port, A1 = pointer to the string.
; NOTE: Only D0.B and A1 are used
;
; =========================================================================== ;
puts:
    move.b  (a1)+,d0                    ; D0.B = current char to print
    cmp.b   #eos,d0                     ; Is it an eos?
    beq     puts_end                    ; Yes, jump
    bsr     putc                        ; No, print it
    bra     puts
puts_end:
    rts
    
; =========================================================================== ;
;
; Send a char to the serial port, D0.B = char to send.
;
; =========================================================================== ;
putc:
    ori     #$0700,sr                   ; Disable CPU IRQ (I2 = I1 = I0 = 1)
    move.b  #SER1TX_OPC,(STOPC_PORT).l  ; Write SERIAL 1 TX opcode to IOS
    move.b  d0,(EXCWR_PORT).l           ; Print current char
    andi    #$a01f,sr                   ; Re-enable CPU IRQ (I2 = I1 = I0 = 0)
    rts
    
; =========================================================================== ;
;
; Read a char from the serial port or wait for it.
; D0.B returns the char.
;
; =========================================================================== ;

getc:
    tst.b   RxFlag
    beq     getc                        ; Jump if no char is present
    ori     #$0700,sr                   ; Disable CPU IRQ (I2 = I1 = I0 = 1)
    move.b  RxChar,d0                   ; D0.B = char
    clr.b   RxFlag                      ; Clear the flag
    andi    #$a01f,sr                   ; Re-enable CPU IRQ (I2 = I1 = I0 = 0)
    rts

; =========================================================================== ;
;
; Abort the demo.
; Prints a message and halt.
;
; =========================================================================== ;
abort:
    lea     Msg6,a1
    bsr     puts
    ;
    ; Halt the CPU and set the HALT output pin active.
    ; To do that we intentionally cause a double exception error loading an illegal address 
    ; in the Address Error Exception vector ($0C) and in the Privilege Violation Exception 
    ; vector ($20), and than generating a privilege violation exception with the instruction 
    ; STOP $0700 that sets to 0 the protected mode bit inside the System Status Register (SSR)
    ;
    move.l  #1,$20.l                    ; Store an illegal address (any odd number) in the Privilege Exception vector
    move.l  #1,$c.l                     ; Store an illegal address (any odd number) in the Address Error Exception vector 
    stop    #$0700                      ; Halt the CPU with a double exception error


Msg1        DC.B    'Echo test (with IRQ) using the serial port 1', cr, lf, '>', eos
RxChar      DC.B    0
Msg2        DC.B    'Full HW option detected', cr, lf, eos
Msg3        DC.B    'IOS IRQ enabled', cr, lf, eos
Msg4        DC.B    'CPU IRQ enabled', cr, lf, eos
Msg5        DC.B    'Lite HW option detected - Cannot execute here!', cr, lf, eos
Msg6        DC.B    ' * CPU halted * ', cr, lf, eos
RxFlag      DC.B    0                   ; 0 = no char in RxChar 

            END     start


