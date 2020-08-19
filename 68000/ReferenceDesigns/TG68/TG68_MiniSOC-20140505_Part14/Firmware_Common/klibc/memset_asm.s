	xdef	memset
memset:
	move.l	4(a7),a0	; ptr
	move.l	8(a7),d0	; fill
	move.l	12(a7),d1	; size
	move.w	d0,$810006	; HEX display
	move.l	d1,a1
	lsr.l	#2,d1		; Divide by 4.
	beq	.endlong	; If less than four bytes, skip longwords.
	cnop	0,8		; Align to make loop faster
.loop
	move.l	d0,(a0)+	; Copy longword
	subq.l	#1,d1
	bne	.loop
.endlong
	move.l	a1,d1	; Restore size
	and.l	#3,d1
	beq	.end
	subq.w	#1,d1	; Reduce by 1 for dbf loop
.byteloop
	rol.l	#8,d0
	move.b	d0,(a0)+
	dbf	d0,.byteloop
.end
	rts
