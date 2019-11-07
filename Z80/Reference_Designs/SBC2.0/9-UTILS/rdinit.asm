MMU	equ 030h	; 
MOFF	equ 4		; track offset
BDOS	equ 5
prtstr	equ 9
cpmver	equ 12
	ORG 100h


start:	ld C,cpmver	; get current CP/M version
	call BDOS
	ld A,H		; if H > 0 we're running MP/M 
	or A		; or somesuch
	jr z,cpm	; MP/M running, exit
	ld DE,mpmerr
	ld c,prtstr
	jp BDOS
cpm:	ld A,L		; get version number
	cp 30h
	jr nc,xfer	; CP/M-3
	ld A,0		; CP/M 2 uses non paged memory
	ld (syspage),A

xfer:	ld HL,0100h
	ld DE,08000h
	ld BC,200h
	ldir
	jp cpm3+07F00h
	
cpm3:	ld A,MOFF	; offset, tracks reserved for system memory
	out (MMU),A
	ld HL,0000h	; directory starts here
	ld DE,MDISKIDENT+07F00h
	ld B,32
mtest:	ld A,(DE)
	cp (HL)		; check first directory entry
	jr nz,mtestfail	; quit at the first character to fail
	inc DE		; next characters to compare
	inc HL
	djnz mtest	; repeat 32 times
	ld DE,RDOK +07F00h
	jr mtestend

mtestfail:
	ld DE,0000h
	ld HL,MDISKIDENT+07F00h
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
	ld DE,RDInit+07F00h

mtestend:
	ld a,(syspage+07F00h)
	out (MMU),A
	ld C,prtstr
	jp BDOS


MDISKIDENT:
	db 0,'Ram$Disk',0A0h,'  ',0,0,0,0
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
RDInit:	db 'RamDisk: Initialized',0Dh,0Ah,'$'	
RDOK	db 'RamDisk: Already available',0Dh,0Ah,'$'
mpmerr	db 'MP/M not supported... Aborting',0Dh,0Ah,'$'
syspage db 2		; default to CP/M3
	end

