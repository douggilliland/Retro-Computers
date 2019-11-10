	title	'division by power of two'
	public	div2
	extrn	?signal
;	entry:
;		p1 -> fixed(7) power of two
;		p2 -> floating point number
;	exit:
;		p1 -> (unchanged)
;		p2 -> p2 / (2**p1)
div2:			;HL = .low(.p1)
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
	inx	h	;to middle of mantissa
	inx	h	;to high byte of mantissa
	inx	h	;to exponent byte
	inr	m
	dcr	m	;p2 already zero?
	rz		;return if so
dby2:	;divide by two
	ora	a	;counted power of 2 to zero?
	rz		;return if so
	dcr	a	;count power of two down
	dcr	m	;count exponent down
	jnz	dby2	;loop again if no underflow
;
;underflow occurred, signal underflow condition
	lxi	h,siglst;signal parameter list
	call	?signal	;signal underflow
	ret		;normally, no return
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
