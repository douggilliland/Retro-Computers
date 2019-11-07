IDE$DATA	equ	10h
IDE$FEATURES	equ	11h
IDE$ERROR	equ	11h
IDE$SECCOUNT	equ	12h
IDE$SECTOR	equ	13h
IDE$CYL$LOW	equ	14h
IDE$CYL$HI	equ	15h
IDE$HEAD	equ	16h
IDE$STATUS	equ	17h
IDE$COMMAND	equ	17h
IDE$LBA0	equ	13h
IDE$LBA1	equ	14h
IDE$LBA2	equ	15h
IDE$LBA3	equ	16h

;IDE Features
IDE$8BIT	equ	1
IDE$NOCACHE	equ	082h
;IDE Commands
IDE$READ$SEC	equ	020h
IDE$WRITE$SEC	equ	030h
IDE$SET$FEAT	equ 	0EFh

BANK$SEL	equ	030h

RTS$HIGH	equ 0E8h
RTS$LOW		equ 0EAh

SIOA$D		equ 00h
SIOB$D		equ 01h
SIOA$C		equ 02h
SIOB$C		equ 03h

	public mnttab,consol

	org $

	jmp boot
	jmp nooper
	jmp nooper
	jmp nooper
	jmp conout
	jmp nooper
	jmp nooper
	jmp nooper
	jmp home
	jmp seldsk
	jmp settrk
	jmp setsec
	jmp setdma
	jmp read
	jmp nooper
	jmp nooper
	jmp scrtn
	jmp nooper
	jmp nooper
	jmp nooper
	jmp nooper
	jmp nooper
	jmp nooper
	jmp nooper
	jmp nooper
	jmp ?move
	jmp nooper
	jmp nooper
	jmp nooper
	jmp nooper
	jmp 00000h
	jmp 00000h
	jmp 00000h

;	dw ide$write
;	dw ide$read
;	dw ide$login
;	dw ide$init
;	db 0,0			; relative drive zero
rhd0:	dw 0			; XLT
	db 0,0,0,0,0,0,0,0,0	; null
	db 0			; MF
	dw dpbhd8s		; DPP
	dw 0			; CSV
	dw alv0			; ALV
	dw dirbcb0		; DIRBCB
	dw dtabcb0		; DTABCB
	dw 0FFFFh		; HASH
	db 0			; HBANK

alv0:	ds 505

dpbhd8s:
	dw 128		; SPT - sectors per track
	db 5		; BSH - block shift factor
	db 31		; BLM - block mask
	db 1		; EXM - Extent mask
	dw 2043		; 2047-4) DSM - Storage size (blocks - 1)
	dw 511		; DRM - Number of directory entries - 1
	db 11110000b	; AL0 - 1 bit set per directory block
	db 0		; AL1 -            "
	dw 8000h	; CKS - DIR check vector size (DRM+1)/4
	dw 1		; OFF - Reserved tracks
	db 2		; PSH
	db 3		; PSM

dirbcb0:
	db 0ffh		; drv
	ds 3		; rec
	db 0		; wflg
	db 0		; null
	dw 0		; track
	dw 0		; sector
	dw dirbuf0	; buffer address

dirbuf0:
	ds 512

dtabcb0:
	db 0ffh		; drv
	ds 3		; rec
	db 0		; wflg
	db 0		; null
	dw 0		; track
	dw 0		; sector
	dw dtabuf0	; buffer address

dtabuf0:
	ds 512

mnttab:	db -1

consol: db 1

signon:
	db 0Dh,0Ah,'CP/M V3.0 LoaderBIOS',0Dh,0Ah,'For the 11 chip Z80 design, based on the work of Grant Searle',0Dh,0Ah,0

SIOCMD:	db 00h,18h	; reset channel
	db 04h,0C4h	; set clock/64, 1 stopbit
	db 01h,18h	; set interrupt on all Rx characters
	db 03h,0E0h	; set Rx disable, 8 bits data
	db 05h,RTS$LOW	; set Tx enable, 8 bits data, DTR & RTS
	db 02h,0	; set interrupt vector (channel B only)

	; active volume and active SIO were stored in BC'
	; by the popandrun action.
boot:
	di			; Disable interrupts.
	db 0D9h			; exx
	mov a,b ! sta mnttab	; retrieve boot disk
	mov a,c ! sta consol	; retrieve active console
	db 0D9h			; exx : save for main program

;	Initialise SIOs

	lxi h,SIOCMD	; initialize SIO A
	mvi b,10	; SIO A uses the first 5 commands
	mvi c,SIOA$C
	db 0EDh,0B3h	;otir

	lxi h,SIOCMD	; initialize SIO B
	mvi b,12	; SIO B uses all 6 commands
	mvi c,SIOB$C	; including set interrupt vector
	db 0EDh,0B3h	;otir


	; Initialize IDE interface
	call ide$Wait
	mvi a,IDE$8BIT ! out IDE$FEATURES
	mvi a,IDE$SET$FEAT ! out IDE$COMMAND

	call ide$Wait
	mvi a,IDE$NOCACHE ! out IDE$FEATURES
	mvi a,IDE$SET$FEAT ! out IDE$COMMAND

	lxi h,signon ! call print
	ret

nooper:
	ret

conout:	
	push psw	
	lda consol
	ani 03h		; mask console
	cpi 01h		; 01 - CRT:
	jnz conoutB1	; 00, 11 - TTY: UC1:

conoutA1:
	xra A
	out SIOA$C
	in SIOA$C	; Status byte D2=TX Buff Empty, D0=RX char ready
	rrc 		; Rotates RX status into Carry Flag,
	db 0CBh,04Fh	; bit 1,A
	jz conoutA1	; Loop until SIO flag signals ready
	mov a,c
	out SIOA$D	; Output the character
	pop psw
	ret
 
conoutB1:
	xra A
	out SIOB$C
	in SIOB$C	; Status byte D2=TX Buff Empty, D0=RX char ready
	rrc 		; Rotates RX status into Carry Flag,
	db 0CBh,04Fh	; bit 1,A
	jz conoutB1	; Loop until SIO flag signals ready
	mov a,c
	out SIOB$D	; Output the character
	pop psw
	ret


adrv:	ds 1		; currently selected disk drive
;rdrv:	ds 1		; controller relative disk drive
trk:	ds 2		; current track number
sect:	ds 2		; current sector number
dma:	ds 2		; current DMA address
;cnt:	db 0		; record count for multisector transfer
;dbnk:	db 0		; bank for DMA operations

home:	lxi b,00000h

settrk:	mov l,c ! mov h,b ! shld trk ! ret

seldsk:	lxi h,rhd0 ! mvi a,0 ! sta adrv ! ret

setsec:	mov l,c ! mov h,b ! shld sect ! ret

scrtn:	mov h,b ! mov l,c ! ret

setdma:	mov l,c ! mov h,b ! shld dma ! ret


read:
	push b ! push d ! push h
	call ide$wait ! call set$lba
	mvi a,1 ! out IDE$SECCOUNT
	call ide$wait ! mvi a,IDE$READ$SEC ! out IDE$COMMAND
	lhld dma ! mvi c,IDE$DATA ! mvi b,0
	call ide$wait
	db 0EDh,0B2h	; inir
	db 0EDh,0B2h	; inir
	pop h ! pop d ! pop b
	xra a ! ret

ide$Wait:
	in IDE$STATUS
	rlc ! jc ide$Wait
	ret


set$lba:
	lhld trk ! mov a,l
	rrc ! rrc ! rrc ! mov l,a
	ani 0E0h ! mov b,a
	lda sect ! add b ! out IDE$LBA0

	mov a,l ! ani 01Fh ! mov l,a
	mov a,h ! rrc ! rrc ! rrc
	add l ! mov b,a
	lda mnttab ! rrc ! rrc ! mov c,a
	ani 0C0h ! add b ! out IDE$LBA1

	mov a,c ! ani 03Fh ! out IDE$LBA2

	mvi a,0E0h ! out IDE$LBA3

	ret


print:
	mov a,m					; get character
	ora a ! rz				; quit if zero
	mov c,a ! call conout			; output character
	inx h ! jmp print			; go for more


?move:
	xchg
	db 0EDh,0B0h	;ldir
	xchg
	ret

	end

