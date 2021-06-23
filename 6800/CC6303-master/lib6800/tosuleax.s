;
;	Compare top of stack with D
;

		.export tosuleax
		.code
tosuleax:
		tsx
		cmpa 2,x
		bne noteq
		cmpb 3,x
noteq:		jsr boolule
		jmp pop2
