
		.export _rewind

_rewind:
		tsx
		ldx 2,x
		tst ,x
		beq failnotty
		inx
		inx
		clr 1,x
		ldab #5
		stab ,x
		jmp fms_and_errno
failnotty:
		ldab #25		; ENOTTY
		stab _errno+1
		clr _errno
		ldab #255
		tba			; -1
		rts
