		.export laddeqstatic16
		.code

		; Add D to 32bit int pointed to by X
laddeqstatic16:
		addb 3,x
		stab 3,x
		adca 2,x
		staa 2,x
		bcc done
		inc 1,x
		bcc done
		inc ,x
done:
		rts
