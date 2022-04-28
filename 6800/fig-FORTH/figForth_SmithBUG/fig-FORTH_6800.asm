; fig-FORTH FOR 6800
;
; Assemble using A68 Assembler
; 	"..\..\A68 6800 Assembler\a68.exe" fig-FORTH_6800.asm -l fig-FORTH_6800.lst -s fig-FORTH_6800.s
; Downloaded through SmithBug
; USB-Serial port selected (J3 installed)
; & Copy-paste S record into Serial terminal
; J 1000
;
; ASSEMBLY SOURCE LISTING
;
; http://www.forth.org/fig-forth/fig-forth_6800.pdf
;
; RELEASE 1
; MAY 1979
; WITH COMPILER SECURITY
; AND VARIABLE LENGTH NAMES
;
; This public domain publication is provided
; through the courtesy of:
; FORTH INTEREST GROUP (fig)
;
; P.O. Box 8231 - San Jose, CA 95155 - (408) 277-0668
; Further distribution must include this notice.
;
; Copyright:FORTH Interest Group
;
; === FORTH-6800 06-06-79 21:OO
;
; This listing is in the PUBLIC DOMAIN and 
; may be freely copied or published with the
; restriction that a credit line is printed
; with the material, crediting the
; authors and the FORTH INTEREST GROUP.
;
; === by Dave Lion,
; ===  with help from
; === Bob Smith,
; === LaFarr Stuart,
; === The Forth Interest Group
; === PO Box 1105
; === San Carlos, CA 94070
; ===  and
; === Unbounded computing
; === 1134-K Aster Ave.
; === Sunnyvale, CA 94086
;
;  This version was developed on an AMI EVK 300 PROTO
;  system using an ACIA for the I/O. All terminal 1/0
;  is done in three subroutines:
;   PEMIT  ( word # 182 )
;   PKEY   (        183 )
;   PQTERM (        184 )
;
;  The FORTH words for disc related I/O follow the model
;  of the FORTH Interest Group, but have not been
;  tested using a real disc.
;
;  Addresses in this implementation reflect the fact that,
;  on the development system, it was convenient to
;  write-protect memory at hex 1000, and leave the first
;  4K bytes write-enabled. As a consequence, code from
;  location $1000 to lable ZZZZ could be put in ROM.
;  Minor deviations from the model were made in the
;  initialization and words ?STACK and FORGET
;  in order to do this.
;
; smp, June 2018
; Modified to assemble properly with the AS02 6800 cross-assembler
; Modified to operate on Corsham Technologies 6800 system (SWTPC replica)
; DGG, APR 2022
; Ported to A68 Assembler
; Running on MULTICOMP
; 
;
;  MEMORY MAP for this 32K system:
;  (positioned so that systems with 4k byte write-
;   protected segments can write protect FORTH)
;
; addr		contents		pointer	init by
; ****	*******************************	*******	*******
; 7FFF						HI
;	substitute for disc mass memory
; 3210						LO,MEMEND
; 320F
; 	4 buffer sectors of VIRTUAL MEMORY
; 3000						FIRST
;
; >>>>>> memory from here up must be RAM <<<<<<
;
; 27FF
; 	6k of romable "FORTH"		<== IP	ABORT
;					<== W
;	the VIRTUAL FORTH MACHINE
;
; 1004 <<< WARM START ENTRY >>>
; 1000 <<< COLD START ENTRY >>>
;
; >>>>>> memory from here down must be RAM <<<<<<
;
;  FFE	RETURN STACK base		<== RP	RINIT
;
;  FB4
;	INPUT LINE BUFFER
;	holds up to 132 characters
;	and is scanned upward by IN
;	sta a rting at TIB
;  F30					<== IN	TIB
;  F2F	DATA STACK			<== SP	SP0,SINIT
;    |	grows downward from F2F
;    v
;    ^
;    |
;    I	DICTIONARY grows upward
; 
;  183	end of ram-dictionary.		<== DP	DPINIT
;	"TASK"
;
;  150	"FORTH" (a word)		<=, <== CONTEXT
;					  `==== CURRENT
;  148	sta a rt of ram-dictionary.
;
;  100	user #l table of variables	<= UP	DPINIT
;   F0	registers & pointers for the virtual machine
; 	scratch area used by various words
;   E0	lowest address used by FORTH
;
; 0000
;
;**
;
; CONVENTIONS USED IN THIS PROGRAM ARE AS FOLLOWS :
;
; IP points to the current instruction (pre-increment mode)
; RP points to second free byte (first free word) in return stack
; SP (hardware SP) points to first free byte in data stack
;
;	when A and B hold one 16 bit FORTH data word,
;	A contains the high byte, B, the low byte.
;**

NBLK	equ	4		;# of disc buffer blocks for virtual memory
MEMEND	equ	132*NBLK+$3000	;end of ram

;  each block is 132 bytes in size,
;  holding 128 characters

MEMTOP	equ	$7BFF	;32K system absolute end of RAM with 1K spare
ACIAC	equ	$FC18	;MultiComp ACIA control address
ACIAD	equ	ACIAC+1	;MultiComp ACIA data address

	org	$E0	;variables

N	rmb	10	;used as scratch by (FIND),ENCLOSE,CMOVE,EMIT,KEY,
;                              SP@,SWAP,DOES>,COLD

;	These locations are used by the TRACE routine :

TRLIM	rmb	1	;the count for tracing without user intervention
TRACEM	rmb	1	;non-zero = trace mode
BRKPT	rmb	2	;the breakpoint address at which
;               	 the program will go into trace mode
VECT	rmb	2	;vector to machine code
;               	 (only needed if the TRACE routine is resident)

;	Registers used by the FORTH virtual machine:
;	Starting at $OOFO:

W	rmb	2	;the instruction register points to 6800 code
IP	rmb	2	;the instruction pointer points to pointer to 6800 code
RP	rmb	2	;the return stack pointer
UP	rmb	2	;the pointer to base of current user's 'USER' table
;           		 (altered during multi-tasking)

;	This system is shown with one user, but additional users
;	may be added by allocating additional user tables:
;	UORIG2 rmb 64 data table for user #2
;
;	Some of this stuff gets initialized during
;	COLD sta a rt and WARM sta a rt:
; 	[ names correspond to FORTH words of similar (no X) name ]

	org	$100

UORIG	rmb	6	;3 reserved variables
XSPZER	rmb	2	;initial top of data stack for this user
XRZERO	rmb	2	;initial top of return stack
XTIB	rmb	2	;sta a rt of terminal input buffer
XWIDTH	rmb	2	;name field width
XWARN	rmb	2	;warning message mode (0 = no disc)
XFENCE	rmb	2	;fence for FORGET
XDP	rmb	2	;dictionary pointer
XVOCL	rmb	2	;vocabulary linking
XBLK	rmb	2	;disc block being accessed
XIN	rmb	2	;scan pointer into the block
XOUT	rmb	2	;cursor position
XSCR	rmb	2	;disc screen being accessed (O=terminal)
XOFSET	rmb	2	;disc sector offset for multi-disc
XCONT	rmb	2	;last word in primary search vocabulary
XCURR	rmb	2	;last word in extensible vocabulary
XSTATE	rmb	2	;flag for 'interpret' or 'COMPILE' modes
XBASE	rmb	2	;number base for I/O numeric conversion
XDPL	rmb	2	;DECIMAl point place
XFLD	rmb	2	
XCSP	rmb	2	;current stack position, for COMPILE checks
XRNUM	rmb	2	
XHLD	rmb	2	
XDELAY	rmb	2	;carriage return delay count
XCOLUM	rmb	2	;carriage width
IOSTAT	rmb	2	;last acia sta a tus from write/read
	rmb	2	;(4 spares!)
	rmb	2	
	rmb	2	
	rmb	2	

;
;   end of user table, sta a rt of common system variables
;

XUSE	rmb	2
XPREV	rmb	2
	rmb	4	;(spares)

;  These things, up through the lable 'REND', are overwritten
;  at time of cold load and should have the same contents
;  as shown here:

	fcb	$C5	;immediate
	fcc	"FORT"	;fcc	4,FORTH
	fcb	$C8
	fdb	NOOP-7
FORTH	fdb	DODOES,DOVOC,$81A0,TASK-7
	fdb	0

	fcc	"(C) Forth Interest Group, 1979"

	fcb	$84
	fcc	"TAS"	;fcc	3,TASK
	fcb	$CB
	fdb	FORTH-8
TASK	fdb	DOCOL,SEMIS

REND	equ	*	;(first empty location in dictionary)

;    The FORTH program (address $1000 to $27FF) is written
;    so that it can be in a ROM, or write-protected if desired

	org	$1000

; ######>> screen 3 <<
;
;**************************
;*  C O L D   E N T R Y  **
;**************************
ORIG	nop
	jmp	CENT
;**************************
;*  W A R M   E N T R Y  **
;**************************
	nop
	jmp	WENT	;warm-sta a rt code, keeps current dictionary intact

;
;*************** startup parmeters *****************
;
	fdb	$6800,0000	;cpu & revision
	fdb	0	;topmost word in FORTH vocabulary
BACKSP	fdb	$7F	;backspace character for editing
UPINIT	fdb	UORIG	;initial user area
SINIT	fdb	ORIG-$D0	;initial top of data stack
RINIT	fdb	ORIG-2	;initial top of return stack
	fdb	ORIG-$D0	;terminal input buffer
	fdb	31	;initial name field width
	fdb	0	;initial warning mode (0 = no disc)
FENCIN	fdb	REND	;initial fence
DPINIT	fdb	REND	;cold sta a rt value for DP
VOCINT	fdb	FORTH+8	
; COLINT	fdb	132	;initial terminal carriage width
; DELINT	fdb	4	;initial carriage return delay
COLINT	fdb	80	;initial terminal carriage width
DELINT	fdb	0	;initial carriage return delay
;
;***************************************************
;

;
; ######>> screen 13 <<
PULABX	pula		;24 cycles until 'NEXT'
	pulb
STABX	sta a 0,x	;16 cycles until 'NEXT'
	sta  b	1,x
	bra	NEXT
GETX	lda a	0,x	;18 cycles until 'NEXT'
	lda b	1,x
PUSHBA	pshb		;8 cycles until 'NEXT'
	psha
;
; "NEXT" takes 38 cycles if TRACE is removed,
; and 95 cycles if NOT tracing.
;

; = = = = t h e   v i r t u a l  m a c h i n e = = = =
;
NEXT	ldx	IP
	inx		;pre-increment mode
	inx
	stx	IP
NEXT2	ldx	0,x	;get W which points to CFA of word to be done
NEXT3	stx	W
	ldx	0,x	;get VECT which points to executable code
;
; The next instruction could be patched to jmp TRACE
; if a TRACE routine is available:
;
	jmp	0,x
	nop
;	jmp	TRACE	;(an alternate for the above)
;
; = = = = = = = = = = = = = = = = = = = = = = = = = = =

;
; ======>>  1  <<
	fcb	$83
	fcc	"LI"	;fcc	2,LIT	;NOTE: this is different from LITERAL
	fcb	$D4
	fdb	0	;link of zero to terminate dictionary scan
LIT	fdb	*+2
	ldx	IP
	inx
	inx
	stx	IP
	lda a	0,x
	lda b	1,x
	jmp	PUSHBA
	nop		;to compensate for assembler substituting BRA
;
; ######>> screen 14 <<
; ======>>  2  <<
CLITER	fdb	*+2	;(this is an invisible word, with no header)
	ldx	IP
	inx
	stx	IP
	clra
	lda b	1,x
	jmp	PUSHBA
	nop		;to compensate for assembler substituting BRA
;
; ======>>  3  <<
	fcb	$87
	fcc	"EXECUT"	;fcc	6,EXECUTE
	fcb	$C5
	fdb	LIT-6
EXEC	fdb	*+2
	tsx
	ldx	0,x	;get code field address (CFA)
	ins		;pop stack
	ins
	jmp	NEXT3
	nop		;to compensate for assembler substituting BRA
;
; ######>> screen 15 <<
; ======>>  4  <<
	fcb	$86
	fcc	"BRANC"	;fcc	5,BRANCH
	fcb	$C8
	fdb	EXEC-10
BRAN	fdb	ZBYES	;Go steal code in ZBRANCH
;
; ======>>  5  <<
	fcb	$87
	fcc	"0BRANC"	;fcc	6,0BRANCH
	fcb	$C8
	fdb	BRAN-9
ZBRAN	fdb	*+2
	pula
	pulb
	aba
	bne	ZBNO
	bcs	ZBNO
ZBYES	ldx	IP	;Note: code is shared with BRANCH, (+LOOP), (LOOP)
	lda b	3,x
	lda	a 2,x
	addb	IP+1
	adca	IP
	sta b	IP+1
	sta a 	IP
	jmp	NEXT
	nop		;to compensate for assembler substituting BRA
ZBNO	ldx	IP	;no branch. This code is shared with (+LOOP), (LOOP).
	inx		;jump over branch delta
	inx
	stx	IP
	jmp	NEXT
	nop		;to compensate for assembler substituting BRA
;
; ######>> screen 16 <<
; ======>>  6  <<
	fcb	$86
	fcc	"(LOOP"	;fcc	5,(LOOP)
	fcb	$A9
	fdb	ZBRAN-10
XLOOP	fdb	*+2
	clra
	lda b	#1	;get set to increment counter by 1
	bra	XPLOP2	;go steal other guy's code!
;
; ======>>  7  <<
	fcb	$87
	fcc	"(+LOOP"	;fcc	6,(+LOOP)
	fcb	$A9
	fdb	XLOOP-9
XPLOOP	fdb *+2		;Note: +LOOP has an un-signed loop counter
	pula		;get increment
	pulb
XPLOP2	tst a 
	bpl	XPLOF	;forward looping
	bsr	XPLOPS
	sec
	sbcb	5,x
	sbca	4,x
	bpl	ZBYES
	bra	XPLONO	;fall through
;
; the subroutine :
XPLOPS	ldx	RP
	addb	3,x	;add it to counter
	adca	2,x
	sta b	3,x	;store new counter value
	sta a 	2,x
	rts
;
XPLOF	bsr	XPLOPS
	subb	5,x
	sbca	4,x
	bmi	ZBYES
;
XPLONO	inx		;done, don't branch back
	inx
	inx
	inx
	stx	RP
	bra	ZBNO	;use ZBRAN to skip over unused delta
;
; ######>> screen 17 <<
; ======>>  8  <<
	fcb	$84
	fcc	"(DO"	;fcc	3,(DO)
	fcb	$A9
	fdb	XPLOOP-10
XDO	fdb	*+2	;This is the RUNTIME DO, not the COMPILING DO
	ldx	RP
	dex
	dex
	dex
	dex
	stx	RP
	pula
	pulb
	sta a 	2,x
	sta b	3,x
	pula
	pulb
	sta a 	4,x
	sta b	5,x
	jmp	NEXT
;
; ======>>  9  <<
	fcb	$81	; I
	fcb	$C9
	fdb	XDO-7	
I	fdb	*+2
	ldx	RP
	inx
	inx
	jmp	GETX
;
; ######>> screen 18 <<
; ======>>  10  <<
	fcb	$85
	fcc	"DIGI"	;fcc	4,DIGIT
	fcb	$D4
	fdb	I-4
DIGIT	fdb	*+2	;NOTE: legal input range is 0-9, A-Z
	tsx
	lda	a 3,x
	suba	#$30	;ascii zero
	bmi	DIGIT2	;IF LESS THAN '0', ILLEGAL
	cmpa	#$A
	bmi	DIGIT0	;IF '9' OR LESS
	cmpa	#$11
	bmi	DIGIT2	;if less than 'A'
	cmpa	#$2B
	bpl	DIGIT2	;if greater than 'Z'
	suba	#7	;translate 'A' thru 'F'
DIGIT0	cmpa	1,x
	bpl	DIGIT2	;if not less than the base
	lda b	#1	;set flag
	sta a 	3,x	;store digit
DIGIT1	sta b	1,x	;store the flag
	jmp	NEXT
DIGIT2	clrb
	ins
	ins		;pop bottom number
	tsx
	sta b	0,x	;make sure both bytes are 00
	bra	DIGIT1
;
; ######>> screen 19 <<
;
; The word format in the dictionary is:
;
; char-count + $80	;lowest address
; char 1
; char 2
; 
; char n  + $80
; link high byte \___point to previous word
; link low  byte /
; CFA  high byte \___point to 6800 code
; CFA  low  byte /
; parameter fields
;    "
;    "
;    "
;
; ======>>  11  <<
	fcb	$86
	fcc	"(FIND"	;fcc	5,(FIND)
	fcb	$A9
	fdb	DIGIT-8
PFIND	fdb	*+2
	nop
	nop
PD	equ	N	;ptr to dict word being checked
PA0	equ	N+2
PA	equ	N+4
PC	equ	N+6
	ldx	#PD
	lda b	#4
PFIND0	pula		;loop to get arguments
	sta a 	0,x
	inx
	decb
	bne	PFIND0
;
	ldx	PD
PFIND1	lda b	0,x	;get count dict count
	sta b	PC
	andb	#$3F
	inx
	stx	PD	;update PD
	ldx	PA0
	lda	a 0,x	;get count from arg
	inx
	stx	PA	;initialize PA
	cba		;compare lengths
	bne	PFIND4
PFIND2	ldx	PA
	lda a	0,x
	inx
	stx	PA
	ldx	PD
	lda b	0,x
	inx
	stx	PD
	tst b		;is dict entry neg. ?
	bpl	PFIND8
	andb	#$7F	;clear sign
	cba
	beq	FOUND
PFIND3	ldx	0,x	;get new link
	bne	PFIND1	;continue if link not=0
;
;	not found :
;
	clra
	clrb
	jmp	PUSHBA
PFIND8	cba
	beq	PFIND2
PFIND4	ldx	PD
PFIND9	lda b	0,x	;scan forward to end of this name
	inx
	bpl	PFIND9
	bra	PFIND3
;
;	found :
;
FOUND	lda a	PD	;compute CFA
	lda b	PD+1
	addb	#4
	adca	#0
	pshb
	psha
	lda a	PC
	psha
	clra
	psha
	lda b	#1
	jmp	PUSHBA
;
	psha
	clra
	psha
	lda b	#1
	jmp	PUSHBA
;
; ######>> screen 20 <<
; ======>>  12  <<
	fcb	$87
	fcc	"ENCLOS"	;fcc	6,ENCLOSE
	fcb 	$C5
	fdb	PFIND-9
; NOTE :
; FC means offset (bytes) to First Character of next word
; EW  "     "   to End of Word
; NC  "     "   to Next Character to sta a rt next enclose at
ENCLOS	fdb	*+2
	ins
	pulb		;now, get the low byte, for an 8-bit delimiter
	tsx
	ldx	0,x
	clr	N
;	wait for a non-delimiter or a NUL
ENCL2	lda a 0,x
	beq	ENCL6
	cba		;CHECK FOR DELIM
	bne	ENCL3
	inx
	inc	N
	bra	ENCL2
;	found first character. Push FC
ENCL3	lda a	N	;found first char.
	psha
	clra
	psha
;	wait for a delimiter or a NUL
ENCL4	lda a 0,x
	beq	ENCL7
	cba		;check for delim.
	beq	ENCL5
	inx
	inc	N
	bra	ENCL4
;	found EW. Push it
ENCL5	lda b	N
	clra
	pshb
	psha
;	advance and push NC
	incb
	jmp	PUSHBA
;	found NUL before non-delimiter, therefore there is no word
ENCL6	lda b	N	;found NUL
	pshb
	psha
	incb
	bra	ENCL7+2	
;	found NUL following the word instead of SPACE
ENCL7	lda b	N
	pshb		;save EW
	psha
ENCL8	lda b	N	;save NC
	jmp	PUSHBA
;
; ######>> screen 21 <<
; The next 4 words call system dependant I/O routines
; which are listed after word "-->" ( lable: "arrow" )
; in the dictionary.
;
; ======>>  13  <<
	fcb	$84
	fcc	"EMI"	;fcc	3,EMIT
	fcb	$D4
	fdb	ENCLOS-10
EMIT	fdb	*+2
	pula
	pula
	jsr	PEMIT
	ldx	UP
	inc	XOUT+1-UORIG,x
	bne	*+4
	inc	XOUT-UORIG,x
	jmp	NEXT
;
; ======>>  14  <<
	fcb	$83
	fcc	"KE"	;fcc	2,KEY
	fcb	$D9
	fdb	EMIT-7
KEY	fdb	*+2
	jsr	PKEY
	psha
	clra
	psha
	jmp	NEXT
;
; ======>>  15  <<
	fcb	$89
	fcc	"?TERMINA"	;fcc	8,?TERMINAL
	fcb	$CC
	fdb	KEY-6
QTERM	fdb	*+2
	jsr	PQTER
	clrb
	jmp	PUSHBA	;stack the flag
;
; ======>>  16  <<
	fcb	$82
	fcc	"C"	;fcc	1,CR
	fcb	$D2
	fdb	QTERM-12
CR	fdb	*+2
	jsr	PCR
	jmp	NEXT
;
; ######>> screen 22 <<
; ======>>  17  <<
	fcb	$85
	fcc	"CMOV"	;fcc	4,CMOVE	;source, destination, count
	fcb	$C5
	fdb	CR-5
CMOVE	fdb	*+2	;takes ( 43+47*count cycles )
	ldx	#N
	lda b	#6
CMOV1	pula
	sta a 	0,x	;move parameters to scratch area
	inx
	decb
	bne	CMOV1
CMOV2	lda	a N
	lda b	N+1
	subb	#1
	sbca	#0
	sta a 	N
	sta b	N+1
	bcs	CMOV3
	ldx	N+4
	lda a 0,x
	inx
	stx	N+4
	ldx	N+2
	sta a 	0,x
	inx
	stx	N+2
	bra	CMOV2
CMOV3	jmp	NEXT
;
; ######>> screen 23 <<
; ======>>  18  <<
	fcb	$82
	fcc	"U"	;fcc	1,U*
	fcb	$AA
	fdb	CMOVE-8
USTAR	fdb	*+2
	bsr	USTARS
	ins
	ins
	jmp	PUSHBA
;
; The following is a subroutine which 
; multiplies top 2 words on stack,
; leaving 32-bit result:  high order word in A,B
; low order word in 2nd word of stack.
;
USTARS	lda	a #16	;bits/word counter
	psha
	clra
	clrb
	tsx
USTAR2	ror	5,x	;shift multiplier
	ror	6,x
	dec	0,x	;done?
	bmi	USTAR4
	bcc	USTAR3
	addb	4,x
	adca	3,x
USTAR3	rora
	rorb		;shift result
	bra	USTAR2
USTAR4	ins		;dump counter
	rts
;
; ######>> screen 24 <<
; ======>>  19  <<
	fcb	$82
	fcc	"U"	;fcc	1,U/
	fcb	$AF
	fdb	USTAR-5
USLASH	fdb	*+2
	lda a #17
	psha
	tsx
	lda a	3,x
	lda b	4,x
USL1	cmpa	1,x
	bhi	USL3
	bcs	USL2
	cmpb	2,x
	bcc	USL3
USL2	clc
	bra	USL4
USL3	subb	2,x
	sbca	1,x
	sec
USL4	rol	6,x
	rol	5,x
	dec	0,x
	beq	USL5
	rolb
	rola
	bcc	USL1
	bra	USL3
USL5	ins
	ins
	ins
	ins
	ins
	jmp	SWAP+4	;reverse quotient & remainder
;
; ######>> screen 25 <<
; ======>>  20  <<
	fcb	$83
	fcc	"AN"	;fcc	2,ANDLAB
	fcb	$C4
	fdb	USLASH-5
ANDLAB	fdb	*+2
	pula
	pulb
	tsx
	andb	1,x
	anda	0,x
	jmp	STABX
;
; ======>>  21  <<
	fcb	$82
	fcc	"O"	;fcc	1,ORLAB
	fcb	$D2
	fdb	ANDLAB-6
ORLAB	fdb	*+2
	pula
	pulb
	tsx
	orab	1,x
	oraa	0,x
	jmp	STABX
;	
; ======>>  22  <<
	fcb	$83
	fcc	"XO"	;fcc	2,XORLAB
	fcb	$D2
	fdb	ORLAB-5
XORLAB	fdb	*+2
	pula
	pulb
	tsx
	eorb	1,x
	eora	0,x
	jmp	STABX
;
; ######>> screen 26 <<
; ======>>  23  <<
	fcb	$83
	fcc	"SP"	;fcc	2,SP@
	fcb	$C0
	fdb	XORLAB-6
SPAT	fdb	*+2
	tsx
	stx	N	;scratch area
	ldx	#N
	jmp	GETX
;
; ======>>  24  <<
	fcb	$83
	fcc	"SP"	;fcc	2,SP!
	fcb	$A1
	fdb	SPAT-6
SPSTOR	fdb	*+2
	ldx	UP
	ldx	XSPZER-UORIG,x
	txs		;watch it ! X and S are not EQUAL.
	jmp	NEXT
;
; ======>>  25  <<
	fcb	$83
	fcc	"RP"	;fcc	2,RP!
	fcb	$A1
	fdb	SPSTOR-6
RPSTOR	fdb	*+2
	ldx	RINIT	;initialize from rom consta a nt
	stx	RP
	jmp	NEXT
;
; ======>>  26  <<
	fcb	$82
	fcc	";"	;fcc	1,;S
	fcb	$D3
	fdb	RPSTOR-6
SEMIS	fdb	*+2
	ldx	RP
	inx
	inx
	stx	RP
	ldx	0,x	;get address we have just finished.
	jmp	NEXT+2	;increment the return address & do next word
;
; ######>> screen 27 <<
; ======>>  27  <<
	fcb	$85
	fcc	"LEAV"	;fcc	4,LEAVE
	fcb	$C5
	fdb	SEMIS-5
LEAVE	fdb	*+2
	ldx	RP
	lda	a 2,x
	lda b	3,x
	sta a 	4,x
	sta b	5,x
	jmp	NEXT
;
; ======>>  28  <<
	fcb	$82
	fcc	">"	;fcc	1,>R
	fcb	$D2
	fdb	LEAVE-8
TOR	fdb	*+2
	ldx	RP
	dex
	dex
	stx	RP
	pula
	pulb
	sta a 	2,x
	sta b	3,x
	jmp	NEXT
;
; ======>>  29  <<
	fcb	$82
	fcc	"R"	;fcc	1,R>
	fcb	$BE
	fdb	TOR-5
FROMR	fdb	*+2
	ldx	RP
	lda	a 2,x
	lda b	3,x
	inx
	inx
	stx	RP
	jmp	PUSHBA
;
; ======>>  30  <<
	fcb	$81	; R
	fcb	$D2
	fdb	FROMR-5
R	fdb	*+2
	ldx	RP
	inx
	inx
	jmp	GETX
;
; ######>> screen 28 <<
; ======>>  31  <<
	fcb	$82
	fcc	"0"	;fcc	1,0=
	fcb	$BD
	fdb	R-4
ZEQU	fdb	*+2
	tsx
	clra
	clrb
	ldx	0,x
	bne	ZEQU2
	incb
ZEQU2	tsx
	jmp	STABX
;
; ======>>  32  <<
	fcb	$82
	fcc	"0"	;fcc	1,0<
	fcb	$BC
	fdb	ZEQU-5
ZLESS	fdb	*+2
	tsx
	lda a #$80	;check the sign bit
	anda	0,x
	beq	ZLESS2
	clra		;if neg.
	lda b	#1
	jmp	STABX
ZLESS2	clrb
	jmp	STABX
;
; ######>> screen 29 <<
; ======>>  33  <<
	fcb	$81	;'+'
	fcb	$AB
	fdb	ZLESS-5
PLUS	fdb	*+2
	pula
	pulb
	tsx
	addb	1,x
	adca	0,x
	jmp	STABX
;
; ======>>  34  <<
	fcb	$82
	fcc	"D"	;fcc	1,D+
	fcb	$AB
	fdb	PLUS-4
DPLUS	fdb	*+2
	tsx
	clc
	lda b	#4
DPLUS2	lda a	3,x
	adca	7,x
	sta a 	7,x
	dex
	decb
	bne	DPLUS2
	ins
	ins
	ins
	ins
	jmp	NEXT
;
; ======>>  35  <<
	fcb	$85
	fcc	"MINU"	;fcc	4,MINUS
	fcb	$D3
	fdb	DPLUS-5
MINUS	fdb	*+2
	tsx
	neg	1,x
	bcs	MINUS2	;BCS to match original 1979 listing
	neg	0,x
	bra	MINUS3
MINUS2	com	0,x
MINUS3	jmp	NEXT
;
; ======>>  36  <<
	fcb	$86
	fcc	"DMINU"	;fcc	5,DMINUS
	fcb	$D3
	fdb	MINUS-8
DMINUS	fdb	*+2
	tsx
	com	0,x
	com	1,x
	com	2,x
	neg	3,x
	bne	DMINX
	inc	2,x
	bne	DMINX
	inc	1,x
	bne	DMINX
	inc	0,x
DMINX	jmp	NEXT
;
; ######>> screen 30 <<
; ======>>  37  <<
	fcb	$84
	fcc	"OVE"	;fcc	3,OVER
	fcb	$D2
	fdb	DMINUS-9
OVER	fdb	*+2
	tsx
	lda	a 2,x
	lda b	3,x
	jmp	PUSHBA
;
; ======>>  38  <<
	fcb	$84
	fcc	"DRO"	;fcc	3,DROP
	fcb	$D0
	fdb	OVER-7
DROP	fdb	*+2
	ins
	ins
	jmp	NEXT
;
; ======>>  39  <<
	fcb	$84
	fcc	"SWA"	;fcc	3,SWAP
	fcb	$D0
	fdb	DROP-7
SWAP	fdb	*+2
	pula
	pulb
	tsx
	ldx	0,x
	ins
	ins
	pshb
	psha
	stx	N
	ldx	#N
	jmp	GETX
;
; ======>>  40  <<
	fcb	$83
	fcc	"DU"	;fcc	2,DUP
	fcb	$D0
	fdb	SWAP-7
DUP	fdb	*+2
	pula
	pulb
	pshb
	psha
	jmp PUSHBA
;
; ######>> screen 31 <<
; ======>>  41  <<
	fcb	$82
	fcc	"+"	;fcc	1,+!
	fcb	$A1
	fdb	DUP-6
PSTORE	fdb	*+2
	tsx
	ldx	0,x
	ins
	ins
	pula		;get stack data
	pulb
	addb	1,x	;add & store low byte
	sta b	1,x
	adca	0,x	;add & store hi byte
	sta a 	0,x
	jmp	NEXT
;
; ======>>  42  <<
	fcb	$86
	fcc	"TOGGL"	;fcc	5,TOGGLE
	fcb	$C5
	fdb	PSTORE-5
TOGGLE	fdb	DOCOL,OVER,CAT,XORLAB,SWAP,CSTORE
	fdb	SEMIS
;
; ######>> screen 32 <<
; ======>>  43  <<
	fcb	$81	; @
	fcb	$C0
	fdb	TOGGLE-9
AT	fdb	*+2
	tsx
	ldx	0,x	;get address
	ins
	ins
	jmp	GETX
;
; ======>>  44  <<
	fcb	$82
	fcc	"C"	;fcc	1,C@
	fcb	$C0
	fdb	AT-4
CAT	fdb	*+2
	tsx
	ldx	0,x
	clra
	lda b	0,x
	ins
	ins
	jmp	PUSHBA
;
; ======>>  45  <<
	fcb	$81
	fcb	$A1
	fdb	CAT-5
STORE	fdb	*+2
	tsx
	ldx	0,x	;get address
	ins
	ins
	jmp	PULABX
;
; ======>>  46  <<
	fcb	$82
	fcc	"C"	;fcc	1,C!
	fcb	$A1
	fdb	STORE-4
CSTORE	fdb	*+2
	tsx
	ldx	0,x	;get address
	ins
	ins
	ins
	pulb
	sta b	0,x
	jmp	NEXT
;
; ######>> screen 33 <<
; ======>>  47  <<
	fcb	$C1	;immediate
	fcb	$BA
	fdb	CSTORE-5
COLON	fdb	DOCOL,QEXEC,SCSP,CURENT,AT,CONTXT,STORE
	fdb	CREATE,RBRAK
	fdb	PSCODE

; Here is the IP pusher for allowing
; nested words in the virtual machine:
; ( ;S is the equivalent un-nester )

DOCOL	ldx	RP	;make room in the stack
	dex
	dex
	stx	RP
	lda	a IP
	lda b	IP+1	
	sta a 	2,x	;Store address of the high level word
	sta b	3,x	;that we are sta a rting to execute
	ldx	W	;Get first sub-word of that definition
	jmp	NEXT+2	;and execute it
;
; ======>>  48  <<
	fcb	$C1	;imnediate code
	fcb	$BB
	fdb	COLON-4
SEMI	fdb	DOCOL,QCSP,COMPIL,SEMIS,SMUDGE,LBRAK
	fdb	SEMIS
;
; ######>> screen 34 <<
; ======>>  49  <<
	fcb	$88
	fcc	"CONSTAN"	;fcc	7,CONSTANT
	fcb	$D4
	fdb	SEMI-4
CON	fdb	DOCOL,CREATE,SMUDGE,COMMA,PSCODE
DOCON	ldx	W
	lda	a 2,x	
	lda b	3,x	;A & B now contain the consta a nt
	jmp	PUSHBA
;
; ======>>  50  <<
	fcb	$88
	fcc	"VARIABL"	;fcc	7,VARIABLE
	fcb	$C5
	fdb	CON-11
VAR	fdb	DOCOL,CON,PSCODE
DOVAR	lda	a W
	lda b	W+1
	addb	#2
	adca	#0	;A,B now contain the address of the variable
	jmp	PUSHBA
;
; ======>>  51  <<
	fcb	$84
	fcc	"USE"	;fcc	3,USER
	fcb	$D2
	fdb	VAR-11
USER	fdb	DOCOL,CON,PSCODE
DOUSER	ldx	W	;get offset  into user's table
	lda	a 2,x
	lda b	3,x
	addb	UP+1	;add to users base address
	adca	UP
	jmp	PUSHBA	;push address of user's variable
;
; ######>> screen 35 <<
; ======>>  52  <<
	fcb	$81
	fcb	$B0	; 0
	fdb	USER-7
ZERO	fdb	DOCON
	fdb	0000
;
; ======>>  53  <<
	fcb	$81
	fcb	$B1	; 1
	fdb	ZERO-4
ONE	fdb	DOCON
	fdb	1
;
; ======>>  54  <<
	fcb	$81
	fcb	$B2	; 2
	fdb	ONE-4
TWO	fdb	DOCON
	fdb	2
;
; ======>>  55  <<
	fcb	$81
	fcb	$B3	; 3
	fdb	TWO-4
THREE	fdb	DOCON
	fdb	3
;
; ======>>  56  <<
	fcb	$82
	fcc	"B"	;fcc	1,BL
	fcb	$CC
	fdb	THREE-4
BL	fdb	DOCON	;ascii blank
	fdb	$20
;
; ======>>  57  <<
	fcb	$85
	fcc	"FIRS"	;fcc	4,FIRST
	fcb	$D4
	fdb	BL-5
FIRST	fdb	DOCON
	fdb	MEMEND-528	;(132 * NBLK)
;
; ======>>  58  <<
	fcb	$85
	fcc	"LIMI"	;fcc	4,LIMIT	;(the end of memory +1)
	fcb	$D4
	fdb	FIRST-8
LIMIT	fdb	DOCON
	fdb	MEMEND
;
; ======>>  59  <<
	fcb	$85
	fcc	"B/BU"	;fcc	4,B/BUF	;(bytes/buffer)
	fcb	$C6
	fdb	LIMIT-8
BBUF	fdb	DOCON
	fdb	128
;
; ======>>  60  <<
	fcb	$85
	fcc	"B/SC"	;fcc	4,B/SCR	;(blocks/screen)
	fcb	$D2
	fdb	BBUF-8
BSCR	fdb	DOCON
	fdb	8
;	blocks/screen = 1024 / "B/BUF" = 8
;
; ======>>  61  <<
	fcb	$87
	fcc	"+ORIGI"	;fcc	6,+ORIGIN
	fcb	$CE
	fdb	BSCR-8
PORIG	fdb	DOCOL,LIT,ORIG,PLUS
	fdb	SEMIS
;
; ######>> screen 36 <<
; ======>>  62  <<
	fcb	$82
	fcc	"S"	;fcc	1,S0
	fcb	$B0
	fdb	PORIG-10
SZERO	fdb	DOUSER
	fdb	XSPZER-UORIG
;
; ======>>  63  <<
	fcb	$82
	fcc	"R"	;fcc	1,R0
	fcb	$B0
	fdb	SZERO-5
RZERO	fdb	DOUSER
	fdb	XRZERO-UORIG
;
; ======>>  64  <<
	fcb	$83
	fcc	"TI"	;fcc	2,TIB
	fcb	$C2
	fdb	RZERO-5
TIB	fdb	DOUSER
	fdb	XTIB-UORIG
;
; ======>>  65  <<
	fcb	$85
	fcc	"WIDT"	;fcc	4,WIDTH
	fcb	$C8
	fdb	TIB-6
WIDTH	fdb	DOUSER
	fdb	XWIDTH-UORIG
;
; ======>>  66  <<
	fcb	$87
	fcc	"WARNIN"	;fcc	6,WARNING
	fcb	$C7
	fdb	WIDTH-8
WARN	fdb	DOUSER
	fdb	XWARN-UORIG
;
; ======>>  67  <<
	fcb	$85
	fcc	"FENC"	;fcc	4,FENCE
	fcb	$C5
	fdb	WARN-10
FENCE	fdb	DOUSER
	fdb	XFENCE-UORIG
;
; ======>>  68  <<
	fcb	$82
	fcc	"D"	;fcc	1,DP	;points to first free byte at end of dictionary
	fcb	$D0
	fdb	FENCE-8
DP	fdb	DOUSER
	fdb	XDP-UORIG
;
; ======>>  68.5  <<
	fcb	$88
	fcc	"VOC-LIN"	;fcc	7,VOC-LINK
	fcb	$CB
	fdb	DP-5
VOCLIN	fdb	DOUSER
	fdb	XVOCL-UORIG
;
; ======>>  69  <<
	fcb	$83
	fcc	"BL"	;fcc	2,BLK
	fcb	$CB
	fdb	VOCLIN-11
BLK	fdb	DOUSER
	fdb	XBLK-UORIG
;
; ======>>  70  <<
	fcb	$82
	fcc	"I"	;fcc	1,IN	;scan pointer for input line buffer
	fcb	$CE
	fdb	BLK-6
IN	fdb	DOUSER
	fdb	XIN-UORIG
;
; ======>>  71  <<
	fcb	$83
	fcc	"OU"	;fcc	2,OUT
	fcb	$D4
	fdb	IN-5
OUT	fdb	DOUSER
	fdb	XOUT-UORIG
;
; ======>>  72  <<
	fcb	$83
	fcc	"SC"	;fcc	2,SCR
	fcb	$D2
	fdb	OUT-6
SCR	fdb	DOUSER
	fdb	XSCR-UORIG
;
; ######>> screen 37 <<
; ======>>  73  <<
	fcb	$86
	fcc	"OFFSE"	;fcc	5,OFFSET
	fcb	$D4
	fdb	SCR-6
OFSET	fdb	DOUSER
	fdb	XOFSET-UORIG
;
; ======>>  74  <<
	fcb	$87
	fcc	"CONTEX"	;fcc	6,CONTEXT	;points to pointer to vocab to search first
	fcb	$D4
	fdb	OFSET-9
CONTXT	fdb	DOUSER
	fdb	XCONT-UORIG
;
; ======>>  75  <<
	fcb	$87
	fcc	"CURREN"	;fcc	6,CURRENT	;points to pointer to vocab being extended
	fcb	$D4
	fdb	CONTXT-10
CURENT	fdb	DOUSER
	fdb	XCURR-UORIG
;
; ======>>  76  <<
	fcb	$85
	fcc	"STAT"	;fcc	4,STATE	;1 if COMPILing, 0 if not
	fcb	$C5
	fdb	CURENT-10
STATE	fdb	DOUSER
	fdb	XSTATE-UORIG
;
; ======>>  77  <<
	fcb	$84
	fcc	"BAS"	;fcc	3,BASE	;number base for all input & output
	fcb	$C5
	fdb	STATE-8
BASE	fdb	DOUSER
	fdb	XBASE-UORIG
;
; ======>>  78  <<
	fcb	$83
	fcc	"DP"	;fcc	2,DPL
	fcb	$CC
	fdb	BASE-7
DPL	fdb	DOUSER
	fdb	XDPL-UORIG
;
; ======>>  79  <<
	fcb	$83
	fcc	"FL"	;fcc	2,FLD
	fcb	$C4
	fdb	DPL-6
FLD	fdb	DOUSER
	fdb	XFLD-UORIG
;
; ======>>  80  <<
	fcb	$83
	fcc	"CS"	;fcc	2,CSP
	fcb	$D0
	fdb	FLD-6
CSP	fdb	DOUSER
	fdb	XCSP-UORIG
;
; ======>>  81  <<
	fcb	$82
	fcc	"R"	;fcc	1,R#
	fcb	$A3
	fdb	CSP-6
RNUM	fdb	DOUSER
	fdb	XRNUM-UORIG
;
; ======>>  82  <<
	fcb	$83
	fcc	"HL"	;fcc	2,HLD
	fcb	$C4
	fdb	RNUM-5
HLD	fdb	DOCON
	fdb	XHLD
;
; ======>>  82.5  <<== SPECIAL
	fcb	$87
	fcc	"COLUMN"	;fcc	6,COLUMNS	;line width of terminal
	fcb	$D3
	fdb	HLD-6
COLUMS	fdb	DOUSER
	fdb	XCOLUM-UORIG
;
; ######>> screen 38 <<
; ======>>  83  <<
	fcb	$82
	fcc	"1"	;fcc	1,1+
	fcb	$AB
	fdb	COLUMS-10
ONEP	fdb	DOCOL,ONE,PLUS
	fdb	SEMIS
;
; ======>>  84  <<
	fcb	$82
	fcc	"2"	;fcc	1,2+
	fcb	$AB
	fdb	ONEP-5
TWOP	fdb	DOCOL,TWO,PLUS
	fdb	SEMIS
;
; ======>>  85  <<
	fcb	$84
	fcc	"HER"	;fcc	3,HERE
	fcb	$C5
	fdb	TWOP-5
HERE	fdb	DOCOL,DP,AT
	fdb	SEMIS
;
; ======>>  86  <<
	fcb	$85
	fcc	"ALLO"	;fcc	4,ALLOT
	fcb	$D4
	fdb	HERE-7
ALLOT	fdb	DOCOL,DP,PSTORE
	fdb	SEMIS
;
; ======>>  87  <<
	fcb	$81	; , (comma)
	fcb	$AC
	fdb	ALLOT-8
COMMA	fdb	DOCOL,HERE,STORE,TWO,ALLOT
	fdb	SEMIS
;
; ======>>  88  <<
	fcb	$82
	fcc	"C"	;fcc	1,C,
	fcb	$AC
	fdb	COMMA-4
CCOMM	fdb	DOCOL,HERE,CSTORE,ONE,ALLOT
	fdb	SEMIS
;
; ======>>  89  <<
	fcb	$81	; -
	fcb	$AD
	fdb	CCOMM-5
SUB	fdb	DOCOL,MINUS,PLUS
	fdb	SEMIS
;
; ======>>  90  <<
	fcb	$81	; =
	fcb	$BD
	fdb	SUB-4
EQUAL	fdb	DOCOL,SUB,ZEQU
	fdb	SEMIS
;
; ======>>  91  <<
	fcb	$81	; <
	fcb	$BC	
	fdb	EQUAL-4
LESS	fdb	*+2
	pula
	pulb
	tsx
	cmpa	0,x
	ins
	bgt	LESST
	bne	LESSF
	cmpb	1,x
	bhi	LESST
LESSF	clrb
	bra	LESSX
LESST	lda b	#1
LESSX	clra
	ins
	jmp	PUSHBA
;
; ======>>  92  <<
	fcb	$81	; >
	fcb	$BE
	fdb	LESS-4
GREAT	fdb	DOCOL,SWAP,LESS
	fdb	SEMIS
;
; ======>>  93  <<
	fcb	$83
	fcc	"RO"	;fcc	2,ROT
	fcb	$D4
	fdb	GREAT-4
ROT	fdb	DOCOL,TOR,SWAP,FROMR,SWAP
	fdb	SEMIS
;
; ======>>  94  <<
	fcb	$85
	fcc	"SPAC"	;fcc	4,SPACE
	fcb	$C5
	fdb	ROT-6
SPACE	fdb	DOCOL,BL,EMIT
	fdb	SEMIS
;
; ======>>  95  <<
	fcb	$83
	fcc	"MI"	;fcc	2,MIN
	fcb	$CE
	fdb	SPACE-8
MIN	fdb	DOCOL,OVER,OVER,GREAT,ZBRAN
	fdb	MIN2-*
	fdb	SWAP
MIN2	fdb	DROP
	fdb	SEMIS
;
; ======>>  96  <<
	fcb	$83
	fcc	"MA"	;fcc	2,MAX
	fcb	$D8
	fdb	MIN-6
MAX	fdb	DOCOL,OVER,OVER,LESS,ZBRAN
	fdb	MAX2-*
	fdb	SWAP
MAX2	fdb	DROP
	fdb	SEMIS
;
; ======>>  97  <<
	fcb	$84
	fcc	"-DU"	;fcc	3,-DUP
	fcb	$D0
	fdb	MAX-6
DDUP	fdb	DOCOL,DUP,ZBRAN
	fdb	DDUP2-*
	fdb	DUP
DDUP2	fdb	SEMIS
;
; ######>> screen 39 <<
; ======>>  98  <<
	fcb	$88
	fcc	"TRAVERS"	;fcc	7,TRAVERSE
	fcb	$C5
	fdb	DDUP-7
TRAV	fdb	DOCOL,SWAP
TRAV2	fdb	OVER,PLUS,CLITER
	fcb	$7F
	fdb	OVER,CAT,LESS,ZBRAN
	fdb	TRAV2-*
	fdb	SWAP,DROP
	fdb	SEMIS
;
; ======>>  99  <<
	fcb	$86
	fcc	"LATES"	;fcc	5,LATEST
	fcb	$D4
	fdb	TRAV-11
LATEST	fdb	DOCOL,CURENT,AT,AT
	fdb	SEMIS
;
; ======>>  100  <<
	fcb	$83
	fcc	"LF"	;fcc	2,LFA
	fcb	$C1
	fdb	LATEST-9
LFA	fdb	DOCOL,CLITER
	fcb	4
	fdb	SUB
	fdb	SEMIS
;
; ======>>  101  <<
	fcb	$83
	fcc	"CF"	;fcc	2,CFA
	fcb	$C1
	fdb	LFA-6
CFA	fdb	DOCOL,TWO,SUB
	fdb	SEMIS
;
; ======>>  102  <<
	fcb	$83
	fcc	"NF"	;fcc	2,NFA
	fcb	$C1
	fdb	CFA-6
NFA	fdb	DOCOL,CLITER
	fcb	5
	fdb	SUB,ONE,MINUS,TRAV
	fdb	SEMIS
;
; ======>>  103  <<
	fcb	$83
	fcc	"PF"	;fcc	2,PFA
	fcb	$C1
	fdb	NFA-6
PFA	fdb	DOCOL,ONE,TRAV,CLITER
	fcb	5
	fdb	PLUS
	fdb	SEMIS
;
; ######>> screen 40 <<
; ======>>  104  <<
	fcb	$84
	fcc	"!CS"	;fcc	3,!CSP
	fcb	$D0
	fdb	PFA-6
SCSP	fdb	DOCOL,SPAT,CSP,STORE
	fdb	SEMIS
;
; ======>>  105  <<
	fcb	$86
	fcc	"?ERRO"	;fcc	5,?ERROR
	fcb	$D2
	fdb	SCSP-7
QERR	fdb	DOCOL,SWAP,ZBRAN
	fdb	QERR2-*
	fdb	ERROR,BRAN
	fdb	QERR3-*
QERR2	fdb	DROP
QERR3	fdb	SEMIS
;	
; ======>>  106  <<
	fcb	$85
	fcc	"?COM"	;fcc	4,?COMP
	fcb	$D0
	fdb	QERR-9
QCOMP	fdb	DOCOL,STATE,AT,ZEQU,CLITER
	fcb	$11
	fdb	QERR
	fdb	SEMIS
;
; ======>>  107  <<
	fcb	$85
	fcc	"?EXE"	;fcc	4,?EXEC
	fcb	$C3
	fdb	QCOMP-8
QEXEC	fdb	DOCOL,STATE,AT,CLITER
	fcb	$12
	fdb	QERR
	fdb	SEMIS
;
; ======>>  108  <<
	fcb	$86
	fcc	"?PAIR"	;fcc	5,?PAIRS
	fcb	$D3
	fdb	QEXEC-8
QPAIRS	fdb	DOCOL,SUB,CLITER
	fcb	$13
	fdb	QERR
	fdb	SEMIS
;
; ======>>  109  <<
	fcb	$84
	fcc	"?CS"	;fcc	3,?CSP
	fcb	$D0
	fdb	QPAIRS-9
QCSP	fdb	DOCOL,SPAT,CSP,AT,SUB,CLITER
	fcb	$14
	fdb	QERR
	fdb	SEMIS
;
; ======>>  110  <<
	fcb	$88
	fcc	"?LOADIN"	;fcc	7,?LOADING
	fcb	$C7
	fdb	QCSP-7
QLOAD	fdb	DOCOL,BLK,AT,ZEQU,CLITER
	fcb	$16
	fdb	QERR
	fdb	SEMIS
;
; ######>> screen 41 <<
; ======>>  111  <<
	fcb	$87
	fcc	"COMPIL"	;fcc	6,COMPILE
	fcb	$C5
	fdb	QLOAD-11
COMPIL	fdb	DOCOL,QCOMP,FROMR,TWOP,DUP,TOR,AT,COMMA
	fdb	SEMIS
;
; ======>>  112  <<
	fcb	$C1	; [	immediate
	fcb	$DB
	fdb	COMPIL-10
LBRAK	fdb	DOCOL,ZERO,STATE,STORE
	fdb	SEMIS
;
; ======>>  113  <<
	fcb	$81	; ]
	fcb	$DD
	fdb	LBRAK-4
RBRAK	fdb	DOCOL,CLITER
	fcb	$C0
	fdb	STATE,STORE
	fdb	SEMIS
;
; ======>>  114  <<
	fcb	$86
	fcc	"SMUDG"	;fcc	5,SMUDGE
	fcb	$C5
	fdb	RBRAK-4
SMUDGE	fdb	DOCOL,LATEST,CLITER
	fcb	$20
	fdb	TOGGLE
	fdb	SEMIS
;
; ======>>  115  <<
	fcb	$83
	fcc	"HE"	;fcc	2,HEX
	fcb	$D8
	fdb	SMUDGE-9
HEX	fdb	DOCOL
	fdb	CLITER
	fcb	16
	fdb	BASE,STORE
	fdb	SEMIS
;
; ======>>  116  <<
	fcb	$87
	fcc	"DECIMA"	;fcc	6,DECIMAL
	fcb	$CC
	fdb	HEX-6
DEC	fdb	DOCOL
	fdb	CLITER
	fcb	10	;note: hex "A"
	fdb	BASE,STORE
	fdb	SEMIS
;
; ######>> screen 42 <<
; ======>>  117  <<
	fcb	$87
	fcc	"(:CODE"	;fcc	6,(;CODE)
	fcb	$A9
	fdb	DEC-10
PSCODE	fdb	DOCOL,FROMR,TWOP,LATEST,PFA,CFA,STORE
	fdb	SEMIS
;
; ======>>  118  <<
	fcb	$C5	;immediate
	fcc	";COD"	;fcc	4,;CODE
	fcb	$C5
	fdb	PSCODE-10
SEMIC	fdb	DOCOL,QCSP,COMPIL,PSCODE,SMUDGE,LBRAK,QSTACK
	fdb	SEMIS
; note: "QSTACK" will be replaced by "ASSEMBLER" later
;
; ######>> screen 43 <<
; ======>>  119  <<
	fcb	$87
	fcc	"<BUILD"	;fcc	6,<BUILDS
	fcb	$D3
	fdb	SEMIC-8
BUILDS	fdb	DOCOL,ZERO,CON
	fdb	SEMIS
;
; ======>>  120  <<
	fcb	$85
	fcc	"DOES"	;fcc	4,DOES>
	fcb	$BE
	fdb	BUILDS-10
DOES	fdb	DOCOL,FROMR,TWOP,LATEST,PFA,STORE
	fdb	PSCODE
DODOES	lda	a IP
	lda b	IP+1
	ldx	RP	;make room on return stack
	dex
	dex
	stx	RP
	sta a  	2,x	;push return address
	sta b	3,x
	ldx	W	;get addr of pointer to run-time code
	inx
	inx
	stx	N	;sta a sh it in scratch area
	ldx	0,x	;get new IP
	stx	IP
	clra		;get address of parameter
	lda b	#2
	addb	N+1
	adca	N
	pshb		;and push it on data stack
	psha
	jmp	NEXT2
;
; ######>> screen 44 <<
; ======>>  121  <<
	fcb	$85
	fcc	"COUN"	;fcc	4,COUNT
	fcb	$D4
	fdb	DOES-8
COUNT	fdb	DOCOL,DUP,ONEP,SWAP,CAT
	fdb	SEMIS
;
; ======>>  122  <<
	fcb	$84
	fcc	"TYP"	;fcc	3,TYPE
	fcb	$C5
	fdb	COUNT-8
TYPE	fdb	DOCOL,DDUP,ZBRAN
	fdb	TYPE3-*
	fdb	OVER,PLUS,SWAP,XDO
;
;TYPE2	fdb	I,CAT,EMIT,XLOOP
;
TYPE2	fdb	I,CAT,CLITER	;fix to make VLIST
	fcb	$7F		;type all the characters
	fdb	ANDLAB,EMIT,XLOOP	;in the words
;
	fdb	TYPE2-*
	fdb	BRAN
	fdb	TYPE4-*
TYPE3	fdb	DROP
TYPE4	fdb	SEMIS
;
; ======>>  123  <<
	fcb	$89
	fcc	"-TRAILIN"	;fcc	8,-TRAILING
	fcb	$C7
	fdb	TYPE-7
DTRAIL	fdb	DOCOL,DUP,ZERO,XDO
DTRAL2	fdb	OVER,OVER,PLUS,ONE,SUB,CAT,BL
	fdb	SUB,ZBRAN
	fdb	DTRAL3-*
	fdb	LEAVE,BRAN
	fdb	DTRAL4-*
DTRAL3	fdb	ONE,SUB
DTRAL4	fdb	XLOOP
	fdb	DTRAL2-*
	fdb	SEMIS
;
; ======>>  124  <<
	fcb	$84
	fcb	$28,$2E,$22	;fcc	3,(.")
	fcb	$A9
	fdb	DTRAIL-12
PDOTQ	fdb	DOCOL,R,TWOP,COUNT,DUP,ONEP
	fdb	FROMR,PLUS,TOR,TYPE
	fdb	SEMIS
;
; ======>>  125  <<
	fcb	$C2	;immediate
	fcc	"."	;fcc	1,."
	fcb	$A2
	fdb	PDOTQ-7
DOTQ	fdb	DOCOL
	fdb	CLITER
	fcb	$22	;ascii quote
	fdb	STATE,AT,ZBRAN
	fdb	DOTQ1-*
	fdb	COMPIL,PDOTQ,WORD
	fdb	HERE,CAT,ONEP,ALLOT,BRAN
	fdb	DOTQ2-*
DOTQ1	fdb	WORD,HERE,COUNT,TYPE
DOTQ2	fdb	SEMIS
;
; ######>> screen 45 <<
; ======>>  126  <<== MACHINE DEPENDENT
	fcb	$86
	fcc	"?STAC"	;fcc	5,?STACK
	fcb	$CB
	fdb	DOTQ-5
QSTACK	fdb	DOCOL,CLITER
	fcb	$12
	fdb	PORIG,AT,TWO,SUB,SPAT,LESS,ONE
	fdb	QERR
; prints 'empty stack'
;
QSTAC2	fdb	SPAT
; Here, we compare with a value at least 128
; higher than dict. ptr. (DP)
	fdb	HERE,CLITER
	fcb	$80
	fdb	PLUS,LESS,ZBRAN
	fdb	QSTAC3-*
	fdb	TWO
	fdb	QERR
; prints 'full stack'
;
QSTAC3	fdb	SEMIS
;
; ======>>  127  <<	this word's function
;	    		is done by ?STACK in this version
;	fcb	$85
;	fcc	"?FRE"	;fcc	4,?FREE
;	fcb	$C5
;	fdb	QSTACK-9
;QFREE	fdb	DOCOL,SPAT,HERE,CLITER
;	fcb	$80
;	fdb	PLUS,LESS,TWO,QERR,SEMIS
;
; ######>> screen 46 <<
; ======>>  128  <<
	fcb	$86
	fcc	"EXPEC"	;fcc	5,EXPECT
	fcb	$D4
	fdb	QSTACK-9
EXPECT	fdb	DOCOL,OVER,PLUS,OVER,XDO
EXPEC2	fdb	KEY,DUP,CLITER
	fcb	$0E
	fdb	PORIG,AT,EQUAL,ZBRAN
	fdb	EXPEC3-*
	fdb	DROP,CLITER
	fcb	8	;(backspace character to emit)
	fdb	OVER,I,EQUAL,DUP,FROMR,TWO,SUB,PLUS
	fdb	TOR,SUB,BRAN
	fdb	EXPEC6-*
EXPEC3	fdb	DUP,CLITER
	fcb	$D	;(carriage return)
	fdb	EQUAL,ZBRAN
	fdb	EXPEC4-*
	fdb	LEAVE,DROP,BL,ZERO,BRAN
	fdb	EXPEC5-*
EXPEC4	fdb	DUP
EXPEC5	fdb	I,CSTORE,ZERO,I,ONEP,STORE
EXPEC6	fdb	EMIT,XLOOP
	fdb	EXPEC2-*
	fdb	DROP
	fdb	SEMIS
;
; ======>>  129  <<
	fcb	$85
	fcc	"QUER"	;fcc	4,QUERY
	fcb	$D9
	fdb	EXPECT-9
QUERY	fdb	DOCOL,TIB,AT,COLUMS
	fdb	AT,EXPECT,ZERO,IN,STORE
	fdb	SEMIS
;
; ======>>  130  <<
	fcb	$C1	;immediate	< carriage return >
	fcb	$80
	fdb	QUERY-8
NULL	fdb	DOCOL,BLK,AT,ZBRAN
	fdb	NULL2-*
	fdb	ONE,BLK,PSTORE
	fdb	ZERO,IN,STORE,BLK,AT,BSCR,MODLAB
	fdb	ZEQU
;     check for end of screen
	fdb	ZBRAN
	fdb	NULL1-*
	fdb	QEXEC,FROMR,DROP
NULL1	fdb	BRAN
	fdb	NULL3-*
NULL2	fdb	FROMR,DROP
NULL3	fdb	SEMIS
;
; ######>> screen 47 <<
; ======>>  133  <<
	fcb	$84
	fcc	"FIL"	;fcc	3,FILL
	fcb	$CC
	fdb	NULL-4
FILL	fdb	DOCOL,SWAP,TOR,OVER,CSTORE,DUP,ONEP
	fdb	FROMR,ONE,SUB,CMOVE
	fdb	SEMIS
;
; ======>>  134  <<
	fcb	$85
	fcc	"ERAS"	;fcc	4,ERASE
	fcb	$C5
	fdb	FILL-7
ERASE	fdb	DOCOL,ZERO,FILL
	fdb	SEMIS
;
; ======>>  135  <<
	fcb	$86
	fcc	"BLANK"	;fcc	5,BLANKS
	fcb	$D3
	fdb	ERASE-8
BLANKS	fdb	DOCOL,BL,FILL
	fdb	SEMIS
;
; ======>>  136  <<
	fcb	$84
	fcc	"HOL"	;fcc	3,HOLD
	fcb	$C4
	fdb	BLANKS-9
HOLD	fdb	DOCOL,LIT,$FFFF,HLD,PSTORE,HLD,AT,CSTORE
	fdb	SEMIS
;
; ======>>  137  <<
	fcb	$83
	fcc	"PA"	;fcc	2,PAD
	fcb	$C4
	fdb	HOLD-7
PAD	fdb	DOCOL,HERE,CLITER
	fcb	$44
	fdb	PLUS
	fdb	SEMIS
;
; ######>> screen 48 <<
; ======>>  138  <<
	fcb	$84
	fcc	"WORLAB"	;fcc	3,WORD
	fcb	$C4
	fdb	PAD-6
WORD	fdb	DOCOL,BLK,AT,ZBRAN
	fdb	WORD2-*
	fdb	BLK,AT,BLOCK,BRAN
	fdb	WORD3-*
WORD2	fdb	TIB,AT
WORD3	fdb	IN,AT,PLUS,SWAP,ENCLOS,HERE,CLITER
	fcb	34
	fdb	BLANKS,IN,PSTORE,OVER,SUB,TOR,R,HERE
	fdb	CSTORE,PLUS,HERE,ONEP,FROMR,CMOVE
	fdb	SEMIS
;
; ######>> screen 49 <<
; ======>>  139  <<
	fcb	$88
	fcc	"(NUMBER"	;fcc	7,(NUMBER)
	fcb	$A9
	fdb	WORD-7
PNUMB	fdb	DOCOL
PNUMB2	fdb	ONEP,DUP,TOR,CAT,BASE,AT,DIGIT,ZBRAN
	fdb	PNUMB4-*
	fdb	SWAP,BASE,AT,USTAR,DROP,ROT,BASE
	fdb	AT,USTAR,DPLUS,DPL,AT,ONEP,ZBRAN
	fdb	PNUMB3-*
	fdb	ONE,DPL,PSTORE
PNUMB3	fdb	FROMR,BRAN
	fdb	PNUMB2-*
PNUMB4	fdb	FROMR
	fdb	SEMIS
;
; ======>>  140  <<
	fcb	$86
	fcc	"NUMBE"	;fcc	5,NUMBER
	fcb	$D2
	fdb	PNUMB-11
NUMB	fdb	DOCOL,ZERO,ZERO,ROT,DUP,ONEP,CAT,CLITER
	fcc	"-"	;minus sign
	fdb	EQUAL,DUP,TOR,PLUS,LIT,$FFFF
NUMB1	fdb	DPL,STORE,PNUMB,DUP,CAT,BL,SUB
	fdb	ZBRAN
	fdb	NUMB2-*
	fdb	DUP,CAT,CLITER
	fcc	"."
	fdb	SUB,ZERO,QERR,ZERO,BRAN
	fdb	NUMB1-*
NUMB2	fdb	DROP,FROMR,ZBRAN
	fdb	NUMB3-*
	fdb	DMINUS
NUMB3	fdb	SEMIS
;
; ======>>  141  <<
	fcb	$85
	fcc	"-FIN"	;fcc	4,-FIND
	fcb	$C4
	fdb	NUMB-9
DFIND	fdb	DOCOL,BL,WORD,HERE,CONTXT,AT,AT
	fdb	PFIND,DUP,ZEQU,ZBRAN
	fdb	DFIND2-*
	fdb	DROP,HERE,LATEST,PFIND
DFIND2	fdb	SEMIS
;
; ######>> screen 50 <<
; ======>>  142  <<
	fcb	$87
	fcc	"(ABORT"	;fcc	6,(ABORT)
	fcb	$A9
	fdb	DFIND-8
PABORT	fdb	DOCOL,ABORT
	fdb	SEMIS
;
; ======>>  143  <<
	fcb	$85
	fcc	"ERRO"	;fcc	4,ERROR
	fcb	$D2
	fdb	PABORT-10
ERROR	fdb	DOCOL,WARN,AT,ZLESS
	fdb	ZBRAN
; note: WARNING is -1 to abort, 0 to print ERROR #
; and 1 to print ERROR message from disc
	fdb	ERROR2-*
	fdb	PABORT
ERROR2	fdb	HERE,COUNT,TYPE,PDOTQ
	fcb	4,7	;(bell)
	fcc	" ? "
	fdb	MESS,SPSTOR,IN,AT,BLK,AT,QUIT
	fdb	SEMIS
;
; ======>>  144  <<
	fcb	$83
	fcc	"ID"	;fcc	2,ID.
	fcb	$AE
	fdb	ERROR-8
IDDOT	fdb	DOCOL,PAD,CLITER
	fcb	32
	fdb	CLITER
	fcb	$5F	;(underline)
	fdb	FILL,DUP,PFA,LFA,OVER,SUB,PAD
	fdb	SWAP,CMOVE,PAD,COUNT,CLITER
	fcb	31
	fdb	ANDLAB,TYPE,SPACE
	fdb	SEMIS
;
; ######>> screen 51 <<
; ======>>  145  <<
	fcb	$86
	fcc	"CREAT"	;fcc	5,CREATE
	fcb	$C5
	fdb	IDDOT-6
CREATE	fdb	DOCOL,DFIND,ZBRAN
	fdb	CREAT2-*
	fdb	DROP,PDOTQ
	fcb	8
	fcb	7	;(bel)
	fcc	"redef: "
	fdb	NFA,IDDOT,CLITER
	fcb	4
	fdb	MESS,SPACE
CREAT2	fdb	HERE,DUP,CAT,WIDTH,AT,MIN
	fdb	ONEP,ALLOT,DUP,CLITER
	fcb	$A0
	fdb	TOGGLE,HERE,ONE,SUB,CLITER
	fcb	$80
	fdb	TOGGLE,LATEST,COMMA,CURENT,AT,STORE
	fdb	HERE,TWOP,COMMA
	fdb	SEMIS
;
; ######>> screen 52 <<
; ======>>  146  <<
	fcb	$C9	;immediate
	fcc	"[COMPILE"	;fcc	8,[COMPILE]
	fcb	$DD
	fdb	CREATE-9
BcomP	fdb	DOCOL,DFIND,ZEQU,ZERO,QERR,DROP,CFA,COMMA
	fdb	SEMIS
;
; ======>>  147  <<
	fcb	$C7	;immediate
	fcc	"LITERA"	;fcc	6,LITERAL
	fcb	$CC
	fdb	BcomP-12
LITER	fdb	DOCOL,STATE,AT,ZBRAN
	fdb	LITER2-*
	fdb	COMPIL,LIT,COMMA
LITER2	fdb	SEMIS
;
; ======>>  148  <<
	fcb	$C8	;immediate
	fcc	"DLITERA"	;fcc	7,DLITERAL
	fcb	$CC
	fdb	LITER-10
DLITER	fdb	DOCOL,STATE,AT,ZBRAN
	fdb	DLITE2-*
	fdb	SWAP,LITER,LITER
DLITE2	fdb	SEMIS
;
; ######>> screen 53 <<
; ======>>  149  <<
	fcb	$89
	fcc	"INTERPRE"	;fcc	8,INTERPRET
	fcb	$D4
	fdb	DLITER-11
INTERP	fdb	DOCOL
INTER2	fdb	DFIND,ZBRAN
	fdb	INTER5-*
	fdb	STATE,AT,LESS
	fdb	ZBRAN
	fdb	INTER3-*
	fdb	CFA,COMMA,BRAN
	fdb	INTER4-*
INTER3	fdb	CFA,EXEC
INTER4	fdb	BRAN
	fdb	INTER7-*
INTER5	fdb	HERE,NUMB,DPL,AT,ONEP,ZBRAN
	fdb	INTER6-*
	fdb	DLITER,BRAN
	fdb	INTER7-*
INTER6	fdb	DROP,LITER
INTER7	fdb	QSTACK,BRAN
	fdb	INTER2-*
;	fdb	SEMIS	;never executed
;
; ######>> screen 54 <<
; ======>>  150  <<
	fcb	$89
	fcc	"IMMEDIAT"	;fcc	8,IMMEDIATE
	fcb	$C5
	fdb	INTERP-12
IMMED	fdb	DOCOL,LATEST,CLITER
	fcb	$40
	fdb	TOGGLE
	fdb	SEMIS
;
; ======>>  151  <<
	fcb	$8A
	fcc	"VOCABULAR"	;fcc	9,VOCABULARY
	fcb	$D9
	fdb	IMMED-12
VOCAB	fdb	DOCOL,BUILDS,LIT,$81A0,COMMA,CURENT,AT,CFA
	fdb	COMMA,HERE,VOCLIN,AT,COMMA,VOCLIN,STORE,DOES
DOVOC	fdb	TWOP,CONTXT,STORE
	fdb	SEMIS
;
; ======>>  152  <<
;
; Note: FORTH does not go here in the rom-able dictionary,
;       since FORTH is a type of variable.
;
;
; ======>>  153  <<
	fcb	$8B
	fcc	"DEFINITION"	;fcc	10,DEFINITIONS
	fcb	$D3
	fdb	VOCAB-13
DEFIN	fdb	DOCOL,CONTXT,AT,CURENT,STORE
	fdb	SEMIS
;
; ======>>  154  <<
	fcb	$C1	;immediate	(
	fcb	$A8
	fdb	DEFIN-14
PAREN	fdb	DOCOL,CLITER
	fcc	")"
	fdb	WORD
	fdb	SEMIS
;
; ######>> screen 55 <<
; ======>>  155  <<
	fcb	$84
	fcc	"QUI"	;fcc	3,QUIT
	fcb	$D4
	fdb	PAREN-4
QUIT	fdb	DOCOL,ZERO,BLK,STORE
	fdb	LBRAK
;
;  Here is the outer interpreter
;  which gets a line of input, does it, prints " OK"
;  then repeats :
;
QUIT2	fdb	RPSTOR,CR,QUERY,INTERP,STATE,AT,ZEQU
	fdb	ZBRAN
	fdb	QUIT3-*
	fdb	PDOTQ
	fcb	3
	fcc	" OK"	;fcc	3, OK
QUIT3	fdb	BRAN
	fdb	QUIT2-*
;	fdb	SEMIS	;(never executed)
;
; ======>>  156  <<
	fcb	$85
	fcc	"ABOR"	;fcc	4,ABORT
	fcb	$D4
	fdb	QUIT-7
ABORT	fdb	DOCOL,SPSTOR,DEC,QSTACK,DRZERO,CR,PDOTQ
	fcb	8
	fcc	"Forth-68"
	fdb	FORTH,DEFIN
	fdb	QUIT
;	fdb	SEMIS	;never executed
;
; ######>> screen 56 <<
; bootstrap code... moves rom contents to ram :
; ======>>  157  <<
	fcb	$84
	fcc	"COL"	;fcc	3,COLD
	fcb	$C4
	fdb	ABORT-8
COLD	fdb	*+2
CENT	lds	#REND-1	;top of destination
	ldx	#ERAM	;top of stuff to move
COLD2	dex
	lda a 0,x
	psha		;move TASK & FORTH to ram
	cpx	#RAM
	bne	COLD2
;
	lds	#XFENCE-1	;put stack at a safe place for now
	ldx	COLINT
	stx	XCOLUM
	ldx	DELINT
	stx	XDELAY
	ldx	VOCINT
	stx	XVOCL
	ldx	DPINIT
	stx	XDP
	ldx	FENCIN
	stx	XFENCE
;
WENT	lds	#XFENCE-1	;top of destination
	ldx	#FENCIN		;top of stuff to move
WARM2	dex
	lda a 0,x
	psha
	cpx	#SINIT
	bne	WARM2
;
	lds	SINIT
	ldx	UPINIT
	stx	UP		;init user ram pointer
	ldx	#ABORT
	stx	IP
	nop		;Here is a place to jump to special user
	nop		;initializations such as I/0 interrups
	nop
;
; For systems with TRACE:
	ldx	#00
	stx	TRLIM	;clear trace mode
	ldx	#0
	stx	BRKPT	;clear breakpoint address
	jmp	RPSTOR+2 ;sta a rt the virtual machine running !
;
; Here is the stuff that gets copied to ram :
; at address $140:
;
RAM	fdb	$3000,$3000,0,0
;
; ======>>  (152)  <<
	fcb	$C5	;immediate
	fcc	"FORT"	;fcc	4,FORTH
	fcb	$C8
	fdb	NOOP-7
RFORTH	fdb	DODOES,DOVOC,$81A0,TASK-7
	fdb	0
	fcc	"(C) Forth Interest Group, 1979"
	fcb	$84
	fcc	"TAS"	;fcc	3,TASK
	fcb	$CB
	fdb	FORTH-8
RTASK	fdb	DOCOL,SEMIS
ERAM	fcc	"David Lion"	
;
; ######>> screen 57 <<
; ======>>  158  <<
	fcb	$84
	fcc	"S->"	;fcc	3,S->D
	fcb	$C4
	fdb	COLD-7
STOD	fdb	DOCOL,DUP,ZLESS,MINUS
	fdb	SEMIS
;
; ======>>  159  <<
	fcb	$81	; *
	fcb	$AA
	fdb	STOD-7
STAR	fdb	*+2
	jsr	USTARS
	ins
	ins
	jmp	NEXT
;
; ======>>  160  <<
	fcb	$84
	fcc	"/MO"	;fcc	3,/MODLAB
	fcb	$C4
	fdb	STAR-4
SLMOD	fdb	DOCOL,TOR,STOD,FROMR,USLASH
	fdb	SEMIS
;
; ======>>  161  <<
	fcb	$81	; /
	fcb	$AF
	fdb	SLMOD-7
SLASH	fdb	DOCOL,SLMOD,SWAP,DROP
	fdb	SEMIS
;
; ======>>  162  <<
	fcb	$83
	fcc	"MO"	;fcc	2,MODLAB
	fcb	$C4
	fdb	SLASH-4
MODLAB	fdb	DOCOL,SLMOD,DROP
	fdb	SEMIS
;
; ======>>  163  <<
	fcb	$85
	fcc	"*/MO"	;fcc	4,*/MODLAB
	fcb	$C4
	fdb	MODLAB-6
SSMOD	fdb	DOCOL,TOR,USTAR,FROMR,USLASH
	fdb	SEMIS
;
; ======>>  164  <<
	fcb	$82
	fcc	"*"	;fcc	1,*/
	fcb	$AF
	fdb	SSMOD-8
SSLASH	fdb	DOCOL,SSMOD,SWAP,DROP
	fdb	SEMIS
;
; ======>>  165  <<
	fcb	$85
	fcc	"M/MO"	;fcc	4,M/MODLAB
	fcb	$C4
	fdb	SSLASH-5
MSMOD	fdb	DOCOL,TOR,ZERO,R,USLASH
	fdb	FROMR,SWAP,TOR,USLASH,FROMR
	fdb	SEMIS
;
; ======>>  166  <<
	fcb	$83
	fcc	"AB"	;fcc	2,ABS
	fcb	$D3
	fdb	MSMOD-8
ABS	fdb	DOCOL,DUP,ZLESS,ZBRAN
	fdb	ABS2-*
	fdb	MINUS
ABS2	fdb	SEMIS
;
; ======>>  167  <<
	fcb	$84
	fcc	"DAB"	;fcc	3,DABS
	fcb	$D3
	fdb	ABS-6
DABS	fdb	DOCOL,DUP,ZLESS,ZBRAN
	fdb	DABS2-*
	fdb	DMINUS
DABS2	fdb	SEMIS
;
; ######>> screen 58 <<
; Disc primatives :
; ======>>  168  <<
	fcb	$83
	fcc	"US"	;fcc	2,USE
	fcb	$C5
	fdb	DABS-7
USE	fdb	DOCON
	fdb	XUSE
;
; ======>>  169  <<
	fcb	$84
	fcc	"PRE"	;fcc	3,PREV
	fcb	$D6
	fdb	USE-6
PREV	fdb	DOCON
	fdb	XPREV
;
; ======>>  170  <<
	fcb	$84
	fcc	"+BU"	;fcc	3,+BUF
	fcb	$C6
	fdb	PREV-7
PBUF	fdb	DOCOL,CLITER
	fcb	$84
	fdb	PLUS,DUP,LIMIT,EQUAL,ZBRAN
	fdb	PBUF2-*
	fdb	DROP,FIRST
PBUF2	fdb	DUP,PREV,AT,SUB
	fdb	SEMIS
;
; ======>>  171  <<
	fcb	$86
	fcc	"UPDAT"	;fcc	5,UPDATE
	fcb	$C5
	fdb	PBUF-7
UPDATE	fdb	DOCOL,PREV,AT,AT,LIT,$8000,ORLAB,PREV,AT,STORE
	fdb	SEMIS
;
; ======>>  172  <<
	fcb	$8D
	fcc	"EMPTY-BUFFER"	;fcc	12,EMPTY-BUFFERS
	fcb	$D3
	fdb	UPDATE-9
MTBUF	fdb	DOCOL,FIRST,LIMIT,OVER,SUB,ERASE
	fdb	SEMIS
;
; ======>>  173  <<
	fcb	$83
	fcc	"DR"	;fcc	2,DR0
	fcb	$B0
	fdb	MTBUF-16
DRZERO	fdb	DOCOL,ZERO,OFSET,STORE
	fdb	SEMIS
;
; ======>>  174  <<== system dependant word
	fcb	$83
	fcc	"DR"	;fcc	2,DR1
	fcb	$B1
	fdb	DRZERO-6
DRONE	fdb	DOCOL,LIT,$07D0,OFSET,STORE
	fdb	SEMIS
;
; ######>> screen 59 <<
; ======>>  175  <<
	fcb	$86
	fcc	"BUFFE"	;fcc	5,BUFFER
	fcb	$D2
	fdb	DRONE-6
BUFFER	fdb	DOCOL,USE,AT,DUP,TOR
BUFFR2	fdb	PBUF,ZBRAN
	fdb	BUFFR2-*
	fdb	USE,STORE,R,AT,ZLESS
	fdb	ZBRAN
	fdb	BUFFR3-*
	fdb	R,TWOP,R,AT,LIT,$7FFF,ANDLAB,ZERO,RW
BUFFR3	fdb	R,STORE,R,PREV,STORE,FROMR,TWOP
	fdb	SEMIS
;
; ######>> screen 60 <<
; ======>>  176  <<
	fcb	$85
	fcc	"BLOC"	;fcc	4,BLOCK
	fcb	$CB
	fdb	BUFFER-9
BLOCK	fdb	DOCOL,OFSET,AT,PLUS,TOR
	fdb	PREV,AT,DUP,AT,R,SUB,DUP,PLUS,ZBRAN
	fdb	BLOCK5-*
BLOCK3	fdb	PBUF,ZEQU,ZBRAN
	fdb	BLOCK4-*
	fdb	DROP,R,BUFFER,DUP,R,ONE,RW,TWO,SUB
BLOCK4	fdb	DUP,AT,R,SUB,DUP,PLUS,ZEQU,ZBRAN
	fdb	BLOCK3-*
	fdb	DUP,PREV,STORE
BLOCK5	fdb	FROMR,DROP,TWOP
	fdb	SEMIS
;
; ######>> screen 61 <<
; ======>>  177  <<
	fcb	$86
	fcc	"(LINE"	;fcc	5,(LINE)
	fcb	$A9
	fdb	BLOCK-8
PLINE	fdb	DOCOL,TOR,CLITER
	fcb	$40
	fdb	BBUF,SSMOD,FROMR,BSCR,STAR,PLUS,BLOCK,PLUS,CLITER
	fcb	$40
	fdb	SEMIS
;
; ======>>  178  <<
	fcb	$85
	fcc	".LIN"	;fcc	4,.LINE
	fcb	$C5
	fdb	PLINE-9
DLINE	fdb	DOCOL,PLINE,DTRAIL,TYPE
	fdb	SEMIS
;
; ======>>  179  <<
	fcb	$87
	fcc	"MESSAG"	;fcc	6,MESSAGE
	fcb	$C5
	fdb	DLINE-8
MESS	fdb	DOCOL,WARN,AT,ZBRAN
	fdb	MESS3-*
	fdb	DDUP,ZBRAN
	fdb	MESS3-*
	fdb	CLITER
	fcb	4
	fdb	OFSET,AT,BSCR,SLASH,SUB,DLINE,BRAN
	fdb	MESS4-*
MESS3	fdb	PDOTQ
	fcb	6
	fcc	"err # "	;fcc	6,err # 
	fdb	DOT
MESS4	fdb	SEMIS
;
; ======>>  180  <<
	fcb	$84
	fcc	"LOA"	;fcc	3,LOAD	;input:scr #
	fcb	$C4
	fdb	MESS-10
LOAD	fdb	DOCOL,BLK,AT,TOR,IN,AT,TOR,ZERO,IN,STORE
	fdb	BSCR,STAR,BLK,STORE
	fdb	INTERP,FROMR,IN,STORE,FROMR,BLK,STORE
	fdb	SEMIS
;
; ======>>  181  <<
	fcb	$C3
	fcc	"--"	;fcc	2,-->
	fcb	$BE
	fdb	LOAD-7
ARROW	fdb	DOCOL,QLOAD,ZERO,IN,STORE,BSCR
	fdb	BLK,AT,OVER,MODLAB,SUB,BLK,PSTORE
	fdb	SEMIS
;
;
; ######>> screen 63 <<
;    The next 4 subroutines are machine dependent, and are
;    called by words 13 through 16 in the dictionary.
;
;
; ======>>  182  << code for EMIT
PEMIT	sta b	N	;save B
	stx	N+1	;save X
	lda b	ACIAC
	bitb	#2	;check ready bit
	beq	PEMIT+4	;if not ready for more data
	sta a 	ACIAD
	ldx	UP
	sta b	IOSTAT-UORIG,x
	lda b	N	;recover B & X
	ldx	N+1
	rts		;only A register may change

;PEMIT	jmp	$E1D1	;for MIKBUG
;  PEMIT	fcb	$3F,$11,$39	;for PROTO
;  PEMIT	jmp	$D286 ;for Smoke Signal DOS
;
; ======>>  183  << code for KEY
PKEY	sta b	N
	stx	N+1
	lda b	ACIAC
	asrb
	bcc	PKEY+4	;no incoming data yet
	lda	a ACIAD
	anda	#$7F	;strip parity bit
	ldx	UP
	sta b	IOSTAT+1-UORIG,x
	lda b	N
	ldx	N+1
	rts
	
;PKEY	jmp	$E1AC	;for MIKBUG
;  PKEY	fcb	$3F,$14,$39	;for PROTO
;  PKEY	jmp	$D289 ;for Smoke Signal DOS
;
; ######>> screen 64 <<
; ======>>  184  << code for ?TERMINAL
PQTER	lda	a ACIAC	;Test for 'break'  condition
	anda	#$11	;mask framing ERROR bit and
;			 input buffer full
	beq	PQTER2
	lda	a ACIAD	;clear input buffer
	lda a #01
PQTER2	rts
;
; ======>>  185  << code for CR
PCR	lda a #$D	;carriage return
	bsr	PEMIT
	lda a #$A	;line feed
	bsr	PEMIT
	lda a #$7F	;rubout
	ldx	UP
	lda b	XDELAY+1-UORIG,x
PCR2	decb
	bmi	PQTER2	;return if minus
	pshb		;save counter
	bsr	PEMIT	;print RUBOUTs to delay.....
	pulb
	bra	PCR2	;repeat
;
; ######>> screen 66 <<
; ======>>  187  <<
	fcb	$85
	fcc	"?DIS"	;fcc	4,?DISC
	fcb	$C3
	fdb	ARROW-6
QDISC	fdb	*+2
	jmp	NEXT
;
; ######>> screen 67 <<
; ======>>  189  <<
	fcb	$8B
	fcc	"BLOCK_WRIT"	;fcc	10,BLOCK-WRITE
	fcb	$C5
	fdb	QDISC-8
BWRITE	fdb	*+2
	jmp	NEXT
;
; ######>> screen 68 <<
; ======>>  190  <<
	fcb	$8A
	fcc	"BLOCK_REA"	;fcc	9,BLOCK-READ
	fcb	$C4
	fdb	BWRITE-14
BREAD	fdb	*+2
	jmp	NEXT
;
; The next 3 words are written to create a substitute for disc
; mass memory,located between $3210 & $7BFF in ram.
;
; ======>>  190.1  <<
	fcb	$82
	fcc	"L"	;fcc	1,LO
	fcb	$CF
	fdb	BREAD-13
LO	fdb	DOCON
	fdb	MEMEND	;a system dependent equate at front
;
; ======>>  190.2  <<
	fcb	$82
	fcc	"H"	;fcc	1,HI
	fcb	$C9
	fdb	LO-5
HI	fdb	DOCON
	fdb	MEMTOP	;($7BFF in this version)
;
; ######>> screen 69 <<
; ======>>  191  <<
	fcb	$83
	fcc	"R/"	;fcc	2,R/W
	fcb	$D7
	fdb	HI-5
RW	fdb	DOCOL,TOR,BBUF,STAR,LO,PLUS,DUP,HI,GREAT,ZBRAN
	fdb	RW2-*
	fdb	PDOTQ
	fcb	8
	fcc	" Range ;"	;fcc	8, Range ;?
	fdb	QUIT
RW2	fdb	FROMR,ZBRAN
	fdb	RW3-*
	fdb	SWAP
RW3	fdb	BBUF,CMOVE
	fdb	SEMIS
;
; ######>> screen 72 <<
; ======>>  192  <<
	fcb	$C1	;immediate
	fcb	$A7	; ' (tick)
	fdb	RW-6
TICK	fdb	DOCOL,DFIND,ZEQU,ZERO,QERR,DROP,LITER
	fdb	SEMIS
;
; ======>>  193  <<
	fcb	$86
	fcc	"FORGE"	;fcc	5,FORGET
	fcb	$D4
	fdb	TICK-4
FORGET	fdb	DOCOL,CURENT,AT,CONTXT,AT,SUB,CLITER
	fcb	$18
	fdb	QERR,TICK,DUP,FENCE,AT,LESS,CLITER
	fcb	$15
	fdb	QERR,DUP,ZERO,PORIG,GREAT,CLITER
	fcb	$15
	fdb	QERR,DUP,NFA,DP,STORE,LFA,AT,CONTXT,AT,STORE
	fdb	SEMIS
;
; ######>> screen 73 <<
; ======>>  194  <<
	fcb	$84
	fcc	"BAC"	;fcc	3,BACK
	fcb	$CB
	fdb	FORGET-9
BACK	fdb	DOCOL,HERE,SUB,COMMA
	fdb	SEMIS
;
; ======>>  195  <<
	fcb	$C5
	fcc	"BEGI"	;fcc	4,BEGIN
	fcb	$CE
	fdb	BACK-7
BEGIN	fdb	DOCOL,QCOMP,HERE,ONE
	fdb	SEMIS
;
; ======>>  196  <<
	fcb	$C5
	fcc	"ENDI"	;fcc	4,ENDIF
	fcb	$C6
	fdb	BEGIN-8
ENDIF	fdb	DOCOL,QCOMP,TWO,QPAIRS,HERE
	fdb	OVER,SUB,SWAP,STORE
	fdb	SEMIS
;
; ======>>  197  <<
	fcb	$C4
	fcc	"THE"	;fcc	3,THEN
	fcb	$CE
	fdb	ENDIF-8
THEN	fdb	DOCOL,ENDIF
	fdb	SEMIS
;
; ======>>  198  <<
	fcb	$C2
	fcc	"D"	;fcc	1,DO
	fcb	$CF
	fdb	THEN-7
DO	fdb	DOCOL,COMPIL,XDO,HERE,THREE
	fdb	SEMIS
;
; ======>>  199  <<
	fcb	$C4
	fcc	"LOO"	;fcc	3,LOOP
	fcb	$D0
	fdb	DO-5
LOOP	fdb	DOCOL,THREE,QPAIRS,COMPIL,XLOOP,BACK
	fdb	SEMIS
;
; ======>>  200  <<
	fcb	$C5
	fcc	"+LOO"	;fcc	4,+LOOP
	fcb	$D0
	fdb	LOOP-7
PLOOP	fdb	DOCOL,THREE,QPAIRS,COMPIL,XPLOOP,BACK
	fdb	SEMIS
;
; ======>>  201  <<
	fcb	$C5
	fcc	"UNTI"	;fcc	4,UNTIL	;(same as END)
	fcb	$CC
	fdb	PLOOP-8
UNTIL	fdb	DOCOL,ONE,QPAIRS,COMPIL,ZBRAN,BACK
	fdb	SEMIS
;
; ######>> screen 74 <<
; ======>>  202  <<
	fcb	$C3
	fcc	"EN"	;fcc	2,END
	fcb	$C4
	fdb	UNTIL-8
END	fdb	DOCOL,UNTIL
	fdb	SEMIS
;
; ======>>  203  <<
	fcb	$C5
	fcc	"AGAI"	;fcc	4,AGAIN
	fcb	$CE
	fdb	END-6
AGAIN	fdb	DOCOL,ONE,QPAIRS,COMPIL,BRAN,BACK
	fdb	SEMIS
;
; ======>>  204  <<
	fcb	$C6
	fcc	"REPEA"	;fcc	5,REPEAT
	fcb	$D4
	fdb	AGAIN-8
REPEAT	fdb	DOCOL,TOR,TOR,AGAIN,FROMR,FROMR
	fdb	TWO,SUB,ENDIF
	fdb	SEMIS
;
; ======>>  205  <<
	fcb	$C2
	fcc	"I"	;fcc	1,IF
	fcb	$C6
	fdb	REPEAT-9
IF	fdb	DOCOL,COMPIL,ZBRAN,HERE,ZERO,COMMA,TWO
	fdb	SEMIS
;
; ======>>  206  <<
	fcb	$C4
	fcc	"ELS"	;fcc	3,ELSE
	fcb	$C5
	fdb	IF-5
ELSE	fdb	DOCOL,TWO,QPAIRS,COMPIL,BRAN,HERE
	fdb	ZERO,COMMA,SWAP,TWO,ENDIF,TWO
	fdb	SEMIS
;
; ======>>  207  <<
	fcb	$C5
	fcc	"WHIL"	;fcc	4,WHILE
	fcb	$C5
	fdb	ELSE-7
WHILE	fdb	DOCOL,IF,TWOP
	fdb	SEMIS
;
; ######>> screen 75 <<
; ======>>  208  <<
	fcb	$86
	fcc	"SPACE"	;fcc	5,SPACES
	fcb	$D3
	fdb	WHILE-8
SPACES	fdb	DOCOL,ZERO,MAX,DDUP,ZBRAN
	fdb	SPACE3-*
	fdb	ZERO,XDO
SPACE2	fdb	SPACE,XLOOP
	fdb	SPACE2-*
SPACE3	fdb	SEMIS
;
; ======>>  209  <<
	fcb	$82
	fcc	"<"	;fcc	1,<#
	fcb	$A3
	fdb	SPACES-9
BDIGS	fdb	DOCOL,PAD,HLD,STORE
	fdb	SEMIS
;
; ======>>  210  <<
	fcb	$82
	fcc	"#"	;fcc	1,#>
	fcb	$BE
	fdb	BDIGS-5
EDIGS	fdb	DOCOL,DROP,DROP,HLD,AT,PAD,OVER,SUB
	fdb	SEMIS
;
; ======>>  211  <<
	fcb	$84
	fcc	"SIG"	;fcc	3,SIGN
	fcb	$CE
	fdb	EDIGS-5
SIGN	fdb	DOCOL,ROT,ZLESS,ZBRAN
 	fdb	SIGN2-*
 	fdb	CLITER
 	fcc	"-"	
 	fdb	HOLD
SIGN2	fdb	SEMIS
;
; ======>>  212  <<
	fcb	$81	; #
	fcb	$A3
	fdb	SIGN-7
DIG	fdb	DOCOL,BASE,AT,MSMOD,ROT,CLITER
	fcb	9
	fdb	OVER,LESS,ZBRAN
	fdb	DIG2-*
	fdb	CLITER
	fcb	7
	fdb	PLUS
DIG2	fdb	CLITER
	fcc	"0"	;ascii zero
	fdb	PLUS,HOLD
	fdb	SEMIS
;
; ======>>  213  <<
	fcb	$82
	fcc	"#"	;fcc	1,#S
	fcb	$D3
	fdb	DIG-4
DIGS	fdb	DOCOL
DIGS2	fdb	DIG,OVER,OVER,ORLAB,ZEQU,ZBRAN
	fdb	DIGS2-*
	fdb	SEMIS
;
; ######>> screen 76 <<
; ======>>  214  <<
	fcb	$82
	fcc	"."	;fcc	1,.R
	fcb	$D2
	fdb	DIGS-5
DOTR	fdb	DOCOL,TOR,STOD,FROMR,DDOTR
	fdb	SEMIS
;
; ======>>  215  <<
	fcb	$83
	fcc	"D."	;fcc	2,D.R
	fcb	$D2
	fdb	DOTR-5
DDOTR	fdb	DOCOL,TOR,SWAP,OVER,DABS,BDIGS,DIGS,SIGN
	fdb	EDIGS,FROMR,OVER,SUB,SPACES,TYPE
	fdb	SEMIS
;
; ======>>  216  <<
	fcb	$82
	fcc	"D"	;fcc	1,D.
	fcb	$AE
	fdb	DDOTR-6
DDOT	fdb	DOCOL,ZERO,DDOTR,SPACE
	fdb	SEMIS
;
; ======>>  217  <<
	fcb	$81	; .
	fcb	$AE
	fdb	DDOT-5
DOT	fdb	DOCOL,STOD,DDOT
	fdb	SEMIS
;
; ======>>  218  <<
	fcb	$81	; ?
	fcb	$BF
	fdb	DOT-4
QUEST	fdb	DOCOL,AT,DOT
	fdb	SEMIS
;
; ######>> screen 77 <<
; ======>>  219  <<
	fcb	$84
	fcc	"LIS"	;fcc	3,LIST
	fcb	$D4
	fdb	QUEST-4
LIST	fdb	DOCOL,DEC,CR,DUP,SCR,STORE,PDOTQ
	fcb	6
	fcc	"SCR # "
	fdb	DOT,CLITER
	fcb	$10
	fdb	ZERO,XDO
LIST2	fdb	CR,I,THREE
	fdb	DOTR,SPACE,I,SCR,AT,DLINE,XLOOP
	fdb	LIST2-*
	fdb	CR
	fdb	SEMIS
;
; ======>>  220  <<
	fcb	$85
	fcc	"INDE"	;fcc	4,INDEX
	fcb	$D8
	fdb	LIST-7
INDEX	fdb	DOCOL,CR,ONEP,SWAP,XDO
INDEX2	fdb	CR,I,THREE
	fdb	DOTR,SPACE,ZERO,I,DLINE
	fdb	QTERM,ZBRAN
	fdb	INDEX3-*
	fdb	LEAVE
INDEX3	fdb	XLOOP
	fdb	INDEX2-*
	fdb	SEMIS
;
; ======>>  221  <<
	fcb	$85
	fcc	"TRIA"	;fcc	4,TRIAD
	fcb	$C4
	fdb	INDEX-8
TRIAD	fdb	DOCOL,THREE,SLASH,THREE,STAR
	fdb	THREE,OVER,PLUS,SWAP,XDO
TRIAD2	fdb	CR,I
	fdb	LIST,QTERM,ZBRAN
	fdb	TRIAD3-*
	fdb	LEAVE
TRIAD3	fdb	XLOOP
	fdb	TRIAD2-*
	fdb	CR,CLITER
	fcb	$0F
	fdb	MESS,CR
	fdb	SEMIS
;
; ######>> screen 78 <<
; ======>>  222  <<
	fcb	$85
	fcc	"VLIS"	;fcc	4,VLIST
	fcb	$D4
	fdb	TRIAD-8
VLIST	fdb	DOCOL,CLITER
	fcb	$80
	fdb	OUT,STORE,CONTXT,AT,AT
VLIST1	fdb	OUT,AT,COLUMS,AT,CLITER
	fcb	32
	fdb	SUB,GREAT,ZBRAN
	fdb	VLIST2-*
	fdb	CR,ZERO,OUT,STORE
VLIST2	fdb	DUP,IDDOT,SPACE,SPACE,PFA,LFA,AT
	fdb	DUP,ZEQU,QTERM,ORLAB,ZBRAN
	fdb	VLIST1-*
	fdb	DROP
	fdb	SEMIS
;
; ======>>  XX  <<
	fcb	$84
	fcc	"NOO"	;fcc	3,NOOP
	fcb	$D0
	fdb	VLIST-8
NOOP	fdb	NEXT	;a useful no-op
ZZZZ	fdb	0,0,0,0,0,0,0,0	;end of rom program
;
	END

