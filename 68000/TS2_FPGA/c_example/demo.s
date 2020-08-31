#NO_APP
	.file	"demo.c"
	.text
	.section	.rodata
.LC0:
	.string	"Start\r\n"
.LC1:
	.string	"n  n^2  n^4  n!\r\n"
	.globl	__mulsi3
.LC2:
	.string	"\r\n"
.LC3:
	.string	"Done\r\n"
	.text
	.align	2
	.globl	main
	.type	main, @function
main:
	link.w %fp,#-4
#APP
| 22 "demo.c" 1
	move.l #0x1000,%sp
| 0 "" 2
#NO_APP
	pea .LC0
	jsr printString
	addq.l #4,%sp
	pea .LC1
	jsr printString
	addq.l #4,%sp
	moveq #1,%d0
	move.l %d0,-4(%fp)
	jra .L2
.L3:
	move.l -4(%fp),%d0
	move.l %d0,-(%sp)
	jsr printNumber
	addq.l #4,%sp
	pea 32.w
	jsr outch
	addq.l #4,%sp
	move.l -4(%fp),-(%sp)
	move.l -4(%fp),-(%sp)
	jsr __mulsi3
	addq.l #8,%sp
	move.l %d0,-(%sp)
	jsr printNumber
	addq.l #4,%sp
	pea 32.w
	jsr outch
	addq.l #4,%sp
	move.l -4(%fp),-(%sp)
	move.l -4(%fp),-(%sp)
	jsr __mulsi3
	addq.l #8,%sp
	move.l -4(%fp),-(%sp)
	move.l %d0,-(%sp)
	jsr __mulsi3
	addq.l #8,%sp
	move.l %d0,-(%sp)
	jsr printNumber
	addq.l #4,%sp
	pea 32.w
	jsr outch
	addq.l #4,%sp
	move.l -4(%fp),-(%sp)
	jsr factorial
	addq.l #4,%sp
	move.l %d0,-(%sp)
	jsr printNumber
	addq.l #4,%sp
	pea .LC2
	jsr printString
	addq.l #4,%sp
	addq.l #1,-4(%fp)
.L2:
	moveq #11,%d0
	cmp.l -4(%fp),%d0
	jge .L3
	pea .LC3
	jsr printString
	addq.l #4,%sp
	jsr tutor
	moveq #0,%d0
	unlk %fp
	rts
	.size	main, .-main
	.align	2
	.globl	factorial
	.type	factorial, @function
factorial:
	link.w %fp,#0
	tst.l 8(%fp)
	jgt .L6
	moveq #1,%d0
	jra .L7
.L6:
	move.l 8(%fp),%d0
	subq.l #1,%d0
	move.l %d0,-(%sp)
	jsr factorial
	addq.l #4,%sp
	move.l 8(%fp),-(%sp)
	move.l %d0,-(%sp)
	jsr __mulsi3
	addq.l #8,%sp
.L7:
	unlk %fp
	rts
	.size	factorial, .-factorial
	.align	2
	.globl	tutor
	.type	tutor, @function
tutor:
	link.w %fp,#0
#APP
| 62 "demo.c" 1
	move.b #228,%d7
	trap #14
| 0 "" 2
#NO_APP
	nop
	unlk %fp
	rts
	.size	tutor, .-tutor
	.align	2
	.globl	outch
	.type	outch, @function
outch:
	link.w %fp,#-4
	move.l 8(%fp),%d0
	move.b %d0,%d0
	move.b %d0,-2(%fp)
#APP
| 69 "demo.c" 1
	movem.l %d0/%d1/%a0,-(%sp)
	move.b %d0,%d0
	move.b #248,%d7
	trap #14
	movem.l (%sp)+,%d0/%d1/%a0
| 0 "" 2
#NO_APP
	nop
	unlk %fp
	rts
	.size	outch, .-outch
	.align	2
	.globl	printString
	.type	printString, @function
printString:
	link.w %fp,#0
	jra .L11
.L12:
	move.l 8(%fp),%a0
	move.b (%a0),%d0
	ext.w %d0
	move.w %d0,%a0
	move.l %a0,-(%sp)
	jsr outch
	addq.l #4,%sp
	addq.l #1,8(%fp)
.L11:
	move.l 8(%fp),%a0
	move.b (%a0),%d0
	tst.b %d0
	jne .L12
	nop
	nop
	unlk %fp
	rts
	.size	printString, .-printString
	.globl	__udivsi3
	.align	2
	.globl	printNumber
	.type	printNumber, @function
printNumber:
	link.w %fp,#-12
	clr.w -2(%fp)
	move.l #1000000000,-6(%fp)
	jra .L14
.L17:
	move.l -6(%fp),-(%sp)
	move.l 8(%fp),-(%sp)
	jsr __udivsi3
	addq.l #8,%sp
	move.l %d0,-10(%fp)
	tst.l -10(%fp)
	jne .L15
	tst.w -2(%fp)
	jeq .L16
	move.l -10(%fp),%d0
	add.b #48,%d0
	ext.w %d0
	move.w %d0,%a0
	move.l %a0,-(%sp)
	jsr outch
	addq.l #4,%sp
	jra .L16
.L15:
	move.l -10(%fp),%d0
	add.b #48,%d0
	ext.w %d0
	move.w %d0,%a0
	move.l %a0,-(%sp)
	jsr outch
	addq.l #4,%sp
	move.w #1,-2(%fp)
.L16:
	move.l -6(%fp),-(%sp)
	move.l -10(%fp),-(%sp)
	jsr __mulsi3
	addq.l #8,%sp
	sub.l %d0,8(%fp)
	move.l -6(%fp),%d0
	pea 10.w
	move.l %d0,-(%sp)
	jsr __udivsi3
	addq.l #8,%sp
	move.l %d0,-6(%fp)
.L14:
	moveq #1,%d0
	cmp.l -6(%fp),%d0
	jcs .L17
	move.l 8(%fp),%d0
	add.b #48,%d0
	ext.w %d0
	move.w %d0,%a0
	move.l %a0,-(%sp)
	jsr outch
	addq.l #4,%sp
	nop
	unlk %fp
	rts
	.size	printNumber, .-printNumber
	.ident	"GCC: (GNU) 9.3.1 20200817"
