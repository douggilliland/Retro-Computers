;
;	Multiply D by 12
;

	.export mulax12

	.code

mulax12:
	lslb
	rola			; x 2
	lslb
	rola			; x 4
	staa @tmp
	stab @tmp+1		; save
	lslb
	rola			; x 8
	addb @tmp+1
	adca @tmp		; x 12
	rts
