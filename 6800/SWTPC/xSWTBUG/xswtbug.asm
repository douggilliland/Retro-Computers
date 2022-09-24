		title	"xSWTBUG v1.2.1"
;***************************************************
;REPLACEMENT FOR MIKBUG ROM
;FOR SWTPC 6800 COMPUTER SYSTEM
;COPYRIGHT 1977
;SOUTHWEST TECHNICAL PROD. CORP.
;AUGUST, 1977
;***************************************************
;
; Enhancements by Bob Applegate, K2UT
; bob@corshamtech.com
; www.corshamtech.com
;
; This was all done for the SWTBUG included with the
; Corsham Tech 6800 CPU board.
;
; I MAKE NO COPYRIGHT CLAIMS!  The original code is
; on the Internet and I simply copied and modified it,
; so all my changes are free to use.
;
; Last edit: 05/27/2016
;
; Source was converted to use the AS02 assembler:
;
;    http://www.kingswood-consulting.co.uk/assemblers/
;
; I prefer this assembler because it gives me nice
; macros and conditional assembly.  It also uses
; traditional pseudo-ops instead of the strange
; Motorola ones.
;
; This includes extensions that can optionally
; be compiled in.  Look near ExtCmd for the new
; code.  I needed to add more commands without
; disrupting anything in the original SWTBUG, so
; the 'C' command has been replaced by the 'X'
; command which goes into the extended command set.
;
; 1.2   - Includes logic for handling the Corsham Tech
;         SD card interface board.
; 1.2.1 - Added a version string at start-up
;
;***************************************************
; Various constants
;
false		equ	0
true		equ	~false
;
; Version and revision values.  Version.Revision
;
VERSION		equ	1
REVISION	equ	2
;
; So included programs know that they are being
; built as part of SWTBUG and don't need to define
; as much.
;
IN_SWTBUG	equ	true
;
; If this is true, then add support for S5 records
; in the "L" command.  Moves some code into the
; extended area.  The original SWTBUG only supported
; S9 for end of file.
;
SUPPORT_S5	equ	true
;
;***************************************************
; User options and tuning parameters...
;
; Number of address bits in EPROM.  This is used
; to calculate the vector addresses.  For Corsham
; Technologies 6800 CPU boards, the value is 13.
;
ADDR_BITS	equ	13
;
; Start of ROM and RAM regions
;
RAM_BASE	equ	$a000
ROM_BASE	equ	$e000
;
; If NO_WEIRD is set, then don't put out tape reader
; control codes in prompts.  Many people are using
; terminal programs running on computers which
; interpret the control codes and display them as
; weird symbols.  Turning on this option will stop
; those weird symbols from coming out.
;
NO_WEIRD	equ	true
;
; If set, add the extended SWTBUG.  Else just have
; the standard set of commands.
;
EXTENDED	equ	true
;
; These are options if EXTENDED is on...
;
SD_SUPPORT	equ	true	;include SD card funcs
SD_CMDS		equ	true	;adds SD card commands
SD_BOOT		equ	true	;boot from SD card
BOOT_ADDR	equ	$a100	;where boot sector goes
;
NUMGUESS	equ	true	;include NumGuess game
MEMTEST		equ	true	;include Memory tester
OTHELLO		equ	true	;include Othello game
;
; To support running with either 6800 or 6809
; motherboards, these two options allow you to set
; the base address of the I/O block and also the
; number of addresses for each I/O slot.
;
; For 6800:
;    IOBASE is $8000
;    IOBYTES is 4
;
; For 6809:
;    IOBASE is $e000
;    IOBYTES is 16
;
IOBASE		equ	$8000
IOBYTES		equ	4
;
; CONSLOT is the slot that the console port is plugged
; into.  SWTPC always uses 1.
;
CONSLOT		equ	1
;
;***************************************************
; Common ASCII control codes
;
EOT		equ	$04
BEL		equ	$07
BS		equ	$08
LF		equ	$0a
CR		equ	$0d
DEL		equ	$7f
;
;***************************************************
; This macro is used to verify that the current
; address meets a required value.  Used mostly to
; guarantee changes don't cause entry points to
; move.  These are used right before documented
; entry points.
;
VERIFY		macro	expected
		if * != expected
		fail	Not at requested address (expected)
		endif
		endm
;
;***************************************************
; More constants.  You definitely don't want to
; change CTLPOR but the PROM address and stack size
; could be.  Beware that changing the stack size
; pushes other things around.
;
CTLPOR		equ	IOBASE+(IOBYTES*CONSLOT)	;CONTROL PORT ADDRESS
PROM		equ	$C000	;JUMP TO PROM ADDRESS
STACK_SIZE	equ	$2b
		page
;***************************************************
; RAM
;
		bss
		org	RAM_BASE
IRQ		ds	2	;IRQ POINTER
BEGA		ds	2	;BEGINNING ADDR PNCH
ENDA		ds	2	;ENDING ADDR PNCH
NMI		ds	2	;NMI INTERRUPT VECTOR
SP		ds	1	;S HIGH
		ds	1	;S LOW
PORADD		ds	2	;PORT ADDRESS
PORECH		ds	1	;ECHO ON/OFF FLAG
XHI		ds	1	;XREG HIGH
XLOW		ds	1	;XREG LOW
CKSM		ds	1	;CHECKSUM
XTEMP		ds	2	;X-REG TEMP STGE
SWIJMP		ds	2	;SWI JUMP VECTOR
BKPT		ds	2	;BREAKPOINT ADDRESS
BKLST		ds	1	;BREAKPOINT DATA
		ds	STACK_SIZE
STACK		ds	1	;SWTBUG STACK
		ds	1
TW		ds	2	;TEMPORARY STORAGE
TEMP		ds	1	;TEMPORARY STORAGE
BYTECT		ds	1	;BYTECT AND MCONT TEMP.
;
; The locations A048 and A049 contain the address where
; the RTI instruction jumps.  It's often loaded with the
; address of a program just loaded from tape so the "G"
; command will execute it.
;
		VERIFY	$a048
RTIVEC		ds	2

	if	SD_CMDS
NAMESIZE	equ	12
FnBuffer	ds	3	;formatting area
Filename	ds	NAMESIZE+1	;xxxxxxxx.xxx
sdState		ds	1
temp		ds	1
tempx		ds	2
byteCnt		ds	1
pointer		ds	2
nibCnt		ds	1
	endif
		page
;***************************************************
; Code!
;
; SWTBUG must be first to match up with subroutine
; addresses commonly used.  Anything extra goes
; after SWTBUG.
;
		code
		org	ROM_BASE
;
;I/O INTERRUPT SEQUENCE
IRQV		ldx	IRQ
		jmp	0,x

;JUMP TO USER PROGRAM
JUMP		bsr	BADDR
		jmp	0,x

CURSOR		db	$10,$16,EOT	;CT-1024 cursor control


;ASCII LOADING ROUTINE
		VERIFY	$e00c
LOAD		jsr	RDON	;READER ON, DIS ECHO, GET P#
;
; This first loop waits for an 'S' indicating the start
; of a new record.  Discards all other characters.
;
LOAD3		bsr	INCH
		cmpa	#'S'
		bne	LOAD3	;1ST CHAR NOT S
;
; The next character is the record type.  SWTBUG only supported
; 1 (data) and 9 (EOF) but I've added support for 5, which some
; assemblers produce instead of an S9.
;
		bsr	INCH	;READ CHAR
		cmpa	#'9'
		beq	LOAD21
;
; I added code to accept an S5 record as EOF since a lot
; of cross assemblers produce them instead of an S9.  To
; make room for the code, some of this function was moved
; into the extended monitor area.
;
	if	SUPPORT_S5
		jsr	LOADX
		nop		;pad to correct address
	else
		cmpa	#'1'
		bne	LOAD3	;2ND CHAR NOT 1
	endif

		clr	CKSM	;ZERO CHECKSUM
		bsr	BYTE	;READ BYTE
		suba	#2
		staa	BYTECT	;BYTE COUNT

;BUILD ADDRESS
		bsr	BADDR
		VERIFY	$e02b
;STORE DATA
LOAD11		bsr	BYTE
		dec	BYTECT
		beq	LOAD15	;ZERO BYTE COUNT
		staa	0,x	;STORE DATA
		cmpa	0,x	;DATA STORED?
		bne	LOAD19
		inx
		bra	LOAD11
LOAD15		inc	CKSM
		beq	LOAD3
		VERIFY	$e040
LOAD19		ldaa	#'?'
		bsr	OUTCH
LOAD21		jmp	RDOFF1

;BUILD ADDRESS
		VERIFY	$e047
BADDR		bsr	BYTE	;READ 2 FRAMES
		staa	XHI
		bsr	BYTE
		staa	XLOW
		ldx	XHI	;LOAD IXR WITH NUMBER
		rts

;INPUT BYTE (TWO FRAMES)
		VERIFY	$e055
BYTE		bsr	INHEX	;GET HEX CHAR
BYTE1		asla
		asla
		asla
		asla
		tab
		bsr	INHEX
		aba
		tab
		addb	CKSM
		stab	CKSM
		rts

		VERIFY	$e067
OUTHL		lsra	;OUT HEX LEFT BCD DIGIT
		lsra
		lsra
		lsra
		VERIFY	$e06b
OUTHR		anda	#$F	;OUT HEX RIGHT BCD DIGIT
		adda	#'0'
		cmpa	#$39
		bls	OUTCH
		adda	#$7

;OUTPUT ONE CHAR
		VERIFY	$e075
OUTCH		jmp	OUTEEE
		VERIFY	$e078
INCH		jmp	INEEE

;PRINT DATA POINTED TO BY X REG
		VERIFY	$e07b
PDATA2		bsr	OUTCH
		inx
		VERIFY	$e07e
PDATA1		ldaa	0,x
		cmpa	#EOT
		bne	PDATA2
		rts		;STOP ON HEX 04

C1		jmp	SWTCTL

;MEMORY EXAMINE AND CHANGE
		VERIFY	$e088
CHANGE		bsr	BADDR
CHA51		ldx	#MCL
		bsr	PDATA1	;C/R L/F
		ldx	#XHI
		bsr	OUT4HS	;PRINT ADDRESS
		ldx	XHI
		bsr	OUT2HS	;PRINT OLD DATA
		bsr	OUTS	;OUTPUT SPACE
ANOTH		bsr	INCH	;INPUT CHAR
		cmpa	#' '
		beq	ANOTH
		cmpa	#CR
		beq	C1
		cmpa	#'^'	;UP ARROW?
		bra	AL3	;BRANCH FOR ADJUSTMENT
		nop

;INPUT HEX CHARACTER
		VERIFY	$e0aa
INHEX		bsr	INCH
INHEX1		suba	#'0'
		bmi	C3
		cmpa	#$9
		ble	IN1HG
		cmpa	#$11
		bmi	C3	;NOT HEX
		cmpa	#$16
		bgt	C3	;NOT HEX
		suba	#7
IN1HG		rts

		VERIFY	$e0bf
OUT2H		ldaa	0,x	;OUTPUT 2 HEX CHAR
OUT2HA		bsr	OUTHL	;OUT LEFT HEX CHAR
		ldaa	0,x
		inx
		bra	OUTHR	;OUTPUT RIGHT HEX CHAR

		VERIFY	$e0c8
OUT4HS		bsr	OUT2H	;OUTPUT 4 HEX CHAR + SPACE
		VERIFY	$e0ca
OUT2HS		bsr	OUT2H	;OUTPUT 2 HEX CHAR + SPACE

		VERIFY	$e0cc
OUTS		ldaa	#' '	;SPACE
		bra	OUTCH	;(BSR & TRS)

;ENTER POWER ON SEQUENCE
		VERIFY	$e0d0
START		lds	#STACK
		bra	al1



;*******************************************
;PART OF MEMORY EXAMINE AND CHANGE
AL3		bne	SK1
		dex
		dex
		stx	XHI
		bra	CHA51
SK1		stx	XHI
		bra	AL4

		VERIFY	$E0E3
EOE3		bra	CONTRL	;BRANCH FOR MIKBUG EQUIV. CONT

AL4		cmpa	#$30
		bcs	CHA51
		cmpa	#$46
		bhi	CHA51
		bsr	INHEX1
		jsr	BYTE1
		dex
		staa	0,x	;CHANGE MEMORY
		cmpa	0,x
		beq	CHA51	;DID CHANGE
		jmp	LOAD19	;DIDN'T CHANGE
C3		lds	SP
		bra	SWTCTL
;*************************************************


al1		sts	SP	;INIT TARGET STACK PTR.
		ldaa	#$FF
		jsr	SWISET
		ldx	#CTLPOR
		jsr	PIAINI
		ldaa	0,x
		cmpa	2,x
		bra	al2
		bra	PRINT
al2		bne	CONTRL

;INITIALIZE AS ACIA
		ldaa	#3	;ACIA MASTER RESET
		staa	0,x
		ldaa	#$11	;11 = 8N2 /16.  15 = 8N1 /16
		staa	0,x;
		bra	CONTRL

;ENTER FROM SOFTWARE INTERRUPT
SF0		nop
SFE1		sts	SP	;SAVE TARGETS STACK POINTER
;DECREMENT P COUNTER
		tsx
		tst	6,x
		bne	*+4
		dec	5,x
		dec	6,x
;PRINT CONTENTS OF STACK.
PRINT		ldx	#MCL
		jsr	PDATA1
		ldx	SP
		inx
		bsr	OUT2HS	;COND CODES
		bsr	OUT2HS	;ACC B
		bsr	OUT2HS	;ACC A
		bsr	OUT4HS	;IXR
		bsr	OUT4HS	;PGM COUNTER
		ldx	#SP
		jsr	OUT4HS	;STACK POINTER
SWTCTL		ldx	SWIJMP
		cpx	#SF0
		beq	CONTR1

CONTRL		lds	#STACK	;SET CONTRL STACK POINTER
		ldx	#CTLPOR	;RESET TO CONTROL PORT
		stx	PORADD
		clr	PORECH	;TURN ECHO ON
		bsr	SAVGET	;GET PORT # AND TYPE
		beq	POF1
		jsr	PIAECH	;SET PIA ECHO ON IF MP-C INTER
POF1		jsr	PNCHOF	;TURN PUNCH OFF
;		jsr	RDOFF	;TURN READER OFF
		jsr	PrintVer
CONTR1		ldx	#MCLOFF
		jsr	PDATA1	;PRINT DATA STRING
		bsr	INEEE		;READ COMMAND CHARACTER

;COMMAND LOOKUP ROUTINE
LOOK		ldx	#TABLE
OVER		cmpa	0,x
		bne	SK3
		jsr	OUTS	;SKIP SPACE
		ldx	1,x
		jmp	0,x
SK3		inx
		inx
		inx
		cpx	#TABEND+3
		bne	OVER
;
; Bob's change.  Branch to a later point.
;
;SWTL1		bra	SWTCTL
SWTL1		bra	CONTR1

;SOFTWARE INTERRUPT ENTRY POINT
SFE		ldx	SWIJMP	;JUMP TO VECTORED SOFTWARE INT
		jmp	0,x

S9		db	'S','9',EOT	;END OF TAPE

;**************************************************
MTAPE1		db	CR,LF,$15,0,0,0,'S','1',EOT	;PUNCH FORMAT

		VERIFY	$e19c
MCLOFF		
	if	NO_WEIRD
		db	0
	else
		db	$13	;READER OFF
	endif
		VERIFY	$e19d
MCL
	if	NO_WEIRD
		db	CR,LF,'$',EOT,0,0,0,0
	else
		db	CR,LF,$15,0,0,0,'$',EOT
	endif
EIA5		bra	BILD	;BINARY LOADER INPUT
;**************************************************


;NMI SEQUENCE
NMIV		ldx	NMI	;GET NMI VECTOR
		jmp	0,x

		VERIFY	$e1ac
INEEE		bra	INEEE1

;BYTE SEARCH ROUTINE
SEARCH		jsr	BADDR		;GET TOP ADDRESS
		stx	ENDA
		jsr	BADDR		;GET BOTTOM ADDRESS
		jsr	BYTE		;GET BYTE TO SEARCH FOR
		tab
OVE		ldaa	0,x
		stx	XHI
		cba
		beq	PNT
		bra	INCR1
PNT		ldx	#MCL
		jsr	PDATA1
		ldx	#XHI
		bra	SKP0
;**************************************************

;GO TO USER PROGRAM ROUTINE
GOTO		rti
		VERIFY	$e1d1
OUTEEE		bra	OUTEE1



;SAVE IXR AND LOAD IXR WITH CORRECT
;PORT NUMBER AND TEST FOR TYPE
SAVGET		stx	XTEMP		;STORE INDEX REGISTER
GETPT1		ldx	PORADD
		VERIFY	$E1D9
ISACIA		pshb
		ldab	1,x
		cmpb	3,x
		pulb
		rts
;**************************************************

;CONTINUATION OF SEARCH ROUTINE
SKP0		jsr	OUT4HS
		ldx	XHI
INCR1		cpx	ENDA
		beq	SWTL1
		inx
		bra	OVE

INEEE1		bsr	INCH8		;INPUT 8 BIT CHARACTER
		anda	#%01111111	;GET RID OF PARITY BIT
		rts

BILD		ins		;FIX	UP STACK WHEN USING
		ins		;BINARY LOADER ON SWTPC TAPES
		ins

;INPUT ONE CHAR INTO ACC B
		VERIFY	$e1f6
INCH8		pshb		;SAVE	ACC B
		bsr	SAVGET	;SAVE IXR, GET PORT# AND TYPE
		bne	IN1	;INPUT FROM PIA IF NOT
		ldaa	#$11	;RECONFIG FOR 8 BIT, 2 SB
		staa	0,x
ACIAIN		ldaa	0,x
		asra
		bcc	ACIAIN	;NOT READY
		ldaa	1,x	;LOAD CHAR
		ldab	PORECH
		beq	ACIOUT	;ECHO
		bra	RES	;DON'T ECHO

;OUTPUT ONE CHARACTER
OUTEE1		pshb	;SAVE	ACC B
		bsr	SAVGET
		bne	IOUT

ACIOUT		ldab	#$15
		stab	0,x
ACIOU1		ldab	0,x
		asrb
		asrb
		bcc	ACIOU1
		staa	1,x	;OUTPUT CHARACTER
RES		pulb		;RESTORE ACC B
		ldx	XTEMP
		rts

;PIA INPUT ROUTINE
IN1		ldaa	0,x	;LOOK FOR START BIT
		bmi	IN1
		bsr	DDL	;DELAY HALF BIT TIME
		ldab	#4	;SET DEL FOR FULL BIT TIME
		stab	2,x
		aslb		;SET UP CNTR WITH 8
IN3		bsr	DEL1	;WAIT ONE CHAR TIME
		sec
		rol	0,x
		rora
		decb
		bne	IN3
		bsr	DEL1	;WAIT FOR STOP BIT
		ldab	PORECH	;IS ECHO DESIRED?
		beq	IOUT2	;ECHO
		bra	RES	;RESTORE IXR,ACCB

IOUT		bsr	DDL1	;DELAY ONE HALF BIT TIME
		ldab	#$A	;SET UP COUNTER
		dec	0,x	;SET START BIT
		bsr	DE	;START TIMER
OUT1		bsr	DEL1	;DELAY ONE BIT TIME
		sta	0,x	;PUT OUT ONE DATA BIT
		sec
		rora		;SHIFT IN NEXT BIT
		decb		;DECREMENT COUNTER
		bne	OUT1	;TEST FOR 0
IOUT2		ldab	2,x	;TEST FOR STOP BITS
		aslb		;SHIFT BIT TO SIGN
		bpl	RES	;BRA FOR 1 STOP BIT
		bsr	DEL1	;DELAY FOR STOP BITS
		bra	RES
DEL1		tst	2,x	;IS TIME UP
		bpl	DEL1
DE		inc	2,x	;RESET TIMER
		dec	2,x
		rts

DDL		clr	2,x	;HALF BIT DELAY
DDL1		bsr	DE
		bra	DEL1


;OPTIONAL PORT ROUTINE
OPTL		bsr	INEEE1
		tab
		clr	PORADD+1	;SET I/O ADDRESS FOR $8000
		ldx	PORADD
		bsr	PIAINI	;INITIALIZE PIA
		bsr	PIAECH	;SET ECHO
		ldx	#TABLE1	;P, L OR E
		tba
		jmp	OVER	;LOOK AT TABLE FOR E, L OR P

PIAECH		ldaa	#$34	;SET DDR
		staa	3,x
		staa	2,x
NOOPT		rts

;PIA INITIALIZATION ROUTINE
PIAINI		inc	0,x	;SET DDR
		ldaa	#$7
		staa	1,x
		inc	0,x
		staa	2,x
		rts

; MINIFLOPPY DISK BOOT
DISK		clr	$8014
		bsr	DELAY
		ldab	#$0B
		bsr	RETT2
LOOP1		ldab	4,x
		bitb	#1
		bne	LOOP1
		clr	6,x
		bsr	RETURN
		ldab	#$9C
		bsr	RETT2
		ldx	#$2400
LOOP2		bitb	#2
		beq	LOOP3
		lda	$801B
		sta	0,x
		inx
LOOP3		ldab	$8018
		bitb	#1
		bne	LOOP2
		jmp	$2400
RETT2		stab	4,x
RETURN		bsr	RETT1
RETT1		rts


;GENERAL PURPOSE DELAY LOOP
		VERIFY	$E2C2
DELAY		ldx	#$FFFF
DELAY1		dex
		cpx	#$8014	;STOP AT 8014
DUM		bne	DELAY1
		rts


CLEAR		ldx	#CURSOR
		jsr	PDATA1
		bsr	DELAY1
RDOFF1		jsr	RDOFF
		bra	C4

;BREAKPOINT ENTERING ROUTINE
BREAK		ldx	#SF0
		cpx	SWIJMP	;BREAKPOINTS ALREADY IN USE?
		beq	INUSE
		inx
BREAK0		bsr	STO1
		jsr	BADDR
		stx	BKPT
		ldaa	0,x
		staa	BKLST
		ldaa	#$3F
		staa	0,x
		ldx	#SF0
		bsr	STO1
		jmp	CONTR1
INUSE		ldx	BKPT
		ldaa	BKLST
		staa	0,x
		ldx	#SFE1
		bra	BREAK0

SWISET		staa	STACK+1	;FIX POWER UP INTERRUPT
		ldx	SWIJMP
		cpx	#SF0
		beq	STORTN
STO		ldx	#SFE1
STO1		stx	SWIJMP
STORTN		rts

PUNCH1		bsr	PUNCH
		bra	POFC4

;FORMAT END OF TAPE WITH PGM. CTR. AND S9
PNCHS9		ldx	#$A049
		stx	ENDA
		dex
		bsr	PUNCH2
		ldx	#S9
PDAT		jsr	PDATA1
POFC4		bsr	PNCHOF
		bsr	DELAY
C4		jmp	CONTRL

RDON
	if NO_WEIRD
		nop	18
	else
		com	PORECH	;DISABLE ECHO FOR ACIA
		ldaa	#$11		;RON CHAR.
		ldab	#$20		;STROBE CHAR
		bsr	STROBE
		jsr	ISACIA	;CHECK TO SEE IF PIA
		beq	RTNN
		ldaa	#$3C		;DISABLE PIA ECHO IF PIA
		staa	3,x
	endif
RTNN		rts

RDOFF
	if NO_WEIRD
		rts
		nop	5
	else
		ldaa	#$13	;TURN READER OFF
		ldab	#$10
		bra	STROBE
	endif

PNCHON
	if NO_WEIRD
		rts
		nop	5
	else
		ldaa	#$12
		ldab	#4
		bra	STROBE
	endif

PNCHOF
	if NO_WEIRD
		rts
		nop	3
	else
		ldaa	#$14
		ldab	#$8
	endif

;PIA STROBING ROUTINE FOR PUNCH/READ ON/OFF
STROBE		jsr	OUTCH
		jsr	GETPT1
		beq	RTN1
		ldaa	#2
		orab	#1
		bsr	STR2
		bsr	STR1
		ldaa	#2
		ldab	#1
		stab	0,x
		bsr	STR2
STR1		ldaa	#6
STR2		staa	1,x
		stab	0,x
RTN1		rts

;PUNCH FROM BEGINNING ADDRESS (BEGA) THRU
;ENDING ADDRESS (ENDA)
PUNCH		ldx	BEGA
PUNCH2		stx	TW
		bsr	PNCHON
PUN11		ldaa	ENDA+1
		suba	TW+1
		ldab	ENDA
		sbcb	TW
		bne	PUN22
		cmpa	#16
		bcs	PUN23
PUN22		ldaa	#15
PUN23		adda	#4
		staa	BYTECT
		suba	#3
		staa	TEMP
;PUNCH C/R L/F NULLS S1
		ldx	#MTAPE1
		jsr	PDATA1
		clrb
;PUNCH FRAME COUNT
		ldx	#BYTECT
		bsr	PUNT2	;PUNCH 2 HEX CHARACTERS
;PUNCH ADDRESS
		ldx	#TW
		bsr	PUNT2
		bsr	PUNT2
;PUNCH	DATA
		ldx	TW
PUN32		bsr	PUNT2	;PUNCH ONE BYTE
		dec	TEMP
		bne	PUN32
		stx	TW
		comb
		pshb
		tsx
		bsr	PUNT2	;PUNCH CHECKSUM
		pulb		;RESTORE STACK
		ldx	TW
		dex
		cpx	ENDA
		bne	PUN11
RTN5		rts

;PUNCH 2 HEX CHAR, UPDATE CHECKSUM
PUNT2		addb	0,x
		jmp	OUT2H	;OUTPUT 2 HEX CHAR AND RTS
		page
;COMMAND TABLE
TABLE		db	'G'	;GOTO
		dw	GOTO
		db	'Z'	;GOTO PROM
		dw	PROM
		db	'M'	;MEMORY EXAM AND CHANGE
		dw	CHANGE
		db	'F'	;BYTE SEARCH
		dw	SEARCH
		db	'R'	;REGISTER DUMP
		dw	PRINT
		db	'J'	;JUMP
		dw	JUMP
	if EXTENDED
		db	'X'
		dw	ExtCmd
	else
		db	'C'	;CLEAR SCREEN
		dw	CLEAR
	endif	;EXTENDED
		db	'D'	;boot from disk
		dw	DISK
		db	'B'	;BREAKPOINT
		dw	BREAK
		db	'O'	;OPTIONAL PORT
		dw	OPTL
TABLE1		db	'P'	;ASCII PUNCH
		dw	PUNCH1
		db	'L'	;ASCII LOAD
		dw	LOAD
TABEND		db	'E'	;END OF TAPE
		dw	PNCHS9
		page
	if EXTENDED
;***************************************************
; This is the signature for a piece of code to
; determine if it's running under normal SWTBUG or
; extended xSWTBUG.  The signature is always at
; $E400.
;
		ds	$e400-*
		VERIFY	$e400
		db	"XSWTBUG",0
;
; These are the version and revision of this build.
; They are always at $E408 and $E409.
;
		VERIFY	$e408
		db	VERSION
		db	REVISION
;
; These are vectors to internal functions that may
; be useful to user applications.  The vectors
; always start at $E40A.
;
		VERIFY	$e40A
	if	SD_SUPPORT
		jmp	SdBoot		;load OS from SD Card
		jmp	xParInit	;init parallel interface
		jmp	xParSetWrite	;set for writing
		jmp	xParSetRead	;set for reading
		jmp	xParWriteByte	;write one byte
		jmp	xParReadByte	;read one byte
;
; Higher level disk functions
;
		jmp	DiskReadSector
		jmp	DiskWriteSector
		jmp	DiskStatus
		jmp	DiskGetDrives
		jmp	DiskGetMounted
		jmp	DiskNextMountedDrv
		jmp	DiskUnmount
		jmp	DiskMount
		jmp	DiskDir
		jmp	DiskDirNext
	endif	;SD_SUPPORT
		page
;
;***************************************************
; Displaced code from LOAD function in original
; SWTBUG.
;
	if	SUPPORT_S5
LOADX		cmpa	#'5'
		beq	LOADWE		;Wait for EOL
		cmpa	#'1'
		bne	LOAD3X		;2ND CHAR NOT 1
		rts
LOAD3X		jmp	LOAD3
;
; Keep eating characters until the end of the line.  Note that
; this might not be right, as it fails if the S5 record does
; not have a CR at the end.  A better approach would be to
; get the byte count (next two bytes) and read twice that
; number of characters.
;
LOADWE		jsr	INCH		;get char
		cmpa	#CR		;end of line?
		bne	LOADWE		;nope
		jmp	LOAD21		;done loading
	endif
;
;***************************************************
; If the option is turned on, build in the SD card
; support functions
;
	if	SD_SUPPORT
		include	"pario.asm"
		include	"parproto.inc"
		include	"diskfunc.asm"
	endif	;SD_SUPPORT

;
;***************************************************
; This is the command loop while in extended command
; mode.  Same basic concept as the other loop.
;
ExtCmd		
	if	SD_CMDS
		jsr	xParInit
		jsr	xParSetWrite
	endif
		ldx	#extprompt
		jsr	PDATA1
Extkey		jsr	INEEE
		cmpa	#CR
		beq	ExtCmd
;
; If they typed a question mark, display all available
; commands.  This is done dynamically based on what's
; in the command table.
;
		cmpa	#'?'
		bne	scancmd	;no, so look for command
		jsr	OUTCH
		ldx	#ct_info
		jsr	PDATA1
;
		ldx	#extcmd	;start of commands
helpnxt		lda	0,x
		cmpa	#0
		beq	ExtCmd	;done when it's a zero
		jsr	OUTCH	;display command
		lda	#' '
		jsr	OUTCH
		lda	#'='	;fancy print stuff
		jsr	OUTCH
		lda	#' '
		jsr	OUTCH
		inx		;move to description
		inx
		inx
		jsr	PDATA1	;display description
		lda	#CR
		jsr	OUTCH
		lda	#LF
		jsr	OUTCH
		inx		;skip past the $04
		bra	helpnxt
;
; They entered a possible command so scan through the
; table looking for it.  The command is in A, so don't
; destroy it.
;
scancmd		ldx	#extcmd	;start of commands
scannxt		ldab	0,x	;load B with current command
		cmpb	#0	;end of table?
		beq	Extkey	;if zero, end of table
		cmpa	0,x	;right one?
		beq	extfnd	;yes
;
; Move to the next command in the table.
;
		inx		;move to handler addr hi
		inx		;move to handler addr lo
;
; Find EOT that marks end of description
;
scansk		inx		;move to description
		ldab	0,x
		cmpb	#EOT	;end of description?
		bne	scansk
		inx		;move to next command
		bra	scannxt	;see if this is the one
;
; This is the right entry
;
extfnd		ldx	1,x	;load pointer...
		jmp	0,x	;...and execute command!
;
; This is the prompt for extended mode.  Feel free to
; change to whatever you like.
;
extprompt	db	CR,LF,'$','$',' ',EOT
ct_info		db	CR,LF,LF
		db	"Extended SWTBUG v"
		db	'0'+VERSION,'.','0'+REVISION
		db	" by Corsham Technologies"
		db	CR,LF
		db	"www.corshamtech.com",LF
crlfmsg		db	CR,LF,EOT
;
;***************************************************
; The extended command table.  This provides both
; command lookups and also some help.  Each entry
; has exactly the same format:
;
;    1 byte command, or zero if end of table
;    2 byte address to command handler
;    multiple byte description
;    1 byte value of $04
;
extcmd
		db	'X'
		dw	CONTRL
		db	"Return to SWTBUG"
		db	EOT
;
	if	SD_BOOT
		db	'B'
		dw	SdBoot
		db	"Boot from SD card"
		db	EOT
	endif	;SD_BOOT
;
	if	SD_CMDS
		db	'P'
		dw	SdPing
		db	"Ping SD controller"
		db	EOT
;
		db	'D'
		dw	SdDirectory
		db	"Do directory of SD card"
		db	EOT
;
		db	'T'
		dw	SdType
		db	"Type file from SD card"
		db	EOT
;
		db	'L'
		dw	SdLoad
		db	"Load SREC file from SD card"
		db	EOT
	endif	;SD_CMDS
;
	if	NUMGUESS
		db	'N'
		dw	NumGuess
		db	"Number guessing game"
		db	EOT
	endif	;NUMGUESS
;
	if	MEMTEST
		db	'M'
		dw	MemTest
		db	"Memory tester"
		db	EOT
	endif	;MEMTEST

	if	OTHELLO
		db	'O'
		dw	Othello
		db	"Othello"
		db	EOT
	endif	;OTHELLO
;
; End of table
;
		db	0
;
;***************************************************
; Handy little function that outputs a CR/LF.
;
crlf		ldx	#crlfmsg
		jmp	PDATA1
;
;***************************************************
; This is the code to boot from an SD card.  Read
; track 0, sector 0, into address $2400 and then
; jump to it.
;
; Note that address $2400 is at the 9K boundary
; so the system needs more than 8K to boot, let
; alone run the DOS.
;
	if	SD_BOOT
SdBoot		ldx	#bootmsg
		jsr	PDATA1
		ldx	#BootFCB
		jsr	DiskReadSector
		bcs	bootErr
		jmp	BOOT_ADDR
;
bootErr		ldx	#berrmsg
		jsr	PDATA1
		jmp	ExtCmd
;
bootmsg		db	CR,LF,"Booting from SD... ",EOT
berrmsg		db	CR,LF,"BOOT ERROR!",CR,LF,EOT
;
; FCB used to load the boot sector into memory
;
BootFCB		db	0	;drive 0
		db	0	;track 0
		db	0	;sector 0
		db	20	;sectors per track
		dw	BOOT_ADDR	;buffer address
	endif	;SD_BOOT
		page

	if	SD_CMDS
;
; These are states for the loader state machine.
; Keep these as hex so debug output is easier to
; match up.
;
ST_ECHO		equ	0x00	;just echo each char
ST_WAIT_S	equ	0x01	;wait for 'S'
ST_GET_TYPE	equ	0x02	;wait for digit record type
ST_WAIT_EOF	equ	0x03	;basically, do nothing
ST_CNT_HI	equ	0x04
ST_CNT_LO	equ	0x05
ST_GET_ADDR	equ	0x06	;get address field
ST_DATA_HI	equ	0x07
ST_DATA_LO	equ	0x08
;
;***************************************************
; Ping the Arduino to see if the link is alive.
;
SdPing		ldx	#pingmsg
		jsr	PDATA1
		jsr	DiskPing
		ldx	#pinggmsg
		jsr	PDATA1
		jmp	ExtCmd
;
pingmsg		db	"ing... ",EOT
pinggmsg	db	"success!",CR,LF,EOT
;
;***************************************************
; Do a disk directory
;
SdDirectory	ldx	#DirMsg
		jsr	PDATA1
		lda	#' '		;to pretty-up output
		sta	FnBuffer
		sta	FnBuffer+1
		sta	FnBuffer+2
;
		jsr	DiskDir		;start a disk directory
doDirLoop	ldx	#Filename	;where to put filename
		jsr	DiskDirNext	;get next file name
		bcs	doDirExit	;branch if End
		ldx	#FnBuffer	;where filename is at
		jsr	puts		;display name
		jsr	crlf
		bra	doDirLoop	;lather, rinse, repeat
doDirNend	jsr	crlf
		bra	doDirLoop
doDirExit	jmp	ExtCmd
;
DirMsg		db	"irectory...",CR,LF,LF,EOT
;
;***************************************************
; Type a file; display its contents.  Great for
; looking at ASCII files.
;
SdType		lda	#ST_ECHO	;initial state
typeload	sta	sdState		;save state
;
; Prompt for a filename...
;
		ldx	#fnmsg
		jsr	PDATA1
		jsr	getfname	;get name
		lda	Filename	;get first char
		cmpa	#EOT	;empty line?
		beq	doDirExit
;
; Got a filename, so start sending the command to
; read a disk file
;
		lda	#PC_READ_FILE
		jsr	xParWriteByte
		ldx	#Filename
		dex
dotypeloop	inx		;point to filename
		lda	0,x
		cmpa	#EOT
		beq	dotydone
		jsr	xParWriteByte	;send next piece of filename
		bra	dotypeloop

dotydone	lda	#0
		jsr	xParWriteByte
		jsr	xParSetRead
		jsr	xParReadByte	;read their reply
;
; It should be either an ACK (82) or NAK (83)
;
		cmpa	#PR_ACK
		beq	dotypeack
;
; A NAK.  Get the value and report it
;
		jsr	xParReadByte
		sta	temp
		ldx	#gotnakmsg
		jsr	PDATA1
		ldx	#temp
		jsr	OUT2HS
		jsr	crlf
		jsr	xParSetWrite
		jmp	ExtCmd
;
; Got an ACK, so now we sit in a loop of requesting more
; data, reporting it, etc.
;
dotypeack	jsr	xParSetWrite
		lda	#PC_READ_BYTES	;request data
		jsr	xParWriteByte
		lda	#BUFFSIZE-1
		jsr	xParWriteByte	;request data
		jsr	xParSetRead	;get ready to read response
		jsr	xParReadByte	;get response
		jsr	xParReadByte	;get number of bytes
		cmpa	#0		;any bytes?
		beq	dotypeof	;no, end of file
		tab		;move byte count into B
		ldx	#buffer	;address of buffer
;
; Loop to read block of data
;
dotyperl	jsr	xParReadByte
		pshb
		stx	tempx
		jsr	loadState	;let state machine process it
		ldx	tempx
		pulb
		inx
		decb
		bne	dotyperl
		bra	dotypeack
;
; Got EOF
;
dotypeof	jsr	xParSetWrite	;back to write mode
		lda	#PC_DONE	;end
		jsr	xParWriteByte
		jmp	ExtCmd
;
gotnakmsg	db	"Got NAK with code: ",EOT
;
;***************************************************
; Load an S-Rec file from the SD card.  This shares
; a lot of code with the Type command, so set up a
; different initial state and then let the load
; logic do all the work.
;
SdLoad		ldx	#$ffff		;indicates no record
		stx	RTIVEC		;...loaded yet
		lda	#ST_WAIT_S
		jmp	typeload	;jump to common code
;
fnmsg		db	CR,LF
		db	"Enter filename: "
		db	EOT
;
;=====================================================
; This is the state machine for loading files from
; the SD drive.  On input, A contains the character
; to process.  This will maintain a state and perform
; any required actions.  The caller only needs to call
; this function for each byte read from the file.
;
; This starts by having the inbound character in A
; and the current state in B.
;
loadState	ldab	sdState	;get current state
		cmpb	#ST_ECHO
		bne	ls_1
;
; Just echo the character and we're done.  This is
; used for the Type command.
;
		jsr	putch
		rts
;
ls_1		cmpb	#ST_WAIT_S
		bne	ls_2
;
; Wait for an 'S' to appear, then move to the next state.
; Each record starts with an 'S'.
;
		cmpa	#'S'
		bne	ls_exit	;not what we wanted, just exit
;
		lda	#'.'
		jsr	putch	;output status indicator
;
		lda	#ST_GET_TYPE
;
; Common entry points.  ls_newstate saves the contents
; of A as the next state.  ls_exit is an RTS.
;
ls_newstate	sta	sdState
	if	DEBUG_STATE
		ldx	#StateMsg
		jsr	PDATA1
		ldx	#state
		jsr	OUT2HS
		jsr	crlf
	endif
ls_exit		rts

	if	DEBUG_STATE
StateMsg	db	"Set state: $",EOT
StateAddr	db	"Record load address: $",EOT
SizeMsg		db	"Bytes in record: $",EOT
	endif
;
ls_2		cmpb	#ST_GET_TYPE
		bne	ls_3
;
; It's the record type.  The Motorola spec says there
; are nine types, but we only process a few:
;
; 1 = Data with 16 bit address
; 5 = as02 uses this as an end of file
; 9 = real end of file
;
; 9 is the usual end of file, but for some reason the
; AS02 assembler outputs a 5 without the 9, so allow
; it to also be an EOF so I don't have to manually
; add the S9 record to files.
;
		cmpa	#'1'
		beq	st_data	;it's a data record
		cmpa	#'5'
		beq	st_end
		cmpa	#'9'
		beq	st_end
;
; Huh, it's not a record type we handle, so just
; go back to echo mode.
;
		lda	#ST_ECHO
		bra	ls_newstate
;
; End of files are easy.  We're basically done, so
; just ignore everything until the end of the file.
;
st_end		ldx	#firstaddrmsg
		jsr	PDATA1
		ldx	#RTIVEC
		jsr	OUT4HS
		jsr	crlf
;
		lda	#ST_WAIT_EOF	;a do-nothing state
		bra	ls_newstate
;
; Woohoo!  It's a data record!  The rest of the record
; contains:
;
;    S1LLYYYY....
;
; Where LL is the number of bytes (the dots).
; YYYY is the 16 bit address where the data goes.
; ...is the data, LL bytes of them.
;
; So the next thing we need to get is the high nibble
; of the byte count.
;
st_data		lda	#ST_CNT_HI
		bra	ls_newstate
;
; See if we're expecting the high nibble of the byte count
;
ls_3		cmpb	#ST_CNT_HI
		bne	ls_4
;
		jsr	tohex
		asla
		asla
		asla
		asla
		sta	byteCnt
		lda	#ST_CNT_LO
		bra	ls_newstate
;
; See if we are expecting the low nibble of the byte count
;
ls_4		cmpb	#ST_CNT_LO
		bne	ls_5
;
		jsr	tohex
		ora	byteCnt	;merge with hi nibble
;
; The byte count includes the address and checksum, so
; subtract three from the count.
;
		suba	#3
		sta	byteCnt
	if	DEBUG_STATE
		ldx	#SizeMsg
		jsr	PDATA1
		ldx	#byteCnt
		jsr	OUT2HS
		jsr	crlf
	endif
;
		ldx	#0
		stx	pointer
		lda	#4	;number of nibbles to get
		sta	nibCnt
		lda	#ST_GET_ADDR
		bra	ls_newstate
;
ls_5		cmpb	#ST_GET_ADDR
		bne	ls_6
;
; Roll the current address left by 4 bits
;
		psha
		lda	pointer		;MSB
		ldab	pointer+1	;LSB
		aslb
		rola
		aslb
		rola
		aslb
		rola
		aslb
		rola
		sta	pointer
		stab	pointer+1
;
		pula
		jsr	tohex
		oraa	pointer+1	;merge in new nibble
		sta	pointer+1
;
; Now see if there are more digits to go or not.
;
		dec	nibCnt
		bne	ls_5_1	;still more
;
; If RTIVEC is still FFFF (a load address that
; can never occur), then save this address there.
; This is a potential way to know the address where
; this file should be run from.
;
		ldx	RTIVEC
		cpx	#$ffff
		bne	ls_5_2	;no, already set
;
		lda	pointer	;set starting address
		sta	RTIVEC
		lda	pointer+1
		sta	RTIVEC+1
;
ls_5_2
	if	DEBUG_STATE
		ldx	#StateAddr
		jsr	PDATA1
		ldx	#pointer
		jsr	OUT4HS
		jsr	crlf
	endif
ls_5_NXT	lda	#ST_DATA_HI
		bra	ls_newstate
ls_5_1		rts
;
ls_6		cmpb	#ST_DATA_HI
		bne	ls_7
;
; This is the high byte of a byte.  Convert to
; a nibble and save in the upper nibble of temp,
; then move to a state to get the lower nibble.
;
		jsr	tohex
		asla
		asla
		asla
		asla
		sta	temp
		lda	#ST_DATA_LO
		bra	ls_newstate
;
ls_7		cmpb	#ST_DATA_LO
		bne	ls_8
;
; This is the lower nibble of a byte of data.
;
		jsr	tohex
		ora	temp	;merge in upper nibble
		ldx	pointer	;where it goes
		sta	0,x
		inx
		stx	pointer	;update address
		dec	byteCnt	;all done?
		bne	ls_5_NXT	;nope, get high nibble of next byte
;
; We read all the data on this line.  Ideally, we should
; have been keeping a checksum and then compare it to the
; checksum in the file, but I'm cheating and just going
; back to wait for the next S record to start.
;
		lda	#ST_WAIT_S
		bra	ls_newstate
;
; All states are handled, so this should not happen,
; but keep the label here for future expansion.
;
ls_8		rts
;
firstaddrmsg	db	CR,LF
		db	"Load done.  First address: ",EOT
;
;=====================================================
; Given a character in A, convert it to a hex nibble
; in the lower 4 bits of A and C clear.  If not a hex
; character, return C set.
;
tohex		suba	#'0'
		bmi	tohexbad
		cmpa	#9
		ble	tohexgud
		cmpa	#$11
		bmi	tohexbad	;NOT HEX
		cmpa	#$16
		bgt	tohexbad	;NOT HEX
		suba	#7
tohexgud	clc
		rts
tohexbad	sec
		rts
;
;=====================================================
; Print version of xSWTBUG
;
PrintVer	jsr	RDOFF	;TURN READER OFF-
		ldx	#greeting
		jsr	puts
		rts
;
greeting	db	CR,LF,CR,LF
		db	"xSWTBUG v1.2.1"
		db	CR,LF,0
;
;=====================================================
; This gets a filename from the user and stores it in
; Filename.  Imposes a max size of 13 chars.  Returns
; when the user hits ENTER.
;
; Modifies A, B and X.
;
getfname	ldx	#Filename	;where to put text
		clrb		;clear char count
getlchar2	jsr	getch
		cmpa	#CR
		beq	getleol2	;branch if end of line
;
		cmpa	#DEL	;delete?
		beq	getdel2
		cmpa	#BS	;backspace?
		bne	getndel2
;
; Erase the last character
;
getdel2		cmpb	#0	;is buffer empty?
		beq	getlchar2
		dex		;back up one
		decb		;one less char
;
; Erase old character with the old backspace-space-backspace
; sequence.
;
		jsr	putch	;move back
		lda	#' '
		jsr	putch	;erase last char
		lda	#BS
		jsr	putch	;and move back again
		bra	getlchar2
;
; See if it's a legal character.
;
getndel2	cmpa	#' '	;lowest allowed
		blt	getlchar2
		cmpa	#'~'
		bgt	getlchar2
;
; Is there room?
;
		cmpb	#NAMESIZE
		beq	getlchar2
;
; Finally, put the character into the buffer
; and echo it.
;
		sta	0,x
		inx
		incb
		jsr	putch
		bra	getlchar2
;
; They hit ENTER.  Terminate the buffer and return.
; I stuck with the Moto tradition and used EOT ($04)
; to mark the end of the line.
;
getleol2		lda	#EOT
		sta	0,x	;terminate line
		jmp	crlf
	endif	;SD_CMDS
;
;***************************************************
; Given a pointer to a null terminated string in X,
; display the string and return.
;
puts		lda	0,x
		beq	putsDone
		jsr	putch
		inx
		bra	puts
putsDone	rts
		page
;***************************************************
; Fun stuff that can optionally be built in...
;
	if	NUMGUESS
		include	"numguess.asm"
	endif	;NUMGUESS

	if	MEMTEST
		include	"memtest.asm"
	endif

	if	OTHELLO
		include	"othello.asm"
	endif

	endif	;EXTENDED

;
;***************************************************
; Vectors.  What's our vector, Victor?
;
		org	ROM_BASE + (1 << ADDR_BITS) - 8

		dw	IRQV 	;IRQ VECTOR
		dw	SFE	;SOFTWARE INTERRUPT
		dw	NMIV	;NMI VECTOR
		dw	START	;RESTART VECTOR



