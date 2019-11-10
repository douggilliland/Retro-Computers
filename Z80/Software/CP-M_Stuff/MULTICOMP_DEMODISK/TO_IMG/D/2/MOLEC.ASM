;	Crosstalk I/O Drivers for Molecular computer

;	Note: set up the Serial B port for the appropriate
;	      baud rate (no interrupts) before running Crosstalk.

status	equ	63h
data	equ	62h

;	Standard ZSIO equates
rrf	equ	1
tbe	equ	4

start:	org	100h
	jmp	200h

	org	110h
stat:	in	status			; get port status
	ani	rrf			; mask for char.
	ret				; back to Crosstalk

	org	120h
sin:	in	status			; get port status
	ani	rrf			; mask for character
	jz	sin			; loop until character comes in
	in	data			; get the character
	ret				; back to prog.

	org	130h
sout:	push	psw			; save char. on stack
sout1:	in	status			; get port status
	ani	tbe			; ready to transmit
	jz	sout1			; loop if not ready
	pop	psw			; get the character back
	out	data			; and send it to the modem
	ret

	end	start
