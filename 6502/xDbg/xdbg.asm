;=====================================================
; This is a set of commands that add more powerful
; debugging commands to the xKIM monitor.
;
; 10/13/2020 - Bob Applegate, bob@corshamtech.com
;
; Adds basic commands:
;    Load Intel HEX file
;    Examine/modify memory
;    Breakpoint handling:
;       List current breakpoints
;       Clear an existing breakpoint
;       Set a breakpoint (execution only)
;    Single step
;    Examine/modify registers
;    Continue from current PC
;    Run starting at specified address
;    Disassembly of code
;    Hex dump of area of memory
;
; Addresses and values can be zero or more hex digits
; in length. 0 = $0000, 12345678 = $5678, etc.
;
; Commands are entered, return pressed, then commands
; are interpreted.  Error messages aren't necessarily
; too useful but give a hint.
;
; DONE
; ====
; B = Lists breakpoints
; BD = Disable breakpoints
; BE = Enable breakpoints
; BC [<addr>] = with addr, clears just one breakpoint.
;             Else clears all.
; BS <addr> = Sets breakpoint at addr.
; C = Continue execution at PC; runs until breakpoint.
; D <addr1> <addr2> = Disassemble at current PC or
;            at specified address or specified range.
; E <addr> = Examine and start modifying at addr.
; H <addr> <addr> = Hex dump specified range.
; J <addr> = Jump to specified address.
; K = Show contents of SD card
; L <filename> = Load intel hex file from SD card.
; L = Load Intel hex file from console.
; R = Displays all registers.
; R <reg> <value> = Set register to value.
; S = Single step current instruction at PC.
; SO = Step over next instruction if it is a JSR.
;
; PARTIALLY DONE
; ==============
;
; NOT STARTED
; ===========
; 
; Consider buying a KIM-1 expansion board or a KIM
; Clone from us:
;
;    www.corshamtech.com
;
;=====================================================
;
		include	"kim.inc"
		include	"xkim.inc"
;
;=====================================================
;
; First, define some common ASCII characters
;
NULL		equ	$00
BELL		equ	$07
BS		equ	$08
LF		equ	$0a
CR		equ	$0d
;
BUFSIZE		equ	40
false		equ	0
true		equ	~false
TRUE		equ	true
FALSE		equ	false
;
;=====================================================
; Options
;
LOW_RAM		equ	FALSE
	if	LOW_RAM
BASE		equ	$0400
HIGHEST		equ	$13ff
	else
BASE		equ	$c000
HIGHEST		equ	$deff
	endif
;
; To avoid stepping on the user stack, the debugger
; moves the stack lower on page 1.  This sets the
; highest location.
;
STACK		equ	$0100
DBG_STACK	equ	STACK+$80
;
;=====================================================
; The debugger
;
		code
		org	BASE
Debugger	jmp	COLD
		jmp	MainLoop
;
COLD		jsr	putsil
		db	CR,LF,LF
		db	"Corsham Tech 65C02 xDebugger v0.2"
		db	CR,LF
		db	"Running at address ",0
		lda	#Debugger>>8
		jsr	xkPRTBYT
		lda	#Debugger&$ff
		jsr	xkPRTBYT
		jsr	putsil
		db	" to ",0
		lda	#CODE_END>>8
		jsr	xkPRTBYT
		lda	#CODE_END&$ff
		jsr	xkPRTBYT
		jsr	CRLF
		jsr	CRLF
;
; Save the stack pointer for cleaning up later
;
		tsx
		stx	initialSP
		jsr	InstallVecs	;install handlers
		jsr	BreakInit	;initialize breakpoints
;
; Main loop.  Present a prompt, get command, process it.
; All command handlers should eventually JMP back to here,
; as this also resets the stack pointer.
;
MainLoop	ldx	#DBG_STACK&$ff
		txs			;make stack sane
		jsr	putsil
		db	"DBG> ",0
		jsr	GetLine		;get command line
		beq	MainLoop	;branch on no data
;
; Parse the command.  This is NOT a very fancy parser
; and it is very intolerant of weirdness.
;
		ldx	#0		;offset into line
		stx	cmdOffset
		jsr	SkipSpaces
		lda	buffer,x	;get command
		pha
		jsr	SkipSpaces2	;skip over command
		pla
;
		ldx	#0
cmdloop		pha			;save command
		lda	Commands,x	;get entry
		beq	cmdnotfound	;not found
		pla			;restore command
		cmp	Commands,x
		beq	cmdfound
		inx
		inx
		inx
		bne	cmdloop		;check next command
;
cmdfound	lda	Commands+1,x	;LSB of handler
		sta	Temp16
		lda	Commands+2,x	;MSB
		sta	Temp16+1
		jmp	(Temp16)	;jump to handler
;
; Unknown command
;
cmdnotfound	pla			;clean stack
		jsr	putsil
		db	"Huh?",CR,LF,0
vecHelp		jsr	putsil
		db	CR,LF
		db	"? = This list",CR,LF
		db	"A <addr> = Mini assembler",CR,LF
		db	"B = List breakpoints",CR,LF
		db	"BD = Disable breakpoints",CR,LF
		db	"BE = Enable breakpoints",CR,LF
		db	"BC [<addr>] = Clear one or all breakpoints",CR,LF
		db	"BS <addr> = Sets breakpoint at address",CR,LF
		db	"C = Continue from last breakpoint",CR,LF
		db	"D = Disassemble at PC",CR,LF
		db	"E <addr> = Edit memory at address",CR,LF
		db	"D <addr> = Disassemble one instruction",CR,LF
		db	"D <addr> <addr> = Disassemble range",CR,LF
		db	"H <addr> <addr> = Do hex dump",CR,LF
		db	"J <addr> = Jump to address",CR,LF
		db	"K = Directory of SD card",CR,LF
		db	"L = Load hex file from console",CR,LF
		db	"L <filename> = Load hex file from SD card",CR,LF
		db	"R [<name> <value>] = Registers",CR,LF
		db	"S = Step one instruction",CR,LF
		db	"SO = Step over JSR",CR,LF
		db	"Q = Quit back to xKIM",CR,LF
		db	0
		jmp	MainLoop
;
; Vectors to command handlers.  Each entry has a one byte
; ASCII character followed by a pointer to the handler for
; that command.  Most handlers end with a JMP MainLoop.
; The end of the table is marked with a 00 byte.
;
Commands	db	'?'
		dw	vecHelp
		db	'A'
		dw	Assembler
		db	'B'
		dw	Breakpoints
		db	'C'
		dw	Continue
		db	'D'
		dw	Disassem
		db	'E'
		dw	MemEdit
		db	'H'
		dw	HexDump
		db	'J'
		dw	Jump
		db	'K'
		dw	SDDiskDir
		db	'L'
		dw	LoadHex
		db	'Q'
		dw	ExitDbg
		db	'R'
		dw	Registers
		db	'S'
		dw	Step
		db	0		;MUST BE LAST!
;
;=====================================================
; Exit the debugger.
;
ExitDbg		jsr	RestoreVecs	;undo our handlers
		ldx	initialSP
		txs
		jmp	extKIM		;return to xKIM
;
;=====================================================
; Jump to addresss which is on the command line.  It
; jumps to the specified address with the last register
; values.  Breakpoints are active.
;
Jump		jsr	ChkParam	;check for param
		jsr	GetHex
		lda	Temp16
		sta	PCL
		lda	Temp16+1
		sta	PCH
;
; Fall through...
;
;=====================================================
; This continues execution by loading all the register
; values saved duringh the interrupt and jumping back
; into the code.  Continue will install breakpoints,
; while ContinueNoBrk will not install them.  This is
; used for single-stepping where breakpoints are not
; needed and get into the way.
;
Continue	jsr	BreakInstall	;enable breakpoints
ContinueNoBrk	ldx	SPUSER
		txs
		lda	PREG		;flags
		pha			;to be restored later
		lda	ACC
		ldx	XREG
		ldy	YREG
		plp			;restore flags
		jmp	(PCL)		;return!
;
;=====================================================
; Does a disassembly of a piece of code.  If no params
; then disassemble instruction at PCL and PCH.  If one
; param then disassemble one instruction at that addr.
; If two, do that range.
;
Disassem	ldx	cmdOffset
		lda	buffer,x
		bne	disasst1
;
disasst2	jsr	doDisPC
		jsr	CRLF
		jmp	MainLoop
;
disasst1	jsr	GetHex		;start address
		jsr	XferPOINT	;put into POINT
		jsr	SkipSpaces
		lda	buffer,x	;another param?
		beq	disasst2	;branch if not
;
		jsr	GetHex
		jsr	XferEA
;
; Now call the disassemble subroutine to do the work.
;
disassemloop	jsr	doDisassem	;disassemble one
;
; The length of the instruction is in A, so add that
; to POINT so it points to the next instruction.
;
		clc
		adc	POINTL
		sta	POINTL
		bcc	disassem1
		inc	POINTH
;
; Keep disassembling if POINTL <= EA
;
disassem1	jsr	CRLF
		lda	EAH
		cmp	POINTH
		bcc	disassemdun
		bne	disassemloop
		lda	EAL
		cmp	POINTL
		bcs	disassemloop
		beq	disassemloop
disassemdun	jmp	MainLoop
;
;=====================================================
; Does a hex dump of the specified range.
;
HexDump		jsr	ChkParam	;missing start?
		jsr	GetHex		;start address
		jsr	XferSA
		jsr	SkipSpaces
		jsr	ChkParam	;missing end?
		jsr	GetHex
		jsr	XferEA
;
; Now call the xKIM hex dump function to do the work.
;
		jsr	xkHexDump
		jmp	MainLoop
;
;=====================================================
; Does a memory edit starting at the specified address
;
MemEdit		jsr	ChkParam	;missing start?
		jsr	GetHex		;start address
		jsr	XferPOINT
;
; Now call the xKIM function to do the work.
;
		jsr	xkMemEdit
		jsr	CRLF
		jmp	MainLoop
;
;=====================================================
; Loads an Intel hex file either from the console or
; from an SD file if a filename was provided.
;
LoadHex		jsr	SkipSpaces
		ldx	cmdOffset
		lda	buffer,x	;anything here?
		beq	loadconsole	;nope
;
; Compute the address of the filename
;
		txa
		clc
		adc	#buffer&$ff
		tay			;LSB of filename
		lda	#buffer>>8
		adc	#0
		tax
		jsr	loadHexFile	;in xKIM
;
; We do not want to auto-run, but if the address was
; set, display it and set the PC value to it.  Allows
; the user to immediate Step the code.
;
loadcheckauto	lda	AutoRun+1
		cmp	#$ff
		beq	loadhexit	;not set
;
		jsr	putsil
		db	"Auto-run address and PC set to ",0
		lda	AutoRun+1
		sta	PCH
		jsr	xkPRTBYT
		lda	AutoRun
		sta	PCL
		jsr	xkPRTBYT
loadhexit	jsr	CRLF
		jmp	MainLoop
;
; Load from the console
;
loadconsole	jsr	loadHexConsole
		jmp	loadcheckauto
;
;=====================================================
; A generic checker/handler for missing parameter.
; If there is no parameter next on the command line,
; this prints and error and jumps back to MainLoop.
;
ChkParam	ldx	cmdOffset
		lda	buffer,x	;get current char
		bne	noparmret	;non-zero is good
		jsr	putsil
		db	"Missing parameter",CR,LF,0
		jmp	MainLoop
noparmret	rts
;
;=====================================================
; Get a line of text into buffer.  Returns the number
; of input characters in A.  Z reflects A's status.
; Does NO checking on input data except for length!
;
GetLine		ldx	#0
getline1	stx	tempX
		jsr	xkGETCH		;get next key
		ldx	tempX
		cmp	#CR		;end of the input?
		beq	getLnDone
		cmp	#BS		;backspace?
		beq	getLnDel
		cpx	#BUFSIZE-1	;check size
		beq	getline1	;at length limit
		sta	buffer,x	;else save it
		inx
		bne	getline1
;
getLnDel	dex			;back up one
		bpl	getline1
		inx			;can't go past start
		beq	getline1
;
getLnDone       lda	#0		;terminate line
		sta	cmdOffset
		sta	buffer,x
		txa
		pha
		jsr	CRLF
		pla
		rts
;
;=====================================================
; Skips spaces in buffer starting at cmdOffset.
; Stops on first non-space and leaves the offset
; in cmdOffset.  SkipSpaces2 advances one position
; first before starting the search.
;
; A is destroyed.  Should fix this.
;
SkipSpaces2	inc	cmdOffset
SkipSpaces	ldx	cmdOffset
		lda	buffer,x
		cmp	#0
		beq	skipsp1
		cmp	#' '		;a space?
		beq	SkipSpaces2
skipsp1		rts
;
;=====================================================
; Skip characters until either a NULL or space are
; found.
;
SkipToSpace	ldx	cmdOffset
		lda	buffer,x
		beq	Skiptospace2
		cmp	#' '
		beq	Skiptospace2
		inc	cmdOffset
		bne	SkipToSpace
Skiptospace2	rts
;
;=====================================================
; Scans the input line to assemble a hex number.  Can
; be anywhere from 1 to X digits long, but only the
; last four are used.  Ie, 123456 returns $3456.
; Return value is in Temp16.  Moves cmdOffset to the
; first non-hex character; returns this value in X.
;
GetHex		lda	#0
		sta	Temp16
		sta	Temp16+1	;clear result
gethex5		ldx	cmdOffset
		lda	buffer,x
		ldy	#HexDigEnd-HexDigits-1
gethex1		cmp	HexDigits,y
		beq	gethex2		;found
		dey
		bpl	gethex1
;
; Not valid hex, so return whatever is in the result.
;
		rts
;
; Found it.  Offset, which is the value, is in Y.
; Shift existing value 4 bits left.
;
gethex2		tya
		ldy	#4
gethex3		asl	Temp16
		rol	Temp16+1
		dey
		bne	gethex3
		clc
		adc	Temp16		;add in digit
		sta	Temp16
		bcc	gethex4
		inc	Temp16+1
gethex4		inc	cmdOffset
		bne	gethex5		;get next digit
;
HexDigits	db	"0123456789ABCDEF"
HexDigEnd	equ	*
;		include	"step.asm"
;
;=====================================================
; Dislays or modifies register values
;
Registers	ldx	cmdOffset
		lda	buffer,x	;get reg name
		beq	registersdump
;
; Skip past register name and get value.
;
		pha			;save register
		jsr	SkipToSpace
		jsr	SkipSpaces
		jsr	ChkParam
		jsr	GetHex
		pla
;
; Valid register names: A X Y SP PC F  Only the
; first character is checked.
;
		cmp	#'A'
		beq	regsetA
		cmp	#'X'
		beq	regsetX
		cmp	#'Y'
		beq	regsetY
		cmp	#'S'
		beq	regsetSP
		cmp	#'P'
		beq	regsetPC
		cmp	#'F'
		beq	regsetFlags
;
		jsr	putsil
		db	"Valid registers: A, X, Y, S (SP),"
		db	" P (PC) and F (Flags)",CR,LF,0
		jmp	MainLoop
;
; Dump registers
;
registersdump	jsr	doDisPC		;disassemble, then...
		jsr	DumpRegisters	;...dump registers
		jsr	CRLF
		jmp	MainLoop
;
regsetA		lda	Temp16
		sta	ACC
		jmp	registersdump
;
regsetX		lda	Temp16
		sta	XREG
		jmp	registersdump
;
regsetY		lda	Temp16
		sta	YREG
		jmp	registersdump
;
regsetSP	lda	Temp16
		sta	SPUSER
		jmp	registersdump
;
regsetPC	lda	Temp16
		sta	PCL
		lda	Temp16+1
		sta	PCH
		jmp	registersdump
;
regsetFlags	lda	Temp16
		sta	PREG
		jmp	registersdump
;
;=====================================================
; This subroutine dumps all registers.
;
DumpRegisters	jsr	putsil
		db	"PC:",0
		lda	PCH
		jsr	xkPRTBYT
		lda	PCL
		jsr	xkPRTBYT
;
		jsr	putsil
		db	" A:",0
		lda	ACC
		jsr	xkPRTBYT
;
		jsr	putsil
		db	" X:",0
		lda	XREG
		jsr	xkPRTBYT
;
		jsr	putsil
		db	" Y:",0
		lda	YREG
		jsr	xkPRTBYT
;
		jsr	putsil
		db	" SP:",0
		lda	SPUSER
		jsr	xkPRTBYT
;
; Last is the condition register.  For this, print the
; actual flags.  Lower case for clear, upper for set.
;
		jsr	putsil
		db	" Flags:",0
;
; N - bit 7
;
		lda	#$80	;bit to test
		ldx	#'N'	;set ACII char
		jsr	testbit
;
; V - bit 6
;
		lda	#$40	;bit to test
		ldx	#'V'	;set ACII char
		jsr	testbit
;
		lda	#'-'	;unused bit
		jsr	xkOUTCH
;
; B - bit 4
;
		lda	#$10	;bit to test
		ldx	#'B'	;set ACII char
		jsr	testbit
;
; D - bit 3
;
		lda	#$08	;bit to test
		ldx	#'D'	;set ACII char
		jsr	testbit
;
; I - bit 2
;
		lda	#$04	;bit to test
		ldx	#'I'	;set ACII char
		jsr	testbit
;
; Z - bit 1
;
		lda	#$02	;bit to test
		ldx	#'Z'	;set ACII char
		jsr	testbit
;
; C - bit 0
;
		lda	#$01	;bit to test
		ldx	#'C'	;set ACII char
;
; Fall through...
;
;=====================================================
; Given a bit mask in A and an upper case character
; indicating the flag name in X, see if the flag is
; set or not.  Output upper case if set, lower case
; if not.
;
testbit		and	PREG	;is bit set?
		bne	testbit1	;yes
		txa
		lda	#'-'
;		ora	#$20	;make lower case
		jmp	xkOUTCH
testbit1	txa
		jmp	xkOUTCH
;
;=====================================================
; Does a directory of the SD card.  xKIM has all the
; code for doing this.
;
SDDiskDir	jsr	doDiskDir
		jmp	MainLoop	;xKIM does it
;
;=====================================================
; This transfers the 16 bit value in Temp16 into SAL
; and SAH.  Preserves registers.
;
XferSA		pha
		lda	Temp16
		sta	SAL
		lda	Temp16+1
		sta	SAH
		pla
		rts
;
;=====================================================
; This transfers the 16 bit value in Temp16 into EAL
; and EAH.  Preserves registers.
;
XferEA		pha
		lda	Temp16
		sta	EAL
		lda	Temp16+1
		sta	EAH
		pla
		rts
;
;=====================================================
; This transfers the 16 bit value in Temp16 into
; POINTL and POINTH.  Preserves registers.
;
XferPOINT	pha
		lda	Temp16
		sta	POINTL
		lda	Temp16+1
		sta	POINTH
		pla
		rts
;
;=====================================================
; These functions print 1, 2 or 3 spaces.
;
space3		jsr	space
space2		jsr	space
space		lda	#' '
		jmp	xkOUTCH
;
;=====================================================
; Functions to save and restore the KIM vectors.
; InstallVecs also points to the debugger's
; interrupt handler.
;
InstallVecs	ldx	#5
savevec1	lda	NMIV,x
		sta	savedVectors,x
		dex
		bpl	savevec1
;
; Install pointers to our handlers
;
		lda	#DefaultNMI&$ff
		sta	NMIV
		lda	#DefaultNMI>>8
		sta	NMIV+1
;
		lda	#DefaultIRQ&$ff
		sta	IRQV
		lda	#DefaultIRQ>>8
		sta	IRQV+1
		rts
;
;*********************************************************
RestoreVecs	ldx	#5
restvec1	lda	savedVectors,x
		sta	NMIV,x
		dex
		bpl	restvec1
		rts
;
;*********************************************************
; Default handler.  Save the state of the machine for
; debugging.  This is taken from the KIM monitor SAVE
; routine.
;
DefaultNMI
DefaultIRQ	sta	ACC
		pla
		sta	PREG
		pla
		sta	PCL
		sta	POINTL		;for disassembler
		pla
		sta	PCH
		sta	POINTH		;for disassembler
		sty	YREG
		stx	XREG
		tsx
		stx	SPUSER		;all registers saved
;
; If a BRK instruction was executed then the PC is now
; two bytes after where the BRK was, so see if there is
; a BRK and if so, move the PC back by two.
;
		lda	PREG
		and	#%00010000	;B flag
		beq	defaultISR	;not a BRK
;
; Should the Break flag be turned off?  Seems like the
; right thing to do but maybe not a good idea.
;
		lda	PREG
		and	#%11101111	;clear B flag
		sta	PREG
;
; Move back two addresses
;
		sec
		lda	PCL
		sbc	#2
		sta	PCL
		bcs	checkStep
		dec	PCH
;
; See if this was a Step command.  If so, clear the flags
; and restore the opcode.
;
checkStep	lda	StepActive
		beq	defaultISR	;branch if not a Step
		lda	StepAddress
		sta	INL
		lda	StepAddress+1
		sta	INH
		ldy	#0
		sty	StepActive	;not active anymore
		lda	StepOpcode
		sta	(INL),y		;restore opcode
;
defaultISR	ldx	#DBG_STACK&$ff
		txs			;switch to dbg stack
		jsr	BreakRemove	;remove breakpoints
		jsr	doDisPC		;disassemble, then...
		jsr	DumpRegisters	;...display registers
		jsr	CRLF
		jmp	MainLoop
;
		include	"step.asm"
		include	"break.asm"	;breakpoints
		include	"dis.asm"	;disassembler
		include	"asm.asm"	;assembler
NEXTFREE	equ	*
;
;=====================================================
; Non zero-page data.  This is all uninitialized; the
; code must set these up as needed.
;
initialSP	ds	1		;SP on entry
cmdOffset	ds	1
buffer		ds	BUFSIZE
tempX		ds	1		;generic storage
savedVectors	ds	6
Temp16		ds	2		;16 bit register
storeX		ds	1
storeY		ds	1
;
; Data for Step command
;
StepAddress	ds	2		;addr of next instruction
StepOpcode	ds	1		;what opcode was there
StepActive	ds	1		;non-zero if step active
;
CODE_END	equ	*
;
	if	* >= HIGHEST
		error	Overran memory
	endif
;
;=====================================================
; Force auto-run
;
		code
		org	AutoRun
		dw	Debugger
;
		end


