;==================================================================================
;
; 68k-MBC - HW ref: A091020, A091020-R140221 (or following HW revisions unless stated otherwise)
;
; Hello world demo on serial 1
;
; REQUIRED: IOS S310121 (or following SW revisions unless stated otherwise)
;
; Assemble with the Easy68K editor/assembler.
;
;
;
; Easy68K can be downloaded here: 
; http://web.archive.org/web/20200113112413/http://www.easy68k.com/files/SetupEASy68K.exe
;
; NOTE: This demo can be loaded into the target board (68k-MBC) using the sLoad boot option or using the 
;       AUTOBOOT boot option of IOS. To use the AUTOBOOT boot option the .S68 S-record formatted 
;       executable must be converted into a binary file (.bin) using the EASyBIN utility, 
;       and the file renamed as AUTOBOOT.BIN and moved into the root of the SD.
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


            ORG     $0400

START:
    ; NOTE: the SSP is already set at $1000 by the IOS load routine
    lea     MESSAGE,a1
    bsr     puts
    stop    #$2700
   
    
; =========================================================================== ;
;
; Send a string to the serial 1, A1 = pointer to the string.
; NOTE: Only D0.B and A1 are used
;
; =========================================================================== ;
puts:
    move.b  (a1)+,d0                    ; D0.B = current char to print
    cmp.b   #eos,d0                     ; Is it an eos?
    beq     puts_end                    ; Yes, jump
    move.b  #SER1TX_OPC,(STOPC_PORT).l  ; Write SERIAL 1 TX opcode to IOS
    move.b  d0,(EXCWR_PORT).l           ; Print current char
    jmp     puts
    
puts_end:
    rts

MESSAGE     DC.B    'HELLO WORLD! ', cr, lf, eos

            END     START

