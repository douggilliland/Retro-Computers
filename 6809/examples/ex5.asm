; Example of embedded string printer.

; Defines

LF      equ     $0A             ; Line feed
CR      equ     $0D             ; Carriage return

; ASSIST09 SWI call numbers

OUTCH   equ     1               ; OUTPUT CHAR FROM A REG

; Main program

        org     $1000           ; Start address

        bsr     Imprint         ; Call string printer
        fcc     "Hello, world!"
        fcb     CR,LF,0

        bsr     Imprint         ; Call string printer
        fcc     " GREETINGS "
        fcb     0

        bsr     Imprint         ; Call string printer
        fcc     "And hello again."
        fcb     CR,LF,0

        rts 

; Embedded string printer. Examines the stack to find the embedded
; string right after the call to this routine. Outputs one character
; at a time until a 0 marker is found. Then it returns to the calling
; program just beyond the string. Note: If you forget the terminating
; zero marker, it will likely crash on return.
;
; Registers changed: none

Imprint pshs    a,x             ; Save registers used (3 bytes).
        ldx     3,s             ; Pull return address from stack (points to start of string).
next    lda     0,x+            ; Get a character to print, increment pointer.
        beq     eos             ; Branch if terminating null reached.
        swi                     ; Call monitor routine to print character.
        fcb     OUTCH           ; System call.
        bra     next            ; Repeat for next character.

; X now points past string to next instruction, where we want to return.

eos     stx     3,s             ; Save return address on stack.
        puls    a,x             ; Restore registers used (3 bytes).
        rts                     ; And return.
