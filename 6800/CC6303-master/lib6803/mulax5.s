;
;	Multiply D by 5
;
	.export mulax5

	.setcpu 6803
	.code

mulax5:
	std @tmp1
	lsld
	lsld
	addd @tmp1
	rts
