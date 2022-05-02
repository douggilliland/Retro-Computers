 NAM MICRO  MICROBASIC

* ***** VERSION 1.3A *****
*
* BY ROBERT H UITERWYK, TAMPA, FLORIDA
*
*THIS PROGRAM ASSUMES THAT THE
*MOTOROLA MIKBUG ROM IS INSTALLED
*AND THAT ITS ASSOCIATED 128 BYTE
*RAN IS ALSO PRESENT
*THE SP AND XSTACK WILL HAVE TO
*BE MOVED IF THIS IS NOT THE CASE

        ORG $20   
INDEX1  FDB $0000
INDEX2  FDB $0000 
INDEX3  FDB $0000 
INDEX4  FDB $0000 
SAVESP  FDB $0000 
NEXTBA  FDB END  
WORKBA  FDB END  
SOURCE  FDB END  
PACKLN  FDB $0000 
HIGHLN  FDB $0000 
BASPNT  FDB $0000 
BASLIN  FDB $0000 
PUSHTX  FDB $0000 
XSTACK  FDB $A07F 
RNDVAL  FDB $0000 
DIMPNT  FDB $0000 
DIMCAL  FDB $0000 
PRCNT   FCB 0  
MAXLIN  FCB 72  
BACKSP  FCB $0F  
CANCEL  FCB $18  
MEMEND  FDB $1FFF 
ARRTAB  FDB $0000 
KEYWD   FDB $0000 
TSIGN   FCB 0  
NCMPR   FCB 0  
TNUMB   FCB 0  
ANUMB   FCB 0  
BNUMB   FCB 0  
AESTK   FDB ASTACK 
FORPNT  FDB FORSTK 
VARPNT  FDB VARTAB 
SBRPNT  FDB SBRSTK 
SBRSTK  RMB 16  
FORSTK  RMB 48  
DIMVAR  FDB VARTAB 
     
     
  ORG $00AC   
BUFNXT  FDB $00B0 
ENDBUF  FDB $00B0 
        ORG $00B0   
BUFFER  RMB $50 

        ORG $0100
PROGM   JMP START
VARTAB  RMB 78
        FCB $1E
COMMAN  FCC /RUN/
        FCB $1E
        FDB RUN
        FCC /LIST/
        FCB $1E
        FDB CLIST 
        FCC /NEW/
        FCB $1E
        FDB START
        FCC /PAT/
        FCB $1E
        FDB PATCH
GOLIST  FCC /GOSUB/
        FCB $1E
        FDB GOSUB
        FCC /GOTO/
        FCB $1E
        FDB GOTO
        FCC /GO TO/
        FCB $1E
        FDB GOTO
        FCC /SIZE/
        FCB $1E
        FDB SIZE
        FCC /THEN/
        FCB $1E
        FDB IF2
        FCC /PRINT/
        FCB $1E
        FDB PRINT
        FCC /LET/
        FCB $1E
        FDB LET
        FCC /INPUT/
        FCB $1E
        FDB INPUT
        FCC /IF/
        FCB $1E
        FDB IF
        FCC /END/
        FCB $1E
        FDB READY
        FCC /RETURN/
        FCB $1E
        FDB RETURN
        FCC /DIM/
        FCB $1E
        FDB DIM
        FCC /FOR/
        FCB $1E
        FDB FOR
        FCC /NEXT/
        FCB $1E
        FDB NEXT
        FCC /EEM/
        FCB $1E
        FDB REMARK
PAUMSG  FCC /PAUSE/
        FCB $1E
        FDB PAUSE
        FCB $20
COMEND  FCB $1E
IMPLET  FDB LET
        RMB 60
ASTACK  EQU *-1
RDYMSG  FCB $0D
        FCB $0A
        FCB $15
        FCB $0A
        FCB $15
        FCC /READY/
        FCB $1E
PROMPT  FCB $23
        FCB $00
        FCB $1E
        FCB $1E
PGCNTL  FCB $10
        FCB $16
        FCB $1E
        FCB $1E
        FCB $1E
ERRMS1  FCC /ERROR# /
        FCB $1E
ERRMS2  FCC / IN LINE /
        FCB $1E
KEYBD   LDA A #$3F
        BSR OUTCH
KEYBD0  LDX #BUFFER
        LDA B #10
KEYBD1  BSR INCH
        CMP A #$00
        BNE KEYB11
        DEC B
        BNE KEYBD11
KEYB10  JMP READY
KEYB11  CMP A CANCEL
        BEQ DEL
        CMP A #$0D
        BEQ IEXIT
KEYBD2  CMP A #$0A
        BEQ KEYBD1
        CMP A #$15
        BEQ KEYBD1
        CMP A #$13
        BEQ KEYBD1
KEYB55  CMP A BACKSP
        BNE KEYBD3
        CPX #BUFFER
        BEQ KEYBD1
        DEX
        BRA KEYBD1
KEYBD3  CPX #BUFFER+71
        BEQ KEYBD1
        STA A 0,X
        INX
        BRA KEYBD1
DEL     BSR CRLF
CNTLIN  LDX #PROMPT
        BSR OUTNCR
        BRA KEYBD0
IEXIT   LDA A #$1E
        STA A X
        STX ENDBUF
        BSR CRLF
        RTS

OUTCH   BSR BREAK
        JMP OUTEEE
OUTEEE  EQU $E1D1

INCH    JMP INEEE

BREAK   JMP BREAK1
BREAK1  PSH A
        LDA A PIAD
PIAD    EQU $8004
        BMI BREAK2
        JMP READY

BREAK2  PUL A
        RTS

INEEE   EQU $E1AC
OUTPUT  EQU *
        BSR OUTNCR
        BRA CRLF

OUTPU2  BSR  OUTCH
OUTPU3  INX
OUTNCR  LDA A 0,X
        CMP A #$1E
        BNE OUTPU2
        RTS

CRLF    BSR PUSHX
        LDX #CRLFST
        BSR OUTNCR
        BSR PULLX
        RTS

CRLFST  FCB $00
        FCB $0D
        FCB $0A
        FCB $15
CREND   FCB $1E
        FCB $FF,$FF
        FCB $FF,$FF
        FCB $1E
PUSHX   STX PUSHTX
        LDX XSTACK
        DEX
        DEX
        STX XSTACK
        PSH A
        LDA A PUSHTX
        STA A 0,X
        LDA A PUSHTX+1
        STA A 1,X
        PUL A
        LDX PUSHTX
        RTS

PULLX   LDX XSTACK
        LDX 0,X
        INC XSTACK+1
        INC XSTACK+1
        RTS

STORE   PSH A
        PSH B
        BSR PUSHX
        JSR PULLAE
        LDX AESTK
        INX
        INX
        STX AESTK
        DEX
        LDX 0,X
        STA A 0,X
        STA B 1,X
        BSR PULLX
        PUL B
        PUL A
        RTS

IND     BSR PUSHX
        PSH A
        PSH B
        LDX AESTK
        INX
        INX
        STX AESTK
        DEX
        LDX 0,X
        LDA A 0,X
        LDA B 1,X
        JSR PUSHAE
        PUL B
        PUL A
        BSR PULLX
        RTS

LIST    LDX NEXTBA
        STX WORKBA
        LDX SOURCE
        BRA LIST1
LIST0   LDX INDEX3
LIST1   CPX WORKBA
        BEQ LEXIT
        BSR OUTLIN
        INX
        BRA LIST1
LEXIT   RTS

OUTLIN  LDA A 0,X
        CLR PRCNT
        INX
        LDA B 0,X
        INX
        CLR TSIGN
        JSR PRN0
        BSR PRINSP
OUTLI1  LDA A 0,X
        INX
        BSR PUSHX
        LDX #COMMAN
        STX KEYWD
        STA A KEYWD+1
        LDX KEYWD
        DEX
OUTLI2  DEX
        LDA A 0,X
        CMP A #$1E
        BNE OUTLI2
        INX
        INX
        INX
        JSR OUTNCR
        JSR PULLX
        JMP OUTPUT

PRINSP  PSH A
        LDA A #$20
        JSR OUTCH
        PUL A
        RTS

RANDOM  INX
        INX
        LDA A 0,X
        CMP A #'D
        BNE  TSTVER
        JSR PUSHX
        LDA A RNDVAL
        LDA B RNDVAL+1
        LDX  #0000
RAND1   ADC B 1,X
        ADC A 0,X
        INX
        INX
        CPX #RNDVAL
        BNE  RAND1
        AND A #$7F
        STA A RNDVAL
        STA B RNDVAL+1
        STX   INDEX1
        LDA A INDEX1
        LDA B INDEX1+1
        JMP   TSTV9

TSTV    JSR   SKIPSP
        JSR   BREAK
        JSR   TSTLTR
        BCC   TSTV1
        RTS

TSTV1   CMP A #'R
        BNE TSTV2
        LDA B 1,X
        CMP B #'N
        BEQ  RANDOM
TSTV2   JSR PUSHX
        SUB A #$40
        STA A VARPNT+1
        ASL A
        ADD A VARPNT+1
        STA A VARPNT+1
        LDX VARPNT
        LDA A VARPNT
        LDA B VARPNT+1
        TST  2,X
        BNE  TSTV20
        JMP  TSTV9

TSTV20  LDX  0,X
        STX  DIMPNT
        INX
        INX
        STX DIMCAL
        JSR  PULLX
        JSR INXSKP
        CMP A #'(
        BEQ TSTV22
TSTVER  JMP DBLLTR
TSTV22  INX
        JSR EXPR
        JSR PUSHX
        JSR PULLAE
        TST A
        BEQ TSTV3
SUBER1  JMP  SUBERR

TSTV3   LDX DIMPNT
        TST B
        BEQ  SUBER1
        CMP B 0,X
        BHI  SUBER1
        LDA A 1,X
        STA A ANUMB
        BEQ TST666
        LDX DIMCAL
TSTV4   DEC B
        BEQ TSTV6
        LDA A ANUMB
TSTV5   INX
        INX
        DEC A
        BNE TSTV5
        BRA TSTV4

TSTV6   STX DIMCAL
        JSR PULLX
        JSR SKIPSP
        CMP A #',
        BNE TSTVER
        INX
        JSR EXPR
        JSR PUSHX
        JSR PULLAE
        TST A
        BNE SUBER1
        LDX DIMPNT
        TST B
        BEQ SUBER1
        CMP B 1,X
        BHI SUBER1
TST666  LDX DIMCAL
TSTV7   INX
        INX
        DEC B
        BNE TSTV7
        DEX
        DEX
        STX DIMCAL
        JSR PULLX
        JSR SKIPSP
TSTV8   CMP A  #')
        BNE TSTVER
        JSR PUSHX
        LDA A DIMCAL
        LDA B DIMCAL+1
TSTV9   JSR  PULLX
        INX
        JSR PUSHAE
        CLC
        RTS

TSTLTR  CMP A #$41
        BMI NONO
        CMP A #$5A
        BLE YESNO
TESTNO  CMP A #$30
        BMI NONO
        CMP A #$39
        BLE YESNO
NONO    SEC
        RTS
YESNO   CLC
        RTS

PULPSH  BSR PULLAE
PUSHAE  STS SAVESP
        LDS AESTK
        PSH B
        PSH A
        STS AESTK
        LDS SAVESP
        RTS

PULLAE  STS SAVESP
        LDS AESTK
        PUL A
        PUL B
        STS AESTK
        LDS SAVESP
        RTS

FACT    JSR SKIPSP
        JSR TSTV
        BCS FACT0
        JSR IND
        RTS

FACT0   JSR TSTN
        BCS FACT1
        RTS

FACT1   CMP A #'(
        BNE FACT2
        INX
        BSR  EXPR
        JSR  SKIPSP
        CMP A #')
        BNE FACT2
        INX
        RTS

FACT2   LDA B #13
        JMP  ERROR

TERM    BSR  FACT
TERM0   JSR SKIPSP
        CMP A #'*
        BNE TERM1
        INX
        BSR FACT
        BSR MPY
        BRA TERM0

TERM1   CMP A #'/
        BNE TERM2
        INX
        BSR FACT
        JSR DIV
        BRA TERM0

TERM2   RTS

EXPR    JSR SKIPSP
        CMP A #'-
        BNE EXPR0
        INX
        BSR TERM
        JSR NEG
        BRA EXPR1
EXPR0   CMP A #'+
        BNE EXPR00
        INX
EXPR00  BSR TERM
EXPR1   JSR SKIPSP
        CMP A #'+
        BNE EXPR2
        INX
        BSR TERM
        JSR ADD
        BRA EXPR1
EXPR2   CMP A #'-
        BNE EXPR3
        INX
        BSR TERM
        JSR SUB
        BRA EXPR1
EXPR3   RTS

MPY     BSR MDSIGN
        LDA A #15
        STA A 0,X
        CLR B
        CLR A
MPY4    LSR 3,X
        ROR 4,X
        BCC MPY5
        ADD B 2,X
        ADC A 1,X
        BCC MPY5
MPYERR  LDA A #2
        JMP ERROR
MPY5    ASL 2,X
        ROL 1,X
        DEC 0,X
        BNE MPY4
        TST A
        BMI MPYERR
        TST TSIGN
        BPL MPY6
        JSR NEGAB
MPY6    STA B 4,X
        STA A 3,X
        JSR PULLX
        RTS

MDSIGN  JSR PUSHX
        CLR A
        LDX AESTK
        TST 1,X
        BPL MDS2
        BSR NEG
        LDA A #$80
MDS2    INX
        INX
        STX AESTK
        TST 1,X
        BPL MDS3
        BSR NEG
        ADD A #$80
MDS3    STA A TSIGN
        DEX
        DEX
        RTS

DIV     BSR MDSIGN
        TST 1,X
        BNE DIV33
        TST 2,X
        BNE DIV33
        LDA B #8
        JMP ERROR
DIV33   LDA A #1
DIV4    INC A
        ASL 2,X
        ROL 1,X
        BMI DIV5
        CMP A #17
        BNE DIV4
DIV5    STA A 0,X
        LDA A 3,X
        LDA B 4,X
        CLR 3,X
        CLR 4,X
DIV163  SUB B 2,X
        SBC A 1,X
        BCC DIV165
        ADD B 2,X
        ADC A 1,X
        CLC
        BRA DIV167
DIV165  SEC
DIV167  ROL 4,X
        ROL 3,X
        LSR 1,X
        ROR 2,X
        DEC 0,X
        BNE DIV163
        TST TSIGN
        BPL DIV169
        BSR NEG
DIV169  JSR PULLX
        RTS

NEG     PSH A
        PSH B
        JSR PULLAE
        BSR NEGAB
        JSR PUSHAE
        PUL B
        PUL A
        RTS

NEGAB   COM A
        COM B
        ADD B #1
        ADC A #0
        RTS

SUB     BSR NEG
ADD     JSR PULLAE
ADD1    STA B BNUMB
        STA A ANUMB
        JSR PULLAE
        ADD B BNUMB
        ADC A ANUMB
        JSR PUSHAE
        CLC
        RTS

FINDNO  LDA A HIGHLN
        LDA B HIGHLN+1
        SUB B PACKLN+1
        SBC A PACKLN
        BCS  HIBALL
FINDN1  LDX  SOURCE
FIND0   JSR PULPSH
        SUB B 1,X
        SBC A 0,X
        BCS FIND3
        BNE FIND1
        TST B
        BEQ  FIND4
FIND1   INX
FIND2   BSR  INXSKP
        CMP A #$1E
        BNE  FIND2
        INX
        CPX NEXTBA
        BNE FIND0
HIBALL  LDX  NEXTBA
FIND3   SEC
FIND4   STX WORKBA
        JSR PULLAE
        RTS

SKIPSP  LDA A 0,X
        CMP A #$20
        BNE  SKIPEX
INXSKP  INX
        BRA SKIPSP
SKIPEX  RTS

LINENO  JSR INTSTN
        BCC  LINE1
        LDA B #7
        JMP  ERROR
LINE1   JSR PULPSH
        STA A PACKLN
        STA B PACKLN+1
        STX BUFNXT
        RTS

NXTLIN  LDX  BASPNT
NXTL12  LDA A 0,X
        INX
        CMP A #$1E
        BNE  NXTLIN
        STX BASLIN
        RTS

CCODE   BSR SKIPSP
        STX INDEX4
        STS SAVESP
        LDX #COMMAN-1
LOOP3   LDS  INDEX4
        DES
LOOP4   INX
        PUL A
        LDA B 0,X
        CMP B #$1E
        BEQ LOOP7
        CBA
        BEQ  LOOP4
LOOP5   INX
        CPX #COMEND
        BEQ CCEXIT
        LDA B 0,X
        CMP B #$1E
        BNE  LOOP5
LOOP6   INX
        INX
        BRA LOOP3
LOOP7   INX
        STS BUFNXT
        STS BASPNT
LOOP8   LDS SAVESP
        RTS

CCEXIT  LDS SAVESP
        LDX #IMPLET
        RTS

START   LDX SOURCE
        STX NEXTBA
        STX WORKBA
        STX ARRTAB
        DEX
        CLR A
START2  INX
        STA A 0,X
        CPX MEMEND
        BNE  START2
START1  CLR A
        STA A PACKLN
        STA A PACKLN+1
        STA A PRCNT
        LDX PACKLN
        STX HIGHLN
READY   LDS #$A045
        LDX #RDYMSG
        JSR OUTPUT
NEWLIN  LDS #$A045
        LDX #$A07F
        STX XSTACK
        CLR PRCNT
NEWL3   JSR CNTLIN
        LDX #BUFFER
        JSR SKIPSP
        STX BUFNXT
        JSR TESTNO
        BCS LOOP2
        JMP NUMBER
LOOP2   CMP A #$1E
        BEQ NEWLIN
        JSR CCODE
        LDX 0,X
        JMP  0,X

ERROR   LDS #$A045
        JSR CRLF
        LDX #ERRMS1
        JSR OUTNCR
        CLR A
        JSR PUSHAE
        JSR PRN
        LDX #ERRMS2
        JSR OUTNCR
        CLR B
        LDA A BASLIN
        BEQ ERROR2
        LDX BASLIN
        LDA A 0,X
        LDA B 1,X
ERROR2  JSR PRN0
        JSR CRLF
        BRA READY

RUN     LDX  SOURCE
        STX BASLIN
        LDX #SBRSTK
        STX SBRPNT
        LDX #FORSTK
        STX FORPNT
        LDX #$A07F
        STX XSTACK
        LDX NEXTBA
        STX ARRTAB
        CLR A
        DEX
RUN1    INX
        STA A 0,X
        CPX MEMEND
        BNE RUN1
        LDX #VARTAB
        LDA B  #78
RUN2    STA A 0,X
        INX
        DEC B
        BNE RUN2
        JMP  BASIC

CLIST   LDX #PGCNTL
        JSR OUTPUT
        LDX  BASPNT
CLIST1  JSR SKIPSP
        CMP A #$1E
        BEQ CLIST4
        JSR INTSTN
        STX BASPNT
        JSR FINDN1
        STX INDEX3
        LDX BASPNT
        PSH A
        JSR SKIPSP
        CMP A #$1E
        PUL A
        BNE CLIST2
        JSR PUSHAE
        BRA  CLIST3
CLIST2  INX
        JSR  INTSTN
CLIST3  CLR A
        LDA B #1
        JSR ADD1
        JSR FINDN1
        JSR LIST0
        BRA CLIST5
CLIST4  JSR  LIST
CLIST5  JMP  REMARK
        NOP

PATCH   JSR  NXTLIN
        LDX #BASIC
        STX $A046
        LDS #$A040
        STS SP
SP      EQU $A008
        JMP CONTRL
CONTRL  EQU  $E0E3

NUMBER  JSR LINENO
NUM1    JSR FINDNO
        BCC DELREP
        LDX WORKBA
        CPX NEXTBA
        BEQ CAPPEN
        BSR INSERT
        BRA NEXIT
DELREP  LDX BUFNXT
        JSR SKIPSP
        CMP A #$1E
        BNE REPLAC
        LDX NEXTBA
        CPX SOURCE
        BEQ NEXIT
        BSR DELETE
        BRA NEXIT

REPLAC  BSR DELETE
        BSR INSERT
NEXIT   JMP NEWLIN
CAPPEN  BSR INSERT
        LDX PACKLN
        STX HIGHLN
        BRA NEXIT
DELETE  STS SAVESP
        LDX WORKBA
        LDS NEXTBA
        LDA B #2
        INX
        INX
        DES
        DES
DEL2    LDA A  0,X
        DES
        INX
        INC B
        CMP A #$1E
        BNE DEL2
        STS NEXTBA
        STS ARRTAB
        LDX WORKBA
        STA B DEL5+1
* IN AT OBJECT TIME
DEL4    CPX  NEXTBA
        BEQ  DELEX
DEL5    LDA A 0,X
        STA A 0,X
        INX
        BRA DEL4

DELEX   LDS SAVESP
        RTS

INSERT  LDX BUFNXT
        JSR  CCODE
INS1    STX  KEYWD
        LDA B ENDBUF+1
        SUB B BUFNXT+1
        ADD B #$04
        STA B OFFSET+1
        ADD B NEXTBA+1
        LDA A #$00
        ADC A NEXTBA
        CMP A MEMEND
        BHI OVERFL
        STA B NEXTBA+1
        STA A NEXTBA
        LDX NEXTBA
        STX  ARRTAB
INS2    CPX  WORKBA
        BEQ BUFWRT
        DEX
        LDA A 0,X
OFFSET  STA A 0,X
        BRA  INS2
BUFWRT  LDX  WORKBA
        STS SAVESP
        LDA A PACKLN
        STA A 0,X
        INX
        LDA A PACKLN+1
        STA A 0,X
        INX
        LDA A KEYWD+1
        STA A 0,X
        INX
        LDS BUFNXT
        DES
BUF3    PUL A
        STA A 0,X
        INX
        CMP A #$1E
        BNE BUF3
        LDS SAVESP
        RTS

OVERFL  LDA B #14
        JMP ERROR
BASIC   LDX BASLIN
        CPX NEXTBA
        BNE BASIC1
BASIC0  JMP READY
BASIC1  TST BASLIN
        BEQ BASIC0
        INX
        INX
        LDA A 0,X
        INX
        STX  BASPNT
        LDX #COMMAN
        STX KEYWD
        STA A KEYWD+1
        LDX #ASTACK
        STX AESTK
        LDX KEYWD
        LDX 0,X
BASIC2  JMP 0,X

GOSUB   LDX BASLIN
        STX INDEX1
        JSR NXTLIN
        LDX SBRPNT
        CPX #SBRSTK+16
        BNE  GOSUB1
        LDA B #9
        JMP  ERROR
GOSUB1  LDA A BASLIN
        STA A 0,X
        INX
        LDA A BASLIN+1
        STA A 0,X
        INX
        STX SBRPNT
        LDX INDEX1
        STX BASLIN
GOTO    LDX BASPNT
        JSR EXPR
        JSR FINDN1
        BCC GOTO2
        LDA B #7
        JMP  ERROR
GOTO2   STX BASLIN
        BRA  BASIC

RETURN  LDX  SBRPNT
        CPX #SBRSTK
        BNE RETUR1
        LDA B #10
        JMP  ERROR
RETUR1  DEX
        DEX
        STX SBRPNT
        LDX  0,X
        STX BASLIN
        BRA BASIC

PAUSE   LDX  #PAUMSG
        JSR OUTNCR
        JSR PRINSP
        LDX  BASLIN
        LDA A 0,X
        INX
        LDA B 0,X
        INX
        JSR  PRN0
PAUSE1  JSR  INCH
        CMP A #$0D
        BNE  PAUSE1
        JSR  CRLF
PAUSE2  JMP  REMARK
INPUT   LDA A  BASPNT
        BNE INPUT0
        LDA B #12
        BRA INPERR
INPUT0  JSR KEYBD
        LDX  #BUFFER
        STX BUFNXT
        LDX BASPNT
INPUT1  JSR TSTV
        BCS INPEX
        STX BASPNT
        LDX BUFNXT
INPUT2  BSR  INNUM
        BCC INPUT4
        DEX
        LDA A 0,X
        CMP A #$1E
        BEQ INPUTS
        LDA B #2
INPERR  JMP  ERROR
INPUTS  JSR  KEYBD
        LDX #BUFFER
        BRA INPUT2
INPUT4  JSR  STORE
        INX
        STX BUFNXT
        LDX BASPNT
        JSR SKIPSP
        INX
        CMP A #',
        BEQ INPUT1
INPEX   DEX
        CLR PRCNT
        CMP A #$1E
        BEQ PAUSE2
DBLLTR  LDA B #3
        JMP  ERROR
TSTN    BSR INTSTN
        BCS TSTN0
        JSR PULLAE
        TST A
        BPL TSTN1
TSTN0   SEC
        RTS
TSTN1   JSR  PUSHAE
        RTS

INNUM   JSR  SKIPSP
        STA A TSIGN
        INX
        CMP A #'-
        BEQ  INNUM0
        DEX
INTSTN  CLR  TSIGN
INNUM0  JSR   SKIPSP
        JSR TESTNO
        BCC INNUM1
        RTS
INNUM1  DEX
        CLR A
        CLR B
INNUM2  INX
        PSH A
        LDA A 0,X
        JSR TESTNO
        BCS INNEX
        SUB A #$30
        STA A TNUMB
        PUL A
        ASL B
        ROL A
        BCS INNERR
        STA B BNUMB
        STA A ANUMB
        ASL B
        ROL A
        BCS INNERR
        ASL B
        ROL A
        BCS INNERR
        ADD B BNUMB
        ADC A ANUMB
        BCS INNERR
        ADD B TNUMB
        ADC A #0
        BCC  INNUM2
INNERR  LDA B #2
        JMP  ERROR
INNEX   PUL A
        TST TSIGN
        BEQ INNEX2
        JSR NEGAB
INNEX2  JSR PUSHAE
        CLC
        RTS

PRINT   LDX  BASPNT
PRINT0  JSR  SKIPSP
        CMP A #'"
        BNE PRINT4
        INX
PRINT1  LDA A 0,X
        INX
        CMP A  #'"
        BEQ  PRIN88
        CMP A #$1E
        BNE PRINT2
        LDA B  #4
        BRA  PRINTE
PRINT2  JSR  OUTCH
        JSR ENLINE
        BRA PRINT1
PRINT4  CMP B #$1E
        BNE PRINT6
        DEX
        LDA A 0,X
        INX
        CMP A #';
        BEQ PRINT5
        JSR CRLF
        CLR PRCNT
PRINT5  INX
        STX BASLIN
        JMP BASIC
PRINT6  CMP A #'T
        BNE PRINT8
        LDA B 1,X
        CMP B #'A
        BNE PRINT8
        INX
        INX
        LDA A 0,X
        CMP A #'B
        BEQ PRINT7
        LDA B #11
PRINTE  JMP  ERROR
PRINT7  INX
        JSR EXPR
        JSR PULLAE
        SUB B PRCNT
        BLS PRIN88
PRIN77  JSR PRINSP
        BSR ENLINE
        DEC B
        BNE PRIN77
        BRA PRIN88
PRINT8  JSR  EXPR
        JSR  PRN
PRIN88  JSR  SKIPSP
        CMP A #',
        BNE PRIN99
        INX
PRLOOP  LDA A PRCNT
        TAB
        AND B #$F8
        SBA
        BEQ PRI999
        JSR PRINSP
        BSR ENLINE
        BRA PRLOOP
PRIN99  CMP A #';
        BNE PREND
        INX
PRI999  JMP  PRINT0
PREND   CMP A #$1E
        BEQ PRINT4
        LDA B #6
        BRA PRINTE
ENLINE  PSH A
        LDA A PRCNT
        INC A
        CMP A MAXLIN
        BNE ENLEXT
        JSR CRLF
        CLR A
ENLEXT  STA A PRCNT
        PUL A
        RTS
PRN     JSR PRINSP
        BSR ENLINE
        LDA A #$FF
        STA A TSIGN
        JSR PULLAE
        TST A
        BPL PRN0
        JSR NEGAB
        PSH A
        LDA A #'-
        JSR OUTCH
        BSR ENLINE
        PUL A
PRN0    JSR  PUSHX
        LDX #KIOK
PRN1    CLR  TNUMB
PRN2    SUB B 1,X
        SBC A 0,X
        BCS PRN5
        INC TNUMB
        BRA PRN2
PRN5    ADD B 1,X
        ADC A 0,X
        PSH A
        LDA A TNUMB
        BNE PRN6
        CPX #KIOK+8
        BEQ PRN6
        TST TSIGN
        BNE PRN7
PRN6    ADD A #$30
        CLR TSIGN
        JSR OUTCH
        BSR ENLINE
PRN7    PUL A
        INX
        INX
        CPX #KIOK+10
        BNE PRN1
        JSR PULLX
        RTS

KIOK    FDB 10000
        FDB 1000
        FDB 100
        FDB 10
        FDB 1

LET     LDX BASPNT
        JSR TSTV
        BCC LET1
LET0    LDA B #12
LET00   JMP  ERROR
LET1    JSR  SKIPSP
        INX
        CMP A #'=
        BEQ LET3
LET2    LDA B #6
        BRA LET00
LET3    JSR EXPR
        CMP A #$1E
        BNE LET2
        JSR STORE
        BRA REMARK
SIZE    LDA B ARRTAB+1
        LDA A ARRTAB
        SUB B SOURCE+1
        SBC A SOURCE
        JSR PRN0
        JSR PRINSP
        LDA B MEMEND+1
        LDA A MEMEND
        SUB B ARRTAB+1
        SBC A ARRTAB
        JSR PRN0
        JSR CRLF
REMARK  JSR NXTLIN
        JMP BASIC
DIM     LDX BASPNT
DIM1    JSR SKIPSP
        JSR TSTLTR
        BCC DIM111
        JMP DIMEX
DIM111  SUB A #$40
        STA A DIMVAR+1
        ASL A
        ADD A DIMVAR+1
        STA A DIMVAR+1
        JSR PUSHX
        LDX DIMVAR
        TST 0,X
        BNE DIMERR
        TST 1,X
        BNE DIMERR
        TST 2,X
        BNE DIMERR
        LDA A ARRTAB+1
        STA A 1,X
        LDA A ARRTAB
        STA A 0,X
        STA A 2,X
        JSR PULLX
        JSR INXSKP
        CMP A #'(
        BEQ  DIM2
DIMERR  LDA B #5
DIMER1  JMP ERROR
DIM2    INX
        JSR EXPR
        JSR PULPSH
        TST B
        BEQ SUBERR
        TST A
        BEQ  DIM3
SUBERR  LDA B #15
        BRA DIMER1
DIM3    BSR STRSUB
        LDA A 0,X
        CMP A #',
        BNE DIM6
        INX
        JSR EXPR
        JSR PULPSH
        TST B
        BEQ SUBERR
        TST A
        BNE SUBERR
        BSR STRSUB
        JSR MPY
DIM6    CLR A
        LDA B #2
        JSR PUSHAE
        JSR MPY
        LDA A 0,X
        CMP A #')
        BNE DIMERR
        INX
        LDA B ARRTAB+1
        LDA A ARRTAB
        JSR ADD1
        CLR A
        LDA B #2
        JSR ADD1
        JSR PULLAE
        CMP A MEMEND
        BLS DIM7
        JMP OVERFL
DIM7    STA A ARRTAB
        STA B ARRTAB+1
        JSR SKIPSP
        CMP A #',
        BNE DIMEX
        INX
        JMP DIM1
DIMEX   CMP A #$1E
        BNE DIMERR
        JMP REMARK
STRSUB  JSR PUSHX
        LDX DIMVAR
        LDX 0,X
STRSU2  TST 0,X
        BEQ STRSU3
        INX
        BRA STRSU2
STRSU3  STA B 0,X
        JSR PULLX
        RTS

FOR     LDX  BASPNT
        JSR TSTV
        BCC FOR1
        JMP LET0
FOR1    STX BASPNT
        JSR PULPSH
        LDX FORPNT
        CPX #FORSTK+48
        BNE FOR11
        LDA B #16
        JMP ERROR
FOR11   STA A 0,X
        INX
        STA B 0,X
        INX
        STX FORPNT
        LDX BASPNT
        JSR SKIPSP
        INX
        CMP A #'=
        BEQ  FOR3
FOR2    JMP  LET2
FOR3    JSR EXPR
        JSR STORE
        INX
        CMP A #'T
        BNE FOR2
        LDA A 0,X
        INX
        CMP A #'O
        BNE FOR2
        JSR EXPR
        JSR PULLAE
        STX BASPNT
        LDX FORPNT
        STA A 0,X
        INX
        STA B 0,X
        INX
        STX FORPNT
        LDX BASPNT
        LDA A 0,X
        CMP A #$1E
FOR8    BNE FOR2
        INX
        STX BASLIN
        LDX FORPNT
        LDA A BASLIN
        STA A 0,X
        INX
        LDA B BASLIN+1
        STA A 0,X
        INX
        STX FORPNT
        JMP BASIC

NEXT    LDX BASPNT
        JSR TSTV
        BCC NEXT1
        JMP LET0
NEXT1   JSR SKIPSP
        CMP A #$1E
        BNE FOR8
        INX
        STX  BASLIN
        LDX #FORSTK
        JSR PULPSH
NEXT2   CPX FORPNT
        BEQ NEXT6
        CMP A 0,X
        BNE NEXT5
        CMP B 1,X
        BNE NEXT5
        JSR IND
        JSR PULPSH
        SUB B 3,X
        SBC A 2,X
        BCS NEXT4
        STX  FORPNT
NEXT3   JMP  BASIC
NEXT4   JSR PULLAE
        ADD B #1
        ADC A #0
        JSR PUSHX
        LDX 0,X
        STA A 0,X
        STA B 1,X
        JSR PULLX
        LDX 4,X
        STX BASLIN
        BRA  NEXT3
NEXT5   INX
        INX
        INX
        INX
        INX
        INX
        BRA NEXT2
NEXT6   LDA B #17 
        JMP ERROR

IF      LDX BASPNT
        JSR EXPR
        BSR RELOP
        STA A NCMPR
        JSR EXPR
        STX BASPNT
        BSR CMPR
        BCC IF2
        JMP  REMARK
IF2     LDX  BASPNT
        JSR  CCODE
        LDX 0,X
        JMP 0,X
RELOP   JSR SKIPSP
        INX
        CMP A #'=
        BNE RELOP0
        LDA A #0
        RTS
RELOP0  LDA B 0,X
        CMP A #'<
        BNE RELOP4
        CMP B #'=
        BNE RELOP1
        INX
        LDA A #2
        RTS
RELOP1  CMP B #'>
        BNE RELOP3
RELOP2  INX
        LDA A #3
        RTS
RELOP3  LDA A #1
        RTS
RELOP4  CMP A #'>
        BEQ REL44
        LDA B #6
        JMP ERROR
REL44   CMP B  #'=
        BNE RELOP5
        INX
        LDA A #5
        RTS
RELOP5  CMP B #'<
        BEQ RELOP2
        LDA A #4
        RTS

CMPR    LDA A  NCMPR
        ASL A
        ASL A
        STA A FUNNY+1
        LDX #CMPR1
        JSR SUB
        JSR PULLAE
        TST A
FUNNY   JMP  0,X
CMPR1   BEQ MAYEQ
        BRA NOCMPR
        BMI OKCMPR
        BRA NOCMPR
        BMI OKCMPR
        BRA CMPR1
        BNE OKCMPR
        BRA MYNTEQ
        BEQ MYNTEQ
        BMI NOCMPR
        BPL OKCMPR
NOCMPR  SEC
        RTS
OKCMPR  CLC
        RTS
MAYEQ   TST B
        BEQ OKCMPR
        BRA NOCMPR
MYNTEQ  TST B
        BNE OKCMPR
        BRA NOCMPR

END     EQU *
        ORG $A048
        FDB PROGM
        END
