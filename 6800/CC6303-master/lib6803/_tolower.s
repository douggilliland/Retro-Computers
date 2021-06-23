
		.export _tolower

		.code

_tolower:
		tsx
		clra
		ldab 3,x
		cmpb #'A'
		blt done
		cmpb #'Z'
		bhi done
		addb #$20
done:		rts
