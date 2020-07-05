 0 REM DIFFERENTIAL V 1.3
 1 C$=CHR$(12):FORI=1TO45:H$=H$+CHR$(135):NEXT
 2 GOSUB90:REM input functions
 3 POKE11,0:POKE12,253:DIMA(40,10)
 4 DEFFNY(N)=:REM....................................................
 5 DEFFNZ(N)=:REM....................................................
 6 DEFFNU(N)=:REM....................................................
 7 DEFFNV(N)=:REM....................................................
 8 DEFFNW(N)=:REM....................................................
 9 DEFFNA(N)=:REM....................................................
 10 DEFFNB(N)=:REM...................................................
 11 DEFFNC(N)=:REM...................................................
 12 DEFFND(N)=:REM................................................... 
 13 DEFFNF(N)=:REM................................................... 
 14 DEFFNN(N)=VAL(LEFT$(STR$(N),6))
 15 PRINTC$;:INPUT"   Printout every ";S:H=S/8
 16 ONNGOTO26,25,24,23,22,21,20,19,18,17
 17 INPUT"  Start F (Fo) ";EN
 18 INPUT"  Start D (Do) ";DN
 19 INPUT"  Start C (Co) ";CN
 20 INPUT"  Start B (Bo) ";BN
 21 INPUT"  Start A (Ao) ";AN
 22 INPUT"  Start W (Wo) ";WN
 23 INPUT"  Start V (Vo) ";VN
 24 INPUT"  Start U (Uo) ";UN
 25 INPUT"  Start Z (Zo) ";ZN
 26 INPUT"  Start Y (Yo) ";YN
 27 INPUT"  Start X ";X
 28 PRINTC$"    X      Y       Z       U       V      W"
 29 PRINTTAB(7)"A       B       C       D       F":PRINTH$
 30 FORI=0TO4:FORJ=1TO8:Y=YN:Z=ZN:U=UN
 31 V=VN:W=WN:A=AN:B=BN:C=CN:D=DN:F=EN
 32 K1=FNY(0)*H:L1=FNZ(0)*H:M1=FNU(0)*H
 33 N1=FNV(0)*H:O1=FNW(0)*H
 34 P1=FNA(0)*H:Q1=FNB(0)*H:R1=FNC(0)*H
 35 S1=FND(0)*H:T1=FNF(0)*H
 36 X=X+H/2:Y=YN+K1/2:Z=ZN+L1/2:D=DN+S1/2
 37 A=AN+P1/2:B=BN+Q1/2:C=CN+R1/2:F=EN+T1/2
 38 U=UN+M1/2:V=VN+N1/2:W=WN+O1/2
 39 K2=FNY(0)*H:L2=FNZ(0)*H:M2=FNU(0)*H
 40 N2=FNV(0)*H:O2=FNW(0)*H
 41 P2=FNA(0)*H:Q2=FNB(0)*H:R2=FNC(0)*H
 42 S2=FND(0)*H:T2=FNF(0)*H
 43 Y=YN+K2/2:Z=ZN+L2/2:U=UN+M2/2:V=VN+N2/2
 44 W=WN+O2/2:A=AN+P2/2:B=BN+Q2/2:C=CN+R2/2
 45 D=DN+S2/2:F=EN+T2/2
 46 K3=FNY(0)*H:L3=FNZ(0)*H:M3=FNU(0)*H
 47 N3=FNV(0)*H:O3=FNW(0)*H
 48 P3=FNA(0)*H:Q3=FNB(0)*H:R3=FNC(0)*H
 49 S3=FND(0)*H:T3=FNF(0)*H
 50 Y=YN+K3:Z=ZN+L3:X=X+H/2:U=UN+M3
 51 V=VN+N3:W=WN+O3:A=AN+P3:B=BN+Q3
 52 C=CN+R3:D=DN+S3:F=EN+T3
 53 K4=FNY(0)*H:L4=FNZ(0)*H:M4=FNU(0)*H
 54 N4=FNV(0)*H:O4=FNW(0)*H
 55 P4=FNA(0)*H:Q4=FNB(0)*H:R4=FNC(0)*H
 56 S4=FND(0)*H:T4=FNF(0)*H
 57 YN=YN+(K1+2*K2+2*K3+K4)/6
 58 AN=AN+(P1+2*P2+2*P3+P4)/6
 59 ZN=ZN+(L1+2*L2+2*L3+L4)/6
 60 BN=BN+(Q1+2*Q2+2*Q3+Q4)/6
 61 UN=UN+(M1+2*M2+2*M3+M4)/6
 62 CN=CN+(R1+2*R2+2*R3+R4)/6
 63 VN=VN+(N1+2*N2+2*N3+N4)/6
 64 DN=DN+(S1+2*S2+2*S3+S4)/6
 65 WN=WN+(O1+2*O2+2*O3+O4)/6
 66 EN=EN+(T1+2*T2+2*T3+T4)/6
 67 A(J+8*I,1)=YN:A(J+8*I,2)=ZN
 68 A(J+8*I,3)=UN:A(J+8*I,4)=VN
 69 A(J+8*I,5)=WN:A(J+8*I,6)=AN
 70 A(J+8*I,7)=BN:A(J+8*I,8)=CN
 71 A(J+8*I,9)=DN:A(J+8*I,10)=EN:NEXT
 72 PRINT"  "FNN(X)TAB(8)FNN(YN)" "FNN(ZN)" ";
 73 PRINTFNN(UN)" "FNN(VN)" "FNN(WN)
 74 PRINTTAB(7)FNN(AN)" "FNN(BN)" "FNN(CN);
 75 PRINT" "FNN(DN)" "FNN(EN):NEXT:PRINTH$
 76 PRINT:RESTORE:FORJ=1TON:READA$
 77 PRINTCHR$(11)"    Do you want "A$" graphed? (SPACE for MENU)"
 78 X=USR(X):IFPEEK(531)=32THENJ=N:NEXT:GOTO106
 79 IFPEEK(531)<>89THENNEXTJ:GOTO28
 80 FORI=0TO1024:POKE54286+I,32:NEXT
 81 FORI=0TO14:POKE54288+64*I,143:NEXT
 82 FORI=1TO40:POKE54672+I,131:NEXT
 83 MX=A(1,J):FORI=1TO40
 84 IFMX<ABS(A(I,J))THENMX=ABS(A(I,J))
 85 NEXT
 86 FORI=1TO40:FX=A(I,J)/MX*7
 87 POKE54672-64*INT(FX)+I,128+8*(FX-INT(FX)):NEXTI,J:GOTO28
 88 .
 89 function input
 90 PRINTC$;:INPUT"    How many equations (max 10)";N
 91 AD=768:RESTORE:FORI=1TO10:READD$
 92 IFCHR$(PEEK(AD))<>D$THENAD=AD+1:GOTO92
 93 AD=AD+5:IFI>NTHENDE$="0":GOTO96
 94 PRINT"   d"D$"/dx= ";:INPUTDE$
 95 IFDE$="Q"THENNEXTI
 96 DE=LEN(DE$):FORJ=1TODE
 97 A=ASC(MID$(DE$,J,1)):IFA=43THENA=163
 98 IFA=45THENA=164
 99 IFA=42THENA=165
 100 IFA=47THENA=166
 101 IFA=94THENA=167
 102 POKEAD+J-1,A:NEXTJ
 103 POKEAD+DE,58:POKEAD+DE+1,142
 104 AD=AD+55:NEXTI:RETURN
 105 DATAY,Z,U,V,W,A,B,C,D,F
 106 PRINTC$TAB(18)"MENU":PRINTH$
 107 PRINT:PRINT:PRINT"   1. Re-run the same differential equations"
 108 PRINT"      with different initial conditions"
 109 PRINT:PRINT"   2. Enter new differential equations"
 110 PRINT:PRINT"   3. Exit this program":PRINT
 111 PRINT:PRINT"    YOUR CHOICE ?":PRINTH$
 112 X=USR(X):CH=PEEK(531)-48
 113 IFCH<1ORCH>3THEN112
 114 IFCH=2THENRUN
 115 IFCH=1THEN15
 116 PRINTC$"  good-bye"
