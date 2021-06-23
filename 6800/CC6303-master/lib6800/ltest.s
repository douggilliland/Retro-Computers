
	.export utsteax
	.export tsteax

	.code

utsteax:
tsteax:
	pshb
	staa @tmp1
	orab @tmp1
	orab @sreg
	orab @sreg+1
	pulb
	rts
