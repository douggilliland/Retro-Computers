;**********************************************************
;*
;*	DOLO-1 HOMEBREW COMPUTER
;*	Hardware and software design by Dolo Miah
;*	Copyright 2014-18
;*  Free to use for any non-commercial purpose subject to
;*  full credit of original my authorship please!
;*
;*  INCLUDES.S
;*  Main include file for key definitions and macros.
;*  Many of the settings here are exremely machine dependent.
;*  Defines : IO block addresses, VIA port usage, SD card
;*  settings, useful macros, sound chip registers, VIA registers
;*  VDP registers, ACIA registers.
;*
;**********************************************************

;* The IO block is at 0xb000 and decodes up to
;* eight IO addresses, at 0x0200 intervals
;* All eight are not used at the present time:
;* - 0 : VIA 1 (Keyboard)
;* - 1 : VIA 2 (Sound and SD card interface)
;* - 2 : VDP (Video)
;* - 3 : ACIA (Serial)
IO_0		= 0xb000
IO_1		= 0xb200
IO_2		= 0xb400
IO_3		= 0xb600
IO_4		= 0xb800
IO_5		= 0xba00
IO_6		= 0xbc00
IO_7		= 0xbe00

;* VDP is accessed through IO_2
VDP_MODE0	= IO_2
VDP_MODE1	= IO_2+1
VDP_STATUS	= IO_2+1
VDP_ADDR	= IO_2+1
VDP_VRAM	= IO_2

;* This structure defines the key information
;* kepts about the VDP current mode
	struct vdp_addr_struct
	dw vdp_addr_nme				;* Address of name table
	dw vdp_addr_col				;* Address of colour table
	dw vdp_addr_pat				;* Address of pattern table
	dw vdp_addr_spa				;* Address of sprite pattern table
	dw vdp_addr_spp				;* Address of sprite position table
	db vdp_bord_col				;* Value of border colour
	end struct

;* Standard definitions of 6522 registers
;* As found in the datasheets
PRB			= 0x00
PRA			= 0x01
DDRB		= 0x02
DDRA		= 0x03
T1CL		= 0x04
T1CH		= 0x05
T1LL		= 0x06
T1LH		= 0x07
T2CL		= 0x08
T2CH		= 0x09
SR			= 0x0a
ACR			= 0x0b
PCR			= 0x0c
IFR			= 0x0d
IER			= 0x0e
PRAH		= 0x0f

IFR_CA2		= 0x01
IFR_CA1		= 0x02

;* AY-3-8910 definitions
;* The sound chip is accessed through VIA 2
SND_ADBUS	= IO_1+PRA
SND_MODE	= IO_1+PRB

SND_SELREAD			= 0x40
SND_SELWRITE		= 0x02
SND_SELSETADDR		= (SND_SELREAD|SND_SELWRITE)
SND_DESELECT_MASK	= (0xff-SND_SELREAD-SND_SELWRITE)

SND_REG_CHAPL	= 0x00
SND_REG_CHAPH	= 0x01
SND_REG_CHBPL	= 0x02
SND_REG_CHBPH	= 0x03
SND_REG_CHCPL	= 0x04
SND_REG_CHCPH	= 0x05
SND_REG_CHNP	= 0x06
SND_REG_CTL		= 0x07
SND_REG_CHAVOL	= 0x08
SND_REG_CHBVOL	= 0x09
SND_REG_CHBVOL	= 0x0a
SND_REG_ENVPL	= 0x0b
SND_REG_ENVPH	= 0x0c
SND_REG_ENVCYC	= 0x0d

SND_REG_IOA	= 0x0e
SND_REG_IOB	= 0x0f

;* 6551 ACIA definitions
;* As found in the datasheets
SER_DATA	= (IO_3+0)
SER_STATUS	= (IO_3+1)
SER_RESET	= (IO_3+1)
SER_CMD		= (IO_3+2)
SER_CTL		= (IO_3+3)

SER_IRQ		= 0x80
SER_DSRB	= 0x40
SER_DCDB	= 0x20
SER_TDRE	= 0x10
SER_RDRF	= 0x08
SER_OVRN	= 0x04
SER_FE		= 0x02
SER_PE		= 0x01
SER_SBN		= 0x80
SER_WL1		= 0x40
SER_WL0		= 0x20
SER_WL		= (SER_WL1|SER_WL0)
SER_RCS		= 0x10
SER_SBR3	= 0x08
SER_SBR2	= 0x04
SER_SBR1	= 0x02
SER_SBR0	= 0x01
SER_SBR		= (SER_SBR3|SER_SBR2|SER_SBR1|SER_SBR0)
SER_19200B	= (SER_SBR3|SER_SBR2|SER_SBR1|SER_SBR0)
SER_9600B	= (SER_SBR3|SER_SBR2|SER_SBR1)
SER_PMC1	= 0x80
SER_PMC0	= 0x40
SER_PMC		= (SER_PMC1|SER_PMC0)
SER_PME		= 0x20
SER_REM		= 0x10
SER_TIC1	= 0x08
SER_TIC0	= 0x04
SER_TIC		= (SER_TIC1|SER_TIC0)
SER_IRD		= 0x02
SER_DTR		= 0x01

;* BBC keyboard definitions
;* The keyboard is accessed through VIA 1
KB_EN		= 0x80
KB_ROWA		= 0x01
KB_ROWB		= 0x02
KB_ROWC		= 0x04
KB_COLA		= 0x08
KB_COLB		= 0x10
KB_COLC		= 0x20
KB_COLD		= 0x40
KB_W		= 0x01
KB_LED0		= 0x02
KB_LED1		= 0x04
KB_LED2		= 0x08
KB_CAPSLK	= 0x01
KB_SHIFTLK	= 0x02

KB_REP_TIM	= 5				; Number of VB periods for the repeat speed
KB_REP_DEL	= 30			; Number of VB periods before repeat activates
KB_DEBOUNCE	=  3			; Number of VB periods before debounce

UTF_ETX		= 0x03			; Break character
UTF_BEL		= 0x07
CRSR_LEFT	= 0x08
CRSR_RIGHT	= 0x09
CRSR_DOWN	= 0x0a
CRSR_UP		= 0x0b
UTF_ACK		= 0x06			; Used for the copy key in this implementation
UTF_FF		= 0x0c
UTF_CR		= 0x0d
UTF_DEL		= 0x7f
UTF_SPECIAL = 0x20

;* SD Card interface definitions
;* The card is accessed through port B of VIA 2
SD_CD		= 0x04
SD_CS		= 0x08
SD_DI		= 0x10
SD_DO		= 0x80
SD_CLK		= 0x01

SD_MOSI		= SD_DI
SD_MISO		= SD_DO
SD_REG		= IO_1+PRB

CMD_ERR_NOERROR			= 0x00
CMD_ERR_NOTFOUND		= 0x01
CMD_ERR_PARM			= 0x02
CMD_ERR_VAL				= 0x03

;* Number formats for conversion routines
NUM_ANY		= 0x00
NUM_DEC		= 0x01
NUM_HEX		= 0x02
NUM_BIN		= 0x03

	
;* SD Card Master Boot Record (MBR) definitions
;* The MBR contains the essential information
;* needed to access the data on the card
;* MBR is usually sector 0, but not always
;* however the card I am using does work ok.
MBR_Code				=	0x0000
MBR_OEMName				=	0x0003
MBR_BytesPerSect		=	0x000b
MBR_SectPerClust		=	0x000d
MBR_ResvSect			=	0x000e
MBR_FATCopies			=	0x0010
MBR_RootEntries			=	0x0011
MBR_SmlSect				=	0x0013
MBR_MediaDesc			=	0x0015
MBR_SectPerFAT			=	0x0016
MBR_SectPerTrk			=	0x0018
MBR_NumHeads			=	0x001a
MBR_NumHidSect			=	0x001c
MBR_NumSect				=	0x0020
MBR_DrvNum				=	0x0024
MBR_ExtSig				=	0x0026
MBR_SerNo				=	0x0027
MBR_VolName				=	0x002b
MBR_FATName				=	0x0036
MBR_ExeCode				=	0x003e
MBR_ExeMark				=	0x01fe

;* FAT16 definitions - these are offsets
;* in to a FAT table entry which is
;* 32 bytes in length.
FAT_Name				= 	0x00
FAT_Ext					=	0x08
FAT_Attr				=	0x0b
FAT_Resv				=	0x0c
FAT_Createms			=	0x0d
FAT_CreateTime			=	0x0e
FAT_CreateDate			=	0x10
FAT_AccessDate			=	0x12
FAT_EAIndex				=	0x14
FAT_ModTime				=	0x16
FAT_ModDate				=	0x18
FAT_FirstClust			=	0x1a
FAT_FileSize			=	0x1c

;* The FileHandle stucture is key to
;* accessing the file system
	struct FileHandle
	ds FH_Name, 13			; 8 name, 3 extension, 1 separator, 1 terminator
	ds FH_Size, 4
	ds FH_Attr, 1
	ds FH_CurrClust, 2
	ds FH_SectCounter, 1
	ds FH_CurrSec, 4
 	ds FH_Pointer, 4
	ds FH_DirSect, 4
	ds FH_DirOffset, 2
	ds FH_FirstClust, 2
	ds FH_LastClust, 2
	ds FH_FileMode, 1
	end struct

FS_BLK_FLG_LOAD		 	= 	0x01		; On next byte, load block
FS_BLK_FLG_FLUSH		=	0x02		; Block has changed, needs flushing
	
FS_ERR_EOF				=	0x01


;* USEFUL MACROS HERE

;* Software break to throw errors
;* use like this : SWBRK XX
;* Where XX is the error code
SWBRK macro sig
	brk
	db sig
	endm

_pushAXY macro
	pha
	phx
	phy
	endm

_pullAXY macro
	ply
	plx
	pla
	endm

_println macro msg
	_pushAXY
	ldx #lo(msg)
	lda #hi(msg)
	jsr io_print_line
	_pullAXY
	endm

_printmsgA macro msg
	phx
	phy
	pha
	ldx #lo(msg)
	lda #hi(msg)
	jsr io_print_line
	pla
	pha
	jsr str_a_to_x
	jsr io_put_ch
	txa
	jsr io_put_ch
	lda #UTF_CR
	jsr io_put_ch
	pla
	ply
	plx
	endm

_printA macro
	phx
	phy
	pha
	jsr str_a_to_x
	jsr io_put_ch
	txa
	jsr io_put_ch
	pla
	ply
	plx
	endm

_printCRLF macro
	pha
	lda #UTF_CR
	jsr put_byte
	pla
	endm

_printC macro ch
	pha
	lda #ch
	jsr put_byte
	pla
	endm

_sendcmd macro cmd
	_pushAXY
	ldx #lo(cmd)
	lda #hi(cmd)
	jsr sd_sendcmd
	_pullAXY
	endm

_incZPWord macro wordp
	inc wordp
	db	0xd0, 0x02
	inc wordp+1
	endm

_decZPWord macro wordp
	pha
	sec
	lda wordp
	sbc #1
	sta wordp
	lda wordp+1
	sbc #0
	sta wordp+1
	pla
	endm

_cpyZPWord macro worda,wordb
	lda worda
	sta wordb
	lda worda+1
	sta wordb+1
	endm
	
_addZPWord macro worda, wordb
	clc
	lda worda
	adc wordb
	sta worda
	lda worda+1
	adc wordb+1
	sta worda+1
	endm

_subZPWord macro worda, wordb
	sec
	lda worda
	sbc wordb
	sta worda
	lda worda+1
	sbc wordb+1
	sta worda+1
	endm
	
_adcZPWord macro worda,const
	clc
	lda worda
	adc #const
	sta worda
	lda worda+1
	adc #0
	sta worda+1
	endm

