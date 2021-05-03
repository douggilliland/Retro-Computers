*	@(#)ldbiosa.s	1.3		*
	.text
	.globl	_bios
	.globl	_biosinit
	.globl	_cbios
	.globl	_setimask
	.globl	_cons_out
*
*
*
*
_bios:	link	a6,#0
	move.l	d2,-(a7)
	move.l	d1,-(a7)
	move.w	d0,-(a7)
	jsr	_cbios
	unlk	a6
	rts
*
_setimask: move sr,d0
	lsr	#8,d0
	and.l	#7,d0
	move	sr,d1
	ror.w	#8,d1
	and.w	#$fff8,d1
	add.w	4(a7),d1
	ror.w	#8,d1
	move	d1,sr
	rts	
*

_cons_out:
	move.l	a6,-(sp)
	move.l	a5,-(sp)
	lea.l	13(sp),a5
	lea.l	1(a5),a6
	trap	#15
	.dc.w	6
	move.l	(sp)+,a5
	move.l	(sp)+,a6
	rts
*
	.globl	_rddat
	.globl	_wrdat
*
* wihtout considering wait states movep.l makes
* the faster loop.  however, accounting for wait
* states makes the 68010 loop mode faster.
*
_rddat:	move.l	4(a7),a0
	move.w	#127,d0
	move.l	#$f1c0d9,a1
rdlp:	move.b	(a1),(a0)+
	dbf	d0,rdlp
	rts
*
*
_wrdat	move.l	4(a7),a0
	move.w	#127,d0
	move.l	#$f1c0d9,a1
wrlp:	move.b	(a0)+,(a1)
	dbf	d0,wrlp
	rts
*
	.globl	_no_device
*
_no_device:
	move.l	4(sp),a0
	move.l	8,-(sp)
	move.l	#ndberr,8
	move.b	(a0),d0
	moveq.l	#0,d0
	move.l	(sp)+,8
	rts
ndberr:
	moveq.l	#1,d0
	add.l	#58,sp
	move.l	(sp)+,8
	rts
	.end

	move.b	(a0),d0
	moveq.l	#0,d0
	move.l	(sp)+,8
	rts
ndberr:
	moveq.l	#1,d0
	add.l	#58,sp
	move.l	(sp)+,8
	rts
	.