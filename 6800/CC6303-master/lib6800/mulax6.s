;
;	Multiply D by 3
;
	.export mulax6

	.code

mulax6:
	staa @tmp1
	stab @tmp1+1
	lslb
	rola
	addb @tmp1+1
	adca @tmp1
	lslb
	rola
	rts
