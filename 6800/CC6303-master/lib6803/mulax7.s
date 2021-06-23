;
;	Multiply D by 7
;
	.export mulax7

	.setcpu 6803
	.code

mulax7:
	std @tmp1
	lsld
	lsld
	addd @tmp1
	addd @tmp1
	addd @tmp1
	rts
