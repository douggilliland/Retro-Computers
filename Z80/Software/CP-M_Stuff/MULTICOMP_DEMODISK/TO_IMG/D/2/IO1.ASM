;	Serial i/o for MicroPro I/O master with modem
;	on serial port # 1 :


	org	100h

	JMP	200h		;Jump past config. block into program

	org	110h
SSTAT:	in	0fbH		;get serial port status
	ani	2		;Test for char. waiting
	ret			;and return

SIN:	ORG	120h
	in	0fbh		;get serial port status
	ani	2		;char. ready ?
	jz	sin		;loop if not
	in	0fah		;get char.
	ret			;and return

SOUT:	ORG	130h
	push	psw		;SAVE CHAR.
SOUT1:	in	0fbh		;get status
	ani	1		;ready to send yet ?
	jz	sout1		;loop if not
	pop	psw		;put char. in acc.
	out	0fah		;and send it to modem
	ret

SCAR:	ORG	140h
	nop ! nop ! ret		;this code MUST be here !

	end

