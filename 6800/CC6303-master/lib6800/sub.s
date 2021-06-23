
	.export tossubax


	.code
;
;	TODO - could we do this better with neg/com and add ?
;
tossubax:
	staa @tmp
	stab @tmp+1
	tsx
	ldaa 2,x	; top of maths stack as seen by caller
	ldab 3,x
	subb @tmp+1
	sbca @tmp
	jmp pop2
