
;	CROSSTALK drivers for ALTOS computers :

;	Revised 8/16/82 by LAF - added INIT routine to 
;	allow operation under MP/M 2.1

;	Revised again 8/24/82 by LAF - fixed ORG conflict
;	in CARR routine....

;	NOTE: for the Series 5 computers, set "acs8002" to TRUE


true	equ	1
false	equ	0

acs8002	equ	false		;set true for altos 8000-2 or series 5
others	equ	not acs8002	;for other models (-7,-10,etc.)

	if	acs8002	
status	equ	01fh
data	equ	01eh
	endif

	if	others
status	equ	029h
data	equ	028h
	endif


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

carr:	ret			;no carrier detect

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
