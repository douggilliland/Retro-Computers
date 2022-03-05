acia_init:
    ; initialize the ACIA
    sta ACIA1_STATUS        ; soft reset (value not important)

                            ; set specific modes and functions
                            
    lda #$0B                ; no parity, no echo, no Tx interrupt, NO Rx interrupt, enable Tx/Rx
    ;lda #$09                ; no parity, no echo, no Tx interrupt, Rx interrupt, enable Tx/Rx
    sta ACIA1_CMD           ; store to the command register

    lda #$10                ; 1 stop bits, 8 bit word length, internal clock, 115.200k baud rate
    sta ACIA1_CTRL          ; program the ctl register
    rts

acia_out:
    phy
    sta ACIA1_DATA
    ldy #$40            ;minimal delay is $02
    jsr delay_short
    ply
    rts

acia_irq:
    pha
    bit ACIA1_STATUS
    bpl @exit
@irq_receive:
    ; we now have the byte, we need to add it to the keyboard buffer
    lda ACIA1_DATA

    sta KB_BUF
    ;sta ACIA1_DATA
    
@exit:
    pla
    rts