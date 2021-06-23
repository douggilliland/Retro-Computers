	.export loadtos
	.export savetos
	.export addtotos
	.export addtotosb

	.code

loadtos:
	tsx
	ldab $03,x
	ldaa $02,x
	rts

savetos:
	tsx
	stab $03,x
	stab $02,x
	rts

addtotosb:
	clra
addtotos:
	tsx
	addb $03,x
	adca $02,x
	stab $03,x
	staa $02,x
	rts
