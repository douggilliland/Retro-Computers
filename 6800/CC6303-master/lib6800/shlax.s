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

	.code

shlax7:
	lslb
	rora
shlax6:
	lslb
	rora
shlax5:
	lslb
	rora
shlax4:
	lslb
	rora
shlax3:
	lslb
	rora
	lslb
	rora
	lslb
	rora
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
	ldaa #0			; clear preserving C
	ldab #0
	rora			; into top
	rts
