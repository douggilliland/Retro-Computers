;6502 Disassembled Code by WinOSI
;DABUG monitor ROM for C1P
;partially annotated by Mark Spankus 7/30/2022

F800  2C 03 02   BIT $0203
F803  10 03      BPL $F808
F805  4C BF FF   JMP $FFBF
F808  98         TYA
F809  48         PHA
F80A  8A         TXA
F80B  48         PHA
F80C  20 DF F9   JSR $F9DF
F80F  85 E0      STA $E0
F811  C9 15      CMP #$15   ;^U
F813  D0 14      BNE $F829
F815  20 20 F9   JSR $F920
F818  90 03      BCC $F81D
F81A  20 38 F9   JSR $F938
F81D  20 E1 00   JSR $00E1
F820  20 4A F9   JSR $F94A
F823  20 38 F9   JSR $F938
F826  4C 0C F8   JMP $F80C
F829  C9 04      CMP #$04
F82B  D0 1F      BNE $F84C
F82D  20 20 F9   JSR $F920
F830  B0 DA      BCS $F80C
F832  20 E1 00   JSR $00E1
F835  A5 E4      LDA $E4
F837  A4 FA      LDY $FA
F839  F0 06      BEQ $F841
F83B  18         CLC
F83C  69 40      ADC #$40
F83E  4C 44 F8   JMP $F844
F841  18         CLC
F842  69 20      ADC #$20
F844  85 E4      STA $E4
F846  90 DB      BCC $F823
F848  E6 E5      INC $E5
F84A  D0 D7      BNE $F823
F84C  C9 EC      CMP #$EC
F84E  D0 15      BNE $F865
F850  20 20 F9   JSR $F920
F853  B0 B7      BCS $F80C
F855  20 E1 00   JSR $00E1
F858  A6 E4      LDX $E4
F85A  20 93 F9   JSR $F993
F85D  85 E4      STA $E4
F85F  B0 C2      BCS $F823
F861  C6 E5      DEC $E5
F863  D0 BE      BNE $F823
F865  C9 EE      CMP #$EE
F867  D0 0E      BNE $F877
F869  20 20 F9   JSR $F920
F86C  B0 20      BCS $F88E
F86E  20 E1 00   JSR $00E1
F871  20 63 F9   JSR $F963
F874  4C 23 F8   JMP $F823
F877  C9 01      CMP #$01
F879  D0 16      BNE $F891
F87B  20 20 F9   JSR $F920
F87E  B0 0E      BCS $F88E
F880  20 E1 00   JSR $00E1
F883  85 E0      STA $E0
F885  20 63 F9   JSR $F963
F888  20 38 F9   JSR $F938
F88B  4C F1 F8   JMP $F8F1
F88E  4C 0C F8   JMP $F80C
F891  C9 5F      CMP #$5F
F893  D0 31      BNE $F8C6
F895  68         PLA
F896  D0 03      BNE $F89B
F898  48         PHA
F899  F0 F3      BEQ $F88E
F89B  AA         TAX
F89C  CA         DEX
F89D  8A         TXA
F89E  48         PHA
F89F  C6 0E      DEC $0E
F8A1  A9 20      LDA #$20
F8A3  20 C9 F9   JSR $F9C9
F8A6  A4 FA      LDY $FA
F8A8  F0 0A      BEQ $F8B4
F8AA  A6 FD      LDX $FD
F8AC  20 93 F9   JSR $F993
F8AF  85 FD      STA $FD
F8B1  4C BD F8   JMP $F8BD
F8B4  AE 00 02   LDX $0200
F8B7  20 93 F9   JSR $F993
F8BA  8D 00 02   STA $0200
F8BD  AA         TAX
F8BE  A9 5F      LDA #$5F
F8C0  9D 00 D3   STA $D300,X
F8C3  4C 0C F8   JMP $F80C
F8C6  C9 40      CMP #$40
F8C8  F0 0F      BEQ $F8D9
F8CA  C9 7F      CMP #$7F
F8CC  D0 07      BNE $F8D5
F8CE  20 D5 FC   JSR $FCD5
F8D1  A9 0D      LDA #$0D
F8D3  85 E0      STA $E0
F8D5  C9 0D      CMP #$0D
F8D7  D0 0A      BNE $F8E3
F8D9  20 B6 F9   JSR $F9B6
F8DC  68         PLA
F8DD  AA         TAX
F8DE  68         PLA
F8DF  A8         TAY
F8E0  A5 E0      LDA $E0
F8E2  60         RTS
F8E3  C9 02      CMP #$02
F8E5  D0 0A      BNE $F8F1
F8E7  A5 FA      LDA $FA
F8E9  49 01      EOR #$01
F8EB  85 FB      STA $FB
F8ED  85 FA      STA $FA
F8EF  10 E0      BPL $F8D1
F8F1  A4 FA      LDY $FA
F8F3  F0 14      BEQ $F909
F8F5  A9 65      LDA #$65
F8F7  8D 00 02   STA $0200
F8FA  A5 FD      LDA $FD
F8FC  AA         TAX
F8FD  C9 7A      CMP #$7A
F8FF  F0 19      BEQ $F91A
F901  20 71 F9   JSR $F971
F904  85 FD      STA $FD
F906  4C DC F8   JMP $F8DC
F909  AD 00 02   LDA $0200
F90C  AA         TAX
F90D  C9 7C      CMP #$7C
F90F  F0 09      BEQ $F91A
F911  20 71 F9   JSR $F971
F914  8D 00 02   STA $0200
F917  4C DC F8   JMP $F8DC
F91A  20 4A F9   JSR $F94A
F91D  4C DC F8   JMP $F8DC
F920  A5 E5      LDA $E5
F922  C9 D3      CMP #$D3
F924  D0 10      BNE $F936
F926  A6 FA      LDX $FA
F928  F0 04      BEQ $F92E
F92A  A9 4B      LDA #$4B
F92C  D0 02      BNE $F930
F92E  A9 65      LDA #$65
F930  C5 E4      CMP $E4
F932  D0 02      BNE $F936
F934  38         SEC
F935  60         RTS
F936  18         CLC
F937  60         RTS
F938  A9 AD      LDA #$AD
F93A  85 E3      STA $E3
F93C  20 E3 00   JSR $00E3
F93F  85 E2      STA $E2
F941  A9 8D      LDA #$8D
F943  85 E3      STA $E3
F945  A9 BB      LDA #$BB
F947  4C E3 00   JMP $00E3
F94A  A5 E4      LDA $E4
F94C  38         SEC
F94D  E9 20      SBC #$20
F94F  85 E4      STA $E4
F951  B0 02      BCS $F955
F953  C6 E5      DEC $E5
F955  A6 FA      LDX $FA
F957  F0 09      BEQ $F962
F959  38         SEC
F95A  E9 20      SBC #$20
F95C  85 E4      STA $E4
F95E  B0 02      BCS $F962
F960  C6 E5      DEC $E5
F962  60         RTS
F963  E6 E4      INC $E4
F965  A6 E4      LDX $E4
F967  20 71 F9   JSR $F971
F96A  85 E4      STA $E4
F96C  90 02      BCC $F970
F96E  E6 E5      INC $E5
F970  60         RTS
F971  8A         TXA
F972  A4 FA      LDY $FA
F974  F0 0A      BEQ $F980
F976  0A         ASL A
F977  0A         ASL A
F978  C9 EC      CMP #$EC
F97A  D0 14      BNE $F990
F97C  A9 10      LDA #$10
F97E  D0 09      BNE $F989
F980  0A         ASL A
F981  0A         ASL A
F982  0A         ASL A
F983  C9 E8      CMP #$E8
F985  D0 09      BNE $F990
F987  A9 08      LDA #$08
F989  85 FC      STA $FC
F98B  8A         TXA
F98C  18         CLC
F98D  65 FC      ADC $FC
F98F  60         RTS
F990  8A         TXA
F991  18         CLC
F992  60         RTS
F993  CA         DEX
F994  8A         TXA
F995  A4 FA      LDY $FA
F997  F0 0A      BEQ $F9A3
F999  0A         ASL A
F99A  0A         ASL A
F99B  C9 28      CMP #$28
F99D  D0 14      BNE $F9B3
F99F  A9 10      LDA #$10
F9A1  D0 09      BNE $F9AC
F9A3  0A         ASL A
F9A4  0A         ASL A
F9A5  0A         ASL A
F9A6  C9 20      CMP #$20
F9A8  D0 09      BNE $F9B3
F9AA  A9 08      LDA #$08
F9AC  85 FC      STA $FC
F9AE  8A         TXA
F9AF  38         SEC
F9B0  E5 FC      SBC $FC
F9B2  60         RTS
F9B3  8A         TXA
F9B4  38         SEC
F9B5  60         RTS
F9B6  A2 06      LDX #$06
F9B8  BD D8 F9   LDA $F9D8,X
F9BB  95 E1      STA $E1,X
F9BD  CA         DEX
F9BE  10 F8      BPL $F9B8
F9C0  A6 FA      LDX $FA
F9C2  F0 04      BEQ $F9C8
F9C4  A9 4B      LDA #$4B
F9C6  85 E4      STA $E4
F9C8  60         RTS
F9C9  A4 FA      LDY $FA
F9CB  F0 04      BEQ $F9D1
F9CD  A4 FD      LDY $FD
F9CF  D0 03      BNE $F9D4
F9D1  AC 00 02   LDY $0200
F9D4  99 00 D3   STA $D300,Y
F9D7  60         RTS
F9D8  A9 80      LDA #$80
F9DA  8D 65 D3   STA $D365
F9DD  60         RTS
F9DE  00         BRK
F9DF  A5 E7      LDA $E7
F9E1  F0 05      BEQ $F9E8
F9E3  A4 E8      LDY $E8
F9E5  4C 1E FA   JMP $FA1E
F9E8  20 00 FD   JSR $FD00
F9EB  C9 1B      CMP #$1B	;<ESC>
F9ED  F0 01      BEQ $F9F0
F9EF  60         RTS
F9F0  A9 12      LDA #$12
F9F2  20 C9 F9   JSR $F9C9
F9F5  20 00 FD   JSR $FD00
F9F8  C9 1B      CMP #$1B	;<ESC>
F9FA  D0 08      BNE $FA04
F9FC  A9 5F      LDA #$5F	;_
F9FE  20 C9 F9   JSR $F9C9
FA01  4C E8 F9   JMP $F9E8
FA04  A2 44      LDX #$44
FA06  DD 34 FA   CMP $FA34,X
FA09  F0 05      BEQ $FA10
FA0B  CA         DEX
FA0C  10 F8      BPL $FA06
FA0E  30 E5      BMI $F9F5
FA10  E8         INX
FA11  A0 FF      LDY #$FF
FA13  CA         DEX
FA14  F0 08      BEQ $FA1E
FA16  C8         INY
FA17  B9 84 A0   LDA $A084,Y
FA1A  10 FA      BPL $FA16
FA1C  30 F5      BMI $FA13
FA1E  C8         INY
FA1F  84 E8      STY $E8
FA21  B9 84 A0   LDA $A084,Y
FA24  A8         TAY
FA25  30 06      BMI $FA2D
FA27  A9 FF      LDA #$FF
FA29  85 E7      STA $E7
FA2B  98         TYA
FA2C  60         RTS
FA2D  29 7F      AND #$7F
FA2F  A8         TAY
FA30  A9 00      LDA #$00
FA32  F0 F5      BEQ $FA29
FA34  3B 31 51   .BYT $3B,$31,$51  ;  ;1Q65ZYX4
FA37  36 35 5A   .BYT $36,$35,$5A ;
FA3A  59 58 34   .BYT $59,$58,$34 ;
FA3D  0D 00 54   .BYT $0D,$00,$54
FA40  33 45      .BYT $33,$45
FA42  0A         .BYT $0A
FA43  4A         .BYT $4A
FA44  00         BRK
FA45  00         BRK
FA46  00         BRK
FA47  4C 53 4F   JMP $4F53
FA4A  30 20      BMI $FA6C
FA4C  4B 7F      .BYT $4B,$7F
FA4E  2B 00      .BYT $2B,$00
FA50  2F 00 00   .BYT $2F,$00,$00
FA53  3F 32 3E   .BYT $3F,$32,$3E
FA56  57 00      .BYT $57,$00
FA58  00         BRK
FA59  00         BRK
FA5A  00         BRK
FA5B  00         BRK
FA5C  3C 00 00   .BYT $3C,$00,$00
FA5F  00         BRK
FA60  00         BRK
FA61  44 2D      .BYT $44,$2D
FA63  00         BRK
FA64  3A         .BYT $3A
FA65  46 00      LSR $00
FA67  2C 52 4D   BIT $4D52
FA6A  2E 56 43   ROL $4356
FA6D  42         .BYT $42
FA6E  4E 50 47   LSR $4750
FA71  49 48      EOR #$48
FA73  41 55      EOR ($55,X)
FA75  37 39      .BYT $37,$39
FA77  38         SEC
FA78  00         BRK
FA79  20 00 FD   JSR $FD00 ;get key from keyboard
FA7C  C9 11      CMP #$11  ;^Q
FA7E  F0 01      BEQ $FA81
FA80  60         RTS
FA81  8A         TXA
FA82  48         PHA
FA83  98         TYA
FA84  48         PHA
FA85  A5 00      LDA $00	;test warm start vector for BASIC in ROM active
FA87  C9 4C      CMP #$4C
FA89  D0 0F      BNE $FA9A
FA8B  A5 01      LDA $01
FA8D  C9 74      CMP #$74
FA8F  D0 09      BNE $FA9A
FA91  A5 02      LDA $02
FA93  C9 A2      CMP #$A2
FA95  D0 03      BNE $FA9A
FA97  20 A1 FA   JSR $FAA1 ;if active go here
FA9A  68         PLA
FA9B  A8         TAY
FA9C  68         PLA
FA9D  AA         TAX
FA9E  6C 18 02   JMP ($0218) ;(input vector)
FAA1  20 B6 F9   JSR $F9B6
FAA4  AD 00 02   LDA $0200
FAA7  85 E4      STA $E4
FAA9  A9 F8      LDA #$F8	;set input vector to F800
FAAB  8D 19 02   STA $0219
FAAE  A9 00      LDA #$00
FAB0  8D 18 02   STA $0218
FAB3  AE 00 02   LDX $0200
FAB6  A9 1D      LDA #$1D	;put ^^ character on screen at current cursor
FAB8  9D 00 D3   STA $D300,X
FABB  4C C8 FB   JMP $FBC8
FABE  20 C4 FA   JSR $FAC4
FAC1  4C 2D BF   JMP $BF2D
FAC4  48         PHA
FAC5  A9 FE      LDA #$FE	;scan for CTRL-LEFT_SHIFT
FAC7  8D 00 DF   STA $DF00  ;loop until not pressed
FACA  2C 00 DF   BIT $DF00
FACD  70 0A      BVS $FAD9
FACF  8D 00 DF   STA $DF00
FAD2  AD 00 DF   LDA $DF00
FAD5  29 04      AND #$04
FAD7  F0 EC      BEQ $FAC5
FAD9  68         PLA
FADA  60         RTS
FADB  44 41      .BYT 'DAVID ANEAR 2/2/81',$FF
FADD  56 49      
FADF  44 20      
FAE1  41 4E      
FAE3  45 41      
FAE5  52         
FAE6  20 32 2F   
FAE9  32         
FAEA  2F 38 31 
FAED  FF 
FAEE  38 EF      .BYT $38,$EF,$18
FAF1  E8         .BYT $E8
FAF2  FC E8 F5   .BYT $FC,$E8,$F5
FAF5  B7 75      .BYT $B7,$75
FAF7  50 3E      BVC $FB37
FAF9  B8         CLV
FAFA  8C 05 CB   STY $CB05
FAFD  DB E4 2C   .BYT $DB,$E4,$2C
FB00  C9 7F      CMP #$7F
FB02  D0 05      BNE $FB09
FB04  20 D5 FC   JSR $FCD5
FB07  A9 0D      LDA #$0D
FB09  85 FE      STA $FE
FB0B  48         PHA
FB0C  A5 FB      LDA $FB
FB0E  30 0B      BMI $FB1B
FB10  8D 00 D8   STA $D800
FB13  29 01      AND #$01
FB15  85 FA      STA $FA
FB17  A9 FF      LDA #$FF
FB19  85 FB      STA $FB
FB1B  A5 FA      LDA $FA
FB1D  D0 04      BNE $FB23
FB1F  68         PLA
FB20  4C 69 FF   JMP $FF69
FB23  20 C4 FA   JSR $FAC4
FB26  8A         TXA
FB27  48         PHA
FB28  98         TYA
FB29  48         PHA
FB2A  A5 FE      LDA $FE
FB2C  A4 FF      LDY $FF
FB2E  A6 FD      LDX $FD
FB30  29 7F      AND #$7F
FB32  C9 0D      CMP #$0D	;^M  <CR>
FB34  F0 5A      BEQ $FB90
FB36  C9 08      CMP #$08	;^H  <BKSP>
FB38  F0 48      BEQ $FB82
FB3A  C9 0C      CMP #$0C	;^L  <TAB>
FB3C  F0 4B      BEQ $FB89
FB3E  C9 0A      CMP #$0A	;^J  <LF>
FB40  F0 5A      BEQ $FB9C
FB42  C9 20      CMP #$20   ;<SPACE>
FB44  30 0E      BMI $FB54
FB46  C9 7B      CMP #$7B   ;{ 
FB48  10 0A      BPL $FB54
FB4A  9D 00 D3   STA $D300,X
FB4D  E8         INX
FB4E  E0 7B      CPX #$7B
FB50  F0 46      BEQ $FB98
FB52  D0 21      BNE $FB75
FB54  BC 00 D3   LDY $D300,X
FB57  84 FF      STY $FF
FB59  A9 5F      LDA #$5F		;write underscore character to current cursor
FB5B  9D 00 D3   STA $D300,X
FB5E  86 FD      STX $FD
FB60  68         PLA
FB61  A8         TAY
FB62  68         PLA
FB63  AA         TAX
FB64  68         PLA
FB65  4C 6C FF   JMP $FF6C
FB68  8A         TXA
FB69  29 3F      AND #$3F
FB6B  C9 0A      CMP #$0A
FB6D  D0 E5      BNE $FB54
FB6F  8A         TXA
FB70  E9 10      SBC #$10
FB72  AA         TAX
FB73  D0 DF      BNE $FB54
FB75  8A         TXA
FB76  29 3F      AND #$3F
FB78  C9 3B      CMP #$3B
FB7A  D0 D8      BNE $FB54
FB7C  8A         TXA
FB7D  69 0F      ADC #$0F
FB7F  AA         TAX
FB80  D0 D2      BNE $FB54
FB82  98         TYA
FB83  9D 00 D3   STA $D300,X
FB86  CA         DEX
FB87  B0 DF      BCS $FB68
FB89  98         TYA
FB8A  9D 00 D3   STA $D300,X
FB8D  E8         INX
FB8E  B0 E5      BCS $FB75
FB90  98         TYA
FB91  9D 00 D3   STA $D300,X
FB94  A2 4B      LDX #$4B
FB96  D0 BC      BNE $FB54
FB98  A2 4B      LDX #$4B
FB9A  D0 04      BNE $FBA0
FB9C  98         TYA
FB9D  9D 00 D3   STA $D300,X
FBA0  86 FC      STX $FC
FBA2  A9 40      LDA #$40
FBA4  85 F8      STA $F8
FBA6  A0 00      LDY #$00
FBA8  84 F6      STY $F6
FBAA  A2 CF      LDX #$CF
FBAC  E8         INX
FBAD  86 F9      STX $F9
FBAF  86 F7      STX $F7
FBB1  B1 F8      LDA ($F8),Y
FBB3  91 F6      STA ($F6),Y
FBB5  C8         INY
FBB6  F0 F4      BEQ $FBAC
FBB8  10 F7      BPL $FBB1
FBBA  E0 D3      CPX #$D3
FBBC  D0 F3      BNE $FBB1
FBBE  A6 FC      LDX $FC
FBC0  4C 54 FB   JMP $FB54
FBC3  29 5D      AND #$5D
FBC5  BB 2C 9B   .BYT $BB,$2C,$9B
FBC8  A9 00      LDA #$00
FBCA  85 FA      STA $FA
FBCC  85 FB      STA $FB
FBCE  8D 1A 02   STA $021A
FBD1  A9 4B      LDA #$4B
FBD3  85 FD      STA $FD
FBD5  A9 FB      LDA #$FB
FBD7  8D 1B 02   STA $021B
FBDA  A9 20      LDA #$20
FBDC  85 FF      STA $FF
FBDE  60         RTS
FBDF  20 C8 FB   JSR $FBC8
FBE2  A9 09      LDA #$09
FBE4  4C CE FB   JMP $FBCE
FBE7  06         .BYT $06

FBE8  A5 00      LDA #$00
FBEA  C9 4C      CMP #$4C
FBEC  D0 0F      BNE $FBFD
FBEE  A5 01      LDA $01
FBF0  C9 74      CMP #$74
FBF2  D0 09      BNE $FBFD
FBF4  A5 02      LDA $02
FBF6  C9 A2      CMP #$A2
FBF8  D0 03      BNE $FBFD
FBFA  4C D6 FC   JMP $FCD6
FBFD  4C 31 FF   JMP $FF31

;floppy disk bootstap $FC00
FC00  20 0C FC   JSR $FC0C
FC03  6C FD 00   JMP ($00FD)  ;jump to address loaded from disk (usually $2200)
FC06  20 0C FC   JSR $FC0C
FC09  4C 00 FE   JMP $FE00
FC0C  A0 00      LDY #$00     ;init disk controller
FC0E  8C 01 C0   STY $C001    ;select DDRA.
FC11  8C 00 C0   STY $C000    ;0's in DDRA indicate input.
FC14  A2 04      LDX #$04     
FC16  8E 01 C0   STX $C001    ;select PORTA
FC19  8C 03 C0   STY $C003    ;select DDRB
FC1C  88         DEY          
FC1D  8C 02 C0   STY $C002    ;1's in DDRB indicate output.
FC20  8E 03 C0   STX $C003    ;select PORT B
FC23  8C 02 C0   STY $C002    ;make all outputs high
FC26  A9 FB      LDA #$FB     ;set step towards 0
FC28  D0 09      BNE $FC33    
FC2A  A9 02      LDA #$02     
FC2C  2C 00 C0   BIT $C000    
FC2F  F0 1C      BEQ $FC4D    ;track 0 enabled?
FC31  A9 FF      LDA #$FF     
FC33  8D 02 C0   STA $C002    ;step off
FC36  20 A5 FC   JSR $FCA5    ; short delay
FC39  29 F7      AND #$F7     
FC3B  8D 02 C0   STA $C002     ;step on
FC3E  20 A5 FC   JSR $FCA5    
FC41  09 08      ORA #$08     
FC43  8D 02 C0   STA $C002    ;step off
FC46  A2 18      LDX #$18     
FC48  20 91 FC   JSR $FC91    
FC4B  F0 DD      BEQ $FC2A    
FC4D  A2 7F      LDX #$7F      ;load head
FC4F  8E 02 C0   STX $C002    
FC52  20 91 FC   JSR $FC91     ;delay 320 ms
FC55  AD 00 C0   LDA $C000    
FC58  30 FB      BMI $FC55     ;wait for index start
FC5A  AD 00 C0   LDA $C000    
FC5D  10 FB      BPL $FC5A     ;wait for index end
FC5F  A9 03      LDA #$03     
FC61  8D 10 C0   STA $C010     ;reset ACIA
FC64  A9 58      LDA #$58     
FC66  8D 10 C0   STA $C010     ;/1 RTS hi, no irq
FC69  20 9C FC   JSR $FC9C    
FC6C  85 FE      STA $FE       ;read start addr hi
FC6E  AA         TAX          
FC6F  20 9C FC   JSR $FC9C      
FC72  85 FD      STA $FD       ;read start addr lo
FC74  20 9C FC   JSR $FC9C    
FC77  85 FF      STA $FF       ;read num pages
FC79  A0 00      LDY #$00     
FC7B  20 9C FC   JSR $FC9C     ;read specified num pages
FC7E  91 FD      STA ($FD),Y  
FC80  C8         INY          
FC81  D0 F8      BNE $FC7B    
FC83  E6 FE      INC $FE      
FC85  C6 FF      DEC $FF      
FC87  D0 F2      BNE $FC7B    
FC89  86 FE      STX $FE       ;restore start addr hi
FC8B  A9 FF      LDA #$FF      ;disable drive               
FC8D  8D 02 C0   STA $C002    
FC90  60         RTS          
FC91  A0 F8      LDY #$F8     ;long delay
FC93  88         DEY          
FC94  D0 FD      BNE $FC93    
FC96  55 FF      EOR $FF,X    
FC98  CA         DEX          
FC99  D0 F6      BNE $FC91    
FC9B  60         RTS          
FC9C  AD 10 C0   LDA $C010    ;wait for disk ACIA char
FC9F  4A         LSR A
FCA0  90 FA      BCC $FC9C
FCA2  AD 11 C0   LDA $C011
FCA5  60         RTS
FCA6  A9 03      LDA #$03   ;RESET serial ACIA @ $F000
FCA8  8D 00 F0   STA $F000
FCAB  A9 11      LDA #$11
FCAD  8D 00 F0   STA $F000
FCB0  60         RTS
FCB1  48         PHA
FCB2  AD 00 F0   LDA $F000	;write to ACIA when empty
FCB5  4A         LSR A
FCB6  4A         LSR A
FCB7  90 F9      BCC $FCB2
FCB9  68         PLA
FCBA  8D 01 F0   STA $F001
FCBD  60         RTS

FCBE  49 FF      EOR #$FF   ;Set KB ROW (C1 patch for $FD00 keypoller)
FCC0  8D 00 DF   STA $DF00
FCC3  49 FF      EOR #$FF
FCC5  60         RTS

FCC6  48         PHA
FCC7  20 CF FC   JSR $FCCF
FCCA  AA         TAX
FCCB  68         PLA
FCCC  CA         DEX
FCCD  E8         INX
FCCE  60         RTS

FCCF  AD 00 DF   LDA $DF00  ;load KB COL (C1 patch for $FD00 keypoller)
FCD2  49 FF      EOR #$FF
FCD4  60         RTS

FCD5  48         PHA		;erase 2K screen
FCD6  8A         TXA
FCD7  48         PHA
FCD8  98         TYA
FCD9  48         PHA
FCDA  A0 00      LDY #$00
FCDC  A9 20      LDA #$20
FCDE  99 00 D7   STA $D700,Y
FCE1  99 00 D6   STA $D600,Y
FCE4  99 00 D5   STA $D500,Y
FCE7  99 00 D4   STA $D400,Y
FCEA  99 00 D3   STA $D300,Y
FCED  99 00 D2   STA $D200,Y
FCF0  99 00 D1   STA $D100,Y
FCF3  99 00 D0   STA $D000,Y
FCF6  C8         INY
FCF7  D0 E5      BNE $FCDE
FCF9  68         PLA
FCFA  A8         TAY
FCFB  68         PLA
FCFC  AA         TAX
FCFD  68         PLA
FCFE  60         RTS
FCFF  FF        .BYT $FF

;STD OSI C1P Keyboard decoder FD00-FDFF
; 
;OSI keyboard decode table reference
;  Columns read from $DF00, Rows selected by writing to $DF00
;  C2/C4 series has noninverted values (bit set when key pressed)
;
;     7    6    5    4    3    2    1    0
; -----------------------------------------
; 7- 1/!  2/"  3/#  4/$  5/%  6/&  7/'
;
; 6- 8/(  9/)  0/@  :/*  -/=  rub
;
; 5- ./>   L    O    lf   cr
; 
; 4-  W    E    R    T	  Y    U    I
; 					 
; 3-  S    D    F    G	  H    J    K
; 
; 2-  X    C    V    B    N    M   ,/<
;
; 1-  Q    A    Z   spc  //?  ;/+   P
; 
; 0- rpt  ctl  esc            lsh  rsh  caps


FD00  8A         TXA
FD01  48         PHA
FD02  98         TYA
FD03  48         PHA
FD04  A9 01      LDA #$01
FD06  20 BE FC   JSR $FCBE
FD09  20 C6 FC   JSR $FCC6
FD0C  D0 05      BNE $FD13
FD0E  0A         ASL A
FD0F  D0 F5      BNE $FD06
FD11  F0 53      BEQ $FD66
FD13  4A         LSR A
FD14  90 09      BCC $FD1F
FD16  2A         ROL A
FD17  E0 21      CPX #$21
FD19  D0 F3      BNE $FD0E
FD1B  A9 1B      LDA #$1B
FD1D  D0 21      BNE $FD40
FD1F  20 C8 FD   JSR $FDC8
FD22  98         TYA
FD23  8D 13 02   STA $0213
FD26  0A         ASL A
FD27  0A         ASL A
FD28  0A         ASL A
FD29  38         SEC
FD2A  ED 13 02   SBC $0213
FD2D  8D 13 02   STA $0213
FD30  8A         TXA
FD31  4A         LSR A
FD32  20 C8 FD   JSR $FDC8
FD35  D0 2F      BNE $FD66
FD37  18         CLC
FD38  98         TYA
FD39  6D 13 02   ADC $0213
FD3C  A8         TAY
FD3D  B9 CF FD   LDA $FDCF,Y
FD40  CD 15 02   CMP $0215
FD43  D0 26      BNE $FD6B
FD45  CE 14 02   DEC $0214
FD48  F0 2B      BEQ $FD75
FD4A  A0 05      LDY #$05
FD4C  A2 C8      LDX #$C8
FD4E  CA         DEX
FD4F  D0 FD      BNE $FD4E
FD51  88         DEY
FD52  D0 F8      BNE $FD4C
FD54  F0 AE      BEQ $FD04
FD56  C9 01      CMP #$01
FD58  F0 35      BEQ $FD8F
FD5A  A0 00      LDY #$00
FD5C  C9 02      CMP #$02
FD5E  F0 47      BEQ $FDA7
FD60  A0 C0      LDY #$C0
FD62  C9 20      CMP #$20
FD64  F0 41      BEQ $FDA7
FD66  A9 00      LDA #$00
FD68  8D 16 02   STA $0216
FD6B  8D 15 02   STA $0215
FD6E  A9 02      LDA #$02
FD70  8D 14 02   STA $0214
FD73  D0 8F      BNE $FD04
FD75  A2 96      LDX #$96
FD77  CD 16 02   CMP $0216
FD7A  D0 02      BNE $FD7E
FD7C  A2 14      LDX #$14
FD7E  8E 14 02   STX $0214
FD81  8D 16 02   STA $0216
FD84  A9 01      LDA #$01
FD86  20 BE FC   JSR $FCBE
FD89  20 CF FC   JSR $FCCF
FD8C  4A         LSR A
FD8D  90 33      BCC $FDC2
FD8F  AA         TAX
FD90  29 03      AND #$03
FD92  F0 0B      BEQ $FD9F
FD94  A0 10      LDY #$10
FD96  AD 15 02   LDA $0215
FD99  10 0C      BPL $FDA7
FD9B  A0 F0      LDY #$F0
FD9D  D0 08      BNE $FDA7
FD9F  A0 00      LDY #$00
FDA1  E0 20      CPX #$20
FDA3  D0 02      BNE $FDA7
FDA5  A0 C0      LDY #$C0
FDA7  AD 15 02   LDA $0215
FDAA  29 7F      AND #$7F
FDAC  C9 20      CMP #$20
FDAE  F0 07      BEQ $FDB7
FDB0  8C 13 02   STY $0213
FDB3  18         CLC
FDB4  6D 13 02   ADC $0213
FDB7  8D 13 02   STA $0213
FDBA  68         PLA
FDBB  A8         TAY
FDBC  68         PLA
FDBD  AA         TAX
FDBE  AD 13 02   LDA $0213
FDC1  60         RTS
FDC2  D0 92      BNE $FD56
FDC4  A0 20      LDY #$20
FDC6  D0 DF      BNE $FDA7
FDC8  A0 08      LDY #$08
FDCA  88         DEY
FDCB  0A         ASL A
FDCC  90 FC      BCC $FDCA
FDCE  60         RTS
FDCF  D0 BB      .BYT $D0, $BB      ;keyboard key decode table
FDD1  2F 20 5A   .BYT $2F, $20, $5A ;/ ZAQ,MNBVCXKJHGFDSIUYTREW
FDD4  41 51 2C   .BYT $41, $51, $2C
FDD7  4D 4E 42   .BYT $4D, $4E, $42
FDDA  56 43 58   .BYT $56, $43, $58
FDDD  4B 5A 48   .BYT $4B, $4A, $48
FDE0  47 46 44   .BYT $47, $46, $44
FDE3  53 49 55   .BYT $53, $49, $55
FDE6  59 54 52   .BYT $59, $54, $52
FDE9  45 57 00   .BYT $45, $57, $00
FDEC  00 0D 0A   .BYT $00, $0D, $0A
FDEF  4F 4C 2E   .BYT $4F, $4C, $2E
FDF2  00 FF 2D   .BYT $00, $FF, $2D
FDF5  BA 30 B9   .BYT $BA, $30, $B9
FDF8  B8 B7 B6   .BYT $B8, $B7, $B6
FDFB  B5 B4 B3   .BYT $B5, $B4, $B3
FDFE  B2 B1      .BYT $B2, $B1

; 65V monitor for C1 FE00-FEFF
FE00  A2 28      LDA #$28
FE02  9A         TXS
FE03  D8         CLD
FE04  EA         NOP
FE05  EA         NOP
FE06  EA         NOP
FE07  EA         NOP
FE08  EA         NOP
FE09  EA         NOP
FE0A  EA         NOP
FE0B  EA         NOP
FE0C  A2 D4      LDX #$D4
FE0E  A9 D0      LDA #$D0
FE10  85 FF      STA $FF
FE12  A9 00      LDA #$00
FE14  85 FE      STA $FE
FE16  85 FB      STA $FB
FE18  A8         TAY
FE19  A9 20      LDA #$20
FE1B  91 FE      STA ($FE),Y
FE1D  C8         INY
FE1E  D0 FB      BNE $FE1B
FE20  E6 FF      INC $FF
FE22  E4 FF      CPX $FF
FE24  D0 F5      BNE $FE1B
FE26  84 FF      STY $FF
FE28  F0 19      BEQ $FE43
FE2A  20 E9 FE   JSR $FEE9
FE2D  C9 2F      CMP #$2F  ;'/
FE2F  F0 1E      BEQ $FE4F
FE31  C9 47      CMP #'G
FE33  F0 17      BEQ $FE4C
FE35  C9 4C      CMP #'L
FE37  F0 43      BEQ $FE7C
FE39  20 93 FE   JSR $FE93
FE3C  30 EC      BMI $FE2A
FE3E  A2 02      LDX #$02
FE40  20 DA FE   JSR $FEDA
FE43  B1 FE      LDA ($FE),Y
FE45  85 FC      STA $FC
FE47  20 AC FE   JSR $FEAC
FE4A  D0 DE      BNE $FE2A
FE4C  6C FE 00   JMP ($00FE)
FE4F  20 E9 FE   JSR $FEE9
FE52  C9 2E      CMP #$2E   ;'.
FE54  F0 D4      BEQ $FE2A
FE56  C9 0D      CMP #$0D   ;<CR>
FE58  D0 0F      BNE $FE69
FE5A  E6 FE      INC $FE
FE5C  D0 02      BNE $FE60
FE5E  E6 FF      INC $FF
FE60  A0 00      LDY #$00
FE62  B1 FE      LDA ($FE),Y
FE64  85 FC      STA $FC
FE66  4C 77 FE   JMP $FE77
FE69  20 93 FE   JSR $FE93
FE6C  30 E1      BMI $FE4F
FE6E  A2 00      LDX #$00
FE70  20 DA FE   JSR $FEDA
FE73  A5 FC      LDA $FC
FE75  91 FE      STA ($FE),Y
FE77  20 AC FE   JSR $FEAC
FE7A  D0 D3      BNE $FE4F
FE7C  85 FB      STA $FB
FE7E  F0 CF      BEQ $FE4F
FE80  AD 00 F0   LDA $F000
FE83  4A         LSR A
FE84  90 FA      BCC $FE80
FE86  AD 01 F0   LDA $F001
FE89  EA         NOP
FE8A  EA         NOP
FE8B  EA         NOP
FE8C  29 7F      AND #$7F
FE8E  60         RTS
FE8F  00         BRK
FE90  00         BRK
FE91  00         BRK
FE92  00         BRK
FE93  C9 30      CMP #$30	;convert HEX to binary nibble lo or $80 on err
FE95  30 12      BMI $FEA9
FE97  C9 3A      CMP #$3A
FE99  30 0B      BMI $FEA6
FE9B  C9 41      CMP #$41
FE9D  30 0A      BMI $FEA9
FE9F  C9 47      CMP #$47
FEA1  10 06      BPL $FEA9
FEA3  38         SEC
FEA4  E9 07      SBC #$07
FEA6  29 0F      AND #$0F
FEA8  60         RTS
FEA9  A9 80      LDA #$80
FEAB  60         RTS
FEAC  A2 03      LDX #$03
FEAE  A0 00      LDY #$00
FEB0  B5 FC      LDA $FC,X
FEB2  4A         LSR A
FEB3  4A         LSR A
FEB4  4A         LSR A
FEB5  4A         LSR A
FEB6  20 CA FE   JSR $FECA
FEB9  B5 FC      LDA $FC,X
FEBB  20 CA FE   JSR $FECA
FEBE  CA         DEX
FEBF  10 EF      BPL $FEB0
FEC1  A9 20      LDA #$20
FEC3  8D CF D1   STA $D1CF	;was $D0CA in syn600 (moved down on screen in this version)
FEC6  8D D0 D1   STA $D1D0  ;was $D0CB 
FEC9  60         RTS
FECA  29 0F      AND #$0F   ;lo nibble to hex on screen
FECC  09 30      ORA #$30
FECE  C9 3A      CMP #$3A
FED0  30 03      BMI $FED5
FED2  18         CLC
FED3  69 07      ADC #$07
FED5  99 CB D1   STA $D1CB,Y
FED8  C8         INY
FED9  60         RTS
FEDA  A0 04      LDY #$04
FEDC  0A         ASL A
FEDD  0A         ASL A
FEDE  0A         ASL A
FEDF  0A         ASL A
FEE0  2A         ROL A
FEE1  36 FC      ROL $FC,X
FEE3  36 FD      ROL $FD,X
FEE5  88         DEY
FEE6  D0 F8      BNE $FEE0
FEE8  60         RTS
FEE9  A5 FB      LDA $FB
FEEB  D0 93      BNE $FE80
FEED  4C 00 FD   JMP $FD00
FEF0  BA         TSX
FEF1  FF 69 FF   .BYT $FF,$69,$FF
FEF4  9B FF 8B   .BYT $9B,$FF,$8B
FEF7  FF 96 FF   .BYT $FF,$96,$FF
FEFA  30 01      .BYT $30,$01
FEFC  00 FE      .BYT $00,$FE
FEFE  C0 01      .BYT $C0,$01

;    $FF00 ROM for C1 'D/C/W/M ?'
FF00  D8         CLD
FF01  A2 28      LDX #$28
FF03  9A         TXS
FF04  A0 0A      LDY #$0A
FF06  B9 EF FE   LDA $FEEF,Y
FF09  99 17 02   STA $0217,Y
FF0C  88         DEY
FF0D  D0 F7      BNE $FF06
FF0F  20 A6 FC   JSR $FCA6 ;reset ACIA @ $F000
FF12  8C 12 02   STY $0212 ;CTRL-C flag !0 = ignore ctrl-c
FF15  8C 03 02   STY $0203 ;LOAD flag
FF18  8C 05 02   STY $0205 ;SAVE flag
FF1B  8C 06 02   STY $0206 ;time delay for CRT driver
FF1E  AD E0 FF   LDA $FFE0 ;$FFE0 - cursor start
FF21  8D 00 02   STA $0200
FF24  20 D5 FC   JSR $FCD5 ;(erase 2K screen)
FF27  D0 0C      BNE $FF35 ;(branch always)
FF29  48         PHA
FF2A  C9 7F      CMP #$7F
FF2C  D0 03      BNE $FF31
FF2E  4C E8 FB   JMP $FBE8
FF31  68         PLA
FF32  4C BE FA   JMP $FABE
FF35  B9 5F FF   LDA $FF5F,Y  ;D/C/W/M ?
FF38  F0 06      BEQ $FF40
FF3A  20 2D BF   JSR $BF2D	;BASIC screen print
FF3D  C8         INY
FF3E  D0 F5      BNE $FF35
FF40  20 BA FF   JSR $FFBA
FF43  C9 4D      CMP #'M
FF45  D0 03      BNE $FF4A
FF47  4C 00 FE   JMP $FE00 ;jump to monitor
FF4A  C9 57      CMP #'W
FF4C  D0 03      BNE $FF51
FF4E  4C 00 00   JMP $0000 ;jump to warm start
FF51  C9 43      CMP #'C
FF53  D0 03      BNE $FF58
FF55  4C 11 BD   JMP $BD11 ;jump to cold start
FF58  C9 44      CMP #'D
FF5A  D0 A4      BNE $FF00
FF5C  4C 00 FC   JMP $FC00;jump to disk boot
FF5F  44 2F      .BYTE 'D/C/W/M ?',0
FF61  43 2F      
FF63  57 2F      
FF65  4D 20 3F
FF68  00 
FF69  20 29 FF   JSR $FF29
FF6C  48         PHA
FF6D  AD 05 02   LDA $0205
FF70  F0 22      BEQ $FF94
FF72  68         PLA
FF73  20 B1 FC   JSR $FCB1
FF76  C9 0D      CMP #$0D
FF78  D0 1B      BNE $FF95
FF7A  48         PHA
FF7B  8A         TXA
FF7C  48         PHA
FF7D  A2 0A      LDX #$0A
FF7F  A9 00      LDA #$00
FF81  20 B1 FC   JSR $FCB1
FF84  CA         DEX
FF85  D0 FA      BNE $FF81
FF87  68         PLA
FF88  AA         TAX
FF89  68         PLA
FF8A  60         RTS
FF8B  48         PHA
FF8C  CE 03 02   DEC $0203
FF8F  A9 00      LDA #$00
FF91  8D 05 02   STA $0205
FF94  68         PLA
FF95  60         RTS
FF96  48         PHA
FF97  A9 01      LDA #$01
FF99  D0 F6      BNE $FF91
FF9B  AD 12 02   LDA $0212
FF9E  D0 19      BNE $FFB9
FFA0  A9 FE      LDA #$FE
FFA2  8D 00 DF   STA $DF00
FFA5  2C 00 DF   BIT $DF00
FFA8  70 0F      BVS $FFB9
FFAA  A9 FB      LDA #$FB
FFAC  8D 00 DF   STA $DF00
FFAF  2C 00 DF   BIT $DF00
FFB2  70 05      BVS $FFB9
FFB4  A9 03      LDA #$03
FFB6  4C 36 A6   JMP $A636
FFB9  60         RTS
FFBA  2C 03 02   BIT $0203	;test load flag
FFBD  10 19      BPL $FFD8
FFBF  A9 FD      LDA #$FD  ;test space bar press
FFC1  8D 00 DF   STA $DF00
FFC4  A9 10      LDA #$10
FFC6  2C 00 DF   BIT $DF00
FFC9  F0 0A      BEQ $FFD5 ;branch if pressed
FFCB  AD 00 F0   LDA $F000 ;test input from ACIA
FFCE  4A         LSR A
FFCF  90 EE      BCC $FFBF
FFD1  AD 01 F0   LDA $F001
FFD4  60         RTS
FFD5  EE 03 02   INC $0203 ;disable load flag
FFD8  4C 79 FA   JMP $FA79
FFDB  FF FF FF   .BYT $FF,$FF,$FF
FFDE  FF FF      .BYT $FF,$FF
FFE0  65         .BYT $65  ; $FFE0 - cursor start
FFE1  17         .BYT $17  ; $FFE1 - line len-1   (wrap position)
FFE2  00         .BYT $00  ; $FFE2 - 00 = 1K vid, 01=2K vid otherwise serial or other ROM
FFE3  00         .BYT $00
FFE4  03 FF      .BYT $03,$FF
FFE6  9F 00 03   .BYT $9F,$00,$03
FFE9  FF 9F      .BYT $FF,$9F
FFEB  6C 18 02   JMP ($0218)	;input vector
FFEE  6C 1A 02   JMP ($021A)	;output vector
FFF1  6C 1C 02   JMP ($021C)	;ctrl-c vector check
FFF4  6C 1E 02   JMP ($021E)	;load vector
FFF7  6C 20 02   JMP ($0220)	;save vector
FFFA  30 01      .BYT $30,$01 ;<IRQ> 
FFFC  00 FF      .BYT $00,$FF ;<RESET>
FFFE  C0 01      .BYT $C0,$01 ;<NMI>