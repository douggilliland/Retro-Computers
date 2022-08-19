; HEXDOS 4 
;
; Copyright (c) 1980-2015 Steven P. Hendrix
;
; All Rights Reserved.
;
; HexDOS was developed by Steven P. Hendrix (The Author), who can be reached at
; Hx Engineering, LLC, 8660 Brandywine, Sagamore Hills OH 44067
; (SteveHx@HxEngineering.com).
;
; Permission is hereby granted, free of charge, to any person obtaining a copy of
; the HEXDOS source code and any accompanying documentation (the "Software"), to
; use, copy, modify, merge, publish, or distribute the Software or software
; derived from it ("Derivative Works") for strictly non-commercial hobbyist
; purposes, and to permit persons to whom the Software is furnished to do so,
; subject to the following conditions:
;
; 1. The above copyright notice and this permission notice shall be included in
;    all copies of the Software source code and the source code of Derivative Works
;    and included with all binary copies of the Software or Derivative works.
;
; 2. The word "HEXDOS" shall not be used to refer to Derivative Works except in
;    the phrase "Based on HEXDOS by Steven P. Hendrix" provided that such phrase
;    is not used to promote the Derivative Work or to imply that The Author
;    endorses you or the Derivative Work.
;
; 3. The source code for any Derivative Work based on this software shall be made
;    readily available to the public for strictly non-commercial hobbyist purposes,
;    free of charge.
;
; 4. Permission and conditions for any purpose other than stated above are not
;    granted under this license and must be obtained in writing from The Author.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
; OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
; HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
; WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
; OTHER DEALINGS IN THE SOFTWARE.
;
;
;

P0-5000

   10; HEXDOS 4.0 
   20; COPYRIGHT (C) 1980-2015 
   30; STEVEN P. HENDRIX 
   40; LAST MOD 8 MAR 83 
   50TRACK =$D8 ;CURRENT HEAD POSITION 
   60TEMP1 =$D9 
   70TEMP2 =$DA 
   80TEMP3 =$DB 
   90TEMP4 =$DC 
  100CRPRGS=$DE ;FIRST TRACK OF CURRENT PROGRAM 
  110CRPRGE=$DF ;LAST TRACK + 1 
  120EDITFL=$E0 
  130SWTRK =$E1 
  140IOPTR =$E2 ;CURRENT IO DEVICE # 
  150MASK  =$E3 
  160CKSEEK=$E6 
  170LSTCHR=$E7 
  180CLOCK =$E8 
  190TASK  =$EC 
  200XTEMP =$F2 
  210YTEMP =$F3 
  215CHRTMP=$0133 
  220CLSCHR=3 
  230TIMOUT=$FC 
  240DTERR =$17 ;SEEK ERROR (DISK TRACK) 
  250FDERR =$EA ;FILE DOESN'T EXIST 
  260ORERR =$26 ;OUT OF ROOM (IN FILE) 
  270EAERR =$39 ;EXISTS ALREADY 
  280ROERR =$25 ;READ ONLY (WRITE-PROTECTED) 
  290INERR =$2A ;INPUT FILE 
  300DFERR =$07 ;DIRECTORY FORMAT 
  310PXERR =$68 ;PROG EXT 
  320FLOPUP=$FC0C 
  330FLOPIN=$C000 
  340FLOPOT=$C002 
  350FLOPDA=$C010 
  360PRSTAT=$D900 
  370PRDATA=$D900 
  380KEYBD =$DF00 
  390OLDLOD=$FF8B 
  400OLDINP=$FFBA 
  410OLDOUT=$FF69 
  420DELAY =$FC91 
  430READSK=$FC9C 
  440ROMDET=$FEFF ;01=OLDMON, 60=C1E, FF=C1S 
  450*=$236 ;DISK FILE HEADERS 
  460DBADDR=*   ;START OF BUFFER 
  470DBPTR =*+2 ;POINTER TO NEXT CHARACTER 
  480STTRK =*+4 ;FIRST TRACK OF FILE 
  490ENDTRK=*+5 ;LAST TRACK OF FILE + 1 
  500TRKNUM=*+6 ;TRACK CURRENTLY IN BUFFER 
  510*=$0300 
  520       JSR MOVE 
  530       .WORD $BD15,DBADDR-1 
  540       .BYTE $C2-$16 
  550       .BYTE $23-$16,GETVAL 
  560       .BYTE $25-$16 
  570              .DBYTE GETVAL 
  580       *=*-1 
  590       .BYTE $3D-$16,USR 
  600       .BYTE $3F-$16 
  610              .DBYTE USR 
  620       *=*-1 
  630       .BYTE $8C-$16,$0C 
  640       .BYTE $C2-$16,$4C 
  650       .BYTE $C3-$16,INTER 
  660       .BYTE $C4-$16 
  670              .DBYTE INTER 
  680       *=*-1 
  690       .BYTE $FF 
  700       JSR DBADDR 
  710INTER 
  720       JSR MOVE 
  730       .WORD $BDC1,DBADDR-1 
  740       .BYTE $139-$C2 
  750       .BYTE $1F5-$C2,$0C 
  760       .BYTE $124-$C2,PROMPT 
  770       .BYTE $126-$C2 
  780              .DBYTE PROMPT 
  790       *=*-1 
  800       .BYTE $12F-$C2,WARM 
  810       .BYTE $131-$C2 
  820               .DBYTE WARM 
  830       *=*-1 
  840       .BYTE $136-$C2,$4C 
  850       .BYTE $137-$C2,WARM-4 
  860       .BYTE $138-$C2 
  870               .DBYTE WARM-4 
  880       *=*-1 
  890       .BYTE $FF 
  900       JSR DBADDR 
  910       DEC $7A 
  920       DEC $C4 
  930WARM   JSR MOVE 
  940       .WORD FLOPUP-1,DBADDR-1 
  950       .BYTE $4D-$C 
  960       .BYTE $11-$C,$8D 
  970       .BYTE $4D-$C,$60 
  980       .BYTE $FF 
  990       LDA #4 
 1000       STA FLOPIN+1 
 1010       LDA #$40 
 1020       STA FLOPIN 
 1030       JSR DBADDR 
 1040; CLEAR DBADDR 
 1050       LDX #$300-DBADDR 
 1060       LDA #$FF 
 1070       STA DBADDR-1,X 
 1080       DEX 
 1090       BNE *-4 
 1100       STX TRACK 
 1110       DEX 
 1120       TXS 
 1130       JSR MOVE 
 1140       .WORD PZERO-1,$DF 
 1150       .BYTE $EF-$E0 
 1160       .BYTE $130-$E0,$4C 
 1170       .BYTE $131-$E0,SECOND 
 1180       .BYTE $132-$E0 
 1190              .DBYTE SECOND 
 1200       *=*-1 
 1210       .BYTE $FF 
 1220;ENABLE CLOCK 
 1230       LDA #$C 
 1240       STA FLOPIN+1 
 1250;MODIFY P. 2 
 1260       JSR MOVE 
 1270       .WORD PAGE2-1,$217 
 1280       .BYTE 10 
 1290       .BYTE $228-$218,$44 
 1300       .BYTE $FF 
 1310;SET UP INTERCEPTOR 
 1320       JSR MOVE 
 1330       .WORD ICPTCD-1,$BB 
 1340       .BYTE 6 
 1350       .BYTE $CC-$BC,$F2 
 1360       .BYTE $FF 
 1370       JSR $A86C ;CR-LF 
 1380       JSR $A491 ;CLEAR STACKS 
 1390       JMP $A5C2 ;RUN BOOTSTRAP 
 1400PZERO  .BYTE $FF,$FF,0,$7F,0,0,0,0,0,0,0 
 1410       .BYTE $FF,$FF,$FF,TIMOUT 
 1420PAGE2  .WORD INPUT,OUTPUT,BREAK,LOAD,SAVE 
 1430ICPTCD JMP INTCPT 
 1440       JMP ICPTE 
 1450MOVE   PLA           ; MOVE AND PATCH 
 1460       STA XTEMP     ; JSR MOVE 
 1470       PLA           ; .WORD source start - 1,dest  
 1480       STA YTEMP     ; .BYTE # of bytes 
 1490       LDY #$FC      ; .BYTE offset,newbyte 
 1500       JSR INTGC     ; etc. 
 1510       STA $FFDD,Y   ; .BYTE $FF 
 1520       INY 
 1530       BNE *-7 
 1540       JSR INTGC 
 1550       TAY 
 1560       LDA (TEMP1),Y 
 1570       STA (TEMP3),Y 
 1580       DEY 
 1590       BNE *-5 
 1600       BEQ *+7 
 1610       JSR INTGC 
 1620       STA (TEMP3),Y 
 1630       JSR INTGC 
 1640       TAY 
 1650       INY 
 1660       BNE *-10 
 1670       JSR INTGC 
 1680       JMP (XTEMP) 
 1690INTGC  INC XTEMP 
 1700       BNE *+4 
 1710       INC YTEMP 
 1720       LDX #0 
 1730       LDA (XTEMP,X) 
 1740RTN4   RTS 
 1750SECOND PHA 
 1760       INC CLOCK 
 1770       BNE *+8 
 1780       INC CLOCK+1 
 1790       BNE *+4 
 1800       INC CLOCK+2 
 1810       INC TASK+2 
 1820       BNE *+9 
 1830       INC TASK+3 
 1840       LDA #$CF 
 1850       STA $C002 
 1860       LDA $C000 
 1870       PLA 
 1880       RTI 
 1890BREAK  LDA TASK 
 1900       ORA TASK+3 
 1910       BNE *+7 
 1920       DEC TASK 
 1930       JMP $A69C 
 1940       LDA $88  ; SKIP FOR IMMEDIATE 
 1950       CMP #$FF 
 1960       BEQ CKBRK 
 1970       LDX #0 
 1980       STX IOPTR 
 1990       LDX $212 
 2000       BEQ CKBRK 
 2010       CPX #1 
 2020       BEQ RTN4 ; IF NO-BREAK MODE 
 2030       LDY $87 ;NOW HAVE STATEMENT NUMBER IN A:Y 
 2040       JSR $AFC1 ;CONVERT TO FLOATING POINT 
 2050       JSR $B96E ;AND THENCE TO STRING AT $0100 
 2060       LDX #$5B ;INSERT LEFT BRACKET 
 2070       STX $0100 
 2080       JSR $A8C3 ;PRINT STRING 
 2090       LDA #$5D ;AND THEN THE RIGHT BRACKET 
 2100       JSR $A8E5 
 2110       BIT $0212 ;CHECK FOR STEP MODE 
 2120       BEQ CKBRK 
 2130       JSR $FD00 ;WAIT FOR A KEY 
 2140       CMP #$0A ;LF 
 2150       BEQ CKBRK 
 2160       CMP #$0D ;CR 
 2170       BNE *-9 
 2180       LDA #0 ;DISABLE TRACE AND CONTINUE 
 2190       STA $0212 
 2200;CHECK FOR BREAK KEY ON MODIFIED KEYBOARD 
 2210CKBRK  LDA #$FE 
 2220       STA KEYBD 
 2230       LDA KEYBD 
 2240       BMI *+6 
 2250       SEC 
 2260       JMP $A63D 
 2270       LSR ROMDET 
 2280       BCC *+5 ; C1E 
 2290       JMP $FF9B 
 2300       JMP $FB94 
 2310USR    JSR $B412 
 2320       TAX 
 2330       BNE *+11 
 2340       STY IOPTR ; INPUT FROM DEVICE # 
 2350       JSR $FFEB 
 2360       TAY 
 2370       JMP $AFD0 ;AND RETURN VALUE OF CHAR 
 2380       BPL TONE 
 2390       TYA 
 2400       CMP #$FB 
 2410       BNE *+10 
 2420       JSR GETVAL ;JUMP TO SPECIFIED ADDRESS 
 2430       STA $AD 
 2440       JMP ($AD) 
 2450       BCS *+12 
 2460       CMP #$F9 
 2470       BEQ *+5 
 2480       JMP $FE00 
 2490       JMP ($00F0) ;USR(-7) ROUTINE 
 2500       TAX ;RETURN VALUE OF ONE BYTE OF CLOCK 
 2510       LDY CLOCK+4,X 
 2520       JMP $AFD0 
 2530TONE   LDA #$58 
 2540       STA TEMP3 
 2550       LDA #0 
 2560       STA TEMP1 
 2570       LDA #8 
 2580       STA TEMP2 
 2590TNLP2  LDA TEMP3 
 2600       EOR #$40 
 2610       STA TEMP3 
 2620       STA FLOPDA 
 2630       LDX $AF 
 2640TNLOOP DEC TEMP1 
 2650       BNE *+15 
 2660       DEC TEMP2 
 2670       BNE *+11 
 2680       LDA #8 
 2690       STA TEMP2 
 2700       DEC $AE 
 2710       BNE *+3 
 2720       RTS 
 2730       DEX 
 2740       BNE TNLOOP 
 2750       BEQ TNLP2 
 2760DK2TRK BIT FLOPIN 
 2770       BVS *+4 
 2780       ORA #$80 
 2790       RTS 
 2800;STEP HEAD ONE TRACK HIGHER IF CARRY SET 
 2810;ONE TRACK LOWER IF CARRY IS CLEAR 
 2820;AND UPDATE TRACK COUNTER 
 2830HEAD   PHA 
 2840       BCC *+8 
 2850       INC TRACK 
 2860       LDA #$FB 
 2870       BNE *+6 
 2880       DEC TRACK 
 2890       LDA #$FF 
 2900       STA FLOPOT 
 2910       AND #$F7 
 2920       STA FLOPOT 
 2930       ORA #$08 
 2940       STA FLOPOT 
 2950       LDX #4 ; HEAD STEP DELAY x 1.25 mSec 
 2960       JSR DELAY 
 2970       PLA 
 2980       RTS 
 2990;SEEK TRACK # IN A, PRESERVING ALL REGISTERS 
 3000;AND VERIFY TRACK IDENTITY IF ENABLED 
 3010SEEK   STA $FF 
 3020       TXA 
 3030       PHA 
 3040       TYA 
 3050       PHA 
 3060       LDX #TIMOUT 
 3070       STX $EE 
 3080       LDX #$FF 
 3090       STX $EF 
 3100       LDA $FF 
 3110       ROR A 
 3120       EOR FLOPIN 
 3130       ROL A 
 3140       BMI *+18 
 3150       LDA FLOPIN 
 3160       EOR #$40 
 3170       STA FLOPIN 
 3180       LDA TRACK 
 3190       LDY SWTRK 
 3200       STA SWTRK 
 3210       STY TRACK 
 3220       LDA $FF 
 3230       CMP TRACK 
 3240       BEQ *+8 
 3250       JSR HEAD 
 3260       JMP *-7 
 3270       LDX #$7F 
 3280       STX FLOPOT 
 3290       JSR DELAY ; OR "HOLE" FOR ADDED RELIABILITY 
 3300       JSR HOLE 
 3310       PLA 
 3320       TAY 
 3330       PLA 
 3340       TAX 
 3350       BIT CKSEEK 
 3360       BMI RTN2 
 3370       LDA TRACK 
 3380       ASL A 
 3390       BNE NONZTR 
 3400       JSR READSK 
 3410RDTWO  JSR READSK 
 3420       JMP READSK 
 3430NONZTR JSR READSK 
 3440       CMP #$57 
 3450       BNE *-5 
 3460       JSR READSK 
 3470       JSR DK2TRK 
 3480       CMP TRACK 
 3490       BEQ RTN2 
 3500       LDX #DTERR 
 3510       JMP ERR0R 
 3520HOLE   STA $C020 ;RESET TIMER 
 3530       BIT FLOPIN 
 3540       BMI *-3 
 3550       BIT FLOPDA+1 
 3560       BIT FLOPIN 
 3570       BPL *-6 
 3580RTN2   RTS 
 3590PATCHP JSR MOVE 
 3600       .WORD $A31B,$FF 
 3610       .BYTE $4B-$1C 
 3620       .BYTE $2B-$1C,$60 
 3630       .BYTE $FF 
 3640       JMP $100 
 3650LOAD   BNE *+6 
 3660       DEC $203 
 3670       RTS 
 3680       CMP #'! 
 3690       BNE LOAD1 
 3700       LDA #$FF 
 3710       STA SWTRK 
 3720       STA CKSEEK 
 3730       LDA FLOPIN 
 3740       ASL A 
 3750       AND #$80 
 3760       JSR SEEK 
 3770       LDA #0 
 3780       STA CKSEEK 
 3790       JMP $BC 
 3800LOAD1  CMP #$A6 ;/ 
 3810       BNE LDPGM 
 3820       JSR ICPTE 
 3830       LDA #1 
 3840       JSR DK2TRK 
 3850       TAX 
 3860       TAY 
 3870       INY 
 3880       BNE NOTFND+4 
 3890;ROUTINE FOR 'LOAD #T,M' 
 3900LDMEM  JSR SETMEM 
 3910;LOAD TRACK A TO ADDRESS X:Y 
 3920LDTRK  JSR SEEK 
 3930       STX $FE 
 3940       STY $FD 
 3950       LDA #8 
 3960       STA $FF 
 3970       CLC 
 3980       ADC $FE 
 3990       TAX 
 4000       JSR $FC79 
 4010       LDY $FD 
 4020       LDA TRACK 
 4030       RTS 
 4040LDPGM  CMP #'# 
 4050       BEQ LDMEM 
 4060       CMP #$A5 ;* 
 4070       BEQ LDDAT 
 4080       JSR FIND 
 4090       BCS *+6 
 4100NOTFND LDX #FDERR 
 4110       BNE ERR0R 
 4120       STX CRPRGS 
 4130       STY CRPRGE 
 4140       LDY #0 
 4150       LDA ($69),Y 
 4160       CMP #'$ 
 4170       BNE NOTML 
 4180       LDA CRPRGS 
 4190       JSR SEEK ;YES 
 4200       JSR READSK 
 4210       TAY 
 4220       JSR READSK 
 4230       TAX 
 4240       STY $F0 
 4250       STX $F1 
 4260       TYA 
 4270       SEC 
 4280       SBC #2 
 4290       TAY 
 4300       BCS *+9 
 4310       DEX 
 4320       BCC *+6 
 4330NOTML  LDX $7A 
 4340       LDY $79 
 4350       LDA CRPRGS 
 4360       JSR LDTRK 
 4370       CLC 
 4380       ADC #1 
 4390       CMP CRPRGE 
 4400       BCC *-8 
 4410       JSR PATCHP 
 4420       LDA $71 
 4430       CLC 
 4440       ADC #2 
 4450       STA $7B 
 4460       STA $7D 
 4470       STA $7F 
 4480       LDA $72 
 4490       ADC #0 
 4500       STA $7C 
 4510       STA $7E 
 4520       STA $80 
 4530       RTS 
 4540; ENTER WITH TYPE # IN X (OFFSET FROM $A164) 
 4550ERR0R  LDY #0 
 4560       STY IOPTR 
 4570       LDA TASK+1 
 4580       BMI BERROR 
 4590       STY $11 
 4600       STA $12 
 4610       STX CLOCK+3 
 4620       DEY 
 4630       STY TASK+1 
 4640       JSR $A6D0 
 4650       LDA #3 
 4660       JMP $A5EE 
 4670;CONVERT # FROM EXECUTION STREAM TO FILE BUFFER # 
 4680;SET UP DATA FILE HEADER 
 4690LDDAT  JSR FILNUM 
 4700       JSR HDRADR 
 4710       LDA $81 
 4720       STA DBADDR,X 
 4730       STA DBPTR,X 
 4740       LDA $82 
 4750       STA DBPTR+1,X 
 4760       SEC 
 4770       SBC #$08 
 4780       STA $82 
 4790       STA DBADDR+1,X 
 4800       TXA 
 4810       PHA 
 4820       JSR $AC01 
 4830       JSR FIND 
 4840       BCS *+6 
 4850       LDX #FDERR 
 4860       BNE ERR0R 
 4870       STX TEMP1 
 4880       PLA 
 4890       TAX 
 4900       LDA TEMP1 
 4910       STA STTRK,X 
 4920       SBC #1 
 4930       STA TRKNUM,X 
 4940       TYA 
 4950       STA ENDTRK,X 
 4960       RTS 
 4970; CONVERT IMMEDIATE # TO FILE BUFFER # 
 4980FILNUM JSR GETVAL-3 
 4990       SEC 
 5000       SBC #4 

.P5000:_  -15000

 5000       SBC #4 
 5010       BCS *+7 
 5020       LDX #8 
 5030BERROR JMP $A24E 
 5040       CMP #24 
 5050       BCS *-7 
 5060       RTS 
 5070;GET TRACK # AND ADDRESS IN THE FORM T,A 
 5080;FROM EXECUTION STREAM AND CONVERT TO 
 5090;TRACK # IN A AND MEMORY ADDRESS IN X:Y 
 5100SETMEM JSR GETVAL-3 
 5110       PHA 
 5120       LDA $AE 
 5130       BNE BERROR-2 
 5140       JSR $AC01 ;CHECK FOR AND DICARD COMMA 
 5150       JSR GETVAL 
 5160       TAY 
 5170       PLA 
 5180       LDX $AE 
 5190       RTS 
 5200       JSR $BC ; 
 5210;GET VALUE OF ARITHMETIC EXPRESSION IN $AF:$AE 
 5220GETVAL JSR $AAC1 
 5230       JSR $B412 
 5240       TYA 
 5250       RTS 
 5260; COMPUTE # OF TRACKS NEEDED FOR PROGRAM 
 5270NMTRKS CLC ;YES, THIS IS DELIBERATE 
 5280       LDA $7B 
 5290       SBC $79 
 5300       LDA $7C 
 5310       SBC $7A 
 5320       LSR A 
 5330       LSR A 
 5340       LSR A 
 5345       NOP ; SPACE FOR LSR FOR DOUBLE DENSITY 
 5350       CLC 
 5360       ADC #1 
 5370       RTS 
 5380;DIRECTORY LOOKUP RETURNS START TRACK IN X 
 5390;AND END TRACK + 1 IN Y 
 5400;CARRY IS SET IF FOUND 
 5410FIND   JSR FILNAM 
 5420       LDA #1 
 5430       JSR DK2TRK 
 5440       JSR SEEK 
 5450FINDLP JSR GETTNO 
 5460       BCC FNDRET 
 5470       STA TEMP1 
 5480       LDY #0 
 5490       JSR READSK 
 5500       BEQ FILFND 
 5510       CMP ($69),Y 
 5520       BNE *+5 
 5530       INY 
 5540       BNE *-10 
 5550       JSR READSK 
 5560       BNE *-3 
 5570       BEQ FINDLP 
 5580FILFND CPY $68 
 5590       BNE FINDLP 
 5600       JSR GETTNO 
 5610       BCC DIRERR 
 5620       TAY 
 5630FNDRET LDX TEMP1 
 5640       RTS 
 5650GETTNO JSR RDTWO 
 5660       BNE *+4 
 5670       CLC 
 5680       RTS 
 5690       JSR READSK 
 5700       JSR DK2TRK 
 5710       PHA 
 5720       JSR READSK 
 5730       BNE DIRERR 
 5740       PLA 
 5750       RTS 
 5760DIRERR LDX #DFERR 
 5770       BNE ERROR1 
 5780;TRANSMIT A BYTE FROM A TO THE DISK HEAD 
 5790SVBYTE PHA 
 5800       LDA #2 
 5810       BIT FLOPDA 
 5820       BEQ *-3 
 5830       PLA 
 5840       STA FLOPDA+1 
 5850       RTS 
 5860FILNAM JSR $AAC1 
 5870       JSR $AAB2 
 5880       LDY #2 
 5890       LDA ($AE),Y 
 5900       STA $68,Y 
 5910       DEY 
 5920       BPL *-6 
 5930       LDY #$68 
 5940       STY $65 
 5950       RTS 
 5960SAVE   BEQ *+5 
 5970       JMP SVNAME 
 5980       JSR NMTRKS ;SAVE TO ORIGINAL TRACKS 
 5990       ADC CRPRGS 
 6000       SBC CRPRGE 
 6010       BMI *+7 
 6020       LDX #PXERR 
 6030ERROR1 JMP ERR0R 
 6040;SAVE PROGRAM TO CRPRGS THRU CRPRGE-1 
 6050SVPROG LDA CRPRGS 
 6060       LDX $7A 
 6070       LDY $79 
 6080       JSR SVTRK 
 6090       CLC 
 6100       ADC #1 
 6110       CMP CRPRGE 
 6120       BCC *-8 
 6130       RTS 
 6140;SAVE #TRACK,ADDRESS 
 6150SVMEM  JSR SETMEM 
 6160;SAVE MEMORY X:Y ON TRACK # A 
 6170SVTRK  JSR SEEK 
 6180       LDA #$20 
 6190       BIT FLOPIN 
 6200       BNE *+7 
 6210       LDX #ROERR 
 6220       JMP ERR0R 
 6230       STX TEMP2 
 6240       STY TEMP1 
 6250       JSR WRTHDR 
 6260       LDX #9 
 6270       LDA (TEMP1),Y 
 6280       JSR SVBYTE 
 6290       INY 
 6300       BNE *+5 
 6310       INC TEMP2 
 6320       DEX 
 6330       CPY #150 ; NUMBER OF BYTES IN PAGE 9 
 6340       BNE *-13 
 6350       CPX #1 
 6360       BNE *-4 
 6370       NOP 
 6380       LDA #$FF 
 6390       JSR SVBYTE 
 6400       JSR SVBYTE 
 6410       STA FLOPOT 
 6420       LDA TRACK 
 6430       LDX TEMP2 
 6440       LDY TEMP1 
 6450       RTS 
 6460; WRITE TRACK HEADER ON DISK 
 6470WRTHDR LDA #$FE 
 6480       AND FLOPOT 
 6490       STA FLOPOT 
 6500       JSR HOLE 
 6510       LDY #0 
 6515       DEY 
 6520       BNE *-1 
 6530       LDA TRACK 
 6540       AND #$7F 
 6550       BNE *+17 
 6560       LDA TEMP2 
 6570       JSR SVBYTE 
 6580       LDA TEMP1 
 6590       JSR SVBYTE 
 6600       LDA #9 
 6610       JMP SVBYTE 
 6620       PHA 
 6630       LDA #$57 
 6640       JSR SVBYTE 
 6650       PLA 
 6660       JMP SVBYTE 
 6670SVNAME CMP #'# 
 6680       BEQ SVMEM 
 6690       CMP #$A5 ;* 
 6700       BNE *+5 
 6710       JMP SVDAT 
 6720       CMP #'& 
 6730       BNE *+21 
 6740       JSR $BC 
 6750       JSR FIND ;SAVE TO A DIFFERENT FILE 
 6760       BCS *+6 
 6770       LDX #FDERR 
 6780       BNE *+16 
 6790       STX CRPRGS 
 6800       STY CRPRGE 
 6810       JMP SAVE+5 
 6820       JSR FIND ;CREATE A NEW FILE AND SAVE 
 6830       BCC *+7 
 6840       LDX #EAERR 
 6850       JMP ERR0R 
 6860       STX CRPRGS 
 6870       JSR NMTRKS 
 6880       ADC CRPRGS 
 6890       STA CRPRGE 
 6900       JSR SVPROG 
 6910       LDA #1 ;UPDATE DIRECTORY WITH NEW FILE 
 6920       JSR DK2TRK 
 6930       LDX $7A 
 6940       LDY $79 
 6950       JSR LDTRK 
 6960       LDA CRPRGS 
 6970       AND #$7F 
 6980       STA $11 
 6990       LDA #0 
 7000       STA $12 
 7010       JSR $A432 
 7020       LDA $AA 
 7030       ADC #3 
 7040       STA $AA 
 7050       BCC *+4 
 7060       INC $AB 
 7070       LDY #0 
 7080       LDA ($69),Y 
 7090       STA ($AA),Y 
 7100       INY 
 7110       CPY $68 
 7120       BNE *-7 
 7130       TYA 
 7140       CLC 
 7150       ADC $AA 
 7160       STA $AA 
 7170       BCC *+4 
 7180       INC $AB 
 7190       LDY #8 
 7200       LDA FILTRM,Y 
 7210       STA ($AA),Y 
 7220       DEY 
 7230       BPL *-6 
 7240       LDA CRPRGE 
 7250       AND #$7F 
 7260       LDY #3 
 7270       STA ($AA),Y 
 7280       JSR PATCHP 
 7290       LDA #1 
 7300       JSR DK2TRK 
 7310       LDX $7A 
 7320       LDY $79 
 7330       JSR SVTRK 
 7340       LDA CRPRGS 
 7350       LDX $7A 
 7360       LDY $79 
 7370       JMP LDTRK 
 7380FILTRM .BYTE 0,11,11,0,0,$A5,0,0,0 
 7390;CLOSE A DATA FILE BY WRITING THE LAST BUFFER OUT 
 7400SVDAT  JSR FILNUM 
 7410SVBUFF JSR HDRADR 
 7420       BEQ *+7 
 7430       LDX #INERR 
 7440       JMP ERR0R 
 7450       TXA 
 7460       PHA 
 7470       LDA TRKNUM,X 
 7480       CMP STTRK,X 
 7490       BCC NDSKOP 
 7500       CMP ENDTRK,X 
 7510       BCC *+7 
 7520       LDX #ORERR 
 7530       JMP ERR0R 
 7540       PHA 
 7550       LDY DBADDR,X 
 7560       LDA DBADDR+1,X 
 7570       TAX 
 7580       PLA 
 7590       JSR SVTRK 
 7600NDSKOP PLA 
 7610       TAX 
 7620       LDA DBADDR,X 
 7630       STA DBPTR,X 
 7640       STA TEMP1 
 7650       LDA DBADDR+1,X 
 7660       STA DBPTR+1,X 
 7670       STA TEMP2 
 7680       LDA #0 
 7690       TAY 
 7700       LDX #8 
 7710       STA (TEMP1),Y 
 7720       INY 
 7730       BNE *-3 
 7740       INC TEMP2 
 7750       DEX 
 7760       BNE *-8 
 7770RTN5   RTS 
 7780INPUT  LDA IOPTR 
 7790       CMP #2 
 7800       BCS TAPEIN 
 7810       LSR ROMDET 
 7820       BCC *+8 
 7830       JSR OLDINP 
 7840       JMP *+6 
 7850       JSR $FB46 
 7860       BIT $0203 
 7870       BMI RTN5 
 7880       CMP #$1B 
 7890       BCS *+5 
 7900       JSR OUTPUT 
 7910       INC ROMDET 
 7920       BEQ RTN5 
 7930       STX TEMP3 
 7940       STY TEMP4 
 7950       TAX 
 7960       BNE INPUT1 
 7970       LDX #$FE  ;REPEAT KEY 
 7980       TXS 
 7990       STA $C4 
 8000       LDX #$12 
 8010       STX $C3 
 8020       JMP $A5F6 
 8030INPUT1 CMP #$7F 
 8040       BNE *+36 
 8050       DEC TEMP3 ;HANDLE RUBOUT 
 8060       DEC $0E 
 8070       JSR $BFC2 
 8080       DEC $0200 
 8090       LDA $0200 
 8100       AND #$1F 
 8110       CMP #$05 
 8120       BCS *+10 
 8130       LDA $0200 
 8140       SBC #7 
 8150       STA $0200 
 8160       JSR $BFDE 
 8170       LDX TEMP3 
 8180       LDA #0 
 8190       CMP #$1B 
 8200       BNE *+5 
 8210       LDA $0201 ;HANDLE ESCAPE KEY 
 8220       CMP #$1D 
 8230       BNE *+8 
 8240       LDA #2 ;HANDLE SHIFT-RETURN 
 8250       STA EDITFL 
 8260       LDA #$0D 
 8270       LDX TEMP3 
 8280       LDY TEMP4 
 8290       RTS 
 8300TAPEIN SBC #4 
 8310       BCS DISKIN 
 8320       JMP $FE80 ;GET CHAR FROM TAPE 
 8330DISKIN STX TEMP3 
 8340       STY TEMP4 
 8350       JSR HDRADR 
 8360       BNE *+7 
 8370       LDX #INERR 
 8380       JMP ERR0R 
 8390       JSR CKEND 
 8400       BCC NOTRKI 
 8410;HAVE READ PAST END OF BUFFER - GET NEXT TRACK 
 8420       TXA 
 8430       PHA 
 8440       INC TRKNUM,X 
 8450       LDA TRKNUM,X 
 8460       CMP ENDTRK,X 
 8470       BCC *+7 
 8480       LDX #ORERR 
 8490       JMP ERR0R 
 8500       PHA 
 8510       LDA DBADDR,X 
 8520       STA DBPTR,X 
 8530       TAY 
 8540       LDA DBADDR+1,X 
 8550       STA DBPTR+1,X 
 8560       TAX 
 8570       PLA 
 8580       JSR LDTRK 
 8590       PLA 
 8600       TAX 
 8610;GET NEXT CHAR FROM BUFFER 
 8620NOTRKI LDY #0 
 8630       LDA DBPTR,X 
 8640       STA TEMP1 
 8650       LDA DBPTR+1,X 
 8660       STA TEMP2 
 8670       LDA (TEMP1),Y 
 8680       STA CHRTMP 
 8690       JMP NCRPTR 
 8700;COMPUTE OFFSET TO FILE POINTERS FOR FILE A+4 
 8710HDRADR ASL A 
 8720       ASL A 
 8730       ASL A 
 8740       TAX 
 8750       AND #$08 
 8760       RTS 
 8770;SET CARRY IF PAST END OF BUFFER 
 8780CKEND  LDA DBPTR,X 
 8790       CMP DBADDR,X 
 8800       LDA DBPTR+1,X 
 8810       SBC DBADDR+1,X 
 8820       CMP #8 
 8830       RTS 
 8840OUTPUT AND MASK 
 8850       STA CHRTMP 
 8860       LDA #$FE ;CHECK FOR PAUSE (CTRL) 
 8870       STA $DF00 
 8880       BIT $DF00 
 8890       BVC *-3 
 8900       LDA IOPTR 
 8910       CMP #1 
 8920       BCS PRINTR 
 8930;OUTPUT TO SCREEN 
 8940       STX TEMP3 
 8950       STY TEMP4 
 8960       LDA CHRTMP 
 8970;AFTER A <SHFT>CR, WAIT ONE LF THEN ENTER IN BUFFER 
 8980       CMP #$0A 
 8990       BNE *+8 
 9000       DEC EDITFL 
 9010       BPL *+4 
 9020       INC EDITFL 
 9030;IGNORE CTRL CHARS IN EDITING 
 9040       CMP #$20 
 9050       BCS SCLEAR 
 9060       DEC EDITFL 
 9070       INC EDITFL 
 9080       BEQ CKCURS 
 9090SCLEAR CMP #CLSCHR 
 9100       BNE PRTCHR 
 9110       LDX #0 
 9120       LDA #$20 
 9130       STA $D000,X 
 9140       STA $D100,X 
 9150       STA $D200,X 
 9160       STA $D300,X 
 9170       INX 
 9180       BNE *-13 
 9190       BEQ RELDRG 
 9200PRTCHR LSR ROMDET 
 9210       BCC *+8 
 9220       JSR OLDOUT 
 9230       JMP *+6 
 9240       JSR $FF9B 
 9250       LDX EDITFL 
 9260       BNE CKCURS 
 9270       CMP #$20 
 9280       BCC CKCURS 
 9290       LDX $0E 
 9300       STX TEMP1 
 9310       DEX 
 9320       CPX $0F 
 9330       BCC *+6 
 9340;RESET EDIT BUFFER POINTER ON CTRL CHAR 
 9350       LDX #0 
 9360       STX $0E 
 9370       STA $13,X ;TO EDIT BUFFER 
 9380;KEEP CURSOR ON SCREEN 
 9390CKCURS LSR ROMDET 
 9400       BCC RELDRG 
 9410       LDA $200 
 9420       AND #$1F 
 9430       CMP #$1D 
 9440       BCC RELDRG 
 9450       JSR $BFC2 
 9460       LDA $0200 
 9470       ADC #7 
 9480       STA $0200 
 9490       JSR $BFDE 
 9500;RESTORE REGISTERS 
 9510RELDRG LDA CHRTMP 
 9520       LDY TEMP4 
 9530       LDX TEMP3 
 9540       RTS 
 9550PRINTR BNE TAPOUT 
 9560       BIT PRSTAT 
 9570       BPL *-3 
 9580       LDA CHRTMP 
 9590       STA PRDATA 
 9600       RTS 
 9610TAPOUT SBC #4 
 9620       BCS DSKOUT 
 9630       LDA CHRTMP 
 9640       JMP $FCB1 ;NORMAL TAPE OUT ROUTINE 
 9650;OUTPUT CHAR TO DISK FILE 
 9660DSKOUT STX TEMP3 
 9670       STY TEMP4 
 9680       JSR HDRADR 
 9690       BEQ *+10 
 9700       LDX #INERR 
 9710       .BYTE $2C 
 9720EOFERR LDX #ORERR 
 9730       JMP ERR0R 
 9740       JSR CKEND 
 9750       BCC *+16 
 9760;SAVE BUFFER AND SET UP NEXT TRACK 
 9770       TXA 
 9780       PHA 
 9790       LDA IOPTR 
 9800       SBC #4 
 9810       JSR SVBUFF 
 9820       PLA 
 9830       TAX 
 9840       INC TRKNUM,X 
 9850;PUT CHAR IN BUFFER AND BUMP POINTER 
 9860       LDA DBPTR,X 
 9870       STA TEMP1 
 9880       LDA DBPTR+1,X 
 9890       STA TEMP2 
 9900       LDY #0 
 9910       LDA CHRTMP 
 9920       STA (TEMP1),Y 
 9930       LDA TRKNUM,X 
 9940       CMP ENDTRK,X 
 9950       BCS EOFERR 
 9960NCRPTR INC DBPTR,X 
 9970       BNE *+5 
 9980       INC DBPTR+1,X 
 9990       BNE RELDRG 
10000PROMPT LDX #0 
10010       STX IOPTR 
10020       LDX EDITFL 
10030       BEQ EDIT 
10040;NOT EDITING SO ISSUE PROMPT 
10050       JMP $A8C3 
10060;EDITING - BUFFER IS ALREADY SET UP AT THIS POINT 
10070;SO SET UP RETURN TO IMMEDIATE MODE AND JUMP TO 
10080;NORMAL LINE INPUT ROUTINE 
10090EDIT   PLA 
10100       PLA 
10110       DEC EDITFL 
10120       LDX TEMP1 
10130       STX $0E 
10140       JSR $A359 
10150       JMP $A280 
10160;INTERCEPT AND MODIFY PRINT#, INPUT#, AND LIST# 
10170INTCPT LDA LSTCHR 
10180       CMP #$84 ;INPUT 
10190       BNE ICPT1 
10200       JSR VECTOR 
10210       LDA IOPTR 
10220       BEQ REGET 
10230       LDA #$FF 
10240       STA $64 
10250       PLA 
10260       CLC 
10270       ADC #2 
10280       PHA 
10290       BNE REGET 
10300ICPTE  INC $C3 
10310       BNE *+4 
10320       INC $C4 
10330REGET  JSR $C2 
10340       STA LSTCHR 
10350RTN    RTS 
10360VECTOR LSR $64 
10370       LDA #0 
10380       STA IOPTR 
10390       JSR ICPTE 
10400       CMP #'# 
10410       BNE REGET 
10420       JSR ICPTE 
10430       JSR GETVAL 
10440       STA IOPTR 
10450       JSR $C2 
10460       BEQ RTN 
10470       CMP #': 
10480       BEQ RTN 
10490       JMP $AC01 
10500ICPT1  CMP #$97 ;PRINT 
10510       BEQ VECTOR 
10520       CMP #$99 ;LIST 
10530       BEQ VECTOR 
10540       CMP #$89 ;RUN 
10550       BNE ICPTE 
10560       JSR ICPTE 
10570       BEQ RTN 
10580       BCC RTN 
10590       CMP #$89 
10600       BEQ REGET 
10610       JSR LDPGM+8 
10620       JSR $A4A7 
10630       BCS REGET 
10640 
10650*=$0B00 
10660.WORD 0,0 
10670;HEXDOS 4.0 
10680;COPYRIGHT 1980 
10690;STEVEN P.. HENDRIX 

.