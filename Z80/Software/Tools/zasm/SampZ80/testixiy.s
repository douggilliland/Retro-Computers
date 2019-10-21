	z80
			;
	nosub:	;no submit file! call SIGNON

CR	equ	13
LF	equ	10
;strings in DB does not work
SIGNON:	DB	'FILE DUMP VERSION 1.4$'
OPNMSG:	DB	CR,LF,'NO INPUT FILE PRESENT ON DISK$'
; must be changed to (also note labels ARE case sensitive)
signon:	text	'FILE DUMP VERSION 1.4$'
opnmsg:	DB	CR,LF
	text	'NO INPUT FILE PRESENT ON DISK$'
;NOTE escape is \ , using '' and "" works like \' and \"
	db	';','0','+','!','o','''','\''
	mov	a,0(ix)	;test bangA! mov a,0(iy);test bangB
MEM	EQU	56	;for a 56k system 
k.byte	equ	1024
cpm.sz	equ	MEM*k.byte

;multiple operands allowed in an expression
CPM.BS	equ	cpm.sz-20*k.byte
;does not need to be writen as ...
cpm.bia	equ	20*k.byte
cpm.bs	equ	cpm.sz-cpm.bia
;
ccp		equ	cpm.bs+3400H
bdos		equ	cpm.bs+3c00H
bios		equ	cpm.bs+4A00H
buf	equ	$
	db	0,9,8,7,9
eob	equ	$
bsz	equ	eob-buf
	iflt	bsz-8
	org	buf+8
	endif
;
;	org	-7573
x	equ
hn	equ	04h-5
on	equ	377o-7
bn	equ	101110b-hn
ch	equ	'y'-3
;
pb	equ	&hp200
nb	equ	-200
pok	equ	100
nok	equ	-1p00h
sb	equ	&h80
qok 	equ	-128
te	equ	-32000

bank.0	equ	400h

io.blk	equ	bank.0+&H0370
tp.stk	equ	io.blk-&H0040
	org	tp.stk

test2	equ	&hfc00
test3	equ	&hfc10-&Hfc20
test4	equ	&hfbff
; 
test5 	equ	5-80h-8h
;multiple characters allowed in single quote
test6	equ	'ui'-4

lb	equ	65539 
	org	&Hf000
	mov	a,0(ix)	;test bang1!  x123:mov a,0(iy);test bang2
	mov	b,test2-test3(ix)
	mov	b,test2-test4(ix)
	mov	c,-200(ix)
test	mov	d,-30(ix)
	mov	e,-40(ix)
	mov	h,-50(ix)
	mov	l,-40h(ix)
	mov	a,-&H90(iy)
test1	mov	b,10h(iy)
	mov	c,20h(iy)
	mov	d,300h(iy)
	mov	e,40(iy)
	mov	h,50(iy)
	mov	l,60(iy)

	mov	pb(ix),a
	mov	nb(ix),b
	mov	pok(ix),c
	mov	nok(ix),d
	mov	qok(ix),e
	mov	sb(ix),h
	mov	10(ix),l
	mov	02(iy),a
	mov	50(iy),b
	mov	60(iy),c
	mov	70(iy),d
	mov	80(iy),e
	mov	90(iy),h
	mov	50(iy),l

	mvi	0(ix),27
	mvi	0(ix),77
	mvi	0(ix),127
	mvi	0(ix),-97
	mvi	0(ix),-129
	mvi	0(ix),200
	mvi	0(ix),p
	mvi	0(iy),q
	mvi	0(iy),s
	mvi	0(iy),pok
	mvi	0(iy),nok
	mvi	0(iy),7
	mvi	0(iy),7
	mvi	0(iy),7



