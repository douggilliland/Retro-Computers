;*********************************************************
; CTMON65
;
; This is the monitor for the Corsham Techologies, LLC
; SS-50 65C02 board.  It's a fairly generic monitor that
; can be ported to other 6502 based systems.
;
; Written mostly while on a family vacation in 2018, but
; ideas and code were taken from other Corsham Tech
; projects and various web pages (credit given in the
; code).
;
; Bob Applegate
; bob@corshamtech.com
; www.corshamtech.com
;*********************************************************
;
		include	"config.inc"
;
; Current version and revision
;
VERSION		equ	0
REVISION	equ	3
;
;---------------------------------------------------------
; ASCII constants
;
BELL		equ	$07
BS		equ	$08
LF		equ	$0a
CR		equ	$0d
;
; Max number of bytes per line for hex dump
;
BYTESLINE	equ	16
;
; These are various buffer sizes
;
FILENAME_SIZE	equ	12
;
; Intel HEX record types
;
DATA_RECORD	equ	$00
EOF_RECORD	equ	$01
;
; Zero-page data
;
;		zpage
		bss
		org	ZERO_PAGE_START
sptr		ds	2
INL		ds	1
INH		ds	1
putsp		ds	2
;
; Non zero-page data
;
		bss
		org	RAM_START
;
; The use of memory starting from here will remain
; constant through different versions of CTMON65.
;
IRQvec		ds	2
NMIvec		ds	2
;
; Before a L(oad) command, these are set to $FF.
; After loading, if they are different, jump to
; that address.
;
AutoRun		ds	2
;
; Pointer to the subroutine that gets the next input
; character.  Used for doing disk/console input.
;
inputVector	ds	2
;
; Same thing for output.
;
outputVector	ds	2
;
; Buffer for GETLINE
;
buffer		ds	BUFFER_SIZE
;
; Anything from here can be moved between versions.
;
SaveA		ds	1
SaveX		ds	1
SaveY		ds	1
SavePC		ds	2
SaveC		ds	1
SaveSP		ds	1
SAL		ds	1
SAH		ds	1
EAL		ds	1
EAH		ds	1
tempA		ds	1
filename	ds	FILENAME_SIZE+1
diskBufOffset	ds	1
diskBufLength	ds	1
CHKL		ds	1
ID		ds	1
Temp16L		ds	1
Temp16H		ds	1
;
; This weird bit of DBs is to allow for the fact that
; I'm putting a 4K monitor into the top half of an
; 8K EEPROM.  This forces the actual code to the top
; 4K section.
;
		code
		org	ROM_START-$1000
		db	"This space for rent.",CR,LF
		db	"Actually, this just forces the "
		db	"binary file to be 8K long."
;
		org	ROM_START
;
;=========================================================
; Jump table to common functions.  The entries in this
; table are used by external programs, so nothing can be
; moved or removed from this table.  New entries always
; go at the end.  Many of these are internal functions
; and I figured they might be handy for others.
;
COLDvec		jmp	RESET
WARMvec		jmp	WARM
;
; These are the major and minor revision numbers so that
; code can check to see which CTMON65 version is running.
;
CTMON65ver	db	VERSION
CTMON65rev	db	REVISION
		db	0
;
; Console related functions
;
CINvec		jmp	cin
COUTvec		jmp	cout
CSTATvec	jmp	cstatus
PUTSILvec	jmp	putsil
GETLINEvec	jmp	getline
CRLFvec		jmp	crlf
OUTHEXvec	jmp	HexA
;
; Low-level functions to access the SD card system
;
	if	SD_ENABLED
XPARINITvev	jmp	xParInit
XPARSETWRITEvec	jmp	xParSetWrite
XPARSETREADvec	jmp	xParSetRead
XPARWRITEvec	jmp	xParWriteByte
XPARREADvec	jmp	xParReadByte
;
; Higher level SD card functions
;
DISKPINGvec	jmp	DiskPing
DISKDIRvec	jmp	DiskDir
DISKDIRNEXTVEC	jmp	DiskDirNext
DISKOPENREADvec	jmp	DiskOpenRead
DISKOPENWRITvec	jmp	DiskOpenWrite
DISKREADvec	jmp	DiskRead
DISKWRITEvec	jmp	DiskWrite
DISKCLOSEvec	jmp	DiskClose
	endif	;SD_ENABLED
;
;---------------------------------------------------------
; Cold start entry point
;
RESET		ldx	#$ff
		txs
		jsr	cinit
		jsr	xParInit
;
; Reset the NMI and IRQ vectors
;
		lda	#DefaultNMI&$ff
		sta	NMIvec
		lda	#DefaultNMI>>8
		sta	NMIvec+1
;
		lda	#DefaultIRQ&$ff
		sta	IRQvec
		lda	#DefaultIRQ>>8
		sta	IRQvec+1
;
; Print start-up message
;
		jsr	putsil
		db	CR,LF,LF,LF,LF
		db	"CTMON65 rev "
		db	VERSION+'0','.'
		db	REVISION+'0'
		db	CR,LF
		db	"09/20/2018 by Bob Applegate K2UT"
		db	", bob@corshamtech.com"
		db	CR,LF,LF,0
;
;---------------------------------------------------------
; Warm start entry point.  This is the best place to jump
; in the code after a user program has ended.  Go through
; the vector, of course!
;
WARM		ldx	#$ff
		txs
;
; Prompt the user and get a line of text
;
prompt		jsr	setOutputConsole
		jsr	setInputConsole
		jsr	putsil
		db	CR,LF
		db	"CTMON65> "
		db	0
prompt2		jsr	cin
		cmp	#CR
		beq	prompt
		cmp	#LF
		beq	prompt2	;don't prompt
		sta	tempA
;
; Now cycle through the list of commands looking for
; what the user just pressed.
;
		lda	#commandTable&$ff
		sta	sptr
		lda	#commandTable/256
		sta	sptr+1
		jsr	searchCmd	;try to find it
;
; Hmmm... wasn't one of the built in commands, so
; see if it's an extended command.
;
	if	EXTENDED_CMDS
		lda	ExtensionAddr
		sta	sptr
		lda	ExtensionAddr+1
		sta	sptr+1
		jsr	searchCmd	;try to find it
	endif
;
; If that returns, then the command was not found.
; Print that it's unknown.
;
		jsr	putsil
		db	" - Huh?",0
cmdFound	jmp	prompt
;
;=====================================================
; Vector table of commands.  Each entry consists of a
; single ASCII character (the command), a pointer to
; the function which handles the command, and a pointer
; to a string that describes the command.
;
commandTable	db	'?'
		dw	showHelp
		dw	quesDesc
;
		db	'C'
		dw	doContinue
		dw	cDesc
;
		db	'D'
		dw	doDiskDir
		dw	dDesc
;
		db	'E'	;edit memory
		dw	editMemory
		dw	eDesc
;
		db	'H'	;hex dump
		dw	hexDump
		dw	hDesc
;
		db	'J'	;jump to address
		dw	jumpAddress
		dw	jDesc
;
		db	'L'	;load Intel HEX file
		dw	loadHex
		dw	lDesc
;
		db	'M'	;perform memory test
		dw	memTest
		dw	mDesc
;
		db	'P'	;ping remote disk
		dw	pingDisk
		dw	pDesc
;
		db	'S'	;save memory as hex file
		dw	saveHex
		dw	sDesc
;
		db	'T'	;type a file on SD
		dw	typeFile
		dw	tDesc
;
		db	0	;marks end of table
;
;=====================================================
; Descriptions for each command in the command table.
; This wastes a lot of space... I'm open for any
; suggestions to keep the commands clear but reducing
; the amount of space this table consumes.
;
quesDesc	db	"? ........... Show this help",0
cDesc		db	"C ........... Continue execution",0
dDesc		db	"D ........... Disk directory",0
eDesc		db	"E xxxx ...... Edit memory",0
hDesc		db	"H xxxx xxxx . Hex dump memory",0
jDesc		db	"J xxxx ...... Jump to address",0
lDesc		db	"L ........... Load HEX file",0
mDesc		db	"M xxxx xxxx . Memory test",0
pDesc		db	"P ........... Ping disk controller",0
sDesc		db	"S xxxx xxxx . Save memory to file",0
tDesc		db	"T ........... Type disk file",0
;
;=====================================================
; This subroutine will search for a command in a table
; and call the appropriate handler.  See the command
; table near the start of the code for what the format
; is.  If a match is found, pop off the return address
; from the stack and jump to the code.  Else, return.
;
searchCmd	ldy	#0
cmdLoop		lda	(sptr),y
		beq	cmdNotFound
		cmp	tempA	;compare to user's input
		beq	cmdMatch
		iny		;start of function ptr
		iny
		iny		;start of help
		iny
		iny		;move to next command
		bne	cmdLoop
;
; It's found!  Load up the address of the code to call,
; pop the return address off the stack and jump to the
; handler.
;
cmdMatch	iny
		lda	(sptr),y	;handler LSB
		pha
		iny
		lda	(sptr),y	;handler MSB
		sta	sptr+1
		pla
		sta	sptr
		pla		;pop return address
		pla
		jmp	(sptr)
;
; Not found, so just return.
;
cmdNotFound	rts
;
;=====================================================
; Handles the command to prompt for an address and then
; jump to it.
;
jumpAddress	jsr	putsil
		db	"Jump to ",0
		jsr	getStartAddr
		bcs	cmdRet	;branch on bad address
		jsr	crlf
		jmp	(SAL)	;else jump to address
;
cmdRet		jmp	prompt
;
;=====================================================
; Do a hex dump of a region of memory.
;
; Slight bug: the starting address is rounded down to
; a multiple of 16.  I'll fix it eventually.
;
hexDump		jsr	putsil
		db	"Hex dump ",0
		jsr	getAddrRange
		bcs	cmdRet
		jsr	crlf
;
; Move start address to sptr but rounded down to the
; 16 byte boundary.  While it's really cool to start at
; the exact address specified by the user, it adds
; code that really doesn't add much (any?) value.
;
		lda	SAH
		sta	sptr+1
		lda	SAL
		and	#$f0	;force to 16 byte
		sta	sptr
;
;-----------------------------------------------------
; This starts each line.  Set flag to indcate we're
; doing the hex portion, print address, etc.
;
hexdump1	jsr	crlf
		lda	sptr+1
		jsr	HexA	;print the address
		lda	sptr
		jsr	HexA
		jsr	space2	;two spaces after address
;
;-----------------------------------------------------
; This loop gets the next byte, prints the value in
; hex and adds the appropriate ASCII character to the
; buffer.
;
		ldy	#0	;offset from sptr
hexdump3	ldx	#0	;bytes on line
hexdump2	lda	(sptr),y	;get byte
		jsr	HexA	;print hex version of it
		jsr	space	;space before next value
;
; Put the byte into the buffer.  If it is not printable
; ASCII then substitute a dot instead.
;
		cmp	#' '
		bcc	hexdot
		cmp	#'~'
		bcc	hexpr
hexdot		lda	#'.'
hexpr		sta	buffer,x	;save for later
;
; See if the end of the user defined area was just dumped
;
hexdumpchk	lda	sptr
		cmp	EAL
		bne	hexdump4
		lda	sptr+1
		cmp	EAH
		beq	hexdumpend
;
; Not done yet, so see if at end of the line
;
hexdump4	jsr	INCPT	;move to next address
		inx
		cpx	#BYTESLINE
		bne	hexdump2
;
; At end, so dump ASCII contents
;
		jsr	dumpBuffer
		jmp	hexdump1
;
; At the end but still need to dump the ASCII version.
;
hexdumpend	inx		;count last byte output
		jsr	dumpBuffer
		jsr	crlf
ret1		jmp	prompt
;
;=====================================================
; A helper function that prints the ASCII data in the
; buffer.  On entry X contains the number of bytes
; in the buffer.
;
dumpBuffer	cpx	#BYTESLINE	;is buffer full?
		beq	hexdump91	;jump if so
		lda	#' '	;else fill with spaces
		sta	buffer,x
		jsr	space3	;and space over
		inx
		bne	dumpBuffer
;
hexdump91	jsr	space3	;separate the two passes
		ldx	#0
hexdump99	lda	buffer,x
		jsr	cout	;print char in buffer
		inx
		cpx	#BYTESLINE
		bne	hexdump99
		rts
;
;=====================================================
; Edit memory.  This waits for a starting address to be
; entered.  It will display the current address and its
; contents.  Possible user inputs and actions:
;
;   Two hex digits will place that value in memory
;   RETURN moves to next address
;   BACKSPACE moves back one address
;
editMemory	jsr	putsil
		db	"Edit memory ",0
		jsr	getStartAddr
		bcs	ret1
		lda	SAL	;move address into...
		sta	sptr	;...POINT
		lda	SAH
		sta	sptr+1
;
; Display the current location
;
editMem1	jsr	crlf
		lda	sptr+1
		jsr	HexA
		lda	sptr
		jsr	HexA
		jsr	space
		ldy	#0
		lda	(sptr),y	;get byte
		jsr	HexA	;print it
		jsr	space
;
		jsr	getHex
		bcs	editMem2	;not hex
		ldy	#0
		sta	(sptr),y	;save new value
;
; Bump POINT to next location
;
editMem3	inc	sptr
		bne	editMem1
		inc	sptr+1
		jmp	editMem1
;
; Not hex, so see if another command
;
editMem2	cmp	#CR
		beq	editMem3	;move to next
		cmp	#BS
		bne     ret1		;else exit
;
; Move back one location
;
		sec
		lda	sptr
		sbc	#1
		sta	sptr
		bcs	editMem1
		dec	sptr+1
		jmp	editMem1
;
;=====================================================
; This handles the Load hex command.
;
loadHex		lda	#$ff
		sta	AutoRun+1
;
		jsr	putsil
		db	CR,LF
		db	"Enter filename, or Enter to "
		db	"load from console: ",0
;
		jsr	getFileName	;get filename
		lda	filename	;null?
		beq	loadHexConsole	;load from console
;
; Open the file
;
		ldy	#filename&$ff
		ldx	#filename/256
		jsr	DiskOpenRead
		bcc	loadHexOk	;opened ok
;
openfail	jsr	putsil
		db	CR,LF
		db	"Failed to open file"
		db	CR,LF,0
cmdRet3		jmp	prompt
;
loadHexOk	jsr	setInputFile	;redirect input
		jmp	loadStart
;
; They are loading from the console
;
loadHexConsole	jsr	putsil
		db	CR,LF
		db	"Waiting for file, or ESC to"
		db	" exit..."
		db	CR,LF,0
		jsr	setInputConsole
;
; The start of a line.  First character should be a
; colon, but toss out CRs, LFs, etc.  Anything else
; causes an abort.
;
loadStart	jsr	redirectedGetch	;get start of line
		cmp	#CR
		beq	loadStart
		cmp	#LF
		beq	loadStart
		cmp	#':'	;what we expect
		bne	loadAbort
;
; Get the header of the record
;
		lda	#0
		sta	CHKL	;initialize checksum
;
		jsr	getHex	;get byte count
		bcs	loadAbort
		sta	SaveX	;save byte count
		jsr	updateCrc
		jsr	getHex	;get the MSB of offset
		bcs	loadAbort
		sta	sptr+1
		jsr	updateCrc
		jsr	getHex	;get LSB of offset
		bcs	loadAbort
		sta	sptr
		jsr	updateCrc
		jsr	getHex	;get the record type
		bcs	loadAbort
		jsr	updateCrc
;
; Only handle two record types:
;    00 = data record
;    01 = end of file record
;
		cmp	#DATA_RECORD
		beq	loadDataRec
		cmp	#EOF_RECORD
		beq	loadEof
;
; Unknown record type
;
loadAbort       jsr	putsil
		db	CR,LF
		db	"Aborting"
		db	CR,LF,0
loadExit	jsr	setInputConsole
		jmp	prompt
;
; EOF is easy
;
loadEof		jsr	getHex	;get checksum
		jsr	putsil
		db	CR,LF
		db	"Success!"
		db	CR,LF,0
;
; If the auto-run vector is no longer $ffff, then jump
; to whatever it points to.
;
		lda	AutoRun+1
		cmp	#$ff		;unchanged?
		beq	lExit1
		jmp	(AutoRun)	;execute!
;
lExit1		jmp	loadExit
;
; Data records have more work.  After processing the
; line, print a dot to indicate progress.  This should
; be re-thought as it could slow down loading a really
; big file if the console speed is slow.
;
loadDataRec	ldx	SaveX	;byte count
		ldy	#0	;offset
loadData1	stx	SaveX
		sty	SaveY
		jsr	getHex
		bcs	loadAbort
		jsr	updateCrc
		ldy	SaveY
		ldx	SaveX
		sta	(sptr),y
		iny
		dex
		bne	loadData1
;
; All the bytes were read so get the checksum and see
; if it agrees.  The checksum is a twos-complement, so
; just add the checksum into what we've been calculating
; and if the result is zero then the record is good.
;
		jsr	getHex	;get checksum
		clc
		adc	CHKL
		bne	loadAbort	;non-zero is error
;
		lda	#'.'	;sanity indicator when
		jsr	cout	;...loading from file
		jmp	loadStart
;
;=====================================================
; Handles the command to save a region of memory as a
; file on the SD.
;
saveHex		jsr	getAddrRange	;get range to dump
		bcs	lExit1	;abort on error
;
; Get the filename to save to
;
		jsr	putsil
		db	CR,LF
		db	"Enter filename, or Enter to "
		db	"load from console: ",0
;
		jsr	getFileName	;get filename
		lda	filename	;null?
		beq	saveHexConsole	;dump to console
;
; They selected a file, so try to open it.
;
		ldx	#filename>>8
		ldy	#filename&$ff
		jsr	DiskOpenWrite	;attempt to open file
		bcc	sopenok		;branch if opened ok
		jmp	openfail
;
sopenok		jsr	setOutputFile
		jmp	savehex2
;
; They are saving to the console.  Set up the output
; vector and do the job.
;
saveHexConsole	jsr	setOutputConsole
;
; Compute the number of bytes to dump
;
savehex2	sec
		lda	EAL
		sbc	SAL
		sta	Temp16L
		lda	EAH
		sbc	SAH
		sta	Temp16H
		bcc	SDone	;start > end
		ora	0
		bmi	SDone	;more than 32K seems wrong
;
; Add one to the count
;
		inc	Temp16L
		bne	slab1
		inc	Temp16H
;
; Move pointer to zero page
;
slab1		lda	SAL
		sta	sptr
		lda	SAH
		sta	sptr+1
;
; Top of each loop.  Start by seeing if there are any bytes
; left to dump.
;
Sloop1		lda	Temp16H
		bne	Sgo	;more to do
		lda	Temp16L
		bne	Sgo	;more to do
;
; At end of the region, so output an end record.  This
; probably looks like overkill but keep in mind this
; might be going to a file so we can't use the normal
; string put functions.
;
		lda	#':'
		jsr	redirectedOutch
		lda	#0
		jsr	HexToOutput
		jsr	HexToOutput
		jsr	HexToOutput
		lda	#1
		jsr	HexToOutput
		lda	#$ff
		jsr	HexToOutput
;
; If output to file, flush and close the file.
;
		lda	filename
		beq	SDone		;it's going to console
		jsr	CloseOutFile
SDone		jmp	prompt		;back to the monitor
;
; This dumps the next line.  See how many bytes are left to do
; and if more than BYTESLINE, then just do BYTESLINE.
;
Sgo		lda	Temp16H
		bne	Sdef	;do default number of bytes
		lda	Temp16L
		cmp	#BYTESLINE
		bcc	Scnt	;more than max per line
Sdef		lda	#BYTESLINE
Scnt		sta	tempA	;for decrementing
		sta	ID	;for subtracting
;
; Put out the header
;
		lda	#':'
		jsr	redirectedOutch
;
		lda	tempA
		sta	CHKL	;start checksum
		jsr	HexToOutput
;
		lda	sptr+1	;starting address
		jsr	updateCrc
		jsr	HexToOutput
		lda	sptr
		jsr	updateCrc
		jsr	HexToOutput
;
		lda	#0	;record type - data
		jsr	HexToOutput
;
; Now print the proper number of bytes
;
Sloop2		ldy	#0
		lda	(sptr),y	;get byte
		jsr	updateCrc
		jsr	HexToOutput
		jsr	INCPT	;increment pointer
;
sdec		dec	tempA
		bne	Sloop2
;
; Now print checksum
;
		lda	CHKL
		eor	#$ff	;one's complement
		clc
		adc	#1	;two's complement
		jsr	HexToOutput
;
; Output a CR/LF
;
		lda	#CR
		jsr	redirectedOutch
		lda	#LF
		jsr	redirectedOutch
;
; If saving to disk, output a dot to indicate progress.
;
		lda	filename
		beq	shf2
;
		lda	#'.'
		jsr	cout	;goes to console
;
shf2		sec
		lda	Temp16L
		sbc	ID
		sta	Temp16L
		lda	Temp16H
		sbc	#0
		sta	Temp16H
;
		jmp	Sloop1
;
;=====================================================
; Get a disk filename.
;
getFileName	ldx	#0
getFilename1	jsr	cin	;get next key
		cmp	#CR	;end of the input?
		beq	getFnDone
		cmp	#BS	;backspace?
		beq	getFnDel
		cpx	#FILENAME_SIZE	;check size
		beq	getFilename1	;at length limit
		sta	filename,x	;else save it
		jsr	cout
		inx
		bne	getFilename1
;
getFnDel	dex
		bmi	getFnU	;no charac here
		lda	#BS
		jsr	cout
		lda	#' '
		jsr	cout
		lda	#BS
		jsr	cout
		dex
getFnU		inx		;can't go past start
		bpl	getFilename1
getFnDone       lda	#0	;terminate line
		sta	filename,x
		jmp	crlf
;
;=====================================================
; Add the byte in A to the output buffer.  If the
; buffer is full, flush it to disk.
;
putNextFileByte	ldx	diskBufOffset
		cpx	#BUFFER_SIZE	;buffer full?
		bne	pNFB		;no
;
; The buffer is full, so write it out.
;
		pha			;save byte
		lda	#BUFFER_SIZE
		ldx	#buffer>>8
		ldy	#buffer&$ff
		jsr	DiskWrite
;
		ldx	#0		;reset index
		pla
pNFB		sta	buffer,x
		inx
		stx	diskBufOffset
		rts
;
;*********************************************************
; Dump the current registers based on values in the Save*
; locations.
;
DumpRegisters	jsr	putsil
		db	"PC:",0
		lda	SavePC+1
		jsr	HexA
		lda	SavePC
		jsr	HexA
;
		jsr	putsil
		db	" A:",0
		lda	SaveA
		jsr	HexA
;
		jsr	putsil
		db	" X:",0
		lda	SaveX
		jsr	HexA
;
		jsr	putsil
		db	" Y:",0
		lda	SaveY
		jsr	HexA
;
		jsr	putsil
		db	" SP:",0
		lda	SaveSP
		jsr	HexA
;
; Last is the condition register.  For this, print the
; actual flags.  Lower case for clear, upper for set.
;
		jsr	putsil
		db	" Flags:",0
	if	FULL_STATUS
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
		jsr	cout
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
;*********************************************************
; Given a bit mask in A and an upper case character
; indicating the flag name in X, see if the flag is set or
; not.  Output upper case if set, lower case if not.
;
testbit		and	SaveC	;is bit set?
		bne	testbit1	;yes
		txa
		ora	#$20	;make lower case
		jmp	cout
testbit1	txa
		jmp	cout
	else
		lda	SaveSP
		jmp	HexA
	endif
;
;=====================================================
; This continues executing from the last saved state,
; such as from a call to DefaultNMI.
;
doContinue
		ldx	SaveSP
		txs
		lda	SavePC+1
		pha
		lda	SavePC
		pha
		lda	SaveC
		pha
		ldx	SaveX
		ldy	SaveY
		lda	SaveA
		rti
;
;=====================================================
; This gets two hex characters and returns the value
; in A with carry clear.  If a non-hex digit is
; entered, then A contans the offending character and
; carry is set.
;
getHex		jsr	getNibble
		bcs	getNibBad
		asl	a
		asl	a
		asl	a
		asl	a
		and	#$f0
		sta	tempA
		jsr	getNibble
		bcs	getNibBad
		ora	tempA
		clc
		rts
;
; Helper.  Gets next input char and converts to a
; value from 0-F in A and returns C clear.  If not a
; valid hex character, return C set.
;
getNibble	jsr	redirectedGetch
		ldx	#nibbleHexEnd-nibbleHex-1
getNibble1	cmp	nibbleHex,x
		beq	getNibF	;got match
		dex
		bpl	getNibble1
getNibBad	sec
		rts

getNibF		txa		;index is value
		clc
		rts
;
nibbleHex	db	"0123456789ABCDEF"
nibbleHexEnd	equ	*
;
;=====================================================
; Gets a four digit hex address amd places it in
; SAL and SAH.  Returns C clear if all is well, or C
; set on error and A contains the character.
;
getStartAddr	jsr	getHex
		bcs	getDone
		sta	SAH
		jsr	getHex
		bcs	getDone
		sta	SAL
		clc
getDone		rts
;
;=====================================================
; Gets a four digit hex address and places it in
; EAL and EAH.  Returns C clear if all is well, or C
; set on error and A contains the character.
;
getEndAddr	jsr	getHex
		bcs	getDone
		sta	EAH
		jsr	getHex
		bcs	getDone
		sta	EAL
		clc
		rts
;
;=====================================================
; Get an address range and leave them in SAL and EAL.
;
getAddrRange	jsr	putsil
		db	"Start: ",0
		jsr	getStartAddr
		bcs	getDone
		jsr	putsil
		db	", End: ",0
		jsr	getEndAddr
		rts
;
;=====================================================
; Command handler for the ? command
;
showHelp	jsr	putsil
		db	CR,LF
		db	"Available commands:"
		db	CR,LF,LF,0
;
; Print help for built-in commands...
;
		lda	#commandTable&$ff
		sta	sptr
		lda	#commandTable/256
		sta	sptr+1
		jsr	displayHelp	;display help
;
; Now print help for the extension commands...
;
	if	EXTENDED_CMDS
		lda	ExtensionAddr
		sta	sptr
		lda	ExtensionAddr+1
		sta	sptr+1
		jsr	displayHelp
		jsr	crlf
	endif
		jmp	prompt
;
;=====================================================
; Given a pointer to a command table in POINT, display
; the help text for all commands in the table.
;
displayHelp	ldy	#0	;index into command table
showHelpLoop	lda	(sptr),y	;get command
		beq	showHelpDone	;jump if at end
;
; Display this entry's descriptive text
;
		iny		;skip over command
		iny		;skip over function ptr
		iny
		lda	(sptr),y
		sta	INL
		iny
		lda	(sptr),y
		sta	INH
		tya
		pha
		jsr	space2
		jsr	puts	;print description
		jsr	crlf
		pla
		tay
		iny		;point to next entry
		bne	showHelpLoop
showHelpDone	rts
;
;=====================================================
; This does a memory test of a region of memory.
;
; Asks for the starting and ending locations.
;
; This cycles a rolling bit, then adds a ninth
; pattern to help detect shorted address bits.
; Ie: 01, 02, 04, 08, 10, 20, 40, 80, BA
;
pattern		equ	SaveA	;re-use some other locations
original	equ	SaveX
;
; Test patterns
;
PATTERN_0	equ	$01
PATTERN_9	equ	$ba
;
memabort	jsr	cin	;eat pending key
cmdRet2		jmp	prompt
;
memTest		jsr	putsil
		db	"Memory test ",0
		jsr	getAddrRange	;get range
		bcs	cmdRet2		;branch if abort
;
		jsr	putsil
		db	CR,LF
		db	"Testing memory.  Press any key to abort"
		db	0
		lda	#PATTERN_0	;only set initial...
		sta	pattern		;..pattern once
;
; Start of loop.  This fills/tests one complete pass
; of memory.
;
memTestMain	jsr	cstatus	;key pressed?
		bne	memabort	;branch if yes
		lda	SAL	;reset pointer to start
		sta	sptr
		lda	SAH
		sta	sptr+1
;
; Fill memory with the rolling pattern until the last
; location is filled.
;
		ldy	#0
		lda	pattern
		sta	original
memTestFill	sta	(sptr),y
		cmp	#PATTERN_9	;at last pattern?
		bne	memFill3
		lda	#PATTERN_0	;restart pattern
		jmp	memFill4
;
; Rotate pattern left one bit
;
memFill3	asl	a
		bcc	memFill4	;branch if not overflow
		lda	#PATTERN_9	;ninth pattern
;
; The new pattern is in A.  Now see if we've reached
; the end of the area to be tested.
;
memFill4	pha		;save pattern
		lda	sptr
		cmp	EAL
		bne	memFill5
		lda	sptr+1
		cmp	EAH
		beq	memCheck
;
; Not done, so move to next address and keep going.
;
memFill5	jsr	INCPT
		pla		;recover pattern
		jmp	memTestFill
;
; Okay, memory is filled, so now go back and test it.
; We kept a backup copy of the initial pattern to
; use, but save the current pattern as the starting
; point for the next pass.
;
memCheck	pla
		sta	pattern	;for next pass
		lda	SAL	;reset pointer to start
		sta	sptr
		lda	SAH
		sta	sptr+1
		lda	original	;restore initial pattern
		ldy	#0
memTest2	cmp	(sptr),y
		bne	memFail
		cmp	#PATTERN_9
		bne	memTest3
;
; Time to reload the pattern
;
		lda	#PATTERN_0
		bne	memTest4
;
; Rotate pattern left one bit
;
memTest3	asl	a
		bcc	memTest4
		lda	#PATTERN_9
;
; The new pattern is in A.
;
memTest4	pha		;save pattern
		lda	sptr
		cmp	EAL
		bne	memTest5	;not at end
		lda	sptr+1
		cmp	EAH
		beq	memDone	;at end of pass
;
; Not at end yet, so inc pointer and continue
;
memTest5	jsr	INCPT
		pla
		jmp	memTest2
;
; Another pass has completed.
;
memDone		pla
		lda	#'.'
		jsr	cout
		jmp	memTestMain
;
; Failure.  Display the failed address, the expected
; value and what was actually there.
;
memFail		pha		;save pattern for error report
		jsr	putsil
		db	CR,LF
		db	"Failure at address ",0
		lda	sptr+1
		jsr	HexA
		lda	sptr
		jsr	HexA
		jsr	putsil
		db	".  Expected ",0
		pla
		jsr	HexA
		jsr	putsil
		db	" but got ",0
		ldy	#0
		lda	(sptr),y
		jsr	HexA
		jsr	crlf
cmdRet4		jmp	prompt
;
;=====================================================
; Increment sptr
;
INCPT		inc	sptr
		bne	incpt2
		inc	sptr+1
incpt2		rts
;
;=====================================================
; Ping the Arduino disk controller.  This just sends the
; PING command gets back one character, then returns.
; Not much of a test but is sufficient to prove the
; link is working.
;
pingDisk	jsr	putsil
		db	"Ping... ",0
		jsr	DiskPing
		jsr	putsil
		db	"success!"
		db	CR,LF,0
doDiskDirEnd	jmp	prompt
;
;=====================================================
; Do a disk directory of the SD card.
;
doDiskDir	jsr	putsil
		db	"Disk Directory..."
		db	CR,LF,0
;		jsr	xParInit
		jsr	DiskDir
;
; Get/Display each entry
;
doDiskDirLoop   ldx	#filename/256	;pointer to buffer
		ldy	#filename&$ff
		stx	INH		;save for puts
		sty	INL
		jsr	DiskDirNext	;get next entry
		bcs	doDiskDirEnd	;carry = end of list
		jsr	space3
		jsr	puts		;else print name
		jsr	crlf
		jmp	doDiskDirLoop	;do next entry
;
;=====================================================
; Adds the character in A to the CRC.  Preserves A.
;
updateCrc	pha
		clc
		adc	CHKL
		sta	CHKL
		pla
		rts
;
;=====================================================
; Print character in A as two hex digits to the
; current output device (console or file).
;
HexToOutput	pha		;save return value
		pha
		lsr	a	;move top nibble to bottom
		lsr	a
		lsr	a
		lsr	a
		jsr	hexta	;output nibble
		pla
		jsr	hexta
		pla		;restore
		rts
;
hexta		and	#%0001111
		cmp	#$0a
		clc
		bmi	hexta1
		adc	#7
hexta1		adc	#'0'	;then fall into...
;
;=====================================================
; This is a helper function used for redirected I/O.
; It simply does a jump through the output vector
; pointer to send the character in A to the proper
; device.
;
redirectedOutch	jmp	(outputVector)
;
;=====================================================
; Set up the output vector to point to the normal
; console output subroutine.
;
setOutputConsole
		lda	#cout&$ff
		sta     outputVector
		lda	#cout/256
		sta	outputVector+1
		rts
;
;=====================================================
; Set up the output vector to point to a file write
; subroutine.
;
setOutputFile	lda	#putNextFileByte&$ff
		sta     outputVector
		lda	#putNextFileByte/256
		sta	outputVector+1
;
; Clear counts and offsets so the next read will
; cause the file to be read.
;
		lda	#0
		sta	diskBufOffset
		rts
;
;=====================================================
; Set up the input vector to point to the normal
; console input subroutine.
;
setInputConsole	lda	#cinecho&$ff
		sta     inputVector
		lda	#cinecho/256
		sta	inputVector+1
		rts
;
cinecho		jsr	cin
		pha
		jsr	cout
		pla
		rts
;
;=====================================================
; Set up the input vector to point to a file read
; subroutine.
;
setInputFile    lda	#getNextFileByte&$ff
		sta     inputVector
		lda	#getNextFileByte/256
		sta	inputVector+1
;
; Clear counts and offsets so the next read will
; cause the file to be read.
;
		lda	#0
		sta	diskBufOffset
		sta	diskBufLength
		rts
;
;=====================================================
; This is a helper function used for redirected I/O.
; It simply does a jump through the input vector
; pointer to get the next input character.
;
redirectedGetch	jmp	(inputVector)
;
;=====================================================
; This gets the next byte from an open disk file.  If
; there are no more bytes left, this returns C set.
; Else, C is clear and A contains the character.
;
getNextFileByte ldx 	diskBufOffset
		cpx	diskBufLength
		bne	hasdata		;branch if still data
;
; There is no data left in the buffer, so read a
; block from the SD system.
;
		lda	#BUFFER_SIZE
		ldx	#buffer>>8
		ldy	#buffer&$ff
		jsr	DiskRead
		bcs	getNextEof
;
; A contains the number of bytes actually read.
;
		sta	diskBufLength	;save length
		cmp	#0		;shouldn't happen
		beq	getNextEof
;
		ldx	#0
hasdata		lda	buffer,x
		inx
		stx	diskBufOffset
		clc
		rts
;
getNextEof	lda	#0
		sta	diskBufOffset
		sta	diskBufLength
		sec
		rts
		page
;
;=====================================================
; Type the contents of an SD file to console.
;
typeFile	jsr	putsil
		db	"Enter filename to type: ",0
		jsr	getFileName
		ldy	#filename&$ff
		ldx	#filename/256
;		jsr	xParInit
		jsr	DiskOpenRead
		bcc	typeFile1	;opened ok
;
		jsr	putsil
		db	CR,LF
		db	"Failed to open file"
		db	CR,LF,0
		jmp	prompt
;
; Now just keep reading in bytes and displaying them.
;
typeFile1	jsr	setInputFile	;reading from file
typeFileLoop	jsr	getNextFileByte
		bcs	typeEof
		jsr	cout	;display character
		jmp	typeFileLoop
;
typeEof		jsr	DiskClose
		jmp	prompt
;
;=====================================================
; This flushes any data remaining in the disk buffer
; and then closes the file.
;
CloseOutFile	lda	diskBufOffset
		beq	closeonly
		ldx	#buffer>>8
		ldy	#buffer&$ff
		jsr	DiskWrite
;
closeonly	jmp	DiskClose
;
		include	"io.asm"
		include	"acia.asm"
	if SD_ENABLED
		include	"parproto.inc"
		include	"pario.asm"
		include "diskfunc.asm"
	endif
;
;*********************************************************
; Handlers for the interrupts.  Basiclly just jump 
; through the vectors and hope they are set up properly.
;
HandleNMI	jmp	(NMIvec)
HandleIRQ	jmp	(IRQvec)
;
;*********************************************************
; Default handler.  Save the state of the machine for
; debugging.  This is taken from the KIM monitor SAVE
; routine.
;
DefaultNMI
DefaultIRQ	sta	SaveA
		pla
		sta	SaveC
		pla
		sta	SavePC
		pla
		sta	SavePC+1
		sty	SaveY
		stx	SaveX
		tsx
		stx	SaveSP
		jsr	DumpRegisters
		jsr	crlf
		jmp	WARM
;
;*********************************************************
; 6502 vectors
;
		org	$fffa
		dw	HandleNMI
		dw	RESET
		dw	HandleIRQ

