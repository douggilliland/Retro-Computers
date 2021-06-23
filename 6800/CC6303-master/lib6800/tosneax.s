;
;	Compare top of stack with D
;

		.export tosneax
		.code
tosneax:
		tsx
		cmpb 3,x
		bne noteq
		cmpa 2,x
noteq:		jsr boolne
		jmp pop2
