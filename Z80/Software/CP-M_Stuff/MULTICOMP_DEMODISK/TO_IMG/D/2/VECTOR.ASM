;               CROSSTALK configuration file for

;                        Vector Graphic

;	This file is to be assembled with the CP/M assembler and
;	patched into the XTALK.COM file with DDT. 

 
;	Set baud rate BEFORE entering Crosstalk !

	org	100h

true	equ	1
false	equ	0

zpb	equ	true		; set true to use port on ZPB board, else
bits	equ	not zpb		; set true to use BITSTREAMER board port.


	if	bits		; equates for bitstreamer
status	equ	13h
data	equ	12h
	endif

	if	zpb		; equates for ZPB serial port
status	equ	5
data	equ	4
	endif


	jmp	200h		; jump to program


	org	110h
sstat:	in	status		; get serial status
	ani	02		; character ready ?
	ret			; return

	org	120h

sin:	in	status		; check status
	ani	02		; mask ready bit
	jz	sin		; loop until char. ready
	in	data		; get char
	ret			; go home
		

	org	130h

sout:	push	psw		; save character
sout1:	in	status		; get status
	ani	2		; ready to send yet ?
	jz	sout1		; loop until ready
	pop	psw		; get char. back
	out	data		; send to modem
	ret			; that's all.

	org	0140h

scar:	ret			; this return MUST be here!!!

	end
