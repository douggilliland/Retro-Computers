
		.export addeqstatic
		.export addeqstaticb
		.export addeqstatic1
		.export addeqstatic2
		.export addeqstatic3
		.export addeqstatic4


;
;	X points to the buffer, AB holds the offset (or 1-4 are the value)
;

addeqstatic1:	ldab #1
addeqstaticb:	clra
addeqstatic:	addb 1,x
		adca ,x
		stab 1,x
		staa ,x
		rts
addeqstatic2:	ldab #2
		bra addeqstaticb
addeqstatic3:	ldab #2
		bra addeqstaticb
addeqstatic4:	ldab #2
		bra addeqstaticb
