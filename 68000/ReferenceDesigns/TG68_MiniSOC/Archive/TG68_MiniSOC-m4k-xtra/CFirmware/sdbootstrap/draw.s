	XREF FrameBuffer

FB_WIDTH equ 640
FB_HEIGHT equ 960
RANDOMSEED	dc.w	12345
RANDOMSEED2	dc.w	6789
pen	dc.w	0

	XDEF pen
	XDEF DrawIteration
DrawIteration
	movem.l	a2-6/d2-d7,-(a7)
	add.w	#1,pen
	bsr	Random
	move.l	d0,d3
	bsr	Random
	move.l	d0,d2
	bsr	Random
	move.l	d0,d1
	bsr	Random

	divu	#FB_WIDTH-1,d0
	clr.w	d0
	swap	d0

	divu	#FB_HEIGHT-1,d1
	clr.w	d1
	swap	d1
	
	move.l	#FB_WIDTH-1,d4
	sub.l	d0,d4
	divu	d4,d2
	clr.w	d2
	swap	d2
	
	move.l	#FB_HEIGHT-1,d4
	sub.l	d1,d4
	divu	d4,d3
	clr.w	d3
	swap	d3
	
	addq	#1,d2
	addq	#1,d3
	move.l	FrameBuffer,a0
	bsr	DrawRectangle
	movem.l	(a7)+,a2-a6/d2-d7
	rts



Plot				; X: d0, y: d1
	movem.l	a0/d0-d1,-(a7)
	move.l	FrameBuffer,a0
	mulu	#FB_WIDTH*2,d1
	asl.l	#1,d0
	add.l	d1,d0
	add.l	d0,a0
	move.w	pen,(a0)
	movem.l	(a7)+,a0/d0-d1
	rts


Random
	movem.l	d1-d2,-(a7)
	move.l	#16807,d0
        move.l  d0,d2
        mulu    RANDOMSEED+2,d0

        move.l  d0,d1
        sub.w	d1,d1
        swap    d1
        mulu    RANDOMSEED,d2
        add.l   d1,d2

        move.l 	d2,d1
        add.l	d1,d1
        clr.w	d1
        swap    d1

        and.l   #$0000FFFF,d0
        and.l   #$7FFFFFFF,d0
        and.l   #$00007FFF,d2
        swap    D2
        add.l   D1,D2
        add.l   D2,D0

        bpl	.upd
        add.l   #$7FFFFFFF,d0
.upd	move.l  d0,RANDOMSEED
	swap	d0
	move.w	#0,d0
	swap	d0
	movem.l	(a7)+,d1-d2
        rts
        

DrawRectangle	; d0: x, d1: y, d2: w, d3: h, a0: framebuffer
;	move.w	RANDOMSEED+2,$810006 ; HEX display
	movem.l	d1-d6,-(a7)
	add.l	d1,d1
	mulu	#FB_WIDTH,d1	; y offset
	add.l	d1,a0
	add.l	d0,d0
	add.l	d0,a0		; x offset
	move.l	#FB_WIDTH,d0
	sub.l	d2,d0		; modulo
	add.l	d0,d0
	
	move.w	pen,d4
	lsr.l	#1,d4
	and.l	#%0111101111101111,d4	; Remove MSBs
	move.w	d4,d1
	swap	d4
	move.w	d1,d4	; duplicate words
.yloop
	move.l	d2,d1
	and.w	#3,d1
	beq	.even
.wordxloop
	move.w	(a0),d5
	add.l	#$00a000a0,d5
;	lsr.l	#1,d5
;	and.l	#%0111101111101111,d5	; Remove MSBs
;	add.w	d4,d5	
	move.w	d5,(a0)+
	subq.w	#1,d1
	bne	.wordxloop	
.even
	move.l	d2,d1
	lsr.w	#2,d1
	beq	.nolongs
.longxloop
	move.l	(a0),d5
	move.l	4(a0),d6
	add.l	#$00a000a0,d5
	add.l	#$00a000a0,d6
;	lsr.l	#1,d5
;	and.l	#$7bef7bef,d5	; Remove MSBs
;	lsr.l	#1,d6
;	and.l	#$7bef7bef,d6	; Remove MSBs
;	add.l	d4,d5	
;	add.l	d4,d6	
	move.l	d5,(a0)+
	move.l	d6,(a0)+
	subq.w	#1,d1
	bne	.longxloop

.nolongs
	add.l	d0,a0		; Add modulo

	subq.w	#1,d3
	bne	.yloop

	movem.l	(a7)+,d1-d6
	rts


FillScreen
	movem.l	a0-a4/d1-d4,-(a7)
	move.l	FrameBuffer,a0
	move.l	#FB_HEIGHT,d0
	mulu	#FB_WIDTH,d0
	add.l	d0,a0
	add.l	d0,a0		; Point to end of buffer
	lsr.l	#4,d0		; We're moving 16 bytes at a time
	move.w	pen,d1
	swap	d1
	move.w	pen,d1
	move.l	d1,d2
	move.l	d1,d3
	move.l	d1,d4
	move.l	d1,a1
	move.l	d1,a2
	move.l	d1,a3
	move.l	d1,a4
.fillloop
	movem.l	a1-a4/d1-d4,-(a0)
	sub.l	#1,d0
	bne	.fillloop
	movem.l	(a7)+,a0-a4/d1-d4
	rts

