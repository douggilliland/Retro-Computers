;
;		Byte signed += to ,x
;
		.export baddeqstatic
		.export baddeqstatic1
		.export baddeqstatic2
		.export baddeqstatic3
		.export baddeqstatic4

baddeqstatic1:
		ldab #1
baddeqstatic:
		clra
		addb ,x
		stab ,x
		bpl done
		coma
done:		rts

baddeqstatic2:
		ldab #2
		bra baddeqstatic
baddeqstatic3:
		ldab #3
		bra baddeqstatic
baddeqstatic4:
		ldab #4
		bra baddeqstatic

