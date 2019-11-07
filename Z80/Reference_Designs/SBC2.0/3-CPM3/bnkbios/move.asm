	title 'bank & move module for CP/M3 linked BIOS'

	cseg

	public ?move,?xmove,?bank,xbuf
	extrn @cbnk

;	maclib z80

bank$select	equ 030h	; bank select address


?xmove:		; destination bank in B source bank in C, no return values
	mov a,b ! sta xdst
	mov a,c ! sta xsrc
	mvi a,1 ! sta xflg
	ret

xdst:	ds 1		; stores destination bank
xsrc:	ds 1		; stores source bank
xflg:	db 0		; interbank transfer flag 0=local 1=xmove
xbuf:	ds 128		; common memory databuffer

?move:		; DE=source, HL=dest. return DE,HL after move 
	lda xflg ! dcr a ! jz movx	; check for ?xmove: go to interbank move
	xchg				; source in DE and dest in HL
	db 0EDh,0B0h			; use Z80 block move instruction
	xchg				; need next addresses in same regs
	ret


movx:	; according to documentation the data is not more than 128 bytes
	xchg ! xra a ! sta xflg		; swap HL-DE for ldir; reset flag
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

?bank:		; 32 k banks
	ana a ! jz bank$1 ! inr a	; '1' is common memory
bank$1:	out bank$select			; a is bank number
	ret

	end
