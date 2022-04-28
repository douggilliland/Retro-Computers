*	TTL	(C) 1980 TALBOT MICROSYSTEMS
*	TTL	68'FORTH for 6809 : FIG MODEL
	OPT	l
	opt	bin
	opt	s19
*
*
** FORTH FOR 6809                by R. J. Talbot, Jr.             80.03.20
*
*** TALBOT MICROSYSTEMS
***
***
***
*  This version of FORTH follows the model created by the
*     The FORTH Interest Group (FIG) 
*   PO Box 1105,     San  Carlos, CA  94070 
*               (415)  962-8653
*  The model is described in a docunent which may be obtained from 
*  them for $15.00 entitled   "fig-FORTH Installation Manual" 
*
*  This version was developed for a SWTPC 6809 system with FLEX, but  
*  all terminal I/O is done by internal code, so it is independent
*  of the rom monitor or operating system such as FLEX. 
*  The only systm dependent terminal I/O code which might need
*  changing is the location of the control ACIA port in memory 
*  space  - -  the present assignment is to E004 and the data word is
*  the control address + 1. 
* 
*  All terminal I/O is done in three assembly language subroutines:
*     PEMIT - emits a character to terminal
*     PKEY - reads a character from terminal ( no echo) 
*     PQTERM - tests terminal for a character having been typed
* 
*  The FORTH words for disk I/O follows the model of the FORTH
*  Interest Group - there are both a RAM simulation of disk I/O and real
*  disk I/O of standard FORTH SCREENS.  Also, there is an interface
*  which allows input or output using DOS format TXT files, and
*  there is a link to the DOS command structure so that
*  DOS comnands may be executed from FORTH, including read into
*  or write from RAM simulated disk using TAPE or DISK SAVE or LOAD.
*  This 68'FORTH Vers 1.1 assembled machine code program is available on
*  a FLEX 9.0 soft-sectored 5-1/4" diskette or
*  on a 300 baud KCS cassette from TALBOT  MICROSYSTEMS.
*  The  cassette version may be used in conjunction with the
*  RAM simulation of disk to inplement a cassette-only version or to
*  modify the DOS interface to something other than FLEX.
* 
*  Advanced versions are available (  in
*  diskette form only) which contains a full 6809 assembler in FORTH,
*  a screen oriented FORTH source text editor, and many other
*  useful vocabularies -- contact TALEOT Microsystems.
* 
*  This assembly source code is available ( on FLEX 9.0 soft sectored
*  5 1/4" diskette only) -- contact TALBOT Microsystems.
*
* 
	PAG

*                  MEMORY MAP
* addr              contents                    pointer     init by
* ****   ***********************************    ****        ******
* 0100   COLD start entry point
* 0103   Warm start entry point  
* 
* 0106   start of FORTH KERNEL
*        COLD startup parameters, WARM startup parameters
*        common system variables
*        start of FORTH code
*                             register Y         <== IP     ABRT
*                (W = X after LDX ,Y++ at NEXT)  <== W 
* 
* 1FEF   end of FORTH KERNAL      dict links to FORTH  further up.
* 2400 -NBLK*(BUFSIZ+4)                                      FIRST, VIRBGN 
*      NBLK buffer sectors of VIRTUAL MEMORY
*      initialized with NBLK=4 so  VIRBGN = 1BF0
* 2400                                                      VIREND
*        registers and pointers for FORTH 
* 2420   USER #1 table of variables              <== UP     UPINT
* 2450   "FORTH"  ( a word )            <=       <== CONTEXT
*                                         `========= CURRENT 
* 247E   "TASK" ( a word marking end of dict.)
* 2xxx                                           <== DP     DPINIT
* 2xxx   dictionary grows |
*                     up  |
*                         | 
*                     towards higher menory
*                         | 
*                     towards lower memory
*                   down  |
* 3330   DATA stack grows |      register U      <== SP     SPO, SPINIT
* 3330                                           <== IN     TIB
*            INPUT LINE BUFFER
*            holds up to 132 characters and
*            is scanned upward by IN starting at TIB
* 2FB4
* 3400   RETURN stack base       register S      <==  RP    RINIT
*                                                           LO,DSMBGN
*        space to simulate a disk mass memory
* 4400                                                      HI,MEMTOP
*                                                           TOPMEM
	PAG

NBLK	equ	2	; # of disc buffer blocks for virtual memory 
BUFSIZ	EQU	512	; # of bytes per disk sector
PRGBGN	EQU	$0100	; beginning of FORTH program, COLD entry point,
			; WARM entry point is PRGBGN + 3
BUFPLU	equ	BUFSIZ+4
VIRSIZ	equ	NBLK*BUFPLU
VIREND	EQU	$2400	; end of virtual memory buffers
VIRBGN	equ	VIREND-VIRSIZ	; assigns space for 4 BUFFERS
* each block is BUFSIZ+4 bytes in size, holding BUFSIZ characters
*     plus 4 bytes of control info
USRBGN 	EQU	$2400	; beginning of user space
USREND	EQU	$3400	; end of user space, above is for disc sim
DSMBGN	EQU	$3400	; begin of space available for disc simulation
DSMEND	EQU	$4400	; end of memory available for disc simulation  
MEMEND	EQU	DSMBGN
MEMTOP	EQU	DSMEND 

	PAG

*** * * * 
*  CONVENTIONS USED IN THIS PROGRAM ARE -
* 
*  IP   = register Y points towards the next word to execute
*  SP   = register U points to LAST BYTE on the data stack
*  RP   = register S points to LAST WORD on return stack
*         register X is used as a general index register for pointing
*                at things. For some indexing purposes, Y, U, or S are
*                saved so X and Y, U, or S may be used at same time.
*  W     upon entry to a word, X = W = location of word containing
*        address of code to execute. 
*
*
*   When A and B are used seperately, in order to maintain compatibility
*   with D register, A contains high byte, B the low byte.
* 
*** * * *
 

********* MACRO for creating dictionary headers  ********* 
;LASTNM	SET	0
* 
;WORDM	MACRO
;NEXTNM	SET	* 
;	IFC	&4,IMMEDIAT
;	FCB	&l+$CO
* 1st byte is no of char with sign and immed bit on if IMMEDIATE
;	ELSE 
;	FCB 	&1+$80
;	ENDIF 
;	IFNC	&l,l
;	FCC	`&2` 
;	ENDIF
*  if more than one char, then all but last in here  
*  then last has sign bit set
;	FCB	$50+'&3 
;	FDB 	LASTNM
;LASTNM	SET	NEXTNM 
;	IFC	&5,USER
;&6	FDB	DOUSER	; TSC assembler gives error message -- IGNOREE 
;*** ILLEGAL LABEL
;	FDB	&7-UORIG 
;	ENDIF
;	ENDM 

	PAG

	ORG	USRBGN	; variables
N	RMB	10	; used as scratch  
UP	RMB	2	; the pointer to base of current user's
*                             USER table ( for multi-tasking)  
* 	This system is shown for one user, but additional ones
*	may be added by allocating additional user tables and 
*	words for switching the pointer between them.
*	Alternatively, with SWTP SBUG dynmic memory assignment, it would
*	be possible to have a memory management procedure in KERNAL which
*	switches various USER 4k blocks in and out of this low space.  
*
*	Some of the next stuff is initialized during COLD and WARM starts.
*	Names correspond to FORTH words of similar (no X) name. 
*
UORIG 	RMB 	6	; 3 reserved variables
*  INIT ON COLD START
XFENCE	RMB 	2	; fence for FORGET
XDP	RMB	2	; dictionary pointer
XVOCL	RMB	2 	; vocabulary linking
XACIA	RMB	2	; address of acia port
XDELAY	RMB 	2 	; carriage return delay count (# of nulls)
XCOLUM	RMB	2	; carriage width
XBKSP	RMB	1	; backspace character
XBKSPE	RMB	1	; backspace echo
XLINDL	RMB	1	; line delete character
XLINDE	RMB	1	; line delete echo 
*  INIT BELOW ON COLD OR WARM START 
XSPZER	RMB	2	; initial top of data stack for this user
XTIB	RMB	2	; start of terminal input buffer
XRZERO	RMB	2	; initial top of return stack
XFINA	RMB	2	; address of input file FCB
XFOUTA	RMB	2	; address of output file FCB
XWIDTH  RMB	2	; name field width
XMSGBS	RMB	2	; Base  SCReen number for messages and GO
XWARN	RMB	2	; warning message node (0 = no disk)  
*  END OF INITIALIZED PARAMETERS
XBLK	FDB	0	; disc block being accessed
XIN	FDB	0	; scan pointer into the block
XOUT	FDB	2	; cursor position
XSCR	FDB	0	; disc screen being accessed (0 = terminal)
XOFSET	FDB	0	; disc sector offset for multi=disc
XCONT	FDB	TASK-7	; last word in primary search vocabulary
XCURR	FDB	TASK-7	; last word in extensible vocabulary
XSTATE	FDB 	0	; flag for 'interpret' or 'compile' modes
XBASE	FDB	10	; number base fo I/O numeric conversions
XDPL	FDB	2	; decimal point place
XFLD	FDB	0
XCSP	FDB	0	; current stack position, for compile checks
XRNUM	FDB	0
XHLD	FDB	0
IOSTAT	FDB	0	; last acia status from write/read

*  END OF USER TABLE
* 
***  Beginning of variable dictionary entries
	FCB	$C5	; 5, IMMEDIATE 
	FCC	"FORT"
	FCB	$80+'H 
	FDB 	NOOP-7	; LINK "BACK"
FORTH	FDB	DODOES,DOVOC,$81A0,TASKAA

	FDB	0
	FCC	"(C) Talbot Microsystems 1980"

TASKAA	FCB	$84
	FCC	"TAS"
	FCB	$80+'K
	FDB	FORTH-8	; link "back" to FORTH
TASK	FDB	DOCOL,SEMIS
REND	EQU	*	; (first empty location is dictionary)

	PAG

*  The FORTH program begins here;  
	ORG	PRGBGN
*  First, COLD and WARM entry points
KERNAL	LBRA	precld
	LBRA	WENT 
*************************************************** 
*	Startup parameters  *********************** 
*
CPUTYP	FDB	$6809	; cpu
VERSON	FDB	$0101	; version  wxyz print as wx.yz 
	FDB	$0000
	FCB 	20
	FCC	"R. J. TALBOT, JR.   " 

UPINIT	FDB	UORIG	; initial user area
* FOLLOWING INITIALIZED ON COLD START ONLY
FENCIN	FDB	TASKAA	; initial fence at TASK
DPINIT	FDB	REND	; cold start value for DP location in dict.
VOCINT	FDB	FORTH+8	; cold start for VOC-LINK 
ACIAI	FDB	$C400	; initial location of acia port
DELINT	FDB	8 	; initial carriage return delay 
COLINT	FDB	80	; initial terminal carriage width
BACKSP	FCB	$08	; character to indicate backspace
BACKEC	FCB	$08	; character to echo for backspace
LINDEL	FCB	$15	; character to indicate line delete
LINDEC	FCB  	$0D	; character to echo for line delete
XVIRBG	FDB	VIRBGN 
XVIRED	FDB	VIREND
XDSMBG	FDB	DSMBGN 
XDSMED	FDB	DSMEND
* END COLD START INITIALIZATION AREA
* 
* THE FOLLOWING USED TO INITIALIZE USER AREA ON WARM OR COLD START
SINIT	FDB 	USREND-$D0	; initial top of data stack
TIBINT	FDB 	USREND-$D0	; terminal input buffer  
RINIT	FDB	USREND	; initial top of return stack
FINA	FDB	0	; initialize no input file FCB
FOUTA	FDB	0	; "          no output file FCB
WIDINT	FDB	31	; init name field width 
MSGBAS	FDB 	40	; init base SCReen number for messages and GO
WRNINT	FDB	1	; init warning mode (O= no disc)
* END WARM+COLD INITIALIZATION AREA
BLKINT	FDB	0	; disc block being accessed
ININIT	FDB	0	; scan pointer into the block
OUTINT	FDB	2	; cursor position
SCRINT	FDB	0	; disc screen being accessed (0 = terminal)
OFFINT	FDB	0	; disc sector offset for multi=disc
CONTINT	FDB	TASK-7	; last word in primary search vocabulary
CURINT	FDB	TASK-7	; last word in extensible vocabulary
STAINT	FDB 	0	; flag for 'interpret' or 'compile' modes
BASINT	FDB	10	; number base fo I/O numeric conversions
DPLINT	FDB	2	; decimal point place
FLDINT	FDB	0
CSPINT	FDB	0	; current stack position, for compile checks
RNINIT	FDB	0
HLDINT	FDB	0
*
* system variables
XUSE	RMB	2 
XPREV	RMB	2

	PAG

*
* Start of FORTH Kernel
* 
PULLDX	PULU	D	; 15 cycles to NEXT
STOREX	STD	,X	; 8
;	BRA	NEXT
	ldx	,y++
	jmp	[,x]

GETX	LDD	,X	; 15 cycles to NEXT 
PUSHD	PSHU	D	; 7
;	BRA	NEXT
	ldx	,y++
	jmp	[,x]
* 
* Here is the IP pusher for allowing nested words
* ;S is the equivalent unnester
* 
;	WORDM 	1,,:,IMMEDIATE
	fcb	$c1
	fcb	$80+':
	fdb	0
COLON 	FDB 	DOCOL,QEXEC,SCSP,CURENT,AT,CONTXT,STORE 
	FDB	CREATE,RBRAK,PSCODE 
DOCOL	PSHS 	Y	; save present IP on ret stack RP
	LEAY	2,X	; kick Y up to first param after CFA in W=X 
* LBRA NEXT JUST DROP ON THROUGH TO NEXT
* 
*  NEXT takes 14 cycles
* 
****  BEGINNING OF SIMULATION OF VIRTUAL FORTH MACHINE
*
NEXT	LDX	,Y++	; get W to X and then increment Y=IP
* the address of the pointer to the present code is in X now
*  if need it at any time, it may be computed by LDX -2,Y
NEXT3	JMP	[,X]	; jump indirect to code pointed to by W
*
****  END OF SIMULATION OF THE VIRTUAL FORTH MACHINE
;	WORDM	2,;,S
	fcb	$82
	fcc	";"
	fcb	$80+'S
	fdb	COLON-4
SEMIS	FDB	*+2
PSEMIS	LDY	,S++	; reset Y=IP to next addr and drop from S=RP
;	BRA	NEXT
	ldx	,y++
	jmp	[,x]

	PAG

;	WORDM	7,EXECUT,E
	fcb	$87
	fcc	"EXECUT"
	fcb	$80+'E
	fdb	SEMIS-5
EXEC	FDB	*+2
	PULU	X	;
;	BRA	NEXT3
	jmp	[,x]

;	WORDM	3,MO,N
	fcb	$83
	fcc	"MO"
	fcb	$80+'N
	fdb	EXEC-10
MON	FDB	PMON

;	WORDM	3,JS,R
	fcb	$83
	fcc	"JS"
	fcb	$80+'R
	fdb	MON-6
JSR	FDB	*+2
	JSR	[,U++]
;	LBRA	NEXT
	ldx	,y++
	jmp	[,x]

;	WORDM	4,EMI,T
	fcb	$84
	fcc	"EMI"
	fcb	$80+'T
	fdb	JSR-6
EMIT	FDB	DOCOL,CEMIT,SEMIS

CEMIT	FDB	*+2	; this is a word with no header
	PULU	D	;
	TFR	B,A
	LBSR	PEMIT
	LDX	XOUT
	LEAX	1,X	; increment by 1
	STX	XOUT
;	LBRA	NEXT
	ldx	,y++
	jmp	[,x]

;	WORDM	3,KE,Y
	fcb	$83
	fcc	"KE"
	fcb	$80+'Y
	fdb	EMIT-7
KEY	fdb	DOCOL,CKEY,SEMIS

CKEY	fdb	*+2	; this is a word with no header
	lbsr	PKEY
	tfr	a,b
	clra
;	lbra	PUSHD
	pshu	d	;
	ldx	,y++
	jmp	[,x]

;	WORDM	9,?TERMINA,L
	fcb	$89
	fcc	"?TERMINA"
	fcb	$80+'L
	fdb	KEY-6
QTERM	fdb	*+2
	lbsr	PQTER
	tfr	a,b
	clra
;	lbra	PUSHD
	pshu	d	;
	ldx	,y++
	jmp	[,x]

;	WORDM	2,C,R
	fcb	$82
	fcc	"C"
	fcb	$80+'R
	fdb	QTERM-12
CR	fdb	DOCOL,QTERM,ZBRAN
	fdb	CR1-*
	fdb	QUIT
CR1	fdb	CLITER
	fcb	$0a
	fdb	EMIT,CLITER
	fcb	$0d	; lf
	fdb	EMIT,ZERO,OUT,STORE
	fdb	LIT,XDELAY,AT,ZBRAN
	fdb	CRE-*
	fdb	LIT,XDELAY,AT,ZERO,XDO
CR2	fdb	ZERO,EMIT,XLOOP
	fdb	CR2-*
CRE	fdb	SEMIS

IFCOLD	fcb	$ff

precld
	ldx	#BLKINT
	ldy	#XBLK
pclp
	lda	,x+
	sta	,y+
	cmpx	#HLDINT
	ble	pclp
	bra	CENT

;	WORDM	4,COL,D
	fcb	$84
	fcc	"COL"
	fcb	$80+'D
	fdb	CR-5
COLD	fdb	*+2
CENT	ldu	DPINIT	; top of destination
	ldx	#ERAM	; top of stuff to move
COLD2	lda	,-x
	sta	,-u
	cpx	#RAM
	bne	COLD2
	lda	#$ff
	sta	IFCOLD
	lds	XVIRED	; put stack somewhere safe
	ldx	XVIRED
	stx	LIMIT+2
	ldx	XVIRBG
	stx	XUSE
	stx	XPREV
	stx	FIRST+2
	lda	#0
COLD8	sta	,x+
	cmpx	XVIRED
	bne	COLD8
	sta	,x
;	ldx	XDSMED
;	stx	HI+2
;	ldx	XDSMBG
;	stx	LO+2
	ldu	#XLINDE+1
	ldx	#LINDEC+1
COLDZ	lda	,-x
	sta	,-u
	cpx	#FENCIN
	bne	COLDZ
	bra	WENT

;	WORDM	4,WAR,M
	fcb	$84
	fcc	"WAR"
	fcb	$80+'M
	fdb	COLD-7
WARM	fdb	*+2
WENT	ldu	#XWARN+2
	ldx	#WRNINT+2
WARM2	lda	,-x
	sta	,-u
	cpx	#SINIT
	bne	WARM2
	ldu	XSPZER	; U is SP
	ldx	UPINIT
	stx	UP	; init user pointer
	ldy	#ABORT+2	; Y is IP, init to first instruc in ABORT
INTSPC	nop
	nop		; here is place to jump to special
	nop		; initialization routines
	lbra	RPSTOR+2

;	WORDM	3,SP,@
	fcb	$83
	fcc	"SP"
	fcb	$80+'@
	fdb	WARM-7
SPAT	fdb	*+2
	leax	,u	; X = value of SP
	pshu	x	;
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]

;	WORDM	3,SP,!
	fcb	$83
	fcc	"SP"
	fcb	$80+'!
	fdb	SPAT-6
SPSTOR	fdb	*+2
	ldu	XSPZER
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]

;	WORDM	3,RP,!
	fcb	$83
	fcc	"RP"
	fcb	$80+'!
	fdb	SPSTOR-6
RPSTOR	fdb	*+2
	lds	XRZERO	; initialize S=RP from constant
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]

;	WORDM	3,LI,T	; NOTE: this is different from LITERAL
	fcb	$83
	fcc	"LI"
	fcb	$80+'T
	fdb	RPSTOR-6
LIT	fdb	*+2
	ldd	,Y++	; get word pointed to by Y=IP and increment
;	lbra	PUSHD	; push D to data stack and then NEXT
	pshu	d	;
	ldx	,y++
	jmp	[,x]

CLITER	fdb	*+2	; this is an invisible word with no header
	ldb	,y+
	clra
;	lbra	PUSHD
	pshu	d	;
	ldx	,y++
	jmp	[,x]

;	WORDM	6,BRANC,H
	fcb	$86
	fcc	"BRANC"
	fcb	$80+'H
	fdb	LIT-6
BRAN	fdb	ZBYES	; go steal code in ZBRANCH

;	WORDM	7,0BRANC,H
	fcb	$87
	fcc	"0BRANC"
	fcb	$80+'H
	fdb	BRAN-9
ZBRAN	fdb	*+2
	ldd	,u++	; get quantity on stack and drop it
	bne	ZBNO
ZBYES	tfr	y,d	; puts IP = Y into D for arithmetic
	addd	,y	; adds offset to which IP is pointing
	tfr	d,y	; sets new IP
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]
ZBNO	leay	2,y	; skip over branch
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]

;	WORDM	6,(LOOP,)
	fcb	$86
	fcc	"(LOOP"
	fcb	$80+')
	fdb	ZBRAN-10
XLOOP	fdb	*+2
	ldd	#1	; set inc cntr to 1 and steal other code
	bra	XPLOP2

;	WORDM	7,(+LOOP,)
	fcb	$87
	fcc	"(+LOOP"
	fcb	$80+')
	fdb	XLOOP-9
XPLOOP	fdb	*+2
	pulu	d	;
XPLOP2	tsta
	bpl	XPLOF	; forward loopint
	addd	,s	; add D to counter on RP=S
	std	,s
	andcc	#$1	; set c bit
	sbcb	3,s
	sbca	2,s
	bpl	ZBYES
	bra	XPLONO	; fall thru
XPLOF	addd	,s
	std	,s
	subd	2,s
	bmi	ZBYES
XPLONO	leas	4,s	; drop 4 bytes of counter and limit
	bra	ZBNO	; user ZBRAN to skip over unused data

;	WORDM	4,(DO,)
	fcb	$84
	fcc	"(DO"
	fcb	$80+')
	fdb	XPLOOP-10
XDO	fdb	*+2
	pulu	d	; counter
	pulu	x	; limit
	pshs	x,d	; X goes first, so becomes second on RP=S
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]

;	WORDM	1,,I
	fcb	$81
	fcb	$80+'I
	fdb	XDO-7
I	fdb	*+2
	ldd	,s	; get counter from RP
;	lbra	PUSHD
	pshu	d	;
	ldx	,y++
	jmp	[,x]

;	WORDM	1,,J
	fcb	$81
	fcb	$80+'J
	fdb	I-4
J	fdb	*+2
	ldd	4,s	; get second counter above limit for first
;	lbra	PUSHD
	pshu	d	;
	ldx	,y++
	jmp	[,x]

;	WORDM	1,,K
	fcb	$81
	fcb	$80+'K
	fdb	J-4
K	fdb	*+2
	ldd	8,s	; get third counter
;	lbra	PUSHD
	pshu	d	;
	ldx	,y++
	jmp	[,x]

;	WORDM	5,DIGI,T
	fcb	$85
	fcc	"DIGI"
	fcb	$80+'T
	fdb	K-4
DIGIT	fdb	*+2
	lda	3,u	; second item is char of interest
	suba	#$30	; ascii xero
	bmi	DIGIT2	; if less than '0', ILLEGAL
	cmpa	#$a
	bmi	DIGIT0	; if '9' or less
	cmpa	#$11
	bmi	DIGIT2	; if less than 'A'
	cmpa	#$2b
	bpl	DIGIT2	; if greater than 'Z'
	suba	#7	; traanslate 'A' thru 'Z'
DIGIT0	cmpa	1,u
	bpl	DIGIT2	; if not less than base
	ldb	#1
	sta	3,u
DIGIT1	stb	1,u	; store flag
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]
DIGIT2	clrb
	leau	2,u	; pop top off
	stb	0,u	; make sure both bytes 0
	bra	DIGIT1

;	WORDM	6,(FIND,)
	fcb	$86
	fcc	"(FIND"
	fcb	$80+')
	fdb	DIGIT-8
PFIND	fdb	*+2
PD	equ	N
PA0	equ	N+2
PA	equ	N+4
PCHR	equ	N+6
	pshs	y	; save y
PFIND0	pulu	x,y	;
	sty	PA0
*     *    *    *    *    *   x is dict ptr   y is ptr to word that finding
PFIND1	ldb	,x+	; get count from dict
	stb	PCHR
	andb	#$3f	; mask sign and precidence
	ldy	PA0
	cmpb	0,y+
	bne	PFIND4
PFIND2	lda	,y+
	tst	,x	; is dict entry neg?
	bpl	PFIND8
	ora	#$80	; make a neg also
	cmpa	,x+
	beq	FOUND
PFIND3	ldx	0,x	; get new link in dict
	bne	PFIND1	; continue if new link not = 0
*    not found :
	tfr	x,d
	bra	PFINDE
*
PFIND8	cmpa	,x+
	beq	PFIND2
PFIND4	ldb	,x+	; scan forward to end of name
	bpl	PFIND4
	bra	PFIND3
*
*  found :
FOUND	leax	4,x	; point to parameter field
	ldb	PCHR
	clra
	pshu	x,d	; x goes first
	ldb	#1
PFINDE	puls	y
;	lbra	PUSHD
	pshu	d
	ldx	,y++
	jmp	[,x]

;	WORDM	7,ENCLOS,E
	fcb	$87
	fcc	"ENCLOS"
	fcb	$80+'E
	fdb	PFIND-9
* NOTE:  FC means offset (bytes) to First Character of next word
*        EW   "     "    to End of next Word
*        NC   "     "    to Next Character to start next enclose at
ENCLOS	fdb	*+2
	pulu	d	; get char off stack to use as delim into b
	ldx	,u	; addr to begin
	clr	N
	stb	N+1	; save delim to use
*   wait for a non-delimiter or NUL
ENCL2	lda	0,x
	beq	ENCL6
	cmpa	N+1	; check for delim
	bne	ENCL3
	leax	1,x
	inc	N
	bra	ENCL2
*    found first character, push PC
ENCL3	ldb	N	; found first character
	clra
	pshu	d
*    wait for a delimiter or NUL
ENCL4	lda	,x+
	beq	ENCL7
	cmpa	N+1	; check for delim
	beq	ENCL5
	inc	N
	bra	ENCL4
*    found EW,  Push it
ENCL5	ldb	N
	clra
	pshu	d	;
* advance and push NC
	incb
;	lbra	PUSHD
	pshu	d	;
	ldx	,y++
	jmp	[,x]
* found NUL before non delimiter, therefore, no word
ENCL6	ldb	N	; a is zero
	pshu	d
	incb
	bra	ENCL7P
* found NUL following word instead of space
ENCL7	ldb	N
ENCL7P	pshu	d	; save EW
ENCL8	ldb	N	; save NC
;	lbra	PUSHD
	pshu	d	;
	ldx	,y++
	jmp	[,x]

;	WORDM	5,CMOV,E	; sourcead, destinationad, count
	fcb	$85
	fcc	"CMOV"
	fcb	$80+'E
	fdb	ENCLOS-10
CMOVE	fdb	*+2
	bsr	PCMOVE
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]
PCMOVE	pshs	x,y
	pulu	d,x,y	; D=ct, X=dest, Y=source
	pshs	u	;
	tfr	y,u
	tfr	d,y	; use y as counter
	leay	1,y
CMOV2	leay	-1,y
	beq	CMOV3
	lda	,u+
	sta 	,x+
	bra	CMOV2
CMOV3	puls	u	;
	puls	x,y	;
	rts
*
;	WORDM	2,U,*
	fcb	$82
	fcc	"U"
	fcb	$80+'*
	fdb	CMOVE-8
USTAR	fdb	*+2
	bsr	USTARS
	leau	2,u
;	lbra	PUSHD
	pshu	d	;
	ldx	,y++
	jmp	[,x]
*
* The following is a subroutine which multiplies top
* 2 words on stack, leaving 32-bit result: high order in D
* and low order word in 2ND word of stack.
USTARS	ldx	#17
	ldd	#0
USTAR2	ror	2,u	; shift mult
	ror	3,u
	leax	-1,x	; done ?
	beq	USTAR4
	bcc	USTAR3
	addd	,u
USTAR3	rora
	rorb
	bra	USTAR2
USTAR4	rts

;	WORDM	2,U,/
	fcb	$82
	fcc	"U"
	fcb	$80+'/
	fdb	USTAR-5
USLASH	fdb	*+2
	ldd	2,u
	ldx	4,u
	stx	2,u
	std	4,u
	asl	3,u
	rol	2,u
	ldx	#$10
USLL1	rol	5,u
	rol	4,u
	ldd	4,u
	subd	,u
	andcc	#$fe	; clc
	bmi	USLL2
	std	4,u
	orcc	#1	; sec
USLL2	rol	3,u
	rol	2,u
	leax	-$1,x
	bne	USLL1
	leau	2,u
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]

;	WORDM	3,AN,D
	fcb	$83
	fcc	"AN"
	fcb	$80+'D
	fdb	USLASH-5
AND	fdb	*+2
	pulu	d	;
	andb	1,u
	anda	0,u
PUTD	std	,u
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]

;	WORDM	2,O,R
	fcb	$82
	fcc	"O"
	fcb	$80+'R
	fdb	AND-6
OR	fdb	*+2
	pulu	d	;
	orb	1,u
	ora	0,u
	bra	PUTD

;	WORDM	3,XO,R
	fcb	$83
	fcc	"XO"
	fcb	$80+'R
	fdb	OR-5
XOR	fdb	*+2
	pulu	d	;
	eorb	1,u
	eora	0,u
	bra	PUTD

;	WORDM	1,,+
	fcb	$81
	fcb	$80+'+
	fdb	XOR-6
PLUS	fdb	*+2
	pulu	d	;
	addd	,u
	lbra	PUTD

;	WORDM	2,D,+
	fcb	$82
	fcc	"D"
	fcb	$80+'+
	fdb	PLUS-4
DPLUS	fdb	*+2
	ldd	2,u
	addd	6,u
	std	6,u
	ldd	,u
	adcb	5,u
	adca	4,u
	leau	4,u
	std	,u
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]

;	WORDM	5,MINU,S
	fcb	$85
	fcc	"MINU"
	fcb	$80+'S
	fdb	DPLUS-5
MINUS	fdb	*+2
	neg	1,u
	bcs	MINUS2
	neg	,u
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]
MINUS2	com	,u
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]

;	WORDM	6,DMINU,S
	fcb	$86
	fcc	"DMINU"
	fcb	$80+'S
	fdb	MINUS-8
DMINUS	fdb	*+2
	com	0,u
	com	1,u
	com	2,u
	neg	3,u
	bne	DMINX
	inc	2,u
	bne	DMINX
	inc	1,u
	bne	DMINX
	inc	,u
DMINX	;lbra	NEXT
	ldx	,y++
	jmp	[,x]

;	WORDM	2,1,+
	fcb	$82
	fcc	"1"
	fcb	$80+'+
	fdb	DMINUS-9
ONEP	fdb	*+2
	ldd	,u
	addd	#1
	lbra	PUTD

;	WORDM	2,2,+
	fcb	$82
	fcc	"2"
	fcb	$80+'+
	fdb	ONEP-5
TWOP	fdb	*+2
	ldd	#2
	addd	,u
	lbra	PUTD

;	WORDM	2,1,-
	fcb	$82
	fcc	"1"
	fcb	$80+'-
	fdb	TWOP-5
ONEM	fdb	*+2
	ldd	,u
	subd	#1
	lbra	PUTD

;	WORDM	2,2,-
	fcb	$82
	fcc	"2"
	fcb	$80+'-
	fdb	ONEM-5
TWOM	fdb	*+2
	ldd	,u
	subd	#2
	lbra	PUTD

;	WORDM	2,M,*
	fcb	$82
	fcc	"M"
	fcb	$80+'*
	fdb	TWOM-5
MSTAR	fdb	DOCOL,OVER,OVER,XOR,TOR,ABS,SWAP,ABS,USTAR
	fdb	FROMR,DSETSN,SEMIS

;	WORDM	1,,*
	fcb	$81
	fcb	$80+'*
	fdb	MSTAR-5
STAR	fdb	DOCOL,MSTAR,DROP,SEMIS

;	WORDM	2,M,/	; signed double=-3,-2,signed divisor-1
*			--> signed rem -2, quotient -1
	fcb	$82
	fcc	"M"
	fcb	$80+'/
	fdb	STAR-4
MSLASH	fdb	DOCOL,OVER,TOR,TOR,DABS,R,ABS,USLASH,FROMR,R,XOR
	fdb	SETSN,SWAP,FROMR,SETSN,SWAP,SEMIS

;	WORDM	4,/MO,D
	fcb	$84
	fcc	"/MO"
	fcb	$80+'D
	fdb	MSLASH-5
SLMOD	fdb	DOCOL,TOR,STOD,FROMR,MSLASH,SEMIS

;	WORDM	1,,/
	fcb	$81
	fcb	$80+'/
	fdb	SLMOD-7
SLASH	fdb	DOCOL,SLMOD,SWAP,DROP,SEMIS

;	WORDM	3,MO,D
	fcb	$83
	fcc	"MO"
	fcb	$80+'D
	fdb	SLASH-4
MOD	fdb	DOCOL,SLMOD,DROP,SEMIS

;	WORDM	5,*/MO,D
	fcb	$85
	fcc	"*/MO"
	fcb	$80+'D
	fdb	MOD-6
SSMOD	fdb	DOCOL,TOR,MSTAR,FROMR,MSLASH,SEMIS

;	WORDM	2,*,/
	fcb	$82
	fcc	"*"
	fcb	$80+'/
	fdb	SSMOD-8
SSLASH	fdb	DOCOL,SSMOD,SWAP,DROP,SEMIS

;	WORDM	5,M/MO,D
	fcb	$85
	fcc	"M/MO"
	fcb	$80+'D
	fdb	SSLASH-5
MSMOD	fdb	DOCOL,TOR,ZERO,R,USLASH,FROMR,SWAP,TOR
	fdb	USLASH,FROMR,SEMIS

;	WORDM	3,AB,S
	fcb	$83
	fcc	"AB"
	fcb	$80+'S
	fdb	MSMOD-8
ABS	fdb	DOCOL,DUP,ZLESS,ZBRAN
	fdb	ABS2-*
	fdb	MINUS
ABS2	fdb	SEMIS

;	WORDM	4,DAB,S
	fcb	$84
	fcc	"DAB"
	fcb	$80+'S
	fdb	ABS-6
DABS	fdb	DOCOL,DUP,ZLESS,ZBRAN
	fdb	DABS2-*
	fdb	DMINUS
DABS2	fdb	SEMIS

;	WORDM	1,,<
	fcb	$81
	fcb	$80+'<
	fdb	DABS-7
LESS	fdb	*+2
	pulu	d	;
	cmpa	0,u
	bgt	LESST
	bne	LESSF
	cmpb	1,u
	bhi	LESST
LESSF	clrb
	bra	LESSX
LESST	ldb	#1
LESSX	clra
	lbra	PUTD

;	WORDM	4,S->,D
	fcb	$84
	fcc	"S->"
	fcb	$80+'D
	fdb	LESS-4
STOD	fdb	*+2
	ldd	#0
	tst	,u
	bpl	STOD2
	coma
	comb
STOD2	std	,--u
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]

;	WORDM	2,+,-
	fcb	$82
	fcc	"+"
	fcb	$80+'-
	fdb	STOD-7
SETSN	fdb	DOCOL,ZLESS,ZBRAN
	fdb	SETSN2-*
	fdb	MINUS
SETSN2	fdb	SEMIS

;	WORDM	3,D+,-
	fcb	$83
	fcc	"D+"
	fcb	$80+'-
	fdb	SETSN-5
DSETSN	fdb	DOCOL,ZLESS,ZBRAN
	fdb	DSETS2-*
	fdb	DMINUS
DSETS2	fdb	SEMIS
	leau	2,u
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]

;	WORDM	2,0,=
	fcb	$82
	fcc	"0"
	fcb	$80+'=
	fdb	DSETSN-6
ZEQU	fdb	*+2
	clra
	clrb
	ldx	,u
	bne	ZEQU2
	incb
ZEQU2	std	,u
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]

;	WORDM	2,0,<
	fcb	$82
	fcc	"0"
	fcb	$80+'<
	fdb	ZEQU-5
ZLESS	fdb	*+2
	lda	#$80	; check sign bit
	anda	,u
	beq	ZLESS2
	clra
	ldb	#1
	lbra	PUTD
ZLESS2	clrb
	lbra	PUTD
*
;	WORDM	5,LEAV,E
	fcb	$85
	fcc	"LEAV"
	fcb	$80+'E
	fdb	ZLESS-5
LEAVE	fdb	*+2
	ldd	,s
	std	2,s
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]

;	WORDM	2,>,R
	fcb	$82
	fcc	">"
	fcb	$80+'R
	fdb	LEAVE-8
TOR	fdb	*+2
	pulu	d	;
	pshs	d	;
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]

;	WORDM	2,R,>
	fcb	$82
	fcc	"R"
	fcb	$80+'>
	fdb	TOR-5
FROMR	fdb	*+2
	puls	d	;
	pshu	d	;
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]

;	WORDM	1,,R
	fcb	$81
	fcb	$80+'R
	fdb	FROMR-5
R	fdb	I+2	; steal code from I

;	WORDM	4,OVE,R
	fcb	$84
	fcc	"OVE"
	fcb	$80+'R
	fdb	R-4
OVER	fdb	*+2
	ldd	2,u
;	lbra	PUSHD
	pshu	d	;
	ldx	,y++
	jmp	[,x]

;	WORDM	4,DRO,P
	fcb	$84
	fcc	"DRO"
	fcb	$80+'P
	fdb	OVER-7
DROP	fdb	*+2
	leau	2,u
;	lbra	next
	ldx	,y++
	jmp	[,x]

;	WORDM	4,SWA,P
	fcb	$84
	fcc	"SWA"
	fcb	$80+'P
	fdb	DROP-7
SWAP	fdb	*+2
	pulu	d,x	;
	exg	d,x	; swap order
	pshu	d,x	;
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]

;	WORDM	3,DU,P
	fcb	$83
	fcc	"DU"
	fcb	$80+'P
	fdb	SWAP-7
DUP	fdb	*+2
	ldd	,u
;	lbra	PUSHD
	pshu	d	;
	ldx	,y++
	jmp	[,x]

;	WORDM	2,+,!
	fcb	$82
	fcc	"+"
	fcb	$80+'!
	fdb	DUP-6
PSTORE	fdb	*+2
	ldx	,u++
	ldd	,u++
	addd	,x
	std	,x
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]

;	WORDM	1,,@
	fcb	$81
	fcb	$80+'@
	fdb	PSTORE-5
AT	fdb	*+2
	ldd	[,u]	; u points to address on stack, get # there
	lbra	PUTD	; replace stack add with #

;	WORDM	2,C,@
	fcb	$82
	fcc	"C"
	fcb	$80+'@
	fdb	AT-4
CAT	fdb	*+2
	ldb	[,u]
	clra
	lbra	PUTD

;	WORDM	1,,!
	fcb	$81
	fcb	$80+'!
	fdb	CAT-5
STORE	fdb	*+2
	pulu	x	;
	pulu	d	; forced to do this because in wrong order
	std	,x
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]

;	WORDM	2,C,!
	fcb	$82
	fcc	"C"
	fcb	$80+'!
	fdb	STORE-4
CSTORE	fdb	*+2
	pulu	x	;
	pulu	d	;
	stb	,x
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]

;	WORDM	7,<BUILD,S
	fcb	$87
	fcc	"<BUILD"
	fcb	$80+'S
	fdb	CSTORE-5
BUILDS	fdb	DOCOL,ZERO,CON,SEMIS

;	WORDM	5,DOES,>
	fcb	$85
	fcc	"DOES"
	fcb	$80+'>
	fdb	BUILDS-10
DOES	fdb	DOCOL,FROMR,LATEST,PFA,STORE,PSCODE
DODOES	pshs	y	; push return address to RP=S
	ldy	2,x	; get new IP
	leax	4,x	; get address of parameter
	pshu	x	;
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]

;	WORDM	6,TOGGL,E
	fcb	$86
	fcc	"TOGGL"
	fcb	$80+'E
	fdb	DOES-8
TOGGLE	fdb	DOCOL,OVER,CAT,XOR,SWAP,CSTORE,SEMIS

;	WORDM	1,,;,IMMEDIATE
	fcb	$c1
	fcb	$80+';
	fdb	TOGGLE-9
SEMI	fdb	DOCOL,QCSP,COMPIL,SEMIS,SMUDGE,LBRAK,SEMIS

;	WORDM	8,CONSTAN,T
	fcb	$88
	fcc	"CONSTAN"
	fcb	$80+'T
	fdb	SEMI-4
CON	fdb	DOCOL,CREATE,SMUDGE,COMMA,PSCODE
DOCON	ldd	2,x
;	lbra	PUSHD
	pshu	d	;
	ldx	,y++
	jmp	[,x]

PRTCON	ldd	2,x
	jsr	prthex
	tfr	b,a
	jsr	prthex
	ldd	2,x
;	lbra	PUSHD
	pshu	d	;
	ldx	,y++
	jmp	[,x]

;	WORDM	8,VARIABL,E
	fcb	$88
	fcc	"VARIABL"
	fcb	$80+'E
	fdb	CON-11
VAR	fdb	DOCOL,CON,PSCODE
DOVAR	leax	2,x	; get address after CFA in W=X
	pshu	x	;
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]

;	WORDM	1,,0
	fcb	$81
	fcb	$80+'0
	fdb	VAR-11
ZERO	fdb	DOCON
	fdb	0

;	WORDM	1,,1
	fcb	$81
	fcb	$80+'1
	fdb	ZERO-4
ONE	fdb	DOCON
	fdb	1

;	WORDM	1,,2
	fcb	$81
	fcb	$80+'2
	fdb	ONE-4
TWO	fdb	DOCON
	fdb	2

;	WORDM	1,,3
	fcb	$81
	fcb	$80+'3
	fdb	TWO-4
THREE	fdb	DOCON
	fdb	3

;	WORDM	2,B,L
	fcb	$82
	fcc	"B"
	fcb	$80+'L
	fdb	THREE-4
BL	fdb	DOCON
	fdb	$20	; ascii blank

;	WORDM	5,FIRS,T
	fcb	$85
	fcc	"FIRS"
	fcb	$80+'T
	fdb	BL-5
FIRST	fdb	DOCON
	fdb	VIRBGN

;	WORDM	5,LIMI,T
	fcb	$85
	fcc	"LIMI"
	fcb	$80+'T
	fdb	FIRST-8
LIMIT	fdb	DOCON
	fdb	VIREND
*
;	WORDM	4,USE,R
	fcb	$84
	fcc	"USE"
	fcb	$80+'R
	fdb	LIMIT-8
USER	fdb	DOCOL,CON,PSCODE
DOUSER	ldd	2,x	; gets offset to user's table
	addd	UP	; add to users base address
;	lbra	PUSHD
	pshu	d	;
	ldx	,y++
	jmp	[,x]

;	WORDM	7,+ORIGI,N
	fcb	$87
	fcc	"+ORIGI"
	fcb	$80+'N
	fdb	USER-7
PORIG	fdb	DOCOL,LIT,PRGBGN,PLUS,SEMIS

;	WORDM	2,S,0
	fcb	$82
	fcc	"S"
	fcb	$80+'0
	fdb	PORIG-10
SZERO	fdb	DOUSER
	fdb	XSPZER-UORIG

;	WORDM	2,R,0
	fcb	$82
	fcc	"R"
	fcb	$80+'0
	fdb	SZERO-5
RZERO	fdb	DOUSER
	fdb	XRZERO-UORIG

;	WORDM	3,TI,B,,USER,TIB,XTIB
	fcb	$83
	fcc	"TI"
	fcb	$80+'B
	fdb	RZERO-5
TIB	fdb	DOUSER
	fdb	XTIB-UORIG

;	WORDM	5,WIDT,H,,USER,WIDTH,XWIDTH
	fcb	$85
	fcc	"WIDT"
	fcb	$80+'H
	fdb	TIB-6
WIDTH	fdb	DOUSER
	fdb	XWIDTH-UORIG

;	WORDM	7,WARNIN,G,,USER,WARN,XWARN
	fcb 	$87
	fcc	"WARNIN"
	fcb	$80+'G
	fdb	WIDTH-8
WARN	fdb	DOUSER
	fdb	XWARN-UORIG

;	WORDM	5,FENC,E,,USER,FENCE,XFENCE
	fcb	$85
	fcc	"FENC"
	fcb	$80+'E
	fdb	WARN-10
FENCE	fdb	DOUSER
	fdb	XFENCE-UORIG

;	WORDM	2,D,P,,USER,DP,XDP
	fcb	$82
	fcc	"D"
	fcb	$80+'P
	fdb	FENCE-8
DP	fdb	DOUSER
	fdb	XDP-UORIG

;	WORDM	8,VOC-LIN,K,,USER,VOCLIN,XVOLC
	fcb	$88
	fcc	"VOC-LIN"
	fcb	$80+'K
	fdb	DP-5
VOCLIN	fdb	DOUSER
	fdb	XVOCL-UORIG

;	WORDM	3,BL,K,,USER,BLK,XBLK
	fcb	$83
	fcc	"BL"
	fcb	$80+'K
	fdb	VOCLIN-11
BLK	fdb	DOUSER
	fdb	XBLK-UORIG

;	WORDM	2,I,N,,USER,IN,XIN
	fcb	$82
	fcc	"I"
	fcb	$80+'N
	fdb	BLK-6
IN	fdb	DOUSER
	fdb	XIN-UORIG

;	WORDM	3,OU,T,,USER,OUT,XOUT
	fcb	$83
	fcc	"OU"
	fcb	$80+'T
	fdb	IN-5
OUT	fdb	DOUSER
	fdb	XOUT-UORIG

;	WORDM	3,SC,R,,USER,SCR,XSCR
	fcb	$83
	fcc	"SC"
	fcb	$80+'R
	fdb	OUT-6
SCR	fdb	DOUSER
	fdb	XSCR-UORIG

;	WORDM	6,OFFSE,T,,USER,OFSET,XOFSET
	fcb	$86
	fcc	"OFFSE"
	fcb	$80+'T
	fdb	SCR-6
OFSET	fdb	DOUSER
	fdb	XOFSET-UORIG

;	WORDM	7,CONTEX,T,,USER,CONTXT,XCONT
	fcb	$87
	fcc	"CONTEX"
	fcb	$80+'T
	fdb	OFSET-9
CONTXT	fdb	DOUSER
	fdb	XCONT-UORIG

;	WORDM	7,CURREN,T,,USER,CURENT,XCURR
	fcb	$87
	fcc	"CURREN"
	fcb	$80+'T
	fdb	CONTXT-10
CURENT	fdb	DOUSER
	fdb	XCURR-UORIG

;	WORDM	5,STAT,E,,USER,STATE,XSTATE
	fcb	$85
	fcc	"STAT"
	fcb	$80+'E
	fdb	CURENT-10
STATE	fdb	DOUSER
	fdb	XSTATE-UORIG

;	WORDM	4,BAS,E,,USER,BASE,XBASE
	fcb	$84
	fcc	"BAS"
	fcb	$80+'E
	fdb	STATE-8
BASE	fdb	DOUSER
	fdb	XBASE-UORIG

;	WORDM	3,DP,L,,USER,DPL,XDPL
	fcb	$83
	fcc	"DP"
	fcb	$80+'L
	fdb	BASE-7
DPL	fdb	DOUSER
	fdb	XDPL-UORIG

;	WORDM	3,FL,D,,USER,FLD,XDFLD
	fcb	$83
	fcc	"FL"
	fcb	$80+'D
	fdb	DPL-6
FLD	fdb	DOUSER
	fdb	XFLD-UORIG

;	WORDM	3,CS,P,,USER,CSP,XCSP
	fcb	$83
	fcc	"CS"
	fcb	$80+'P
	fdb	FLD-6
CSP	fdb	DOUSER
	fdb	XCSP-UORIG

;	WORDM	2,R,#,,USER,RNUM,XRNUM
	fcb	$82
	fcc	"R"
	fcb	$80+'#
	fdb	CSP-6
RNUM	fdb	DOUSER
	fdb	XRNUM-UORIG

;	WORDM	3,HL,D,,USER,HLD,XHLD
	fcb	$83
	fcc	"HL"
	fcb	$80+'D
	fdb	RNUM-5
HLD	fdb	DOUSER
	fdb	XHLD-UORIG

;	WORDM	7,COLUMN,S,,USER,COLUMS,XCOLUM
	fcb	$87
	fcc	"COLUMN"
	fcb	$80+'S
	fdb	HLD-6
COLUMS	fdb	DOUSER
	fdb	XCOLUM-UORIG

*
;	WORDM	4,HER,E
	fcb	$84
	fcc	"HER"
	fcb	$80+'E
	fdb	COLUMS-10
HERE	fdb	DOCOL,DP,AT,SEMIS

;	WORDM	5,ALLO,T
	fcb	$85
	fcc	"ALLO"
	fcb	$80+'T
	fdb	HERE-7
ALLOT	fdb	DOCOL,DP,PSTORE,SEMIS

;	WORDM	1,,","
	fcb	$81
	fcb	$80+',
	fdb	ALLOT-8
COMMA	fdb	DOCOL,HERE,STORE,TWO,ALLOT,SEMIS

;	WORDM	2,C,","
	fcb	$82
	fcc	"C"
	fcb	$80+',
	fdb	COMMA-4
CCOMM	fdb	DOCOL,HERE,CSTORE,ONE,ALLOT,SEMIS

;	WORDM	1,,-
	fcb	$81
	fcb	$80+'-
	fdb	CCOMM-5
SUB	fdb	DOCOL,MINUS,PLUS,SEMIS

;	WORDM	1,,=
	fcb	$81
	fcb	$80+'=
	fdb	SUB-4
EQUAL	fdb	DOCOL,SUB,ZEQU,SEMIS

;	WORDM	1,,>
	fcb	$81
	fcb	$80+'>
	fdb	EQUAL-4
GREAT	fdb	DOCOL,SWAP,LESS,SEMIS

;	WORDM	5,SPAC,E
	fcb	$85
	fcc	"SPAC"
	fcb	$80+'E
	fdb	GREAT-4
SPACE	fdb	DOCOL,BL,EMIT,SEMIS

;	WORDM	3,MI,N
	fcb	$83
	fcc	"MI"
	fcb	$80+'N
	fdb	SPACE-8
MIN	fdb	DOCOL,OVER,OVER,GREAT,ZBRAN
	fdb	MIN2-*
	fdb	SWAP
MIN2	fdb	DROP,SEMIS

;	WORDM	3,MA,X
	fcb	$83
	fcc	"MA"
	fcb	$80+'X
	fdb	MIN-6
MAX	fdb	DOCOL,OVER,OVER,LESS,ZBRAN
	fdb	MAX2-*
	fdb	SWAP
MAX2	fdb	DROP,SEMIS

;	WORDM	4,-DU,P
	fcb	$84
	fcc	"-DU"
	fcb	$80+'P
	fdb	MAX-6
DDUP	fdb	DOCOL,DUP,ZBRAN
	fdb	DDUP2-*
	fdb	DUP
DDUP2	fdb	SEMIS

;	WORDM	8,TRAVERS,E
	fcb	$88
	fcc	"TRAVERS"
	fcb	$80+'E
	fdb	DDUP-7
TRAV	fdb	DOCOL,SWAP
TRAV2	fdb	OVER,PLUS,CLITER
	fcb	$7f
	fdb	OVER,CAT,LESS,ZBRAN
	fdb	TRAV2-*
	fdb	SWAP,DROP,SEMIS

;	WORDM	6,LATES,T
	fcb	$86
	fcc	"LATES"
	fcb	$80+'T
	fdb	TRAV-11
LATEST	fdb	DOCOL,CURENT,AT,AT,SEMIS

;	WORDM	3,LF,A
	fcb	$83
	fcc	"LF"
	fcb	$80+'A
	fdb	LATEST-9
LFA	fdb	DOCOL,CLITER
	fcb	4
	fdb	SUB,SEMIS

;	WORDM	3,CF,A
	fcb	$83
	fcc	"CF"
	fcb	$80+'A
	fdb	LFA-6
CFA	fdb	DOCOL,TWO,SUB,SEMIS

;	WORDM	3,NF,A
	fcb	$83
	fcc	"NF"
	fcb	$80+'A
	fdb	CFA-6
NFA	fdb	DOCOL,CLITER
	fcb	5
	fdb	SUB,ONE,MINUS,TRAV,SEMIS

;	WORDM	3,PF,A
	fcb	$83
	fcc	"PF"
	fcb	$80+'A
	fdb	NFA-6
PFA	fdb	DOCOL,ONE,TRAV,CLITER
	fcb	5
	fdb	PLUS,SEMIS

;	WORDM	4,!CS,P
	fcb	$84
	fcc	"!CS"
	fcb	$80+'P
	fdb	PFA-6
SCSP	fdb	DOCOL,SPAT,CSP,STORE,SEMIS

;	WORDM	6,?ERRO,R
	fcb	$86
	fcc	"?ERRO"
	fcb	$80+'R
	fdb	SCSP-7
QERR	fdb	DOCOL,SWAP,ZBRAN
	fdb	QERR2-*
	fdb	ERROR,BRAN
	fdb	QERR3-*
QERR2	fdb	DROP
QERR3	fdb	SEMIS

;	WORDM	5,?COM,P
	fcb	$85
	fcc	"?COM"
	fcb	$80+'P
	fdb	QERR-9
QCOMP	fdb	DOCOL,STATE,AT,ZEQU,CLITER
	fcb	$11
	fdb	QERR,SEMIS

;	WORDM	5,?EXE,C
	fcb	$85
	fcc	"?EXE"
	fcb	$80+'C
	fdb	QCOMP-8
QEXEC	fdb	DOCOL,STATE,AT,CLITER
	fcb	$12
	fdb	QERR,SEMIS

;	WORDM	6,?PAIR,S
	fcb	$86
	fcc	"?PAIR"
	fcb	$80+'S
	fdb	QEXEC-8
QPAIRS	fdb	DOCOL,SUB,CLITER
	fcb	$13
	fdb	QERR,SEMIS

;	WORDM	4,?CS,P
	fcb	$84
	fcc	"?CS"
	fcb	$80+'P
	fdb	QPAIRS-9
QCSP	fdb	DOCOL,SPAT,CSP,AT,SUB,CLITER
	fcb	$14
	fdb	QERR,SEMIS

;	WORDM	8,?LOADIN,G
	fcb	$88
	fcc	"?LOADIN"
	fcb	$80+'G
	fdb	QCSP-7
QLOAD	fdb	DOCOL,BLK,AT,ZEQU,CLITER
	fcb	$16
	fdb	QERR,SEMIS

;	WORDM	7,COMPIL,E
	fcb	$87
	fcc	"COMPIL"
	fcb	$80+'E
	fdb	QLOAD-11
COMPIL	fdb	DOCOL,QCOMP,FROMR,DUP,TWOP,TOR,AT,COMMA,SEMIS

;	WORDM	1,,[,IMMEDIATE
	fdb	$c1
	fcb	$80+'[
	fdb	COMPIL-10
LBRAK	fdb	DOCOL,ZERO,STATE,STORE,SEMIS

;	WORDM	1,,],NOIM
	fcb	$81
	fcb	$80+']
	fdb	LBRAK-4
RBRAK	fdb	DOCOL,CLITER
	fcb	$c0
	fdb	STATE,STORE,SEMIS

;	WORDM	6,SMUDG,E
	fcb	$86
	fcc	"SMUDG"
	fcb	$80+'E
	fdb	RBRAK-4
SMUDGE	fdb	DOCOL,LATEST,CLITER
	fcb	$20
	fdb	TOGGLE,SEMIS

;	WORDM	3,HE,X
	fcb	$83
	fcc	"HE"
	fcb	$80+'X
	fdb	SMUDGE-9
HEX	fdb	DOCOL,CLITER
	fcb	16
	fdb	BASE,STORE,SEMIS

;	WORDM	7,DECIMA,L
	fcb	$87
	fcc	"DECIMA"
	fcb	$80+'L
	fdb	HEX-6
DEC	fdb	DOCOL,CLITER
	fcb	10
	fdb	BASE,STORE,SEMIS

;	WORDM	7,(;CODE,)
	fcb	$87
	fcc	"(;CODE"
	fcb	$80+')
	fdb	DEC-10
PSCODE	fdb	DOCOL,FROMR,LATEST,PFA,CFA,STORE,SEMIS

;	WORDM	5,;COD,E,IMMEDIATE
	fcb	$c5
	fcc	";COD"
	fcb	$80+'E
	fdb	PSCODE-10
SEMIC	fdb	DOCOL,QCSP,COMPIL,PSCODE,SMUDGE,LBRAK,QSTACK,SEMIS
*  NOTE: QSTACK is replaced by ASSEMBLER in versions with one.

;	WORDM	5,COUN,T,NOIM
	fcb	$85
	fcc	"COUN"
	fcb	$80+'T
	fdb	SEMIC-8
COUNT	fdb	DOCOL,DUP,ONEP,SWAP,CAT,SEMIS

;	WORDM	4,TYP,E
	fcb	$84
	fcc	"TYP"
	fcb	$80+'E
	fdb	COUNT-8
TYPE	fdb	DOCOL,DDUP,ZBRAN
	fdb	TYPE3-*
	fdb	OVER,PLUS,SWAP,XDO
TYPE2	fdb	I,CAT,EMIT,XLOOP
	fdb	TYPE2-*
	fdb	BRAN
	fdb	TYPE4-*
TYPE3	fdb	DROP
TYPE4	fdb	SEMIS

PRTHEX	fdb	*+2
	ldd	,u++
	jsr	prthex
	tfr	b,a
	jsr	prthex
	ldx	,y++
	jmp	[,x]
	

;	WORDM	9,-TRAILIN,G
	fcb	$89
	fcc	"-TRAILIN"
	fcb	$80+'G
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

	fcb	$c1
	fcb	$80+'"
	fdb	DTRAIL-12
QUOTE	fdb	DOCOL,CLITER
	fcb	$22	; quote
	fdb	STATE,AT,ZBRAN
	fdb	QUOTE1-*
	fdb	COMPIL,PQUOTE,WORD,HERE,CAT,ONEP,ALLOT,BRAN
	fdb	QUOTE2-*
QUOTE1	fdb	WORD,HERE,HERE,CAT,ONEP,PAD,SWAP,CMOVE,PAD
QUOTE2	fdb	SEMIS

	fcb	$83
	fcc	/("/
	fcb	$80+')
	fdb	QUOTE-4
PQUOTE	fdb	DOCOL,R,DUP,CAT,ONEP,FROMR,PLUS,TOR,SEMIS

	fcb	$84
	fcc	/(."/
	fcb	$80+')
	fdb	PQUOTE-6
PDOTQ	fdb 	DOCOL,R,COUNT,DUP,ONEP,FROMR,PLUS,TOR,TYPE,SEMIS

	fcb	$c2	; IMMEDIATE
	fcb	'.
	fcb	$80+'"
	fdb	PDOTQ-7
DOTQ	fdb	DOCOL,CLITER
	fcb	$22	; quote
	fdb	STATE,AT,ZBRAN
	fdb	DOTQ1-*
	fdb	COMPIL,PDOTQ,WORD,HERE,CAT,ONEP,ALLOT,BRAN
	fdb	DOTQ2-*
DOTQ1	fdb	WORD,HERE,COUNT,TYPE
DOTQ2	fdb	SEMIS

;	WORDM	6,?STAC,K	; machine dependent
	fcb	$86
	fcc	"?STAC"
	fcb	$80+'K
	fdb	DOTQ-5
QSTACK	fdb	DOCOL,LIT
	fdb	SINIT-PRGBGN
	fdb	PORIG,AT,SPAT,LESS,ONE,QERR
QSTAC2	fdb	SPAT
	fdb	HERE,CLITER
	fcb	$80	; want 128 spaces higher than dict
	fdb	PLUS,LESS
	fdb	TWO,QERR	; full stack
QSTAC3	fdb	SEMIS

* WORDM	5,?FRE,E is done by ?STACK in this version
*QFREE fdb  DOCOL,SPAT,HERE,CLITER
* fcb	$80
* fdb	PLUS,LESS,TWO,QERR,SEMIS

;	WORDM	3,RO,T
	fcb	$83
	fcc	"RO"
	fcb	$80+'T
	fdb	QSTACK-9
ROT	fdb	DOCOL,TOR,SWAP,FROMR,SWAP,SEMIS

;	WORDM	6,EXPEC,T
	fcb	$86
	fcc	"EXPEC"
	fcb	$80+'T
	fdb	ROT-6
EXPECT	fdb	DOCOL,OVER,PLUS,OVER,XDO
EXPEC2	fdb	KEY,DUP,LIT
	fdb	XLINDL,CAT,EQUAL,ZBRAN
	fdb	EXPECZ-*
	fdb	DROP,LIT,XLINDE,CAT,FROMR,DROP,OVER,ONEM,TOR,BRAN
	fdb	EXPEC6-*
EXPECZ	fdb	DUP,LIT,XBKSP,CAT
	fdb	EQUAL,ZBRAN
	fdb	EXPEC3-*
	fdb	DROP,LIT
	fdb	XBKSPE,CAT
	fdb	OVER,I,EQUAL,DUP,FROMR,TWO,SUB,PLUS,TOR,SUB,BRAN
	fdb	EXPEC6-*
EXPEC3	fdb	DUP,CLITER
	fcb	$d	; (CR)
	fdb	EQUAL,ZBRAN
	fdb	EXPEC4-*
	fdb	LEAVE,DROP,BL,ZERO,BRAN
	fdb	EXPEC5-*
EXPEC4	fdb	DUP
EXPEC5	fdb	I,CSTORE,ZERO,I,ONEP,STORE
EXPEC6	fdb	EMIT,XLOOP
	fdb	EXPEC2-*
	fdb	DROP,SEMIS

;	WORDM	5,QUER,Y
	fcb	$85
	fcc	"QUER"
	fcb	$80+'Y
	fdb	EXPECT-9
QUERY	fdb	DOCOL,TIB,AT,COLUMS,AT,EXPECT,ZERO,IN,STORE,SEMIS

	fcb	$c1	; IMMEDIATE
	fcb	$80	; ( NULL)
	fdb	QUERY-8
NULL	fdb	DOCOL,BLK,AT,ZBRAN
	fdb	NULL2-*
	fdb	ONE,BLK,PSTORE,ZERO,IN,STORE,BLK,AT,BSCR,MOD,ZEQU
* check for end of screen
	fdb	ZBRAN
	fdb	NULL1-*
	fdb	QEXEC,FROMR,DROP
NULL1	fdb	BRAN
	fdb	NULL3-*
NULL2	fdb	FROMR,DROP
NULL3	fdb	SEMIS

;	WORDM	4,FIL,L
	fcb	$84
	fcc	"FIL"
	fcb	$80+'L
	fdb	NULL-4
FILL	fdb	DOCOL,SWAP,TOR,OVER,CSTORE,DUP,ONEP,FROMR,ONE
	fdb	SUB,CMOVE,SEMIS

;	WORDM	5,ERAS,E
	fcb	$85
	fcc	"ERAS"
	fcb	$80+'E
	fdb	FILL-7
ERASE	fdb	DOCOL,ZERO,FILL,SEMIS

;	WORDM	6,BLANK,S
	fcb	$86
	fcc	"BLANK"
	fcb	$80+'S
	fdb	ERASE-8
BLANKS	fdb	DOCOL,BL,FILL,SEMIS

;	WORDM	4,HOL,D
	fcb	$84
	fcc	"HOL"
	fcb	$80+'D
	fdb	BLANKS-9
HOLD	fdb	DOCOL,LIT,$FFFF,HLD,PSTORE,HLD,AT,CSTORE,SEMIS

;	WORDM	3,PA,D
	fcb	$83
	fcc	"PA"
	fcb	$80+'D
	fdb	HOLD-7
PAD	fdb	DOCOL,HERE,CLITER
	fcb	$44
	fdb	PLUS,SEMIS

;	WORDM	4,WOR,D
	fcb	$84
	fcc	"WOR"
	fcb	$80+'D
	fdb	PAD-6
WORD	fdb	DOCOL,BLK,AT,ZBRAN
	fdb	WORD2-*
	fdb	BLK,AT,BLOCK,BRAN
	fdb	WORD3-*
WORD2	fdb	TIB,AT
WORD3	fdb	IN,AT,PLUS,SWAP,ENCLOS,HERE,CLITER
	fcb	34
	fdb	BLANKS,IN,PSTORE,OVER,SUB,TOR,R,HERE,CSTORE,PLUS
	fdb	HERE,ONEP,FROMR,CMOVE,SEMIS

;	WORDM	8,(NUMBER,)
	fcb	$88
	fcc	"(NUMBER"
	fcb	$80+')
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
PNUMB4	fdb	FROMR,SEMIS

;	WORDM	6,NUMBE,R
	fcb	$86
	fcc	"NUMBE"
	fcb	$80+'R
	fdb	PNUMB-11
NUMB	fdb	DOCOL,ZERO,ZERO,ROT,DUP,ONEP,CAT,CLITER
	fcb	'-	; minus sign
	fdb	EQUAL,DUP,TOR,PLUS,LIT,$FFFF
NUMB1	fdb	DPL,STORE,PNUMB,DUP,CAT,BL,SUB,ZBRAN
	fdb	NUMB2-*
	fdb	DUP,CAT,CLITER
	fcb	'.
	fdb	SUB,ZERO,QERR,ZERO,BRAN
	fdb	NUMB1-*
NUMB2	fdb	DROP,FROMR,ZBRAN
	fdb	NUMB3-*
	fdb	DMINUS
NUMB3	fdb	SEMIS

;	WORDM	5,-FIN,D
	fcb	$85
	fcc	"-FIN"
	fcb	$80+'D
	fdb	NUMB-9
DFIND	fdb	DOCOL,BL,WORD,HERE,CONTXT,AT,AT,PFIND,DUP,ZEQU,ZBRAN
	fdb	DFIND2-*
	fdb	DROP,HERE,LATEST,PFIND
DFIND2	fdb	SEMIS

;	WORDM	7,(ABORT,)
	fcb	$87
	fcc	"(ABORT"
	fcb	$80+')
	fdb	DFIND-8
PABORT	fdb	DOCOL,ABORT,SEMIS

;	WORDM	5,ERRO,R
	fcb	$85
	fcc	"ERRO"
	fcb	$80+'R
	fdb	PABORT-10
ERROR	fdb	DOCOL,WARN,AT,ZLESS,ZBRAN
* WARNING is -1 to abort, 0 to print error #, and >1 to print
*	error message from the message SCReen on disk
	fdb	ERROR2-*
	fdb	PABORT
ERROR2	fdb	HERE,COUNT,TYPE,PDOTQ
	fcb	4,7	; (BELL)
	fcc	" ? "
	fdb	MESS,SPSTOR,IN,AT,BLK,AT,QUIT,SEMIS

;	WORDM	3,ID,.
	fcb	$83
	fcc	"ID"
	fcb	$80+'.
	fdb	ERROR-8
IDDOT	fdb	DOCOL,PAD,CLITER
	fcb	32
	fdb	CLITER
	fcb	$5f
	fdb	FILL,DUP,PFA,LFA,OVER,SUB,PAD,SWAP,CMOVE
	fdb	PAD,COUNT,CLITER
	fcb	31
	fdb	AND,TYPE,SPACE,SEMIS

;	WORDM	6,CREAT,E
	fcb	$86
	fcc	"CREAT"
	fcb	$80+'E
	fdb	IDDOT-6
CREATE	fdb	DOCOL,DFIND,ZBRAN
	fdb	CREAT2-*
	fdb	DROP,PDOTQ
	fcb	8,7	; (BELL)
	fcc	"redef: "
	fdb	NFA,IDDOT,CLITER
	fcb	4
	fdb	MESS,SPACE
CREAT2	fdb	HERE,DUP,CAT,WIDTH,AT,MIN,ONEP,ALLOT,DUP,CLITER
	fcb	$a0
	fdb	TOGGLE,HERE,ONE,SUB,CLITER
	fcb	$80
	fdb	TOGGLE,LATEST,COMMA,CURENT,AT,STORE,HERE,TWOP
	fdb	COMMA,SEMIS

;	WORDM	9,[COMPILE,],IMMEDIATE
	fcb	$89
	fcc	"[COMPILE"
	fcb	$80+']
	fdb	CREATE-9
BCOMP	fdb	DOCOL,DFIND,ZEQU,ZERO,QERR,DROP,CFA,COMMA,SEMIS

;	WORDM	7,LITERA,L,IMMEDIATE
	fcb	$c7
	fcc	"LITERA"
	fcb	$80+'L
	fdb	BCOMP-12
LITER	fdb	DOCOL,STATE,AT,ZBRAN
	fdb	LITER2-*
	fdb	COMPIL,LIT,COMMA
LITER2	fdb	SEMIS

;	WORDM	8,DLITERA,L,IMMEDIATE
	fcb	$c8
	fcc	"DLITERA"
	fcb	$80+'L
	fdb	LITER-10
DLITER	fdb	DOCOL,STATE,AT,ZBRAN
	fdb	DLITE2-*
	fdb	SWAP,LITER,LITER
DLITE2	fdb	SEMIS

;	WORDM	9,INTERPRE,T,NOIM
	fcb	$89
	fcc	"INTERPRE"
	fcb	$80+'T
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
INTER4	fdb	QSTACK,BRAN
	fdb	INTER7-*
INTER5	fdb	HERE,NUMB,DPL,AT,ONEP,ZBRAN
	fdb	INTER6-*
	fdb	DLITER,BRAN
	fdb	INTER7-*
INTER6	fdb	DROP,LITER
INTER7	fdb	QSTACK,BRAN
	fdb	INTER2-*
* fdb SEMIS never execute

;	WORDM	9,IMMEDIAT,E
	fcb	$89
	fcc	"IMMEDIAT"
	fcb	$80+'E
	fdb	INTERP-12
IMMED	fdb	DOCOL,LATEST,CLITER
	fcb	$40
	fdb	TOGGLE,SEMIS

;	WORDM	10,VOCABULAR,Y
	fcb	$8a
	fcc	"VOCABULAR"
	fcb	$80+'Y
	fdb	IMMED-12
VOCAB	fdb	DOCOL,BUILDS,LIT,$81a0,COMMA,CURENT,AT,CFA,COMMA
	fdb	HERE,VOCLIN,AT,COMMA,VOCLIN,STORE,DOES
DOVOC	fdb	TWOP,CONTXT,STORE,SEMIS
	fdb	0

;	WORDM	11,DEFINITION,S
	fcb	$8b
	fcc	"DEFINITION"
	fcb	$80+'S
	fdb	VOCAB-13
DEFIN	fdb	DOCOL,CONTXT,AT,CURENT,STORE,SEMIS

;	WORDM	1,,(,IMMEDIATE
	fcb	$c1
	fcb	$80+'(
	fdb	DEFIN-14
PAREN	fdb	DOCOL,CLITER
	fcb	')
	fdb	WORD,SEMIS

CON1	fdb	PRTCON
	fdb	1
CON3	fdb	PRTCON
	fdb	3

;	WORDM	4,QUI,T,NOIM
	fcb	$84
	fcc	"QUI"
	fcb	$80+'T
	fdb	PAREN-4
QUIT	fdb	DOCOL,ZERO,BLK,STORE,LBRAK
* Here is outer interpreter which gets line of input, does it, and
* then prints " OK" and repeats.
QUIT2	fdb	RPSTOR,CR,QUERY,INTERP,STATE,AT,ZEQU,ZBRAN
	fdb	QUIT3-*
	fdb	PDOTQ
	fcb	3
	fcc	" OK"
QUIT3	fdb	BRAN
	fdb	QUIT2-*
* fdb SEMIS never executed

;	WORDM	5,ABOR,T
	fcb	$85
	fcc	"ABOR"
	fcb	$80+'T
	fdb	QUIT-7
ABORT	fdb	DOCOL,SPSTOR,DEC,DRZERO,CR,PDOTQ
	fcb	18
	fcc	"68'FORTH-09 VERS #"
	fdb	LIT,VERSON,DUP,CAT,DOT,PDOTQ
	fcb	1
	fcb	'.
	fdb	ONEP,CAT,DOT
	fdb	ZERO,IN,STORE,ZERO,BLK,STORE
	fdb	FORTH,DEFIN,LIT,IFCOLD,CAT,ZBRAN
	fdb	ABORTC-*
	fdb	ZERO,LIT,IFCOLD,CSTORE,GO
ABORTC	fdb	QUIT
* fdb SEMIS never executed

;	WORDM	2,G,O
	fcb	$82
	fcc	"G"
	fcb	$80+'O
	fdb	ABORT-8
GO	fdb	DOCOL,LIT,XMSGBS,AT,THREE,PLUS,DRZERO,LOAD,SEMIS

	pag

*
* Here is stuff which gets copied to ram in user space
RAM	fcb	$c5	; 5, IMMEDIATE
	fcc	"FORT"
	fcb	$80+'H
	fdb	NOOP-7	; link "back"
RFORTH	fdb	DODOES,DOVOC,$81a0,TASK-7
	fdb	0
	fcc	"(C) Talbot Microsystems 1980"

	fcb	$84
	fcc	"TAS"
	fcb	$80+'K
	fdb	FORTH-8	; link "back" to FORTH
RTASK	fdb	DOCOL,SEMIS
ERAM	fcc	"R. J. Talbot, Jr."

	pag

*
* Disc primitives :
;	WORDM	3,US,E
	fcb	$83
	fcc	"US"
	fcb	$80+'E
	fdb	GO-5
USE	fdb	DOCON,XUSE

;	WORDM	4,PRE,V
	fcb	$84
	fcc	"PRE"
	fcb	$80+'V
	fdb	USE-6
PREV	fdb	DOCON,XPREV

;	WORDM	4,+BU,F
	fcb	$84
	fcc	"+BU"
	fcb	$80+'F
	fdb	PREV-7
PBUF	fdb	DOCOL,BBUF
	fdb	CLITER
	fcb	4
	fdb	PLUS
	fdb	PLUS,DUP,BBUF,PLUS,CLITER
	fcb	4
	fdb	PLUS,LIMIT,GREAT,ZBRAN
	fdb	PBUF2-*
	fdb	DROP,FIRST
PBUF2	fdb	DUP,PREV,AT,SUB,SEMIS

;	WORDM	6,UPDAT,E
	fcb	$86
	fcc	"UPDAT"
	fcb	$80+'E
	fdb	PBUF-7
UPDATE	fdb	DOCOL,PREV,AT,AT,LIT,$8000,OR,PREV,AT,STORE,SEMIS

;	WORDM	13,EMPTY-BUFFER,S
	fcb	$8d
	fcc	"EMPTY-BUFFER"
	fcb	$80+'S
	fdb	UPDATE-9
MTBUF	fdb	DOCOL,FIRST,LIMIT,OVER,SUB,ERASE,SEMIS

;	WORDM	6,BUFFE,R
	fcb	$86
	fcc	"BUFFE"
	fcb	$80+'R
	fdb	MTBUF-16
BUFFER	fdb	DOCOL,USE,AT,DUP,TOR
BUFFR2	fdb	PBUF,ZBRAN
	fdb	BUFFR2-*
	fdb	USE,STORE,R,AT,ZLESS,ZBRAN
	fdb	BUFFR3-*
	fdb	R,TWOP,R,AT,LIT,$7fff,AND,ZERO,RW
BUFFR3	fdb	R,STORE,R,PREV,STORE,FROMR,TWOP,SEMIS

;	WORDM	5,BLOC,K
	fcb	$85
	fcc	"BLOC"
	fcb	$80+'K
	fdb	BUFFER-9
BLOCK	fdb	DOCOL,OFSET,AT,PLUS,TOR,PREV,AT,DUP,AT,R,SUB
	fdb	DUP,PLUS,ZBRAN
	fdb	BLOCK5-*
BLOCK3	fdb	PBUF,ZEQU,ZBRAN
	fdb	BLOCK4-*
	fdb	DROP,R,BUFFER,DUP,R,ONE,RW,TWO,SUB
BLOCK4	fdb	DUP,AT,R,SUB,DUP,PLUS,ZEQU,ZBRAN
	fdb	BLOCK3-*
	fdb	DUP,PREV,STORE
BLOCK5	fdb	FROMR,DROP,TWOP,SEMIS

;	WORDM	5,FLUS,H
	fcb	$85
	fcc	"FLUS"
	fcb	$80+'H
	fdb	BLOCK-8
FLUSH	fdb	DOCOL,LIMIT,FIRST,SUB,BBUF,CLITER
	fcb	$04
	fdb	PLUS,SLASH,ZERO,XDO
FLUSH1	fdb	LIT
	fdb	$7fff
	fdb	BUFFER,DROP
	fdb	XLOOP
	fdb	FLUSH1-*
	fdb	SEMIS

;	WORDM	6,(LINE,)
	fcb	$86
	fcc	"(LINE"
	fcb	$80+')
	fdb	FLUSH-8
PLINE	fdb	DOCOL,TOR,CLITER
	fcb	$40
	fdb	BBUF,SSMOD,FROMR,SCRBLK,PLUS,BLOCK,PLUS,CLITER
	fcb	$40
	fdb	SEMIS

;	WORDM	5,.LIN,E
	fcb	$85
	fcc	".LIN"
	fcb	$80+'E
	fdb	PLINE-9
DLINE	fdb	DOCOL,PLINE,DTRAIL,TYPE,SEMIS

;	WORDM	7,MESSAG,E
	fcb	$87
	fcc	"MESSAG"
	fcb	$80+'E
	fdb	DLINE-8
MESS	fdb	DOCOL,WARN,AT,ZBRAN
	fdb	MESS3-*
	fdb	DDUP,ZBRAN
	fdb	MESS4-*
	fdb	LIT,XMSGBS,AT
	fdb	OFSET,AT,TOR,ZERO,OFSET,STORE,DLINE,FROMR,OFSET,STORE
	fdb	CR,BRAN
	fdb	MESS4-*
MESS3	fdb	PDOTQ
	fcb	4
	fcc	"err "
	fdb	CLITER
	fcb	'#
	fcb	10	; DECIMAL
	fdb	EQUAL,ZEQU,PLUS	; if =10, add 0, if =16 add 1 to MAKE '$
	fdb	EMIT,SPACE
	fdb	DOT
MESS4	fdb	SEMIS

;	WORDM	4,LOA,D	; input: scr #
	fcb	$84
	fcc	"LOA"
	fcb	$80+'D
	fdb	MESS-10
LOAD	fdb	DOCOL,BLK,AT,TOR,IN,AT,TOR,ZERO,IN,STORE,SCRBLK,BLK
	fdb	STORE,INTERP,FROMR,IN,STORE,FROMR,BLK,STORE,SEMIS

;	WORDM	3,--,>,IMMEDIATE
	fcb	$c3
	fcc	"--"
	fcb	$80+'>
	fdb	LOAD-7
ARROW	fdb	DOCOL,QLOAD,ZERO,IN,STORE,BSCR,BLK,AT,OVER,MOD
	fdb	SUB,BLK,PSTORE,SEMIS

;	WORDM	1,,',IMMEDIATE
	fcb	$c1
	fcb	$80+''
	fdb	ARROW-6
TICK	fdb	DOCOL,DFIND,ZEQU,ZERO,QERR,DROP,LITER,SEMIS

;	WORDM	6,FORGE,T,NOIM
	fcb	$86
	fcc	"FORGE"
	fcb	$80+'T
	fdb	TICK-4
FORGET	fdb	DOCOL,CURENT,AT,CONTXT,AT,SUB,CLITER
	fcb	$18
	fdb	QERR,TICK,DUP,FENCE,AT,LESS,CLITER
	fcb	$15
	fdb	QERR,DUP,LIT,SINIT,AT,GREAT,CLITER
	fcb	$15
	fdb	QERR,DUP,NFA,DP,STORE,LFA,AT,CONTXT,AT,STORE,SEMIS
*
;	WORDM	4,BAC,K
	fcb	$84
	fcc	"BAC"
	fcb	$80+'K
	fdb	FORGET-9
BACK	fdb	DOCOL,HERE,SUB,COMMA,SEMIS

;	WORDM	5,BEGI,N,IMMEDIATE
	fcb	$c5
	fcc	"BEGI"
	fcb	$80+'N
	fdb	BACK-7
BEGIN	fdb	DOCOL,QCOMP,HERE,ONE,SEMIS

;	WORDM	5,ENDI,F,IMMEDIATE
	fcb	$c5
	fcc	"ENDI"
	fcb	$80+'F
	fdb	BEGIN-8
ENDIF	fdb	DOCOL,QCOMP,TWO,QPAIRS,HERE,OVER,SUB,SWAP,STORE,SEMIS

;	WORDM	4,THE,N,IMMEDIATE
	fcb	$c4
	fcc	"THE"
	fcb	$80+'N
	fdb	ENDIF-8
THEN	fdb	DOCOL,ENDIF,SEMIS

;	WORDM	2,D,O,IMMEDIATE
	fcb	$c2
	fcc	"D"
	fcb	$80+'O
	fdb	THEN-7
DO	fdb	DOCOL,COMPIL,XDO,HERE,THREE,SEMIS

;	WORDM	4,LOO,P,IMMEDIATE
	fcb	$c4
	fcc	"LOO"
	fcb	$80+'P
	fdb	DO-5
LOOP	fdb	DOCOL,THREE,QPAIRS,COMPIL,XLOOP,BACK,SEMIS

;	WORDM	5,+LOO,P,IMMEDIATE
	fcb	$c5
	fcc	"+LOO"
	fcb	$80+'P
	fdb	LOOP-7
PLOOP	fdb	DOCOL,THREE,QPAIRS,COMPIL,XPLOOP,BACK,SEMIS

;	WORDM	5,UNTI,L,IMMEDIATE
	fcb	$c5
	fcc	"UNTI"
	fcb	$80+'L
	fdb	PLOOP-8
UNTIL	fdb	DOCOL,ONE,QPAIRS,COMPIL,ZBRAN,BACK,SEMIS

;	WORDM	3,EN,D,IMMEDIATE
	fcb	$c3
	fcc	"EN"
	fcb	$80+'D
	fdb	UNTIL-8
END	fdb	DOCOL,UNTIL,SEMIS

;	WORDM	5,AGAI,N,IMMEDIATE
	fcb	$c5
	fcc	"AGAI"
	fcb	$80+'N
	fdb	END-6
AGAIN	FDB	DOCOL,ONE,QPAIRS,COMPIL,BRAN,BACK,SEMIS

;	WORDM	6,REPEA,T,IMMEDIATE
	fcb	$c6
	fcc	"REPEA"
	fcb	$80+'T
	fdb	AGAIN-8
REPEAT	fdb	DOCOL,TOR,TOR,AGAIN,FROMR,FROMR,TWO,SUB,ENDIF,SEMIS

;	WORDM	2,I,F,IMMEDIATE
	fcb	$c2
	fcc	"I"
	fcb	$80+'F
	fdb	REPEAT-9
IF	fdb	DOCOL,COMPIL,ZBRAN,HERE,ZERO,COMMA,TWO,SEMIS

;	WORDM	4,ELS,E,IMMEDIATE
	fdb	$c4
	fcc	"ELS"
	fcb	$80+'E
	fdb	IF-5
ELSE	fdb	DOCOL,TWO,QPAIRS,COMPIL,BRAN,HERE,ZERO,COMMA,SWAP
	fdb	TWO,ENDIF,TWO,SEMIS

;	WORDM	5,WHIL,E,IMMEDIATE
	fcb	$c5
	fcc	"WHIL"
	fcb	$80+'E
	fdb	ELSE-7
WHILE	fdb	DOCOL,IF,TWOP,SEMIS
*
;	WORDM	6,SPACE,S
	fcb	$86
	fcc	"SPACE"
	fcb	$80+'S
	fdb	WHILE-8
SPACES	fdb	DOCOL,ZERO,MAX,DDUP,ZBRAN
	fdb	SPACE3-*
	fdb	ZERO,XDO
SPACE2	fdb	SPACE,XLOOP
	fdb	SPACE2-*
SPACE3	fdb	SEMIS

;	WORDM	2,<,#
	fcb	$82
	fcc	"<"
	fcb	$80+'#
	fdb	SPACES-9
BDIGS	fdb	DOCOL,PAD,HLD,STORE,SEMIS

;	WORDM	2,#>
	fcb	$82
	fcc	"#"
	fcb	$80+'>
	fdb	BDIGS-5
EDIGS	fdb	DOCOL,DROP,DROP,HLD,AT,PAD,OVER,SUB,SEMIS

;	WORDM	4,SIG,N
	fcb	$84
	fcc	"SIG"
	fcb	$80+'N
	fdb	EDIGS-5
SIGN	fdb	DOCOL,ROT,ZLESS,ZBRAN
	fdb	SIGN2-*
	fdb	CLITER
	fcb	'-
	fdb	HOLD
SIGN2	fdb	SEMIS

;	WORDM	1,,#
	fcb	$81
	fcb	$80+'#
	fdb	SIGN-7
DIG	fdb	DOCOL,BASE,AT,MSMOD,ROT,CLITER
	fcb	9
	fdb	OVER,LESS,ZBRAN
	fdb	DIG2-*
	fdb	CLITER
	fcb	7
	fdb	PLUS
DIG2	fdb	CLITER
	fcb	'0	; ascii zero
	fdb	PLUS,HOLD
	fdb	SEMIS

;	WORDM	2,#,S
	fcb	$82
	fcc	"#"
	fcb	$80+'S
	fdb	DIG-4
DIGS	fdb	DOCOL
DIGS2	fdb	DIG,OVER,OVER,OR,ZEQU,ZBRAN
	fdb	DIGS2-*
	fdb	SEMIS

DMP3	fdb	DOCOL,CLITER
	fcb	'=
	fdb	EMIT,ROT,DUP,PRTHEX,CLITER	; c
	fcb	'=
	fdb	EMIT,ROT,DUP,PRTHEX,CLITER	; b
	fcb	'=
	fdb	EMIT,ROT,DUP,PRTHEX,CLITER	; a
	fcb	'~
	fdb	EMIT,SEMIS

;	WORDM	3,D.,R
	fcb	$83
	fcc	"D."
	fcb	$80+'R
	fdb	DIGS-5
DDOTR	fdb	DOCOL,TOR,SWAP,OVER,DABS,BDIGS,DIGS,SIGN
;DDOTR	fdb	DOCOL,DMP3,TOR,SWAP,OVER,DABS,DMP3
;	fdb	BDIGS,DIGS,SIGN
	fdb	EDIGS,FROMR,OVER,SUB,SPACES,TYPE,SEMIS

;	WORDM	2,.,R
	fcb	$82
	fcc	"."
	fcb	$80+'R
	fdb	DDOTR-6
DOTR	fdb	DOCOL,TOR,STOD,FROMR,DDOTR,SEMIS

;	WORDM	2,D,.
	fcb	$82
	fcc	"D"
	fcb	$80+'.
	fdb	DOTR-5
DDOT	fdb	DOCOL,ZERO,DDOTR,SPACE,SEMIS

;	WORDM	1,,.
	fcb	$81
	fcb	$80+'.
	fdb	DDOT-5
DOT	fdb	DOCOL,STOD,DDOT,SEMIS
;DOT	fdb	DOCOL,STOD,CLITER
;	fcb	'+
;	fdb	EMIT,DUP,PRTHEX,OVER,PRTHEX,DDOT,SEMIS

;	WORDM	1,,?
	fcb	$81
	fcb	$80+'?
	fdb	DOT-4
QUEST	fdb	DOCOL,AT,DOT,SEMIS
*
;	WORDM	4,LIS,T
	fcb	$84
	fcc	"LIS"
	fcb	$80+'T
	fdb	QUEST-4
LIST	fdb	DOCOL,DEC,CR,DUP,SCR,STORE,PDOTQ
	fcb	6
	fcc	"SCR # "
	fdb	DOT,CLITER
	fcb	16
	fdb	ZERO,XDO
LIST2	fdb	CR,I,THREE
	fdb	DOTR,SPACE,I,SCR,AT,PLINE,TYPE,CLITER
	fcb	$3c
	fdb	EMIT,XLOOP
	fdb	LIST2-*
	fdb	CR,SEMIS

;	WORDM	4,DUM,P
	fcb	$84
	fcc	"DUM"
	fcb	$80+'P
	fdb	LIST-7
DUMP	fdb	DOCOL,OVER,PLUS,SWAP,XDO
DUMP1	fdb	I,CR,HEX,DOT,I,CLITER
	fcb	16
	fdb	PLUS,I,XDO
DUMP2	fdb	SPACE,I,CAT,TWO,DOTR,XLOOP
	fdb	DUMP2-*
	fdb	THREE,SPACES,I,CLITER
	fcb	16
	fdb	PLUS,I,XDO
DUMP3	fdb	I,CAT,DUP,CLITER
	fcb	$20
	fdb	LESS,ZBRAN
	fdb	DUMP31-*
	fdb	DROP,CLITER
	fcb	'_
DUMP31	fdb	EMIT,XLOOP
	fdb	DUMP3-*
	fdb	CLITER
	fcb	16
	fdb	XPLOOP
	fdb	DUMP1-*
	fdb	SEMIS

;	WORDM	5,VLIS,T
	fcb	$85
	fcc	"VLIS"
	fcb	$80+'T
	fdb	DUMP-7
VLIST	fdb	DOCOL,CLITER
	fcb	$80
	fdb	OUT,STORE,CONTXT,AT,AT
VLIST1	fdb	OUT,AT,COLUMS,AT,CLITER
	fcb	16
	fdb	SUB,GREAT,ZBRAN
	fdb	VLIST2-*
	fdb	CR,ZERO,OUT,STORE
VLIST2	fdb	DUP,IDDOT,SPACE,SPACE,PFA,LFA,AT,DUP,ZEQU,QTERM
	fdb	OR,ZBRAN
	fdb	VLIST1-*
	fdb	DROP,SEMIS
*
*
**** FILE FDISK.TXT
*<<<< DISK I/O WORDS >>>> SYSTEM DEPENDENT
*
;	WORDM	3,#D,R
	fcb	$83
	fcc	"#D"
	fcb	$80+'R
	fdb	VLIST-8
NUMDR	fdb	DOCON
	fdb	2	; the number of disk drives

;	WORDM	8,TRK/DIS,K	; track per disk
	fcb	$88
	fcc	"TRK/DIS"
	fcb	$80+'K
	fdb	NUMDR-6
TRKDSK	fdb	DOCON
	fdb	35

;	WORDM	7,SEC/TR,K	; sectors per track == block = sector
	fcb	$87
	fcc	"SEC/TR"
	fcb	$80+'K
	fdb	TRKDSK-11
SECTRK	fdb	DOCON
	fdb	10

;	WORDM	5,B/BU,F
	fcb	$85
	fcc	"B/BU"
	fcb	$80+'F
	fdb	SECTRK-10
BBUF	fdb	DOCON
	fdb	BUFSIZ

;	WORDM	5,B/SC,R
	fcb	$85
	fcc	"B/SC"
	fcb	$80+'R
	fdb	BBUF-8
BSCR	fdb	DOCOL,LIT,1024,BBUF,SLASH,SEMIS

;	WORDM	7,SCR>BL,K
	fcb	$87
	fcc	"SCR>BL"
	fcb	$80+'K
	fdb	BSCR-8
SCRBLK	fdb	DOCOL,BSCR,STAR,USEBLK,SLMOD,SECTRK,STAR
	fdb	TRKDSK,STAR,PLUS,SEMIS	; converts SCR# to BLOCK #

*	ALLOWING	FOR THE NON INTEGER # OF SCR PER DISK
;	WORDM	6,USEBL,K	; no of blocks per disk useable as SCReens
	fcb	$86
	fcc	"USEBL"
	fcb	$80+'K
	fdb	SCRBLK-10
USEBLK	fdb	DOCOL,SECTRK,TRKDSK,STAR,BSCR,SLASH,BSCR,STAR,SEMIS

;	WORDM	3,DR,0
	fcb	$83
	fcc	"DR"
	fcb	$80+'0
	fdb	USEBLK-9
DRZERO	fdb	DOCOL,ZERO,OFSET,STORE
	fdb	SEMIS

;	WORDM	3,DR,1
	fcb	$83
	fcc	"DR"
	fcb	$80+'1
	fdb	DRZERO-6
DRONE	fdb	DOCOL,ONE,DRIVE,SEMIS

;	WORDM	5,DRSI,M
	fcb	$85
	fcc	"DRSI"
	fcb	$80+'M
	fdb	DRONE-6
DRSIM	fdb	DOCOL,NUMDR,DRIVE,SEMIS

;	WORDM	5,DRIV,E	; drive number is arg on stack
	fcb	$85
	fcc	"DRIV"
	fcb	$80+'E
	fdb	DRSIM-8
DRIVE	fdb	DOCOL,SECTRK,TRKDSK,STAR,STAR,OFSET,STORE,SEMIS

*
	pag

*** The next 4 words are written to create a substitute for
*   disc mass memory, located in DSMBGN to DSMEND in RAM
***
*;	WORDM	2,L,O	; low address for simulated disk
*	fcb	$82
*	fcc	"L"
*	fcb	$80+'O
*	fdb	DRIVE-8
*LO	fdb	DOCON
*	fdb	DSMBGN
*
*;	WORDM	2,H,I	; high address for simulated disk
*	fcb	$82
*	fcc	"H"
*	fcb	$80+'I
*	fdb	LO-5
*HI	fdb	DOCON
*	fdb	DSMEND
*
*;	WORDM	3,R/,W
*	fcb	$83
*	fcc	"R/"
*	fcb	$80+'W
*	fdb	HI-5
*RW	fdb	DOCOL,SWAP	; now have BLOCK NO ON STACK
*	fdb	DUP,ZLESS,ZEQU,ZBRAN	; can't have block < 0
*	fdb	RWDE-*
*	fdb	SECTRK,TRKDSK,STAR,SLMOD	; now have block-2,dr-1
*	fdb	DUP,NUMDR,GREAT,ZBRAN
*	fdb	RWD1-*	; > RWD1 IF DRIVE <= #DR
*RWDE	fdb	CR,DOT,PDOTQ	; drive error
*	fcb	8
*	fcc	" Drive ?"
*RWDE1	fdb	LIT,$7FFF,PREV,AT,STORE,QUIT
*RWD1	fdb	DUP,NUMDR,EQUAL,ZBRAN
*	fdb	RWD2-*	; -> RWD2 IF < #DR
*	fdb	DROP,TWOM,TWOM,DUP,ZLESS,ZBRAN	; USER SIM BUFF
*	fdb	RWS1-*	; ONLY IF SCR>0
*RWRE	fdb	CR,DOT,PDOTQ
*	fcb	8
*	fcc	" Range ?"
*	fdb	BRAN
*	fdb	RWDE1-*
*RWS1	fdb	BBUF,STAR,LO,PLUS,DUP,HI,BBUF,SUB,GREAT,ZEQU,ZBRAN
*	fdb	RWRE-*
*RW4	fdb	SWAP,ZBRAN
*	fdb	RW44-*
*	fdb	SWAP
*RW44	fdb	BBUF,CMOVE,SEMIS
*RWD2	fdb	TOR,SECTRK,SLMOD,SWAP,ONEP,SWAP,FROMR
*	fdb	DISKRW,SEMIS
*
*;	WORDM	6,DISKR,W
*	fcb	$86
*	fcc	"DISKR"
*	fcb	$80+'W
*	fdb	RW-6
*DISKRW	fdb	*+2
*	lbsr	DSKRW0
*;	lbra	NEXT
*	ldx	,y++
*	jmp	[,x]

;	WORDM	3,R/,W
	fcb	$83
	fcc	"R/"
	fcb	$80+'W
	fdb	DRIVE-8
RW	fdb	*+2
	pulu	x	;
	pulu	d
	pshs	d
	clra
	pshs	a
	pshs	a
	pulu	d
	pshs	d
	tfr	x,d
	tstb
	beq	RWW
	jsr	rdblk
	bra	RWX
RWW
	jsr	wrblk
RWX
	leas	6,s
	ldx	,y++
	jmp	[,x]

;	WORDM	3,(_,)
	fcb	$83
	fcc	"(_"
	fcb	$80+')
	fdb	RW-6
PDOS	fdb	DOCOL,R,COUNT,DUP,ONEP,FROMR,PLUS,TOR,GODOS,SEMIS
GODOS	fdb	*+2
	lbsr	GODOS0
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]

	fcb	$c1	; immediate
	fcb	$80+'_
	fdb	PDOS-6
DOSQ	fdb	DOCOL,CLITER
	fcb	$22	; ascii quote
	fdb	STATE,AT,ZBRAN
	fdb	DOS1-*
	fdb	COMPIL,PDOS,WORD,HERE,CAT,ONEP,ALLOT,BRAN
	fdb	DOS2-*
DOS1	fdb	WORD,HERE,COUNT,GODOS
DOS2	fdb	SEMIS

;	WORDM	3,DO,S
	fcb	$83
	fcc	"DO"
	fcb	$80+'S
	fdb	DOSQ-4
DOS	fdb	PDOSW
FCBIN	equ	USREND-$100-640
FCBOUT	equ	FCBIN-320

;	WORDM	6,DISKI,N
	fcb	$86
	fcc	"DISKI"
	fcb	$80+'N
	fdb	DOS-6
DISKIN	fdb	DOCON,FCBIN

;	WORDM	7,DISKOU,T
	fcb	$87
	fcc	"DISKOU"
	fcb	$80+'T
	fdb	DISKIN-9
DISKOUT	fdb	DOCON,FCBOUT

;	WORDM	6,REWIN,D
	fcb	$86
	fcc	"REWIN"
	fcb	$80+'D
	fdb	DISKOUT-10
REWDF0	fdb	*+2
	lbsr	REWNDF
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]

;	WORDM	6,DELET,E
	fcb	$86
	fcc	"DELET"
	fcb	$80+'E
	fdb	REWDF0-9
DELTF0	fdb	*+2
	lbsr	DELETF
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]

;	WORDM	4,OPE,N
	fcb	$84
	fcc	"OPE"
	fcb	$80+'N
	fdb	DELTF0-9
OPENF0	fdb	*+2
	lbsr	OPENF	; expects filename,addr,iocode,fcbadr on STACK
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]

;	WORDM	4,REA,D
	fcb	$84
	fcc	"REA"
	fcb	$80+'D
	fdb	OPENF0-7
READ	fdb	DOCOL,ONE,DISKIN,OPENF0,DISKIN,LIT,XFINA
	fdb	STORE,SEMIS

;	WORDM	5,WRIT,E
	fcb	$85
	fcc	"WRIT"
	fcb	$80+'E
	fdb	READ-7
WRITE	fdb	DOCOL,ZERO,DISKOUT,OPENF0,DISKOUT,LIT,XFOUTA
	fdb	STORE,SEMIS

;	WORDM	5,CLOS,E
	fcb	$85
	fcc	"CLOS"
	fcb	$80+'E
	fdb	WRITE-8
CLOSF0	fdb	*+2
	lbsr	CLOSEF	; expects fcb adr on stack
;	lbra	NEXT
	ldx	,y++
	jmp	[,x]

;	WORDM	7,CLOSEI,N
	fcb	$87
	fcc	"CLOSEI"
	fcb	$80+'N
	fdb	CLOSF0-8
CLOSIN	fdb	DOCOL,ZERO,LIT,XFINA,STORE
	fdb	DISKIN,CLOSF0,SEMIS

;	WORDM	8,CLOSEOU,T
	fcb	$88
	fcc	"CLOSEOU"
	fcb	$80+'T
	fdb	CLOSIN-10
CLOSOT	fdb	DOCOL,ZERO,LIT,XFOUTA,STORE
	fdb	DISKOUT,CLOSF0,SEMIS

;	WORDM	5,FLOA,D
	fcb	$85
	fcc	"FLOA"
	fcb	$80+'D
	fdb	CLOSOT-11
FLOAD	fdb	DOCOL,READ,DISKIN,LIT,$0022,PLUS,AT
	fdb	BSCR,SLASH,LOAD,SEMIS

;	WORDM	5,FLIS,T
	fcb	$85
	fcc	"FLIS"
	fcb	$80+'T
	fdb	FLOAD-8
FLIST	fdb	DOCOL,READ,DISKIN,LIT,$0022,PLUS,AT
	fdb	BSCR,SLASH,LIST,SEMIS
*
;	WORDM	4,NOO,P	; a noop
	fcb	$84
	fcc	"NOO"
	fcb	$80+'P
	fdb	FLIST-8
NOOP	fdb	NEXT
*
* CHECK TO SEE IF SPACE OK FOR FDOS
FDOSBG	equ	*
*
* FOLLOWING ARE SYSTEM DEPENDENT MACHINE LANGUAGE ROUTINES

	pag

* The fdos file is included here

*
* FDOS IS A  FILE CONTAINING THE ASSEMBLY LANGUAGE ROUTINES WHICH
*      INTERFACE 68'FORTH WITH A DISK OPERATING SYSTEM
* THIS IS VERSION  1.1 ( 80.3.8)
*
* THERE ARE ADDRESSES IN HERE WHICH REFER BACK INTO THE CODE
*      68'FORTH AND THESE MUST NOT BE CHANGED
* THERE ARE ENTRY POINTS AT WHICH 68'FORTH EXPECTS TO FIND
*      VARIOUS ROUTINES, AND THESE ADDRESSES MUST NOT BE CHANGED
* THE STARTING POINT IS  FBGNIO
* THE LAST BYTE OF THESE ROUTINES MUST NOT GO BEYOND $1BEF
*
* IF NECESSARY TO USE MORE SPACE, YOU MUST ALLOCATE IT SOMEWHERE
*      UP ABOVE THE MEMORY SPACE USED FOR VIRTUAL MEMORY DISK BUFFERS
*      STACKS, AND SIMULATED DISK.
*
********
*
*  THE NEXT WORDS ARE SYSTEM-DEPENDENT I/O SUBROUTINES
*
*
*  FBGNIO	this is the address where these I/O routines are to start.
*
*  FBYTSC	the addr of # of bytes in a sector in the disk IO
*
*  FFINA	location for storing address of input FCB
*  FFOUTA	location for storing address of output FCB
*  FACIA	location of address of terminal ACIA
*
*
*<<<<<<<<<<<<<  FROM HERE TO >>>>>>>>>>>>> THE ADDRESSES CAN NOT BE CHANGED
*
FBGNIO	equ	$1e50
	org	FBGNIO
*
FBYTSC	equ	$17BB
*
FFINA	equ	$2428
FFOUTA	equ	$242a
FACIA	equ	$c400
*
*** * * *
*
* NOW JUMP VECTORS FOR FORTH  -  3 BYTES EACH
*
PEMIT	lbra	PPEMIT	; emit char in A to terminal
PKEY	lbra	PPKEY	; get char from terminal - put in A, NO ECHO!
PQTER	lbra	PPQTER	; query terminal to see if char typed -
*		ret 0 if not, ret char if so - ESC is treated as a
*		request to pause, another ESC will resume as if no
*		key had been pressed
PMON	lbra	RESMON	; close any open files an return to MONITOR
PDOSW	jmp	[DOSWRM,PCR]	; return to DOS
GODOS0	lbra	GODOSI	; routine to set up DOS command call
DSKRW0	lbra	DSKRWI	; disk sector IO - args on U stack
*		FORTH-BUFFER-ADDRESS	-5
*		READ/WRITE CODE	- 1=READ, 0=WRITE -4
*		SECTOR NUMBER		-3
*		TRACK NUMBER		-2
*		DRIVE NUMBER		-1
OPENF	lbra	OPENFI	; OPEN file - args on the U stack
*		ADDRESS OF FIRST CHAR (COUNT FIELD) OF STRING WITH
*			NAME OF FILE	-3
*		READ/WRITE FLAG - 1=READ, 0=WRITE -2
*		ADDRESS OF FCB		-1
*
CLOSEF	lbra	CLOSFI	; arg is on stack   ADDRESS OF FCB -1
REWNDF	lbra	REWNDI	;  "  "  "    "        "    "   "
DELETF	lbra	DELETI	;  "  "  "    "        "    "   "
*
	rmb	9	; reserve space for 3 more vectors
*
*	>>>>>>>>>>>>>>>   THE ABOVE CODE CAN NOT BE CHANGED
*
*<<<<<<<<  THE CODE BELOW MAY BE CHANGED, BUT THE LAST ADDRESS MAY
*		NOT BE LARGER THAN 1BEF - 1BFO TO 2000 IS USED FOR DISK
*		VIRTUAL MEMORY BUFFERS
*
NXTMON	equ	$e000
*	i.e., jmp  [NXTMON,PCR]
*

uart	equ	$c400
rbr	equ	uart+0
thr	equ	uart+0
ier	equ	uart+1
iir	equ	uart+2
fcr	equ	uart+2
lcr	equ	uart+3
mcr	equ	uart+4
lsr	equ	uart+5
msr	equ	uart+6
scr	equ	uart+7
dll	equ	uart+0
ptype	equ	$baff
pstart	equ	$bafb
fatsec	equ	$baf7
rdirsec	equ	$baf3
sec0	equ	$baef
sperc	equ	$baee
rseed	equ	$baec

getc	equ	$e003
hexdig	equ	$e006
getline	equ	$e009
gethex1	equ	$e00c
gethex2	equ	$e00f
putc	equ	$e012
outhl	equ	$e015
outhr	equ	$e018
outs	equ	$e01b
print	equ	$e01e
prthex	equ	$e021
map	equ	$e024
sdinit	equ	$e027
sdcmd	equ	$e02a
rdblk	equ	$e02d
wrblk	equ	$e030
fatinit	equ	$e033
fatwalk	equ	$e036

DOSWRM	fdb	$e000

	rmb	6
PPEMIT
	anda	#$7f
	jsr	putc
	rts

PPKEY	jsr	getc
	rts

PPQTER
	lda	lsr
	anda	#1
	beq	nokey
	lda	rbr
nokey
	rts

GODOSI	rts

DSKRWI
	rts

OPENFI
	pshs	x,y	;
	pulu	x	;
	pulu	d	;
	pulu	y	;
	pshs	x	;
	ldb	,y+	; File name at FCB+0
oflp
	lda	,y+
	cmpa	#'a
	blt	isuc
	anda	#$df
isuc
	sta	,x+
	decb
	bne	oflp
	clra
	sta	,x
	jsr	fatinit
	ldd	sec0+2
	std	XOFSET
	ldx	,s
	jsr	fatwalk
	puls	x	;
	leax	$20,x	; Starting sector at FCB+$20
	lda	$1a,y
	ldb	sperc
	mul
*	addb	sec0+3
	stb	3,x
*	adca	sec0+2
	sta	2,x
	lda	$1b,y
	ldb	sperc
	mul
	addb	2,x
	stb	2,x
*	adca	sec0+1
	sta	1,x
	clra
*	lda	sec0
	sta	,x
	lda	ptype
	cmpa	#$0b
	bne	of16
	lda	$14,y
	ldb	sperc
	mul
	addb	1,x
	stb	1,x
	adca	,x
	sta	,x
	lda	$15,y
	ldb	sperc
	mul
	addb	,x
	stb	,x
of16
	lda	$1c,y	; File size in FCB+$24
	sta	7,x
	lda	$1d,y
	sta	6,x
	lda	$1e,y
	sta	5,x
	lda	$1f,y
	sta	4,x
	puls	x,y	;
	rts

CLOSFI	rts

REWNDI	rts

DELETI	rts

RESMON	jmp	NXTMON
