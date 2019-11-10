	name	'MPMDIO'
	title	'Direct MP/M Calls From PL/I-80'
;
;  Note:  The CP/M function get version number (#12) has been
;	included in this module.  If you wish to link both the
;	DIOMOD and the MPMDIO, you must remove the function
;	from this module.
;
;***********************************************************
;*							   *
;*	MP/M calls from pl/i for direct i/o		   *
;*							   *
;*	   This interface is re-entrant.                   *
;*							   *
;***********************************************************
	public	amemrq	;absolute memory request (#128)
	public	rmemrq	;relocatable memory request (#129)
	public	memfr	;memory free (#130)
	public	poll	;poll device (#131)
	public	flgwt	;flag wait (#132)
	public	flgset	;flag set (#133)
	public	makque	;make queue (#134)
	public	opnque	;open queue (#135)
	public	delque	;delete queue (#136)
	public	rdque	;read queue - unconditional (#137)
	public	crdque	;conditional read queue (#138)
	public	wrque	;write queue - unconditional (#139)
	public	cwrque	;conditional write queue (#140)
	public	delay	;delay (#141)
	public	dsptch	;dispatch (#142)
	public	term	;terminate calling process (#143)
	public	crproc	;create process (#144)
	public	setpri	;set process priority (#145)
	public	attcon	;attach console (#146)
	public	detcon	;detach console (#147)
	public	setcon	;set console (#148)
	public	asncon	;assign console (#149)
	public	sclicd	;send CLI command (#150)
	public	clresp	;call resident system process (#151)
	public	parse	;parse filename (#152)
	public	getcon	;get console number (#153)
	public	sysdat	;return system data page adr (#154)
	public	gettod	;get time and date (#155)
	public	rpdadr	;return process descr adr (#156)
	public	abtspr	;abort specified process (#157)

	public	disabl	;disable interrupts
	public	enable	;enable interrupts

	public	vers	;CP/M function - get version number (#12)
;
;
	extrn	?bdos
;
;***********************************************************
;*							   *
;*	equates for interface to mp/m xdos		   *
;*							   *
;***********************************************************
amemrqf	equ	128	;absolute memory request
rmemrqf	equ	129	;relocatable memory request
memfrf	equ	130	;memory free
pollf	equ	131	;poll device
flgwtf	equ	132	;flag wait
flgsetf	equ	133	;flag set
makquef	equ	134	;make queue
opnquef	equ	135	;open queue
delquef	equ	136	;delete queue
rdquef	equ	137	;read queue - unconditional
crdquef	equ	138	;conditional read queue
wrquef	equ	139	;write queue - unconditional
cwrquef	equ	140	;conditional write queue
delayf	equ	141	;delay
dsptchf	equ	142	;dispatch
termf	equ	143	;terminate calling process
crprocf	equ	144	;create process
setprif	equ	145	;set process priority
attconf	equ	146	;attach console
detconf	equ	147	;detach console
setconf	equ	148	;set console
asnconf	equ	149	;assign console
sclicdf	equ	150	;send CLI command
clrespf	equ	151	;call resident system process
parsef	equ	152	;parse filename
getconf	equ	153	;get console number
sysdatf	equ	154	;return system data page adr
gettodf	equ	155	;get time and date
rpdadrf	equ	156	;return process descr adr
abtsprf	equ	157	;abort specified process

versf	equ	12	;get version number (CP/M function)
;
;	utility functions
;***********************************************************
;*							   *
;*	general purpose routines used upon entry	   *
;*							   *
;***********************************************************
getp1i:
	call	getp1
	jmp	?bdos		;return through bdos

getp1:	;get single byte parameter to register e
	mov	e,m		;low (addr)
	inx	h
	mov	d,m		;high (addr)
	xchg			;hl = .char
	mov	e,m		;to register e
	ret
;
getp2:	;get single word parameter to DE
getp2i:	;(equivalent to getp2)
	call 	getp1
	inx	h
	mov	d,m		;get high byte as well
	jmp	?bdos		;return through bdos
;
getp3i:	;get single word parameter to DE
	;perform bdos call and then compliment result
	call	getp2i
	cma
	ret
;
;***********************************************************
;*							   *
;***********************************************************
amemrq:	;absolute memory request (#128)
	;1->addr(memdscr)
	mvi	c,amemrqf	;abs mem rqst function
	jmp	getp3i		;DE = .memdscr
				;return through bdos
;
;***********************************************************
;*							   *
;***********************************************************
rmemrq:	;relocatable memory request (#129)
	;1->addr(memdscr)
	mvi	c,rmemrqf	;rel mem rqst function
	jmp	getp3i		;DE = .memdscr
				;return through bdos
;
;***********************************************************
;*							   *
;***********************************************************
memfr:	;memory free (#130)
	;1->addr(memdscr)
	mvi	c,memfrf	;memory free function
	jmp	getp2i		;DE = .memdscr
				;return through bdos
;
;***********************************************************
;*							   *
;***********************************************************
poll:	;poll device (#131)
	;1->fixed(7) poll device number
	mvi	c,pollf		;poll function
	jmp	getp1i		;device number to E
				;return through bdos
;
;***********************************************************
;*							   *
;***********************************************************
flgwt:	;flag wait (#132)
	;1->fixed(7) flag number
	mvi	c,flgwtf	;flag wait function
	call	getp1i		;flag number to E
	cma
	ret
;
;***********************************************************
;*							   *
;***********************************************************
flgset:	;flag set (#133)
	;1->fixed(7) flag number
	mvi	c,flgsetf	;flag set function
	call	getp1i		;flag number to E
	cma
	ret
;
;***********************************************************
;*							   *
;***********************************************************
makque:	;make queue (#134)
	;1->addr(qcb)
	mvi	c,makquef	;make queue function
	jmp	getp2i		;DE = .qcb
				;return through bdos
;
;***********************************************************
;*							   *
;***********************************************************
opnque:	;open queue (#135)
	;1->addr(uqcb)
	mvi	c,opnquef	;open queue function
	jmp	getp3i		;DE = .uqcb
				;return through bdos
;
;***********************************************************
;*							   *
;***********************************************************
delque:	;delete queue (#136)
	;1->addr(qcb)
	mvi	c,delquef	;delete queue function
	jmp	getp3i		;DE = .qcb
				;return through bdos
;
;***********************************************************
;*							   *
;***********************************************************
rdque:	;read queue - unconditional (#137)
	;1->addr(uqcb)
	mvi	c,rdquef	;read queue function
	jmp	getp2i		;DE = .uqcb
				;return through bdos
;
;***********************************************************
;*							   *
;***********************************************************
crdque:	;conditional read queue (#138)
	;1->addr(uqcb)
	mvi	c,crdquef	;conditional read queue function
	jmp	getp3i		;DE = .uqcb
				;return through bdos
;
;***********************************************************
;*							   *
;***********************************************************
wrque:	;write queue - unconditional (#139)
	;1->addr(uqcb)
	mvi	c,wrquef	;write queue function
	jmp	getp2i		;DE = .uqcb
				;return through bdos
;
;***********************************************************
;*							   *
;***********************************************************
cwrque:	;conditional write queue (#140)
	;1->addr(uqcb)
	mvi	c,cwrquef	;conditional write queue function
	jmp	getp3i		;DE = .uqcb
				;return through bdos
;
;***********************************************************
;*							   *
;***********************************************************
delay:	;delay (#141)
	;1->number of ticks to delay
	mvi	c,delayf	;delay function
	jmp	getp2i		;DE = #ticks
				;return through bdos
;
;***********************************************************
;*							   *
;***********************************************************
dsptch:	;dispatch (#142)
	mvi	c,dsptchf	;dispatch function
	jmp	?bdos		;return through bdos
;
;***********************************************************
;*							   *
;***********************************************************
term:	;terminate calling process (#143)
	;1->terminate code
	mvi	c,termf		;terminate function
	jmp	getp2i		;DE = terminate code, where
				; if D = FF then keep mem seg
				; if E = FF term sys process
				;return through bdos
;
;***********************************************************
;*							   *
;***********************************************************
crproc:	;create process (#144)
	;1->addr(pdadr)
	mvi	c,crprocf	;create process function
	jmp	getp2i		;DE = .pdadr
				;return through bdos
;
;***********************************************************
;*							   *
;***********************************************************
setpri:	;set process priority (#145)
	;1->fixed(7) priority
	mvi	c,setprif	;set priority function
	jmp	getp1i		;priority to E
				;return through bdos
;
;***********************************************************
;*							   *
;***********************************************************
attcon:	;attach console (#146)
	mvi	c,attconf	;attach console function
	jmp	?bdos		;return through bdos
;
;***********************************************************
;*							   *
;***********************************************************
detcon:	;detach console (#147)
	mvi	c,detconf	;detach console function
	jmp	?bdos		;return through bdos
;
;***********************************************************
;*							   *
;***********************************************************
setcon:	;set console (#148)
	;1->fixed(7) console
	mvi	c,setconf	;set console function
	jmp	getp1i		;console to E
				;return through bdos
;
;***********************************************************
;*							   *
;***********************************************************
asncon:	;assign console (#149)
	;1->addr(apb)
	mvi	c,asnconf	;assign console function
	jmp	getp3i		;DE = .apb
				;return through bdos
;
;***********************************************************
;*							   *
;***********************************************************
sclicd:	;send CLI command (#150)
	;1->addr(clicmd)
	mvi	c,sclicdf	;send CLI command function
	jmp	getp2i		;DE = .clicmd
				;return through bdos
;
;***********************************************************
;*							   *
;***********************************************************
clresp:	;call resident system process (#151)
	;1->addr(cpb)
	call	getp1		;DE = .cpb
	inx	h
	mov	d,m
	xchg
	mov	c,m
	inx	h
	mov	b,m		;BC = cpb.name
	inx	h
	mov	d,h
	mov	e,l		;DE = .cpb.param
	lxi	h,-14
	dad	sp
	sphl			;make room for uqcb+2 on stk
	push	d
;
;	Stack Structure:
;
;	+-----------------------+
;	|   Return Address      |
;	+-----------------------+
;	|                       |
;	  uqcb.name(0) - name(7)
;	|                       |
;	+-----------------------+
;	|   uqcb.msgadr         | ---+
;	+-----------------------+    |
;	|   uqcb.pointer        |    |
;	+-----------------------+    |
;	|  (space for .pliproc) | <--+
;	+-----------------------+
;  S--->|   .cpb.param          |
;	+-----------------------+
;
	mov	d,h
	mov	e,l
	inx	h
	inx	h
	inx	h
	inx	h
	mov	m,e
	inx	h
	mov	m,d		;uqcb.msgadr <-
	inx	h
	mvi	e,8
clresploop:
	ldax	b
	mov	m,a
	inx	b
	inx	h
	dcr	e
	jnz	clresploop
	lxi	b,-12
	dad	b		;HL = .uqcb
	mvi	c,opnquef
	xchg
	call	?bdos		;open the cpb.name queue
	inr	a
	lxi	h,0001h
	pop	d		;DE = cpb.param
	jz	clresprtn	;queue not found
	lxi	h,2
	dad	sp
	mvi	c,rdquef
	push	d
	xchg
	call	?bdos		;read proc adr from queue
	pop	d		;DE = cpb.param
	pop	h		;HL = procadr
	push	h
	lxi	b,clresprtn
	push	b		;setup return addr
	push	h
	xchg
	ret			;call pliproc (param)
clresprtn:			;return here from pliproc call
	push	h		;save returned result
	lxi	h,4
	dad	sp
	xchg			;DE = .uqcb
	mvi	c,wrquef
	call	?bdos		;write proc adr to queue
	pop	d		;DE = result returned from pliproc
	lxi	h,14
	dad	sp
	sphl			;discard uqcb on stack
	xchg
	ret			;return with HL = pliproc()
	;
;***********************************************************
;*							   *
;***********************************************************
parse:	;parse filename (#152)
	;1->addr(pfcb)
	mvi	c,parsef	;parse filename function
	jmp	getp2i		;DE = .pfcb
				;return through bdos
;
;***********************************************************
;*							   *
;***********************************************************
getcon:	;get console number (#153)
	mvi	c,getconf	;get console function
	jmp	?bdos		;return through bdos
;
;***********************************************************
;*							   *
;***********************************************************
sysdat:	;return system data page adr (#154)
	mvi	c,sysdatf	;get system data pg adr fn
	jmp	?bdos		;return through bdos
;
;***********************************************************
;*							   *
;***********************************************************
gettod:	;get time and date (#155)
	;1->addr(todadr)
	mvi	c,gettodf	;get time and date function
	jmp	getp2i		;DE = .todadr
				;return through bdos
;
;***********************************************************
;*							   *
;***********************************************************
rpdadr:	;return process descr adr (#156)
	mvi	c,rpdadrf	;return Proc dscr adr fn
	jmp	?bdos		;return through bdos
;
;***********************************************************
;*							   *
;***********************************************************
abtspr:	;abort specified process (#157)
	;1->addr(abtpb)
	mvi	c,abtsprf	;abort specified proc fn
	jmp	getp3i		;DE = .abtpb
				;return through bdos
;
;***********************************************************
;*							   *
;***********************************************************
disabl: ;disable interrupts
	di
	ret
;
;***********************************************************
;*							   *
;***********************************************************
enable:	;enable interrupts
	ei
	ret
;
;***********************************************************
;*							   *
;***********************************************************
vers:	;get version number (#12)  CP/M function
	mvi	c,versf
	jmp	?bdos		;return through bdos
;
;***********************************************************
;*							   *
;***********************************************************
	end
