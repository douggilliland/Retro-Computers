;
;	Compare top of stack with D
;

		.export tosgeax
		.code
tosgeax:
		tsx
		cmpa 2,x
		bne noteq
		cmpb 3,x
noteq:		jsr boolge
		jmp pop2
