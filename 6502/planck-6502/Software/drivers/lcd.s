
; initialize the LCD in 8 bit mode
lcd_init:
    jsr buf_clr
    lda #0
    sta lcd_absent
    sta LCD_BUF_W_PTR
    sta LCD_BUF_R_PTR
    sta lcd_pos


    ldy #$FF
    jsr delay

    LDA #$38            ;function set: 8 bit
    jsr lcd_inst


    ldy #$FF
    jsr delay

    LDA #$0F            ;display on, cursor on, blink on
    jsr lcd_inst

    ;entry mode set
    LDA #$06
    jsr lcd_inst

    ;clear display
    LDA #$01            
    jsr lcd_inst

    ldy #$ff            ; wait a while
    jsr delay
    ;set dram address to start of screen
    LDA #$80            
    jsr lcd_inst

    ldy #$ff            ; wait a while
    jsr delay


    RTS

; Send an instruction in 8 bit mode
lcd_inst:
    phy
    sta LCD_ADDR_ENABLED
    ldy #$2                    ; Delay 38 clock cycles - 3 us at 12.5 MHz
    jsr delay_short
    sta LCD_ADDR_DISABLED
    ldy #$20                     ; Delay 608 clock cycles - 48 us at 12.5 MHz
    jsr delay_short
    ply
    rts

lcd_send:
    sta LCD_DATA_ENABLED
    ldy #$2                    ; Delay 38 clock cycles - 3 us at 12.5 MHz
    jsr delay_short
    sta LCD_DATA_DISABLED
    ldy #$20                     ; Delay 608 clock cycles - 48 us at 12.5 MHz
    jsr delay_short
    rts

; Sends the character in A to the display
lcd_print:               ; 8 bit data in A
    phy
    phx
    pha
    cmp #$0A
    beq @next_line
    cmp #$0D
    beq @next_line
    cmp #$08            ;backspace
    beq @backspace

    jsr lcd_send
    ldx lcd_pos
    sta LCD_BUF, x

    inx
    ; Check at which position we are and change line if necessary
    stx lcd_pos
    
    cpx #20
    beq @line_2
    cpx #40
    beq @line_3
    cpx #60
    beq @line_4
    cpx #80
    beq @clr
    
@continue:
    pla
    plx
    ply
    rts

; LCD adressing http://web.alfredstate.edu/faculty/weimandn/lcd/lcd_addressing/lcd_addressing_index.html
@backspace:
    lda #$10            ; shift cursor left
    jsr lcd_inst
    lda #$20            ; print a space to erase previous char
    jsr lcd_send
    
    lda #$10            ; shift cursor left
    jsr lcd_inst
    dec lcd_pos
    ldx lcd_pos         ; save in buffer
    lda #$20
    sta LCD_BUF,x
    bra @continue
@line_2:
    lda #20
    sta lcd_pos
    lda #$C0
    jsr lcd_inst
    bra @continue

@line_3:
    lda #40
    sta lcd_pos
    lda #$94            
    jsr lcd_inst
    bra @continue

@line_4:
    lda #60
    sta lcd_pos
    lda #$D4
    jsr lcd_inst
    bra @continue
@clr:
    ; lda #0
    ; sta lcd_pos
    ; lda #$80
    ; jsr lcd_inst
    jsr lcd_scroll_up
    bra @continue

@next_line:
    ldx lcd_pos            ;get current position
    cpx #80
    beq @clr
    cpx #60
    beq @line_4
    cpx #40
    beq @line_3
    cpx #20
    beq @line_2
    inx
    stx lcd_pos
    lda #$20
    jsr lcd_send
    sta LCD_BUF, x
    bra @next_line

lcd_scroll_up:
    pha                     ; save registers
    phy
    phx
    lda #$80                ; set LCD address to start
    jsr lcd_inst

    ldx #20                 ; start getting characters at the start of the second line
@scroll_loop:
    lda LCD_BUF, X          ; load from buffer
    jsr lcd_send            ; send to display
    tay                     ; save current character in Y
    cpx #79                 ; update LCD address if necessary
    beq @scline_4
    cpx #59
    beq @scline_3
    cpx #39
    beq @scline_2
@sccontinue:                ; return from updating LCD address
    txa                     ; copy X to A to be able to subtract from it
    sec                     ; set carry before subtraction
    sbc #20                 ; subtract 20 to get where to put this character
    tax                     ; put the result in X
    tya                     ; restore character from Y
    sta LCD_BUF, X          ; store char in buffer
    txa                     ; copy X to A to be able to add to it
    clc
    adc #20                 ; add 20 to restore X
    tax                     ; put the result back in X
    inx                     ; increment X to prepare to get next char
    cpx #80                 ; if not at end of buffer
    bcc @scroll_loop        ; do next char
    ; fill the last line with spaces
    lda #$D4                ; set address to last line
    jsr lcd_inst
    lda #$20
    ldx #60
@last_line_loop:
    sta LCD_BUF, x
    jsr lcd_send
    inx
    cpx #80                 ; if not at end of buffer
    bcc @last_line_loop     ; do next char

    ;finally, place the cursor at the start of the last line
    lda #60
    sta lcd_pos
    lda #$D4
    jsr lcd_inst
    plx                     ; restore everything as it was
    ply
    pla
    rts

@scline_2:
    lda #$C0
    jsr lcd_inst
    bra @sccontinue

@scline_3:
    lda #$94            
    jsr lcd_inst
    bra @sccontinue

@scline_4:
    lda #$D4
    jsr lcd_inst
    bra @sccontinue

lcd_clear:
    PHA
    ;clear display
    LDA #$01
    jsr lcd_inst
    ;set dram address
    LDA #$80            
    jsr lcd_inst
    PLA
    RTS


buf_clr:
    pha
    phx
    ldx #$80
    lda #$20
buf_clr_loop:
    sta LCD_BUF,X
    dex
    bne buf_clr_loop
    plx
    pla
    rts
