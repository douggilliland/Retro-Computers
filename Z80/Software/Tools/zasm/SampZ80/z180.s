	z180
	otim
	otimr
	otdm
	otdmr
	in0	a,07ch
	in0	b,07ch
	in0	m,07ch
	out0	008h,a
	out0	009h,b
	out0	007h,m
	mult	bc
	mult	de
	mult	hl
	mult	sp
	tst	b
	tst	c
	tst	m
	tsti	055h
	tstio	07cH
; wrong
	in0	5(ix),07ch
	mult	ix
; wrong
	tst	4(ix)
	slp
	z80
	tst	b
	tst	c
	tst	m
	slp
	i8080
	tst	b
	tst	c
	tst	m
	