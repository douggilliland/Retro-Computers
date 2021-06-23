
		.export _fgetc
		.export _getc
		.export _getchar

		.code

_fgetc:
_getc:
		tsx
		ldx 2,x		; FILE (and thus FCB) pointer
dogetc:
		tst ,x
		beq fms
		; actually we are a fake logical device
		; for now just console
		jmp __getch
fms:
		inx
		inx
		clr ,x
		clr 1,x
		jmp fms_and_errno

_getchar:
		ldx #stdin
		bra dogetc
