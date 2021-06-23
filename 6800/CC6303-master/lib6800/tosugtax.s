;
;	Compare top of stack with D
;

		.export tosugtax
		.code
tosugtax:
		tsx
		cmpa 2,x
		bne noteq
		cmpb 3,x
noteq:		jsr boolugt
		jmp pop2
