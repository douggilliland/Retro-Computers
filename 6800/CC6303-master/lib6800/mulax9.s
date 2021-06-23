;
;	Multiply D by 9
;
	.export mulax9

	.code

mulax9:
	staa @tmp1
	stab @tmp1+1
	lslb
	rola
	lslb
	rola
	lslb
	rola
	addb @tmp1+1
	adca @tmp1
	rts
