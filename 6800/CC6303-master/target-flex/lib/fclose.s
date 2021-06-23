
		.export _fclose
		.export _closedir
		.code

_closedir:
		tsx
		ldx 2,x
		ldab #17		; move to FCB
		jsr $AD36		; add B to X
		bra closer
_fclose:
		tsx
		ldx 2,x
		tst ,x
		beq notfms
		inx
		inx
closer:
		clr 1,x
		ldab #4
		stab ,x
		jsr fms_and_errno
		pshb
		psha
		tsx
		ldx 4,x
		jsr __free
		pula
		pulb
		rts
notfms:
		tsx
		ldx 2,x			; right address for dir or file free
		jsr __free
		clra
		clrb
		rts

