
*	@(#)biosa.s	2.3	
	.text
*
*	Global Code addresses
*
	.globl	_init
	.globl	_biosinit
	.globl	_flush
	.globl	_wboot
	.globl	_cbios
	.globl	_setimask
	.globl	_ccp
	.globl	cpm			*	Lowest addr of CP/M 
	.globl	_end			*	Highest addr of CP/M
*
*	Global data addresses
*
	.globl	_memtab			*	memory region table
	.globl	_dpb3			*	RAM disk dpb address
	.globl	_memdsk			*	-> First memory disk location
*
*	Vector Addresses
*
trap3:	.equ	$8c			*	Trap 3 vector
buserr:	.equ	$8			*	Bus error vector
*
*
_init:	lea	entry,a0
	move.l	a0,trap3
*
*	Auto-Size TPA
*
	lea	_memtab,a0		*	a0 -> Memory region table
	move.w	#1,(a0)+		*	1 region
	move.l	#$b00,(a0)+		*	TPA starts at b00
	move.l	#cpm-$b08,(a0)+		*	Ends where CP/M begins
*
*	Auto-Size RAM disk
*
	move.l	buserr,-(sp)		*	Push bus err vector
	lea	_end,a0			*	a0 -> Last location in CP/M
	add.l	#cpm,a0			*	Linker doesn't reloc this!!
	move.l	a0,_memdsk		*	-> first location in RAM disk
	move.l	#quit,buserr		*	set up vector -> ourselves
loop:
	tst.w	(a0)+			*	Find
	bra	loop			*		End of memory
quit:
	add.l	#58,a7			*	Clear buserr gorp
	move.l	(a7)+,buserr		*	Pop buserr vector
	sub.l	#_end,a0		*	a0 = # bytes in RAM disk
	sub.l	#cpm,a0			*	Relocation bug
	move.l	a0,d0			*	Into D reg for shift
	move.l	#11,d1			*	Load shift count
	lsr.l	d1,d0			*	Divide by 2048
	move.w	d0,_dpb3+6		*	Load DRM field of dpb

	move	#$2000,sr
	jsr	_biosinit
	clr.l	d0
	rts
*
_wboot:	clr.l	d0
	jmp	_ccp
*
entry:	move.l	d2,-(a7)
	move.l	d1,-(a7)
	move.w	d0,-(a7)
	jsr	_cbios
	add	#10,a7
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
	.globl	_rddat
	.globl	_wrdat
*
* without considering wait states movep.l makes
* the faster loop.  however, accounting for wait
* states makes the 68010 loop mode faster.
*
_rddat:	move.l	4(sp),a0
	move.w	#127,d0
	move.l	#$f1c0d9,a1
rdlp:	move.b	(a1),(a0)+
	dbf	d0,rdlp
	rts
*
_wrdat:	move.l	4(sp),a0
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
	move.l	buserr,-(sp)
	move.l	#ndber,buserr
	move.b	(a0),d0
	moveq.l	#0,d0
	move.l	(sp)+,buserr
	rts
ndber:
	moveq.l #1,d0
	add.l	#58,sp
	move.l	(sp)+,buserr
	rts
	.end
(a0),d0
	moveq.l	#0,d0
	move.l	(sp)+,buserr
	rts
ndber