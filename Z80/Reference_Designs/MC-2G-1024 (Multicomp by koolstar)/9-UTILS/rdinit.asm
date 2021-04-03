MMU_SEL	equ 0F8h	; use 2 bits to select memory quadrant
MMU_FRM	equ 0FDh	; use 6 bits to remap SRAM page
MOFF	equ 8		; track offset
BDOS	equ 5
prtstr	equ 9
cpmver	equ 12
	ORG 100h


; test Ramdisk and format if necessary
START:	ld C,cpmver	; get current CP/M version
	call BDOS
	ld A,H		; if H > 0 we're running MP/M 
	or A		; or somesuch
	jr z,cpm	; MP/M running, exit
	ld DE,mpmerr
	ld c,prtstr
	jp BDOS
cpm:	ld A,L		; get version number
	cp 30h
	jr nc,cpm3	; CP/M-3
	ld A,1		; CP/M 2 uses non paged memory
	ld (syspage),A
cpm3:	ld A,1
	out (MMU_SEL),A
	ld A,MOFF	; offset, tracks reserved for system memory
	out (MMU_FRM),A
	ld HL,4000h	; directory starts here
	ld DE,MDISKIDENT
	ld B,32
mtest:	ld A,(DE)
	cp (HL)		; check first directory entry
	jr nz,mtestfail	; quit at the first character to fail
	inc DE		; next characters to compare
	inc HL
	djnz mtest	; repeat 32 times
	ld DE,RDOK
	jr mtestend

mtestfail:
	ld DE,4000h
	ld HL,MDISKIDENT
	ld BC,32
	ldir		; write first entry
	ex DE,HL	; HL points to next byte
	ld C,127	; 128-1 enties left to write
mformat	ld B,32		; each 32 bytes long
	ld A,0E5h	; 'erased'
mfmt1:	ld (HL),a	; write first character
	inc HL		; next byte
	xor A		; is zero
	djnz mfmt1	; repeat 32 times
	dec c		; write 127 entries
	jr nz,mformat	;
	ld DE,RDInit 

mtestend:
	ld a,1
	out (MMU_SEL),A
	ld A,(syspage)
	out (MMU_FRM),A
	ld C,prtstr
	jp BDOS


MDISKIDENT:
	db 0,'Ram$Disk',0A0h,'  ',0,0,0,0
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
RDInit:	db 'RamDisk: Initialized',0Dh,0Ah,'$'	
RDOK	db 'RamDisk: Already available',0Dh,0Ah,'$'
mpmerr	db 'MP/M not supported... Aborting',0Dh,0Ah,'$'
syspage db 5		; default to CP/M-3
	end

