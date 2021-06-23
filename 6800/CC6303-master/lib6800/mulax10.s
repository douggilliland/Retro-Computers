;
;	Multiply D by 10
;

	.export mulax10

	.code

mulax10:
	lslb
	rola			; x 2
	staa @tmp
	stab @tmp+1		; save
	lslb
	rola			; x 4
	lslb
	rola			; x 8
	addb @tmp+1
	adca @tmp		; x 10
	rts
