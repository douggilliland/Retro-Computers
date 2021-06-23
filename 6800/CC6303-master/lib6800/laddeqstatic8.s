		.export laddeqstatic8
		.code

		; Add B to 32bit int pointed to by X
laddeqstatic8:
		addb 3,x
		stab 3,x
		bcc done
		inc 2,x
		bcc done
		inc 1,x
		bcc done
		inc ,x
done:
		rts
