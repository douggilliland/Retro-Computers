
	.export storedpush
	.export pshtop
	.code
;
;	Store D and push it
;
storedpush:
	staa 2,x		; save D at top of stack (as seen by caller)
	stab 3,x
pshtop:
	ldx ,x			; get return address
	stx @tmp		; patch it in
	tsx
	ldx 2,x			; get saved D
	stx ,x			; overwrite return address
	jmp jmptmp		; to caller without adjusting stack


