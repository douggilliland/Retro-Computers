;
;	Left unsigned shift
;
	.export shlax15
	.export shlax14
	.export shlax13
	.export shlax12
	.export shlax11
	.export shlax10
	.export shlax9
	.export shlax7
	.export shlax6
	.export shlax5
	.export shlax4
	.export shlax3

	.setcpu 6803
	.code

shlax7:
	lsld
shlax6:
	lsld
shlax5:
	lsld
shlax4:
	lsld
shlax3:
	lsld
	lsld
	lsld
	rts

shlax9:
	tba
	clrb
	lsla
	rts
shlax10:
	tba
	clrb
	bra shl10e
shlax11:
	tba
	clrb
	bra shl11e
shlax12:
	tba
	clrb
	bra shl12e
shlax13:
	tba
	clrb
	bra shl13e
shlax14:
	tba
	clrb
	lsla
shl13e:
	lsla
shl12e:
	lsla
shl11e:
	lsla
shl10e:
	lsla
	lsla
	rts
shlax15:
	rorb			; save low bit into C
	ldd @zero		; clear preserving C
	rora			; into top
	rts
