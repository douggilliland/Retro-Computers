; Simple example of using ASSIST09 monitor service routines to do
; console input and output.

; Character defines

EOT     EQU     $04             ; String terminator
LF      EQU     $0A             ; Line feed
CR      EQU     $0D             ; Carriage return

; ASSIST09 SWI call numbers

INCHNP  EQU     0               ; INPUT CHAR IN A REG - NO PARITY
OUTCH   EQU     1               ; OUTPUT CHAR FROM A REG
PDATA1  EQU     2               ; OUTPUT STRING
PDATA   EQU     3               ; OUTPUT CR/LF THEN STRING
OUT2HS  EQU     4               ; OUTPUT TWO HEX AND SPACE
OUT4HS  EQU     5               ; OUTPUT FOUR HEX AND SPACE
PCRLF   EQU     6               ; OUTPUT CR/LF
SPACE   EQU     7               ; OUTPUT A SPACE
MONITR  EQU     8               ; ENTER ASSIST09 MONITOR
VCTRSW  EQU     9               ; VECTOR EXAMINE/SWITCH
BRKPT   EQU     10              ; USER PROGRAM BREAKPOINT
PAUSE   EQU     11              ; TASK PAUSE FUNCTION

        ORG     $7000           ; Start address

START   LEAX    MSG1,PCR        ; Get address of string to display
        SWI                     ; Call ASSIST09 monitor function
        FCB     PDATA1          ; Service code byte

        SWI                     ; Input character, return in A
        FCB     INCHNP
        STA     CHAR            ; Save the character in memory

        SWI                     ; Print CR/LF
        FCB     PCRLF

        LEAX    MSG2,PCR        ; Get address of string to display
        SWI                     ; Call ASSIST09 monitor function
        FCB     PDATA1          ; Service code byte

        LEAX    CHAR,PCR        ; Get pointer to character
        SWI                     ; Output in hex
        FCB     OUT2HS

        SWI                     ; Print CR/LF
        FCB     PCRLF

        LDA     CHAR            ; Get the character
        CMPA    #'Q             ; Was it Q?
        BNE     START           ; If not, repeat
                                 
        RTS                     ; Otherwise, return to caller

MSG1    FCC     'Type a key (Q to quit): '  ; String to display
        FCB     EOT

MSG2    FCC     'Key code: '    ; String to display
        FCB     EOT

CHAR    RMB     1               ; Holds entered character
