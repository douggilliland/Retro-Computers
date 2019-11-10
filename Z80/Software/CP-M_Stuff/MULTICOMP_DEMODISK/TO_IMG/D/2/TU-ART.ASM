;	Crosstalk/S i/o drivers for CROMEMCO TU-ART


	org	100h

base	equ	0000		; base address of tu-art
stat	equ	base
data	equ	base+1

	jmp	200H		; skip past drivers

	org	110h
sstat:	in	stat		; get serial port status
	ani	40h		; mask input status bit
	ret			; and return

	org	120h

sin:	in	stat		; get port status
	ani	40h		; char. waiting ?
	jz	sin		; no, loop until ready
	in	data		; get character into acc. 
	ret			; go home with it

	org	130h

sout:	push	psw		; save char. on stack
sout1:	in	stat		; get port status
	ani	80h		; mask output status bit
	jz	sout1		; loop until ready
	pop	psw		; get char. off stack
	out	data		; send to modem
	ret			; that's it

	org	140h		; this code MUST be here
	ret

	end
