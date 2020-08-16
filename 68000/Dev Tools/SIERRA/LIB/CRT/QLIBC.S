*	qlibc.s
*
*	Copyright 1991 - 1992 by Sierra Systems.  All rights reserved.
*
*	Useful standard C library routines that should always be linked in for
*	convenience when using QuickFix.

	.lcomm	__heap_base,4,4

	.text
	.align	2
	.def	_sbrk\	.val	_sbrk\	.scl	2\	.type	0x62\	.endef
_sbrk:
	link	a6,#-4
	tst.l	__heap_base
	bne.s	qlibc6
	move.l	#heap_org,d0
	tst.l	d0
	bne.s	qlibc14
	moveq	#16,d0
	bra.s	rtrn1
qlibc14:
	move.l	#heap_org,d2
	move.l	d2,d0
	addq.l	#3,d0
	andi.l	#-4,d0
	sub.l	d2,d0
	add.l	d0,d2
	move.l	d2,__heap_base
qlibc6:
	move.l	__heap_base,d1
	move.l	8(a6),d0
	addq.l	#3,d0
	andi.l	#-4,d0
	add.l	d0,__heap_base
	movea.l	#heap_org,a0
	adda.l	#heap_len,a0
	movea.l	__heap_base,a1
	subq.l	#1,a1
	subq.l	#1,a0
	cmpa.l	a0,a1
	bls.s	qlibc22
	move.l	d1,__heap_base
	moveq	#4,d0
rtrn1:
	jsr 	set_errno			; value to set errno to is in d0
	suba.l	a0,a0
rtrn2:
	unlk	a6
	rts	
qlibc22:
	movea.l	d1,a0
	bra.s	rtrn2
	.def	_sbrk\	.val	.\	.scl	-1\	.endef

	.def	_strcmp\	.val	_strcmp\	.scl	2\	.type	0x24\	.endef
_strcmp:
	link	a6,#-4
	movea.l	8(a6),a0
	movea.l	12(a6),a1
	bra.s	qlibc2
qlibc8:
	cmp.b	(a0)+,d1
	beq.s	qlibc2
	move.b	-(a0),d0
	ext.w	d0
	ext.w	d1
	sub.w	d1,d0
	ext.l	d0
	unlk	a6
	rts	
qlibc2:
	move.b	(a1)+,d1
	bne 	qlibc8
	move.b	(a0),d0
	ext.w	d0
	ext.l	d0
	unlk	a6
	rts	
	.def	_strcmp\	.val	.\	.scl	-1\	.endef

	.def	_strcpy\	.val	_strcpy\	.scl	2\	.type	0x62\	.endef
_strcpy:
	link	a6,#-4
	movea.l	8(a6),a1
	movea.l	12(a6),a0
	move.l	a1,d0
qlibc20:
	move.b	(a0)+,(a1)+
	bne 	qlibc20
	movea.l	d0,a0
	unlk	a6
	rts	
	.def	_strcpy\	.val	.\	.scl	-1\	.endef

	.def	_strncmp\	.val	_strncmp\	.scl	2\	.type	0x24\	.endef
_strncmp:
	link	a6,#-4
	movea.l	8(a6),a1
	movea.l	12(a6),a0
	move.l	16(a6),d1
	bra.s	qlibc30
qlibc48:
	tst.b	(a1)+
	bne.s	qlibc56
	moveq	#0,d0
rtrn3:
	unlk	a6
	rts	
qlibc56:
	addq.l	#1,a0
qlibc30:
	move.l	d1,d0
	subq.l	#1,d1
	tst.l	d0
	ble.s	qlibc40
	move.b	(a1),d0
	cmp.b	(a0),d0
	beq 	qlibc48
qlibc40:
	tst.l	d1
	bmi.s	qlibc64
	move.b	(a1),d0
	ext.w	d0
	move.b	(a0),d2
	ext.w	d2
	sub.w	d2,d0
	move.w	d0,d2
	ext.l	d2
	bra.s	qlibc68
qlibc64:
	moveq	#0,d2
qlibc68:
	move.l	d2,d0
	bra.s	rtrn3
	.def	_strncmp\	.val	.\	.scl	-1\	.endef

	.def	__memset\	.val	__memset\	.scl	2\	.type	0x60\	.endef
__memset:
	link	a6,#-8
	movea.l	8(a6),a1
	move.l	16(a6),d1
	move.l	a1,-4(a6)
	move.l	12(a6),d2
	bra.s	qlibc106
qlibc112:
	move.b	d2,(a1)+
qlibc106:
	move.l	d1,d0
	subq.l	#1,d1
	tst.l	d0
	bne 	qlibc112
	movea.l	-4(a6),a0
	unlk	a6
	rts	
	.def	__memset\	.val	.\	.scl	-1\	.endef

	.def	_memmove\	.val	_memmove\	.scl	2\	.type	0x60\	.endef
_memmove:
	link	a6,#-4
	movea.l	8(a6),a1
	movea.l	12(a6),a0
	move.l	16(a6),d1
	move.l	a1,d2
	cmpa.l	a1,a0
	bls.s	qlibc120
	bra.s	qlibc124
qlibc134:
	move.b	(a0)+,(a1)+
qlibc124:
	move.l	d1,d0
	subq.l	#1,d1
	tst.l	d0
	ble.s	qlibc138
	bra 	qlibc134
qlibc120:
	adda.l	d1,a0
	adda.l	d1,a1
	bra.s	qlibc140
qlibc150:
	move.b	-(a0),-(a1)
qlibc140:
	move.l	d1,d0
	subq.l	#1,d1
	tst.l	d0
	bgt 	qlibc150
qlibc138:
	movea.l	d2,a0
	unlk	a6
	rts	
	.def	_memmove\	.val	.\	.scl	-1\	.endef

	.def	_memcmp\	.val	_memcmp\	.scl	2\	.type	0x24\	.endef
_memcmp:
	link	a6,#-4
	movea.l	8(a6),a0
	movea.l	12(a6),a1
	move.l	16(a6),d1
	bmi.s	qlibc158
qlibc162:
	move.l	d1,d0
	subq.l	#1,d1
	tst.l	d0
	beq.s	qlibc172
	cmpm.b	(a1)+,(a0)+
	beq 	qlibc162
qlibc172:
	move.b	-(a0),d0
	ext.w	d0
	move.b	-(a1),d2
	ext.w	d2
	sub.w	d2,d0
	ext.l	d0
rtrn4:
	unlk	a6
	rts	
qlibc158:
	moveq	#0,d0
	bra.s	rtrn4
	.def	_memcmp\	.val	.\	.scl	-1\	.endef

	.globl	_sbrk
	.globl	_strcmp
	.globl	_strcpy
	.globl	_strncmp
	.globl	__memset
	.globl	_memmove
	.globl	_memcmp

