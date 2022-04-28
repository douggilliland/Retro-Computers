	opt	l
	opt	bin
	opt	s19

	org	$0020

stpsfl	rmb	1
basex	rmb	1
basey	rmb	1
basesx	rmb	1
basesy	rmb	1
glmflg	rmb	1
seckln	rmb	1
flagc	rmb	1
timdec	rmb	1
stcflg	rmb	1
sqflg	rmb	1
pntflg	rmb	1
course	rmb	1
warp	rmb	1
fincx	rmb	1
fincy	rmb	1
count	rmb	1
temp	rmb	2
temp2	rmb	2
xtemp	rmb	2
time0	rmb	2
gamtim	rmb	1
timuse	rmb	2
shengy	rmb	2
klneng	rmb	2
phseng	rmb	2
topflg	rmb	1
botflg	rmb	1
lsdflg	rmb	1
rsdflg	rmb	1
photon	rmb	1
curqux	rmb	1
curquy	rmb	1
curscx	rmb	1
curscy	rmb	1
trialx	rmb	1
trialy	rmb	1
flag	rmb	1
cndflg	rmb	1
scanx	rmb	1
scany	rmb	1
count1	rmb	1
secinf	rmb	1
mask	rmb	1
klngct	rmb	1
length	rmb	1
asave	rmb	1
shield	rmb	1
energy	rmb	2
tsave1	rmb	1
hitkls	rmb	1
hitstr	rmb	1
hitbas	rmb	1
temp3	rmb	2
galcnt	rmb	1
dameng	rmb	1
damsrs	rmb	1
damlrs	rmb	1
damphs	rmb	1
dampht	rmb	1
damshl	rmb	1
supflg	rmb	1
telflg	rmb	1
atkeng	rmb	2
qudptr	rmb	2
paswrd	rmb	3
phtflg	rmb	1
qudmap	rmb	64
secmap	rmb	16
endvar

	org	$100

	jmp	spavoy

* table of move vectors

movtbl	fcb	0,$ff,1,$ff,1,0,1,1,0,1,$ff,1,$ff,0
	fcb	$ff,$ff

* special character table

chrtbl	fcc	;.*KB;

* command jump table

jmptbl	fdb	setcrs
	fdb	srscan
	fdb	lrscan
	fdb	phaser
	fdb	photor
	fdb	damrpt
	fdb	shldup
	fdb	shldwn
	fdb	telept
	fdb	selfde

* external i-o jumps

pdata1	jmp	$e01e
outhr	jmp	$e018
outhl	jmp	$e015
outs	jmp	$e01b
outch	jmp	$e012
inch	jmp	$e003
rseed	equ	$baec


* setup of galaxy

puthex	equ	$e021

spavoy
	lds	#$a042	; setup stack
	ldd	rseed
	std	rndm+1
	ldx	#title
	jsr	pstrng	; output title
	ldx	#stpsfl
	clra		; clear all temp storage
setup
	sta	,x+
	cpx	#endvar
	bne	setup

	ldx	#shtlng	; short or long version?
	jsr	pstrng
	jsr	inch
	jsr	outch
	anda	#$df
	cmpa	#'S
	beq	short
	inc	length	; if long set flag
short
	ldx	#qudmap	; point to quadrant map
	ldb	#64
setup0
	jsr	random	; setup number of Klingons
	cmpa	#$fc	; in each quadrant
	bls	setup1	; probability low for 4
	lda	#4
	bra	setup5

setup1
	cmpa	#$f7
	bls	setup2
	lda	#3
	bra	setup5

setup2
	cmpa	#$e0
	bls	setup3
	lda	#2
	bra	setup5

setup3
	cmpa	#$a0	; probability much higher
	bls	setup4	; for 1 Klingon
	lda	#1
	bra	setup5

setup4
	clra
setup5
	clr	asave
	tst	length	; check for long version
	beq	setup8	; if not jump ahead
	sta	asave	; else generate additional
	jsr	random	; Klingons and add to the
	cmpa	#$f0	; previously generated
	bls	setup6
	lda	#3
	bra	setup8

setup6
	cmpa	#$c0
	bls	setup7
	lda	#2
	bra	setup8

setup7
	clra
setup8
	adda	asave
	sta	,x	; save Klingons
	adda	klngct	; update totl count
	sta	klngct
stars
	jsr	random	; generate some stars
	anda	#$38
	ora	,x
	sta	,x
cont
	leax	1,x
	decb
	beq	cont1	; if not done with all
	jmp	setup0	; quadrants, repeat
cont1
	jsr	random	; generate starbase
	anda	#7
	tfr	a,b
	jsr	random
	anda	#7
	sta	basex	; save its position
	stb	basey
	inc	stpsfl
	ldx	#qudmap
	jsr	stpsex
	lda	#$40	; put in quad. map
	ora	,x
	sta	,x
cont2
	bsr	refuel	; setup initial energy
	jsr	random	; calculate stardate
	adda	#0
	daa
	sta	time0+1
	jsr	random
	anda	#$7f
	ora	#$10
	adda	#0
	daa
	sta	time0
	bsr	maktim	; calculate game time
	tst	length	; if long, more time
	beq	gatm
	tfr	a,b
	bsr	maktim
	suba	#0
	stb	,-s
	adda	,s+
	daa
gatm
	sta	gamtim
	bra	cont3

* refuel the Enterprise

refuel
	clr	shield	; lower shield
	lda	#$30
	sta	energy	; set energy to 3000
	sta	shengy	; shield energy also
	clr	energy+1
	clr	shengy+1
	lda	#15	; initialize torpedoes
	sta	photon
	ldx	#dameng	; fix all damage
reful1
	clr	,x+
	cpx	#supflg
	bne	reful1
	rts

* calculate game time

maktim
	jsr	random	; get random num
	anda	#$0f
	ora	#$30	; no less than 22 years
	adda	#0
	daa
	rts

* setup continued

cont3
	jsr	random	; generate position of
	anda	#7	; Enterprise
	sta	curqux
	jsr	random
	anda	#7
	sta	curquy
	jsr	setups
	ldx	#basinf	; report base position
	jsr	pstrng
	lda	basex
	bsr	fixout
	jsr	outdsh
	lda	basey
	bsr	fixout
	ldx	#intro0	; out password prompt
	jsr	pstrng
	ldx	#paswrd	; get password
	ldb	#3
cont4
	jsr	inch
	sta	,x+	; save it
	decb
	bne	cont4
	ldx	#intro1
	jsr	pstrng	; output stardate
	bsr	outdat
	ldx	#intro2
	jsr	pstrng	; out # of Klingons
	bsr	outkln
	ldx	#intro3
	jsr	pstrng	; out years to win
	clr	temp
	lda	gamtim
	sta	temp+1
	jsr	outbcd
	ldx	#intro4
	jsr	pstrng	; output quadrant
	bsr	outqud
	ldx	#intro6
	jsr	pstrng	; output sector
	bsr	outsec
	jmp	comand

* output a number
fixout
	adda	#$31	; bias and output
	jmp	outch

* output stardate
outdat
	ldx	time0	; load date
	stx	temp
	jsr	outbcd
	lda	#'.
	jsr	outch	; output dec point
	lda	timdec
	jmp	outhr

* output Klingon count
outkln
	lda	klngct	; get count
outk0
	clr	temp
outk1
	clr	temp+1
	ldb	#10	; convert to bcd
outk2
	stb	,-s
	suba	,s+
	bcs	outk3
	inc	temp+1
	cmpb	temp+1
	bne	outk2
	inc	temp
	bra	outk1
outk3
	stb	,-s
	adda	,s+
	ldb	temp+1
	aslb
	aslb
	aslb
	aslb
	stb	,-s
	adda	,s+
	sta	temp+1
	jmp	outbcd

* output quadrant
outqud
	lda	curqux	; get quad. info
	bsr	fixout	; output it
	bsr	outdsh	; output dash
	lda	curquy
	bra	fixout

* output sector
outsec
	lda	curscx	; get sector info
	bsr	fixout	; output it
	bsr	outdsh	; output a dash
	lda	curscy
	bra	fixout

* output a dash
outdsh
	lda	#'-	; load up dash
	jmp	outch	; output it

* main program loop
comand
	lda	gamtim	; check time
	cmpa	timuse+1
	bhi	noextc	; is it up?
	jmp	nomtim
noextc
	tst	klngct	; all Klingons gone?
	bne	noext2
	jmp	nomkln
noext2
	tst	supflg	; supernova here?
	beq	noext4
	ldx	#supdes
	jsr	pstrng
	jmp	selfda
noext4
	jsr	clrcqu	; clear Klingons and stars
	lda	#2
	cmpa	cndflg	; are we docked
	beq	cmnd27
	clr	cndflg
	tst	seckln	; condition red?
	beq	cmndac
	deca
	sta	cndflg
cmndac
	jsr	random
	cmpa	#$fc	; space storm?
	bls	comnd2
	ldx	#spstrm
	jsr	pstrng
	lda	#2
	sta	damshl
	jmp	shldwn
comnd2
	jsr	random
	cmpa	#$fc	; supernova?
	bls	cmnd25
	jmp	supnov
cmnd25
	jsr	attack	; go get attacked
	tst	energy	; any energy left?
	bpl	comnd0
	jmp	nrgout
comnd0
	lda	#3	; is condition yellow?
	cmpa	energy
	bls	cmndad
	sta	cndflg
cmndad
	tst	shengy	; shield energy left?
	bpl	cmnd27
	clra
	sta	shield	; if not lower shields
	sta	shengy
	sta	shengy+1
cmnd27
	ldx	#comst	; output com. prompt
	jsr	pstrng
	clr	stcflg
	clr	phtflg
comnd3
	jsr	inchck	; input command
comnd4
	asla
	ldx	#jmptbl
	ldx	a,x	; FIXXRG
	jmp	,x	; jump to it

* output a 4 digit bcd number
outbcd
	clr	flag	; output a bcd num.
	lda	temp	; from location temp
	beq	outbc2	; and temp+1
	anda	#$f0
	beq	outbc1
	lda	temp
	jsr	outhl	; first digit
outbc1
	lda	temp
	jsr	outhr	; second digit
	inc	flag
outbc2
	lda	temp+1
	tst	flag
	bne	nozero
	anda	#$f0
	beq	outbc3
nozero
	jsr	outhl	; third digit
outbc3
	lda	temp+1
	jmp	outhr

* lower shields
shldwn
	clr	shield	; shields down
	ldx	#dwnst
shld0
	jsr	pstrng	; report
shld1
	jmp	comand

* raise shields
shldup
	lda	shengy	; have enough energy?
	cmpa	#1
	bls	shld1
	tst	damshl	; shields damanged?
	bne	shldwn
	inc	shield	; raise shields
	ldx	#shengy
	lda	#2	; deduct energy
	sta	temp
	clr	temp+1
	jsr	bcdsub
	ldx	#upstr
	bra	shld0	; report

* short range scan
srscan
	tst	damsrs	; damaged?
	beq	sscan1
	jmp	rptdam
sscan1
	jsr	pcrlf	; output a cr & lf
	clr	scany
	lda	cndflg	; are we docked?
	cmpa	#2
	bne	sscan2
	jsr	refuel	; if so, refuel
sscan2
	ldx	#secmap	; point to sector map
	stx	temp2
	jsr	doscan	; output first line
	ldx	#sdate	; output date
	jsr	pdata1
	jsr	outdat
	jsr	doscan	; output next line
	ldx	#cndtns
	jsr	pdata1
	lda	cndflg
	beq	srscn1	; check condition
	cmpa	#1
	beq	srscn0
	cmpa	#3
	beq	outcn1
	ldx	#docked
	bra	outcnd
outcn1
	ldx	#yellow	; yellow
outcnd
	jsr	pdata1
	bra	srscn2
srscn0
	ldx	#red	; condition red
	bra	outcnd
srscn1
	ldx	#green	; green
	bra	outcnd
srscn2
	bsr	doscan	; output next line
	ldx	#quadp
	jsr	pdata1	; out quadrant
	jsr	outqud
	bsr	doscan	; output next line
	ldx	#secp
	jsr	pdata1	; output sector
	jsr	outsec
	bsr	doscan	; next line
	ldx	#engstr
	jsr	pdata1	; output energy
	ldx	energy
	stx	temp
	jsr	outbcd
	bsr	doscan	; output next line
	ldx	#klstr
	jsr	pdata1	; out Klingon count
	jsr	outkln
	bsr	doscan	; out next line
	ldx	#shstr
	jsr	pdata1	; output shields
	ldx	shengy
	stx	temp
	jsr	outbcd	; shield energy
	tst	shield
	beq	srscn4
	ldx	#upscas	; up
	bra	srscn5
srscn4
	ldx	#dnscas	; down
srscn5
	jsr	pdata1
	bsr	doscan	; output last line
	ldx	#trpstr
	jsr	pdata1	; output torpedoes
	clr	temp
	lda	photon
	adda	#0
	daa
	sta	temp+1
	jsr	outbcd
	jmp	comand	; return

* output 1 short rand scan line
doscan
	jsr	pcrlf	; output a cr & lf
	lda	#2
	sta	count	; setup counter
	clr	scanx
doscn
	lda	#4
	sta	count1	; setup end counter
	ldx	temp2
	lda	,x
doscn0
	sta	asave
	lda	curscy
	cmpa	scany	; is it y loc of Ent.
	bne	chk0
	lda	curscx
	cmpa	scanx	; is it x loc of Ent.
	bne	chk0
	lda	#'E	; if so print "E"
	jsr	outch
	bra	goahd
chk0
	lda	asave
doscn1
	ldx	#chrtbl	; find character
	anda	#3
	leax	a,x	; FIXXRG
	lda	0,x
	jsr	outch	; output it
goahd
	jsr	outs	; output a space
	ldx	temp2
	inc	scanx
	dec	count1	; dec the counter
	beq	doscn2	; are we done?
	lda	asave
	lsra		; if not, get to next
	lsra		; sector in byte
	bra	doscn0	; repeat
doscn2
	leax	1,x
	stx	temp2
	lda	,x
	dec	count	; dec the counter
	bne	doscn	; if not 0, repeat
	inc	scany
	rts

* print string routine
pstrng
	bsr	pcrlf	; output a cr & lf
	jmp	pdata1

* print carriage return & line feed
pcrlf
	stx	xtemp	; save the x reg
	ldx	#crlfst	; output a cr & lf
	jsr	pdata1
	ldx	xtemp	; restore x
	rts

* setup sector map
setups
	clr	seckln	; clear local Klings
	ldx	#secmap	; point to sector map
	ldb	#16
	clra
setps1
	sta	,x+
	decb
	bne	setps1
	ldx	#qudmap	; point to quad map
	lda	curqux	; get current pos.
	ldb	curquy
stpsex
	sta	asave
	tstb
	beq	setps4
setps2
	lda	#8
setps3
	leax	1,x	; find cur. y quad.
	deca
	bne	setps3
	decb
	bne	setps2
setps4
	lda	asave
	beq	setps6
setps5
	leax	1,x	; find cur. x quad.
	deca
	bne	setps5
setps6
	tst	stpsfl
	beq	stpsnx
	clr	stpsfl	; if entered external
	rts		; return
stpsnx
	stx	qudptr	; save current quadrant
	ldb	,x
	stb	secinf
	beq	setp10
	andb	#7	; check for Klingons
	beq	setps7
	stb	count
	stb	seckln
	lda	#2
	sta	mask
	bsr	putinm	; go put in map
setps7
	ldb	secinf
	andb	#$38	; check for stars
	beq	setps8
	lsrb
	lsrb
	lsrb
	stb	count
	lda	#1
	sta	mask
	bsr	putinm	; put stars in map
setps8
	ldb	secinf
	bitb	#$40	; check for base
	beq	setps9
	lda	#1
	sta	count
	lda	#3
	sta	mask
	bsr	putinm	; put base in map
setps9
	ldb	secinf
	bpl	setp10	; check for supernova
	inc	supflg	; if so, set flag
setp10
	jsr	random	; get random x
	anda	#7
	sta	trialx
	jsr	random	; get random y
	anda	#7
	sta	trialy
	jsr	chkpos	; location empty?
	tst	flag
	bne	setp10
	lda	trialx	; if so, this is
	sta	curscx	; current location
	lda	trialy	; of Enterprise
	sta	curscy

* calculate local Klingon energy
cscken
	ldb	seckln	; get # of Klingons
	aslb		; multiply by 2
	ldx	#klneng	; point to k energy
cscext
	clr	,x
	clr	1,x
csckn1
	jsr	random	; gen random energy
	adda	#0	; for each Klingon
	daa
	clr	temp
	sta	temp+1
	jsr	bcdadd	; add up energy
	decb
	bne	csckn1
	rts

* put objects in sector map
putinm
	ldx	#secmap	; point to map
	jsr	random
	anda	#$f	; gen random position
	sta	tsave1
	leax	a,x	; FIXXRG
	ldb	,x
	jsr	random	; get random x
	anda	#3
	sta	asave
	beq	putin2
putin1
	rorb		; find x position
	rorb
	deca
	bne	putin1
putin2
	bitb	#3	; is position empty?
	bne	putinm	; if not, repeat
	orb	mask
	lda	asave
	beq	putin4
putin3
	rolb		; put object in map
	rolb
	deca
	bne	putin3
putin4
	stb	,x	; save it
	dec	count
	bne	putinm
	lda	mask
	cmpa	#3	; was object a base?
	bne	putin6
	ldb	tsave1
	andcc	#$fe
	rorb		; find position
	lda	asave
	bcc	putin5
	adda	#4
putin5
	sta	basesx	; save x position
	stb	basesy	; and y position
putin6
	rts

* check for empty sector
chkpos
	clr	flag
	stx	xtemp	; save pointer
	ldx	#secmap	; point to map
	lda	trialy	; get y position
	beq	chkpo2
chkpo1
	leax	2,x	; find in map
	deca
	bne	chkpo1
chkpo2
	lda	trialx	; get x position
	cmpa	#3
	bls	chkpo3
	leax	1,x
	suba	#4
chkpo3
	ldb	,x	; find in map
	sta	asave
	beq	chkpo5
chkpo4
	lsrb
	lsrb
	deca
	bne	chkpo4
chkpo5
	andb	#3	; is position empty?
	beq	chkpo6
	stb	flag	; if not, set flag
	tst	stcflg
	beq	chkpo6
	tst	phtflg
	bne	chkpo7
	cmpb	#2	; is it a Klingon?
	beq	chkpo7
chkpo6
	ldx	xtemp
	rts
chkpo7
	ldb	#$fc	; setup mask
	lda	asave
	beq	chkpo9
	orcc	#1
chkpo8
	rolb		; position mask
	rolb
	deca
	bne	chkpo8
chkpo9
	andb	,x	; clear out Klingon
	stb	,x
	bra	chkpo6

* fire photon torpedoes
photor
	tst	dampht	; damaged?
	beq	ptrndm
ptrnd9
	jmp	rptdam
ptrndm
	tst	photon	; any left?
	bne	photr0
	jmp	ptempt	; report empty
photr0
	inc	phtflg
	jsr	random
	anda	#$f	; set energy
	ora	#4
	sta	warp
	dec	photon

* warp engines
setcrs
	clr	sqflg
	clr	glmflg
	ldx	#crsstr	; course prompt
	jsr	pstrng
	jsr	inchck	; input course
	cmpa	#7
	bhi	abc29	; greater than 7?
	sta	course
	tst	phtflg
	bne	phtor1
	ldx	#wrpstr	; warp prompt
	jsr	pstrng
	jsr	inchck	; input w. factor
	sta	warp
	tst	pntflg	; test for dec pnt
	bne	stcrs2
	sta	sqflg	; set quad flag
	tst	dameng	; damaged?
	bne	ptrnd9
	bra	stcrs2
stcrs2
	jsr	inch	; wait for c.r.
	jsr	outch
	cmpa	#$d
	bne	stcrs2
	lda	course
phtor1
	ldx	#movtbl	; find move vector
	asla
	leax	a,x	; FIXXRG
	lda	warp	; warp = 0?
	bne	abc30
abc29
	jmp	comand
abc30
	sta	count	; set counter
	tst	sqflg
	beq	stcrs3
	lda	#$0f
	sta	count
stcrs3
	lda	curscx	; get cur position
	ldb	curscy
phtor2
	adda	,x	; add in move vect.
	addb	1,x
	jsr	tstbnd	; out of bounds?
	tst	fincx
	beq	abc1
	jmp	stcrs5	; if so, jmp ahead
abc1
	tst	fincy
	beq	abc5
	jmp	stcrs5
abc5
	sta	trialx	; save trial pos
	stb	trialy
	tst	phtflg
	beq	abc4	; if firing torp.
	jsr	pcrlf	; outupt cr & lf
	bsr	obats0	; and sector loc.
abc4
	inc	stcflg
	jsr	chkpos	; check if blocked
	lda	flag
	beq	stcrs4
	tst	phtflg
	beq	abc2
	jmp	phtor3
abc2
	cmpa	#2	; rammed Klingon?
	bne	abc3
	jmp	klgram
abc3
	ldx	#blokst	; blocked
	jsr	pstrng
obats0
	lda	trialx	; output sector
	jsr	fixout
	jsr	outdsh
	lda	trialy
	jsr	fixout
	tst	phtflg
	beq	stcret
	rts
stcret
	jmp	stcrs6
stcrs4
	tst	phtflg	; torpedo?
	beq	stcrsb	; if not, jmp ahead
	lda	trialx	; get trial pos.
	ldb	trialy
	dec	count	; dec counter
	bne	phtor2	; if no done, rtp
	jmp	phtor4
stcrsb
	lda	trialx
	sta	curscx	; update cur pos
	lda	trialy
	sta	curscy
	jsr	random
	cmpa	#$80	; inc time?
	bls	stcrsc
	lda	#1	; inc time by 1
	jsr	fixtim
	lda	#3	; inc energy
 	jsr	fixeng
stcrsc
	dec	count	; dec counter
	beq	stcrsd
	jmp	stcrs3
stcrsd
	tst	sqflg	; quadrant move?
	bne	stcrs5
	jmp	stcrs6
stcrs5
	tst	phtflg
	beq	abc6
	jmp	phtor4
abc6
	lda	warp	; restore warp
	sta	count
abc7
	lda	curqux	; get current q pos
	ldb	curquy
	tst	sqflg
	beq	stcrs7
	adda	,x	; addin move vec.
	addb	1,x
	sta	trialx
	stb	trialy
	jsr	tstbnd	; out of bounds?
	tst	fincx
	beq	abcd0
	jmp	galbnd	; if so, report
abcd0
	tst	fincy
	beq	abcd1
	jmp	galbnd
abcd1
	lda	trialx
	sta	curqux	; update cur position
	lda	trialy
	sta	curquy
	inc	glmflg	; set move flag
	lda	#6	; inc time
	jsr	fixtim
	lda	#$30	; inc energy
	jsr	fixeng
	dec	count
	bne	abc7	; not don? rpt
stcrsa
	jsr	setups	; go setup quad
stcrs6
	clr	cndflg
	lda	basex	; check if in
	cmpa	curqux	; same quadrang as
	bne	sexit1	; starbase
	ldb	basey
	cmpb	curquy
	bne	sexit1
	lda	basesx
	ldb	basesy	; docked?
	inca
	suba	curscx
	cmpa	#2
	bhi	sexit1
sexit0
	incb
	subb	curscy
	cmpb	#2
	bhi	sexit1
sdock
	lda	#2	; set cnd flag to
	sta	cndflg	; show docked
sexit1
	jmp	comand
stcrs7
	adda	fincx	; restore cur pos
	addb	fincy
	cmpa	#7	; out of galaxy?
	bhi	galbnd
	cmpb	#7
	bhi	galbnd
	sta	curqux	; save position
	stb	curquy
	lda	#7	; inc time
	jsr	fixtim
	bra	stcrsa

* rammed Klingon
klgram
	ldx	#krmstr	; report ram
	jsr	pstrng
	lda	#1
	sta	count
	clr	sqflg
	inc	hitkls
	dec	klngct	; dec Kling count
	dec	seckln
	inc	phtflg
	jsr	obats0	; output sector
	ldx	#hevdam	; heavy damage!
	jsr	pstrng
	ldb	#$6a
	jsr	mandam	; go make damage
	ldx	#stilft	; report K's left
	jsr	pstrng
	jsr	outkln
	jmp	stcrsb

* report galaxy limit
galbnd
	ldx	#glbnds	; out galaxy limit
	jsr	pstrng
	lda	galcnt
	inca
	cmpa	#3	; was it 3rd time?
	bne	galbn2
	ldx	#galdum	; if so, report
	jsr	pstrng
	jmp	endgam	; end game
galbn2
	sta	galcnt
	tst	glmflg
	bne	abc20
	jmp	stcrs6
abc20
	jmp	stcrsa

* torpedo hit object
phtor3
	ldx	#phitst	; report
	jsr	pstrng
	lda	flag
	cmpa	#2	; was it a Klingon?
	bne	abc8
	dec	seckln
	dec	klngct	; dec Klingon cnt
	inc	hitkls
	ldx	#klgstr	; report Klingon
	jsr	pdata1
	ldx	#stilft	; report # left
	jsr	pstrng
	jsr	outkln
	bra	abc10
abc8
	cmpa	#1
	bne	abc11
	inc	hitstr	; hit star
	ldx	#starst
abc9
	jsr	pdata1	; report
abc10
	jmp	comand
abc11
	ldx	#basest	; hit base
	inc	hitbas	; report
	bra	abc9

* torpedo out of energy
phtor4
	ldx	#phoeng
	jsr	pstrng	; report
	jmp	stcrs6

* test for out of bounds
tstbnd
	clr	fincx
	clr	fincy
	tsta		; test x pos.
	bpl	tstbn1
	dec	fincx
	bra	tstbn2
tstbn1
	cmpa	#7
	bls	tstbn2
	inc	fincx
tstbn2
	tstb		; test y pos.
	bpl	tstbn3
	dec	fincy
	rts
tstbn3
	cmpb	#7
	bls	tstbn4
	inc	fincy
tstbn4
	rts

* torpedo tubes empty
ptempt
	ldx	#ptemst	; report
	jsr	pstrng
	jmp	comand

* input character and check
inchck
	clra
inchk0
	sta	pntflg
	jsr	inch	; input character
	jsr	outch	; echo it
	cmpa	#'.	; is it a point?
	beq	inchk0
	cmpa	#$39	; greater than 9?
	bhi	inchk1
	cmpa	#$2f	; less than 0?
	bls	inchk1
	suba	#$30	; mask off ASCII
	rts
inchk1
	ldx	#err	; report error
	jsr	pdata1
	bra	inchck

* fix up time
fixtim
	adda	timdec	; add in decimal
	cmpa	#9	; overflow?
	bls	fixtm1
	suba	#10	; subtract 10
	sta	timdec	; save decimal
	clr	temp
	lda	#1	; add in 1
	sta	temp+1
	stx	xtemp
	ldx	#time0	; add to time
	jsr	bcdadd
	ldx	#timuse	; inc time used
	jsr	bcdadd
	jsr	fixdam	; go fix damage
	ldx	xtemp
	rts
fixtm1
	sta	timdec
	rts		; return

* fix up energy
fixeng
	stx	xtemp
	ldx	#energy	; point to energy
	clr	temp
	sta	temp+1
	jsr	bcdsub	; go subtract
	ldx	xtemp
	rts		; return

* bcd addition
bcdadd
	andcc	#$fe
	bra	bcdfix

* bcd subtract
bcdsub
	lda	#$99	; find 10's comp.
	suba	temp
	sta	temp
	lda	#$99
	suba	temp+1
	sta	temp+1
	orcc	#1

* bcd fix
bcdfix
	lda	1,x
	adca	temp+1	; add l.s. byte
	daa
	sta	1,x	; save it
	lda	,x
	adca	temp	; add m.s. byte
	daa
	sta	,x	; save it
	rts		; return

* long range scan
lrscan
	tst	damlrs	; damaged?
	beq	lrsndm
	jmp	rptdam
lrsndm
	clr	topflg	; clear flags
	clr	botflg
	clr	lsdflg
	clr	rsdflg
	ldx	#lrscst	; output quadrant
	jsr	pstrng	; being scanned
	jsr	outqud
	jsr	pcrlf
	jsr	pcrlf
	lda	curqux	; on left side?
	bne	lrscn1
	inc	lsdflg
lrscn1
	cmpa	#7	; right side?
	bne	lrscn2
	inc	rsdflg
lrscn2
	lda	curquy
	bne	lrscn3	; top of galaxy?
	inc	topflg
lrscn3
	cmpa	#7	; bottom?
	bne	lrscn4
	inc	botflg
lrscn4
	ldx	qudptr	; point to quad.
lrscnc
	lda	#$f7	; find upper left
	leax	a,x	; FIXXRG
	tst	topflg
	beq	lrscn7
	bsr	outth0
	bra	lrscn8
lrscn7
	bsr	outlin	; output 1st line
lrscn8
	lda	#5	; fix x reg
	leax	a,x	; FIXXRG
	bsr	outlin	; output 2nd line
	lda	#5
	leax	a,x	; FIXXRG
	tst	botflg
	beq	lrscn9
	bsr	outth0
	bra	lrsc10
lrscn9
	bsr	outlin	; output 3rd line
lrsc10
	jmp	comand

* output 1 line of long range scan
outlin
	lda	,x	; get quad info
	tst	lsdflg
	beq	outln1
	clra
outln1
	bsr	outqin	; output quad info
	lda	,x
	bsr	outqin	; again
	lda	,x
	tst	rsdflg
	beq	outln2
	clra
outln2
	bsr	outqin	; output 3rd quadrant
	jmp	pcrlf	; of line

* output quadrant information
outqin
	tfr	a,b
	anda	#$80	; suprnova
	andcc	#$fe
	rola
	rola
	jsr	outhr	; if so, output
	tfr	b,a
	anda	#$40	; base?
	lsra
	lsra
	jsr	outhl	; if so output
	tfr	b,a
	anda	#$38	; stars?
	asla
	jsr	outhl	; output them
	tfr	b,a
	anda	#$07	; Klingons?
	jsr	outhr	; output
	leax	1,x
	jmp	outs	; output space

* output a line of zeros
outth0
	lda	#3	; set counter
	sta	count
outth1
	clra
	bsr	outqin	; output them
	dec	count
	bne	outth1
	jmp	pcrlf	; output cr & lf

* fire phasers
phaser
	tst	damphs	; damaged?
	beq	phsndm
	jmp	rptdam
phsndm
	tst	shield	; shields down?
	beq	phasr1
	ldx	#mlshld
	bra	toomc1
phasr1
	ldx	#enavlb	; report energy
	jsr	pstrng
	ldx	energy
	stx	temp
	jsr	outbcd
	ldx	#fireng	; fire prompt
	jsr	pstrng
	jsr	inbcd	; get energy
	lda	phseng
	cmpa	energy
	bhi	toomch	; too much?
	bne	phasr2
	lda	phseng+1
	cmpa	energy+1
	bls	phasr2
toomch
	ldx	#tomuch	; report
toomc1
	jsr	pstrng
	jmp	comand
phasr2
	jsr	random	; check if misfire
	cmpa	#$f4
	bls	phasr3
	ldx	#phamis	; report if so
	jsr	pstrng
	bra	phasr6
phasr3
	lda	phseng	; fire enough?
	cmpa	klneng
	bhi	phasr4
	bne	phasr5
	lda	phseng+1
	cmpa	klneng+1
	bls	phasr5
phasr4
	clr	klneng	; clear K energy
	clr	klneng+1
	ldx	#alkill	; report all killed
	jsr	pstrng
	ldx	#stilft	; report # left
	jsr	pstrng
	ldb	seckln
	stb	hitkls
	lda	klngct	; dec kling cnt
	stb	,-s
	suba	,s+
	sta	klngct
	jsr	outkln
	clr	seckln
kilalk
	ldx	#secmap	; remove K's from q
	lda	#16
	sta	count	; setup count
kilal1
	ldb	#4
	lda	,x	; find all Klingons
kilal2
	rora
	bcs	kilal4
	rora
	bcc	kilal3
	andcc	#$fe	; clear out
kilal3
	decb
	bne	kilal2
	rora
	sta	,x
	leax	1,x
	dec	count	; if no done rpt
	bne	kilal1
	bra	phasr6
kilal4
	rora
	bra	kilal3
phasr5
	ldx	phseng
	stx	temp
	ldx	#klneng	; sub K energy
	jsr	bcdsub
	ldx	#khtadm	; report damaged
	jsr	pstrng
phasr6
	ldx	phseng
	stx	temp
	ldx	#energy
	jsr	bcdsub
	jmp	comand

* input a bcd number
inbcd
	clr	phseng
	clr	phseng+1
inbcd1
	jsr	inch	; input number
	jsr	outch
	cmpa	#$2f
	bls	exit
	bsr	check	; is it valid?
	tst	flagc
	bne	ineror
	ldb	#4	; set counter
inbcd2
	asl	phseng+1
	rol	phseng
	decb
	bne	inbcd2
	adda	phseng+1	; add in number
	sta	phseng+1
	bra	inbcd1
ineror
	ldx	#err
	jsr	pdata1	; report error
	bra	inbcd1
exit
	rts
check
	clr	flagc	; clear flag
	cmpa	#$39	; greater than 9?
	bhi	setflg
	anda	#$0f	; mask off
	rts
setflg
	inc	flagc	; inc flag
	rts

* self destruct
selfde
	ldx	#intro0	; ask for password
	jsr	pstrng
	ldx	#paswrd
	ldb	#3
selfd1
	jsr	inch	; input word
	cmpa	,x
	bne	selfd2
	leax	1,x
	decb
	bne	selfd1	; if not =, jmp ahead
selfda
	ldx	#disint	; disintegrate
	jsr	pstrng
	jmp	endgam
selfd2
	ldx	#abort	; abort sequence
	jsr	pstrng
	jmp	comand

* teleporter
telept
	lda	#$12	; 12 years used?
	cmpa	timuse+1
	bhi	telep2
	tst	telflg
	bne	telep4
	jsr	random	; maybe damage
	cmpa	#$b0
	bls	telep1
	inc	telflg
telep1
	jsr	random	; malfunction?
	cmpa	#$b0
	bhi	telep5	; if not, put
	lda	basex	; Enterprise in
	sta	curqux	; quad. with base
	lda	basey
	sta	curquy
telepa
	jmp	stcrsa
telep2
	ldx	#cantus	; too early
telep3
	jsr	pstrng
	jmp	comand
telep4
	ldx	#dmgdst	; damaged
	bra	telep3
telep5
	jsr	random	; malfunction!
	anda	#7	; generate random
	sta	curqux	; quadrant
	jsr	random
	anda	#7
	sta	curquy
	ldx	#somwhr	; report
	jsr	pstrng
	bra	telepa

* Klingons attack
attack
	tst	seckln	; any Klingons?
	bne	attac1	; if not, return
	rts
attac1
	jsr	random	; maybe won't
	cmpa	#$b0
	bhi	attac2
	ldx	#atkeng	; get K energy
	ldb	seckln
	aslb
	jsr	cscext	; find total energy
	ldx	atkeng
	stx	temp
	tst	shield	; shields up?
	bne	attac3
	ldx	#energy	; if not, must
	jsr	bcdsub	; sub internal nrgy
	jsr	pcrlf
	jsr	pcrlf
	ldx	atkeng
	stx	temp
	jsr	outbcd
	ldx	#katkdn	; report attack
	jsr	pdata1
	ldb	#$fa	; go make damage
	jsr	mandam
attac2
	rts
attac3
	ldx	#shengy	; sub attack
	jsr	bcdsub	; from shields
	ldx	#katkup	; report
	jmp	pstrng

* end of game clean up
nrgout
	ldx	#nmengs	; out of energy
nrgou1
	jsr	pstrng
	bra	endgam
nomtim
	ldx	#nmtmst	; out of time
	bra	nrgou1
nomkln
	ldx	#nmklst	; all Klingons gone!
	jsr	pstrng
	bsr	endgm2
endgam
	ldx	#failst	; output failure
	jsr	pstrng
	bra	endgm3
endgm2
	ldx	#succst	; output success
	jsr	pstrng
endgm3
	ldx	#playag	; play again??
	jsr	pstrng
	jsr	inch	; get response
	jsr	outch
	anda	#$df
	cmpa	#'N
	beq	endgm4
	jmp	spavoy
endgm4
	jmp	$e000

* clear out curent quadrant
clrcqu
	ldx	qudptr	; point to quad
	lda	,x
	suba	hitkls	; clear Klingons
	ldb	hitstr	; clear stars
	aslb
	aslb
	aslb
	stb	,-s
	suba	,s+
	tst	hitbas	; clear base
	beq	clrcq2
	anda	#$bf
	ldb	#$a
	stb	basex
	stb	basey
	clr	cndflg
clrcq2
	sta	,x
	clra		; clear all flags
	sta	hitkls
	sta	hitstr
	sta	hitbas
	rts		; return

* fix damage
fixdam
	ldx	#dameng	; pnt to damage
	ldb	#6	; set counter
fixdm1
	tst	,x
	beq	fixdm2
	dec	,x
fixdm2
	leax	1,x	; loop til done
	decb
	bne	fixdm1
	rts

* supernova generator
supnov
	jsr	random	; get random coord.
	anda	#7
	tfr	a,b
	jsr	random
	anda	#7
	stb	tsave1	; save
	ldx	#qudmap	; pnt to map
	inc	stpsfl
	jsr	stpsex
	ldb	,x
	andb	#7	; clear any Klingons
	lda	klngct
	stb	,-s
	suba	,s+
	sta	klngct
	lda	#$80	; clear out rest
	sta	,x
	ldx	#supstr
	jsr	pstrng	; report supnov
	lda	asave
	jsr	fixout	; output its loc.
	jsr	outdsh
	lda	tsave1
	jsr	fixout
	jmp	comand

* generate main damage
mandam
	ldx	#dameng	; pnt to damage
mandm1
	jsr	random
	stb	,-s
	cmpa	,s+
	bls	mandm2
	jsr	random	; set random years
	anda	#3
	orcc	#1
	adca	,x	; add in damage
	sta	,x
mandm2
	leax	1,x
	cmpx	#supflg
	bne	mandm1	; loop til done
	tst	damshl
	beq	mandm3	; lower shields
	clr	shield	; if damaged
mandm3
	rts

* report damage
rptdam
	ldx	#dmgdst	; output damage
	jsr	pstrng
rptdm8
	jmp	comand

* damage report
damrpt
	ldx	#dmrpst	; pnt to damage
	jsr	pstrng
	ldx	#devstr	; pnt to device
	stx	temp2
	ldx	#dameng
dmrpt2
	tst	,x	; see if damaged
	beq	bmpx4
	stx	temp3
	ldx	temp2
	jsr	pstrng	; if it is, report
	leax	1,x
	stx	temp2
	ldx	temp3
	ldb	#3	; setup space cnt
outs4
	jsr	outs	; output space
	decb
	bne	outs4	; if not 3, rpt
	lda	,x
	jsr	outk0	; output status
dmrpt4
	leax	1,x
	cmpx	#supflg	; loop til done
	bne	dmrpt2
	bra	rptdm8
bmpx4
	stx	temp3	; save x
	ldx	temp2
	leax	4,x
	stx	temp2
	ldx	temp3	; restore x
	bra	dmrpt4

* strings
title	fcb	$a
	fcc	;Space Voyage V3.2;
	fcb	0
shtlng	fcb	$a
	fcc	;S or L? ;
	fcb	0
upscas	fcc	; up;
	fcb	0
basinf	fcb	$a
	fcc	;Base in Q;
	fcb	0
docked	fcc	;Docked;
	fcb	0
dnscas	fcc	; dn;
	fcb	0
ptemst	fcc	;Tubes empty;
	fcb	0
intro1	fcb	$a,$a
	fcc	;Date: ;
	fcb	0
intro2	fcc	;Klingons: ;
	fcb	0
intro3	fcc	;Years: ;
	fcb	0
intro4	fcc	;Quadrant: ;
	fcb	0
intro6	fcc	;Sector: ;
	fcb	0
comst	fcb	$a
	fcc	;Command: ;
	fcb	0
dwnst	fcc	;Shields Down!;
	fcb	0
upstr	fcc	;Shields up;
	fcb	0
crsstr	fcc	;Course: ;
	fcb	0
wrpstr	fcc	;Warp factor: ;
	fcb	0
blokst	fcc	;Blocked at S;
	fcb	0
krmstr	fcc	;Rammed Klingon at S;
	fcb	0
glbnds	fcc	;Galaxy limit;
	fcb	0
phitst	fcc	;Torpedo hit ;
	fcb	0
phoeng	fcc	;Out of energy;
	fcb	0
sdate	fcc	;  S.Date: ;
	fcb	0
cndtns	fcc	;  Cndtn: ;
	fcb	0
yellow	fcc	;Yellow;
	fcb	0
red	fcc	;Red;
	fcb	0
green	fcc	;Green;
	fcb	0
quadp	fcc	;  Qudrnt: ;
	fcb	0
secp	fcc	;  Sector: ;
	fcb	0
engstr	fcc	;  Energy: ;
	fcb	0
klstr	fcc	;  Klingons: ;
	fcb	0
shstr	fcc	;  Shlds: ;
	fcb	0
trpstr	fcc	;  Torpedo: ;
	fcb	0
crlfst	fcb	$d,$a,0
lrscst	fcb	$a
	fcc	;Scan for Q;
	fcb	0
mlshld	fcc	;Must lower shields;
	fcb	0
enavlb	fcc	;Energy available: ;
	fcb	0
fireng	fcc	;Energy = ;
	fcb	0
tomuch	fcc	;Enery too low;
	fcb	0
phamis	fcc	;Misfire!;
	fcb	0
alkill	fcc	;All local Klingons destroyed!;
	fcb	0
khtadm	fcc	;Enemy damaged;
	fcb	0
err	fcc	; ? ;
	fcb	0
starst	fcc	;Star;
	fcb	0
basest	fcc	;Base;
	fcb	0
klgstr	fcc	;Klingon;
	fcb	0
intro0	fcb	$a
	fcc	;Password.. ;
	fcb	0
stilft	fcc	;Klingons left = ;
	fcb	0
katkdn	fcc	; units hit Enterprise;
	fcb	0
katkup	fcb	$a
	fcc	;Klingons attack: shields holding;
	fcb	0
disint	fcc	;Enterprise disintegrates;
	fcb	0
abort	fcc	;Sequence abort: password;
	fcb	0
cantus	fcc	;Too early!;
	fcb	0
somwhr	fcc	;Malfunction!;
	fcb	0
spstrm	fcb	$a,7
	fcc	;Space storm: Shields damaged!;
	fcb	0
galdum	fcb	$a,7
	fcc	;Ship is fried for 3rd attempt!;
	fcb	0
nmengs	fcb	7
	fcc	;Energy = 0;
	fcb	0
nmtmst	fcb	7
	fcc	;Time up!;
	fcb	0
nmklst	fcb	$a,7
	fcc	;Congratulations!;
	fcb	$d,$a,0
failst	fcc	;Mission a failure;
	fcb	0
succst	fcc	;The Federation is saved!;
	fcb	0
supdes	fcc	;Supernova!;
	fcb	0
supstr	fcb	$a,7
	fcc	;Supernova in Q;
	fcb	0
hevdam	fcc	;Badly ;
dmgdst	fcc	;Damaged;
	fcb	0
dmrpst	fcb	$a
	fcc	;Dev  Stat;
	fcb	0
devstr	fcc	;Eng;
	fcb	0
	fcc	;SRS;
	fcb	0
	fcc	;LRS;
	fcb	0
	fcc	;Phs;
	fcb	0
	fcc	;Trp;
	fcb	0
	fcc	;Shl;
	fcb	0
playag	fcb	$a
	fcc	;Play again? ;
	fcb	0

random
	stb	,-s
	ldb	#8
rpt
	lda	rndm+3
	asla
	asla
	asla
	eora	rndm+3
	asla
	asla
	rol	rndm
	rol	rndm+1
	rol	rndm+2
	rol	rndm+3
	decb
	bne	rpt
	ldb	,s+
	lda	rndm
	rts

rndm	rmb	4
