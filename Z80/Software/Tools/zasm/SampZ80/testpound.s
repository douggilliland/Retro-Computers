ds	equ	5
nop1	equ	-50
nop2	equ	-8
div1	equ	30/6
div2	equ	5/9
div3	equ	&hff04/16
o1	equ	&hff04
div4	equ	o1/16
div5	equ	nop1/16
div6	equ	nop1/nop2
mod1	equ	30%6
mod2	equ	50%9
mod3	equ	&hff00%16
mod4	equ	o1%16
mod5	equ	57%4
mod6	equ	&hff04%16
mod7	equ	nop1%16
mod8	equ	nop1%nop2
xor1	equ	0$1111b xor 0$1010b
and1	equ	0$1111b&0$0100b
or1	equ	0$1010b|1$0101b
false	equ	0
true	equ	1
;whole line comment
	ift	1
ttt	equ	1234	;test
;whole line comment
t111	equ	456
	else
ttt	equ	4321	;test
;whole line comment
t111	equ	654
	endif

	ift	0
tttx	equ	1234	;test
;whole line comment
t111x	equ	456
	else
tttx	equ	4321	;test
;whole line comment
t111x	equ	654
	endif
	
;	org	testvalq

	iff	false
tttv	equ	1234	;test
;whole line comment
t111v	equ	456
	else
tttv	equ	4321	;test
;whole line comment
t111v	equ	654
	endif

testval	equ	0
	ifz	testval
xyz	equ	4
	endif

	ifnz	testval
xyz	equ	999
	endif

	ifgt	5
	mov	01010101b(ix),a
	endif

	iflt	5
	mov	01010101b(ix),a
	endif

	ifle	4-5
	mov	01010101b(ix),b
	endif

	ifge	4-5
	mov	01010101b(ix),c
	endif

	if	0
	mov	01010101b(ix),d
	endif


size	equ	24
td	equ	size/10
od	equ	size%10
tda	equ	td+&h30
oda	equ	od+&h30

	org 	1000

	lxi	b,#ds
	lxi	h,#hj
	sded	&H9000
..x	equ	10
	lxi	b,..x
..x	equ	&Hff
	lxi	b,..x
..x     lxi	b,..x
	jmp	..y
	nop	
	jmp	..x
..x     lxi	b,..x
	nop
	nop	
..y	jmp	..x
..x     lxi	b,..x
	jmp	..y
	nop	
label	srlr	..x(ix)
	jmp	..x
..x     lxi	b,..x
	nop
	nop	
..y	jmp	..x