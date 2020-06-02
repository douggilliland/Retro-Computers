	title	'div by power of two (function)'
	public	fdiv2
	extrn	?signal
;	entry:
;		p1 -> fixed(7) power of two
;		p2 -> floating point number
;	exit:
;		p1 -> (unchanged)
;		p2 -> (unchanged)
;	stack:	p2 / (2 ** p1)
fdiv2:			;HL = .low(.p1)
	mov	e,m	;low(.p1)
	inx	h	;HL = .high(.p1)
	mov	d,m	;DE = .p1
	inx	h	;HL = .low(p2)
	ldax	d	;a = p1 (power of two)
	mov	e,m	;low(.p2)
	inx	h	;HL = .high(.p2)
	mov	d,m	;DE = .p2
	xchg		;HL = .p2
;
;	A = power of 2, HL = .low byte of fp num
	mov	e,m	;E = low mantissa
	inx	h	;to middle of mantissa
	mov	d,m	;D = middle mantissa
	inx	h	;to high byte of mantissa
	mov	c,m	;C = high mantissa
	inx	h	;to exponent byte
	mov	b,m	;B = exponent
	inr	b	;B = 00?
	dcr	b	;becomes 00 if so
	jz	fdret	;to return from float div
dby2:	;divide by two
	ora	a	;counted power of 2 to zero?
	jz	fdret	;return if so
	dcr	a	;count power of two down
	dcr	b	;count exponent down
	jnz	dby2	;loop again if no underflow
;
;underflow occurred, signal underflow condition
	lxi	h,siglst;signal parameter list
	call	?signal	;signal underflow
	lxi	b,0	;clear to zero
	lxi	d,0	;for default return
;
fdret:	pop	h	;recall return address
	push	b	;save high order fp num
	push	d	;save low order fp num
	pchl		;return to calling routine
;
	dseg
siglst:	dw	sigcod	;address of signal code
	dw	sigsub	;address of subcode
	dw	sigfil	;address of file code
	dw	sigaux	;address of aux message
;	end of parameter vector, start of params
sigcod:	db	3	;03 = underflow
sigsub:	db	128	;arbitrary subcode for id
sigfil:	dw	0000	;no associated file name
sigaux:	dw	undmsg	;0000 if no aux message
undmsg:	db	32,'Underflow in Divide by Two',0
	end
