; LCD interfacing, minor modifications to Ben Eater's code

lcd_wait:
  pha
  lda #%00000000  ; Port B is input
  sta DDRB
.busy:
  lda #LCD_RW
  sta PORTA
  lda #(LCD_RW | LCD_E)
  sta PORTA
  lda PORTB
  and #%10000000
  bne .busy

  lda #LCD_RW
  sta PORTA
  lda #%11111111  ; Port B is output
  sta DDRB
  pla
  rts

lcd_instruction:
  jsr lcd_wait
  sta PORTB
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  lda #LCD_E     ; Set E bit to send instruction
  sta PORTA
  lda #0         ; Clear RS/RW/E bits
  sta PORTA
  rts


lcd_init:
  lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
  jsr lcd_instruction
  lda #%00001110 ; Display on; cursor on; blink off
  jsr lcd_instruction
  lda #%00000110 ; Increment and shift cursor; don't shift display
  jsr lcd_instruction

lcd_cleardisplay:
  lda #%00000001 ; Clear display
  jmp lcd_instruction

lcd_setpos_startline0:
  lda #%10000000
  jmp lcd_instruction

lcd_setpos_startline1:
  lda #%11000000
  jmp lcd_instruction

lcd_setpos_xy:
  txa
  asl
  asl
  cpy #1  ; set carry if Y >= 1
  ror
  sec
  ror
  jmp lcd_instruction


print_char:
  jsr lcd_wait
  sta PORTB
  lda #LCD_RS             ; Set RS; Clear RW/E bits
  sta PORTA
  lda #(LCD_RS | LCD_E)   ; Set E bit to send instruction
  sta PORTA
  lda #LCD_RS             ; Clear E bits
  sta PORTA
  rts

print_hex:
  pha
  ror
  ror
  ror
  ror
  jsr print_nybble
  pla
  pha
  jsr print_nybble
  pla
  rts
print_nybble:
  and #15
  cmp #10
  bmi .skipletter
  adc #6
.skipletter
  adc #48
  jsr print_char
  rts

