
;	CROSSTALK drivers for ATTACHE computers :

;	Revised 8/16/82 by LAF - added INIT routine to 
;	allow operation under MP/M 2.1
;	Revised 9/17/82 by MAW - configured Altos drivers
;	for Attache computer.


status	equ	0f1h
data	equ	0f0h


start:	org	100h
	jmp	init		;go set up port

	org	110h
sstat:	in	status		;get serial port status
	ani	1		;Test for char. waiting
	ret			;and return

sin:	org	120h
	in	status		;get serial port status
	ani	1		;char. ready ?
	jz	sin		;loop if not
	in	data		;get char.
	ret			;and return

sout:	org	130h
	push	psw		;save char.
sout1:	mvi	a,10h		;reset serial status
	out	status
	in	status		;get status
	ani	04h		;ready?
	cpi	04h
	jnz	sout1		;loop if not
	pop	psw		;put char. in acc.
	out	data		;and send it to modem
	ret


CARR:	nop ! nop ! ret		;no carrier detect

init:	; set up Altos port for communications:

	mvi	a,18h		; reset port
	out	status
	out	status
	mvi	a,1		; point to WR #1
	out	status
	xra	a		; no interrupts
	out	status
	mvi	a,3		; point to WR #3
	out	status
	mvi	a,0c1h		; Rx 8 bits, Rx enable
	out	status
	mvi	a,4		; point to WR #4
	out	status
	mvi	a,44h		; 16X clock, 1 stop bit
	out	status
	mvi	a,5		; point to WR#5
	out	status
	mvi	a,0eah		; DTR on, Tx 8 bits, Tx enable, RTS on
	out	status
	jmp	200h		; now jump into xtalk program

	end
