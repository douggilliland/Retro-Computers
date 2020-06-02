;	Serial i/o for DYNABYTE computer with modem
;	on port user1 or user2 :


port	equ	1		;set for port 1

base	equ	80h+((port-1)*10h)

status	equ	base+3
datain	equ	base
dataout	equ	base+6

tre	equ	10h		;xmit reg empty bit
rda	equ	8		;recv dta available bit


start:	org	100h
	jmp	200h


	org	110h
SSTAT:	in	status		;get serial port status
	ani	rda		;Test for char. waiting
	ret			;and return

SIN:	ORG	120h
	in	status		;get serial port status
	ani	rda		;char. ready ?
	jz	sin		;loop if not
	in	datain		;get char.
	ret			;and return

SOUT:	ORG	130h
	push	psw		;SAVE CHAR.
SOUT1:	in	status		;get status
	ani	tre		;ready?
	jz	sout1		;loop if not
	pop	psw		;put char. in acc.
	out	dataout		;and send it to modem
	ret


carr:	org	140h
	nop ! nop ! ret


	end	start
