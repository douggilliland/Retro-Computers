;	Crosstalk/S i/o drivers for NNC computer
;	with modem connected to the printer port


data	equ	0ah		; data port address
status	equ	0bh		; status port address

;	Standard 8251 equates

rrf	equ	02h		; receive register full bit (data avail.)
tbe	equ	01h		; transmitter reg. empty



	org	100h

	jmp	200h

	org	110h
sstat:	in	status		; get serial port status
	ani	rrf		; mask input status bit
	ret			; and return

	org	120h

sin:	in	status		; get port status
	ani	rrf		; char. waiting ?
	jz	sin		; no, loop until ready
	in	data		; get character into acc. 
	ret			; go home with it

	org	130h

sout:	push	psw		; save char. on stack
sout1:	in	status		; get port status
	ani	tbe		; mask output status bit
	jz	sout1		; loop until ready
	pop	psw		; get char. off stack
	out	data		; send to modem
	ret			; that's it

	org	140h		; this code MUST be here
	ret

	end
