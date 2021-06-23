		.export _fputs
		.export _puts
		.code

_fputs:
		tsx
		ldx 4,x
		stx @tmp2
		tsx
		ldx 2,x
dofputs:
		tst ,x
		beq fms
		; console
		ldx @tmp2
conloop:	ldaa ,x
		beq done
		cmpa #10
		bne normal
		jsr $AD24
		bra nextcon
normal:
		jsr $AD18
nextcon:
		inx
		bra conloop
fms:		inx
		inx
		stx @tmp
nextchar:
		ldx @tmp2
		ldaa ,x
		beq done
		inx
		stx @tmp2
		ldx @tmp
		clr ,x
		clr 1,x
		jsr $B403
		beq nextchar
		jsr fcb_to_errno
		ldaa #$FF
		tab
		rts
done:		ldab #1
		clra
		rts
;
; For puts as we don't support freopen we know stdout is console. Now it may
; be that FLEX has a redirected console but it sorts that bit out		
_puts:
		tsx
putsl:
		ldx 2,x
		ldaa ,x
		beq putsnl
		jsr $AD18
		inx
		bra putsl
putsnl:		jmp $AD24
