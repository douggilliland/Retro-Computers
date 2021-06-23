;
;	Right unsigned shift
;
	.export shrax15
	.export shrax14
	.export shrax13
	.export shrax12
	.export shrax11
	.export shrax10
	.export shrax9
	.export shrax8
	.export shrax7
	.export shrax6
	.export shrax5
	.export shrax4
	.export shrax3

	.code

shrax7:
	lsra
	rorb
shrax6:
	lsra
	rorb
shrax5:
	lsra
	rorb
shrax4:
	lsra
	rorb
shrax3:
	lsra
	rorb
	lsra
	rorb
	lsra
	rorb
	rts

shrax8:
	tab
	clra
	rts
shrax9:
	tab
	clra
	lsrb
	rts
shrax10:
	tab
	clra
	bra shr10e
shrax11:
	tab
	clra
	bra shr11e
shrax12:
	tab
	clra
	bra shr12e
shrax13:
	tab
	clra
	bra shr13e
shrax14:
	tab
	clra
	lsrb
shr13e:
	lsrb
shr12e:
	lsrb
shr11e:
	lsrb
shr10e:
	lsrb
	lsrb
	rts

;
;	There are two possible outputs - 0 and -1 based upon the top bit
;
shrax15:
	rola			; save top bit into C
	ldaa #0			; clear preserving C
	ldab #0
	rolb			; and C into low bit
	rts
