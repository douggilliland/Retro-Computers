;
;	A dummy minimal crt0.s for now
;
	.code

	.export _exit

start:
	ldaa #1
	staa @one
	clra
	clrb
	sts exitsp
	psha
	pshb
	psha
	pshb
	ldab #4
	jsr _main
	bra doexit

_exit:
	tsx
	ldaa 3,x
	ldab 4,x
doexit:
;
;	No atexit support yet
;
	lds exitsp
	rts

	.bss
exitsp:
