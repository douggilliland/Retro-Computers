
*	@(#)terma.s	3.1	
*
*	assembly routines for term.c using
*	interrupt driven serial input
*
*	globals
*
	.globl	_serint
	.globl	_setivecs
	.globl	_resvecs
	.globl	_seti
	.globl	_clri
	.globl	_setvmecr
*
*	vectors
*
trp4vec: .equ	$90
trp5vec: .equ	$94
int3vec: .equ	$110
*
*	original vector storage
*
	.data
	.comm	trp4sav,4
	.comm	trp5sav,4
	.comm	int3sav,4
	.text
*
*	initialize vectors
*
_setivecs:
	move.l	trp4vec,trp4sav
	move.l	#newtrp4,trp4vec
	move.l	trp5vec,trp5sav
	move.l	#newtrp5,trp5vec
	move.l	int3vec,int3sav
	move.l	#newint3,int3vec
	rts
*
*	restore vectors
*
_resvecs:
	move.l	trp4sav,trp4vec
	move.l	trp5sav,trp5vec
	move.l	int3sav,int3vec
	rts
*
*	interrupt 3 entry
*
newint3:
	movem.l	a0-a6/d0-d7,-(a7)
	link	a6,#-4
	jsr	_serint
	unlk	a6
	movem.l	(a7)+,a0-a6/d0-d7
	rte
*
*	set interrupt mask
*
_seti:	move.w	#$700,d0
	trap	#4
	rts
*
*	clear interrupt mask
*
_clri:	move.w	#$0,d0
	trap	#4
	rts
*
*	trap #4 handler - change
*	interrupt mask per d0
*
newtrp4:
	move.w	(a7),d1
	and.w	#$f8ff,d1
	or.w	d0,d1
	move.w	d1,(a7)
	rte
*
*	set vme/10 control register
*	must be done in supervisor mode
*
_setvmecr:
	move.w	4(a7),d0	* control reg #
	move.l	#$f19f05,a0	* convert to addr
	asl.w	#1,d0
	add.w	d0,a0
	move.w	6(a7),d0	* contents
	trap	#5		* get to super mode
	rts
*
*	trap 5 handler - write
*	to vem/10 control register
*
newtrp5:
	move.b	d0,(a0)
	rte
*
	.end
 to super mode
	rts
*
*	trap 5 handler - write
*	to 