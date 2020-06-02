;	Crosstalk/S i/o drivers for SOL-20 computer


	org	100h

	jmp	200h

	org	110h
sstat:	in	0f8h		; get serial port status
	ani	1		; mask input status bit
	ret			; and return

	org	120h

sin:	in	0f8h		; get port status
	ani	1		; char. waiting ?
	jz	sin		; no, loop until ready
	in	0f9h		; get character into acc. 
	ret			; go home with it

	org	130h

sout:	push	psw		; save char. on stack
sout1:	in	0f8h		; get port status
	ani	2		; mask output status bit
	jz	sout1		; loop until ready
	pop	psw		; get char. off stack
	out	0f9h		; send to modem
	ret			; that's it

	org	140h		; this code MUST be here
	ret

	end
