; Copyright 2020 Jonathan Foucher

; Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
; and associated documentation files (the "Software"), to deal in the Software without restriction, 
; including without limitation the rights to use, copy, modify, merge, publish, distribute, 
; sublicense, and/or sell copies of the Software, and to permit persons to whom the Software 
; is furnished to do so, subject to the following conditions:

; The above copyright notice and this permission notice shall be included in all copies or 
; substantial portions of the Software.

; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
; INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
; PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
; FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
; OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
; DEALINGS IN THE SOFTWARE.




ps2_irq:
    pha
    phx
    lda to_send
    bne @willsend
    lda KB_STATE            ; which state ?
    cmp #KB_STATE_START
    beq @start        ; start bit

    cmp #KB_STATE_DATA             ; get data bits
    beq @data   

    cmp #KB_STATE_PARITY             ; this is the parity bit
    beq @parity       

    cmp #KB_STATE_STOP      ; stop bit
    beq @stop
    jmp @exit

@start:
    lda #KB_STATE_DATA
    sta KB_STATE        ; next state will be to get data
    lda #0
    sta KB_TEMP
    sta KB_BIT
    bra @exit
@willsend:
    jmp @sending
@data:
    lda PORTB       ; get the bit of data from PORTB bit 7
    and #$80
    ora KB_TEMP     ; OR it with existing temp data
    sta KB_TEMP     ; save it
    inc KB_BIT      ; prepare for next bit
    lda KB_BIT
    cmp #8          ; if this is the last bit, next state is parity
    beq @next_state_parity
    lsr KB_TEMP     ; if not last bit, shift KB_TEMP right to prepare for next bit

    bra @exit

@next_state_parity:
    lda #KB_STATE_PARITY    ;next state is parity
    sta KB_STATE
    bra @exit

@parity:
    lda #KB_STATE_STOP      ;next state is stop
    sta KB_STATE
    bra @exit

@stop:
    lda #KB_STATE_START
    sta KB_STATE
    lda ignore_next
    bne @ignored
    ; Save key to character buffer
    ldx KB_TEMP
    cpx #$AA
    beq @init
    cpx #$FA
    beq @init
    cpx #$F0
    beq @ignore_next
    cpx #LSHIFT_KEY
    beq @shift_pressed
    cpx #RSHIFT_KEY
    beq @shift_pressed
    lda control_keys
    and #SHIFT
    bne @shifted
@unshifted:
    ;stx PORTA
    lda ASCIITBL, x

    cmp #$1B             ; reset if escape pressed
    beq @esc
    bra @output
@shifted:
    lda ASCIITBL+128, x
@output:
    ldx KB_BUF_W_PTR
    sta KB_BUF, x
    ;sta PORTA
    inc KB_BUF_W_PTR

@exit:
    bit PORTB
    plx
    pla
    rts
@esc:
    jmp v_reset
@init:
    stx ready
    bra @exit

@ignore_next:
    lda #1
    sta ignore_next
    bra @exit

@ignored:
    ldx KB_TEMP
    cpx #LSHIFT_KEY
    beq @shift_released
    cpx #RSHIFT_KEY
    beq @shift_released
    lda #0
    sta ignore_next
    bra @exit

@shift_released:
    lda #0
    sta ignore_next
    lda #0
    sta control_keys
    bra @exit

@shift_pressed:
    lda control_keys
    ora #shift
    sta control_keys
    bra @exit

@sending:
    ; lda #1
    ; sta PORTA
    ; data pin of DDRB should be set as output by prepare_send
    lda KB_STATE                ; which state ?
    cmp #KB_STATE_DATA          ; send data bits
    beq @sending_data   
    cmp #KB_STATE_PARITY        ; this is the parity bit
    beq @sending_parity       
    cmp #KB_STATE_STOP          ; stop bit
    beq @sending_stop
    bra @exit


@sending_data:
    ; lda #4
    ; sta PORTA
    lda to_send       ; get the bit of data from memory
    and #$01          ; get only bottom bit
    beq @send_zero

@send_one:
    lda PORTB
    ora #$80
    sta PORTB
    inc KB_PARITY
    bra @sending_done
@send_zero:
    lda PORTB
    and #$7F
    sta PORTB
@sending_done:
    ; lda #2
    ; sta PORTA
    inc KB_BIT      ; prepare for next bit
    lda KB_BIT
    cmp #8          ; if this is the last bit, next state is parity
    jmp @next_state_parity
    lsr to_send
    clc
    bra @exit

@sending_parity:
    ; lda #5
    ; sta PORTA
    lda KB_PARITY
    and #$01
    beq @odd_parity     ; send zero if odd parity
    lda PORTB
    ora #$80            ; send one if even
    sta PORTB
    lda #KB_STATE_STOP      ;next state is stop
    sta KB_STATE
    jmp @exit
@odd_parity:
    lda PORTB
    and #$7F
    sta PORTB
    lda #KB_STATE_STOP      ;next state is stop
    sta KB_STATE
    jmp @exit

@sending_stop:
    ; lda #6
    ; sta PORTA
    lda #KB_STATE_START     ; set it back to start in case we are receivin next
    sta KB_STATE
    lda #0
    sta to_send
    sta KB_BIT
    sta KB_PARITY
    lda DDRB        ; set PORTB back to input
    and #$7F
    sta DDRB
    jmp @exit
