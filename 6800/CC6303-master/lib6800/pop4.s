;
;	Stack unwind helpers
;
	.export pop4
	.export tpop4
	.export swap32pop4

	.code

swap32pop4:
	staa @sreg
	stab @sreg+1
tpop4:
	ldaa @tmp
	ldab @tmp+1
pop4:
	tsx		; Fake the missing pulx
	ldx ,x
	ins
	ins
	ins
	ins
	ins
	ins
	jmp ,x
