;
;	See "Math in the Real World" - Joel Boney, Byte  Sept 1978
;
;
;
;	The tricky bit here is trying to keep it all in registers. To
;	make that work we keep the exponent in A and the data in B + sreg
;
fpadd:
	bsr fpsetup
	ldaa @sreg+1
	adda 3,x
	staa @sreg+1
	ldaa @sreg
	adca 2,x
	staa @sreg
	adcb 1,x
	ldaa ,x
	; Normalize is called with C indicating an overflow on the
	; fraction - can that occur - I think not due to the sign fixing
	jsr normalize
	jsr roundup
	rts

fpsub:
	bsr fpsetup
	ldaa @sreg+1
	suba 3,x
	staa @sreg+1
	ldaa @sreg
	sbca 2,x
	staa @sreg
	sbcb 1,x
	ldaa ,x
	jsr normalize
	jsr roundup
	rts

fpmul:
	adda ,x		; new exponent
	; TODO mul 24x24 of the fraction
	jsr normalize
	jsr roundup
	rts

fpdiv:
	psha
	ldaa 1,x
	oraa 2,x
	oraa 3,x
	beq  div0
	lsrb
	ldaa @sreg
	rora
	staa @sreg
	ldaa @sreg+1
	rora
	staa @sreg+1
	pula
	inca
	; TOO div24  sreg/x
	; Expoent
	suba ,x
	jsr normalize
	jsr roundup
	rts


;
;	Keep moving the fraction left and decrementing the exponent.
;	On entry the one complication we have is that carry may be set
;	indicating the need to go the other way
;
normalize:
	rolb
	bcs normalize_done
	rorb
	lsl @sreg+1
	rol @sreg
	rolb
	inca
	bra normalize
normalize_done
	rorb
	rts	

normalize_done
	rorb
	rts

;
;	Align the two values, make sure the fractions are positive
;	and prepare.
;
fpsetup:
	cmpa ,x			; which sign is biggest
	beq aligned
	bcc shiftd
	inc ,x			; right we go
	lsr 1,x
	ror 2,x
	ror 3,x
	bra align
shiftd:
	inca
	lsrb
	ror @sreg
	ror @sreg+1
	bra align
aligned:
	; We can now free up A because it's also ,X
	tba
	rola
	bcc noneg1
	inc @sreg+1
	ldaa @sreg
	adca #0
	staa @sreg
	adcb #0
	; com alas messes with carry so we have to do the add pass first
	com @sreg+1
	com @sreg
	comb
noneg1:
	ldaa ,x
	rola
	bcc noneg2
	inc 1,x
	ldaa 2,x
	adca #0
	staa 2,x
	ldaa 3,x
	adca #0
	coma
	staa 3,x
	com 1,x
	com 2,x
noneg2:
	rts
