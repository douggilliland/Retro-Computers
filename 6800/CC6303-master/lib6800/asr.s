;
;	top of stack arithmetic shift right by D
;
	.export tosasrax
	.code
tosasrax:
	tsx
asraxsh:
	asr ,x
	ror 1,x
	decb
	bne asraxsh
	rts
