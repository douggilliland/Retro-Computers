false	set 	0
true	set 	not false
test	macro	x
	IF	true
		db  1
x		set 	2
		IF	false
			db 2
		ELSE
			db 3
		ENDIF
		db 4
	ELSE
		db 5
		IF	true
			db 6
		else
			db 4
		ENDIF
		db 7
	ENDIF
	endm

	test	lblSET

	if 	true or false
	db	1
	endif
	if 	true and false
	db 	2
	endif
	if 	5 ge 6
	db	3
	endif
	if 	5 le 6
	db	4
	endif

	dw	FINIS
FINIS:

