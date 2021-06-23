;
;	Get the address of a local object
;
		.export leasp
		.export leasp8
		.code

; D (or B) holds the offset from ,S allowing for this call depth and the
; difference between TSX and STS

leasp8:		clra
leasp:		sts @tmp1
		addb @tmp1+1
		adca @tmp1
		rts
