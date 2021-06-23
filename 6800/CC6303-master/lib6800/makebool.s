;
;	These are based ont the CC65 runtime. 6803 is much the same
;	as 6502 here except we've got ldd to load two bytes (and the
;	optimizer will turn it into a 2 byte load of 'one' in the direct page)
;

	.code

	.export booleq
	.export boolne
	.export boolle
	.export boollt
	.export boolge
	.export boolgt
	.export boolule
	.export boolult
	.export booluge
	.export boolugt

;
;	Turn  val op test into 1 for true 0 for false. Ensure the Z flag
;	is appropriately set
;

booleq:
	bne	ret0
ret1:
	clra
	ldab	#1
	rts
boolne:
	bne	ret1
ret0:
	clra
	clrb
	rts

boolle:
	beq	ret1
boollt:
	blt	ret1
	clra
	clrb
	rts

boolge:
	beq	ret1
boolgt:	bgt	ret1
	clra
	clrb
	rts

booluge:
	beq	ret1
boolugt:
	bcc	ret1
	clra
	clrb
	rts

boolule:
	beq	ret1
boolult:			; use C flag
	ldab	#0		; clrb clears the flag
	rolb
	clra
	rts
