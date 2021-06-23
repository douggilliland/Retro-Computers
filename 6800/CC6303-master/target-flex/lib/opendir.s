
		.export _opendir

		.code

_opendir:
		ldab #<322+15
		ldaa #>322+15
		jsr __malloc
		staa @tmp
		orab @tmp
		beq nospace
		stab @tmp+1	; @tmp is the struct
		ldab #15	; size of dirent
		jsr $AD36	; add b to X - point at FILE struct
		tsx
		ldx 2,x
		jsr parsename	; parse name into fcb at @tmp + 2
		beq badname
		tsx
badname:
		ldab #22		; EINVAL
		jmp erroutb
nospace:	ldab #12
		jmp erroutb

open_read:
		ldaa #$01		; read open
		ldx @tmp
		inx
		inx			; FCB
		clr 1,x
		staa ,x			; command mode
		jsr $BE06
		bne openfail
		pulb
		stab 59,x		; binary/ascii set
		ldab @tmp+1
		ldaa @tmp
		rts			; return the handle
openfail:
		jsr fcb_to_errno
		clra			; NULL return
		clrb
opendone:
		rts
