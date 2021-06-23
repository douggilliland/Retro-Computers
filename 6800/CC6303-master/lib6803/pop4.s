;
;	Stack unwind helpers
;
	.export pop4
	.export tpop4
	.export swap32pop4

	.setcpu 6803
	.code

swap32pop4:
	std @sreg
tpop4:
	ldd @tmp
pop4:
	pulx
	ins
	ins
	ins
	ins
	jmp ,x
