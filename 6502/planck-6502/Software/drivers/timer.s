

.alias COUNTER CLOCK_SPEED/400        ; n/s


timer_init:
    lda IER
    ora #$C0        ;enable interrupt on timer1 timeout
    sta IER
    lda #$40        ; timer one free run mode
    sta ACR
    lda #<COUNTER     ; set timer to low byte to calculated value from defined clock speed
    sta T1CL
    lda #>COUNTER       ; set timer to high byte to calculated value from defined clock speed

    sta T1CH        
    lda #0              ; reset time variable
    sta time
    sta time+1
    sta time+2
    sta time+3
    cli
    rts
    

timer_irq:
    inc time
    beq @inc1
@exit1:
    ; this resets the PS/2 temp variables
    jsr reset_ps2
    rts
@inc1:
    inc time+1
    beq @inc2
    bra @exit1
@inc2:
    inc time+2
    beq @inc3
    bra @exit1
@inc3:
    inc time+3
    bra @exit1