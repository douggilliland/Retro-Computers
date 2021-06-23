;
;	Push indirected via X
;
	.export pshindvx
	.export pshindvx1
	.export pshindvx2
	.export pshindvx3
	.export pshindvx4
	.export pshindvx5
	.export pshindvx6
	.export pshindvx7
	.code

pshindvx:
	ldab $01,x
	ldaa $00,x
pshind:
	tsx
	ldx ,x		; return address
	stx @tmp
	stab $01,x	; swap return address with parameter
	staa $00,x
	jmp jmptmp
pshindvx1:
	ldab $02,x
	ldaa $01,x
	bra pshind
pshindvx2:
	ldab $02,x
	ldaa $01,x
	bra pshind
pshindvx3:
	ldab $03,x
	ldaa $02,x
	bra pshind
pshindvx4:
	ldab $04,x
	ldaa $03,x
	bra pshind
pshindvx5:
	ldab $05,x
	ldaa $04,x
	bra pshind
pshindvx6:
	ldab $06,x
	ldaa $05,x
	bra pshind
pshindvx7:
	ldab $07,x
	ldaa $06,x
	bra pshind
