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

	.setcpu 6803
	.code
shrax7:
	lsrd
shrax6:
	lsrd
shrax5:
	lsrd
shrax4:
	lsrd
shrax3:
	lsrd
	lsrd
	lsrd
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

shrax15:
	rola
	ldd @zero
	bcc ret0
	coma
	comb
ret0:
	rts
