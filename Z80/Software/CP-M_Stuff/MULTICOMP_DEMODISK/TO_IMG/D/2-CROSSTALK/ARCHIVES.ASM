;	Crosstalk/S i/o drivers for ARCHIVES computer

true	equ	1
false	equ	0

status	equ	0edh
data	equ	0ech


	org	100h

	jmp	200h

	org	110h
sstat:	in	status		; get serial port status
	ani	1		; mask input status bit
	ret			; and return

	org	120h

sin:	in	status		; get port status
	ani	1		; char. waiting ?
	jz	sin		; no, loop until ready
	in	data		; get character into acc. 
	ret			; go home with it

	org	130h

sout:	push	psw		; save char. on stack
sout1:	in	status		; get port status
	ani	4		; mask output status bit
	jz	sout1		; loop until ready
	pop	psw		; get char. off stack
	out	data		; send to modem
	ret			; that's it

	org	140h		; this code MUST be here
	ret

	end
