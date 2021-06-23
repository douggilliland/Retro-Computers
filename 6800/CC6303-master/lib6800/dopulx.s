;
;	Uninlined pulx equivalent
;
	.export dopulx
	.code

dopulx:
	tsx
	ldx ,x
	stx @tmp
	ldx 2,x
	ins
	ins
	ins
	ins
	jmp jmptmp
