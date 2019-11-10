;	CROSSTALK i/o drivers for GODBOUT interfacer

	org	100h
	jmp	init		; jump to initialization code

baud	equ	77h		; set for 300 baud


base	equ	10h		; base addr. of interfacer card
				; (change if your card is at another addr.)

txe	equ	1		; xmit empty
rrf	equ	2		; rcvr ready

data	equ	base
status	equ	base+1
mode	equ	base+2
cmnd	equ	base+3
select	equ	base+7



	org	110h
sstat:	in	status		; get status
	ani	rrf		; mask for ready bit
	ret			; and return

	org	120h
sin:	call	sstat		; test status
	jz	sin		; loop until a char. is ready
	in	data		; get the data
	ret			; and go home with it

	org	130h
sout:	push	psw		; save char.
sout1:	in	status		; get status
	ani	txe		; mask ready bit
	jz	sout1		; loop until ready
	pop	psw		; get char. back
	out	data		; send it
	ret			; go home

	org	140h
carr:	nop ! nop ! ret		; dummy carrier routine

init:	mvi	a,7		; select port 7
	out	status
	mvi	a,0eeh
	out	mode
	mvi	a,baud
	out	mode
	mvi	a,27h
	out	cmnd
	jmp	200h		; jump on to xtalk


	end
