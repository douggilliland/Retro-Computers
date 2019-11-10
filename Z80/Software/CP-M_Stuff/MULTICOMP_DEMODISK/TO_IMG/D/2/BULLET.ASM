;	I/O For Wave-Mate Bullet computer
;	Hardware handshaking is not required.
 

	org	100h

stat	equ	3		; status port
data	equ	2		; data port


	jmp	200h		; jump into program

	org	110h
sstat	in	stat		; get port a status
	ani	01		; character ready ?
	ret

	org	120h

sin	call	sstat		; check status
	jz	sin		; loop until char. ready
	in	data		; get char
	ret			; go home
		

	org	130h

sout	push	psw		; save character
sout1	in	stat		; get status
	ani	04		; ready to send yet ?
	jz	sout1		; loop until ready
	pop	psw		; get char. back
	out	data		; send to modem
	ret			; that's all.

	org	140h
scar	nop ! nop ! ret		; This code MUST be here!
