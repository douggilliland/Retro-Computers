;
;	Uninlined pulx equivalent
;
	.export dopulxstd
	.code

dopulxstd:
	tsx
	ldx ,x
	stx @tmp
	ldx 2,x
	ins
	ins
	ins
	ins
	staa ,x
	stab 1,x
	jmp jmptmp
