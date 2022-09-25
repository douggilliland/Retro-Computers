		title	"SBUG18 MP-09 MONITOR"
		list
;=====================================================
;
; MONITOR PROGRAM FOR THE SOUTHWEST TECHNICAL
; PRODUCTS MP-09 CPU BOARD AS COMMENTED BY....
;
; ALLEN CLARK            WALLACE WATSON
; 2502 REGAL OAKS LANE   4815 EAST 97th AVE.
; LUTZ, FLA. 33549       TEMPLE TERRACE, FLA. 33617
; PH. 813-977-0347       PH. 813-985-1359
;
; MODIFIED TO SBUG09 VER 1.8 BY:  RANDY JARRETT
;                                 2561 NANTUCKET DR APT. E
;                                 ATLANTA, GA  30345
;                                 PH. 404-320-1043
;
; Modified by Bob Applegate, bob@corshamtech.com in
; late 2014 to add some extra flexibility at build
; time.  Also made it compatible with the AS09
; assembler.
;
; I've added notes in some sections of code while
; working through some of the logic, and left them in
; case they are helpful to others as well.
;
; 1.8.2 has the updated functions to do long sector
; read/writes and other support for NitrOS/9.
;
; Memory map note:
;
; At start-up, the only memory hard-wired to a
; specific address is from FF00 to FFFF which is
; mapped to the upper 256 bytes of the EPROM, probably
; containing SBUG.
;
; The code in the upper 256 bytes will do setup of the
; DAT registers, then the rest of the EPROM is availble.
;
;       *** COMMANDS ***

; CONTROL A   = ALTER THE "A" ACCUMULATOR
; CONTROL B   = ALTER THE "B" ACCUMULATOR
; CONTROL C   = ALTER THE CONDITION CODE REGISTER
; CONTROL D   = ALTER THE DIRECT PAGE REGISTER
; CONTROL P   = ALTER THE PROGRAM COUNTER
; CONTROL U   = ALTER USER STACK POINTER
; CONTROL X   = ALTER "X" INDEX REGISTER
; CONTROL Y   = ALTER "Y" INDEX REGISTER
; B hhhh      = SET BREAKPOINT AT LOCATION $hhhh
; D           = BOOT A SWTPC 8 INCH FLOPPY SYSTEM
; U           = BOOT A SWTPC 5 INCH FLOPPY SYSTEM
; E ssss-eeee = EXAMINE MEMORY FROM STARTING ADDRESS ssss
;              -TO ENDING ADDRESS eeee.
; G           = CONTINUE EXECUTION FROM BREAKPOINT OR SWI
; L           = LOAD TAPE
; M hhhh      = EXAMINE AND CHANGE MEMORY LOCATION hhhh
; P ssss-eeee = PUNCH TAPE, START ssss TO END eeee ADDR.
; Q ssss-eeee = TEST MEMORY FROM ssss TO eeee
; R           = DISPLAY REGISTER CONTENTS
; S           = DISPLAY STACK FROM ssss TO $DFC0
; X           = REMOVE ALL BREAKPOINTS
;
; Useful constants
;
false		equ	0
true		equ	~false
;
;***************************************************
; This is so other files included (if any) can tell
; they are being assembled into SBUG.  This should
; always be true.
;
IN_SBUG		equ	true
;
;***************************************************
; Allow S5 recognition for the L command.  Some
; assemblers output S5 instead of S9, but it takes
; more space for S5 processing.
;
ALLOW_S5	equ	true
;
;***************************************************
; Include Tiny BASIC in the lower 2K.
;
ENABLE_BASIC	equ	false
;
;***************************************************
; Include SD card drivers and commands.  Note that
; the ENABLE_BASIC option ***MUST*** be false if
; this is true; there just isn't enough space for
; both sets of code.
;
SD_SUPPORT	equ	true
;
		if	SD_SUPPORT
		if	ENABLE_BASIC
		error	You cannot have both options on!
		endif
		endif
;
;***************************************************
; This enables/disables tape read control codes.
; This should be true to emulate the original SBUG,
; but false is fine for modern use.
;
READER_CONTROL	equ	false
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

FORCE		macro	desired
		if * > desired
		fail	Past expected address (desired)
		else
		if * < desired
		ds	desired-*
		endif
		endif
		endm

;
; A test pattern used for sizing
;
TSTPAT		equ	$55AA	;TEST PATTERN


		bss
		org	$dfc0
STACK		ds	2	;TOP OF INTERNAL STACK / USER VECTOR
SWI3		ds	2	;SOFTWARE INTERRUPT VECTOR #3
SWI2		ds	2	;SOFTWARE INTERRUPT VECTOR #2
FIRQ		ds	2	;FAST INTERRUPT VECTOR
IRQ		ds	2	;INTERRUPT VECTOR
SWI		ds	2	;SOFTWARE INTERRUPT VECTOR
SVCVO		ds	2	;SUPERVISOR CALL VECTOR ORGIN
SVCVL		ds	2	;SUPERVISOR CALL VECTOR LIMIT
LRARAM		ds	16	;LRA ADDRESSES
CPORT		ds	2	;RE-VECTORABLE CONTROL PORT
ECHO		ds	1	;ECHO FLAG
BPTBL		ds	24	;BREAKPOINT TABLE BASE ADDR

;
; The original code was hard coded for the I/O base address to
; be at E000, each slot occupied 4 bytes, and the MP-S card
; was always in slot 1.  I've added EQUates to set these things.
;
IO_BASE		equ	$e000	;usually $E000, but $8000 on unmodified motherboard
IO_SIZE		equ	16	;number of addresses per I/O slot
MPS_SLOT	equ	1	;which slot console MP-S is in
ACIAS		equ	(MPS_SLOT*IO_SIZE)+IO_BASE	;CONTROL PORT
;
; Disk drive options you can turn on/off.  If you
; turn them off, then the command disappears from
; the list.
;
DMAF2		equ	false	;SWTPC DMAf2 controller
DC_X		equ	false	;SWTPC DX-x disk controller
;
; This sets up disk drive addresses.  The code
; appears to be suited to a controller occupying
; slots 5 and 6's address space.
;
	if	DC_X
DISK_SLOT	equ	5
DISK_BASE	equ	(DISK_SLOT*IO_SIZE)+IO_BASE
Comreg		equ	DISK_BASE+4	;COMMAND REGISTER
Drvreg		equ	DISK_BASE	;DRIVE REGISTER
Secreg		equ	DISK_BASE+6	;SECTOR REGISTER
Datreg		equ	DISK_BASE+7	;DATA REGISTER
	endif
;
; Not sure what card this is for but it's in upper
; address space
;
	if	DMAF2
ADDREG		equ	$F000	;ADDRESS REGISTER
CNTREG		equ	$F002	;COUNT REGISTER
CCREG		equ	$F010	;CHANNEL CONTROL REGISTER
PRIREG		equ	$F014	;DMA PRIORITY REGISTER
AAAREG		equ	$F015	;???
BBBREG		equ	$F016	;???
COMREG		equ	$F020	;1791 COMMAND REGISTER
SECREG		equ	$F022	;SECTOR REGISTER
DRVREG		equ	$F024	;DRIVE SELECT LATCH
CCCREG		equ	$F040	;???
	endif
;
; The Dynamic Address Translation (DAT) uses 16 write-
; only registers from FFF0 to FFFF.  The lower 4 bits
; are the inverse of the values presented to A12-A15,
; while the upper 4 bits are the non-inverted bank
; select (A16-A19).
;
DATREGS		equ	$FFF0	;DAT RAM CHIP
;
; Common ASCII characters
;
EOT		equ	$04
BS		equ	$08
LF		equ	$0a
CR		equ	$0d
;
; Since the Corsham Tech board takes 8K EPROMs but the
; memory space for the EPROM is only 4K, put something
; here so the EPROM programmer will locate the file
; properly in its memory.
;
		code
		org	$e000
		db	"Don't put anything here"
;
; If you put in the jumper on the Corsham Tech CPU
; board for 4K of EPROM, then the code starts here
; for the lower 2K.
;
		org	$f000
	if	ENABLE_BASIC
		include	"basic.asm"
	else
	if	SD_SUPPORT
		jmp	SdBoot		;load OS from SD Card
		jmp	xParInit	;init parallel interface
		jmp	xParSetWrite	;set for writing
		jmp	xParSetRead	;set for reading
		jmp	xParWriteByte	;write one byte
		jmp	xParReadByte
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
		jmp	DiskPing
;
		jmp	DiskReadLong
		jmp	DiskWriteLong	


		include	"pario.asm"
		include	"diskfunc.asm"
	else
		db	"You have 4K of EPROM enabled!"
	endif
	endif
;
; This is the real start of the 2K monitor...
;
; The vector table to handy functions.  It's nice that
; SWTPC did this so the code can move around inside
; SBUG without breaking user programs.
;
		code
		org	$f800
		dw	MONITOR
		dw	NEXTCMD
		dw	INCH
		dw	INCHE
		dw	INCHEK
		dw	OUTCH
		dw	PDATA
		dw	PCRLF
		dw	PSTRNG
		dw	LRA
;
; These are additional vectors to useful functions within
; SBUG that other programs can use.
;
		dw	OUT1S	;output a space
		dw	OUT2H	;output A as 2 hex characters
		dw	OUT4H	;output X as 4 hex characters
		dw	BYTE	;input 2 hex digits, return in A
		dw	IN1ADR	;input 4 hex digits, return in X

; MONITOR

; VECTOR ADDRESS STRING IS.....
; $F8A1-$F8A1-$F8A1-$F8A1-$F8A1-$FAB0-$FFFF-$FFFF

;		VERIFY	$f814
MONITOR		ldx	#RAMVEC	;POINT TO VECTOR ADDR. STRING
		ldy	#STACK	;POINT TO RAM VECTOR LOCATION
		ldb	#$10	;BYTES TO MOVE = 16
LOOPA		lda	,x+	;GET VECTOR BYTE
		sta	,y+	;PUT VECTORS IN RAM / $DFC0-$DFCF
		decb		;SUBTRACT 1 FROM NUMBER OF BYTES TO MOVE
		bne	LOOPA	;CONTINUE UNTIL ALL VECTORS MOVED

* CONTENTS     FROM         TO      FUNCTION
*  $F8A1       $FE40      $DFC0     USER-V
*  $F8A1       $FE42      $DFC2     SWI3-V
*  $F8A1       $FE44      $DFC4     SWI2-V
*  $F8A1       $FE46      $DFC6     FIRQ-V
*  $F8A1       $FE48      $DFC8     IRQ-V
*  $FAB0       $FE4A      $DFCA     SWI-V
*  $FFFF       $FE4C      $DFCC     SVC-VO
*  $FFFF       $FE4E      $DFCE     SVC-VL

;		VERIFY	$f824
		ldx	#ACIAS	;GET CONTROL PORT ADDR.
		stx	CPORT	;STORE ADDR. IN RAM
		lbsr	XBKPNT	;CLEAR OUTSTANDING BREAKPOINTS
		ldb	#12	;CLEAR 12 BYTES ON STACK
CLRSTK		clr	,-s
		decb
		bne	CLRSTK
		leax	MONITOR,pc	;SET PC TO SBUG-E ENTRY
		stx	10,s	;ON STACK
		lda	#$D0	;PRESET CONDITION CODES ON STACK
		sta	,s
		tfr	s,u
		lbsr	ACINIZ	;INITIALIZE CONTROL PORT
		ldx	#MSG1	;POINT TO 'SBUG 1.8' MESSAGE
		lbsr	PDATA	;PRINT MSG
		ldx	#LRARAM	;POINT TO LRA RAM STORAGE AREA
		clra		;START TOTAL AT ZERO
		ldb	#13	;TOTAL UP ALL ACTIVE RAM MEMORY
FNDREL		tst	b,x	;TEST FOR RAM AT NEXT LOC.
		beq	RELPAS	;IF NO RAM GO TO NEXT LOC.
		adda	#4	;ELSE ADD 4K TO TOTAL
		daa		;ADJ. TOTAL FOR DECIMAL
RELPAS		decb		;SUB. 1 FROM LOCS. TO TEST
		bpl	FNDREL	;PRINT TOTAL OF RAM
		lbsr	OUT2H	;OUTPUT HEX BYTE AS ASCII
		ldx	#MSG2	;POINT TO MSG 'K' CR/LF + 3 NULS
		lbsr	PDATA	;PRINT MSG

***** NEXTCMD *****

;		VERIFY	$f861
NEXTCMD		ldx	#MSG3	;POINT TO MSG ">"
		lbsr	PSTRNG	;PRINT MSG
		lbsr	INCH	;GET ONE CHAR. FROM TERMINAL
		anda	#$7F	;STRIP PARITY FROM CHAR.
		cmpa	#$0D	;IS IT CARRIAGE RETURN ?
		beq	NEXTCMD	;IF CR THEN GET ANOTHER CHAR.
		tfr	a,b	;PUT CHAR. IN "B" ACCUM.
		cmpa	#$20	;IS IT CONTROL OR DATA CHAR ?
		bge	PRTCMD	;IF CMD CHAR IS DATA, PRNT IT
		lda	#'^'	;ELSE CNTRL CHAR CMD SO...
		lbsr	OUTCH	;PRINT "^"
		tfr	b,a	;RECALL CNTRL CMD CHAR
		adda	#'A'-1	;CONVERT IT TO ASCII LETTER
PRTCMD		lbsr	OUTCH	;PRNT CMD CHAR
		lbsr	OUT1S	;PRNT SPACE
		cmpb	#$60
		ble	NXTCH0
		subb	#$20


***** DO TABLE LOOKUP *****
*   FOR COMMAND FUNCTIONS

;		VERIFY	$f88b
NXTCH0		ldx	#JMPTAB	;POINT TO JUMP TABLE
NXTCHR		cmpb	,x+	;DOES COMMAND MATCH TABLE ENTRY ?
		beq	JMPCMD	;BRANCH IF MATCH FOUND
		leax	2,x	;POINT TO NEXT ENTRY IN TABLE
		cmpx	#TABEND	;REACHED END OF TABLE YET ?
		bne	NXTCHR	;IF NOT END, CHECK NEXT ENTRY
		ldx	#MSG4	;POINT TO MSG "WHAT?"
		lbsr	PDATA	;PRINT MSG
		bra	NEXTCMD	;IF NO MATCH, PRMPT FOR NEW CMD
JMPCMD		jsr	[,x]	;JUMP TO COMMAND ROUTINE
		bra	NEXTCMD	;PROMPT FOR NEW COMMAND
*
* "G" GO OR CONTINUE

;		VERIFY	$f8a5
GO		tfr	u,s
RTI		rti

* "R" DISPLAY REGISTERS

;		VERIFY	$f8a8
REGSTR		ldx	#MSG5	;POINT TO MSG " - "
		lbsr	PSTRNG	;PRINT MSG
		lbsr	PRTSP	;$FCBF
		lbsr	PRTUS	;$FCCA
		lbsr	PRTDP	;$FCD5
		lbsr	PRTIX	;$FCE0
		lbsr	PRTIY	;$FCEB
		ldx	#MSG5	;POINT TO MSG " - "
		lbsr	PSTRNG	;PRINT MSG
		lbsr	PRTPC	;$FCF5
		lbsr	PRTA	;$FCFF
		lbsr	PRTB	;$FD09
		lbra	PRTCC	;$FD13


* ALTER "PC" PROGRAM COUNTER

;		VERIFY	$f8cf
ALTRPC		lbsr	PRTPC	;$FCF5 PRINT MSG " PC = "
		lbsr	OUT1S	;OUTPUT SPACE
		lbsr	IN1ADR	;GET NEW CONTENTS FOR "PC"
		bvs	ALTPCD	;EXIT IF INVALID HEX
		stx	10,u	;POKE IN NEW CONTENTS
ALTPCD		rts


* ALTER "U" USER STACK POINTER

;		VERIFY	$f8dd
ALTRU		lbsr	PRTUS	;$FCCA PRINT MSG " US = "
		lbsr	OUT1S	;OUTPUT SPACE
		lbsr	IN1ADR
		bvs	ALTUD
		stx	8,u
ALTUD		rts

*
* ALTER "Y" INDEX REGISTER


ALTRY		lbsr	PRTIY	;PRINT MSG " IY = "
		lbsr	OUT1S	;OUTPUT SPACE
		lbsr	IN1ADR
		bvs	ALTYD
		stx	6,u	;$F8F0
ALTYD		rts


* ALTER "X" INDEX REGISTER


ALTRX		lbsr	PRTIX	;$FCE0 PRINT MSG " IX = "
		lbsr	OUT1S	;OUTPUT SPACE
		lbsr	IN1ADR
		bvs	ALTXD
		stx	4,u
ALTXD		rts


* ALTER "DP" DIRECT PAGE REGISTER


ALTRDP		lbsr	PRTDP	;$FCD5 PRINT MSG " DP = "
		lbsr	OUT1S	;OUTPUT SPACE
		lbsr	BYTE	;INPUT BYTE (2 HEX CHAR)
		bvs	ALTDPD
		sta	3,u
ALTDPD		rts


* ALTER "B" ACCUMULATOR


ALTRB		lbsr	PRTB	;$FD09 PRINT MSG " B = "
		lbsr	OUT1S	;OUTPUT SPACE
		lbsr	BYTE	;INPUT BYTE (2 HEX CHAR)
		bvs	ALTBD
		sta	2,u
ALTBD		rts		;$F91C


* ALTER "A" ACCUMULATOR

*
ALTRA		lbsr	PRTA	;$FCFF RINT MSG " A = "
		lbsr	OUT1S	;OUTPUT SPACE
		lbsr	BYTE	;INPUT BYTE (2 HEX CHAR)
		bvs	ALTAD
		sta	1,u
ALTAD		rts


* ALTER "CC" REGISTER


ALTRCC		lbsr	PRTCC	;$FD13 PRINT MSG " CC: "
		lbsr	OUT1S	;OUTPUT SPACE
		lbsr	BYTE	;INPUT BYTE (2 HEX CHAR)
		bvs	ALTCCD
		ora	#$80	;SETS "E" FLAG IN PRINT LIST
		sta	,u
ALTCCD		rts

***** "M" MEMORY EXAMINE AND CHANGE *****

;		VERIFY	$f941
MEMCHG		lbsr	IN1ADR	;INPUT ADDRESS
		bvs	CHRTN	;IF NOT HEX, RETURN
		tfr	x,y	;SAVE ADDR IN "Y"
MEMC2		ldx	#MSG5	;POINT TO MSG " - "
		lbsr	PSTRNG	;PRINT MSG
		tfr	y,x	;FETCH ADDRESS
		lbsr	OUT4H	;PRINT ADDR IN HEX
		lbsr	OUT1S	;OUTPUT SPACE
		lda	,y	;GET CONTENTS OF CURRENT ADDR.
		lbsr	OUT2H	;OUTPUT CONTENTS IN ASCII
		lbsr	OUT1S	;OUTPUT SPACE
		lbsr	BYTE	;LOOP WAITING FOR OPERATOR INPUT
		bvc	CHANGE	;IF VALID HEX GO CHANGE MEM. LOC.
		cmpa	#8	;IS IT A BACKSPACE (CNTRL H)?
		beq	MEMC2	;PROMPT OPERATOR AGAIN
		cmpa	#$18	;IS IT A CANCEL (CNTRL X)?
		beq	MEMC2	;PROMPT OPERATOR AGAIN
		cmpa	#'^'	;IS IT AN UP ARROW?
		beq	BACK	;DISPLAY PREVIOUS BYTE
		cmpa	#$D	;IS IT A CR?
		bne	FORWRD	;DISPLAY NEXT BYTE
CHRTN		rts		;EXIT ROUTINE


CHANGE		sta	,y	;CHANGE BYTE IN MEMORY
		cmpa	,y	;DID MEMORY BYTE CHANGE?
		beq	FORWRD	;$F972
		lbsr	OUT1S	;OUTPUT SPACE
		lda	#'?'	;LOAD QUESTION MARK
		lbsr	OUTCH	;PRINT IT
FORWRD		leay	1,y	;POINT TO NEXT HIGHER MEM LOCATION
		bra	MEMC2	;PRINT LOCATION & CONTENTS
BACK		leay	-1,y	;POINT TO LAST MEM LOCATION
		bra	MEMC2	;PRINT LOCATION & CONTENTS

* "S" DISPLAY STACK
* HEX-ASCII DISPLAY OF CURRENT STACK CONTENTS FROM
* CURRENT STACK POINTER TO INTERNAL STACK LIMIT.

DISSTK		lbsr	PRTSP	;PRINT CURRENT STACK POINTER
		tfr	u,y
		ldx	#STACK	;LOAD INTERNAL STACK AS UPPER LIMIT
		leax	-1,x	;POINT TO CURRENT STACK
		bra	MDUMP1	;ENTER MEMORY DUMP OF STACK CONTENTS

* "E" DUMP MEMORY FOR EXAMINE IN HEX AND ASCII
* AFTER CALLING 'IN2ADR' LOWER ADDRESS IN Y-REG.
*                        UPPER ADDRESS IN X-REG.
* IF HEX ADDRESSES ARE INVALID (V)=1.

;		VERIFY	$f996
MEMDUMP		lbsr	IN2ADR	;INPUT ADDRESS BOUNDRIES
		bvs	EDPRTN	;NEW COMMAND IF ILLEGAL HEX
;
; The start address is now in IY and the end in IX
;
MDUMP1		pshs	y	;COMPARE LOWER TO UPPER BOUNDS
		cmpx	,s++	;LOWER BOUNDS > UPPER BOUNDS?
		bcc	AJDUMP	;IF NOT, DUMP HEX AND ASCII
EDPRTN		rts

* ADJUST LOWER AND UPPER ADDRESS LIMITS
* TO EVEN 16 BYTE BOUNDRIES.

* IF LOWER ADDR = $4532
* LOWER BOUNDS WILL BE ADJUSTED TO = $4530.

* IF UPPER ADDR = $4567
* UPPER BOUNDS WILL BE ADJUSTED TO = $4570.

* ENTER WITH LOWER ADDRESS IN X-REG.
*           -UPPER ADDRESS ON TOP OF STACK.

AJDUMP		tfr	x,d	;GET UPPER ADDR IN D-REG
		addd	#$10	;ADD 16 TO UPPER ADDRESS
		andb	#$F0	;MASK TO EVEN 16 BYTE BOUNDRY
		pshs	a,b	;SAVE ON STACK AS UPPER DUMP LIMIT
		tfr	y,d	;$F9A5 GET LOWER ADDRESS IN D-REG
		andb	#$F0	;MASK TO EVEN 16 BYTE BOUNDRY
		tfr	d,x	;PUT IN X-REG AS LOWER DUMP LIMIT
NXTLIN		cmpx	,s	;COMPARE LOWER TO UPPER LIMIT
		beq	SKPDMP	;IF EQUAL SKIP HEX-ASCII DUMP
		lbsr	INCHEK	;CHECK FOR INPUT FROM KEYBOARD
		beq	EDUMP	;IF NONE, CONTINUE WITH DUMP
SKPDMP		leas	2,s	;READJUST STACK IF NOT DUMPING
		rts

* PRINT 16 HEX BYTES FOLLOWED BY 16 ASCII CHARACTERS
* FOR EACH LINE THROUGHOUT ADDRESS LIMITS.

EDUMP		pshs	x	;PUSH LOWER ADDR LIMIT ON STACK
		ldx	#MSG5	;POINT TO MSG " - "
		lbsr	PSTRNG	;PRINT MSG
		ldx	,s	;LOAD LOWER ADDR FROM TOP OF STACK
		lbsr	OUT4H	;PRINT THE ADDRESS		
		lbsr	OUT2S	;PRINT 2 SPACES
		ldb	#$10	;LOAD COUNT OF 16 BYTES TO DUMP
ELOOP		lda	,x+	;GET FROM MEMORY HEX BYTE TO PRINT
		lbsr	OUT2H	;OUTPUT HEX BYTE AS ASCII
		lbsr	OUT1S	;OUTPUT SPACE
		decb		;$F9D1 DECREMENT BYTE COUNT
		bne	ELOOP	;CONTINUE TIL 16 HEX BYTES PRINTED

* PRINT 16 ASCII CHARACTERS
* IF NOT PRINTABLE OR NOT VALID
* ASCII PRINT A PERIOD (.)
		lbsr	OUT2S	;2 SPACES
		ldx	,s++	;GET LOW LIMIT FRM STACK - ADJ STACK
		ldb	#$10	;SET ASCII CHAR TO PRINT = 16
EDPASC		lda	,x+	;GET CHARACTER FROM MEMORY
		cmpa	#$20	;IF LESS THAN $20, NON-PRINTABLE?
		bcs	PERIOD	;IF SO, PRINT PERIOD INSTEAD
		cmpa	#$7E	;IS IT VALID ASCII?
		bls	PRASC	;IF SO PRINT IT
PERIOD		lda	#'.'	;LOAD A PERIOD (.)
PRASC		lbsr	OUTCH	;PRINT ASCII CHARACTER
		decb		;DECREMENT COUNT
		bne	EDPASC
		bra	NXTLIN

***** "Q" MEMORY TEST *****

;		VERIFY	$f9f2
MEMTST		clr	,-s	;CLEAR BYTE ON STACK
		clr	,-s	;CLEAR ANOTHER BYTE
		lbsr	IN2ADR	;GET BEGIN(Y) & END(X) ADDR. LIMITS
		pshs	x,y	;SAVE ADDRESSES ON STACK
		bvs	ADJSK6	;EXIT IF NOT VALID HEX
		cmpx	2,s	;COMPARE BEGIN TO END ADDR.
		bcs	ADJSK6	;EXIT IF BEGIN > END ADDR.
		lbsr	OUT1S	;OUTPUT SPACE
MEMSET		tfr	y,d	;PUT BEGIN ADDR. IN 'D'-ACCUM.
		addd	4,s	;ADD PASS COUNT TO BEGIN ADDR
		pshs	b	;ADD LS BYTE TO MS BYTE OF BEGIN ADDR
		adda	,s+
		sta	,y+	;SAVE THIS DATA BYTE AT BEGIN ADDR
		cmpy	,s	;COMPARE END TO BEGIN ADDR
		bcs	MEMSET	;IF BEGIN LOWER, CONTINUE TO SET MEMORY
		ldy	2,s	;RELOAD BEGIN ADDRESS
TEST1		tfr	y,d	;PUT BEGIN ADDR IN 'D'-ACC.
		addd	4,s	;ADD PASS COUNT TO ADDRESS
		pshs	a	;ADD MS BYTE TO LS BYTE OF ADDRESS
		addb	,s+
		eorb	,y+	;EX-OR THIS DATA WITH DATA IN MEMORY LOC.
		beq	GUDPAS	;IF (Z) SET, MEMORY BYTE OK
		ldx	#MSG5	;POINT TO MSG " - "
		lbsr	PSTRNG	;PRINT MSG
		leax	-1,y	;GET ERROR ADDRESS IN X-REG
		lbsr	OUT4H	;OUTPUT IT
		pshs	x	;PUSH ERROR ADDR ON STACK
		ldx	#MSG8	;POINT TO MSG " =>"
		lbsr	PDATA	;PRINT MSG
		puls	x	;POP ERROR ADDR FROM STACK
		lbsr	LRA	;GET PHYSICAL ADDR FROM LRA
		lbsr	XASCII	;OUTPUT EXTENDED 4 BITS OF PHYSICAL ADDR
		lbsr	OUT4H	;OUTPUT LS 16 BITS OF PHYSICAL ADDR
		ldx	#MSG6	;POINT TO MSG ", PASS "
		lbsr	PDATA	;PRINT MSG
		ldx	4,s	;LOAD PASS COUNT
		lbsr	OUT4H	;OUTPUT IT
		ldx	#MSG7	;POINT TO MSG ", BITS IN ERROR
		lbsr	PDATA	;PRINT MSG
		tfr	b,a	;GET ERROR BYTE INTO A-ACC
		ldx	#MSG9	;POINT TO MSG "76543210"
		lbsr	BIASCI	;OUTPUT IN BINARY/ASCII FORMAT
		lbsr	INCHEK	;CHECK FOR INPUT FROM KEYBOARD $FA56
		bne	ADJSK6	;IF SO, EXIT MEMORY TEST
GUDPAS		cmpy	,s	;COMPARE END ADDR TO BEGIN ADDR
		bcs	TEST1
		lda	#'+'	;GET "PASS" SYMBOL IF MEMORY PASS OK
		lbsr	OUTCH	;OUTPUT SYMBOL TO TERMINAL
		lbsr	INCHEK	;INPUT FROM KEYBOARD?
		bne	ADJSK6	;IF SO, EXIT MEMORY TEST
		ldy	2,s	;LOAD BEGIN ADDRESS
		inc	5,s	;INCREMENT LS BYTE OF PASS COUNT
		bne	MEMSET	;IF NOT ZERO, SET NEXT MEMORY BYTE
		inc	4,s	;INCREMENT MS BYTE OF PASS COUNT
		bne	MEMSET	;DONE WITH 65,535 PASSES OF MEMORY?
ADJSK6		leas	6,s	;ADJ STACK POINTER BY 6
		rts

***** "B" SET BREAKPOINT *****

BRKPNT		lbsr	IN1ADR	;GET BREAKPOINT ADDRESS
		bvs	EXITBP	;EXIT IF INVALID HEX ADDR.
		cmpx	#STACK	;ADDRESS ILLEGAL IF >=$DFC0
		bcc	BPERR	;IF ERROR PRINT (?), EXIT
		pshs	x	;$FA82 PUSH BP ADDRESS ON STACK
		ldx	#$FFFF	;LOAD DUMMY ADDR TO TEST BP TABLE
		bsr	BPTEST	;TEST BP TABLE FOR FREE SPACE
		puls	x	;POP BP ADDRESS FROM STACK
		beq	BPERR	;(Z) SET, OUT OF BP TABLE SPACE
		lda	,x	;GET DATA AT BREAKPOINT ADDRESS
		cmpa	#$3F	;IS IT A SWI?
		beq	BPERR	;IF SWI ALREADY, INDICATE ERROR
		sta	,y+	;SAVE DATA BYTE IN BP TABLE
		stx	,y	;SAVE BP ADDRESS IN BP TABLE
		lda	#$3F	;LOAD A SWI ($3F)
		sta	,x	;SAVE SWI AT BREAKPOINT ADDRESS
EXITBP		rts

*  INDICATE ERROR SETTING BREAKPOINT

BPERR		lbsr	OUT1S	;OUTPUT SPACE
		lda	#'?'	;LOAD (?), INDICATE BREAKPOINT ERROR
		lbra	OUTCH	;PRINT "?"

*** "X" CLEAR OUTSTANDING BREAKPOINTS ***

XBKPNT		ldy	#BPTBL	;POINT TO BREAKPOINT TABLE
		ldb	#8	;LOAD BREAKPOINT COUNTER
XBPLP		bsr	RPLSWI	;REMOVE USED ENTRY IN BP TABLE
		decb		;$FAAC DECREMENT BP COUNTER
		bne	XBPLP	;END OF BREAKPOINT TABLE?
		rts

***** SWI ENTRY POINT *****

;		VERIFY	$fab3
SWIE		tfr	s,u	;TRANSFER STACK TO USER POINTER
		ldx	10,u	;LOAD PC FROM STACK INTO X-REG
		leax	-1,x	;ADJUST ADDR DOWN 1 BYTE.
		bsr	BPTEST	;FIND BREAKPOINT IN BP TABLE
		beq	REGPR	;IF FOUND, REPLACE DATA AT BP ADDR
		stx	10,u	;SAVE BREAKPOINT ADDR IN STACK
		bsr	RPLSWI	;GO REPLACE SWI WITH ORIGINAL DATA
REGPR		lbsr	REGSTR	;GO PRINT REGISTERS
		lbra	NEXTCMD	;GET NEXT COMMAND
RPLSWI		ldx	1,y	;LOAD BP ADDRESS FROM BP TABLE
		cmpx	#STACK	;COMPARE TO TOP AVAILABLE USER MEMORY
		bcc	FFSTBL	;GO RESET TABLE ENTRY TO $FF'S
		lda	,x	;GET DATA FROM BP ADDRESS
		cmpa	#$3F	;IS IT SWI?
		bne	FFSTBL	;IF NOT, RESET TABLE ENTRY TO $FF'S
		lda	,y	;GET ORIGINAL DATA FROM BP TABLE
		sta	,x	;$FAD3 RESTORE DATA AT BP ADDRESS
FFSTBL		lda	#$FF	;LOAD $FF IN A-ACC
		sta	,y+	;RESET BREAKPOINT TABLE DATA TO $FF'S
		sta	,y+	;RESET BREAKPOINT TABLE ADDR TO $FF'S
		sta	,y+
		rts

** SEARCH BREAKPOINT TABLE FOR MATCH **

BPTEST		ldy	#BPTBL	;POINT TO BREAKPOINT TABLE
		ldb	#8	;LOAD BREAKPOINT COUNTER
FNDBP		lda	,y+	;LOAD DATA BYTE
		cmpx	,y++	;COMPARE ADDRESS, IS IT SAME?
		beq	BPADJ	;IF SO, ADJUST POINTER FOR TABLE ENTRY
		decb		;IF NOT, DECREMENT BREAKPOINT COUNTER
		bne	FNDBP	;AND LOOK FOR NEXT POSSIBLE MATCH
		rts


BPADJ		leay	-3,y	;MOVE POINTER TO BEGIN OF BP ENTRY
		rts

*** "D" DISK BOOT FOR DMAF2 ***
	if	DMAF2
DBOOT		lda	#$DE
		sta	DRVREG
		lda	#$FF
		sta	PRIREG	;$FAF8
		sta	CCREG
		sta	AAAREG
		sta	BBBREG
		tst	CCREG
		lda	#$D8
		sta	COMREG
		lbsr	DLY
DBOOT0		lda	COMREG
		bmi	DBOOT0
		lda	#$09
		sta	COMREG
		lbsr	DLY

DISKWT		lda	COMREG	;FETCH DRIVE STATUS
		bita	#1	;TEST BUSY BIT
		bne	DISKWT	;LOOP UNTIL NOT BUSY

		bita	#$10
		bne	DBOOT

		ldx	#$C000	;LOGICAL ADDR. = $C000
		bsr	LRA	;GET 20 BIT PHYSICAL ADDR. OF LOG. ADDR.
		ora	#$10
		sta	CCCREG
		tfr	x,d
		coma
		comb
		std	ADDREG
		ldx	#$FEFF	;LOAD DMA BYTE COUNT = $100
		stx	CNTREG	;STORE IN COUNT REGISTER
		lda	#$FF	;LOAD THE CHANNEL REGISTER
		sta	CCREG
		lda	#$FE	;SET CHANNEL 0
		sta	PRIREG
		lda	#1	;SET SECTOR TO "1"
		sta	SECREG	;ISSUE COMMAND
		lda	#$8C	;SET SINGLE SECTOR READ
		sta	COMREG	;ISSUE COMMAND
		bsr	DLY

* THE FOLLOWING CODE TESTS THE STATUS OF THE
* CHANNEL CONTROL REGISTER. IF "D7" IS NOT
* ZERO THEN IT WILL LOOP WAITING FOR "D7"
* TO GO TO ZERO. IF AFTER 65,536 TRIES IT
* IS STILL A ONE THE BOOT OPERATION WILL
* BE STARTED OVER FROM THE BEGINING.

		clrb
DBOOT1		pshs	b	;$FB55
		clrb
DBOOT2		tst	CCREG
		bpl	DBOOT3
		decb
		bne	DBOOT2
		puls	b
		decb
		bne	DBOOT1
		bra	DBOOT
DBOOT3		puls	b
		lda	COMREG
		bita	#$1C
		beq	DBOOT4
		rts


DBOOT4		ldb	#$DE
		stb	DRVREG
		ldx	#$C000
		stx	10,u
		tfr	u,s	;$FB7B
		rti
	endif

	if	SD_SUPPORT
;
;=====================================================
; This boots the OS from the SD card.  No registers
; are set on entry, and this never returns.  If the
; boot fails, jump back into SBUG.
;
SdBoot2 	ldx	#dbmsg		;print prompt
		jsr	PDATA
SdBoot		jsr	xParInit	;do initialization
		ldx	#BootFCB
		jsr	DiskReadSector
		bcs	bootErr
		jmp	BOOT_ADDR
;
bootErr		ldx	#berrmsg
		jsr	PSTRNG
		jmp	MONITOR
;
berrmsg		db	CR,LF
		db	"BOOT ERROR!"
		db	CR,LF,0,EOT
dbmsg		db	BS,"isk boot"
		db	CR,LF,EOT
;
; FCB used to load the boot sector into memory
;
BootFCB		db	0	;drive 0
		db	0	;track 0
		db	0	;sector 0
		db	0	;sectors per track
		dw	BOOT_ADDR	;buffer address
	endif

***** LRA LOAD REAL ADDRESS *****

* THE FOLLOWING CODE LOADS THE 20-BIT
* PHYSICAL ADDRESS OF A MEMORY BYTE
* INTO THE "A" AND "X" REGISTERS. THIS
* ROUTINE IS ENTERED WITH THE LOGICAL
* ADDRESS OF A MEMORY BYTE IN THE "IX"
* REGISTER. EXIT IS MADE WITH THE HIGH-
* ORDER FOUR BITS OF THE 20-BIT PHYSICAL
* ADDRESS IN THE "A" REGISTER, AND THE
* LOW-ORDER 16-BITS OF THE 20-BIT
* PHYSICAL ADDRESS IN THE "IX" REGISTER.
* ALL OTHER REGISTERS ARE PRESERVED.
* THIS ROUTINE IS REQUIRED SINCE THE
* DMAF1 AND DMAF2 DISK CONTROLLERS MUST
* PRESENT PHYSICAL ADDRESSES ON THE
* SYSTEM BUS.

		FORCE	$fb81
LRA		pshs	a,b,x,y	;PUSH REGISTERS ON STACK
		lda	2,s	;GET MSB LOGICAL ADDR FRM X REG ON STACK
		lsra
		lsra		;ADJ FOR INDEXED INTO
		lsra		;CORRESPONDING LOCATION
		lsra		;IN LRA TABLE
		ldy	#LRARAM	;LOAD LRA TABLE BASE ADDRESS
		ldb	a,y	;GET PHYSICAL ADDR. DATA FROM LRA TABLE
		lsrb		;. REAL ADDR. TO REFLECT EXTENDED
		lsrb		; ADDRESS.
		lsrb		; MS 4-BITS ARE RETURNED
		lsrb		; THE "A" ACCUMULATOR
		stb	,s	;MS 4 BITS IN A ACCUM. STORED ON STACK
		ldb	a,y	;LOAD REAL ADDRESS DATA FROM LRA TABLE
		comb		;COMP TO ADJ FOR PHYSICAL ADDR. IN X REG
		aslb		;ADJ DATA FOR RELOCATION IN X REG
		aslb
		aslb		;$FB97
		aslb
		lda	2,s	;GET MS BYTE OF LOGICAL ADDR.
		anda	#$0F	;MASK MS NIBBLE OF LOGICAL ADDRESS
		sta	2,s	;SAVE IT IN X REG ON STACK
		orb	2,s	;SET MS BYTE IN X REG TO ADJ PHY ADDR.

* PLUS LS NIBBLE OF LOGICAL ADDRESS
		stb	2,s	;SAVE AS LS 16 BITS OF PHY ADDR IN X REG
* ON STACK
		puls	a,b,x,y	;POP REGS. FROM STACK
		rts

* DELAY LOOP

DLY		pshs	b	;SAVE CONTENTS OF "B"
		ldb	#$20	;GET LOOP DELAY VALUE
SUB1		decb		;SUBTRACT ONE FROM VALUE
		bne	SUB1	;LOOP UNTIL ZERO
		puls	b	;RESTORE CONTENTS OF "B"
		rts

***** "U" MINIDISK BOOT *****
	if	DC_X
MINBOOT		tst	Comreg
		clr	Drvreg	;SELECT DRIVE 0

* DELAY BEFORE ISSUING RESTORE COMMAND
		ldb	#3
		ldx	#0
LOOP		leax	1,x	;$FBBB
		cmpx	#0
		bne	LOOP
		decb		;$FBC2
		bne	LOOP

		lda	#$0F	;*LOAD HEAD, VERIFY, 20msec/step
		sta	Comreg	;ISSUE RESTORE COMMAND
		bsr	DELAY
LOOP1		ldb	Comreg	;$FBCC
		bitb	#1
		bne	LOOP1	;LOOP UNTIL THRU
		lda	#1
		sta	Secreg	;SET SECTOR REGISTER TO ONE
		bsr	DELAY
		lda	#$8C	;LOAD HEAD, DELAY 10msec,
		sta	Comreg	;AND READ SINGLE RECORD
		bsr	DELAY
		ldx	#$C000
		bra	LOOP3

LOOP2		bitb	#2	;$FBE6 DRQ?
		beq	LOOP3
		lda	Datreg
		sta	,x+

LOOP3		ldb	Comreg	;FETCH STATUS
		bitb	#1	;BUSY?
		bne	LOOP2
		bitb	#$2C	;CRC ERROR OR LOST DATA?
		beq	LOOP4
		rts
LOOP4		ldx	#$C000	;$FBFB
		stx	10,u
		tfr	u,s
		rti

* DELAY

DELAY		ldb	#$20
LOOP5		decb
		bne	LOOP5
		rts
	endif	;DC_X

***** "L" LOAD MIKBUG TAPE *****
* Otherwise known as an S-record file

LOAD
	if	READER_CONTROL
		lda	#$11	;LOAD 'DC1' CASS. READ ON CODE
		lbsr	OUTCH	;OUTPUT IT TO TERMINAL PORT
	endif
		clr	ECHO	;TURN OFF ECHO FLAG
LOAD1		lbsr	ECHON	;INPUT 8 BIT BYTE WITH NO ECHO
LOAD2		cmpa	#'S'	;IS IT AN "S", START CHARACTER ?
		bne	LOAD1	;IF NOT, DISCARD AND GET NEXT CHAR.
		lbsr	ECHON
		cmpa	#'9'	;IS IT A "9" , END OF FILE CHAR ?
		beq	LOAD21	;IF SO, EXIT LOAD
	if	ALLOW_S5
		cmpa	#'5'	;5 can also end some files
		beq	LOAD22
	endif	;ALLOW_S5
		cmpa	#'1'	;IS IT A "1" , FILE LOAD CHAR ?
		bne	LOAD2	;IF NOT, LOOK FOR START CHAR.
		lbsr	BYTE	;INPUT BYTE COUNT
		pshs	a	;PUSH COUNT ON STACK
		bvs	LODERR	;(V) C-CODE SET, ILLEGAL HEX
		lbsr	IN1ADR	;INPUT LOAD ADDRESS
		bvs	LODERR	;(V) C-CODE SET, ADDR NOT HEX
		pshs	x	;PUSH ADDR ON STACK
		ldb	,s+	;LOAD MSB OF ADDR AS CHECKSUM BYTE
		addb	,s+	;ADD LSB OF ADDR TO CHECKSUM
		addb	,s	;ADD BYTE COUNT BYTE TO CHECKSUM
		dec	,s	;$FC37 DECREMENT BYTE COUNT 2 TO BYPASS
		dec	,s	;ADDRESS BYTES.
LOAD10		pshs	b	;PUSH CHECKSUM ON STACK
		lbsr	BYTE	;INPUT DATA BYTE (2 HEX CHAR)
		puls	b	;POP CHECKSUM FROM STACK
		bvs	LODERR	;(V) SET, DATA BYTE NOT HEX
		pshs	a	;PUSH DATA BYTE ON STACK
		addb	,s+	;ADD DATA TO CHECKSUM, AUTO INC STACK
		dec	,s	;DECREMENT BYTE COUNT 1
		beq	LOAD16	;IF BYTE COUNT ZERO, TEST CHECKSUM
		sta	,x+	;SAVE DATA BYTE IN MEMORY
		bra	LOAD10	;GET NEXT DATA BYTE
LODERR		clrb		;ERROR CONDITION, ZERO CHECKSUM
LOAD16		puls	a	;ADJUST STACK (REMOVE BYTE COUNT)
		cmpb	#$FF	;CHECKSUM OK?
		beq	LOAD	;IF SO, LOAD NEXT LINE
		lda	#'?'	;LOAD (?) ERROR INDICATOR
		lbsr	OUTCH	;OUTPUT IT TO TERMINAL
LOAD21		com	ECHO	;TURN ECHO ON
	if	READER_CONTROL
		lda	#$13  	;$FC5F LOAD 'DC3' CASS. READ OFF CODE
		lbra	OUTCH	;OUTPUT IT
	else
		rts
	endif
;
; Handle the rest of an S5 record; byte count is next
; followed by that many bytes.
;
	if	ALLOW_S5
LOAD22		jsr	BYTE
		tfr	a,b	;move byte count into B
LOAD23		cmpb	#0
		beq	LOAD21	;all done
		pshs	b	;save byte count
		jsr	BYTE	;get next byte
		puls	b
		decb
		bra	LOAD23
	endif	;ALLOW_S5
***** "P" PUNCH MIKBUG TAPE *****

PUNCH		clr	,-s	;CLEAR RESERVED BYTE ON STACK
		lbsr	IN2ADR	;GET BEGIN AND END ADDRESS
		pshs	x,y	;SAVE ADDRESSES ON STACK
		bvs	PUNEXT	;(V) C-CODE SET, EXIT PUNCH
		cmpx	2,s	;COMPARE BEGIN TO END ADDR
		bcs	PUNEXT	;IF BEGIN GREATER THAN END, EXIT PUNCH
		leax	1,x	;INCREMENT END ADDRESS
		stx	,s	;STORE END ADDR ON STACK
	if	READER_CONTROL
		lda	#$12	;LOAD 'DC2' PUNCH ON CODE
		lbsr	OUTCH	;OUTPUT IT TO TERMINAL
	endif
PUNCH2		ldd	,s	;LOAD END ADDR IN D-ACC
		subd	2,s	;SUBTRACT BEGIN FROM END
		beq	PUNCH3	;SAME, PUNCH 32 BYTES DEFAULT
		cmpd	#$20	;LESS THAN 32 BYTES?
		bls	PUNCH4	;PUNCH THAT MANY BYTES
PUNCH3		ldb	#$20	;LOAD BYTE COUNT OF 32.
PUNCH4		stb	4,s	;STORE ON STACK AS BYTE COUNT
		ldx	#MSG20	;POINT TO MSG "S1"
		lbsr	PSTRNG	;PRINT MSG
		addb	#3	;ADD 3 BYTES TO BYTE COUNT
		tfr	b,a	;GET BYTE COUNT IN A-ACC TO PUNCH
		lbsr	OUT2H	;OUTPUT BYTE COUNT
		ldx	2,s	;LOAD BEGIN ADDRESS
		lbsr	OUT4H	;PUNCH ADDRESS
		addb	2,s	;ADD ADDR MSB TO CHECKSUM
		addb	3,s	;ADD ADDR LSB TO CHECKSUM
PUNCHL		addb	,x	;ADD DATA BYTE TO CHECKSUM
		lda	,x+	;LOAD DATA BYTE TO PUNCH
		lbsr	OUT2H	;OUTPUT DATA BYTE
		dec	4,s	;DECREMENT BYTE COUNT
		bne	PUNCHL	;NOT DONE, PUNCH NEXT BYTE
		comb		;1's COMPLIMENT CHECKSUM BYTE
		tfr	b,a	;GET IT IN A-ACC TO PUNCH
		lbsr	OUT2H	;OUTPUT CHECKSUM BYTE
		stx	2,s	;SAVE X-REG IN STACK AS NEW PUNCH ADDR
		cmpx	,s	;COMPARE IT TO END ADDR
		bne	PUNCH2	;$FCB5 PUNCH NOT DONE, CONT.
PUNEXT		
	if	READER_CONTROL
		lda	#$14	;LOAD 'DC4' PUNCH OFF CODE
		lbsr	OUTCH	;OUTPUT IT
	endif
		leas	5,s	;READJUST STACK POINTER
		rts


PRTSP		ldx	#MSG10	;POINT TO MSG "SP="
		lbsr	PDATA	;PRINT MSG
		tfr	u,x
		lbra	OUT4H
PRTUS		ldx	#MSG12	;POINT TO MSG "US="
		lbsr	PDATA	;PRINT MSG
		ldx	8,u
		lbra	OUT4H
PRTDP		ldx	#MSG15	;POINT TO MSG "DP="
		lbsr	PDATA	;PRINT MSG
		lda	3,u
		lbra	OUT2H	;OUTPUT HEX BYTE AS ASCII
PRTIX		ldx	#MSG14	;POINT TO MSG "IX="
		lbsr	PDATA	;PRINT MSG
		ldx	4,u	;$FCE6
		lbra	OUT4H
PRTIY		ldx	#MSG13	;POINT TO MSG "IY="
		lbsr	PDATA	;PRINT MSG
		ldx	6,u
		lbra	OUT4H
PRTPC		ldx	#MSG11	;POINT TO MSG "PC="
		lbsr	PDATA	;PRINT MSG
		ldx	10,u
		bra	OUT4H
PRTA		ldx	#MSG16	;POINT TO MSG "A="
		lbsr	PDATA	;PRINT MSG
		lda	1,u
		bra	OUT2H	;OUTPUT HEX BYTE AS ASCII
PRTB		ldx	#MSG17	;POINT TO MSG "B="
		lbsr	PDATA	;PRINT MSG
		lda	2,u
		bra	OUT2H	;OUTPUT HEX BYTE AS ASCII
PRTCC		ldx	#MSG18	;POINT TO MSG "CC:"
		lbsr	PDATA	;PRINT MSG
		lda	,u
		ldx	#MSG19	;POINT TO MSG "EFHINZVC"
		bra	BIASCI	;OUTPUT IN BINARY/ASCII FORMAT

* THE FOLLOWING ROUTINE LOOPS WAITING FOR THE
* OPERATOR TO INPUT TWO VALID HEX ADDRESSES.
* THE FIRST ADDRESS INPUT IS RETURNED IN "IY".
* THE SECOND IS RETURNED IN "IX". THE "V" BIT
* IN THE C-CODE REG. IS SET IF AN INVALID HEX
* ADDRESS IS INPUT.

;		VERIFY	$fd24
IN2ADR		bsr	IN1ADR	;GET FIRST ADDRESS
		bvs	NOTHEX	;EXIT IF NOT VALID HEX
		tfr	x,y	;SAVE FIRST ADDR. IN "IY"
		lda	#'-'
		lbsr	OUTCH	;PRINT " - "

* THE FOLLOWING ROUTINE LOOPS WAITING FOR THE
* OPERATOR TO INPUT ONE VALID HEX ADDRESS. THE
* ADDRESS IS RETURNED IN THE "X" REGISTER.

IN1ADR		bsr	BYTE	;INPUT BYTE (2 HEX CHAR)
		bvs	NOTHEX	;EXIT IF NOT VALID HEX
		tfr	d,x
		bsr	BYTE	;INPUT BYTE (2 HEX CHAR)
		bvs	NOTHEX
		pshs	x
		sta	1,s
		puls	x
		rts

***** INPUT BYTE (2 HEX CHAR.) *****

BYTE		bsr	INHEX	;GET HEX LEFT
		bvs	NOTHEX	;EXIT IF NOT VALID HEX
		asla
		asla
		asla		;SHIFT INTO LEFT NIBBLE
		asla
		tfr	a,b	;PUT HEXL IN "B"
		bsr	INHEX	;GET HEX RIGHT
		bvs	NOTHEX	;EXIT IF NOT VALID HEX
		pshs	b	;PUSH HEXL ON STACK
		adda	,s+	;ADD HEXL TO HEXR AND ADJ. STK
		rts		;RETURN WITH HEX L&R IN "A"


INHEX		bsr	ECHON	;INPUT ASCII CHAR.
		cmpa	#'0'	;IS IT > OR = "0" ?
		bcs	NOTHEX	;IF LESS IT AIN'T HEX
		cmpa	#'9'	;IS IT < OR = "9" ?
		bhi	INHEXA	;IF > MAYBE IT'S ALPHA
		suba	#$30	;ASCII ADJ. NUMERIC
		rts


INHEXA		cmpa	#'A'	;IS IT > OR = "A"
		bcs	NOTHEX	;IF LESS IT AIN'T HEX
		cmpa	#'F'	;IS IT < OR = "F" ?
		bhi	INHEXL	;IF > IT AIN'T HEX
		suba	#$37	;ASCII ADJ. ALPHA
		rts

INHEXL		cmpa	#'a'	;IS IT > OR = "a"
		bcs	NOTHEX	;IF LESS IT AIN'T HEX
		cmpa	#'f'	;IS IT < "f"
		bhi	NOTHEX	;IF > IT AIN'T HEX
		suba	#$57	;ADJUST TO LOWER CASE
		rts


NOTHEX		orcc	#2	;SET (V) FLAG IN C-CODES REGISTER
		rts
;
; Output contents of X as four hex digits.
;
OUT4H		pshs	x	;PUSH X-REG. ON THE STACK
		puls	a	;POP MS BYTE OF X-REG INTO A-ACC.
		bsr	OUTHL	;OUTPUT HEX LEFT
		puls	a	;POP LS BYTE OF X-REG INTO A-ACC.
;
; Output A as two hex digits.
;
OUTHL		equ	*
OUT2H		pshs	a	;SAVE IT BACK ON STACK
		lsra		;CONVERT UPPER HEX NIBBLE TO ASCII
		lsra
		lsra
		lsra
		bsr	XASCII	;PRINT HEX NIBBLE AS ASCII
OUTHR		puls	a	;CONVERT LOWER HEX NIBBLE TO ASCII
		anda	#$0F	;STRIP LEFT NIBBLE
;
; Output lower nibble of A as a hex digit.  Upper nibble
; must be 0!
;
XASCII		adda	#'0'	;ASCII ADJ
		cmpa	#'9'	;IS IT < OR = "9" ?
		ble	OUTC	;IF LESS, OUTPUT IT
		adda	#7	;IF > MAKE ASCII LETTER
OUTC		bra	OUTCH	;OUTPUT CHAR

* BINARY / ASCII --- THIS ROUTINE
* OUTPUTS A BYTE IN ENHANCED
* BINARY FORMAT. THE ENHANCEMENT
* IS DONE BY SUBSTITUTING ASCII
* LETTERS FOR THE ONES IN THE BYTE.
* THE ASCII ENHANCEMENT LETTERS
* ARE OBTAINED FROM THE STRING
* POINTED TO BY THE INDEX REG. "X".

BIASCI		pshs	a	;SAVE "A" ON STACK
		ldb	#8	;PRESET LOOP# TO BITS PER BYTE
OUTBA		lda	,x+	;GET LETTER FROM STRING
		asl	,s	;TEST BYTE FOR "1" IN B7
		bcs	PRTBA	;IF ONE PRINT LETTER
		lda	#'-'	;IF ZERO PRINT "-"
PRTBA		bsr	OUTCH	;PRINT IT
		bsr	OUT1S	;PRINT SPACE
		decb		;SUB 1 FROM #BITS YET TO PRINT
		bne	OUTBA
		puls	a
		rts

* PRINT STRING PRECEEDED BY A CR & LF.

PSTRNG		bsr	PCRLF	;PRINT CR/LF
		bra	PDATA	;PRINT STRING POINTED TO BY IX

* PCRLF

PCRLF		pshs	x	;SAVE IX
		ldx	#MSG2+1	;POINT TO MSG CR/LF + 3 NULS
		bsr	PDATA	;PRINT MSG
		puls	x	;RESTORE IX
		rts
PRINT		bsr	OUTCH

* PDATA

PDATA		lda	,x+	;GET 1st CHAR. TO PRINT
		cmpa	#4	;IS IT EOT?
		bne	PRINT	;IF NOT EOT PRINT IT
		rts


ECHON		tst	ECHO	;IS ECHO REQUIRED ?
		beq	INCH	;ECHO NOT REQ. IF CLEAR

* INCHE

* ---GETS CHARACTER FROM TERMINAL AND
* ECHOS SAME. THE CHARACTER IS RETURNED
* IN THE "A" ACCUMULATOR WITH THE PARITY
* BIT MASKED OFF. ALL OTHER REGISTERS
* ARE PRESERVED.

INCHE		bsr	INCH	;GET CHAR FROM TERMINAL
		anda	#$7F	;STRIP PARITY FROM CHAR.
		bra	OUTCH	;ECHO CHAR TO TERMINAL

* INCH

* GET CHARACTER FROM TERMINAL. RETURN
* CHARACTER IN "A" ACCUMULATOR AND PRESERVE
* ALL OTHER REGISTERS. THE INPUT CHARACTER
* IS 8 BITS AND IS NOT ECHOED.


INCH		pshs	x	;SAVE IX
		ldx	CPORT	;POINT TO TERMINAL PORT
GETSTA		lda	,x	;FETCH PORT STATUS
		bita	#1	;TEST READY BIT, RDRF ?
		beq	GETSTA	;IF NOT RDY, THEN TRY AGAIN
		lda	1,x	;FETCH CHAR
		puls	x	;RESTORE IX
		rts

* INCHEK

* CHECK FOR A CHARACTER AVAILABLE FROM
* THE TERMINAL. THE SERIAL PORT IS CHECKED
* FOR READ READY. ALL REGISTERS ARE
* PRESERVED, AND THE "Z" BIT WILL BE
* CLEAR IF A CHARACTER CAN BE READ.


INCHEK		pshs	a	;SAVE A ACCUM.
		lda	[CPORT]	;FETCH PORT STATUS
		bita	#1	;TEST READY BIT, RDRF ?
		puls	a	;RESTORE A ACCUM.
		rts

OUT2S		bsr	OUT1S	;OUTPUT 2 SPACES
OUT1S		lda	#$20	;OUTPUT 1 SPACE


* OUTCH

* OUTPUT CHARACTER TO TERMINAL.
* THE CHAR. TO BE OUTPUT IS
* PASSED IN THE A REGISTER.
* ALL REGISTERS ARE PRESERVED.

OUTCH		pshs	a,x	;SAVE A ACCUM AND IX
		ldx	CPORT	;GET ADDR. OF TERMINAL
FETSTA		lda	,x	;FETCH PORT STATUS
		bita	#2	;TEST TDRE, OK TO XMIT ?
		beq	FETSTA	;IF NOT LOOP UNTIL RDY
		puls	a	;GET CHAR. FOR XMIT
		sta	1,x	;XMIT CHAR.
		puls	x	;RESTORE IX
		rts


ACINIZ		ldx	CPORT	;POINT TO CONTROL PORT ADDRESS
		lda	#3	;RESET ACIA PORT CODE
		sta	,x	;STORE IN CONTROL REGISTER
		lda	#$11	;SET 8 DATA, 2 STOP AN 0 PARITY
		sta	,x	;STORE IN CONTROL REGISTER
		tst	1,x	;ANYTHING IN DATA REGISTER?
		lda	#$FF	;TURN ON ECHO FLAG
		sta	ECHO
		rts


* MONITOR KEYBOARD COMMAND JUMP TABLE


JMPTAB		equ	*
		db	1	;" ^A "
		dw	ALTRA
		db	2	;" ^B "
		dw	ALTRB
		db	3	;" ^C "
		dw	ALTRCC
		db	4	;" ^D "
		dw	ALTRDP
		db	$10	;" ^P "
		dw	ALTRPC
		db	$15	;" ^U "
		dw	ALTRU
		db	$18	;" ^X "
		dw	ALTRX
		db	$19	;" ^Y "
		dw	ALTRY

		db	'B'
		dw	BRKPNT
	if	DMAF2
		db	'D'
		dw	DBOOT
	endif
	if	SD_SUPPORT
		db	'D'	;boot from SD card
		dw	SdBoot2
	endif
		db	'E'
		dw	MEMDUMP
		db	'G'
		dw	GO
		db	'L'
		dw	LOAD
		db	'M'
		dw	MEMCHG
		db	'P'
		dw	PUNCH
		db	'Q'
		dw	MEMTST
		db	'R'
		dw	REGSTR
		db	'S'
		dw	DISSTK
	if	DC_X
		db	'U'
		dw	MINBOOT
	endif
		db	'X'
		dw	XBKPNT
	if	ENABLE_BASIC
		db	'!'
		dw	BASIC
		db	'@'
		dw	WARMS
	endif

TABEND		equ	*

* ** 6809 VECTOR ADDRESSES **

* FOLLOWING ARE THE ADDRESSES OF THE VECTOR ROUTINES
* FOR THE 6809 PROCESSOR. DURING INITIALIZATION THEY
* ARE RELOCATED TO RAM FROM $DFC0 TO $DFCF. THEY ARE
* RELOCATED TO RAM SO THAT THE USER MAY REVECTOR TO
* HIS OWN ROUTINES IF HE SO DESIRES.


RAMVEC		dw	SWIE	;USER-V
		dw	RTI	;SWI3-V
		dw	RTI	;SWI2-V
		dw	RTI	;FIRQ-V
		dw	RTI	;IRQ-V
		dw	SWIE	;SWI-V
		dw	$FFFF	;SVC-VO
		dw	$FFFF	;SVC-VL

* PRINTABLE MESSAGE STRINGS

MSG1		db	0,0,CR,LF,CR,LF
		db	'S-BUG 1.8.2 '
	if	SD_SUPPORT
		db	"with SD support"
	endif
	if	ENABLE_BASIC
		db	"with Tiny BASIC"
	endif
		db	", "
		db	EOT
MSG2		db	'K',CR,LF,EOT	;K, * CR/LF + 3 NULS
MSG3		db	'>'
		db	EOT
MSG4		db	'WHAT?'
		db	EOT
MSG5		db	' - '
		db	EOT
MSG6		db	', PASS '
		db	EOT
MSG7		db	', BITS IN ERROR: '
		db	EOT
MSG8		db	' => '
		db	EOT
MSG9		db	'76543210'
MSG10		db	'  SP='
		db	EOT
MSG11		db	'  PC='
		db	EOT
MSG12		db	'  US='
		db	EOT
MSG13		db	'  IY='
		db	EOT
MSG14		db	'  IX='
		db	EOT
MSG15		db	'  DP='
		db	EOT
MSG16		db	'  A='
		db	EOT
MSG17		db	'  B='
		db	EOT
MSG18		db	'  CC: '
		db	EOT
MSG19		db	'EFHINZVC'
MSG20		db	'S1'
		db	EOT

* MESSAGE EXPANSION AREA



* POWER UP/ RESET/ NMI ENTRY POINT
;
;=====================================================
; The CPU board has addresses FF00-FFFF hard-wired to
; always be the top of the monitor EPROM and also the
; DAT registers.  This code beginning at FF00 must set
; up the DAT so that logical addresses F900-FEFF are
; mapped to the EPROM as well.
;
; Any read from FF00 to FFFF reads from the EPROM
; while any write from FFF0 to FFFF will go to the
; DAT registers.
;
; So, it is imperative that the DAT tables get set up
; so that logical addresses F800-FFFF all point to
; the EPROM containing SBUG or else bad stuff will
; happen.
;
		FORCE	$ff00
START		ldx	#DATREGS	;POINT TO DAT RAM
		lda	#$F	;GET COMPLIMENT OF ZERO


* INITIALIZE DAT RAM --- LOADS $F-$0 IN LOCATIONS $0-$F
* OF DAT RAM, THUS STORING COMPLEMENT OF MSB OF ADDRESS
* IN THE DAT RAM. THE COMPLEMENT IS REQUIRED BECAUSE THE
* OUTPUT OF IC11, A 74S189, IS THE INVERSE OF THE DATA
* STORED IN IT.
;
; Also note that the upper nibble contains the non-inverted
; bank number for extended addressing.  This loop sets up all
; translations to point to block 0, which is good.
;
DATLP		sta	,x+	;STORE & POINT TO NEXT RAM LOCATION
		deca		;GET COMP. VALUE FOR NEXT LOCATION
		bne	DATLP	;ALL 16 LOCATIONS INITIALIZED ?

* NOTE: IX NOW CONTAINS $0000, DAT RAM IS NO LONGER
*       ADDRESSED, AND LOGICAL ADDRESSES NOW EQUAL
*       PHYSICAL ADDRESSES.

		lda	#$F0
		sta	,x	;STORE $F0 AT $FFFF
		ldx	#$D0A0	;ASSUME RAM TO BE AT $D000-$DFFF
		ldy	#TSTPAT	;LOAD TEST DATA PATTERN INTO "Y"
TSTRAM		ldu	,x	;SAVE DATA FROM TEST LOCATION
		sty	,x	;STORE TEST PATTERN AT $D0A0
		cmpy	,x	;IS THERE RAM AT THIS LOCATION ?
		beq	CNVADR	;IF MATCH THERE'S RAM, SO SKIP
		leax	-$1000,x	;ELSE POINT 4K LOWER
		cmpx	#$F0A0	;DECREMENTED PAST ZER0 YET ?
		bne	TSTRAM	;IF NOT CONTINUE TESTING FOR RAM
		bra	START	;ELSE START ALL OVER AGAIN


* THE FOLLOWING CODE STORES THE COMPLEMENT OF
* THE MS CHARACTER OF THE FOUR CHARACTER HEX
* ADDRESS OF THE FIRST 4K BLOCK OF RAM LOCATED
* BY THE ROUTINE "TSTRAM" INTO THE DAT RAM. IT
* IS STORED IN RAM IN THE LOCATION THAT IS
* ADDRESSED WHEN THE PROCESSOR ADDRESS IS $D---,
* THUS IF THE FIRST 4K BLOCK OF RAM IS FOUND
* WHEN TESTING LOCATION $70A0, MEANING THERE
* IS NO RAM PHYSICALLY ADDRESSED IN THE RANGE
* $8000-$DFFF, THEN THE COMPLEMENT OF THE
* "7" IN THE $70A0 WILL BE STORED IN
* THE DAT RAM. THUS WHEN THE PROCESSOR OUTPUTS
* AN ADDRESS OF $D---, THE DAT RAM WILL RESPOND
* BY RECOMPLEMENTING THE "7" AND OUTPUTTING THE
* 7 ONTO THE A12-A15 ADDRESS LINES. THUS THE
* RAM THAT IS PHYSICALLY ADDRESSED AT $7---
* WILL RESPOND AND APPEAR TO THE 6809 THAT IT
* IS AT $D--- SINCE THAT IS THE ADDRESS THE
* 6809 WILL BE OUTPUTING WHEN THAT 4K BLOCK
* OF RAM RESPONDS.


CNVADR		stu	,x	;RESTORE DATA AT TEST LOCATION
		tfr	x,d	;PUT ADDR. OF PRESENT 4K BLOCK IN D
		coma		;COMPLEMENT MSB OF THAT ADDRESS
		lsra		;PUT MS 4 BITS OF ADDRESS IN
		lsra		;LOCATION D0-D3 TO ALLOW STORING
		lsra		;IT IN THE DYNAMIC ADDRESS
		lsra		;TRANSLATION RAM.
		sta	$FFFD	;STORE XLATION FACTOR IN DAT "D"

		lds	#STACK	;INITIALIZE STACK POINTER


* THE FOLLOWING CHECKS TO FIND THE REAL PHYSICAL ADDRESSES
* OF ALL 4K BLKS OF RAM IN THE SYSTEM. WHEN EACH 4K BLK
* OF RAM IS LOCATED, THE COMPLEMENT OF IT'S REAL ADDRESS
* IS THEN STORED IN A "LOGICAL" TO "REAL" ADDRESS XLATION
* TABLE THAT IS BUILT FROM $DFD0 TO $DFDF. FOR EXAMPLE IF
* THE SYSTEM HAS RAM THAT IS PHYSICALLY LOCATED (WIRED TO
* RESPOND) AT THE HEX LOCATIONS $0--- THRU $F---....

*  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
* 4K 4K 4K 4K 4K 4K 4K 4K -- 4K 4K 4K 4K -- -- --

* ....FOR A TOTAL OF 48K OF RAM, THEN THE TRANSLATION TABLE
* CREATED FROM $DFD0 TO $DFDF WILL CONSIST OF THE FOLLOWING....

*  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
* 0F 0E 0D 0C 0B 0A 09 08 06 05 00 00 04 03 F1 F0


* HERE WE SEE THE LOGICAL ADDRESSES OF MEMORY FROM $0000-$7FFF
* HAVE NOT BEEN SELECTED FOR RELOCATION SO THAT THEIR PHYSICAL
* ADDRESS WILL = THEIR LOGICAL ADDRESS; HOWEVER, THE 4K BLOCK
* PHYSICALLY AT $9000 WILL HAVE ITS ADDRESS TRANSLATED SO THAT
* IT WILL LOGICALLY RESPOND AT $8000. LIKEWISE $A,$B, AND $C000
* WILL BE TRANSLATED TO RESPOND TO $9000,$C000, AND $D000
* RESPECTIVELY. THE USER SYSTEM WILL LOGICALLY APPEAR TO HAVE
* MEMORY ADDRESSED AS FOLLOWS....

*  0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
* 4K 4K 4K 4K 4K 4K 4K 4K 4K 4K -- -- 4K 4K -- --


		ldy	#LRARAM	;POINT TO LOGICAL/REAL ADDR. TABLE
		sta	13,y	;STORE $D--- XLATION FACTOR AT $DFDD
		clr	14,y	;CLEAR $DFDE
		lda	#$F0	;DESTINED FOR IC8 AN MEM EXPANSION ?
		sta	15,y	;STORE AT $DFDF
		lda	#$0C	;PRESET NUMBER OF BYTES TO CLEAR
CLRLRT		clr	a,y	;CLEAR $DFDC THRU $DFD0
		deca		;. 1 FROM BYTES LEFT TO CLEAR
		bpl	CLRLRT	;CONTINUE IF NOT DONE CLEARING
FNDRAM		leax	-$1000,x	;POINT TO NEXT LOWER 4K OF RAM
		cmpx	#$F0A0	;TEST FOR DECREMENT PAST ZERO
		beq	FINTAB	;SKIP IF FINISHED
		ldu	,x	;SAVE DATA AT CURRENT TEST LOCATION
		ldy	#TSTPAT	;LOAD TEST DATA PATTERN INTO Y REG.
		sty	,x	;STORE TEST PATT. INTO RAM TEST LOC.
		cmpy	,x	;VERIFY RAM AT TEST LOCATION
		bne	FNDRAM	;IF NO RAM GO LOOK 4K LOWER
		stu	,x	;ELSE RESTORE DATA TO TEST LOCATION
		ldy	#LRARAM	;POINT TO LOGICAL/REAL ADDR. TABLE
		tfr	x,d	;PUT ADDR. OF PRESENT 4K BLOCK IN D
		lsra		;PUT MS 4 BITS OF ADDR. IN LOC. D0-D3
		lsra		;TO ALLOW STORING IT IN THE DAT RAM.
		lsra
		lsra
		tfr	a,b	;SAVE OFFSET INTO LRARAM TABLE
		eora	#$0F	;INVERT MSB OF ADDR. OF CURRENT 4K BLK
		sta	b,y	;SAVE TRANSLATION FACTOR IN LRARAM TABLE
		bra	FNDRAM	;GO TRANSLATE ADDR. OF NEXT 4K BLK
FINTAB		lda	#$F1	;DESTINED FOR IC8 AND MEM EXPANSION ?
		ldy	#LRARAM	;POINT TO LRARAM TABLE
		sta	14,y	;STORE $F1 AT $DFCE

* THE FOLLOWING CHECKS TO SEE IF THERE IS A 4K BLK OF
* RAM LOCATED AT $C000-$CFFF. IF NONE THERE IT LOCATES
* THE NEXT LOWER 4K BLK AN XLATES ITS ADDR SO IT
* LOGICALLY RESPONDS TO THE ADDRESS $C---.


		lda	#$0C	;PRESET NUMBER HEX "C"
FINDC		ldb	a,y	;GET ENTRY FROM LRARAM TABLE
		bne	FOUNDC	;BRANCH IF RAM THIS PHYSICAL ADDR.
		deca		;ELSE POINT 4K LOWER
		bpl	FINDC	;GO TRY AGAIN
		bra	XFERTF
FOUNDC		clr	a,y	;CLR XLATION FACTOR OF 4K BLOCK FOUND
		stb	$C,y	;GIVE IT XLATION FACTOR MOVING IT TO $C---

* THE FOLLOWING CODE ADJUSTS THE TRANSLATION
* FACTORS SUCH THAT ALL REMAINING RAM WILL
* RESPOND TO A CONTIGUOUS BLOCK OF LOGICAL
* ADDRESSES FROM $0000 AND UP....

		clra		;START AT ZERO
		tfr	y,x	;START POINTER "X" START OF "LRARAM" TABLE.
COMPRS		ldb	a,y	;GET ENTRY FROM "LRARAM" TABLE
		beq	PNTNXT	;IF IT'S ZER0 SKIP
		clr	a,y	;ELSE ERASE FROM TABLE
		stb	,x+	;AND ENTER ABOVE LAST ENTRY- BUMP
PNTNXT		inca		;GET OFFSET TO NEXT ENTRY
		cmpa	#$0C	;LAST ENTRY YET ?
		blt	COMPRS

* THE FOLLOWING CODE TRANSFER THE TRANSLATION
* FACTORS FROM THE LRARAM TABLE TO IC11 ON
* THE MP-09 CPU CARD.

XFERTF		ldx	#DATREGS	;POINT TO DAT RAM
		ldb	#$10	;GET NO. OF BYTES TO MOVE
FETCH		lda	,y+	;GET BYTE AND POINT TO NEXT
		sta	,x+	;POKE XLATION FACTOR IN IC11
		decb		;SUB 1 FROM BYTES TO MOVE
		bne	FETCH	;CONTINUE UNTIL 16 MOVED
		comb 		;SET "B" NON-ZERO
		stb	ECHO	;TURN ON ECHO FLAG
		lbra	MONITOR	;INITIALIZATION IS COMPLETE


V1		jmp	[STACK]
V2		jmp	[SWI2]
V3		jmp	[FIRQ]
V4		jmp	[IRQ]
V5		jmp	[SWI]

* SWI3 ENTRY POINT

SWI3E		tfr	s,u
		ldx	10,u	;*$FFC8
		ldb	,x+
		stx	10,u
		clra
		aslb
		rola
		ldx	SVCVO
		cmpx	#$FFFF
		beq	SWI3Z
		leax	d,x
		cmpx	SVCVL
		bhi	SWI3Z
		pshs	x
		ldd	,u
		ldx	4,u
		jmp	[,s++]
SWI3Z		pulu	a,b,x,cc,dp
		ldu	2,u
		jmp	[SWI3]
;
; 6809 VECTORS
; By definition, these must be at specific addresses.
;
		VERIFY	$fff0
		dw	V1	;USER-V
		dw	SWI3E	;SWI3-V
		dw	V2	;SWI2-V
		dw	V3	;FIRQ-V
		dw	V4	;IRQ-V
		dw	V5	;SWI-V
		dw	V1	;NMI-V
		dw	START	;RESTART-V
;
		end 

