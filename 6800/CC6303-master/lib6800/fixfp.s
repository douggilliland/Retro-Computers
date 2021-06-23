;
;	Generate a frame pointer offset into X
;
		.export fixfp
		.export restorefp
		.code

fixfp:
		; On entry B holds the offset and the caller made a hole
		; for fp on the stack
		tsx
		ldaa @fp
		staa 2,x
		ldaa @fp+1
		staa 3,x
		clra
		addb @fp+1
		adca #0
		stab @fp+1
		staa @fp
		rts

		; jumped to from the end of 6800 vararg functions
restorefp:
		tsx
		ldx ,x
		inx
		inx
		stx @fp
		rts
