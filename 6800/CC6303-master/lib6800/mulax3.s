;
;	Multiply D by 3
;
	.export mulax3

	.code

mulax3:
	staa @tmp1
	stab @tmp1+1
	lslb
	rola
	addb @tmp1+1
	adca @tmp1
	rts
