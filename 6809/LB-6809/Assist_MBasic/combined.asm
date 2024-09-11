************************************************************************
;
; Microsoft Color Computer Basic

UART      EQU  $A000
RECEV     EQU  UART+1
TRANS     EQU  UART+1
USTAT     EQU  UART
UCTRL     EQU  UART

BS        EQU  8              ; BACKSPACE
CR        EQU  $D             ; ENTER KEY
ESC       EQU  $1B            ; ESCAPE CODE
SPACE     EQU  $20            ; SPACE (BLANK)
STKBUF    EQU  58             ; STACK BUFFER ROOM
LBUFMX    EQU  250            ; MAX NUMBER OF CHARS IN A BASIC LINE
MAXLIN    EQU  $FA            ; MAXIMUM MS BYTE OF LINE NUMBER
* PSEUDO OPS
SKP1      EQU  $21            ; OP CODE OF BRN - SKIP ONE BYTE
SKP2      EQU  $8C            ; OP CODE OF CMPX # - SKIP TWO BYTES
SKP1LD    EQU  $86            ; OP CODE OF LDA # - SKIP THE NEXT BYTE
*                             ; AND LOAD THE VALUE OF THAT BYTE INTO ACCA - THIS
*                             ; IS USUALLY USED TO LOAD ACCA WITH A NON ZERO VALUE
RTS_LOW   EQU  $15            ; 6850 ACIA CONTROL REGISTER: RX INT DISABLED, RTS LOW, TX INT DISABLED, 8N1, CLK/16
          ORG  0
ENDFLG    RMB  1              ; STOP/END FLAG: POSITIVE=STOP, NEG=END
CHARAC    RMB  1              ; TERMINATOR FLAG 1
ENDCHR    RMB  1              ; TERMINATOR FLAG 2
TMPLOC    RMB  1              ; SCRATCH VARIABLE
IFCTR     RMB  1              ; IF COUNTER - HOW MANY IF STATEMENTS IN A LINE
DIMFLG    RMB  1              ; *DV* ARRAY FLAG 0=EVALUATE, 1=DIMENSIONING
VALTYP    RMB  1              ; *DV* *PV TYPE FLAG: 0=NUMERIC, $FF=STRING
GARBFL    RMB  1              ; *TV STRING SPACE HOUSEKEEPING FLAG
ARYDIS    RMB  1              ; DISABLE ARRAY SEARCH: 00=ALLOW SEARCH
INPFLG    RMB  1              ; *TV INPUT FLAG: READ=0, INPUT<>0
RELFLG    RMB  1              ; *TV RELATIONAL OPERATOR FLAG
TEMPPT    RMB  2              ; *PV TEMPORARY STRING STACK POINTER
LASTPT    RMB  2              ; *PV ADDR OF LAST USED STRING STACK ADDRESS
TEMPTR    RMB  2              ; TEMPORARY POINTER
TMPTR1    RMB  2              ; TEMPORARY DESCRIPTOR STORAGE (STACK SEARCH)
FPA2      RMB  4              ; FLOATING POINT ACCUMULATOR #2 MANTISSA
BOTSTK    RMB  2              ; BOTTOM OF STACK AT LAST CHECK
TXTTAB    RMB  2              ; *PV BEGINNING OF BASIC PROGRAM
VARTAB    RMB  2              ; *PV START OF VARIABLES
ARYTAB    RMB  2              ; *PV START OF ARRAYS
ARYEND    RMB  2              ; *PV END OF ARRAYS (+1)
FRETOP    RMB  2              ; *PV START OF STRING STORAGE (TOP OF FREE RAM)
STRTAB    RMB  2              ; *PV START OF STRING VARIABLES
FRESPC    RMB  2              ; UTILITY STRING POINTER
MEMSIZ    RMB  2              ; *PV TOP OF STRING SPACE
OLDTXT    RMB  2              ; SAVED LINE NUMBER DURING A "STOP"
BINVAL    RMB  2              ; BINARY VALUE OF A CONVERTED LINE NUMBER
OLDPTR    RMB  2              ; SAVED INPUT PTR DURING A "STOP"
TINPTR    RMB  2              ; TEMPORARY INPUT POINTER STORAGE
DATTXT    RMB  2              ; *PV 'DATA' STATEMENT LINE NUMBER POINTER
DATPTR    RMB  2              ; *PV 'DATA' STATEMENT ADDRESS POINTER
DATTMP    RMB  2              ; DATA POINTER FOR 'INPUT' & 'READ'
VARNAM    RMB  2              ; *TV TEMP STORAGE FOR A VARIABLE NAME
VARPTR    RMB  2              ; *TV POINTER TO A VARIABLE DESCRIPTOR
VARDES    RMB  2              ; TEMP POINTER TO A VARIABLE DESCRIPTOR
RELPTR    RMB  2              ; POINTER TO RELATIONAL OPERATOR PROCESSING ROUTINE
TRELFL    RMB  1              ; TEMPORARY RELATIONAL OPERATOR FLAG BYTE
* FLOATING POINT ACCUMULATORS #3,4 & 5 ARE MOSTLY
* USED AS SCRATCH PAD VARIABLES.
** FLOATING POINT ACCUMULATOR #3 :PACKED: ($40-$44)
V40       RMB  1
V41       RMB  1
V42       RMB  1
V43       RMB  1
V44       RMB  1
** FLOATING POINT ACCUMULATOR #4 :PACKED: ($45-$49)
V45       RMB  1
V46       RMB  1
V47       RMB  1
V48       RMB  2
** FLOATING POINT ACCUMULATOR #5 :PACKED: ($4A-$4E)
V4A       RMB  1
V4B       RMB  2
V4D       RMB  2
** FLOATING POINT ACCUMULATOR #0
FP0EXP    RMB  1              ; *PV FLOATING POINT ACCUMULATOR #0 EXPONENT
FPA0      RMB  4              ; *PV FLOATING POINT ACCUMULATOR #0 MANTISSA
FP0SGN    RMB  1              ; *PV FLOATING POINT ACCUMULATOR #0 SIGN
COEFCT    RMB  1              ; POLYNOMIAL COEFFICIENT COUNTER
STRDES    RMB  5              ; TEMPORARY STRING DESCRIPTOR
FPCARY    RMB  1              ; FLOATING POINT CARRY BYTE
** FLOATING POINT ACCUMULATOR #1
FP1EXP    RMB  1              ; *PV FLOATING POINT ACCUMULATOR #1 EXPONENT
FPA1      RMB  4              ; *PV FLOATING POINT ACCUMULATOR #1 MANTISSA
FP1SGN    RMB  1              ; *PV FLOATING POINT ACCUMULATOR #1 SIGN
RESSGN    RMB  1              ; SIGN OF RESULT OF FLOATING POINT OPERATION
FPSBYT    RMB  1              ; FLOATING POINT SUB BYTE (FIFTH BYTE)
COEFPT    RMB  2              ; POLYNOMIAL COEFFICIENT POINTER
LSTTXT    RMB  2              ; CURRENT LINE POINTER DURING LIST
CURLIN    RMB  2              ; *PV CURRENT LINE # OF BASIC PROGRAM, $FFFF = DIRECT
DEVCFW    RMB  1              ; *TV TAB FIELD WIDTH
DEVLCF    RMB  1              ; *TV TAB ZONE
DEVPOS    RMB  1              ; *TV PRINT POSITION
DEVWID    RMB  1              ; *TV PRINT WIDTH
RSTFLG    RMB  1              ; *PV WARM START FLAG: $55=WARM, OTHER=COLD
RSTVEC    RMB  2              ; *PV WARM START VECTOR - JUMP ADDRESS FOR WARM START
TOPRAM    RMB  2              ; *PV TOP OF RAM
IKEYIM    RMB  1              ; *TV INKEY$ RAM IMAGE
ZERO      RMB  2              ; *PV DUMMY - THESE TWO BYTES ARE ALWAYS ZERO
* THE FOLLOWING BYTES ARE MOVED DOWN FROM ROM
LPTCFW    RMB  1              ; 16
LPTLCF    RMB  1              ; 112
LPTWID    RMB  1              ; 132
LPTPOS    RMB  1              ; 0
EXECJP    RMB  2              ; LB4AA

* THIS ROUTINE PICKS UP THE NEXT INPUT CHARACTER FROM
* BASIC. THE ADDRESS OF THE NEXT BASIC BYTE TO BE
* INTERPRETED IS STORED AT CHARAD.
GETNCH    INC  <CHARAD+1      ; *PV INCREMENT LS BYTE OF INPUT POINTER
          BNE  GETCCH         ; *PV BRANCH IF NOT ZERO (NO CARRY)
          INC  <CHARAD        ; *PV INCREMENT MS BYTE OF INPUT POINTER
GETCCH    FCB  $B6            ; *PV OP CODE OF LDA EXTENDED
CHARAD    RMB  2              ; *PV THESE 2 BYTES CONTAIN ADDRESS OF THE CURRENT
*         *    CHARACTER WHICH THE BASIC INTERPRETER IS
*         *    PROCESSING
          JMP  BROMHK         ; JUMP BACK INTO THE BASIC RUM

VAB       RMB  1              ; = LOW ORDER FOUR BYTES OF THE PRODUCT
VAC       RMB  1              ; = OF A FLOATING POINT MULTIPLICATION
VAD       RMB  1              ; = THESE BYTES ARE USE AS RANDOM DATA
VAE       RMB  1              ; = BY THE RND STATEMENT

* EXTENDED BASIC VARIABLES
TRCFLG    RMB  1              ; *PV TRACE FLAG 0=OFF ELSE=ON
USRADR    RMB  2              ; *PV ADDRESS OF THE START OF USR VECTORS

* EXTENDED BASIC SCRATCH PAD VARIABLES
VCF       RMB  2
VD1       RMB  2
VD3       RMB  2
VD5       RMB  2
VD7       RMB  1
VD8       RMB  1
VD9       RMB  1
VDA       RMB  1
SW3VEC    RMB  3
SW2VEC    RMB  3
SWIVEC    RMB  3
NMIVEC    RMB  3
IRQVEC    RMB  3
FRQVEC    RMB  3
USRJMP    RMB  3              ; JUMP ADDRESS FOR BASIC'S USR FUNCTION
RVSEED    RMB  1              ; * FLOATING POINT RANDOM NUMBER SEED EXPONENT
          RMB  4              ; * MANTISSA: INITIALLY SET TO $804FC75259

**** USR FUNCTION VECTOR ADDRESSES (EX BASIC ONLY)
USR0      RMB  2              ; USR 0 VECTOR
          RMB  2              ; USR 1
          RMB  2              ; USR 2
          RMB  2              ; USR 3
          RMB  2              ; USR 4
          RMB  2              ; USR 5
          RMB  2              ; USR 6
          RMB  2              ; USR 7
          RMB  2              ; USR 8
          RMB  2              ; USR 9

STRSTK    RMB  8*5            ; STRING DESCRIPTOR STACK
LINHDR    RMB  2              ; LINE INPUT BUFFER HEADER
LINBUF    RMB  LBUFMX+1       ; BASIC LINE INPUT BUFFER
STRBUF    RMB  41             ; STRING BUFFER

PROGST    RMB  1              ; START OF PROGRAM SPACE
*         INTERRUPT VECTORS
*          ORG  $FFF2
*SWI3      RMB  2
*SWI2      RMB  2
*FIRQ      RMB  2
*IRQ       RMB  2
*SWI       RMB  2
*NMI       RMB  2
*RESETV    RMB  2

          ORG  $C000

* JUMP TO BASIC COLD START AT START OF ROM FOR CONVENIENCE
          JMP   RESVEC

* CONSOLE IN
LA171     BSR  KEYIN          ; GET A CHARACTER FROM CONSOLE IN
          BEQ  LA171          ; LOOP IF NO KEY DOWN
          RTS

*
* THIS ROUTINE GETS A KEYSTROKE FROM THE KEYBOARD IF A KEY
* IS DOWN. IT RETURNS ZERO TRUE IF THERE WAS NO KEY DOWN.
*
*
LA1C1
KEYIN     LDA  USTAT
          BITA #1
          BEQ  NOCHAR
          LDA  RECEV
          ANDA #$7F
          RTS
NOCHAR    CLRA
          RTS



* CONSOLE OUT
PUTCHR    BSR  WAITACIA
          PSHS A              ;
          CMPA #CR            ; IS IT CARRIAGE RETURN?
          BEQ  NEWLINE        ; YES
          STA  TRANS
          INC  LPTPOS         ; INCREMENT CHARACTER COUNTER
          LDA  LPTPOS         ; CHECK FOR END OF LINE PRINTER LINE
          CMPA LPTWID         ; AT END OF LINE PRINTER LINE?
          BLO  PUTEND         ; NO
NEWLINE   CLR  LPTPOS         ; RESET CHARACTER COUNTER
          BSR  WAITACIA
          LDA  #13
          STA  TRANS
          BSR  WAITACIA
          LDA  #10            ; DO LINEFEED AFTER CR
          STA  TRANS
PUTEND    PULS A              ;
          RTS

WAITACIA  PSHS A
WRWAIT    LDA  USTAT
          BITA #2
          BEQ  WRWAIT
          PULS A              ;
          RTS

*
RESVEC
LA00E     LDS  #LINBUF+LBUFMX+1 ; SET STACK TO TOP OF LINE INPUT BUFFER
          LDA  RSTFLG         ; GET WARM START FLAG
          CMPA #$55           ; IS IT A WARM START?
          BNE  BACDST         ; NO - D0 A COLD START
          LDX  RSTVEC         ; WARM START VECTOR
          LDA  ,X             ; GET FIRST BYTE OF WARM START ADDR
          CMPA #$12           ; IS IT NOP?
          BNE  BACDST         ; NO - DO A COLD START
          JMP  ,X             ; YES, G0 THERE

* COLD START ENTRY

BACDST    LDX  #PROGST+1      ; POINT X TO CLEAR 1ST 1K OF RAM
LA077     CLR  ,--X           ; MOVE POINTER DOWN TWO-CLEAR BYTE
          LEAX 1,X            ; ADVANCE POINTER ONE
          BNE  LA077          ; KEEP GOING IF NOT AT BOTTOM OF PAGE 0
          LDX  #PROGST        ; SET TO START OF PROGRAM SPACE
          CLR  ,X+            ; CLEAR 1ST BYTE OF BASIC PROGRAM
          STX  TXTTAB         ; BEGINNING OF BASIC PROGRAM
LA084     LDA  2,X            ; LOOK FOR END OF MEMORY
          COMA                ; * COMPLEMENT IT AND PUT IT BACK
          STA  2,X            ; * INTO SYSTEM MEMORY
          CMPA 2,X            ; IS IT RAM?
          BNE  LA093          ; BRANCH IF NOT (ROM, BAD RAM OR NO RAM)
          LEAX 1,X            ; MOVE POINTER UP ONE
          COM  1,X            ; RE-COMPLEMENT TO RESTORE BYTE
          BRA  LA084          ; KEEP LOOKING FOR END OF RAM
LA093     STX  TOPRAM         ; SAVE ABSOLUTE TOP OF RAM
          STX  MEMSIZ         ; SAVE TOP OF STRING SPACE
          STX  STRTAB         ; SAVE START OF STRING VARIABLES
          LEAX -200,X         ; CLEAR 200 - DEFAULT STRING SPACE TO 200 BYTES
          STX  FRETOP         ; SAVE START OF STRING SPACE
          TFR  X,S            ; PUT STACK THERE
          LDX  #LA10D         ; POINT X TO ROM SOURCE DATA
          LDU  #LPTCFW        ; POINT U TO RAM DESTINATION
          LDB  #18            ; MOVE 18 BYTES
          JSR  LA59A          ; MOVE 18 BYTES FROM ROM TO RAM
          LDU  #IRQVEC        ; POINT U TO NEXT RAM DESTINATION
          LDB  #4             ; MOVE 4 MORE BYTES
          JSR  LA59A          ; MOVE 4 BYTES FROM ROM TO RAM
          LDA  #$39
          STA  LINHDR-1       ; PUT RTS IN LINHDR-1
          JSR  LAD19          ; G0 DO A 'NEW'
* EXTENDED BASIC INITIALISATION
          LDX  #USR0          ; INITIALIZE ADDRESS OF START OF
          STX  USRADR         ; USR JUMP TABLE
* INITIALIZE THE USR CALLS TO 'FC ERROR'
          LDU  #LB44A         ; ADDRESS OF 'FC ERROR' ROUTINE
          LDB  #10            ; 10 USR CALLS IN EX BASIC
L8031     STU  ,X++           ; STORE 'FC' ERROR AT USR ADDRESSES
          DECB                ; FINISHED ALL 10?
          BNE  L8031          ; NO

* INITIALISE ACIA
          LDA  #RTS_LOW       ; DIV16 CLOCK -> 7372800 / 4 / 16 = 115200
          STA  UCTRL
          LDX  #LA147-1       ; POINT X TO COLOR BASIC COPYRIGHT MESSAGE
          JSR  LB99C          ; PRINT 'COLOR BASIC'
          LDX  #BAWMST        ; WARM START ADDRESS
          STX  RSTVEC         ; SAVE IT
          LDA  #$55           ; WARM START FLAG
          STA  RSTFLG         ; SAVE IT
          BRA  LA0F3          ; GO TO BASIC'S MAIN LOOP
BAWMST    NOP                 ; NOP REQ'D FOR WARM START
          JSR  LAD33          ; DO PART OF A NEW
LA0F3     JMP  LAC73          ; GO TO MAIN LOOP OF BASIC
*
* FIRQ SERVICE ROUTINE
BFRQSV
          RTI
*
* THESE BYTES ARE MOVED TO ADDRESSES $76 - $85 THE DIRECT PAGE
LA10D     FCB  16             ; TAB FIELD WIDTH
          FCB  64             ; LAST TAB ZONE
          FCB  80             ; PRINTER WIDTH
          FCB  0              ; LINE PRINTER POSITION
          FDB  LB44A          ; ARGUMENT OF EXEC COMMAND - SET TO 'FC' ERROR
* LINE INPUT ROUTINE
          INC  CHARAD+1
          BNE  LA123
          INC  CHARAD
LA123     LDA  >0000
          JMP  BROMHK
*
* THESE BYTES ARE MOVED TO ADDRESSES $A7-$B1
          JMP  BIRQSV         ; IRQ SERVICE
          JMP  BFRQSV         ; FIRQ SERVICE
          JMP  LB44A          ; USR ADDRESS FOR 8K BASIC (INITIALIZED TO 'FC' ERROR)
          FCB  $80            ; *RANDOM SEED
          FDB  $4FC7          ; *RANDON SEED OF MANTISSA
          FDB  $5259          ; *.811635157
* BASIC COMMAND INTERPRETATION TABLE ROM IMAGE
COMVEC    FCB  50             ; 50 BASIC COMMANDS
          FDB  LAA66          ; POINTS TO RESERVED WORDS
          FDB  LAB67          ; POINTS TO JUMP TABLE FOR COMMANDS
          FCB  29             ; 29 BASIC SECONDARY COMMANDS
          FDB  LAB1A          ; POINTS TO SECONDARY FUNCTION RESERVED WORDS
          FDB  LAA29          ; POINTS TO SECONDARY FUNCTION JUMP TABLE
          FDB  0              ; NO MORE TABLES (RES WORDS=0)
          FDB  0              ; NO MORE TABLES
          FDB  0              ; NO MORE TABLES
          FDB  0              ; NO MORE TABLES
          FDB  0              ; NO MORE TABLES
          FDB  0              ; NO MORE TABLES (SECONDARY FNS =0)

* COPYRIGHT MESSAGES
LA147     FCC  "6809 EXTENDED BASIC"
          FCB  CR
          FCC  "(C) 1982 BY MICROSOFT"
LA156     FCB  CR,CR
LA165     FCB  $00


LA35F     PSHS X,B,A          ; SAVE REGISTERS
          LDX  LPTCFW         ; TAB FIELD WIDTH AND TAB ZONE
          LDD  LPTWID         ; PRINTER WIDTH AND POSITION
LA37C     STX  DEVCFW         ; SAVE TAB FIELD WIDTH AND ZONE
          STB  DEVPOS         ; SAVE PRINT POSITION
          STA  DEVWID         ; SAVE PRINT WIDTH
          PULS A,B,X,PC       ; RESTORE REGISTERS

* THIS IS THE ROUTINE THAT GETS AN INPUT LINE FOR BASIC
* EXIT WITH BREAK KEY: CARRY = 1
* EXIT WITH ENTER KEY: CARRY = 0
LA38D
LA390     CLR  IKEYIM         ; RESET BREAK CHECK KEY TEMP KEY STORAGE
          LDX  #LINBUF+1      ; INPUT LINE BUFFER
          LDB  #1             ; ACCB CHAR COUNTER: SET TO 1 TO ALLOW A
*         BACKSPACE AS FIRST CHARACTER
LA39A     JSR  LA171          ; GO GET A CHARACTER FROM CONSOLE IN
          CMPA #BS            ; BACKSPACE
          BNE  LA3B4          ; NO
          DECB                ; YES - DECREMENT CHAR COUNTER
          BEQ  LA390          ; BRANCH IF BACK AT START OF LINE AGAIN
          LEAX -1,X           ; DECREMENT BUFFER POINTER
          BRA  LA3E8          ; ECHO CHAR TO SCREEN
LA3B4     CMPA #$15           ; SHIFT RIGHT ARROW?
          BNE  LA3C2          ; NO
* YES, RESET BUFFER TO BEGINNING AND ERASE CURRENT LINE
LA3B8     DECB                ; DEC CHAR CTR
          BEQ  LA390          ; GO BACK TO START IF CHAR CTR = 0
          LDA  #BS            ; BACKSPACE?
          JSR  PUTCHR         ; SEND TO CONSOLE OUT (SCREEN)
          BRA  LA3B8          ; KEEP GOING
LA3C2     CMPA #3             ; BREAK KEY?
          ORCC #1             ; SET CARRY FLAG
          BEQ  LA3CD          ; BRANCH IF BREAK KEY DOWN
LA3C8     CMPA #CR            ; ENTER KEY?
          BNE  LA3D9          ; NO
LA3CC     CLRA                ; CLEAR CARRY FLAG IF ENTER KEY - END LINE ENTRY
LA3CD     PSHS CC             ; SAVE CARRY FLAG
          JSR  LB958          ; SEND CR TO SCREEN
          CLR  ,X             ; MAKE LAST BYTE IN INPUT BUFFER = 0
          LDX  #LINBUF        ; RESET INPUT BUFFER POINTER
          PULS CC,PC          ; RESTORE CARRY FLAG

* INSERT A CHARACTER INTO THE BASIC LINE INPUT BUFFER
LA3D9     CMPA #$20           ; IS IT CONTROL CHAR?
          BLO  LA39A          ; BRANCH IF CONTROL CHARACTER
          CMPA #'z+1          ; *
          BCC  LA39A          ; * IGNORE IF > LOWER CASE Z
          CMPB #LBUFMX        ; HAVE 250 OR MORE CHARACTERS BEEN ENTERED?
          BCC  LA39A          ; YES, IGNORE ANY MORE
          STA  ,X+            ; PUT IT IN INPUT BUFFER
          INCB                ; INCREMENT CHARACTER COUNTER
LA3E8     JSR  PUTCHR         ; ECHO IT TO SCREEN
          BRA  LA39A          ; GO SET SOME MORE


* EXEC
EXEC      BEQ  LA545          ; BRANCH IF NO ARGUMENT
          JSR  LB73D          ; EVALUATE ARGUMENT - ARGUMENT RETURNED IN X
          STX  EXECJP         ; STORE X TO EXEC JUMP ADDRESS
LA545     JMP  [EXECJP]       ; GO DO IT

* BREAK CHECK
LA549     JMP  LADEB          ; GO DO BREAK KEY CHECK

* INKEY$
INKEY     LDA  IKEYIM         ; WAS A KEY DOWN IN THE BREAK CHECK?
          BNE  LA56B          ; YES
          JSR  KEYIN          ; GO GET A KEY
LA56B     CLR  IKEYIM         ; CLEAR INKEY RAM IMAGE
          STA  FPA0+3         ; STORE THE KEY IN FPA0
          LBNE LB68F          ; CONVERT FPA0+3 TO A STRING
          STA  STRDES         ; SET LENGTH OF STRING = 0 IF NO KEY DOWN
          JMP  LB69B          ; PUT A NULL STRING ONTO THE STRING STACK

* MOVE ACCB BYTES FROM (X) TO (U)
LA59A     LDA  ,X+            ; GET BYTE FROM X
          STA  ,U+            ; STORE IT AT U
          DECB                ; MOVED ALL BYTES?
          BNE  LA59A          ; NO
LA5A1     RTS

LA5C4     RTS

** THIS ROUTINE WILL SCAN OFF THE FILE NAME FROM A BASIC LINE
** AND RETURN A SYNTAX ERROR IF THERE ARE ANY CHARACTERS
** FOLLOWING THE END OF THE NAME
LA5C7     JSR  GETCCH         ; GET CURRENT INPUT CHAR FROM BASIC LINE
LA5C9     BEQ  LA5C4          ; RETURN IF END OF LINE
          JMP  LB277          ; SYNTAX ERROR IF ANY MORE CHARACTERS
* IRQ SERVICE
BIRQSV
LA9C5     RTI                 ; RETURN FROM INTERRUPT

* SET CARRY IF NUMERIC - RETURN WITH
* ZERO FLAG SET IF ACCA = 0 OR 3A(:) - END
* OF BASIC LINE OR SUB LINE
BROMHK    CMPA #'9+1          ; IS THIS CHARACTER >=(ASCII 9)+1?
          BHS  LAA28          ; BRANCH IF > 9; Z SET IF = COLON
          CMPA #SPACE         ; SPACE?
          BNE  LAA24          ; NO - SET CARRY IF NUMERIC
          JMP  GETNCH         ; IF SPACE, GET NECT CHAR (IGNORE SPACES)
LAA24     SUBA #'0            ; * SET CARRY IF
          SUBA #-'0           ; * CHARACTER > ASCII 0
LAA28     RTS

* DISPATCH TABLE FOR SECONDARY FUNCTIONS
* TOKENS ARE PRECEEDED BY $FF
* FIRST SET ALWAYS HAS ONE PARAMETER
FUNC_TAB
LAA29     FDB  SGN            ; SGN
          FDB  INT            ; INT
          FDB  ABS            ; ABS
          FDB  USRJMP         ; USR
TOK_USR   EQU  *-FUNC_TAB/2+$7F
TOK_FF_USR EQU  *-FUNC_TAB/2+$FF7F
          FDB  RND            ; RND
          FDB  SIN            ; SIN
          FDB  PEEK           ; PEEK
          FDB  LEN            ; LEN
          FDB  STR            ; STR$
          FDB  VAL            ; VAL
          FDB  ASC            ; ASC
          FDB  CHR            ; CHR$
          FDB  ATN            ; ATN
          FDB  COS            ; COS
          FDB  TAN            ; TAN
          FDB  EXP            ; EXP
          FDB  FIX            ; FIX
          FDB  LOG            ; LOG
          FDB  POS            ; POS
          FDB  SQR            ; SQR
          FDB  HEXDOL         ; HEX$
* LEFT, RIGHT AND MID ARE TREATED SEPARATELY
          FDB  LEFT           ; LEFT$
TOK_LEFT  EQU  *-FUNC_TAB/2+$7F
          FDB  RIGHT          ; RIGHT$
          FDB  MID            ; MID$
TOK_MID   EQU  *-FUNC_TAB/2+$7F
* REMAINING FUNCTIONS
          FDB  INKEY          ; INKEY$
TOK_INKEY EQU  *-FUNC_TAB/2+$7F
          FDB  MEM            ; MEM
          FDB  VARPT          ; VARPTR
          FDB  INSTR          ; INSTR
          FDB  STRING         ; STRING$
NUM_SEC_FNS EQU  *-FUNC_TAB/2

* THIS TABLE CONTAINS PRECEDENCES AND DISPATCH ADDRESSES FOR ARITHMETIC
* AND LOGICAL OPERATORS - THE NEGATION OPERATORS DO NOT ACT ON TWO OPERANDS
* S0 THEY ARE NOT LISTED IN THIS TABLE. THEY ARE TREATED SEPARATELY IN THE
* EXPRESSION EVALUATION ROUTINE. THEY ARE:
* UNARY NEGATION (-), PRECEDENCE &7D AND LOGICAL NEGATION (NOT), PRECEDENCE $5A
* THE RELATIONAL OPERATORS < > = ARE ALSO NOT LISTED, PRECEDENCE $64.
* A PRECEDENCE VALUE OF ZERO INDICATES END OF EXPRESSION OR PARENTHESES
*
LAA51     FCB  $79
          FDB  LB9C5          ; +
          FCB  $79
          FDB  LB9BC          ; -
          FCB  $7B
          FDB  LBACC          ; *
          FCB  $7B
          FDB  LBB91          ; /
          FCB  $7F
          FDB  L8489          ; EXPONENTIATION
          FCB  $50
          FDB  LB2D5          ; AND
          FCB  $46
          FDB  LB2D4          ; OR

* THIS IS THE RESERVED WORD TABLE
* FIRST PART OF THE TABLE CONTAINS EXECUTABLE COMMANDS
LAA66     FCC  "FO"           ; 80
          FCB  $80+'R
          FCC  "G"            ; 81
          FCB  $80+'O
TOK_GO    EQU  $81
          FCC  "RE"           ; 82
          FCB  $80+'M
          FCB  ''+$80         ; 83
          FCC  "ELS"          ; 84
          FCB  $80+'E
          FCC  "I"            ; 85
          FCB  $80+'F
          FCC  "DAT"          ; 86
          FCB  $80+'A
          FCC  "PRIN"         ; 87
          FCB  $80+'T
          FCC  "O"            ; 88
          FCB  $80+'N
          FCC  "INPU"         ; 89
          FCB  $80+'T
          FCC  "EN"           ; 8A
          FCB  $80+'D
          FCC  "NEX"          ; 8B
          FCB  $80+'T
          FCC  "DI"           ; 8C
          FCB  $80+'M
          FCC  "REA"          ; 8D
          FCB  $80+'D
          FCC  "RU"           ; 8E
          FCB  $80+'N
          FCC  "RESTOR"       ; 8F
          FCB  $80+'E
          FCC  "RETUR"        ; 90
          FCB  $80+'N
          FCC  "STO"          ; 91
          FCB  $80+'P
          FCC  "POK"          ; 92
          FCB  $80+'E
          FCC  "CON"          ; 93
          FCB  $80+'T
          FCC  "LIS"          ; 94
          FCB  $80+'T
          FCC  "CLEA"         ; 95
          FCB  $80+'R
          FCC  "NE"           ; 96
          FCB  $80+'W
          FCC  "EXE"          ; 97
          FCB  $80+'C
          FCC  "TRO"          ; 98
          FCB  $80+'N
          FCC  "TROF"         ; 99
          FCB  $80+'F
          FCC  "DE"           ; 9A
          FCB  $80+'L
          FCC  "DE"           ; 9B
          FCB  $80+'F
          FCC  "LIN"          ; 9C
          FCB  $80+'E
          FCC  "RENU"         ; 9D
          FCB  $80+'M
          FCC  "EDI"          ; 9E
          FCB  $80+'T
* END OF EXECUTABLE COMMANDS. THE REMAINDER OF THE TABLE ARE NON-EXECUTABLE TOKENS
          FCC  "TAB"          ; 9F
          FCB  $80+'(
TOK_TAB   EQU  $9F
          FCC  "T"            ; A0
          FCB  $80+'O
TOK_TO    EQU  $A0
          FCC  "SU"           ; A1
          FCB  $80+'B
TOK_SUB   EQU  $A1
          FCC  "THE"          ; A2
          FCB  $80+'N
TOK_THEN  EQU  $A2
          FCC  "NO"           ; A3
          FCB  $80+'T
TOK_NOT   EQU  $A3
          FCC  "STE"          ; A4
          FCB  $80+'P
TOK_STEP  EQU  $A4
          FCC  "OF"           ; A5
          FCB  $80+'F
          FCB  '++$80         ; A6
TOK_PLUS  EQU  $A6
          FCB  '-+$80         ; A7
TOK_MINUS EQU  $A7
          FCB  '*+$80         ; A8
          FCB  '/+$80         ; A9
          FCB  '^+$80         ; AA
          FCC  "AN"           ; AB
          FCB  $80+'D
          FCC  "O"            ; AC
          FCB  $80+'R
          FCB  '>+$80         ; AD
TOK_GREATER EQU  $AD
          FCB  '=+$80         ; AE
TOK_EQUALS EQU  $AE
          FCB  '<+$80         ; AF
          FCC  "F"            ; B0
          FCB  $80+'N
TOK_FN    EQU  $B0
          FCC  "USIN"         ; B1
          FCB  $80+'G
TOK_USING EQU  $B1
*

* FIRST SET ALWAYS HAS ONE PARAMETER
LAB1A     FCC  "SG"           ; 80
          FCB  $80+'N
          FCC  "IN"           ; 81
          FCB  $80+'T
          FCC  "AB"           ; 82
          FCB  $80+'S
          FCC  "US"           ; 83
          FCB  $80+'R
          FCC  "RN"           ; 84
          FCB  $80+'D
          FCC  "SI"           ; 85
          FCB  $80+'N
          FCC  "PEE"          ; 86
          FCB  $80+'K
          FCC  "LE"           ; 87
          FCB  $80+'N
          FCC  "STR"          ; 88
          FCB  $80+'$
          FCC  "VA"           ; 89
          FCB  $80+'L
          FCC  "AS"           ; 8A
          FCB  $80+'C
          FCC  "CHR"          ; 8B
          FCB  $80+'$
          FCC  "AT"           ; 8C
          FCB  $80+'N
          FCC  "CO"           ; 8D
          FCB  $80+'S
          FCC  "TA"           ; 8E
          FCB  $80+'N
          FCC  "EX"           ; 8F
          FCB  $80+'P
          FCC  "FI"           ; 90
          FCB  $80+'X
          FCC  "LO"           ; 91
          FCB  $80+'G
          FCC  "PO"           ; 92
          FCB  $80+'S
          FCC  "SQ"           ; 93
          FCB  $80+'R
          FCC  "HEX"          ; 94
          FCB  $80+'$
* LEFT, RIGHT AND MID ARE TREATED SEPARATELY
          FCC  "LEFT"         ; 95
          FCB  $80+'$
          FCC  "RIGHT"        ; 96
          FCB  $80+'$
          FCC  "MID"          ; 97
          FCB  $80+'$
* REMAINING FUNCTIONS
          FCC  "INKEY"        ; 98
          FCB  $80+'$
          FCC  "ME"           ; 99
          FCB  $80+'M
          FCC  "VARPT"        ; 9A
          FCB  $80+'R
          FCC  "INST"         ; 9B
          FCB  $80+'R
          FCC  "STRING"       ; 9C
          FCB  $80+'$

*
* DISPATCH TABLE FOR COMMANDS TOKEN #
CMD_TAB
LAB67     FDB  FOR            ; 80
          FDB  GO             ; 81
          FDB  REM            ; 82
TOK_REM   EQU  *-CMD_TAB/2+$7F
          FDB  REM            ; 83 (')
TOK_SNGL_Q EQU  *-CMD_TAB/2+$7F
          FDB  REM            ; 84 (ELSE)
TOK_ELSE  EQU  *-CMD_TAB/2+$7F
          FDB  IF             ; 85
TOK_IF    EQU  *-CMD_TAB/2+$7F
          FDB  DATA           ; 86
TOK_DATA  EQU  *-CMD_TAB/2+$7F
          FDB  PRINT          ; 87
TOK_PRINT EQU  *-CMD_TAB/2+$7F
          FDB  ON             ; 88
          FDB  INPUT          ; 89
TOK_INPUT EQU  *-CMD_TAB/2+$7F
          FDB  END            ; 8A
          FDB  NEXT           ; 8B
          FDB  DIM            ; 8C
          FDB  READ           ; 8D
          FDB  RUN            ; 8E
          FDB  RESTOR         ; 8F
          FDB  RETURN         ; 90
          FDB  STOP           ; 91
          FDB  POKE           ; 92
          FDB  CONT           ; 93
          FDB  LIST           ; 94
          FDB  CLEAR          ; 95
          FDB  NEW            ; 96
          FDB  EXEC           ; 97
          FDB  TRON           ; 98
          FDB  TROFF          ; 99
          FDB  DEL            ; 9A
          FDB  DEF            ; 9B
          FDB  LINE           ; 9C
          FDB  RENUM          ; 9D
          FDB  EDIT           ; 9E
TOK_HIGH_EXEC EQU  *-CMD_TAB/2+$7F

* ERROR MESSAGES AND THEIR NUMBERS AS USED INTERNALLY
LABAF     FCC  "NF"           ; 0 NEXT WITHOUT FOR
          FCC  "SN"           ; 1 SYNTAX ERROR
          FCC  "RG"           ; 2 RETURN WITHOUT GOSUB
          FCC  "OD"           ; 3 OUT OF DATA
          FCC  "FC"           ; 4 ILLEGAL FUNCTION CALL
          FCC  "OV"           ; 5 OVERFLOW
          FCC  "OM"           ; 6 OUT OF MEMORY
          FCC  "UL"           ; 7 UNDEFINED LINE NUMBER
          FCC  "BS"           ; 8 BAD SUBSCRIPT
          FCC  "DD"           ; 9 REDIMENSIONED ARRAY
          FCC  "/0"           ; 10 DIVISION BY ZERO
          FCC  "ID"           ; 11 ILLEGAL DIRECT STATEMENT
          FCC  "TM"           ; 12 TYPE MISMATCH
          FCC  "OS"           ; 13 OUT OF STRING SPACE
          FCC  "LS"           ; 14 STRING TOO LONG
          FCC  "ST"           ; 15 STRING FORMULA TOO COMPLEX
          FCC  "CN"           ; 16 CAN'T CONTINUE
          FCC  "FD"           ; 17 BAD FILE DATA
          FCC  "AO"           ; 18 FILE ALREADY OPEN
          FCC  "DN"           ; 19 DEVICE NUMBER ERROR
          FCC  "IO"           ; 20 I/O ERROR
          FCC  "FM"           ; 21 BAD FILE MODE
          FCC  "NO"           ; 22 FILE NOT OPEN
          FCC  "IE"           ; 23 INPUT PAST END OF FILE
          FCC  "DS"           ; 24 DIRECT STATEMENT IN FILE
* ADDITIONAL ERROR MESSAGES ADDED BY EXTENDED BASIC
L890B     FCC  "UF"           ; 25 UNDEFINED FUNCTION (FN) CALL
L890D     FCC  "NE"           ; 26 FILE NOT FOUND

LABE1     FCC  " ERROR"
          FCB  $00
LABE8     FCC  " IN "
          FCB  $00
LABED     FCB  CR
LABEE     FCC  "OK"
          FCB  CR,$00
LABF2     FCB  CR
          FCC  "BREAK"
          FCB  $00

* SEARCH THE STACK FOR 'GOSUB/RETURN' OR 'FOR/NEXT' DATA.
* THE 'FOR/NEXT' INDEX VARIABLE DESCRIPTOR ADDRESS BEING
* SOUGHT IS STORED IN VARDES. EACH BLOCK OF FOR/NEXT DATA IS 18
* BYTES WITH A $80 LEADER BYTE AND THE GOSUB/RETURN DATA IS 5 BYTES
* WITH AN $A6 LEADER BYTE. THE FIRST NON "FOR/NEXT" DATA
* IS CONSIDERED 'GOSUB/RETURN'
LABF9     LEAX 4,S            ; POINT X TO 3RD ADDRESS ON STACK - IGNORE THE
*         FIRST TWO RETURN ADDRESSES ON THE STACK
LABFB     LDB  #18            ; 18 BYTES SAVED ON STACK FOR EACH 'FOR' LOOP
          STX  TEMPTR         ; SAVE POINTER
          LDA  ,X             ; GET 1ST BYTE
          SUBA #$80           ; * CHECK FOR TYPE OF STACK JUMP FOUND
          BNE  LAC1A          ; * BRANCH IF NOT 'FOR/NEXT'
          LDX  1,X            ; = GET INDEX VARIABLE DESCRIPTOR
          STX  TMPTR1         ; = POINTER AND SAVE IT IN TMPTR1
          LDX  VARDES         ; GET INDEX VARIABLE BEING SEARCHED FOR
          BEQ  LAC16          ; BRANCH IF DEFAULT INDEX VARIABLE - USE THE
*                             ; FIRST 'FOR/NEXT' DATA FOUND ON STACK
*                             ; IF NO INDEX VARIABLE AFTER 'NEXT'
          CMPX TMPTR1         ; DOES THE STACK INDEX MATCH THE ONE
*                             ; BEING SEARCHED FOR?
          BEQ  LAC1A          ; YES
          LDX  TEMPTR         ; * RESTORE INITIAL POINTER, ADD
          ABX                 ; * 18 TO IT AND LOOK FOR
          BRA  LABFB          ; * NEXT BLOCK OF DATA
LAC16     LDX  TMPTR1         ; = GET 1ST INDEX VARIABLE FOUND AND
          STX  VARDES         ; = SAVE AS 'NEXT' INDEX
LAC1A     LDX  TEMPTR         ; POINT X TO START OF 'FOR/NEXT' DATA
          TSTA                ; SET ZERO FLAG IF 'FOR/NEXT' DATA
          RTS
* CHECK FOR MEMORY SPACE FOR NEW TOP OF
* ARRAYS AND MOVE ARRAYS TO NEW LOCATION
LAC1E     BSR  LAC37          ; ACCD = NEW BOTTOM OF FREE RAM - IS THERE
*                             ; ROOM FOR THE STACK?
* MOVE BYTES FROM V43(X) TO V41(U) UNTIL (X) = V47 AND
* SAVE FINAL VALUE OF U IN V45
LAC20     LDU  V41            ; POINT U TO DESTINATION ADDRESS (V41)
          LEAU 1,U            ; ADD ONE TO U - COMPENSATE FOR FIRST PSHU
          LDX  V43            ; POINT X TO SOURCE ADDRESS (V43)
          LEAX 1,X            ; ADD ONE - COMPENSATE FOR FIRST LDA ,X
LAC28     LDA  ,-X            ; GRAB A BYTE FROM SOURCE
          PSHU A              ; MOVE IT TO DESTINATION
          CMPX V47            ; DONE?
          BNE  LAC28          ; NO - KEEP MOVING BYTES
          STU  V45            ; SAVE FINAL DESTINATION ADDRESS
LAC32     RTS
* CHECK TO SEE IF THERE IS ROOM TO STORE 2*ACCB
* BYTES IN FREE RAM - OM ERROR IF NOT
LAC33     CLRA                ; * ACCD CONTAINS NUMBER OF EXTRA
          ASLB                ; * BYTES TO PUT ON STACK
          ADDD ARYEND         ; END OF PROGRAM AND VARIABLES
LAC37     ADDD #STKBUF        ; ADD STACK BUFFER - ROOM FOR STACK?
          BCS  LAC44          ; BRANCH IF GREATER THAN $FFFF
          STS  BOTSTK         ; CURRENT NEW BOTTOM OF STACK STACK POINTER
          CMPD BOTSTK         ; ARE WE GOING TO BE BELOW STACK?
          BCS  LAC32          ; YES - NO ERROR
LAC44     LDB  #6*2           ; OUT OF MEMORY ERROR

* ERROR SERVICING ROUTINE
LAC46     JSR  LAD33          ; RESET STACK, STRING STACK, CONTINUE POINTER
          JSR  LB95C          ; SEND A CR TO SCREEN
          JSR  LB9AF          ; SEND A '?' TO SCREEN
          LDX  #LABAF         ; POINT TO ERROR TABLE
LAC60     ABX                 ; ADD MESSAGE NUMBER OFFSET
          BSR  LACA0          ; * GET TWO CHARACTERS FROM X AND
          BSR  LACA0          ; * SEND TO CONSOLE OUT (SCREEN)
          LDX  #LABE1-1       ; POINT TO "ERROR" MESSAGE
LAC68     JSR  LB99C          ; PRINT MESSAGE POINTED TO BY X
          LDA  CURLIN         ; GET CURRENT LINE NUMBER (CURL IN)
          INCA                ; TEST FOR DIRECT MODE
          BEQ  LAC73          ; BRANCH IF DIRECT MODE
          JSR  LBDC5          ; PRINT 'IN ****'

* THIS IS THE MAIN LOOP OF BASIC WHEN IN DIRECT MODE
LAC73     JSR  LB95C          ; MOVE CURSOR TO START OF LINE
          LDX  #LABED         ; POINT X TO 'OK', CR MESSAGE
          JSR  LB99C          ; PRINT 'OK', CR
LAC7C     JSR  LA390          ; GO GET AN INPUT LINE
          LDU  #$FFFF         ; THE LINE NUMBER FOR DIRECT MODE IS $FFFF
          STU  CURLIN         ; SAVE IT IN CURLIN
          BCS  LAC7C          ; BRANCH IF LINE INPUT TERMINATED BY BREAK
          STX  CHARAD         ; SAVE (X) AS CURRENT INPUT POINTER - THIS WILL
*         ENABLE THE 'LIVE KEYBOARD' (DIRECT) MODE. THE
*         LINE JUST ENTERED WILL BE INTERPRETED
          JSR  GETNCH         ; GET NEXT CHARACTER FROM BASIC
          BEQ  LAC7C          ; NO LINE INPUT - GET ANOTHER LINE
          BCS  LACA5          ; BRANCH IF NUMER1C - THERE WAS A LINE NUMBER BEFORE
*         THE  STATEMENT ENTERED, SO THIS STATEMENT
*         WILL BE MERGED INTO THE BASIC PROGRAM
          JSR  LB821          ; GO CRUNCH LINE
          JMP  LADC0          ; GO EXECUTE THE STATEMENT (LIVE KEYBOARD)
*
LACA0     LDA  ,X+            ; GET A CHARACTER
          JMP  LB9B1          ; SEND TO CONSOLE OUT
* TAKE A LINE FROM THE LINE INPUT BUFFER
* AND INSERT IT INTO THE BASIC PROGRAM
LACA5     JSR  LAF67          ; CONVERT LINE NUMBER TO BINARY
LACA8     LDX  BINVAL         ; GET CONVERTED LINE NUMBER
          STX  LINHDR         ; STORE IT IN LINE INPUT HEADER
          JSR  LB821          ; GO CRUNCH THE LINE
          STB  TMPLOC         ; SAVE LINE LENGTH
          BSR  LAD01          ; FIND OUT WHERE TO INSERT LINE
          BCS  LACC8          ; RANCH IF LINE NUMBER DOES NOT ALREADY EXIST
          LDD  V47            ; GET ABSOLUTE ADDRESS OF LINE NUMBER
          SUBD ,X             ; SUBTRACT ADDRESS OF NEXT LINE NUMBER
          ADDD VARTAB         ; * ADD TO CURRENT END OF PROGRAM - THIS WILL REMOVE
          STD  VARTAB         ; * THE LENGTH OF THIS LINE NUMBER FROM THE PROGRAM
          LDU  ,X             ; POINT U TO ADDRESS OF NEXT LINE NUMBER
* DELETE OLD LINE FROM BASIC PROGRAM
LACC0     PULU A              ; GET A BYTE FROM WHAT'S LEFT OF PROGRAM
          STA  ,X+            ; MOVE IT DOWN
          CMPX VARTAB         ; COMPARE TO END OF BASIC PROGRAM
          BNE  LACC0          ; BRANCH IF NOT AT END
LACC8     LDA  LINBUF         ; * CHECK TO SEE IF THERE IS A LINE IN
          BEQ  LACE9          ; * THE BUFFER AND BRANCH IF NONE
          LDD  VARTAB         ; = SAVE CURRENT END OF
          STD  V43            ; = PROGRAM IN V43
          ADDB TMPLOC         ; * ADD LENGTH OF CRUNCHED LINE,
          ADCA #0             ; * PROPOGATE CARRY AND SAVE NEW END
          STD  V41            ; * OF PROGRAM IN V41
          JSR  LAC1E          ; = MAKE SURE THERE'S ENOUGH RAM FOR THIS
*         =    LINE & MAKE A HOLE IN BASIC FOR NEW LINE
          LDU  #LINHDR-2      ; POINT U TO LINE TO BE INSERTED
LACDD     PULU A              ; GET A BYTE FROM NEW LINE
          STA  ,X+            ; INSERT IT IN PROGRAM
          CMPX V45            ; * COMPARE TO ADDRESS OF END OF INSERTED
          BNE  LACDD          ; * LINE AND BRANCH IF NOT DONE
          LDX  V41            ; = GET AND SAVE
          STX  VARTAB         ; = END OF PROGRAM
LACE9     BSR  LAD21          ; RESET INPUT POINTER, CLEAR VARIABLES, INITIALIZE
          BSR  LACEF          ; ADJUST START OF NEXT LINE ADDRESSES
          BRA  LAC7C          ; EENTER BASIC'S INPUT LOOP
* COMPUTE THE START OF NEXT LINE ADDRESSES FOR THE BASIC PROGRAM
LACEF     LDX  TXTTAB         ; POINT X TO START OF PROGRAM
LACF1     LDD  ,X             ; GET ADDRESS OF NEXT LINE
          BEQ  LAD16          ; RETURN IF END OF PROGRAM
          LEAU 4,X            ; POINT U TO START OF BASIC TEXT IN LINE
LACF7     LDA  ,U+            ; * SKIP THROUGH THE LINE UNTIL A
          BNE  LACF7          ; * ZERO (END OF LINE) IS FOUND
          STU  ,X             ; SAVE THE NEW START OF NEXT LINE ADDRESS
          LDX  ,X             ; POINT X TO START OF NEXT LINE
          BRA  LACF1          ; KEEP GOING
*
* FIND A LINE NUMBER IN THE BASIC PROGRAM
* RETURN WITH CARRY SET IF NO MATCH FOUND
LAD01     LDD  BINVAL         ; GET THE LINE NUMBER TO FIND
          LDX  TXTTAB         ; BEGINNING OF PROGRAM
LAD05     LDU  ,X             ; GET ADDRESS OF NEXT LINE NUMBER
          BEQ  LAD12          ; BRANCH IF END OF PROG
          CMPD 2,X            ; IS IT A MATCH?
          BLS  LAD14          ; CARRY SET IF LOWER; CARRY CLEAR IF MATCH
          LDX  ,X             ; X = ADDRESS OF NEXT LINE
          BRA  LAD05          ; KEEP LOOPING FOR LINE NUMBER
LAD12     ORCC #1             ; SET CARRY FLAG
LAD14     STX  V47            ; SAVE MATCH LINE NUMBER OR NUMBER OF LINE JUST AFTER
*                             ; WHERE IT SHOULD HAVE BEEN
LAD16     RTS

* NEW
NEW       BNE  LAD14          ; BRANCH IF ARGUMENT GIVEN
LAD19     LDX  TXTTAB         ; GET START OF BASIC
          CLR  ,X+            ; * PUT 2 ZERO BYTES THERE - ERASE
          CLR  ,X+            ; * THE BASIC PROGRAM
          STX  VARTAB         ; AND THE NEXT ADDRESS IS NOW THE END OF PROGRAM
LAD21     LDX  TXTTAB         ; GET START OF BASIC
          JSR  LAEBB          ; PUT INPUT POINTER ONE BEFORE START OF BASIC
* ERASE ALL VARIABLES
LAD26     LDX  MEMSIZ         ; * RESET START OF STRING VARIABLES
          STX  STRTAB         ; * TO TOP OF STRING SPACE
          JSR  RESTOR         ; RESET 'DATA' POINTER TO START OF BASIC
          LDX  VARTAB         ; * GET START OF VARIABLES AND USE IT
          STX  ARYTAB         ; * TO RESET START OF ARRAYS
          STX  ARYEND         ; RESET END OF ARRAYS
LAD33     LDX  #STRSTK        ; * RESET STRING STACK POINTER TO
          STX  TEMPPT         ; * BOTTOM OF STRING STACK
          LDX  ,S             ; GET RETURN ADDRESS OFF STACK
          LDS  FRETOP         ; RESTORE STACK POINTER
          CLR  ,-S            ; PUT A ZERO BYTE ON STACK - TO CLEAR ANY RETURN OF
*                             ; FOR/NEXT DATA FROM THE STACK
          CLR  OLDPTR         ; RESET 'CONT' ADDRESS SO YOU
          CLR  OLDPTR+1       ; 'CAN'T CONTINUE'
          CLR  ARYDIS         ; CLEAR THE ARRAY DISABLE FLAG
          JMP  ,X             ; RETURN TO CALLING ROUTINE - THIS IS NECESSARY
*                             ; SINCE THE STACK WAS RESET
*
* FOR
*
* THE FOR COMMAND WILL STORE 18 BYTES ON THE STACK FOR
* EACH FOR-NEXT LOOP WHICH IS BEING PROCESSED. THESE
* BYTES ARE DEFINED AS FOLLOWS: 0- $80 (FOR FLAG);
*         1,2=INDEX VARIABLE DESCRIPTOR POINTER; 3-7=FP VALUE OF STEP;
*         8=STEP DIRECTION: $FF IF NEGATIVE; 0 IF ZERO; 1 IF POSITIVE;
* 9-13=FP VALUE OF 'TO' PARAMETER;
* 14,15=CURRENT LINE NUMBER; 16,17=RAM ADDRESS OF THE END
*         OF   THE LINE CONTAINING THE 'FOR' STATEMENT
FOR       LDA  #$80           ; * SAVE THE DISABLE ARRAY FLAG IN VO8
          STA  ARYDIS         ; * DO NOT ALLOW THE INDEX VARIABLE TO BE AN ARRAY
          JSR  LET            ; SET INDEX VARIABLE TO INITIAL VALUE
          JSR  LABF9          ; SEARCH THE STACK FOR 'FOR/NEXT' DATA
          LEAS 2,S            ; PURGE RETURN ADDRESS OFF OF THE STACK
          BNE  LAD59          ; BRANCH IF INDEX VARIABLE NOT ALREADY BEING USED
          LDX  TEMPTR         ; GET (ADDRESS + 18) OF MATCHED 'FOR/NEXT' DATA
          LEAS B,X            ; MOVE THE STACK POINTER TO THE BEGINNING OF THE
* MATCHED 'FOR/NEXT' DATA SO THE NEW DATA WILL
* OVERLAY THE OLD DATA. THIS WILL ALSO DESTROY
* ALL OF THE 'RETURN' AND 'FOR/NEXT' DATA BELOW
* THIS POINT ON THE STACK
LAD59     LDB  #$09           ; * CHECK FOR ROOM FOR 18 BYTES
          JSR  LAC33          ; * IN FREE RAM
          JSR  LAEE8          ; GET ADDR OF END OF SUBLINE IN X
          LDD  CURLIN         ; GET CURRENT LINE NUMBER
          PSHS X,B,A          ; SAVE LINE ADDR AND LINE NUMBER ON STACK
          LDB  #TOK_TO        ; TOKEN FOR 'TO'
          JSR  LB26F          ; SYNTAX CHECK FOR 'TO'
          JSR  LB143          ; 'TM' ERROR IF INDEX VARIABLE SET TO STRING
          JSR  LB141          ; EVALUATE EXPRESSION
*
          LDB  FP0SGN         ; GET FPA0 MANTISSA SIGN
          ORB  #$7F           ; FORM A MASK TO SAVE DATA BITS OF HIGH ORDER MANTISSA
          ANDB FPA0           ; PUT THE MANTISSA SIGN IN BIT 7 OF HIGH ORDER MANTISSA
          STB  FPA0           ; SAVE THE PACKED HIGH ORDER MANTISSA
          LDY  #LAD7F         ; LOAD FOLLOWING ADDRESS INTO Y AS A RETURN
          JMP  LB1EA          ; ADDRESS - PUSH FPA0 ONTO THE STACK
LAD7F     LDX  #LBAC5         ; POINT X TO FLOATING POINT NUMBER 1.0 (DEFAULT STEP VALUE)
          JSR  LBC14          ; MOVE (X) TO FPA0
          JSR  GETCCH         ; GET CURRENT INPUT CHARACTER
          CMPA #TOK_STEP      ; STEP TOKEN
          BNE  LAD90          ; BRANCH IF NO 'STEP' VALUE
          JSR  GETNCH         ; GET A CHARACTER FROM BASIC
          JSR  LB141          ; EVALUATE NUMERIC EXPRESSION
LAD90     JSR  LBC6D          ; CHECK STATUS OF FPA0
          JSR  LB1E6          ; SAVE STATUS AND FPA0 ON THE STACK
          LDD  VARDES         ; * GET DESCRIPTOR POINTER FOR THE 'STEP'
          PSHS B,A            ; * VARIABLE AND SAVE IT ON THE STACK
          LDA  #$80           ; = GET THE 'FOR' FLAG AND
          PSHS A              ; = SAVE IT ON THE STACK
*
* MAIN COMMAND INTERPRETATION LOOP
LAD9E     ANDCC #$AF          ; ENABLE IRQ,FIRQ
          BSR  LADEB          ; CHECK FOR KEYBOARD BREAK
          LDX  CHARAD         ; GET BASIC'S INPUT POINTER
          STX  TINPTR         ; SAVE IT
          LDA  ,X+            ; GET CURRENT INPUT CHAR & MOVE POINTER
          BEQ  LADB4          ; BRANCH IF END OF LINE
          CMPA #':            ; CHECK FOR LINE SEPARATOR
          BEQ  LADC0          ; BRANCH IF COLON
LADB1     JMP  LB277          ; 'SYNTAX ERROR'-IF NOT LINE SEPARATOR
LADB4     LDA  ,X++           ; GET MS BYTE OF ADDRESS OF NEXT BASIC LINE
          STA  ENDFLG         ; SAVE IN STOP/END FLAG - CAUSE A STOP IF
*                             ; NEXT LINE ADDRESS IS < $8000; CAUSE
*                             ; AN END IF ADDRESS > $8000
          BEQ  LAE15          ; BRANCH TO 'STOP' - END OF PROGRAM
          LDD  ,X+            ; GET CURRENT LINE NUMBER
          STD  CURLIN         ; SAVE IN CURLIN
          STX  CHARAD         ; SAVE ADDRESS OF FIRST BYTE OF LINE
* EXTENDED BASIC TRACE
          LDA  TRCFLG         ; TEST THE TRACE FLAG
          BEQ  LADC0          ; BRANCH IF TRACE OFF
          LDA  #$5B           ; <LEFT HAND MARKER FOR TRON LINE NUMBER
          JSR  PUTCHR         ; OUTPUT A CHARACTER
          LDA  CURLIN         ; GET MS BYTE OF LINE NUMBER
          JSR  LBDCC          ; CONVERT ACCD TO DECIMAL AND PRINT ON SCREEN
          LDA  #$5D           ; > RIGHT HAND MARKER FOR TRON LINE NUMBER
          JSR  PUTCHR         ; OUTPUT A CHARACTER
* END OF EXTENDED BASIC TRACE
LADC0     JSR  GETNCH         ; GET A CHARACTER FROM BASIC
          BSR  LADC6          ; GO PROCESS COMMAND
          BRA  LAD9E          ; GO BACK TO MAIN LOOP
LADC6     BEQ  LADEA          ; RETURN IF END OF LINE (RTS - was BEQ LAE40)
          TSTA                ; CHECK FOR TOKEN - BIT 7 SET (NEGATIVE)
          LBPL LET            ; BRANCH IF NOT A TOKEN - GO DO A 'LET' WHICH
*                             ; IS THE 'DEFAULT' TOKEN FOR MICROSOFT BASIC
          CMPA #$FF           ; SECONDARY TOKEN
          BEQ  SECTOK
          CMPA #TOK_HIGH_EXEC ; SKIPF TOKEN - HIGHEST EXECUTABLE COMMAND IN BASIC
          BHI  LADB1          ; 'SYNTAX ERROR' IF NON-EXECUTABLE TOKEN
          LDX  COMVEC+3       ; GET ADDRESS OF BASIC'S COMMAND TABLE
LADD4     ASLA                ; X2 (2 BYTE/JUMP ADDRESS) & DISCARD BIT 7
          TFR  A,B            ; SAVE COMMAND OFFSET IN ACCB
          ABX                 ; NON X POINTS TO COMMAND JUMP ADDR
          JSR  GETNCH         ; GET AN INPUT CHAR
*
* HERE IS WHERE WE BRANCH TO DO A 'COMMAND'
          JMP  [,X]           ; GO DO A COMMAND
SECTOK
* THE ONLY SECONDARY TOKEN THAT CAN ALSO BE AN EXECUTABLE IS
* THE MID$ REPLACEMENT STATEMENT. SO SPECIAL-CASE CHECK DONE HERE
          JSR  GETNCH         ; GET AN INPUT CHAR
          CMPA #TOK_MID       ; TOKEN FOR "MID$"
          LBEQ L86D6          ; PROCESS MID$ REPLACEMENT
          JMP  LB277          ; SYNTAX ERROR

*
* RESTORE
RESTOR    LDX  TXTTAB         ; BEGINNING OF PROGRAM ADDRESS
          LEAX -1,X           ; MOVE TO ONE BYTE BEFORE PROGRAM
LADE8     STX  DATPTR         ; SAVE NEW DATA POINTER
LADEA     RTS
*
* BREAK CHECK
LADEB     JSR  LA1C1          ; GET A KEYSTROKE ENTRY
          BEQ  LADFA          ; RETURN IF NO INPUT
LADF0     CMPA #3             ; CONTROL C? (BREAK)
          BEQ  STOP           ; YES
          CMPA #$13           ; CONTROL S? (PAUSE)
          BEQ  LADFB          ; YES
          STA  IKEYIM         ; SAVE KEYSTROKE IN INKEY IMAGE
LADFA     RTS
LADFB     JSR  KEYIN          ; GET A KEY
          BEQ  LADFB          ; BRANCH IF NO KEY DOWN
          BRA  LADF0          ; CONTINUE - DO A BREAK CHECK
*
* END
END       JSR  GETCCH         ; GET CURRENT INPUT CHAR
          BRA  LAE0B
*
* STOP
STOP      ORCC #$01           ; SET CARRY FLAG
LAE0B     BNE  LAE40          ; BRANCH IF ARGUMENT EXISTS
          LDX  CHARAD         ; * SAVE CURRENT POSITION OF
          STX  TINPTR         ; * BASIC'S INPUT POINTER
LAE11     ROR  ENDFLG         ; ROTATE CARRY INTO BIT 7 OF STOP/END FLAG
          LEAS 2,S            ; PURGE RETURN ADDRESS OFF STACK
LAE15     LDX  CURLIN         ; GET CURRENT LINE NUMBER
          CMPX #$FFFF         ; DIRECT MODE?
          BEQ  LAE22          ; YES
          STX  OLDTXT         ; SAVE CURRENT LINE NUMBER
          LDX  TINPTR         ; * GET AND SAVE CURRENT POSITION
          STX  OLDPTR         ; * OF BASIC'S INPUT POINTER
LAE22
          LDX  #LABF2-1       ; POINT TO CR, 'BREAK' MESSAGE
          TST  ENDFLG         ; CHECK STOP/END FLAG
          LBPL LAC73          ; BRANCH TO MAIN LOOP OF BASIC IF END
          JMP  LAC68          ; PRINT 'BREAK AT ####' AND GO TO
*                             ; BASIC'S MAIN LOOP IF 'STOP'

* CONT
CONT      BNE  LAE40          ; RETURN IF ARGUMENT GIVEN
          LDB  #2*16          ; 'CAN'T CONTINUE' ERROR
          LDX  OLDPTR         ; GET CONTINUE ADDRESS (INPUT POINTER)
          LBEQ LAC46          ; 'CN' ERROR IF CONTINUE ADDRESS = 0
          STX  CHARAD         ; RESET BASIC'S INPUT POINTER
          LDX  OLDTXT         ; GET LINE NUMBER
          STX  CURLIN         ; RESET CURRENT LINE NUMBER
LAE40     RTS
*
* CLEAR
CLEAR     BEQ  LAE6F          ; BRANCH IF NO ARGUMENT
          JSR  LB3E6          ; EVALUATE ARGUMENT
          PSHS B,A            ; SAVE AMOUNT OF STRING SPACE ON STACK
          LDX  MEMSIZ         ; GET CURRENT TOP OF CLEARED SPACE
          JSR  GETCCH         ; GET CURRENT INPUT CHARACTER
          BEQ  LAE5A          ; BRANCH IF NO NEW TOP OF CLEARED SPACE
          JSR  LB26D          ; SYNTAX CHECK FOR COMMA
          JSR  LB73D          ; EVALUATE EXPRESSlON; RETURN VALUE IN X
          LEAX -1,X           ; X = TOP OF CLEARED SPACE
          CMPX TOPRAM         ; COMPARE TO TOP OF RAM
          BHI  LAE72          ; 'OM' ERROR IF > TOP OF RAM
LAE5A     TFR  X,D            ; ACCD = TOP OF CLEARED SPACE
          SUBD ,S++           ; SUBTRACT OUT AMOUNT OF CLEARED SPACE
          BCS  LAE72          ; 'OM' ERROR IF FREE MEM < 0
          TFR  D,U            ; U = BOTTOM OF CLEARED SPACE
          SUBD #STKBUF        ; SUBTRACT OUT STACK BUFFER
          BCS  LAE72          ; 'OM' ERROR IF FREE MEM < 0
          SUBD VARTAB         ; SUBTRACT OUT START OF VARIABLES
          BCS  LAE72          ; 'OM' ERROR IF FREE MEM < 0
          STU  FRETOP         ; SAVE NEW BOTTOM OF CLEARED SPACE
          STX  MEMSIZ         ; SAVE NEW TOP OF CLEARED SPACE
LAE6F     JMP  LAD26          ; ERASE ALL VARIABLES, INITIALIZE POINTERS, ETC
LAE72     JMP  LAC44          ; 'OM' ERROR
*
* RUN
RUN       JSR  GETCCH         ; * GET CURRENT INPUT CHARACTER
          LBEQ LAD21          ; * IF NO LINE NUMBER
          JSR  LAD26          ; ERASE ALL VARIABLES
          BRA  LAE9F          ; 'GOTO' THE RUN ADDRESS
*
* GO
GO        TFR  A,B            ; SAVE INPUT CHARACTER IN ACCB
LAE88     JSR  GETNCH         ; GET A CHARACTER FROM BASIC
          CMPB #TOK_TO        ; 'TO' TOKEN
          BEQ  LAEA4          ; BRANCH IF GOTO
          CMPB #TOK_SUB       ; 'SUB' TOKEN
          BNE  LAED7          ; 'SYNTAX ERROR' IF NEITHER
          LDB  #3             ; =ROOM FOR 6
          JSR  LAC33          ; =BYTES ON STACK?
          LDU  CHARAD         ; * SAVE CURRENT BASIC INPUT POINTER, LINE
          LDX  CURLIN         ; * NUMBER AND SUB TOKEN ON STACK
          LDA  #TOK_SUB       ; *
          PSHS U,X,A          ; *
LAE9F     BSR  LAEA4          ; GO DO A 'GOTO'
          JMP  LAD9E          ; JUMP BACK TO BASIC'S MAIN LOOP
* GOTO
LAEA4     JSR  GETCCH         ; GET CURRENT INPUT CHAR
          JSR  LAF67          ; GET LINE NUMBER TO BINARY IN BINVAL
          BSR  LAEEB          ; ADVANCE BASIC'S POINTER TO END OF LINE
          LEAX $01,X          ; POINT TO START OF NEXT LINE
          LDD  BINVAL         ; GET THE LINE NUMBER TO RUN
          CMPD CURLIN         ; COMPARE TO CURRENT LINE NUMBER
          BHI  LAEB6          ; IF REO'D LINE NUMBER IS > CURRENT LINE NUMBER,
*              ; DON'T START LOOKING FROM
*              ; START OF PROGRAM
          LDX  TXTTAB         ; BEGINNING OF PROGRAM
LAEB6     JSR  LAD05          ; GO FIND A LINE NUMBER
          BCS  LAED2          ; 'UNDEFINED LINE NUMBER'
LAEBB     LEAX -1,X           ; MOVE BACK TO JUST BEFORE START OF LINE
          STX  CHARAD         ; RESET BASIC'S INPUT POINTER
LAEBF     RTS
*
* RETURN
RETURN    BNE  LAEBF          ; EXIT ROUTINE IF ARGUMENT GIVEN
          LDA  #$FF           ; * PUT AN ILLEGAL VARIABLE NAME IN FIRST BYTE OF
          STA  VARDES         ; * VARDES WHICH WILL CAUSE 'FOR/NEXT' DATA ON THE
*              ; STACK TO BE IGNORED
          JSR  LABF9          ; CHECK FOR RETURN DATA ON THE STACK
          TFR  X,S            ; RESET STACK POINTER - PURGE TWO RETURN ADDRESSES
*              ; FROM THE STACK
          CMPA #TOK_SUB-$80   ; SUB TOKEN - $80
          BEQ  LAEDA          ; BRANCH IF 'RETURN' FROM SUBROUTINE
          LDB  #2*2           ; ERROR #2 'RETURN WITHOUT GOSUB'
          FCB  SKP2           ; SKIP TWO BYTES
LAED2     LDB  #7*2           ; ERROR #7 'UNDEFINED LINE NUMBER'
          JMP  LAC46          ; JUMP TO ERROR HANDLER
LAED7     JMP  LB277          ; 'SYNTAX ERROR'
LAEDA     PULS A,X,U          ; * RESTORE VALUES OF CURRENT LINE NUMBER AND
          STX  CURLIN         ; * BASIC'S INPUT POINTER FOR THIS SUBROUTINE
          STU  CHARAD         ; * AND LOAD ACCA WITH SUB TOKEN ($A6)
*
* DATA
DATA      BSR  LAEE8          ; MOVE INPUT POINTER TO END OF SUBLINE OR LINE
          FCB  SKP2           ; SKIP 2 BYTES

* REM, ELSE
ELSE
REM       BSR  LAEEB          ; MOVE INPUT POINTER TO END OF LINE
          STX  CHARAD         ; RESET BASIC'S INPUT POINTER
LAEE7     RTS
* ADVANCE INPUT POINTER TO END OF SUBLINE OR LINE
LAEE8     LDB  #':            ; COLON = SUBLINE TERMINATOR CHARACTER
LAEEA     FCB  SKP1LD         ; SKPILD SKIP ONE BYTE; LDA #$5F
* ADVANCE BASIC'S INPUT POINTER TO END OF
* LINE - RETURN ADDRESS OF END OF LINE+1 IN X
LAEEB     CLRB                ; 0 = LINE TERMINATOR CHARACTER
          STB  CHARAC         ; TEMP STORE PRIMARY TERMINATOR CHARACTER
          CLRB                ; 0 (END OF LINE) = ALTERNATE TERM. CHAR.
          LDX  CHARAD         ; LOAD X W/BASIC'S INPUT POINTER
LAEF1     TFR  B,A            ; * CHANGE TERMINATOR CHARACTER
          LDB  CHARAC         ; * FROM ACCB TO CHARAC - SAVE OLD TERMINATOR
*         IN   CHARAC
          STA  CHARAC         ; SWAP PRIMARY AND SECONDARY TERMINATORS
LAEF7     LDA  ,X             ; GET NEXT INPUT CHARACTER
          BEQ  LAEE7          ; RETURN IF 0 (END OF LINE)
          PSHS B              ; SAVE TERMINATOR ON STACK
          CMPA ,S+            ; COMPARE TO INPUT CHARACTER
          BEQ  LAEE7          ; RETURN IF EQUAL
          LEAX 1,X            ; MOVE POINTER UP ONE
          CMPA #'"            ; CHECK FOR DOUBLE QUOTES
          BEQ  LAEF1          ; BRANCH IF " - TOGGLE TERMINATOR CHARACTERS
          INCA                ; * CHECK FOR $FF AND BRANCH IF
          BNE  LAF0C          ; * NOT SECONDARY TOKEN
          LEAX 1,X            ; MOVE INPUT POINTER 1 MORE IF SECONDARY
LAF0C     CMPA #TOK_IF+1      ; TOKEN FOR IF?
          BNE  LAEF7          ; NO - GET ANOTHER INPUT CHARACTER
          INC  IFCTR          ; INCREMENT IF COUNTER - KEEP TRACK OF HOW MANY
*                             ; 'IF' STATEMENTS ARE NESTED IN ONE LINE
          BRA  LAEF7          ; GET ANOTHER INPUT CHARACTER

* IF
IF        JSR  LB141          ; EVALUATE NUMERIC EXPRESSION
          JSR  GETCCH         ; GET CURRENT INPUT CHARACTER
          CMPA #TOK_GO        ; TOKEN FOR GO
          BEQ  LAF22          ; TREAT 'GO' THE SAME AS 'THEN'
          LDB  #TOK_THEN      ; TOKEN FOR THEN
          JSR  LB26F          ; DO A SYNTAX CHECK ON ACCB
LAF22     LDA  FP0EXP         ; CHECK FOR TRUE/FALSE - FALSE IF FPA0 EXPONENT = ZERO
          BNE  LAF39          ; BRANCH IF CONDITION TRUE
          CLR  IFCTR          ; CLEAR FLAG - KEEP TRACK OF WHICH NESTED ELSE STATEMENT
*                             ; TO SEARCH FOR IN NESTED 'IF' LOOPS
LAF28     BSR  DATA           ; MOVE BASIC'S POINTER TO END OF SUBLINE
          TSTA                ; * CHECK TO SEE IF END OF LINE OR SUBLINE
          BEQ  LAEE7          ; * AND RETURN IF END OF LINE
          JSR  GETNCH         ; GET AN INPUT CHARACTER FROM BASIC
          CMPA #TOK_ELSE      ; TOKEN FOR ELSE
          BNE  LAF28          ; IGNORE ALL DATA EXCEPT 'ELSE' UNTIL
*                             ; END OF LINE (ZERO BYTE)
          DEC  IFCTR          ; CHECK TO SEE IF YOU MUST SEARCH ANOTHER SUBLINE
          BPL  LAF28          ; BRANCH TO SEARCH ANOTHER SUBLINE FOR 'ELSE'
          JSR  GETNCH         ; GET AN INPUT CHARACTER FROM BASIC
LAF39     JSR  GETCCH         ; GET CURRENT INPUT CHARACTER
          LBCS LAEA4          ; BRANCH TO 'GOTO' IF NUMERIC CHARACTER
          JMP  LADC6          ; RETURN TO MAIN INTERPRETATION LOOP

* ON
ON        JSR  LB70B          ; EVALUATE EXPRESSION
          LDB  #TOK_GO        ; TOKEN FOR GO
          JSR  LB26F          ; SYNTAX CHECK FOR GO
          PSHS A              ; SAVE NEW TOKEN (TO,SUB)
          CMPA #TOK_SUB       ; TOKEN FOR SUB?
          BEQ  LAF54          ; YES
          CMPA #TOK_TO        ; TOKEN FOR TO?
LAF52     BNE  LAED7          ; 'SYNTAX' ERROR IF NOT 'SUB' OR 'TO'
LAF54     DEC  FPA0+3         ; DECREMENT IS BYTE OF MANTISSA OF FPA0 - THIS
*                             ; IS THE ARGUMENT OF THE 'ON' STATEMENT
          BNE  LAF5D          ; BRANCH IF NOT AT THE PROPER GOTO OR GOSUB LINE NUMBER
          PULS B              ; GET BACK THE TOKEN FOLLOWING 'GO'
          JMP  LAE88          ; GO DO A 'GOTO' OR 'GOSUB'
LAF5D     JSR  GETNCH         ; GET A CHARACTER FROM BASIC
          BSR  LAF67          ; CONVERT BASIC LINE NUMBER TO BINARY
          CMPA #',            ; IS CHARACTER FOLLOWING LINE NUMBER A COMMA?
          BEQ  LAF54          ; YES
          PULS B,PC           ; IF NOT, FALL THROUGH TO NEXT COMMAND
LAF67     LDX  ZERO           ; DEFAULT LINE NUMBER OF ZERO
          STX  BINVAL         ; SAVE IT IN BINVAL
*
* CONVERT LINE NUMBER TO BINARY - RETURN VALUE IN BINVAL
*
LAF6B     BCC  LAFCE          ; RETURN IF NOT NUMERIC CHARACTER
          SUBA #'0            ; MASK OFF ASCII
          STA  CHARAC         ; SAVE DIGIT IN VO1
          LDD  BINVAL         ; GET ACCUMULATED LINE NUMBER VALUE
          CMPA #24            ; LARGEST LINE NUMBER IS $F9FF (63999) -
*         (24*256+255)*10+9
          BHI  LAF52          ; 'SYNTAX' ERROR IF TOO BIG
* MULT ACCD X 10
          ASLB                ; *
          ROLA                ; * TIMES 2
          ASLB                ; =
          ROLA                ; = TIMES 4
          ADDD BINVAL         ; ADD 1 = TIMES 5
          ASLB                ; *
          ROLA                ; * TIMES 10
          ADDB CHARAC         ; ADD NEXT DIGIT
          ADCA #0             ; PROPAGATE CARRY
          STD  BINVAL         ; SAVE NEW ACCUMULATED LINE NUMBER
          JSR  GETNCH         ; GET NEXT CHARACTER FROM BASIC
          BRA  LAF6B          ; LOOP- PROCESS NEXT DIGIT
*
* LET (EXBAS)
* EVALUATE A NON-TOKEN EXPRESSION
* TARGET = REPLACEMENT
LET       JSR  LB357          ; FIND TARGET VARIABLE DESCRIPTOR
          STX  VARDES         ; SAVE DESCRIPTOR ADDRESS OF 1ST EXPRESSION
          LDB  #TOK_EQUALS    ; TOKEN FOR "="
          JSR  LB26F          ; DO A SYNTAX CHECK FOR '='
          LDA  VALTYP         ; * GET VARIABLE TYPE AND
          PSHS A              ; * SAVE ON THE STACK
          JSR  LB156          ; EVALUATE EXPRESSION
          PULS A              ; * REGET VARIABLE TYPE OF 1ST EXPRESSION AND
          RORA                ; * SET CARRY IF STRING
          JSR  LB148          ; TYPE CHECK-TM ERROR IF VARIABLE TYPES ON
*                             ; BOTH SIDES OF EQUALS SIGN NOT THE SAME
          LBEQ LBC33          ; GO PUT FPA0 INTO VARIABLE DESCRIPTOR IF NUMERIC
* MOVE A STRING WHOSE DESCRIPTOR IS LOCATED AT
* FPA0+2 INTO THE STRING SPACE. TRANSFER THE
* DESCRIPTOR ADDRESS TO THE ADDRESS IN VARDES
* DON'T MOVE THE STRING IF IT IS ALREADY IN THE
* STRING SPACE. REMOVE DESCRIPTOR FROM STRING
* STACK IF IT IS LAST ONE ON THE STACK
LAFA4     LDX  FPA0+2         ; POINT X TO DESCRIPTOR OF REPLACEMENT STRING
          LDD  FRETOP         ; LOAD ACCD WITH START OF STRING SPACE
          CMPD 2,X            ; IS THE STRING IN STRING SPACE?
          BCC  LAFBE          ; BRANCH IF IT'S NOT IN THE STRING SPACE
          CMPX VARTAB         ; COMPARE DESCRIPTOR ADDRESS TO START OF VARIABLES
          BCS  LAFBE          ; BRANCH IF DESCRIPTOR ADDRESS NOT IN VARIABLES
LAFB1     LDB  ,X             ; GET LENGTH OF REPLACEMENT STRING
          JSR  LB50D          ; RESERVE ACCB BYTES OF STRING SPACE
          LDX  V4D            ; GET DESCRIPTOR ADDRESS BACK
          JSR  LB643          ; MOVE STRING INTO STRING SPACE
          LDX  #STRDES        ; POINT X TO TEMP STRING DESCRIPTOR ADDRESS
LAFBE     STX  V4D            ; SAVE STRING DESCRIPTOR ADDRESS IN V4D
          JSR  LB675          ; REMOVE STRING DESCRIPTOR IF LAST ONE
*              ; ON STRING STACK
          LDU  V4D            ; POINT U TO REPLACEMENT DESCRIPTOR ADDRESS
          LDX  VARDES         ; GET TARGET DESCRIPTOR ADDRESS
          PULU A,B,Y          ; GET LENGTH AND START OF REPLACEMENT STRING
          STA  ,X             ; * SAVE STRING LENGTH AND START IN
          STY  2,X            ; * TARGET DESCRIPTOR LOCATION
LAFCE     RTS

LAFCF     FCC  "?REDO"        ; ?REDO MESSAGE
          FCB  CR,$00

LAFD6
LAFDC     JMP  LAC46          ; JMP TO ERROR HANDLER
LAFDF     LDA  INPFLG         ; = GET THE INPUT FLAG AND BRANCH
          BEQ  LAFEA          ; = IF 'INPUT'
          LDX  DATTXT         ; * GET LINE NUMBER WHERE THE ERROR OCCURRED
          STX  CURLIN         ; * AND USE IT AS THE CURRENT LINE NUMBER
          JMP  LB277          ; 'SYNTAX ERROR'
LAFEA     LDX  #LAFCF-1       ; * POINT X TO '?REDO' AND PRINT
          JSR  LB99C          ; * IT ON THE SCREEN
          LDX  TINPTR         ; = GET THE SAVED ABSOLUTE ADDRESS OF
          STX  CHARAD         ; = INPUT POINTER AND RESTORE IT
          RTS
*
* INPUT
INPUT     LDB  #11*2          ; 'ID' ERROR
          LDX  CURLIN         ; GET CURRENT LINE NUMBER
          LEAX 1,X            ; ADD ONE
          BEQ  LAFDC          ; 'ID' ERROR BRANCH IF DIRECT MODE
          BSR  LB00F          ; GET SOME INPUT DATA - WAS LB002
          RTS
LB00F     CMPA #'"            ; CHECK FOR PROMPT STRING DELIMITER
          BNE  LB01E          ; BRANCH IF NO PROMPT STRING
          JSR  LB244          ; PUT PROMPT STRING ON STRING STACK
          LDB  #';            ; *
          JSR  LB26F          ; * DO A SYNTAX CHECK FOR SEMICOLON
          JSR  LB99F          ; PRINT MESSAGE TO CONSOLE OUT
LB01E     LDX  #LINBUF        ; POINT TO BASIC'S LINE BUFFER
          CLR  ,X             ; CLEAR 1ST BYTE - FLAG TO INDICATE NO DATA
*              ; IN LINE BUFFER
          BSR  LB02F          ; INPUT A STRING TO LINE BUFFER
          LDB  #',            ; * INSERT A COMMA AT THE END
          STB  ,X             ; * OF THE LINE INPUT BUFFER
          BRA  LB049
* FILL BASIC'S LINE INPUT BUFFER CONSOLE IN
LB02F     JSR  LB9AF          ; SEND A "?" TO CONSOLE OUT
          JSR  LB9AC          ; SEND A 'SPACE' TO CONSOLE OUT
LB035     JSR  LA390          ; GO READ IN A BASIC LINE
          BCC  LB03F          ; BRANCH IF ENTER KEY ENDED ENTRY
          LEAS 4,S            ; PURGE TWO RETURN ADDRESSES OFF THE STACK
          JMP  LAE11          ; GO DO A 'STOP' IF BREAK KEY ENDED LINE ENTRY
LB03F     LDB  #2*23          ; 'INPUT PAST END OF FILE' ERROR
          RTS
*
* READ
READ      LDX  DATPTR         ; GET 'READ' START ADDRESS
          FCB  SKP1LD         ; SKIP ONE BYTE - LDA #*$4F
LB049     CLRA                ; 'INPUT' ENTRY POINT: INPUT FLAG = 0
          STA  INPFLG         ; SET INPUT FLAG; 0 = INPUT: <> 0 = READ
          STX  DATTMP         ; SAVE 'READ' START ADDRESS/'INPUT' BUFFER START
LB04E     JSR  LB357          ; EVALUATE A VARIABLE
          STX  VARDES         ; SAVE DESCRIPTOR ADDRESS
          LDX  CHARAD         ; * GET BASIC'S INPUT POINTER
          STX  BINVAL         ; * AND SAVE IT
          LDX  DATTMP         ; GET 'READ' ADDRESS START/'INPUT' BUFFER POINTER
          LDA  ,X             ; GET A CHARACTER FROM THE BASIC PROGRAM
          BNE  LB069          ; BRANCH IF NOT END OF LINE
          LDA  INPFLG         ; * CHECK INPUT FLAG AND BRANCH
          BNE  LB0B9          ; * IF LOOKING FOR DATA (READ)
* NO DATA IN 'INPUT' LINE BUFFER AND/OR INPUT
* NOT COMING FROM SCREEN
          JSR  LB9AF          ; SEND A '?' TO CONSOLE OUT
          BSR  LB02F          ; FILL INPUT BUFFER FROM CONSOLE IN
LB069     STX  CHARAD         ; RESET BASIC'S INPUT POINTER
          JSR  GETNCH         ; GET A CHARACTER FROM BASIC
          LDB  VALTYP         ; * CHECK VARIABLE TYPE AND
          BEQ  LB098          ; * BRANCH IF NUMERIC
* READ/INPUT A STRING VARIABLE
          LDX  CHARAD         ; LOAD X WITH CURRENT BASIC INPUT POINTER
          STA  CHARAC         ; SAVE CURRENT INPUT CHARACTER
          CMPA #'"            ; CHECK FOR STRING DELIMITER
          BEQ  LB08B          ; BRANCH IF STRING DELIMITER
          LEAX -1,X           ; BACK UP POINTER
          CLRA                ; * ZERO = END OF LINE CHARACTER
          STA  CHARAC         ; * SAVE AS TERMINATOR
          JSR  LA35F          ; SET UP PRINT PARAMETERS
          LDA  #':            ; END OF SUBLINE CHARACTER
          STA  CHARAC         ; SAVE AS TERMINATOR I
          LDA  #',            ; COMMA
LB08B     STA  ENDCHR         ; SAVE AS TERMINATOR 2
          JSR  LB51E          ; STRIP A STRING FROM THE INPUT BUFFER
          JSR  LB249          ; MOVE INPUT POINTER TO END OF STRING
          JSR  LAFA4          ; PUT A STRING INTO THE STRING SPACE IF NECESSARY
          BRA  LB09E          ; CHECK FOR ANOTHER DATA ITEM
* SAVE A NUMERIC VALUE IN A READ OR INPUT DATA ITEM
LB098     JSR  LBD12          ; CONVERT AN ASCII STRING TO FP NUMBER
          JSR  LBC33          ; PACK FPA0 AND STORE IT IN ADDRESS IN VARDES -
*                             ; INPUT OR READ DATA ITEM
LB09E     JSR  GETCCH         ; GET CURRENT INPUT CHARACTER
          BEQ  LB0A8          ; BRANCH IF END OF LINE
          CMPA #',            ; CHECK FOR A COMMA
          LBNE LAFD6          ; BAD FILE DATA' ERROR OR RETRY
LB0A8     LDX  CHARAD         ; * GET CURRENT INPUT
          STX  DATTMP         ; * POINTER (USED AS A DATA POINTER) AND SAVE IT
          LDX  BINVAL         ; * RESET INPUT POINTER TO INPUT OR
          STX  CHARAD         ; * READ STATEMENT
          JSR  GETCCH         ; GET CURRENT CHARACTER FROM BASIC
          BEQ  LB0D5          ; BRANCH IF END OF LINE - EXIT COMMAND
          JSR  LB26D          ; SYNTAX CHECK FOR COMMA
          BRA  LB04E          ; GET ANOTHER INPUT OR READ ITEM
* SEARCH FROM ADDRESS IN X FOR
* 1ST OCCURENCE OF THE TOKEN FOR DATA
LB0B9     STX  CHARAD         ; RESET BASIC'S INPUT POINTER
          JSR  LAEE8          ; SEARCH FOR END OF CURRENT LINE OR SUBLINE
          LEAX 1,X            ; MOVE X ONE PAST END OF LINE
          TSTA                ; CHECK FOR END OF LINE
          BNE  LB0CD          ; BRANCH IF END OF SUBLINE
          LDB  #2*3           ; 'OUT OF DATA' ERROR
          LDU  ,X++           ; GET NEXT 2 CHARACTERS
          BEQ  LB10A          ; 'OD' ERROR IF END OF PROGRAM
          LDD  ,X++           ; GET BASIC LINE NUMBER AND
          STD  DATTXT         ; SAVE IT IN DATTXT
LB0CD     LDA  ,X             ; GET AN INPUT CHARACTER
          CMPA #TOK_DATA      ; DATA TOKEN?
          BNE  LB0B9          ; NO - KEEP LOOKING
          BRA  LB069          ; YES
* EXIT READ AND INPUT COMMANDS
LB0D5     LDX  DATTMP         ; GET DATA POINTER
          LDB  INPFLG         ; * CHECK INPUT FLAG
          LBNE LADE8          ; * SAVE NEW DATA POINTER IF READ
          LDA  ,X             ; = CHECK NEXT CHARACTER IN 'INPUT' BUFFER
          BEQ  LB0E7          ; =
          LDX  #LB0E8-1       ; POINT X TO '?EXTRA IGNORED'
          JMP  LB99C          ; PRINT THE MESSAGE
LB0E7     RTS

LB0E8     FCC  "?EXTRA IGNORED" ; ?EXTRA IGNORED MESSAGE


          FCB  CR,$00

* NEXT
NEXT      BNE  LB0FE          ; BRANCH IF ARGUMENT GIVEN
          LDX  ZERO           ; X = 0: DEFAULT FOR NO ARGUMENT
          BRA  LB101
LB0FE     JSR  LB357          ; EVALUATE AN ALPHA EXPRESSION
LB101     STX  VARDES         ; SAVE VARIABLE DESCRIPTOR POINTER
          JSR  LABF9          ; GO SCAN FOR 'FOR/NEXT' DATA ON STACK
          BEQ  LB10C          ; BRANCH IF DATA FOUND
          LDB  #0             ; 'NEXT WITHOUT FOR' ERROR (SHOULD BE CLRB)
LB10A     BRA  LB153          ; PROCESS ERROR
LB10C     TFR  X,S            ; POINT S TO START OF 'FOR/NEXT' DATA
          LEAX 3,X            ; POINT X TO FP VALUE OF STEP
          JSR  LBC14          ; COPY A FP NUMBER FROM (X) TO FPA0
          LDA  8,S            ; GET THE DIRECTION OF STEP
          STA  FP0SGN         ; SAVE IT AS THE SIGN OF FPA0
          LDX  VARDES         ; POINT (X) TO INDEX VARIABLE DESCRIPTOR
          JSR  LB9C2          ; ADD (X) TO FPA0 (STEP TO INDEX)
          JSR  LBC33          ; PACK FPA0 AND STORE IT IN ADDRESS
*                             ; CONTAINED IN VARDES
          LEAX 9,S            ; POINT (X) TO TERMINAL VALUE OF INDEX
          JSR  LBC96          ; COMPARE CURRENT INDEX VALUE TO TERMINAL VALUE OF INDEX
          SUBB 8,S            ; ACCB = 0 IF TERMINAL VALUE=CURRENT VALUE AND STEP=0 OR IF
*                             ; STEP IS POSITIVE AND CURRENT VALUE>TERMINAL VALUE OR
*                             ; STEP IS NEGATIVE AND CURRENT VALUE<TERMINAL VALUE
          BEQ  LB134          ; BRANCH IF 'FOR/NEXT' LOOP DONE
          LDX  14,S           ; * GET LINE NUMBER AND
          STX  CURLIN         ; * BASIC POINTER OF
          LDX  16,S           ; * STATEMENT FOLLOWING THE
          STX  CHARAD         ; * PROPER FOR STATEMENT
LB131     JMP  LAD9E          ; JUMP BACK TO COMMAND INTEPR. LOOP
LB134     LEAS 18,S           ; PULL THE 'FOR-NEXT' DATA OFF THE STACK
          JSR  GETCCH         ; GET CURRENT INPUT CHARACTER
          CMPA #',            ; CHECK FOR ANOTHER ARGUMENT
          BNE  LB131          ; RETURN IF NONE
          JSR  GETNCH         ; GET NEXT CHARACTER FROM BASIC
          BSR  LB0FE          ; BSR SIMULATES A CALL TO 'NEXT' FROM COMMAND LOOP


LB141     BSR  LB156          ; EVALUATE EXPRESSION AND DO A TYPE CHECK FOR NUMERIC
LB143     ANDCC #$FE          ; CLEAR CARRY FLAG
LB145     FCB  $7D            ; OP CODE OF TST $1A01 - SKIP TWO BYTES (DO
*              ; NOT CHANGE CARRY FLAG)
LB146     ORCC #1             ; SET CARRY

* STRING TYPE MODE CHECK - IF ENTERED AT LB146 THEN VALTYP PLUS IS 'TM' ERROR
* NUMERIC TYPE MODE CHECK - IF ENTERED AT LB143 THEN VALTYP MINUS IS 'TM' ERROR
* IF ENTERED AT LB148, A TYPE CHECK IS DONE ON VALTYP
* IF ENTERED WITH CARRY SET, THEN 'TM' ERROR IF NUMERIC
* IF ENTERED WITH CARRY CLEAR, THEN 'TM' ERROR IF STRING.
LB148     TST  VALTYP         ; TEST TYPE FLAG; DO NOT CHANGE CARRY
          BCS  LB14F          ; BRANCH IF STRING
          BPL  LB0E7          ; RETURN ON PLUS
          FCB  SKP2           ; SKIP 2 BYTES - 'TM' ERROR
LB14F     BMI  LB0E7          ; RETURN ON MINUS
          LDB  #12*2          ; 'TYPE M1SMATCH' ERROR
LB153     JMP  LAC46          ; PROCESS ERROR
* EVALUATE EXPRESSION
LB156     BSR  LB1C6          ; BACK UP INPUT POINTER
LB158     CLRA                ; END OF OPERATION PRECEDENCE FLAG
          FCB  SKP2           ; SKIP TWO BYTES
LB15A     PSHS B              ; SAVE FLAG (RELATIONAL OPERATOR FLAG)
          PSHS A              ; SAVE FLAG (PRECEDENCE FLAG)
          LDB  #1             ; *
          JSR  LAC33          ; * SEE IF ROOM IN FREE RAM FOR (B) WORDS
          JSR  LB223          ; GO EVALUATE AN EXPRESSION
          CLR  TRELFL         ; RESET RELATIONAL OPERATOR FLAG
LB168     JSR  GETCCH         ; GET CURRENT INPUT CHARACTER
* CHECK FOR RELATIONAL OPERATORS
LB16A     SUBA #TOK_GREATER   ; TOKEN FOR >
          BCS  LB181          ; BRANCH IF LESS THAN RELATIONAL OPERATORS
          CMPA #3             ; *
          BCC  LB181          ; * BRANCH IF GREATER THAN RELATIONAL OPERATORS
          CMPA #1             ; SET CARRY IF '>'
          ROLA                ; CARRY TO BIT 0
          EORA TRELFL         ; * CARRY SET IF
          CMPA TRELFL         ; * TRELFL = ACCA
          BCS  LB1DF          ; BRANCH IF SYNTAX ERROR : == << OR >>
          STA  TRELFL         ; BIT 0: >, BIT 1 =, BIT 2: <
          JSR  GETNCH         ; GET AN INPUT CHARACTER
          BRA  LB16A          ; CHECK FOR ANOTHER RELATIONAL OPERATOR
*
LB181     LDB  TRELFL         ; GET RELATIONAL OPERATOR FLAG
          BNE  LB1B8          ; BRANCH IF RELATIONAL COMPARISON
          LBCC LB1F4          ; BRANCH IF > RELATIONAL OPERATOR
          ADDA #7             ; SEVEN ARITHMETIC/LOGICAL OPERATORS
          BCC  LB1F4          ; BRANCH IF NOT ARITHMETIC/LOGICAL OPERATOR
          ADCA VALTYP         ; ADD CARRY, NUMERIC FLAG AND MODIFIED TOKEN NUMBER
          LBEQ LB60F          ; BRANCH IF VALTYP = FF, AND ACCA = '+' TOKEN -
*                             ; CONCATENATE TWO STRINGS
          ADCA #-1            ; RESTORE ARITHMETIC/LOGICAL OPERATOR NUMBER
          PSHS A              ; * STORE OPERATOR NUMBER ON STACK; MULTIPLY IT BY 2
          ASLA                ; * THEN ADD THE STORED STACK DATA = MULTIPLY
          ADDA ,S+            ; * X 3; 3 BYTE/TABLE ENTRY
          LDX  #LAA51         ; JUMP TABLE FOR ARITHMETIC & LOGICAL OPERATORS
          LEAX A,X            ; POINT X TO PROPER TABLE
LB19F     PULS A              ; GET PRECEDENCE FLAG FROM STACK
          CMPA ,X             ; COMPARE TO CURRENT OPERATOR
          BCC  LB1FA          ; BRANCH IF STACK OPERATOR > CURRENT OPERATOR
          BSR  LB143          ; 'TM' ERROR IF VARIABLE TYPE = STRING

* OPERATION BEING PROCESSED IS OF HIGHER PRECEDENCE THAN THE PREVIOUS OPERATION.
LB1A7     PSHS A              ; SAVE PRECEDENCE FLAG
          BSR  LB1D4          ; PUSH OPERATOR ROUTINE ADDRESS AND FPA0 ONTO STACK
          LDX  RELPTR         ; GET POINTER TO ARITHMETIC/LOGICAL TABLE ENTRY FOR
*                             ; LAST CALCULATED OPERATION
          PULS A              ; GET PRECEDENCE FLAG OF PREVIOUS OPERATION
          BNE  LB1CE          ; BRANCH IF NOT END OF OPERATION
          TSTA                ; CHECK TYPE OF PRECEDENCE FLAG
          LBEQ LB220          ; BRANCH IF END OF EXPRESSION OR SUB-EXPRESSION
          BRA  LB203          ; EVALUATE AN OPERATION

LB1B8     ASL  VALTYP         ; BIT 7 OF TYPE FLAG TO CARRY
          ROLB                ; SHIFT RELATIONAL FLAG LEFT - VALTYP TO BIT 0
          BSR  LB1C6          ; MOVE THE INPUT POINTER BACK ONE
          LDX  #LB1CB         ; POINT X TO RELATIONAL COMPARISON JUMP TABLE
          STB  TRELFL         ; SAVE RELATIONAL COMPARISON DATA
          CLR  VALTYP         ; SET VARIABLE TYPE TO NUMERIC
          BRA  LB19F          ; PERFORM OPERATION OR SAVE ON STACK

LB1C6     LDX  CHARAD         ; * GET BASIC'S INPUT POINTER AND
          JMP  LAEBB          ; * MOVE IT BACK ONE
* RELATIONAL COMPARISON JUMP TABLE
LB1CB     FCB  $64            ; RELATIONAL COMPARISON FLAG
LB1CC     FDB  LB2F4          ; JUMP ADDRESS

LB1CE     CMPA ,X             ; COMPARE PRECEDENCE OF LAST DONE OPERATION TO
*         NEXT TO BE DONE OPERATION
          BCC  LB203          ; EVALUATE OPERATION IF LOWER PRECEDENCE
          BRA  LB1A7          ; PUSH OPERATION DATA ON STACK IF HIGHER PRECEDENCE

* PUSH OPERATOR EVALUATION ADDRESS AND FPA0 ONTO STACK AND EVALUATE ANOTHER EXPR
LB1D4     LDD  1,X            ; GET ADDRESS OF OPERATOR ROUTINE
          PSHS B,A            ; SAVE IT ON THE STACK
          BSR  LB1E2          ; PUSH FPA0 ONTO STACK
          LDB  TRELFL         ; GET BACK RELATIONAL OPERATOR FLAG
          LBRA LB15A          ; EVALUATE ANOTHER EXPRESSION
LB1DF     JMP  LB277          ; 'SYNTAX ERROR'
* PUSH FPA0 ONTO THE STACK. ,S   = EXPONENT
* 1-2,S =HIGH ORDER MANTISSA 3-4,S = LOW ORDER MANTISSA
* 5,S = SIGN RETURN WITH PRECEDENCE CODE IN ACCA
LB1E2     LDB  FP0SGN         ; GET SIGN OF FPA0 MANTISSA
          LDA  ,X             ; GET PRECEDENCE CODE TO ACCA
LB1E6     PULS Y              ; GET RETURN ADDRESS FROM STACK & PUT IT IN Y
          PSHS B              ; SAVE ACCB ON STACK
LB1EA     LDB  FP0EXP         ; * PUSH FPA0 ONTO THE STACK
          LDX  FPA0           ; *
          LDU  FPA0+2         ; *
          PSHS U,X,B          ; *
          JMP  ,Y             ; JUMP TO ADDRESS IN Y

* BRANCH HERE IF NON-OPERATOR CHARACTER FOUND - USUALLY ')' OR END OF LINE
LB1F4     LDX  ZERO           ; POINT X TO DUMMY VALUE (ZERO)
          LDA  ,S+            ; GET PRECEDENCE FLAG FROM STACK
          BEQ  LB220          ; BRANCH IF END OF EXPRESSION
LB1FA     CMPA #$64           ; * CHECK FOR RELATIONAL COMPARISON FLAG
          BEQ  LB201          ; * AND BRANCH IF RELATIONAL COMPARISON
          JSR  LB143          ; 'TM' ERROR IF VARIABLE TYPE = STRING
LB201     STX  RELPTR         ; SAVE POINTER TO OPERATOR ROUTINE
LB203     PULS B              ; GET RELATIONAL OPERATOR FLAG FROM STACK
          CMPA #$5A           ; CHECK FOR 'NOT' OPERATOR
          BEQ  LB222          ; RETURN IF 'NOT' - NO RELATIONAL COMPARISON
          CMPA #$7D           ; CHECK FOR NEGATION (UNARY) FLAG
          BEQ  LB222          ; RETURN IF NEGATION - NO RELATIONAL COMPARISON

* EVALUATE AN OPERATION. EIGHT BYTES WILL BE STORED ON STACK, FIRST SIX BYTES
* ARE A TEMPORARY FLOATING POINT RESULT THEN THE ADDRESS OF ROUTINE WHICH
* WILL EVALUATE THE OPERATION. THE RTS AT END OF ROUTINE WILL VECTOR
* TO EVALUATING ROUTINE.
          LSRB                ; = ROTATE VALTYP BIT INTO CARRY
          STB  RELFLG         ; = FLAG AND SAVE NEW RELFLG
          PULS A,X,U          ; * PULL A FP VALUE OFF OF THE STACK
          STA  FP1EXP         ; * AND SAVE IT IN FPA1
          STX  FPA1           ; *
          STU  FPA1+2         ; *
          PULS B              ; = GET MANTISSA SIGN AND
          STB  FP1SGN         ; = SAVE IT IN FPA1
          EORB FP0SGN         ; EOR IT WITH FPA1 MANTISSA SIGN
          STB  RESSGN         ; SAVE IT IN RESULT SIGN BYTE
LB220     LDB  FP0EXP         ; GET EXPONENT OF FPA0
LB222     RTS

LB223     JSR  XVEC15         ; CALL EXTENDED BASIC ADD-IN
          CLR  VALTYP         ; INITIALIZE TYPE FLAG TO NUMERIC
          JSR  GETNCH         ; GET AN INPUT CHAR
          BCC  LB22F          ; BRANCH IF NOT NUMERIC
LB22C     JMP  LBD12          ; CONVERT ASCII STRING TO FLOATING POINT -
*         RETURN RESULT IN FPA0
* PROCESS A NON NUMERIC FIRST CHARACTER
LB22F     JSR  LB3A2          ; SET CARRY IF NOT ALPHA
          BCC  LB284          ; BRANCH IF ALPHA CHARACTER
          CMPA #'.            ; IS IT '.' (DECIMAL POINT)?
          BEQ  LB22C          ; CONVERT ASCII STRING TO FLOATING POINT
          CMPA #TOK_MINUS     ; MINUS TOKEN
          BEQ  LB27C          ; YES - GO PROCESS THE MINUS OPERATOR
          CMPA #TOK_PLUS      ; PLUS TOKEN
          BEQ  LB223          ; YES - GET ANOTHER CHARACTER
          CMPA #'"            ; STRING DELIMITER?
          BNE  LB24E          ; NO
LB244     LDX  CHARAD         ; CURRENT BASIC POINTER TO X
          JSR  LB518          ; SAVE STRING ON STRING STACK
LB249     LDX  COEFPT         ; * GET ADDRESS OF END OF STRING AND
          STX  CHARAD         ; * PUT BASIC'S INPUT POINTER THERE
          RTS
LB24E     CMPA #TOK_NOT       ; NOT TOKEN?
          BNE  LB25F          ; NO
* PROCESS THE NOT OPERATOR
          LDA  #$5A           ; 'NOT' PRECEDENCE FLAG
          JSR  LB15A          ; PROCESS OPERATION FOLLOWING 'NOT'
          JSR  INTCNV         ; CONVERT FPA0 TO INTEGER IN ACCD
          COMA                ; * 'NOT' THE INTEGER
          COMB                ; *
          JMP  GIVABF         ; CONVERT ACCD TO FLOATING POINT (FPA0)
LB25F     INCA                ; CHECK FOR TOKENS PRECEEDED BY $FF
          BEQ  LB290          ; IT WAS PRECEEDED BY $FF
LB262     BSR  LB26A          ; SYNTAX CHECK FOR A '('
          JSR  LB156          ; EVALUATE EXPRESSIONS WITHIN PARENTHESES AT
*         HIGHEST PRECEDENCE
LB267     LDB  #')            ; SYNTAX CHECK FOR ')'
          FCB  SKP2           ; SKIP 2 BYTES
LB26A     LDB  #'(            ; SYNTAX CHECK FOR '('
          FCB  SKP2           ; SKIP 2 BYTES
LB26D     LDB  #',            ; SYNTAX CHECK FOR COMMA
LB26F     CMPB [CHARAD]       ; * COMPARE ACCB TO CURRENT INPUT
          BNE  LB277          ; * CHARACTER - SYNTAX ERROR IF NO MATCH
          JMP  GETNCH         ; GET A CHARACTER FROM BASIC
LB277     LDB  #2*1           ; SYNTAX ERROR
          JMP  LAC46          ; JUMP TO ERROR HANDLER

* PROCESS THE MINUS (UNARY) OPERATOR
LB27C     LDA  #$7D           ; MINUS (UNARY) PRECEDENCE FLAG
          JSR  LB15A          ; PROCESS OPERATION FOLLOWING 'UNARY' NEGATION
          JMP  LBEE9          ; CHANGE SIGN OF FPA0 MANTISSA

* EVALUATE ALPHA EXPRESSION
LB284     JSR  LB357          ; FIND THE DESCRIPTOR ADDRESS OF A VARIABLE
LB287     STX  FPA0+2         ; SAVE DESCRIPTOR ADDRESS IN FPA0
          LDA  VALTYP         ; TEST VARIABLE TYPE
          BNE  LB222          ; RETURN IF STRING
          JMP  LBC14          ; COPY A FP NUMBER FROM (X) TO FPA0

* EVALUATING A SECONDARY TOKEN
LB290     JSR  GETNCH         ; GET AN INPUT CHARACTER (SECONDARY TOKEN)
          TFR  A,B            ; SAVE IT IN ACCB
          ASLB                ; X2 & BET RID OF BIT 7
          JSR  GETNCH         ; GET ANOTHER INPUT CHARACTER
          CMPB #NUM_SEC_FNS-1*2 ; 29 SECONDARY FUNCTIONS - 1
          BLS  LB29F          ; BRANCH IF COLOR BASIC TOKEN
          JMP  LB277          ; SYNTAX ERROR
LB29F     PSHS B              ; SAVE TOKEN OFFSET ON STACK
          CMPB #TOK_LEFT-$80*2 ; CHECK FOR TOKEN WITH AN ARGUMENT
          BCS  LB2C7          ; DO SECONDARIES STRING$ OR LESS
          CMPB #TOK_INKEY-$80*2 ; *
          BCC  LB2C9          ; * DO SECONDARIES $92 (INKEY$) OR >
          BSR  LB26A          ; SYNTAX CHECK FOR A '('
          LDA  ,S             ; GET TOKEN NUMBER
* DO SECONDARIES (LEFT$, RIGHT$, MID$)
          JSR  LB156          ; EVALUATE FIRST STRING IN ARGUMENT
          BSR  LB26D          ; SYNTAX CHECK FOR A COMMA
          JSR  LB146          ; 'TM' ERROR IF NUMERIC VARiABLE
          PULS A              ; GET TOKEN OFFSET FROM STACK
          LDU  FPA0+2         ; POINT U TO STRING DESCRIPTOR
          PSHS U,A            ; SAVE TOKEN OFFSET AND DESCRIPTOR ADDRESS
          JSR  LB70B          ; EVALUATE FIRST NUMERIC ARGUMENT
          PULS A              ; GET TOKEN OFFSET FROM STACK
          PSHS B,A            ; SAVE TOKEN OFFSET AND NUMERIC ARGUMENT
          FCB  $8E            ; OP CODE OF LDX# - SKlP 2 BYTES
LB2C7     BSR  LB262          ; SYNTAX CHECK FOR A '('
LB2C9     PULS B              ; GET TOKEN OFFSET
          LDX  COMVEC+8       ; GET SECONDARY FUNCTION JUMP TABLE ADDRESS
LB2CE     ABX                 ; ADD IN COMMAND OFFSET
*
* HERE IS WHERE WE BRANCH TO A SECONDARY FUNCTION
          JSR  [,X]           ; GO DO AN SECONDARY FUNCTION
          JMP  LB143          ; 'TM' ERROR IF VARIABLE TYPE = STRING

* LOGICAL OPERATOR 'OR' JUMPS HERE
LB2D4     FCB  SKP1LD         ; SKIP ONE BYTE - 'OR' FLAG = $4F

* LOGICAL OPERATOR 'AND' JUMPS HERE
LB2D5     CLRA                ; AND FLAG = 0
          STA  TMPLOC         ; AND/OR FLAG
          JSR  INTCNV         ; CONVERT FPA0 INTO AN INTEGER IN ACCD
          STD  CHARAC         ; TEMP SAVE ACCD
          JSR  LBC4A          ; MOVE FPA1 TO FPA0
          JSR  INTCNV         ; CONVERT FPA0 INTO AN INTEGER IN ACCD
          TST  TMPLOC         ; CHECK AND/OR FLAG
          BNE  LB2ED          ; BRANCH IF OR
          ANDA CHARAC         ; * 'AND' ACCD WITH FPA0 INTEGER
          ANDB ENDCHR         ; * STORED IN ENDCHR
          BRA  LB2F1          ; CONVERT TO FP
LB2ED     ORA  CHARAC         ; * 'OR' ACCD WITH FPA0 INTEGER
          ORB  ENDCHR         ; * STORED IN CHARAC
LB2F1     JMP  GIVABF         ; CONVERT THE VALUE IN ACCD INTO A FP NUMBER

* RELATIONAL COMPARISON PROCESS HANDLER
LB2F4     JSR  LB148          ; 'TM' ERROR IF TYPE MISMATCH
          BNE  LB309          ; BRANCH IF STRING VARIABLE
          LDA  FP1SGN         ; * 'PACK' THE MANTISSA
          ORA  #$7F           ; * SIGN OF FPA1 INTO
          ANDA FPA1           ; * BIT 7 OF THE
          STA  FPA1           ; * MANTISSA MS BYTE
          LDX  #FP1EXP        ; POINT X TO FPA1
          JSR  LBC96          ; COMPARE FPA0 TO FPA1
          BRA  LB33F          ; CHECK TRUTH OF RELATIONAL COMPARISON

* RELATIONAL COMPARISON OF STRINGS
LB309     CLR  VALTYP         ; SET VARIABLE TYPE TO NUMERIC
          DEC  TRELFL         ; REMOVE STRING TYPE FLAG (BIT0=1 FOR STRINGS) FROM THE
*                             ; DESIRED RELATIONAL COMPARISON DATA
          JSR  LB657          ; GET LENGTH AND ADDRESS OF STRING WHOSE
*                             ; DESCRIPTOR ADDRESS IS IN THE BOTTOM OF FPA0
          STB  STRDES         ; * SAVE LENGTH AND ADDRESS IN TEMPORARY
          STX  STRDES+2       ; * DESCRIPTOR (STRING B)
          LDX  FPA1+2         ; = RETURN LENGTH AND ADDRESS OF STRING
          JSR  LB659          ; = WHOSE DESCRIPTOR ADDRESS IS STORED IN FPA1+2
          LDA  STRDES         ; LOAD ACCA WITH LENGTH OF STRING B
          PSHS B              ; SAVE LENGTH A ON STACK
          SUBA ,S+            ; SUBTRACT LENGTH A FROM LENGTH B
          BEQ  LB328          ; BRANCH IF STRINGS OF EQUAL LENGTH
          LDA  #1             ; ; TRUE FLAG
          BCC  LB328          ; TRUE IF LENGTH B > LENGTH A
          LDB  STRDES         ; LOAD ACCB WITH LENGTH B
          NEGA                ; SET FLAG = FALSE (1FF)
LB328     STA  FP0SGN         ; SAVE TRUE/FALSE FLAG
          LDU  STRDES+2       ; POINT U TO START OF STRING
          INCB                ; COMPENSATE FOR THE DECB BELOW
* ENTER WITH ACCB CONTAINING LENGTH OF SHORTER STRING
LB32D     DECB                ; DECREMENT SHORTER STRING LENGTH
          BNE  LB334          ; BRANCH IF ALL OF STRING NOT COMPARED
          LDB  FP0SGN         ; GET TRUE/FALSE FLAB
          BRA  LB33F          ; CHECK TRUTH OF RELATIONAL COMPARISON
LB334     LDA  ,X+            ; GET A BYTE FROM STRING A
          CMPA ,U+            ; COMPARE TO STRING B
          BEQ  LB32D          ; CHECK ANOTHER CHARACTER IF =
          LDB  #$FF           ; FALSE FLAG IF STRING A > B
          BCC  LB33F          ; BRANCH IF STRING A > STRING B
          NEGB                ; SET FLAG = TRUE

* DETERMINE TRUTH OF COMPARISON - RETURN RESULT IN FPA0
LB33F     ADDB #1             ; CONVERT $FF,0,1 TO 0,1,2
          ROLB                ; NOW IT'S 1,2,4 FOR > = <
          ANDB RELFLG         ; 'AND' THE ACTUAL COMPARISON WITH THE DESIRED -
COMPARISON
          BEQ  LB348          ; BRANCH IF FALSE (NO MATCHING BITS)
          LDB  #$FF           ; TRUE FLAG
LB348     JMP  LBC7C          ; CONVERT ACCB INTO FP NUMBER IN FPA0

* DIM
LB34B     JSR  LB26D          ; SYNTAX CHECK FOR COMMA
DIM       LDB  #1             ; DIMENSION FLAG
          BSR  LB35A          ; SAVE ARRAY SPACE FOR THIS VARIABLE
          JSR  GETCCH         ; GET CURRENT INPUT CHARACTER
          BNE  LB34B          ; KEEP DIMENSIONING IF NOT END OF LINE
          RTS
* EVALUATE A VARIABLE - RETURN X AND
* VARPTR POINTING TO VARIABLE DESCRIPTOR
* EACH VARIABLE REQUIRES 7 BYTES - THE FIRST TWO
* BYTES ARE THE VARIABLE NAME AND THE NEXT 5
* BYTES ARE THE DESCRIPTOR. IF BIT 7 OF THE
* FIRST BYTE OF VARlABLE NAME IS SET, THE
* VARIABLE IS A DEF FN VARIABLE. IF BIT 7 OF
* THE SECOND BYTE OF VARIABLE NAME IS SET, THE
* VARIABLE IS A STRING, OTHERWISE THE VARIABLE
* IS NUMERIC.
* IF THE VARIABLE IS NOT FOUND, A ZERO VARIABLE IS
* INSERTED INTO THE VARIABLE SPACE
LB357     CLRB                ; DIMENSION FLAG = 0; DO NOT SET UP AN ARRAY
          JSR  GETCCH         ; GET CURRENT INPUT CHARACTER
LB35A     STB  DIMFLG         ; SAVE ARRAY FLAG
* ENTRY POINT FOR DEF FN VARIABLE SEARCH
LB35C     STA  VARNAM         ; SAVE INPUT CHARACTER
          JSR  GETCCH         ; GET CURRENT INPUT CHARACTER
          BSR  LB3A2          ; SET CARRY IF NOT ALPHA
          LBCS LB277          ; SYNTAX ERROR IF NOT ALPHA
          CLRB                ; DEFAULT 2ND VARIABLE CHARACTER TO ZERO
          STB  VALTYP         ; SET VARIABLE TYPE TO NUMERIC
          JSR  GETNCH         ; GET ANOTHER CHARACTER FROM BASIC
          BCS  LB371          ; BRANCH IF NUMERIC (2ND CHARACTER IN
*                             ; VARIABLE MAY BE NUMERIC)
          BSR  LB3A2          ; SET CARRY IF NOT ALPHA
          BCS  LB37B          ; BRANCH IF NOT ALPHA
LB371     TFR  A,B            ; SAVE 2ND CHARACTER IN ACCB
* READ INPUT CHARACTERS UNTIL A NON ALPHA OR
* NON NUMERIC IS FOUND - IGNORE ALL CHARACTERS
* IN VARIABLE NAME AFTER THE 1ST TWO
LB373     JSR  GETNCH         ; GET AN INPUT CHARACTER
          BCS  LB373          ; BRANCH IF NUMERIC
          BSR  LB3A2          ; SET CARRY IF NOT ALPHA
          BCC  LB373          ; BRANCH IF ALPHA
LB37B     CMPA #'$            ; CHECK FOR A STRING VARIABLE
          BNE  LB385          ; BRANCH IF IT IS NOT A STRING
          COM  VALTYP         ; SET VARIABLE TYPE TO STRING
          ADDB #$80           ; SET BIT 7 OF 2ND CHARACTER (STRING)
          JSR  GETNCH         ; GET AN INPUT CHARACTER
LB385     STB  VARNAM+1       ; SAVE 2ND CHARACTER IN VARNAM+1
          ORA  ARYDIS         ; OR IN THE ARRAY DISABLE FLAG - IF = $80,
*              ; DON'T SEARCH FOR VARIABLES IN THE ARRAYS
          SUBA #'(            ; IS THIS AN ARRAY VARIABLE?
          LBEQ LB404          ; BRANCH IF IT IS
          CLR  ARYDIS         ; RESET THE ARRAY DISABLE FLAG
          LDX  VARTAB         ; POINT X TO THE START OF VARIABLES
          LDD  VARNAM         ; GET VARIABLE IN QUESTION
LB395     CMPX ARYTAB         ; COMPARE X TO THE END OF VARIABLES
          BEQ  LB3AB          ; BRANCH IF END OF VARIABLES
          CMPD ,X++           ; * COMPARE VARIABLE IN QUESTION TO CURRENT
          BEQ  LB3DC          ; * VARIABLE AND BRANCH IF MATCH
          LEAX 5,X            ; = MOVE POINTER TO NEXT VARIABLE AND
          BRA  LB395          ; = KEEP LOOKING

* SET CARRY IF NOT UPPER CASE ALPHA
LB3A2     CMPA #'A            ; * CARRY SET IF < 'A'
          BCS  LB3AA          ; *
          SUBA #'Z+1          ; =
*         SUBA #-('Z+1)       ; = CARRY CLEAR IF <= 'Z'
          FCB  $80,$A5
LB3AA     RTS
* PUT A NEW VARIABLE IN TABLE OF VARIABLES
LB3AB     LDX  #ZERO          ; POINT X TO ZERO LOCATION
          LDU  ,S             ; GET CURRENT RETURN ADDRESS
          CMPU #LB287         ; DID WE COME FROM 'EVALUATE ALPHA EXPR'?
          BEQ  LB3DE          ; YES - RETURN A ZERO VALUE
          LDD  ARYEND         ; * GET END OF ARRAYS ADDRESS AND
          STD  V43            ; * SAVE IT AT V43
          ADDD #7             ; = ADD 7 TO END OF ARRAYS (EACH
          STD  V41            ; = VARIABLE = 7 BYTES) AND SAVE AT V41
          LDX  ARYTAB         ; * GET END OF VARIABLES AND SAVE AT V47
          STX  V47            ; *
          JSR  LAC1E          ; MAKE A SEVEN BYTE SLOT FOR NEW VARIABLE AT
*         TOP  OF VARIABLES
          LDX  V41            ; = GET NEW END OF ARRAYS AND SAVE IT
          STX  ARYEND         ; =
          LDX  V45            ; * GET NEW END OF VARIABLES AND SAVE IT
          STX  ARYTAB         ; *
          LDX  V47            ; GET OLD END OF VARIABLES
          LDD  VARNAM         ; GET NEW VARIABLE NAME
          STD  ,X++           ; SAVE VARIABLE NAME
          CLRA                ; * ZERO OUT THE FP VALUE OF THE NUMERIC
          CLRB                ; * VARIABLE OR THE LENGTH AND ADDRESS
          STD  ,X             ; * OF A STRING VARIABLE
          STD  2,X            ; *
          STA  4,X            ; *
LB3DC     STX  VARPTR         ; STORE ADDRESS OF VARIABLE VALUE
LB3DE     RTS
*
LB3DF     FCB  $90,$80,$00,$00,$00 ; * FLOATING POINT -32768
*                             ; SMALLEST SIGNED TWO BYTE INTEGER
*
LB3E4     JSR  GETNCH         ; GET AN INPUT CHARACTER FROM BASIC
LB3E6     JSR  LB141          ; GO EVALUATE NUMERIC EXPRESSION
LB3E9     LDA  FP0SGN         ; GET FPA0 MANTISSA SIGN
          BMI  LB44A          ; 'FC' ERROR IF NEGATIVE NUMBER


INTCNV    JSR  LB143          ; 'TM' ERROR IF STRING VARIABLE
          LDA  FP0EXP         ; GET FPA0 EXPONENT
          CMPA #$90           ; * COMPARE TO 32768 - LARGEST INTEGER EXPONENT AND
          BCS  LB3FE          ; * BRANCH IF FPA0 < 32768
          LDX  #LB3DF         ; POINT X TO FP VALUE OF -32768
          JSR  LBC96          ; COMPARE -32768 TO FPA0
          BNE  LB44A          ; 'FC' ERROR IF NOT =
LB3FE     JSR  LBCC8          ; CONVERT FPA0 TO A TWO BYTE INTEGER
          LDD  FPA0+2         ; GET THE INTEGER
          RTS
* EVALUATE AN ARRAY VARIABLE
LB404     LDD  DIMFLG         ; GET ARRAY FLAG AND VARIABLE TYPE
          PSHS B,A            ; SAVE THEM ON STACK
          NOP                 ; DEAD SPACE CAUSED BY 1.2 REVISION
          CLRB                ; RESET DIMENSION COUNTER
LB40A     LDX  VARNAM         ; GET VARIABLE NAME
          PSHS X,B            ; SAVE VARIABLE NAME AND DIMENSION COUNTER
          BSR  LB3E4          ; EVALUATE EXPRESSION (DIMENSlON LENGTH)
          PULS B,X,Y          ; PULL OFF VARIABLE NAME, DIMENSlON COUNTER,
*                             ; ARRAY FLAG
          STX  VARNAM         ; SAVE VARIABLE NAME AND VARIABLE TYPE
          LDU  FPA0+2         ; GET DIMENSION LENGTH
          PSHS U,Y            ; SAVE DIMENSION LENGTH, ARRAY FLAG, VARIABLE TYPE
          INCB                ; INCREASE DIMENSION COUNTER
          JSR  GETCCH         ; GET CURRENT INPUT CHARACTER
          CMPA #',            ; CHECK FOR ANOTHER DIMENSION
          BEQ  LB40A          ; BRANCH IF MORE
          STB  TMPLOC         ; SAVE DIMENSION COUNTER
          JSR  LB267          ; SYNTAX CHECK FOR A ')'
          PULS A,B            ; * RESTORE VARIABLE TYPE AND ARRAY
          STD  DIMFLG         ; * FLAG - LEAVE DIMENSION LENGTH ON STACK
          LDX  ARYTAB         ; GET START OF ARRAYS
LB42A     CMPX ARYEND         ; COMPARE TO END OF ARRAYS
          BEQ  LB44F          ; BRANCH IF NO MATCH FOUND
          LDD  VARNAM         ; GET VARIABLE IN QUESTION
          CMPD ,X             ; COMPARE TO CURRENT VARIABLE
          BEQ  LB43B          ; BRANCH IF =
          LDD  2,X            ; GET OFFSET TO NEXT ARRAY VARIABLE
          LEAX D,X            ; ADD TO CURRENT POINTER
          BRA  LB42A          ; KEEP SEARCHING
LB43B     LDB  #2*9           ; 'REDIMENSIONED ARRAY' ERROR
          LDA  DIMFLG         ; * TEST ARRAY FLAG - IF <>0 YOU ARE TRYING
          BNE  LB44C          ; * TO REDIMENSION AN ARRAY
          LDB  TMPLOC         ; GET NUMBER OF DIMENSIONS IN ARRAY
          CMPB 4,X            ; COMPARE TO THIS ARRAYS DIMENSIONS
          BEQ  LB4A0          ; BRANCH IF =
LB447     LDB  #8*2           ; 'BAD SUBSCRIPT'
          FCB  SKP2           ; SKIP TWO BYTES
LB44A     LDB  #4*2           ; 'ILLEGAL FUNCTION CALL'
LB44C     JMP  LAC46          ; JUMP TO ERROR SERVICING ROUTINE

* INSERT A NEW ARRAY INTO ARRAY VARIABLES
* EACH SET OF ARRAY VARIABLES IS PRECEEDED BY A DE-
* SCRIPTOR BLOCK COMPOSED OF 5+2*N BYTES WHERE N IS THE
* NUMBER OF DIMENSIONS IN THE ARRAY. THE BLOCK IS DEFINED
* AS FOLLOWS: BYTES 0,1:VARIABLE'S NAME; 2,3:TOTAL LENGTH
* OF ARRAY ITEMS AND DESCRIPTOR BLOCK; 4:NUMBER OF DIMEN-
* ISIONS; 5,6:LENGTH OF DIMENSION 1; 7,8:LENGTH OF DIMEN-
* SION 2;... 4+N,5+N:LENGTH OF DIMENSION N.

LB44F     LDD  #5             ; * 5 BYTES/ARRAY ENTRY SAVE AT COEFPT
          STD  COEFPT         ; *
          LDD  VARNAM         ; = GET NAME OF ARRAY AND SAVE IN
          STD  ,X             ; = FIRST 2 BYTES OF DESCRIPTOR
          LDB  TMPLOC         ; GET NUMBER OF DIMENSIONS AND SAVE IN
          STB  4,X            ; * 5TH BYTE OF DESCRIPTOR
          JSR  LAC33          ; CHECK FOR ROOM FOR DESCRIPTOR IN FREE RAM
          STX  V41            ; TEMPORARILY SAVE DESCRIPTOR ADDRESS
LB461     LDB  #11            ; * DEFAULT DIMENSION VALUE:X(10)
          CLRA                ; *
          TST  DIMFLG         ; = CHECK ARRAY FLAG AND BRANCH IF
          BEQ  LB46D          ; = NOT DIMENSIONING AN ARRAY
          PULS A,B            ; GET DIMENSION LENGTH
          ADDD #1             ; ADD ONE (X(0) HAS A LENGTH OF ONE)
LB46D     STD  5,X            ; SAVE LENGTH OF ARRAY DIMENSION
          BSR  LB4CE          ; MULTIPLY ACCUM ARRAY SIZE NUMBER LENGTH
*                             ; OF NEW DIMENSION
          STD  COEFPT         ; TEMP STORE NEW CURRENT ACCUMULATED ARRAY SIZE
          LEAX 2,X            ; BUMP POINTER UP TWO
          DEC  TMPLOC         ; * DECREMENT DIMENSION COUNTER AND BRANCH IF
          BNE  LB461          ; * NOT DONE WITH ALL DIMENSIONS
          STX  TEMPTR         ; SAVE ADDRESS OF (END OF ARRAY DESCRIPTOR - 5)
          ADDD TEMPTR         ; ADD TOTAL SIZE OF NEW ARRAY
          LBCS LAC44          ; 'OM' ERROR IF > $FFFF
          TFR  D,X            ; SAVE END OF ARRAY IN X
          JSR  LAC37          ; MAKE SURE THERE IS ENOUGH FREE RAM FOR ARRAY
          SUBD #STKBUF-5      ; SUBTRACT OUT THE (STACK BUFFER - 5)
          STD  ARYEND         ; SAVE NEW END OF ARRAYS
          CLRA                ; ZERO = TERMINATOR BYTE
LB48C     LEAX -1,X           ; * STORE TWO TERMINATOR BYTES AT
          STA  5,X            ; * THE END OF THE ARRAY DESCRIPTOR
          CMPX TEMPTR         ; *
          BNE  LB48C          ; *
          LDX  V41            ; GET ADDRESS OF START OF DESCRIPTOR
          LDA  ARYEND         ; GET MSB OF END OF ARRAYS; LSB ALREADY THERE
          SUBD V41            ; SUBTRACT OUT ADDRESS OF START OF DESCRIPTOR
          STD  2,X            ; SAVE LENGTH OF (ARRAY AND DESCRIPTOR)
          LDA  DIMFLG         ; * GET ARRAY FLAG AND BRANCH
          BNE  LB4CD          ; * BACK IF DIMENSIONING
* CALCULATE POINTER TO CORRECT ELEMENT
LB4A0     LDB  4,X            ; GET THE NUMBER OF DIMENSIONS
          STB  TMPLOC         ; TEMPORARILY SAVE
          CLRA                ; * INITIALIZE POINTER
          CLRB                ; * TO ZERO
LB4A6     STD  COEFPT         ; SAVE ACCUMULATED POINTER
          PULS A,B            ; * PULL DIMENSION ARGUMENT OFF THE
          STD  FPA0+2         ; * STACK AND SAVE IT
          CMPD 5,X            ; COMPARE TO STORED 'DIM' ARGUMENT
          BCC  LB4EB          ; 'BS' ERROR IF > = "DIM" ARGUMENT
          LDU  COEFPT         ; * GET ACCUMULATED POINTER AND
          BEQ  LB4B9          ; * BRANCH IF 1ST DIMENSION
          BSR  LB4CE          ; = MULTIPLY ACCUMULATED POINTER AND DIMENSION
          ADDD FPA0+2         ; = LENGTH AND ADD TO CURRENT ARGUMENT
LB4B9     LEAX 2,X            ; MOVE POINTER TO NEXT DIMENSION
          DEC  TMPLOC         ; * DECREMENT DIMENSION COUNTER AND
          BNE  LB4A6          ; * BRANCH IF ANY DIMENSIONS LEFT
* MULTIPLY ACCD BY 5 - 5 BYTES/ARRAY VALUE
          STD  ,--S
          ASLB
          ROLA                ; TIMES 2
          ASLB
          ROLA                ; TIMES 4
          ADDD ,S++           ; TIMES 5
          LEAX D,X            ; ADD OFFSET TO START OF ARRAY
          LEAX 5,X            ; ADJUST POINTER FOR SIZE OF DESCRIPTOR
          STX  VARPTR         ; SAVE POINTER TO ARRAY VALUE
LB4CD     RTS
* MULTIPLY 2 BYTE NUMBER IN 5,X BY THE 2 BYTE NUMBER
* IN COEFPT. RETURN RESULT IN ACCD, BS ERROR IF > $FFFF
LB4CE     LDA  #16            ; 16 SHIFTS TO DO A MULTIPLY
          STA  V45            ; SHIFT COUNTER
          LDD  5,X            ; * GET SIZE OF DIMENSION
          STD  BOTSTK         ; * AND SAVE IT
          CLRA                ; * ZERO
          CLRB                ; * ACCD
LB4D8     ASLB                ; = SHIFT ACCB LEFT
          ROLA                ; = ONE BIT
          BCS  LB4EB          ; 'BS' ERROR IF CARRY
          ASL  COEFPT+1       ; * SHIFT MULTIPLICAND LEFT ONE
          ROL  COEFPT         ; * BIT - ADD MULTIPLIER TO ACCUMULATOR
          BCC  LB4E6          ; * IF CARRY <> 0
          ADDD BOTSTK         ; ADD MULTIPLIER TO ACCD
          BCS  LB4EB          ; 'BS' ERROR IF CARRY (>$FFFF)
LB4E6     DEC  V45            ; * DECREMENT SHIFT COUNTER
          BNE  LB4D8          ; * IF NOT DONE
          RTS
LB4EB     JMP  LB447          ; 'BS' ERROR
*
* MEM
* THIS IS NOT A TRUE INDICATOR OF FREE MEMORY BECAUSE
* BASIC REQUIRES A STKBUF SIZE BUFFER FOR THE STACK
* FOR WHICH MEM DOES NOT ALLOW.
*
MEM       TFR  S,D            ; PUT STACK POINTER INTO ACCD
          SUBD ARYEND         ; SUBTRACT END OF ARRAYS
          FCB  SKP1           ; SKIP ONE BYTE
*CONVERT THE VALUE IN ACCB INTO A FP NUMBER IN FPA0
LB4F3     CLRA                ; CLEAR MS BYTE OF ACCD
* CONVERT THE VALUE IN ACCD INTO A FLOATING POINT NUMBER IN FPA0
GIVABF    CLR  VALTYP         ; SET VARIABLE TYPE TO NUMERIC
          STD  FPA0           ; SAVE ACCD IN TOP OF FACA
          LDB  #$90           ; EXPONENT REQUIRED IF THE TOP TWO BYTES
*         OF   FPA0 ARE TO BE TREATED AS AN INTEGER IN FPA0
          JMP  LBC82          ; CONVERT THE REST OF FPA0 TO AN INTEGER

* STR$
STR       JSR  LB143          ; 'TM' ERROR IF STRING VARIABLE
          LDU  #STRBUF+2      ; *CONVERT FP NUMBER TO ASCII STRING IN
          JSR  LBDDC          ; *THE STRING BUFFER
          LEAS 2,S            ; PURGE THE RETURN ADDRESS FROM THE STACK
          LDX  #STRBUF+1      ; *POINT X TO STRING BUFFER AND SAVE
          BRA  LB518          ; *THE STRING IN THE STRING SPACE
* RESERVE ACCB BYTES OF STRING SPACE. RETURN START
* ADDRESS IN (X) AND FRESPC
LB50D     STX  V4D            ; SAVE X IN V4D
LB50F     BSR  LB56D          ; RESERVE ACCB BYTES IN STRING SPACE
LB511     STX  STRDES+2       ; SAVE NEW STRING ADDRESS
          STB  STRDES         ; SAVE LENGTH OF RESERVED BLOCK
          RTS
LB516     LEAX -1,X           ; MOVE POINTER BACK ONE
* SCAN A LINE FROM (X) UNTIL AN END OF LINE FLAG (ZERO) OR
* EITHER OF THE TWO TERMINATORS STORED IN CHARAC OR ENDCHR IS MATCHED.
* THE RESULTING STRING IS STORED IN THE STRING SPACE
* ONLY IF THE START OF THE STRING IS <= STRBUF+2
LB518     LDA  #'"            ; * INITIALIZE
          STA  CHARAC         ; * TERMINATORS
LB51A     STA  ENDCHR         ; * TO "
LB51E     LEAX 1,X            ; MOVE POINTER UP ONE
          STX  RESSGN         ; TEMPORARILY SAVE START OF STRING
          STX  STRDES+2       ; SAVE START OF STRING IN TEMP DESCRIPTOR
          LDB  #-1            ; INITIALIZE CHARACTER COUNTER TO - 1
LB526     INCB                ; INCREMENT CHARACTER COUNTER
          LDA  ,X+            ; GET CHARACTER
          BEQ  LB537          ; BRANCH IF END OF LINE
          CMPA CHARAC         ; * CHECK FOR TERMINATORS
          BEQ  LB533          ; * IN CHARAC AND ENDCHR
          CMPA ENDCHR         ; * DON'T MOVE POINTER BACK
          BNE  LB526          ; * ONE IF TERMINATOR IS "MATCHED"
LB533     CMPA #'"            ; = COMPARE CHARACTER TO STRING DELIMITER
          BEQ  LB539          ; = & DON'T MOVE POINTER BACK IF SO
LB537     LEAX -1,X           ; MOVE POINTER BACK ONE
LB539     STX  COEFPT         ; SAVE END OF STRING ADDRESS
          STB  STRDES         ; SAVE STRING LENGTH IN TEMP DESCRIPTOR
          LDU  RESSGN         ; GET INITlAL STRING START
          CMPU #STRBUF+2      ; COMPARE TO START OF STRING BUFFER
LB543     BHI  LB54C          ; BRANCH IF > START OF STRING BUFFER
          BSR  LB50D          ; GO RESERVE SPACE FOR THE STRING
          LDX  RESSGN         ; POINT X TO THE BEGINNING OF THE STRING
          JSR  LB645          ; MOVE (B) BYTES FROM (X) TO
*                             [FRESPC] - MOVE STRING DATA
* PUT DIRECT PAGE STRING DESCRIPTOR BUFFER DATA
* ON THE STRING STACK. SET VARIABLE TYPE TO STRING
LB54C     LDX  TEMPPT         ; GET NEXT AVAILABLE STRING STACK DESCRIPTOR
          CMPX #LINHDR        ; COMPARE TO TOP OF STRING DESCRIPTOR STACK - WAS #CFNBUF
          BNE  LB558          ; FORMULA O.K.
          LDB  #15*2          ; STRING FORMULA TOO COMPLEX' ERROR
LB555     JMP  LAC46          ; JUMP TO ERROR SERVICING ROUTINE
LB558     LDA  STRDES         ; * GET LENGTH OF STRING AND SAVE IT
*         STA  ,X             ; * IN BYTE 0 OF DESCRIPTOR
          FCB  $A7,$00
          LDD  STRDES+2       ; = GET START ADDRESS OF ACTUAL STRING
          STD  2,X            ; = AND SAVE IN BYTES 2,3 OF DESCRIPTOR
          LDA  #$FF           ; * VARIABLE TYPE = STRING
          STA  VALTYP         ; * SAVE IN VARIABLE TYPE FLAG
          STX  LASTPT         ; = SAVE START OF DESCRIPTOR
          STX  FPA0+2         ; = ADDRESS IN LASTPT AND FPA0
          LEAX 5,X            ; 5 BYTES/STRING DESCRIPTOR
          STX  TEMPPT         ; NEXT AVAILABLE STRING VARIABLE DESCRIPTOR
          RTS
* RESERVE ACCB BYTES IN STRING STORAGE SPACE
* RETURN WITH THE STARTING ADDRESS OF THE
* RESERVED STRING SPACE IN (X) AND FRESPC
LB56D     CLR  GARBFL         ; CLEAR STRING REORGANIZATION FLAG
LB56F     CLRA                ; * PUSH THE LENGTH OF THE
          PSHS B,A            ; * STRING ONTO THE STACK
          LDD  STRTAB         ; GET START OF STRING VARIABLES
          SUBD ,S+            ; SUBTRACT STRING LENGTH
          CMPD FRETOP         ; COMPARE TO START OF STRING STORAGE
          BCS  LB585          ; IF BELOW START, THEN REORGANIZE
          STD  STRTAB         ; SAVE NEW START OF STRING VARIABLES
          LDX  STRTAB         ; GET START OF STRING VARIABLES
          LEAX 1,X            ; ADD ONE
          STX  FRESPC         ; SAVE START ADDRESS OF NEWLY RESERVED SPACE
          PULS B,PC           ; RESTORE NUMBER OF BYTES RESERVED AND RETURN
LB585     LDB  #2*13          ; OUT OF STRING SPACE' ERROR
          COM  GARBFL         ; TOGGLE REORGANIZATiON FLAG
          BEQ  LB555          ; ERROR IF FRESHLY REORGANIZED
          BSR  LB591          ; GO REORGANIZE STRING SPACE
          PULS B              ; GET BACK THE NUMBER OF BYTES TO RESERVE
          BRA  LB56F          ; TRY TO RESERVE ACCB BYTES AGAIN
* REORGANIZE THE STRING SPACE
LB591     LDX  MEMSIZ         ; GET THE TOP OF STRING SPACE
LB593     STX  STRTAB         ; SAVE TOP OF UNORGANIZED STRING SPACE
          CLRA                ; * ZERO OUT ACCD
          CLRB                ; * AND RESET VARIABLE
          STD  V4B            ; * POINTER TO 0
          LDX  FRETOP         ; POINT X TO START OF STRING SPACE
          STX  V47            ; SAVE POINTER IN V47
          LDX  #STRSTK        ; POINT X TO START OF STRING DESCRIPTOR STACK
LB5A0     CMPX TEMPPT         ; COMPARE TO ADDRESS OF NEXT AVAILABLE DESCRIPTOR
          BEQ  LB5A8          ; BRANCH IF TOP OF STRING STACK
          BSR  LB5D8          ; CHECK FOR STRING IN UNORGANIZED STRING SPACE
          BRA  LB5A0          ; KEEP CHECKING
LB5A8     LDX  VARTAB         ; GET THE END OF BASIC PROGRAM
LB5AA     CMPX ARYTAB         ; COMPARE TO END OF VARIABLES
          BEQ  LB5B2          ; BRANCH IF AT TOP OF VARIABLES
          BSR  LB5D2          ; CHECK FOR STRING IN UNORGANIZED STRING SPACE
          BRA  LB5AA          ; KEEP CHECKING VARIABLES
LB5B2     STX  V41            ; SAVE ADDRESS OF THE END OF VARIABLES
LB5B4     LDX  V41            ; GET CURRENT ARRAY POINTER
LB5B6     CMPX ARYEND         ; COMPARE TO THE END OF ARRAYS
          BEQ  LB5EF          ; BRANCH IF AT END OF ARRAYS
          LDD  2,X            ; GET LENGTH OF ARRAY AND DESCRIPTOR
          ADDD V41            ; * ADD TO CURRENT ARRAY POINTER
          STD  V41            ; * AND SAVE IT
          LDA  1,X            ; GET 1ST CHARACTER OF VARIABLE NAME
          BPL  LB5B4          ; BRANCH IF NUMERIC ARRAY
          LDB  4,X            ; GET THE NUMBER OF DIMENSIONS IN THIS ARRAY
          ASLB                ; MULTIPLY BY 2
          ADDB #5             ; ADD FIVE BYTES (VARIABLE NAME, ARRAY
*                             ; LENGTH, NUMBER DIMENSIONS)
          ABX                 ; X NOW POINTS TO START OF ARRAY ELEMENTS
LB5CA     CMPX V41            ; AT END OF THIS ARRAY?
          BEQ  LB5B6          ; YES - CHECK FOR ANOTHER
          BSR  LB5D8          ; CHECK FOR STRING LOCATED IN
*                             ; UNORGANIZED STRING SPACE
          BRA  LB5CA          ; KEEP CHECKING ELEMENTS IN THIS ARRAY
LB5D2     LDA  1,X            ; GET F1RST BYTE OF VARIABLE NAME
          LEAX 2,X            ; MOVE POINTER TO DESCRIPTOR
          BPL  LB5EC          ; BRANCH IF VARIABLE IS NUMERIC
* SEARCH FOR STRING - ENTER WITH X POINTING TO
* THE STRING DESCRIPTOR. IF STRING IS STORED
* BETWEEN V47 AND STRTAB, SAVE DESCRIPTOR POINTER
* IN V4B AND RESET V47 TO STRING ADDRESS
LB5D8     LDB  ,X             ; GET THE LENGTH OF THE STRING
          BEQ  LB5EC          ; BRANCH IF NULL - NO STRING
          LDD  2,X            ; GET STARTING ADDRESS OF THE STRING
          CMPD STRTAB         ; COMPARE TO THE START OF STRING VARIABLES
          BHI  LB5EC          ; BRANCH IF THIS STRING IS STORED IN
*              ; THE STRING VARIABLES
          CMPD V47            ; COMPARE TO START OF STRING SPACE
          BLS  LB5EC          ; BRANCH IF NOT STORED IN THE STRING SPACE
          STX  V4B            ; SAVE VARIABLE POINTER IF STORED IN STRING SPACE
          STD  V47            ; SAVE STRING STARTING ADDRESS
LB5EC     LEAX 5,X            ; MOVE TO NEXT VARIABLE DESCRIPTOR
LB5EE     RTS
LB5EF     LDX  V4B            ; GET ADDRESS OF THE DESCRIPTOR FOR THE
*              ; STRING WHICH IS STORED IN THE HIGHEST RAM ADDRESS IN
*              ; THE UNORGANIZED STRING SPACE
          BEQ  LB5EE          ; BRANCH IF NONE FOUND AND REORGANIZATION DONE
          CLRA                ; CLEAR MS BYTE OF LENGTH
          LDB  ,X             ; GET LENGTH OF STRING
          DECB                ; SUBTRACT ONE
          ADDD V47            ; ADD LENGTH OF STRING TO ITS STARTING ADDRESS
          STD  V43            ; SAVE AS MOVE STARTING ADDRESS
          LDX  STRTAB         ; POINT X TO THE START OF ORGANIZED STRING VARIABLES
          STX  V41            ; SAVE AS MOVE ENDING ADDRESS
          JSR  LAC20          ; MOVE STRING FROM CURRENT POSITION TO THE
*              ; TOP OF UNORGANIZED STRING SPACE
          LDX  V4B            ; POINT X TO STRING DESCRIPTOR
          LDD  V45            ; * GET NEW STARTING ADDRESS OF STRING AND
          STD  2,X            ; * SAVE IT IN DESCRIPTOR
          LDX  V45            ; GET NEW TOP OF UNORGANIZED STRING SPACE
          LEAX -1,X           ; MOVE POINTER BACK ONE
          JMP  LB593          ; JUMP BACK AND REORGANIZE SOME MORE


LB60F     LDD  FPA0+2         ; * GET DESCRIPTOR ADDRESS OF STRING A
          PSHS B,A            ; * AND SAVE IT ON THE STACK
          JSR  LB223          ; GET DESCRIPTOR ADDRESS OF STRING B
          JSR  LB146          ; 'TM' ERROR IF NUMERIC VARIABLE
          PULS X              ; * POINT X TO STRING A DESCRIPTOR
          STX  RESSGN         ; * ADDRESS AND SAVE IT IN RESSGN
          LDB  ,X             ; GET LENGTH OF STRING A
          LDX  FPA0+2         ; POINT X TO DESCRIPTOR OF STRING B
          ADDB ,X             ; ADD LENGTH OF STRING B TO STR1NG A
          BCC  LB62A          ; BRANCH IF LENGTH < 256
          LDB  #2*14          ; 'STRING TOO LONG' ERROR IF LENGTH > 255
          JMP  LAC46          ; JUMP TO ERROR SERVICING ROUTINE
LB62A     JSR  LB50D          ; RESERVE ROOM IN STRING SPACE FOR NEW STRING
          LDX  RESSGN         ; GET DESCRIPTOR ADDRESS OF STRING A
          LDB  ,X             ; GET LENGTH OF STRING A
          BSR  LB643          ; MOVE STRING A INTO RESERVED BUFFER IN STRING SPACE
          LDX  V4D            ; GET DESCRIPTOR ADDRESS OF STRING B
          BSR  LB659          ; GET LENGTH AND ADDRESS OF STRING B
          BSR  LB645          ; MOVE STRING B INTO REST OF RESERVED BUFFER
          LDX  RESSGN         ; POINT X TO DESCRIPTOR OF STRING A
          BSR  LB659          ; DELETE STRING A IF LAST STRING ON STRING STACK
          JSR  LB54C          ; PUT STRING DESCRIPTOR ON THE STRING STACK
          JMP  LB168          ; BRANCH BACK TO EXPRESSION EVALUATION

* MOVE (B) BYTES FROM 2,X TO FRESPC
LB643     LDX  2,X            ; POINT X TO SOURCE ADDRESS
LB645     LDU  FRESPC         ; POINT U TO DESTINATION ADDRESS
          INCB                ; COMPENSATION FOR THE DECB BELOW
          BRA  LB64E          ; GO MOVE THE BYTES
* MOVE B BYTES FROM (X) TO (U)
LB64A     LDA  ,X+            ; * GET A SOURCE BYTE AND MOVE IT
          STA  ,U+            ; * TO THE DESTINATION
LB64E     DECB                ; DECREMENT BYTE COUNTER
          BNE  LB64A          ; BRANCH IF ALL BYTES NOT MOVED
          STU  FRESPC         ; SAVE ENDING ADDRESS IN FRESPC
          RTS
* RETURN LENGTH (ACCB) AND ADDRESS (X) OF
* STRING WHOSE DESCRIPTOR IS IN FPA0+2
* DELETE THE STRING IF IT IS THE LAST ONE
* PUT ON THE STRING STACK. REMOVE STRING FROM STRING
* SPACE IF IT IS AT THE BOTTOM OF STRING VARIABLES.
LB654     JSR  LB146          ; 'TM' ERROR IF VARIABLE TYPE = NUMERIC
LB657     LDX  FPA0+2         ; GET ADDRESS OF SELECTED STRING DESCRIPTOR
LB659     LDB  ,X             ; GET LENGTH OF STRING
          BSR  LB675          ; * CHECK TO SEE IF THIS STRING DESCRIPTOR WAS
          BNE  LB672          ; * THE LAST ONE PUT ON THE STRING STACK AND
*                             ; * BRANCH IF NOT
          LDX  5+2,X          ; GET START ADDRESS OF STRING JUST REMOVED
          LEAX -1,X           ; MOVE POINTER DOWN ONE
          CMPX STRTAB         ; COMPARE TO START OF STRING VARIABLES
          BNE  LB66F          ; BRANCH IF THIS STRING IS NOT AT THE BOTTOM
*                             ; OF STRING VARIABLES
          PSHS B              ; SAVE LENGTH; ACCA WAS CLEARED
          ADDD STRTAB         ; * ADD THE LENGTH OF THE JUST REMOVED STRING
          STD  STRTAB         ; * TO THE START OF STRING VARIABLES - THIS WILL
*                             ; * REMOVE THE STRING FROM THE STRING SPACE
          PULS B              ; RESTORE LENGTH
LB66F     LEAX 1,X            ; ADD ONE TO POINTER
          RTS
LB672     LDX  2,X            ; *POINT X TO ADDRESS OF STRING NOT
          RTS                 ; *ON THE STRING STACK
* REMOVE STRING FROM STRING STACK. ENTER WITH X
* POINTING TO A STRING DESCRIPTOR - DELETE THE
* STRING FROM STACK IF IT IS ON TOP OF THE
* STACK. IF THE STRING IS DELETED, SET THE ZERO FLAG
LB675     CMPX LASTPT         ; *COMPARE TO LAST USED DESCRIPTOR ADDRESS
          BNE  LB680          ; *ON THE STRING STACK, RETURN IF DESCRIPTOR
*                             ; *ADDRESS NOT ON THE STRING STACK
          STX  TEMPPT         ; SAVE LAST USED DESCRIPTOR AS NEXT AVAILABLE
          LEAX -5,X           ; * MOVE LAST USED DESCRIPTOR BACK 5 BYTES
          STX  LASTPT         ; * AND SAVE AS THE LAST USED DESCRIPTOR ADDR
          CLRA                ; SET ZERO FLAG
LB680     RTS

* LEN
LEN       BSR  LB686          ; POINT X TO PROPER STRING AND GET LENGTH
LB683     JMP  LB4F3          ; CONVERT ACCB TO FP NUMBER IN FPA0
* POINT X TO STRING ADDRESS LOAD LENGTH INTO
* ACCB. ENTER WITH THE STRING DESCRIPTOR IN
* BOTTOM TWO BYTES OF FPA0
LB686     BSR  LB654          ; GET LENGTH AND ADDRESS OF STRING
          CLR  VALTYP         ; SET VARIABLE TYPE TO NUMERIC
          TSTB                ; SET FLAGS ACCORDING TO LENGTH
          RTS

* CHR$
CHR       JSR  LB70E          ; CONVERT FPA0 TO AN INTEGER IN ACCD
LB68F     LDB  #1             ; * RESERVE ONE BYTE IN
          JSR  LB56D          ; * THE STRING SPACE
          LDA  FPA0+3         ; GET ASCII STRING VALUE
          JSR  LB511          ; SAVE RESERVED STRING DESCRIPTOR IN TEMP DESCRIPTOR
          STA  ,X             ; SAVE THE STRING (IT'S ONLY ONE BYTE)
LB69B     LEAS 2,S            ; PURGE THE RETURN ADDRESS OFF OF THE STACK
LB69D     JMP  LB54C          ; PUT TEMP DESCRIPTOR DATA ONTO STRING STACK


ASC       BSR  LB6A4          ; PUT 1ST CHARACTER OF STRING INTO ACCB
          BRA  LB683          ; CONVERT ACCB INTO FP NUMBER IN FPA0
LB6A4     BSR  LB686          ; POINT X TO STRING DESCRIPTOR
          BEQ  LB706          ; 'FC' ERROR IF NULL STRING
          LDB  ,X             ; GET FIRST BYTE OF STRING
          RTS


LEFT      BSR  LB6F5          ; GET ARGUMENTS FROM STACK
LB6AD     CLRA                ; CLEAR STRING POINTER OFFSET - OFFSET = 0 FOR LEFT$
LB6AE     CMPB ,X             ; * COMPARE LENGTH PARAMETER TO LENGTH OF
          BLS  LB6B5          ; * STRING AND BRANCH IF LENGTH OF STRING
*                             ; >= LENGTH PARAMETER
          LDB  ,X             ; USE LENGTH OF STRING OTHERWISE
          CLRA                ; CLEAR STRING POINTER OFFSET (0 FOR LEFT$)
LB6B5     PSHS B,A            ; PUSH PARAMETERS ONTO STACK
          JSR  LB50F          ; RESERVE ACCB BYTES IN THE STRING SPACE
          LDX  V4D            ; POINT X TO STRING DESCRIPTOR
          BSR  LB659          ; GET ADDRESS OF OLD STRING (X=ADDRESS)
          PULS B              ; * PULL STRING POINTER OFFSET OFF OF THE STACK
          ABX                 ; * AND ADD IT TO STRING ADDRESS
          PULS B              ; PULL LENGTH PARAMETER OFF OF THE STACK
          JSR  LB645          ; MOVE ACCB BYTES FROM (X) TO [FRESPC]
          BRA  LB69D          ; PUT TEMP STRING DESCRIPTOR ONTO THE STRING STACK

* RIGHT$
RIGHT     BSR  LB6F5          ; GET ARGUMENTS FROM STACK
          SUBA ,X             ; ACCA=LENGTH PARAMETER - LENGTH OF OLD STRING
          NEGA                ; NOW ACCA = LENGTH OF OLD STRING
          BRA  LB6AE          ; PUT NEW STRING IN THE STRING SPACE

* MID$
MID       LDB  #$FF           ; * GET DEFAULT VALUE OF LENGTH AND
          STB  FPA0+3         ; * SAVE IT IN FPA0
          JSR  GETCCH         ; GET CURRENT CHARACTER FROM BASIC
          CMPA #')            ; ARGUMENT DELIMITER?
          BEQ  LB6DE          ; YES - NO LENGTH PARAMETER GIVEN
          JSR  LB26D          ; SYNTAX CHECK FOR COMMA
          BSR  LB70B          ; EVALUATE NUMERIC EXPRESSION (LENGTH)
LB6DE     BSR  LB6F5          ; GET ARGUMENTS FROM STACK
          BEQ  LB706          ; 'FC' ERROR IF NULL STRING
          CLRB                ; CLEAR LENGTH COUNTER (DEFAULT VALUE)
          DECA                ; *SUOTRACT ONE FROM POSITION PARAMETER (THESE
          CMPA ,X             ; *ROUTINES EXPECT 1ST POSITION TO BE ZERO, NOT ONE)
*                             ; *AND COMPARE IT TO LENGTH OF OLD STRING
          BCC  LB6B5          ; IF POSITION > LENGTH OF OLD STRING, THEN NEW
*                             ; STRING WILL BE A NULL STRING
          TFR  A,B            ; SAVE ABSOLUTE POSITION PARAMETER IN ACCB
          SUBB ,X             ; ACCB=POSITION-LENGTH OF OLD STRING
          NEGB                ; NOW ACCB=LENGTH OF OLDSTRING-POSITION
          CMPB FPA0+3         ; *IF THE AMOUNT OF OLD STRING TO THE RIGHT OF
          BLS  LB6B5          ; *POSITION IS <= THE LENGTH PARAMETER, BRANCH AND
* USE ALL OF THE STRING TO THE RIGHT OF THE POSITION
* INSTEAD OF THE LENGTH PARAMETER
          LDB  FPA0+3         ; GET LENGTH OF NEW STRING
          BRA  LB6B5          ; PUT NEW STRING IN STRING SPACE
* DO A SYNTAX CHECK FOR ")", THEN PULL THE PREVIOUSLY CALCULATED NUMERIC
* ARGUMENT (ACCD) AND STRING ARGUMENT DESCRIPTOR ADDR OFF OF THE STACK
LB6F5     JSR  LB267          ; SYNTAX CHECK FOR A ")"
          LDU  ,S             ; LOAD THE RETURN ADDRESS INTO U REGISTER
          LDX  5,S            ; * GET ADDRESS OF STRING AND
          STX  V4D            ; * SAVE IT IN V4D
          LDA  4,S            ; = PUT LENGTH OF STRING IN
          LDB  4,S            ; = BOTH ACCA AND ACCB
          LEAS 7,S            ; REMOVE DESCRIPTOR AND RETURN ADDRESS FROM STACK
          TFR  U,PC           ; JUMP TO ADDRESS IN U REGISTER
LB706     JMP  LB44A          ; 'ILLEGAL FUNCTION CALL'
* EVALUATE AN EXPRESSION - RETURN AN INTEGER IN
* ACCB - 'FC' ERROR IF EXPRESSION > 255
LB709     JSR  GETNCH         ; GET NEXT BASIC INPUT CHARACTER
LB70B     JSR  LB141          ; EVALUATE A NUMERIC EXPRESSION
LB70E     JSR  LB3E9          ; CONVERT FPA0 TO INTEGER IN ACCD
          TSTA                ; TEST MS BYTE OF INTEGER
          BNE  LB706          ; 'FC' ERROR IF EXPRESSION > 255
          JMP  GETCCH         ; GET CURRENT INPUT CHARACTER FROM BASIC

* VAL
VAL       JSR  LB686          ; POINT X TO STRING ADDRESS
          LBEQ LBA39          ; IF NULL STRING SET FPA0
          LDU  CHARAD         ; SAVE INPUT POINTER IN REGISTER U
          STX  CHARAD         ; POINT INPUT POINTER TO ADDRESS OF STRING
          ABX                 ; MOVE POINTER TO END OF STRING TERMINATOR
          LDA  ,X             ; GET LAST BYTE OF STRING
          PSHS U,X,A          ; SAVE INPUT POINTER, STRING TERMINATOR
*         ADDRESS AND CHARACTER
          CLR  ,X             ; CLEAR STRING TERMINATOR : FOR ASCII - FP CONVERSION
          JSR  GETCCH         ; GET CURRENT CHARACTER FROM BASIC
          JSR  LBD12          ; CONVERT AN ASCII STRING TO FLOATING POINT
          PULS A,X,U          ; RESTORE CHARACTERS AND POINTERS
          STA  ,X             ; REPLACE STRING TERMINATOR
          STU  CHARAD         ; RESTORE INPUT CHARACTER
          RTS

LB734     BSR  LB73D          ; * EVALUATE AN EXPRESSION, RETURN
          STX  BINVAL         ; * THE VALUE IN X; STORE IT IN BINVAL
LB738     JSR  LB26D          ; SYNTAX CHECK FOR A COMMA
          BRA  LB70B          ; EVALUATE EXPRESSION IN RANGE 0 <= X < 256
* EVALUATE EXPRESSION : RETURN INTEGER PORTION IN X - 'FC' ERROR IF

LB73D     JSR  LB141          ; EVALUATE NUMERIC EXPRESSION
LB740     LDA  FP0SGN         ; GET SIGN OF FPA0 MANTISSA
          BMI  LB706          ; ILLEGAL FUNCTION CALL' IF NEGATIVE
          LDA  FP0EXP         ; GET EXPONENT OF FPA0
          CMPA #$90           ; COMPARE TO LARGEST POSITIVE INTEGER
          BHI  LB706          ; ILLEGAL FUNCTION CALL' IF TOO LARGE
          JSR  LBCC8          ; SHIFT BINARY POINT TO EXTREME RIGHT OF FPA0
          LDX  FPA0+2         ; LOAD X WITH LOWER TWO BYTES OF FPA0
          RTS

* PEEK
PEEK      BSR  LB740          ; CONVERT FPA0 TO INTEGER IN REGISTER X
          LDB  ,X             ; GET THE VALUE BEING 'PEEK'ED
          JMP  LB4F3          ; CONVERT ACCB INTO A FP NUMBER

* POKE
POKE      BSR  LB734          ; EVALUATE 2 EXPRESSIONS
          LDX  BINVAL         ; GET THE ADDRESS TO BE 'POKE'ED
          STB  ,X             ; STORE THE DATA IN THAT ADDRESS
          RTS


* LIST
LIST      PSHS CC             ; SAVE ZERO FLAG ON STACK
          JSR  LAF67          ; CONVERT DECIMAL LINE NUMBER TO BINARY
          JSR  LAD01          ; * FIND RAM ADDRESS OF THAT LINE NUMBER AND
          STX  LSTTXT         ; * SAVE IT IN LSTTXT
          PULS CC             ; GET ZERO FLAG FROM STACK
          BEQ  LB784          ; BRANCH IF END OF LINE
          JSR  GETCCH         ; GET CURRENT CHARACTER FROM BASIC
          BEQ  LB789          ; BRANCH IF END OF LINE
          CMPA #TOK_MINUS     ; MINUS TOKEN (IS IT A RANGE OF LINE NUMBERS?)
          BNE  LB783          ; NO - RETURN
          JSR  GETNCH         ; GET NEXT CHARACTER FROM BASIC
          BEQ  LB784          ; BRANCH IF END OF LINE
          JSR  LAF67          ; GET ENDING LINE NUMBER
          BEQ  LB789          ; BRANCH IF LEGAL LINE NUMBER
LB783 RTS
* LIST THE ENTIRE PROGRAM
LB784     LDU  #$FFFF         ; * SET THE DEFAULT ENDING LINE NUMBER
          STU  BINVAL         ; * TO $FFFF
LB789     LEAS 2,S            ; PURGE RETURN ADDRESS FROM THE STACK
          LDX  LSTTXT         ; POINT X TO STARTING LINE ADDRESS
LB78D     JSR  LB95C          ; MOVE CURSOR TO START OF A NEW LINE
          JSR  LA549          ; CHECK FOR A BREAK OR PAUSE
          LDD  ,X             ; GET ADDRESS OF NEXT BASIC LINE
          BNE  LB79F          ; BRANCH IF NOT END OF PROGRAM
LB797
          JMP  LAC73          ; RETURN TO BASIC'S MAIN INPUT LOOP
LB79F     STX  LSTTXT         ; SAVE NEW STARTING LINE ADDRESS
          LDD  2,X            ; * GET THE LINE NUMBER OF THIS LINE AND
          CMPD BINVAL         ; * COMPARE IT TO ENDING LINE NUMBER
          BHI  LB797          ; EXIT IF LINE NUMBER > ENDING LINE NUMBER
          JSR  LBDCC          ; PRINT THE NUMBER IN ACCD ON SCREEN IN DECIMAL
          JSR  LB9AC          ; SEND A SPACE TO CONSOLE OUT
          LDX  LSTTXT         ; GET RAM ADDRESS OF THIS LINE
          BSR  LB7C2          ; UNCRUNCH A LINE
          LDX  [LSTTXT]       ; POINT X TO START OF NEXT LINE
          LDU  #LINBUF+1      ; POINT U TO BUFFER FULL OF UNCRUNCHED LINE
LB7B9     LDA  ,U+            ; GET A BYTE FROM THE BUFFER
          BEQ  LB78D          ; BRANCH IF END OF BUFFER
          JSR  LB9B1          ; SEND CHARACTER TO CONSOLE OUT
          BRA  LB7B9          ; GET ANOTHER CHARACTER

* UNCRUNCH A LINE INTO BASIC'S LINE INPUT BUFFER
LB7C2     LEAX 4,X            ; MOVE POINTER PAST ADDRESS OF NEXT LINE AND LINE NUMBER
          LDY  #LINBUF+1      ; UNCRUNCH LINE INTO LINE INPUT BUFFER
LB7CB     LDA  ,X+            ; GET A CHARACTER
          BEQ  LB820          ; BRANCH IF END OF LINE
          BMI  LB7E6          ; BRANCH IF IT'S A TOKEN
          CMPA #':            ; CHECK FOR END OF SUB LINE
          BNE  LB7E2          ; BRNCH IF NOT END OF SUB LINE
          LDB  ,X             ; GET CHARACTER FOLLOWING COLON
          CMPB #TOK_ELSE      ; TOKEN FOR ELSE?
          BEQ  LB7CB          ; YES - DON'T PUT IT IN BUFFER
          CMPB #TOK_SNGL_Q    ; TOKEN FOR REMARK?
          BEQ  LB7CB          ; YES - DON'T PUT IT IN BUFFER
          FCB  SKP2           ; SKIP TWO BYTES
LB7E0     LDA  #'!            ; EXCLAMATION POINT
LB7E2     BSR  LB814          ; PUT CHARACTER IN BUFFER
          BRA  LB7CB          ; GET ANOTHER CHARACTER

LB7E6     LDU  #COMVEC-10     ; FIRST DO COMMANDS
          CMPA #$FF           ; CHECK FOR SECONDARY TOKEN
          BNE  LB7F1          ; BRANCH IF NON SECONDARY TOKEN
          LDA  ,X+            ; GET SECONDARY TOKEN
          LEAU 5,U            ; BUMP IT UP TO SECONDARY FUNCTIONS
LB7F1     ANDA #$7F           ; MASK OFF BIT 7 OF TOKEN
LB7F3     LEAU 10,U           ; MOVE TO NEXT COMMAND TABLE
          TST  ,U             ; IS THIS TABLE ENABLED?
          BEQ  LB7E0          ; NO - ILLEGAL TOKEN
          SUBA ,U             ; SUBTRACT THE NUMBER OF TOKENS FROM THE CURRENT TOKEN NUMBER
          BPL  LB7F3          ; BRANCH IF TOKEN NOT IN THIS TABLE
          ADDA ,U             ; RESTORE TOKEN NUMBER RELATIVE TO THIS TABLE
          LDU  1,U            ; POINT U TO COMMAND DICTIONARY TABLE
LB801     DECA                ; DECREMENT TOKEN NUMBER
          BMI  LB80A          ; BRANCH IF THIS IS THE CORRECT TOKEN
* SKIP THROUGH DICTIONARY TABLE TO START OF NEXT TOKEN
LB804     TST  ,U+            ; GRAB A BYTE
          BPL  LB804          ; BRANCH IF BIT 7 NOT SET
          BRA  LB801          ; GO SEE IF THIS IS THE CORRECT TOKEN
LB80A     LDA  ,U             ; GET A CHARACTER FROM DICTIONARY TABLE
          BSR  LB814          ; PUT CHARACTER IN BUFFER
          TST  ,U+            ; CHECK FOR START OF NEXT TOKEN
          BPL  LB80A          ; BRANCH IF NOT DONE WITH THIS TOKEN
          BRA  LB7CB          ; GO GET ANOTHER CHARACTER
LB814     CMPY #LINBUF+LBUFMX ; TEST FOR END OF LINE INPUT BUFFER
          BCC  LB820          ; BRANCH IF AT END OF BUFFER
          ANDA #$7F           ; MASK OFF BIT 7
          STA  ,Y+            ; * SAVE CHARACTER IN BUFFER AND
          CLR  ,Y             ; * CLEAR NEXT CHARACTER SLOT IN BUFFER
LB820     RTS
*
* CRUNCH THE LINE THAT THE INPUT POINTER IS
* POINTING TO INTO THE LINE INPUT BUFFER
* RETURN LENGTH OF CRUNCHED LINE IN ACCD
*
LB821     LDX  CHARAD         ; GET BASIC'S INPUT POINTER ADDRESS
          LDU  #LINBUF        ; POINT X TO LINE INPUT BUFFER
LB829     CLR  V43            ; CLEAR ILLEGAL TOKEN FLAG
          CLR  V44            ; CLEAR DATA FLAG
LB82D     LDA  ,X+            ; GET INPUT CHAR
          BEQ  LB852          ; BRANCH IF END OF LINE
          TST  V43            ; * CHECK ILLEGAL TOKEN FLAG & BRANCH IF NOT
          BEQ  LB844          ; * PROCESSING AN ILLEGAL TOKEN
          JSR  LB3A2          ; SET CARRY IF NOT UPPER CASE ALPHA
          BCC  LB852          ; BRANCH IF UPPER CASE ALPHA
          CMPA #'0            ; * DON'T CRUNCH ASCII NUMERIC CHARACTERS
          BLO  LB842          ; * BRANCH IF NOT NUMERIC
          CMPA #'9            ; *
          BLS  LB852          ; * BRANCH IF NUMERIC
* END UP HERE IF NOT UPPER CASE ALPHA OR NUMERIC
LB842     CLR  V43            ; CLEAR ILLEGAL TOKEN FLAG
LB844     CMPA #SPACE         ; SPACE?
          BEQ  LB852          ; DO NOT REMOVE SPACES
          STA  V42            ; SAVE INPUT CHARACTER AS SCAN DELIMITER
          CMPA #'"            ; CHECK FOR STRING DELIMITER
          BEQ  LB886          ; BRANCH IF STRING
          TST  V44            ; * CHECK DATA FLAG AND BRANCH IF CLEAR
          BEQ  LB86B          ; * DO NOT CRUNCH DATA
LB852     STA  ,U+            ; SAVE CHARACTER IN BUFFER
          BEQ  LB85C          ; BRANCH IF END OF LINE
          CMPA #':            ; * CHECK FOR END OF SUBLINE
          BEQ  LB829          ; * AND RESET FLAGS IF END OF SUBLINE
LB85A     BRA  LB82D          ; GO GET ANOTHER CHARACTER
LB85C     CLR  ,U+            ; * DOUBLE ZERO AT END OF LINE
          CLR  ,U+            ; *
          TFR  U,D            ; SAVE ADDRESS OF END OF LINE IN ACCD
          SUBD #LINHDR        ; LENGTH OF LINE IN ACCD
          LDX  #LINBUF-1      ; * SET THE INPUT POINTER TO ONE BEFORE
          STX  CHARAD         ; * THE START OF THE CRUNCHED LINE
          RTS                 ; EXIT 'CRUNCH'
LB86B     CMPA #'?            ; CHECK FOR "?" - PRINT ABBREVIATION
          BNE  LB873          ; BRANCH IF NOT PRINT ABBREVIATION
          LDA  #TOK_PRINT     ; * GET THE PRINT TOKEN AND SAVE IT
          BRA  LB852          ; * IN BUFFER
LB873     CMPA #''            ; APOSTROPHE IS SAME AS REM
          BNE  LB88A          ; BRANCH IF NOT REMARK
          LDD  #$3A00+TOK_SNGL_Q ; COLON, REM TOKEN
          STD  ,U++           ; SAVE IN BUFFER
LB87C     CLR  V42            ; SET DELIMITER = 0 (END OF LINE)
LB87E     LDA  ,X+            ; SCAN TILL WE MATCH [V42]
          BEQ  LB852          ; BRANCH IF END OF LINE
          CMPA V42            ; DELIMITER?
          BEQ  LB852          ; BRANCH OUT IF SO
LB886     STA  ,U+            ; DON'T CRUNCH REMARKS OR STRINGS
          BRA  LB87E          ; GO GET MORE STRING OR REMARK
LB88A     CMPA #'0            ; * LESS THAN ASCII ZERO?
          BCS  LB892          ; * BRANCH IF SO
          CMPA #';+1          ; = CHECK FOR NUMERIC VALUE, COLON OR SEMICOLON
          BCS  LB852          ; = AND INSERT IN BUFFER IF SO
LB892     LEAX -1,X           ; MOVE INPUT POINTER BACK ONE
          PSHS U,X            ; SAVE POINTERS TO INPUT STRING, OUTPUT STRING
          CLR  V41            ; TOKEN FLAG 0 = COMMAND, FF = SECONDARY
          LDU  #COMVEC-10     ; POINT U TO COMMAND INTERPRETATION
*                             ; TABLE FOR BASIC - 10
LB89B     CLR  V42            ; INITIALIZE V42 AS TOKEN COUNTER
LB89D     LEAU 10,U           ; MOVE TO NEXT COMMAND INTERPRETATION TABLE
          LDA  ,U             ; GET NUMBER OF COMMANDS
          BEQ  LB8D4          ; GO DO SECONDARY FUNCTIONS IF NO COMMAND TABLE
          LDY  1,U            ; POINT Y TO COMMAND DICTIONARY TABLE
LB8A6     LDX  ,S             ; GET POINTER TO INPUT STRING
LB8A8     LDB  ,Y+            ; GET A BYTE FROM DICTIONARY TABLE
          SUBB ,X+            ; SUBTRACT INPUT CHARACTER
          BEQ  LB8A8          ; LOOP IF SAME
          CMPB #$80           ; LAST CHAR IN RESERVED WORD TABLE HAD
*                             ; BIT 7 SET, SO IF WE HAVE $80 HERE
*                             ; THEN IT IS A GOOD COMPARE
          BNE  LB8EA          ; BRANCH IF NO MATCH - CHECK ANOTHER COMMAND
          LEAS 2,S            ; DELETE OLD INPUT POINTER FROM STACK
          PULS U              ; GET POINTER TO OUTPUT STRING
          ORB  V42            ; OR IN THE TABLE POSITION TO MAKE THE TOKEN
*                             ; - NOTE THAT B ALREADY HAD $80 IN IT -
          LDA  V41            ; * CHECK TOKEN FLAG AND BRANCH
          BNE  LB8C2          ; * IF SECONDARY
          CMPB #TOK_ELSE      ; IS IT ELSE TOKEN?
          BNE  LB8C6          ; NO
          LDA  #':            ; PUT A COLON (SUBLINE) BEFORE ELSE TOKEN
LB8C2     STD  ,U++           ; SECONDARY TOKENS PRECEEDED BY $FF
          BRA  LB85A          ; GO PROCESS MORE INPUT CHARACTERS
LB8C6     STB  ,U+            ; SAVE THIS TOKEN
          CMPB #TOK_DATA      ; DATA TOKEN?
          BNE  LB8CE          ; NO
          INC  V44            ; SET DATA FLAG
LB8CE     CMPB #TOK_REM       ; REM TOKEN?
          BEQ  LB87C          ; YES
LB8D2     BRA  LB85A          ; GO PROCESS MORE INPUT CHARACTERS
* CHECK FOR A SECONDARY TOKEN
LB8D4     LDU  #COMVEC-5      ; NOW DO SECONDARY FUNCTIONS
          COM  V41            ; TOGGLE THE TOKEN FLAG
          BNE  LB89B          ; BRANCH IF NOW CHECKING SECONDARY COMMANDS

* THIS CODE WILL PROCESS INPUT DATA WHICH CANNOT BE CRUNCHED AND SO
* IS ASSUMED TO BE ILLEGAL DATA OR AN ILLEGAL TOKEN
          PULS X,U            ; RESTORE INPUT AND OUTPUT POINTERS
          LDA  ,X+            ; * MOVE THE FIRST CHARACTER OF AN
          STA  ,U+            ; * ILLEGAL TOKEN
          JSR  LB3A2          ; SET CARRY IF NOT ALPHA
          BCS  LB8D2          ; BRANCH IF NOT ALPHA
          COM  V43            ; SET ILLEGAL TOKEN FLAG IF UPPER CASE ALPHA
          BRA  LB8D2          ; PROCESS MORE INPUT CHARACTERS
LB8EA     INC  V42            ; INCREMENT TOKEN COUNTER
          DECA                ; DECR COMMAND COUNTER
          BEQ  LB89D          ; GET ANOTHER COMMAND TABLE IF DONE W/THIS ONE
          LEAY -1,Y           ; MOVE POINTER BACK ONE
LB8F1     LDB  ,Y+            ; * GET TO NEXT
          BPL  LB8F1          ; * RESERVED WORD
          BRA  LB8A6          ; GO SEE IF THIS WORD IS A MATCH

* PRINT
PRINT     BEQ  LB958          ; BRANCH IF NO ARGUMENT
          BSR  LB8FE          ; CHECK FOR ALL PRINT OPTIONS
          RTS
LB8FE
LB918     JSR  XVEC9          ; CALL EXTENDED BASIC ADD-IN
LB91B     BEQ  LB965          ; RETURN IF END OF LINE
LB91D     CMPA #TOK_TAB       ; TOKEN FOR TAB( ?
          BEQ  LB97E          ; YES
          CMPA #',            ; COMMA?
          BEQ  LB966          ; YES - ADVANCE TO NEXT TAB FIELD
          CMPA #';            ; SEMICOLON?
          BEQ  LB997          ; YES - DO NOT ADVANCE CURSOR
          JSR  LB156          ; EVALUATE EXPRESSION
          LDA  VALTYP         ; * GET VARIABLE TYPE AND
          PSHS A              ; * SAVE IT ON THE STACK
          BNE  LB938          ; BRANCH IF STRING VARIABLE
          JSR  LBDD9          ; CONVERT FP NUMBER TO AN ASCII STRING
          JSR  LB516          ; PARSE A STRING FROM (X-1) AND PUT
*                             ; DESCRIPTOR ON STRING STACK
LB938     BSR  LB99F          ; PRINT STRING POINTED TO BY X
          PULS B              ; GET VARIABLE TYPE BACK
          JSR  LA35F          ; SET UP TAB WIDTH ZONE, ETC
LB949     TSTB                ; CHECK CURRENT PRINT POSITION
          BNE  LB954          ; BRANCH IF NOT AT START OF LINE
          JSR  GETCCH         ; GET CURRENT INPUT CHARACTER
          CMPA #',            ; COMMA?
          BEQ  LB966          ; SKIP TO NEXT TAB FIELD
          BSR  LB9AC          ; SEND A SPACE TO CONSOLE OUT
LB954     JSR  GETCCH         ; GET CURRENT INPUT CHARACTER
          BNE  LB91D          ; BRANCH IF NOT END OF LINE
LB958     LDA  #CR            ; * SEND A CR TO
          BRA  LB9B1          ; * CONSOLE OUT
LB95C     JSR  LA35F          ; SET UP TAB WIDTH, ZONE ETC
          BEQ  LB958          ; BRANCH IF WIDTH = ZERO
          LDA  DEVPOS         ; GET PRINT POSITION
          BNE  LB958          ; BRANCH IF NOT AT START OF LINE
LB965     RTS
* SKIP TO NEXT TAB FIELD
LB966     JSR  LA35F          ; SET UP TAB WIDTH, ZONE ETC
          BEQ  LB975          ; BRANCH IF LINE WIDTH = 0 (CASSETTE)
          LDB  DEVPOS         ; GET CURRENT POSITION
          CMPB DEVLCF         ; COMPARE TO LAST TAB ZONE
          BCS  LB977          ; BRANCH IF < LAST TAB ZONE
          BSR  LB958          ; SEND A CARRIAGE RETURN TO CONSOLE OUT
          BRA  LB997          ; GET MORE DATA
LB975     LDB  DEVPOS         ; *
LB977     SUBB DEVCFW         ; * SUBTRACT TAB FIELD WIDTH FROM CURRENT
          BCC  LB977          ; * POSITION UNTIL CARRY SET - NEGATING THE
          NEGB                ; * REMAINDER LEAVES THE NUMBER OF SPACES TO NEXT
*              ; * TAB ZONE IN ACCB
          BRA  LB98E          ; GO ADVANCE TO NEXT TAB ZONE

* PRINT TAB(
LB97E     JSR  LB709          ; EVALUATE EXPRESSION - RETURN VALUE IN B
          CMPA #')            ; * 'SYNTAX' ERROR IF NOT ')'
          LBNE LB277          ; *
          JSR  LA35F          ; SET UP TAB WIDTH, ZONE ETC
          SUBB DEVPOS         ; GET DIFFERENCE OF PRINT POSITION & TAB POSITION
          BLS  LB997          ; BRANCH IF TAB POSITION < CURRENT POSITION
LB98E
LB992     BSR  LB9AC          ; SEND A SPACE TO CONSOLE OUT
          DECB                ; DECREMENT DIFFERENCE COUNT
          BNE  LB992          ; BRANCH UNTIL CURRENT POSITION = TAB POSITION
LB997     JSR  GETNCH         ; GET NEXT CHARACTER FROM BASIC
          JMP  LB91B          ; LOOK FOR MORE PRINT DATA
* COPY A STRING FROM (X) TO CONSOLE OUT
LB99C     JSR  LB518          ; PARSE A STRING FROM X AND PUT
*         DESCRIPTOR ON STRING STACK
LB99F     JSR  LB657          ; GET LENGTH OF STRING AND REMOVE
*         DESCRIPTOR FROM STRING STACK
          INCB                ; COMPENSATE FOR DECB BELOW
LB9A3     DECB                ; DECREMENT COUNTER
          BEQ  LB965          ; EXIT ROUTINE
          LDA  ,X+            ; GET A CHARACTER FROM X
          BSR  LB9B1          ; SEND TO CONSOLE OUT
          BRA  LB9A3          ; KEEP LOOPING
LB9AC     LDA  #SPACE         ; SPACE TO CONSOLE OUT
          FCB  SKP2           ; SKIP NEXT TWO BYTES
LB9AF     LDA  #'?            ; QUESTION MARK TO CONSOLE OUT
LB9B1     JMP  PUTCHR         ; JUMP TO CONSOLE OUT

* FLOATING POINT MATH PACKAGE

* ADD .5 TO FPA0
LB9B4     LDX  #LBEC0         ; FLOATING POINT CONSTANT (.5)
          BRA  LB9C2          ; ADD .5 TO FPA0
* SUBTRACT FPA0 FROM FP NUMBER POINTED
* TO BY (X), LEAVE RESULT IN FPA0
LB9B9     JSR  LBB2F          ; COPY PACKED FP DATA FROM (X) TO FPA1

* ARITHMETIC OPERATION (-) JUMPS HERE - SUBTRACT FPA0 FROM FPA1 (ENTER
* WITH EXPONENT OF FPA0 IN ACCB AND EXPONENT OF FPA1 IN ACCA)
LB9BC     COM  FP0SGN         ; CHANGE MANTISSA SIGN OF FPA0
          COM  RESSGN         ; REVERSE RESULT SIGN FLAG
          BRA  LB9C5          ; GO ADD FPA1 AND FPA0
* ADD FP NUMBER POINTED TO BY
* (X) TO FPA0 - LEAVE RESULT IN FPA0
LB9C2     JSR  LBB2F          ; UNPACK PACKED FP DATA FROM (X) TO
*         FPA1; RETURN EXPONENT OF FPA1 IN ACCA

* ARITHMETIC OPERATION (+) JUMPS HERE - ADD FPA0 TO

LB9C5     TSTB                ; CHECK EXPONENT OF FPA0
          LBEQ LBC4A          ; COPY FPA1 TO FPA0 IF FPA0 =
          LDX  #FP1EXP        ; POINT X TO FPA1
LB9CD     TFR  A,B            ; PUT EXPONENT OF FPA1 INTO ACCB
          TSTB                ; CHECK EXPONENT
          BEQ  LBA3E          ; RETURN IF EXPONENT = 0 (ADDING 0 TO FPA0)
          SUBB FP0EXP         ; SUBTRACT EXPONENT OF FPA0 FROM EXPONENT OF FPA1
          BEQ  LBA3F          ; BRANCH IF EXPONENTS ARE EQUAL
          BCS  LB9E2          ; BRANCH IF EXPONENT FPA0 > FPA1
          STA  FP0EXP         ; REPLACE FPA0 EXPONENT WITH FPA1 EXPONENT
          LDA  FP1SGN         ; * REPLACE FPA0 MANTISSA SIGN
          STA  FP0SGN         ; * WITH FPA1 MANTISSA SIGN
          LDX  #FP0EXP        ; POINT X TO FPA0
          NEGB                ; NEGATE DIFFERENCE OF EXPONENTS
LB9E2     CMPB #-8            ; TEST DIFFERENCE OF EXPONENTS
          BLE  LBA3F          ; BRANCH IF DIFFERENCE OF EXPONENTS <= 8
          CLRA                ; CLEAR OVERFLOW BYTE
          LSR  1,X            ; SHIFT MS BYTE OF MANTISSA; BIT 7 = 0
          JSR  LBABA          ; GO SHIFT MANTISSA OF (X) TO THE RIGHT (B) TIMES
LB9EC     LDB  RESSGN         ; GET SIGN FLAG
          BPL  LB9FB          ; BRANCH IF FPA0 AND FPA1 SIGNS ARE THE SAME
          COM  1,X            ; * COMPLEMENT MANTISSA POINTED
          COM  2,X            ; * TO BY (X) THE
          COM  3,X            ; * ADCA BELOW WILL
          COM  4,X            ; * CONVERT THIS OPERATION
          COMA                ; * INTO A NEG (MANTISSA)
          ADCA #0             ; ADD ONE TO ACCA - COMA ALWAYS SETS THE CARRY FLAG
* THE PREVIOUS TWO BYTES MAY BE REPLACED BY A NEGA
*
* ADD MANTISSAS OF FPA0 AND FPA1, PUT RESULT IN FPA0
LB9FB     STA  FPSBYT         ; SAVE FPA SUB BYTE
          LDA  FPA0+3         ; * ADD LS BYTE
          ADCA FPA1+3         ; * OF MANTISSA
          STA  FPA0+3         ; SAVE IN FPA0 LSB
          LDA  FPA0+2         ; * ADD NEXT BYTE
          ADCA FPA1+2         ; * OF MANTISSA
          STA  FPA0+2         ; SAVE IN FPA0
          LDA  FPA0+1         ; * ADD NEXT BYTE
          ADCA FPA1+1         ; * OF MANTISSA
          STA  FPA0+1         ; SAVE IN FPA0
          LDA  FPA0           ; * ADD MS BYTE
          ADCA FPA1           ; * OF MANTISSA
          STA  FPA0           ; SAVE IN FPA0
          TSTB                ; TEST SIGN FLAG
          BPL  LBA5C          ; BRANCH IF FPA0 & FPA1 SIGNS WERE ALIKE
LBA18     BCS  LBA1C          ; BRANCH IF POSITIVE MANTISSA
          BSR  LBA79          ; NEGATE FPA0 MANTISSA

* NORMALIZE FPA0
LBA1C     CLRB                ; CLEAR TEMPORARY EXPONENT ACCUMULATOR
LBA1D     LDA  FPA0           ; TEST MSB OF MANTISSA
          BNE  LBA4F          ; BRANCH IF <> 0
          LDA  FPA0+1         ; * IF THE MSB IS
          STA  FPA0           ; * 0, THEN SHIFT THE
          LDA  FPA0+2         ; * MANTISSA A WHOLE BYTE
          STA  FPA0+1         ; * AT A TIME. THIS
          LDA  FPA0+3         ; * IS FASTER THAN ONE
          STA  FPA0+2         ; * BIT AT A TIME
          LDA  FPSBYT         ; * BUT USES MORE MEMORY.
          STA  FPA0+3         ; * FPSBYT, THE CARRY IN
          CLR  FPSBYT         ; * BYTE, REPLACES THE MATISSA LSB.
          ADDB #8             ; SHIFTING ONE BYTE = 8 BIT SHIFTS; ADD 8 TO EXPONENT
          CMPB #5*8           ; CHECK FOR 5 SHIFTS
          BLT  LBA1D          ; BRANCH IF < 5 SHIFTS, IF > 5, THEN MANTISSA = 0
LBA39     CLRA                ; A ZERO EXPONENT = 0 FLOATING POINT
LBA3A     STA  FP0EXP         ; ZERO OUT THE EXPONENT
          STA  FP0SGN         ; ZERO OUT THE MANTISSA SIGN
LBA3E     RTS
LBA3F     BSR  LBAAE          ; SHIFT FPA0 MANTISSA TO RIGHT
          CLRB                ; CLEAR CARRY FLAG
          BRA  LB9EC
* SHIFT FPA0 LEFT ONE BIT UNTIL BIT 7
* OF MATISSA MS BYTE = 1
LBA44     INCB                ; ADD ONE TO EXPONENT ACCUMULATOR
          ASL  FPSBYT         ; SHIFT SUB BYTE ONE LEFT
          ROL  FPA0+3         ; SHIFT LS BYTE
          ROL  FPA0+2         ; SHIFT NS BYTE
          ROL  FPA0+1         ; SHIFT NS BYTE
          ROL  FPA0           ; SHIFT MS BYTE
LBA4F     BPL  LBA44          ; BRANCH IF NOT YET NORMALIZED
          LDA  FP0EXP         ; GET CURRENT EXPONENT
          PSHS B              ; SAVE EXPONENT MODIFIER CAUSED BY NORMALIZATION
          SUBA ,S+            ; SUBTRACT ACCUMULATED EXPONENT MODIFIER
          STA  FP0EXP         ; SAVE AS NEW EXPONENT
          BLS  LBA39          ; SET FPA0 = 0 IF THE NORMALIZATION CAUSED
*         MORE OR EQUAL NUMBER OF LEFT SHIFTS THAN THE
*         SIZE OF THE EXPONENT
          FCB  SKP2           ; SKIP 2 BYTES
LBA5C     BCS  LBA66          ; BRANCH IF MANTISSA OVERFLOW
          ASL  FPSBYT         ; SUB BYTE BIT 7 TO CARRY - USE AS ROUND-OFF
*                             ; FLAG (TRUNCATE THE REST OF SUB BYTE)
          LDA  #0             ; CLRA, BUT DO NOT CHANGE CARRY FLAG
          STA  FPSBYT         ; CLEAR THE SUB BYTE
          BRA  LBA72          ; GO ROUND-OFF RESULT
LBA66     INC  FP0EXP         ; INCREMENT EXPONENT - MULTIPLY BY 2
          BEQ  LBA92          ; OVERFLOW ERROR IF CARRY PAST $FF
          ROR  FPA0           ; * SHIFT MANTISSA
          ROR  FPA0+1         ; * ONE TO
          ROR  FPA0+2         ; * THE RIGHT -
          ROR  FPA0+3         ; * DIVIDE BY TWO
LBA72     BCC  LBA78          ; BRANCH IF NO ROUND-OFF NEEDED
          BSR  LBA83          ; ADD ONE TO MANTISSA - ROUND OFF
          BEQ  LBA66          ; BRANCH iF OVERFLOW - MANTISSA = 0
LBA78     RTS
* NEGATE FPA0 MANTISSA
LBA79     COM  FP0SGN         ; TOGGLE SIGN OF MANTISSA
LBA7B     COM  FPA0           ; * COMPLEMENT ALL 4 MANTISSA BYTES
          COM  FPA0+1         ; *
          COM  FPA0+2         ; *
          COM  FPA0+3         ; *
* ADD ONE TO FPA0 MANTISSA
LBA83     LDX  FPA0+2         ; * GET BOTTOM 2 MANTISSA
          LEAX 1,X            ; * BYTES, ADD ONE TO
          STX  FPA0+2         ; * THEM AND SAVE THEM
          BNE  LBA91          ; BRANCH IF NO OVERFLOW
          LDX  FPA0           ; * IF OVERFLOW ADD ONE
          LEAX 1,X            ; * TO TOP 2 MANTISSA
          STX  FPA0           ; * BYTES AND SAVE THEM
LBA91     RTS
LBA92     LDB  #2*5           ; OV' OVERFLOW ERROR
          JMP  LAC46          ; PROCESS AN ERROR
LBA97     LDX  #FPA2-1        ; POINT X TO FPA2
* SHIFT FPA POINTED TO BY (X) TO
* THE RIGHT -(B) TIMES. EXIT WITH
* ACCA CONTAINING DATA SHIFTED OUT
* TO THE RIGHT (SUB BYTE) AND THE DATA
* SHIFTED IN FROM THE LEFT WILL COME FROM FPCARY
LBA9A     LDA  4,X            ; GET LS BYTE OF MANTISSA (X)
          STA  FPSBYT         ; SAVE IN FPA SUB BYTE
          LDA  3,X            ; * SHIFT THE NEXT THREE BYTES OF THE
          STA  4,X            ; * MANTISSA RIGHT ONE COMPLETE BYTE.
          LDA  2,X            ; *
          STA  3,X            ; *
          LDA  1,X            ; *
          STA  2,X            ; *
          LDA  FPCARY         ; GET THE CARRY IN BYTE
          STA  1,X            ; STORE AS THE MS MANTISSA BYTE OF (X)
LBAAE     ADDB #8             ; ADD 8 TO DIFFERENCE OF EXPONENTS
          BLE  LBA9A          ; BRANCH IF EXPONENT DIFFERENCE < -8
          LDA  FPSBYT         ; GET FPA SUB BYTE
          SUBB #8             ; CAST OUT THE 8 ADDED IN ABOVE
          BEQ  LBAC4          ; BRANCH IF EXPONENT DIFFERENCE = 0


LBAB8     ASR  1,X            ; * SHIFT MANTISSA AND SUB BYTE ONE BIT TO THE RIGHT
LBABA     ROR  2,X            ; *
          ROR  3,X            ; *
          ROR  4,X            ; *
          RORA                ; *
          INCB                ; ADD ONE TO EXPONENT DIFFERENCE
          BNE  LBAB8          ; BRANCH IF EXPONENTS NOT =
LBAC4     RTS
LBAC5     FCB  $81,$00,$00,$00,$00 ; FLOATING POINT CONSTANT 1.0

* ARITHMETIC OPERATION (*) JUMPS HERE - MULTIPLY
* FPA0 BY (X) - RETURN PRODUCT IN FPA0
LBACA     BSR  LBB2F          ; MOVE PACKED FPA FROM (X) TO FPA1
LBACC     BEQ  LBB2E          ; BRANCH IF EXPONENT OF FPA0 = 0
          BSR  LBB48          ; CALCULATE EXPONENT OF PRODUCT
* MULTIPLY FPA0 MANTISSA BY FPA1. NORMALIZE
* HIGH ORDER BYTES OF PRODUCT IN FPA0. THE
* LOW ORDER FOUR BYTES OF THE PRODUCT WILL
* BE STORED IN VAB-VAE.
LBAD0     LDA  #0             ; * ZERO OUT MANTISSA OF FPA2
          STA  FPA2           ; *
          STA  FPA2+1         ; *
          STA  FPA2+2         ; *
          STA  FPA2+3         ; *
          LDB  FPA0+3         ; GET LS BYTE OF FPA0
          BSR  LBB00          ; MULTIPLY BY FPA1
          LDB  FPSBYT         ; * TEMPORARILY SAVE SUB BYTE 4
          STB  VAE            ; *
          LDB  FPA0+2         ; GET NUMBER 3 MANTISSA BYTE OF FPA0
          BSR  LBB00          ; MULTIPLY BY FPA1
          LDB  FPSBYT         ; * TEMPORARILY SAVE SUB BYTE 3
          STB  VAD            ; *
          LDB  FPA0+1         ; GET NUMBER 2 MANTISSA BYTE OF FPA0
          BSR  LBB00          ; MULTIPLY BY FPA1
          LDB  FPSBYT         ; * TEMPORARILY SAVE SUB BYTE 2
          STB  VAC            ; *
          LDB  FPA0           ; GET MS BYTE OF FPA0 MANTISSA
          BSR  LBB02          ; MULTIPLY BY FPA1
          LDB  FPSBYT         ; * TEMPORARILY SAVE SUB BYTE 1
          STB  VAB            ; *
          JSR  LBC0B          ; COPY MANTISSA FROM FPA2 TO FPA0
          JMP  LBA1C          ; NORMALIZE FPA0
LBB00     BEQ  LBA97          ; SHIFT FPA2 ONE BYTE TO RIGHT
LBB02     COMA                ; SET CARRY FLAG
* MULTIPLY FPA1 MANTISSA BY ACCB AND
* ADD PRODUCT TO FPA2 MANTISSA
LBB03     LDA  FPA2           ; GET FPA2 MS BYTE
          RORB                ; ROTATE CARRY FLAG INTO SHIFT COUNTER;
*         DATA BIT INTO CARRY
          BEQ  LBB2E          ; BRANCH WHEN 8 SHIFTS DONE
          BCC  LBB20          ; DO NOT ADD FPA1 IF DATA BIT = 0
          LDA  FPA2+3         ; * ADD MANTISSA LS BYTE
          ADDA FPA1+3         ; *
          STA  FPA2+3         ; *
          LDA  FPA2+2         ; = ADD MANTISSA NUMBER 3 BYTE
          ADCA FPA1+2         ; =
          STA  FPA2+2         ; =
          LDA  FPA2+1         ; * ADD MANTISSA NUMBER 2 BYTE
          ADCA FPA1+1         ; *
          STA  FPA2+1         ; *
          LDA  FPA2           ; = ADD MANTISSA MS BYTE
          ADCA FPA1           ; =
LBB20     RORA                ; * ROTATE CARRY INTO MS BYTE
          STA  FPA2           ; *
          ROR  FPA2+1         ; = ROTATE FPA2 ONE BIT TO THE RIGHT
          ROR  FPA2+2         ; =
          ROR  FPA2+3         ; =
          ROR  FPSBYT         ; =
          CLRA                ; CLEAR CARRY FLAG
          BRA  LBB03          ; KEEP LOOPING
LBB2E     RTS
* UNPACK A FP NUMBER FROM (X) TO FPA1
LBB2F     LDD  1,X            ; GET TWO MSB BYTES OF MANTISSA FROM
*         FPA  POINTED TO BY X
          STA  FP1SGN         ; SAVE PACKED MANTISSA SIGN BYTE
          ORA  #$80           ; FORCE BIT 7 OF MSB MANTISSA = 1
          STD  FPA1           ; SAVE 2 MSB BYTES IN FPA1
          LDB  FP1SGN         ; * GET PACKED MANTISSA SIGN BYTE. EOR W/FPA0
          EORB FP0SGN         ; * SIGN - NEW SIGN POSITION IF BOTH OLD SIGNS ALIKE,
          STB  RESSGN         ; * NEG IF BOTH OLD SIGNS DIFF. SAVE ADJUSTED
*                             ; * MANTISSA SIGN BYTE
          LDD  3,X            ; = GET 2 LSB BYTES OF MANTISSA
          STD  FPA1+2         ; = AND PUT IN FPA1
          LDA  ,X             ; * GET EXPONENT FROM (X) AND
          STA  FP1EXP         ; * PUT IN EXPONENT OF FPA1
          LDB  FP0EXP         ; GET EXPONENT OF FPA0
          RTS
* CALCULATE EXPONENT FOR PRODUCT OF FPA0 & FPA1
* ENTER WITH EXPONENT OF FPA1 IN ACCA
LBB48     TSTA                ; TEST EXPONENT OF FPA1
          BEQ  LBB61          ; PURGE RETURN ADDRESS & SET FPA0 = 0
          ADDA FP0EXP         ; ADD FPA1 EXPONENT TO FPA0 EXPONENT
          RORA                ; ROTATE CARRY INTO BIT 7; BIT 0 INTO CARRY
          ROLA                ; SET OVERFLOW FLAG
          BVC  LBB61          ; BRANCH IF EXPONENT TOO LARGE OR SMALL
          ADDA #$80           ; ADD $80 BIAS TO EXPONENT
          STA  FP0EXP         ; SAVE NEW EXPONENT
          BEQ  LBB63          ; SET FPA0
          LDA  RESSGN         ; GET MANTISSA SIGN
          STA  FP0SGN         ; SAVE AS MANTISSA SIGN OF FPA0
          RTS
* IF FPA0 = POSITIVE THEN 'OV' ERROR IF FPA0
* = IS NEGATIVE THEN FPA0 = 0
LBB5C     LDA  FP0SGN         ; GET MANTISSA SIGN OF FPA0
          COMA                ; CHANGE SIGN OF FPA0 MANTISSA
          BRA  LBB63
LBB61     LEAS 2,S            ; PURGE RETURN ADDRESS FROM STACK
LBB63     LBPL LBA39          ; ZERO FPA0 MANTISSA SIGN & EXPONENT
LBB67     JMP  LBA92          ; 'OV' OVERFLOW ERROR
* FAST MULTIPLY BY 10 AND LEAVE RESULT IN FPA0
LBB6A     JSR  LBC5F          ; TRANSFER FPA0 TO FPA1
          BEQ  LBB7C          ; BRANCH IF EXPONENT = 0
          ADDA #2             ; ADD 2 TO EXPONENT (TIMES 4)
          BCS  LBB67          ; 'OV' ERROR IF EXPONENT > $FF
          CLR  RESSGN         ; CLEAR RESULT SIGN BYTE
          JSR  LB9CD          ; ADD FPA1 TO FPA0 (TIMES 5)
          INC  FP0EXP         ; ADD ONE TO EXPONENT (TIMES 10)
          BEQ  LBB67          ; 'OV' ERROR IF EXPONENT > $FF
LBB7C     RTS
LBB7D     FCB  $84,$20,$00,$00,$00 ; FLOATING POINT CONSTANT 10
* DIVIDE FPA0 BY 10
LBB82     JSR  LBC5F          ; MOVE FPA0 TO FPA1
          LDX  #LBB7D         ; POINT TO FLOATING POINT CONSTANT 10
          CLRB                ; ZERO MANTISSA SIGN BYTE
LBB89     STB  RESSGN         ; STORE THE QUOTIENT MANTISSA SIGN BYTE
          JSR  LBC14          ; UNPACK AN FP NUMBER FROM (X) INTO FPA0
          FCB  SKP2           ; SKIP TWO BYTES
* DIVIDE (X) BY FPA0-LEAVE NORMALIZED QUOTIENT IN FPA0
LBB8F     BSR  LBB2F          ; GET FP NUMBER FROM (X) TO FPA1

* ARITHMETIC OPERATION (/) JUMPS HERE. DIVIDE FPA1 BY FPA0 (ENTER WITH
* EXPONENT OF FPA1 IN ACCA AND FLAGS SET BY TSTA)

* DIVIDE FPA1 BY FPA0
LBB91     BEQ  LBC06          ; '/0' DIVIDE BY ZERO ERROR
          NEG  FP0EXP         ; GET EXPONENT OF RECIPROCAL OF DIVISOR
          BSR  LBB48          ; CALCULATE EXPONENT OF QUOTIENT
          INC  FP0EXP         ; INCREMENT EXPONENT
          BEQ  LBB67          ; 'OV' OVERFLOW ERROR
          LDX  #FPA2          ; POINT X TO MANTISSA OF FPA2 - HOLD
*                             ; TEMPORARY QUOTIENT IN FPA2
          LDB  #4             ; 5 BYTE DIVIDE
          STB  TMPLOC         ; SAVE BYTE COUNTER
          LDB  #1             ; SHIFT COUNTER-AND TEMPORARY QUOTIENT BYTE
* COMPARE FPA0 MANTISSA TO FPA1 MANTISSA -
* SET CARRY FLAG IF FPA1 >= FPA0
LBBA4     LDA  FPA0           ; * COMPARE THE TWO MS BYTES
          CMPA FPA1           ; * OF FPA0 AND FPA1 AND
          BNE  LBBBD          ; * BRANCH IF <>
          LDA  FPA0+1         ; = COMPARE THE NUMBER 2
          CMPA FPA1+1         ; = BYTES AND
          BNE  LBBBD          ; = BRANCH IF <>
          LDA  FPA0+2         ; * COMPARE THE NUMBER 3
          CMPA FPA1+2         ; * BYTES AND
          BNE  LBBBD          ; * BRANCH IF <>
          LDA  FPA0+3         ; = COMPARE THE LS BYTES
          CMPA FPA1+3         ; = AND BRANCH
          BNE  LBBBD          ; = IF <>
          COMA                ; SET CARRY FLAG IF FPA0 = FPA1
LBBBD     TFR  CC,A           ; SAVE CARRY FLAG STATUS IN ACCA; CARRY
*         CLEAR IF FPA0 > FPA1
          ROLB                ; ROTATE CARRY INTO TEMPORARY QUOTIENT BYTE
          BCC  LBBCC          ; CARRY WILL BE SET AFTER 8 SHIFTS
          STB  ,X+            ; SAVE TEMPORARY QUOTIENT
          DEC  TMPLOC         ; DECREMENT BYTE COUNTER
          BMI  LBBFC          ; BRANCH IF DONE
          BEQ  LBBF8          ; BRANCH IF LAST BYTE
          LDB  #1             ; RESET SHIFT COUNTER AND TEMPORARY QUOTIENT BYTE
LBBCC     TFR  A,CC           ; RESTORE CARRY FLAG AND
          BCS  LBBDE          ; BRANCH IF FPA0 =< FPA1
LBBD0     ASL  FPA1+3         ; * SHIFT FPA1 MANTISSA 1 BIT TO LEFT
          ROL  FPA1+2         ; *
          ROL  FPA1+1         ; *
          ROL  FPA1           ; *
          BCS  LBBBD          ; BRANCH IF CARRY - ADD ONE TO PARTIAL QUOTIENT
          BMI  LBBA4          ; IF MSB OF HIGH ORDER MANTISSA BYTE IS
*         SET, CHECK THE MAGNITUDES OF FPA0, FPA1
          BRA  LBBBD          ; CARRY IS CLEAR, CHECK ANOTHER BIT
* SUBTRACT FPA0 FROM FPA1 - LEAVE RESULT IN FPA1
LBBDE     LDA  FPA1+3         ; * SUBTRACT THE LS BYTES OF MANTISSA
          SUBA FPA0+3         ; *
          STA  FPA1+3         ; *
          LDA  FPA1+2         ; = THEN THE NEXT BYTE
          SBCA FPA0+2         ; =
          STA  FPA1+2         ; =
          LDA  FPA1+1         ; * AND THE NEXT
          SBCA FPA0+1         ; *
          STA  FPA1+1         ; *
          LDA  FPA1           ; = AND FINALLY, THE MS BYTE OF MANTISSA
          SBCA FPA0           ; =
          STA  FPA1           ; =
          BRA  LBBD0          ; GO SHIFT FPA1
LBBF8     LDB  #$40           ; USE ONLY TWO BITS OF THE LAST BYTE (FIFTH)
          BRA  LBBCC          ; GO SHIFT THE LAST BYTE
LBBFC     RORB                ; * SHIFT CARRY (ALWAYS SET HERE) INTO
          RORB                ; * BIT 5 AND MOVE
          RORB                ; * BITS 1,0 TO BITS 7,6
          STB  FPSBYT         ; SAVE SUB BYTE
          BSR  LBC0B          ; MOVE MANTISSA OF FPA2 TO FPA0
          JMP  LBA1C          ; NORMALIZE FPA0
LBC06     LDB  #2*10          ; /0' ERROR
          JMP  LAC46          ; PROCESS THE ERROR
* COPY MANTISSA FROM FPA2 TO FPA0
LBC0B     LDX  FPA2           ; * MOVE TOP 2 BYTES
          STX  FPA0           ; *
          LDX  FPA2+2         ; = MOVE BOTTOM 2 BYTES
          STX  FPA0+2         ; =
          RTS
* COPY A PACKED FP NUMBER FROM (X) TO FPA0
LBC14     PSHS A              ; SAVE ACCA
          LDD  1,X            ; GET TOP TWO MANTISSA BYTES
          STA  FP0SGN         ; SAVE MS BYTE OF MANTISSA AS MANTISSA SIGN
          ORA  #$80           ; UNPACK MS BYTE
          STD  FPA0           ; SAVE UNPACKED TOP 2 MANTISSA BYTES
          CLR  FPSBYT         ; CLEAR MANTISSA SUB BYTE
          LDB  ,X             ; GET EXPONENT TO ACCB
          LDX  3,X            ; * MOVE LAST 2
          STX  FPA0+2         ; * MANTISSA BYTES
          STB  FP0EXP         ; SAVE EXPONENT
          PULS A,PC           ; RESTORE ACCA AND RETURN

LBC2A     LDX  #V45           ; POINT X TO MANTISSA OF FPA4
          BRA  LBC35          ; MOVE FPA0 TO FPA4
LBC2F     LDX  #V40           ; POINT X TO MANTISSA OF FPA3
          FCB  SKP2           ; SKIP TWO BYTES
LBC33     LDX  VARDES         ; POINT X TO VARIABLE DESCRIPTOR IN VARDES
* PACK FPA0 AND MOVE IT TO ADDRESS IN X
LBC35     LDA  FP0EXP         ; * COPY EXPONENT
          STA  ,X             ; *
          LDA  FP0SGN         ; GET MANTISSA SIGN BIT
          ORA  #$7F           ; MASK THE BOTTOM 7 BITS
          ANDA FPA0           ; AND BIT 7 OF MANTISSA SIGN INTO BIT 7 OF MS BYTE
          STA  1,X            ; SAVE MS BYTE
          LDA  FPA0+1         ; * MOVE 2ND MANTISSA BYTE
          STA  2,X            ; *
          LDU  FPA0+2         ; = MOVE BOTTOM 2 MANTISSA BYTES
          STU  3,X            ; =
          RTS
* MOVE FPA1 TO FPA0 RETURN W/MANTISSA SIGN IN ACCA
LBC4A     LDA  FP1SGN         ; * COPY MANTISSA SIGN FROM
LBC4C     STA  FP0SGN         ; * FPA1 TO FPA0
          LDX  FP1EXP         ; = COPY EXPONENT + MS BYTE FROM
          STX  FP0EXP         ; = FPA1 TO FPA0
          CLR  FPSBYT         ; CLEAR MANTISSA SUB BYTE
          LDA  FPA1+1         ; * COPY 2ND MANTISSA BYTE
          STA  FPA0+1         ; * FROM FPA1 TO FPA0
          LDA  FP0SGN         ; GET MANTISSA SIGN
          LDX  FPA1+2         ; * COPY 3RD AND 4TH MANTISSA BYTE
          STX  FPA0+2         ; * FROM FPA1 TO FPA0
          RTS
* TRANSFER FPA0 TO FPA1
LBC5F     LDD  FP0EXP         ; * TRANSFER EXPONENT & MS BYTE
          STD  FP1EXP         ; *
          LDX  FPA0+1         ; = TRANSFER MIDDLE TWO BYTES
          STX  FPA1+1         ; =
          LDX  FPA0+3         ; * TRANSFER BOTTOM TWO BYTES
          STX  FPA1+3         ; *
          TSTA                ; SET FLAGS ACCORDING TO EXPONENT
          RTS
* CHECK FPA0; RETURN ACCB = 0 IF FPA0 = 0,
* ACCB = $FF IF FPA0 = NEGATIVE, ACCB = 1 IF FPA0 = POSITIVE
LBC6D     LDB  FP0EXP         ; GET EXPONENT
          BEQ  LBC79          ; BRANCH IF FPA0 = 0
LBC71     LDB  FP0SGN         ; GET SIGN OF MANTISSA
LBC73     ROLB                ; BIT 7 TO CARRY
          LDB  #$FF           ; NEGATIVE FLAG
          BCS  LBC79          ; BRANCH IF NEGATIVE MANTISSA
          NEGB                ; ACCB = 1 IF POSITIVE MANTISSA
LBC79     RTS

* SGN
SGN       BSR  LBC6D          ; SET ACCB ACCORDING TO SIGN OF FPA0
* CONVERT A SIGNED NUMBER IN ACCB INTO A FLOATING POINT NUMBER
LBC7C     STB  FPA0           ; SAVE ACCB IN FPA0
          CLR  FPA0+1         ; CLEAR NUMBER 2 MANTISSA BYTE OF FPA0
          LDB  #$88           ; EXPONENT REQUIRED IF FPA0 IS TO BE AN INTEGER
LBC82     LDA  FPA0           ; GET MS BYTE OF MANTISSA
          SUBA #$80           ; SET CARRY IF POSITIVE MANTISSA
LBC86     STB  FP0EXP         ; SAVE EXPONENT
          LDD  ZERO           ; * ZERO OUT ACCD AND
          STD  FPA0+2         ; * BOTTOM HALF OF FPA0
          STA  FPSBYT         ; CLEAR SUB BYTE
          STA  FP0SGN         ; CLEAR SIGN OF FPA0 MANTISSA
          JMP  LBA18          ; GO NORMALIZE FPA0

* ABS
ABS       CLR  FP0SGN         ; FORCE MANTISSA SIGN OF FPA0 POSITIVE
          RTS
* COMPARE A PACKED FLOATING POINT NUMBER POINTED TO
* BY (X) TO AN UNPACKED FP NUMBER IN FPA0. RETURN
* ZERO FLAG SET AND ACCB = 0, IF EQUAL; ACCB = 1 IF
* FPA0 > (X); ACCB = $FF IF FPA0 < (X)
LBC96     LDB  ,X             ; CHECK EXPONENT OF (X)
          BEQ  LBC6D          ; BRANCH IF FPA = 0
          LDB  1,X            ; GET MS BYTE OF MANTISSA OF (X)
          EORB FP0SGN         ; EOR WITH SIGN OF FPA0
          BMI  LBC71          ; BRANCH IF SIGNS NOT =
* COMPARE FPA0 WITH FP NUMBER POINTED TO BY (X).
* FPA0 IS NORMALIZED, (X) IS PACKED.
LBCA0     LDB  FP0EXP         ; * GET EXPONENT OF
          CMPB ,X             ; * FPA0, COMPARE TO EXPONENT OF
          BNE  LBCC3          ; * (X) AND BRANCH IF <>.
          LDB  1,X            ; * GET MS BYTE OF (X), KEEP ONLY
          ORB  #$7F           ; * THE SIGN BIT - 'AND' THE BOTTOM 7
          ANDB FPA0           ; * BITS OF FPA0 INTO ACCB
          CMPB 1,X            ; = COMPARE THE BOTTOM 7 BITS OF THE MANTISSA
          BNE  LBCC3          ; = MS BYTE AND BRANCH IF <>
          LDB  FPA0+1         ; * COMPARE 2ND BYTE
          CMPB 2,X            ; * OF MANTISSA,
          BNE  LBCC3          ; * BRANCH IF <>
          LDB  FPA0+2         ; = COMPARE 3RD BYTE
          CMPB 3,X            ; = OF MANTISSA,
          BNE  LBCC3          ; = BRANCH IF <>
          LDB  FPA0+3         ; * SUBTRACT LS BYTE
          SUBB 4,X            ; * OF (X) FROM LS BYTE OF
          BNE  LBCC3          ; * FPA0, BRANCH IF <>
          RTS                 ; RETURN IF FP (X) = FPA0
LBCC3     RORB                ; SHIFT CARRY TO BIT 7; CARRY SET IF FPA0 < (X)
          EORB FP0SGN         ; TOGGLE SIZE COMPARISON BIT IF FPA0 IS NEGATIVE
          BRA  LBC73          ; GO SET ACCB ACCORDING TO COMPARISON
* DE-NORMALIZE FPA0 : SHIFT THE MANTISSA UNTIL THE BINARY POINT IS TO THE RIGHT
* OF THE LEAST SIGNIFICANT BYTE OF THE MANTISSA
LBCC8     LDB  FP0EXP         ; GET EXPONENT OF FPA0
          BEQ  LBD09          ; ZERO MANTISSA IF FPA0 = 0
          SUBB #$A0           ; SUBTRACT $A0 FROM FPA0 EXPONENT T THIS WILL YIELD
*                             ; THE NUMBER OF SHIFTS REQUIRED TO DENORMALIZE FPA0. WHEN
*                             ; THE EXPONENT OF FPA0 IS = ZERO, THEN THE BINARY POINT
*                             ; WILL BE TO THE RIGHT OF THE MANTISSA
          LDA  FP0SGN         ; TEST SIGN OF FPA0 MANTISSA
          BPL  LBCD7          ; BRANCH IF POSITIVE
          COM  FPCARY         ; COMPLEMENT CARRY IN BYTE
          JSR  LBA7B          ; NEGATE MANTISSA OF FPA0
LBCD7     LDX  #FP0EXP        ; POINT X TO FPA0
          CMPB #-8            ; EXPONENT DIFFERENCE < -8?
          BGT  LBCE4          ; YES
          JSR  LBAAE          ; SHIFT FPA0 RIGHT UNTIL FPA0 EXPONENT = $A0
          CLR  FPCARY         ; CLEAR CARRY IN BYTE
          RTS
LBCE4     CLR  FPCARY         ; CLEAR CARRY IN BYTE
          LDA  FP0SGN         ; * GET SIGN OF FPA0 MANTISSA
          ROLA                ; * ROTATE IT INTO THE CARRY FLAG
          ROR  FPA0           ; ROTATE CARRY (MANTISSA SIGN) INTO BIT 7
*                             ; OF LS BYTE OF MANTISSA
          JMP  LBABA          ; DE-NORMALIZE FPA0

* INT
* THE INT STATEMENT WILL "DENORMALIZE" FPA0 - THAT IS IT WILL SHIFT THE BINARY POINT
* TO THE EXTREME RIGHT OF THE MANTISSA TO FORCE ITS EXPONENT TO BE $AO. ONCE
* THIS IS DONE THE MANTISSA OF FPA0 WILL CONTAIN THE FOUR LEAST SIGNIFICANT
* BYTES OF THE INTEGER PORTION OF FPA0. AT THE CONCLUSION OF THE DE-NORMALIZATION
* ONLY THE INTEGER PORTION OF FPA0 WILL REMAIN.
*
INT       LDB  FP0EXP         ; GET EXPONENT OF FPA0
          CMPB #$A0           ; LARGEST POSSIBLE INTEGER EXPONENT
          BCC  LBD11          ; RETURN IF FPA0 >= 32768
          BSR  LBCC8          ; SHIFT THE BINARY POINT ONE TO THE RIGHT OF THE
*                             ; LS BYTE OF THE FPA0 MANTISSA
          STB  FPSBYT         ; ACCB = 0: ZERO OUT THE SUB BYTE
          LDA  FP0SGN         ; GET MANTISSA SIGN
          STB  FP0SGN         ; FORCE MANTISSA SIGN TO BE POSITIVE
          SUBA #$80           ; SET CARRY IF MANTISSA
          LDA  #$A0           ; * GET DENORMALIZED EXPONENT AND
          STA  FP0EXP         ; * SAVE IT IN FPA0 EXPONENT
          LDA  FPA0+3         ; = GET LS BYTE OF FPA0 AND
          STA  CHARAC         ; = SAVE IT IN CHARAC
          JMP  LBA18          ; NORMALIZE FPA0

LBD09     STB  FPA0           ; * LOAD MANTISSA OF FPA0 WITH CONTENTS OF ACCB
          STB  FPA0+1         ; *
          STB  FPA0+2         ; *
          STB  FPA0+3         ; *
LBD11     RTS                 ; *

* CONVERT ASCII STRING TO FLOATING POINT
LBD12     LDX  ZERO           ; (X) = 0
          STX  FP0SGN         ; * ZERO OUT FPA0 & THE SIGN FLAG (COEFCT)
          STX  FP0EXP         ; *
          STX  FPA0+1         ; *
          STX  FPA0+2         ; *
          STX  V47            ; INITIALIZE EXPONENT & EXPONENT SIGN FLAG TO ZERO
          STX  V45            ; INITIALIZE RIGHT DECIMAL CTR & DECIMAL PT FLAG TO 0
          BCS  LBD86          ; IF CARRY SET (NUMERIC CHARACTER), ASSUME ACCA CONTAINS FIRST
*         NUMERIC CHAR, SIGN IS POSITIVE AND SKIP THE RAM HOOK
          JSR  XVEC19         ; CALL EXTENDED BASIC ADD-IN
LBD25     CMPA #'-            ; * CHECK FOR A LEADING MINUS SIGN AND BRANCH
          BNE  LBD2D          ; * IF NO MINUS SIGN
          COM  COEFCT         ; TOGGLE SIGN; 0 = +; FF = -
          BRA  LBD31          ; INTERPRET THE REST OF THE STRING
LBD2D     CMPA #'+            ; * CHECK FOR LEADING PLUS SlGN AND BRANCH
          BNE  LBD35          ; * IF NOT A PLUS SIGN
LBD31     JSR  GETNCH         ; GET NEXT INPUT CHARACTER FROM BASIC
          BCS  LBD86          ; BRANCH IF NUMERIC CHARACTER
LBD35     CMPA #'.            ; DECIMAL POlNT?
          BEQ  LBD61          ; YES
          CMPA #'E            ; "E" SHORTHAND FORM (SCIENTIFIC NOTATION)?
          BNE  LBD65          ; NO
* EVALUATE EXPONENT OF EXPONENTIAL FORMAT
          JSR  GETNCH         ; GET NEXT INPUT CHARACTER FROM BASIC
          BCS  LBDA5          ; BRANCH IF NUMERIC
          CMPA #TOK_MINUS     ; MINUS TOKEN?
          BEQ  LBD53          ; YES
          CMPA #'-            ; ASCII MINUS?
          BEQ  LBD53          ; YES
          CMPA #TOK_PLUS      ; PLUS TOKEN?
          BEQ  LBD55          ; YES
          CMPA #'+            ; ASCII PLUS?
          BEQ  LBD55          ; YES
          BRA  LBD59          ; BRANCH IF NO SIGN FOUND
LBD53     COM  V48            ; SET EXPONENT SIGN FLAG TO NEGATIVE
* STRIP A DECIMAL NUMBER FROM BASIC LINE, CONVERT IT TO BINARY IN V47
LBD55     JSR  GETNCH         ; GET NEXT INPUT CHARACTER FROM BASIC
          BCS  LBDA5          ; IF NUMERIC CHARACTER, CONVERT TO BINARY
LBD59     TST  V48            ; * CHECK EXPONENT SIGN FLAG
          BEQ  LBD65          ; * AND BRANCH IF POSITIVE
          NEG  V47            ; NEGATE VALUE OF EXPONENT
          BRA  LBD65
LBD61     COM  V46            ; *TOGGLE DECIMAL PT FLAG AND INTERPRET ANOTHER
          BNE  LBD31          ; *CHARACTER IF <> 0 - TERMINATE INTERPRETATION
*         IF   SECOND DECIMAL POINT
* ADJUST FPA0 FOR THE DECIMAL EXPONENT IN V47
LBD65     LDA  V47            ; * GET EXPONENT, SUBTRACT THE NUMBER OF
          SUBA V45            ; * PLACES TO THE RIGHT OF DECIMAL POINT
          STA  V47            ; * AND RESAVE IT.
          BEQ  LBD7F          ; EXIT ROUTINE IF ADJUSTED EXPONENT = ZERO
          BPL  LBD78          ; BRANCH IF POSITIVE EXPONENT
LBD6F     JSR  LBB82          ; DIVIDE FPA0 BY 10
          INC  V47            ; INCREMENT EXPONENT COUNTER (MULTIPLY BY 10)
          BNE  LBD6F          ; KEEP MULTIPLYING
          BRA  LBD7F          ; EXIT ROUTINE
LBD78     JSR  LBB6A          ; MULTIPLY FPA0 BY 10
          DEC  V47            ; DECREMENT EXPONENT COUNTER (DIVIDE BY 10)
          BNE  LBD78          ; KEEP MULTIPLYING
LBD7F     LDA  COEFCT         ; GET THE SIGN FLAG
          BPL  LBD11          ; RETURN IF POSITIVE
          JMP  LBEE9          ; TOGGLE MANTISSA SIGN OF FPA0, IF NEGATIVE
*MULTIPLY FPA0 BY TEN AND ADD ACCA TO THE RESULT
LBD86     LDB  V45            ; *GET THE RIGHT DECIMAL COUNTER AND SUBTRACT
          SUBB V46            ; *THE DECIMAL POINT FLAG FROM IT. IF DECIMAL POINT
          STB  V45            ; *FLAG=0, NOTHING HAPPENS. IF DECIMAL POINT FLAG IS
*                             -1, THEN RIGHT DECIMAL COUNTER IS INCREMENTED BY ONE
          PSHS A              ; SAVE NEW DIGIT ON STACK
          JSR  LBB6A          ; MULTIPLY FPA0 BY 10
          PULS B              ; GET NEW DIGIT BACK
          SUBB #'0            ; MASK OFF ASCII
          BSR  LBD99          ; ADD ACCB TO FPA0
          BRA  LBD31          ; GET ANOTHER CHARACTER FROM BASIC
LBD99     JSR  LBC2F          ; PACK FPA0 AND SAVE IT IN FPA3
          JSR  LBC7C          ; CONVERT ACCB TO FP NUMBER IN FPA0
          LDX  #V40           ; * ADD FPA0 TO
          JMP  LB9C2          ; * FPA3


LBDA5     LDB  V47
          ASLB                ; TIMES 2
          ASLB                ; TIMES 4
          ADDB V47            ; ADD 1 = TIMES 5
          ASLB                ; TIMES 10
          SUBA #'0            ; *MASK OFF ASCII FROM ACCA, PUSH
          PSHS B              ; *RESULT ONTO THE STACK AND
          ADDA ,S+            ; ADD lT TO ACCB
          STA  V47            ; SAVE IN V47
          BRA  LBD55          ; INTERPRET ANOTHER CHARACTER
*
LBDB6     FCB  $9B,$3E,$BC,$1F,$FD ; * 99999999.9
LBDBB     FCB  $9E,$6E,$6B,$27,$FD ; * 999999999
LBDC0     FCB  $9E,$6E,$6B,$28,$00 ; * 1E + 09
*
LBDC5     LDX  #LABE8-1       ; POINT X TO " IN " MESSAGE
          BSR  LBDD6          ; COPY A STRING FROM (X) TO CONSOLE OUT
          LDD  CURLIN         ; GET CURRENT BASIC LINE NUMBER TO ACCD
* CONVERT VALUE IN ACCD INTO A DECIMAL NUMBER
* AND PRINT IT TO CONSOLE OUT
LBDCC     STD  FPA0           ; SAVE ACCD IN TOP HALF OF FPA0
          LDB  #$90           ; REQ'D EXPONENT IF TOP HALF OF ACCD = INTEGER
          COMA                ; SET CARRY FLAG - FORCE POSITIVE MANTISSA
          JSR  LBC86          ; ZERO BOTTOM HALF AND SIGN OF FPA0, THEN
*         SAVE EXPONENT AND NORMALIZE IT
          BSR  LBDD9          ; CONVERT FP NUMBER TO ASCII STRING
LBDD6     JMP  LB99C          ; COPY A STRING FROM (X) TO CONSOLE OUT

* CONVERT FP NUMBER TO ASCII STRING
LBDD9     LDU  #STRBUF+3      ; POINT U TO BUFFER WHICH WILL NOT CAUSE
*                             ; THE STRING TO BE STORED IN STRING SPACE
LBDDC     LDA  #SPACE         ; SPACE = DEFAULT SIGN FOR POSITIVE #
          LDB  FP0SGN         ; GET SIGN OF FPA0
          BPL  LBDE4          ; BRANCH IF POSITIVE
          LDA  #'-            ; ASCII MINUS SIGN
LBDE4     STA  ,U+            ; STORE SIGN OF NUMBER
          STU  COEFPT         ; SAVE BUFFER POINTER
          STA  FP0SGN         ; SAVE SIGN (IN ASCII)
          LDA  #'0            ; ASCII ZERO IF EXPONENT = 0
          LDB  FP0EXP         ; GET FPA0 EXPONENT
          LBEQ LBEB8          ; BRANCH IF FPA0 = 0
          CLRA                ; BASE 10 EXPONENT=0 FOR FP NUMBER > 1
          CMPB #$80           ; CHECK EXPONENT
          BHI  LBDFF          ; BRANCH IF FP NUMBER > 1
* IF FPA0 < 1.0, MULTIPLY IT BY 1E+09 TO SPEED UP THE CONVERSION PROCESS
          LDX  #LBDC0         ; POINT X TO FP 1E+09
          JSR  LBACA          ; MULTIPLY FPA0 BY (X)
          LDA  #-9            ; BASE 10 EXPONENT = -9
LBDFF     STA  V45            ; BASE 10 EXPONENT
* PSEUDO - NORMALIZE THE FP NUMBER TO A VALUE IN THE RANGE
* OF 999,999,999 RO 99,999,999.9 - THIS IS THE LARGEST
* NUMBER RANGE IN WHICH ALL OF THE DIGITS ARE
* SIGNIFICANT WHICH CAN BE DISPLAYED WITHOUT USING
* SCIENTIFIC NOTATION
LBE01     LDX  #LBDBB         ; POINT X TO FP 999,999,999
          JSR  LBCA0          ; COMPARE FPA0 TO 999,999,999
          BGT  LBE18          ; BRANCH IF > 999,999,999
LBE09     LDX  #LBDB6         ; POINT X TO FP 99,999,999.9
          JSR  LBCA0          ; COMPARE FPA0 TO 99,999,999.9
          BGT  LBE1F          ; BRANCH IF > 99,999,999.9 (IN RANGE)
          JSR  LBB6A          ; MULTIPLY FPA0 BY 10
          DEC  V45            ; SUBTRACT ONE FROM DECIMAL OFFSET
          BRA  LBE09          ; PSEUDO - NORMALIZE SOME MORE
LBE18     JSR  LBB82          ; DIVIDE FPA0 BY 10
          INC  V45            ; ADD ONE TO BASE 10 EXPONENT
          BRA  LBE01          ; PSEUDO - NORMALIZE SOME MORE
LBE1F     JSR  LB9B4          ; ADD .5 TO FPA0 (ROUND OFF)
          JSR  LBCC8          ; CONVERT FPA0 TO AN INTEGER
          LDB  #1             ; DEFAULT DECIMAL POINT FLAG (FORCE IMMED DECIMAL PT)
          LDA  V45            ; * GET BASE 10 EXPONENT AND ADD TEN TO IT
          ADDA #9+1           ; * (NUMBER 'NORMALIZED' TO 9 PLACES & DECIMAL PT)
          BMI  LBE36          ; BRANCH IF NUMBER < 1.0
          CMPA #9+2           ; NINE PLACES MAY BE DISPLAYED WITHOUT
*         USING SCIENTIFIC NOTATION
          BCC  LBE36          ; BRANCH IF SCIENTIFIC NOTATION REQUIRED
          DECA                ; * SUBTRACT 1 FROM MODIFIED BASE 10 EXPONENT CTR
          TFR  A,B            ; * AND SAVE IT IN ACCB (DECiMAL POINT FLAG)
          LDA  #2             ; FORCE EXPONENT = 0 - DON'T USE SCIENTIFIC NOTATION
LBE36     DECA                ; * SUBTRACT TWO (WITHOUT AFFECTING CARRY)
          DECA                ; * FROM BASE 10 EXPONENT
          STA  V47            ; SAVE EXPONENT - ZERO EXPONENT = DO NOT DISPLAY
*         IN   SCIENTIFIC NOTATION
          STB  V45            ; DECIMAL POINT FLAG - NUMBER OF PLACES TO
*         LEFT OF DECIMAL POINT
          BGT  LBE4B          ; BRANCH IF >= 1
          LDU  COEFPT         ; POINT U TO THE STRING BUFFER
          LDA  #'.            ; * STORE A PERIOD
          STA  ,U+            ; * IN THE BUFFER
          TSTB                ; CHECK DECIMAL POINT FLAG
          BEQ  LBE4B          ; BRANCH IF NOTHING TO LEFT OF DECIMAL POINT
          LDA  #'0            ; * STORE A ZERO
          STA  ,U+            ; * IN THE BUFFER

* CONVERT FPA0 INTO A STRING OF ASCII DIGITS
LBE4B     LDX  #LBEC5         ; POINT X TO FP POWER OF 10 MANTISSA
          LDB  #0+$80         ; INITIALIZE DIGIT COUNTER TO 0+$80
* BIT 7 SET IS USED TO INDICATE THAT THE POWER OF 10 MANTISSA
* IS NEGATIVE. WHEN YOU 'ADD' A NEGATIVE MANTISSA, IT IS
* THE SAME AS SUBTRACTING A POSITIVE ONE AND BIT 7 OF ACCB IS HOW
* THE ROUTINE KNOWS THAT A 'SUBTRACTION' IS OCCURING.
LBE50     LDA  FPA0+3         ; * ADD MANTISSA LS
          ADDA 3,X            ; * BYTE OF FPA0
          STA  FPA0+3         ; * AND (X)
          LDA  FPA0+2         ; = ADD MANTISSA
          ADCA 2,X            ; = NUMBER 3 BYTE OF
          STA  FPA0+2         ; = FPA0 AND (X)
          LDA  FPA0+1         ; * ADD MANTISSA
          ADCA 1,X            ; * NUMBER 2 BYTE OF
          STA  FPA0+1         ; * FPA0 AND (X)
          LDA  FPA0           ; = ADD MANTISSA
          ADCA ,X             ; = MS BYTE OF
          STA  FPA0           ; = FPA0 AND (X)
          INCB                ; ADD ONE TO DIGIT COUNTER
          RORB                ; ROTATE CARRY INTO BIT 7
          ROLB                ; *SET OVERFLOW FLAG AND BRANCH IF CARRY = 1 AND
          BVC  LBE50          ; *POSITIVE MANTISSA OR CARRY = 0 AND NEG MANTISSA
          BCC  LBE72          ; BRANCH IF NEGATIVE MANTISSA
          SUBB #10+1          ; * TAKE THE 9'S COMPLEMENT IF
          NEGB                ; * ADDING MANTISSA
LBE72     ADDB #'0-1          ; ADD ASCII OFFSET TO DIGIT
          LEAX 4,X            ; MOVE TO NEXT POWER OF 10 MANTISSA
          TFR  B,A            ; SAVE DIGIT IN ACCA
          ANDA #$7F           ; MASK OFF BIT 7 (ADD/SUBTRACT FLAG)
          STA  ,U+            ; STORE DIGIT IN STRING BUFFER
          DEC  V45            ; DECREMENT DECIMAL POINT FLAG
          BNE  LBE84          ; BRANCH IF NOT TIME FOR DECIMAL POINT
          LDA  #'.            ; * STORE DECIMAL POINT IN
          STA  ,U+            ; * STRING BUFFER
LBE84     COMB                ; TOGGLE BIT 7 (ADD/SUBTRACT FLAG)
          ANDB #$80           ; MASK OFF ALL BUT ADD/SUBTRACT FLAG
          CMPX #LBEC5+36      ; COMPARE X TO END OF MANTISSA TABLE
          BNE  LBE50          ; BRANCH IF NOT AT END OF TABLE
* BLANK TRAILING ZEROS AND STORE EXPONENT IF ANY
LBE8C     LDA  ,-U            ; GET THE LAST CHARACTER; MOVE POINTER BACK
          CMPA #'0            ; WAS IT A ZERO?
          BEQ  LBE8C          ; IGNORE TRAILING ZEROS IF SO
          CMPA #'.            ; CHECK FOR DECIMAL POINT
          BNE  LBE98          ; BRANCH IF NOT DECIMAL POINT
          LEAU -1,U           ; STEP OVER THE DECIMAL POINT
LBE98     LDA  #'+            ; ASCII PLUS SIGN
          LDB  V47            ; GET SCIENTIFIC NOTATION EXPONENT
          BEQ  LBEBA          ; BRANCH IF NOT SCIENTIFIC NOTATION
          BPL  LBEA3          ; BRANCH IF POSITIVE EXPONENT
          LDA  #'-            ; ASCII MINUS SIGN
          NEGB                ; NEGATE EXPONENT IF NEGATIVE
LBEA3     STA  2,U            ; STORE EXPONENT SIGN IN STRING
          LDA  #'E            ; * GET ASCII 'E' (SCIENTIFIC NOTATION
          STA  1,U            ; * FLAG) AND SAVE IT IN THE STRING
          LDA  #'0-1          ; INITIALIZE ACCA TO ASCII ZERO


LBEAB     INCA                ; ADD ONE TO 10'S DIGIT OF EXPONENT
          SUBB #10            ; SUBTRACT 10 FROM ACCB
          BCC  LBEAB          ; ADD 1 TO 10'S DIGIT IF NO CARRY
          ADDB #'9+1          ; CONVERT UNITS DIGIT TO ASCII
          STD  3,U            ; SAVE EXPONENT IN STRING
          CLR  5,U            ; CLEAR LAST BYTE (TERMINATOR)
          BRA  LBEBC          ; GO RESET POINTER
LBEB8     STA  ,U             ; STORE LAST CHARACTER
LBEBA     CLR  1,U            ; CLEAR LAST BYTE (TERMINATOR - REQUIRED BY
*         PRINT SUBROUTINES)
LBEBC     LDX  #STRBUF+3      ; RESET POINTER TO START OF BUFFER
          RTS
*
LBEC0     FCB  $80,$00,$00,$00,$00 ; FLOATING POINT .5
*
*** TABLE OF UNNORMALIZED POWERS OF 10
LBEC5     FCB  $FA,$0A,$1F,$00 ; -100000000
LBEC9     FCB  $00,$98,$96,$80 ; 10000000
LBECD     FCB  $FF,$F0,$BD,$C0 ; -1000000
LBED1     FCB  $00,$01,$86,$A0 ; 100000
LBED5     FCB  $FF,$FF,$D8,$F0 ; -10000
LBED9     FCB  $00,$00,$03,$E8 ; 1000
LBEDD     FCB  $FF,$FF,$FF,$9C ; -100
LBEE1     FCB  $00,$00,$00,$0A ; 10
LBEE5     FCB  $FF,$FF,$FF,$FF ; -1
*
*
LBEE9     LDA  FP0EXP         ; GET EXPONENT OF FPA0
          BEQ  LBEEF          ; BRANCH IF FPA0 = 0
          COM  FP0SGN         ; TOGGLE MANTISSA SIGN OF FPA0
LBEEF     RTS
* EXPAND A POLYNOMIAL OF THE FORM
* AQ+BQ**3+CQ**5+DQ**7.... WHERE Q = FPA0
* AND THE X REGISTER POINTS TO A TABLE OF
* COEFFICIENTS A,B,C,D....
LBEF0     STX  COEFPT         ; SAVE COEFFICIENT TABLE POINTER
          JSR  LBC2F          ; MOVE FPA0 TO FPA3
          BSR  LBEFC          ; MULTIPLY FPA3 BY FPA0
          BSR  LBF01          ; EXPAND POLYNOMIAL
          LDX  #V40           ; POINT X TO FPA3
LBEFC     JMP  LBACA          ; MULTIPLY (X) BY FPA0

* CALCULATE THE VALUE OF AN EXPANDED POLYNOMIAL
* EXPRESSION. ENTER WITH (X) POINTING TO A TABLE
* OF COEFFICIENTS, THE FIRST BYTE OF WHICH IS THE
* NUMBER OF (COEFFICIENTS-1) FOLLOWED BY THAT NUMBER
* OF PACKED FLOATING POINT NUMBERS. THE
* POLYNOMIAL IS EVALUATED AS FOLLOWS: VALUE =
* (((FPA0*Y0+Y1)*FPA0+Y2)*FPA0...YN)
LBEFF     STX  COEFPT         ; SAVE COEFFICIENT TABLE POINTER
LBF01     JSR  LBC2A          ; MOVE FPA0 TO FPA4
          LDX  COEFPT         ; GET THE COEFFICIENT POINTER
          LDB  ,X+            ; GET THE TOP OF COEFFICIENT TABLE TO
          STB  COEFCT         ; * USE AND STORE IT IN TEMPORARY COUNTER
          STX  COEFPT         ; SAVE NEW COEFFICIENT POINTER
LBF0C     BSR  LBEFC          ; MULTIPLY (X) BY FPA0
          LDX  COEFPT         ; *GET COEFFICIENT POINTER
          LEAX 5,X            ; *MOVE TO NEXT FP NUMBER
          STX  COEFPT         ; *SAVE NEW COEFFICIENT POINTER
          JSR  LB9C2          ; ADD (X) AND FPA0
          LDX  #V45           ; POINT (X) TO FPA4
          DEC  COEFCT         ; DECREMENT TEMP COUNTER
          BNE  LBF0C          ; BRANCH IF MORE COEFFICIENTS LEFT
          RTS

* RND
RND       JSR  LBC6D          ; TEST FPA0
          BMI  LBF45          ; BRANCH IF FPA0 = NEGATIVE
          BEQ  LBF3B          ; BRANCH IF FPA0 = 0
          BSR  LBF38          ; CONVERT FPA0 TO AN INTEGER
          JSR  LBC2F          ; PACK FPA0 TO FPA3
          BSR  LBF3B          ; GET A RANDOM NUMBER: FPA0 < 1.0
          LDX  #V40           ; POINT (X) TO FPA3
          BSR  LBEFC          ; MULTIPLY (X) BY FPA0
          LDX  #LBAC5         ; POINT (X) TO FP VALUE OF 1.0
          JSR  LB9C2          ; ADD 1.0 TO FPA0
LBF38     JMP  INT            ; CONVERT FPA0 TO AN INTEGER
* CALCULATE A RANDOM NUMBER IN THE RANGE 0.0 < X <= 1.0
LBF3B     LDX  RVSEED+1       ; * MOVE VARIABLE
          STX  FPA0           ; * RANDOM NUMBER
          LDX  RVSEED+3       ; * SEED TO
          STX  FPA0+2         ; * FPA0
LBF45     LDX  RSEED          ; = MOVE FIXED
          STX  FPA1           ; = RANDOM NUMBER
          LDX  RSEED+2        ; = SEED TO
          STX  FPA1+2         ; = MANTISSA OF FPA0
          JSR  LBAD0          ; MULTIPLY FPA0 X FPA1
          LDD  VAD            ; GET THE TWO LOWEST ORDER PRODUCT BYTES
          ADDD #$658B         ; ADD A CONSTANT
          STD  RVSEED+3       ; SAVE NEW LOW ORDER VARIABLE RANDOM # SEED
          STD  FPA0+2         ; SAVE NEW LOW ORDER BYTES OF FPA0 MANTISSA
          LDD  VAB            ; GET 2 MORE LOW ORDER PRODUCT BYTES
          ADCB #$B0           ; ADD A CONSTANT
          ADCA #5             ; ADD A CONSTANT
          STD  RVSEED+1       ; SAVE NEW HIGH ORDER VARIABLE RANDOM # SEED
          STD  FPA0           ; SAVE NEW HIGH ORDER FPA0 MANTISSA
          CLR  FP0SGN         ; FORCE FPA0 MANTISSA = POSITIVE
          LDA  #$80           ; * SET FPA0 BIASED EXPONENT
          STA  FP0EXP         ; * TO 0 1 < FPA0 < 0
          LDA  FPA2+2         ; GET A BYTE FROM FPA2 (MORE RANDOMNESS)
          STA  FPSBYT         ; SAVE AS SUB BYTE
          JMP  LBA1C          ; NORMALIZE FPA0
*
RSEED     FDB  $40E6          ; *CONSTANT RANDOM NUMBER GENERATOR SEED
          FDB  $4DAB          ; *

* SIN
* THE SIN FUNCTION REQUIRES AN ARGUMENT IN RADIANS AND WILL REPEAT ITSELF EVERY
* 2*PI RADIANS. THE ARGUMENT IS DIVIDED BY 2*PI AND ONLY THE FRACTIONAL PART IS
* RETAINED. SINCE THE ARGUMENT WAS DIVIDED BY 2*P1, THE COEFFICIENTS MUST BE
* MULTIPLIED BY THE APPROPRIATE POWER OF 2*PI.

* SIN IS EVALUATED USING THE TRIGONOMETRIC IDENTITIES BELOW:
* SIN(X)=SIN(PI-X) & -SIN(PI/2-X)=SIN((3*PI)/2+X)
SIN       JSR  LBC5F          ; COPY FPA0 TO FPA1
          LDX  #LBFBD         ; POINT (X) TO 2*PI
          LDB  FP1SGN         ; *GET MANTISSA SIGN OF FPA1
          JSR  LBB89          ; *AND DIVIDE FPA0 BY 2*PI
          JSR  LBC5F          ; COPY FPA0 TO FPA1
          BSR  LBF38          ; CONVERT FPA0 TO AN INTEGER
          CLR  RESSGN         ; SET RESULT SIGN = POSITIVE
          LDA  FP1EXP         ; *GET EXPONENT OF FPA1
          LDB  FP0EXP         ; *GET EXPONENT OF FPA0
          JSR  LB9BC          ; *SUBTRACT FPA0 FROM FPA1
* NOW FPA0 CONTAINS ONLY THE FRACTIONAL PART OF ARGUMENT/2*PI
          LDX  #LBFC2         ; POINT X TO FP (.25)
          JSR  LB9B9          ; SUBTRACT FPA0 FROM .25 (PI/2)
          LDA  FP0SGN         ; GET MANTISSA SIGN OF FPA0
          PSHS A              ; SAVE IT ON STACK
          BPL  LBFA6          ; BRANCH IF MANTISSA POSITIVE
          JSR  LB9B4          ; ADD .5 (PI) TO FPA0
          LDA  FP0SGN         ; GET SIGN OF FPA0
          BMI  LBFA9          ; BRANCH IF NEGATIVE
          COM  RELFLG         ; COM IF +(3*PI)/2 >= ARGUMENT >+ PI/2 (QUADRANT FLAG)
LBFA6     JSR  LBEE9          ; TOGGLE MANTISSA SIGN OF FPA0
LBFA9     LDX  #LBFC2         ; POINT X TO FP (.25)
          JSR  LB9C2          ; ADD .25 (PI/2) TO FPA0
          PULS A              ; GET OLD MANTISSA SIGN
          TSTA                ; * BRANCH IF OLD
          BPL  LBFB7          ; * SIGN WAS POSITIVE
          JSR  LBEE9          ; TOGGLE MANTISSA SIGN
LBFB7     LDX  #LBFC7         ; POINT X TO TABLE OF COEFFICIENTS
          JMP  LBEF0          ; GO CALCULATE POLYNOMIAL VALUE

LBFBD     FCB  $83,$49,$0F,$DA,$A2 ; 6.28318531 (2*PI)
LBFC2     FCB  $7F,$00,$00,$00,$00 ; .25


LBFC7     FCB  6-1            ; SIX COEFFICIENTS
LBFC8     FCB  $84,$E6,$1A,$2D,$1B ; * -((2*PI)**11)/11!
LBFCD     FCB  $86,$28,$07,$FB,$F8 ; * ((2*PI)**9)/9!
LBFD2     FCB  $87,$99,$68,$89,$01 ; * -((2*PI)**7)/7!
LBFD7     FCB  $87,$23,$35,$DF,$E1 ; * ((2*PI)**5)/5!
LBFDC     FCB  $86,$A5,$5D,$E7,$28 ; * -((2*PI)**3)/3!
LBFE1     FCB  $83,$49,$0F,$DA,$A2 ; *

          FCB  $A1,$54,$46,$8F,$13 ; UNUSED GARBAGE BYTES
          FCB  $8F,$52,$43,$89,$CD ; UNUSED GARBAGE BYTES
* EXTENDED BASIC

* COS
* THE VALUE OF COS(X) IS DETERMINED BY THE TRIG IDENTITY COS(X)=SIN((PI/2)+X)
COS       LDX  #L83AB         ; POINT X TO FP CONSTANT (P1/2)
          JSR  LB9C2          ; ADD FPA0 TO (X)
L837E     JMP  SIN            ; JUMP TO SIN ROUTINE

* TAN
* THE VALUE OF TAN(X) IS DETERMINED BY THE TRIG IDENTITY TAN(X)=SIN(X)/COS(X)
TAN       JSR  LBC2F          ; PACK FPA0 AND MOVE IT TO FPA3
          CLR  RELFLG         ; RESET QUADRANT FLAG
          BSR  L837E          ; CALCULATE SIN OF ARGUMENT
          LDX  #V4A           ; POINT X TO FPA5
          JSR  LBC35          ; PACK FPA0 AND MOVE IT TO FPA5
          LDX  #V40           ; POINT X TO FPA3
          JSR  LBC14          ; MOVE FPA3 TO FPA0
          CLR  FP0SGN         ; FORCE FPA0 MANTISSA TO BE POSITIVE
          LDA  RELFLG         ; GET THE QUADRANT FLAG - COS NEGATIVE IN QUADS 2,3
          BSR  L83A6          ; CALCULATE VALUE OF COS(FPA0)
          TST  FP0EXP         ; CHECK EXPONENT OF FPA0
          LBEQ LBA92          ; ''OV' ERROR IF COS(X)=0
          LDX  #V4A           ; POINT X TO FPA5
L83A3     JMP  LBB8F          ; DIVIDE (X) BY FPA0 - SIN(X)/COS(X)
L83A6     PSHS A              ; SAVE SIGN FLAG ON STACK
          JMP  LBFA6          ; EXPAND POLYNOMIAL

L83AB     FCB  $81,$49,$0F,$DA,$A2 ; 1.57079633 (PI/2)

* ATN
* A 12 TERM TAYLOR SERIES IS USED TO EVALUATE THE
* ARCTAN EXPRESSION. TWO  DIFFERENT FORMULI ARE USED
* TO EVALUATE THE EXPRESSION DEPENDING UPON
* WHETHER OR NOT THE ARGUMENT SQUARED IS > OR < 1.0

* IF X**2<1 THEN ATN=X-(X**3)/3+(X**5)/5-(X**7)/7. . .
* IF X**2>=1 THEN ATN=PI/2-(1/X-1/((X**3)*3)+(1/((X**5)*5)-. . .)

ATN       LDA  FP0SGN         ; * GET THE SIGN OF THE MANTISSA AND
          PSHS A              ; * SAVE IT ON THE STACK
          BPL  L83B8          ; BRANCH IF POSITIVE MANTISSA
          BSR  L83DC          ; CHANGE SIGN OF FPA0
L83B8     LDA  FP0EXP         ; * GET EXPONENT OF FPA0 AND
          PSHS A              ; * SAVE IT ON THE STACK
          CMPA #$81           ; IS FPAO < 1.0?
          BLO  L83C5          ; YES
          LDX  #LBAC5         ; POINT X TO FP CONSTANT 1.0
          BSR  L83A3          ; GET RECIPROCAL OF FPA0
L83C5     LDX  #L83E0         ; POINT (X) TO TAYLOR SERIES COEFFICIENTS
          JSR  LBEF0          ; EXPAND POLYNOMIAL
          PULS A              ; GET EXPONENT OF ARGUMENT
          CMPA #$81           ; WAS ARGUMENT < 1.0?
          BLO  L83D7          ; YES
          LDX  #L83AB         ; POINT (X) TO FP NUMBER (PI/2)
          JSR  LB9B9          ; SUBTRACT FPA0 FROM (PI/2)
L83D7     PULS A              ; * GET SIGN OF INITIAL ARGUMENT MANTISSA
          TSTA                ; * AND SET FLAGS ACCORDING TO IT
          BPL  L83DF          ; RETURN IF ARGUMENT WAS POSITIVE
L83DC     JMP  LBEE9          ; CHANGE MANTISSA SIGN OF FPA0
L83DF     RTS
*
* TCHEBYSHEV MODIFIED TAYLOR SERIES COEFFICIENTS FOR ARCTANGENT
L83E0     FCB  $0B            ; TWELVE COEFFICIENTS
L83E1     FCB  $76,$B3,$83,$BD,$D3 ; -6.84793912E-04 1/23
L83E6     FCB  $79,$1E,$F4,$A6,$F5 ; +4.85094216E-03 1/21
L83EB     FCB  $7B,$83,$FC,$B0,$10 ; -0.0161117018
L83F0     FCB  $7C,$0C,$1F,$67,$CA ; 0.0342096381
L83F5     FCB  $7C,$DE,$53,$CB,$C1 ; -0.0542791328
L83FA     FCB  $7D,$14,$64,$70,$4C ; 0.0724571965
L83FF     FCB  $7D,$B7,$EA,$51,$7A ; -0.0898023954
L8404     FCB  $7D,$63,$30,$88,$7E ; 0.110932413
L8409     FCB  $7E,$92,$44,$99,$3A ; -0.142839808
L840E     FCB  $7E,$4C,$CC,$91,$C7 ; 0.199999121
L8413     FCB  $7F,$AA,$AA,$AA,$13 ; -0.333333316
L8418     FCB  $81,$00,$00,$00,$00 ; 1
*
*** TCHEBYSHEV MODIFIED TAYLOR SERIES COEFFICIENTS FOR LN(X)
*
L841D     FCB  3              ; FOUR COEFFICIENTS
L841E     FCB  $7F,$5E,$56,$CB,$79 ; 0.434255942
L8423     FCB  $80,$13,$9B,$0B,$64 ; 0.576584541
L8428     FCB  $80,$76,$38,$93,$16 ; 0.961800759
L842D     FCB  $82,$38,$AA,$3B,$20 ; 2.88539007

L8432     FCB  $80,$35,$04,$F3,$34 ; 1/SQR(2)

L8437     FCB  $81,$35,$04,$F3,$34 ; SQR(2)

L843C     FCB  $80,$80,$00,$00,$00 ; -0.5

L8441     FCB  $80,$31,$72,$17,$F8 ; LN(2)
*
* LOG - NATURAL LOGARITHM (LN)

* THE NATURAL OR NAPERIAN LOGARITHM IS CALCULATED USING
* MATHEMATICAL IDENTITIES. FPA0 IS OF THE FORM FPA0=A*(2**B) (SCIENTIFIC
* NOTATION). THEREFORE, THE LOG ROUTINE DETERMINES THE VALUE OF
* LN(A*(2**B)). A SERIES OF MATHEMATICAL IDENTITIES WILL EXPAND THIS
* TERM: LN(A*(2**B))=(-1/2+(1/LN(2))*(LN(A*SQR(2)))+B)*LN(2). ALL OF
* THE TERMS OF THE LATTER EXPRESSION ARE CONSTANTS EXCEPT FOR THE
* LN(A*SQR(2)) TERM WHICH IS EVALUATED USING THE TAYLOR SERIES EXPANSION
LOG       JSR  LBC6D          ; CHECK STATUS OF FPA0
          LBLE LB44A          ; 'FC' ERROR IF NEGATIVE OR ZERO
          LDX  #L8432         ; POINT (X) TO FP NUMBER (1/SQR(2))
          LDA  FP0EXP         ; *GET EXPONENT OF ARGUMENT
          SUBA #$80           ; *SUBTRACT OFF THE BIAS AND
          PSHS A              ; *SAVE IT ON THE STACK
          LDA  #$80
          STA  FP0EXP
          JSR  LB9C2          ; ADD FPA0 TO (X)
          LDX  #L8437         ; POINT X TO SQR(2)
          JSR  LBB8F          ; DIVIDE SQR(2) BY FPA0
          LDX  #LBAC5         ; POINT X TO FP VALUE OF 1.00
          JSR  LB9B9          ; SUBTRACT FPA0 FROM (X)
*         NOW  FPA0 = (1-SQR(2)*X)/(1+SQR(2)*X) WHERE X IS ARGUMENT
          LDX  #L841D         ; POINT X TO TABLE OF COEFFICIENTS
          JSR  LBEF0          ; EXPAND POLYNOMIAL
          LDX  #L843C         ; POINT X TO FP VALUE OF (-.5)
          JSR  LB9C2          ; ADD FPA0 TO X
          PULS B              ; GET EXPONENT OF ARGUMENT BACK (WITHOUT BIAS)
          JSR  LBD99          ; ADD ACCB TO FPA0
          LDX  #L8441         ; POINT X TO LN(2)
          JMP  LBACA          ; MULTIPLY FPA0 * LN(2)

* SQR
SQR       JSR  LBC5F          ; MOVE FPA0 TO FPA1
          LDX  #LBEC0         ; POINT (X) TO FP NUMBER (.5)
          JSR  LBC14          ; COPY A PACKED NUMBER FROM (X) TO FPA0

* ARITHMETIC OPERATOR FOR EXPONENTIATION JUMPS
* HERE. THE FORMULA USED TO EVALUATE EXPONENTIATION
* IS A**X=E**(X LN A) = E**(FPA0*LN(FPA1)), E=2.7182818
L8489     BEQ  EXP            ; DO A NATURAL EXPONENTIATION IF EXPONENT = 0
          TSTA                ; *CHECK VALUE BEING EXPONENTIATED
          BNE  L8491          ; *AND BRANCH IF IT IS <> 0
          JMP  LBA3A          ; FPA0=0 IF RAISING ZERO TO A POWER
L8491     LDX  #V4A           ; * PACK FPA0 AND SAVE
          JSR  LBC35          ; * IT IN FPA5 (ARGUMENT'S EXPONENT)
          CLRB                ; ACCB=DEFAULT RESULT SIGN FLAG; 0=POSITIVE
          LDA  FP1SGN         ; *CHECK THE SIGN OF ARGUMENT
          BPL  L84AC          ; *BRANCH IF POSITIVE
          JSR  INT            ; CONVERT EXPONENT INTO AN INTEGER
          LDX  #V4A           ; POINT X TO FPA5 (ORIGINAL EXPONENT)
          LDA  FP1SGN         ; GET MANTISSA SIGN OF FPA1 (ARGUMENT)
          JSR  LBCA0          ; *COMPARE FPA0 TO (X) AND
          BNE  L84AC          ; *BRANCH IF NOT EQUAL
          COMA                ; TOGGLE FPA1 MANTISSA SIGN - FORCE POSITIVE
          LDB  CHARAC         ; GET LS BYTE OF INTEGER VALUE OF EXPONENT (RESULT SIGN FLAG)
L84AC     JSR  LBC4C          ; COPY FPA1 TO FPA0; ACCA = MANTISSA SIGN
          PSHS B              ; PUT RESULT SIGN FLAG ON THE STACK
          JSR  LOG
          LDX  #V4A           ; POINT (X) TO FPA5
          JSR  LBACA          ; MULTIPLY FPA0 BY FPA5
          BSR  EXP            ; CALCULATE E**(FPA0)
          PULS A              ; * GET RESULT SIGN FLAG FROM THE STACK
          RORA                ; * AND BRANCH IF NEGATIVE
          LBCS LBEE9          ; CHANGE SIGN OF FPA0 MANTISSA
          RTS

* CORRECTION FACTOR FOR EXPONENTIAL FUNCTION
L84C4     FCB  $81,$38,$AA,$3B,$29 ; 1.44269504 ( CF )
*
* TCHEBYSHEV MODIFIED TAYLOR SERIES COEFFICIENTS FOR E**X
*
L84C9     FCB  7              ; EIGHT COEFFICIENTS
L84CA     FCB  $71,$34,$58,$3E,$56 ; 2.14987637E-05: 1/(7!*(CF**7))
L84CF     FCB  $74,$16,$7E,$B3,$1B ; 1.4352314E-04 : 1/(6!*(CF**6))
L84D4     FCB  $77,$2F,$EE,$E3,$85 ; 1.34226348E-03: 1/(5!*(CF**5))
L84D9     FCB  $7A,$1D,$84,$1C,$2A ; 9.61401701E-03: 1/(4!*(CF**4))
L84DE     FCB  $7C,$63,$59,$58,$0A ; 0.0555051269
L84E3     FCB  $7E,$75,$FD,$E7,$C6 ; 0.240226385
L84E8     FCB  $80,$31,$72,$18,$10 ; 0.693147186
L84ED     FCB  $81,$00,$00,$00,$00 ; 1
*
* EXP ( E**X)
* THE EXPONENTIAL FUNCTION IS EVALUATED BY FIRST MULTIPLYING THE
* ARGUMENT BY A CORRECTION FACTOR (CF). AFTER THIS IS DONE, AN
* ARGUMENT >= 127 WILL YIELD A ZERO RESULT (NO UNDERFLOW) FOR A
* NEGATIVE ARGUMENT OR AN 'OV' (OVERFLOW) ERROR FOR A POSITIVE
* ARGUMENT. THE POLYNOMIAL COEFFICIENTS ARE MODIFIED TO REFLECT
* THE CF MULTIPLICATION AT THE START OF THE EVALUATION PROCESS.

EXP       LDX  #L84C4         ; POINT X TO THE CORRECTION FACTOR
          JSR  LBACA          ; MULTIPLY FPA0 BY (X)
          JSR  LBC2F          ; PACK FPA0 AND STORE IT IN FPA3
          LDA  FP0EXP         ; *GET EXPONENT OF FPA0 AND
          CMPA #$88           ; *COMPARE TO THE MAXIMUM VALUE
          BLO  L8504          ; BRANCH IF FPA0 < 128
L8501     JMP  LBB5C          ; SET FPA0 = 0 OR 'OV' ERROR
L8504     JSR  INT            ; CONVERT FPA0 TO INTEGER
          LDA  CHARAC         ; GET LS BYTE OF INTEGER
          ADDA #$81           ; * WAS THE ARGUMENT =127, IF SO
          BEQ  L8501          ; * THEN 'OV' ERROR; THIS WILL ALSO ADD THE $80 BIAS
*              ; * REQUIRED WHEN THE NEW EXPONENT IS CALCULATED BELOW
          DECA                ; DECREMENT ONE FROM THE EXPONENT, BECAUSE $81, NOT $80 WAS USED ABOVE
          PSHS A              ; SAVE EXPONENT OF INTEGER PORTION ON STACK
          LDX  #V40           ; POINT (X) TO FPA3
          JSR  LB9B9          ; SUBTRACT FPA0 FROM (X) - GET FRACTIONAL PART OF ARGUMENT
          LDX  #L84C9         ; POINT X TO COEFFICIENTS
          JSR  LBEFF          ; EVALUATE POLYNOMIAL FOR FRACTIONAL PART
          CLR  RESSGN         ; FORCE THE MANTISSA TO BE POSITIVE
          PULS A              ; GET INTEGER EXPONENT FROM STACK
          JSR  LBB48          ; * CALCULATE EXPONENT OF NEW FPA0 BY ADDING THE EXPONENTS OF THE
*              ; * INTEGER AND FRACTIONAL PARTS
          RTS

* FIX
FIX       JSR  LBC6D          ; CHECK STATUS OF FPA0
          BMI  L852C          ; BRANCH IF FPA0 = NEGATIVE
L8529     JMP  INT            ; CONVERT FPA0 TO INTEGER
L852C     COM  FP0SGN         ; TOGGLE SIGN OF FPA0 MANTISSA
          BSR  L8529          ; CONVERT FPA0 TO INTEGER
          JMP  LBEE9          ; TOGGLE SIGN OF FPA0

* EDIT
EDIT      JSR  L89AE          ; GET LINE NUMBER FROM BASIC
          LEAS $02,S          ; PURGE RETURN ADDRESS OFF OF THE STACK
L8538     LDA  #$01           ; 'LIST' FLAG
          STA  VD8            ; SET FLAG TO LIST LINE
          JSR  LAD01          ; GO FIND THE LINE NUMBER IN PROGRAM
          LBCS LAED2          ; ERROR #7 'UNDEFINED LINE #'
          JSR  LB7C2          ; GO UNCRUNCH LINE INTO BUFFER AT LINBUF+1
          TFR  Y,D            ; PUT ABSOLUTE ADDRESS OF END OF LINE TO ACCD
          SUBD #LINBUF+2      ; SUBTRACT OUT THE START OF LINE
          STB  VD7            ; SAVE LENGTH OF LINE
L854D     LDD  BINVAL         ; GET THE HEX VALUE OF LINE NUMBER
          JSR  LBDCC          ; LIST THE LINE NUMBER ON THE SCREEN
          JSR  LB9AC          ; PRINT A SPACE
          LDX  #LINBUF+1      ; POINT X TO BUFFER
          LDB  VD8            ; * CHECK TO SEE IF LINE IS TO BE
          BNE  L8581          ; * LISTED TO SCREEN - BRANCH IF IT IS
L855C     CLRB                ; RESET DIGIT ACCUMULATOR - DEFAULT VALUE
L855D     JSR  L8687          ; GET KEY STROKE
          JSR  L90AA          ; SET CARRY IF NOT NUMERIC
          BLO  L8570          ; BRANCH IF NOT NUMERIC
          SUBA #'0            ; MASK OFF ASCII
          PSHS A              ; SAVE IT ON STACK
          LDA  #10            ; NUMBER BEING CONVERTED IS BASE 10
          MUL                 ; MULTIPLY ACCUMULATED VALUE BY BASE (10)
          ADDB ,S+            ; ADD DIGIT TO ACCUMULATED VALUE
          BRA  L855D          ; CHECK FOR ANOTHER DIGIT
L8570     SUBB #$01           ; * REPEAT PARAMETER IN ACCB; IF IT
          ADCB #$01           ; *IS 0, THEN MAKE IT '1'
          CMPA #'A            ; ABORT?
          BNE  L857D          ; NO
          JSR  LB958          ; PRINT CARRIAGE RETURN TO SCREEN
          BRA  L8538          ; RESTART EDIT PROCESS - CANCEL ALL CHANGES
L857D     CMPA #'L            ; LIST?
          BNE  L858C          ; NO
L8581     BSR  L85B4          ; LIST THE LINE
          CLR  VD8            ; RESET THE LIST FLAG TO 'NO LIST'
          JSR  LB958          ; PRINT CARRIAGE RETURN
          BRA  L854D          ; GO INTERPRET ANOTHER EDIT COMMAND
L858A     LEAS $02,S          ; PURGE RETURN ADDRESS OFF OF THE STACK
L858C     CMPA #CR            ; ENTER KEY?
          BNE  L859D          ; NO
          BSR  L85B4          ; ECHO THE LINE TO THE SCREEN
L8592     JSR  LB958          ; PRINT CARRIAGE RETURN
          LDX  #LINBUF+1      ; * RESET BASIC'S INPUT POINTER
          STX  CHARAD         ; * TO THE LINE INPUT BUFFER
          JMP  LACA8          ; GO PUT LINE BACK IN PROGRAM
L859D     CMPA #'E            ; EXIT?
          BEQ  L8592          ; YES - SAME AS ENTER EXCEPT NO ECHO
          CMPA #'Q            ; QUIT?
          BNE  L85AB          ; NO
          JSR  LB958          ; PRINT CARRIAGE RETURN TO SCREEN
          JMP  LAC73          ; GO TO COMMAND LEVEL - MAKE NO CHANGES
L85AB     BSR  L85AF          ; INTERPRET THE REMAINING COMMANDS AS SUBROUTINES
          BRA  L855C          ; GO INTERPRET ANOTHER EDIT COMMAND
L85AF     CMPA #SPACE         ; SPACE BAR?
          BNE  L85C3          ; NO
L85B3     FCB  SKP2           ; SKIP TWO BYTES
* DISPLAY THE NEXT ACCB BYTES OF THE LINE IN THE BUFFER TO THE SCREEN
*
L85B4     LDB  #LBUFMX-1      ; 250 BYTES MAX IN BUFFER
L85B6     LDA  ,X             ; GET A CHARACTER FROM BUFFER
          BEQ  L85C2          ; EXIT IF IT'S A 0
          JSR  PUTCHR         ; SEND CHAR TO CONSOLE OUT
          LEAX $01,X          ; MOVE POINTER UP ONE
          DECB                ; DECREMENT CHARACTER COUNTER
          BNE  L85B6          ; LOOP IF NOT DONE
L85C2     RTS
L85C3     CMPA #'D            ; DELETE?
          BNE  L860F          ; NO
L85C7     TST  ,X             ; * CHECK FOR END OF LINE
          BEQ  L85C2          ; * AND BRANCH IF SO
          BSR  L85D1          ; REMOVE A CHARACTER
          DECB                ; DECREMENT REPEAT PARAMETER
          BNE  L85C7          ; BRANCH IF NOT DONE
          RTS
* REMOVE ONE CHARACTER FROM BUFFER
L85D1     DEC  VD7            ; DECREMENT LENGTH OF BUFFER
          LEAY -1,X           ; POINT Y TO ONE BEFORE CURRENT BUFFER POINTER
L85D5     LEAY $01,Y          ; INCREMENT TEMPORARY BUFFER POINTER
          LDA  $01,Y          ; GET NEXT CHARACTER
          STA  ,Y             ; PUT IT IN CURRENT POSITION
          BNE  L85D5          ; BRANCH IF NOT END OF LINE
          RTS
L85DE     CMPA #'I            ;  INSERT?
          BEQ  L85F5          ; YES
          CMPA #'X            ; EXTEND?
          BEQ  L85F3          ; YES
          CMPA #'H            ; HACK?
          BNE  L8646          ; NO
          CLR  ,X             ; TURN CURRENT BUFFER POINTER INTO END OF LINE FLAG
          TFR  X,D            ; PUT CURRENT BUFFER POINTER IN ACCD
          SUBD #LINBUF+2      ; SUBTRACT INITIAL POINTER POSITION
          STB  VD7            ; SAVE NEW BUFFER LENGTH
L85F3     BSR  L85B4          ; DISPLAY THE LINE ON THE SCREEN
L85F5     JSR  L8687          ; GET A KEYSTROKE
          CMPA #CR            ; ENTER KEY?
          BEQ  L858A          ; YES - INTERPRET ANOTHER COMMAND - PRINT LINE
          CMPA #ESC           ; ESCAPE?
          BEQ  L8625          ; YES - RETURN TO COMMAND LEVEL - DON'T PRINT LINE
          CMPA #BS            ; BACK SPACE?
          BNE  L8626          ; NO
          CMPX #LINBUF+1      ; COMPARE POINTER TO START OF BUFFER
          BEQ  L85F5          ; DO NOT ALLOW BS IF AT START
          BSR  L8650          ; MOVE POINTER BACK ONE, BS TO SCREEN
          BSR  L85D1          ; REMOVE ONE CHARACTER FROM BUFFER
          BRA  L85F5          ; GET INSERT SUB COMMAND
L860F     CMPA #'C            ; CHANGE?
          BNE  L85DE          ; NO
L8613     TST  ,X             ; CHECK CURRENT BUFFER CHARACTER
          BEQ  L8625          ; BRANCH IF END OF LINE
          JSR  L8687          ; GET A KEYSTROKE
          BLO  L861E          ; BRANCH IF LEGITIMATE KEY
          BRA  L8613          ; TRY AGAIN IF ILLEGAL KEY
L861E     STA  ,X+            ; INSERT NEW CHARACTER INTO BUFFER
          BSR  L8659          ; SEND NEW CHARACTER TO SCREEN
          DECB                ; DECREMENT REPEAT PARAMETER
          BNE  L8613          ; BRANCH IF NOT DONE
L8625     RTS
L8626     LDB  VD7            ; GET LENGTH OF LINE
          CMPB #LBUFMX-1      ; COMPARE TO MAXIMUM LENGTH
          BNE  L862E          ; BRANCH IF NOT AT MAXIMUM
          BRA  L85F5          ; IGNORE INPUT IF LINE AT MAXIMUM LENGTH
L862E     PSHS X              ; SAVE CURRENT BUFFER POINTER
L8630     TST  ,X+            ; * SCAN THE LINE UNTIL END OF
          BNE  L8630          ; * LINE (0) IS FOUND
L8634     LDB  ,-X            ; DECR TEMP LINE POINTER AND GET A CHARACTER
          STB  $01,X          ; PUT CHARACTER BACK DOWN ONE SPOT
          CMPX ,S             ; HAVE WE REACHED STARTING POINT?
          BNE  L8634          ; NO - KEEP GOING
          LEAS $02,S          ; PURGE BUFFER POINTER FROM STACK
          STA  ,X+            ; INSERT NEW CHARACTER INTO THE LINE
          BSR  L8659          ; SEND A CHARACTER TO CONSOLE OUT
          INC  VD7            ; ADD ONE TO BUFFER LENGTH
          BRA  L85F5          ; GET INSERT SUB COMMAND
L8646     CMPA #BS            ; BACKSPACE?
          BNE  L865C          ; NO
L864A     BSR  L8650          ; MOVE POINTER BACK 1, SEND BS TO SCREEN
          DECB                ; DECREMENT REPEAT PARAMETER
          BNE  L864A          ; LOOP UNTIL DONE
          RTS
L8650     CMPX #LINBUF+1      ; COMPARE POINTER TO START OF BUFFER
          BEQ  L8625          ; DO NOT ALLOW BS IF AT START
          LEAX -1,X           ; MOVE POINTER BACK ONE
          LDA  #BS            ; BACK SPACE
L8659     JMP  PUTCHR         ; SEND TO CONSOLE OUT
L865C     CMPA #'K            ; KILL?
          BEQ  L8665          ; YES
          SUBA #'S            ; SEARCH?
          BEQ  L8665          ; YES
          RTS
L8665     PSHS A              ; SAVE KILL/SEARCH FLAG ON STACK
          BSR  L8687          ; * GET A KEYSTROKE (TARGET CHARACTER)
          PSHS A              ; * AND SAVE IT ON STACK
L866B     LDA  ,X             ; GET CURRENT BUFFER CHARACTER
          BEQ  L8685          ; AND RETURN IF END OF LINE
          TST  $01,S          ; CHECK KILL/SEARCH FLAG
          BNE  L8679          ; BRANCH IF KILL
          BSR  L8659          ; SEND A CHARACTER TO CONSOLE OUT
          LEAX $01,X          ; INCREMENT BUFFER POINTER
          BRA  L867C          ; CHECK NEXT INPUT CHARACTER
L8679     JSR  L85D1          ; REMOVE ONE CHARACTER FROM BUFFER
L867C     LDA  ,X             ; GET CURRENT INPUT CHARACTER
          CMPA ,S             ; COMPARE TO TARGET CHARACTER
          BNE  L866B          ; BRANCH IF NO MATCH
          DECB                ; DECREMENT REPEAT PARAMETER
          BNE  L866B          ; BRANCH IF NOT DONE
L8685     PULS Y,PC           ; THE Y PULL WILL CLEAN UP THE STACK FOR THE 2 PSHS A
*
* GET A KEYSTRKE
L8687     JSR  LA171          ; CALL CONSOLE IN : DEV NBR=SCREEN
          CMPA #$7F           ; GRAPHIC CHARACTER?
          BCC  L8687          ; YES - GET ANOTHER CHAR
          CMPA #$5F           ; SHIFT UP ARROW (QUIT INSERT)
          BNE  L8694          ; NO
          LDA  #ESC           ; REPLACE W/ESCAPE CODE
L8694     CMPA #CR            ; ENTER KEY
          BEQ  L86A6          ; YES
          CMPA #ESC           ; ESCAPE?
          BEQ  L86A6          ; YES
          CMPA #BS            ; BACKSPACE?
          BEQ  L86A6          ; YES
          CMPA #SPACE         ; SPACE
          BLO  L8687          ; GET ANOTHER CHAR IF CONTROL CHAR
          ORCC #$01           ; SET CARRY
L86A6     RTS

* TRON
TRON      FCB  SKP1LD         ; SKIP ONE BYTE AND LDA #$4F

* TROFF
TROFF     CLRA                ; TROFF FLAG
          STA  TRCFLG         ; TRON/TROFF FLAG:0=TROFF, <> 0=TRON
          RTS

* POS

POS       LDA  #0             ; GET DEVICE NUMBER
          LDB  LPTPOS         ; GET PRINT POSITION
LA5E8     SEX                 ; CONVERT ACCB TO 2 DIGIT SIGNED INTEGER
          JMP  GIVABF         ; CONVERT ACCD TO FLOATING POINT


* VARPTR
VARPT     JSR  LB26A          ; SYNTAX CHECK FOR '('
          LDD  ARYEND         ; GET ADDR OF END OF ARRAYS
          PSHS B,A            ; SAVE IT ON STACK
          JSR  LB357          ; GET VARIABLE DESCRIPTOR
          JSR  LB267          ; SYNTAX CHECK FOR ')'
          PULS A,B            ; GET END OF ARRAYS ADDR BACK
          EXG  X,D            ; SWAP END OF ARRAYS AND VARIABLE DESCRIPTOR
          CMPX ARYEND         ; COMPARE TO NEW END OF ARRAYS
          BNE  L8724          ; 'FC' ERROR IF VARIABLE WAS NOT DEFINED PRIOR TO CALLING VARPTR
          JMP  GIVABF         ; CONVERT VARIABLE DESCRIPTOR INTO A FP NUMBER

* MID$(OLDSTRING,POSITION,LENGTH)=REPLACEMENT
L86D6     JSR  GETNCH         ; GET INPUT CHAR FROM BASIC
          JSR  LB26A          ; SYNTAX CHECK FOR '('
          JSR  LB357          ; * GET VARIABLE DESCRIPTOR ADDRESS AND
          PSHS X              ; * SAVE IT ON THE STACK
          LDD  $02,X          ; POINT ACCD TO START OF OLDSTRING
          CMPD FRETOP         ; COMPARE TO START OF CLEARED SPACE
          BLS  L86EB          ; BRANCH IF <=
          SUBD MEMSIZ         ; SUBTRACT OUT TOP OF CLEARED SPACE
          BLS  L86FD          ; BRANCH IF STRING IN STRING SPACE
L86EB     LDB  ,X             ; GET LENGTH OF OLDSTRING
          JSR  LB56D          ; RESERVE ACCB BYTES IN STRING SPACE
          PSHS X              ; SAVE RESERVED SPACE STRING ADDRESS ON STACK
          LDX  $02,S          ; POINT X TO OLDSTRING DESCRIPTOR
          JSR  LB643          ; MOVE OLDSTRING INTO STRING SPACE
          PULS X,U            ; * GET OLDSTRING DESCRIPTOR ADDRESS AND RESERVED STRING
          STX  $02,U          ; * ADDRESS AND SAVE RESERVED ADDRESS AS OLDSTRING ADDRESS
          PSHS U              ; SAVE OLDSTRING DESCRIPTOR ADDRESS
L86FD     JSR  LB738          ; SYNTAX CHECK FOR COMMA AND EVALUATE LENGTH EXPRESSION
          PSHS B              ; SAVE POSITION PARAMETER ON STACK
          TSTB                ; * CHECK POSITION PARAMETER AND BRANCH
          BEQ  L8724          ; * IF START OF STRING
          LDB  #$FF           ; DEFAULT REPLACEMENT LENGTH = $FF
          CMPA #')            ; * CHECK FOR END OF MID$ STATEMENT AND
          BEQ  L870E          ; * BRANCH IF AT END OF STATEMENT
          JSR  LB738          ; SYNTAX CHECK FOR COMMA AND EVALUATE LENGTH EXPRESSION
L870E     PSHS B              ; SAVE LENGTH PARAMETER ON STACK
          JSR  LB267          ; SYNTAX CHECK FOR ')'
          LDB  #TOK_EQUALS    ; TOKEN FOR =
          JSR  LB26F          ; SYNTAX CHECK FOR '='
          BSR  L8748          ; EVALUATE REPLACEMENT STRING
          TFR  X,U            ; SAVE REPLACEMENT STRING ADDRESS IN U
          LDX  $02,S          ; POINT X TO OLOSTRING DESCRIPTOR ADDRESS
          LDA  ,X             ; GET LENGTH OF OLDSTRING
          SUBA $01,S          ; SUBTRACT POSITION PARAMETER
          BCC  L8727          ; INSERT REPLACEMENT STRING INTO OLDSTRING
L8724     JMP  LB44A          ; 'FC' ERROR IF POSITION > LENGTH OF OLDSTRING
L8727     INCA                ; * NOW ACCA = NUMBER OF CHARACTERS TO THE RIGHT
*                             ; * (INCLUSIVE) OF THE POSITION PARAMETER
          CMPA ,S
          BCC  L872E          ; BRANCH IF NEW STRING WILL FIT IN OLDSTRING
          STA  ,S             ; IF NOT, USE AS MUCH OF LENGTH PARAMETER AS WILL FIT
L872E     LDA  $01,S          ; GET POSITION PARAMETER
          EXG  A,B            ; ACCA=LENGTH OF REPL STRING, ACCB=POSITION PARAMETER
          LDX  $02,X          ; POINT X TO OLDSTRING ADDRESS
          DECB                ; * BASIC'S POSITION PARAMETER STARTS AT 1; THIS ROUTINE
*                             ; * WANTS IT TO START AT ZERO
          ABX                 ; POINT X TO POSITION IN OLDSTRING WHERE THE REPLACEMENT WILL GO
          TSTA                ; * IF THE LENGTH OF THE REPLACEMENT STRING IS ZERO
          BEQ  L8746          ; * THEN RETURN
          CMPA ,S
          BLS  L873F          ; ADJUSTED LENGTH PARAMETER, THEN BRANCH
          LDA  ,S             ; OTHERWISE USE AS MUCH ROOM AS IS AVAILABLE
L873F     TFR  A,B            ; SAVE NUMBER OF BYTES TO MOVE IN ACCB
          EXG  U,X            ; SWAP SOURCE AND DESTINATION POINTERS
          JSR  LA59A          ; MOVE (B) BYTES FROM (X) TO (U)
L8746     PULS A,B,X,PC
L8748     JSR  LB156          ; EVALUATE EXPRESSION
          JMP  LB654          ; *'TM' ERROR IF NUMERIC; RETURN WITH X POINTING
*                             ; *TO STRING, ACCB = LENGTH

* STRING
STRING    JSR  LB26A          ; SYNTAX CHECK FOR '('
          JSR  LB70B          ; EVALUATE EXPRESSION; ERROR IF > 255
          PSHS B              ; SAVE LENGTH OF STRING
          JSR  LB26D          ; SYNTAX CHECK FOR COMMA
          JSR  LB156          ; EVALUATE EXPRESSION
          JSR  LB267          ; SYNTAX CHECK FOR ')'
          LDA  VALTYP         ; GET VARIABLE TYPE
          BNE  L8768          ; BRANCH IF STRING
          JSR  LB70E          ; CONVERT FPA0 INTO AN INTEGER IN ACCB
          BRA  L876B          ; SAVE THE STRING IN STRING SPACE
L8768     JSR  LB6A4          ; GET FIRST BYTE OF STRING
L876B     PSHS B              ; SAVE FIRST BYTE OF EXPRESSION
          LDB  $01,S          ; GET LENGTH OF STRING
          JSR  LB50F          ; RESERVE ACCB BYTES IN STRING SPACE
          PULS A,B            ; GET LENGTH OF STRING AND CHARACTER
          BEQ  L877B          ; BRANCH IF NULL STRING
L8776     STA  ,X+            ; SAVE A CHARACTER IN STRING SPACE
          DECB                ; DECREMENT LENGTH
          BNE  L8776          ; BRANCH IF NOT DONE
L877B     JMP  LB69B          ; PUT STRING DESCRIPTOR ONTO STRING STACK

* INSTR
INSTR     JSR  LB26A          ; SYNTAX CHECK FOR '('
          JSR  LB156          ; EVALUATE EXPRESSION
          LDB  #$01           ; DEFAULT POSITION = 1 (SEARCH START)
          PSHS B              ; SAVE START
          LDA  VALTYP         ; GET VARIABLE TYPE
          BNE  L879C          ; BRANCH IF STRING
          JSR  LB70E          ; CONVERT FPA0 TO INTEGER IN ACCB
          STB  ,S             ; SAVE START SEARCH VALUE
          BEQ  L8724          ; BRANCH IF START SEARCH AT ZERO
          JSR  LB26D          ; SYNTAX CHECK FOR COMMA
          JSR  LB156          ; EVALUATE EXPRESSION - SEARCH STRING
          JSR  LB146          ; 'TM' ERROR IF NUMERIC
L879C     LDX  FPA0+2         ; SEARCH STRING DESCRIPTOR ADDRESS
          PSHS X              ; SAVE ON THE STACK
          JSR  LB26D          ; SYNTAX CHECK FOR COMMA
          JSR  L8748          ; EVALUATE TARGET STRING EXPRESSION
          PSHS X,B            ; SAVE ADDRESS AND LENGTH ON STACK
          JSR  LB267          ; SYNTAX CHECK FOR ')'
          LDX  $03,S          ; * LOAD X WITH SEARCH STRING DESCRIPTOR ADDRESS
          JSR  LB659          ; * AND GET THE LENGTH ANDADDRESS OF SEARCH STRING
          PSHS B              ; SAVE LENGTH ON STACK
*
* AT THIS POINT THE STACK HAS THE FOLLOWING INFORMATION
* ON IT: 0,S-SEARCH LENGTH; 1,S-TARGET LENGTH; 2 3,S-TARGET
* ADDRESS; 4 5,S-SEARCH DESCRIPTOR ADDRESS; 6,S-SEARCH POSITION
          CMPB $06,S          ; COMPARE LENGTH OF SEARCH STRING TO START
          BLO  L87D9          ; POSITION; RETURN 0 IF LENGTH < START
          LDA  $01,S          ; GET LENGTH OF TARGET STRING
          BEQ  L87D6          ; BRANCH IF TARGET STRING = NULL
          LDB  $06,S          ; GET START POSITION
          DECB                ; MOVE BACK ONE
          ABX                 ; POINT X TO POSITION IN SEARCH STRING WHERE SEARCHING WILL START
L87BE     LEAY ,X             ; POINT Y TO SEARCH POSITION
          LDU  $02,S          ; POINT U TO START OF TARGET
          LDB  $01,S          ; LOAD ACCB WITH LENGTH OF TARGET
          LDA  ,S             ; LOAD ACCA WITH LENGTH OF SEARCH
          SUBA $06,S          ; SUBTRACT SEARCH POSITION FROM SEARCH LENGTH
          INCA                ; ADD ONE
          CMPA $01,S          ; COMPARE TO TARGET LENGTH
          BLO  L87D9          ; RETURN 0 IF TARGET LENGTH > WHAT'S LEFT OF SEARCH STRING
L87CD     LDA  ,X+            ; GET A CHARACTER FROM SEARCH STRING
          CMPA ,U+            ; COMPARE IT TO TARGET STRING
          BNE  L87DF          ; BRANCH IF NO MATCH
          DECB                ; DECREMENT TARGET LENGTH
          BNE  L87CD          ; CHECK ANOTHER CHARACTER
L87D6     LDB  $06,S          ; GET MATCH POSITION
L87D8     FCB  SKP1           ; SKIP NEXT BYTE
L87D9     CLRB                ; MATCH ADDRESS = 0
          LEAS $07,S          ; CLEAN UP THE STACK
          JMP  LB4F3          ; CONVERT ACCB TO FP NUMBER
L87DF     INC  $06,S          ; INCREMENT SEARCH POSITION
          LEAX $01,Y          ; MOVE X TO NEXT SEARCH POSITION
          BRA  L87BE          ; KEEP LOOKING FOR A MATCH

* EXTENDED BASIC RVEC19 HOOK CODE
XVEC19    CMPA #'&            ; *
          BNE  L8845          ; * RETURN IF NOT HEX OR OCTAL VARIABLE
          LEAS $02,S          ; PURGE RETURN ADDRESS FROM STACK
* PROCESS A VARIABLE PRECEEDED BY A '&' (&H,&O)
L87EB     CLR  FPA0+2         ; * CLEAR BOTTOM TWO
          CLR  FPA0+3         ; * BYTES OF FPA0
          LDX  #FPA0+2        ; BYTES 2,3 OF FPA0 = (TEMPORARY ACCUMULATOR)
          JSR  GETNCH         ; GET A CHARACTER FROM BASIC
          CMPA #'O
          BEQ  L880A          ; YES
          CMPA #'H
          BEQ  L881F          ; YES
          JSR  GETCCH         ; GET CURRENT INPUT CHARACTER
          BRA  L880C          ; DEFAULT TO OCTAL (&O)
L8800     CMPA #'8
          LBHI LB277
          LDB  #$03           ; BASE 8 MULTIPLIER
          BSR  L8834          ; ADD DIGIT TO TEMPORARY ACCUMULATOR
* EVALUATE AN &O VARIABLE
L880A     JSR  GETNCH         ; GET A CHARACTER FROM BASIC
L880C     BLO  L8800          ; BRANCH IF NUMERIC
L880E     CLR  FPA0           ; * CLEAR 2 HIGH ORDER
          CLR  FPA0+1         ; * BYTES OF FPA0
          CLR  VALTYP         ; SET VARXABLE TYPE TO NUMERIC
          CLR  FPSBYT         ; ZERO OUT SUB BYTE OF FPA0
          CLR  FP0SGN         ; ZERO OUT MANTISSA SIGN OF FPA0
          LDB  #$A0           ; * SET EXPONENT OF FPA0
          STB  FP0EXP         ; *
          JMP  LBA1C          ; GO NORMALIZE FPA0
* EVALUATE AN &H VARIABLE
L881F     JSR  GETNCH         ; GET A CHARACTER FROM BASIC
          BLO  L882E          ; BRANCH IF NUMERIC
          JSR  LB3A2          ; SET CARRY IF NOT ALPHA
          BLO  L880E          ; BRANCH IF NOT ALPHA OR NUMERIC
          CMPA #'G            ; CHECK FOR LETTERS A-F
          BCC  L880E          ; BRANCH IF >= G (ILLEGAL HEX LETTER)
          SUBA #7             ; SUBTRACT ASCII DIFFERENCE BETWEEN A AND 9
L882E     LDB  #$04           ; BASE 16 DIGIT MULTIPLIER = 2**4
          BSR  L8834          ; ADD DIGIT TO TEMPORARY ACCUMULATOR
          BRA  L881F          ; KEEP EVALUATING VARIABLE
L8834     ASL  $01,X          ; * MULTIPLY TEMPORARY
          ROL  ,X             ; * ACCUMULATOR BY TWO
          LBCS LBA92          ; 'OV' OVERFLOW ERROR
          DECB                ; DECREMENT SHIFT COUNTER
          BNE  L8834          ; MULTIPLY TEMPORARY ACCUMULATOR AGAIN
          SUBA #'0            ; MASK OFF ASCII
          ADDA $01,X          ; * ADD DIGIT TO TEMPORARY
          STA  $01,X          ; * ACCUMULATOR AND SAVE IT
L8845     RTS

XVEC15    PULS U              ; PULL RETURN ADDRESS AND SAVE IN U REGISTER
          CLR  VALTYP         ; SET VARIABLE TYPE TO NUMERIC
          LDX  CHARAD         ; CURRENT INPUT POINTER TO X
          JSR  GETNCH         ; GET CHARACTER FROM BASIC
          CMPA #'&            ; HEX AND OCTAL VARIABLES ARE PRECEEDED BY &
          BEQ  L87EB          ; PROCESS A '&' VARIABLE
          CMPA #TOK_FN        ; TOKEN FOR FN
          BEQ  L88B4          ; PROCESS FN CALL
          CMPA #$FF           ; CHECK FOR SECONDARY TOKEN
          BNE  L8862          ; NOT SECONDARY
          JSR  GETNCH         ; GET CHARACTER FROM BASIC
          CMPA #TOK_USR       ; TOKEN FOR USR
          LBEQ L892C          ; PROCESS USR CALL
L8862     STX  CHARAD         ; RESTORE BASIC'S INPUT POINTER
          JMP  ,U             ; RETURN TO CALLING ROUTINE
L8866     LDX  CURLIN         ; GET CURRENT LINE NUMBER
          LEAX $01,X          ; IN DIRECT MODE?
          BNE  L8845          ; RETURN IF NOT IN DIRECT MODE
          LDB  #2*11          ; 'ILLEGAL DIRECT STATEMENT' ERROR
L886E     JMP  LAC46          ; PROCESS ERROR

DEF       LDX  [CHARAD]       ; GET TWO INPUT CHARS
          CMPX #TOK_FF_USR    ; TOKEN FOR USR
          LBEQ L890F          ; BRANCH IF DEF USR
          BSR  L88A1          ; GET DESCRIPTOR ADDRESS FOR FN VARIABLE NAME
          BSR  L8866          ; DON'T ALLOW DEF FN IF IN DIRECT MODE
          JSR  LB26A          ; SYNTAX CHECK FOR '('
          LDB  #$80           ; * GET THE FLAG TO INDICATE ARRAY VARIABLE SEARCH DISABLE
          STB  ARYDIS         ; * AND SAVE IT IN THE ARRAY DISABLE FLAG
          JSR  LB357          ; GET VARIABLE DESCRIPTOR
          BSR  L88B1          ; 'TM' ERROR IF STRING
          JSR  LB267          ; SYNTAX CHECK FOR ')'
          LDB  #TOK_EQUALS    ; TOKEN FOR '='
          JSR  LB26F          ; DO A SYNTAX CHECK FOR =
          LDX  V4B            ; GET THE ADDRESS OF THE FN NAME DESCRIPTOR
          LDD  CHARAD         ; * GET THE CURRENT INPUT POINTER ADDRESS AND
          STD  ,X             ; * SAVE IT IN FIRST 2 BYTES OF THE DESCRIPTOR
          LDD  VARPTR         ; = GET THE DESCRIPTOR ADDRESS OF THE ARGUMENT
          STD  $02,X          ; = VARIABLE AND SAVE IT IN THE DESCRIPTOR OF THE FN NAME
          JMP  DATA           ; MOVE INPUT POINTER TO END OF LINE OR SUBLINE
L88A1     LDB  #TOK_FN        ; TOKEN FOR FN
          JSR  LB26F          ; DO A SYNTAX CHECK FOR FN
          LDB  #$80           ; * GET THE FLAG TO INDICATE ARRAY VARIABLE SEARCH DISABLE FLAG
          STB  ARYDIS         ; * AND SAVE IT IN ARRAY VARIABLE FLAG
          ORA  #$80           ; SET BIT 7 OF CURRENT INPUT CHARACTER TO INDICATE AN FN VARIABLE
          JSR  LB35C          ; * GET THE DESCRIPTOR ADDRESS OF THIS
          STX  V4B            ; * VARIABLE AND SAVE IT IN V4B
L88B1     JMP  LB143          ; 'TM' ERROR IF STRING VARIABLE
* EVALUATE AN FN CALL
L88B4     BSR  L88A1          ; * GET THE DESCRIPTOR OF THE FN NAME
          PSHS X              ; * VARIABLE AND SAVE IT ON THE STACK
          JSR  LB262          ; SYNTAX CHECK FOR '(' & EVALUATE EXPR
          BSR  L88B1          ; 'TM' ERROR IF STRING VARIABLE
          PULS U              ; POINT U TO FN NAME DESCRIPTOR
          LDB  #2*25          ; 'UNDEFINED FUNCTION CALL' ERROR
          LDX  $02,U          ; POINT X TO ARGUMENT VARIABLE DESCRIPTOR
          BEQ  L886E          ; BRANCH TO ERROR HANDLER
          LDY  CHARAD         ; SAVE CURRENT INPUT POINTER IN Y
          LDU  ,U             ; * POINT U TO START OF FN FORMULA AND
          STU  CHARAD         ; * SAVE IT IN INPUT POINTER
          LDA  $04,X          ; = GET FP VALUE OF
          PSHS A              ; = ARGUMENT VARIABLE, CURRENT INPUT
          LDD  ,X             ; = POINTER, AND ADDRESS OF START
          LDU  $02,X          ; = OF FN FORMULA AND SAVE
          PSHS U,Y,X,B,A      ; = THEM ON THE STACK
          JSR  LBC35          ; PACK FPA0 AND SAVE IT IN (X)
L88D9     JSR  LB141          ; EVALUATE FN EXPRESSION
          PULS A,B,X,Y,U      ; RESTORE REGISTERS
          STD  ,X             ; * GET THE FP
          STU  $02,X          ; * VALUE OF THE ARGUMENT
          PULS A              ; * VARIABLE OFF OF THE
          STA  $04,X          ; * STACK AND RE-SAVE IT
          JSR  GETCCH         ; GET FINAL CHARACTER OF THE FN FORMULA
          LBNE LB277          ; 'SYNTAX' ERROR IF NOT END OF LINE
          STY  CHARAD         ; RESTORE INPUT POINTER
L88EF     RTS



* DEF USR
L890F     JSR  GETNCH         ; SKIP PAST SECOND BYTE OF DEF USR TOKEN
          BSR  L891C          ; GET FN NUMBER
          PSHS X              ; SAVE FN EXEC ADDRESS STORAGE LOC
          BSR  L8944          ; CALCULATE EXEC ADDRESS
          PULS U              ; GET FN EXEC ADDRESS STORAGE LOC
          STX  ,U             ; SAVE EXEC ADDRESS
          RTS
L891C     CLRB                ; DEFAULT TO USR0 IF NO ARGUMENT
          JSR  GETNCH         ; GET A CHARACTER FROM BASIC
          BCC  L8927          ; BRANCH IF NOT NUMERIC
          SUBA #'0            ; MASK OFF ASCII
          TFR  A,B            ; SAVE USR NUMBER IN ACCB
          JSR  GETNCH         ; GET A CHARACTER FROM BASIC
L8927     LDX  USRADR         ; GET ADDRESS OF STORAGE LOCs FOR USR ADDRESS
          ASLB                ; X2 - 2 BYTES/USR ADDRESS
          ABX                 ; ADD OFFSET TO START ADDRESS OF STORAGE LOCs
          RTS
* PROCESS A USR CALL
L892C     BSR  L891C          ; GET STORAGE LOC OF EXEC ADDRESS FOR USR N
          LDX  ,X             ; * GET EXEC ADDRESS AND
          PSHS X              ; * PUSH IT ONTO STACK
          JSR  LB262          ; SYNTAX CHECK FOR '(' & EVALUATE EXPR
          LDX  #FP0EXP        ; POINT X TO FPA0
          LDA  VALTYP         ; GET VARIABLE TYPE
          BEQ  L8943          ; BRANCH IF NUMERIC, STRING IF <> 0
          JSR  LB657          ; GET LENGTH & ADDRESS OF STRING VARIABLE
          LDX  FPA0+2         ; GET POINTER TO STRING DESCRIPTOR
          LDA  VALTYP         ; GET VARIABLE TYPE
L8943     RTS                 ; JUMP TO USR ROUTINE (PSHS X ABOVE)
L8944     LDB  #TOK_EQUALS    ; TOKEN FOR '='
          JSR  LB26F          ; DO A SYNTAX CHECK FOR =
          JMP  LB73D          ; EVALUATE EXPRESSION, RETURN VALUE IN X



* DEL
DEL       LBEQ LB44A          ; 'FC' ERROR IF NO ARGUMENT
          JSR  LAF67          ; CONVERT A DECIMAL BASiC NUMBER TO BINARY
          JSR  LAD01          ; FIND RAM ADDRESS OF START OF A BASIC LINE
          STX  VD3            ; SAVE RAM ADDRESS OF STARTING LINE NUMBER
          JSR  GETCCH         ; GET CURRENT INPUT CHARACTER
          BEQ  L8990          ; BRANCH IF END OF LINE
          CMPA #TOK_MINUS     ; TOKEN FOR '-'
          BNE  L89BF          ; TERMINATE COMMAND IF LINE NUMBER NOT FOLLOWED BY '-'
          JSR  GETNCH         ; GET A CHARACTER FROM BASIC
          BEQ  L898C          ; IF END OF LINE, USE DEFAULT ENDING LINE NUMBER
          BSR  L89AE          ; * CONVERT ENDING LINE NUMBER TO BINARY
          BRA  L8990          ; * AND SAVE IT IN BINVAL
L898C     LDA  #$FF           ; = USE $FFXX AS DEFAULT ENDING
          STA  BINVAL         ; = LINE NUMBER - SAVE IT IN BINVAL
L8990     LDU  VD3            ; POINT U TO STARTING LINE NUMBER ADDRESS
L8992     FCB  SKP2           ; SKIP TWO BYTES
L8993     LDU  ,U             ; POINT U TO START OF NEXT LINE
          LDD  ,U             ; CHECK FOR END OF PROGRAM
          BEQ  L899F          ; BRANCH IF END OF PROGRAM
          LDD  $02,U          ; LOAD ACCD WITH THIS LINE'S NUMBER
          SUBD BINVAL         ; SUBTRACT ENDING LINE NUMBER ADDRESS
          BLS  L8993          ; BRANCH IF = < ENDING LINE NUMBER
L899F     LDX  VD3            ; GET STARTING LINE NUMBER
          BSR  L89B8          ; MOVE (U) TO (X) UNTIL END OF PROGRAM
          JSR  LAD21          ; RESET BASIC'S INPUT POINTER AND ERASE VARIABLES
          LDX  VD3            ; GET STARTING LINE NUMBER ADDRESS
          JSR  LACF1          ; RECOMPUTE START OF NEXT LINE ADDRESSES
          JMP  LAC73          ; JUMP TO BASIC'S MAIN COMMAND LOOP
L89AE     JSR  LAF67          ; GO GET LINE NUMBER CONVERTED TO BINARY
          JMP  LA5C7          ; MAKE SURE THERE'S NO MORE ON THIS LINE
L89B4     LDA  ,U+            ; GET A BYTE FROM (U)
          STA  ,X+            ; MOVE THE BYTE TO (X)
L89B8     CMPU VARTAB         ; COMPARE TO END OF BASIC
          BNE  L89B4          ; BRANCH IF NOT AT END
          STX  VARTAB         ; SAVE (X) AS NEW END OF BASIC
L89BF     RTS


L89C0     JSR  L8866          ; 'BS' ERROR IF IN DIRECT MODE
          JSR  GETNCH         ; GET A CHAR FROM BASIC
L89D2     CMPA #'"            ; CHECK FOR PROMPT STRING
          BNE  L89E1          ; BRANCH IF NO PROMPT STRING
          JSR  LB244          ; STRIP OFF PROMPT STRING & PUT IT ON STRING STACK
          LDB  #';            ; *
          JSR  LB26F          ; * DO A SYNTAX CHECK FOR;
          JSR  LB99F          ; REMOVE PROMPT STRING FROM STRING STACK & SEND TO CONSOLE OUT
L89E1     LEAS -2,S           ; RESERVE TWO STORAGE SLOTS ON STACK
          JSR  LB035          ; INPUT A LINE FROM CURRENT INPUT DEVICE
          LEAS $02,S          ; CLEAN UP THE STACK
          JSR  LB357          ; SEARCH FOR A VARIABLE
          STX  VARDES         ; SAVE POINTER TO VARIABLE DESCRIPTOR
          JSR  LB146          ; ''TM' ERROR IF VARIABLE TYPE = NUMERIC
          LDX  #LINBUF        ; POINT X TO THE STRING BUFFER WHERE THE INPUT STRING WAS STORED
          CLRA                ; TERMINATOR CHARACTER 0 (END OF LINE)
          JSR  LB51A          ; PARSE THE INPUT STRING AND STORE IT IN THE STRING SPACE
          JMP  LAFA4          ; REMOVE DESCRIPTOR FROM STRING STACK
L89FC     JSR  LAF67          ; STRIP A DECIMAL NUMBER FROM BASIC INPUT LINE
          LDX  BINVAL         ; GET BINARY VALUE
          RTS
L8A02     LDX  VD1            ; GET CURRENT OLD NUMBER BEING RENUMBERED
L8A04     STX  BINVAL         ; SAVE THE LINE NUMBER BEING SEARCHED FOR
          JMP  LAD01          ; GO FIND THE LINE NUMBER IN BASIC PROGRAM

* RENUM
RENUM     JSR  LAD26          ; ERASE VARIABLES
          LDD  #10            ; DEFAULT LINE NUMBER INTERVAL
          STD  VD5            ; SAVE DEFAULT RENUMBER START LINE NUMBER
          STD  VCF            ; SAVE DEFAULT INTERVAL
          CLRB                ; NOW ACCD = 0
          STD  VD1            ; DEFAULT LINE NUMBER OF WHERE TO START RENUMBERING
          JSR  GETCCH         ; GET CURRENT INPUT CHARACTER
          BCC  L8A20          ; BRANCH IF NOT NUMERIC
          BSR  L89FC          ; CONVERT DECIMAL NUMBER IN BASIC PROGRAM TO BINARY
          STX  VD5            ; SAVE LINE NUMBER WHERE RENUMBERING STARTS
          JSR  GETCCH         ; GET CURRENT INPUT CHARACTER
L8A20     BEQ  L8A3D          ; BRANCH IF END OF LINE
          JSR  LB26D          ; SYNTAX CHECK FOR COMMA
          BCC  L8A2D          ; BRANCH IF NEXT CHARACTER NOT NUMERIC
          BSR  L89FC          ; CONVERT DECIMAL NUMBER IN BASIC PROGRAM TO BINARY
          STX  VD1            ; SAVE NEW RENUMBER LINE
          JSR  GETCCH         ; GET CURRENT INPUT CHARACTER
L8A2D     BEQ  L8A3D          ; BRANCH IF END OF LINE
          JSR  LB26D          ; SYNTAX CHECK FOR COMMA
          BCC  L8A3A          ; BRANCH IF NEXT CHARACTER NOT NUMERIC
          BSR  L89FC          ; CONVERT DECIMAL NUMBER IN BASIC PROGRAM TO BINARY
          STX  VCF            ; SAVE NEW INTERVAL
          BEQ  L8A83          ; 'FC' ERROR
L8A3A     JSR  LA5C7          ; CHECK FOR MORE CHARACTERS ON LINE - 'SYNTAX' ERROR IF ANY
L8A3D     BSR  L8A02          ; GO GET ADDRESS OF OLD NUMBER BEING RENUMBERED
          STX  VD3            ; SAVE ADDRESS
          LDX  VD5            ; GET NEXT RENUMBERED LINE NUMBER TO USE
          BSR  L8A04          ; FIND THE LINE NUMBER IN THE BASIC PROGRAM
          CMPX VD3            ; COMPARE TO ADDRESS OF OLD LINE NUMBER
          BLO  L8A83          ; 'FC' ERROR IF NEW ADDRESS < OLD ADDRESS
          BSR  L8A67          ; MAKE SURE RENUMBERED LINE NUMBERS WILL BE IN RANGE
          JSR  L8ADD          ; CONVERT ASCII LINE NUMBERS TO 'EXPANDED' BINARY
          JSR  LACEF          ; RECALCULATE NEXT LINE RAM ADDRESSES
          BSR  L8A02          ; GET RAM ADDRESS OF FIRST LINE TO BE RENUMBERED
          STX  VD3            ; SAVE IT
          BSR  L8A91          ; MAKE SURE LINE NUMBERS EXIST
          BSR  L8A68          ; INSERT NEW LINE NUMBERS IN LINE HEADERS
          BSR  L8A91          ; INSERT NEW LINE NUMBERS IN PROGRAM STATEMENTS
          JSR  L8B7B          ; CONVERT PACKED BINARY LINE NUMBERS TO ASCII
          JSR  LAD26          ; ERASE VARIABLES
          JSR  LACEF          ; RECALCULATE NEXT LINE RAM ADDRESS
          JMP  LAC73          ; GO BACK TO BASIC'S MAIN LOOP
L8A67     FCB  SKP1LD         ; SKIP ONE BYTE - LDA #$4F
L8A68     CLRA                ; NEW LINE NUMBER FLAG - 0; INSERT NEW LINE NUMBERS
          STA  VD8            ; SAVE NEW LINE NUMBER FLAG; 0 = INSERT NEW NUMBERS
          LDX  VD3            ; GET ADDRESS OF OLD LINE NUMBER BEING RENUMBERED
          LDD  VD5            ; GET THE CURRENT RENUMBERED LINE NUMBER
          BSR  L8A86          ; RETURN IF END OF PROGRAM
L8A71     TST  VD8            ; CHECK NEW LINE NUMBER FLAG
          BNE  L8A77          ; BRANCH IF NOT INSERTING NEW LINE NUMBERS
          STD  $02,X          ; STORE THE NEW LINE NUMBER IN THE BASIC PROGRAM
L8A77     LDX  ,X             ; POINT X TO THE NEXT LINE IN BASIC
          BSR  L8A86          ; RETURN IF END OF PROGRAM
          ADDD VCF            ; ADD INTERVAL TO CURRENT RENUMBERED LINE NUMBER
          BLO  L8A83          ; 'FC' ERROR IF LINE NUMBER > $FFFF
          CMPA #MAXLIN        ; LARGEST LINE NUMBER = $F9FF
          BLO  L8A71          ; BRANCH IF LEGAL LINE NUMBER
L8A83     JMP  LB44A          ; 'FC' ERROR IF LINE NUMBER MS BYTE > $F9
* TEST THE TWO BYTES POINTED TO BY (X).
* NORMAL RETURN IF <> 0. IF = 0 (END OF
* PROGRAM) RETURN IS PULLED OFF STACK AND
* YOU RETURN TO PREVIOUS SUBROUTINE CALL.
L8A86     PSHS B,A            ; SAVE ACCD
          LDD  ,X             ; TEST THE 2 BYTES POINTED TO BY X
          PULS A,B            ; RESTORE ACCD
          BNE  L8A90          ; BRANCH IF NOT END OF PROGRAM
          LEAS $02,S          ; PURGE RETURN ADDRESS FROM STACK
L8A90     RTS
L8A91     LDX  TXTTAB         ; GET START OF BASIC PROGRAM
          LEAX -1,X           ; MOVE POINTER BACK ONE
L8A95     LEAX $01,X          ; MOVE POINTER UP ONE
          BSR  L8A86          ; RETURN IF END OF PROGRAM
L8A99     LEAX $03,X          ; SKIP OVER NEXT LINE ADDRESS AND LINE NUMBER
L8A9B     LEAX $01,X          ; MOVE POINTER TO NEXT CHARACTER
          LDA  ,X             ; CHECK CURRENT CHARACTER
          BEQ  L8A95          ; BRANCH IF END OF LINE
          STX  TEMPTR         ; SAVE CURRENT POINTER
          DECA                ; =
          BEQ  L8AB2          ; =BRANCH IF START OF PACKED NUMERIC LINE
          DECA                ; *
          BEQ  L8AD3          ; *BRANCH IF LINE NUMBER EXISTS
          DECA                ; =
          BNE  L8A9B          ; =MOVE TO NEXT CHARACTER IF > 3
L8AAC     LDA  #$03           ; * SET 1ST BYTE = 3 TO INDICATE LINE
          STA  ,X+            ; * NUMBER DOESN'T CURRENTLY EXIST
          BRA  L8A99          ; GO GET ANOTHER CHARACTER
L8AB2     LDD  $01,X          ; GET MS BYTE OF LINE NUMBER
          DEC  $02,X          ; DECREMENT ZERO CHECK BYTE
          BEQ  L8AB9          ; BRANCH IF MS BYTE <> 0
          CLRA                ; CLEAR MS BYTE
L8AB9     LDB  $03,X          ; GET LS BYTE OF LINE NUMBER
          DEC  $04,X          ; DECREMENT ZERO CHECK FLAG
          BEQ  L8AC0          ; BRANCH IF IS BYTE <> 0
          CLRB                ; CLEAR LS BYTE
L8AC0     STD  $01,X          ; SAVE BINARY LINE NUMBER
          STD  BINVAL         ; SAVE TRIAL LINE NUMBER
          JSR  LAD01          ; FIND RAM ADDRESS OF A BASIC LINE NUMBER
L8AC7     LDX  TEMPTR         ; GET BACK POINTER TO START OF PACKED LINE NUMBER
          BLO  L8AAC          ; BRANCH IF NO LINE NUMBER MATCH FOUND
          LDD  V47            ; GET START ADDRESS OF LINE NUMBER
          INC  ,X+            ; * SET 1ST BYTE = 2, TO INDICATE LINE NUMBER EXISTS IF CHECKING FOR
*              ; * EXISTENCE OF LINE NUMBER, SET IT = 1 IF INSERTING LINE NUMBERS

          STD  ,X             ; SAVE RAM ADDRESS OF CORRECT LINE NUMBER
          BRA  L8A99          ; GO GET ANOTHER CHARACTER
L8AD3     CLR  ,X             ; CLEAR CARRY FLAG AND 1ST BYTE
          LDX  $01,X          ; POINT X TO RAM ADDRESS OF CORRECT LINE NUMBER
          LDX  $02,X          ; PUT CORRECT LINE NUMBER INTO (X)
          STX  V47            ; SAVE IT TEMPORARILY
          BRA  L8AC7          ; GO INSERT IT INTO BASIC LINE
L8ADD     LDX  TXTTAB         ; GET BEGINNING OF BASIC PROGRAM
          BRA  L8AE5
L8AE1     LDX  CHARAD         ; *GET CURRENT INPUT POINTER
          LEAX $01,X          ; *AND BUMP IT ONE
L8AE5     BSR  L8A86          ; RETURN IF END OF PROGRAM
          LEAX $02,X          ; SKIP PAST NEXT LINE ADDRESS
L8AE9     LEAX $01,X          ; ADVANCE POINTER BY ONE
L8AEB     STX  CHARAD         ; SAVE NEW BASIC INPUT POINTER
L8AED     JSR  GETNCH         ; GET NEXT CHARACTER FROM BASIC
L8AEF     TSTA                ; CHECK THE CHARACTER
          BEQ  L8AE1          ; BRANCH IF END OF LINE
          BPL  L8AED          ; BRANCH IF NOT A TOKEN
          LDX  CHARAD         ; GET CURRENT INPUT POINTER
          CMPA #$FF           ; IS THIS A SECONDARY TOKEN?
          BEQ  L8AE9          ; YES - IGNORE IT
          CMPA #TOK_THEN      ; TOKEN FOR THEN?
          BEQ  L8B13          ; YES
          CMPA #TOK_ELSE      ; TOKEN FOR ELSE?
          BEQ  L8B13          ; YES
          CMPA #TOK_GO        ; TOKEN FOR GO?
          BNE  L8AED          ; NO
          JSR  GETNCH         ; GET A CHARACTER FROM BASIC
          CMPA #TOK_TO        ; TOKEN FOR TO?
          BEQ  L8B13          ; YES
          CMPA #TOK_SUB       ; TOKEN FOR SUB?
          BNE  L8AEB          ; NO
L8B13     JSR  GETNCH         ; GET A CHARACTER FROM BASIC
          BLO  L8B1B          ; BRANCH IF NUMERIC
L8B17     JSR  GETCCH         ; GET CURRENT BASIC INPUT CHARRACTER
          BRA  L8AEF          ; KEEP CHECKING THE LINE
L8B1B     LDX  CHARAD         ; GET CURRENT INPUT ADDRESS
          PSHS X              ; SAVE IT ON THE STACK
          JSR  LAF67          ; CONVERT DECIMAL BASIC NUMBER TO BINARY
          LDX  CHARAD         ; GET CURRENT INPUT POINTER
L8B24     LDA  ,-X            ; GET PREVIOUS INPUT CHARACTER
          JSR  L90AA          ; CLEAR CARRY IF NUMERIC INPUT VALUE
          BLO  L8B24          ; BRANCH IF NON-NUMERIC
          LEAX $01,X          ; MOVE POINTER UP ONE
          TFR  X,D            ; NOW ACCD POINTS TO ONE PAST END OF LINE NUMBER
          SUBB $01,S          ; SUBTRACT PRE-NUMERIC POINTER LS BYTE
          SUBB #$05           ; MAKE SURE THERE ARE AT LEAST 5 CHARACTERS IN THE NUMERIC LINE
*
          BEQ  L8B55          ; BRANCH IF EXACTLY 5
          BLO  L8B41          ; BRANCH IF < 5
          LEAU ,X             ; TRANSFER X TO U
          NEGB                ; NEGATE B
          LEAX B,X            ; MOVE X BACK B BYTES
          JSR  L89B8          ; *MOVE BYTES FROM (U) TO (X) UNTIL
*         *U   = END OF BASIC; (I) = NEW END OF BASIC
          BRA  L8B55
* FORCE FIVE BYTES OF SPACE FOR THE LINE NUMBER
L8B41     STX  V47            ; SAVE END OF NUMERIC VALUE
          LDX  VARTAB         ; GET END OF BASIC PROGRAM
          STX  V43            ; SAVE IT
          NEGB                ; NEGATE B
          LEAX B,X            ; ADD IT TO END OF NUMERIC POiNTER
          STX  V41            ; SAVE POINTER
          STX  VARTAB         ; STORE END OF BASIC PROGRAM
          JSR  LAC1E          ; ACCD = TOP OF ARRAYS - CHECK FOR ENOUGH ROOM
          LDX  V45            ; * GET AND SAVE THE
          STX  CHARAD         ; * NEW CURRENT INPUT POINTER
L8B55     PULS X              ; RESTORE POINTER TO START OF NUMERIC VALUE
          LDA  #$01           ; NEW LINE NUMBER FLAG
          STA  ,X             ; * SAVE NEW LINE FLAG
          STA  $02,X          ; *
          STA  $04,X          ; *
          LDB  BINVAL         ; GET MS BYTE OF BINARY LINE NUMBER
          BNE  L8B67          ; BRANCH IF IT IS NOT ZERO
          LDB  #$01           ; ; SAVE A 1 IF BYTE IS 0; OTHERWISE, BASIC WILL
*              ; THINK IT IS THE END OF A LINE
          INC  $02,X          ; IF 2,X = 2, THEN PREVIOUS BYTE WAS A ZERO
L8B67     STB  $01,X          ; SAVE MS BYTE OF BINARY LINE NUMBER
          LDB  BINVAL+1       ; GET IS BYTE OF BINARY LINE NUMBER
          BNE  L8B71          ; BRANCH IF NOT A ZERO BYTE
          LDB  #$01           ; SAVE A 1 IF BYTE IS A 0
          INC  $04,X          ; IF 4,X = 2, THEN PREVIOUS BYTE WAS A 0
L8B71     STB  $03,X          ; SAVE LS BYTE OF BINARY LINE NUMBER
          JSR  GETCCH         ; GET CURRENT INPUT CHARACTER
          CMPA #',            ; IS IT A COMMA?
          BEQ  L8B13          ; YES - PROCESS ANOTHER NUMERIC VALUE
          BRA  L8B17          ; NO - GO GET AND PROCESS AN INPUT CHARACTER
L8B7B     LDX  TXTTAB         ; POINT X TO START OF BASIC PROGRAM
          LEAX -1,X           ; MOVE POINTER BACK ONE
L8B7F     LEAX $01,X          ; MOVE POINTER UP ONE
          LDD  $02,X          ; GET ADDRESS OF NEXT LINE
          STD  CURLIN         ; SAVE IT IN CURLIN
          JSR  L8A86          ; RETURN IF END OF PROGRAM
          LEAX $03,X          ; SKIP OVER ADDRESS OF NEXT LINE AND 1ST BYTE OF LINE NUMBER
L8B8A     LEAX $01,X          ; MOVE POINTER UP ONE
L8B8C     LDA  ,X             ; GET CURRENT CHARACTER
          BEQ  L8B7F          ; BRANCH IF END OF LINE
          DECA                ; INPUT CHARACTER = 1? - VALID LINE NUMBER
          BEQ  L8BAE          ; YES
          SUBA #$02           ; INPUT CHARACTER 3? - UL LINE NUMBER
          BNE  L8B8A          ; NO
          PSHS X              ; SAVE CURRENT POSITION OF INPUT POINTER
          LDX  #L8BD9-1       ; POINT X TO 'UL' MESSAGE
          JSR  LB99C          ; PRINT STRING TO THE SCREEN
          LDX  ,S             ; GET INPUT POINTER
          LDD  $01,X          ; GET THE UNDEFINED LINE NUMBER
          JSR  LBDCC          ; CONVERT NUMBER IN ACCD TO DECIMAL AND DISPLAY IT
          JSR  LBDC5          ; PRINT 'IN XXXX' XXXX = CURRENT LINE NUMBER
          JSR  LB958          ; SEND A CR TO CONSOLE OUT
          PULS X              ; GET INPUT POINTER BACK
L8BAE     PSHS X              ; SAVE CURRENT POSITION OF INPUT POINTER
          LDD  $01,X          ; LOAD ACCD WITH BINARY VALUE OF LINE NUMBER
          STD  FPA0+2         ; SAVE IN BOTTOM 2 BYTES OF FPA0
          JSR  L880E          ; ADJUST REST OF FPA0 AS AN INTEGER
          JSR  LBDD9          ; CONVERT FPA0 TO ASCII, STORE IN LINE NUMBER
          PULS U              ; LOAD U WITH PREVIOUS ADDRESS OF INPUT POINTER
          LDB  #$05           ; EACH EXPANDED LINE NUMBER USES 5 BYTES
L8BBE     LEAX $01,X          ; MOVE POINTER FORWARD ONE
          LDA  ,X             ; GET AN ASCII BYTE
          BEQ  L8BC9          ; BRANCH IF END OF NUMBER
          DECB                ; DECREMENT BYTE COUNTER
          STA  ,U+            ; STORE ASCII NUMBER IN BASIC LINE
          BRA  L8BBE          ; CHECK FOR ANOTHER DIGIT
L8BC9     LEAX ,U             ; TRANSFER NEW LINE POINTER TO (X)
          TSTB                ; DOES THE NEW LINE NUMBER REQUIRE 5 BYTES?
          BEQ  L8B8C          ; YES - GO GET ANOTHER INPUT CHARACTER
          LEAY ,U             ; SAVE NEW LINE POINTER IN Y
          LEAU B,U            ; POINT U TO END OF 5 BYTE PACKED LINE NUMBER BLOCK
          JSR  L89B8          ; MOVE BYTES FROM (U) TO (X) UNTIL END OF PROGRAM
          LEAX ,Y             ; LOAD (X) WITH NEW LINE POINTER
          BRA  L8B8C          ; GO GET ANOTHER INPUT CHARACTER

L8BD9     FCC  "UL "          ; UNKNOWN LINE NUMBER MESSAGE
          FCB  0


HEXDOL    JSR  LB740          ; CONVERT FPA0 INTO A POSITIVE 2 BYTE INTEGER
          LDX  #STRBUF+2      ; POINT TO TEMPORARY BUFFER
          LDB  #$04           ; CONVERT 4 NIBBLES
L8BE5     PSHS B              ; SAVE NIBBLE COUNTER
          CLRB                ; CLEAR CARRY FLAG
          LDA  #$04           ; 4 SHIFTS
L8BEA     ASL  FPA0+3         ; * SHIFT BOTTOM TWO BYTES OF
          ROL  FPA0+2         ; * FPA0 LEFT ONE BIT (X2)
          ROLB                ; IF OVERFLOW, ACCB <> 0
          DECA                ; * DECREMENT SHIFT COUNTER AND
          BNE  L8BEA          ; * BRANCH IF NOT DONE
          TSTB                ; CHECK FOR OVERFLOW
          BNE  L8BFF          ; BRANCH IF OVERFLOW
          LDA  ,S             ; * GET NIBBLE COUNTER,
          DECA                ; * DECREMENT IT AND
          BEQ  L8BFF          ; * BRANCH IF DONE
          CMPX #STRBUF+2      ; DO NOT DO A CONVERSION UNTIL A NON-ZERO
          BEQ  L8C0B          ; BYTE IS FOUND - LEADING ZERO SUPPRESSION
L8BFF     ADDB #'0            ; ADD IN ASCII ZERO
          CMPB #'9            ; COMPARE TO ASCII 9
          BLS  L8C07          ; BRANCH IF < 9
          ADDB #7             ; ADD ASCII OFFSET IF HEX LETTER
L8C07     STB  ,X+            ; STORE HEX VALUE AND ADVANCE POINTER
          CLR  ,X             ; CLEAR NEXT BYTE - END OF STRING FLAG
L8C0B     PULS B              ; * GET NIBBLE COUNTER,
          DECB                ; * DECREMENT IT AND
          BNE  L8BE5          ; * BRANCH IF NOT DONE
          LEAS $02,S          ; PURGE RETURN ADDRESS OFF OF STACK
          LDX  #STRBUF+1      ; RESET POINTER
          JMP  LB518          ; SAVE STRING ON STRING STACK
* PROCESS EXCLAMATION POINT
L8E37     LDA  #$01           ; * SET SPACES
          STA  VD9            ; * COUNTER = 1
* PROCESS STRING ITEM - LIST
L8E3B     DECB                ; DECREMENT FORMAT STRING LENGTH COUNTER
          JSR  L8FD8          ; SEND A '+' TO CONSOLE OUT IF VDA <>0
          JSR  GETCCH         ; GET CURRENT INPUT CHARACTER
          LBEQ L8ED8          ; EXIT PRINT USING IF END OF LINE
          STB  VD3            ; SAVE REMAINDER FORMAT STRING LENGTH
          JSR  LB156          ; EVALUATE EXPRESSION
          JSR  LB146          ; 'TM' ERROR IF NUMERIC VARIABLE
          LDX  FPA0+2         ; * GET ITEM - LIST DESCRIPTOR ADDRESS
          STX  V4D            ; * AND SAVE IT IN V4D
          LDB  VD9            ; GET SPACES COUNTER
          JSR  LB6AD          ; PUT ACCB BYTES INTO STRING SPACE & PUT DESCRIPTOR ON STRING STACK
          JSR  LB99F          ; PRINT THE FORMATTED STRING TO CONSOLE OUT
* PAD FORMAT STRING WITH SPACES IF ITEM - LIST STRING < FORMAT STRING LENGTH
          LDX  FPA0+2         ; POINT X TO FORMATTED STRING DESCRIPTOR ADDRESS
          LDB  VD9            ; GET SPACES COUNTER
          SUBB ,X             ; SUBTRACT LENGTH OF FORMATTED STRING
L8E5F     DECB                ; DECREMENT DIFFERENCE
          LBMI L8FB3          ; GO INTERPRET ANOTHER ITEM - LIST
          JSR  LB9AC          ; PAD FORMAT STRING WITH A SPACE
          BRA  L8E5F          ; KEEP PADDING
* PERCENT SIGN - PROCESS A %SPACES% COMMAND
L8E69     STB  VD3            ; * SAVE THE CURRENT FORMAT STRING
          STX  TEMPTR         ; * COUNTER AND POINTER
          LDA  #$02           ; INITIAL SPACES COUNTER = 2
          STA  VD9            ; SAVE IN SPACES COUNTER
L8E71     LDA  ,X             ; GET A CHARACTER FROM FORMAT STRING
          CMPA #'%            ; COMPARE TO TERMINATOR CHARACTER
          BEQ  L8E3B          ; BRANCH IF END OF SPACES COMMAND
          CMPA #'             ; BLANK
          BNE  L8E82          ; BRANCH IF ILLEGAL CHARACTER
          INC  VD9            ; ADD ONE TO SPACES COUNTER
          LEAX $01,X          ; MOVE FORMAT POINTER UP ONE
          DECB                ; DECREMENT LENGTH COUNTER
          BNE  L8E71          ; BRANCH IF NOT END OF FORMAT STRING
L8E82     LDX  TEMPTR         ; * RESTORE CURRENT FORMAT STRING COUNTER
          LDB  VD3            ; * AND POINTER TO POSITION BEFORE SPACES COMMAND
          LDA  #'%            ; SEND A '%' TO CONSOLE OUT AS A DEBUGGING AID
* ERROR PROCESSOR - ILLEGAL CHARACTER OR BAD SYNTAX IN FORMAT STRING
L8E88     JSR  L8FD8          ; SEND A '+' TO CONSOLE OUT IF VDA <> 0
          JSR  PUTCHR         ; SEND CHARACTER TO CONSOLE OUT
          BRA  L8EB9          ; GET NEXT CHARACTER IN FORMAT STRING

* PRINT RAM HOOK
XVEC9     CMPA #TOK_USING     ; USING TOKEN
          BEQ  L8E95          ; BRANCH IF PRINT USING
          RTS

* PRINT USING
* VDA IS USED AS A STATUS BYTE: BIT 6 = COMMA FORCE
* BIT 5=LEADING ASTERISK FORCE; BIT 4 = FLOATING $ FORCE
* BIT 3 = PRE SIGN FORCE; BIT 2 = POST SIGN FORCE; BIT 0 = EXPONENTIAL FORCE
L8E95     LEAS $02,S          ; PURGE RETURN ADDRESS OFF THE STACK
          JSR  LB158          ; EVALUATE FORMAT STRING
          JSR  LB146          ; 'TM' ERROR IF VARIABLE TYPE = NUMERIC
          LDB  #';            ; CHECK FOR ITEM LIST SEPARATOR
          JSR  LB26F          ; SYNTAX CHECK FOR ;
          LDX  FPA0+2         ; * GET FORMAT STRING DESCRIPTOR ADDRESS
          STX  VD5            ; * AND SAVE IT IN VD5
          BRA  L8EAE          ; GO PROCESS FORMAT STRING
L8EA8     LDA  VD7            ; *CHECK NEXT PRINT ITEM FLAG AND
          BEQ  L8EB4          ; *'FC' ERROR IF NO FURTHER PRINT ITEMS
          LDX  VD5            ; RESET FORMAT STRING POINTER TO START OF STRING
L8EAE     CLR  VD7            ; RESET NEXT PRINT ITEM FLAG
          LDB  ,X             ; GET LENGTH OF FORMAT STRING
          BNE  L8EB7          ; INTERPRET FORMAT STRING IF LENGTH > 0
L8EB4     JMP  LB44A          ; 'FC' ERROR IF FORMAT STRING = NULL
L8EB7     LDX  $02,X          ; POINT X TO START OF FORMAT STRING
* INTERPRET THE FORMAT STRING
L8EB9     CLR  VDA            ; CLEAR THE STATUS BYTE
L8EBB     CLR  VD9            ; CLEAR LEFT DIGIT COUNTER
          LDA  ,X+            ; GET A CHARACTER FROM FORMAT STRING
          CMPA #'!            ; EXCLAMATION POINT?
          LBEQ L8E37          ; YES - STRING TYPE FORMAT
          CMPA #'#            ; NUMBER SIGN? (DIGIT LOCATOR)
          BEQ  L8F24          ; YES - NUMERIC TYPE FORMAT
          DECB                ; DECREMENT FORMAT STRING LENGTH
          BNE  L8EE2          ; BRANCH IF NOT DONE
          JSR  L8FD8          ; SEND A '+' TO CONSOLE OUT IF VDA <> 0
          JSR  PUTCHR         ; SEND CHARACTER TO CONSOLE OUT
L8ED2     JSR  GETCCH         ; GET CURRENT CHARACTER FROM BASIC
          BNE  L8EA8          ; BRANCH IF NOT END OF LINE
          LDA  VD7            ; GET NEXT PRINT ITEM FLAG
L8ED8     BNE  L8EDD          ; BRANCH IF MORE PRINT ITEMS
          JSR  LB958          ; SEND A CARRIAGE RETURN TO CONSOLE OUT
L8EDD     LDX  VD5            ; POINT X TO FORMAT STRING DESCRIPTOR
          JMP  LB659          ; RETURN ADDRESS AND LENGTH OF FORMAT STRING - EXIT PRINT USING
L8EE2     CMPA #'+            ; CHECK FOR '+' (PRE-SIGN FORCE)
          BNE  L8EEF          ; NO PLUS
          JSR  L8FD8          ; SEND A '+' TO CONSOLE OUT IF VDA <> 0
          LDA  #$08           ; * LOAD THE STATUS BYTE WITH 8;
          STA  VDA            ; * PRE-SIGN FORCE FLAG
          BRA  L8EBB          ; INTERPRET THE REST OF THE FORMAT STRING
L8EEF     CMPA #'.            ; DECIMAL POINT?
          BEQ  L8F41          ; YES
          CMPA #'%            ; PERCENT SIGN?
          LBEQ L8E69          ; YES
          CMPA ,X             ; COMPARE THE PRESENT FORMAT STRING INPUT
*              ; CHARACTER TO THE NEXT ONE IN THE STRING
L8EFB     BNE  L8E88          ; NO MATCH - ILLEGAL CHARACTER
* TWO CONSECUTIVE EQUAL CHARACTERS IN FORMAT STRING
          CMPA #'$            ; DOLLAR SIGN?
          BEQ  L8F1A          ; YES - MAKE THE DOLLAR SIGN FLOAT
          CMPA #'*            ; ASTERISK?
          BNE  L8EFB          ; NO - ILLEGAL CHARACTER
          LDA  VDA            ; * GRAB THE STATUS BYTE AND BET BIT 5
          ORA  #$20           ; * TO INDICATE THAT THE OUTPUT WILL
          STA  VDA            ; * BE LEFT PADDED WITH ASTERISKS
          CMPB #2             ; * CHECK TO SEE IF THE $$ ARE THE LAST TWO
          BLO  L8F20          ; * CHARACTERS IN THE FORMAT STRING AND BRANCH IF SO
          LDA  $01,X          ; GET THE NEXT CHARACTER AFTER **
          CMPA #'$            ; CHECK FOR **$
          BNE  L8F20          ; CHECK FOR MORE CHARACTERS
          DECB                ; DECREMENT STRING LENGTH COUNTER
          LEAX $01,X          ; MOVE FORMAT STRING POINTER UP ONE
          INC  VD9            ; ADD ONE TO LEFT DIGIT COUNTER - FOR ASTERISK PAD AND
*              ; FLOATING DOLLAR SIGN COMBINATION
L8F1A     LDA  VDA            ; * GET THE STATUS BYTE AND SET
          ORA  #$10           ; * BIT 4 TO INDICATE A
          STA  VDA            ; * FLOATING DOLLAR SIGN
L8F20     LEAX $01,X          ; MOVE FORMAT STRING POINTER UP ONE
          INC  VD9            ; ADD ONE TO LEFT DIGIT (FLOATING $ OR ASTERISK PAD)
* PROCESS CHARACTERS TO THE LEFT OF THE DECIMAL POINT IN THE FORMAT STRING
L8F24     CLR  VD8            ; CLEAR THE RIGHT DIGIT COUNTER
L8F26     INC  VD9            ; ADD ONE TO LEFT DIGIT COUNTER
          DECB                ; DECREMENT FORMAT STRING LENGTH COUNTER
          BEQ  L8F74          ; BRANCH IF END OF FORMAT STRING
          LDA  ,X+            ; GET THE NEXT FORMAT CHARACTER
          CMPA #'.            ; DECIMAL POINT?
          BEQ  L8F4F          ; YES
          CMPA #'#            ; NUMBER SIGN?
          BEQ  L8F26          ; YES
          CMPA #',            ; COMMA?
          BNE  L8F5A          ; NO
          LDA  VDA            ; * GET THE STATUS BYTE
          ORA  #$40           ; * AND SET BIT 6 WHICH IS THE
          STA  VDA            ; * COMMA SEPARATOR FLAG
          BRA  L8F26          ; PROCESS MORE CHARACTERS TO LEFT OF DECIMAL POINT
* PROCESS DECIMAL POINT IF NO DIGITS TO LEFT OF IT
L8F41     LDA  ,X             ; GET NEXT FORMAT CHARACTER
          CMPA #'#            ; IS IT A NUMBER SIGN?
          LBNE L8E88          ; NO
          LDA  #1             ; * SET THE RIGHT DIGIT COUNTER TO 1 -
          STA  VD8            ; * ALLOW ONE SPOT FOR DECIMAL POINT
          LEAX $01,X          ; MOVE FORMAT POINTER UP ONE
* PROCESS DIGITS TO RIGHT OF DECIMAL POINT
L8F4F     INC  VD8            ; ADD ONE TO RIGHT DIGIT COUNTER
          DECB                ; DECREMENT FORMAT LENGTH COUNTER
          BEQ  L8F74          ; BRANCH IF END OF FORMAT STRING
          LDA  ,X+            ; GET A CHARACTER FROM FORMAT STRING
          CMPA #'#            ; IS IT NUMBER SIGN?
          BEQ  L8F4F          ; YES - KEEP CHECKING
* CHECK FOR EXPONENTIAL FORCE
L8F5A     CMPA #$5E           ; CHECK FOR UP ARROW
          BNE  L8F74          ; NO UP ARROW
          CMPA ,X             ; IS THE NEXT CHARACTER AN UP ARROW?
          BNE  L8F74          ; NO
          CMPA $01,X          ; AND THE NEXT CHARACTER?
          BNE  L8F74          ; NO
          CMPA $02,X          ; HOW ABOUT THE 4TH CHARACTER?
          BNE  L8F74          ; NO, ALSO
          CMPB #4             ; * CHECK TO SEE IF THE 4 UP ARROWS ARE IN THE
          BLO  L8F74          ; * FORMAT STRING AND BRANCH IF NOT
          SUBB #4             ; * MOVE POINTER UP 4 AND SUBTRACT
          LEAX $04,X          ; * FOUR FROM LENGTH
          INC  VDA            ; INCREMENT STATUS BYTE - EXPONENTIAL FORM

* CHECK FOR A PRE OR POST - SIGN FORCE AT END OF FORMAT STRING
L8F74     LEAX -1,X           ; MOVE POINTER BACK ONE
          INC  VD9            ; ADD ONE TO LEFT DIGIT COUNTER FOR PRE-SIGN FORCE
          LDA  VDA            ; * PRE-SIGN
          BITA #$08           ; * FORCE AND
          BNE  L8F96          ; * BRANCH IF SET
          DEC  VD9            ; DECREMENT LEFT DIGIT - NO PRE-SIGN FORCE
          TSTB                ; * CHECK LENGTH COUNTER AND BRANCH
          BEQ  L8F96          ; * IF END OF FORMAT STRING
          LDA  ,X             ; GET NEXT FORMAT STRING CHARACTER
          SUBA #'-            ; CHECK FOR MINUS SIGN
          BEQ  L8F8F          ; BRANCH IF MINUS SIGN
          CMPA #$FE           ; * WAS CMPA #('+')-('-')
          BNE  L8F96          ; BRANCH IF NO PLUS SIGN
          LDA  #$08           ; GET THE PRE-SIGN FORCE FLAG
L8F8F     ORA  #$04           ; 'OR' IN POST-SIGN FORCE FLAG
          ORA  VDA            ; 'OR' IN THE STATUS BYTE
          STA  VDA            ; SAVE THE STATUS BYTE
          DECB                ; DECREMENT FORMAT STRING LENGTH

* EVALUATE NUMERIC ITEM-LIST
L8F96     JSR  GETCCH         ; GET CURRENT CHARACTER
          LBEQ L8ED8          ; BRANCH IF END OF LINE
          STB  VD3            ; SAVE FORMAT STRING LENGTH WHEN FORMAT EVALUATION ENDED
          JSR  LB141          ; EVALUATE EXPRESSION
          LDA  VD9            ; GET THE LEFT DIGIT COUNTER
          ADDA VD8            ; ADD IT TO THE RIGHT DIGIT COUNTER
          CMPA #17            ; *
          LBHI LB44A          ; *'FC' ERROR IF MORE THAN 16 DIGITS AND DECIMAL POiNT
          JSR  L8FE5          ; CONVERT ITEM-LIST TO FORMATTED ASCII STRING
          LEAX -1,X           ; MOVE BUFFER POINTER BACK ONE
          JSR  LB99C          ; DISPLAY THE FORMATTED STRING TO CONSOLE OUT
L8FB3     CLR  VD7            ; RESET NEXT PRINT ITEM FLAG
          JSR  GETCCH         ; GET CURRENT INPUT CHARACTER
          BEQ  L8FC6          ; BRANCH IF END OF LINE
          STA  VD7            ; SAVE CURRENT CHARACTER (<>0) IN NEXT PRINT ITEM FLAG
          CMPA #';            ; * CHECK FOR ; - ITEM-LIST SEPARATOR AND
          BEQ  L8FC4          ; * BRANCH IF SEMICOLON
          JSR  LB26D          ; SYNTAX CHECK FOR COMMA
          BRA  L8FC6          ; PROCESS NEXT PRINT ITEM
L8FC4     JSR  GETNCH         ; GET NEXT INPUT CHARACTER
L8FC6     LDX  VD5            ; GET FORMAT STRING DESCRIPTOR ADDRESS
          LDB  ,X             ; GET LENGTH OF FORMAT STRING
          SUBB VD3            ; SUBTRACT AMOUNT OF FORMAT STRING LEFT AFTER LAST PRINT ITEM
          LDX  $02,X          ; *GET FORMAT STRING START ADDRESS AND ADVANCE
          ABX                 ; *POINTER TO START OF UNUSED FORMAT STRING
          LDB  VD3            ; * GET AMOUNT OF UNUSED FORMAT STRING
          LBNE L8EB9          ; * REINTERPRET FORMAT STRING FROM THAT POINT
          JMP  L8ED2          ; REINTERPRET FORMAT STRING FROM THE START IF ENTIRELY
*         USED ON LAST PRINT ITEM

* PRINT A '+' TO CONSOLE OUT IF THE STATUS BYTE <> 0
L8FD8     PSHS A              ; RESTORE ACCA AND RETURN
          LDA  #'+            ; GET ASCII PLUS SIGN
          TST  VDA            ; * CHECK THE STATUS BYTE AND
          BEQ  L8FE3          ; * RETURN IF = 0
          JSR  PUTCHR         ; SEND A CHARACTER TO CONSOLE OUT
L8FE3     PULS A,PC           ; RETURN ACCA AND RETURN

* CONVERT ITEM-LIST TO DECIMAL ASCII STRING
L8FE5     LDU  #STRBUF+4      ; POINT U TO STRING BUFFER
          LDB  #SPACE         ; BLANK
          LDA  VDA            ; * GET THE STATUS FLAG AND
          BITA #$08           ; * CHECK FOR A PRE-SIGN FORCE
          BEQ  L8FF2          ; * BRANCH IF NO PRE-SIGN FORCE
          LDB  #'+            ; PLUS SIGN
L8FF2     TST  FP0SGN         ; CHECK THE SIGN OF FPA0
          BPL  L8FFA          ; BRANCH IF POSITIVE
          CLR  FP0SGN         ; FORCE FPA0 SIGN TO BE POSITIVE
          LDB  #'-            ; MINUS SIGN
L8FFA     STB  ,U+            ; SAVE THE SIGN IN BUFFER
          LDB  #'0            ; * PUT A ZERO INTO THE BUFFER
          STB  ,U+            ; *
          ANDA #$01           ; * CHECK THE EXPONENTIAL FORCE FLAG IN
          LBNE L910D          ; * THE STATUS BYTE - BRANCH IF ACTIVE
          LDX  #LBDC0         ; POINT X TO FLOATING POINT 1E + 09
          JSR  LBCA0          ; COMPARE FPA0 TO (X)
          BMI  L9023          ; BRANCH IF FPA0 < 1E+09
          JSR  LBDD9          ; CONVERT FP NUMBER TO ASCII STRING
L9011     LDA  ,X+            ; * ADVANCE POINTER TO END OF
          BNE  L9011          ; * ASCII STRING (ZERO BYTE)
L9015     LDA  ,-X            ; MOVE THE
          STA  $01,X          ; ENTIRE STRING
          CMPX #STRBUF+3      ; UP ONE
          BNE  L9015          ; BYTE
          LDA  #'%            ; * INSERT A % SIGN AT START OF
          STA  ,X             ; * STRING - OVERFLOW ERROR
          RTS

L9023     LDA  FP0EXP         ; GET EXPONENT OF FPA0
          STA  V47            ; AND SAVE IT IN V74
          BEQ  L902C          ; BRANCH IF FPA0 = 0
          JSR  L91CD          ; CONVERT FPA0 TO NUMBER WITH 9 SIGNIFICANT
*              ; PLACES TO LEFT OF DECIMAL POINT
L902C     LDA  V47            ; GET BASE 10 EXPONENT OFFSET
          LBMI L90B3          ; BRANCH IF FPA0 < 100,000,000
          NEGA                ; * CALCULATE THE NUMBER OF LEADING ZEROES TO INSERT -
          ADDA VD9            ; * SUBTRACT BASE 10 EXPONENT OFFSET AND 9 (FPA0 HAS
          SUBA #$09           ; * 9 PLACES TO LEFT OF EXPONENT) FROM LEFT DIGIT COUNTER
          JSR  L90EA          ; PUT ACCA ZEROES IN STRING BUFFER
          JSR  L9263          ; INITIALIZE DECIMAL POINT AND COMMA COUNTERS
          JSR  L9202          ; CONVERT FPA0 TO DECIMAL ASCII IN THE STRING BUFFER
          LDA  V47            ; * GET BASE 10 EXPONENT AND PUT THAT MANY
          JSR  L9281          ; * ZEROES IN STRING BUFFER - STOP AT DECIMAL POINT
          LDA  V47            ; WASTED INSTRUCTION - SERVES NO PURPOSE
          JSR  L9249          ; CHECK FOR DECIMAL POINT
          LDA  VD8            ; GET THE RIGHT DIGIT COUNTER
          BNE  L9050          ; BRANCH IF RIGHT DIGlT COUNTER <> 0
          LEAU -1,U           ; * MOVE BUFFER POINTER BACK ONE - DELETE
*                             ; * DECIMAL POINT IF NO RIGHT DIGITS SPECiFIED
L9050     DECA                ; SUBTRACT ONE (DECIMAL POINT)
          JSR  L90EA          ; PUT ACCA ZEROES INTO BUFFER (TRAILING ZEROES)
L9054     JSR  L9185          ; INSERT ASTERISK PADDING, FLOATING $, AND POST-SIGN
          TSTA                ; WAS THERE A POST-SIGN?
          BEQ  L9060          ; NO
          CMPB #'*            ; IS THE FIRST CHARACTER AN $?
          BEQ  L9060          ; YES
          STB  ,U+            ; STORE THE POST-SIGN
L9060     CLR  ,U             ; CLEAR THE LAST CHARACTER IN THE BUFFER
*
* REMOVE ANY EXTRA BLANKS OR ASTERISKS FROM THE
* STRING BUFFER TO THE LEFT OF THE DECIMAL POINT
          LDX  #STRBUF+3      ; POINT X TO THE START OF THE BUFFER
L9065     LEAX $01,X          ; MOVE BUFFER POINTER UP ONE
          STX  TEMPTR         ; SAVE BUFFER POINTER IN TEMPTR
          LDA  VARPTR+1       ; * GET ADDRESS OF DECIMAL POINT IN BUFFER, SUBTRACT
          SUBA TEMPTR+1       ; * CURRENT POSITION AND SUBTRACT LEFT DIGIT COUNTER -
          SUBA VD9            ; * THE RESULT WILL BE ZERO WHEN TEMPTR+1 IS POINTING
*              ; * TO THE FIRST DIGIT OF THE FORMAT STRING
          BEQ  L90A9          ; RETURN IF NO DIGITS TO LEFT OF THE DECiMAL POINT
          LDA  ,X             ; GET THE CURRENT BUFFER CHARACTER
          CMPA #SPACE         ; SPACE?
          BEQ  L9065          ; YES - ADVANCE POINTER
          CMPA #'*            ; ASTERISK?
          BEQ  L9065          ; YES - ADVANCE POINTER
          CLRA                ; A ZERO ON THE STACK IS END OF DATA POINTER
L907C     PSHS A              ; PUSH A CHARACTER ONTO THE STACK
          LDA  ,X+            ; GET NEXT CHARACTER FROM BUFFER
          CMPA #'-            ; MINUS SIGN?
          BEQ  L907C          ; YES
          CMPA #'+            ; PLUS SIGN?
          BEQ  L907C          ; YES
          CMPA #'$            ; DOLLAR SIGN?
          BEQ  L907C          ; YES
          CMPA #'0            ; ZERO?
          BNE  L909E          ; NO - ERROR
          LDA  $01,X          ; GET CHARACTER FOLLOWING ZERO
          BSR  L90AA          ; CLEAR CARRY IF NUMERIC
          BLO  L909E          ; BRANCH IF NOT A NUMERIC CHARACTER - ERROR
L9096     PULS A              ; * PULL A CHARACTER OFF OF THE STACK
          STA  ,-X            ; * AND PUT IT BACK IN THE STRING BUFFER
          BNE  L9096          ; * KEEP GOING UNTIL ZERO FLAG
          BRA  L9065          ; KEEP CLEANING UP THE INPUT BUFFER
L909E     PULS A              ;
          TSTA                ; * THE STACK AND EXIT WHEN
          BNE  L909E          ; * ZERO FLAG FOUND
          LDX  TEMPTR         ; GET THE STRING BUFFER START POINTER
          LDA  #'%            ; * PUT A % SIGN BEFORE THE ERROR POSITION TO
          STA  ,-X            ; * INDICATE AN ERROR
L90A9     RTS
*
* CLEAR CARRY IF NUMERIC
L90AA     CMPA #'0            ; ASCII ZERO
          BLO  L90B2          ; RETURN IF ACCA < ASCII 0
          SUBA #$3A           ; *  #'9'+1
          SUBA #$C6           ; * #-('9'+1)  CARRY CLEAR IF NUMERIC
L90B2     RTS
*
* PROCESS AN ITEM-LIST WHICH IS < 100,000,000
L90B3     LDA  VD8            ; GET RIGHT DIGIT COUNTER
          BEQ  L90B8          ; BRANCH IF NO FORMATTED DIGITS TO THE RIGHT OF DECIMAL PT
          DECA                ; SUBTRACT ONE FOR DECIMAL POINT
L90B8     ADDA V47            ; *ADD THE BASE 10 EXPONENT OFFSET - ACCA CONTAINS THE
*         *NUMBER OF SHIFTS REQUIRED TO ADJUST FPA0 TO THE SPECIFIED
*         *NUMBER OF DlGITS TO THE RIGHT OF THE DECIMAL POINT
          BMI  L90BD          ; IF ACCA >= 0 THEN NO SHIFTS ARE REQUIRED
          CLRA                ; FORCE SHIFT COUNTER = 0
L90BD     PSHS A              ; SAVE INITIAL SHIFT COUNTER ON THE STACK
L90BF     BPL  L90CB          ; EXIT ROUTINE IF POSITIVE
          PSHS A              ; SAVE SHIFT COUNTER ON STACK
          JSR  LBB82          ; DIVIDE FPA0 BY 10 - SHIFT ONE DIGIT TO RIGHT
          PULS A              ; GET SHIFT COUNTER FROM THE STACK
          INCA                ; BUMP SHIFT COUNTER UP BY ONE
          BRA  L90BF          ; CHECK FOR FURTHER DIVISION
L90CB     LDA  V47            ; * GET BASE 10 EXPONENT OFFSET, ADD INITIAL SHIFT COUNTER
          SUBA ,S+            ; * AND SAVE NEW BASE 10 EXPONENT OFFSET - BECAUSE
          STA  V47            ; * FPA0 WAS SHIFTED ABOVE
          ADDA #$09           ; * ADD NINE (SIGNIFICANT PLACES) AND BRANCH IF THERE ARE NO
          BMI  L90EE          ; * ZEROES TO THE LEFT OF THE DECIMAL POINT IN THIS PRINT ITEM
          LDA  VD9            ; *DETERMINE HOW MANY FILLER ZEROES TO THE LEFT OF THE DECIMAL
          SUBA #$09           ; *POINT. GET THE NUMBER OF FORMAT PLACES TO LEFT OF DECIMAL
          SUBA V47            ; *POINT, SUBTRACT THE BASE 10 EXPONENT OFFSET AND THE CONSTANT 9
          BSR  L90EA          ; *(UNNORMALIZATION)-THEN OUTPUT THAT MANY ZEROES TO THE BUFFER
          JSR  L9263          ; INITIALIZE DECIMAL POINT AND COMMA COUNTERS
          BRA  L90FF          ; PROCESS THE REMAINDER OF THE PRINT ITEM
*
* PUT (ACCA+1) ASCII ZEROES IN BUFFER
L90E2     PSHS A              ; SAVE ZERO COUNTER
          LDA  #'0            ; * INSERT A ZERO INTO
          STA  ,U+            ; * THE BUFFER
          PULS A              ; RESTORE ZERO COUNTER

* PUT ACCA ASCII ZEROES INTO THE BUFFER
L90EA     DECA                ; DECREMENT ZERO COUNTER
          BPL  L90E2          ; BRANCH IF NOT DONE
          RTS

L90EE     LDA  VD9            ; * GET THE LEFT DIGIT COUNTER AND PUT
          BSR  L90EA          ; * THAT MANY ZEROES IN THE STRiNG BUFFER
          JSR  L924D          ; PUT THE DECIMAL POINT IN THE STRING BUFFER
          LDA  #-9            ; *DETERMINE HOW MANY FILLER ZEROES BETWEEN THE DECIMAL POINT
          SUBA V47            ; *AND SIGNIFICANT DATA. SUBTRACT BASE 10 EXPONENT FROM -9
          BSR  L90EA          ; *(UNNORMALIZATION) AND OUTPUT THAT MANY ZEROES TO BUFFER
          CLR  V45            ; CLEAR THE DECIMAL POINT COUNTER - SUPPRESS THE DECIMAL POINT
          CLR  VD7            ; CLEAR THE COMMA COUNTER - SUPPRESS COMMAS
L90FF     JSR  L9202          ; DECODE FPA0 INTO A DECIMAL ASCII STRING
          LDA  VD8            ; GET THE RIGHT DIGIT COUNTER
          BNE  L9108          ; BRANCH IF RIGHT DIGIT COUNTER <> 0
          LDU  VARPTR         ; RESET BUFFER PTR TO THE DECIMAL POINT IF NO DIGITS TO RIGHT
L9108     ADDA V47            ; *ADD BASE 10 EXPONENT - A POSITIVE ACCA WILL CAUSE THAT MANY
* *FILLER ZEROES TO BE OUTPUT ; TO THE RIGHT OF LAST SIGNIFICANT DATA
*         *SIGNIFICANT DATA
          LBRA L9050          ; INSERT LEADING ASTERISKS, FLOATING DOLLAR SIGN, ETC
*
* FORCE THE NUMERIC OUTPUT FORMAT TO BE EXPONENTIAL FORMAT
L910D     LDA  FP0EXP         ; * GET EXPONENT OF FPA0 AND
          PSHS A              ; * SAVE IT ON THE STACK
          BEQ  L9116          ; BRANCH IF FPA0 = 0
          JSR  L91CD          ; *CONVERT FPA0 INTO A NUMBER WITH 9 SIGNIFICANT
*         *DIGITS TO THE LEFT OF THE DECIMAL POINT
L9116     LDA  VD8            ; GET THE RIGHT DIGIT COUNTER
          BEQ  L911B          ; BRANCH IF NO FORMATTED DIGITS TO THE RIGHT
          DECA                ; SUBTRACT ONE FOR THE DECIMAL POINT
L911B     ADDA VD9            ; ADD TO THE LEFT DIGIT COUNTER
          CLR  STRBUF+3       ; CLEAR BUFFER BYTE AS TEMPORARY STORAGE LOCATION
          LDB  VDA            ; * GET THE STATUS BYTE FOR A
          ANDB #$04           ; * POST-BYTE FORCE; BRANCH IF
          BNE  L9129          ; * A POST-BYTE FORCE
          COM  STRBUF+3       ; TOGGLE BUFFER BYTE TO -1 IF NO POST-BYTE FORCE
L9129     ADDA STRBUF+3       ; SUBTRACT 1 IF NO POST BYTE FORCE
          SUBA #$09           ; *SUBTRACT 9 (DUE TO THE CONVERSION TO 9
*         *SIGNIFICANT DIGITS TO LEFT OF DECIMAL POINT)
          PSHS A              ; * SAVE SHIFT COUNTER ON THE STACK - ACCA CONTAINS THE NUMBER
*         OF   SHIFTS REQUIRED TO ADJUST FPA0 FOR THE NUMBER OF
*         FORMATTED PLACES TO THE RIGHT OF THE DECIMAL POINT.
L9130     BPL  L913C          ; NO MORE SHIFTS WHEN ACCA >= 0
          PSHS A              ; SAVE SHIFT COUNTER
          JSR  LBB82          ; DIVIDE FPA0 BY 10 - SHIFT TO RIGHT ONE
          PULS A              ; RESTORE THE SHIFT COUNTER
          INCA                ; ADD 1 TO SHIFT COUNTER
          BRA  L9130          ; CHECK FOR FURTHER SHIFTING (DIVISION)
L913C     LDA  ,S             ; *GET THE INITIAL VALUE OF THE SHIFT COUNTER
          BMI  L9141          ; *AND BRANCH IF SHIFTING HAS TAKEN PLACE
          CLRA                ; RESET ACCA IF NO SHIFTING HAS TAKEN PLACE
L9141     NEGA                ; *CALCULATE THE POSITION OF THE DECIMAL POINT BY
          ADDA VD9            ; *NEGATING SHIFT COUNTER, ADDING THE LEFT DIGIT COUNTER
          INCA                ; *PLUS ONE AND THE POST-BYTE POSlTION, IF USED
          ADDA STRBUF+3       ; *
          STA  V45            ; SAVE DECIMAL POINT COUNTER
          CLR  VD7            ; CLEAR COMMA COUNTER - NO COMMAS INSERTED
          JSR  L9202          ; CONVERT FPA0 INTO ASCII DECIMAL STRING
          PULS A              ; * GET THE INITIAL VALUE OF SHIFT COUNTER AND
          JSR  L9281          ; * INSERT THAT MANY ZEROES INTO THE BUFFER
          LDA  VD8            ; *GET THE RIGHT DIGIT COUNTER AND BRANCH
          BNE  L915A          ; *IF NOT ZERO
          LEAU -1,U           ; MOVE BUFFER POINTER BACK ONE

* CALCULATE VALUE OF EXPONENT AND PUT IN STRING BUFFER
L915A     LDB  ,S+            ; GET ORIGINAL EXPONENT OF FPA0
          BEQ  L9167          ; BRANCH IF EXPONENT = 0
          LDB  V47            ; GET BASE 10 EXPONENT
          ADDB #$09           ; ADD 9 FOR 9 SIGNIFICANT DIGIT CONVERSION
          SUBB VD9            ; SUBTRACT LEFT DIGIT COUNTER
          SUBB STRBUF+3       ; ADD ONE TO EXPONENT IF POST-SIGN FORCE
L9167     LDA  #'+            ; PLUS SIGN
          TSTB                ; TEST EXPONENT
          BPL  L916F          ; BRANCH IF POSITIVE EXPONENT
          LDA  #'-            ; MINUS SIGN
          NEGB                ; CONVERT EXPONENT TO POSITIVE NUMBER
L916F     STA  $01,U          ; PUT SIGN OF EXPONENT IN STRING BUFFER
          LDA  #'E            ; * PUT AN 'E' (EXPONENTIATION FLAG) IN
          STA  ,U++           ; * BUFFER AND SKIP OVER THE SIGN
          LDA  #$2F           ; * WAS LDA #'0'-1
*CONVERT BINARY EXPONENT IN ACCB TO ASCII VALUE IN ACCA
L9177     INCA                ; ADD ONE TO TENS DIGIT COUNTER
          SUBB #10            ; *SUBTRACT 10 FROM EXPONENT AND ADD ONE TO TENS
          BCC  L9177          ; * DIGIT IF NO CARRY. TENS DIGIT DONE IF THERE IS A CARRY
          ADDB #$3A           ; WAS ADDB #'9'+1
          STD  ,U++           ; SAVE EXPONENT IN BUFFER
          CLR  ,U             ; CLEAR FINAL BYTE IN BUFFER - PRINT TERMINATOR
          JMP  L9054          ; INSERT ASTERISK PADDING, FLOATING DOLLAR SIGN, ETC.

* INSERT ASTERISK PADDING, FLOATING $ AND PRE-SIGN
L9185     LDX  #STRBUF+4      ; POINT X TO START OF PRINT ITEM BUFFER
          LDB  ,X             ; * GET SIGN BYTE OF ITEM-LIST BUFFER
          PSHS B              ; * AND SAVE IT ON THE STACK
          LDA  #SPACE         ; DEFAULT PAD WITH BLANKS
          LDB  VDA            ; * GET STATUS BYTE AND CHECK FOR
          BITB #$20           ; * ASTERISK LEFT PADDING
          PULS B              ; GET SIGN BYTE AGAIN
          BEQ  L919E          ; BRANCH IF NO PADDING
          LDA  #'*            ; PAD WITH ASTERISK
          CMPB #SPACE         ; WAS THE FIRST BYTE A BLANK (POSITIVE)?
          BNE  L919E          ; NO
          TFR  A,B            ; TRANSFER PAD CHARACTER TO ACCB
L919E     PSHS B              ; SAVE FIRST CHARACTER ON STACK
L91A0     STA  ,X+            ; STORE PAD CHARACTER IN BUFFER
          LDB  ,X             ; GET NEXT CHARACTER IN BUFFER
          BEQ  L91B6          ; INSERT A ZERO IF END OF BUFFER
          CMPB #'E            ; * CHECK FOR AN 'E' AND
          BEQ  L91B6          ; * PUT A ZERO BEFORE IT
          CMPB #'0            ; * REPLACE LEADING ZEROES WITH
          BEQ  L91A0          ; * PAD CHARACTERS
          CMPB #',            ; * REPLACE LEADING COMMAS
          BEQ  L91A0          ; * WITH PAD CHARACTERS
          CMPB #'.            ; * CHECK FOR DECIMAL POINT
          BNE  L91BA          ; * AND DON'T PUT A ZERO BEFORE IT
L91B6     LDA  #'0            ; * REPLACE PREVIOUS CHARACTER
          STA  ,-X            ; * WITH A ZERO
L91BA     LDA  VDA            ; * GET STATUS BYTE, CHECK
          BITA #$10           ; * FOR FLOATING $
          BEQ  L91C4          ; * BRANCH IF NO FLOATING $
          LDB  #'$            ; * STORE A $ IN
          STB  ,-X            ; * BUFFER
L91C4     ANDA #$04           ; CHECK PRE-SIGN FLAG
          PULS B              ; GET SIGN CHARACTER
          BNE  L91CC          ; RETURN IF POST-SIGN REQUIRED
          STB  ,-X            ; STORE FIRST CHARACTER
L91CC     RTS
*
* CONVERT FPA0 INTO A NUMBER OF THE FORM - NNN,NNN,NNN X 10**M.
* THE EXPONENT M WILL BE RETURNED IN V47 (BASE 10 EXPONENT).
L91CD     PSHS U              ; SAVE BUFFER POINTER
          CLRA                ; INITIAL EXPONENT OFFSET = 0
L91D0     STA  V47            ; SAVE EXPONENT OFFSET
          LDB  FP0EXP         ; GET EXPONENT OF FPA0
          CMPB #$80           ; * COMPARE TO EXPONENT OF .5
          BHI  L91E9          ; * AND BRANCH IF FPA0 > = 1.0

* IF FPA0 < 1.0, MULTIPLY IT BY 1E+09 UNTIL IT IS >= 1
          LDX  #LBDC0         ; POINT X TO FP NUMBER (1E+09)
          JSR  LBACA          ; MULTIPLY FPA0 BY 1E+09
          LDA  V47            ; GET EXPONENT OFFSET
          SUBA #$09           ; SUBTRACT 9 (BECAUSE WE MULTIPLIED BY 1E+09 ABOVE)
          BRA  L91D0          ; CHECK TO SEE IF > 1.0
L91E4     JSR  LBB82          ; DIVIDE FPA0 BY 10
          INC  V47            ; INCREMENT EXPONENT OFFSET
L91E9     LDX  #LBDBB         ; POINT X TO FP NUMBER (999,999,999)
          JSR  LBCA0          ; COMPARE FPA0 TO X
          BGT  L91E4          ; BRANCH IF FPA0 > 999,999,999
L91F1     LDX  #LBDB6         ; POINT X TO FP NUMBER (99,999,999.9)
          JSR  LBCA0          ; COMPARE FPA0 TO X
          BGT  L9200          ; RETURN IF 999,999,999 > FPA0 > 99,999,999.9
          JSR  LBB6A          ; MULTIPLY FPA0 BY 10
          DEC  V47            ; DECREMENT EXPONENT OFFSET
          BRA  L91F1          ; KEEP UNNORMALIZING
L9200     PULS U,PC           ; RESTORE BUFFER POINTER AND RETURN
*
* CONVERT FPA0 INTO AN INTEGER, THEN DECODE IT
* INTO A DECIMAL ASCII STRING IN THE BUFFER
L9202     PSHS U              ; SAVE BUFFER POINTER
          JSR  LB9B4          ; ADD .5 TO FPA0 (ROUND OFF)
          JSR  LBCC8          ; CONVERT FPA0 TO INTEGER FORMAT
          PULS U              ; RESTORE BUFFER POINTER
*
* CONVERT FPA0 INTO A DECIMAL ASCII STRING
          LDX  #LBEC5         ; POINT X TO UNNORMALIZED POWERS OF 10
          LDB  #$80           ; INITIALIZE DIGIT COUNTER TO 0 + $80.
* BIT 7 SET IS USED TO INDICATE THAT THE POWER OF 10 MANTISSA
* IS NEGATIVE. WHEN YOU 'ADD' A NEGATIVE MANTISSA, IT IS
* THE SAME AS SUBTRACTING A POSITIVE ONE AND BIT 7 OF ACCB
* IS HOW THIS ROUTINE KNOWS THAT A 'SUBTRACTION' IS OCCURRING.
L9211     BSR  L9249          ; CHECK FOR COMMA INSERTION
L9213     LDA  FPA0+3         ; * 'ADD' A POWER OF 10 MANTISSA TO FPA0.
          ADDA $03,X          ; * IF THE MANTISSA IS NEGATIVE, A SUBTRACTION
          STA  FPA0+3         ; * WILL BE WHAT REALLY TAKES PLACE.
          LDA  FPA0+2         ; *
          ADCA $02,X          ; *
          STA  FPA0+2         ; *
          LDA  FPA0+1         ; *
          ADCA $01,X          ; *
          STA  FPA0+1         ; *
          LDA  FPA0           ; *
          ADCA ,X             ; *
          STA  FPA0           ; *
          INCB                ; ADD ONE TO DIGIT COUNTER
          RORB                ; ROTATE CARRY INTO BIT 7
          ROLB                ; * SET OVERFLOW FLAG - BRANCH IF CARRY SET AND
          BVC  L9213          ; * ADDING MANTISSA OR CARRY CLEAR AND SUBTRACTING MANTISSA
          BCC  L9235          ; BRANCH IF SUBTRACTING MANTISSA
          SUBB #10+1          ; WAS SUBB #10+1
          NEGB                ; * IF ADDING MANTISSA
L9235     ADDB #$2F           ; WAS ADDB #'0'-1
          LEAX $04,X          ; MOVE TO NEXT POWER OF 10 MANTISSA
          TFR  B,A            ; SAVE DIGIT IN ACCA
          ANDA #$7F           ; MASK OFF ADD/SUBTRACT FLAG (BIT 7)
          STA  ,U+            ; STORE DIGIT IN BUFFER
          COMB                ; TOGGLE ADD/SUBTRACT FLAG
          ANDB #$80           ; MASK OFF EVERYTHING BUT ADD/SUB FLAG
          CMPX #LBEE9         ; COMPARE TO END OF UNNORMALIZED POWERS OF 10
          BNE  L9211          ; BRANCH IF NOT DONE
          CLR  ,U             ; PUT A ZERO AT END OF INTEGER

* DECREMENT DECIMAL POINT COUNTER AND CHECK FOR COMMA INSERTION
L9249     DEC  V45            ; DECREMENT DECIMAL POINT COUNTER
          BNE  L9256          ; NOT TIME FOR DECIMAL POINT
L924D     STU  VARPTR         ; SAVE BUFFER POINTER-POSITION OF THE DECIMAL POINT
          LDA  #'.            ; * STORE A DECIMAL
          STA  ,U+            ; * POINT IN THE OUTPUT BUFFER
          CLR  VD7            ; * CLEAR COMMA COUNTER - NOW IT WILL TAKE 255
*                             ; * DECREMENTS BEFORE ANOTHER COMMA WILL BE INSERTED
          RTS
L9256     DEC  VD7            ; DECREMENT COMMA COUNTER
          BNE  L9262          ; RETURN IF NOT TIME FOR COMMA
          LDA  #$03           ; * RESET COMMA COUNTER TO 3; THREE
          STA  VD7            ; * DIGITS BETWEEN COMMAS
          LDA  #',            ; * PUT A COMMA INTO
          STA  ,U+            ; * THE BUFFER
L9262     RTS

* INITIALIZE DECIMAL POINT AND COMMA COUNTERS
L9263     LDA  V47            ; GET THE BASE 10 EXPONENT OFFSET
          ADDA #10            ; * ADD 10 (FPA0 WAS 'NORMALIZED' TO 9 PLACES LEFT
          STA  V45            ; * OF DECIMAL POINT) - SAVE IN DECIMAL POINT COUNTER
          INCA                ; ADD ONE FOR THE DECIMAL POINT
L926A     SUBA #$03           ; * DIVIDE DECIMAL POINT COUNTER BY 3; LEAVE
          BCC  L926A          ; * THE REMAINDER IN ACCA
          ADDA #$05           ; CONVERT REMAINDER INTO A NUMBER FROM 1-3
          STA  VD7            ; SAVE COMMA COUNTER
          LDA  VDA            ; GET STATUS BYTE
          ANDA #$40           ; CHECK FOR COMMA FLAG
          BNE  L927A          ; BRANCH IF COMMA FLAG ACTIVE
          STA  VD7            ; CLEAR COMMA COUNTER - 255 DIGITS OUTPUT BEFORE A COMMA
L927A     RTS
*
* INSERT ACCA ZEROES INTO THE BUFFER
L927B     PSHS A              ; SAVE ZEROES COUNTER
          BSR  L9249          ; CHECK FOR DECIMAL POINT
          PULS A              ; RESTORE ZEROES COUNTER
L9281     DECA                ; * DECREMENT ZEROES COUNTER AND
          BMI  L928E          ; * RETURN IF < 0
          PSHS A              ; SAVE ZEROES COUNTER
          LDA  #'0            ; * PUT A ZERO INTO
          STA  ,U+            ; * THE BUFFER
          LDA  ,S+            ; RESTORE THE ZEROES COUNTER
          BNE  L927B          ; BRANCH IF NOT DONE
L928E     RTS


* LINE
LINE      CMPA #TOK_INPUT     ; 'INPUT' TOKEN
          LBEQ L89C0          ; GO DO 'LINE INPUT' COMMAND
          JMP  LB277          ; 'SYNTAX ERROR' IF NOT "LINE INPUT"

* END OF EXTENDED BASIC

;************************************************************************
;
; 6809 Disassembler
;
; Copyright (C) 2019 by Jeff Tranter <tranter@pobox.com>
;
; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
;   http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.
;
; Revision History
; Version Date         Comments
; 0.0     29-Jan-2019  First version started, based on 6502 code.
; 0.1     03-Feb-2019  All instructions now supported.
; 0.2     05-Feb-2019  Integrated into ASSSIST09/BASIC ROM.

; Character defines

RET     EQU     $0D             ; Carriage return
SP      EQU     $20             ; Space

PAGELEN EQU     24              ; Number of instructions to show before waiting for keypress

; Start address for RAM variables
        ORG     $6FD0

; Variables

ADRS    RMB     2               ; Current address to disassemble
OPCODE  RMB     1               ; Opcode of instruction
AM      RMB     1               ; Addressing mode of instruction
OPTYPE  RMB     1               ; Instruction type
POSTBYT RMB     1               ; Post byte (for indexed addressing)
LENG    RMB     1               ; Length of instruction
TEMP    RMB     2               ; Temp variable (used by print routines)
TEMP1   RMB     2               ; Temp variable
FIRST   RMB     1               ; Flag used to indicate first time an item printed
PAGE23  RMB     1               ; Flag indicating page2/3 instruction when non-zero

; Instructions. Matches indexes into entries in table MNEMONICS.

OP_INV   EQU    $00
OP_ABX   EQU    $01
OP_ADCA  EQU    $02
OP_ADCB  EQU    $03
OP_ADDA  EQU    $04
OP_ADDB  EQU    $05
OP_ADDD  EQU    $06
OP_ANDA  EQU    $07
OP_ANDB  EQU    $08
OP_ANDCC EQU    $09
OP_ASL   EQU    $0A
OP_ASLA  EQU    $0B
OP_ASLB  EQU    $0C
OP_ASR   EQU    $0D
OP_ASRA  EQU    $0E
OP_ASRB  EQU    $0F
OP_BCC   EQU    $10
OP_BCS   EQU    $11
OP_BEQ   EQU    $12
OP_BGE   EQU    $13
OP_BGT   EQU    $14
OP_BHI   EQU    $15
OP_BITA  EQU    $16
OP_BITB  EQU    $17
OP_BLE   EQU    $18
OP_BLS   EQU    $19
OP_BLT   EQU    $1A
OP_BMI   EQU    $1B
OP_BNE   EQU    $1C
OP_BPL   EQU    $1D
OP_BRA   EQU    $1E
OP_BRN   EQU    $1F
OP_BSR   EQU    $20
OP_BVC   EQU    $21
OP_BVS   EQU    $22
OP_CLR   EQU    $23
OP_CLRA  EQU    $24
OP_CLRB  EQU    $25
OP_CMPA  EQU    $26
OP_CMPB  EQU    $27
OP_CMPD  EQU    $28
OP_CMPS  EQU    $29
OP_CMPU  EQU    $2A
OP_CMPX  EQU    $2B
OP_CMPY  EQU    $2C
OP_COMA  EQU    $2D
OP_COMB  EQU    $2E
OP_COM   EQU    $2F
OP_CWAI  EQU    $30
OP_DAA   EQU    $31
OP_DEC   EQU    $32
OP_DECA  EQU    $33
OP_DECB  EQU    $34
OP_EORA  EQU    $35
OP_EORB  EQU    $36
OP_EXG   EQU    $37
OP_INC   EQU    $38
OP_INCA  EQU    $39
OP_INCB  EQU    $3A
OP_JMP   EQU    $3B
OP_JSR   EQU    $3C
OP_LBCC  EQU    $3D
OP_LBCS  EQU    $3E
OP_LBEQ  EQU    $3F
OP_LBGE  EQU    $40
OP_LBGT  EQU    $41
OP_LBHI  EQU    $42
OP_LBLE  EQU    $43
OP_LBLS  EQU    $44
OP_LBLT  EQU    $45
OP_LBMI  EQU    $46
OP_LBNE  EQU    $47
OP_LBPL  EQU    $48
OP_LBRA  EQU    $49
OP_LBRN  EQU    $4A
OP_LBSR  EQU    $4B
OP_LBVC  EQU    $4C
OP_LBVS  EQU    $4D
OP_LDA   EQU    $4E
OP_LDB   EQU    $4F
OP_LDD   EQU    $50
OP_LDS   EQU    $51
OP_LDU   EQU    $52
OP_LDX   EQU    $53
OP_LDY   EQU    $54
OP_LEAS  EQU    $55
OP_LEAU  EQU    $56
OP_LEAX  EQU    $57
OP_LEAY  EQU    $58
OP_LSR   EQU    $59
OP_LSRA  EQU    $5A
OP_LSRB  EQU    $5B
OP_MUL   EQU    $5C
OP_NEG   EQU    $5D
OP_NEGA  EQU    $5E
OP_NEGB  EQU    $5F
OP_NOP   EQU    $60
OP_ORA   EQU    $61
OP_ORB   EQU    $62
OP_ORCC  EQU    $63
OP_PSHS  EQU    $64
OP_PSHU  EQU    $65
OP_PULS  EQU    $66
OP_PULU  EQU    $67
OP_ROL   EQU    $68
OP_ROLA  EQU    $69
OP_ROLB  EQU    $6A
OP_ROR   EQU    $6B
OP_RORA  EQU    $6C
OP_RORB  EQU    $6D
OP_RTI   EQU    $6E
OP_RTS   EQU    $6F
OP_SBCA  EQU    $70
OP_SBCB  EQU    $71
OP_SEX   EQU    $72
OP_STA   EQU    $73
OP_STB   EQU    $74
OP_STD   EQU    $75
OP_STS   EQU    $76
OP_STU   EQU    $77
OP_STX   EQU    $78
OP_STY   EQU    $79
OP_SUBA  EQU    $7A
OP_SUBB  EQU    $7B
OP_SUBD  EQU    $7C
OP_SWI   EQU    $7D
OP_SWI2  EQU    $7E
OP_SWI3  EQU    $7F
OP_SYNC  EQU    $80
OP_TFR   EQU    $81
OP_TST   EQU    $82
OP_TSTA  EQU    $83
OP_TSTB  EQU    $84

; Addressing Modes. OPCODES table lists these for each instruction.
; LENGTHS lists the instruction length for each addressing mode.
; Need to distinguish relative modes that are 2 and 3 (long) bytes.
; Some immediate are 2 and some 3 bytes.
; Indexed modes can be longer depending on postbyte.
; Page 2 and 3 opcodes are one byte longer (prefixed by 10 or 11)

AM_INVALID      EQU     0       ; $01 (1)
AM_INHERENT     EQU     1       ; RTS (1)
AM_IMMEDIATE8   EQU     2       ; LDA #$12 (2)
AM_IMMEDIATE16  EQU     3       ; LDD #$1234 (3)
AM_DIRECT       EQU     4       ; LDA $12 (2)
AM_EXTENDED     EQU     5       ; LDA $1234 (3)
AM_RELATIVE8    EQU     6       ; BSR $1234 (2)
AM_RELATIVE16   EQU     7       ; LBSR $1234 (3)
AM_INDEXED      EQU     8       ; LDA 0,X (2+)

; *** CODE ***

        ORG     $E400

; Unassemble command. Disassembles a page at a time. Can be run directly or
; as an ASSIST09 monitor external command. Gets start address from
; command line.

CUNAS:  LBSR    CDNUM           ; Parse command line, return 16-bit number in D
        STD     ADRS            ; Store it
PAGE:   LDA     #PAGELEN        ; Number of instructions to disassemble per page
DIS:    PSHS    A               ; Save A
        LBSR    DISASM          ; Do disassembly of one instruction
        PULS    A               ; Restore A
        DECA                    ; Decrement count
        BNE     DIS             ; Go back and repeat until a page has been done
        LEAX    MSG2,PCR        ; Display message to press a key
        LBSR    PrintString
BADKEY: BSR     GetChar         ; Wait for keyboard input
        BSR     PrintCR
        CMPA    #SP             ; Space key pressed?
        BEQ     PAGE            ; If so, display next page
        CMPA    #'Q             ; Q key pressed?
        BEQ     RETN            ; If so, return
        CMPA    #'q             ; q key pressed?
        BEQ     RETN            ; If so, return
        BSR     PrintString     ; Bad key, prompt and try again
        BRA     BADKEY
RETN:   RTS                     ; Return to caller

; *** Utility Functions ***
; Some of these call ASSIST09 ROM monitor routines.

; Print CR/LF to the console.
; Registers changed: none
PrintCR:
        PSHS    A               ; Save A
        LDA     #RET
        BSR     PrintChar
        LDA     #LF
        BSR     PrintChar
        PULS    A               ; Restore A
        RTS

; Print dollar sign to the console.
; Registers changed: none
PrintDollar:
        PSHS    A               ; Save A
        LDA     #'$
        BSR     PrintChar
        PULS    A               ; Restore A
        RTS

; Print comma to the console.
; Registers changed: none
PrintComma:
        PSHS    A               ; Save A
        LDA     #',
        BSR     PrintChar
        PULS    A               ; Restore A
        RTS

; Print left square bracket to the console.
; Registers changed: none
PrintLBracket:
        PSHS    A               ; Save A
        LDA     #'[
        BSR     PrintChar
        PULS    A               ; Restore A
        RTS

; Print right square bracket to the console.
; Registers changed: none
PrintRBracket:
        PSHS    A               ; Save A
        LDA     #']
        BSR     PrintChar
        PULS    A               ; Restore A
        RTS

; Print space sign to the console.
; Registers changed: none
PrintSpace:
        SWI
        FCB     SPACEF
        RTS

; Print two spaces to the console.
; Registers changed: none
Print2Spaces:
        PSHS    A               ; Save A
        LDA     #SP
        BSR     PrintChar
        BSR     PrintChar
        PULS    A               ; Restore A
        RTS

; Print several space characters.
; A contains number of spaces to print.
; Registers changed: none
PrintSpaces:
        PSHS    A               ; Save registers used
PS1:    CMPA    #0              ; Is count zero?
        BEQ     PS2             ; Is so, done
        BSR     PrintSpace      ; Print a space
        DECA                    ; Decrement count
        BRA     PS1             ; Check again
PS2:    PULS    A               ; Restore registers used
        RTS

; Print character to the console
; A contains character to print.
; Registers changed: none
PrintChar:
        SWI                     ; Call ASSIST09 monitor function
        FCB     OUTCH           ; Service code byte
        RTS

; Get character from the console
; A contains character read. Blocks until key pressed. Character is
; echoed. Ignores NULL ($00) and RUBOUT ($7F). CR ($OD) is converted
; to LF ($0A).
; Registers changed: none (flags may change). Returns char in A.
GetChar:
        SWI                     ; Call ASSIST09 monitor function
        FCB     INCHNP          ; Service code byte
        RTS

; Print a byte as two hex digits followed by a space.
; A contains byte to print.
; Registers changed: none
PrintByte:
        PSHS    A,B,X           ; Save registers used
        STA     TEMP            ; Needs to be in memory so we can point to it
        LEAX    TEMP,PCR        ; Get pointer to it
        SWI                     ; Call ASSIST09 monitor function
        FCB     OUT2HS          ; Service code byte
        PULS    X,B,A           ; Restore registers used
        RTS

; Print a word as four hex digits followed by a space.
; X contains word to print.
; Registers changed: none
PrintAddress:
        PSHS    A,B,X           ; Save registers used
        STX     TEMP            ; Needs to be in memory so we can point to it
        LEAX    TEMP,PCR        ; Get pointer to it
        SWI                     ; Call ASSIST09 monitor function
        FCB     OUT4HS          ; Service code byte
        PULS    X,B,A           ; Restore registers used
        RTS

; Print a string.
; X points to start of string to display.
; String must be terminated in EOT character.
; Registers changed: none
PrintString:
        PSHS    X               ; Save registers used
        SWI                     ; Call ASSIST09 monitor function
        FCB     PDATA1          ; Service code byte
        PULS    X               ; Restore registers used
        RTS

; Decode the instruction pointed to by ADRS. On return will have set
; ADRS, OPCODE, OPTYPE, LENG, AM, PAGE23, and POSTBYT.

Decode: CLR     PAGE23          ; Clear page2/3 flag
        LDX     ADRS,PCR        ; Get address of instruction
        LDB     ,X              ; Get instruction op code
        CMPB    #$10            ; Is it a page 2 16-bit opcode prefix with 10?
        BEQ     handle10        ; If so, do special handling
        CMPB    #$11            ; Is it a page 3 16-bit opcode prefix with 11?
        BEQ     handle11        ; If so, do special handling
        LBRA    not1011         ; If not, handle as normal case

handle10:                       ; Handle page 2 instruction
        LDA     #1              ; Set page2/3 flag
        STA     PAGE23
        LDB     1,X             ; Get real opcode
        STB     OPCODE          ; Save it.
        LEAX    PAGE2,PCR       ; Pointer to start of table
        CLRA                    ; Set index into table to zero
search10:
        CMPB    A,X             ; Check for match of opcode in table
        BEQ     found10         ; Branch if found
        ADDA    #3              ; Advance to next entry in table (entries are 3 bytes long)
        TST     A,X             ; Check entry
        BEQ     notfound10      ; If zero, then reached end of table
        BRA     search10        ; If not, keep looking

notfound10:                     ; Instruction not found, so is invalid.
        LDA     #$10            ; Set opcode to 10
        STA     OPCODE
        LDA     #OP_INV         ; Set as instruction type invalid
        STA     OPTYPE
        LDA     #AM_INVALID     ; Set as addressing mode invalid
        STA     AM
        LDA     #1              ; Set length to one
        STA     LENG
        LBRA    dism            ; Disassemble as normal

found10:                        ; Found entry in table
        ADDA    #1              ; Advance to instruction type entry in table
        LDB     A,X             ; Get instruction type
        STB     OPTYPE          ; Save it
        ADDA    #1              ; Advanced to address mode entry in table
        LDB     A,X             ; Get address mode
        STB     AM              ; Save it
        CLRA                    ; Clear MSB of D, addressing mode is now in A:B (D)
        TFR     D,X             ; Put addressing mode in X
        LDB     LENGTHS,X       ; Get instruction length from table
        STB     LENG            ; Store it
        INC     LENG            ; Add one because it is a two byte op code
        LBRA    dism            ; Continue normal disassembly processing.

handle11:                       ; Same logic as above, but use table for page 3 opcodes.
        LDA     #1              ; Set page2/3 flag
        STA     PAGE23
        LDB     1,X             ; Get real opcode
        STB     OPCODE          ; Save it.
        LEAX    PAGE3,PCR       ; Pointer to start of table
        CLRA                    ; Set index into table to zero
search11:
        CMPB    A,X             ; Check for match of opcode in table
        BEQ     found11         ; Branch if found
        ADDA    #3              ; Advance to next entry in table (entries are 3 bytes long)
        TST     A,X             ; Check entry
        BEQ     notfound11      ; If zero, then reached end of table
        BRA     search11        ; If not, keep looking

notfound11:                     ; Instruction not found, so is invalid.
        LDA     #$11            ; Set opcode to 10
        STA     OPCODE
        LDA     #OP_INV         ; Set as instruction type invalid
        STA     OPTYPE
        LDA     #AM_INVALID     ; Set as addressing mode invalid
        STA     AM
        LDA     #1              ; Set length to one
        STA     LENG
        LBRA    dism            ; Disassemble as normal

found11:                        ; Found entry in table
        ADDA    #1              ; Advance to instruction type entry in table
        LDB     A,X             ; Get instruction type
        STB     OPTYPE          ; Save it
        ADDA    #1              ; Advanced to address mode entry in table
        LDB     A,X             ; Get address mode
        STB     AM              ; Save it
        CLRA                    ; Clear MSB of D, addressing mode is now in A:B (D)
        TFR     D,X             ; Put addressing mode in X
        LDB     LENGTHS,X       ; Get instruction length from table
        STB     LENG            ; Store it
        INC     LENG            ; Add one because it is a two byte op code
        LBRA    dism            ; Continue normal disassembly processing.

not1011:
        STB     OPCODE          ; Save the op code
        CLRA                    ; Clear MSB of D
        TFR     D,X             ; Put op code in X
        LDB     OPCODES,X       ; Get opcode type from table
        STB     OPTYPE          ; Store it
        LDB     OPCODE          ; Get op code again
        TFR     D,X             ; Put opcode in X
        LDB     MODES,X         ; Get addressing mode type from table
        STB     AM              ; Store it
        TFR     D,X             ; Put addressing mode in X
        LDB     LENGTHS,X       ; Get instruction length from table
        STB     LENG            ; Store it

; If addressing mode is indexed, get and save the indexed addressing
; post byte.

dism:   LDA     AM              ; Get addressing mode
        CMPA    #AM_INDEXED     ; Is it indexed mode?
        BNE     NotIndexed      ; Branch if not
        LDX     ADRS,PCR        ; Get address of op code
                                ; If it is a page2/3 instruction, op code is the next byte after ADRS
        TST     PAGE23          ; Page2/3 instruction?
        BEQ     norm            ; Branch if not
        LDA     2,X             ; Post byte is two past ADRS
        BRA     getpb
norm:   LDA     1,X             ; Get next byte (the post byte)
getpb:  STA     POSTBYT         ; Save it

; Determine number of additional bytes for indexed addressing based on
; postbyte. If most significant bit is 0, there are no additional
; bytes and we can skip the rest of the check.

        BPL     NotIndexed      ; Branch of MSB is zero

; Else if most significant bit is 1, mask off all but low order 5 bits
; and look up length in table.

        ANDA    #%00011111      ; Mask off bits
        LEAX    POSTBYTES,PCR   ; Lookup table of lengths
        LDA     A,X             ; Get table entry
        ADDA    LENG            ; Add to instruction length
        STA     LENG            ; Save new length

NotIndexed:
        rts

; Disassemble instruction at address ADRS. On return, ADRS points to
; next instruction so it can be called again.

DISASM: JSR     Decode          ; Decode the instruction

; Print address followed by a space
        LDX     ADRS,PCR
        LBSR    PrintAddress

; Print one more space

        LBSR    PrintSpace

; Print the op code bytes based on the instruction length

        LDB     LENG            ; Number of bytes in instruction
        LDX     ADRS,PCR        ; Pointer to start of instruction
opby:   LDA     ,X+             ; Get instruction byte and increment pointer
        LBSR    PrintByte       ; Print it, followed by a space
        DECB                    ; Decrement byte count
        BNE     opby            ; Repeat until done

; Print needed remaining spaces to pad out to correct column

        LEAX    PADDING,PCR     ; Pointer to start of lookup table
        LDA     LENG            ; Number of bytes in instruction
        DECA                    ; Subtract 1 since table starts at 1, not 0
        LDA     A,X             ; Get number of spaces to print
        LBSR    PrintSpaces

; If a page2/3 instruction, advance ADRS to the next byte which points
; to the real op code.

        TST     PAGE23          ; Flag set
        BEQ     noinc           ; Branch if not
        LDD     ADRS            ; Increment 16-bit address
        ADDD    #1
        STD     ADRS

; Get and print mnemonic (4 chars)

noinc   LDB     OPTYPE          ; Get instruction type to index into table
        CLRA                    ; Clear MSB of D
        ASLB                    ; 16-bit shift of D: Rotate B, MSB into Carry
        ROLA                    ; Rotate A, Carry into LSB
        ASLB                    ; Do it twice to multiple by four
        ROLA                    ;
        LEAX    MNEMONICS,PCR   ; Pointer to start of table
        STA     TEMP1           ; Save value of A
        LDA     D,X             ; Get first char of mnemonic
        LBSR    PrintChar       ; Print it
        LDA     TEMP1           ; Restore value of A
        INCB                    ; Advance pointer
        LDA     D,X             ; Get second char of mnemonic
        LBSR    PrintChar       ; Print it
        LDA     TEMP1           ; Restore value of A
        INCB                    ; Advance pointer
        LDA     D,X             ; Get third char of mnemonic
        LBSR    PrintChar       ; Print it
        LDA     TEMP1           ; Restore value of A
        INCB                    ; Advance pointer
        LDA     D,X             ; Get fourth char of mnemonic
        LBSR    PrintChar       ; Print it

; Display any operands based on addressing mode and call appropriate
; routine. TODO: Could use a lookup table for this.

        LDA     AM              ; Get addressing mode
        CMPA    #AM_INVALID
        BEQ     DO_INVALID
        CMPA    #AM_INHERENT
        BEQ     DO_INHERENT
        CMPA    #AM_IMMEDIATE8
        BEQ     DO_IMMEDIATE8
        CMPA    #AM_IMMEDIATE16
        LBEQ    DO_IMMEDIATE16
        CMPA    #AM_DIRECT
        LBEQ    DO_DIRECT
        CMPA    #AM_EXTENDED
        LBEQ    DO_EXTENDED
        CMPA    #AM_RELATIVE8
        LBEQ    DO_RELATIVE8
        CMPA    #AM_RELATIVE16
        LBEQ    DO_RELATIVE16
        CMPA    #AM_INDEXED
        LBEQ    DO_INDEXED
        BRA     DO_INVALID      ; Should never be reached

DO_INVALID:                     ; Display "   ; INVALID"
        LDA     #15             ; Want 15 spaces
        LBSR    PrintSpaces
        LEAX    MSG1,PCR
        LBSR    PrintString
        LBRA    done

DO_INHERENT:                    ; Nothing else to do
        LBRA    done

DO_IMMEDIATE8:
        LDA     OPTYPE          ; Get opcode type
        CMPA    #OP_TFR         ; Is is TFR?
        BEQ     XFREXG          ; Handle special case of TFR
        CMPA    #OP_EXG         ; Is is EXG?
        BEQ     XFREXG          ; Handle special case of EXG

        CMPA    #OP_PULS        ; Is is PULS?
        LBEQ    PULPSH
        CMPA    #OP_PULU        ; Is is PULU?
        LBEQ    PULPSH
        CMPA    #OP_PSHS        ; Is is PSHS?
        LBEQ    PULPSH
        CMPA    #OP_PSHU        ; Is is PSHU?
        LBEQ    PULPSH

                                ; Display "  #$nn"
        LBSR    Print2Spaces    ; Two spaces
        LDA     #'#             ; Number sign
        LBSR    PrintChar
        LBSR    PrintDollar     ; Dollar sign
        LDX     ADRS,PCR        ; Get address of op code
        LDA     1,X             ; Get next byte (immediate data)
        LBSR    PrintByte       ; Print as hex value
        LBRA    done

XFREXG:                         ; Handle special case of TFR and EXG
                                ; Display "  r1,r2"
        LBSR    Print2Spaces    ; Two spaces
        LDX     ADRS,PCR        ; Get address of op code
        LDA     1,X             ; Get next byte (postbyte)
        ANDA    #%11110000      ; Mask out source register bits
        LSRA                    ; Shift into low order bits
        LSRA
        LSRA
        LSRA
        BSR     TFREXGRegister  ; Print source register name
        LDA     #',             ; Print comma
        LBSR    PrintChar
        LDA     1,X             ; Get postbyte again
        ANDA    #%00001111      ; Mask out destination register bits
        BSR     TFREXGRegister  ; Print destination register name
        LBRA    done

; Look up register name (in A) from Transfer/Exchange postbyte. 4 LSB
; bits determine the register name. Value is printed. Invalid value
; is shown as '?'.
; Value:    0 1 2 3 4 5  8 9 10 11
; Register: D X Y U S PC A B CC DP

TFREXGRegister:
        CMPA    #0
        BNE     Try1
        LDA     #'D
        BRA     Print1Reg
Try1:   CMPA    #1
        BNE     Try2
        LDA     #'X
        BRA     Print1Reg
Try2:   CMPA    #2
        BNE     Try3
        LDA     #'Y
        BRA     Print1Reg
Try3:   CMPA    #3
        BNE     Try4
        LDA     #'U
        BRA     Print1Reg
Try4:   CMPA    #4
        BNE     Try5
        LDA     #'S
        BRA     Print1Reg
Try5:   CMPA    #5
        BNE     Try8
        LDA     #'P
        LDB     #'C
        BRA     Print2Reg
Try8:   CMPA    #8
        BNE     Try9
        LDA     #'A
        BRA     Print1Reg
Try9:   CMPA    #9
        BNE     Try10
        LDA     #'B
        BRA     Print1Reg
Try10:  CMPA    #10
        BNE     Try11
        LDA     #'C
        LDB     #'C
        BRA     Print2Reg
Try11:  CMPA    #11
        BNE     Inv
        LDA     #'D
        LDB     #'P
        BRA     Print2Reg
Inv:    LDA     #'?             ; Invalid
                                ; Fall through
Print1Reg:
        LBSR   PrintChar        ; Print character
        RTS
Print2Reg:
        LBSR   PrintChar        ; Print first character
        TFR    B,A
        LBSR   PrintChar        ; Print second character
        RTS

; Handle PSHS/PSHU/PULS/PULU instruction operands
; Format is a register list, eg; "  A,B,X"

PULPSH:
        LBSR    Print2Spaces    ; Two spaces
        LDA     #1
        STA     FIRST           ; Flag set before any items printed
        LDX     ADRS,PCR        ; Get address of op code
        LDA     1,X             ; Get next byte (postbyte)

; Postbyte bits indicate registers to push/pull when 1.
; 7  6   5 4 3  2 1 0
; PC S/U Y X DP B A CC

; TODO: Could simplify this with shifting and lookup table.

        BITA    #%10000000      ; Bit 7 set?
        BEQ     bit6
        PSHS    A,B
        LDA     #'P
        LDB     #'C
        BSR     Print2Reg       ; Print PC
        CLR     FIRST
        PULS    A,B
bit6:   BITA    #%01000000      ; Bit 6 set?
        BEQ     bit5

; Need to show S or U depending on instruction

        PSHS    A               ; Save postbyte
        LDA     OPTYPE          ; Get opcode type
        CMPA    #OP_PULS
        BEQ     printu
        CMPA    #OP_PSHS
        BEQ     printu
        LBSR    PrintCommaIfNotFirst
        LDA     #'S             ; Print S
pr1     BSR     Print1Reg
        CLR     FIRST
        PULS    A
        bra     bit5
printu: BSR     PrintCommaIfNotFirst
        LDA     #'U             ; Print U
        bra     pr1
bit5:   BITA    #%00100000      ; Bit 5 set?
        BEQ     bit4
        PSHS    A
        BSR     PrintCommaIfNotFirst
        LDA     #'Y
        BSR     Print1Reg       ; Print Y
        CLR     FIRST
        PULS    A
bit4:   BITA    #%00010000      ; Bit 4 set?
        BEQ     bit3
        PSHS    A
        BSR     PrintCommaIfNotFirst
        LDA     #'X
        BSR     Print1Reg       ; Print X
        CLR     FIRST
        PULS    A
bit3:   BITA    #%00001000      ; Bit 3 set?
        BEQ     bit2
        PSHS    A,B
        BSR     PrintCommaIfNotFirst
        LDA     #'D
        LDB     #'P
        BSR     Print2Reg       ; Print DP
        CLR     FIRST
        PULS    A,B
bit2:   BITA    #%00000100      ; Bit 2 set?
        BEQ     bit1
        PSHS    A
        BSR     PrintCommaIfNotFirst
        LDA     #'B
        LBSR    Print1Reg       ; Print B
        CLR     FIRST
        PULS    A
bit1:   BITA    #%00000010      ; Bit 1 set?
        BEQ     bit0
        PSHS    A
        BSR     PrintCommaIfNotFirst
        LDA     #'A
        LBSR    Print1Reg       ; Print A
        CLR     FIRST
        PULS    A
bit0:   BITA    #%00000001      ; Bit 0 set?
        BEQ     done1
        PSHS    A,B
        BSR     PrintCommaIfNotFirst
        LDA     #'C
        LDB     #'C
        LBSR    Print2Reg       ; Print CC
        CLR     FIRST
        PULS    A,B
done1   LBRA    done

; Print comma if FIRST flag is not set.
PrintCommaIfNotFirst:
        TST     FIRST
        BNE     ret1
        LDA     #',
        LBSR    PrintChar
ret1:   RTS

DO_IMMEDIATE16:                 ; Display "  #$nnnn"
        LBSR    Print2Spaces    ; Two spaces
        LDA     #'#             ; Number sign
        LBSR    PrintChar
        LBSR    PrintDollar     ; Dollar sign
        LDX     ADRS,PCR        ; Get address of op code
        LDA     1,X             ; Get first byte (immediate data MSB)
        LDB     2,X             ; Get second byte (immediate data LSB)
        TFR     D,X             ; Put in X to print
        LBSR    PrintAddress    ; Print as hex value
        LBRA    done

DO_DIRECT:                      ; Display "  $nn"
        LBSR    Print2Spaces    ; Two spaces
        LBSR    PrintDollar     ; Dollar sign
        LDX     ADRS,PCR        ; Get address of op code
        LDA     1,X             ; Get next byte (byte data)
        LBSR    PrintByte       ; Print as hex value
        LBRA    done

DO_EXTENDED:                    ; Display "  $nnnn"
        LBSR    Print2Spaces    ; Two spaces
        LBSR    PrintDollar     ; Dollar sign
        LDX     ADRS,PCR        ; Get address of op code
        LDA     1,X             ; Get first byte (address MSB)
        LDB     2,X             ; Get second byte (address LSB)
        TFR     D,X             ; Put in X to print
        LBSR    PrintAddress    ; Print as hex value
        LBRA    done

DO_RELATIVE8:                   ; Display "  $nnnn"
        LBSR    Print2Spaces    ; Two spaces
        LBSR    PrintDollar     ; Dollar sign

; Destination address for relative branch is address of opcode + (sign
; extended)offset + 2, e.g.
;   $1015 + $(FF)FC + 2 = $1013
;   $101B + $(00)27 + 2 = $1044

        LDX     ADRS,PCR        ; Get address of op code
        LDB     1,X             ; Get first byte (8-bit branch offset)
        SEX                     ; Sign extend to 16 bits
        ADDD    ADRS            ; Add address of op code
        ADDD    #2              ; Add 2
        TFR     D,X             ; Put in X to print
        LBSR    PrintAddress    ; Print as hex value
        LBRA    done

DO_RELATIVE16:                  ; Display "  $nnnn"
        LBSR    Print2Spaces    ; Two spaces
        LBSR    PrintDollar     ; Dollar sign

; Destination address calculation is similar to above, except offset
; is 16 bits and need to add 3.

        LDX     ADRS,PCR        ; Get address of op code
        LDD     1,X             ; Get next 2 bytes (16-bit branch offset)
        ADDD    ADRS            ; Add address of op code
        ADDD    #3              ; Add 3
        TFR     D,X             ; Put in X to print
        LBSR    PrintAddress    ; Print as hex value
        LBRA    done

DO_INDEXED:
        LBSR    Print2Spaces    ; Two spaces

; Addressing modes are determined by the postbyte:
;
; Postbyte  Format  Additional Bytes
; --------  ------  ----------------
; 0RRnnnnn  n,R     0
; 1RR00100  ,R      0
; 1RR01000  n,R     1
; 1RR01001  n,R     2
; 1RR00110  A,R     0
; 1RR00101  B,R     0
; 1RR01011  D,R     0
; 1RR00000  ,R+     0
; 1RR00001  ,R++    0
; 1RR00010  ,-R     0
; 1RR00011  ,--R    0
; 1xx01100  n,PCR   1
; 1xx01101  n,PCR   2
; 1RR10100  [,R]    0
; 1RR11000  [n,R]   1
; 1RR11001  [n,R]   2
; 1RR10110  [A,R]   0
; 1RR10101  [B,R]   0
; 1RR11011  [D,R]   0
; 1RR10001  [,R++]  0
; 1RR10011  [,--R]  0
; 1xx11100  [n,PCR] 1
; 1xx11101  [n,PCR] 2
; 10011111  [n]     2
;
; Where RR: 00=X 01=Y 10=U 11=S

        LDA     POSTBYT         ; Get postbyte
        BMI     ind2            ; Branch if MSB is 1

                                ; Format is 0RRnnnnn  n,R
        ANDA    #%00011111      ; Get 5-bit offset
        LBSR    PrintDollar     ; Dollar sign
        LBSR    PrintByte       ; Print offset
        LBSR    PrintComma      ; Print comma
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LBRA    done
ind2:
        ANDA    #%10011111      ; Mask out register bits
        CMPA    #%10000100      ; Check against pattern
        BNE     ind3
                                ; Format is 1RR00100  ,R
        LBSR    PrintComma      ; Print comma
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LBRA    done
ind3:
        CMPA    #%10001000      ; Check against pattern
        BNE     ind4
                                ; Format is 1RR01000  n,R
        LDX     ADRS,PCR
        LDA     2,X             ; Get 8-bit offset
        LBSR    PrintDollar     ; Dollar sign
        LBSR    PrintByte       ; Display it
        LBSR    PrintComma      ; Print comma
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LBRA    done
ind4:
        CMPA    #%10001001      ; Check against pattern
        BNE     ind5
                                ; Format is 1RR01001  n,R
        LDX     ADRS,PCR
        LDD     2,X             ; Get 16-bit offset
        TFR     D,X
        LBSR    PrintDollar     ; Dollar sign
        LBSR    PrintAddress    ; Display it
        LBSR    PrintComma      ; Print comma
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LBRA    done
ind5:
        CMPA    #%10000110      ; Check against pattern
        BNE     ind6
                                ; Format is 1RR00110  A,R
        LDA     #'A
        LBSR    PrintChar       ; Print A
commar: LBSR    PrintComma      ; Print comma
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LBRA    done
ind6:
        CMPA    #%10000101      ; Check against pattern
        BNE     ind7
                                ; Format is 1RR00101  B,R
        LDA     #'B
        LBSR    PrintChar
        BRA     commar
ind7:
        CMPA    #%10001011      ; Check against pattern
        BNE     ind8
                                ; Format is 1RR01011  D,R
        LDA     #'D
        LBSR    PrintChar
        BRA     commar
ind8:
        CMPA    #%10000000      ; Check against pattern
        BNE     ind9
                                ; Format is 1RR00000  ,R+
        LBSR    PrintComma      ; Print comma
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LDA     #'+             ; Print plus
        LBSR    PrintChar
        LBRA    done
ind9:
        CMPA    #%10000001      ; Check against pattern
        BNE     ind10
                                ; Format is 1RR00001  ,R++
        LBSR    PrintComma      ; Print comma
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LDA     #'+             ; Print plus twice
        LBSR    PrintChar
        LBSR    PrintChar
        LBRA    done
ind10:
        CMPA    #%10000010      ; Check against pattern
        BNE     ind11
                                ; Format is 1RR00010  ,-R
        LBSR    PrintComma      ; Print comma
        LDA     #'-             ; Print minus
        LBSR    PrintChar
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LBRA    done
ind11:
        CMPA    #%10000011      ; Check against pattern
        BNE     ind12
                                ; Format is 1RR00011  ,--R
        LBSR    PrintComma      ; Print comma
        LDA     #'-             ; Print minus twice
        LBSR    PrintChar
        LBSR    PrintChar
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LBRA    done
ind12:
        CMPA    #%10001100      ; Check against pattern
        BNE     ind13
                                ; Format is 1xx01100  n,PCR
        LDX     ADRS,PCR
        LDA     2,X             ; Get 8-bit offset
        LBSR    PrintDollar     ; Dollar sign
        LBSR    PrintByte       ; Display it
        LBSR    PrintComma      ; Print comma
        LBSR    PrintPCR        ; Print PCR
        LBRA    done
ind13:
        CMPA    #%10001101      ; Check against pattern
        BNE     ind14
                                ; Format is 1xx01101  n,PCR
        LDX     ADRS,PCR
        LDD     2,X             ; Get 16-bit offset
        TFR     D,X
        LBSR    PrintDollar     ; Dollar sign
        LBSR    PrintAddress    ; Display it
        LBSR    PrintComma      ; Print comma
        LBSR    PrintPCR        ; Print PCR
        LBRA    done
ind14:
        CMPA    #%10010100      ; Check against pattern
        BNE     ind15
                                ; Format is 1RR10100  [,R]
        LBSR    PrintLBracket   ; Print left bracket
        LBSR    PrintComma      ; Print comma
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LBSR    PrintRBracket   ; Print right bracket
        LBRA    done
ind15:
        CMPA    #%10011000      ; Check against pattern
        BNE     ind16
                                ; Format is 1RR11000  [n,R]
        LBSR    PrintLBracket   ; Print left bracket
        LDX     ADRS,PCR
        LDA     2,X             ; Get 8-bit offset
        LBSR    PrintDollar     ; Dollar sign
        LBSR    PrintByte       ; Display it
        LBSR    PrintComma      ; Print comma
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LBSR    PrintRBracket   ; Print right bracket
        LBRA    done
ind16:
        CMPA    #%10011001      ; Check against pattern
        BNE     ind17
                                ; Format is 1RR11001  [n,R]
        LBSR    PrintLBracket   ; Print left bracket
        LDX     ADRS,PCR
        LDD     2,X             ; Get 16-bit offset
        TFR     D,X
        LBSR    PrintDollar     ; Dollar sign
        LBSR    PrintAddress    ; Display it
        LBSR    PrintComma      ; Print comma
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LBSR    PrintRBracket   ; Print right bracket
        LBRA    done
ind17:
        CMPA    #%10010110      ; Check against pattern
        BNE     ind18
                                ; Format is 1RR10110  [A,R]
        LBSR    PrintLBracket   ; Print left bracket
        LDA     #'A
        LBSR    PrintChar       ; Print A
comrb:  LBSR    PrintComma      ; Print comma
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LBSR    PrintRBracket   ; Print right bracket
        LBRA    done
ind18:
        CMPA    #%10010101      ; Check against pattern
        BNE     ind19
                                ; Format is 1RR10101  [B,R]
        LBSR    PrintLBracket   ; Print left bracket
        LDA     #'B
        LBSR    PrintChar
        BRA     comrb
ind19:
        CMPA    #%10011011      ; Check against pattern
        BNE     ind20
                                ; Format is 1RR11011  [D,R]
        LBSR    PrintLBracket   ; Print left bracket
        LDA     #'D
        LBSR    PrintChar
        BRA     comrb
ind20:
        CMPA    #%10010001      ; Check against pattern
        BNE     ind21
                                ; Format is 1RR10001  [,R++]
        LBSR    PrintLBracket   ; Print left bracket
        LBSR    PrintComma      ; Print comma
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LDA     #'+             ; Print plus twice
        LBSR    PrintChar
        LBSR    PrintChar
        LBSR    PrintRBracket   ; Print right bracket
        LBRA    done
ind21:
        CMPA    #%10010011      ; Check against pattern
        BNE     ind22
                                ; Format is 1RR10011  [,--R]
        LBSR    PrintLBracket   ; Print left bracket
        LBSR    PrintComma      ; Print comma
        LDA     #'-             ; Print minus twice
        LBSR    PrintChar
        LBSR    PrintChar
        LDA     POSTBYT         ; Get postbyte again
        LBSR    PrintRegister   ; Print register name
        LBSR    PrintRBracket   ; Print right bracket
        LBRA    done
ind22:
        CMPA    #%10011100      ; Check against pattern
        BNE     ind23
                                ; Format is 1xx11100  [n,PCR]
        LBSR    PrintLBracket   ; Print left bracket
        LDX     ADRS,PCR
        LDA     2,X             ; Get 8-bit offset
        LBSR    PrintDollar     ; Dollar sign
        LBSR    PrintByte       ; Display it
        LBSR    PrintComma      ; Print comma
        LBSR    PrintPCR        ; Print PCR
        LBSR    PrintRBracket   ; Print right bracket
        LBRA    done
ind23:
        CMPA    #%10011101      ; Check against pattern
        BNE     ind24
                                ; Format is 1xx11101  [n,PCR]
        LBSR    PrintLBracket   ; Print left bracket
        LDX     ADRS,PCR
        LDD     2,X             ; Get 16-bit offset
        TFR     D,X
        LBSR    PrintDollar     ; Dollar sign
        LBSR    PrintAddress    ; Display it
        LBSR    PrintComma      ; Print comma
        LBSR    PrintPCR        ; Print PCR
        LBSR    PrintRBracket   ; Print right bracket
        LBRA    done
ind24:
        CMPA    #%10011111      ; Check against pattern
        BNE     ind25
                                ; Format is 1xx11111  [n]
        LBSR    PrintLBracket   ; Print left bracket
        LDX     ADRS,PCR
        LDD     2,X             ; Get 16-bit offset
        TFR     D,X
        LBSR    PrintDollar     ; Dollar sign
        LBSR    PrintAddress    ; Display it
        LBSR    PrintRBracket   ; Print right bracket
        LBRA    done
ind25:                          ; Should never be reached
        LBRA    done

; Print register name encoded in bits 5 and 6 of A for indexed
; addressing: xRRxxxxx where RR: 00=X 01=Y 10=U 11=S
; Registers changed: X
PrintRegister:
        PSHS    A               ; Save A
        ANDA    #%01100000      ; Mask out other bits
        LSRA                    ; Shift into 2 LSB
        LSRA
        LSRA
        LSRA
        LSRA
        LEAX    REGTABLE,PCR    ; Lookup table of register name characters
        LDA     A,X             ; Get character
        LBSR    PrintChar       ; Print it
        PULS    A               ; Restore A
        RTS                     ; Return
REGTABLE:
        FCC     "XYUS"


; Print the string "PCR" on the console.
; Registers changed: X
PrintPCR:
        LEAX    MSG3,PCR        ; "PCR" string
        LBSR    PrintString
        RTS

; Print final CR

done:   LBSR    PrintCR

; Update address to next instruction
; If it was a page 2/3 instruction, we need to subtract one from the
; length to account for ADRS being moved to the second byte of the
; instruction.

        TST     PAGE23          ; Flag set
        BEQ     not23           ; Branch if not
        DEC     LENG            ; Decrement length
not23:  CLRA                    ; Clear MSB of D
        LDB     LENG            ; Get length byte in LSB of D
        ADDD    ADRS            ; Add to address
        STD     ADRS            ; Write new address

; Return
        RTS

; *** DATA

; Table of instruction strings. 4 bytes per table entry
MNEMONICS:
        FCC     "??? "          ; $00
        FCC     "ABX "          ; $01
        FCC     "ADCA"          ; $02
        FCC     "ADCB"          ; $03
        FCC     "ADDA"          ; $04
        FCC     "ADDB"          ; $05
        FCC     "ADDD"          ; $06
        FCC     "ANDA"          ; $07
        FCC     "ANDB"          ; $08
        FCC     "ANDC"          ; $09 Should really  be "ANDCC"
        FCC     "ASL "          ; $0A
        FCC     "ASLA"          ; $0B
        FCC     "ASLB"          ; $0C
        FCC     "ASR "          ; $0D
        FCC     "ASRA"          ; $0E
        FCC     "ASRB"          ; $0F
        FCC     "BCC "          ; $10
        FCC     "BCS "          ; $11
        FCC     "BEQ "          ; $12
        FCC     "BGE "          ; $13
        FCC     "BGT "          ; $14
        FCC     "BHI "          ; $15
        FCC     "BITA"          ; $16
        FCC     "BITB"          ; $17
        FCC     "BLE "          ; $18
        FCC     "BLS "          ; $19
        FCC     "BLT "          ; $1A
        FCC     "BMI "          ; $1B
        FCC     "BNE "          ; $1C
        FCC     "BPL "          ; $1D
        FCC     "BRA "          ; $1E
        FCC     "BRN "          ; $1F
        FCC     "BSR "          ; $20
        FCC     "BVC "          ; $21
        FCC     "BVS "          ; $22
        FCC     "CLR "          ; $23
        FCC     "CLRA"          ; $24
        FCC     "CLRB"          ; $25
        FCC     "CMPA"          ; $26
        FCC     "CMPB"          ; $27
        FCC     "CMPD"          ; $28
        FCC     "CMPS"          ; $29
        FCC     "CMPU"          ; $2A
        FCC     "CMPX"          ; $2B
        FCC     "CMPY"          ; $2C
        FCC     "COMA"          ; $2D
        FCC     "COMB"          ; $2E
        FCC     "COM "          ; $2F
        FCC     "CWAI"          ; $30
        FCC     "DAA "          ; $31
        FCC     "DEC "          ; $32
        FCC     "DECA"          ; $33
        FCC     "DECB"          ; $34
        FCC     "EORA"          ; $35
        FCC     "EORB"          ; $36
        FCC     "EXG "          ; $37
        FCC     "INC "          ; $38
        FCC     "INCA"          ; $39
        FCC     "INCB"          ; $3A
        FCC     "JMP "          ; $3B
        FCC     "JSR "          ; $3C
        FCC     "LBCC"          ; $3D
        FCC     "LBCS"          ; $3E
        FCC     "LBEQ"          ; $3F
        FCC     "LBGE"          ; $40
        FCC     "LBGT"          ; $41
        FCC     "LBHI"          ; $42
        FCC     "LBLE"          ; $43
        FCC     "LBLS"          ; $44
        FCC     "LBLT"          ; $45
        FCC     "LBMI"          ; $46
        FCC     "LBNE"          ; $47
        FCC     "LBPL"          ; $48
        FCC     "LBRA"          ; $49
        FCC     "LBRN"          ; $4A
        FCC     "LBSR"          ; $4B
        FCC     "LBVC"          ; $4C
        FCC     "LBVS"          ; $4D
        FCC     "LDA "          ; $4E
        FCC     "LDB "          ; $4F
        FCC     "LDD "          ; $50
        FCC     "LDS "          ; $51
        FCC     "LDU "          ; $52
        FCC     "LDX "          ; $53
        FCC     "LDY "          ; $54
        FCC     "LEAS"          ; $55
        FCC     "LEAU"          ; $56
        FCC     "LEAX"          ; $57
        FCC     "LEAY"          ; $58
        FCC     "LSR "          ; $59
        FCC     "LSRA"          ; $5A
        FCC     "LSRB"          ; $5B
        FCC     "MUL "          ; $5C
        FCC     "NEG "          ; $5D
        FCC     "NEGA"          ; $5E
        FCC     "NEGB"          ; $5F
        FCC     "NOP "          ; $60
        FCC     "ORA "          ; $61
        FCC     "ORB "          ; $62
        FCC     "ORCC"          ; $63
        FCC     "PSHS"          ; $64
        FCC     "PSHU"          ; $65
        FCC     "PULS"          ; $66
        FCC     "PULU"          ; $67
        FCC     "ROL "          ; $68
        FCC     "ROLA"          ; $69
        FCC     "ROLB"          ; $6A
        FCC     "ROR "          ; $6B
        FCC     "RORA"          ; $6C
        FCC     "RORB"          ; $6D
        FCC     "RTI "          ; $6E
        FCC     "RTS "          ; $6F
        FCC     "SBCA"          ; $70
        FCC     "SBCB"          ; $71
        FCC     "SEX "          ; $72
        FCC     "STA "          ; $73
        FCC     "STB "          ; $74
        FCC     "STD "          ; $75
        FCC     "STS "          ; $76
        FCC     "STU "          ; $77
        FCC     "STX "          ; $78
        FCC     "STY "          ; $79
        FCC     "SUBA"          ; $7A
        FCC     "SUBB"          ; $7B
        FCC     "SUBD"          ; $7C
        FCC     "SWI "          ; $7D
        FCC     "SWI2"          ; $7E
        FCC     "SWI3"          ; $7F
        FCC     "SYNC"          ; $80
        FCC     "TFR "          ; $81
        FCC     "TST "          ; $82
        FCC     "TSTA"          ; $83
        FCC     "TSTB"          ; $84

; Lengths of instructions given an addressing mode. Matches values of
; AM_* Indexed addessing instructions length can increase due to post
; byte.
LENGTHS:
        FCB     1               ; 0 AM_INVALID
        FCB     1               ; 1 AM_INHERENT
        FCB     2               ; 2 AM_IMMEDIATE8
        FCB     3               ; 3 AM_IMMEDIATE16
        FCB     2               ; 4 AM_DIRECT
        FCB     3               ; 5 AM_EXTENDED
        FCB     2               ; 6 AM_RELATIVE8
        FCB     3               ; 7 AM_RELATIVE16
        FCB     2               ; 8 AM_INDEXED

; Lookup table to return needed remaining spaces to print to pad out
; instruction to correct column in disassembly.
; # bytes: 1 2 3 4
; Padding: 9 6 3 0
PADDING:
        FCB     10, 7, 4, 1

; Lookup table to return number of additional bytes for indexed
; addressing based on low order 5 bits of postbyte. Based on
; detailed list of values below.

POSTBYTES:
        FCB     0, 0, 0, 0, 0, 0, 0, 0
        FCB     1, 2, 0, 0, 1, 2, 0, 0
        FCB     0, 0, 0, 0, 0, 0, 0, 0
        FCB     1, 2, 0, 0, 1, 2, 0, 2

; Pattern:  # Extra bytes:
; --------  --------------
; 0XXXXXXX   0
; 1XX00000   0
; 1XX00001   0
; 1XX00010   0
; 1XX00011   0
; 1XX00100   0
; 1X000101   0
; 1XX00110   0
; 1XX00111   0 (INVALID)
; 1XX01000   1
; 1XX01001   2
; 1XX01010   0 (INVALID)
; 1XX01011   0
; 1XX01100   1
; 1XX01101   2
; 1XX01110   0 (INVALID)
; 1XX01111   0 (INVALID)
; 1XX10000   0 (INVALID)
; 1XX10001   0
; 1XX10010   0 (INVALID)
; 1XX10011   0
; 1XX10100   0
; 1XX10101   0
; 1XX10110   0
; 1XX10111   0 (INVALID)
; 1XX11000   1
; 1XX11001   2
; 1XX11010   0 (INVALID)
; 1XX11011   0
; 1XX11100   1
; 1XX11101   2
; 1XX11110   0 (INVALID)
; 1XX11111   2

; Opcodes. Listed in order indexed by op code. Defines the mnemonic.
OPCODES:
        FCB     OP_NEG          ; 00
        FCB     OP_INV          ; 01
        FCB     OP_INV          ; 02
        FCB     OP_COMB         ; 03
        FCB     OP_LSR          ; 04
        FCB     OP_INV          ; 05
        FCB     OP_ROR          ; 06
        FCB     OP_ASR          ; 07
        FCB     OP_ASL          ; 08
        FCB     OP_ROL          ; 09
        FCB     OP_DEC          ; 0A
        FCB     OP_INV          ; 0B
        FCB     OP_INC          ; 0C
        FCB     OP_TST          ; 0D
        FCB     OP_JMP          ; 0E
        FCB     OP_CLR          ; 0F

        FCB     OP_INV          ; 10 Page 2 extended opcodes (see other table)
        FCB     OP_INV          ; 11 Page 3 extended opcodes (see other table)
        FCB     OP_NOP          ; 12
        FCB     OP_SYNC         ; 13
        FCB     OP_INV          ; 14
        FCB     OP_INV          ; 15
        FCB     OP_LBRA         ; 16
        FCB     OP_LBSR         ; 17
        FCB     OP_INV          ; 18
        FCB     OP_DAA          ; 19
        FCB     OP_ORCC         ; 1A
        FCB     OP_INV          ; 1B
        FCB     OP_ANDCC        ; 1C
        FCB     OP_SEX          ; 1D
        FCB     OP_EXG          ; 1E
        FCB     OP_TFR          ; 1F

        FCB     OP_BRA          ; 20
        FCB     OP_BRN          ; 21
        FCB     OP_BHI          ; 22
        FCB     OP_BLS          ; 23
        FCB     OP_BCC          ; 24
        FCB     OP_BCS          ; 25
        FCB     OP_BNE          ; 26
        FCB     OP_BEQ          ; 27
        FCB     OP_BVC          ; 28
        FCB     OP_BVS          ; 29
        FCB     OP_BPL          ; 2A
        FCB     OP_BMI          ; 2B
        FCB     OP_BGE          ; 2C
        FCB     OP_BLT          ; 2D
        FCB     OP_BGT          ; 2E
        FCB     OP_BLE          ; 2F

        FCB     OP_LEAX         ; 30
        FCB     OP_LEAY         ; 31
        FCB     OP_LEAS         ; 32
        FCB     OP_LEAU         ; 33
        FCB     OP_PSHS         ; 34
        FCB     OP_PULS         ; 35
        FCB     OP_PSHU         ; 36
        FCB     OP_PULU         ; 37
        FCB     OP_INV          ; 38
        FCB     OP_RTS          ; 39
        FCB     OP_ABX          ; 3A
        FCB     OP_RTI          ; 3B
        FCB     OP_CWAI         ; 3C
        FCB     OP_MUL          ; 3D
        FCB     OP_INV          ; 3E
        FCB     OP_SWI          ; 3F

        FCB     OP_NEGA         ; 40
        FCB     OP_INV          ; 41
        FCB     OP_INV          ; 42
        FCB     OP_COMA         ; 43
        FCB     OP_LSRA         ; 44
        FCB     OP_INV          ; 45
        FCB     OP_RORA         ; 46
        FCB     OP_ASRA         ; 47
        FCB     OP_ASLA         ; 48
        FCB     OP_ROLA         ; 49
        FCB     OP_DECA         ; 4A
        FCB     OP_INV          ; 4B
        FCB     OP_INCA         ; 4C
        FCB     OP_TSTA         ; 4D
        FCB     OP_INV          ; 4E
        FCB     OP_CLRA         ; 4F

        FCB     OP_NEGB         ; 50
        FCB     OP_INV          ; 51
        FCB     OP_INV          ; 52
        FCB     OP_COMB         ; 53
        FCB     OP_LSRB         ; 54
        FCB     OP_INV          ; 55
        FCB     OP_RORB         ; 56
        FCB     OP_ASRB         ; 57
        FCB     OP_ASLB         ; 58
        FCB     OP_ROLB         ; 59
        FCB     OP_DECB         ; 5A
        FCB     OP_INV          ; 5B
        FCB     OP_INCB         ; 5C
        FCB     OP_TSTB         ; 5D
        FCB     OP_INV          ; 5E
        FCB     OP_CLRB         ; 5F

        FCB     OP_NEG          ; 60
        FCB     OP_INV          ; 61
        FCB     OP_INV          ; 62
        FCB     OP_COM          ; 63
        FCB     OP_LSR          ; 64
        FCB     OP_INV          ; 65
        FCB     OP_ROR          ; 66
        FCB     OP_ASR          ; 67
        FCB     OP_ASL          ; 68
        FCB     OP_ROL          ; 69
        FCB     OP_DEC          ; 6A
        FCB     OP_INV          ; 6B
        FCB     OP_INC          ; 6C
        FCB     OP_TST          ; 6D
        FCB     OP_JMP          ; 6E
        FCB     OP_CLR          ; 6F

        FCB     OP_NEG          ; 70
        FCB     OP_INV          ; 71
        FCB     OP_INV          ; 72
        FCB     OP_COM          ; 73
        FCB     OP_LSR          ; 74
        FCB     OP_INV          ; 75
        FCB     OP_ROR          ; 76
        FCB     OP_ASR          ; 77
        FCB     OP_ASL          ; 78
        FCB     OP_ROL          ; 79
        FCB     OP_DEC          ; 7A
        FCB     OP_INV          ; 7B
        FCB     OP_INC          ; 7C
        FCB     OP_TST          ; 7D
        FCB     OP_JMP          ; 7E
        FCB     OP_CLR          ; 7F

        FCB     OP_SUBA         ; 80
        FCB     OP_CMPA         ; 81
        FCB     OP_SBCA         ; 82
        FCB     OP_SUBD         ; 83
        FCB     OP_ANDA         ; 84
        FCB     OP_BITA         ; 85
        FCB     OP_LDA          ; 86
        FCB     OP_INV          ; 87
        FCB     OP_EORA         ; 88
        FCB     OP_ADCA         ; 89
        FCB     OP_ORA          ; 8A
        FCB     OP_ADDA         ; 8B
        FCB     OP_CMPX         ; 8C
        FCB     OP_BSR          ; 8D
        FCB     OP_LDX          ; 8E
        FCB     OP_INV          ; 8F

        FCB     OP_SUBA         ; 90
        FCB     OP_CMPA         ; 91
        FCB     OP_SBCA         ; 92
        FCB     OP_SUBD         ; 93
        FCB     OP_ANDA         ; 94
        FCB     OP_BITA         ; 95
        FCB     OP_LDA          ; 96
        FCB     OP_STA          ; 97
        FCB     OP_EORA         ; 98
        FCB     OP_ADCA         ; 99
        FCB     OP_ORA          ; 9A
        FCB     OP_ADDA         ; 9B
        FCB     OP_CMPX         ; 9C
        FCB     OP_JSR          ; 9D
        FCB     OP_LDX          ; 9E
        FCB     OP_STX          ; 9F

        FCB     OP_SUBA         ; A0
        FCB     OP_CMPA         ; A1
        FCB     OP_SBCA         ; A2
        FCB     OP_SUBD         ; A3
        FCB     OP_ANDA         ; A4
        FCB     OP_BITA         ; A5
        FCB     OP_LDA          ; A6
        FCB     OP_STA          ; A7
        FCB     OP_EORA         ; A8
        FCB     OP_ADCA         ; A9
        FCB     OP_ORA          ; AA
        FCB     OP_ADDA         ; AB
        FCB     OP_CMPX         ; AC
        FCB     OP_JSR          ; AD
        FCB     OP_LDX          ; AE
        FCB     OP_STX          ; AF

        FCB     OP_SUBA         ; B0
        FCB     OP_CMPA         ; B1
        FCB     OP_SBCA         ; B2
        FCB     OP_SUBD         ; B3
        FCB     OP_ANDA         ; B4
        FCB     OP_BITA         ; B5
        FCB     OP_LDA          ; B6
        FCB     OP_STA          ; B7
        FCB     OP_EORA         ; B8
        FCB     OP_ADCA         ; B9
        FCB     OP_ORA          ; BA
        FCB     OP_ADDA         ; BB
        FCB     OP_CMPX         ; BC
        FCB     OP_JSR          ; BD
        FCB     OP_LDX          ; BE
        FCB     OP_STX          ; BF

        FCB     OP_SUBB         ; C0
        FCB     OP_CMPB         ; C1
        FCB     OP_SBCB         ; C2
        FCB     OP_ADDD         ; C3
        FCB     OP_ANDB         ; C4
        FCB     OP_BITB         ; C5
        FCB     OP_LDB          ; C6
        FCB     OP_INV          ; C7
        FCB     OP_EORB         ; C8
        FCB     OP_ADCB         ; C9
        FCB     OP_ORB          ; CA
        FCB     OP_ADDB         ; CB
        FCB     OP_LDD          ; CC
        FCB     OP_INV          ; CD
        FCB     OP_LDU          ; CE
        FCB     OP_INV          ; CF

        FCB     OP_SUBB         ; D0
        FCB     OP_CMPB         ; D1
        FCB     OP_SBCB         ; D2
        FCB     OP_ADDD         ; D3
        FCB     OP_ANDB         ; D4
        FCB     OP_BITB         ; D5
        FCB     OP_LDB          ; D6
        FCB     OP_STB          ; D7
        FCB     OP_EORB         ; D8
        FCB     OP_ADCB         ; D9
        FCB     OP_ORB          ; DA
        FCB     OP_ADDB         ; DB
        FCB     OP_LDD          ; DC
        FCB     OP_STD          ; DD
        FCB     OP_LDU          ; DE
        FCB     OP_STU          ; DF

        FCB     OP_SUBB         ; E0
        FCB     OP_CMPB         ; E1
        FCB     OP_SBCB         ; E2
        FCB     OP_ADDD         ; E3
        FCB     OP_ANDB         ; E4
        FCB     OP_BITB         ; E5
        FCB     OP_LDB          ; E6
        FCB     OP_STB          ; E7
        FCB     OP_EORB         ; E8
        FCB     OP_ADCB         ; E9
        FCB     OP_ORB          ; EA
        FCB     OP_ADDB         ; EB
        FCB     OP_LDD          ; EC
        FCB     OP_STD          ; ED
        FCB     OP_LDU          ; EE
        FCB     OP_STU          ; EF

        FCB     OP_SUBB         ; F0
        FCB     OP_CMPB         ; F1
        FCB     OP_SBCB         ; F2
        FCB     OP_ADDD         ; F3
        FCB     OP_ANDB         ; F4
        FCB     OP_BITB         ; F5
        FCB     OP_LDB          ; F6
        FCB     OP_STB          ; F7
        FCB     OP_EORB         ; F8
        FCB     OP_ADCB         ; F9
        FCB     OP_ORB          ; FA
        FCB     OP_ADDB         ; FB
        FCB     OP_LDD          ; FC
        FCB     OP_STD          ; FD
        FCB     OP_LDU          ; FE
        FCB     OP_STU          ; FF

; Table of addressing modes. Listed in order,indexed by op code.
MODES:
        FCB     AM_DIRECT       ; 00
        FCB     AM_INVALID      ; 01
        FCB     AM_INVALID      ; 02
        FCB     AM_DIRECT       ; 03
        FCB     AM_DIRECT       ; 04
        FCB     AM_INVALID      ; 05
        FCB     AM_DIRECT       ; 06
        FCB     AM_DIRECT       ; 07
        FCB     AM_DIRECT       ; 08
        FCB     AM_DIRECT       ; 09
        FCB     AM_DIRECT       ; 0A
        FCB     AM_INVALID      ; 0B
        FCB     AM_DIRECT       ; 0C
        FCB     AM_DIRECT       ; 0D
        FCB     AM_DIRECT       ; 0E
        FCB     AM_DIRECT       ; 0F

        FCB     AM_INVALID      ; 10 Page 2 extended opcodes (see other table)
        FCB     AM_INVALID      ; 11 Page 3 extended opcodes (see other table)
        FCB     AM_INHERENT     ; 12
        FCB     AM_INHERENT     ; 13
        FCB     AM_INVALID      ; 14
        FCB     AM_INVALID      ; 15
        FCB     AM_RELATIVE16   ; 16
        FCB     AM_RELATIVE16   ; 17
        FCB     AM_INVALID      ; 18
        FCB     AM_INHERENT     ; 19
        FCB     AM_IMMEDIATE8   ; 1A
        FCB     AM_INVALID      ; 1B
        FCB     AM_IMMEDIATE8   ; 1C
        FCB     AM_INHERENT     ; 1D
        FCB     AM_IMMEDIATE8   ; 1E
        FCB     AM_IMMEDIATE8   ; 1F

        FCB     AM_RELATIVE8    ; 20
        FCB     AM_RELATIVE8    ; 21
        FCB     AM_RELATIVE8    ; 22
        FCB     AM_RELATIVE8    ; 23
        FCB     AM_RELATIVE8    ; 24
        FCB     AM_RELATIVE8    ; 25
        FCB     AM_RELATIVE8    ; 26
        FCB     AM_RELATIVE8    ; 27
        FCB     AM_RELATIVE8    ; 28
        FCB     AM_RELATIVE8    ; 29
        FCB     AM_RELATIVE8    ; 2A
        FCB     AM_RELATIVE8    ; 2B
        FCB     AM_RELATIVE8    ; 2C
        FCB     AM_RELATIVE8    ; 2D
        FCB     AM_RELATIVE8    ; 2E
        FCB     AM_RELATIVE8    ; 2F

        FCB     AM_INDEXED      ; 30
        FCB     AM_INDEXED      ; 31
        FCB     AM_INDEXED      ; 32
        FCB     AM_INDEXED      ; 33
        FCB     AM_IMMEDIATE8   ; 34
        FCB     AM_IMMEDIATE8   ; 35
        FCB     AM_IMMEDIATE8   ; 36
        FCB     AM_IMMEDIATE8   ; 37
        FCB     AM_INVALID      ; 38
        FCB     AM_INHERENT     ; 39
        FCB     AM_INHERENT     ; 3A
        FCB     AM_INHERENT     ; 3B
        FCB     AM_IMMEDIATE8   ; 3C
        FCB     AM_INHERENT     ; 3D
        FCB     AM_INVALID      ; 3E
        FCB     AM_INHERENT     ; 3F

        FCB     AM_INHERENT     ; 40
        FCB     AM_INVALID      ; 41
        FCB     AM_INVALID      ; 42
        FCB     AM_INHERENT     ; 43
        FCB     AM_INHERENT     ; 44
        FCB     AM_INVALID      ; 45
        FCB     AM_INHERENT     ; 46
        FCB     AM_INHERENT     ; 47
        FCB     AM_INHERENT     ; 48
        FCB     AM_INHERENT     ; 49
        FCB     AM_INHERENT     ; 4A
        FCB     AM_INVALID      ; 4B
        FCB     AM_INHERENT     ; 4C
        FCB     AM_INHERENT     ; 4D
        FCB     AM_INVALID      ; 4E
        FCB     AM_INHERENT     ; 4F

        FCB     AM_INHERENT     ; 50
        FCB     AM_INVALID      ; 51
        FCB     AM_INVALID      ; 52
        FCB     AM_INHERENT     ; 53
        FCB     AM_INHERENT     ; 54
        FCB     AM_INVALID      ; 55
        FCB     AM_INHERENT     ; 56
        FCB     AM_INHERENT     ; 57
        FCB     AM_INHERENT     ; 58
        FCB     AM_INHERENT     ; 59
        FCB     AM_INHERENT     ; 5A
        FCB     AM_INVALID      ; 5B
        FCB     AM_INHERENT     ; 5C
        FCB     AM_INHERENT     ; 5D
        FCB     AM_INVALID      ; 5E
        FCB     AM_INHERENT     ; 5F

        FCB     AM_INDEXED      ; 60
        FCB     AM_INVALID      ; 61
        FCB     AM_INVALID      ; 62
        FCB     AM_INDEXED      ; 63
        FCB     AM_INDEXED      ; 64
        FCB     AM_INVALID      ; 65
        FCB     AM_INDEXED      ; 66
        FCB     AM_INDEXED      ; 67
        FCB     AM_INDEXED      ; 68
        FCB     AM_INDEXED      ; 69
        FCB     AM_INDEXED      ; 6A
        FCB     AM_INVALID      ; 6B
        FCB     AM_INDEXED      ; 6C
        FCB     AM_INDEXED      ; 6D
        FCB     AM_INDEXED      ; 6E
        FCB     AM_INDEXED      ; 6F

        FCB     AM_EXTENDED     ; 70
        FCB     AM_INVALID      ; 71
        FCB     AM_INVALID      ; 72
        FCB     AM_EXTENDED     ; 73
        FCB     AM_EXTENDED     ; 74
        FCB     AM_INVALID      ; 75
        FCB     AM_EXTENDED     ; 76
        FCB     AM_EXTENDED     ; 77
        FCB     AM_EXTENDED     ; 78
        FCB     AM_EXTENDED     ; 79
        FCB     AM_EXTENDED     ; 7A
        FCB     AM_INVALID      ; 7B
        FCB     AM_EXTENDED     ; 7C
        FCB     AM_EXTENDED     ; 7D
        FCB     AM_EXTENDED     ; 7E
        FCB     AM_EXTENDED     ; 7F

        FCB     AM_IMMEDIATE8   ; 80
        FCB     AM_IMMEDIATE8   ; 81
        FCB     AM_IMMEDIATE8   ; 82
        FCB     AM_IMMEDIATE16  ; 83
        FCB     AM_IMMEDIATE8   ; 84
        FCB     AM_IMMEDIATE8   ; 85
        FCB     AM_IMMEDIATE8   ; 86
        FCB     AM_INVALID      ; 87
        FCB     AM_IMMEDIATE8   ; 88
        FCB     AM_IMMEDIATE8   ; 89
        FCB     AM_IMMEDIATE8   ; 8A
        FCB     AM_IMMEDIATE8   ; 8B
        FCB     AM_IMMEDIATE16  ; 8C
        FCB     AM_RELATIVE8    ; 8D
        FCB     AM_IMMEDIATE16  ; 8E
        FCB     AM_INVALID      ; 8F

        FCB     AM_DIRECT       ; 90
        FCB     AM_DIRECT       ; 91
        FCB     AM_DIRECT       ; 92
        FCB     AM_DIRECT       ; 93
        FCB     AM_DIRECT       ; 94
        FCB     AM_DIRECT       ; 95
        FCB     AM_DIRECT       ; 96
        FCB     AM_DIRECT       ; 97
        FCB     AM_DIRECT       ; 98
        FCB     AM_DIRECT       ; 99
        FCB     AM_DIRECT       ; 9A
        FCB     AM_DIRECT       ; 9B
        FCB     AM_DIRECT       ; 9C
        FCB     AM_DIRECT       ; 9D
        FCB     AM_DIRECT       ; 9E
        FCB     AM_DIRECT       ; 9F

        FCB     AM_INDEXED      ; A0
        FCB     AM_INDEXED      ; A1
        FCB     AM_INDEXED      ; A2
        FCB     AM_INDEXED      ; A3
        FCB     AM_INDEXED      ; A4
        FCB     AM_INDEXED      ; A5
        FCB     AM_INDEXED      ; A6
        FCB     AM_INDEXED      ; A7
        FCB     AM_INDEXED      ; A8
        FCB     AM_INDEXED      ; A9
        FCB     AM_INDEXED      ; AA
        FCB     AM_INDEXED      ; AB
        FCB     AM_INDEXED      ; AC
        FCB     AM_INDEXED      ; AD
        FCB     AM_INDEXED      ; AE
        FCB     AM_INDEXED      ; AF

        FCB     AM_EXTENDED     ; B0
        FCB     AM_EXTENDED     ; B1
        FCB     AM_EXTENDED     ; B2
        FCB     AM_EXTENDED     ; B3
        FCB     AM_EXTENDED     ; B4
        FCB     AM_EXTENDED     ; B5
        FCB     AM_EXTENDED     ; B6
        FCB     AM_EXTENDED     ; B7
        FCB     AM_EXTENDED     ; B8
        FCB     AM_EXTENDED     ; B9
        FCB     AM_EXTENDED     ; BA
        FCB     AM_EXTENDED     ; BB
        FCB     AM_EXTENDED     ; BC
        FCB     AM_EXTENDED     ; BD
        FCB     AM_EXTENDED     ; BE
        FCB     AM_EXTENDED     ; BF

        FCB     AM_IMMEDIATE8   ; C0
        FCB     AM_IMMEDIATE8   ; C1
        FCB     AM_IMMEDIATE8   ; C2
        FCB     AM_IMMEDIATE16  ; C3
        FCB     AM_IMMEDIATE8   ; C4
        FCB     AM_IMMEDIATE8   ; C5
        FCB     AM_IMMEDIATE8   ; C6
        FCB     AM_INVALID      ; C7
        FCB     AM_IMMEDIATE8   ; C8
        FCB     AM_IMMEDIATE8   ; C9
        FCB     AM_IMMEDIATE8   ; CA
        FCB     AM_IMMEDIATE8   ; CB
        FCB     AM_IMMEDIATE16  ; CC
        FCB     AM_INHERENT     ; CD
        FCB     AM_IMMEDIATE16  ; CE
        FCB     AM_INVALID      ; CF

        FCB     AM_DIRECT       ; D0
        FCB     AM_DIRECT       ; D1
        FCB     AM_DIRECT       ; D2
        FCB     AM_DIRECT       ; D3
        FCB     AM_DIRECT       ; D4
        FCB     AM_DIRECT       ; D5
        FCB     AM_DIRECT       ; D6
        FCB     AM_DIRECT       ; D7
        FCB     AM_DIRECT       ; D8
        FCB     AM_DIRECT       ; D9
        FCB     AM_DIRECT       ; DA
        FCB     AM_DIRECT       ; DB
        FCB     AM_DIRECT       ; DC
        FCB     AM_DIRECT       ; DD
        FCB     AM_DIRECT       ; DE
        FCB     AM_DIRECT       ; DF

        FCB     AM_INDEXED      ; E0
        FCB     AM_INDEXED      ; E1
        FCB     AM_INDEXED      ; E2
        FCB     AM_INDEXED      ; E3
        FCB     AM_INDEXED      ; E4
        FCB     AM_INDEXED      ; E5
        FCB     AM_INDEXED      ; E6
        FCB     AM_INDEXED      ; E7
        FCB     AM_INDEXED      ; E8
        FCB     AM_INDEXED      ; E9
        FCB     AM_INDEXED      ; EA
        FCB     AM_INDEXED      ; EB
        FCB     AM_INDEXED      ; EC
        FCB     AM_INDEXED      ; ED
        FCB     AM_INDEXED      ; EE
        FCB     AM_INDEXED      ; EF

        FCB     AM_EXTENDED     ; F0
        FCB     AM_EXTENDED     ; F1
        FCB     AM_EXTENDED     ; F2
        FCB     AM_EXTENDED     ; F3
        FCB     AM_EXTENDED     ; F4
        FCB     AM_EXTENDED     ; F5
        FCB     AM_EXTENDED     ; F6
        FCB     AM_EXTENDED     ; F7
        FCB     AM_EXTENDED     ; F8
        FCB     AM_EXTENDED     ; F9
        FCB     AM_EXTENDED     ; FA
        FCB     AM_EXTENDED     ; FB
        FCB     AM_EXTENDED     ; FC
        FCB     AM_EXTENDED     ; FD
        FCB     AM_EXTENDED     ; FE
        FCB     AM_EXTENDED     ; FF

; Special table for page 2 instructions prefixed by $10.
; Format: opcode (less 10), instruction, addressing mode

PAGE2:
        FCB     $21, OP_LBRN,  AM_RELATIVE16
        FCB     $22, OP_LBHI,  AM_RELATIVE16
        FCB     $23, OP_LBLS,  AM_RELATIVE16
        FCB     $24, OP_LBCC,  AM_RELATIVE16
        FCB     $25, OP_LBCS,  AM_RELATIVE16
        FCB     $26, OP_LBNE,  AM_RELATIVE16
        FCB     $27, OP_LBEQ,  AM_RELATIVE16
        FCB     $28, OP_LBVC,  AM_RELATIVE16
        FCB     $29, OP_LBVS,  AM_RELATIVE16
        FCB     $2A, OP_LBPL,  AM_RELATIVE16
        FCB     $2B, OP_LBMI,  AM_RELATIVE16
        FCB     $2C, OP_LBGE,  AM_RELATIVE16
        FCB     $2D, OP_LBLT,  AM_RELATIVE16
        FCB     $2E, OP_LBGT,  AM_RELATIVE16
        FCB     $2F, OP_LBLE,  AM_RELATIVE16
        FCB     $3F, OP_SWI2,  AM_INHERENT
        FCB     $83, OP_CMPD,  AM_IMMEDIATE16
        FCB     $8C, OP_CMPY,  AM_IMMEDIATE16
        FCB     $8E, OP_LDY,   AM_IMMEDIATE16
        FCB     $93, OP_CMPD,  AM_DIRECT
        FCB     $9C, OP_CMPY,  AM_DIRECT
        FCB     $9E, OP_LDY,   AM_DIRECT
        FCB     $9D, OP_STY,   AM_DIRECT
        FCB     $A3, OP_CMPD,  AM_INDEXED
        FCB     $AC, OP_CMPY,  AM_INDEXED
        FCB     $AE, OP_LDY,   AM_INDEXED
        FCB     $AF, OP_STY,   AM_INDEXED
        FCB     $B3, OP_CMPD,  AM_EXTENDED
        FCB     $BC, OP_CMPY,  AM_EXTENDED
        FCB     $BE, OP_LDY,   AM_EXTENDED
        FCB     $BF, OP_STY,   AM_EXTENDED
        FCB     $CE, OP_LDS,   AM_IMMEDIATE16
        FCB     $DE, OP_LDS,   AM_DIRECT
        FCB     $DD, OP_STS,   AM_DIRECT
        FCB     $EE, OP_LDS,   AM_INDEXED
        FCB     $EF, OP_STS,   AM_INDEXED
        FCB     $FE, OP_LDS,   AM_EXTENDED
        FCB     $FF, OP_STS,   AM_EXTENDED
        FCB     0                             ; indicates end of table

; Special table for page 3 instructions prefixed by $11.
; Same format as table above.

PAGE3:
        FCB     $3F, OP_SWI3,  AM_INHERENT
        FCB     $83, OP_CMPU,  AM_IMMEDIATE16
        FCB     $8C, OP_CMPS,  AM_IMMEDIATE16
        FCB     $93, OP_CMPU,  AM_DIRECT
        FCB     $9C, OP_CMPS,  AM_DIRECT
        FCB     $A3, OP_CMPU,  AM_INDEXED
        FCB     $AC, OP_CMPS,  AM_INDEXED
        FCB     $B3, OP_CMPU,  AM_EXTENDED
        FCB     $BC, OP_CMPS,  AM_EXTENDED
        FCB     0                             ; indicates end of table

; Display strings. Should be terminated in EOT character.

MSG1:   FCC     "; INVALID"
        FCB     EOT

MSG2:   FCC     "PRESS <SPACE> TO CONTINUE, <Q> TO QUIT "
        FCB     EOT

MSG3:   FCC     "PCR"
        FCB     EOT

; ========================================================================
;
; 6809 Trace Utility
;
; Copyright (C) 2019 by Jeff Tranter <tranter@pobox.com>
;
; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
;   http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.

; Start address for RAM variables
        ORG     $6FE0

; Variables

SAVE_CC RMB     1               ; Saved register values
SAVE_A  RMB     1
SAVE_B  RMB     1
SAVE_D  equ     SAVE_A          ; Synonym for SAVE_A and SAVE_B
SAVE_DP RMB     1
SAVE_X  RMB     2
SAVE_Y  RMB     2
SAVE_U  RMB     2
SAVE_S  RMB     2
SAVE_PC RMB     2
OURS    RMB     2               ; This program's user stack pointer
OURU    RMB     2               ; This program's system stack pointer
BUFFER  RMB     10              ; Buffer holding traced instruction (up to 10 bytes)

        ORG     $F000

;------------------------------------------------------------------------
; Trace Command.
; Accepts a start address on the command line. Traces and disassembles
; an instruction. Pressing Q or q will go to monitor, any other key
; will trace another instruction.

TRACE   lbsr    CDNUM           ; Parse command line, return 16-bit number in D
        std     SAVE_PC         ; Store it
loop    bsr     step            ; Step one instruction
        leax    MSG2,pcr        ; Display message to press a key
        lbsr    PrintString
        lbsr    GetChar         ; Wait for a key press
        lbsr    PrintCR
        cmpa    #'Q'            ; Check for Q
        beq     quit            ; If so, quit
        cmpa    #'q'            ; Check for q
        beq     quit            ; If so, quit
        bra     loop            ; If not, continue
quit    jmp     [$fffe]         ; Go back to ASSIST09 via reset vector

;------------------------------------------------------------------------
; Step: Step one instruction
; Disassemble next instruction
; Call Trace
; Display register values
; Return

step    lbsr    Disassemble     ; Disassemble the instruction
        bsr     Trace           ; Trace/execute the instruction
        lbsr    DisplayRegs     ; Display register values
        rts

;------------------------------------------------------------------------
; Trace one instruction.
; Input: Address of instruction in SAVE_PC
; Returns: Updates saved register values.

Trace

; At this point we have set: OPCODE, OPTYPE, LENG, AM, PAGE23, POSTBYT
; Now check for special instructions that change flow of control or otherwise
; need special handling rather than being directly executed.

; Invalid op code?
        lda     OPTYPE          ; Get op code type
        cmpa    #OP_INV         ; Is it an invalid instruction?
        lbeq    update          ; If so, nothing to do (length is 1 byte)

; Check for PC relative indexed addressing modes that we don't
; currently handle. If so, display a warning but still trace the
; instruction.

        lda    AM               ; Get address mode
        cmpa   #AM_INDEXED      ; Indexed addressing
        bne    trysync          ; Branch if not
        lda    POSTBYT          ; Get the post byte

; It is a PCR mode if the post byte has the pattern 1xxx110x

        anda   #%10001110       ; Mask bits we want to check
        cmpa   #%10001100       ; Check for pattern
        bne    trysync          ; Branch if no match

; Display "Warning: instruction not supported, expect incorrect results."

        leax    TMSG12,PCR      ; Message string
        lbsr    PrintString     ; Display it
        lbsr    PrintCR

; SYNC instruction. Continue (emulate interrupt and then RTI
; happenning or mask interrupt and instruction continuing).

trysync lda     OPTYPE          ; Get op code type
        cmpa    #OP_SYNC        ; Is it a SYNC instruction?
        lbeq    update          ; If so, nothing to do (length is 1 byte)

; CWAI #$XX instruction. AND operand with CC. Set E flag in CC. Continue (emulate interrupt and then RTI happenning).

        lda     OPTYPE          ; Get op code type
        cmpa    #OP_CWAI        ; Is it a CWAI instruction?
        bne     tryswi
        ldx     SAVE_PC         ; Get address of instruction
        lda     1,x             ; Get operand
        ora     #%10000000      ; Set E bit
        ora     SAVE_CC         ; Or with CC
        sta     SAVE_CC         ; Save CC
        lbra    update          ; Done

; SWI instruction. Increment PC. Save all registers except S on hardware stack.
; Set I and F in CC. Set new PC to [FFFA,FFFB].

tryswi  cmpa    #OP_SWI
        bne     tryswi2
        ldx     SAVE_PC         ; Get address of instruction
        leax    1,x             ; Add one
        stx     SAVE_PC         ; Save new PC

; push CC, A, B, DP, X, Y, U, PC

        sts     OURS            ; Save our SP
        lds     SAVE_S          ; Use program's SP to push

        lda     SAVE_CC
        pshs    a
        ora     #%01010000      ; Set I and F bits
        sta     SAVE_CC
        lda     SAVE_A
        pshs    a
        lda     SAVE_B
        pshs    a
        lda     SAVE_DP
        pshs    a
        ldx     SAVE_X
        pshs    x
        ldx     SAVE_Y
        pshs    x
        ldx     SAVE_U
        pshs    x
        ldx     SAVE_PC
        pshs    x
        sts     SAVE_S          ; Save new value of SP
        lds     OURS            ; Restore our SP

        ldx     $FFFA           ; Get address of SWI vector
        stx     SAVE_PC         ; Set as new address

        lbra    don             ; Done

; SWI2 instruction. Increment PC. Save all registers except S on
; stack. Set new PC to [FFF4,FFF5].

tryswi2 cmpa    #OP_SWI2
        bne     tryswi3
        ldx     SAVE_PC         ; Get address of instruction
        leax    1,x             ; Add one
        stx     SAVE_PC         ; Save new PC

; push CC, A, B, DP, X, Y, U, PC

        sts     OURS            ; Save our SP
        lds     SAVE_S          ; Use program's SP to push

        lda     SAVE_CC
        pshs    a
        lda     SAVE_A
        pshs    a
        lda     SAVE_B
        pshs    a
        lda     SAVE_DP
        pshs    a
        ldx     SAVE_X
        pshs    x
        ldx     SAVE_Y
        pshs    x
        ldx     SAVE_U
        pshs    x
        ldx     SAVE_PC
        pshs    x
        sts     SAVE_S          ; Save new value of SP
        lds     OURS            ; Restore our SP

        ldx     $FFF4           ; Get address of SWI2 vector
        stx     SAVE_PC         ; Set as new address

        lbra    don             ; Done

; SWI3 instruction. Increment PC. Save all registers except S on
; stack. Set new PC to [FFF2,FFF3].

tryswi3 cmpa    #OP_SWI3
        bne     tryjmp
        ldx     SAVE_PC         ; Get address of instruction
        leax    1,x             ; Add one
        stx     SAVE_PC         ; Save new PC

; push CC, A, B, DP, X, Y, U, PC

        sts     OURS            ; Save our SP
        lds     SAVE_S          ; Use program's SP to push

        lda     SAVE_CC
        pshs    a
        lda     SAVE_A
        pshs    a
        lda     SAVE_B
        pshs    a
        lda     SAVE_DP
        pshs    a
        ldx     SAVE_X
        pshs    x
        ldx     SAVE_Y
        pshs    x
        ldx     SAVE_U
        pshs    x
        ldx     SAVE_PC
        pshs    x
        sts     SAVE_S          ; Save new value of SP
        lds     OURS            ; Restore our SP

        ldx     $FFF2           ; Get address of SWI3 vector
        stx     SAVE_PC         ; Set as new address

        lbra    don             ; Done

; JMP instruction. Next PC is operand effective address. Need to
; handle extended, direct, and indexed modes.

tryjmp  cmpa    #OP_JMP         ; Is it a JMP instruction?
        lbne    tryjsr          ; Branch if not.
        lda     OPCODE          ; Get the actual op code
        cmpa    #$7E            ; Extended, e.g. JMP $XXXX ?
        bne     jmp1
        ldx     SAVE_PC         ; Get address of instruction
        ldx     1,x             ; Get 16-bit operand (JMP destination)
        stx     SAVE_PC         ; Set as new instruction address
        lbra    don             ; Done

jmp1    cmpa    #$0E            ; Direct, e.g. JMP $XX ?
        bne     jmp2
        ldx     SAVE_PC         ; Get address of instruction
        ldb     1,x             ; Get 8-bit operand (JMP destination)
        lda     SAVE_DP         ; Get DP register
        std     SAVE_PC         ; Full address is DP (in A) + operand (in B)
        lbra    don             ; Done

; Must be indexed, e.g. JMP 1,X. Can't get effective address directly
; from instruction. Instead we use this trick: Run a LEAU instruction
; with the same indexed operand. Then examine value of X, which should
; be the new PC. Need to run it with the current index register values
; of X, Y, U, and S.
; TODO: Not handled: addressing modes that change U register like JMP ,U++.
; TODO: Not handled correctly: PCR modes like JMP 10,PCR

jmp2    ldx     SAVE_PC         ; Address of instruction
        ldy     #BUFFER         ; Address of buffer
        ldb     #$33            ; LEAU instruction
        clra                    ; Loop counter and index
        stb     a,y             ; Write LEAU instruction to buffer
        inca                    ; Move to next byte
copy1   ldb     a,x             ; Get instruction byte
        stb     a,y             ; Write to buffer
        inca                    ; Increment counter
        cmpa    LENG            ; Copied all bytes?
        bne     copy1

; Add a jump after the instruction to where we want to go after it is executed (ReturnFromJump).

        ldb     #$7E            ; JMP $XXXX instruction
        stb     a,y             ; Store in buffer
        inca                    ; Advance buffer
        ldx     #ReturnFromJump ; Destination address of JMP
        stx     a,y             ; Store in buffer

; Restore registers from saved values.

        sts     OURS            ; Save this program's stack pointers
        stu     OURU

        lda     SAVE_A
        ldb     SAVE_B
        ldx     SAVE_X
        ldy     SAVE_Y
        lds     SAVE_S
        ldu     SAVE_U

; Call instruction in buffer. It is followed by a JMP ReturnFromJump so we get back.

        jmp     BUFFER

ReturnFromJump

; Restore saved registers (except U and PC).

        stx     SAVE_X
        sty     SAVE_Y
        sts     SAVE_S

; Restore this program's stack pointers so RTS etc. will still work.

        lds     OURS
        ldu     OURU

; Value of X is new PC

        stx     SAVE_PC         ; Set as new instruction address
        lbra    don             ; Done

; JSR instruction. Next PC is operand effective address. Push return
; address on stack. Need to handle extended, direct, and indexed
; modes.

tryjsr  cmpa    #OP_JSR         ; Is it a JSR instruction?
        lbne    tryrts          ; Branch if not.
        lda     OPCODE          ; Get the actual op code
        cmpa    #$BD            ; Extended, e.g. JSR $XXXX ?
        bne     jsr1

        clra                    ; Set MSB to zero
        ldb     LENG            ; Get instruction length (byte)
        addd    SAVE_PC         ; 16-bit add

        sts     OURS            ; Save this program's stack pointer
        lds     SAVE_S          ; Get program's stack pointer
        pshs    d               ; Push return address
        sts     SAVE_S          ; Save program's new stack pointer
        lds     OURS            ; Restore our stack pointer

        ldx     SAVE_PC         ; Get address of instruction
        ldx     1,x             ; Get 16-bit operand (JSR destination)
        stx     SAVE_PC         ; Set as new instruction address
        lbra    don             ; Done

jsr1    cmpa    #$9D            ; Direct, e.g. JSR $XX ?
        bne     jsr2

        clra                    ; Set MSB to zero
        ldb     LENG            ; Get instruction length (byte)
        addd    SAVE_PC         ; 16-bit add

        sts     OURS            ; Save this program's stack pointer
        lds     SAVE_S          ; Get program's stack pointer
        pshs    d               ; Push return address
        sts     SAVE_S          ; Save program's new stack pointer
        lds     OURS            ; Restore our stack pointer

        ldx     SAVE_PC         ; Get address of instruction
        ldb     1,x             ; Get 8-bit operand (JSR destination)
        lda     SAVE_DP         ; Get DP register
        std     SAVE_PC         ; Full address is DP (in A) + operand (in B)
        lbra    don             ; Done

; Must be indexed, e.g. JSR 1,X. Use same LEAU trick as for JMP.
; TODO: Not handled: addressing modes that change U register like JSR ,U++.
; TODO: Not handled correctly: PCR modes like JSR 10,PCR

jsr2    clra                    ; Set MSB to zero
        ldb     LENG            ; Get instruction length (byte)
        addd    SAVE_PC         ; 16-bit add

        sts     OURS            ; Save this program's stack pointer
        lds     SAVE_S          ; Get program's stack pointer
        pshs    d               ; Push return address
        sts     SAVE_S          ; Save program's new stack pointer
        lds     OURS            ; Restore our stack pointer

        lbra    jmp2            ; Rest of code is shared with JMP routine

; RTS instruction. Pop PC from stack and set it to next address.

tryrts  cmpa    #OP_RTS         ; Is it a RTS instruction?
        bne     tryrti          ; Branch if not.
        sts     OURS            ; Save this program's stack pointer
        lds     SAVE_S          ; Get program's stack pointer
        puls    x               ; Pull return address
        sts     SAVE_S          ; Save program's new stack pointer
        lds     OURS            ; Restore our stack pointer
        stx     SAVE_PC         ; Set as new instruction address
        lbra    don             ; Done

; RTI instruction.
; If E flag is not set, pop PC and CC.
; If E flag is set, pop PC, U, Y, X, DP, B, A, and CC.
; Set next instruction to PC.

tryrti  cmpa    #OP_RTI         ; Is it a RTI instruction?
        bne     trybsr          ; Branch if not.
        sts     OURS            ; Save this program's stack pointer
        lds     SAVE_S          ; Get program's stack pointer
        puls    x               ; Pull PC
        stx     SAVE_PC         ; Set as new instruction address

        lda     SAVE_CC         ; Test CC
        bpl     notEntire       ; Branch if Entire bit (MSB is not set)
        puls    x               ; Pull U
        stx     SAVE_U
        puls    x               ; Pull Y
        stx     SAVE_Y
        puls    x               ; Pull X
        stx     SAVE_X
        puls    a               ; Pull DP
        sta     SAVE_DP
        puls    a               ; Pull B
        sta     SAVE_B
        puls    a               ; Pull A
        sta     SAVE_A
notEntire
        puls    a               ; Pull CC
        sta     SAVE_CC

        sts     SAVE_S          ; Save program's new stack pointer
        lds     OURS            ; Restore our stack pointer
        lbra    don             ; Done

; BSR instruction. Similar to JSR but EA is relative.

trybsr  cmpa    #OP_BSR         ; Is it a BSR instruction?
        bne     trylbsr         ; Branch if not.

; Push return address on stack.

        clra                    ; Set MSB to zero
        ldb     LENG            ; Get instruction length (byte)
        addd    SAVE_PC         ; 16-bit add

        sts     OURS            ; Save this program's stack pointer
        lds     SAVE_S          ; Get program's stack pointer
        pshs    d               ; Push return address
        sts     SAVE_S          ; Save program's new stack pointer
        lds     OURS            ; Restore our stack pointer

; Next PC is PC plus instruction length (2) plus offset operand.

        ldx     SAVE_PC         ; Get address of instruction
        clra                    ; Clear MSB
        ldb     1,x             ; Get 8-bit signed branch offset
        sex                     ; Sign extend to 16-bits
        addd    #2              ; Add instruction length (2)
        addd    SAVE_PC         ; Add to address
        std     SAVE_PC         ; Store new address value
        lbra    don             ; Done

; LBSR instruction. Similar to BSR above.

trylbsr cmpa    #OP_LBSR        ; Is it a LBSR instruction?
        bne     trybxx          ; Branch if not.

; Push return address on stack.

        clra                    ; Set MSB to zero
        ldb     LENG            ; Get instruction length (byte)
        addd    SAVE_PC         ; 16-bit add

        sts     OURS            ; Save this program's stack pointer
        lds     SAVE_S          ; Get program's stack pointer
        pshs    d               ; Push return address
        sts     SAVE_S          ; Save program's new stack pointer
        lds     OURS            ; Restore our stack pointer

; Next PC is PC plus instruction length (3) plus 16-bit offset operand.

        ldx     SAVE_PC         ; Get address of instruction
        ldd     1,x             ; Get 16-bit signed branch offset
        addd    #3              ; Add instruction length (3)
        addd    SAVE_PC         ; Add to address
        std     SAVE_PC         ; Store new address value
        lbra    don             ; Done

; Bxx instructions.
; These are executed but we change the destination of the branch so we
; catch whether they are taken or not.
; The code in the buffer will look like this:
;
;       JMP BUFFER
;       ...
; XXXX XX 03           Bxx $03 (Taken)         ; Instruction being traced
; XXXX 7E XX XX        JMP BranchNotTaken
; XXXX 7E XX XX Taken  JMP BranchTaken
;        ...
;
; If we come back via BranchNotTaken, next PC is instruction after the branch (PC plus 2).
; If we come back via BranchTaken, next PC is PC plus offset plus 2.
; Need to set CC to program's value before the branch is executed.

trybxx  lda     AM              ; Get addressing mode
        cmpa    #AM_RELATIVE8   ; Is it a relative branch?
        bne     trylbxx

        ldx     SAVE_PC         ; Address of instruction
        ldy     #BUFFER         ; Address of buffer
        lda     ,x              ; Get branch instruction
        sta     ,y              ; Store in buffer
        lda     #3              ; Branch offset (Taken)
        sta     1,y             ; Store in buffer
        lda     #$7E            ; JMP $XXXX instruction
        sta     2,y             ; Store in buffer
        ldx     #BranchNotTaken ; Address for branch
        stx     3,y             ; Store in buffer
        lda     #$7E            ; JMP $XXXX instruction
        sta     5,y             ; Store in buffer
        ldx     #BranchTaken    ; Address for branch
        stx     6,y             ; Store in buffer

; Restore CC from saved value.

        lda     SAVE_CC
        tfr     a,cc

; Call instruction in buffer. It is followed by a JMP so we get back.

        jmp     BUFFER

BranchTaken                     ; Next PC is PC plus offset plus 2.

        ldx     SAVE_PC         ; Get address of instruction
        clra                    ; Clear MSB
        ldb     1,x             ; Get 8-bit signed branch offset
        sex                     ; Sign extend to 16-bits
        addd    #2              ; Add instruction length (2)
        addd    SAVE_PC         ; Add to address
        std     SAVE_PC         ; Store new address value
        lbra    don             ; Done

BranchNotTaken                  ; Next PC is instruction after the branch (PC plus 2).

        ldd     SAVE_PC         ; Get address of instruction
        addd    #2              ; Add instruction length (2)
        std     SAVE_PC         ; Store new address value
        std     SAVE_PC
        lbra    don             ; Done

; LBxx instructions. Similar to Bxx above.

trylbxx cmpa    #AM_RELATIVE16  ; Is it a long relative branch?
        lbne    trytfr

; Note Long branch instructions are 4 bytes (prefixed by 10) except
; LBRA which is only 3 bytes.
; BUFFER in this case is:
; XXXX 16 00 03        LBRA $0003 (Taken)   ; Instruction being traced
; XXXX 7E XX XX        JMP  BranchNotTaken1
; XXX  7E XX XX Taken  JMP  BranchTaken1
;
; Or:
;
; XXXX 10 XX 00 03       LBxx $0003 (Taken) ; Instruction being traced
; XXXX 7E XX XX          JMP  BranchNotTaken1
; XXXX 7E XX XX   Taken  JMP  BranchTaken1

        lda     OPCODE          ; Get  opcode
        cmpa    #$16            ; Is it LBRA?
        bne     long            ; Branch if it is one of the other 4 byte instructions

        ldx     SAVE_PC         ; Address of instruction
        ldy     #BUFFER         ; Address of buffer
        lda     ,x              ; Get branch instruction
        sta     ,y              ; Store in buffer
        ldx     #3              ; Branch offset (Taken)
        stx     1,y             ; Store in buffer
        lda     #$7E            ; JMP $XXXX instruction
        sta     3,y             ; Store in buffer
        ldx     #BranchNotTaken1 ; Address for branch
        stx     4,y             ; Store in buffer
        lda     #$7E            ; JMP $XXXX instruction
        sta     6,y             ; Store in buffer
        ldx     #BranchTaken1   ; Address for branch
        stx     7,y             ; Store in buffer
        bra     branch

long    ldx     SAVE_PC         ; Address of instruction
        ldy     #BUFFER         ; Address of buffer
        ldx     ,x              ; Get two byte branch instruction
        stx     ,y              ; Store in buffer
        ldx     #3              ; Branch offset (Taken)
        stx     2,y             ; Store in buffer
        lda     #$7E            ; JMP $XXXX instruction
        sta     4,y             ; Store in buffer
        ldx     #BranchNotTaken1 ; Address for branch
        stx     5,y             ; Store in buffer
        lda     #$7E            ; JMP $XXXX instruction
        sta     7,y             ; Store in buffer
        ldx     #BranchTaken1   ; Address for branch
        stx     8,y             ; Store in buffer

; Restore CC from saved value.

branch  lda     SAVE_CC
        tfr     a,cc

; Call instruction in buffer. It is followed by a JMP so we get back.

        jmp     BUFFER

BranchTaken1                    ; Next PC is PC plus offset plus instruction length (3 or 4)

; Offset is 1,X for LBRA (2 byte instruction) and 2,X for others (3 byte instructions)

        ldx     SAVE_PC
        lda     OPCODE          ; Get  opcode
        cmpa    #$16            ; Is it LBRA?
        bne     long1           ; Branch if it is one of the other 4 byte instructions

        ldd     SAVE_PC         ; Get address
        addd    #3              ; Plus 3
        addd    1,x             ; Add 16-bit signed branch offset
        bra     upd

long1   ldd     SAVE_PC         ; Get address
        addd    #4              ; Plus 4
        addd    2,x             ; Add 16-bit signed branch offset

upd     std     SAVE_PC         ; Store new address value
        lbra    don             ; Done

BranchNotTaken1                 ; Next PC is instruction after the branch (PC plus 3 or 4).

        clra                    ; Clear MSB
        ldb     LENG            ; Get instruction length
        sex                     ; Sign extend to 16 bits
        addd    SAVE_PC         ; Add instruction address
        std     SAVE_PC         ; Store new address value
        lbra    don             ; Done

; Handle TFR instruction.
; Need to manually handle cases where source or destination is the PC
; since it won't run correctly from the buffer.

trytfr  lda     OPCODE          ; Get the actual op code
        cmpa    #$1F            ; Is it TFR R1,R2 ?
        lbne    tryexg          ; Branch if not
        ldx     SAVE_PC         ; Get address of instruction
        lda     1,x             ; Get operand byte
        anda    #%11110000      ; Mask source bits
        cmpa    #%01010000      ; Is source register PC?
        bne     checkdest       ; Branch if not

        ldy     SAVE_PC         ; Get current PC
        leay    2,y             ; Add instruction length

        lda     1,x             ; Get operand byte
        anda    #%00001111      ; Mask destination bits
        cmpa    #%00000000      ; D?
        beq     to_d
        cmpa    #%00000001      ; X?
        beq     to_x
        cmpa    #%00000010      ; Y?
        beq     to_y
        cmpa    #%00000011      ; U?
        beq     to_u
        cmpa    #%00000100      ; S?
        beq     to_s
        lbra    update          ; Anything else is invalid or PC to PC, so ignore

to_d    sty     SAVE_D          ; Write new PC to D
        lbra    update          ; Done
to_x    sty     SAVE_X          ; Write new PC to X
        lbra    update          ; Done
to_y    sty     SAVE_Y          ; Write new PC to Y
        lbra    update          ; Done
to_u    sty     SAVE_U          ; Write new PC to U
        lbra    update          ; Done
to_s    sty     SAVE_S          ; Write new PC to S
        lbra    update          ; Done

checkdest
        lda     1,x             ; Get operand byte
        anda    #%00001111      ; Mask destination bits
        cmpa    #%00000101      ; Is destination register PC?
        lbne    norml           ; Branch to normal instruction handling if not

        lda     1,x             ; Get operand byte
        anda    #%11110000      ; Mask source bits
        cmpa    #%00000000      ; D?
        beq     from_d
        cmpa    #%00010000      ; X?
        beq     from_x
        cmpa    #%00100000      ; Y?
        beq     from_y
        cmpa    #%00110000      ; U?
        beq     from_u
        cmpa    #%01000000      ; S?
        beq     from_s
        lbra    update          ; Anything else is invalid or PC to PC, so ignore

from_d  ldx     SAVE_D          ; Get D
        bra     write
from_x  ldx     SAVE_X          ; Get X
        bra     write
from_y  ldx     SAVE_Y          ; Get Y
        bra     write
from_u  ldx     SAVE_U          ; Get U
        bra     write
from_s  ldx     SAVE_S          ; Get S

write   stx     SAVE_PC
        lbra    don

; Handle EXG instruction.
; Need to manually handle cases where source or destination is the PC
; since it won't run correctly from the buffer.

tryexg  lda     OPCODE          ; Get the actual op code
        cmpa    #$1E            ; Is it EXG R1,R2 ?
        bne     trypul          ; Branch if not

        ldx     SAVE_PC         ; Get address of instruction
        lda     1,x             ; Get operand byte
        anda    #%11110000      ; Mask source bits
        cmpa    #%01010000      ; Is source register PC?
        bne     checkdest1      ; Branch if not
        lda     1,x             ; Get operand byte again
        anda    #%00001111      ; Mask destination bits
        bra     doexg           ; Do the exchange
checkdest1
        lda     1,x             ; Get operand byte
        anda    #%00001111      ; Mask destination bits
        cmpa    #%00000101      ; Is destination register PC?
        lbne    norml           ; Branch and execute normally if not
        lda     1,x             ; Get operand byte again
        anda    #%11110000      ; Mask source bits
        lsr                     ; Shift into low nybble
        lsr
        lsr
        lsr                     ; And fall thru to code below

doexg   ldy     SAVE_PC         ; Get current PC
        leay    2,y             ; Add instruction length

        cmpa    #%00000000      ; Exchange D?
        beq     exg_d
        cmpa    #%00000001      ; Exchange X?
        beq     exg_x
        cmpa    #%00000010      ; Exchange Y?
        beq     exg_y
        cmpa    #%00000011      ; Exchange U?
        beq     exg_u
        cmpa    #%00000100      ; Exchange S?
        beq     exg_s
        lbra    update          ; Anything else is invalid or PC to PC, so ignore

; At this point Y contains PC

exg_d                           ; Swap PC and D
        ldx     SAVE_D
        exg     x,y
        stx     SAVE_D
        bra     fin
exg_x   ldx     SAVE_X          ; Swap PC and X
        exg     x,y
        stx     SAVE_X
exg_y   ldx     SAVE_Y          ; Swap PC and Y
        exg     x,y
        stx     SAVE_Y
exg_u   ldx     SAVE_U          ; Swap PC and U
        exg     x,y
        stx     SAVE_U
exg_s   ldx     SAVE_S          ; Swap PC and S
        exg     x,y
        stx     SAVE_S
fin     sty     SAVE_PC
        lbra    don

; Handle PULS/PULU PC,r,r,r
; Could support it, but handling all the combinations of registers
; would take a lot of code. For now, just generate warning that
; instruction is unsupported and being ignored.

trypul  lda     OPCODE          ; Get the actual op code
        cmpa    #$35            ; Is it PULS ?
        beq     pull            ; If so, handle it.
        cmpa    #$37            ; Is it PULU ?
        bne     trypush         ; If no, skip

pull    ldx     SAVE_PC         ; Get address of instruction
        lda     1,x             ; Get operand byte
        anda    #%10000000      ; Mask PC bit
        cmpa    #%10000000      ; Is PC bit set?
        bne     norml           ; If not, handle nornmally

; Display "Warning: instruction not supported, skipping."

        leax    TMSG11,PCR      ; Message string
        lbsr    PrintString     ; Display it
        lbsr    PrintCR
        lbra    update          ; Don't execute it

; Handle PSHS/PSHU PC,r,r,r
; Could support it, but handling all the combinations of registers
; would take a lot of code. For now just generate warning that
; instruction is unsupported and results will be incorrect.
; Still execute the instruction.

trypush lda     OPCODE          ; Get the actual op code
        cmpa    #$34            ; Is it PSHS ?
        beq     push            ; If so, handle it.
        cmpa    #$36            ; Is it PSHU ?
        bne     norml           ; If no, skip

push    ldx     SAVE_PC         ; Get address of instruction
        lda     1,x             ; Get operand byte
        anda    #%10000000      ; Mask PC bit
        cmpa    #%10000000      ; Is PC bit set?
        bne     norml           ; If not, handle nornmally

; Display "Warning: instruction not supported, expect incorrect results."

        leax    TMSG12,PCR      ; Message string
        lbsr    PrintString     ; Display it
        lbsr    PrintCR
                                ; Fall through and execute it

; Otherwise:
; Not a special instruction. We execute it from the buffer.
; Copy instruction and operands to RAM buffer (based on LEN, can be 1 to 5 bytes)
; TODO: Handle PC relative instructions.


; Thoughts on handling PC relative modes:
; Original code:
; 2013  A6 8D 00 14                lda     tbl,pcr
; 202B  01 02 03 04 05     tbl     fcb     1,2,3,4,5
; Offset $0014 = $202B - ($2013 + 4)
;
; When running in buffer:
; 101C  A6 8D 10 0B                lda     tbl,pcr
; Offset should be $202B - ($101C + 4) = $100B
; Change offset by $100B - $0014 = $0FF7
; Original Address - Buffer Address = $2013 - $101C - $0FF7
; Should be able to fix up offset to run in buffer.
; Can't handle case where offset is 8 bits but won't reach buffer.


norml   ldx     SAVE_PC         ; Address of instruction
        ldy     #BUFFER         ; Address of buffer
        clra                    ; Loop counter and index
copy    ldb     a,x             ; Get instruction byte
        stb     a,y             ; Write to buffer
        inca                    ; Increment counter
        cmpa    LENG            ; Copied all bytes?
        bne     copy

; Add a jump after the instruction to where we want to go after it is executed (ReturnFromTrace).

        ldb     #$7E            ; JMP $XXXX instruction
        stb     a,y             ; Store in buffer
        inca                    ; Advance buffer
        ldx     #ReturnFromTrace ; Destination address of JMP
        stx     a,y             ; Store in buffer

; Restore registers from saved values.

        sts     OURS            ; Save this program's stack pointers
        stu     OURU

        ldb     SAVE_B
        ldx     SAVE_X
        ldy     SAVE_Y
        lds     SAVE_S
        ldu     SAVE_U
        lda     SAVE_DP
        tfr     a,dp
        lda     SAVE_CC
        pshu    a
        lda     SAVE_A
        pulu    cc              ; Has to be last so CC is left unchanged

; Call instruction in buffer. It is followed by a JMP ReturnFromTrace so we get back.

        jmp     BUFFER

ReturnFromTrace

; Restore saved registers (except PC).

        pshu    cc              ; Have to save before it changes
        sta     SAVE_A
        pulu    a
        sta     SAVE_CC
        tfr     dp,a
        sta     SAVE_DP
        stb     SAVE_B
        stx     SAVE_X
        sty     SAVE_Y
        sts     SAVE_S
        stu     SAVE_U

; Restore this program's stack pointers so RTS etc. will still work.

        lds     OURS
        ldu     OURU

; Set this program's DP register to zero just in case calling program changed it.

        clra
        tfr     a,dp

; Update new SAVE_PC value based on instruction address and length

update  clra                    ; Set MSB to zero
        ldb     LENG            ; Get length byte
        addd    SAVE_PC         ; 16-bit add
        std     SAVE_PC         ; Store new address value

; And return.

don     rts

;------------------------------------------------------------------------
; Display register values
; Uses values in SAVED_A etc.
; e.g.
; PC=FEED A=01 B=02 X=1234 Y=2345 S=2000 U=2000 DP=00 CC=10001101 (EFHINZVC)

DisplayRegs
        leax    TMSG1,PCR
        lbsr    PrintString
        ldx     SAVE_PC
        lbsr    PrintAddress

        leax    TMSG2,PCR
        lbsr    PrintString
        lda     SAVE_A
        lbsr    PrintByte

        leax    TMSG3,PCR
        lbsr    PrintString
        lda     SAVE_B
        lbsr    PrintByte

        leax    TMSG4,PCR
        lbsr    PrintString
        ldx     SAVE_X
        lbsr    PrintAddress

        leax    TMSG5,PCR
        lbsr    PrintString
        ldx     SAVE_Y
        lbsr    PrintAddress

        leax    TMSG6,PCR
        lbsr    PrintString
        ldx     SAVE_S
        lbsr    PrintAddress

        leax    TMSG7,PCR
        lbsr    PrintString
        ldx     SAVE_U
        lbsr    PrintAddress

        leax    TMSG8,PCR
        lbsr    PrintString
        lda     SAVE_DP
        lbsr    PrintByte

        leax    TMSG9,PCR       ; Show CC in binary
        lbsr    PrintString
        ldx     #8              ; Loop counter
        ldb     SAVE_CC         ; Get CC byte
ploop   aslb                    ; Shift bit into carry
        bcs     one             ; Branch if it is a one
        lda     #'0'            ; Print '0'
        bra     prn
one     lda     #'1'            ; Print '1'
prn     jsr     PrintChar
        leax    -1,x            ; Decrement loop counter
        bne     ploop           ; Branch if not done

        leax    TMSG10,PCR
        lbsr    PrintString
        lbsr    PrintCR
        rts

TMSG1   FCC     "PC="
        FCB     EOT
TMSG2   FCC     "A="
        FCB     EOT
TMSG3   FCC     "B="
        FCB     EOT
TMSG4   FCC     "X="
        FCB     EOT
TMSG5   FCC     "Y="
        FCB     EOT
TMSG6   FCC     "S="
        FCB     EOT
TMSG7   FCC     "U="
        FCB     EOT
TMSG8   FCC     "DP="
        FCB     EOT
TMSG9   FCC     "CC="
        FCB     EOT
TMSG10  FCC     " (EFHINZVC)"
        FCB     EOT
TMSG11  FCC     "Warning: instruction not supported, skipping."
        FCB     EOT
TMSG12  FCC     "Warning: instruction not supported, expect incorrect results."
        FCB     EOT

;------------------------------------------------------------------------
; Disassemble an instruction. Uses ASSIST09 ROM code.
; e.g.
; 1053 2001 86 01    lda     #$01

Disassemble
        ldx     SAVE_PC         ; Get address of instruction
        stx     ADRS            ; Pass it to the disassembler
        jsr     DISASM          ; Disassemble one instruction
        rts

;========================================================================

        ORG     $F800

*************************************
* COPYRIGHT (C) MOTOROLA, INC. 1979 *
*************************************

*************************************
* THIS IS THE BASE ASSIST09 ROM.
* IT MAY RUN WITH OR WITHOUT THE
* EXTENSION ROM WHICH
* WHEN PRESENT WILL BE AUTOMATICALLY
* INCORPORATED BY THE BLDVTR
* SUBROUTINE.
*************************************

*********************************************
* GLOBAL MODULE EQUATES
********************************************
ROMBEG  EQU     $F800           ; ROM START ASSEMBLY ADDRESS
RAMOFS  EQU     -$8800          ; ROM OFFSET TO RAM WORK PAGE
ROMSIZ  EQU     2048            ; ROM SIZE
ROM2OF  EQU     ROMBEG-ROMSIZ   ; START OF EXTENSION ROM
ACIA    EQU     $A000           ; DEFAULT ACIA ADDRESS
PTM     EQU     $0000           ; DEFAULT PTM ADDRESS
DFTCHP  EQU     0               ; DEFAULT CHARACTER PAD COUNT
DFTNLP  EQU     5               ; DEFAULT NEW LINE PAD COUNT
PROMPT  EQU     '>              ; PROMPT CHARACTER
NUMBKP  EQU     8               ; NUMBER OF BREAKPOINTS
*********************************************

*********************************************
* MISCELANEOUS EQUATES
*********************************************
EOT     EQU     $04             ; END OF TRANSMISSION
BELL    EQU     $07             ; BELL CHARACTER
LF      EQU     $0A             ; LINE FEED
*CR     EQU     $0D             ; CARRIAGE RETURN
DLE     EQU     $10             ; DATA LINK ESCAPE
CAN     EQU     $18             ; CANCEL (CTL-X)

* PTM ACCESS DEFINITIONS
PTMSTA  EQU     PTM+1           ; READ STATUS REGISTER
PTMC13  EQU     PTM             ; CONTROL REGISTERS 1 AND 3
PTMC2   EQU     PTM+1           ; CONTROL REGISTER 2
PTMTM1  EQU     PTM+2           ; LATCH 1
PTMTM2  EQU     PTM+4           ; LATCH 2
PTMTM3  EQU     PTM+6           ; LATCH 3
SKIP2   EQU     $8C             ; "CMPX #" OPCODE - SKIPS TWO BYTES

*******************************************
* ASSIST09 MONITOR SWI FUNCTIONS
* THE FOLLOWING EQUATES DEFINE FUNCTIONS PROVIDED
* BY THE ASSIST09 MONITOR VIA THE SWI INSTRUCTION.
******************************************
INCHNP  EQU     0               ; INPUT CHAR IN A REG - NO PARITY
OUTCH   EQU     1               ; OUTPUT CHAR FROM A REG
PDATA1  EQU     2               ; OUTPUT STRING
PDATA   EQU     3               ; OUTPUT CR/LF THEN STRING
OUT2HS  EQU     4               ; OUTPUT TWO HEX AND SPACE
OUT4HS  EQU     5               ; OUTPUT FOUR HEX AND SPACE
PCRLF   EQU     6               ; OUTPUT CR/LF
SPACEF  EQU     7               ; OUTPUT A SPACE
MONITR  EQU     8               ; ENTER ASSIST09 MONITOR
VCTRSW  EQU     9               ; VECTOR EXAMINE/SWITCH
BRKPT   EQU     10              ; USER PROGRAM BREAKPOINT
PAUSE   EQU     11              ; TASK PAUSE FUNCTION
NUMFUN  EQU     11              ; NUMBER OF AVAILABLE FUNCTIONS

* NEXT SUB-CODES FOR ACCESSING THE VECTOR TABLE.
* THEY ARE EQUIVALENT TO OFFSETS IN THE TABLE.
* RELATIVE POSITIONING MUST BE MAINTAINED

.AVTBL  EQU     0               ; ADDRESS OF VECTOR TABLE
.CMDL1  EQU     2               ; FIRST COMMAND LIST
.RSVD   EQU     4               ; RESERVED HARDWARE VECTOR
.SWI3   EQU     6               ; SWI3 ROUTINE
.SWI2   EQU     8               ; SWI2 ROUTINE
.FIRQ   EQU     10              ; FIRQ ROUTINE
.IRQ    EQU     12              ; IRQ ROUTINE
.SWI    EQU     14              ; SWI ROUTINE
.NMI    EQU     16              ; NMI ROUTINE
.RESET  EQU     18              ; RESET ROUTINE
.CION   EQU     20              ; CONSOLE ON
.CIDTA  EQU     22              ; CONSOLE INPUT DATA
.CIOFF  EQU     24              ; CONSOLE INPUT OFF
.COON   EQU     26              ; CONSOLE OUTPUT ON
.CODTA  EQU     28              ; CONSOLE OUTPUT DATA
.COOFF  EQU     30              ; CONSOLE OUTPUT OFF
.HSDTA  EQU     32              ; HIGH SPEED PRINTDATA
.BSON   EQU     34              ; PUNCH/LOAD ON
.BSDTA  EQU     36              ; PUNCH/LOAD DATA
.BSOFF  EQU     38              ; PUNCH/LOAD OFF
.PAUSE  EQU     40              ; TASK PAUSE ROUTINE
.EXPAN  EQU     42              ; EXPRESSION ANALYZER
.CMDL2  EQU     44              ; SECOND COMMAND LIST
.ACIA   EQU     46              ; ACIA ADDRESS
.PAD    EQU     48              ; CHARACTER PAD AND NEW LINE PAD
.ECHO   EQU     50              ; ECHO/LOAD AND NULL BKPT FLAG
.PTM    EQU     52              ; PTM ADDRESS
NUMVTR  EQU     52/2+1          ; NUMBER OF VECTORS
HIVTR   EQU     52              ; HIGHEST VECTOR OFFSET

******************************************
*           WORK AREA
* THIS WORK AREA IS ASSIGNED TO THE PAGE ADDRESSED BY
* -$1800,PCR FROM THE BASE ADDRESS OF THE ASSIST09
* ROM. THE DIRECT PAGE REGISTER DURING MOST ROUTINE
* OPERATIONS WILL POINT TO THIS WORK AREA. THE STACK
* INITIALLY STARTS UNDER THE RESERVED WORK AREAS AS
* DEFINED HEREIN.
******************************************
WORKPG  EQU     ROMBEG+RAMOFS   ; SETUP DIRECT PAGE ADDRESS
*       SETDP   =WORKPG         ; NOTIFY ASSEMBLER
        ORG     WORKPG+256      ; READY PAGE DEFINITIONS

* THE FOLLOWING THRU BKPTOP MUST RESIDE IN THIS ORDER
* FOR PROPER INITIALIZATION
        ORG     *-4
PAUSER  EQU     *               ; PAUSE ROUTINE
        ORG     *-1
SWIBFL  EQU     *               ; BYPASS SWI AS BREAKPOINT FLAG
        ORG     *-1
BKPTCT  EQU     *               ; BREAKPOINT COUNT
        ORG     *-2             ; SLEVEL EQU
SLEVEL  EQU     *               ; STACK TRACE LEVEL
        ORG     -NUMVTR*2+*
VECTAB  EQU     *               ; VECTOR TABLE
        ORG     -2*NUMBKP+*
BKPTBL  EQU     *               ; BREAKPOINT TABLE
        ORG     -2*NUMBKP+*
BKPTOP  EQU     *               ; BREAKPOINT OPCODE TABLE
        ORG     *-2
WINDOW  EQU     *               ; WINDOW
        ORG     *-2
ADDR    EQU     *               ; ADDRESS POINTER VALUE
        ORG     *-1
BASEPG  EQU     *               ; BASE PAGE VALUE
        ORG     *-2
NUMBER  EQU     *               ; BINARY BUILD AREA
        ORG     *-2
LASTOP  EQU     *               ; LAST OPCODE TRACED
        ORG     *-2
RSTACK  EQU     *               ; RESET STACK POINTER
        ORG     *-2
PSTACK  EQU     *               ; COMMAND RECOVERY STACK
        ORG     *-2
PCNTER  EQU     *               ; LAST PROGRAM COUNTER
        ORG     *-2
TRACEC  EQU     *               ; TRACE COUNT
        ORG     *-1
SWICNT  EQU     *               ; TRACE "SWI" NEST LEVEL COUNT
        ORG     *-1             ; (MISFLG MUST FOLLOW SWICNT)
MISFLG  EQU     *               ; LOAD CMD/THRU BREAKPOINT FLAG
        ORG     *-1
DELIM   EQU     *               ; EXPRESSION DELIMITER/WORK BYTE
        ORG     *-40
ROM2WK  EQU     *               ; EXTENSION ROM RESERVED AREA
        ORG     *-21
TSTACK  EQU     *               ; TEMPORARY STACK HOLD
STACK   EQU     *               ; START OF INITIAL STACK

******************************************
* DEFAULT THE ROM BEGINNING ADDRESS TO 'ROMBEG'
* ASSIST09 IS POSITION ADDRESS INDEPENDENT, HOWEVER
* WE ASSEMBLE ASSUMING CONTROL OF THE HARDWARE VECTORS.
* NOTE THAT THE WORK RAM PAGE MUST BE 'RAMOFS'
* FROM THE ROM BEGINNING ADDRESS.
********************************************
        ORG     ROMBEG          ; ROM ASSEMBLY/DEFAULT ADDRESS

*****************************************************
* BLDVTR - BUILD ASSIST09 VECTOR TABLE
* HARDWARE RESET CALLS THIS SUBROUTINE TO BUILD THE
* ASSIST09 VECTOR TABLE. THIS SUBROUTINE RESIDES AT
* THE FIRST BYTE OF THE ASSIST09 ROM, AND CAN BE
* CALLED VIA EXTERNAL CONTROL CODE FOR REMOTE
* ASSIST09 EXECUTION.
* INPUT: S->VALID STACK RAM
* OUTPUT: U->VECTOR TABLE ADDRESS
* DPR->ASSIST09 WORK AREA PAGE
* THE VECTOR TABLE AND DEFAULTS ARE INITIALIZED
* ALL REGISTERS VOLATILE
*************************************************
BLDVTR  LEAX    VECTAB,PCR      ; ADDRESS VECTOR TABLE
        TFR     X,D             ; OBTAIN BASE PAGE ADDRESS
        TFR     A,DP            ; SETUP DPR
        STA     <BASEPG         ; STORE FOR QUICK REFERENCE
        LEAU    ,X              ; RETURN TABLE TO CALLER
        LEAY    <INITVT,PCR     ; LOAD FROM ADDR
        STU     ,X++            ; INIT VECTOR TABLE ADDRESS
        LDB     #NUMVTR-5       ; NUMBER RELOCATABLE VECTORS
        PSHS    B               ; STORE INDEX ON STACK
BLD2    TFR     Y,D             ; PREPARE ADDRESS RESOLVE
        ADDD    ,Y++            ; TO ABSOLUTE ADDRESS
        STD     ,X++            ; INTO VECTOR TABLE
        DEC     ,S              ; COUNT DOWN
        BNE     BLD2            ; BRANCH IF MORE TO INSERT
        LDB     #INTVE-INTVS    ; STATIC VALUE INIT LENGTH
BLD3    LDA     ,Y+             ; LOAD NEXT BYTE
        STA     ,X+             ; STORE INTO POSITION
        DECB                    ; COUNT DOWN
        BNE     BLD3            ; LOOP UNTIL DONE
        LEAY    ROM2OF,PCR      ; TEST POSSIBLE EXTENSION ROM
        LDX     #$20FE          ; LOAD "BRA *" FLAG PATTERN
        CMPX    ,Y++            ; ? EXTENDED ROM HERE
        BNE     BLDRTN          ; BRANCH NOT OUR ROM TO RETURN
        JSR     ,Y              ; CALL EXTENDED ROM INITIALIZE
BLDRTN  PULS    PC,B            ; RETURN TO INITIALIZER

*****************************************************
*                RESET ENTRY POINT
* HARDWARE RESET ENTERS HERE IF ASSIST09 IS ENABLED
* TO RECEIVE THE MC6809 HARDWARE VECTORS. WE CALL
* THE BLDVTR SUBROUTINE TO INITIALIZE THE VECTOR
* TABLE, STACK, AND THEN FIREUP THE MONITOR VIA SWI
* CALL.
*******************************************************
RESET   LEAS    STACK,PCR       ; SETUP INITIAL STACK
        BSR     BLDVTR          ; BUILD VECTOR TABLE
RESET2  CLRA                    ; ISSUE STARTUP MESSAGE
        TFR     A,DP            ; DEFAULT TO PAGE ZERO
        SWI                     ; PERFORM MONITOR FIREUP
        FCB     MONITR          ; TO ENTER COMMAND PROCESSING
        BRA     RESET2          ; REENTER MONITOR IF 'CONTINUE'

******************************************************
*        INITVT - INITIAL VECTOR TABLE
* THIS TABLE IS RELOCATED TO RAM AND REPRESENTS THE
* INITIAL STATE OF THE VECTOR TABLE. ALL ADDRESSES
* ARE CONVERTED TO ABSOLUTE FORM. THIS TABLE STARTS
* WITH THE SECOND ENTRY, ENDS WITH STATIC CONSTANT
* INITIALIZATION DATA WHICH CARRIES BEYOND THE TABLE.
************************************************
INITVT  FDB     CMDTBL-*        ; DEFAULT FIRST COMMAND TABLE
        FDB     RSRVDR-*        ; DEFAULT UNDEFINED HARDWARE VECTOR
        FDB     SWI3R-*         ; DEFAULT SWI3
        FDB     SWI2R-*         ; DEFAULT SWI2
        FDB     FIRQR-*         ; DEFAULT FIRQ
        FDB     IRQR-*          ; DEFAULT IRQ ROUTINE
        FDB     SWIR-*          ; DEFAULT SWI ROUTINE
        FDB     NMIR-*          ; DEFAULT NMI ROUTINE
        FDB     RESET-*         ; RESTART VECTOR
        FDB     CION-*          ; DEFAULT CION
        FDB     CIDTA-*         ; DEFAULT CIDTA
        FDB     CIOFF-*         ; DEFAULT CIOFF
        FDB     COON-*          ; DEFAULT COON
        FDB     CODTA-*         ; DEFAULT CODTA
        FDB     COOFF-*         ; DEFAULT COOFF
        FDB     HSDTA-*         ; DEFAULT HSDTA
        FDB     BSON-*          ; DEFAULT BSON
        FDB     BSDTA-*         ; DEFAULT BSDTA
        FDB     BSOFF-*         ; DEFAULT BSOFF
        FDB     PAUSER-*        ; DEFAULT PAUSE ROUTINE
        FDB     EXP1-*          ; DEFAULT EXPRESSION ANALYZER
        FDB     CMDTB2-*        ; DEFAULT SECOND COMMAND TABLE
* CONSTANTS
INTVS   FDB     ACIA            ; DEFAULT ACIA
        FCB     DFTCHP,DFTNLP   ; DEFAULT NULL PADDS
        FDB     0               ; DEFAULT ECHO
        FDB     PTM             ; DEFAULT PTM
        FDB     0               ; INITIAL STACK TRACE LEVEL
        FCB     0               ; INITIAL BREAKPOINT COUNT
        FCB     0               ; SWI BREAKPOINT LEVEL
        FCB     $39             ; DEFAULT PAUSE ROUTINE (RTS)
INTVE   EQU     *
*B
***********************************************
*            ASSIST09 SWI HANDLER
* THE SWI HANDLER PROVIDES ALL INTERFACING NECESSARY
* FOR A USER PROGRAM. A FUNCTION BYTE IS ASSUMED TO
* FOLLOW THE SWI INSTRUCTION. IT IS BOUND CHECKED
* AND THE PROPER ROUTINE IS GIVEN CONTROL. THIS
* INVOCATION MAY ALSO BE A BREAKPOINT INTERRUPT.
* IF SO, THE BREAKPOINT HANDLER IS ENTERED.
* INPUT: MACHINE STATE DEFINED FOR SWI
* OUTPUT: VARIES ACCORDING TO FUNCTION CALLED. PC ON
* CALLERS STACK INCREMENTED BY ONE IF VALID CALL.
* VOLATILE REGISTERS: SEE FUNCTIONS CALLED
* STATE: RUNS DISABLED UNLESS FUNCTION CLEARS I FLAG.
************************************************
* SWI FUNCTION VECTOR TABLE
SWIVTB  FDB     ZINCH-SWIVTB    ; INCHNP
        FDB     ZOTCH1-SWIVTB   ; OUTCH
        FDB     ZPDTA1-SWIVTB   ; PDATA1
        FDB     ZPDATA-SWIVTB   ; PDATA
        FDB     ZOT2HS-SWIVTB   ; OUT2HS
        FDB     ZOT4HS-SWIVTB   ; OUT4HS
        FDB     ZPCRLF-SWIVTB   ; PCRLF
        FDB     ZSPACE-SWIVTB   ; SPACE
        FDB     ZMONTR-SWIVTB   ; MONITR
        FDB     ZVSWTH-SWIVTB   ; VCTRSW
        FDB     ZBKPNT-SWIVTB   ; BREAKPOINT
        FDB     ZPAUSE-SWIVTB   ; TASK PAUSE

SWIR    DEC     SWICNT,PCR      ; UP "SWI" LEVEL FOR TRACE
        LBSR    LDDP            ; SETUP PAGE AND VERIFY STACK
* CHECK FOR BREAKPOINT TRAP
        LDU     10,S            ; LOAD PROGRAM COUNTER
        LEAU    -1,U            ; BACK TO SWI ADDRESS
        TST     <SWIBFL         ; ? THIS "SWI" BREAKPOINT
        BNE     SWIDNE          ; BRANCH IF SO TO LET THROUGH
        LBSR    CBKLDR          ; OBTAIN BREAKPOINT POINTERS
        NEGB                    ; OBTAIN POSITIVE COUNT
SWILP   DECB                    ; COUNT DOWN
        BMI     SWIDNE          ; BRANCH WHEN DONE
        CMPU    ,Y++            ; ? WAS THIS A BREAKPOINT
        BNE     SWILP           ; BRANCH IF NOT
        STU     10,S            ; SET PROGRAM COUNTER BACK
        LBRA    ZBKPNT          ; GO DO BREAKPOINT
SWIDNE  CLR     <SWIBFL         ; CLEAR IN CASE SET
        PULU    D               ; OBTAIN FUNCTION BYTE, UP PC
        CMPB    #NUMFUN         ; ? TOO HIGH
        LBHI    ERROR           ; YES, DO BREAKPOINT
        STU     10,S            ; BUMP PROGRAM COUNTER PAST SWI
        ASLB                    ; FUNCTION CODE TIMES TWO
        LEAU    SWIVTB,PCR      ; OBTAIN VECTOR BRANCH ADDRESS
        LDD     B,U             ; LOAD OFFSET
        JMP     D,U             ; JUMP TO ROUTINE

**********************************************
* REGISTERS TO FUNCTION ROUTINES:
*  DP-> WORK AREA PAGE
*  D,Y,U=UNRELIABLE           X=AS CALLED FROM USER
*  S=AS FROM SWI INTERRUPT
*********************************************

**************************************************
*            [SWI FUNCTION 8]
*              MONITOR ENTRY
*  FIREUP THE ASSIST09 MONITOR.
*  THE STACK WITH ITS VALUES FOR THE DIRECT PAGE
*  REGISTER AND CONDITION CODE FLAGS ARE USED AS IS.
*   1) INITIALIZE CONSOLE I/O
*   2) OPTIONALLY PRINT SIGNON
*   3) INITIALIZE PTM FOR SINGLE STEPPING
*   4) ENTER COMMAND PROCESSOR
* INPUT: A=0 INIT CONSOLE AND PRINT STARTUP MESSAGE
*        A#0 OMIT CONSOLE INIT AND STARTUP MESSAGE
*************************************************

SIGNON  FCC     /ASSIST09/      ; SIGNON EYE-CATCHER
        FCB     EOT
ZMONTR  STS     <RSTACK         ; SAVE FOR BAD STACK RECOVERY
        TST     1,S             ; ? INIT CONSOLE AND SEND MSG
        BNE     ZMONT2          ; BRANCH IF NOT
        JSR     [VECTAB+.CION,PCR] ; READY CONSOLE INPUT
        JSR     [VECTAB+.COON,PCR] ; READY CONSOLE OUTPUT
        LEAX    SIGNON,PCR         ; READY SIGNON EYE-CATCHER
        SWI                     ; PERFORM
        FCB     PDATA           ; PRINT STRING
ZMONT2  LDX     <VECTAB+.PTM    ; LOAD PTM ADDRESS
        BEQ     CMD             ; BRANCH IF NOT TO USE A PTM
        CLR     PTMTM1-PTM,X    ; SET LATCH TO CLEAR RESET
        CLR     PTMTM1+1-PTM,X  ; AND SET GATE HIGH
        LDD     #$01A6          ; SETUP TIMER 1 MODE
        STA     PTMC2-PTM,X     ; SETUP FOR CONTROL REGISTER1
        STB     PTMC13-PTM,X    ; SET OUTPUT ENABLED/
* SINGLE SHOT/ DUAL 8 BIT/INTERNAL MODE/OPERATE
        CLR     PTMC2-PTM,X     ; SET CR2 BACK TO RESET FORM
* FALL INTO COMMAND PROCESSOR

***************************************************
*          COMMAND HANDLER
*  BREAKPOINTS ARE REMOVED AT THIS TIME.
*  PROMPT FOR A COMMAND, AND STORE ALL CHARACTERS
*  UNTIL A SEPARATOR ON THE STACK.
*  SEARCH FOR FIRST MATCHING COMMAND SUBSET,
*  CALL IT OR GIVE '?' RESPONSE.
*  DURING COMMAND SEARCH:
*      B=OFFSET TO NEXT ENTRY ON X
*      U=SAVED S
*      U-1=ENTRY SIZE+2
*      U-2=VALID NUMBER FLAG (>=0 VALID)/COMPARE CNT
*      U-3=CARRIAGE RETURN FLAG (0=CR HAS BEEN DONE)
*      U-4=START OF COMMAND STORE
*      S+0=END OF COMMAND STORE
***********************************************

CMD     SWI                     ; TO NEW LINE
        FCB     PCRLF           ; FUNCTION
* DISARM THE BREAKPOINTS
CMDNEP  LBSR    CBKLDR          ; OBTAIN BREAKPOINT POINTERS
        BPL     CMDNOL          ; BRANCH IF NOT ARMED OR NONE
        NEGB                    ; MAKE POSITIVE
        STB     <BKPTCT         ; FLAG AS DISARMED
CMDDDL  DECB                    ; ? FINISHED
        BMI     CMDNOL          ; BRANCH IF SO
        LDA     -NUMBKP*2,Y     ; LOAD OPCODE STORED
        STA     [,Y++]          ; STORE BACK OVER "SWI"
        BRA     CMDDDL          ; LOOP UNTIL DONE
CMDNOL  LDX     10,S            ; LOAD USERS PROGRAM COUNTER
        STX     <PCNTER         ; SAVE FOR EXPRESSION ANALYZER
        LDA     #PROMPT         ; LOAD PROMPT CHARACTER
        SWI                     ; SEND TO OUTPUT HANDLER
        FCB     OUTCH           ; FUNCTION
        LEAU    ,S              ; REMEMBER STACK RESTORE ADDRESS
        STU     <PSTACK         ; REMEMBER STACK FOR ERROR USE
        CLRA                    ; PREPARE ZERO
        CLRB                    ; PREPARE ZERO
        STD     <NUMBER         ; CLEAR NUMBER BUILD AREA
        STD     <MISFLG         ; CLEAR MISCEL. AND SWICNT FLAGS
        STD     <TRACEC         ; CLEAR TRACE COUNT
        LDB     #2              ; SET D TO TWO
        PSHS    D,CC            ; PLACE DEFAULTS ONTO STACK
* CHECK FOR "QUICK" COMMANDS.
        LBSR    READC           ; OBTAIN FIRST CHARACTER
        LEAX    CDOT+2,PCR      ; PRESET FOR SINGLE TRACE
        CMPA    #'.             ; ? QUICK TRACE
        BEQ     CMDXQT          ; BRANCH EQUAL FOR TRACE ONE
        LEAX    CMPADP+2,PCR    ; READY MEMORY ENTRY POINT
        CMPA    #'/             ; ? OPEN LAST USED MEMORY
        BEQ     CMDXQT          ; BRANCH TO DO IT IF SO
* PROCESS NEXT CHARACTER
CMD2    CMPA    #'              ; ? BLANK OR DELIMITER
        BLS    CMDGOT           ; BRANCH YES, WE HAVE IT
        PSHS   A                ; BUILD ONTO STACK
        INC    -1,U             ; COUNT THIS CHARACTER
        CMPA   #'/              ; ? MEMORY COMMAND
        BEQ    CMDMEM           ; BRANCH IF SO
        LBSR   BLDHXC           ; TREAT AS HEX VALUE
        BEQ    CMD3             ; BRANCH IF STILL VALID NUMBER
        DEC    -2,U             ; FLAG AS INVALID NUMBER
CMD3    LBSR   READC            ; OBTAIN NEXT CHARACTER
        BRA    CMD2             ; TEST NEXT CHARACTER
* GOT COMMAND, NOW SEARCH TABLES
CMDGOT  SUBA   #CR              ; SET ZERO IF CARRIAGE RETURN
        STA    -3,U             ; SETUP FLAG
        LDX    <VECTAB+.CMDL1   ; START WITH FIRST CMD LIST
CMDSCH  LDB    ,X+              ; LOAD ENTRY LENGTH
        BPL    CMDSME           ; BRANCH IF NOT LIST END
        LDX    <VECTAB+.CMDL2   ; NOW TO SECOND CMD LITS
        INCB                    ; ? TO CONTINUE TO DEFAULT LIST
        BEQ     CMDSCH          ; BRANCH IF SO
CMDBAD  LDS     <PSTACK         ; RESTORE STACK
        LEAX    ERRMSG,PCR      ; POINT TO ERROR STRING
        SWI                     ; SEND OUT
        FCB     PDATA1          ; TO CONSOLE
        BRA     CMD             ; AND TRY AGAIN
* SEARCH NEXT ENTRY
CMDSME  DECB                    ; TAKE ACCOUNT OF LENGTH BYTE
        CMPB    -1,U            ; ? ENTERED LONGER THAN ENTRY
        BHS     CMDSIZ          ; BRANCH IF NOT TOO LONG
CMDFLS  ABX                     ; SKIP TO NEXT ENTRY
        BRA     CMDSCH          ; AND TRY NEXT
CMDSIZ  LEAY    -3,U            ; PREPARE TO COMPARE
        LDA     -1,U            ; LOAD SIZE+2
        SUBA    #2              ; TO ACTUAL SIZE ENTERED
        STA     -2,U            ; SAVE SIZE FOR COUNTDOWN
CMDCMP  DECB                    ; DOWN ONE BYTE
        LDA     ,X+             ; NEXT COMMAND CHARACTER
        CMPA    ,-Y             ; ? SAME AS THAT ENTERED
        BNE     CMDFLS          ; BRANCH TO FLUSH IF NOT
        DEC     -2,U            ; COUNT DOWN LENGTH OF ENTRY
        BNE     CMDCMP          ; BRANCH IF MORE TO TEST
        ABX                     ; TO NEXT ENTRY
        LDD     -2,X            ; LOAD OFFSET
        LEAX    D,X             ; COMPUTE ROUTINE ADDRESS+2
CMDXQT  TST     -3,U            ; SET CC FOR CARRIAGE RETURN TEST
        LEAS    ,U              ; DELETE STACK WORK AREA
        JSR     -2,X            ; CALL COMMAND
        LBRA    CMDNOL          ; GO GET NEXT COMMAND
CMDMEM  TST     -2,U            ; ? VALID HEX NUMBER ENTERED
        BMI     CMDBAD          ; BRANCH ERROR IF NOT
        LEAX    <CMEMN-CMPADP,X ; TO DIFFERENT ENTRY
        LDD     <NUMBER         ; LOAD NUMBER ENTERED
        BRA     CMDXQT          ; AND ENTER MEMORY COMMAND

** COMMANDS ARE ENTERED AS A SUBROUTINE WITH:
**    DPR->ASSIST09 DIRECT PAGE WORK AREA
**    Z=1 CARRIAGE RETURN ENTERED
**    Z=0 NON CARRIAGE RETURN DELIMITER
**    S=NORMAL RETURN ADDRESS
** THE LABEL "CMDBAD" MAY BE ENTERED TO ISSUE AN
** AN ERROR FLAG (*).
**************************************************
*       ASSIST09 COMMAND TABLES
* THESE ARE THE DEFAULT COMMAND TABLES. EXTERNAL
* TABLES OF THE SAME FORMAT MAY EXTEND/REPLACE
* THESE BY USING THE VECTOR SWAP FUNCTION.
*
* ENTRY FORMAT:
*    +0...TOTAL SIZE OF ENTRY (INCLUDING THIS BYTE)
*    +1...COMMAND STRING
*    +N...TWO BYTE OFFSET TO COMMAND (ENTRYADDR-*)
*
* THE TABLES TERMINATE WITH A ONE BYTE -1 OR -2.
* THE -1 CONTINUES THE COMMAND SEARCH WITH THE
*        SECOND COMMAND TABLE.
* THE -2 TERMINATES COMMAND SEARCHES.
*****************************************************

* THIS IS THE DEFAULT LIST FOR THE SECOND COMMAND
* LIST ENTRY.

CMDTB2  FCB     4               ; TABLE ENTRY LENGTH
        FCC     'U'             ; 'UNASSEMBLE' COMMAND
        FDB     CUNAS-*         ; POINTER TO COMMAND (RELATIVE TO HERE)
        FCB     4               ; TABLE ENTRY LENGTH
        FCC     'T'             ; 'TRACE' COMMAND
        FDB     TRACE-*         ; POINTER TO COMMAND (RELATIVE TO HERE)
        FCB     -2              ; -2 INDICATES END OF TABLE

* THIS IS THE DEFAULT LIST FOR THE FIRST COMMAND
* LIST ENTRY.

CMDTBL  EQU     *               ; MONITOR COMMAND TABLE
        FCB     4
        FCC     /B/             ; 'BREAKPOINT' COMMAND
        FDB     CBKPT-*
        FCB     4
        FCC     /C/             ; 'CALL' COMMAND
        FDB     CCALL-*
        FCB     4
        FCC     /D/             ; 'DISPLAY' COMMAND
        FDB     CDISP-*
        FCB     4
        FCC     /E/             ; 'ENCODE' COMMAND
        FDB     CENCDE-*
        FCB     4
        FCC     /G/             ; 'GO' COMMAND
        FDB     CGO-*
        FCB     4
        FCC     /L/             ; 'LOAD' COMMAND
        FDB     CLOAD-*
        FCB     4
        FCC     /M/             ; 'MEMORY' COMMAND
        FDB     CMEM-*
        FCB     4
        FCC     /N/             ; 'NULLS' COMMAND
        FDB     CNULLS-*
        FCB     4
        FCC     /O/             ; 'OFFSET' COMMAND
        FDB     COFFS-*
        FCB     4
        FCC     /P/             ; 'PUNCH' COMMAND
        FDB     CPUNCH-*
        FCB     4
        FCC     /R/             ; 'REGISTERS' COMMAND
        FDB     CREG-*
;       FCB     4
;       FCC     /S/             ; 'STLEVEL' COMMAND - NOT SUPPORTED IN THIS VERSION
;       FDB     CSTLEV-*
;       FCB     4
;       FCC     /T/             ; 'TRACE' COMMAND - NOT SUPPORTED IN THIS VERSION
;       FDB     CTRACE-*
        FCB     4
        FCC     /V/             ; 'VERIFY' COMMAND
        FDB     CVER-*
        FCB     4
        FCC     /W/             ; 'WINDOW' COMMAND
        FDB     CWINDO-*
        FCB     -1              ; END, CONTINUE WITH THE SECOND

*************************************************
*             [SWI FUNCTIONS 4 AND 5]
*      4 - OUT2HS - DECODE BYTE TO HEX AND ADD SPACE
*      5 - OUT4HS - DECODE WORD TO HEX AND ADD SPACE
* INPUT: X->BYTE OR WORD TO DECODE
* OUTPUT: CHARACTERS SENT TO OUTPUT HANDLER
*         X->NEXT BYTE OR WORD
*************************************************
ZOUT2H  LDA     ,X+             ; LOAD NEXT BYTE
        PSHS    D               ; SAVE - DO NOT REREAD
        LDB     #16             ; SHIFT BY 4 BITS
        MUL                     ; WITH MULTIPLY
        BSR     ZOUTHX          ; SEND OUT AS HEX
        PULS    D               ; RESTORE BYTES
        ANDA    #$0F            ; ISOLATE RIGHT HEX
ZOUTHX  ADDA    #$90            ; PREPARE A-F ADJUST
        DAA                     ; ADJUST
        ADCA    #$40            ; PREPARE CHARACTER BITS
        DAA                     ; ADJUST
SEND    JMP     [VECTAB+.CODTA,PCR] ; SEND TO OUT HANDLER

ZOT4HS  BSR     ZOUT2H          ; CONVERT FIRST BYTE
ZOT2HS  BSR     ZOUT2H          ; CONVERT BYTE TO HEX
        STX     4,S             ; UPDATE USERS X REGISTER
* FALL INTO SPACE ROUTINE

*************************************************
*            [SWI FUNCTION 7]
*         SPACE - SEND BLANK TO OUTPUT HANDLER
* INPUT: NONE
* OUTPUT: BLANK SEND TO CONSOLE HANDLER
*************************************************
ZSPACE  LDA     #'              ; LOAD BLANK
        BRA     ZOTCH2          ; SEND AND RETURN

***********************************************
*             [SWI FUNCTION 9]
*          SWAP VECTOR TABLE ENTRY
* INPUT: A=VECTOR TABLE CODE (OFFSET)
* X=0 OR REPLACEMENT VALUE
* OUTPUT: X=PREVIOUS VALUE
***********************************************
ZVSWTH  LDA     1,S             ; LOAD REQUESTERS A
        CMPA    #HIVTR          ; ? SUB-CODE TOO HIGH
        BHI     ZOTCH3          ; IGNORE CALL IF SO
        LDY     <VECTAB+.AVTBL  ; LOAD VECTOR TABLE ADDRESS
        LDU     A,Y             ; U=OLD ENTRY
        STU     4,S             ; RETURN OLD VALUE TO CALLERS X
        STX     -2,S            ; ? X=0
        BEQ     ZOTCH3          ; YES, DO NOT CHANGE ENTRY
        STX     A,Y             ; REPLACE ENTRY
        BRA     ZOTCH3          ; RETURN FROM SWI
*D

************************************************
*               [SWI FUNCTION 0]
*  INCHNP - OBTAIN INPUT CHAR IN A (NO PARITY)
* NULLS AND RUBOUTS ARE IGNORED.
* AUTOMATIC LINE FEED IS SENT UPON RECEIVING A
* CARRIAGE RETURN.
* UNLESS WE ARE LOADING FROM TAPE.
************************************************
ZINCHP  BSR     XQPAUS          ; RELEASE PROCESSOR
ZINCH   BSR     XQCIDT          ; CALL INPUT DATA APPENDAGE
        BCC     ZINCHP          ; LOOP IF NONE AVAILABLE
        TSTA                    ; ? TEST FOR NULL
        BEQ     ZINCH           ; IGNORE NULL
        CMPA    #$7F            ; ? RUBOUT
        BEQ     ZINCH           ; BRANCH YES TO IGNORE
        STA     1,S             ; STORE INTO CALLERS A
        TST     <MISFLG         ; ? LOAD IN PROGRESS
        BNE     ZOTCH3          ; BRANCH IF SO TO NOT ECHO
        CMPA    #CR             ; ? CARRIAGE RETURN
        BNE     ZIN2            ; NO, TEST ECHO BYTE
        LDA     #LF             ; LOAD LINE FEED
        BSR     SEND            ; ALWAYS ECHO LINE FEED
ZIN2    TST     <VECTAB+.ECHO   ; ? ECHO DESIRED
        BNE     ZOTCH3          ; NO, RETURN
* FALL THROUGH TO OUTCH
************************************************
*            [SWI FUNCTION 1]
*        OUTCH - OUTPUT CHARACTER FROM A
* INPUT: NONE
* OUTPUT: IF LINEFEED IS THE OUTPUT CHARACTER THEN
* C=0 NO CTL-X RECEIVED, C=1 CTL-X RECEIVED
************************************************
ZOTCH1  LDA     1,S             ; LOAD CHARACTER TO SEND
        LEAX    <ZPCRLS,PCR     ; DEFAULT FOR LINE FEED
        CMPA    #LF             ; ? LINE FEED
        BEQ     ZPDTLP          ; BRANCH TO CHECK PAUSE IF SO
ZOTCH2  BSR     SEND            ; SEND TO OUTPUT ROUTINE
ZOTCH3  INC     <SWICNT         ; BUMP UP "SWI" TRACE NEST LEVEL
        RTI                     ; RETURN FROM "SWI" FUNCTION

**************************************************
* [SWI FUNCTION 6]
* PCRLF - SEND CR/LF TO CONSOLE HANDLER
* INPUT: NONE
* OUTPUT: CR AND LF SENT TO HANDLER
* C=0 NO CTL-X, C=1 CTL-X RECEIVED
**************************************************
ZPCRLS  FCB     EOT             ; NULL STRING
ZPCRLF LEAX     ZPCRLS,PCR      ; READY CR,LF STRING
* FALL INTO CR/LF CODE

**************************************************
* [SWI FUNCTION 3]
* PDATA - OUTPUT CR/LF AND STRING
* INPUT: X->STRING
* OUTPUT: CR/LF AND STRING SENT TO OUTPUT CONSOLE
* HANDLER.
* C=0 NO CTL-X, C=1 CTL-X RECEIVED
* NOTE: LINE FEED MUST FOLLOW CARRIAGE RETURN FOR
* PROPER PUNCH DATA.
**************************************************

ZPDATA  LDA     #CR             ; LOAD CARRIAGE RETURN
        BSR     SEND            ; SEND IT
        LDA     #LF             ; LOAD LINE FEED
* FALL INTO PDATA1

*************************************************
* [SWI FUNCTION 2]
* PDATA1 - OUTPUT STRING TILL EOT ($04)
* THIS ROUTINE PAUSES IF AN INPUT BYTE BECOMES
* AVAILABLE DURING OUTPUT TRANSMISSION UNTIL A
* SECOND IS RECEIVED.
* INPUT: X->STRING
* OUTPUT: STRING SENT TO OUTPUT CONSOLE DRIVER
* C=0 NO CTL-X, C=1 CTL-X RECEIVED
*************************************************

ZPDTLP  BSR     SEND            ; SEND CHARACTER TO DRIVER
ZPDTA1  LDA     ,X+             ; LOAD NEXT CHARACTER
        CMPA    #EOT            ; ? EOT
        BNE     ZPDTLP          ; LOOP IF NOT
* FALL INTO PAUSE CHECK FUNCTION

********************************************
* [SWI FUNCTION 12]
* PAUSE - RETURN TO TASK DISPATCHING AND CHECK
* FOR FREEZE CONDITION OR CTL-X BREAK
* THIS FUNCTION ENTERS THE TASK PAUSE HANDLER SO
* OPTIONALLY OTHER 6809 PROCESSES MAY GAIN CONTROL.
* UPON RETURN, CHECK FOR A 'FREEZE' CONDITION
* WITH A RESULTING WAIT LOOP, OR CONDITION CODE
* RETURN IF A CONTROL-X IS ENTERED FROM THE INPUT
* HANDLER.
* OUTPUT: C=1 IF CTL-X HAS ENTERED, C=0 OTHERWISE
******************************************

ZPAUSE  BSR     XQPAUS          ; RELEASE CONTROL AT EVERY LINE
        BSR     CHKABT          ; CHECK FOR FREEZE OR ABORT
        TFR     CC,B            ; PREPARE TO REPLACE CC
        STB     ,S              ; OVERLAY OLD ONE ON STACK
        BRA     ZOTCH3          ; RETURN FROM "SWI"

* CHKABT - SCAN FOR INPUT PAUSE/ABORT DURING OUTPUT
* OUTPUT: C=0 OK, C=1 ABORT (CTL-X ISSUED)
* VOLATILE: U,X,D
CHKABT  BSR     XQCIDT          ; ATTEMPT INPUT
        BCC     CHKRTN          ; BRANCH NO TO RETURN
        CMPA    #CAN            ; ? CTL-X FOR ABORT
        BNE     CHKWT           ; BRANCH NO TO PAUSE
CHKSEC  COMB                    ; SET CARRY
CHKRTN  RTS                     ; RETURN TO CALLER WITH CC SET
CHKWT   BSR     XQPAUS          ; PAUSE FOR A MOMENT
        BSR     XQCIDT          ; ? KEY FOR START
        BCC     CHKWT           ; LOOP UNTIL RECEIVED
        CMPA    #CAN            ; ? ABORT SIGNALED FROM WAIT
        BEQ     CHKSEC          ; BRANCH YES
        CLRA                    ; SET C=0 FOR NO ABORT
        RTS                     ; AND RETURN

* SAVE MEMORY WITH JUMPS
XQPAUS  JMP   [VECTAB+.PAUSE,PCR] ; TO PAUSE ROUTINE
XQCIDT  JSR   [VECTAB+.CIDTA,PCR] ; TO INPUT ROUTINE
        ANDA  #$7F              ; STRIP PARITY
        RTS                     ; RETURN TO CALLER

********************************************
* NMI DEFAULT INTERRUPT HANDLER
* THE NMI HANDLER IS USED FOR TRACING INSTRUCTIONS.
* TRACE PRINTOUTS OCCUR ONLY AS LONG AS THE STACK
* TRACE LEVEL IS NOT BREACHED BY FALLING BELOW IT.
* TRACING CONTINUES UNTIL THE COUNT TURNS ZERO OR
* A CTL-X IS ENTERED FROM THE INPUT CONSOLE DEVICE.
*********************************************

MSHOWP  FCB     'O,'P,'-,EOT    ; OPCODE PREP

NMIR    BSR     LDDP            ; LOAD PAGE AND VERIFY STACK
        TST     <MISFLG         ; ? THRU A BREAKPOINT
        BNE     NMICON          ; BRANCH IF SO TO CONTINUE
        TST     <SWICNT         ; ? INHIBIT "SWI" DURING TRACE
        BMI     NMITRC          ; BRANCH YES
        LEAX    12,S            ; OBTAIN USERS STACK POINTER
        CMPX    <SLEVEL         ; ? TO TRACE HERE
        BLO     NMITRC          ; BRANCH IF TOO LOW TO DISPLAY
        LEAX    MSHOWP,PCR      ; LOAD OP PREP
        SWI                     ; SEND TO CONSOLE
        FCB     PDATA1          ; FUNCTION
        ROL     <DELIM          ; SAVE CARRY BIT
        LEAX    LASTOP,PCR      ; POINT TO LAST OP
        SWI                     ; SEND OUT AS HEX
        FCB     OUT4HS          ; FUNCTION
        BSR     REGPRS          ; FOLLOW MEMORY WITH REGISTERS
        BCS     ZBKCMD          ; BRANCH IF "CANCEL"
        ROR     <DELIM          ; RESTORE CARRY BIT
        BCS     ZBKCMD          ; BRANCH IF "CANCEL"
        LDX     <TRACEC         ; LOAD TRACE COUNT
        BEQ     ZBKCMD          ; IF ZERO TO COMMAND HANDLER
        LEAX    -1,X            ; MINUS ONE
        STX     <TRACEC         ; REFRESH
        BEQ     ZBKCMD          ; STOP TRACE WHEN ZERO
        BSR     CHKABT          ; ? ABORT THE TRACE
        BCS     ZBKCMD          ; BRANCH YES TO COMMAND HANDLER
NMITRC  LBRA    CTRCE3          ; NO, TRACE ANOTHER INSTRUCTION

REGPRS  LBSR    REGPRT          ; PRINT REGISTERS AS FROM COMMAND
        RTS                     ; RETURN TO CALLER

* JUST EXECUTED THRU A BRKPNT. NOW CONTINUE NORMALLY

NMICON  CLR     <MISFLG        ; CLEAR THRU FLAG
        LBSR    ARMBK2         ; ARM BREAKPOINTS
RTI     RTI                    ; AND CONTINUE USERS PROGRAM

* LDDP - SETUP DIRECT PAGE REGISTER, VERIFY STACK.
* AN INVALID STACK CAUSES A RETURN TO THE COMMAND
* HANDLER.
* INPUT: FULLY STACKED REGISTERS FROM AN INTERRUPT
* OUTPUT: DPR LOADED TO WORK PAGE

ERRMSG  FCB     '?,BELL,$20,EOT ; ERROR RESPONSE

LDDP    LDB     BASEPG,PCR      ; LOAD DIRECT PAGE HIGH BYTE
        TFR     B,DP            ; SETUP DIRECT PAGE REGISTER
        CMPA    3,S             ; ? IS STACK VALID
        BEQ     RTS             ; YES, RETURN
        LDS     <RSTACK         ; RESET TO INITIAL STACK POINTER
ERROR   LEAX    ERRMSG,PCR      ; LOAD ERROR REPORT
        SWI                     ; SEND OUT BEFORE REGISTERS
        FCB     PDATA           ; ON NEXT LINE
* FALL INTO BREAKPOINT HANDLER

**********************************************
* [SWI FUNCTION 10]
* BREAKPOINT PROGRAM FUNCTION
* PRINT REGISTERS AND GO TO COMMAND HANLER
***********************************************

ZBKPNT  BSR     REGPRS          ; PRINT OUT REGISTERS
ZBKCMD  LBRA    CMDNEP          ; NOW ENTER COMMAND HANDLER

********************************************
* IRQ, RESERVED, SWI2 AND SWI3 INTERRUPT HANDLERS
* THE DEFAULT HANDLING IS TO CAUSE A BREAKPOINT.
********************************************
SWI2R   EQU     *               ; SWI2 ENTRY
SWI3R   EQU     *               ; SWI3 ENTRY
IRQR    EQU     *               ; IRQ ENTRY
RSRVDR  BSR     LDDP            ; SET BASE PAGE, VALIDATE STACK
        BRA     ZBKPNT          ; FORCE A BREAKPOINT

******************************************
* FIRQ HANDLER
* JUST RETURN FOR THE FIRQ INTERRUPT
******************************************
FIRQR   EQU     RTI             ; IMMEDIATE RETURN

**************************************************
* DEFAULT I/O DRIVERS
**************************************************
* CIDTA - RETURN CONSOLE INPUT CHARACTER
* OUTPUT: C=0 IF NO DATA READY, C=1 A=CHARACTER
* U VOLATILE

CIDTA   LDU     <VECTAB+.ACIA   ; LOAD ACIA ADDRESS
        LDA     ,U              ; LOAD STATUS REGISTER
        LSRA                    ; TEST RECEIVER REGISTER FLAG
        BCC     CIRTN           ; RETURN IF NOTHING
        LDA     1,U             ; LOAD DATA BYTE
CIRTN   RTS                     ; RETURN TO CALLER

* CION - INPUT CONSOLE INITIALIZATION
* COON - OUTPUT CONSOLE INITIALIZATION
* A,X VOLATILE
CION   EQU      *
COON   LDA      #$13            ; RESET ACIA CODE
       LDX      <VECTAB+.ACIA   ; LOAD ACIA ADDRESS
       STA      ,X              ; STORE INTO STATUS REGISTER
       LDA      #$15            ; SET CONTROL
       STA      ,X              ; REGISTER UP
RTS    RTS                      ; RETURN TO CALLER

* THE FOLLOWING HAVE NO DUTIES TO PERFORM
CIOFF EQU       RTS             ; CONSOLE INPUT OFF
COOFF EQU       RTS             ; CONSOLE OUTPUT OFF

* CODTA - OUTPUT CHARACTER TO CONSOLE DEVICE
* INPUT: A=CHARACTER TO SEND
* OUTPUT: CHAR SENT TO TERMINAL WITH PROPER PADDING
* ALL REGISTERS TRANSPARENT

CODTA   PSHS    U,D,CC          ; SAVE REGISTERS,WORK BYTE
        LDU     <VECTAB+.ACIA   ; ADDRESS ACIA
        BSR     CODTAO          ; CALL OUTPUT CHAR SUBROUTINE
        CMPA    #DLE            ; ? DATA LINE ESCAPE
        BEQ     CODTRT          ; YES, RETURN
        LDB     <VECTAB+.PAD    ; DEFAULT TO CHAR PAD COUNT
        CMPA    #CR             ; ? CR
        BNE     CODTPD          ; BRANCH NO
        LDB     <VECTAB+.PAD+1  ; LOAD NEW LINE PAD COUNT
CODTPD  CLRA                    ; CREATE NULL
        STB     ,S              ; SAVE COUNT
        FCB     SKIP2           ; ENTER LOOP
CODTLP  BSR     CODTAO          ; SEND NULL
        DEC     ,S              ; ? FINISHED
        BPL     CODTLP          ; NO, CONTINUE WITH MORE
CODTRT  PULS    PC,U,D,CC       ; RESTORE REGISTERS AND RETURN

CODTAD  LBSR    XQPAUS          ; TEMPORARY GIVE UP CONTROL
CODTAO  LDB     ,U              ; LOAD ACIA CONTROL REGISTER
        BITB    #$02            ; ? TX REGISTER CLEAR >LSAB FIXME
        BEQ     CODTAD          ; RELEASE CONTROL IF NOT
        STA     1,U             ; STORE INTO DATA REGISTER
        RTS                     ; RETURN TO CALLER
*E

* BSON - TURN ON READ/VERIFY/PUNCH MECHANISM
* A IS VOLATILE

BSON    LDA     #$11            ; SET READ CODE
        TST     6,S             ; ? READ OR VERIFY
        BNE     BSON2           ; BRANCH YES
        INCA                    ; SET TO WRITE
BSON2   SWI                     ; PERFORM OUTPUT
        FCB     OUTCH           ; FUNCTION
        INC     <MISFLG         ; SET LOAD IN PROGRESS FLAG
        RTS                     ; RETURN TO CALLER

* BSOFF - TURN OFF READ/VERIFY/PUNCH MECHANISM
* A,X VOLATILE

BSOFF   LDA     #$14            ; TO DC4 - STOP
        SWI                     ; SEND OUT
        FCB     OUTCH           ; FUNCTION
        DECA                    ; CHANGE TO DC3 (X-OFF)
        SWI                     ; SEND OUT
        FCB     OUTCH           ; FUNCTION
        DEC     <MISFLG         ; CLEAR LOAD IN PROGRESS FLAG
        LDX     #25000          ; DELAY 1 SECOND (2MHZ CLOCK)
BSOFLP  LEAX    -1,X            ; COUNT DOWN
        BNE     BSOFLP          ; LOOP TILL DONE
        RTS                     ; RETURN TO CALLER

* BSDTA - READ/VERIFY/PUNCH HANDLER
* INPUT: S+6=CODE BYTE, VERIFY(-1),PUNCH(0),LOAD(1)
* S+4=START ADDRESS
* S+2=STOP ADDRESS
* S+0=RETURN ADDRESS
* OUTPUT: Z=1 NORMAL COMPLETION, Z=0 INVALID LOAD/VER
* REGISTERS ARE VOLATILE
BSDTA   LDU     2,S             ; U=TO ADDRESS OR OFFSET
        TST     6,S             ; ? PUNCH
        BEQ     BSDPUN          ; BRANCH YES

* DURING READ/VERIFY: S+2=MSB ADDRESS SAVE BYTE
* S+1=BYTE COUNTER
* S+0=CHECKSUM
* U HOLDS OFFSET
        LEAS    -3,S            ; ROOM FOR WORK/COUNTER/CHECKSUM
BSDLD1  SWI                     ; GET NEXT CHARACTER
        FCB     INCHNP          ; FUNCTION
BSDLD2  CMPA    #'S             ; ? START OF S1/S9
        BNE     BSDLD1          ; BRANCH NOT
        SWI                     ; GET NEXT CHARACTER
        FCB     INCHNP          ; FUNCTION
        CMPA    #'9             ; ? HAVE S9
        BEQ     BSDSRT          ; YES, RETURN GOOD CODE
        CMPA    #'1             ; ? HAVE NEW RECORD
        BNE     BSDLD2          ; BRANCH IF NOT
        CLR     ,S              ; CLEAR CHECKSUM
        BSR     BYTE            ; OBTAIN BYTE COUNT
        STB     1,S             ; SAVE FOR DECREMENT

* READ ADDRESS
        BSR     BYTE            ; OBTAIN HIGH VALUE
        STB     2,S             ; SAVE IT
        BSR     BYTE            ; OBTAIN LOW VALUE
        LDA     2,S             ; MAKE D=VALUE
        LEAY    D,U             ; Y=ADDRESS+OFFSET
* STORE TEXT
BSDNXT  BSR     BYTE            ; NEXT BYTE
        BEQ     BSDEOL          ; BRANCH IF CHECKSUM
        TST     9,S             ; ? VERIFY ONLY
        BMI     BSDCMP          ; YES, ONLY COMPARE
        STB     ,Y              ; STORE INTO MEMORY
BSDCMP  CMPB    ,Y+             ; ? VALID RAM
        BEQ     BSDNXT          ; YES, CONTINUE READING
BSDSRT  PULS    PC,X,A          ; RETURN WITH Z SET PROPER
BSDEOL  INCA                    ; ? VALID CHECKSUM
        BEQ     BSDLD1          ; BRANCH YES
        BRA     BSDSRT          ; RETURN Z=0 INVALID

* BYTE BUILDS 8 BIT VALUE FROM TWO HEX DIGITS IN
BYTE    BSR     BYTHEX         ; OBTAIN FIRST HEX
        LDB     #16            ; PREPARE SHIFT
        MUL                    ; OVER TO A
        BSR     BYTHEX         ; OBTAIN SECOND HEX
        PSHS    B              ; SAVE HIGH HEX
        ADDA    ,S+            ; COMBINE BOTH SIDES
        TFR     A,B            ; SEND BACK IN B
        ADDA    2,S            ; COMPUTE NEW CHECKSUM
        STA     2,S            ; STORE BACK
        DEC     3,S            ; DECREMENT BYTE COUNT
BYTRTS  RTS                    ; RETURN TO CALLER

BYTHEX  SWI                    ; GET NEXT HEX
        FCB     INCHNP         ; CHARACTER
        LBSR    CNVHEX         ; CONVERT TO HEX
        BEQ     BYTRTS         ; RETURN IF VALID HEX
        PULS    PC,U,Y,X,A     ; RETURN TO CALLER WITH Z=0

* PUNCH STACK USE: S+8=TO ADDRESS
*                  S+6=RETURN ADDRESS
*                  S+4=SAVED PADDING VALUES
*                  S+2 FROM ADDRESS
*                  S+1=FRAME COUNT/CHECKSUM
*                  S+0=BYTE COUNT

BSDPUN  LDU     <VECTAB+.PAD    ; LOAD PADDING VALUES
        LDX     4,S             ; X=FROM ADDRESS
        PSHS    U,X,D           ; CREATE STACK WORK AREA
        LDD     #24             ; SET A=0, B=24
        STB     <VECTAB+.PAD    ; SETUP 24 CHARACTER PADS
        SWI                     ; SEND NULLS OUT
        FCB     OUTCH           ; FUNCTION
        LDB     #4              ; SETUP NEW LINE PAD TO 4
        STD     <VECTAB+.PAD    ; SETUP PUNCH PADDING
* CALCULATE SIZE
BSPGO   LDD     8,S             ; LOAD TO
        SUBD    2,S             ; MINUS FROM=LENGTH
        CMPD    #24             ; ? MORE THAN 23
        BLO     BSPOK           ; NO, OK
        LDB     #23             ; FORCE TO 23 MAX
BSPOK   INCB                    ; PREPARE COUNTER
        STB     ,S              ; STORE BYTE COUNT
        ADDB    #3              ; ADJUST TO FRAME COUNT
        STB     1,S             ; SAVE

*PUNCH CR,LF,NULS,S,1
       LEAX     <BSPSTR,PCR     ; LOAD START RECORD HEADER
       SWI                      ; SEND OUT
       FCB      PDATA           ; FUNCTION
* SEND FRAME COUNT
       CLRB                     ; INITIALIZE CHECKSUM
       LEAX     1,S             ; POINT TO FRAME COUNT AND ADDR
       BSR      BSPUN2          ; SEND FRAME COUNT
*DATA ADDRESS
      BSR       BSPUN2          ; SEND ADDRESS HI
      BSR       BSPUN2          ; SEND ADDRESS LOW
*PUNCH DATA
       LDX      2,S             ; LOAD START DATA ADDRESS
BSPMRE BSR      BSPUN2          ; SEND OUT NEXT BYTE
       DEC      ,S              ; ? FINAL BYTE
       BNE      BSPMRE          ; LOOP IF NOT DONE
       STX      2,S             ; UPDATE FROM ADDRESS VALUE
*PUNCH CHECKSUM
       COMB                     ; COMPLEMENT
       STB      1,S             ; STORE FOR SENDOUT
       LEAX     1,S             ; POINT TO IT
       BSR      BSPUNC          ; SEND OUT AS HEX
       LDX      8,S             ; LOAD TOP ADDRESS
       CMPX     2,S             ; ? DONE
       BHS      BSPGO           ; BRANCH NOT
       LEAX     <BSPEOF,PCR     ; PREPARE END OF FILE
       SWI                      ; SEND OUT STRING
       FCB      PDATA           ; FUNCTION
       LDD      4,S             ; RECOVER PAD COUNTS
       STD      <VECTAB+.PAD    ; RESTORE
       CLRA                     ; SET Z=1 FOR OK RETURN
       PULS     PC,U,X,D        ; RETURN WITH OK CODE
BSPUN2 ADDB     ,X              ; ADD TO CHECKSUM
BSPUNC LBRA     ZOUT2H          ; SEND OUT AS HEX AND RETURN

BSPSTR FCB      'S,'1,EOT       ; CR,LF,NULLS,S,1
BSPEOF FCC      /S9030000FC/    ; EOF STRING
       FCB      CR,LF,EOT

* HSDTA - HIGH SPEED PRINT MEMORY
* INPUT: S+4=START ADDRESS
* S+2=STOP ADDRESS
* S+0=RETURN ADDRESS
* X,D VOLATILE

* SEND TITLE

HSDTA   SWI                     ; SEND NEW LINE
        FCB     PCRLF           ; FUNCTION
        LDB     #6              ; PREPARE 6 SPACES
HSBLNK  SWI                     ; SEND BLANK
        FCB     SPACEF          ; FUNCTION
        DECB                    ; COUNT DOWN
        BNE     HSBLNK          ; LOOP IF MORE
        CLRB                    ; SETUP BYTE COUNT
HSHTTL  TFR     B,A             ; PREPARE FOR CONVERT
        LBSR    ZOUTHX          ; CONVERT TO A HEX DIGIT
        SWI                     ; SEND BLANK
        FCB     SPACEF          ; FUNCTION
        SWI                     ; SEND ANOTHER
        FCB     SPACEF          ; BLANK
        INCB                    ; UP ANOTHER
        CMPB    #$10            ; ? PAST 'F'
        BLO     HSHTTL          ; LOOP UNTIL SO
HSHLNE  SWI                     ; TO NEXT LINE
        FCB     PCRLF           ; FUNCTION
        BCS     HSDRTN          ; RETURN IF USER ENTERED CTL-X
        LEAX    4,S             ; POINT AT ADDRESS TO CONVERT
        SWI                     ; PRINT OUT ADDRESS
        FCB     OUT4HS          ; FUNCTION
        LDX     4,S             ; LOAD ADDRESS PROPER
        LDB     #16             ; NEXT SIXTEEN
HSHNXT  SWI                     ; CONVERT BYTE TO HEX AND SEND
        FCB     OUT2HS          ; FUNCTION
        DECB                    ; COUNT DOWN
        BNE     HSHNXT          ; LOOP IF NOT SIXTEENTH
        SWI                     ; SEND BLANK
        FCB     SPACEF          ; FUNCTION
        LDX     4,S             ; RELOAD FROM ADDRESS
        LDB     #16             ; COUNT
HSHCHR  LDA     ,X+             ; NEXT BYTE
        BMI     HSHDOT          ; TOO LARGE, TO A DOT
        CMPA    #'              ; ? LOWER THAN A BLANK
        BHS     HSHCOK          ; NO, BRANCH OK
HSHDOT  LDA     #'.             ; CONVERT INVALID TO A BLANK
HSHCOK  SWI                     ; SEND CHARACTER
        FCB     OUTCH           ; FUNCTION
        DECB                    ; ? DONE
        BNE     HSHCHR          ; BRANCH NO
        CPX     2,S             ; ? PAST LAST ADDRESS
        BHS     HSDRTN          ; QUIT IF SO
        STX     4,S             ; UPDATE FROM ADDRESS
        LDA     5,S             ; LOAD LOW BYTE ADDRESS
        ASLA                    ; ? TO SECTION BOUNDARY
        BNE     HSHLNE          ; BRANCH IF NOT
        BRA     HSDTA           ; BRANCH IF SO
HSDRTN  SWI                     ; SEND NEW LINE
        FCB     PCRLF           ; FUNCTION
        RTS                     ; RETURN TO CALLER
*F

***********************************************
*     A S S I S T 0 9    C O M M A N D S
***********************************************

*************REGISTERS - DISPLAY AND CHANGE REGISTERS
CREG    BSR     REGPRT          ; PRINT REGISTERS
        INCA                    ; SET FOR CHANGE FUNCTION
        BSR     REGCHG          ; GO CHANGE, DISPLAY REGISTERS
        RTS                     ; RETURN TO COMMAND PROCESSOR

********************************************
* REGPRT - PRINT/CHANGE REGISTERS SUBROUTINE
* WILL ABORT TO 'CMDBAD' IF OVERFLOW DETECTED DURING
* A CHANGE OPERATION. CHANGE DISPLAYS REGISTERS WHEN
* DONE.

* REGISTER MASK LIST CONSISTS OF:
* A) CHARACTERS DENOTING REGISTER
* B) ZERO FOR ONE BYTE, -1 FOR TWO
* C) OFFSET ON STACK TO REGISTER POSITION
* INPUT: SP+4=STACKED REGISTERS
* A=0 PRINT, A#0 PRINT AND CHANGE
* OUTPUT: (ONLY FOR REGISTER DISPLAY)
* C=1 CONTROL-X ENTERED, C=0 OTHERWISE
* VOLATILE: D,X (CHANGE)
* B,X (DISPLAY)
*******************************************

REGMSK  FCB     'P,'C,-1,19     ; PC REG
        FCB     'A,0,10         ; A REG
        FCB     'B,0,11         ; B REG
        FCB     'X,-1,13        ; X REG
        FCB     'Y,-1,15        ; Y REG
        FCB     'U,-1,17        ; U REG
        FCB     'S,-1,1         ; S REG
        FCB     'C,'C,0,9       ; CC REG
        FCB     'D,'P,0,12      ; DP REG
        FCB     0               ; END OF LIST

REGPRT  CLRA                    ; SETUP PRINT ONLY FLAG
REGCHG  LEAX    4+12,S          ; READY STACK VALUE
        PSHS    Y,X,A           ; SAVE ON STACK WITH OPTION
        LEAY    REGMSK,PCR      ; LOAD REGISTER MASK
REGP1   LDD     ,Y+             ; LOAD NEXT CHAR OR <=0
        TSTA                    ; ? END OF CHARACTERS
        BLE     REGP2           ; BRANCH NOT CHARACTER
        SWI                     ; SEND TO CONSOLE
        FCB     OUTCH           ; FUNCTION BYTE
        BRA     REGP1           ; CHECK NEXT
REGP2   LDA     #'-             ; READY '-'
        SWI                     ; SEND OUT
        FCB     OUTCH           ; WITH OUTCH
        LEAX    B,S             ; X->REGISTER TO PRINT
        TST     ,S              ; ? CHANGE OPTION
        BNE     REGCNG          ; BRANCH YES
        TST     -1,Y            ; ? ONE OR TWO BYTES
        BEQ     REGP3           ; BRANCH ZERO MEANS ONE
        SWI                     ; PERFORM WORD HEX
        FCB     OUT4HS          ; FUNCTION
        FCB     SKIP2           ; SKIP BYTE PRINT
REGP3   SWI                     ; PERFORM BYTE HEX
        FCB     OUT2HS          ; FUNCTION
REG4    LDD     ,Y+             ; TO FRONT OF NEXT ENTRY
        TSTB                    ; ? END OF ENTRIES
        BNE     REGP1           ; LOOP IF MORE
        SWI                     ; FORCE NEW LINE
        FCB     PCRLF           ; FUNCTION
REGRTN  PULS    PC,Y,X,A        ; RESTORE STACK AND RETURN

REGCNG  BSR     BLDNNB          ; INPUT BINARY NUMBER
        BEQ     REGNXC          ; IF CHANGE THEN JUMP
        CMPA    #CR             ; ? NO MORE DESIRED
        BEQ     REGAGN          ; BRANCH NOPE
        LDB     -1,Y            ; LOAD SIZE FLAG
        DECB                    ; MINUS ONE
        NEGB                    ; MAKE POSITIVE
        ASLB                    ; TIMES TWO (=2 OR =4)
REGSKP  SWI                     ; PERFORM SPACES
        FCB     SPACEF          ; FUNCTION
        DECB
        BNE     REGSKP          ; LOOP IF MORE
        BRA     REG4            ; CONTINUE WITH NEXT REGISTER
REGNXC  STA     ,S              ; SAVE DELIMITER IN OPTION
*                               ; (ALWAYS > 0)
        LDD     <NUMBER         ; OBTAIN BINARY RESULT
        TST     -1,Y            ; ? TWO BYTES WORTH
        BNE     REGTWO          ; BRANCH YES
        LDA     ,-X             ; SETUP FOR TWO
REGTWO  STD     ,X              ; STORE IN NEW VALUE
        LDA     ,S              ; RECOVER DELIMITER
        CMPA    #CR             ; ? END OF CHANGES
        BNE     REG4            ; NO, KEEP ON TRUCK'N
* MOVE STACKED DATA TO NEW STACK IN CASE STACK
* POINTER HAS CHANGED
REGAGN  LEAX    TSTACK,PCR      ; LOAD TEMP AREA
        LDB     #21             ; LOAD COUNT
REGTF1  PULS    A               ; NEXT BYTE
        STA     ,X+             ; STORE INTO TEMP
        DECB                    ; COUNT DOWN
        BNE     REGTF1          ; LOOP IF MORE
        LDS     -20,X           ; LOAD NEW STACK POINTER
        LDB     #21             ; LOAD COUNT AGAIN
REGTF2 LDA      ,-X             ; NEXT TO STORE
       PSHS     A               ; BACK ONTO NEW STACK
       DECB                     ; COUNT DOWN
       BNE      REGTF2          ; LOOP IF MORE
       BRA      REGRTN          ; GO RESTART COMMAND

*********************************************
* BLDNUM - BUILDS BINARY VALUE FROM INPUT HEX
* THE ACTIVE EXPRESSION HANDLER IS USED.
* INPUT: S=RETURN ADDRESS
* OUTPUT: A=DELIMITER WHICH TERMINATED VALUE
* (IF DELM NOT ZERO)
* "NUMBER"=WORD BINARY RESULT
* Z=1 IF INPUT RECEIVED, Z=0 IF NO HEX RECEIVED
* REGISTERS ARE TRANSPARENT
**********************************************
* EXECUTE SINGLE OR EXTENDED ROM EXPRESSION HANDLER
*
* THE FLAG "DELIM" IS USED AS FOLLOWS:
* DELIM=0 NO LEADING BLANKS, NO FORCED TERMINATOR
* DELIM=CHR ACCEPT LEADING 'CHR'S, FORCED TERMINATOR
BLDNNB  CLRA                    ; NO DYNAMIC DELIMITER
        FCB     SKIP2           ; SKIP NEXT INSTRUCTION
* BUILD WITH LEADING BLANKS
BLDNUM  LDA     #'              ; ALLOW LEADING BLANKS
        STA     <DELIM          ; STORE AS DELIMITER
        JMP     [VECTAB+.EXPAN,PCR]   ; TO EXP ANALYZER
* THIS IS THE DEFAULT SINGLE ROM ANALYZER. WE ACCEPT:
* 1) HEX INPUT
* 2) 'M' FOR LAST MEMORY EXAMINE ADDRESS
* 3) 'P' FOR PROGRAM COUNTER ADDRESS
* 4) 'W' FOR WINDOW VALUE
* 5) '@' FOR INDIRECT VALUE

EXP1    PSHS    X,B             ; SAVE REGISTERS
EXPDLM  BSR     BLDHXI          ; CLEAR NUMBER, CHECK FIRST CHAR
        BEQ     EXP2            ; IF HEX DIGIT CONTINUE BUILDING
* SKIP BLANKS IF DESIRED
        CMPA    <DELIM          ; ? CORRECT DELIMITER
        BEQ     EXPDLM          ; YES, IGNORE IT
* TEST FOR M OR P
        LDX     <ADDR           ; DEFAULT FOR 'M'
        CMPA    #'M             ; ? MEMORY EXAMINE ADDR WANTED
        BEQ     EXPTDL          ; BRANCH IF SO
        LDX     <PCNTER         ; DEFAULT FOR 'P'
        CMPA    #'P             ; ? LAST PROGRAM COUNTER WANTED
        BEQ     EXPTDL          ; BRANCH IF SO
        LDX     <WINDOW         ; DEFAULT TO WINDOW
        CMPA    #'W             ; ? WINDOW WANTED
        BEQ     EXPTDL

EXPRTN  PULS    PC,X,B          ; RETURN AND RESTORE REGISTERS
* GOT HEX, NOW CONTINUE BUILDING
EXP2    BSR     BLDHEX          ; COMPUTE NEXT DIGIT
        BEQ     EXP2            ; CONTINUE IF MORE
        BRA     EXPCDL          ; SEARCH FOR +/-
* STORE VALUE AND CHECK IF NEED DELIMITER
EXPTDI  LDX     ,X              ; INDIRECTION DESIRED
EXPTDL  STX     <NUMBER         ; STORE RESULT
        TST     <DELIM          ; ? TO FORCE A DELIMITER
        BEQ     EXPRTN          ; RETURN IF NOT WITH VALUE
        BSR     READC           ; OBTAIN NEXT CHARACTER
* TEST FOR + OR -
EXPCDL  LDX     <NUMBER         ; LOAD LAST VALUE
        CMPA    #'+             ; ? ADD OPERATOR
        BNE     EXPCHM          ; BRANCH NOT
        BSR     EXPTRM          ; COMPUTE NEXT TERM
        PSHS    A               ; SAVE DELIMITER
        LDD     <NUMBER         ; LOAD NEW TERM
EXPADD  LEAX    D,X             ; ADD TO X
        STX     <NUMBER         ; STORE AS NEW RESULT
        PULS    A               ; RESTORE DELIMITER
        BRA     EXPCDL          ; NOW TEST IT
EXPCHM  CMPA    #'-             ; ? SUBTRACT OPERATOR
        BEQ     EXPSUB          ; BRANCH IF SO
        CMPA    #'@             ; ? INDIRECTION DESIRED
        BEQ     EXPTDI          ; BRANCH IF SO
        CLRB                    ; SET DELIMITER RETURN
        BRA     EXPRTN          ; AND RETURN TO CALLER
EXPSUB  BSR     EXPTRM          ; OBTAIN NEXT TERM
        PSHS    A               ; SAVE DELIMITER
        LDD     <NUMBER         ; LOAD UP NEXT TERM
        NEGA                    ; NEGATE A
        NEGB                    ; NEGATE B
        SBCA    #0              ; CORRECT FOR A
        BRA     EXPADD          ; GO ADD TO EXPRESSION
* COMPUTE NEXT EXPRESSION TERM
* OUTPUT: X=OLD VALUE
* 'NUMBER'=NEXT TERM
EXPTRM  BSR     BLDNUM          ; OBTAIN NEXT VALUE
        BEQ     CNVRTS          ; RETURN IF VALID NUMBER
BLDBAD  LBRA    CMDBAD          ; ABORT COMMAND IF INVALID

*********************************************
* BUILD BINARY VALUE USING INPUT CHARACTERS.
* INPUT: A=ASCII HEX VALUE OR DELIMITER
* SP+0=RETURN ADDRESS
* SP+2=16 BIT RESULT AREA
* OUTPUT: Z=1 A=BINARY VALUE
* Z=0 IF INVALID HEX CHARACTER (A UNCHANGED)
* VOLATILE: D
****************************************
BLDHXI  CLR     <NUMBER         ; CLEAR NUMBER
        CLR     <NUMBER+1       ; CLEAR NUMBER
BLDHEX  BSR     READC           ; GET INPUT CHARACTER
BLDHXC  BSR     CNVHEX          ; CONVERT AND TEST CHARACTER
        BNE     CNVRTS          ; RETURN IF NOT A NUMBER
        LDB     #16             ; PREPARE SHIFT
        MUL                     ; BY FOUR PLACES
        LDA     #4              ; ROTATE BINARY INTO VALUE
BLDSHF  ASLB                    ; OBTAIN NEXT BIT
        ROL     <NUMBER+1       ; INTO LOW BYTE
        ROL     <NUMBER         ; INTO HI BYTE
        DECA                    ; COUNT DOWN
        BNE     BLDSHF          ; BRANCH IF MORE TO DO
        BRA     CNVOK           ; SET GOOD RETURN CODE

****************************************
* CONVERT ASCII CHARACTER TO BINARY BYTE
* INPUT: A=ASCII
* OUTPUT: Z=1 A=BINARY VALUE
* Z=0 IF INVALID
* ALL REGISTERS TRANSPARENT
* (A UNALTERED IF INVALID HEX)
**************************************
CNVHEX  CMPA    #'0             ; ? LOWER THAN A ZERO
        BLO     CNVRTS          ; BRANCH NOT VALUE
        CMPA    #'9             ; ? POSSIBLE A-F
        BLE     CNVGOT          ; BRANCH NO TO ACCEPT
        CMPA    #'A             ; ? LESS THEN TEN
        BLO     CNVRTS          ; RETURN IF MINUS (INVALID)
        CMPA    #'F             ; ? NOT TOO LARGE
        BHI     CNVRTS          ; NO, RETURN TOO LARGE
        SUBA    #7              ; DOWN TO BINARY
CNVGOT  ANDA    #$0F            ; CLEAR HIGH HEX
CNVOK   ORCC    #4              ; FORCE ZERO ON FOR VALID HEX
CNVRTS  RTS                     ; RETURN TO CALLER

* GET INPUT CHAR, ABORT COMMAND IF CONTROL-X (CANCEL)
READC    SWI                    ; GET NEXT CHARACTER
         FCB    INCHNP          ; FUNCTION
         CMPA   #CAN            ; ? ABORT COMMAND
         BEQ    BLDBAD          ; BRANCH TO ABORT IF SO
         RTS                    ; RETURN TO CALLER
*G

***************GO - START PROGRAM EXECUTION
CGO      BSR    GOADDR          ; BUILD ADDRESS IF NEEDED
         RTI                    ; START EXECUTING

* FIND OPTIONAL NEW PROGRAM COUNTER. ALSO ARM THE
* BREAKPOINTS.
GOADDR   PULS   Y,X             ; RECOVER RETURN ADDRESS
         PSHS   X               ; STORE RETURN BACK
         BNE    GONDFT          ; IF NO CARRIAGE RETURN THEN NEW PC

* DEFAULT PROGRAM COUNTER, SO FALL THROUGH IF
* IMMEDIATE BREAKPOINT.
         LBSR   CBKLDR          ; SEARCH BREAKPOINTS
         LDX    12,S            ; LOAD PROGRAM COUNTER
ARMBLP  DECB                    ; COUNT DOWN
        BMI     ARMBK2          ; DONE, NONE TO SINGLE TRACE
        LDA     -NUMBKP*2,Y     ; PRE-FETCH OPCODE
        CMPX    ,Y++            ; ? IS THIS A BREAKPOINT
        BNE     ARMBLP          ; LOOP IF NOT
        CMPA    #$3F            ; ? SWI BREAKPOINTED
        BNE     ARMNSW          ; NO, SKIP SETTING OF PASS FLAG
        STA     <SWIBFL         ; SHOW UPCOMING SWI NOT BRKPNT
ARMNSW  INC     <MISFLG         ; FLAG THRU A BREAKPOINT
        LBRA    CDOT            ; DO SINGLE TRACE W/O BREAKPOINTS

* OBTAIN NEW PROGRAM COUNTER
GONDFT  LBSR    CDNUM           ; OBTAIN NEW PROGRAM COUNTER
        STD     12,S            ; STORE INTO STACK
ARMBK2  LBSR    CBKLDR          ; OBTAIN TABLE
        NEG     <BKPTCT         ; COMPLEMENT TO SHOW ARMED
ARMLOP  DECB                    ; ? DONE
        BMI     CNVRTS          ; RETURN WHEN DONE
        LDA     [,Y]            ; LOAD OPCODE
        STA     -NUMBKP*2,Y     ; STORE INTO OPCODE TABLE
        LDA     #$3F            ; READY "SWI" OPCODE
        STA     [,Y++]          ; STORE AND MOVE UP TABLE
        BRA     ARMLOP          ; AND CONTINUE

*******************CALL - CALL ADDRESS AS SUBROUTINE
CCALL   BSR     GOADDR          ; FETCH ADDRESS IF NEEDED
        PULS    U,Y,X,DP,D,CC   ; RESTORE USERS REGISTERS
        JSR     [,S++]          ; CALL USER SUBROUTINE
CGOBRK  SWI                     ; PERFORM BREAKPOINT
        FCB     BRKPT           ; FUNCTION
        BRA     CGOBRK          ; LOOP UNTIL USER CHANGES PC

****************MEMORY - DISPLAY/CHANGE MEMORY
* CMEMN AND CMPADP ARE DIRECT ENTRY POINTS FROM
* THE COMMAND HANDLER FOR QUICK COMMANDS
CMEM    LBSR    CDNUM           ; OBTAIN ADDRESS
CMEMN   STD     <ADDR           ; STORE DEFAULT
CMEM2   LDX     <ADDR           ; LOAD POINTER
        LBSR    ZOUT2H          ; SEND OUT HEX VALUE OF BYTE
        LDA     #'-             ; LOAD DELIMITER
        SWI                     ; SEND OUT
        FCB     OUTCH           ; FUNCTION
CMEM4   LBSR    BLDNNB          ; OBTAIN NEW BYTE VALUE
        BEQ     CMENUM          ; BRANCH IF NUMBER
* COMA - SKIP BYTE
        CMPA    #',             ; ? COMMA
        BNE     CMNOTC          ; BRANCH NOT
        STX     <ADDR           ; UPDATE POINTER
        LEAX    1,X             ; TO NEXT BYTE
        BRA     CMEM4           ; AND INPUT IT
CMENUM  LDB     <NUMBER+1       ; LOAD LOW BYTE VALUE
        BSR     MUPDAT          ; GO OVERLAY MEMORY BYTE
        CMPA    #',             ; ? CONTINUE WITH NO DISPLAY
        BEQ     CMEM4           ; BRANCH YES
* QUOTED STRING
CMNOTC  CMPA    #$27            ; ? QUOTED STRING
        BNE     CMNOTQ          ; BRANCH NO
CMESTR  BSR     READC           ; OBTAIN NEXT CHARACTER
        CMPA    #$27            ; ? END OF QUOTED STRING
        BEQ     CMSPCE          ; YES, QUIT STRING MODE
        TFR     A,B             ; TO B FOR SUBROUTINE
        BSR     MUPDAT          ; GO UPDATE BYTE
        BRA     CMESTR          ; GET NEXT CHARACTER
* BLANK - NEXT BYTE
CMNOTQ  CMPA    #$20            ; ? BLANK FOR NEXT BYTE
        BNE     CMNOTB          ; BRANCH NOT
        STX     <ADDR           ; UPDATE POINTER
CMSPCE  SWI                     ; GIVE SPACE
        FCB     SPACEF          ; FUNCTION
        BRA     CMEM2           ; NOW PROMPT FOR NEXT

* LINE FEED - NEXT BYTE WITH ADDRESS
CMNOTB  CMPA    #LF             ; ? LINE FEED FOR NEXT BYTE
        BNE     CMNOTL          ; BRANCH NO
        LDA     #CR             ; GIVE CARRIAGE RETURN
        SWI                     ; TO CONSOLE
        FCB     OUTCH           ; HANDLER
        STX     <ADDR           ; STORE NEXT ADDRESS
        BRA     CMPADP          ; BRANCH TO SHOW

* UP ARROW - PREVIOUS BYTE AND ADDRESS
CMNOTL  CMPA    #'^             ; ? UP ARROW FOR PREVIOUS BYTE
        BNE     CMNOTU          ; BRANCH NOT
        LEAX    -2,X            ; DOWN TO PREVIOUS BYTE
        STX     <ADDR           ; STORE NEW POINTER
CMPADS  SWI                     ; FORCE NEW LINE
        FCB     PCRLF           ; FUNCTION
CMPADP  BSR     PRTADR          ; GO PRINT ITS VALUE
        BRA     CMEM2           ; THEN PROMPT FOR INPUT

* SLASH - NEXT BYTE WITH ADDRESS
CMNOTU  CMPA    #'/             ; ? SLASH FOR CURRENT DISPLAY
        BEQ     CMPADS          ; YES, SEND ADDRESS
        RTS                     ; RETURN FROM COMMAND

* PRINT CURRENT ADDRESS
PRTADR  LDX     <ADDR           ; LOAD POINTER VALUE
        PSHS    X               ; SAVE X ON STACK
        LEAX    ,S              ; POINT TO IT FOR DISPLAY
        SWI                     ; DISPLAY POINTER IN HEX
        FCB     OUT4HS          ; FUNCTION
        PULS    PC,X            ; RECOVER POINTER AND RETURN

* UPDATE BYTE
MUPDAT  LDX     <ADDR           ; LOAD NEXT BYTE POINTER
        STB     ,X+             ; STORE AND INCREMENT X
        CMPB    -1,X            ; ? SUCCESFULL STORE
        BNE     MUPBAD          ; BRANCH FOR '?' IF NOT
        STX     <ADDR           ; STORE NEW POINTER VALUE
        RTS                     ; BACK TO CALLER
MUPBAD  PSHS    A               ; SAVE A REGISTER
        LDA     #'?             ; SHOW INVALID
        SWI                     ; SEND OUT
        FCB     OUTCH           ; FUNCTION
        PULS    PC,A            ; RETURN TO CALLER

********************WINDOW - SET WINDOW VALUE
CWINDO  BSR     CDNUM           ; OBTAIN WINDOW VALUE
        STD     <WINDOW         ; STORE IT IN
        RTS                     ; END COMMAND

******************DISPLAY - HIGH SPEED DISPLAY MEMORY
CDISP   BSR     CDNUM           ; FETCH ADDRESS
        ANDB    #$F0            ; FORCE TO 16 BOUNDARY
        TFR     D,Y             ; SAVE IN Y
        LEAX    15,Y            ; DEFAULT LENGTH
        BCS     CDISPS          ; BRANCH IF END OF INPUT
        BSR     CDNUM           ; OBTAIN COUNT
        LEAX    D,Y             ; ASSUME COUNT, COMPUTE END ADDR
CDISPS  PSHS    Y,X             ; SETUP PARAMETERS FOR HSDATA
        CMPD    2,S             ; ? WAS IT COUNT
        BLS     CDCNT           ; BRANCH YES
        STD     ,S              ; STORE HIGH ADDRESS
CDCNT   JSR     [VECTAB+.HSDTA,PCR] ; CALL PRINT ROUTINE
        PULS    PC,U,Y          ; CLEAN STACK AND END COMMAND

* OBTAIN NUMBER - ABORT IF NONE
* ONLY DELIMITERS OF CR, BLANK, OR '/' ARE ACCEPTED
* OUTPUT: D=VALUE, C=1 IF CARRIAGE RETURN DELMITER,
* ELSE C=0
CDNUM   LBSR    BLDNUM          ; OBTAIN NUMBER
        BNE     CDBADN          ; BRANCH IF INVALID
        CMPA    #'/             ; ? VALID DELIMITER
        BHI     CDBADN          ; BRANCH IF NOT FOR ERROR
        CMPA    #CR+1           ; LEAVE COMPARE FOR CARRIAGE RET
        LDD     <NUMBER         ; LOAD NUMBER
        RTS                     ; RETURN WITH COMPARE
CDBADN  LBRA    CMDBAD          ; RETURN TO ERROR MECHANISM

*****************PUNCH - PUNCH MEMORY IN S1-S9 FORMAT
CPUNCH  BSR     CDNUM           ; OBTAIN START ADDRESS
        TFR     D,Y             ; SAVE IN Y
        BSR     CDNUM           ; OBTAIN END ADDRESS
        CLR     ,-S             ; SETUP PUNCH FUNCTION CODE
        PSHS    Y,D             ; STORE VALUES ON STACK
CCALBS  JSR     [VECTAB+.BSON,PCR] ; INITIALIZE HANDLER
        JSR     [VECTAB+.BSDTA,PCR] ; PERFORM FUNCTION
        PSHS    CC              ; SAVE RETURN CODE
        JSR     [VECTAB+.BSOFF,PCR] ; TURN OFF HANDLER
        PULS    CC              ; OBTAIN CONDITION CODE SAVED
        BNE     CDBADN          ; BRANCH IF ERROR
        PULS    PC,Y,X,A        ; RETURN FROM COMMAND

*****************LOAD - LOAD MEMORY FROM S1-S9 FORMAT
CLOAD   BSR     CLVOFS          ; CALL SETUP AND PASS CODE
        FCB     1               ; LOAD FUNCTION CODE FOR PACKET

CLVOFS  LEAU    [,S++]          ; LOAD CODE IN HIGH BYTE OF U
        LEAU    [,U]            ; NOT CHANGING CC AND RESTORE S
        BEQ     CLVDFT          ; BRANCH IF CARRIAGE RETURN NEXT
        BSR     CDNUM           ; OBTAIN OFFSET
        FCB     SKIP2           ; SKIP DEFAULT OFFSET
CLVDFT  CLRA                    ; CREATE ZERO OFFSET
        CLRB                    ; AS DEFAULT
        PSHS    U,DP,D          ; SETUP CODE, NULL WORD, OFFSET
        BRA     CCALBS          ; ENTER CALL TO BS ROUTINES

******************VERIFY - COMPARE MEMORY WITH FILES
CVER    BSR     CLVOFS          ; COMPUTE OFFSET IF ANY
        FCB     -1              ; VERIFY FNCTN CODE FOR PACKET

*******************TRACE - TRACE INSTRUCTIONS
******************* . - SINGLE STEP TRACE
CTRACE  BSR     CDNUM           ; OBTAIN TRACE COUNT
        STD     <TRACEC         ; STORE COUNT
CDOT    LEAS    2,S             ; RID COMMAND RETURN FROM STACK
CTRCE3  LDU     [10,S]          ; LOAD OPCODE TO EXECUTE
        STU     <LASTOP         ; STORE FOR TRACE INTERRUPT
        LDU     <VECTAB+.PTM    ; LOAD PTM ADDRESS
        LDD     #$0701          ; 7,1 CYCLES DOWN+CYCLES UP
        STD     PTMTM1-PTM,U    ; START NMI TIMEOUT
        RTI                     ; RETURN FOR ONE INSTRUCTION

*************NULLS  -  SET NEW LINE AND CHAR PADDING
CNULLS  BSR     CDNUM           ; OBTAIN NEW LINE PAD
        STD     <VECTAB+.PAD    ; RESET VALUES
        RTS                     ; END COMMAND

******************STLEVEL - SET STACK TRACE LEVEL
CSTLEV  BEQ     STLDFT          ; TAKE DEFAULT
        BSR     CDNUM           ; OBTAIN NEW STACK LEVEL
        STD     <SLEVEL         ; STORE NEW ENTRY
        RTS                     ; TO COMMAND HANDLER
STLDFT  LEAX    14,S            ; COMPUTE NMI COMPARE
        STX     <SLEVEL         ; AND STORE IT
        RTS                     ; END COMMAND

******************OFFSET - COMPUTE SHORT AND LONG
******************                  BRANCH OFFSETS
COFFS   BSR     CDNUM           ; OBTAIN INSTRUCTION ADDRESS
        TFR     D,X             ; USE AS FROM ADDRESS
        BSR     CDNUM           ; OBTAIN TO ADDRESS
* D=TO INSTRUCTION, X=FROM INSTRUCTION OFFSET BYTE(S)
        LEAX    1,X             ; ADJUST FOR *+2 SHORT BRANCH
        PSHS    Y,X             ; STORE WORK WORD AND VALUE ON S
        SUBD    ,S              ; FIND OFFSET
        STD     ,S              ; SAVE OVER STACK
        LEAX    1,S             ; POINT FOR ONE BYTE DISPLAY
        SEX                     ; SIGN EXTEND LOW BYTE
        CMPA    ,S              ; ? VALID ONE BYTE OFFSET
        BNE     COFNO1          ; BRANCH IF NOT
        SWI                     ; SHOW ONE BYTE OFFSET
        FCB     OUT2HS          ; FUNCTION
COFNO1  LDU     ,S              ; RELOAD OFFSET
        LEAU    -1,U            ; CONVERT TO LONG BRANCH OFFSET
        STU     ,X              ; STORE BACK WHERE X POINTS NOW
        SWI                     ; SHOW TWO BYTE OFFSET
        FCB     OUT4HS          ; FUNCTION
        SWI                     ; FORCE NEW LINE
        FCB     PCRLF           ; FUNCTION
        PULS    PC,X,D          ; RESTORE STACK AND END COMMAND
*H

*************BREAKPOINT - DISPLAY/ENTER/DELETE/CLEAR
*************             BREAKPOINTS
CBKPT   BEQ     CBKDSP          ; BRANCH DISPLAY OF JUST 'B'
        LBSR    BLDNUM          ; ATTEMPT VALUE ENTRY
        BEQ     CBKADD          ; BRANCH TO ADD IF SO
        CMPA    #'-             ; ? CORRECT DELIMITER
        BNE     CBKERR          ; NO, BRANCH FOR ERROR
        LBSR    BLDNUM          ; ATTEMPT DELETE VALUE
        BEQ     CBKDLE          ; GOT ONE, GO DELETE IT
        CLR     <BKPTCT         ; WAS 'B -', SO ZERO COUNT
CBKRTS  RTS                     ; END COMMAND
* DELETE THE ENTRY
CBKDLE  BSR     CBKSET          ; SETUP REGISTERS AND VALUE
CBKDLP  DECB                    ; ? ANY ENTRIES IN TABLE
        BMI     CBKERR          ; BRANCH NO, ERROR
        CMPX    ,Y++            ; ? IS THIS THE ENTRY
        BNE     CBKDLP          ; NO, TRY NEXT
* FOUND, NOW MOVE OTHERS UP IN ITS PLACE
CBKDLM  LDX     ,Y++            ; LOAD NEXT ONE UP
        STX     -4,Y            ; MOVE DOWN BY ONE
        DECB                    ; ? DONE
        BPL     CBKDLM          ; NO, CONTINUE MOVE
        DEC     <BKPTCT         ; DECREMENT BREAKPOINT COUNT
CBKDSP  BSR     CBKSET          ; SETUP REGISTERS AND LOAD VALUE
        BEQ     CBKRTS          ; RETURN IF NONE TO DISPLY
CBKDSL  LEAX    ,Y++            ; POINT TO NEXT ENTRY
        SWI                     ; DISPLAY IN HEX
        FCB     OUT4HS          ; FUNCTION
        DECB                    ; COUNT DOWN
        BNE     CBKDSL          ; LOOP IF NGABLE RAM
        SWI                     ; SKIP TO NEW LINK
        FCB     PCRLF           ; FUNCTIONRTS
        RTS

* ADD NEW ENTRY
CBKADD  BSR     CBKSET          ; SETUP REGISTERS
        CMPB    #NUMBKP         ; ? ALREADY FULL
        BEQ     CBKERR          ; BRANCH ERROR IF SO
        LDA     ,X              ; LOAD BYTE TO TRAP
        STB     ,X              ; TRY TO CHANGE
        CMPB    ,X              ; ? CHANGEABLE RAM
        BNE     CBKERR          ; BRANCH ERROR IF NOT
        STA ,X                  ; RESTORE BYTE
CBKADL  DECB                    ; COUNT DOWN
        BMI     CBKADT          ; BRANCH IF DONE TO ADD IT
        CMPX    ,Y++            ; ? ENTRY ALREADY HERE
        BNE     CBKADL          ; LOOP IF NOT
CBKERR  LBRA    CMDBAD          ; RETURN TO ERROR PRODUCE
CBKADT  STX ,Y                  ; ADD THIS ENTRY
        CLR     -NUMBKP*2+1,Y   ; CLEAR OPTIONAL BYTE
        INC     <BKPTCT         ; ADD ONE TO COUNT
        BRA     CBKDSP          ; AND NOW DISPLAY ALL OF 'EM
* SETUP REGISTERS FOR SCAN
CBKSET  LDX     <NUMBER         ; LOAD VALUE DESIRED
CBKLDR  LEAY    BKPTBL,PCR      ; LOAD START OF TABLE
        LDB     <BKPTCT         ; LOAD ENTRY COUNT
        RTS                     ; RETURN

*****************ENCODE  -  ENCODE A POSTBYTE
CENCDE  CLR     ,-S             ; DEFAULT TO NOT INDIRECT
        CLRB                    ; ZERO POSTBYTE VALUE
        LEAX    <CONV1,PCR      ; START TABLE SEARCH
        SWI                     ; OBTAIN FIRST CHARACTER
        FCB     INCHNP          ; FUNCTION
        CMPA    #'[             ; ? INDIRECT HERE
        BNE     CEN2            ; BRANCH IF NOT
        LDA     #$10            ; SET INDIRECT BIT ON
        STA     ,S              ; SAVE FOR LATER
CENGET  SWI                     ; OBTAIN NEXT CHARACTER
        FCB     INCHNP          ; FUNCTION
CEN2    CMPA    #CR             ; ? END OF ENTRY
        BEQ     CEND1           ; BRANCH YES
CENLP1  TST     ,X              ; ? END OF TABLE
        BMI     CBKERR          ; BRANCH ERROR IF SO
        CMPA    ,X++            ; ? THIS THE CHARACTER
        BNE     CENLP1          ; BRANCH IF NOT
        ADDB    -1,X            ; ADD THIS VALUE
        BRA     CENGET          ; GET NEXT INPUT
CEND1   LEAX    <CONV2,PCR      ; POINT AT TABLE 2
        TFR     B,A             ; SAVE COPY IN A
        ANDA    #$60            ; ISOLATE REGISTER MASK
        ORA     ,S              ; ADD IN INDIRECTION BIT
        STA     ,S              ; SAVE BACK AS POSTBYTE SKELETON
        ANDB    #$9F            ; CLEAR REGISTER BITS
CENLP2  TST     ,X              ; ? END OF TABLE
        BEQ     CBKERR          ; BRANCH ERROR IF SO
        CMPB    ,X++            ; ? SAME VALUE
        BNE     CENLP2          ; LOOP IF NOT
        LDB     -1,X            ; LOAD RESULT VALUE
        ORB     ,S              ; ADD TO BASE SKELETON
        STB     ,S              ; SAVE POSTBYTE ON STACK
        LEAX    ,S              ; POINT TO IT
        SWI                     ; SEND OUT AS HEX
        FCB     OUT2HS          ; FUNCTION
        SWI                     ; TO NEXT LINE
        FCB     PCRLF           ; FUNCTION
        PULS    PC,B            ; END OF COMMAND

* TABLE ONE DEFINES VALID INPUT IN SEQUENCE
CONV1
        FCB     'A,$04,'B,$05,'D,$06,'H,$01
        FCB     'H,$01,'H,$01,'H,$00,',,$00
        FCB     '-,$09,'-,$01,'S,$70,'Y,$30
        FCB     'U,$50,'X,$10,'+,$07,'+,$01
        FCB     'P,$80,'C,$00,'R,$00,'],$00
        FCB     $FF             ; END OF TABLE

* CONV2 USES ABOVE CONVERSION TO SET POSTBYTE
* BIT SKELETON.
CONV2
        FDB     $1084,$1100     ; R,      H,R
        FDB     $1288,$1389     ; HH,R    HHHH,R
        FDB     $1486,$1585     ; A,R     B,R
        FDB     $168B,$1780     ; D,R     ,R+
        FDB     $1881,$1982     ; ,R++    ,-R
        FDB     $1A83,$828C     ; ,--R    HH,PCR
        FDB     $838D,$039F     ; HHHH,PCR [HHHH]
        FCB     0               ; END OF TABLE

****************************************************
*            DEFAULT INTERRUPT TRANSFERS           *
****************************************************
RSRVD   JMP     [VECTAB+.RSVD,PCR]      ; RESERVED VECTOR
SWI3    JMP     [VECTAB+.SWI3,PCR]      ; SWI3 VECTOR
SWI2    JMP     [VECTAB+.SWI2,PCR]      ; SWI2 VECTOR
FIRQ    JMP     [VECTAB+.FIRQ,PCR]      ; FIRQ VECTOR
IRQ     JMP     [VECTAB+.IRQ,PCR]       ; IRQ VECTOR
SWI     JMP     [VECTAB+.SWI,PCR]       ; SWI VECTOR
NMI     JMP     [VECTAB+.NMI,PCR]       ; NMI VECTOR

******************************************************
*            ASSIST09 HARDWARE VECTOR TABLE
* THIS TABLE IS USED IF THE ASSIST09 ROM ADDRESSES
* THE MC6809 HARDWARE VECTORS.
******************************************************
        ORG     ROMBEG+ROMSIZ-16 ; SETUP HARDWARE VECTORS
        FDB     RSRVD           ; RESERVED SLOT
        FDB     SWI3            ; SOFTWARE INTERRUPT 3
        FDB     SWI2            ; SOFTWARE INTERRUPT 2
        FDB     FIRQ            ; FAST INTERRUPT REQUEST
        FDB     IRQ             ; INTERRUPT REQUEST
        FDB     SWI             ; SOFTWARE INTERRUPT
        FDB     NMI             ; NON-MASKABLE INTERRUPT
        FDB     RESET           ; RESTART
