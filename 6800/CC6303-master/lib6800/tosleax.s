;
;	Compare top of stack with D
;

		.export tosleax
		.code
tosleax:
		tsx
		cmpa 2,x
		bne noteq
		cmpb 3,x
noteq:		jsr boolle
		jmp pop2
