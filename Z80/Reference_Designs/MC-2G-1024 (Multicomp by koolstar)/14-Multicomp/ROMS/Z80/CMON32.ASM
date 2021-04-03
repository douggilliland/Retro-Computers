;==============================================================================
; Contents of this file are based on the work of Grant Searle who
; holds copyright on the original.
;    (http://searle.hostei.com/grant/index.html
; 
; HEXload routine from Joel Owens.
; Unpack routine from Dr.Dobb's Journal #60 october 1981
; DectoBinary routine from David E. Cortesi
; 
; Author: Rienk H. Koolstra
; Monitor size - 2 kilobyte (0000h -07D0h)
;
; You have permission to use this for NON COMMERCIAL USE ONLY
; If you wish to use it elsewhere, please include an acknowledgement
; to the contributors.
;==============================================================================

; This Monitor is intended for the FPGA multicomputer by Grant Searle
;              http://searle.hostei.com/grant/index.html

; General Equates
;-------------------------------------------------------------

CR		equ 0Dh
LF		equ 0Ah
ESC		equ 1Bh
CTRLC		equ 'C'-40h
BS		equ 08h
TAB		equ 'I'-40h
CLS		equ 0Ch

; 8 MB volume parameters
LOADADDR	equ 0BFFEh	; CP/M load address location in buffer
BUFFADDR	equ 08000h	; transferbufer
FMTSECS		equ 32		; Number of 512 sectors to be formatted
MAXVOLUME	equ 254		; depends on SD card size

; ACIA data
RTS_HIGH	equ 0D5h
RTS_LOW		equ 095h

ACIA0_C		EQU 080h
ACIA0_D		EQU 081h
ACIA0_B		EQU 07Bh	; Baud rate port
ACIA1_C		EQU 082h
ACIA1_D		EQU 083h
ACIA1_B		EQU 07Ch	; Baud rate port

B1200		EQU 0
B2400		EQU 1
B4800		EQU 2
B9600		EQU 3
B19200		EQU 4
B38400		EQU 5
B57600		EQU 6
B115200		EQU 7

; SD disk data
SD_DATA		equ 088h
SD_CONTROL	equ 089h
SD_STATUS	equ 089h
SD_LBA0		equ 08Ah
SD_LBA1		equ 08Bh
SD_LBA2		equ 08Ch

MMUSELECT	equ 0F8h
MMUFRAME	equ 0FDh


	org	800h		; variables in RAM

aciaCtl		ds 1		; active acia ctl port
dmaAddr		ds 2
volume		ds 1		; volume and sector cover all the 
sector		ds 1		; needs for the monitor. with sector 
volumeID	ds 33		; 0-255 (8 tracks)
lastMR:		ds 2		; last used address reference
cbuff		ds 32		; command line buffer
stackSpace	ds 32
STACK		equ $		; Stack top

;-------------------------------------------------------------
;		 START OF MONITOR ROM
;-------------------------------------------------------------
start		equ 0000h
mon:		org	start	; MONITOR ROM RESET VECTOR


;  RST 00 - reset / poweron
;-------------------------------------------------------------
reset:
rst00h:	di			; Disable Interrupts
	jp init
	ds start+08h-$


;  RST 08 h - console output
;-------------------------------------------------------------
rst08h:	jr conout
	ds start+10h-$


;  RST 10h - CONIN receice character from default console
;-------------------------------------------------------------
rst10h:
conin:	push BC			; we use C for IN/OUTput
	ld A,(aciaCtl)
	ld C,A
conin1:	in A,(C)		; Status byte D1=TX Buff Empty, D0=RX char ready
	and 01h			; bit 0 set is data ready
	jr z, conin1		; wait for data
	inc C			; select acia data
	in A,(C)
	pop BC
	ret

; CONOUT - send character to default console
;-------------------------------------------------------------
conout:	PUSH BC ; we use C for in/output
	PUSH AF ; Store character
	LD A,(aciaCtl)
	LD C,A
conout1:			; continued from rst 08h
	in	A,(C)		; Status byte D1=TX Buff Empty, D0=RX char ready
	and	0Ah		; bits n_cts and TX busy
	jr	z,conout1	; either no terminal or TX ready contiunues
	inc	C		; select acia data
	pop	AF		; character to send
	out	(C),A
	pop	BC
	ret



;  INIT - initialise hardware and start main loop
;-------------------------------------------------------------
INITTXT:
	db CLS,'Press [SPACE] to activate console',CR,LF,0
SIGNON:	db CR,LF,'Z80 Multicomp Multiboot Monitor v3.2',CR,LF
	db 'based on design by G. Searle',CR,LF,LF
	db '  press ? for help',CR,LF,LF,0


init:	ld b,4			; all 4 frames
	xor a			; start at...
nextBlock:
	out (MMUSELECT),A	; first reset mmu
	out (MMUFRAME),A 	; make sure logical SRAM addresses
	inc a			; match the physical ones
	djnz nextBlock

	ld SP,STACK		; before the Stack Pointer is set
	ld A,RTS_LOW		; acia configuration byte
	out (ACIA0_C),A		; Initialise ACIA0
	out (ACIA1_C),A		; Initialise ACIA1

;	LD A,B115200		; select baudrate
;	OUT (ACIA0_B),A
;	OUT (ACIA1_B),A	

	ld A,ACIA0_C
	ld (aciaCtl),A
	ld HL,INITTXT
	push HL
	call print
	ld A,ACIA1_C
	ld (aciaCtl),A
	pop HL
	call print

	; wait until Space is in one of the buffers to determine the active console

	LD B,B115200		; select baudrate
waitForSpace:
	LD A,B
	inc A
	and 07h
	ld B,A
	OUT (ACIA0_B),A
	OUT (ACIA1_B),A	
	ld A,ACIA0_C
	ld C,A
	in A,(C)		; Status byte
	and 01h			; Z flag set if no char
	jr nz,dataIn
	inc C
	inc C			; Port B
	in A,(C)		; Status byte
	and 01h			; Z flag set if no char
	jr z,waitForSpace
dataIn:	inc C			; data port
	in A,(C)
	cp ' '
	jr nz,waitForSpace

	; Space was pressed
	dec C			; back to control port
	ld A,C
	ld (aciaCtl),A		; either 80h or 82h

	; aciaCtl is now set to the channel where SPACE was pressed

	; clear message on both consoles
	ld A,CLS
	out (ACIA0_D),A		; can't use aciaCtl because we don't
	out (ACIA1_D),A		; know what it is set to

	ld HL,SIGNON		; Print SIGNON message
	call print
	jp main			; done with init jump to mail loop



; PRINT - display a zero-terminated string on console
;-------------------------------------------------------------
print:	ld A,(HL)		; Get character
	and 7Fh			; strip high bit and set flags
	ret z			; Return on terminator
	rst 08h			; Print it
	inc HL			; Next Character
	jr print		; Continue until 00h



crlf:	ld A,CR
	call conout
	ld A,LF
	jp conout



; GETARGS - extract the volume number and a DMA address from the command string
;-------------------------------------------------------------
volerr:	db CR,LF,'Bad Volumenumber',0
getargs:
	call getdec		; get volume in DE
	ld A,D
	or A
	jr nz, badvol		; number way too big
	ld A,E
	dec A			; from base 1 to base 0
	cp MAXVOLUME
	jr nc,badvol		; number just too big or '0'
	inc A
	ld (volume),A		; store for client to use
	ld A,(HL)		; is the next character a ','
	cp ','
	ret nz			; a second argument?
	inc HL			; next character in string
	call gethex		; get the new DMA address
	ld A,D
	or E
	ret z			; empty string
	ld (dmaAddr),DE		; overwrite default
	ret ; getargs
badvol: ld HL, volerr
	call print
	pop HL			; pop calling subroutine
	ret			; return to main



;ISTRING - user adds arguments to the command string
;-------------------------------------------------------------
istring:
cloop:	call getchr		; get an U/C character
	cp CR			; CR - go process the command
	ret z
	cp BS			; BS - erase previous character
	jr z,erase
	cp CTRLC		; Ctrl-C
	jr z,escape
	cp ESC			; ESC 
	jr z,escape
	cp 'F'+1		; filter non desirables...
	jr nc,cloop		; all above F is rejected
	cp 'A'
	jr nc,charok		; A-F is ok
	cp '9'+1
	jr nc,cloop		; all over 9 is rejected
	cp '0'
	jr nc,charok		; 0-9 is ok
	cp ','			; as is ',' the argument separator
	jr nz,cloop		; the rest is rejected
charok:	ld (HL),A		; store accepted input
	call conout		; show on screen
	inc B			; increment counters
	inc HL
	ld (HL),0		; set end of string
	ld A,B
	cp 32
	jr z,erase		; string too long
	jr cloop

; erase last entry
erastr: db 08,' ',08,0		; BS SP BS
erase:	push HL
	ld HL,erastr		; adjust display
	call print
	pop HL
	dec B			; last character entered
	jr z,escend		; wiping entire string
	dec HL			; step back in string
	ld (HL),0		; erase charcter
	jr cloop 		; go back



; ESCAPE - erase all user input and start over
;-------------------------------------------------------------
wipe:	db CR,'aborted                         ',CR,0
escape:	ld HL,wipe		; clean up entry, start over
	call print
escend:	pop HL			; return to main
	ret ; wipe



; GETCHR - get filtered user input converted to upper case
;-------------------------------------------------------------
getchr: call conin
ucase:	cp "A"-1	; less than "A"?
	ret c
	cp 'z'+1	; greater than "z"
	ret nc
	and 5FH		; make all ALPHA upper case
	ret 



; GETHEX - zero terminated string is converted from ascii HEX to binary in DE
;-------------------------------------------------------------
gethex: ld DE,0
	push DE
gloop:	ld A,(HL)
	sub '0'
	jr c,gdone		; either a '0' or a ','
	cp 0Ah
	jr c,noletter
	sub 7
noletter:
	ld E,A
	ld D,0
	ex (SP),HL
	add HL,HL		; previous result
	add HL,HL		; times 16
	add HL,HL
	add HL,HL
	add HL,DE		; add next entry
	ex (SP),HL
	inc HL			; go for next digit
	jp gloop
gdone:	pop DE			; reg de holds result
	ret ; gethex



; GETDEC - [0|,] terminated string is converted from ascii decimal to binary in DE
;-------------------------------------------------------------
getdec:	ld DE,0			; result in DE
	push DE
dloop:	ld a,(HL)		; get character
	cp 'A'
	jr nc,doops		; number was hex.
	sub '0'
	jr c,ddone		; is it less than '0'? then were done
	ld E,A			; store in DE
	ex (SP),HL		; get result from stack
	ld B,H			; store it in bc
	ld C,L
	add HL,HL		; previous result times 10
	add HL,HL
	add HL,BC		; times 5
	add HL,HL		; times 2 (makes 10)
	add HL,DE		; add next digit
	ex (SP),HL		; back on stack
	inc HL			; go for next digit
	jr dloop
ddone:	pop DE			; reg de holds result
	ret
doops:	pop DE			; number out of range
	ld DE,0FF00h		; returns bogus result
	ret ; getdec



;  PRTHL - print HL or  LBYTE - print A  on console
;-------------------------------------------------------------
prtHL:	ld A,H
	call lByte
	ld A,L
lByte:	push AF
	rrca
	rrca
	rrca
	rrca
	call s2
	pop AF
s2:	call conv
	jp conout



;  CONV - convert HEX to ASCII
;-------------------------------------------------------------
conv:	and 0Fh
	add A,90h
	daa
	adc A,40h
	daa
	ret



;-------------------------------------------------------------
;  MAIN - Main command loop
;-------------------------------------------------------------
PROMPT:	db CR,LF,'> ',0
nocmd:	db CR,LF,'Unknown Command',0

main:
	ld HL,main		; Save entry point for Monitor
	push HL			; This is the return address
	ld HL,0
	ld (dmaAddr),HL		; set default load address

	ld HL,PROMPT		; Entry point for Monitor, Normal
	call print		; Get a "> "

main1:	call getchr		; Get a character from the input port
	cp ' '			; <spc> or less?
	jr c,main1		; Go back

	; simple one character commands with immediate action
	; no echo
	cp ':'			; ":"?
	jp z,load		; First character of a HEX load
	cp '?'			; print instructions
	jp z,help
;	cp 'R'			; reset
;	jp z,reset

	; next, multi argument commands, execute on return
	ld HL,cbuff		; command buffer
	ld (HL),A		; store command
	inc HL			; next position
	ld (HL),0		; end of string
	ld B,1			; init counter
	call conout		; show command
	call istring		; get arguments
	dec HL
	ld A,(HL)
	cp ','			; last entry a comma?
	jr nz,main2
	ld (HL),0		; then make it a '0'
main2:	ld HL,cbuff		; reset pointer in command string
	ld A,(HL)		; get command 
	inc HL
	cp 'R'			; if 'R' goto Rxxxx
	jp z,goto
	cp 'S'			; if 'S' System start Sddd
	jp z,sysrun
	cp 'I'			; if 'I' Format Iddd
	jp z,format
	cp 'G'			; if 'G' getsys Gddd
	jp z,getsys
	cp 'P'			; if 'P' putsys Pddd[,xxxx]
	jp z,putsys
	cp 'D'			; if 'D' dump Dxxxx[,yyyy]
	jp z,dump
	cp 'C'			; if 'C' change Cxxxx,dd[,dd,dd]
	jp z,change
	ld HL,nocmd		; if none of these, express confusion
	call print
	ret ; to main



;  DUMP - display memory Dxxxx[,yyyy]
;-------------------------------------------------------------
dSep4:	db TAB,'  '
dsep2:	db '  ',0
dump:	ld DE,(lastMR)		; retrieve last address used by D or C command
	inc DE			; use next address
	xor A
	cp (HL)
	jr z,dskip		; if no address given, use last one
	call gethex		; get hex entry in DE
dskip:	ld A,E
	and 0F0h		; start at xxx0 boundary
	ld E,A
	push DE			; start address on stack
	push HL
	ld HL,07Fh		; default display 8 lines
	add HL,DE
	jr nc,dendok		; don't fold back to 0000h
	ld HL,0FFFFh
dendok:	ld (lastMR),HL		; save for later use
	ex DE,HL		; DE now valid endaddress
	pop HL
	ld A,(HL)
	cp ','			; if no second argument
	jr nz,darg2		; DE stays DE
	inc HL			; if not
	call gethex		; get new DE
darg2:	pop HL			; start address now in HL
dline:	call crlf		; start line
	push HL			; save for ascii output
	call prtHL		; print address
	ld A,' '		; extra space
	call conout
	ld b,16			; 16 bytes
dbyte:	ld A,' '		; extra space
	call conout
	ld a,(hl)
	call lByte		; print byte
	inc HL			; next byte
	djnz dbyte		; repeat
	ld hl,dSep4		; print separator
	call print
	pop hl			; het start of line back
	ld B,16			; now the same in ascii
t11:	ld A,(HL)		; get byte
	and 7Fh
	cp ' ' 			; don't print control characters
	jr nc,t33
t22:	ld a,'.'		; but print something
t33:	cp 07Fh			; also skip DEL and higher
	jr nc,t22
	call conout
	inc HL			; next byte
	djnz t11		; get next byte
	ld A,L			; pointer overflow?
	or H
	ret z			; the quit
	ld A,E			; compare DE and HL 
	sub L			; DE - HL
	ld A,D
	sbc A,H			; carry flag set if D+carry>H
	ret c
	jr dline



;  CHANGE - Change memory addresses : Cxxxx,dd,dd,dd,dd
;-------------------------------------------------------------
change:
	call gethex	; get DE
	ex DE,HL
chnext:
	ld (lastMR),HL	; get last address used by D or C command
	call crlf
	call prtHL	; show address
	ld A,' '
	call conout	; a space
	ld A,(HL)
	ld E,A
	call lByte	; memory content
	ld A,' '
	call conout	; another space
	ld HL,cbuff+4	; command buffer
	xor A
	ld (HL),A	; start with end of string
	ld B,4		; lengthcounter 
	call istring	; get new byte (esc ends)
	ld HL,cbuff+4
	ld A,(HL)
	cp 0		; empty string
	jr z, chskip	; skip change
	cp ','
	ret z		; comma quits
	call gethex	; new byte in DE (D is discarded)
chskip:	ld HL,(lastMR)
	ld (HL),E
	inc HL
	jr chnext





;-------------------------------------------------------------
; LOAD - load Intel Hex format file from the console.
; [Intel Hex Format is:
; 1) Colon (Frame 0)
; 2) Record Length Field (Frames 1 and 2)
; 3) Load Address Field (Frames 3,4,5,6)
; 4) Record Type Field (Frames 7 and 8)
; 5) Data Field (Frames 9 to 9+2*(Record Length)-1
; 6) Checksum Field - Sum of all byte values from Record Length to and 
; including Checksum Field = 0 ]
;-------------------------------------------------------------	
chksumerr:
	db 'Checksum error',0
ldetxt:	db 'HEXload Complete',0

load:	ld E,0		; First two Characters is the Record Length Field
	call get2	; Get us two characters into BC, convert it to a byte <A>
	ld D,A		; Load Record Length count into D
	call get2	; Get next two characters, Memory Load Address <H>
	ld H,A		; put value in H register.
	call get2	; Get next two characters, Memory Load Address <L>
	ld L,A		; put value in L register.
	call get2	; Get next two characters, Record Field Type
	cp 01		; Record Field Type 00 is Data, 01 is End of File
	jr nz,load2	; Must be the end of that file
	call get2	; Get next two characters, assemble into byte
	ld A,E		; Recall the Checksum byte
	and A		; Is it Zero?
	jr z,load00	; Print footer reached message
	jr loaderr	; Checksums don't add up, Error out

load2:	ld A,D		; Retrieve line character counter	
	and A		; Are we done with this line?
	jr z,load3	; Get two more ascii characters, build a byte and checksum
	call get2	; Get next two chars, convert to byte in A, checksum it
	ld (HL),A	; Move converted byte in A to memory location
	inc HL		; Increment pointer to next memory location	
	ld A,'.'	; Print out a "." for every byte loaded
	rst 08h	;
	dec D		; Decrement line character counter
	jr load2	; and keep loading into memory until line is complete
	
load3:	call get2	; Get two chars, build byte and checksum
	ld A,E		; Check the checksum value
	and A		; Is it zero?
	ret z

loaderr:
	ld HL,chksumerr	; Get "Checksum Error" message
	jp print	; Print Message from (HL) and terminate the load

load00: ld HL,ldetxt	; Print load complete message
	jp print

;-------------------------------------------------------------
; GET2 - Gets two ASCII characters from the console (assuming them to be HEX 0-9 A-F)
; Moves them into B and C, converts them into a byte value in A and updates a
; Checksum value in E
;-------------------------------------------------------------
get2:	rst 10h		; Get us a valid character to work with
	ld B,A		; Load it in B
	rst 10h		; Get us another character
	ld C,A		; load it in C
bctoa:	ld A,B		; Move the hi order byte to A
	sub $30		; Take it down from Ascii
	cp $0a		; Are we in the 0-9 range here?
	jr c,bctoa1	; If so, get the next nybble
	sub $07		; But if A-F, take it down some more
bctoa1:	rlca		; Rotate the nybble from low to high
	rlca		; One bit at a time
	rlca		; Until we
	rlca		; Get there with it
	ld B,A		; Save the converted high nybble
	ld A,C		; Now get the low order byte
	sub '0'		; Convert it down from Ascii
	cp 0Ah		; 0-9 at this point?
	jr c,bctoa2	; Good enough then, but
	sub 07h		; Take off 7 more if it's A-F
bctoa2:	add A,B		; Add in the high order nybble
	ld C,A		; Build the checksum
	ld A,E
	sub C		; The checksum should always equal zero when checked
	ld E,A		; Save the checksum back where it came from
	ld A,C		; Retrieve the byte and go back
	ret



; HELP - display help message
;-------------------------------------------------------------
HLPTXT:	db CR,LF
	db '  Available Commands:',CR,LF,LF
;	db '  R			Reset',CR,LF
	db '  :ccxxxxiibbbbbb	Load Intel-Hex file record',CR,LF
	db '  Rxxxx		Run from address xxxx',CR,LF
	db '  Sddd		System boot',CR,LF
	db '  Iddd		Init: Format directory',CR,LF
	db '  Pddd[,xxxx]	PutSys: write system image[,loadaddress]',CR,LF
	db '		(No address: re-use last loadaddress)',CR,LF
	db '  Gddd[,xxxx]	GetSys: load system track',CR,LF,LF
	db '  Dxxxx[,yyyy]	Dump memory from xxxx [,to yyyy]',CR,LF
	db '		D (no address) shows next block',CR,LF
	db '  Cxxxx		Change/show memory at xxxx',CR,LF
	db '		CR advances "," quits',CR,LF,LF
	db '  ddd is a decimal volume number,',CR,LF
	db '  xxxx, yyyy is a hexadecimal address.',CR,LF
	db '  Leading zeros may be omitted.',CR,LF
	db '  ESC or ^C aborts.',CR,LF,0

help:	ld HL,HLPTXT		; Print Help message
	jp print ; end help



; GOTO - jump to address
;-------------------------------------------------------------
goto:	call gethex		; get hex entry in DE
	ex DE,HL
	jp (HL)



; SYSRUN - boot (load and run) from system track of selected volume
;-------------------------------------------------------------
sysrun:	call getargs		; get volume and loadaddress
	call setDskIO
	call readsys		; read disk contents to loadaddress
	call getlen		; find loadaddress and length
	ldir			; move buffer to image
	ld A,(aciaCtl)		; message bootdisk and console to 
	and 02h			; main program - 2 methods, on stack
	rrca			; and in alternate BC registers
	xor 01h			; convert to iobyte...
	push AF			; ...to save bytes in BIOS
	ld C,A
	ld A,(volume)		; tell BIOS which is ...
	push AF			; ...the active bootvolume
	ld B,A
	exx			; also make b'=bootdisk, c'=console
	ld HL,(0FFFEh)		; pop and run location
	jp (HL)			; bye bye



; GETSYS - load data from system track of selected volume to DMA address
;-------------------------------------------------------------
GETTXT:	db CR,LF,'System Read OK',0
getsys:	call getargs
	call setDskIO
	call readsys
	call getlen	; find loadaddress and length
	ldir		; write buffer to image
	ld HL,GETTXT
	jp print ; end getsys



; PUTSYS - write data from DMA address to system track of selected volume
;-------------------------------------------------------------
PTSYSTXT:
	db CR,LF,'System Write OK',0
putsys:	call getargs
	ld DE,(dmaAddr)
	xor A			; set to zero
	or D			; any bits in D
	or E			; and in E
	jr z,p1			; no loadaddres specified: just write buffer
	ld (LOADADDR),DE	; put loadaddres on top of buffer
	call getlen		; get buffer start and length
	ex DE,HL		; swap source/destination
	ldir			; fill buffer with image
p1:	call setDskIO
	call writesys
	ld HL,PTSYSTXT
	jp print ; end putsys



; FORMAT - write empty directory to selected volume and add a volume label
;-------------------------------------------------------------
volImg:	db 0,'  Volume000'
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0E5h
FMTXT:	db CR,LF,'Format OK - ',0
format:	call getargs		; if a loadaddress was entered we ignore it
	ld HL,volImg		; prepare the volumelabel
	ld DE,volumeID		; from ROM to RAM
	ld BC,33
	ldir
	; convert volume into decimal again
	ld A,(volume)
	ld L,A
;	inc L			; base 1
	ld B,8			; b = count (8 bits to go)
	ld DE,0			; result, de=zero
unpack:	rl L			; unpack hex number in L to bcd in DE
	ld A,E			; rotate next highest bit in carry flag
	adc A,A			; shift and add next high bit of L
	daa			; adjust for BCD
	ld E,A
	ld A,D
	adc A,A			; shift and add carry of previous operation
	daa			; adjust for BCD
	ld D,A
	djnz unpack		; do  all 8 bits
	;insert volume in label
	ld HL,STACK		; find a free byte
	ld (HL),E		; last two BCD digits
	ld A,D			; first BCD digit 
	ld B,3			; do all three
	ld DE,volumeID+9	; index to labeltext
	add a,'0'		; make ascii
labidx:	ld (DE),A		; store in label
	rld			; rotate next digit into A
	inc DE			; increment index
	djnz labidx		; all three of them
	ld HL,volumeID+9	; index to labeltext
	set 7,(HL)		; make read-only

	call fmtsys		; write to disk

	ld HL,FMTXT
	call print
	ld HL,volumeID+1	; display the volumelabel
	jp print ; end format



; READSYS - perform I/O for physical sytem track read
;-------------------------------------------------------------
readsys:
	ld D,2
	call setLBAddr
	xor A			; 00 = Read block
	out (SD_CONTROL),A

readbyte:
	in A,(SD_STATUS)
	cp 0E0h			; output buffer has data ready
	jr nz,readbyte		; wait for ready
	in A,(SD_DATA)		; read next databyte from disk
	ld (HL),A		; store it
	inc HL			; increase index
	djnz readbyte		; do 256 times
	dec D			; do twice for 512 bytes
	jr nz,readbyte
	ld A,(sector)		; next sector to read
	inc A
	ld (sector),A
	dec E			; last sector yet?
	jr nz,readsys		; if not do again
	ret ; readsys



; WRITESYS - perform I/O for physical system track write
;-------------------------------------------------------------
writesys:
	ld D,2			; 2 x 256 bytes to read
	call setLBAddr
	ld A,1			; 01 = Write block
	out (SD_CONTROL),A

writebyte:
	in A,(SD_STATUS)
	cp 0A0h			; output buffer has data ready
	jr nz,writebyte		; wait for ready
	ld A,(HL)		; next databyte
	out (SD_DATA),A		; write to disk
	inc HL			; increase index
	djnz writebyte		; do 256 times
	dec D			; do twice for 512 bytes
	jr nz,writebyte

	ld A,(sector)		; next sector to read
	inc A
	ld (sector),a
	dec E			; last sector yet?
	jr nz,writesys		; if not do again

	ret ; writesys



; FMTSYS - perform I/O for the physical format
;-------------------------------------------------------------
fmtsys:
	ld A,32			; startsector
	ld (sector),A
	ld B,0			; count in b (0 is 256 loops)
	ld HL,volumeID		; source Address

fmtsec:	ld D,2			; 2 x 256 bytes to write
	call setLBAddr
	ld A,1			; 01 = Write block
	out (SD_CONTROL),A

fmtbyte:
	in A,(SD_STATUS)
	cp 0A0h			; write buffer empty?
	jr nz,fmtbyte
	ld A,(HL)		; first het label, 
	out (SD_DATA),A		; then
	cp 0E5h			; if label is done
	jr z,fskip		; stop incrementing
	inc HL
fskip:	djnz fmtbyte		; B = 0?
	dec D			; do twice for 512 bytes
	jr nz,fmtbyte		; do second half

	ld A,(sector)		; next sector to format
	inc A
	ld (sector),a		; stop if next is last
	cp FMTSECS+32
	jr nz,fmtsec		; if not do next sector

	ret ; fmtsys


; getlen sets the length of the CP/M image in BC, 
;	destination address in DE and source address in HL
getlen:
	ld DE,(LOADADDR)
	ld A,D		; calculate 10000h-loadaddress
	neg
	ld B,A
	ld A,E
	neg
	ld C,A
	ld HL,BUFFADDR
	ret


; SETDSKIO - prepare SD card for physical read/write block I/O
;-------------------------------------------------------------
setDskIO:
	xor A		; a is startsector
	ld (sector),A
	ld HL,BUFFADDR	; transfer buffer address
	ld E,32		; read/write the whole systemtrack
	ld A,E
	ld B,0		; output block counter
	ret ;  setDskIO
	

; SETLBADR - convert volume and sector to Logic Block Address for the first 8 tracks
;-------------------------------------------------------------
setLBAddr:
	push BC
	push AF

	ld A,(volume)	; get the physical volume
	rrc A		; move bits to line up with 
	rrc A		; LBA framing
	ld C,A		; save this part for LBA1
	and 3Fh		; mask off the lower 6 bits
	out (SD_LBA2),A	; and set the third byte 
	ld A,C		; the rotated physical volume
	and 0C0h	; top 2 bits for LBA1
	out (SD_LBA1),A	; second LBA byte set
lba1:	in A,(SD_STATUS)
	cp 080h		; disk ready
	jr nz,lba1
	ld A,(sector)	; sector includes first 8 tracks
	out (SD_LBA0),A	; first LBA byte set

	pop AF
	pop BC
	ret

	end
