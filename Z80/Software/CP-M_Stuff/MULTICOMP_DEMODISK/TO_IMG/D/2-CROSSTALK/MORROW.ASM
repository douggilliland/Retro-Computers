;	Crosstalk I/O Primitives for Morrow Decisions 1

base	equ	48h		; base i/o address 
rbr	equ	base		; ACE receiver buffer register
thr	equ	base		; ACE transmitter holding register
dll	equ	base		; ACE baud rate divisor latch (lsb)
dlm	equ	base+1		; ACE baud rate divisor latch (msb)
ier	equ	base+1		; ACE interrupt enable register
clk	equ	base+2		; WB14 printer select port
lcr	equ	base+3		; line control register
lsr	equ	base+5		; line status register
msr	equ	base+6		; modem status register
grpsel	equ	base+7		; group select bit

dlab	equ	80h		; divisor latch access bit
thre	equ	20h		; transmitter holding reg. empty mask
dsr	equ	20h		; data set ready mask
rrf	equ	01h		; receive register full mask
dcd	equ	80h		; data carrier detect mask

wl5	equ	00h		; 5 bit word length
wl6	equ	01h		; 6 bit word length
wl7	equ	02h		; 7 bit word length
wl8	equ	03h		; 8 bit word length

wl	equ	wl8		;******* set to proper word length *******

st1	equ	00h		; 1 stop bit
st2	equ	04h		; 2 stop bits

st	equ	st1		;******* set to proper stop bits *********

parn	equ	00h		; no parity
pare	equ	18h		; even parity
paro	equ	08h		; odd parity

par	equ	parn		;******* set to necessary parity *********

lb300	equ	80h		; 300 baud low divisor
hb300	equ	01h		; 	   high divisor

lb600	equ	0c0h		; 600 baud low divisor
hb600	equ	00h		; 	   high divisor

lb1200	equ	60h		; 1200 baud low divisor
hb1200	equ	00h		;	    high divisor

lb2400	equ	30h		; 2400 baud low divisor
hb2400	equ	00h		; 	    high divisor

lb4800	equ	18h		; 4800 baud low divisor
hb4800	equ	00h		;	    high divisor

baudl	equ	lb300		;******* set to proper baud divisor *****
baudh	equ	hb300		;******* set to proper baud divisor *****

group	equ	2		;******* set to proper ACE

imask	equ	0		; disable all interrupts on this ACE


	org	100h
start:	jmp	init		; go do initialization

	org	110h
stat:	call	setgrp		; go set ACE to access 
	in	lsr		; read line status register
	ani	rrf		; mask for receive register full
	ret

	org	120h
sin:	call	stat		; set group and get status
	jz	sin		; and loop until character is ready
	in	rbr		; get character from receive buffer
	ret

	org	130h
sout:	push	psw		; save character on stack
	call	setgrp		; go set to proper ACE
sout1:	in	lsr		; read line status register
	ani	thre		; mask for trans. holding reg. empty
	jz	sout1		; loop until it is ready
	pop	psw		; restore character
	out	thr		; and send to trans. holding register
	ret

	org	140h
carr:	call	setgrp		; set to ACE
	in	msr		; read modem status
	ani	dcd		; mask for carrier
	ret


init:	call	setgrp		; point at correct ACE
	mvi	a,wl+st+par+dlab	; set dlab + options
	out	lcr		; and send to line control reg.
	mvi	a,baudl		; get low byte of baud rate divisor
	out	dll		; and send it
	mvi	a,baudh		; now get high byte
	out	dlm		; and send it too
	mvi	a,wl+st+par	; set word length, stop bits, and parity
	out	lcr		; and reset line control register (no dlab)
	xra	a		; clear accumulator
	out	lsr		; clear data available flag
	mvi	a,imask		; get int. mask
	out	ier
	jmp	200h		; and jump into Crosstalk

setgrp:	mvi	a,group		; select the ACE
	out	grpsel		; and send it
	mvi	a,wl+st+par	; no dlab.
	out	lcr
	ret			; and back to where we came from

	end	start
