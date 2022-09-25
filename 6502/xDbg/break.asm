;=====================================================
; break.asm
;
; This file has all the logic associated with
; breakpoints.
;
; 09/20/2021
;
; Max number of active breakpoints...
;
USER_BREAKPTS	equ	5
;
; 6502 BRK instruction
;
BRK		equ	$00
;
; Flags used for breakpoint status
;
FREE		equ	0
NOT_FREE	equ	~0
NONE		equ	~0
;
;=====================================================
; This needs to be called once to initialize the
; breakpoint system.
;
BreakInit	jsr	ClearBreakpoint
		lda	#0
		sta	BreakptEnable	;disabled by default
		rts
;
;=====================================================
; Command handler.  cmdOffset points to letter after
; B.
; B = Lists breakpoints
; BD = Disable breakpoints
; BE = Enable breakpoints
; BC [<addr>] = with addr, clears just one breakpoint.
;             Else clears all.
; BS <addr> = Sets breakpoint at addr.
;
Breakpoints	ldx	cmdOffset
		lda	buffer,x
		beq	breakshow	;display?
		cmp	#'D'		;disable?
		beq	breakdisable
		cmp	#'E'		;enable?
		beq	breakenable
		cmp	#'C'		;clear?
		beq	breakclear
		cmp	#'S'		;set?
		beq	breaksetV
;
; Unknown option for the B command.
;
		jsr	putsil
		db	"Huh?",CR,LF,0
		jmp	MainLoop
;
breaksetV	jmp	breakset

;
;-----------------------------------------------------
; Handlers for specific subcommands
;
; Enable or disable breakpoints
;
breakdisable	lda	#$0
		beq	breakenab1
breakenable	lda	#$ff
breakenab1	sta	BreakptEnable
		jmp	MainLoop
;
;-----------------------------------------------------
; Clear breakpoints
;
breakclear	jsr	SkipSpaces2
		ldx	cmdOffset
		lda	buffer,x
		bne	breakclraddr	;clear specific one
		jsr	ClearBreakpoint	;else clear all
		jmp	MainLoop
;
;-----------------------------------------------------
; List all breakpoints, even if disabled.
;
breakshow	jsr	putsil
		db	"Breakpoints: ",0
		ldy	#0		;offset into table
breakshow2	lda	breakpoints,y
		beq	breakskip	;not in use
		lda	breakpoints+2,y	;MSB of address
		sty	storeY
		jsr	xkPRTBYT
		ldy	storeY		;get back index
		lda	breakpoints+1,y	;LSB of address
		jsr	xkPRTBYT
		lda	#' '
		jsr	xkOUTCH
		ldy	storeY
;
; Skip to the next entry
;
breakskip	iny
		iny
		iny
		iny
;
; At end of table?
;
		cpy	#breakptend-breakpoints
		bne	breakshow2
;
; Display whether breakpoints are enabled or not.
;
		jsr	putsil
		db	CR,LF
		db	"Breakpoints are ",0
		lda	BreakptEnable
		bne	breakcmd1
		jsr	putsil
		db	"disabled",CR,LF,0
		jmp	MainLoop
breakcmd1	jsr	putsil
		db	"enabled",CR,LF,0
		jmp	MainLoop
;
;-----------------------------------------------------
; Remove the breakpoint at a specific address
;
breakclraddr	jsr	ChkParam
		jsr	GetHex		;get address to clear
;
; Search table for entry, set in-use flag to 0.
;
		jsr	breakfind	;find it
		bcc	breakclr2	;not found, no problemo
;
		lda	#0
		sta	breakpoints,y	;turn off
breakclr2	jmp	MainLoop
;
;-----------------------------------------------------
; Set a breakpoint
;
breakset	jsr	SkipSpaces2
		jsr	ChkParam
		jsr	GetHex
;
; Search table to see if it exists already, or find
; first free entry to use.
;
		jsr	breakfind
		cpy	#$ff		;no free entry?
		bne	breakset2
		jsr	putsil
		db	"No free breakpoints",CR,LF,0
		jmp	MainLoop
;
breakset2	lda	#$ff
		sta	breakpoints,y	;mark in-use
		lda	Temp16		;LSB of address
		sta	breakpoints+1,y
		lda	Temp16+1	;MSB
		sta	breakpoints+2,y
		lda	#$ff
		sta	BreakptEnable
		jmp	MainLoop
;
;=====================================================
; Given a breakpoint address in Temp16, find the entry
; in breakpoints.  If found, returns C set and Y has
; the offset to the start of the entry.  Else, return
; with C clear.  If Y is FF then there is no free entry,
; else Y points to first free entry.  Uses storeY to
; keep track of first free entry.
;
breakfind	ldy	#NONE
		sty	storeY		;no free entry found
		iny			;offset into table
breakfind2	lda	breakpoints,y
		beq	breakfind3	;not in use
		lda	breakpoints+1,y	;LSB
		cmp	Temp16
		bne	breakfind4
		lda	breakpoints+2,y	;MSB
		cmp	Temp16+1
		bne	breakfind4
		sec
		rts			;Found!
;
; Branch here if this is a free entry.  See if this is the
; first free entry found, and if so, save the index.
;
breakfind3	lda	storeY		;first free
		cmp	#NONE		;no free entry?
		bne	breakfind4	;branch if have one
		sty	storeY		;else save this entry
;
breakfind4	iny
		iny
		iny
		iny
;
; At end of table?
;
		cpy	#breakptend-breakpoints
		bne	breakfind2	;branch if not end
		ldy	storeY		;get free entry
		sec
		rts
;
;=====================================================
; A handy subroutine that can be called to clear all
; breakpoints.  Modifies A and X.
;
ClearBreakpoint	ldx	#breakptend-breakpoints-1
		lda	#0
breakclear2	sta	breakpoints,x
		dex
		bpl	breakclear2
		lda	#0		;disable breakpoints
		sta	BreakptEnable
		rts
;
;=====================================================
; This installs BRK instructions at all breakpoints if
; breakpoints are currently enabled.
;
BreakInstall	lda	BreakptEnable	;only if breakpts enabled
		beq	breakinst1
		ldx	#0
		ldy	#0
breakinst1	lda	breakpoints,x
		beq	breakinst3
		lda	breakpoints+1,x	;LSB
		sta	POINTL
		lda	breakpoints+2,x	;MSB
		sta	POINTH
		lda	(POINTL),y	;get instruction
		sta	breakpoints+3,x
		lda	#BRK
		sta	(POINTL),y	;install BRK
;
; Move to next entry
;
breakinst2	inx
		inx
		inx
		inx
		cpx	#breakptend-breakpoints
		bne	breakinst1
breakinst3	rts
;
;=====================================================
; This puts back all the original instructions from
; the breakpoint table.
;
BreakRemove	lda	BreakptEnable	;only if breakpts enabled
		beq	breakinst3
		ldx	#0
		ldy	#0
breakrem1	lda	breakpoints,x
		beq	breakrem2
		lda	breakpoints+1,x	;LSB
		sta	POINTL
		lda	breakpoints+2,x	;MSB
		sta	POINTH
		lda	breakpoints+3,x	;get instruction
		sta	(POINTL),y	;put it back
;
; Move to next entry
;
breakrem2	inx
		inx
		inx
		inx
		cpx	#breakptend-breakpoints
		bne	breakrem1
		rts	
		rts
;
;=====================================================
; The actual breakpoints.  Each entry has these fields:
;
;    * In use - non-zero if active
;    * Address
;    * Original instruction at that address
;
breakpoints	ds	4*USER_BREAKPTS
breakptend	equ	*
;
; Set if breakpoints are enabled.
;
BreakptEnable	ds	1

