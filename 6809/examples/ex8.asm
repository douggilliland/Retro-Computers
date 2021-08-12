; Interrupt example 2.
; Example of receiving characters in an interrupt-driven fashion.
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
        lda     #%10010101      ; Control register setting.
        sta     aciac           ; Initialize ACIA to 8 bits and no parity.

; Set IRQ vector to call our handler routine.

        ldx     #handler        ; This only works with MONDEB monitor.
        stx     intvec

; Buffer contains characters entered.
; Initialize bufptr to point to start of string.

        ldx     #buffer
        stx     bufptr

; Run CWAI # to enable interrupts
; Loop back forever

forever cwai    #%11101111      ; Enable IRQ
        bra     forever

; IRQ Handler:

; Get serial data. Echo it back.
; Write character to buffer.
; Increment bufptr to point to next address.
; If character was Return or Newline, jump to monitor.
; Otherwise, return from interrupt.

handler lda    aciad           ; Get character.
        sta    aciad           ; Echo character back out.
        ldx    bufptr          ; Get buffer pointer
        sta    ,x+             ; Save in buffer and increment pointer.
        stx    bufptr          ; Save new pointer.

        cmpa   #cr             ; Carriage return?
        beq    eol             ; If so, branch.
        cmpa   #nl             ; Line feed?
        beq    eol             ; If so, branch.   
        rti                    ; Return from interrupt.

eol     jmp    [$fffe]         ; Go to monitor via reset vector.

; Data

        org     $2000
bufptr  rmb     2               ; Pointer to next available point in data buffer.
buffer  rmb     132             ; Data buffer.
