;sysgen
;version 2.15-a
;released:	30 november 1985 (2.10)
;last revised:	2 may 1996 (2.11)
;			eliminated word mode for 1024 blocks
;			made extent a single byte
;		3 may 1996 (2.12)
;			added initial exm related code
;		11 may 1996 (2.13)
;			added use of exm in getblk
;			added code to set exm & cexm1f
;			corrected errors
;		19 may 1996 (2.14)
;			changed ccm ren to "to from" syntax
;			allowed _ in file names
;		13 march 2008 (2.15)
;			reformatted for TASM & ASM210+
;			eliminated dependence on "IBM" format
;			  by reading first sector # using SIM+51
;			  TRANSLATE code. If translate
;			  does not have first physical sector in first
;			  position this approach may not work.
;			  SIM can also perform no translation at all.
;			  Also assumes BOOT & SIM both know correct
;			  starting sector for cold & warm boot. It
;			  should work regardless of physical sector
;			  size as long as existing SIM is configured
;			  correctly for destination drive. BOOT
;			  must correctly handle sectors > 128 bytes
;			  as must WARM BOOT in SIM.
;			  In any case BOOT and WARM BOOT must
;			  read sectors in sequential order, i.e.,
;			  no interleave.
;this program contains the complete dos/65 operating
;system except for the boot and sim.
;when used by the system operator this program
;provides the capability to construct a new
;operating system including the users boot and sim.
;the system is relocated to fit the memory size
;specified by the user and is written onto
;the system tracks of the specified drive.
;improvements over version 2.0 include:
;	use of "from to" syntax for ren
;	addition of go command
;	addition of load command
;	ability to enter numbers as decimal or hex
;	address parameter added to save
;	error checking in sysgen (write)
;	write type for deblocking added
;	page zero 0 & 1 not used
;	allow _ in file names
;base addresses and definitions
btejmp	=	$100		;warm boot jump
pemjmp	=	$103		;jump to pem
iostat	=	$106		;i/o status
dflfcb	=	$107		;default fcb
dflbuf	=	$128		;default buffer
tea	=	$800		;tea start
ccmlng	=	2048		;ccm length
pemlng	=	3072		;pem length
paglim	=	ccm+ccmlng+pemlng/256+1	;allow one page for sim
;zero page for setup
	*=	$02
trknum				;current track
	*=	*+2
dcbadd				;dcb address
	*=	*+2
nmsstr				;number system tracks
	*=	*+2
nsectr				;number sectors per track
	*=	*+2
ttlsec				;total sectors to write
	*=	*+1
trkcnt	=	ttlsec
size				;ascii size
	*=	*+2
lokim				;low kim limit
	*=	*+2
hikim				;high kim limit
	*=	*+2
offset				;relocation offset
	*=	*+2
kimcnt				;kim counter
	*=	*+1
pointr				;pointer
	*=	*+2
lengt				;inst length
	*=	*+1
point				;relocate pointer
	*=	*+2
adjust				;relocate distance
	*=	*+2
kimpnt				;kim file index
	*=	*+1
savex				;save for x
	*=	*+1
savey				;save for y
	*=	*+1
number				;input pack buffer
	*=	*+2
dstdrv				;destination drive
	*=	*+1
defalt				;default drive
	*=	*+1
seccnt				;sector count
	*=	*+2
secnum				;sector number
	*=	*+2
curccm				;start of current ccm
	*=	*+2
simlng				;length of sim
	*=	*+2
room				;memory needed for sysgen
	*=	*+2
stksav				;save stack register
	*=	*+1
frstsc				;first sector number of disk
	*=	*+1
lastzp
;fixed parameters
lf	=	$a		;linefeeed
cr	=	$d		;return
eof	=	$1a		;end of file
null	=	0		;null
ctlc	=	3		;abort
ctle	=	5		;physical cr lf
ctli	=	9		;tab character
ctlp	=	$10		;toggle printer
ctlr	=	$12		;repeat line
ctls	=	$13		;freeze
ctlx	=	$18		;cancel
semico	=	$3b		;semicolon
delete	=	$7f		;delete character
numcmd	=	36		;number commands
;main program
	*=	tea
	jmp	sysgen		;jump to main
;copyright notice
	.byte	"COPYRIGHT (C) 2008 - "
	.byte	"RICHARD A. LEARY"
sysgen	ldy	btejmp+2	;get sim page from boot vector
	sty	jshome+2
	sty	jsseld+2
	sty	jssett+2
	sty	jssets+2
	sty	jssetd+2
	sty	jswrit+4
	sty	jsxlat+2
;initialize
	ldx	#2		;set start location
	lda	#0		;clear accum
clrzp	sta	$00,x		;clear mem
	inx			;bump index
	cpx	#lastzp		;see if past end
	bne	clrzp		;loop if not
;save stack register for exit
	tsx			;move to x
	stx	stksav		;save it
;calculate current ccm start
	sec			;set carry
	lda	pemjmp+1	;subtract ccm length from pem start
	sbc	#<ccmlng
	sta	curccm
	lda	pemjmp+2
	sbc	#>ccmlng
	sta	curccm+1
	lda	#<opnmsg	;send
	ldy	#>opnmsg	;"opening"
	jsr	wrtmsg		;message
	ldx	#25		;read
	jsr	pemjmp		;default drive
	sta	defalt		;and save
	jsr	gns		;get new size
	jsr	bcdbyt		;pack into byte
	sta	adjust		;and save
;convert xx k to bytes
	ldx	#10		;multiply
m1024	asl	adjust		;by
	rol	adjust+1	;1024
	dex			;to get
	bne	m1024		;size in bytes
;calculate room available for sysgen
	lda	adjust		;get msize
	ldy	adjust+1
	sec			;now subtract ccm image start
	sbc	#<ccm
	sta	room		;and save
	tya
	sbc	#>ccm
	sta	room+1
	lsr	room+1		;divide by two
	ror	room
;get sim length
	lda	#0		;clear size
	sta	size
	sta	size+1
	jsr	gss
	jsr	bcdbyt		;pack into byte
	sta	simlng		;and save
;convert xx pages to bytes
	ldx	#8
m256	asl	simlng		;multiply
	rol	simlng+1
	dex
	bne	m256
;calculate new system length
	clc			;by adding sim length to syslng
	lda	syslng
	adc	simlng
	sta	syslng
	lda	syslng+1
	adc	simlng+1
	sta	syslng+1	;and saving
;calculate new system start
	sec			;subtract
	lda	adjust		;system
	sbc	syslng		;length
	sta	adjust		;from
	lda	adjust+1	;top
	sbc	syslng+1	;limit to
	sta	adjust+1	;get new start
;make sure another sysgen is possible
	lda	room		;see if room
	cmp	syslng		;is >= syslng
	lda	room+1
	sbc	syslng+1
	bcs	rmok		;ok if is
	lda	#<bigmsg	;else send too big message
	ldy	#>bigmsg
	jmp	errext		;and exit
;now calculate relocation distance
rmok	sec			;now
	lda	adjust		;subtract
	sbc	#<ccm		;old start
	sta	adjust		;from new
	lda	adjust+1	;to get
	sbc	#>ccm		;relocation
	sta	adjust+1	;distance
;relocate ccm
	lda	#<ccm		;set
	ldy	#>ccm		;pointer
	sta	point
	sty	point+1
	jsr	strtrl		;relocate it
;then pem
	lda	#<pem		;set
	ldy	#>pem		;pointer
	sta	point
	sty	point+1
	jsr	strtrl		;do it
;get new boot and sim
	jsr	gnbte		;get new boot
	jsr	gnsim		;and sim
;write system to specified drive
wrtdrv	lda	#<crtmsg	;send
	ldy	#>crtmsg	;"dest drive"
	jsr	wrtmsg		;message
	jsr	rinclw		;get answer
	cmp	#'A'		;if less than "A"
	bcc	invd		;try again
	cmp	#'H'+1		;if over "H"
	bcs	invd		;also try again
	and	#%1111		;look at lsbs
	sec			;drop
	sbc	#1		;one
	sta	dstdrv		;and save
	iny			;if
	lda	ctxt,y		;anything else
	bne	invd		;is error
	lda	dstdrv		;get drive
	jsr	jsseld		;and set
	sta	dcbadd		;save dcb address
	sty	dcbadd+1
	ora	dcbadd+1	;see if legal
	bne	vld		;ok if not zero
invd	lda	#<invmsg	;else point to invalid drive message
	ldy	#>invmsg
	jsr	wrtmsg		;send it
	jmp	wrtdrv		;and try again
vld	ldy	#2		;get sectors per track
	lda	(dcbadd),y
	sta	nsectr
	iny
	lda	(dcbadd),y
	sta	nsectr+1
	iny			;get number systems tracks
	lda	(dcbadd),y
	sta	nmsstr
	iny
	lda	(dcbadd),y
	sta	nmsstr+1
;send a logical sector 0 to translate to determine first physical sector
	lda	#0		;low and high to 0
	tay
	jsr	jsxlat		;and translate
;only look at low - assume first is probably 0 or 1
	sta	frstsc		;and save
;calculate actual amount of data to write
	lda	pointr		;see if part
	and	#$7f		;of a sector
	beq	whlsec		;no so ok as is
	lda	pointr		;get again
	and	#$80		;capture mod 128
	clc			;then add 128
	adc	#128
	sta	pointr
	bcc	*+4		;with carry
	inc	pointr+1
whlsec	sec			;calculate actual data length
	lda	pointr
	sbc	#<ccm
	sta	syslng
	lda	pointr+1
	sbc	#>ccm
	sta	syslng+1	;and save
;calculate total sector count
	lda	syslng
	ldx	#7		;divide by 128
d128	lsr	syslng+1
	ror	a
	dex
	bne	d128
	clc			;add one for boot
	adc	#1
	sta	ttlsec
;calculate number of tracks needed
	ldx	#0		;use x as counter
	lda	ttlsec		;get total
tcntl	inx
	sec
	sbc	nsectr		;drop by number in track
	beq	*+4		;done if zero
	bcs	tcntl		;loop if more
	stx	trkcnt		;set counter
	dex			;drop for compare
	cpx	nmsstr		;compare to avail
	bcs	romerr		;error if too big
	jsr	jshome		;home it
	lda	#<boot		;set pointer
	ldy	#>boot		;to
	sta	pointr		;boot
	sty	pointr+1	;start
wrsysl	jsr	writit		;write a track
	dec	trkcnt		;drop count
	bne	wrsysl		;loop if more
;done - clean up and exit
cupext	jsr	stdfbf		;point back to default
	ldx	stksav		;get stack register
	txs			;and set
	lda	defalt		;get default
	jmp	jsseld		;select it
;room error exit
romerr	lda	#<rommsg	;send not enough track message
	ldy	#>rommsg
errext	jsr	wrtmsg
	jmp	cupext		;clean up and exit
;pack bcd size into byte
bcdbyt	clc			;clear carry
	lda	#0		;and accum
	ldx	#10		;then add high
	adc	size+1		;to accum
	dex			;10
	bne	*-3		;times
	adc	size		;then add low
	rts			;and quit
;jumps to sim routines
;only the low part of the address is shown here - page is captured from
;existing warm boot entry point
;home
jshome	jmp	24
;select drive
jsseld	jmp	27
;set track
jssett	jmp	30
;set sector
jssets	jmp	33
;set dma
jssetd	jmp	36
;translate sectort
jsxlat	jmp	51
;write sector
jswrit	lda	#1		;force immediate write
	jsr	42
	and	#$ff		;check for error
	bne	twrerr		;if so quit
	rts
twrerr	lda	#<wermsg	;point to error msg
	ldy	#>wermsg
	jmp	errext		;and exit
;write nsectr sectors (records) in track
writit	lda	trknum		;get track number
	ldy	trknum+1
	jsr	jssett		;set it
	inc	trknum		;bump for next
	bne	*+4
	inc	trknum+1
	lda	nsectr		;set counter
	ldy	nsectr+1
	sta	seccnt		;to number sectors in track
	sty	seccnt+1
	lda	frstsc		;from value captured earlier
	ldy	#0		;set starting sector
	sta	secnum		;number (probably 0 or 1)
	sty	secnum+1
wrtslp	lda	secnum		;get sector number
	ldy	secnum+1
	jsr	jssets		;set it
	lda	pointr		;get
	ldy	pointr+1	;pointer
	jsr	jssetd		;set address
	jsr	jswrit		;write sector
	clc			;then
	lda	pointr		;bump
	adc	#128		;by
	sta	pointr		;128
	bcc	*+4		;for
	inc	pointr+1	;next
	inc	secnum		;bump sector number
	bne	*+4
	inc	secnum+1
	lda	seccnt
	bne	*+4
	dec	seccnt+1
	dec	seccnt		;drop count
	lda	seccnt
	ora	seccnt+1
	bne	wrtslp		;loop if more
	rts
;get new boot
gnbte	lda	#<btemsg	;send
	ldy	#>btemsg	;"boot name"
	jsr	wrtmsg		;message
	jsr	rinclw		;get response
	jsr	inptfn		;convert to fcb
	bcs	gnberr		;branch if error
	lda	#<boot		;offset
	ldy	#>boot		;is same
	sta	offset		;as boot
	sty	offset+1	;start
	sta	lokim		;as is lower
	sty	lokim+1		;limit
	lda	#boot+128*256/256	;set
	ldy	#boot+128/256	;upper
	sta	hikim		;limit
	sty	hikim+1		;then
	jsr	xqread		;read file
	bcs	gnberr		;branch if error
	rts
gnberr	lda	#<flemsg	;send
	ldy	#>flemsg	;"file error"
	jmp	errext		;message and exit
;get new sim
gnsim	lda	#<simmsg	;send
	ldy	#>simmsg	;"sim name"
	jsr	wrtmsg		;message
	jsr	rinclw		;get input
	jsr	inptfn		;convert to fcb
	bcs	gnsirr		;branch if error
	lda	#<sim		;set lower
	ldy	#>sim		;limit
	sta	lokim		;for
	sty	lokim+1		;load
	lda	curccm		;and
	ldy	curccm+1	;upper
	sta	hikim		;limit
	sty	hikim+1		;for load
	lda	adjust		;get
	ldy	adjust+1	;relocation
	eor	#$ff		;distance
	sta	offset		;and
	tya			;complement
	eor	#$ff		;it
	sta	offset+1	;then
	inc	offset		;bump to
	bne	*+4		;get
	inc	offset+1	;load offset
	jsr	xqread		;read file
	bcs	gnsirr		;branch if error
	rts
gnsirr	jmp	gnberr		;error exit
;relocation routine
; point must be set to first code byte of segment
; to relocate. paglim must be set to
; upper address change limits.
strtrl	ldy	#0		;get opcode
	lda	(point),y	;from memory
	tay			;save in y
	ldx	#7		;search seven
rlloop	tya			;get opcode
	and	table1-1,x	;remove bits
	eor	table2-1,x	;test rest
	beq	gotopc		;if zero a match
	dex			;else try
	bne	rlloop		;next
gotopc	ldy	table3,x	;get length/flag
	bpl	skipby		;no change if positive
	iny			;add one
	bmi	exrelc		;exit if terminator
	iny			;else add one more
	lda	(point),y	;get low
	tax			;save in x
	iny			;then get
	lda	(point),y	;high
	cmp	#<paglim	;if at high limit
	bcs	norelc		;do nothing
	cmp	#tea+1/256	;if above
	bne	trylow		;lower limit
	cpx	#tea+1*256/256	;then
trylow	bcc	norelc		;do nothing
	pha			;else save high
	txa			;add offset
	clc			;to low
	adc	adjust		;and then
	tax			;save
	pla			;get high
	adc	adjust+1	;add again
norelc	sta	(point),y	;put back
	dey			;backup
	txa			;get low
	sta	(point),y	;save
	ldy	#3		;go up three
skipby	inc	point		;add one
	bne	*+4		;with
	inc	point+1		;carry
	dey			;loop if
	bne	skipby		;more
	beq	strtrl		;then start over
exrelc	rts
;relocation tables
table1	.byte	$c,$1f,$d,$87,$1f,$ff,$3
table2	.byte	$c,$19,$8,$0,$10,$20,$3
table3	.byte	2,$ff,$ff,1,1,2,$ff,$fe
;read input and convert lower case to upper
; error if no input or if input is all blanks.
; at exit y is index into ctxt
;         a is character at ctxt,y
rinclw	lda	#<cbuf		;point to
	ldy	#>cbuf		;buffer
	jsr	rdeinp		;read input
	lda	#lf		;send
	jsr	charot		;a lf
	ldy	#0		;clear index
	ldx	clng		;get length
	beq	rdiner		;error if zero
lwrcnv	lda	ctxt,y		;get char
	cmp	#'a'		;if less than a
	bcc	dochg		;is ok
	cmp	#'z'+1		;if over z
	bcs	dochg		;is ok
	and	#%01011111	;else convert
	sta	ctxt,y		;and save
dochg	iny			;bump index
	dex			;drop count
	bne	lwrcnv		;loop if more
	txa			;clear a
	sta	ctxt,y		;insert zero
	tay			;clear index
	jsr	spcskp		;find first non-blank
	beq	rdiner		;error if none
	rts			;else ok
rdiner	lda	#<iermsg	;point to
	ldy	#>iermsg	;input error message
	jsr	wrtmsg		;print it
	jmp	rinclw		;try all over
;check for decimal
; if decimal then c=1 else c=0
chkdec	cmp	#'0'		;if less than "0"
	bcc	*+7		;not number
	cmp	#'9'+1		;if less than "9"+1
	bcc	*+4		;is a number
	clc			;not a number
	rts
	sec			;a number
	rts
;get and save sim length
gss	lda	#<nwsmsg	;send "enter size"
	ldy	#>nwsmsg	;message
	jsr	wrtmsg
gssagn	jsr	rinclw		;get input
	jsr	chkdec		;see if first is decimal
	bcc	gsserr		;error if not
	cmp	#'1'		;if at least 1 is ok
	bcc	gsserr		;else error
	and	#%00001111	;get low nibble
	tax			;save in x
	sta	size+1		;store in high
	iny			;next char
	lda	ctxt,y		;get it
	bne	not1pg		;if not zero more than one
	stx	size		;else set low to old high
	sta	size+1		;and clear high
	rts
not1pg	jsr	chkdec		;see if decimal
	bcc	gsserr		;error if not
	and	#%00001111	;get nibble
	sta	size		;put in low
	iny			;next char
	lda	ctxt,y		;get it
	bne	gsserr		;error if not end
	rts
gsserr	lda	#<iermsg	;send illegal input message
	ldy	#>iermsg
	jsr	wrtmsg
	jmp	gssagn		;and loop
;get and save new memory size
; check for decimal and for 64k>=size>=16k
gns	lda	#<szemsg	;send
	ldy	#>szemsg	;"enter size"
	jsr	wrtmsg		;message
gnsagn	jsr	rinclw		;get input
	jsr	chkdec		;test for decimal
	bcc	gnserr		;error if not
	cmp	#'6'+1		;if over "6"
	bcs	gnserr		;is error
	cmp	#'0'		;if "0"
	beq	gnserr		;is error
	tax			;save in x
	and	#%00001111	;get low nibble only
	sta	size+1		;else save
	iny			;move to next
	lda	ctxt,y		;get char
	jsr	chkdec		;test it also
	bcc	gnserr		;error if not decimal
	cpx	#'1'		;if not one
	bne	gns20		;is 20 or more
	cmp	#'6'		;but if low under 6
	bcc	gnserr		;is an error
	bcs	gnshi		;else is ok (17 to 19)
gns20	cpx	#'6'		;if high not 6
	bne	gnshi		;is ok (20 to 59)
	cmp	#'4'+1		;if low over 4
	bcs	gnserr		;is error
gnshi	and	#%00001111	;get low nibble
	sta	size		;else ok so save low
	iny			;look past number
	lda	ctxt,y		;get char
	bne	gnserr		;error if not null
	rts			;else ok
gnserr	lda	#<iermsg	;send
	ldy	#>iermsg	;"illegal input"
	jsr	wrtmsg		;message
	jmp	gnsagn		;try again
;input file designator
; at input y must be set to first non-blank of field
inptfn	ldx	#11		;fill
	lda	#' '		;name
	sta	dflfcb,x	;and
	dex			;type
	bne	*-4		;with spaces
	inx			;set index to one
	lda	ctxt,y		;get first char
	and	#%00001111	;convert to number
	sta	dflfcb		;set automatic
	iny			;point to next
	lda	ctxt,y		;get char
	cmp	#':'		;if : then
	beq	getnme		;then continue
	dey			;else backup
	dey			;two places
	lda	#0		;then clear
	sta	dflfcb		;automatic
getnme	iny			;go to next
gtmrnm	lda	ctxt,y		;get char
	beq	endall		;over if none
	jsr	lgltst		;make sure its legal
	beq	inperr		;if not error
	sta	dflfcb,x	;else put in fcb
	iny			;point to
	inx			;next positions
	cpx	#9		;if not to big
	bne	gtmrnm		;get more
	lda	ctxt,y		;get input
	bne	inperr		;then error
endall	dex			;and if no
	beq	inperr		;input is error
	clc			;no error
	rts			;else return
inperr	sec			;error
	rts
;read kim file
xqread	lda	#0		;clear
	ldx	#32		;fcb
zerfcb	sta	dflfcb,x	;except
	dex			;for name
	cpx	#11		;and type
	bne	zerfcb		;and drive
	ldx	#2		;set to
typset	lda	kimtyp,x	;move kim
	sta	dflfcb+9,x	;type to fcb
	dex			;count down
	bpl	typset		;and loop until done
	jsr	opndfl		;try to open
	bpl	*+5		;got it
	jmp	xqrerr		;else error
	lda	#128		;set pointer
	sta	kimpnt		;to illegal
kimlop	jsr	getchr		;get char
	bcc	*+5		;continue if ok
	jmp	xqrerr		;else error
	cmp	#'$'		;if $
	beq	endkim		;then done
	cmp	#eof		;if eof
	beq	endkim		;then done
	cmp	#semico		;if not file mark
	bne	kimlop		;try again
	jsr	gettwo		;get count
	beq	endkim		;done if zero
	sta	kimcnt		;set count
	jsr	gettwo		;get high addr
	sta	pointr+1	;and save
	jsr	gettwo		;get low addr
	clc			;add
	adc	offset		;offset
	sta	pointr		;and save
	pha			;locally
	lda	pointr+1	;get high
	adc	offset+1	;add offset
	sta	pointr+1	;and save
	tay			;set high
	pla			;and low
	pha			;save low again
	cmp	lokim		;see if
	tya			;too
	sbc	lokim+1		;small
	pla			;get low back
	bcs	*+5		;if ok continue
	jmp	xqrerr		;else error
	clc			;add
	adc	kimcnt		;count
	bcc	*+3		;to start
	iny			;and save
	sec			;set carry
	sbc	#1		;drop
	bcs	*+3		;by one to
	dey			;get last address
	cmp	hikim		;see if
	tya			;too
	sbc	hikim+1		;big
	bcc	*+5		;if ok continue
	jmp	xqrerr		;else error
kmhiok	jsr	gettwo		;get byte
	ldy	#0		;clear index
	sta	(pointr),y	;store byte
	inc	pointr		;bump low
	bne	*+4		;done if not zero
	inc	pointr+1	;else bump high
	dec	kimcnt		;count down
	bne	kmhiok		;loop if more
	jsr	gettwo		;ignore
	jsr	gettwo		;checksum
	jmp	kimlop		;and loop
endkim	clc			;no error
	rts
xqrerr	sec			;error
	rts
;skip blanks
spcskp	lda	ctxt,y		;get char
	beq	spcext		;done if none
	cmp	#' '		;if not space
	bne	spcext		;then done
	iny			;else loop
	bne	spcskp		;and try again
spcext	rts
;test for illegal
; if an error then z=1 else z=0
lgltst	lda	ctxt,y		;get char
	beq	lglext		;done if null
	cmp	#' '		;if less than space
	bcc	inptbd		;is an error
	beq	lglext
	cmp	#'?'
	beq	lglext
	cmp	#'*'
	beq	lglext
	cmp	#'='
	beq	lglext
	cmp	#'.'
	beq	lglext
	cmp	#':'
	beq	lglext
	cmp	#semico
	beq	lglext
	cmp	#'<'
	beq	lglext
	cmp	#'>'
lglext	rts
inptbd	lda	#0		;error
	rts
;get character
getchr	ldx	kimpnt		;get pointer
	bpl	noread		;if ok use
	jsr	rdedfl		;else read
	beq	getok		;if ok continue
	bpl	*+5		;ok if eof
	jmp	gcerr		;else error
	lda	#eof		;get an eof
	sta	dflbuf		;put in buffer
	lda	#0		;clear a to
getok	tax			;clear index
	stx	kimpnt		;and pointer
noread	inc	kimpnt		;bump pointer
	lda	dflbuf,x	;get char
	and	#%01111111	;mask out parity
	clc			;no error
	rts
gcerr	sec			;read error
	rts
;get byte
gettwo	lda	#0		;clear
	sta	number		;buffer
	sta	number+1	;so no error
	jsr	getone		;get nibble
	bcs	geterr		;branch if error
getone	jsr	getchr		;get char
	bcs	geterr		;branch if error
	jsr	pack		;pack and convert
	bcs	geterr		;error if carry
	lda	number		;else get result
	clc			;no error
geterr	rts
;pack ascii
pack	cmp	#'0'		;if too small
	bmi	packer		;then error
	cmp	#'9'+1		;if "0" to "9"
	bmi	decnum		;is decimal
	cmp	#'A'		;if less than "A"
	bmi	packer		;then error
	cmp	#'F'+1		;if more than "F"
	bpl	packer		;then error
	clc			;else add
	adc	#9		;nine
decnum	rol	a		;move
	rol	a		;to
	rol	a		;high
	rol	a		;nibble
	ldx	#4		;shift
packlp	rol	a		;input
	rol	number		;and
	rol	number+1	;buffer
	bcs	packer		;error if carry
	dex			;count down
	bne	packlp		;and loop
	rts
packer	sec			;error
	rts			;return
;output space
outspc	lda	#' '		;get space
;output with save
charot	pha			;save char
	stx	savex		;save x
	sty	savey		;and y
	jsr	outchr		;send
	ldy	savey		;restore
	ldx	savex		;x and y
	pla			;then char
	rts
;default file references
stdfbf	lda	#<dflbuf	;point to
	ldy	#>dflbuf	;default buffer
bufset	ldx	#26		;set dma
	bne	topem
opndfl	ldx	#15		;open file
	bne	setdfl
rdedfl	ldx	#20		;read record
setdfl	lda	#<dflfcb	;point to
	ldy	#>dflfcb	;default fcb
	jmp	topem		;go
;general pem references
chrinp	ldx	#1		;character input
	bne	topem
outchr	ldx	#2		;character output
	bne	topem
wrtmsg	ldx	#9		;write message
	bne	topem
select	ldx	#14		;select drive
	bne	topem
rdeinp	lda	#<cbuf		;read buffer
	ldy	#>cbuf
	ldx	#10
topem	jmp	pemjmp
;kim type field
kimtyp	.byte	"KIM"
;messages
opnmsg	.byte	"SYSGEN"
	.byte	cr,lf,"VERSION 2.15-A$"
szemsg	.byte	cr,lf,"ENTER MEMORY SIZE IN DECIMAL "
	.byte	"K BYTES (K=1024) $"
btemsg	.byte	cr,lf,"ENTER DRIVE AND NAME FIELD "
	.byte	"FOR BOOT .KIM FILE $"
flemsg	.byte	cr,lf
	.byte	"ILLEGAL FILE NAME, BAD DATA OR"
	.byte	cr,lf
	.byte	"ILLEGAL ADDRESS IN INPUT FILE "
	.byte	"- ABORTING$"
nwsmsg	.byte	cr,lf,"ENTER SIM LENGTH IN DECIMAL "
	.byte	"PAGES (PAGE=256) (1 TO 99) $"
simmsg	.byte	cr,lf,"ENTER DRIVE AND NAME "
	.byte	"FIELD FOR SIM .KIM FILE $"
iermsg	.byte	"ILLEGAL INPUT - REENTER $"
crtmsg	.byte	cr,lf,"INSERT DISKETTE THEN ENTER "
	.byte	"DESTINATION DRIVE (A-H) $"
rommsg	.byte	cr,lf,"NOT ENOUGH SYSTEM TRACKS - "
	.byte	"ABORTING$"
invmsg	.byte	cr,lf,"INVALID DRIVE - TRY AGAIN$"
bigmsg	.byte	cr,lf
	.byte	"SYSTEM IS TOO LONG - ABORTING$"
wermsg	.byte	cr,lf
	.byte	"ERROR DURING WRITE - ABORTING$"
;variables
syslng	.word	ccmlng+pemlng	;system length
;input buffer
cbuf
cmax	.byte	32		;input
clng	.byte	0		;buffer
ctxt
	*=	*+32
;align code on half page inorder to assist in
;debugging and to allow jmp (xxxx) to be
;placed at word boundary.
	*=	*/256*256+384
;-------------------------------
;dos/65 boot
;-------------------------------
boot				;reserve space
	*=	*+128
;-------------------------------
;dos/65 console command module
;-------------------------------
;ccm unique definitions
nbuilt	=	7		;number built in commands
;main program
ccm	cld			;set binary mode
	pha			;save drive number
	jsr	rstdsk		;initialize system
	pla			;restore drive num
	jsr	slctds		;select drive
	lda	sysdef+6	;get line length
	lsr	a		;divide
	lsr	a		;by
	lsr	a		;16
	lsr	a		;for dir
	sta	sixten		;and save
	lda	cnslng		;get buffer length
	bne	mrecmd		;if more handle it
ccmlpe	ldx	#$ff		;set
	txs			;stack
	cld			;set binary mode
	jsr	hdrout		;send header
	lda	#'>'		;then print
	jsr	chrout		;prompt
	lda	cnsbvc		;point to start
	ldy	cnsbvc+1	;of buffer
	jsr	rdebuf		;do buffer read
	ldy	#0		;clear index
	ldx	cnslng		;get length
	beq	ccmlpe		;loop if empty
lwrupr	lda	cnstxt,y	;else get char
	cmp	#'a'		;if less than a
	bcc	nxtchg		;skip convert
	cmp	#'z'+1		;if over z
	bcs	nxtchg		;skip convert
	and	#%01011111	;else convert
	sta	cnstxt,y	;put back in buffer
nxtchg	iny			;bump index
	dex			;count down
	bne	lwrupr		;loop if more
	txa			;set a to zero
	sta	cnstxt,y	;insert stopper
	sta	cnbfpt		;initialize pointer
mrecmd	jsr	stdflb		;set default buffer
	jsr	intdsk		;get drive number
	sta	dfldsk		;store as default
	jsr	prslin		;parse command
	bne	cmderr		;error if afn
	lda	tmpdsk		;get temporary
	beq	nodrch		;if zero ok
	lda	#nbuilt*3	;else set and
	bne	dotrns		;do transient
nodrch	lda	#0		;clear
	tax			;table index
	sta	count		;and count
tsnxfn	ldy	#1		;set fcb index
tsnxch	lda	fnctbl,x	;get table entry
	beq	gotcmd		;if zero got it
	cmp	fcbone,y	;else test
	bne	nocmpr		;no good if not =
	inx			;bump
	iny			;pointers
	bne	tsnxch		;and loop
nocmpr	inx			;go to end
	lda	fnctbl,x	;of table
	bne	nocmpr		;entry
	inx			;point to next
	inc	count		;bump count
	lda	count		;and if not
	cmp	#nbuilt		;limit then
	bne	tsnxfn		;try next
gotcmd	lda	count		;get count
	asl	a		;multiply by two
	adc	count		;then add for x3
dotrns	tax			;use as index
	inx			;bump to pass jmp
	lda	xqfntb,x	;to get
	ldy	xqfntb+1,x	;entry address
	sta	vector		;then set
	sty	vector+1	;vector
	lda	extcvc+1	;save
	pha			;return
	lda	extcvc		;address
	pha			;on stack
	jmp	(vector)	;execute
extcmd	jsr	rstddr		;restore default
extwod	jsr	prslin		;parse more
	lda	fcbone+1	;if first
	sec			;character
	sbc	#' '		;not a space
	ora	tmpdsk		;or if temporary
	bne	cmderr		;then an error
	jmp	ccmlpe		;else loop
;command error syntax handler
cmderr	jsr	ccrlf		;do a cr lf
	ldy	curpnt		;get command pointer
cmerlp	lda	cnstxt,y	;get char
	beq	cmerex		;if null then done
	cmp	#' '		;if space
	beq	cmerex		;then done
	jsr	cotsxy		;output with save
	iny			;point to next
	bne	cmerlp		;and loop
cmerex	lda	#'?'		;send a
	jsr	chrout		;question mark
	jmp	ccmlpe		;and start over
;execute dir command
; dir <afn>
dir	jsr	prslin		;find object file
	jsr	clrslt		;clear auto and select
	lda	#' '		;if name
	cmp	fcbone+1	;and
	bne	findfr		;type are
	cmp	fcbone+9	;not empty
	bne	findfr		;then use it
	lda	#'?'		;else
	ldy	#11		;fill
fillqu	sta	fcbone,y	;fcb
	dey			;with
	bne	fillqu		;question marks
findfr	jsr	srchf1		;search for first match
	bmi	notfnd		;error if none
fnddir	lda	sixten		;set across
	sta	across		;to four
	jsr	ccrlf		;do a crlf
dirl	jsr	hdr		;do header
	lda	#':'		;then a
	jsr	chrout		;colon
	lda	diradd		;get number
	asl	a		;and
	asl	a		;multiply
	asl	a		;by
	asl	a		;thirty two
	asl	a		;then
	and	#%01100000	;mask out insignificant
	tay			;make a pointer
	iny			;and bump
	ldx	#1		;set counter
nmelpe	lda	dflbuf,y	;get name
	jsr	cotsxy		;else send to console
noname	iny			;bump index
	inx			;and count
	cpx	#12		;if count is 12
	beq	endnme		;then done
	cpx	#9		;or if not 9
	bne	nmelpe		;then loop
	lda	#'.'		;else send
	jsr	cotsxy		;a period
	jmp	nmelpe		;and loop
endnme	jsr	chkcst		;check console status
	bne	extdir		;if key down quit
	jsr	setone		;else point to fcb
	jsr	srchnx		;else search for next
	sta	diradd		;save number
	bmi	extdir		;quit if not found
	dec	across		;drop count
	beq	fnddir		;new line if 0
	jsr	spcout		;send
	jsr	spcout		;two spaces
	jmp	dirl		;and stay
extdir	rts			;else done
;not found error handler
notfnd	ldy	#ntfnms		;point to message
	jmp	sndmsg		;send and exit
;execute ren command
; ren <ufn> <ufn>
;where first ufn is from name and second is to name
ren	jsr	prslin		;get old name
	bne	renerr		;error if afn
	jsr	tmpold		;save drive
	jsr	clrslt		;clear auto and select
	jsr	srchf1		;if file does not exist
	bmi	fntfnd		;then an error
	jsr	frssec		;move name to second half
	ldy	cnbfpt		;get pointer
	lda	cnstxt,y	;and then char
	cmp	#' '		;if not a space
	bne	rensyn		;then error
	jsr	prslin		;get new name
	bne	rensyn		;error if afn
	lda	tmpdsk		;get new drive
	beq	nonwdr		;if zero ok
	cmp	oldtmp		;compare to old
	beq	nonwdr		;ok if same
	sec			;drop for default check
	sbc	#1
	cmp	dfldsk		;if not default
	bne	rensyn		;is error
	lda	oldtmp		;and then if from not
	bne	rensyn		;default is error
nonwdr	lda	oldtmp		;else get old
	sta	tmpdsk		;and save
	lda	#0		;clear
	sta	fcbone+16
	jsr	clrslt		;reselect
	jsr	srchf1		;search for old
	bpl	filexs		;error if found
	jsr	frssec		;swap names
	jsr	setone		;point to fcb
	jmp	renmfl		;and do it
;ren file exists error handler
filexs	ldy	#flexms		;point to
	bne	remsg		;and send
;ren syntax error handler
rensyn	jsr	rstddr		;restore default
renerr	jmp	cmderr		;do error
;ren source file not found error handler
fntfnd	ldy	#ntfnms		;point to
remsg	jmp	sndmsg		;and send
;execute save command
; save <length> <drive:>ufn (<address>)
save	lda	#<tea		;set start address to tea start
	ldy	#>tea
	sta	sadr
	sty	sadr+1
	jsr	bldnum		;calculate length
	bne	saverr		;error if > 255 pages
	sta	length		;else save low
	ora	length		;test for zero length
	beq	saverr		;error if is
	jsr	prslin		;get file name
	bne	saverr		;error if afn
	jsr	frssec		;move name to second half
	jsr	tmpold		;save drive
	jsr	bldnum		;it is so find value
	ldx	fcbone+1	;see if there
	cpx	#' '
	beq	nosadr		;it is not
	sta	sadr		;and set address
	sty	sadr+1
	cpy	#2		;make sure is high enough
	bcc	saverr		;error if not
nosadr	jsr	secfrs		;move name back
	jsr	clrslt		;clear auto and select
	jsr	dlt1		;delete
	jsr	setone		;then create
	jsr	cratfl		;new file
	bmi	noroom		;say no room if error
	jsr	open1		;open file
	bmi	noopen		;if error
	clc			;now find end page
	lda	sadr+1
	adc	length
	sta	length
	lda	sadr		;get start address
	ldy	sadr+1
wrtmre	sta	dskbuf		;set
	sty	dskbuf+1	;buffer
	jsr	mv128		;move data to buffer
	jsr	setone		;point to fcb
	jsr	wrrcrd		;write record
	bne	wrterr		;exit if error
	clc			;else
	lda	dskbuf		;get old
	ldy	dskbuf+1	;buffer
	adc	#128		;add 128
	bcc	donotc		;if carry
	iny			;bump upper
	beq	clssav		;done if page zero
donotc	cpy	length		;loop if upper
	bne	wrtmre		;not at limit
clssav	jsr	setone		;else point to
	jsr	clsefl		;and close file
	bmi	cantcl		;say so if error
extera	rts
;save error handler
saverr	jmp	cmderr		;do error
;save no room error handler
noroom	ldy	#nospms		;point to
	bne	semsg		;and send
;save can not open error handler
noopen	ldy	#cnnoms		;point to
	bne	semsg		;and send
;save write error handler
wrterr	ldy	#wrerms		;point
	bne	semsg		;to and send
;save can not close error
cantcl	ldy	#ntclms		;point to
semsg	jmp	sndmsg		;and send
;execute era command
; era <afn>
era	jsr	prslin		;get file name
	cmp	#11		;if not all ?
	bne	nteral		;then skip verify
	ldy	#alflms		;else point to
	jsr	sndmsg		;and send all files
	jsr	cnsrde		;get an input
	pha			;and save
	jsr	ccrlf		;do a cr lf
	pla			;restore char
	and	#$5f		;convert to upper case
	cmp	#'Y'		;if not y
	bne	extera		;then quit
nteral	jsr	clrslt		;clear auto and select
	jmp	dlt1		;delete first
;execute type command
; type d:ufn
type	jsr	prslin		;get file
	bne	typafn		;error if afn
	jsr	casdo1		;clear - select - open file 1
	bmi	notype		;error if not found
	jsr	ccrlf		;else do cr lf
typmre	jsr	read1		;read record
	beq	okread		;if ok continue
	bpl	exttyp		;exit if just end
	bmi	typerr		;else error
okread	ldx	#0		;clear index
typlpe	lda	dflbuf,x	;get char
	cmp	#eof		;if eof
	beq	exttyp		;then exit
	jsr	cotsxy		;else send
	jsr	chkcst		;if key down
	bne	exttok		;then exit
	ldx	savx		;else get index
	inx			;bump it
	bpl	typlpe		;and loop if < 128
	bmi	typmre		;else read more
exttok	ldx	#6		;clear console
	jsr	pemjmp		;with no echo
exttyp	rts
;type syntax error handler
typafn	jmp	cmderr		;error return
;type read error handler
typerr	ldy	#rderms		;point to
	bne	temsg		;and send
;type not found error handler
notype	ldy	#ntfnms		;point to
temsg	jmp	sndmsg		;and send
;execute load command
; load <ufn> (<address>)
load	jsr	setddb		;set load start to tea start
	jsr	prslin		;build fcb
	bne	typafn		;error if afn
	jsr	frssec		;save in second half
	jsr	tmpold		;save file
	jsr	bldnum		;find start address
	ldx	fcbone+1	;see if number
	cpx	#' '
	beq	usedfl		;if none use default
	jsr	setdb		;and set
usedfl	jsr	secfrs		;move name back
	jsr	casdo1		;clear - select - open file 1
	bmi	notype		;exit if not found
	lda	dskbuf		;get load start
	ldy	dskbuf+1
lcmdlp	jsr	setbuf		;set as disk buffer
	jsr	read1		;read record
	bne	loadnd		;done if not zero
	jsr	adjdb		;bump address
	jmp	lcmdlp		;and loop
loadnd	bmi	typerr		;if error say so
	jmp	stdflb		;back to default buffer
;execute go command
; go (<address>)
go	jsr	bldnum		;get address
	ldx	fcbone+1	;get first char
	cpx	#' '		;see if nothing
	beq	nolnum		;nothing so use tea
	jmp	godoit		;then execute
nolnum	jmp	gotea
;execute trns (transient) command
; <ufn> (<fn>) (<fn>)
trns	lda	fcbone+1	;get first char
	cmp	#' '		;if not space
	bne	chktyp		;check type
	lda	tmpdsk		;else test temp
	beq	skpdrv		;if none skip
	sec			;else convert
	sbc	#1		;to number
	sta	dfldsk		;set default
	jsr	slctds		;and select
skpdrv	jmp	extwod		;return
chktyp	lda	fcbone+9	;get type
	cmp	#' '		;if space
	beq	typemp		;then ok
	jmp	trnerr		;else error
typemp	ldx	#2		;make
setcom	lda	typcom,x	;type
	sta	fcbone+9,x	;com
	dex			;then
	bpl	setcom		;continue
	jsr	casdo1		;clear - select - open file one
	bpl	gottrn		;jump if ok
	jmp	topner		;else do error
gottrn	jsr	setddb		;set start to tea
nxtrcr	jsr	setbuf		;set address
	jsr	read1		;read fcb 1
	bne	endlde		;branch if error or eof
	jsr	adjdb		;adjust address up by 128
	cmp	ccmvc		;if new low
	bcc	tryhig		;ok try high
	cpy	ccmvc+1		;else if high
	bcc	nxtrcr		;ok do more
	bcs	chklnd		;else check for end
tryhig	cpy	ccmvc+1		;if high less
	bcc	nxtrcr		;then ok
	beq	nxtrcr		;or ok if same
chklnd	jsr	stdflb		;set buffer to default
	jsr	read1		;read (should be eof)
	beq	tlderr		;error if more
endlde	bmi	tlderr		;do error
gotea	lda	#<tea		;set go address to tea start
	ldy	#>tea
godoit	sta	do+1		;set to ay
	sty	do+2
	jsr	rstddr		;else restore default
	jsr	prslin		;parse file
	lda	tmpdsk		;set auto
	sta	fcbone		;select position
	ldx	#16		;do a second
	jsr	prsmre		;fcb if there
	lda	tmpdsk		;set auto select
	sta	fcbone+16	;again
	ldy	#0		;clear record
	sty	fcbone+32	;counter
	ldx	#32		;move
movfcb	lda	fcbone,x	;all
	sta	dflfcb,x	;to
	dex			;default
	bpl	movfcb		;fcb
	inx			;set x to zero
tstbuf	lda	cnstxt,y	;get char
	beq	isnull		;if null jump
	cmp	#' '		;or if space
	beq	isnull		;jump
	iny			;else bump pointer
	bne	tstbuf		;and loop
isnull	lda	#0		;clear 
	sta	dflbuf		;count
movbuf	lda	cnstxt,y	;get char
	sta	dflbuf+1,x	;and move
	beq	fillov		;exit if null
	inx			;increment
	iny			;counters
	inc	dflbuf		;and length
	bne	movbuf		;and loop
fillov	jsr	ccrlf		;do a cr lf
	jsr	stdflb		;set default
do	jsr	tea		;execute
	lda	dfldsk		;get default
	jsr	slctds		;and set
	jmp	ccmlpe		;then loop
;trns syntax error handler
topner	jsr	rstddr		;restore default
trnerr	jmp	cmderr		;do error
;trns load error
tlderr	ldy	#lderms		;point to
	jmp	sndmsg		;and send
;carriage return and linefeed
ccrlf	lda	#cr		;get a cr
	jsr	chrout		;send
	lda	#lf		;get a lf
	bne	chrout		;and send
;pem entry routines
cnsrde	ldx	#1		;console read
	bne	pemgo
spcout	lda	#' '		;output space
chrout	ldx	#2		;console output
	bne	pemgo
rdebuf	ldx	#10		;buffered input
	bne	pemgo
chkcst	ldx	#11		;check console
	bne	pemgo
rstdsk	ldx	#13		;initialize system
	bne	pemgo
slctds	ldx	#14		;select drive
	bne	pemgo
openfl	ldx	#15		;open file
	bne	pemgo
clsefl	ldx	#16		;close file
	bne	pemgo
srchfr	ldx	#17		;first match
	bne	pemgo
srchnx	ldx	#18		;next match
	bne	pemgo
;delete file one
dlt1	jsr	setone		;point to fcb
dltfil	ldx	#19		;delete file
	bne	pemgo
rdrcrd	ldx	#20		;read record
	bne	pemgo
wrrcrd	ldx	#21		;write record
	bne	pemgo
cratfl	ldx	#22		;create file
	bne	pemgo
renmfl	ldx	#23		;rename file
	bne	pemgo
intdsk	ldx	#25		;read drive num
	bne	pemgo
setbuf	ldx	#26		;set buffer add
pemgo	jmp	pemjmp		;go to pem
;restore default drive
rstddr	lda	tmpdsk		;if temp drive
	beq	extddr		;zero then exit
	sec			;else
	sbc	#1		;subtract one
	cmp	dfldsk		;compare to default
	beq	extddr		;exit if same
seldfl	lda	dfldsk		;else get default
	jmp	slctds		;select
;clear auto - select disk - open file at fcbone
casdo1	jsr	clrslt		;clear auto and select
;open file one
; returns:n=1 if not found
open1	lda	#0		;clear
	sta	fcbone+32	;record number
	jsr	setone		;point to fcb
	jsr	openfl		;open it
	sta	diradd		;save number
extddr	rts
;read file one
read1	jsr	setone		;point to fcb
	jmp	rdrcrd		;do read
;search for first file one
; returns:n=1 if not found
srchf1	jsr	setone		;point to fcb
	jsr	srchfr		;search for first
	sta	diradd		;save number
	rts
;header output
hdrout	jsr	ccrlf		;do cr lf
hdr	jsr	intdsk		;get drive number
	clc			;make
	adc	#'A'		;a letter
;output with save of x and y
;this routine calls the pem resident routine
;tstchr to see if a char is a printing char.
;if it is then c=1 upon return from tstchr.
cotsxy	stx	savx		;save x
	sty	savy		;and y
	jsr	tstchr		;see if printing
	bcs	isprnt		;jump if is
	pha			;else save
	lda	sysdef+4	;get invert
	jsr	chrout		;send it
	pla			;get char
	ora	#'@'		;make printing
	jsr	chrout		;send it
	lda	sysdef+3	;get normal
isprnt	jsr	chrout		;do output
	ldy	savy		;get y
	ldx	savx		;and x
	rts
;set up fcb one pointer
setone	lda	fcb1vc		;low
	ldy	fcb1vc+1	;and high
	rts
;save tmpdsk in oldtmp
tmpold	lda	tmpdsk
	sta	oldtmp
	rts
;parse command line
prslin	ldx	#0		;clear index
prsmre	txa			;save
	pha			;index
	lda	#0		;clear temp
	sta	tmpdsk		;drive flag
	ldy	cnbfpt		;get buffer pointer
	jsr	skpspc		;find first non-space
	sty	curpnt		;save index
	beq	nulchr		;jump if null
	and	#%00001111	;else look at 4 lsbs
	pha			;and save
	iny			;point to next char
	lda	cnstxt,y	;and get it
	cmp	#':'		;if a colon
	beq	drvinp		;jump and set drive
	pla			;else clear stack
	dey			;backup index
nulchr	lda	dfldsk		;set automatic
	sta	fcbone,x	;to default
	bpl	trynme		;then parse name
drvinp	pla			;get number
	sta	tmpdsk		;set temp flag
	sta	fcbone,x	;and fcb
	iny			;point past colon
trynme	lda	#8		;set name count
	sta	count		;to eight
tstnme	jsr	tstlgl		;test for illegal
	beq	flnmsp		;if illegal jump
	inx			;bump pointer
	cmp	#'*'		;if not *
	bne	notafn		;skip ? fill
	lda	#'?'		;get a ?
	sta	fcbone,x	;store
	bne	nxtout		;and jump
notafn	sta	fcbone,x	;store char
	iny			;bump source
nxtout	dec	count		;drop counter down
	bne	tstnme		;and loop
skpmre	jsr	tstlgl		;if illegal
	beq	trytyp		;try type
	iny			;else bump index
	bne	skpmre		;and loop
flnmsp	inx			;next position
	lda	#' '		;get a space
	sta	fcbone,x	;store
	dec	count		;count down
	bne	flnmsp		;and loop
	lda	cnstxt,y	;get char again
trytyp	pha			;save char
	lda	#3		;set count
	sta	count		;to three
	pla			;get char
	cmp	#'.'		;if not .
	bne	fltysp		;then fill spaces
	iny			;else bump source
tsttyp	jsr	tstlgl		;if not legal
	beq	fltysp		;then fill spaces
	inx			;else bump index
	cmp	#'*'		;if not *
	bne	notaft		;then skip fill
	lda	#'?'		;else get ?
	sta	fcbone,x	;move to fcb
	bne	mrtyfl		;and loop
notaft	sta	fcbone,x	;move char to fcb
	iny			;bump source
mrtyfl	dec	count		;count down
	bne	tsttyp		;and loop
nttype	jsr	tstlgl		;if illegal
	beq	filnul		;fill out nulls
	iny			;else bump source
	bne	nttype		;and loop
fltysp	inx			;bump fcb pointer
	lda	#' '		;get space
	sta	fcbone,x	;put in fcb
	dec	count		;count down
	bne	fltysp		;and continue
filnul	lda	#3		;clear
	sta	count		;three
mrnlty	inx			;bump fcb pointer
	lda	#0		;get a zero
	sta	fcbone,x	;move to fcb
	dec	count		;count down
	bne	mrnlty		;loop until done
	sty	cnbfpt		;update start pointer
	lda	#0		;clear
	sta	count		;count
	pla			;restore stack
	tay			;move to index
	ldx	#11		;counter to 11
tstqus	iny			;point to
	lda	fcbone,y	;and get char
	cmp	#'?'		;if not a ?
	bne	nxtqus		;then jump
	inc	count		;else bump count
nxtqus	dex			;loop until
	bne	tstqus		;11 tested
	lda	count		;get count
	rts			;and return
;skip space
skpspc	lda	cnstxt,y	;get char
	beq	extskp		;jump if null
	cmp	#' '		;if not space
	bne	extskp		;then exit
	iny			;else go to next
	bne	skpspc		;and test
extskp	rts
;test legal
tstlgl	lda	cnstxt,y	;get char
	beq	extlgl
	cmp	#' '		;if space
	bcc	badinp		;ok - less is error
	beq	extlgl
	cmp	#'='
	beq	extlgl
	cmp	#'.'
	beq	extlgl
	cmp	#':'
	beq	extlgl
	cmp	#semico
	beq	extlgl
	cmp	#'<'
	beq	extlgl
	cmp	#'>'
extlgl	rts
badinp	jmp	cmderr
;set default buffer address
stdflb	lda	#<dflbuf 	;point to
	ldy	#>dflbuf	;location
	jmp	setbuf		;and set
;clear automatic and select
clrslt	lda	#0		;clear auto
	sta	fcbone		;select
slttmp	lda	tmpdsk		;get temp
	beq	extsnd		;if zero exit
	sec			;else subtract
	sbc	#1		;one
	cmp	dfldsk		;if same as default
	beq	extsnd		;then quit
	jmp	slctds		;else set
;send message
sndmsg	sty	savy		;save index
	jsr	ccrlf		;do cr and lf
	ldy	savy		;get index
lpesnd	lda	msgtbl,y	;get char
	beq	extsnd		;if null quit
	jsr	cotsxy		;else send
	iny			;point to next
	bne	lpesnd		;and loop
extsnd	rts
;set load start address
setddb	lda	#<tea		;to tea start
	ldy	#>tea
setdb	sta	dskbuf		;to ay
	sty	dskbuf+1
	rts
;move first part of fcb to second half
;and move second part to first part.
;only ren depends upon this routine to actually
;swap fcb halves.
;alters:a,x,p
;returns:x=$ff
frssec	ldx	#15		;set index to last
frsclp	lda	fcbone,x	;get byte
	ldy	fcbone+16,x
	sta	fcbone+16,x	;move it
	tya
	sta	fcbone,x
	dex
	bpl	frsclp		;until 16 moved
	rts
;move second part of fcb to first half
;restore tmpdsk from save location
;alters:a,x,p
;returns:x=$ff
secfrs	ldx	#15		;set index to last
scfrlp	lda	fcbone+16,x	;get byte
	sta	fcbone,x	;move it
	dex
	bpl	scfrlp		;loop until done
	lda	oldtmp		;get old flag
	sta	tmpdsk		;and set
	rts
;build a number from command line and leave in num
;will handle either decimal (e.g., 578) or hexadecimal (e.g., $3f2)
;move parse index past number
;modifies:all
;returns:a,y set to low and high of number
;	 flags set according to y which is high part of number
bldnum	lda	#9		;preset to decimal
	sta	moduls
	jsr	prslin		;put in fcb
	lda	tmpdsk		;if temp
	bne	numerr		;is error
	sta	num		;else clear num
	sta	num+1
	tay			;and index
	lda	fcbone+1,y	;get first char
	cmp	#'$'		;see if hex signal
	bne	bnumlp		;skip if not
	lda	#15		;set for modulus
	sta	moduls
	iny			;bump past $
bnumlp	iny			;next char
	lda	fcbone,y	;get digit
	cmp	#' '		;see if space
	beq	endnlp		;done if is
	jsr	tstdec		;see if decimal
	bcc	usedig		;use if is
	jsr	tsthex		;see if hex
	bcs	numerr		;error if not
	sbc	#6		;remove offset
	ldx	#15		;test for hex modulus
	cpx	moduls
	bne	numerr		;error if not
usedig	and	#%00001111	;eliminate ascii bias
	pha			;save result
	lda	num		;move number to temp
	sta	tnum
	lda	num+1
	sta	tnum+1
	ldx	moduls		;get modulus
	clc
addlpe	lda	num		;add number to itself
	adc	tnum
	sta	num
	lda	num+1		;modulus times
	adc	tnum+1
	sta	num+1
	bcs	numerr		;error if carry out
	dex
	bne	addlpe		;loop if more
	pla			;get input back
	adc	num		;add in
	sta	num
	bcc	bnumlp		;loop if no carry
	inc	num+1		;else bump high
	bne	bnumlp		;and loop for more
;error in bldnum - handle and quit
numerr	jmp	cmderr		;do general error
;end of use of name part - check type
endnlp	lda	fcbone+9	;get first
	cmp	#' '		;see if space
	bne	numerr		;error if not
	lda	num		;return with result
	ldy	num+1
	rts
;relocatable vectors
	.byte	$4c
cnsbvc	.word	cnsbuf
	.byte	$4c
extcvc	.word	extcmd-1
	.byte	$4c
ccmvc	.word	ccm
	.byte	$4c
fcb1vc	.word	fcbone
;function entry vector
xqfntb	jmp	dir
	jmp	save
	jmp	era
	jmp	type
	jmp	ren
	jmp	go
	jmp	load
	jmp	trns
;terminator for relocation
	.byte	$ff
;messages
msgtbl
	.byte 0
nospms	=	*-msgtbl
	.byte	"NO SPACE",0
ntclms	=	*-msgtbl
	.byte "CAN NOT CLOSE",0
alflms	=	*-msgtbl
	.byte "ALL FILES (Y/N)?",0
rderms	=	*-msgtbl
	.byte	"READ ERROR",0
ntfnms	=	*-msgtbl
	.byte	"NOT FOUND",0
flexms	=	*-msgtbl
	.byte "FILE EXISTS",0
lderms	=	*-msgtbl
	.byte "LOAD ERROR",0
cnnoms	=	*-msgtbl
	.byte "CAN NOT OPEN",0
wrerms	=	*-msgtbl
	.byte "WRITE ERROR",0
;function name table
fnctbl	.byte	"DIR ",0
	.byte	"SAVE ",0
	.byte	"ERA ",0
	.byte	"TYPE ",0
	.byte	"REN ",0
	.byte	"GO ",0
	.byte	"LOAD ",0
;input buffer
cnsbuf
cnsmax .byte 127
cnslng .byte 0
cnstxt
	*=	*+127
;fcb one
fcbone
	*=	*+33
;com type field
typcom	.byte	"COM"
;variable storage
cnbfpt	.byte	0		;buffer index
dfldsk	.byte	0		;default drive
tmpdsk	.byte	0		;temporary dvive
;align vector on word boundary
	*=	*/2*2+2
vector	.word	0		;execution vector
count	.byte	0		;counter
curpnt	.byte	0		;input parse start
diradd	.byte	0		;directory number
savx	.byte	0		;save x location
savy	.byte	0		;save y location
length	.byte	0		;number tages to save
oldtmp	.byte	0		;temp drive in ren
dskbuf	.word	tea		;disk buffer start
across	.byte	0		;dir count on line
sixten	.byte	0		;line length div 16
moduls	.byte	9		;modulus-1 for number input
num	.word	0		;input number
tnum	.word	0		;temp in bldnum
sadr	.word	tea		;save start address
;-------------------------------
;dos/65 primitive execution module (pem)
;-------------------------------
;zero page data storage
addinp	=	$02		;initialized to a,y
bufadd	=	$04		;buffer address
alcpnt	=	$06		;allocation map pointer
chkpnt	=	$08		;checksum map pointer
numvar	=	8		;eight bytes
;main program
; input:x=command,a=value,a&y=address
; returns:a=value,a&y=address
; alters:all
	*=	ccm+ccmlng
pem	cld			;set binary mode
	sta	bytinp		;save input
	sta	lowin		;value and
	sty	bytinp+1	;save high
	sty	lowin+1		;address
	stx	cmdinp		;and command
	cpx	#numcmd		;if invalid
	bcs	extpem		;then exit
	lda	swctbl,x	;if flag zero
	beq	noswin		;skip switch
	lda	#255		;else set
	sta	swcflg		;memory switch flag
	jsr	switch		;move data to page zero
noswin	lda	#0		;clear drive
	sta	tmpdrv		;switch flag
	lda	cmdinp		;get command
	asl	a		;multiply by two
	adc	cmdinp		;then add to get x3
	tax			;and make a pointer
	inx			;bump to pass jmp
	lda	cmdtbl,x	;get command
	ldy	cmdtbl+1,x	;address
	sta	xqtvec		;and put
	sty	xqtvec+1	;in vector
	lda	extevc+1	;get return
	pha			;address
	lda	extevc		;and push
	pha			;as return
	lda	bytinp		;get input value
	ldy	bytinp+1
	jmp	(xqtvec)	;then execute
extexq	sta	bytout		;save value
	sty	addout+1	;and address
	lda	tmpdrv		;get temp drive
	beq	extpem		;if zero skip switch
	ldy	#0		;else
	sta	(addinp),y	;put back in fcb
	lda	olddrv		;get old drive number
	sta	bytinp		;set input value
	jsr	chgdrv		;then switch back
extpem	bit	swcflg		;test memory switch
	bpl	noswot		;if not set skip
	jsr	switch		;else do memory switch
	lda	#0		;clear
	sta	swcflg		;flag
noswot	ldy	addout+1	;get address
	lda	bytout		;and value (address low)
	rts
;command vector table
cmdtbl	jmp	xwboot		;warm boot
	jmp	xcnsin		;console input with echo
	jmp	sndchr		;console output
	jmp	sim+21		;tape reader
	jmp	sim+18		;tape punch
	jmp	sim+15		;printer output
	jmp	getcon		;console input w/o echo
	jmp	xgtios		;read i/o status
	jmp	xstios		;set i/o status
	jmp	sndstr		;print buffer
	jmp	bufinp		;read buffer
	jmp	kbdsts		;test console ready
	jmp	sim+45		;read list status
	jmp	xintds		;initialize system
	jmp	chgdrv		;log in drive
	jmp	xopen		;open file
	jmp	xclose		;close file
	jmp	xfndfr		;find first match
	jmp	xfndnx		;find next match
	jmp	xdltfl		;delete file
	jmp	xread		;read record
	jmp	xwrite		;write record
	jmp	xmake		;create file
	jmp	xrenme		;rename file
	jmp	xintlg		;interrogate log in status
	jmp	xintdr		;interrogate current drive
	jmp	chgdma		;set buffer address
	jmp	xrdalv		;read allocation map start
	jmp	setron		;set r/w status
	jmp	xrdros		;read r/w status
	jmp	setlst		;set list echo status
	jmp	lststs		;read list echo status
	jmp	xrtclo		;read low clock
	jmp	xrtchi		;read high clock
	jmp	xrddcb		;read dcb address
	jmp	sim+51		;translate sector
;set list echo status
setlst	sta	lstflg		;set flag
	rts
;read list echo status
lststs	lda	lstflg		;read flag
	rts
;execute warm boot
; ***this command does not return to pem***
; ***instead it jumps to sim, resets	***
; ***system and stack and jumps to ccm. ***
xwboot	bit	swcflg		;test memory switch flag
	bpl	dowmbt		;if clear do not
	jsr	switch		;switch memory
	lda	#0		;clear
	sta	swcflg		;flag
dowmbt	jmp	sim+3		;go to sim
;execute read real time clock
xrtclo	jsr	sim+48		;read clock
	sta	rtclk		;save low
	sty	rtclk+1		;middle
	stx	rtclk+2		;high
	txa
	and	#%10000000	;test for valid
	tay
	lda	rtclk		;get low
	rts
;execute read real time clock high
xrtchi	lda	rtclk+2		;get high
	and	#%01111111	;clear status
	tay
	lda	rtclk+1		;get middle
	rts
;execute read dcb address
xrddcb	lda	cptdcb+1	;get address
	ldy	cptdcb+2
	rts
;execute read i/o status
xgtios	lda	iostat		;get status byte
	rts
;execute read allocation map starting address
xrdalv	lda	alcmap		;get
	ldy	alcmap+1	;starting address
	rts			;then return
;execute set i/o status
xstios	sta	iostat		;set status
	rts
;execute interrogate current drive
xintdr	lda	curdrv		;get number
	rts
;execute read log in status
xintlg	lda	lginvc		;get status
	rts
;execute read read/write status
xrdros	lda	ronlst		;get status
	rts
;execute find next match
xfndnx	jsr	autodr		;auto drive select
	lda	#13		;match including
	jmp	search		;extent
;execute read next record
xread	jsr	autodr		;auto drive select
	jsr	inrcct		;initialize record counters
	lda	nxtrec		;if next record less
	cmp	numrec		;then number records
	bcc	tryrde		;then try to read
	cmp	#128		;but if not and
	beq	tryext		;is max try to extend
rdeeof	lda	#1		;else set eof
	rts			;code and return
tryext	ldx	#1		;try for a read
	jsr	extend		;file extension
	cmp	#0		;if not ok exit eof
	bne	rdeeof		;with jump back
	sta	nxtrec		;clear next record
tryrde	jsr	getblk		;and get block
	lda	blknum		;if block not zero
	ora	blknum+1
	bne	dorde		;do the read
	lda	#2		;else set unwritten
	rts			;code and exit
dorde	jsr	calrcn		;calculate record number
	jsr	sttrsc		;set track and sector
	jsr	rdesec		;do sector read
	jsr	updtrc		;update counters
	lda	#0		;return w/o error
extrde	rts
;execute file rename
xrenme	jsr	autodr		;automatic drive select
	jsr	tstron		;test for r/o
	lda	#12		;match name
	jsr	frstsr		;and type
	bmi	extren		;exit if not found
doren	lda	#0		;clear drive select
	ldy	#16		;in new name
	sta	(addinp),y	;part of fcb
	lda	#12		;then move
	ldx	#16		;new name
	jsr	dirchg		;to directory
	lda	#12		;see if
	jsr	search		;another match
	bpl	doren		;loop if found
extren	rts			;number
;execute delete file
xdltfl	jsr	autodr		;automatic drive select
	jsr	tstron		;test for r/o
	lda	#12		;match name
	jsr	frstsr		;and type
	bmi	extdlt		;done if not found
dodlt	ldx	#0		;else do a
	jsr	mapdir		;delete
	ldy	subrec		;then change
	lda	empty		;byte zero to
	sta	(bufadd),y	;empty code
	jsr	updtck		;then update directory
	lda	#12		;search
	jsr	search		;for next
	bpl	dodlt		;loop if found
extdlt	rts			;exit
;execute write next record
xwrite	jsr	autodr		;automatic drive select
	jsr	tstron		;test for r/o
	jsr	inrcct		;initialize counters
	lda	nxtrec		;get next record
	cmp	#128		;compare to max
	bcc	ntexte		;continue if less
	lda	#1		;else flag as extend
	rts			;error and exit
ntexte	jsr	getblk		;calculate block num
	lda	#0		;say normal write
	sta	wrtype		;for now
	lda	blknum		;get it and if
	ora	blknum+1
	beq	*+5		;zero then get number
	jmp	blkopn		;else go write
	lda	#2		;say unalloc write
	sta	wrtype
	lda	fcbind		;get index from prior
	pha			;and save
	cmp	#16		;if first block
	beq	isfrst		;then don't change
	tay			;else make an index
	dey			;point to last
	bit	blmode		;test mode
	bpl	*+3		;done if byte
	dey			;else drop for word
	lda	(addinp),y	;and get that number
	sta	blknum		;store as starting
	iny			;bump for word
	lda	#0		;preset for byte
	bit	blmode		;test mode
	bpl	*+4		;done if byte
	lda	(addinp),y	;else get high
	sta	blknum+1	;then set high
isfrst	lda	blknum		;get block
	sta	lkdown		;set lower and 
	sta	lookup		;upper pointers
	lda	blknum+1	;now set high part
	sta	lkdown+1
	sta	lookup+1
srblag	lda	lookup		;if upper pointer
	cmp	maxblk		;not at max
	bne	upnemx		;then keep going
	ldy	lookup+1	;now check high
	cpy	maxblk+1
	beq	tstdwn		;go test down
upnemx	inc	lookup		;else bump upper
	bne	*+5
	inc	lookup+1
	lda	lkdown		;then if lower
	ora	lkdown+1
	beq	dotest		;is zero start test
	bne	dcdown		;else drop lower
tstdwn	lda	lkdown		;if upper & lower at
	ora	lkdown+1
	bne	dcdown		;drop if not zero
	tay			;also set y
	beq	extsbl		;then exit
dcdown	lda	lkdown		;drop lower
	bne	*+5
	dec	lkdown+1
	dec	lkdown
dotest	lda	lkdown		;get lower
	ldy	lkdown+1
	jsr	tstblk		;and test
	bne	trylup		;if full try upper
	lda	lkdown		;else use lower
	ldy	lkdown+1
	jmp	extsbl		;as result
trylup	lda	lookup		;get upper
	ldy	lookup+1
	jsr	tstblk		;if full
	bne	srblag		;then loop
	lda	lookup		;else use upper
	ldy	lookup+1
extsbl	sta	blknum		;then save number
	sty	blknum+1
	ora	blknum+1	;see if zero
	bne	gtgood		;then proceed
	pla			;clear stack
	lda	#2		;set end
	rts			;of data return
gtgood	lda	blknum		;get low again
	jsr	setblk		;set allocation map
	pla			;get block
	tay			;pointer back
	lda	blknum		;get number
	sta	(addinp),y	;and put in fcb
	lda	blknum+1	;get high
	iny
	bit	blmode		;test mode
	bpl	*+4		;done if byte
	sta	(addinp),y	;else set high
blkopn	jsr	calrcn		;calculate record num
	jsr	sttrsc		;set track and sector
	jsr	wrtsec		;do write
	ldx	nxtrec		;get next record
	cpx	numrec		;if less than max
	bcc	notful		;then ok
	inx			;else bump count
	stx	numrec		;and save
	dex			;back down
notful	cpx	#127		;if not at max
	bne	noawex		;skip extending
	jsr	updtrc		;update record counters
	ldx	#0		;do write
	jsr	extend		;file extension
	cmp	#0		;if not ok
	bne	extwrt		;exit
	lda	#255		;else start counter
	sta	nxtrec		;at one short
noawex	jsr	updtrc		;then update counters
	lda	#0		;good return
extwrt	rts			;exit
;execute console input
xcnsin	jsr	getcon		;get input
	jsr	tstchr		;test it and
	bcc	extxci		;if control exit
	pha			;else save
	jsr	sndchr		;echo
	pla			;restore
extxci	rts			;return
;switch memory
;page zero block begins at $02 and is numvar bytes long.
switch	ldx	#numvar-1	;get number to switch
nxtswh	lda	2,x		;get zero page
	ldy	varblk,x	;and save area
	sta	varblk,x	;save zero
	sty	2,x		;and high
	dex			;count down
	bpl	nxtswh		;and loop until done
drvsme	rts			;then return
;change dma address
; input:addinp=address
; returns:none
; alters:all
chgdma	lda	addinp		;get low
	ldy	addinp+1	;and high address
	sta	bufadd		;then store
	sty	bufadd+1	;in address
	jmp	sim+36		;then go to sim
;change drive
; input:bytinp
; returns:none
; alters:all
chgdrv	lda	bytinp		;get input
	cmp	curdrv		;if same as current
	beq	drvsme		;do nothing
	sta	curdrv		;else change current
	jmp	mapdrv		;then log it in
;automatic drive select
; input:(addinp) 0=no change
; 1-8 or 'A'-'H' = change
; returns:none
; alters:all
autodr	ldy	#0		;get
	lda	(addinp),y	;first byte of fcb
	beq	qtatdr		;if zero quit
	sec			;set carry for
	sbc	#1		;subtract one
	and	#%00000111	;look at three lsbs
	sta	bytinp		;make parameter
	lda	curdrv		;get current
	sta	olddrv		;and save
	lda	(addinp),y	;get fcb entry
	sta	tmpdrv		;and save as flag
	tya			;set a to 0
	sta	(addinp),y	;clear byte zero in fcb
	jsr	chgdrv		;then select new drive
qtatdr	rts			;and return
;execute initialize system
; input:none
; returns:none
; alters:all,curdrv,lginvc,bufadd
xintds	lda	#0		;set current
	sta	curdrv		;drive to a
	sta	lginvc		;clear log in status
	lda	#<dflbuf	;get default buffer
	ldy	#>dflbuf	;address
	sta	addinp		;and set up 
	sty	addinp+1	;parameters
	jsr	chgdma		;change address
;log in drive and set pointers and maps
; input:curdrv
; returns:none
; alters:all
mapdrv	lda	curdrv		;if current drive
	cmp	#8		;is 0 to 7
	bcc	vlddrv		;then log it in
drserr	jsr	errout		;send error message
	lda	sltmvc		;point to
	ldy	sltmvc+1	;select message
	jsr	sndstr		;and send it
	jmp	xwboot		;and abort
vlddrv	jsr	sim+27		;go to sim to set
	sta	cptdcb+1	;save
	sty	cptdcb+2
	ora	cptdcb+2	;see if invalid
	beq	drserr		;error if is
;capture dcb
	ldy	#14-1		;do 14 bytes
cptdcb	lda	$ffff,y		;get value from sim
	sta	dcb,y		;store it
	dey
	bpl	cptdcb		;loop for more
	lda	blkscd		;get block size code
	tay			;save in y
	clc
	adc	#3		;convert to sxb
	sta	sxb		;and save
	lda	sabtbl,y	;get sab
	sta	sab		;and set
	lda	maxdir		;get max dir
	sta	maxdrc		;set max dir record
	lda	maxdir+1
	lsr	a		;divide by 4
	ror	maxdrc
	lsr	a
	ror	maxdrc
	sta	maxdrc+1	;then save high
	lda	#0		;set mode to byte
	sta	blmode
	lda	maxblk+1	;branch if max block
	beq	ntm255		;not over 255
;if y=0 when the following line is executed it means
;that the user has put an illegal combination into
;the disk definition table. may want to consider
;putting some error checking here in the future if
;there is space in pem.
	dey			;back up index
	sec			;else set mode to word
	ror	blmode
ntm255	lda	exmtbl,y	;get extent mask
	sta	exm
	sec			;now calculate cexm1f
	lda	#31
	sbc	exmtbl,y
	sta	cexm1f
	ldx	curdrv		;get drive as pointer
	lda	bitmap,x	;get bit
	and	lginvc		;if logged in
	bne	extstm		;then exit
	lda	bitmap,x	;get bit back
	ora	lginvc		;set in log-in
	sta	lginvc		;and update
	jmp	flinal		;then fill in maps
extstm	rts			;and return
;fill in allocation map
flinal	jsr	setrw		;set to read/write
	lda	maxblk		;divide max block by
	sta	gpcnt		;eight to get max
	lda	maxblk+1
	ldx	#3
clcnab	lsr	a		;use a for speed
	ror	gpcnt
	dex
	bne	clcnab		;loop if more
	sta	gpcnt+1		;save high
	inc	gpcnt		;bump by one
	bne	*+5
	inc	gpcnt+1		;with carry
	lda	alcmap		;get map start
	ldy	alcmap+1
	sta	alcpnt		;set pointer to start
	sty	alcpnt+1
	ldy	#0		;clear index
clraml	lda	#0		;clear byte
	sta	(alcpnt),y	;put in map
	inc	alcpnt		;bump pointer
	bne	*+4
	inc	alcpnt+1	;with carry
	lda	gpcnt		;get low of count
	bne	*+5		;skip if not zero
	dec	gpcnt+1		;else drop high
	dec	gpcnt		;always drop low
	lda	gpcnt		;test for zero
	ora	gpcnt+1
	bne	clraml		;loop if more
;at this point complete map is cleared
	lda	maxdrc		;get low of max dir record
	sta	gpcnt
	lda	maxdrc+1	;high in a
	ldx	sxb		;set x according to block size
clcmdb	lsr	a		;do division
	ror	gpcnt
	dex
	bne	clcmdb		;until x is zero
	sta	gpcnt+1		;set high
	inc	gpcnt		;then bump by one
	bne	*+5
	inc	gpcnt+1
	stx	blknum		;clear block number
	stx	blknum+1
fildal	lda	blknum		;get block number
	ldy	blknum+1
	jsr	setblk		;set bit
	inc	blknum		;bump block number
	bne	*+5
	inc	blknum+1
	lda	gpcnt		;get low of count
	bne	*+5		;skip if not zero
	dec	gpcnt+1		;else drop high
	dec	gpcnt		;always do low
	lda	gpcnt		;test for zero
	ora	gpcnt+1
	bne	fildal		;loop if more
;at this point directory space is mapped
	jsr	intdrv		;initialize drive
	jsr	cldrnm		;clear directory number
fillpe	ldx	#1		;parameter for fill
	jsr	nxtdir		;execute for next directory
	bmi	extfil		;done if invalid
	ldy	subrec		;get offset
	lda	(bufadd),y	;get empty/valid flag
	cmp	#$e5		;if empty
	beq	fillpe		;try next
	ldx	#1		;parameter for fill in
	jsr	mapdir		;do directory map
	jmp	fillpe		;then loop
extfil	rts			;return
;initialize drive
; input:nsystr
; returns:none
; alters:all
intdrv	jsr	sim+24		;home then
	lda	nsystr		;get number of system tracks
	ldy	nsystr+1
	jmp	sim+30		;and set in sim
;directory record set up
; input:dirnum
; returns:none
; alters:all,recnum,dirrec
drrcsu	lda	dirnum+1	;move high dir number
	sta	recnum+1	;to record number
	lda	dirnum		;divide
	lsr	recnum+1	;directory by four
	ror	a
	lsr	recnum+1
	ror	a
	sta	dirrec		;and save
	sta	recnum		;set low record number
	lda	recnum+1	;get high
	sta	dirrec+1	;and set
	lda	#0		;clear top byte
	sta	recnum+2
;set track and sector
; input:recnum
; returns:none
; alters:all,countr,trkctr
sttrsc	ldx	#0		;clear track counter
	stx	trkctr
	stx	countr		;and record
	stx	countr+1	;counter
	stx	countr+2
trnxtr	lda	recnum		;from
	cmp	countr		;record number
	lda	recnum+1	;and if a
	sbc	countr+1	;borrow then
	lda	recnum+2
	sbc	countr+2
	bcc	higher		;gone too far
	clc			;else
	lda	countr		;get counter
	adc	sectrk		;add sectors per track
	sta	countr		;sectors per track
	lda	countr+1
	adc	sectrk+1
	sta	countr+1
	bcc	bumptr		;done if no carry
	inc	countr+2	;else bump high
bumptr	inx			;increase track count
	bne	trnxtr		;with carry
	inc	trkctr
	jmp	trnxtr		;then loop
higher	dex			;back up track
	cpx	#$ff		;see if wrap around
	bne	*+5		;wasn't
	dec	trkctr		;else drop high
	txa			;move to a
	clc			;add starting track
	adc	nsystr
	tax			;save in x
	lda	trkctr
	adc	nsystr+1
	tay			;move to correct registers
	txa
	jsr	sim+30		;then set in sim
	sec			;back
	lda	countr		;counter down
	sbc	sectrk		;by sectors per track
	sta	countr		;and save
	lda	countr+1
	sbc	sectrk+1
	sta	countr+1
	sec			;now 
	lda	recnum		;find difference
	sbc	countr		;as sector
	tax			;save in x
	lda	recnum+1
	sbc	countr+1
	tay			;move to correct registers
	txa
	jsr	sim+51		;translate
	jmp	sim+33		;and set through sim
;get block bit mask and index
; input:a&y=block number
; returns:a=bit mask and y=0
; alters:all and alcpnt
blkmsk	pha			;save block number
	sty	alcpnt+1	;including high
	ldy	#3		;divide by eight
blkmlp	lsr	alcpnt+1	;shift high
	ror	a
	dey			;loop until done
	bne	blkmlp
	clc			;now add map start
	adc	alcmap
	sta	alcpnt
	lda	alcpnt+1
	adc	alcmap+1
	sta	alcpnt+1
	pla			;get number back
	and	#%00000111	;look at 3 lsbs
	tax			;get
	lda	bitmsk,x	;mask
	rts			;and return
;test block
; input:a&y=block number
; returns:z=1 if unassigned
; 	   =0 if assigned and bit in a is set
; alters:all
tstblk	jsr	blkmsk		;get mask and index
	and	(alcpnt),y	;mask with map entry
	rts			;then return
;alter block status
; input:a&y=block number,x=1 if set
;		   	  =0 if reset
; returns:none
; alters:all and allocation map
altalc	cpx	#1		;if set
	beq	setblk		;go do it
clrblk	jsr	blkmsk		;else get mask
	eor	#$ff		;and complement
	and	(alcpnt),y	;preserve others
	sta	(alcpnt),y	;and save
	rts			;then return
setblk	jsr	blkmsk		;get mask
	ora	(alcpnt),y	;set bit
	sta	(alcpnt),y	;and put back
	rts			;then return
;set current drive to read only
; input:curdrv,ronlst,bitmap
; returns:none
; alters:a,x,p and ronlst
setron	ldx	curdrv		;get number
	lda	bitmap,x	;and get mask
	ora	ronlst		;or with status
	sta	ronlst		;and put back
	rts			;then return
;calculate checksum of buffer @ bufadd
; input: buffer@(bufadd)
; returns:a=checksum
; alters:a,y,p
clcchk	lda	#0		;clear accumulator
	ldy	#127		;start at end
chkmre	clc			;no carry
	adc	(bufadd),y	;add byte
	dey			;count down
	bpl	chkmre		;and loop until done
	rts			;then return
;check read/write status
; input:curdrv,ronlst
; returns:z=0 if r/o or z=1 if r/w
; alters:a,x,p
chkron	ldx	curdrv		;get current drive
	lda	bitmap,x	;get mask
	and	ronlst		;and test status
	rts
;initialize record counters from fcb
; input:fcb@(addinp)
; returns:none
; alters:a,y,p,nxtrec,numrec
inrcct	ldy	#32		;next record offset
	lda	(addinp),y	;get next record
	sta	nxtrec		;and save
	ldy	#15		;number records offset
	lda	(addinp),y	;get number
	sta	numrec		;and save
	rts			;and return
;update record counters in fcb
; input:nxtrec,numrec
; returns:none
; alters:all,fcb@(addinp)
updtrc	ldx	nxtrec		;get next record
	inx			;bump it
	txa			;transfer
	ldy	#32		;set offset
	sta	(addinp),y	;and store in fcb
	lda	numrec		;get number
	ldy	#15		;and its offset
	sta	(addinp),y	;and store
	rts			;then return
;execute open file
xopen	jsr	autodr		;auto drive select
;open file
; input:fcb @ (addinp)
; returns:n=1 if not found,a=dirmod (255 if not found)
; alters:all
opnfle	jsr	fndf13		;match all including extent
	bmi	extopn		;done if not found
	lda	#12		;point to first char
	ora	subrec		;add offset
	tay			;make it a pointer
nxopmv	lda	(bufadd),y	;get buffer contents
	tax			;and save
	tya			;save index
	and	#%00011111	;remove offset
	tay			;back to index
	txa			;get byte back
	sta	(addinp),y	;and store in fcb
	tya			;get index
	ora	subrec		;add offset back
	tay			;and make index again
	iny			;next position
	tya			;if index
	and	#%00011111	;not gone past
	bne	nxopmv		;end then loop
;now correct extent and max records
	ldy	#12		;point at extent in fcb
	lda	savext		;get save from search
	cmp	(addinp),y	;compare
	beq	extsme		;jump ahead if same
	sta	(addinp),y	;else change extent
	lda	#128		;assume fcb ext < dir ext
	bcc	fcbxls		;jump ahead if true
	asl	a		;clear a
fcbxls	ldy	#15		;point to max
	sta	(addinp),y	;and set
extsme	lda	dirmod		;else get number
extopn	rts			;and return
;execute close file
xclose	jsr	autodr		;auto drive select
;close file
;if file is r/o then no actual close
;operation is performed.
; input:fcb @ (addinp)
; returns:n=1 if not valid,a=dirmod (255 if invalid)
; alters:all
clsfle	jsr	fndf13		;match including extent
	bmi	extcls		;exit if not found
	jsr	chkron		;see if r/o
	bne	noclse		;branch if is
;now set flag to ensure directory extent and number of
;records fields are only changed if necessary.
;The decision to change is determined by whether or
;not the system is closing an extent less than the
;maximum extent in the directory entry. If that is
;the case, the directory extent and number of record
;fields are not changed.
	ldy	#12		;get extent
	lda	(addinp),y
	pha			;save it
	tya			;now look in directory
	ora	subrec
	tay
	pla			;get extent back
	cmp	(bufadd),y
	ror	skpdir		;save result
;now go do it
	jsr	updtdr		;update directory
noclse	lda	dirmod		;get directory number
extcls	rts			;and return
;execute find first match
xfndfr	jsr	autodr		;auto drive select
fndf13	lda	#13		;match including extent
;search for first match
; input:a=number char to match
; returns:n=1 if invalid,a=dirmod (255 if invalid)
; alters:all
frstsr	pha			;save number to match
	jsr	cldrnm		;clear directory number to -1
	jsr	intdrv		;and drive
	pla			;get number to match
;search for directory match
; input:a=number char to match
; returns:n=1 if not found,a=dirmod (255 if invalid)
; alters:all
search	sta	chrcnt		;save number
newtry	ldx	#0		;set for search
	stx	cmppnt		;clear pointer
	jsr	nxtdir		;get next entry
	bmi	exitsr		;exit if not found
	ldx	chrcnt		;get count
mremch	ldy	cmppnt		;get pointer
	inc	cmppnt		;and bump
	lda	(addinp),y	;get fcb entry
	cpy	#12		;see if at extent
	bne	notaex		;jump if not
	sta	savext		;save for later use
	pha			;save extent
	tya			;change to directory
	ora	subrec		;coordinates
	tay
	pla			;get extent back
	eor	(bufadd),y	;exclusive or with dir
	and	cexm1f		;and with exm complement + 1f
	beq	trynxt		;ok if zero
	bne	newtry		;else get next directory
notaex	cmp	#'?'		;if a ? then
	beq	trynxt		;is a match
	pha			;save char
	tya			;then add
	ora	subrec		;offset to
	tay			;make pointer
	pla			;get char back
	cmp	(bufadd),y	;if not same
	bne	newtry		;try next directory
trynxt	dex			;else count number down
	bne	mremch		;and loop if more
	lda	dirmod		;return with directory
exitsr	rts			;number mod 4
;calculate logical record number
; input:blknum
; returns:none
; alters:a,x,p,recnum
calrcn	ldx	sxb		;set x according to blkscd
mulmre	asl	blknum		;multiply block
	rol	blknum+1	;number
	rol	blknum+2
	dex			;by code
	bne	mulmre	
	lda	sab		;set mask in a
	and	nxtrec		;and with next record
	ora	recnum		;or with number
	sta	recnum		;and save
	rts
;update directory
updtdr	lda	#32		;change all
	ldx	#0		;from start
;change directory entry
; input:a=number char to change,x=starting position,fcb@(addinp)
; returns:none
; alters:all,directory,checksums
dirchg	sta	chrcnt		;save count
	dec	chrcnt		;back up
mrechg	clc			;clear carry
	txa			;get offset
	adc	chrcnt		;compute index
	tay			;and set
	cpy	#12		;see if at extent
	beq	docare		;if so do special
	cpy	#15		;see if at number rec
	bne	dntcar		;if not skip
docare	bit	skpdir		;check flag
	bpl	nochng		;skip if ok
dntcar	lda	(addinp),y	;get char
	pha			;save it
	lda	chrcnt		;get count
	ora	subrec		;add offset
	tay			;make an index
	pla			;get char back
	sta	(bufadd),y	;and put in buffer
nochng	dec	chrcnt		;count down
	bpl	mrechg		;and loop
	jsr	drrcsu		;set it up
	jmp	updtck		;and do change
;execute create file
xmake	jsr	autodr		;auto drive select
;create file
; input:fcb@(addinp)
; returns:n=1 if not valid,a=dirmod (255 if not valid)
; alters:dirnum,dirmod,fcb@(addinp)
mkefle	jsr	tstron		;test for r/o
	lda	addinp		;save fcb
	pha			;address
	lda	addinp+1	;on
	pha			;stack
	lda	empdvc		;then point
	ldy	empdvc+1	;to empty
	sta	addinp		;dummy
	sty	addinp+1	;fcb
	lda	#1		;match only
	jsr	frstsr		;first char
	pla			;restore
	sta	addinp+1	;fcb
	pla			;address
	sta	addinp		;from stack
	lda	dirmod		;get number mod 4
	bmi	extmke		;quit if not found
	ldy	#13		;else set up
	lda	#0		;to clear
mkeagn	sta	(addinp),y	;rest of
	iny			;fcb
	cpy	#33		;including next
	bne	mkeagn		;record
;the next two lines ensure that the extent and
;number of records fields are updated
	sec
	ror	skpdir
	jsr	updtdr		;update directory
	lda	dirmod		;get number
extmke	rts			;and quit
;extend file
; input:fcb@(addinp), x=1 read
;		        0 write
extend	stx	exrwfl		;save parameter
	jsr	clsfle		;close current extent
	bmi	extext		;exit if not found
	ldy	#12		;else
	lda	(addinp),y	;get extent
	clc			;and
	adc	#1		;add one
	and	#%00011111	;see if overflow
	beq	exteof		;eof if so
	sta	(addinp),y	;and save
	jsr	fndf13		;see if next extent exists
	bpl	opnext		;if so open
	lda	exrwfl		;if not and is write then create
	bne	extext		;else return as eof
dwrtex	jsr	mkefle		;create file
	jmp	tstext		;and test
opnext	jsr	opnfle		;open
tstext	bpl	extnok		;continue if ok
exteof	lda	#1		;else set eof
	rts			;and return
extnok	jsr	inrcct		;initialize counters
	lda	#0		;good
extext	rts			;return
;set up next directory block
; input:dirnum,x=1 for update checksum
; returns:a=dirmod (255 if invalid),n=1 if invalid
; alters:alll,dirnum,dirmod
nxtdir	txa			;save operation
	pha			;on stack
	inc	dirnum		;bump directory
	bne	*+5
	inc	dirnum+1
	lda	maxdir		;if not at limit continue
	cmp	dirnum
	lda	maxdir+1
	sbc	dirnum+1
	bcs	gtnxdr		;then continue
	pla			;else clear stack
	tax			;and set x
	jmp	cldrnm		;set to invalid
gtnxdr	lda	dirnum		;get low again
	and	#%00000011	;look at 2 lsbs
	sta	dirmod		;save mod 4
	asl	a		;multiply
	asl	a		;by
	asl	a		;32 to
	asl	a		;get pointer
	asl	a		;offset
	sta	subrec		;and save
	beq	getdir		;if zero read new
	pla			;else clear stack
	tax			;set x
	jmp	gotdir		;and exit
getdir	jsr	drrcsu		;set up to read
	jsr	rdesec		;do read
	pla			;get operation
	tax			;code
	jsr	chksop		;do it
gotdir	lda	dirmod		;and return
exnxdr	rts			;with number
;checksum operation
;this routine assumes calling routine has checked for
;valid dirnum and hence valid dirrec
; input:chkflg,dirrec,x (1=update else check)
; returns:none
; alters:map@(chkmap)
chksop	bit	chkflg		;check flag
	bmi	exnxdr		;done if set
	dex			;dec code
	bne	tstchk		;if not zero test
	jsr	clcchk		;else calculate
	jsr	clcckp		;calculate pointer
	sta	(chkpnt),y	;and save
	rts			;then return
tstchk	jsr	clcchk		;do calculation
	jsr	clcckp		;calculate pointer
	cmp	(chkpnt),y	;compare to old
	beq	exnxdr		;if equal ok
	jmp	setron		;else set to r/o
;get block number
; input:nxtrec,blmode,fcb@(addinp),sxb,exm
; returns:none
; alters:all,blknum
getblk	ldx	sxb		;set x according to blkscd
	lda	nxtrec		;get next record
gblp	lsr	a		;divide by 2 x times
	dex
	bne	gblp
	sta	blknum		;save previous as temp
;use extent as offset but first use sxb to create param
	sec
	lda	#8
	sbc	sxb
	tax
;now get extent from fcb
	ldy	#12
	lda	(addinp),y
	and	exm		;and with mask
	lsr	a		;shift with lsb to c
gbxlp	rol	a		;now go other way
	dex
	bne	gbxlp
	clc			;now add saved value
	adc	blknum		;back
	bit	blmode		;test mode
	bpl	*+3		;skip if byte
	asl	a		;else times two
	clc			;then add
	adc	#16		;offset into fcb
	sta	fcbind		;save for later
	tay			;set index
	lda	(addinp),y	;get number
	sta	blknum		;store
	iny
	lda	#0		;clear
	bit	blmode		;test mode
	bpl	*+4		;skip if byte
	lda	(addinp),y	;else get high
	sta	blknum+1	;high byte
	rts			;and return
;calculate chkpnt as function of dirrec and chkmap
; input:dirrec,chkmap
; returns:y=0
; alters:y,p,chkpnt
clcckp	pha			;save a
	clc
	lda	dirrec		;add record number
	adc	chkmap		;to start
	sta	chkpnt
	lda	dirrec+1
	adc	chkmap+1
	sta	chkpnt+1
	ldy	#0
	pla			;get a back
	rts
;clear directory number to $ffff
; input:none
; returns:a=$ff,n=1,z=0
; alters:a,p,dirnum,dirmod
cldrnm	lda	#$ff		;set to $ff
	sta	dirnum
	sta	dirnum+1
	sta	dirmod
	rts
;change allocation map
; input:subrec,directory record @ (bufadd)
; returns:none
; alters:all,allocation map
mapdir	clc			;add 16 to
	lda	subrec		;to subrec to point
	adc	#16		;to block number field
	tay			;make index
lpmpdr	sty	mpdrsy		;save index
	txa			;save x
	pha			;operation
	lda	(bufadd),y	;get block number
	sta	mpdrtm		;save in temp
	iny			;bump index for word
	jsr	gthibn		;get high part of number
mpdrnw	ora	mpdrtm		;see if zero
	beq	skpedr		;skip if zero
	jsr	gthibn		;get high again
	tay			;move to y
	lda	mpdrtm		;get low again
	jsr	altalc		;else alter map
skpedr	pla			;get operation
	tax			;back
	ldy	mpdrsy		;get index back
	iny			;bump it
	tya			;if still
	and	#%00001111	;in field
	bne	lpmpdr		;then loop
	rts			;else quit
;test r/w status
;does warm boot if r/o
; input:curdrv,ronlst
; returns:none
; alters:a,x,p
tstron	jsr	chkron		;test bit
	beq	exttro		;exit if r/w
	jsr	errout		;else send error
	lda	rommvc		;point to r/o
	ldy	rommvc+1	;message
	jsr	sndstr		;send it
	jmp	xwboot		;then abort
;set current drive to r/w
; input:curdrv,ronlst
; returns:ronlst
; alters:a,x,p,ronlst
setrw	ldx	curdrv		;get drive
	lda	bitmap,x	;and mask
	eor	#$ff		;complement
	and	ronlst		;and with status
	sta	ronlst		;save
exttro	rts			;return
;read sector
rdesec	jsr	sim+39		;do read
	jmp	chkrwe		;check for error
;update checksum and directory
updtck	ldx	#1		;set for update
	jsr	chksop		;do it
	lda	#1		;say is directory op
	bne	secwrt		;do it
;write sector
wrtsec	lda	wrtype		;get write type
secwrt	jsr	sim+42		;do write
chkrwe	cmp	#0		;if not ok
	beq	exttro		;done if zero
;read/write error
rwerrt	jsr	errout		;send error message
	lda	bdsmvc		;point to
	ldy	bdsmvc+1	;bad sector message
	jsr	sndstr		;and send
	jsr	getcon		;get input
	cmp	#cr		;if a cr
	beq	ignerr		;then continue
	jmp	xwboot		;else abort
ignerr	jmp	pcrlf		;crlf and return
;error output routine
; input:curdrv,pemmvc
; returns:none
; alters:all
errout	lda	pemmvc		;point to
	ldy	pemmvc+1	;error message
	jsr	sndstr		;send it
	lda	curdrv		;get drive number
	clc			;add
	adc	#'A'		;ascii a
	jmp	sndchr		;and send it
;get high part of block number if word (zero if byte)
; input:y=index to high,blmode,directory@(bufadd)+subrec
; returns:a=high part of block number
; alters:a,p,mpdrsy iff word
gthibn	lda	#0		;preset for byte
	bit	blmode		;test mode
	bpl	gthiex		;done if byte
	lda	(bufadd),y	;get high
	sty	mpdrsy		;alter y
gthiex	rts
;get console input
; input:pndkey
; returns:a=character
; alters:all,pndkey
getcon	lda	pndkey		;get pending
	pha			;save it
	lda	#0		;clear
	sta	pndkey		;pending
	pla			;restore
	bne	extget		;exit if not null
	jsr	sim+9		;else get new
extget	rts			;and return
;check keyboard status
;handles <ctl-s> for freeze and <ctl-c> for boot
; input:pndkey
; returns:a=0 if no input or <>0 if input
; alters:all,pndkey
kbdsts	lda	pndkey		;get pending
	bne	extkbd		;if there quit
	jsr	sim+6		;else test
	and	#$ff		;if zero
	beq	extkbd		;exit
	jsr	sim+9		;else get input
	cmp	#ctls		;if not freeze
	bne	newpnd		;save input
	jsr	sim+9		;else wait for more
	cmp	#ctlc		;if not abort
	bne	nowarm		;then jump
	jmp	xwboot		;else do warm boot
nowarm	lda	#0		;clear
	rts			;and return
newpnd	sta	pndkey		;save
	lda	#$ff		;set ready
extkbd	rts			;and return
;test character
; input:a=character
; returns:c=0 if control or c=1 if printing
; alters:p
tstchr	cmp	#cr		;if cr
	beq	chtext		;quit
	cmp	#lf		;if linefeed
	beq	chtext		;quit
	cmp	#ctli		;if tab
	beq	chtext		;quit
	cmp	#' '		;see if control
chtext	rts			;and return
;send string ending in $
; input:ay=string address
; returns:none
; alters:all,index,sndlpe+1 and +2
sndstr	sta	sndlpe+1	;set pointer
	sty	sndlpe+2
	ldy	#0
sndlpe	lda	$ffff,y		;get char
	cmp	#'$'		;if terminator
	beq	sndext		;then exit
	iny			;else bump
	sty	index		;and save
	jsr	sndchr		;send char
	ldy	index		;get index
	bne	sndlpe		;and loop
sndext	rts			;return
;send char to printer if enabled
; input:a=character,lstflg
; returns:a=character
; alters:x,y,p
lstout	bit	lstflg		;test flag
	bpl	extlst		;exit if off
	bit	outflg		;test output flag
	bmi	extlst		;done if set
	pha			;save char
	jsr	sim+15		;send
	pla			;get char
extlst	rts			;and done
;output a character
; input:a=character,console definition block in sim
; returns:none
; alters:all,positn
output	jsr	tstchr		;test it
	bcs	sndchr		;if not control jump
	pha			;else save
	lda	sysdef+4	;get invert
	jsr	nolist		;send to console
	lda	#'^'		;get arrow
	jsr	lstout		;send to printer
	pla			;get character
	ora	#'A'-1		;convert to ascii
	jsr	pchrot		;send to all
	lda	sysdef+3	;get normal
	jmp	nolist		;to console
sndchr	cmp	#ctli		;if not tab
	bne	pchrot		;send
tabspc	lda	#' '		;else get space
	jsr	pchrot		;send
	lda	positn		;get count
	and	#7		;if not mod 8
	bne	tabspc		;loop
	rts			;else exit
pchrot	pha			;save char
	jsr	kbdsts		;test input
	pla			;restore
	jsr	lstout		;to printer if on
nolist	pha			;save again
	bit	outflg		;test flag
	bmi	*+5		;done if set
	jsr	sim+12		;to console
	pla			;restore
	inc	positn		;bump col
	cmp	#' '		;if space or more
	bcs	extchr		;is ok
	cmp	sysdef+2	;also ok
	beq	extchr		;if forward
	dec	positn		;else drop back
	cmp	sysdef+0	;see if bs
	bne	tryotr		;branch if not
	dec	positn		;else drop again
	bmi	zrocol		;zero if <0
	rts			;else ok
tryotr	cmp	#cr		;if a cr
	beq	zrocol		;clear col
	cmp	sysdef+7	;if a formfeed
	beq	zrocol		;also clear
	cmp	sysdef+8	;if not home
	bne	extchr		;then done
zrocol	lda	#0		;clear
	sta	positn		;column
extchr	rts			;and exit
;go to left and space past prompt
; input:frscol,positn
; returns:none
; alters:positn
spcovr	lda	#cr		;get cr
	jsr	pchrot		;send to all
	lda	#lf		;send lf
	jsr	lstout		;only to printer
mreovr	lda	frscol		;get first
	cmp	positn		;see if there
	beq	extchr		;done if is
	lda	sysdef+2	;get forward
	jsr	nolist		;send it
	jmp	mreovr		;and loop
;buffered read
; input:buffer@(addinp)
; returns:none
; alters:all,buffer@(addinp)
bufinp	lda	#0		;clear
	ldy	#1		;length
	sta	(addinp),y	;position in buffer
	sty	bufpsn		;set point to 1
	lda	positn		;get current
	sta	frscol		;and save
nxtinp	jsr	getcon		;get input
	ldy	bufpsn		;get index
	cmp	#cr		;if not a cr
	bne	notcr		;then jump
	jmp	endlin		;else done
notcr	cmp	#delete		;if not delete
	bne	ntdelt		;then jump
	cpy	#1		;else if start
	beq	nxtinp		;then loop
	lda	(addinp),y	;get last
	pha			;save char
	ldy	#1		;point to count
	sec			;set carry
	lda	(addinp),y	;get count
	sbc	#1		;decrement
	sta	(addinp),y	;then save
	pla			;restore char
	dec	bufpsn		;backup pointer
	cmp	#' '		;if space or more
	bcs	nrmbs		;just backspace
	cmp	#ctli		;see if tab
	bne	ctlbs		;if not is control
	sec			;set flag
	ror	outflg
	lda	positn		;get position and save
	sta	lstcol
	jsr	spcovr		;else go back
	jsr	rptlne		;and retype
	lda	positn		;get new last position
	pha			;save on stack
	sec			;subtract to get delta
	lda	lstcol
	sbc	positn
	sta	lstcol		;and save
	asl	outflg		;clear flag
bstab	jsr	dobs		;do one
	dec	lstcol		;drop count
	bne	bstab		;loop if more
	pla			;get position
	sta	positn		;and set
	jmp	nxtinp		;then loop
ctlbs	lda	sysdef+3	;get normal
	jsr	chkbs		;bs if printing
	lda	sysdef+4	;same for invert
	jsr	chkbs		;then delete char itself
nrmbs	jsr	dobs		;do a backspace
	jmp	nxtinp		;and loop
ntdelt	cmp	#ctlp		;if not ctl-p
	bne	ntctlp		;then jump
	lda	lstflg		;else get printer flag
	eor	#$ff		;complement
	sta	lstflg		;save
	jmp	nxtinp		;and loop
ntctlp	cmp	#ctlx		;if not ctl-x
	bne	ntctlx		;then jump
	jsr	spcovr		;restart
	lda	sysdef+1	;get clear to eol
	jsr	nolist		;send it
	jmp	bufinp		;and start over
ntctlx	cmp	#ctlr		;if not ctl-r
	bne	ntctlr		;then jump
	jsr	spcovr		;restart
	jsr	rptlne		;retype line
	jmp	nxtinp		;and start over
ntctlr	iny			;next position
	sta	(addinp),y	;store char
	pha			;and save
	sty	bufpsn		;index
	ldy	#1		;point to count
	tya			;set a to 1
	clc			;then
	adc	(addinp),y	;add count
	sta	(addinp),y	;and save
	pla			;restore char
dontsv	jsr	output		;send char
	ldy	bufpsn		;get index
	lda	(addinp),y	;get char
	cmp	#ctlc		;if not ctl-c
	bne	ignrcc		;ignore
	ldy	#1		;get count
	lda	(addinp),y	;from buffer
	cmp	#1		;if not at start
	bne	ignrcc		;ignore
	jmp	xwboot		;else do warm boot
ignrcc	ldy	#1		;get
	lda	(addinp),y	;count
	dey			;point to max
	cmp	(addinp),y	;if length
	bcs	lineen		;at max jump
	jmp	nxtinp		;else loop
lineen	lda	#cr		;get a cr
endlin	jmp	pchrot		;and send
;cr and lf
pcrlf	lda	#cr		;then a
	jsr	pchrot		;cr
	lda	#lf		;and a
	jmp	pchrot		;lf
;retype line
rptlne	lda	bufpsn		;save point
	sta	numcnt		;as count
	lda	#1		;start position
	pha			;save
mrerpt	pla			;get position
	dec	numcnt		;count down
	bne	*+3		;continue if more
	rts			;else done
	tay			;else make index
	iny			;and bump
	tya			;save
	pha			;on stack
	lda	(addinp),y	;get char
	jsr	output		;send
	jmp	mrerpt		;and loop
;check for printing and backspace if needed
chkbs	cmp	#' '		;compare to space
	bcc	extdec		;not printing so done
;do a backspace
dobs	lda	sysdef+0	;get backspace
	pha			;save it
	jsr	nolist		;send
	lda	#' '		;get space
	jsr	nolist		;send
	pla			;get backspace
	jmp	nolist		;send it
;test for decimal digit
;if decimal then c=0 else c=1
tstdec	cmp	#'0'		;if under 0
	bcc	notdec		;then not decimal
	cmp	#'9'+1		;if 9 or under is ok
	bcc	extdec
notdec	sec			;else not a match
extdec	rts
;test for hexadecimal digit
;if hex then c=0 else c=1
tsthex	jsr	tstdec		;first try decimal
	bcc	extdec		;ok if dec
	cmp	#'A'		;if under A
	bcc	notdec		;then not hex
	cmp	#'F'+1		;set c in F compare
	rts
;bump load address by 128 and return in ay
adjdb	lda	dskbuf		;get old
	ldy	dskbuf+1	;address
	clc			;and bump
	adc	#128		;by 128
	sta	dskbuf		;save low
	bcc	*+6		;then bump
	iny			;and save
	sty	dskbuf+1	;high as needed
	rts
;move record from disk buffer to default buffer
mv128	lda	dskbuf		;get address
	ldy	dskbuf+1
	sta	mvfrom+1	;and set pointer
	sty	mvfrom+2
	ldx	#0		;clear index
mvfrom	lda	$ffff,x		;get byte
	sta	dflbuf,x	;move it
	inx
	bpl	mvfrom		;loop until done
	rts
;relocatable vectors
	.byte	$4c
extevc	.word	extexq-1
	.byte	$4c
sltmvc	.word	sltmsg
	.byte	$4c
empdvc	.word	empty
	.byte	$4c
rommvc	.word	romsg
	.byte	$4c
bdsmvc	.word	bdsmsg
	.byte	$4c
pemmvc	.word	pemmsg
	.byte	$4c
dcbevc	.word	dcb
;relocation stopper
	.byte	$ff
;messages
romsg	.byte	" - R/O$"
bdsmsg	.byte	" - BAD SECTOR"
	.byte	cr,lf,"<RET> TO IGNORE -- <OTHER> "
	.byte	"TO ABORT$"
pemmsg	.byte	cr,lf,"PEM ERROR ON $"
sltmsg	.byte	" - INVALID DRIVE$"
;dummy fcb
empty	.byte	$e5
;zero page switch enable table
swctbl	.byte	0,0,0,0,0,0,0,0
	.byte	0,0,1,0,0,1,1,1
	.byte	1,1,1,1,1,1,1,1
	.byte	0,0,1,0,0,0,0,0
	.byte	0,0,0,0
;bit mask table
bitmsk	.byte	128,64,32,16,8,4,2,1
;bit map table
bitmap	.byte	1,2,4,8,16,32,64,128
;extent mask table (also uses 3 bytes in sabtbl
exmtbl	.byte	0,1,3
;sab table
sabtbl	.byte	7,15,31,63,127
;variable storage
skpdir	.byte	0		;positive if no change
fcbind	.byte	0		;index to block number
savext	.byte	0		;save extent
frscol	.byte	0		;first col
pndkey	.byte	0		;pending input
lstflg	.byte	0		;printer flag
positn	.byte	0		;print position
swcflg	.byte	0		;zero page switch flag
bytinp	.word	0		;input value
cmdinp	.byte	0		;input command
addout	.word	0		;output address
bytout	=	addout		;output value
bufpsn	.byte	0		;input buffer position
exrwfl	.byte	0		;extend flag
tmpdrv	.byte	0		;temporary drive number
;align xqtvec on word boundary
	*=	*/2*2+2
xqtvec	.word	0		;command vector
countr	.word	0		;record counter
	.byte	0		;overflow
lkdown	.word	0		;down pnt. for block search
lookup	.word	0		;up pnt. for block search
olddrv	.byte	0		;old drive number
curdrv	.byte	0		;current drive
lginvc	.byte	0		;log in status
ronlst	.byte	0		;read write status
dirnum	.word	0		;directory number
subrec	.byte	0		;directory offset
recnum	.word	0		;record number
blknum	=	recnum		;block number
	.byte	0		;overflow
chrcnt	.byte	0		;character count
cmppnt	.byte	0		;comparison pointer
nxtrec	.byte	0		;next record
numrec	.byte	0		;number records
dirrec	.word	0		;directory record
dirmod	.byte	0		;directory mod 4
index	.byte	0		;buffer index
numcnt	.byte	0		;counter
outflg	.byte	0		;output enable flag
lstcol	.byte	0		;last column
mpdrsy	.byte	0		;save for y in mapdir
mpdrtm	.byte	0		;temp in mapdir
blmode	.byte	0		;<128 if byte else word
maxdrc	.word	0		;max directory record
sab	.byte	0		;mask for block
sxb	.byte	0		;shift for block
rtclk	.byte	0,0,0		;real time clock
gpcnt	.word	0		;gp counter
trkctr	.byte	0		;track counter
;following region is used to capture dcb
dcb
maxblk	.word	0		;maximum block number
sectrk	.word	0		;sectors per track
nsystr	.word	0		;number system tracks
blkscd	.byte	0		;block size code
maxdir	.word	0		;maximum directory number
alcmap	.word	0		;address of allocation map
chkflg	.byte	0		;check flag
chkmap	.word	0		;address of checksum map
wrtype	.byte	0		;write type 0=norm,1=dir,2=unalloc
exm	.byte	0		;extent mask
cexm1f	.byte	0		;exm complemented and 1f
;zero page save block
varblk
lowin	.word	0
	.word	0		;save bufadd
	.word	0		;save alcpnt
	.word	0		;save chkpnt
;--------------------------------
;dos/65 system interface module (sim)
;--------------------------------
	*=	pem+pemlng
sim
	*=	*+55
sysdef
	.end
