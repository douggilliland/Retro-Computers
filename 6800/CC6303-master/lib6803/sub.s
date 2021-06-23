
	.export tossubax

	.setcpu 6803
	.code
;
;	TODO - could we do this better with neg/com and add ?
;
tossubax:
	std @tmp
	tsx
	ldd 2,x		; top of maths stack as seen by caller
	subd @tmp
	jmp pop2
