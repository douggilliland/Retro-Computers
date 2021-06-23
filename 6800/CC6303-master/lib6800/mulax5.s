;
;	Multiply D by 5
;
	.export mulax5

	.code

mulax5:
	staa @tmp1
	stab @tmp1+1
	lslb
	rola
	lslb
	rola
	addb @tmp1+1
	adca @tmp1
	rts
