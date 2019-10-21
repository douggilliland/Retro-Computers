test	equ	6	+	(	not	2	)
test2	equ	not	sin(	90	)	*	2
test3	equ	nul	
test4	equ	nul		
test5 	equ	nul	9
test6	equ	'	'	+	'	'
	db	'l	4	r'
t1	equ	'	'
t2	equ	'\t'
test7	equ	-1=0xffff
test8	equ	-1=0xffffffff
test9	equ	-1=s16(0xffff)
test10	equ	-1=s32(0xffffffff)
	
	if	t1 = t2
	db	4	,	5
	endif
	irpc	x,
	if  not nul x
	endif
	if nul x
	endif
	endm
	irpc	x,1
	if not nul x
	if nul x
	endm
	irpc	x,
	if 6*4 + 3 and not nul x
	endm
	irpc	x,1
	if 6*4 + 3 and not nul x
	endm
	irpc	x,1
	if (not	nul x) and not nul x
	endm
	end