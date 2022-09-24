	list
;       NAM    OTHELLO
*****************************
* OTHELLO GAME
* BY UNKNOWN SOURCE
* RECOVERED FROM OLD FLOPPIES
*
* ADOPTED TO RUN ON THE MC3
* BY DANIEL TUFVESSON 2014
*****************************

;OUTCH  equ    $C003
;INCH   equ    $C006
;CONTRL equ    $C000

	if	~IN_SWTBUG
OUTCH  equ    $e1d1
INCH   equ    $e1ac
CONTRL equ    $e0e3

LF	equ	$0a
CR	equ	$0d
	endif

	bss
	org	$0020

TROW   rmb    1
TCOL   rmb    1
CROW   rmb    2
CPUTRY rmb    1
CPUSCR rmb    1
FORFIT rmb    1
ROW    rmb    1
COL    rmb    1
PIECE  rmb    1
       org    *
XXOO   fcc    'O'
WAIT   fcb    0         ;NO WAIT
STRTGY fcb    2         ;BEST STRATEGY
WHO1ST fcb    1         ;HUMAN FIRST
COUNT  rmb    1
TEMPX1 rmb    2
TEMP1  rmb    1
RDIR   rmb    1
CDIR   rmb    1

CPU    rmb    1
ME     rmb    1
TOTAL  rmb    1
FLAG   rmb    1
FLAG1  rmb    1
SCORE1 rmb    1
SCORE2 rmb    1
SCORE3 rmb    1
MATRIX rmb    8*8

	code
	if	~IN_SWTBUG
	org	$0100
	endif

Othello	ldx    #GREET	;	LDS    #$C07F    GREETINGS
       bsr    OUTIN
       cmpa   #'Y'
       bne    PROMT1
       bra    PROMT2

* SHOULD CPU WAIT?

PROMT1 ldx    #IWAIT
PROMT2 bsr    OUTIN     ;WAIT?
       clrb
       cmpa   #'Y'
       bne    STORWT
       jsr    PDATA9
       incb
STORWT stab   WAIT
       ldx    #BEST     ;STRATEGY?
       bsr    OUTIN
       clrb
       cmpa   #'N'
       beq    STORBT
       ldab   #2
STORBT stab   STRTGY
       ldx    #XORO     ;WANT X OR O ?
       bsr    OUTIN
       cmpa   #'X'
       beq    STORXO
       ldaa   #'O'
STORXO staa   XXOO
       ldx    #FIRST    ;MOVE?
       bsr    OUTIN
       clrb
       cmpa   #'N'
       beq    STOR1
       incb
STOR1  stab   WHO1ST
       jsr    PCRLF

* INITIAL BOARD

INITAL ldab   #'.'
       ldx    #MATRIX
ZAP    stab   0,x		;stab   0,X+
       inx
       cpx    #MATRIX+65
       bne    ZAP
       ldx    #$4F58    	;O X
       stx    MATRIX+27
       ldx    #$584F    	;X O
       stx    MATRIX+35

* INITIAL PIECE SCORE

       ldx    #$0204
       stx    CPU       	;CPU=ME=2
       stx    ME        	;TOTAL=4
       staa   FORFIT    	;=0

* PRINT INITIAL BOARD

       jsr    Print

* WHO'S FIRST?

       tst    WHO1ST
       beq    COMPTR
       jmp    HUMAN
OUTIN  jsr    PDATA9
INE    jsr    INCH 
       cmpa   #$1B      	;ESCAPE
       bne    rts1
       jmp    REPLAY
rts1   rts

* SHOULD CPU WAIT

COMPTR tst    WAIT
       beq    CPUGO
       bsr    INE

* SETUP CPU'S PIECE

CPUGO  ldaa   XXOO
       eora   #$17      	;FLIP
       staa   PIECE

* INITIAL VARIABLES

       ldaa   #64
       staa   CPUTRY
       clr    ROW
       clr    COL
       clr    CPUSCR
       clr    SCORE3

* CHECK FOR EMPTY SQUARE

TESTPT ldx    #ROW
       jsr    GETMTX
       cmpa   #'.'
       bne    NOGOOD

* TEST FOR PROPER NEIGHBOR

       jsr    PROPER
       tsta
       beq    NOGOOD

* CHECK FOR FLANKED ROW

       clr    FLAG
       jsr    SCORE
       ldab   SCORE1
       beq    NOGOOD

* BEST MOVE SO FAR?

       ldaa   ROW
       beq    CKROW
       cmpa   #7
       bne    CKROW1
CKROW  addb   STRTGY
CKROW1 ldaa   COL
       beq    ADSTRT
       cmpa   #7
       bne    CKSCOR
ADSTRT addb   STRTGY
CKSCOR cmpb   CPUSCR
       bhi    STCPUS
       bne    NOGOOD
       bitb   #1        ;RANDOM CHOICE
       beq    NOGOOD

* FOUND BETTER MOVE FOR CPU

STCPUS ldaa   SCORE1
       staa   SCORE3
       stab   CPUSCR
       ldx    ROW
       stx    CROW

* ALL SQ'S TESTED?

NOGOOD dec    CPUTRY
       beq    TSTSCR

* TRY AGAIN

       clrb
       inc    COL
       ldaa   COL
       cmpa   #7
       bls    DOROW
       stab   COL
       incb
DOROW  ldaa   ROW
       aba
       staa   ROW
       bra    TESTPT

* ANY CAPTURED?

TSTSCR tst    SCORE3
       beq    CPUFOR

* UPDATE SCORES

GOODMV clr    FORFIT
       ldaa   CPU
       adda   SCORE3
       inca
       staa   CPU
       ldaa   ME
       suba   SCORE3
       staa   ME
       inc    TOTAL

* PRINT CPU'S MOVE

       ldx    #IMOVE
       jsr    PDATA9
       ldaa   CROW
       adda   #$31      ;MAKE ASCII
       jsr    OUTCH 
       ldaa   CROW+1
       adda   #$41      ;MAKE ASCII LETTER
       jsr    OUTCH     ;OUTPUT LETTER

* PRINT # CAPTURED

       ldx    #THAT1
       jsr    PDATA9    ;THAT GIVES ME
       ldx    #SCORE3
       jsr    PRTDEC
       ldx    #YOUR
       jsr    PDATA9    ;YOUR PIECES

* FLIP CAPTURED PIECES

       ldx    CROW
       stx    ROW
       inc    FLAG
       jsr    SCORE
       jsr    Print

* TEST FOR END OF GAME

       ldaa   ME
       beq    THEND
TSTTOT ldaa   TOTAL
       cmpa   #64
       bne    HUMAN
THEND  jmp    THEEND

* CPU FORFITS MOVE

CPUFOR ldx    #CPU0
       jsr    PDATA9
       ldaa   FORFIT
       bne    THEND
       inc    FORFIT

* GET HUMAN'S ROW,COL I/P

HUMAN  ldaa   XXOO
       staa   PIECE
       ldx    #MOVE
       jsr    OUTIN
       cmpa   #'X'
       bne    CHKCOL
       jsr    Print
       bra    HUMAN
CHKCOL cmpa   #'8'
       bhi    HUMFOR
       suba   #$31
       bcs    HUMFOR
       staa   ROW
       jsr    INE
       cmpa   #'H'
       bhi    HUMFOR
       suba   #$41      ;=A
       bcs    HUMFOR
       staa   COL

* OCCUPIED SQ?

       ldx    #ROW
       jsr    GETMTX
       ldx    #SORRY
       cmpa   #'.'
       bne    PRNT2

* PROPER NEIGHBOR?

EMPTY  jsr    PROPER
       ldx    #NONEXT
       tsta
       beq    PRNT2

* FLANK?

CKFLNK clr    FLAG
       jsr    SCORE
       tst    SCORE1
       bne    LEGAL
       ldx    #NOFLNK
PRNT2  jsr    PDATA9
HUM1   bra    HUMAN

* ALL LEGAL

LEGAL  clr    FORFIT
       ldx    #THAT
       jsr    PDATA9
       ldx    #SCORE1
       jsr    PRTDEC
       ldx    #OFMY
       jsr    PDATA9

* UPDATE SCORES

       ldaa   ME
       adda   SCORE1
       inca
       staa   ME
       ldaa   CPU
       suba   SCORE1
       staa   CPU
       inc    TOTAL

* FLIP BOARD PIECES

       inc    FLAG
       jsr    SCORE
       jsr    Print

* TEST FOR END OF GAME

       ldaa   CPU
       beq    THEEND
       ldaa   TOTAL
       cmpa   #64
       beq    THEEND
GOCPU  jmp    COMPTR

* HUMAN FORFITS MOVE

HUMFOR ldx    #HUM0
       jsr    OUTIN
       cmpa   #'Y'
       bne    HUM1
BYEBYE jsr    PCRLF
       ldaa   FORFIT
       bne    THEEND
       inc    FORFIT
       bra    GOCPU
THEEND ldx    #YOUHAV
       jsr    PDATA9
       ldx    #ME
       jsr    PRTDEC
       ldx    #ANDI
       jsr    PDATA9
       ldx    #CPU
       jsr    PRTDEC
       ldx    #PTEXT
       jsr    PDATA9

* DETERMINE WINNER

       ldx    #ATIE     ;TIE
       ldaa   ME
       cmpa   CPU
       beq    PRNT1     ;TIE
       bhi    HUMWON
       ldx    #IWON
       jsr    PDATA9
       ldab   CPU
       subb   ME
       bra    HOWBAD
HUMWON ldx    #MEWON
       jsr    PDATA9
       ldab   ME
       subb   CPU

* HOW BAD WAS OTHER GUY TROUNCED?

HOWBAD ldx    #TTYPE
       jsr    PDATA9
       ldx    #PERFCT
       cmpb   TOTAL
       beq    PRNT1     ;PERFECT GAME
       ldx    #SQEAK
       cmpb   #5
       bls    PRNT1     ;SQUEAKER
       ldx    #HOT
       cmpb   #10
       bls    PRNT1     ;HOT GAME
       ldx    #FIGHT
       cmpb   #15
       bls    PRNT1     ;FIGHT!
       ldx    #WALK     ;WALKAWAY!
PRNT1  jsr    PDATA9
REPLAY ldx    #ANOTHR   ;PLAY AGAIN?
       jsr    OUTIN
       cmpa   #'N'
       beq    FIN
       jsr    PCRLF
       jmp    INITAL
FIN    ldx    #THANX
       jsr    PDATA9
	if	IN_SWTBUG
	jmp	ExtCmd
	else
	jmp	CONTRL
	endif

*********************
* STORMX SUBROUTINE *
*********************

STORMX bsr    GETMTX    ;POINT TO PLACE
       ldaa   PIECE
       staa   0,x
       rts

*********************
* GETMTX SUBROUTINE *
*********************

GETMTX ldaa   0,x       ;PASSED ROW # (0-7)
       ldab   1,x       ;PASSED COL # (0-7)
       asla             ;MULTIPLY
       asla             ;BY
       asla             ;EIGHT
       ldx    #MATRIX   ;START ADDR
       aba
       beq    LOADA
BUILDX inx    		;BUMP
       deca
       bne    BUILDX
LOADA  ldaa   0,x       ;MATRIX ELEMENT REQ'D
       rts

*********************
* PROPER SUBROUTINE *
*********************

PROPER ldaa   PIECE     ;OTHER PLAYER'S PIECE
       eora   #$17      ;FLIP
       staa   TEMP1
       ldaa   #8        ;8 NEIGHBORS
       staa   COUNT     ;TO CHECK
       ldx    #NEIBOR   ;START ADDR
       stx    TEMPX1    ;OF NEIGHBOR
GETROW ldab   ROW       ;ROW COORD
       ldaa   0,x       ;ROW'S DIRECTION
       beq    SETR      ;=0
       bmi    MROW      ;=-
AROW   incb
       cmpb   #7        ;OFF OF BOARD
       bhi    NONEIB    ;YES
       bra    SETR      ;NO
MROW   tstb             ;OFF OF BOARD
       beq    NONEIB    ;YES
       decb             ;NO
SETR   stab   TROW      ;STORE NEIGHBOR'S ROW #
GETCOL ldab   COL       ;COL COORD
       ldx    TEMPX1    ;COL'S
       ldaa   1,x       ;DIRECTION
       beq    SETC      ;=0
       bmi    MCOL      ;=-
ACOL   incb
       cmpb   #7        ;OFF OF BOARD
       bhi    NONEIB    ;YES
       bra    SETC      ;NO
MCOL   tstb             ;OFF OF BOARD
       beq    NONEIB    ;YES
       decb             ;NO
SETC   stab   TCOL      ;STORE NEIGHBOR'S COL #
       ldx    #TROW     ;GET PIECE
       bsr    GETMTX    ;AT NEIGHBOR'S COORDS
       cmpa   TEMP1     ;GET OTHER PLAYER'S PIECE
       beq    rts2      ;IS PROPER

* NO NEIGHBOR

NONEIB ldx    TEMPX1
       inx              ;BUMP NEIGHBOR POINTER
       inx
       stx    TEMPX1
       dec    COUNT     ;DEC COUNT
       bne    GETROW    ;OF ENTRIES TO CHECK
       clra             ;FLAG=NO NEIGHBOR
rts2   rts
NEIBOR fcb    0,1       ;DOWN
       fcb    $FF,1     ;LOWER-LEFT
       fcb    $FF,0     ;LEFT
       fcb    $FF,$FF   ;UPPER-LEFT
       fcb    0,$FF     ;UP
       fcb    1,$FF     ;UPPER-RIGHT
       fcb    1,0       ;RIGHT
       fcb    1,1       ;LOWER RIGHT

********************
* PRINT SUBROUTINE *
********************

Print	ldx	#LETTERa
       jsr    PDATA9
       ldx    #MATRIX
       ldaa   #'0'
BOARD  inca
       staa   COUNT
       jsr    OUTCH     ;LINE #
       ldab   #8        ;8 CHARS TO PRINT
EIGHT  ldaa   #$20
       jsr    OUTCH     ;SPACE
       ldaa   0,x       ;OUTPUT
       jsr    OUTCH     ;CHAR
       inx    		;BUMP CHAR PTR
       decb             ;DEC CHAR COUNT
       bne    EIGHT     ;MORE TO DO
       bsr    PCR
       ldaa   COUNT
       cmpa   #'8'
       bne    BOARD     ;BOARD
PCR    jmp    PCRLF

********************
* SCORE SUBROUTINE *
********************

SCORE  tst    FLAG      ;HERE FOR SCORE ONLY
       beq    NOSTOR    ;YES
       ldx    #ROW
       jsr    STORMX    ;PUT PIECE ON BOARD
NOSTOR clr    SCORE1    ;ZERO OVERALL CTR
       ldaa   #8
       staa   COUNT     ;8 NEIGHBORS TO CHECK
       ldx    #NEIBOR   ;START ADDR
       stx    TEMPX1    ;OF NEIGHBOR
LOOP1b ldx    TEMPX1    ;ADDR OF 'NEW' NEIGHBORS
       ldaa   0,x
       staa   RDIR      ;ROW VECT
       ldaa   1,x
       staa   CDIR      ;COL VECT
       clr    FLAG1     ;ZERO STORAGE FLAG
LOOP1A ldaa   ROW       ;PASSED ROW #
       staa   TROW
       ldaa   COL       ;PASSED COL #
       staa   TCOL
       clr    SCORE2    ;ZERO INTERMEDIATE SCORE
LOOP2b  ldaa   RDIR      ;ROW VECT
       beq    NEWCOL    ;=0
       bmi    NROW      ;=-
PROW   inc    TROW      ;TROW=TROW+1
       ldaa   TROW
       cmpa   #7        ;OFF OF BOARD
       bhi    END1      ;YES
       bra    NEWCOL    ;NO
NROW   tst    TROW      ;OFF OF BOARD
       beq    END1      ;YES
       dec    TROW      ;ROW=ROW-1
NEWCOL ldaa   CDIR      ;COL VECT
       beq    CHECK     ;=0
       bmi    NCOL      ;=-
PCOL   inc    TCOL      ;COL=COL+1
       ldaa   TCOL
       cmpa   #7        ;OFF OF BOARD
       bhi    END1      ;YES
       bra    CHECK
NCOL   tst    TCOL      ;OFF OF BOARD
       beq    END1      ;YES
       dec    TCOL      ;COL=COL-1
CHECK  ldx    #TROW     ;GET PIECE
       jsr    GETMTX    ;AT TROW,TCOL
       tab
       ldaa   PIECE     ;GET OPPONENTS CODE
       eora   #$17      ;FLIP
       cba              ;CAPTURED OPPONENT'S PIECE
       bne    ISME      ;NO
       inc    SCORE2    ;YES
       tst    FLAG1     ;STORE IT?
       beq    LOOP2b     ;NO
       ldx    #TROW     ;YES
       jsr    STORMX
       bra    LOOP2b
ISME   cmpb   PIECE     ;FOUND ONE OF MY PIECES
       bne    END1      ;NO-FOUND BLANK
       tst    FLAG1     ;HERE ON SCORE PASS
       bne    TEST      ;NO
       ldaa   SCORE2    ;UPDATE
       adda   SCORE1    ;# PIECES
       staa   SCORE1    ;CAPTURED
TEST   tst    FLAG      ;FOR REAL?
       beq    END1      ;NO
       tst    FLAG1     ;OPPONENT'S PIECES FLIPPED YET
       bne    END1      ;YES
       inc    FLAG1     ;NO-SET FLAG
       bra    LOOP1A    ;FLIP OPPONENT
END1   ldaa   TEMPX1+1
       adda   #2        ;UPDATE
       ldab   TEMPX1    ;NEIGHBOR
       adcb   #0        ;POINTER
       staa   TEMPX1+1
       stab   TEMPX1
       dec    COUNT     ;ALL CHECKED?
       beq    RETURNb    ;YES
       jmp    LOOP1b
RETURNb rts

********************
*PRTDEC SUBROUTINE *
********************

PRTDEC ldab   0,x       ;LOAD PASSED HEX #
       clra             ;ZERO HIGH ORDER DIGIT
DECLOP inca
       subb   #10       ;NN=NN-10
       bcc    DECLOP
       addb   #10       ;RESTORE B
       deca
       beq    OUTB      ;SUPPRESS LEADING ZERO
       bsr    OUTASC
OUTB   tba
OUTASC adda   #'0'
       jmp    OUTCH 

*********************
* PDATA9 SUBROUTINE *
*********************

PDATAa bsr    OUTE
PDATA9 ldaa   0,x
       inx
       cmpa   #'^'
       bne    CKCR
       ldaa   #$10
       bsr    CLRSCN    ;CLEAR SCREEN
CKCR   cmpa   #$0D       ;C.R.?
       bne    CKEND
       bsr    PCRLF     ;C.R. L.F.
CKEND  cmpa   #';'
       bne    PDATAa
       rts
PCRLF  ldaa   #$D
       bsr    OUTE
       ldaa   #$A
CLRSCN bsr    OUTE
NUL4   bsr    NUL2
NUL2   bsr    NUL1
NUL1   clra
OUTE   jmp    OUTCH 

GREET	db	CR,LF,LF
       fcc    "GREETINGS FROM OTHELLO"
	db	CR,LF
INST0  fcc    "DO YOU WANT INSTRUCTIONS? ;"
INST1  	db	CR
	fcc    "OTHELLO IS PLAYED ON AN "
       fcc    "8 BY 8 CHECKER BOARD WITH"
	db	CR
       fcc    "ROWS NUMBERED 1 TO 8 "
       fcc    "AND COLUMNS A TO H."
	db	CR
       fcc    "THE INITIAL CONFIGURATION "
       fcc    "IS ALL BLANK EXCEPT"
	db	CR
       fcc    "FOR THE CENTER FOUR SQUARES, "
       fcc    "WHICH FORM THE PATTERN:"
	db	CR
       fcc    "          O X"
	db	CR
       fcc    "          X O"
	db	CR
       fcc    "PUT YOUR PIECE SO THAT MINE IS "
       fcc    "BETWEEN 2 OF YOURS, SUCH AS:"
	db	CR
	db	"        X O X",CR
	db	"          X O",CR
       fcc    "THIS WILL 'FLIP' MY TOP 'O' INTO YOUR 'X'"
	db	CR
       fcc    "NOTE: YOU MAY CAPTURE 1 OR MORE OF "
       fcc    "MY PIECES THIS WAY,"
	db	CR
       fcc    "OR YOU MAY FORFEIT BY TYPING 'Z';"
IWAIT  	db	CR,LF
	fcc    "SHOULD I WAIT BEFORE "
       fcc    "MAKING MY MOVES? ;"
OKWAIT 	db	CR
	fcc	"OK. TYPING ANY CHARACTER "
	fcc	"WILL LET ME GO!"
	db	CR,';'
BEST  	db	CR
	fcc	"SHOULD I PLAY MY BEST STRATEGY? ;"
SORRY	db	CR
	fcc    "SORRY, THAT SQUARE IS OCCUPIED. TRY AGAIN!;"
MOVE	fcc	"YOUR MOVE--(ROW,COL)?;"
XORO	db	CR
	fcc	"DO YOU WANT TO HAVE X OR O?;"
FIRST	db	CR
	fcc	"DO YOU WANT TO GO FIRST?;"
NONEXT fcc	"SORRY, YOU ARE NOT NEXT TO "
       fcc	"ONE OF MY PIECES. TRY AGAIN!;"
NOFLNK	db	CR
	fcc    "SORRY, THAT MOVE DOES NOT FLANK A ROW. TRY AGAIN!;"
THAT	db	CR
	fcc	"THAT GIVES YOU ;"
OFMY	fcc	" OF MY PIECES;"
YOUHAV fcb    7
       fcc    "YOU HAVE ;"
ANDI   fcc    " PIECES AND I HAVE ;"
PTEXT  fcc    " PIECES!;"
IWON	db	CR
	fcc    "SORRY, I WON THAT ONE!  ;"
ATIE   fcc    "A TIE!;"
MEWON	db	CR
	fcc    "YOU WON!!  ;"
TTYPE  fcc    "THAT WAS A ;"
PERFCT fcc    "PERFECT GAME!;"
WALK   fcc    "WALKAWAY!;"
FIGHT  fcc    "FIGHT!;"
HOT    fcc    "HOT GAME!;"
SQEAK  fcc    "SQUEAKER!;"
ANOTHR	db	CR,LF
	fcc    "DO YOU WANT TO PLAY ANOTHER GAME? ;"
THANX	db	CR,LF
	fcc	"THANKS FOR PLAYING!"
	db	CR,LF,';'
IMOVE	db	CR
	fcc    "I MOVE TO ;"
THAT1	db	CR
	fcc	"THAT GIVES ME ;"
YOUR	fcc	" OF YOUR PIECES.;"
CPU0   fcc    "I HAVE TO FORFIT MY MOVE!"
	db	CR,';'
HUM0	db	CR
	fcc    "ARE YOU FORFEITING "
       fcc    "YOUR TURN (Y OR N)? ;"
LETTERa	db	CR
	fcc    "  A B C D E F G H"
	db	CR,';'


