	; Settings
DISK0	EQU	20			; First disk number in set
DEBUG	EQU	0			; Debug mode

;-----------------------------------------------------------------------------
;	This auto-generated file defines $DATE and $TIME macros
	include	"datetime.asm"

CR	EQU	0DH
LF	EQU	0AH

;-----------------------------------------------------------------------------
;	Macro to break in Keil-like emulator
$BREAK	MACRO
	IF	DEBUG
	DB	0EDH,0F5H		; Keil's emulator $BREAK opcode
	ENDIF
	ENDM
					;

;-----------------------------------------------------------------------------
;	IPL entry
	ORG	0
	JP	BOOTZ80			; bootstrap routine
	DC	3DH,0			; fill RST vector area with NULL

;-----------------------------------------------------------------------------
;	Bootstrap routine, executed at first IPL
	ORG	40H
BOOTZ80:
	DI

	LD	HL,$BIOS_BEGIN		; Install CBIOS in high memory (at first IPL)
	LD	DE,BIOS			;
	LD	BC,$BIOS_END-$BIOS_BEGIN;
	LDIR				;


;-----------------------------------------------------------------------------
;	Second IPL entry point
MAIN:					;LET'S BOOT UCSD PASCAL
;
;	  This program is a skeletal outline for a 128-byte primary
;	bootstrap for automatically booting to UCSD Pascal (tm).
;	  Set the correct origin for this program for your system, set
;	'MSIZE' for the appropriate number of kilobytes of RAM memory
;	for your system, set the appropriate parameters describing your
;	disk environment and finally write a very low level disk read
;	routine to allow reading in the secondary bootstrap and your
;	CBIOS off the disk and into RAM.
;	  The program 'CPMBOOT' on the UCSD Pascal distribution disk will
;	then use this program and your CBIOS to generate an automatically
;	booting UCSD Pascal system.
;
;	Adapted for Z80SIM, August 2008, Udo Munk
;	Adapted for Z80-MBC2, August 2019, Michel B.
;
BOOT	EQU	8200H		; SECONDARY BOOTSTRAP LOADED HERE
;MSIZE	EQU	64		; MEMORY SIZE FOR ASSEMBLY
;BIAS	EQU	(MSIZE*1024)-01A00H
;CBIOS	EQU	1500H+BIAS	; ORIGIN POINT
SECNUM	EQU	16		; SECONDARY BOOTSTRAP IS 16 SECTORS LONG
SECSEC	EQU	3		; SECONDARY BOOTSTRAP ON THIS SECTOR
;
PBOOT:	LD	HL,BIOS		; CBIOS GOES HERE
	LD	SP,HL		; RESET THE STACK

	LD	HL,HELLO$	; Copyright Text
	CALL	PUTS		; Display message (at first IPL only)
	LD	HL,READSEC$	; Reading sec bootstrap
	CALL	PUTS		; Display message (at first IPL only)
	LD	HL,BOOT		; LOAD BOOT BASE ADDRESS
	LD	D,SECNUM	; D - # OF SECTORS TO READ
	LD	E,SECSEC	; E - STARTING SECTOR
	CALL	READIT		; READ IN SECONDARY BOOTSTRAP
	LD	HL,128		; MAXIMUM NUMBER OF BYTES PER SECTOR
	PUSH	HL
	LD	HL,128		; MAXIMUM NUMBER OF SECTORS IN TABLE
	PUSH	HL
	LD	HL,0		; TRACK-TO-TRACK SKEW
	PUSH	HL
	LD	HL,1		; FIRST INTERLEAVED TRACK
	PUSH	HL
	LD	HL,1		; 1:1 INTERLEAVING
	PUSH	HL
	LD	HL,128		; BYTES PER SECTOR
	PUSH	HL
	LD	HL,128		; SECTORS PER TRACK
	PUSH	HL
	LD	HL,77		; TRACKS PER DISK
	PUSH	HL
	LD	HL,BIOS-2	; TOP OF MEMORY (MUST BE WORD BOUNDARY)
	PUSH	HL
	LD	HL,0100H	; BOTTOM OF MEMORY
	PUSH	HL
	LD	DE,BIOS+3	; START OF THE SBIOS (JMP WBOOT)
	PUSH	DE
	PUSH	HL		; STARTING ADDRESS OF INTERPRETER
	LD	HL,BOOTING$	; 'Booting to UCSD Pascal'
	CALL	PUTS1		; Display message (after reset)
	LD	A,0C3H		; For next reset actions:
	LD	(0),A		; - skip CBIOS move to high memory
	LD	HL,MAIN		;
	LD	(1),HL		;
	LD	A,0C9H		; - deactivate first IPL display routine
	LD	(PUTS),A	;
	JP	BOOT		; ENTER SECONDARY BOOTSTRAP

;-----------------------------------------------------------------------------
;
;	  READIT must read the number of sectors specified in the D
;	reg, starting at the sector specified in the E reg, into the
;	memory location specified in the HL pair.
;
READIT:
	PUSH	HL		; Save loading pointer
	LD	C,0		; SELECT DRIVE 0
	CALL	SELDSK
	LD	C,0
	CALL	SETTRK		; SELECT TRACK 0
	POP	HL		; get back loading pointer
L1:
	LD	C,E		; SELECT SECTOR
	CALL	SETSEC
	LD	C,L		; SET DMA ADDRESS LOW
	LD	B,H		; SET DMA ADDRESS HIGH
	CALL	SETDMA
	CALL	READ		; READ SECTOR
	OR	A		; READ SUCCESSFULL?
	JP	Z,L2		; YES, CONTINUE
	DI			; FAILURE, HALT CPU
	HALT
L2:
	DEC	D		; SECTORS = SECTORS - 1
	RET	Z		; RETURN IF ALL SECTORS LOADED
	INC	E		; NEXT SECTOR TO READ
	LD	BC,80H		; 128 BYTES PER SECTOR
	ADD	HL,BC		; DMA ADDRESS + 128
	JP	L1		; GO READ NEXT

;-----------------------------------------------------------------------------
;	Message display routine for first IPL
PUTS:	NOP
;	Message display routine for subsequent IPL
PUTS1:	LD	A,(HL)		; Get char from message
	OR	A		; End of message (NUL) ?
	RET	Z		; done if yes
	LD	C,A		;
	CALL	CONOUT		; SEND CHAR TO TERMINAL
	INC	HL		; bump message ptr
	JR	PUTS1		; and loop


;-----------------------------------------------------------------------------
;	Booting UCSD Pascal message, must fit below 0100H
;
BOOTING$:
	DB	CR,LF,LF,'Booting to UCSD Pascal',0

;	END of area 0000h-0100h which will remain untouched by P-System
	ASSERT	$ < 0100H	; enforce that ...

;-----------------------------------------------------------------------------
;	Reading secondary bootstrap message
READSEC$:
	DB	CR,LF,'Reading Secondary Bootstrap',0

;-----------------------------------------------------------------------------
;
;	copyright text
;
;	UCSD p-System IV CBIOS for Z80-MBC2
;
;	Copyright (C) 2019 by GmEsoft
;
;
HELLO$:
	DB	'64K UCSD p-System IV.0 CBIOS V1.1 for Z80-MBC2, '
	DB	'Copyright (C) 2019 by GmEsoft'
	DB	CR,LF
	DB	'Build: '
	$DATE			; Macro defining build date
	DB	' - '
	$TIME			; Macro defining build time
	DB	CR,LF,0

;-----------------------------------------------------------------------------
;	CBIOS area begin, to move in high memory at first IPL
;
$BIOS_BEGIN
    	PHASE	BIOS		; where the CBIOS code will be moved
MSIZE	EQU	64		; memory size in kilobytes
BIAS	EQU	(MSIZE*1024)-01A00H
BIOS	EQU	1500H+BIAS	; base of bios


;-----------------------------------------------------------------------------
;
;	jump vector for individual subroutines
;
	JP	CBOOT		; cold start
WBOOTE: JP	WBOOT		; warm start
	JP	CONST		; console status
	JP	CONIN		; console character in
	JP	CONOUT		; console character out
	JP	LIST		; list character out
	JP	PUNCH		; punch character out
	JP	READER		; reader character out
	JP	HOME		; move head to home position
	JP	SELDSK		; select disk
	JP	SETTRK		; set track number
	JP	SETSEC		; set sector number
	JP	SETDMA		; set dma address
	JP	READ		; read disk
	JP	WRITE		; write disk
	JP	LISTST		; return list status
	JP	SECTRAN		; sector translate
	REPT	20H
	JP	WBOOT		; do a HALT
	ENDM

;-----------------------------------------------------------------------------
;
;	individual subroutines to perform each function
;
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;	Cold boot
CBOOT:
	$BREAK			; break into simulator's debugger
	RET			; done

;-----------------------------------------------------------------------------
;	Warm boot
WBOOT:
	DI			; interrupts off
	HALT			; halt system
	RET			; ret if not halted
;
;
;-----------------------------------------------------------------------------
;	simple i/o handlers
;
;-----------------------------------------------------------------------------
;	console status, return 0ffh if character ready, 00h if not
;
CONST:
	PUSH	BC		; Save register
	LD	BC,$-$		; Get keyboard poll countdown timer
KBTIMER	EQU	$-2		;
	LD	A,B		; Done counting ?
	OR	C		;
	JR	Z,CONST1	; Go if yes
	DEC	BC		; Do the countdown at each routine call
	LD	(KBTIMER),BC	; Update counter
	LD	A,B		; Done counting ?
	OR	C		;
	JR	NZ,CONST1	; Go if not
	LD	BC,0101H	; for OUT (C),B, with C=1 and B=1
	LD	A,(DIRTY)	; Check if sector buffer is dirty
	OR	A		;
	CALL	NZ,WRITE512	; If yes, write back to disk
CONST1:	POP	BC		; Restore register
	LD	A,83H		; IOS:SYSFLAGS opcode
	OUT	(1),A		; send opcode
	IN	A,(0)		; get console status
	AND	4		; Is char ready in input buffer ?
	RET	Z		; done if not, returning A=0
	LD	A,0FFH		; else return A=0FFh
	RET			;

;-----------------------------------------------------------------------------
;
;	console character into register a
;
CONIN:	LD	A,$-$		; Get last key
LASTKEY	EQU	$-1		;
	CP	'_'-40H		; Ctrl-_ ? (used for special funcs)
	JR	NZ,CONIN1	; Go if not
	IN	A,(1)		; Read char from term kbd
	INC	A		; Is there a char ?
	RET	Z		; done if yes, returning A=0
	DEC	A		; recover char
	AND	0DFH		; Convert letter to upper case
	LD	(KEYMAP),A	; Save as keymap code
	LD	(LASTKEY),A	; Save as last key
	LD	A,'_'-40H	; Return initial char
	RET			;
CONIN1:	IN	A,(1)		; get character from console
	INC	A		; Is there a char ?
	RET	Z		; done if yes, returning A=0
	DEC	A		; recover char
	LD	(LASTKEY),A	; Save as last key
	PUSH	BC		; Save regs
	LD	C,A		; Move Key code to C
	LD	A,$-$
KEYMAP	EQU	$-1		; Get keymap code
	CP	'B'		; Check for BE keyboard layout
	CALL	Z,keybbe	; Convert if yes (C contains converted key)
	LD	A,C		; Get key code from C
	POP	BC		; restore regs
	RET			; Done


;-----------------------------------------------------------------------------
;	convert key for BE keyboard layout
keybbe:
	ld	a,c		; Get key code
	rlca			; Check high bit
	ret	c		; Return if key code >= 0x80
	push	hl		; Save regs
	ld	hl,keybbe$	; Ptr to Keyboard conversion map
	ld	b,0		; Add offset
	add	hl,bc		; to ptr
	ld	c,(hl)		; Get converted key from map
	pop	hl		; Restore regs
	ret			; Done

;-----------------------------------------------------------------------------
;	BE keyboard map
keybbe$:
	db	00h,11h,02h,03h,04h,05h,06h,07h,08h,09h,0Ah,0Bh,0Ch,0Dh,0Eh,0Fh
	db	10h,01h,12h,13h,14h,15h,16h,1Ah,18h,19h,17h,1Bh,'|','~',1Eh,1Fh
	db	' 1%3457`908_;):='
	db	'@&["''(#]!^Mm.-/+'
	db	'2QBCDEFGHIJKL?NO'
	db	'PARSTUVZXYW{<$6\'
	db	'|qbcdefghijkl,no'
	db	'parstuvzxyw}>*~',7FH

;-----------------------------------------------------------------------------
;
;	console character output from register c
;
CONOUT:
	LD	A,C		; get char to send
	OR	A		; Check for NUL
	RET	Z		; Don't send if NUL
	LD	A,01H		; IOS:SERIAL_TX opcode
	OUT	(1),A		; Send IOS opcode
	LD	A,C		; Get to accumulator
	OUT	(0),A		; Send character to console
	CP	27		; ESC character?
	RET	NZ		; No, done
	LD	A,01H		; SERIAL_TX
	OUT	(1),A		; Send IOS opcode
	LD	A,'['		; Send second lead in for ANSI terminals
	OUT	(0),A		;
	RET			; done

;-----------------------------------------------------------------------------
;
;	list character from register c
;
LIST:	JR	CONOUT		; re-route to console output

;-----------------------------------------------------------------------------
;
;	return list status (00h if not ready, 0ffh if ready)
;
LISTST: LD	A,0FFH		; List device always ready :)
	RET			; done

;-----------------------------------------------------------------------------
;
;	punch character from register c
;
PUNCH:	JR	CONOUT		; re-route to console output

;-----------------------------------------------------------------------------
;
;	read character into register a from reader device
;
READER: JP	CONIN		; re-route to console input

;-----------------------------------------------------------------------------
;
;
;	i/o drivers for the disk follow
;
;	move to the track 00 position of current drive
;	translate this call into a settrk call with parameter 00
;
HOME:	LD	C,0		; select track 0
	JP	SETTRK		; we will move to 00 on first read/write

;-----------------------------------------------------------------------------
;
;	select disk given by register C
;
SELDSK: LD	HL,0000H	; return code
	LD	A,C		; Save disk number
	LD	(NEWDSK),A	; to be used later when actual I/O ops are performed
	XOR	A		; return A=0 for OK
	RET			; done

;-----------------------------------------------------------------------------
;
;	set track given by register c
;
SETTRK: LD	A,B		; Save original value of B
	LD	B,0		; (high byte is 0)
	LD	(NEWTRK),BC	; to be used later when actual I/O ops are performed
	LD	B,A		; restore value of B
	XOR	A		; return OK (A=0)
	RET			; done

;-----------------------------------------------------------------------------
;
;	set sector given by register c
;
SETSEC: DEC	C		; Sectors are numbered from O, so decrement
	LD	A,C		; get decremented sect #
	AND	3		; keep lower 2 bits
	LD	(SECOFF),A	; save as sector offset (block of 128 bytes inside the 512 bytes sector)
	LD	A,C		; get decremented sect #
	SRL	A		; move bits 2-7 to pos 0-5, as 512 bytes sector #
	SRL	A		;
	LD	(NEWSEC),A	; save
	INC	C		; restore initial sector 1
	XOR	A		; return OK (A=0)
	RET			;

;-----------------------------------------------------------------------------
;
;	translate the sector given by BC using the
;	translate table given by DE
;
SECTRAN:
	LD	L,C		; return untranslated
	LD	H,B		; in HL
	INC	HL		; sector no. start with 1
	RET			; done

;-----------------------------------------------------------------------------
;
;	set dma address given by registers b and c
;
SETDMA: LD	(DMA),BC	; Save transfer location
	XOR	A		; return 0K (A=0)
	RET			; done

;-----------------------------------------------------------------------------
;
;	perform read operation
;
READ:	XOR	A		; read command -> A
	JR	WAITIO		; to perform the actual i/o

;-----------------------------------------------------------------------------
;
;	perform a write operation
;
WRITE:
	LD	A,1		; write command -> A

;-----------------------------------------------------------------------------
;
;	enter here from read and write to perform the actual i/o
;	operation.  return a 00h in register a if the operation completes
;	properly, and 01h if an error occurs during the read or write
;
WAITIO:
	PUSH	HL		; Save all 16-bit regs
	PUSH	DE		;
	PUSH	BC		;
	LD	(IO_OP),A	; Save I/O direction flag
	LD	A,0		; Get new disk #
NEWDSK	EQU	$-1		;
	LD	HL,CURDSK	; Pointer to current disk #
	CP	(HL)		; Are they the same ?
	JR	NZ,FLUSH	; Go if not, to flush current sect if necessary
	LD	BC,0		; Get new track #
NEWTRK	EQU	$-2		;
	LD	HL,(CURTRK)	; Pointer to current track #
	LD	A,C		; Compare low bytes
	CP	L		; Are they the same ?
	JR	NZ,FLUSH	; Go if not ...
	LD	A,B		; Compare high bytes
	CP	H		; Are they the same ?
	JR	NZ,FLUSH	; Go if not
	LD	A,0		; Get new sector #
NEWSEC	EQU	$-1		;
	LD	HL,CURSEC	; Pointer to current sector #
	CP	(HL)		; Are they the same ?
	JR	Z,NOREAD	; Don't flush and read if yes

	; Dirty sector write is now done if needed
	; Flush the current sector if buffer is dirty
FLUSH:
	LD	A,(DIRTY)	; Get the dirty flag
	OR	A		; Is it dirty ?
	CALL	NZ,WRITE512	; Write sector if yes
	JR	NZ,WAITIOX	; Go if error on write
	LD	A,(NEWDSK)	; Get new disk #
	LD	HL,CURDSK	; Pointer to current disk #
	CP	(HL)		; Are they the same ?
	JR	Z,NOSELDSK	; Skip disk select if yes
	LD	(HL),A		; Save new disk # as current disk #
	LD	A,09H		; IOS:SELDISK opcode
	OUT	(1),A		; Send IOS opcode
	LD	A,(HL)		; Get disk #
	ADD	A,DISK0		; Add DISK 0 offset for DSnDxx.DSK file name
	OUT	(0),A		; Send disk # with offset

	; Disk selection now done if needed
NOSELDSK:
	CALL	READ512		; Read sector
	JR	NZ,WAITIOX	; Go if error on read

	; Sector now read if needed (currently no check for allocation)
NOREAD:
	LD	DE,BUFFER	; Get 512-byte buffer address in DE
	LD	A,0		; Get sector offset in A (0..3)
SECOFF	EQU	$-1		; Sector offset
	LD	H,A		; Move offset * 128 to HL
	LD	L,0		;
	SRL	H		;
	RR	L		;
	ADD	HL,DE		; Add buffer address to offset
	LD	DE,0		; Get "DMA" address to DE
DMA	EQU	$-2		; "DMA" (CBIOS I/O transfer location)
	LD	BC,80H		; get sector length of 128 bytes to BC
	LD	A,0		; Get I/O direction in A
IO_OP	EQU	$-1		; I/O direction
	OR	A		; Is it a write ?
	JR	NZ,WRITEIO	; go if yes
	LDIR			; transfer 128 bytes sector from buffer to DMA
	JR	WAITIOX		; return OK (shows Z)

	; Code segment to write a sector from DMA to the buffer
WRITEIO:
	LD	(DIRTY),A	; Set the buffer "dirty" (needs to be written to disk)
	EX	DE,HL		; Swap DMA and buffer address
	LDIR			; transfer 128 bytes sector from DMA to buffer
	LD	B,10H		; Initialize the keyboard timer to commit the sector write
	LD	(KBTIMER),BC	;
	XOR	A		; return OK (shows Z)

	; Restore registers and return A=0 if Z or A=1 if NZ
WAITIOX:
	POP	BC		; restore regs
	POP	DE		;
	POP	HL		;
	LD	A,0		; A=0
	RET	Z		;   if Z
	INC	A		; otherwise A=1
	RET			; done


	; Routine to read a physical sector of 512 bytes to the buffer
READ512:
	LD	A,0AH		; IOS:SELTRACK opcode
	OUT	(1),A		; send opcode
	LD	BC,(NEWTRK)	; load the new track #
	LD	(CURTRK),BC	; save as current track #
	LD	A,C		; send low byte
	OUT	(0),A		;
	LD	A,B		; send high byte
	OUT	(0),A		;
	LD	A,0BH		; IOS:SELSECT opcode
	OUT	(1),A		; send opcode
	LD	A,(NEWSEC)	; load new physical sector #
	LD	(CURSEC),A	; save as current sector #
	OUT	(0),A		; send sector #
	LD	HL,BUFFER	; load buffer address
	LD	BC,0		; B = byte count = 256 ; C = I/O port #
	LD	A,86H		; IOS:READSECT opcode
	OUT	(1),A		; send opcode
	INIR			; read first 256 bytes
	INIR			; read last 256 bytes
	; Check the error status of the I/O operation
RETSTAT:
	LD	A,85H		; IOS:ERRDISK opcode
	OUT	(1),A		; send opcode
	IN	A,(0)		; get the error status
	OR	A		; is it 0 ?
	RET	Z		; return A=0 if yes
	LD	A,1		; otherwise return A=1
	RET			; done ; return to p-System

	; Routine to write a physical sector of 512 bytes from the buffer
WRITE512:
	XOR	A		; IOS:USER_LED opcode
	OUT	(1),A		; send opcode
	INC	A		; set A bit 1 to set the LED on
	OUT	(0),A		; send A
	LD	A,0AH		; IOS:SELTRACK opcode
	OUT	(1),A		; send opcode
	LD	BC,(CURTRK)	; get the current track #
	LD	A,C		; send low byte
	OUT	(0),A		;
	LD	A,B		; send high byte
	OUT	(0),A		;
	LD	A,0BH		; IOS:SELSECT opcode
	OUT	(1),A		; send opcode
	LD	A,(CURSEC)	; get the current sector #
	OUT	(0),A		; send sector #
	LD	HL,BUFFER	; load buffer address
	LD	BC,0		; B = byte count = 256 ; C = I/O port #
	LD	A,0CH		; IOS:WRITESECT opcode
	OUT	(1),A		; send opcode
	OTIR			; write first 256 bytes
	OTIR			; write next 256 bytes
	XOR	A		; clear the DIRTY flag
	LD	(DIRTY),A	;
	OUT	(1),A		; send IOS:USER_LED opcode
	OUT	(0),A		; set the LED off
	JR	RETSTAT		; check the error status and exit

	; Variables for disk I/O
CURDSK	DB	0FFH		; current disk #
CURTRK	DW	0FFFFH		; current track #
CURSEC	DB	0FFH		; current sector #
DIRTY	DB	0		; buffer dirty flag (needs to be written)

	DS	1 + low not $	; go to next 256 bytes boundary

BUFFER	DS	200H		; 512 bytes sector buffer

ENDBUF	EQU	$		; end of buffer, should be 0000h
	ASSERT	ENDBUF == 0000H	; enforce that ...
;
	DEPHASE
$BIOS_END:

	END	BOOT

