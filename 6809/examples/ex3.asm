; Example of adding custom command to ASSIST09 using secondary command
; list. After calling this code from the monitor, typing the command U
; will get an address from the user and then display it.

; Character defines

EOT     EQU     $04             ; String terminator

; ASSIST09 SWI call numbers

PDATA1  EQU     2               ; Output string
OUT4HS  EQU     5               ; Output four hex and space
PCRLF   EQU     6               ; Output CR/LF
VCTRSW  EQU     9               ; Vector swap
.CMDL2  EQU     44              ; Secondary command list

; ASSIST09 Routines and data

CDNUM   EQU     $FE60           ; Note: Only valid for my ROM version
PCNTER  EQU     $6093           ; Stores last PC value


        ORG     $1000           ; Start address

START   LEAX    MYCMDL,PCR      ; Load new handler address
        LDA     #.CMDL2         ; Load subcode for vector swap
        SWI                     ; Request service
        FCB    VCTRSW           ; Service code byte
        RTS                     ; Return to monitor

; Command table.

MYCMDL:
        FCB     4               ; Table entry length
        FCC     'U'             ; Command name
        FDB     UCMD-*          ; Pointer to command (relative to here)
        FCB     $FE             ; -2 indicates end of table

; The actual command.

UCMD:   LBSR    CDNUM           ; Parse command line, return 16-bit number in D
        LEAX    MSG1,PCR        ; Get address of string to display
        SWI                     ; Call ASSIST09 monitor function
        FCB     PDATA1          ; Service code byte
        TFR     D,X             ; Put entered address in X
        BSR     PrintAddress    ; Print it
        SWI                     ; Print CR/LF
        FCB     PCRLF
        RTS                     ; Return to monitor

TEMP    RMB     2               ; Temp variable (used by print routines)

; Print a word as four hex digits followed by a space.
; X contains word to print.
; Registers changed: none
PrintAddress:
        PSHS    A,B,X           ; Save registers used
        STX     TEMP            ; Needs to be in memory so we can point to it
        LEAX    TEMP,PCR        ; Get pointer to it
        SWI                     ; Call ASSIST09 monitor function
        FCB     OUT4HS          ; Service code byte
        PULS    X,B,A           ; Restore registers used
        RTS

MSG1    FCC     'Entered: '
        FCB     EOT
