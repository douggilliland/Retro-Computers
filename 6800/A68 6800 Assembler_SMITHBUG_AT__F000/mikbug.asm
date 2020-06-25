        NAM    MIKBUG
*      REV 009
*      COPYRIGHT 1974 BY MOTOROLA INC
*
*      MIKBUG (TM)
*
*      L  LOAD
*      G  GO TO TARGET PROGRAM
*      M  MEMORY CHANGE
*      F  PRINTIPUNCH DUMP
*      R  DISPLAY CONTENTS OF TARGET STACK
*            CC   B   A   X   P   S
PIASB   EQU    $8007
PIADB   EQU    $8006     B DATA
PIAS    EQU    $8005     PIA STATUS
PIAD    EQU    $8004     PIA DATA
*       OPT    MEMORY
        ORG    $E000

*     I/O INTERRUPT SEQUENCE
IO      LDX    IOV
        JMP    X

* NMI SEQUENCE
POWDWN  LDX    NIO       GET NMI VECTOR
        JMP    X

LOAD    EQU    *
        LDA A  #$3C
        STA A  PIASB     READER RELAY ON
        LDA A  #@21
        BSR    OUTCH     OUTPUT CHAR

LOAD3   BSR    INCH
        CMP A  #'S
        BNE    LOAD3     1ST CHAR NOT (S)
        BSR    INCH      READ CHAR
        CMP A  #'9
        BEQ    LOAD21
        CMP A  #'1
        BNE    LOAD3     2ND CHAR NOT (1)
        CLR    CKSM      ZERO CHECKSUM
        BSR    BYTE      READ BYTE
        SUB A  #2
        STA A  BYTECT    BYTE COUNT
* BUILD ADDRESS
        BSR    BADDR
* STORE DATA
LOAD11  BSR    BYTE

        DEC    BYTECT
        BEQ    LOAD15    ZERO BYTE COUNT
        STA A  X         STORE DATA
        INX
        BRA    LOAD11

LOAD15  INC    CKSM
        BEQ    LOAD3
LOAD19  LDA A  #'?       PRINT QUESTION MARK
        BSR    OUTCH
LOAD21  EQU    *
C1      JMP    CONTRL

* BUILD ADDRESS
BADDR   BSR    BYTE      READ 2 FRAMES
        STA A  XHI
        BSR    BYTE
        STA A  XLOW
        LDX    XHI       (X) ADDRESS WE BUILT
        RTS

*INPUT BYTE (TWO FRAMES)
BYTE    BSR    INHEX     GET HEX CHAR
        ASL A
        ASL A
        ASL A
        ASL A
        TAB
        BSR    INHEX
        ABA
        TAB
        ADD B  CKSM
        STA B  CKSM
        RTS

OUTHL   LSR A            OUT HEX LEFT BCD DIGIT
        LSR A
        LSR A
        LSR A

OUTHR   AND A  #$F       OUT HEX RIGHT BCD DIGIT
        ADD A  #$30
        CMP A  #$39
        BLS    OUTCH
        ADD A  #$7

* OUTPUT ONE CHAR
OUTCH   JMP    OUTEEE
INCH    JMP    INEEE

* PRINT DATA POINTED AT BY X-REG
PDATA2  BSR    OUTCH
        INX
PDATA1  LDA A  X
        CMP A  #4
        BNE    PDATA2
        RTS              STOP ON EOT

* CHANGE MENORY (M AAAA DD NN)
CHANGE  BSR    BADDR     BUILD ADDRESS
CHA51   LDX    #MCL
        BSR    PDATA1    C/R L/F
        LDX    #XHI
        BSR    OUT4HS    PRINT ADDRESS
        LDX    XHI
        BSR    OUT2HS    PRINT DATA (OLD)
        STX    XHI       SAYE DATA ADDRESS
        BSR    INCH      INPUT ONE CHAR
        CMP A  #$20
        BNE    CHA51     NOT SPACE
        BSR    BYTE      INPUT NEW DATA
        DEX
        STA A  X         CHANGE MEMORY
        CMP A  X
        BEQ    CHA51     DID CHANGE
        BRA    LOAD19    NOT CHANGED

* INPUT HEX CHAR
INHEX   BSR    INCH
        SUB A  #$30
        BMI    C1        NOT HEX
        CMP A  #$09
        BLE    IN1HG
        CMP A  #$11
        BMI    C1        NOT HEX
        CMP A  #$16
        BGT    C1        NOT HEX
        SUB A  #7
IN1HG   RTS

OUT2H   LDA A  0,X       OUTPUT 2 HEX CHAR
OUT2HA  BSR    OUTHL     OUT LEFT HEX CHAR
        LDA A  0,X
        INX
        BRA    OUTHR     OUTPUT RIGHT HEX CHAR AND R

OUT4HS  BSR    OUT2H     OUTPUT 4 HEX CHAR + SPACE
OUT2HS  BSR    OUT2H     OUTPUT 2 HEX CHAR + SPACE

OUTS    LDA A  #$20      SPACE
        BRA    OUTCH     (BSR & RTS)

* ENTER POWER  ON SEQUENCE
START   EQU    *
        LDS    #STACK
        STS    SP        INZ TARGET'S STACK PNTR
* INZ PIA
        LDX    #PIAD     (X) POINTER TO DEVICE PIA
        INC    0,X       SET DATA DIR PIAD
        LDA A  #$7
        STA A  1,X       INIT CON PIAS
        INC    0,X       MARK COM LINE
        STA A  2,X       SET DATA DIR PIADB
CONTRL  LDA A  #$34
        STA A  PIASB     SET CONTROL PIASB TURN READ
        STA A  PIADB     SET TIMER INTERVAL
        LDS    #STACK    SET CONTRL STACK POINTER
        LDX    #MCLOFF

        BSR    PDATA1    PRINT DATA STRING

        BSR    INCH      READ CHARACTER
        TAB
        BSR    OUTS      PRINT SPACE
        CMP B  #'L
        BNE    *+5
        JMP    LOAD
        CMP B  #'M
        BEQ    CHANGE
        CMP B  #'R
        BEQ    PRINT     STACK
        CMP B  #'P
        BEQ    PUNCH     PRINT/PUNCH
        CMP B  #'G
        BNE    CONTRL
        LDS    SP        RESTORE PGM'S STACK PTR
        RTI              GO

* ENTER FROM SOFTVARE INTERRUPT
SFE     EQU    *
        STS    SP        SAVE TARGET'S STACK POINTER
* DECREMENT P-COUNTER
        TSX
        TST    6,X
        BNE    *+4
        DEC    5,X
        DEC    6,X

* PRINT CONTENTS OF STACK
PRINT   LDX    SP
        INX
        BSR    OUT2HS    CONDITION CODES
        BSR    OUT2HS    ACC-B
        BSR    OUT2HS    ACC-A
        BSR    OUT4HS    X-REG
        BSR    OUT4HS    P-COUNTER
        LDX    #SP
        BSR    OUT4HS    STACK POINTER
C2      BRA    CONTRL

* PUNCH DUMP
* PUNCH FROM BEGINING ADDRESS (BEGA) THRU ENDI
* ADDRESS (ENDA)
*
MTAPE1  FCB    $D,$A,0,0,0,0,'S,'1,4 PUNCH FORMAT


PUNCH   EQU    *

        LDA A  #$12      TURN TTY PUNCH ON
        JSR    OUTCH     OUT CHAR  

        LDX    BEGA
        STX    TW        TEMP BEGINING ADDRESS
PUN11   LDA A  ENDA+1
        SUB A  TW+1
        LDA B  ENDA
        SBC B  TW
        BNE    PUN22
        CMP A  #16
        BCS    PUN23
PUN22   LDA A  #15
PUN23   ADD A  #4
        STA A  MCONT     FRAME COUNT THIS RECORD
        SUB A  #3
        STA A  TEMP      BYTE COUNT THIS RECORD
* PUNCH C/R,L/F,NULL,S,1
        LDX    #MTAPE1
        JSR    PDATA1
        CLR B            ZERO CHECKSUM
* PUNCH FRAME COUNT
        LDX    #MCONT
        BSR    PUNT2     PUNCH 2 HEX CHAR
* PUNCH ADDRESS
        LDX    #TW
        BSR    PUNT2
        BSR    PUNT2
* PUNCH DATA
        LDX    TW
PUN32   BSR    PUNT2     PUNCH ONE BYTE (2 FRAMES)
        DEC    TEMP      DEC BYTE COUNT
        BNE    PUN32
        STX    TW
        COM B
        PSH B
        TSX
        BSR    PUNT2     PUNCH CHECKSUM
        PUL B            RESTORE STACK
        LDX    TW
        DEX
        CPX    ENDA
        BNE    PUN11
        BRA    C2        JMP TO CONTRL

* PUNCH 2 HEX CHAR UPDATE CHECKSUM
PUNT2   ADD B  0,X       UPDATE CHECKSUM
        JMP    OUT2H     OUTPUT TWO HEX CHAR AND RTS


MCLOFF  FCB    $13       READER OFF
MCL     FCB    $D,$A,$14,0,0,0,'*,4 C/R,L/F,PUNCH

*
SAV     STX    XTEMP
        LDX    #PIAD
        RTS

*INPUT   ONE CHAR INTO A-REGISTER
INEEE   PSH B            SAVE ACC-B
        BSR    SAV       SAV XR
IN1     LDA A  0,X       LOOK FOR START BIT
        BMI    IN1
        CLR    2,X       SET COUNTER FOR HALF BIT TI
        BSR    DE        START TIMER
        BSR    DEL       DELAY HALF BIT TIME
        LDA B  #4        SET DEL FOR FULL BIT TIME
        STA B  2,X
        ASL B            SET UP CNTR WITH 8

IN3     BSR    DEL       WAIT ONE CHAR TIME
        SEC              NARK CON LINE
        ROL    0,X       GET BIT INTO CFF
        ROR A            CFF TO AR
        DEC B
        BNE    IN3
        BSR    DEL       WAIT FOR STOP BIT
        AND A  #$7F      RESET PARITY BIT
        CMP A  #$7F
        BEQ    IN1       IF RUBOUT, GET NEXT CHAR
        BRA    IOUT2     GO RESTORE REG

* OUTPUT ONE CHAR 
OUTEEE  PSH B            SAV BR
        BSR    SAV       SAV XR
IOUT    LDA B  #$A       SET UP COUNTER
        DEC    0,X       SET START BIT
        BSR    DE        START TIMER
OUT1    BSR    DEL       DELAY ONE BIT TIME
        STA A  0,X       PUT OUT ONE DATA BIT
        SEC              SET CARRY BIT
        ROR A            SHIFT IN NEXT BIT
        DEC B            DECREMENT COUNTER
        BNE    OUT1      TEST FOR 0
IOUT2   LDA B  2,X       TEST FOR STOP BITS
        ASL B            SHIFT BIT TO SIGN
        BPL    IOS       BRANCH FOR 1 STOP BIT
        BSR    DEL       DELAY-FOR STOP BITS
IOS     LDX    XTEMP     RES XR
        PUL B            RESTORE BR
        RTS

DEL     TST    2,X       IS TIME UP
        BPL    DEL
DE      INC    2,X       RESET TIMER
        DEC    2,X
        RTS

        FDB    IO
        FDB    SFE
        FDB    POWDWN
        FDB    START
        ORG    $A000
IOV     RMB    2         IO INTERRUPT POINTER
BEGA    RMB    2         BEGINING ADDR PRINT/PUNCH
ENDA    RMB    2         ENDING ADDR PRINT/PUNCH
NIO     RMB    2         NMI INTERRUPT POINTER
SP      RMB    1         S-HIGH
        RMB    1         S-LOW
CKSM    RMB    1         CHECKSUM

BYTECT  RMB    1         BYTE COUNT
XHI     RMB    1         XREG HIGH
XLOW    RMB    1         XREG LOW
TEMP    RMB    1         CHAR COUNT (INADD)
TW      RMB    2         TEMP/
MCONT   RMB    1         TEMP
XTEMP   RMB    2         X-REG TEMP STORAGE
        RMB    46
STACK   RMB    1         STACK POINTER


        END    
