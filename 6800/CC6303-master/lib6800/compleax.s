;
;	Complement the 32bit working register
;
	.export compleax

compleax:
	staa @tmp
	stab @tmp+1
	ldaa @sreg
	ldab @sreg+1
	coma
	comb
	staa @sreg
	stab @sreg+1
	ldaa @tmp
	ldab @tmp+1
	coma
	comb
	rts
