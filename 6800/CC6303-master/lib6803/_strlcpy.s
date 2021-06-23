
		.export _strlcpy

		.setcpu 6803
		.code

_strlcpy:
		tsx
		ldd 2,x		; size limit
		addd 4,x	; source limit marker
		std @tmp
		ldd 6,x		; dest
		std @tmp2
		ldx 4,x		; source
loop:
		ldab ,x
		beq end		; null terminator
		pshx
		ldx @tmp2	; copy byte
		stab ,x
		inx
		stx @tmp2
		pulx
		inx
		cpx @tmp	; source hit limit ?
		bne loop
		; We ran out of space
		dex
		clr ,x
		tsx		; if we ran out of space we copied size
		ldd 2,x
		rts
end:
		ldx @tmp2	; get the destination
		clr ,x		; clear the final byte
		tsx
		ldd @tmp2	; end byte
		addd @one	; +1
		subd 2,x	; - start (size used)
		rts
