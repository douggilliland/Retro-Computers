	.text
	.globl	_bios
	.globl	_biosinit
	.globl	_cbios
	.globl	_dskia
	.globl	_dskic
	.globl	_setimask
*
*
*
*
_bios:	link	a6,#0
	move.l	d2,-(a7)
	move.l	d1,-(a7)
	move.w	d0,-(a7)
	move	#$2000,sr
	lea	_dskia,a0
	move.l	a0,$3fc
	jsr	_cbios
	unlk	a6
	rts
*
_dskia:	link	a6,#0
	movem.l	d0-d7/a0-a5,-(a7)
	jsr	_dskic
	movem.l	(a7)+,d0-d7/a0-a5
	unlk	a6
	rte
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
	.end
#8,d0
	and.l	#7,d0
	move	sr,d1
	ror.w	#8,d1
	and.w	#$fff8,d1
	add.w	4(a7),d1
	ror.w	#8,d1
	mo