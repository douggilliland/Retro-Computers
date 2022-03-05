.segment "ZEROPAGE"
line: .res  1
char: .res  1


.segment "CODE"

.include "../drivers/via.inc"
.include "../drivers/vga.inc"
.include "../drivers/vga.s"
.include "../drivers/delayroutines.s"

reset:
    ldy #$10
    jsr delay_long
    jsr video_init
    ;set background color
    lda #$1E
    sta VIDEO_ADDR_LOW
    lda #$BF
    sta VIDEO_ADDR_HIGH
    lda #$1F            ; red background
    sta VIDEO_DATA
    lda #$C0            ; green foreground
    sta VIDEO_DATA

    lda #$00
    sta VIDEO_ADDR_LOW
    sta VIDEO_ADDR_HIGH
restart:
    ldx #0
loop:
    lda message,x
    beq restart
    sta VIDEO_DATA
    
    ldy #$20
    jsr delay
    inx
    
    jmp loop

read_data:
    lda #$00
    sta VIDEO_ADDR_LOW
    lda #$00
    sta VIDEO_ADDR_HIGH
    ldx #0
read_loop:
    lda VIDEO_DATA
    sta buf,x
    inx
    cpx #100
    bne read_loop

write_again:
    lda #$04
    sta VIDEO_ADDR_LOW
    lda #$03
    sta VIDEO_ADDR_HIGH
    ldx #0
write_again_loop:
    lda buf,x
    sta VIDEO_DATA
    inx
    cpx #100
    bne write_again_loop

    jmp reset

message: .asciiz "The quick brown fox jumps over the lazy dog."

buf: .res 100;
.segment "ROM_VECTORS"

.word reset
.word reset
.word reset