;
;	Save and restore the 32bit working register to a workspace
;

	.export saveeax
	.export resteax

	.code

saveeax:
	staa @regsave
	stab @regsave+1
	ldaa @sreg
	ldab @sreg+1
	staa @regsaveh
	stab @regsaveh+1
	rts
resteax:
	ldaa @regsaveh
	ldab @regsaveh+1
	staa @sreg
	stab @sreg+1
	ldaa @regsave
	ldab @regsave+1
	rts

	.zp

regsave:
	.word 0
regsaveh:
	.word 0
