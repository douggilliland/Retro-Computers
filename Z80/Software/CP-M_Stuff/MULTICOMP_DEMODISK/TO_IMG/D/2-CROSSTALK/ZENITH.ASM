;	Crosstalk/S i/o drivers for ZENITH 89 and 90 computers


	org	100h

stat	equ	0ddh
data	equ	0d8h

	jmp	200h

	org	110h
sstat:	in	stat		; get serial port status
	ani	1		; mask input status bit
	ret			; and return

	org	120h

sin:	in	stat		; get port status
	ani	1		; char. waiting ?
	jz	sin		; no, loop until ready
	in	data		; get character into acc. 
	ret			; go home with it

	org	130h

sout:	push	psw		; save char. on stack
sout1:	in	stat		; get port status
	ani	20h		; mask output status bit
	jz	sout1		; loop until ready
	pop	psw		; get char. off stack
	out	data		; send to modem
	ret			; that's it

	org	140h		; this code MUST be here
	ret

	end
