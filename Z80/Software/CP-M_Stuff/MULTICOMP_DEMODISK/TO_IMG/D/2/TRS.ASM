;	I/O For TRS-80 model II with modem on port "A".
;	Hardware handshaking is not required.
 
;	Set baud rate on TRS-80 BEFORE entering Crosstalk

	org	100h

	jmp	200h		; jump into program

	org	110h
sstat	in	0f6h		; get port a status
	ani	01		; character ready ?
	ret

	org	120h

sin	in	0f6h		; check status
	ani	01		; mask ready bit
	jz	sin		; loop until char. ready
	in	0f4h		; get char
	ret			; go home
		

	org	130h

sout	push	psw		; save character
sout1	in	0f6h		; get status
	ani	04		; ready to send yet ?
	jz	sout1		; loop until ready
	pop	psw		; get char. back
	out	0f4h		; send to modem
	ret			; that's all.

	org	140h
scar	nop ! nop ! ret		; This code MUST be here!
