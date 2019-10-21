	maclib	makedate
	maclib	compare
	maclib	z80
	
	predef	z80regs
	
	@LCOPY
	@BDATE

true	equ	0xffff
false	equ	not true
	
m	set	44
n	equ	55

x	set	nul()
x	set	nul(notnul)

testp	irp	x,<,9;comment>,<,8;comment2>
	db	3&x
	endm

	IF1
nine	SET	99
	endif

	ifdef	undefined
	db	undefined
	else
	db	5
	endif

	ifndef	undefined
	db	6
	else
	db	undefined
	endif

testL	db	m,n
	ldx	a,-2		;maclib
	mov	a,-2(ix)
	lxix	1234h		;maclib
	lxi	ix,1234h
	ADDX	+4		;maclib
	add	4(ix)
	sta	testL
	jmp 	testL
	jmp 	finis
	jmp 	get

	leq	m,n,finis
	eql	m,n,finis
	geq	m,n,finis

; MAC manual calls this next one a special case
	irpc	testzero,
	if 	nul testzero
	db	5
	else	
	db	testzero
	endif
	endm
; I think its a bug; but i implemented it anyway
ddb	macro	data,comment
;;	define a db statement
	db	data		comment
	endm
;
ddw	macro	data,comment
;;	define a dw statement
	dw	data		comment
	endm

	ddw	33,<;sec per track>
	ddb	44,<;block shift>

	irp	val,"xy&z",%(m - 9)*2,"mn^&o",(m - 9)*2
	db	val,val
	endm

	irp	val,m,n
	db	val+40,(val- val ) * val,"val&x"
	endm
	
	irpc	reg,abdh
	push	reg
	db	"&reg&reg &reg reg& &reg^&reg& regul^&ar"
	endm

mac2	macro	d,f
	db	d,f	;db stuff for first mac2
mac2	macro	x,y	;;redefine mac2
	local	lbl1,lbl2	
lbl1	db	x,y	;db stuff for second mac2
	endm		;;end of redefinition of mac2
lbl2	mac2	m,n
	endm		

lfmac2	mac2	3,%m
	mac2	m,6
	db 4


mac1	rept	2
	if 6=5
	db	6
test1	exitm
	else
	db	12
test1	exitm
	endif
..mac3	endm


mac5	rept	2	;outer rept
	local 	mac4,mac8 ;;locals for rept
	db	6
mac4	rept	2	;inner rept
	db	4
	endm
mac8	endm

	irp	?LAB,INIT,GET,PUT,FINIS
	jmp	?LAB
	endm

INIT:

	IF	true
		db  1
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
		ENDIF
		db 7
	ENDIF

GET:
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
PUT:
	dw	FINIS
FINIS:	jmp get
	end	finis