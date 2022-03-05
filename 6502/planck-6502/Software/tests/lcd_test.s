.segment "ZEROPAGE"
lcd_pos: .res  1
LCD_BUF_R_PTR: .res  1
LCD_BUF_W_PTR: .res  1
lcd_absent: .res  1


.segment "CODE"

.include "../drivers/lcd.inc"
.include "../drivers/via.inc"
.include "../drivers/lcd.s"
.include "../drivers/delayroutines.s"

reset:
    ldy #$FF
    jsr delay
    
    LDA #$38            ;function set
    jsr lcd_inst

    ldy #$FF
    jsr delay

    LDA #$0F            ;display on / off control
    jsr lcd_inst

    ldy #$FF
    jsr delay

    LDA #$06            ;entry mode set
    jsr lcd_inst

    ldy #$FF
    jsr delay

    LDA #$01            ;clear display
    jsr lcd_inst

    ldy #$FF
    jsr delay
    lda #$80            ; move to first line
    jsr lcd_inst
    ldx #$0
l:
    txa
    jsr lcd_send
    ldy #$ff
    jsr delay

    inx
    jmp l

    ; lda #$4C            ; move to second line
    ; ora #$80
    ; jsr lcd_inst

    ; LDA #$49            
    ; jsr lcd_send

    ; ldy #$10
    ; jsr delay_long

    ; jmp l

LCD_BUF: .res 256

.segment "ROM_VECTORS"

.word reset
.word reset
.word reset