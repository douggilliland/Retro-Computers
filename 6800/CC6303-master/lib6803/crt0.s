;
;	A dummy minimal crt0.s for now
;
	.setcpu	6803

	.code

start:
	ldaa #1
	staa @one
	ldx @zero
	pshx
	pshx
	jsr _main
	pulx
	pulx
	rts

