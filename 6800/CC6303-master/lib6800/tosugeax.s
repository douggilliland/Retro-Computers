;
;	Compare top of stack with D
;

		.export tosugeax
		.code
tosugeax:
		tsx
		cmpa 2,x
		bne noteq
		cmpb 3,x
noteq:		jsr booluge
		jmp pop2
