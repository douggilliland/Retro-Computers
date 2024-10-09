PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

E  = %10000000
RW = %01000000
RS = %00100000

SD_CS   = %00010000
SD_SCK  = %00001000
SD_MOSI = %00000100
SD_MISO = %00000010

PORTA_OUTPUTPINS = E | RW | RS | SD_CS | SD_SCK | SD_MOSI


  .org $e000

reset:
  ldx #$ff
  txs

  lda #%11111111          ; Set all pins on port B to output
  sta DDRB
  lda #PORTA_OUTPUTPINS   ; Set various pins on port A to output
  sta DDRA

  jsr lcd_init


  ; Let the SD card boot up, by pumping the clock with SD CS disabled

  lda #'I'
  jsr print_char

  ; We need to apply around 80 clock pulses with CS and MOSI high.
  ; Normally MOSI doesn't matter when CS is high, but the card is
  ; not yet is SPI mode, and in this non-SPI state it does care.

  lda #SD_CS | SD_MOSI
  ldx #160               ; toggle the clock 160 times, so 80 low-high transitions
.preinitloop:
  eor #SD_SCK
  sta PORTA
  dex
  bne .preinitloop
  
  ; Read a byte from the card, expecting $ff as no commands have been sent
  jsr sd_readbyte
  jsr print_hex

.cmd0
  ; GO_IDLE_STATE - resets card to idle state
  ; This also puts the card in SPI mode.
  ; Unlike most commands, the CRC is checked.

  lda #'c'
  jsr print_char
  lda #$00
  jsr print_hex

  lda #SD_MOSI           ; pull CS low to begin command
  sta PORTA

  ; CMD0, data 00000000, crc 95
  lda #$40
  jsr sd_writebyte
  lda #$00
  jsr sd_writebyte
  lda #$00
  jsr sd_writebyte
  lda #$00
  jsr sd_writebyte
  lda #$00
  jsr sd_writebyte
  lda #$95
  jsr sd_writebyte

  ; Read response and print it - should be $01 (not initialized)
  jsr sd_waitresult
  pha
  jsr print_hex

  lda #SD_CS | SD_MOSI   ; set CS high again
  sta PORTA

  ; Expect status response $01 (not initialized)
  pla
  cmp #$01
  bne .initfailed


  lda #'Y'
  jsr print_char

  ; loop forever
.loop:
  jmp .loop


.initfailed
  lda #'X'
  jsr print_char
  jmp .loop



sd_readbyte:
  ; Enable the card and tick the clock 8 times with MOSI high, 
  ; capturing bits from MISO and returning them

  ldx #8                      ; we'll read 8 bits
.loop:

  lda #SD_MOSI                ; enable card (CS low), set MOSI (resting state), SCK low
  sta PORTA

  lda #SD_MOSI | SD_SCK       ; toggle the clock high
  sta PORTA

  lda PORTA                   ; read next bit
  and #SD_MISO

  clc                         ; default to clearing the bottom bit
  beq .bitnotset              ; unless MISO was set
  sec                         ; in which case get ready to set the bottom bit
.bitnotset:

  tya                         ; transfer partial result from Y
  rol                         ; rotate carry bit into read result
  tay                         ; save partial result back to Y

  dex                         ; decrement counter
  bne .loop                   ; loop if we need to read more bits

  rts


sd_writebyte:
  ; Tick the clock 8 times with descending bits on MOSI
  ; SD communication is mostly half-duplex so we ignore anything it sends back here

  ldx #8                      ; send 8 bits

.loop:
  asl                         ; shift next bit into carry
  tay                         ; save remaining bits for later

  lda #0
  bcc .sendbit                ; if carry clear, don't set MOSI for this bit
  ora #SD_MOSI

.sendbit:
  sta PORTA                   ; set MOSI (or not) first with SCK low
  eor #SD_SCK
  sta PORTA                   ; raise SCK keeping MOSI the same, to send the bit

  tya                         ; restore remaining bits to send

  dex
  bne .loop                   ; loop if there are more bits to send

  rts


sd_waitresult:
  ; Wait for the SD card to return something other than $ff
  jsr sd_readbyte
  cmp #$ff
  beq sd_waitresult
  rts


lcd_wait:
  pha
  lda #%00000000  ; Port B is input
  sta DDRB
.busy:
  lda #RW
  sta PORTA
  lda #(RW | E)
  sta PORTA
  lda PORTB
  and #%10000000
  bne .busy

  lda #RW
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
  lda #E         ; Set E bit to send instruction
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


print_char:
  jsr lcd_wait
  sta PORTB
  lda #RS         ; Set RS; Clear RW/E bits
  sta PORTA
  lda #(RS | E)   ; Set E bit to send instruction
  sta PORTA
  lda #RS         ; Clear E bits
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
print_nybble:
  and #15
  cmp #10
  bmi .skipletter
  adc #6
.skipletter
  adc #48
  jsr print_char
  rts

  .org $fffc
  .word reset
  .word $0000
