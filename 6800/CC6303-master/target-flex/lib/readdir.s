
		.export _readdir
		.code


_readdir:
		tsx
		ldx 2,x			; DIR pointer
		ldab #17
		jsr $AD36		; add B to X
		clr 1,x
		ldab #7
		stab ,x
		jsr $AD06
		bne recordok
		ldab 1,x
		cmpb #8			; EOF
		beq dirdone
		; Error
		jsr fcb_to_errno
dirdone:	clra
		clrb
		jmp ret2
recordok:
		; Copy the name
		tsx
		ldx 2,x
		stx @tmp		; dirent
		ldab #21
		jsr $AD36		; get FCB name field
		ldaa #8			; max bytes
copynam:	ldab 4,x
		inx
		stx @tmp2
		beq namedone
		bsr storebtmp
		ldx @tmp2
		deca
		bne copynam
namedone:
		ldab #'.'
		bsr storebtmp
		tsx
		ldx 2,x
		ldab #29		; FCB extension field
		jsr $AD36		; X is now the ext field
		ldaa #3			; length
copyext:
		ldab ,x
		inx
		stx @tmp2
		beq extdone
		bsr storebtmp
		ldx @tmp2
		deca
		bne copyext
extdone:
		ldab #' '
		ldx @tmp
		stab ,x
		inx
		stx @tmp
		tsx
		ldaa 2,x
		ldab 3,x
		jmp ret2
		
storebtmp:
		ldx @tmp
		stab ,x
		inx
		stx @tmp
		rts
