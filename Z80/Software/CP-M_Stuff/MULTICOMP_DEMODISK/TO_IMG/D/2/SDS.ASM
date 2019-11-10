;	I/O For Sierra Data Sciences SBC 100  
 
;	Rev 1.1 4/1982 LAF

true	equ	1
false	equ	0

porta	equ	false		; set true if modem on port a
portb	equ	true		;  "                      " b

 	if	porta
	status	equ	81h
	data	equ	80h
	endif

	if	portb
	status	equ	83h
	data	equ	82h
	endif


	org	100h

init:	mvi	a,1
	out	status
	mvi	a,4		;shut off SIO interrupts
	out	status

	jmp	200h		; jump into program

	org	110h
sstat	in	status		; get port status
	ani	01		; character ready ?
	ret

	org	120h

sin	in	status		; check status
	ani	01		; mask ready bit
	jz	sin		; loop until char. ready
	in	data		; get char
	ret			; go home
		

	org	130h

sout	push	psw		; save character
sout1	in	status		; get status
	ani	04		; ready to send yet ?
	jz	sout1		; loop until ready
	pop	psw		; get char. back
	out	data		; send to modem
	ret			; that's all.

	org	140h
scar	nop ! nop ! ret		; This code MUST be here!

	end
