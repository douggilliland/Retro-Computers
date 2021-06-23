	.export lateadjustsp

	.code
;
;	Entered with X pointing to the 16bit modifier
;
lateadjustsp:
	sts @tmp
	ldaa @tmp
	ldab @tmp+1
	addb 1,x
	adca ,x
	staa @tmp
	stab @tmp+1
	lds @tmp
	rts
