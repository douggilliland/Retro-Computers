; Interrupt example 1.
; Example of sending characters in an interrupt-driven fashion.
;
; Uses a 6850 ACIA which must have its INT* line connnected to the
; CPU/IRQ line.

; Equates

intvec  equ  $7f00              ; Address of IRQ handler in MONDEB.
aciac   equ  $a000              ; 6850 ACIA status/control register.
aciad   equ  $a001              ; 6850 ACIA data register.
eos     equ  $00                ; End of string character (NULL).
cr      equ  $0d                ; Carriage return.
nl      equ  $0a                : Newline.

; Main program

        org     $1000

; Disable interrupts to start.

start   orcc    #%00010000      ; SEI (mask interrupts).

; Set up ACIA control register to send interrupts when TDRE true.
; Receive interrupt disabled. Output /RTS=low and enable Tx Interrupt.
; Data format 8N1. CLK/16

        lda     #3              ; Reset ACIA
        sta     aciac
        lda     #%00110101      ; Control register setting.
        sta     aciac           ; Initialize ACIA to 8 bits and no parity.

; Set IRQ vector to call our handler routine.

        ldx     #handler        ; This only works with MONDEB monitor.
        stx     intvec

; Buffer contains string to send.
; Initialize bufptr to point to start of string.

        ldx     #buffer
        stx     bufptr

; Run CWAI # to enable interrupts
; Loop back forever

;forever cwai    #%11101111      ; Enable IRQ
;        bra     forever

; Alternative code to above. Enable interrupts and perform SYNC.

        andcc   #%11101111      ; CLI (enable IRQ)
forever sync
        bra     forever

; Third option to above. Run code to increment a 16-bit value in a
; loop. Gets interrupted to output characters to ACIA.

;        ldx     #0              ; Initialize counter to $0000
;        stx     counter
;        andcc   #%11101111      ; CLI (enable IRQ)
;forever ldx     counter         ; Increment 16-bit counter
;        leax    1,x
;        stx     counter
;        bra     forever

; IRQ Handler:

; If next character (pointed to by bufptr) is not a null:
;   Write next character (pointed to by bufptr) to ACIA data register
;   Increment bufptr to point to next address.
; Return from interrupt.


handler lda    [bufptr]        ; Get character.
        cmpa   #eos            ; End of string character?
        beq    done            ; Branch to return if end of string.
        sta    aciad           ; Write to ACIA (also clears interrupt).
        ldx    bufptr          ; Get buffer pointer.
        leax   1,x             ; Do 16-bit increment.
        stx    bufptr          ; Save it.
done    rti                    ; Return from interrupt.

; Data

        org     $2000
bufptr  rmb     2               ; Pointer to next available point in data buffer
counter rmb     2               ; 16-bit counter
buffer  fcc     "This is a test of interrupt driven serial output." ; Data buffer
        fcb     cr,nl
        fcb     eos             ; End of string indicator
