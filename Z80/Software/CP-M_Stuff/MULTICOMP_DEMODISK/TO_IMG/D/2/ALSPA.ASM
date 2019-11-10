;	Crosstalk/S i/o drivers for ALSPA computer
;	with modem connected to the MODEM port (port 4)


	org	100h

	jmp	200h

	org	110h
sstat:	in	5		; get serial port status
	ani	2		; mask input status bit
	ret			; and return

	org	120h

sin:	in	5		; get port status
	ani	2		; char. waiting ?
	jz	sin		; no, loop until ready
	in	4		; get character into acc. 
	ret			; go home with it

	org	130h

sout:	push	psw		; save char. on stack
sout1:	in	5		; get port status
	ani	1		; mask output status bit
	jz	sout1		; loop until ready
	pop	psw		; get char. off stack
	out	4		; send to modem
	ret			; that's it

	org	140h		; this code MUST be here
	ret

	end
