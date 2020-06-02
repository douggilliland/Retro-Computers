;	Crosstalk/S i/o drivers for XEROX  820 computer
;	with modem on communications or printer ports


true	equ	1
false	equ	0

comm	equ	true		;set TRUE if modem on comm. port
prin	equ	false		;set TRUE if modem on print. port

	if	comm
status	equ	6		;comm. status port
data	equ	4		;comm. data port
	endif

	if	prin
status	equ	7		;comm. status port
data	equ	5		;comm. data port
	endif

	org	100h
	jmp	200h		;jump into CROSSTALK

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
