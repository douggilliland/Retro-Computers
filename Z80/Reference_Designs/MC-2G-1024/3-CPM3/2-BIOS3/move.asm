	title 'bank & move module for CP/M3 linked BIOS'

	cseg

	public ?move,?xmove,?bank,xbuf	; xbuf also used by RAMDISK
	extrn @cbnk

;	maclib z80

mmu$select	equ 0F8h	; use 4 bits to select which one of
				; 4 16k blocks to change
mmu$frame	equ 0FDh	; use 5 bits to remap to one of 32
				; locations in sram


?xmove:		; destination bank in B source bank in C, no return values
	mov a,b ! sta xdst
	mov a,c ! sta xsrc
	mvi a,1 ! sta xflg
	ret

xdst:	ds 1		; stores destination bank
xsrc:	ds 1		; stores source bank
xflg:	db 0		; interbank transfer flag 0=local 1=xmove
xbuf:	ds 128		; common memory databuffer. also used for Ramdisk

?move:		; DE=source, HL=dest. return DE,HL after move 
	lda xflg ! dcr a ! jz movx	; check for ?xmove: go to interbank move
	xchg				; source in DE and dest in HL
	db 0EDh,0B0h			; use Z80 block move instruction
	xchg				; need next addresses in same regs
	ret

movx:	xchg ! xra a ! sta xflg		; swap HL-DE for ldir; reset flag
	lda xsrc ! call ?bank		; use source bank
	push d ! push b			; used for second part
	lxi d,xbuf			; fill local buffer
	db 0EDh,0B0h			; with source data
	lda xdst ! call ?bank		; now use dest bank
	pop b ! pop d ! push h		; get dest and byte count. store new HL
	lxi h,xbuf			; load from local buffer
	db 0EDh,0B0h			; move to dest address
	lda @cbnk ! call ?bank		; switch back to original bank
	pop h ! xchg ! ret		; retrieve HL, swap with DE


	; memory map: |bank0|bank0|bank0|bank0|
	;                0     1     2     3
	;             |bank1|bank1|bank2|bank2|
	;                4     5     6     7
 
?bank:		; 32 k banks
	push b ! push h
	ana a ! jz bank$1 ! inr a	; '1' is common memory
bank$1:	rlc				; times 2 (banksize)
	mvi b,2 ! mvi h,0 ! mov l,a	; init counter and startvalues
next$block:
	mov a,h ! out mmu$select	; replace this block
	mov a,l ! out mmu$frame		; with this one
	inr h ! inr l			; increase pointers
	dcr b ! jnz next$block		; repeat 2 times
	pop h ! pop b
	ret

	end
