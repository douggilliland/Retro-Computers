$0000 a5 0e      lda $0e
$0002 f0 06      beq $000a
$0004 c6 0e      dec $0e
$0006 f0 02      beq $000a
$0008 c6 0e      dec $0e
$000a a9 20      lda #$20
$000c 8d 01 02   sta $0201
$000f 20 8f ff   jsr $ff8f
$0012 10 19      bpl $002d
$0014 38         sec
$0015 ad 2b 02   lda $022b
$0018 e9 40      sbc #$40
$001a 8d 2b 02   sta $022b
$001d ad 2c 02   lda $022c
$0020 e9 00      sbc #$00
$0022 8d 2c 02   sta $022c
$0025 20 cf fb   jsr $fbcf
$0028 b0 03      bcs $002d
$002a 20 d1 ff   jsr $ffd1
$002d 8e 00 02   stx $0200
$0030 20 88 ff   jsr $ff88
$0033 4c d2 f8   jmp $f8d2
$0036 8d 02 02   sta $0202
$0039 48         pha
$003a 8a         txa
$003b 48         pha
$003c 98         tya
$003d 48         pha
$003e ad 02 02   lda $0202
$0041 d0 03      bne $0046
$0043 4c d2 f8   jmp $f8d2
$0046 ac 06 02   ldy $0206
$0049 f0 03      beq $004e
$004b 20 e1 fc   jsr $fce1
$004e c9 5f      cmp #$5f
$0050 f0 ae      beq $0000
$0052 c9 0c      cmp #$0c
$0054 d0 0b      bne $0061
$0056 20 8c ff   jsr $ff8c
$0059 20 d1 ff   jsr $ffd1
$005c 8e 00 02   stx $0200
$005f f0 6e      beq $00cf
$0061 c9 0a      cmp #$0a
$0063 f0 27      beq $008c
$0065 c9 1e      cmp #$1e
$0067 f0 77      beq $00e0
$0069 c9 0b      cmp #$0b
$006b f0 10      beq $007d
$006d c9 1a      cmp #$1a
$006f f0 67      beq $00d8
$0071 c9 0d      cmp #$0d
$0073 d0 05      bne $007a
$0075 20 6d ff   jsr $ff6d
$0078 d0 58      bne $00d2
$007a 8d 01 02   sta $0201
$007d 20 8c ff   jsr $ff8c
$0080 ee 00 02   inc $0200
$0083 e8         inx
$0084 ec 22 02   cpx $0222
$0087 30 46      bmi $00cf
$0089 20 70 ff   jsr $ff70
$008c 20 8c ff   jsr $ff8c
$008f a0 02      ldy #$02
$0091 20 d2 fb   jsr $fbd2
$0094 b0 08      bcs $009e
$0096 a2 03      ldx #$03
$0098 20 ee fd   jsr $fdee
$009b 4c cf f8   jmp $f8cf
$009e 20 28 fe   jsr $fe28
$00a1 20 d1 ff   jsr $ffd1
$00a4 20 ee fd   jsr $fdee
$00a7 ae 22 02   ldx $0222
$00aa 20 27 02   jsr $0227
$00ad 10 fb      bpl $00aa
$00af e8         inx
$00b0 20 ee fd   jsr $fdee
$00b3 a2 03      ldx #$03
$00b5 20 ee fd   jsr $fdee
$00b8 20 cf fb   jsr $fbcf
$00bb 90 ed      bcc $00aa
$00bd a9 20      lda #$20
$00bf 20 2a 02   jsr $022a
$00c2 10 fb      bpl $00bf
$00c4 a2 01      ldx #$01
$00c6 bd 23 02   lda $0223,x
$00c9 9d 28 02   sta $0228,x
$00cc ca         dex
$00cd 10 f7      bpl $00c6
$00cf 20 75 ff   jsr $ff75
$00d2 68         pla
$00d3 a8         tay
$00d4 68         pla
$00d5 aa         tax
$00d6 68         pla
$00d7 60         rts
$00d8 20 59 fe   jsr $fe59
$00db 8d 01 02   sta $0201
$00de f0 24      beq $0104
$00e0 a9 20      lda #$20
$00e2 20 8f ff   jsr $ff8f
$00e5 20 d1 ff   jsr $ffd1
$00e8 ae 22 02   ldx $0222
$00eb a9 20      lda #$20
$00ed 20 2a 02   jsr $022a
$00f0 10 fb      bpl $00ed
$00f2 8d 01 02   sta $0201
$00f5 a0 02      ldy #$02
$00f7 20 d2 fb   jsr $fbd2
$00fa b0 08      bcs $0104
$00fc a2 03      ldx #$03
$00fe 20 ee fd   jsr $fdee
$0101 4c e8 f8   jmp $f8e8
$0104 20 d1 ff   jsr $ffd1
$0107 8e 00 02   stx $0200
$010a f0 c6      beq $00d2
$010c 20 a6 f9   jsr $f9a6
$010f 20 f5 fb   jsr $fbf5
$0112 20 b6 fe   jsr $feb6
$0115 20 e6 fb   jsr $fbe6
$0118 20 e0 fb   jsr $fbe0
$011b a2 08      ldx #$08
$011d 86 fd      stx $fd
$011f 20 e6 fb   jsr $fbe6
$0122 20 f0 fe   jsr $fef0
$0125 20 eb fb   jsr $fbeb
$0128 b0 51      bcs $017b
$012a 20 f9 fe   jsr $fef9
$012d c6 fd      dec $fd
$012f d0 ee      bne $011f
$0131 f0 dc      beq $010f
$0133 20 bd ff   jsr $ffbd
$0136 20 e4 fd   jsr $fde4
$0139 b0 43      bcs $017e
$013b a6 e4      ldx $e4
$013d 9a         txs
$013e a5 e6      lda $e6
$0140 48         pha
$0141 a5 e5      lda $e5
$0143 48         pha
$0144 a5 e3      lda $e3
$0146 48         pha
$0147 a5 e0      lda $e0
$0149 a6 e1      ldx $e1
$014b a4 e2      ldy $e2
$014d 40         rti
$014e a2 03      ldx #$03
$0150 bd 4b fa   lda $fa4b,x
$0153 9d 34 02   sta $0234,x
$0156 ca         dex
$0157 d0 f7      bne $0150
$0159 20 8d fe   jsr $fe8d
$015c 20 b5 f9   jsr $f9b5
$015f b1 fe      lda ($fe),y
$0161 85 e7      sta $e7
$0163 98         tya
$0164 91 fe      sta ($fe),y
$0166 f0 16      beq $017e
$0168 4c 7e fa   jmp $fa7e
$016b c6 fb      dec $fb
$016d d0 79      bne $01e8
$016f f0 9b      beq $010c
$0171 60         rts
$0172 a5 fb      lda $fb
$0174 d0 fb      bne $0171
$0176 a9 3f      lda #$3f
$0178 20 ee ff   jsr $ffee
$017b a2 28      ldx #$28
$017d 9a         txs
$017e 20 f5 fb   jsr $fbf5
$0181 a0 00      ldy #$00
$0183 84 fb      sty $fb
$0185 20 e0 fb   jsr $fbe0
$0188 20 8d fe   jsr $fe8d
$018b c9 4d      cmp #$4d
$018d f0 a4      beq $0133
$018f c9 52      cmp #$52
$0191 f0 a8      beq $013b
$0193 c9 5a      cmp #$5a
$0195 f0 b7      beq $014e
$0197 c9 53      cmp #$53
$0199 f0 cd      beq $0168
$019b c9 4c      cmp #$4c
$019d f0 cc      beq $016b
$019f c9 55      cmp #$55
$01a1 d0 33      bne $01d6
$01a3 6c 33 02   jmp ($0233)
$01a6 20 8d fe   jsr $fe8d
$01a9 20 b5 f9   jsr $f9b5
$01ac 20 e3 fb   jsr $fbe3
$01af a2 00      ldx #$00
$01b1 20 8d fe   jsr $fe8d
$01b4 2c a2 05   bit $05a2
$01b7 20 c0 f9   jsr $f9c0
$01ba 20 8d fe   jsr $fe8d
$01bd 2c a2 03   bit $03a2
$01c0 20 c6 f9   jsr $f9c6
$01c3 20 8d fe   jsr $fe8d
$01c6 c9 2e      cmp #$2e
$01c8 f0 be      beq $0188
$01ca c9 2f      cmp #$2f
$01cc f0 1a      beq $01e8
$01ce 20 93 fe   jsr $fe93
$01d1 30 9f      bmi $0172
$01d3 4c da fe   jmp $feda
$01d6 c9 54      cmp #$54
$01d8 f0 95      beq $016f
$01da 20 b5 f9   jsr $f9b5
$01dd a9 2f      lda #$2f
$01df 20 ee ff   jsr $ffee
$01e2 20 f0 fe   jsr $fef0
$01e5 20 e6 fb   jsr $fbe6
$01e8 20 8d fe   jsr $fe8d
$01eb c9 47      cmp #$47
$01ed d0 03      bne $01f2
$01ef 6c fe 00   jmp ($00fe)
$01f2 c9 2c      cmp #$2c
$01f4 d0 06      bne $01fc
$01f6 20 f9 fe   jsr $fef9
$01f9 4c e8 f9   jmp $f9e8
$01fc c9 0a      cmp #$0a
$01fe f0 16      beq $0216
$0200 c9 0d      cmp #$0d
$0202 f0 17      beq $021b
$0204 c9 5e      cmp #$5e
$0206 f0 19      beq $0221
$0208 c9 27      cmp #$27
$020a f0 2e      beq $023a
$020c 20 be f9   jsr $f9be
$020f a5 fc      lda $fc
$0211 91 fe      sta ($fe),y
$0213 4c e8 f9   jmp $f9e8
$0216 a9 0d      lda #$0d
$0218 20 ee ff   jsr $ffee
$021b 20 f9 fe   jsr $fef9
$021e 4c 31 fa   jmp $fa31
$0221 38         sec
$0222 a5 fe      lda $fe
$0224 e9 01      sbc #$01
$0226 85 fe      sta $fe
$0228 a5 ff      lda $ff
$022a e9 00      sbc #$00
$022c 85 ff      sta $ff
$022e 20 f5 fb   jsr $fbf5
$0231 20 b6 fe   jsr $feb6
$0234 4c dd f9   jmp $f9dd
$0237 20 f7 fe   jsr $fef7
$023a 20 8d fe   jsr $fe8d
$023d c9 27      cmp #$27
$023f d0 05      bne $0246
$0241 20 e3 fb   jsr $fbe3
$0244 d0 cd      bne $0213
$0246 c9 0d      cmp #$0d
$0248 f0 e4      beq $022e
$024a d0 eb      bne $0237
$024c 4c 4f fa   jmp $fa4f
$024f 85 e0      sta $e0
$0251 68         pla
$0252 48         pha
$0253 29 10      and #$10
$0255 d0 03      bne $025a
$0257 a5 e0      lda $e0
$0259 40         rti
$025a 86 e1      stx $e1
$025c 84 e2      sty $e2
$025e 68         pla
$025f 85 e3      sta $e3
$0261 d8         cld
$0262 38         sec
$0263 68         pla
$0264 e9 02      sbc #$02
$0266 85 e5      sta $e5
$0268 68         pla
$0269 e9 00      sbc #$00
$026b 85 e6      sta $e6
$026d ba         tsx
$026e 86 e4      stx $e4
$0270 a0 00      ldy #$00
$0272 a5 e7      lda $e7
$0274 91 e5      sta ($e5),y
$0276 a9 e0      lda #$e0
$0278 85 fe      sta $fe
$027a 84 ff      sty $ff
$027c d0 b0      bne $022e
$027e 20 bd ff   jsr $ffbd
$0281 20 f7 ff   jsr $fff7
$0284 20 e9 fe   jsr $fee9
$0287 20 ee ff   jsr $ffee
$028a 20 e3 ff   jsr $ffe3
$028d a9 2f      lda #$2f
$028f 20 ee ff   jsr $ffee
$0292 d0 03      bne $0297
$0294 20 f9 fe   jsr $fef9
$0297 20 f0 fe   jsr $fef0
$029a a9 0d      lda #$0d
$029c 20 b1 fc   jsr $fcb1
$029f 20 eb fb   jsr $fbeb
$02a2 90 f0      bcc $0294
$02a4 a5 e4      lda $e4
$02a6 a6 e5      ldx $e5
$02a8 85 fe      sta $fe
$02aa 86 ff      stx $ff
$02ac 20 e3 ff   jsr $ffe3
$02af a9 47      lda #$47
$02b1 20 ee ff   jsr $ffee
$02b4 20 ac ff   jsr $ffac
$02b7 8c 05 02   sty $0205
$02ba 4c 7e f9   jmp $f97e
$02bd 8a         txa
$02be 48         pha
$02bf 98         tya
$02c0 48         pha
$02c1 ad 04 02   lda $0204
$02c4 10 59      bpl $031f
$02c6 ac 2f 02   ldy $022f
$02c9 ad 31 02   lda $0231
$02cc 85 e4      sta $e4
$02ce ad 32 02   lda $0232
$02d1 85 e5      sta $e5
$02d3 b1 e4      lda ($e4),y
$02d5 8d 30 02   sta $0230
$02d8 a9 a1      lda #$a1
$02da 91 e4      sta ($e4),y
$02dc 20 00 fd   jsr $fd00
$02df ad 30 02   lda $0230
$02e2 91 e4      sta ($e4),y
$02e4 ad 15 02   lda $0215
$02e7 c9 11      cmp #$11
$02e9 f0 28      beq $0313
$02eb c9 01      cmp #$01
$02ed f0 1e      beq $030d
$02ef c9 04      cmp #$04
$02f1 f0 14      beq $0307
$02f3 c9 13      cmp #$13
$02f5 f0 0a      beq $0301
$02f7 c9 06      cmp #$06
$02f9 d0 27      bne $0322
$02fb 20 7c fb   jsr $fb7c
$02fe 4c c6 fa   jmp $fac6
$0301 20 28 fe   jsr $fe28
$0304 4c c6 fa   jmp $fac6
$0307 20 6b fb   jsr $fb6b
$030a 4c c6 fa   jmp $fac6
$030d 20 19 fe   jsr $fe19
$0310 4c c6 fa   jmp $fac6
$0313 ad 30 02   lda $0230
$0316 8d 15 02   sta $0215
$0319 20 6b fb   jsr $fb6b
$031c 4c 43 fb   jmp $fb43
$031f 20 00 fd   jsr $fd00
$0322 c9 05      cmp #$05
$0324 d0 1d      bne $0343
$0326 ad 04 02   lda $0204
$0329 49 ff      eor #$ff
$032b 8d 04 02   sta $0204
$032e 10 ef      bpl $031f
$0330 ad 2b 02   lda $022b
$0333 8d 31 02   sta $0231
$0336 ad 2c 02   lda $022c
$0339 8d 32 02   sta $0232
$033c a2 00      ldx #$00
$033e 8e 2f 02   stx $022f
$0341 f0 83      beq $02c6
$0343 4c d3 fd   jmp $fdd3
$0346 2c 03 02   bit $0203
$0349 10 1d      bpl $0368
$034b a9 fd      lda #$fd
$034d 8d 00 df   sta $df00
$0350 a9 10      lda #$10
$0352 2c 00 df   bit $df00
$0355 f0 0a      beq $0361
$0357 ad 00 f0   lda $f000
$035a 4a         lsr
$035b 90 ee      bcc $034b
$035d ad 01 f0   lda $f001
$0360 60         rts
$0361 a9 00      lda #$00
$0363 85 fb      sta $fb
$0365 8d 03 02   sta $0203
$0368 4c bd fa   jmp $fabd
$036b ae 22 02   ldx $0222
$036e ec 2f 02   cpx $022f
$0371 f0 04      beq $0377
$0373 ee 2f 02   inc $022f
$0376 60         rts
$0377 a2 00      ldx #$00
$0379 8e 2f 02   stx $022f
$037c 18         clc
$037d ad 31 02   lda $0231
$0380 69 40      adc #$40
$0382 8d 31 02   sta $0231
$0385 ad 32 02   lda $0232
$0388 69 00      adc #$00
$038a c9 d8      cmp #$d8
$038c d0 02      bne $0390
$038e a9 d0      lda #$d0
$0390 8d 32 02   sta $0232
$0393 60         rts
$0394 ad 12 02   lda $0212
$0397 d0 fa      bne $0393
$0399 a9 fe      lda #$fe
$039b 8d 00 df   sta $df00
$039e 2c 00 df   bit $df00
$03a1 70 f0      bvs $0393
$03a3 a9 fb      lda #$fb
$03a5 8d 00 df   sta $df00
$03a8 2c 00 df   bit $df00
$03ab 70 e6      bvs $0393
$03ad a9 03      lda #$03
$03af 4c 36 a6   jmp $a636
$03b2 46 fb      lsr $fb
$03b4 9b         ???
$03b5 ff         ???
$03b6 94 fb      sty $fb,x
$03b8 70 fe      bvs $03b8
$03ba 7b         ???
$03bb fe 3f 80   inc $803f,x
$03be d0 40      bne $0400
$03c0 d7         ???
$03c1 bd 8c d0   lda $d08c,x
$03c4 9d 8c d0   sta $d08c,x
$03c7 ca         dex
$03c8 60         rts
$03c9 00         brk
$03ca 20 8c d0   jsr $d08c
$03cd 88         dey
$03ce f9 ae 22   sbc $22ae,y
$03d1 02         ???
$03d2 38         sec
$03d3 ad 2b 02   lda $022b
$03d6 f9 23 02   sbc $0223,y
$03d9 ad 2c 02   lda $022c
$03dc f9 24 02   sbc $0224,y
$03df 60         rts
$03e0 a9 3e      lda #$3e
$03e2 2c a9 2c   bit $2ca9
$03e5 2c a9 20   bit $20a9
$03e8 4c ee ff   jmp $ffee
$03eb 38         sec
$03ec a5 fe      lda $fe
$03ee e5 f9      sbc $f9
$03f0 a5 ff      lda $ff
$03f2 e5 fa      sbc $fa
$03f4 60         rts
$03f5 a9 0d      lda #$0d
$03f7 20 ee ff   jsr $ffee
$03fa a9 0a      lda #$0a
$03fc 4c ee ff   jmp $ffee
$03ff 40         rti
$0400 20 0c fc   jsr $fc0c
$0403 6c fd 00   jmp ($00fd)
$0406 20 0c fc   jsr $fc0c
$0409 4c 00 fe   jmp $fe00
$040c a0 00      ldy #$00
$040e 8c 01 c0   sty $c001
$0411 8c 00 c0   sty $c000
$0414 a2 04      ldx #$04
$0416 8e 01 c0   stx $c001
$0419 8c 03 c0   sty $c003
$041c 88         dey
$041d 8c 02 c0   sty $c002
$0420 8e 03 c0   stx $c003
$0423 8c 02 c0   sty $c002
$0426 a9 fb      lda #$fb
$0428 d0 09      bne $0433
$042a a9 02      lda #$02
$042c 2c 00 c0   bit $c000
$042f f0 1c      beq $044d
$0431 a9 ff      lda #$ff
$0433 8d 02 c0   sta $c002
$0436 20 a5 fc   jsr $fca5
$0439 29 f7      and #$f7
$043b 8d 02 c0   sta $c002
$043e 20 a5 fc   jsr $fca5
$0441 09 08      ora #$08
$0443 8d 02 c0   sta $c002
$0446 a2 18      ldx #$18
$0448 20 91 fc   jsr $fc91
$044b f0 dd      beq $042a
$044d a2 7f      ldx #$7f
$044f 8e 02 c0   stx $c002
$0452 20 91 fc   jsr $fc91
$0455 ad 00 c0   lda $c000
$0458 30 fb      bmi $0455
$045a ad 00 c0   lda $c000
$045d 10 fb      bpl $045a
$045f a9 03      lda #$03
$0461 8d 10 c0   sta $c010
$0464 a9 58      lda #$58
$0466 8d 10 c0   sta $c010
$0469 20 9c fc   jsr $fc9c
$046c 85 fe      sta $fe
$046e aa         tax
$046f 20 9c fc   jsr $fc9c
$0472 85 fd      sta $fd
$0474 20 9c fc   jsr $fc9c
$0477 85 ff      sta $ff
$0479 a0 00      ldy #$00
$047b 20 9c fc   jsr $fc9c
$047e 91 fd      sta ($fd),y
$0480 c8         iny
$0481 d0 f8      bne $047b
$0483 e6 fe      inc $fe
$0485 c6 ff      dec $ff
$0487 d0 f2      bne $047b
$0489 86 fe      stx $fe
$048b a9 ff      lda #$ff
$048d 8d 02 c0   sta $c002
$0490 60         rts
$0491 a0 f8      ldy #$f8
$0493 88         dey
$0494 d0 fd      bne $0493
$0496 55 ff      eor $ff,x
$0498 ca         dex
$0499 d0 f6      bne $0491
$049b 60         rts
$049c ad 10 c0   lda $c010
$049f 4a         lsr
$04a0 90 fa      bcc $049c
$04a2 ad 11 c0   lda $c011
$04a5 60         rts
$04a6 a9 03      lda #$03
$04a8 8d 00 f0   sta $f000
$04ab a9 11      lda #$11
$04ad 8d 00 f0   sta $f000
$04b0 60         rts
$04b1 48         pha
$04b2 ad 00 f0   lda $f000
$04b5 4a         lsr
$04b6 4a         lsr
$04b7 90 f9      bcc $04b2
$04b9 68         pla
$04ba 8d 01 f0   sta $f001
$04bd 60         rts
$04be 49 ff      eor #$ff
$04c0 8d 00 df   sta $df00
$04c3 49 ff      eor #$ff
$04c5 60         rts
$04c6 48         pha
$04c7 20 cf fc   jsr $fccf
$04ca aa         tax
$04cb 68         pla
$04cc ca         dex
$04cd e8         inx
$04ce 60         rts
$04cf ad 00 df   lda $df00
$04d2 49 ff      eor #$ff
$04d4 60         rts
$04d5 c9 5f      cmp #$5f
$04d7 f0 03      beq $04dc
$04d9 4c 74 a3   jmp $a374
$04dc 4c 4b a3   jmp $a34b
$04df a0 10      ldy #$10
$04e1 a2 40      ldx #$40
$04e3 ca         dex
$04e4 d0 fd      bne $04e3
$04e6 88         dey
$04e7 d0 f8      bne $04e1
$04e9 60         rts
$04ea 43         ???
$04eb 45 47      eor $47
$04ed 4d 4f 4e   eor $4e4f
$04f0 28         plp
$04f1 43         ???
$04f2 29 31      and #$31
$04f4 39 38 30   and $3038,y
$04f7 20 44 2f   jsr $2f44
$04fa 43         ???
$04fb 2f         ???
$04fc 57         ???
$04fd 2f         ???
$04fe 4d 3f 8a   eor $8a3f
$0501 48         pha
$0502 98         tya
$0503 48         pha
$0504 a9 80      lda #$80
$0506 20 be fc   jsr $fcbe
$0509 20 c6 fc   jsr $fcc6
$050c d0 05      bne $0513
$050e 4a         lsr
$050f d0 f5      bne $0506
$0511 f0 27      beq $053a
$0513 4a         lsr
$0514 90 09      bcc $051f
$0516 8a         txa
$0517 29 20      and #$20
$0519 f0 1f      beq $053a
$051b a9 1b      lda #$1b
$051d d0 31      bne $0550
$051f 20 86 fe   jsr $fe86
$0522 98         tya
$0523 8d 15 02   sta $0215
$0526 0a         asl
$0527 0a         asl
$0528 0a         asl
$0529 38         sec
$052a ed 15 02   sbc $0215
$052d 8d 15 02   sta $0215
$0530 8a         txa
$0531 4a         lsr
$0532 0a         asl
$0533 20 86 fe   jsr $fe86
$0536 f0 0f      beq $0547
$0538 a9 00      lda #$00
$053a 8d 16 02   sta $0216
$053d 8d 13 02   sta $0213
$0540 a9 02      lda #$02
$0542 8d 14 02   sta $0214
$0545 d0 bd      bne $0504
$0547 18         clc
$0548 98         tya
$0549 6d 15 02   adc $0215
$054c a8         tay
$054d b9 3b ff   lda $ff3b,y
$0550 cd 13 02   cmp $0213
$0553 d0 e8      bne $053d
$0555 ce 14 02   dec $0214
$0558 f0 05      beq $055f
$055a 20 df fc   jsr $fcdf
$055d f0 a5      beq $0504
$055f a2 64      ldx #$64
$0561 cd 16 02   cmp $0216
$0564 d0 02      bne $0568
$0566 a2 0f      ldx #$0f
$0568 8e 14 02   stx $0214
$056b 8d 16 02   sta $0216
$056e c9 21      cmp #$21
$0570 30 5e      bmi $05d0
$0572 c9 5f      cmp #$5f
$0574 f0 5a      beq $05d0
$0576 a9 01      lda #$01
$0578 20 be fc   jsr $fcbe
$057b 20 cf fc   jsr $fccf
$057e 8d 15 02   sta $0215
$0581 29 01      and #$01
$0583 aa         tax
$0584 ad 15 02   lda $0215
$0587 29 06      and #$06
$0589 d0 17      bne $05a2
$058b 2c 13 02   bit $0213
$058e 50 2b      bvc $05bb
$0590 8a         txa
$0591 49 01      eor #$01
$0593 29 01      and #$01
$0595 f0 24      beq $05bb
$0597 a9 20      lda #$20
$0599 2c 15 02   bit $0215
$059c 50 25      bvc $05c3
$059e a9 c0      lda #$c0
$05a0 d0 21      bne $05c3
$05a2 2c 13 02   bit $0213
$05a5 50 03      bvc $05aa
$05a7 8a         txa
$05a8 f0 11      beq $05bb
$05aa ac 13 02   ldy $0213
$05ad c0 31      cpy #$31
$05af 90 08      bcc $05b9
$05b1 c0 3c      cpy #$3c
$05b3 b0 04      bcs $05b9
$05b5 a9 f0      lda #$f0
$05b7 d0 02      bne $05bb
$05b9 a9 10      lda #$10
$05bb 2c 15 02   bit $0215
$05be 50 03      bvc $05c3
$05c0 18         clc
$05c1 69 c0      adc #$c0
$05c3 18         clc
$05c4 6d 13 02   adc $0213
$05c7 29 7f      and #$7f
$05c9 2c 15 02   bit $0215
$05cc 10 02      bpl $05d0
$05ce 09 80      ora #$80
$05d0 8d 15 02   sta $0215
$05d3 68         pla
$05d4 a8         tay
$05d5 68         pla
$05d6 aa         tax
$05d7 ad 15 02   lda $0215
$05da 60         rts
$05db 20 f9 fe   jsr $fef9
$05de e6 e4      inc $e4
$05e0 d0 02      bne $05e4
$05e2 e6 e5      inc $e5
$05e4 b1 fe      lda ($fe),y
$05e6 91 e4      sta ($e4),y
$05e8 20 eb fb   jsr $fbeb
$05eb 90 ee      bcc $05db
$05ed 60         rts
$05ee 18         clc
$05ef a9 40      lda #$40
$05f1 7d 28 02   adc $0228,x
$05f4 9d 28 02   sta $0228,x
$05f7 a9 00      lda #$00
$05f9 7d 29 02   adc $0229,x
$05fc 9d 29 02   sta $0229,x
$05ff 60         rts
$0600 a2 28      ldx #$28
$0602 9a         txs
$0603 d8         cld
$0604 20 a6 fc   jsr $fca6
$0607 20 40 fe   jsr $fe40
$060a ea         nop
$060b ea         nop
$060c 20 59 fe   jsr $fe59
$060f 8d 01 02   sta $0201
$0612 84 fe      sty $fe
$0614 84 ff      sty $ff
$0616 4c 7e f9   jmp $f97e
$0619 ae 2f 02   ldx $022f
$061c f0 04      beq $0622
$061e ce 2f 02   dec $022f
$0621 60         rts
$0622 ae 22 02   ldx $0222
$0625 8e 2f 02   stx $022f
$0628 38         sec
$0629 ad 31 02   lda $0231
$062c e9 40      sbc #$40
$062e 8d 31 02   sta $0231
$0631 ad 32 02   lda $0232
$0634 e9 00      sbc #$00
$0636 c9 cf      cmp #$cf
$0638 d0 02      bne $063c
$063a a9 d7      lda #$d7
$063c 8d 32 02   sta $0232
$063f 60         rts
$0640 a0 1c      ldy #$1c
$0642 b9 b2 fb   lda $fbb2,y
$0645 99 18 02   sta $0218,y
$0648 88         dey
$0649 10 f7      bpl $0642
$064b a0 07      ldy #$07
$064d a9 00      lda #$00
$064f 8d 12 02   sta $0212
$0652 99 ff 01   sta $01ff,y
$0655 88         dey
$0656 d0 fa      bne $0652
$0658 60         rts
$0659 a0 00      ldy #$00
$065b 84 f9      sty $f9
$065d a9 d0      lda #$d0
$065f 85 fa      sta $fa
$0661 a2 08      ldx #$08
$0663 a9 20      lda #$20
$0665 91 f9      sta ($f9),y
$0667 c8         iny
$0668 d0 fb      bne $0665
$066a e6 fa      inc $fa
$066c ca         dex
$066d d0 f6      bne $0665
$066f 60         rts
$0670 48         pha
$0671 ce 03 02   dec $0203
$0674 a9 00      lda #$00
$0676 8d 05 02   sta $0205
$0679 68         pla
$067a 60         rts
$067b 48         pha
$067c a9 01      lda #$01
$067e d0 f6      bne $0676
$0680 20 57 fb   jsr $fb57
$0683 29 7f      and #$7f
$0685 60         rts
$0686 a0 08      ldy #$08
$0688 88         dey
$0689 0a         asl
$068a 90 fc      bcc $0688
$068c 60         rts
$068d 20 e9 fe   jsr $fee9
$0690 4c ee ff   jmp $ffee
$0693 c9 30      cmp #$30
$0695 30 12      bmi $06a9
$0697 c9 3a      cmp #$3a
$0699 30 0b      bmi $06a6
$069b c9 41      cmp #$41
$069d 30 0a      bmi $06a9
$069f c9 47      cmp #$47
$06a1 10 06      bpl $06a9
$06a3 38         sec
$06a4 e9 07      sbc #$07
$06a6 29 0f      and #$0f
$06a8 60         rts
$06a9 a9 80      lda #$80
$06ab 60         rts
$06ac 20 b6 fe   jsr $feb6
$06af ea         nop
$06b0 ea         nop
$06b1 20 e6 fb   jsr $fbe6
$06b4 d0 07      bne $06bd
$06b6 a2 03      ldx #$03
$06b8 20 bf fe   jsr $febf
$06bb ca         dex
$06bc 2c a2 00   bit $00a2
$06bf b5 fc      lda $fc,x
$06c1 4a         lsr
$06c2 4a         lsr
$06c3 4a         lsr
$06c4 4a         lsr
$06c5 20 ca fe   jsr $feca
$06c8 b5 fc      lda $fc,x
$06ca 29 0f      and #$0f
$06cc 09 30      ora #$30
$06ce c9 3a      cmp #$3a
$06d0 30 03      bmi $06d5
$06d2 18         clc
$06d3 69 07      adc #$07
$06d5 4c ee ff   jmp $ffee
$06d8 ea         nop
$06d9 ea         nop
$06da a0 04      ldy #$04
$06dc 0a         asl
$06dd 0a         asl
$06de 0a         asl
$06df 0a         asl
$06e0 2a         rol
$06e1 36 f9      rol $f9,x
$06e3 36 fa      rol $fa,x
$06e5 88         dey
$06e6 d0 f8      bne $06e0
$06e8 60         rts
$06e9 a5 fb      lda $fb
$06eb d0 93      bne $0680
$06ed 4c 00 fd   jmp $fd00
$06f0 b1 fe      lda ($fe),y
$06f2 85 fc      sta $fc
$06f4 4c bd fe   jmp $febd
$06f7 91 fe      sta ($fe),y
$06f9 e6 fe      inc $fe
$06fb d0 02      bne $06ff
$06fd e6 ff      inc $ff
$06ff 60         rts
$0700 d8         cld
$0701 a2 28      ldx #$28
$0703 9a         txs
$0704 20 a6 fc   jsr $fca6
$0707 20 40 fe   jsr $fe40
$070a 20 59 fe   jsr $fe59
$070d 20 d1 ff   jsr $ffd1
$0710 b9 ea fc   lda $fcea,y
$0713 20 ee ff   jsr $ffee
$0716 c8         iny
$0717 c0 16      cpy #$16
$0719 d0 f5      bne $0710
$071b 20 eb ff   jsr $ffeb
$071e 29 df      and #$df
$0720 c9 44      cmp #$44
$0722 d0 03      bne $0727
$0724 4c 00 fc   jmp $fc00
$0727 c9 4d      cmp #$4d
$0729 d0 03      bne $072e
$072b 4c 00 fe   jmp $fe00
$072e c9 57      cmp #$57
$0730 d0 03      bne $0735
$0732 4c 00 00   jmp $0000
$0735 c9 43      cmp #$43
$0737 d0 c7      bne $0700
$0739 4c 11 bd   jmp $bd11
$073c 50 3b      bvc $0779
$073e 2f         ???
$073f 20 5a 41   jsr $415a
$0742 51 2c      eor ($2c),y
$0744 4d 4e 42   eor $424e
$0747 56 43      lsr $43,x
$0749 58         cli
$074a 4b         ???
$074b 4a         lsr
$074c 48         pha
$074d 47         ???
$074e 46 44      lsr $44
$0750 53         ???
$0751 49 55      eor #$55
$0753 59 54 52   eor $5254,y
$0756 45 57      eor $57
$0758 00         brk
$0759 00         brk
$075a 0d 0a 4f   ora $4f0a
$075d 4c 2e 00   jmp $002e
$0760 5f         ???
$0761 2d 3a 30   and $303a
$0764 39 38 37   and $3738,y
$0767 36 35      rol $35,x
$0769 34         ???
$076a 33         ???
$076b 32         ???
$076c 31 20      and ($20),y
$076e 8c ff a2   sty $a2ff
$0771 00         brk
$0772 8e 00 02   stx $0200
$0775 ae 00 02   ldx $0200
$0778 a9 bd      lda #$bd
$077a 8d 2a 02   sta $022a
$077d 20 2a 02   jsr $022a
$0780 8d 01 02   sta $0201
$0783 a9 9d      lda #$9d
$0785 8d 2a 02   sta $022a
$0788 a9 5f      lda #$5f
$078a d0 03      bne $078f
$078c ad 01 02   lda $0201
$078f ae 00 02   ldx $0200
$0792 4c 2a 02   jmp $022a
$0795 20 2d bf   jsr $bf2d
$0798 4c 9e ff   jmp $ff9e
$079b 20 36 f8   jsr $f836
$079e 48         pha
$079f ad 05 02   lda $0205
$07a2 f0 17      beq $07bb
$07a4 68         pla
$07a5 20 b1 fc   jsr $fcb1
$07a8 c9 0d      cmp #$0d
$07aa d0 10      bne $07bc
$07ac 48         pha
$07ad 8a         txa
$07ae 48         pha
$07af a2 0a      ldx #$0a
$07b1 a9 00      lda #$00
$07b3 20 b1 fc   jsr $fcb1
$07b6 ca         dex
$07b7 d0 fa      bne $07b3
$07b9 68         pla
$07ba aa         tax
$07bb 68         pla
$07bc 60         rts
$07bd 20 a6 f9   jsr $f9a6
$07c0 20 e0 fb   jsr $fbe0
$07c3 a2 03      ldx #$03
$07c5 20 b1 f9   jsr $f9b1
$07c8 a5 fc      lda $fc
$07ca a6 fd      ldx $fd
$07cc 85 e4      sta $e4
$07ce 86 e5      stx $e5
$07d0 60         rts
$07d1 a2 02      ldx #$02
$07d3 bd 22 02   lda $0222,x
$07d6 9d 27 02   sta $0227,x
$07d9 9d 2a 02   sta $022a,x
$07dc ca         dex
$07dd d0 f4      bne $07d3
$07df 60         rts
$07e0 4d 2f 01   eor $012f
$07e3 a9 2e      lda #$2e
$07e5 20 ee ff   jsr $ffee
$07e8 4c b6 fe   jmp $feb6
$07eb 6c 18 02   jmp ($0218)
$07ee 6c 1a 02   jmp ($021a)
$07f1 6c 1c 02   jmp ($021c)
$07f4 6c 1e 02   jmp ($021e)
$07f7 6c 20 02   jmp ($0220)
$07fa 37         ???
$07fb 02         ???
$07fc 00         brk
$07fd ff         ???
$07fe 35 02      and $02,x
