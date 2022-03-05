video_init:
    ; set colors
    lda #$05
    sta VIDEO_CTRL
    lda #$1E
    sta VIDEO_ADDR_LOW
    lda #$FF
    sta VIDEO_ADDR_HIGH
    lda #$00
    sta VIDEO_DATA
    lda #$F0
    sta VIDEO_DATA
    lda #0
    sta VIDEO_IEN
    sta VIDEO_ADDR_LOW
    sta VIDEO_ADDR_HIGH
    jsr vga_clear
    rts

char_out:
    pha
    phx
    phy
    cmp #$0D
    beq next_line
    cmp #$0A
    beq next_line
    cmp #$08
    beq backspace
    sta VIDEO_DATA
    inc char
    ldx char
    cpx #VIDEO_HIRES_HCHARS
    beq next_line
    
char_out_exit:
    ply
    plx
    pla
    rts

backspace:
    dec char
    lda #$85        ; make increment negative
    sta VIDEO_CTRL
    lda #$20
    sta VIDEO_DATA  ;write a space to go back one
    lda #$01        ; make increment zero
    sta VIDEO_CTRL
    lda #$20
    sta VIDEO_DATA  ; replace with a space
    lda #$05        ; make increment positive again
    sta VIDEO_CTRL
    bra char_out_exit

next_line:
    inc line
    stz char
    ldx line
    cpx #VIDEO_HIRES_VCHARS
    bcc nl
    jsr scroll_up
    bra char_out_exit
nl:
    lda mult_table_high,x
    sta VIDEO_ADDR_HIGH
    lda mult_table_low,x
    sta VIDEO_ADDR_LOW
    bra char_out_exit

scroll_up:
    jsr vga_clear
    rts
    pha
    ; lda #1
    ; sta VIDEO_VSCROLL
    ; lda mult_table_high+60
    ; sta VIDEO_ADDR_HIGH
    ; lda mult_table_low+60
    ; sta VIDEO_ADDR_LOW
    lda #0
    sta VIDEO_ADDR_HIGH
    sta VIDEO_ADDR_LOW
    sta char
    sta line
    pla
    rts

vga_clear:
    pha
    phx
    phy
    lda #0
    sta line
    ;lda #$05                ; monochrome chars, increment by one
    ;sta VIDEO_CTRL
    
    lda #$00                ; set start address
    sta VIDEO_ADDR_HIGH
    sta VIDEO_ADDR_LOW

    lda #$20
    ldy #VIDEO_HIRES_HCHARS
outer:
    ldx #VIDEO_HIRES_VCHARS
inner:
    sta VIDEO_DATA

    dex
    bne inner
    dey
    bne outer

    lda #0
    sta line
    sta char
    lda #$00
    sta VIDEO_ADDR_HIGH
    sta VIDEO_ADDR_LOW
    ply
    plx
    pla
    rts



; These are precalculated multiplications for ADDR_LOW and ADDR_HIGH depending on the line number
mult_table_high:
    .byte $00
    .byte $02
    .byte $05
    .byte $07
    .byte $0a
    .byte $0c
    .byte $0f
    .byte $11
    .byte $14
    .byte $16
    .byte $19
    .byte $1b
    .byte $1e
    .byte $20
    .byte $23
    .byte $25
    .byte $28
    .byte $2a
    .byte $2d
    .byte $2f
    .byte $32
    .byte $34
    .byte $37
    .byte $39
    .byte $3c
    .byte $3e
    .byte $41
    .byte $43
    .byte $46
    .byte $48
    .byte $4b
    .byte $4d
    .byte $50
    .byte $52
    .byte $55
    .byte $57
    .byte $5a
    .byte $5c
    .byte $5f
    .byte $61
    .byte $64
    .byte $66
    .byte $69
    .byte $6b
    .byte $6e
    .byte $70
    .byte $73
    .byte $75
    .byte $78
    .byte $7a
    .byte $7d
    .byte $7f
    .byte $82
    .byte $84
    .byte $87
    .byte $89
    .byte $8c
    .byte $8e
    .byte $91
    .byte $93
    .byte $96

mult_table_low:
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00
    .byte $10
    .byte $00