	org $
	ds 14

blkst:	equ 0E000h	; block start
blklen: equ 02000h	; block length
destad: equ 0100h	; relocate to
execad: equ 0100h	; run from

popandrun	equ $
	out 38h				; kill ROM
	lxi d,destad			; destination address in DE
	lxi h,blkst			; block start address in HL
	lxi b,blklen			; block length in BC
	db 0EDh,0B0h			; ldir : move the lot
	jmp execad			; start the loader
	dw popandrun			; tell ROM monitor where to begin

	end
