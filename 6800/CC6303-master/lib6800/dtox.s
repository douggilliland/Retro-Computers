
	.export dtox
	.export dtoxclra
	.export dtoxldb
	.export dtoxldw
	.export dtoxstoretmp2
	.export dtoxstoretmp2b

dtox:
dtoxclra:
	stab @tmp+1
	staa @tmp
	ldx @tmp
	clra
	rts
dtoxldb:
	bsr dtoxclra
	ldab ,x
	rts

dtoxstoretmp2:
	bsr dtox
	ldaa @tmp2
	staa ,x
	ldab @tmp2+1
	stab 1,x
	rts

dtoxstoretmp2b:
	bsr dtoxclra
	ldab @tmp2+1
	stab ,x
	rts

dtoxldw:
	bsr dtox
	ldab 1,x
	ldaa ,x
	rts
