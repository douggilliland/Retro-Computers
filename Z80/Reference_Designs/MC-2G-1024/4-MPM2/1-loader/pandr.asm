;	org FFE0h

blkst:	equ 0E000h	; block start
blklen: equ 02000h	; block length
destad: equ 0100h	; relocate to
execad: equ 0100h	; run from

	ds 6				; make an even 32 bytes long
					; link, unload at FFE0
popandrun	equ $
	out 38h				; kill ROM
	db 0D9h				; exx
	pop psw ! mov b,a		; retrieve boot disk
	pop psw ! xri 1 ! mov c,a	; retrieve active console
	db 0D9h				; exx : save for main program
	lxi d,destad			; destination address in DE
	lxi h,blkst			; block start address in HL
	lxi b,blklen			; block length in BC
	db 0EDh,0B0h			; ldir : move the lot
	jmp execad			; start the loader
	dw popandrun			; tell ROM monitor where to begin

	end
