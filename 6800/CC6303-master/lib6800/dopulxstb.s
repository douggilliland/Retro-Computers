;
;	Uninlined pulx equivalent
;
	.export dopulxstb
	.code

dopulxstb:
	tsx
	ldx ,x
	stx @tmp
	ldx 2,x
	ins
	ins
	ins
	ins
	stab ,x
	jmp jmptmp
