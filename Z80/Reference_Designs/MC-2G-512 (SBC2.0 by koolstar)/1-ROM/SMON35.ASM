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
;
; You have permission to use this for NON COMMERCIAL USE ONLY
; If you wish to use it elsewhere, please include an acknowledgement
; to the contributors.
;==============================================================================

; This Monitor is intended for the Z80 Single Board Computer by Grant Searle
;              http://searle.hostei.com/grant/index.html
;
; I/O designation: 	SIO: Port 00-04H, CF-Card: Port 10-18H, 
;			Banked MEM: Port 28H, SRAM select: Port 30H.

; Disk volumes are 8MB in size and numbered 1-254. Volume 0 is not used, to 
; make room for a partition table (utilize anything above 2GB).
; system images reside on track 0 of every volume. The complete track (16 kB) 
; is loaded in memory 8000h-BFFFh. Address BFFE will hold the CP/M 
; loadaddress. Writing a system track goes in reverse.


; General Equates
;-------------------------------------------------------------
BKSP		equ 08h		; Back space
TAB		equ 09h		; Tab
LF		equ 0Ah		; Line feed
CS		equ 0Ch		; Clear screen
CR		equ 0Dh		; Carriage return
CTRLC		equ 'C'-40h	; Control "C"
CTRLG		equ 'G'-40h	; Control "G"
CTRLO		equ 'O'-40h	; Control "O"
CTRLQ		equ 'Q'-40h	; Control "Q"
CTRLR		equ 'R'-40h	; Control "R"
CTRLS		equ 'S'-40h	; Control "S"
CTRLU		equ 'U'-40h	; Control "U"
ESC		equ 1Bh		; Escape
DEL		equ 7Fh		; Delete


;SIO registers
SIOA_D		equ 00h
SIOB_D		equ 01h
SIOA_C		equ 02h
SIOB_C		equ 03h

; SIO features
RTS_HIGH	equ 0E8H
RTS_LOW		equ 0EAH


; CF registers
CF_DATA		equ 10h
CF_FEATURES	equ 11h
CF_ERROR	equ 11h
CF_SECCNT	equ 12h		; sector count
CF_SECTOR	equ 13h
CF_CYL_LOW	equ 14h
CF_CYL_HI	equ 15h
CF_HEAD		equ 16h
CF_STAT		equ 17h		; status 
CF_CMD		equ 17h		; command
CF_LBA0		equ 13h
CF_LBA1		equ 14h
CF_LBA2		equ 15h
CF_LBA3		equ 16h

;CF Features
CF_8BIT		equ 1
CF_NOCACHE	equ 082H
;CF Commands
CF_READ_SEC	equ 020H
CF_WRITE_SEC	equ 030H
CF_SET_FEAT	equ 0EFH

;Banked Memory Register
BM_CTL		equ 030H


; disk parameters
LOADADDR	equ 0BFFEh	; CP/M load address location in buffer
BUFFADDR	equ 08000h	; transferbufer
DIRSIZE		equ 32		; Number of 512 sectors in DIR
MAXVOLUME	equ 254

CBUFSIZE	equ 20H	; do not change without changing code too
CBUFHIGH	equ 10H
CBUFLOW		equ 6


	org	4000h		; variables space

primaryIO	ds 1
sbufferA:			; SIO-A. Keep these adresses together
sUseA:		ds 1		; number of characters in buffer 
soIdxA:		ds 1		; location of last character read
siIdxA:		ds 1		; location of last character written
sSIOA:		ds 1		; data port address
sBufA:		ds CBUFSIZE

sbufferB			; SIO-B. Keep these adresses together
sUseB:		ds 1		; number of characters in buffer 
soIdxB:		ds 1		; location of last character read
siIdxB:		ds 1		; location of last character written
sSIOB:		ds 1		; data port address
sBufB:		ds CBUFSIZE
stackend:	ds 32
stack:		equ $		; Stack top


sector		ds 1
dmaAddr		ds 2

volume		ds 1
volumeID	ds 32
lastMR:		ds 2		; last used address reference
cbuff:		ds 32		; command buffer

;------------------------------------------------------------------------------
;			 START OF MONITOR ROM
;------------------------------------------------------------------------------

MON:	org 0000h	; MONITOR ROM RESET VECTOR
;------------------------------------------------------------------------------
; Reset
;------------------------------------------------------------------------------
reset:
RST00:	di		; Disable Interrupts
	jp init		; Initialize Hardware and go
	ds 08h-$

;------------------------------------------------------------------------------
; TX a character over RS232 wait for TXDONE first.
;------------------------------------------------------------------------------
RST08:	jp conout
	ds 10h-$

;------------------------------------------------------------------------------
; RX a character from buffer wait until char ready.
;------------------------------------------------------------------------------
RST10:	jp conin
	ds 18h-$

;------------------------------------------------------------------------------
; rst 18 - Check input buffer status
; Check if there is a character in the input buffer
; Use the "primaryio" flag to determine which port to check.
;------------------------------------------------------------------------------
CKINCHAR:
	ld A,(primaryIO)
	cp 0
	jr nz,ckincharB

ckincharA:

	ld A,(sUseA)
	cp 0h
	ret

ckincharB:

	ld A,(sUseB)
	cp 0h
	ret

;------------------------------------------------------------------------------
;   interrupt vector table - needs to start on an even address
;------------------------------------------------------------------------------
	org (($+1)/2)*2
intvec:	equ $
	dw serialInt


;------------------------------------------------------------------------------
; Serial interrupt handlers
; Same interrupt called if either of the inputs receives a character
; so need to check the status of each SIO input.
;------------------------------------------------------------------------------

serialInt:
	di
	push HL
	push BC
	push DE
	push AF

	; check if there is a char in channel A
	; if not, there is a char in channel B
	xor A
	ld D,A
	out (SIOA_C),A
	in A,(SIOA_C)	; Statusdb D2=TX Buff Empty, D0=RX char ready
	rrca		; Rotates RX status into Carry Flag,
	jr nc, sintB

			; (HL)   = buffUse
			; (HL+1) = bufferoutpointer
			; (HL+2) = bufferinpointer
			; (HL+3) = dataport
			; HL+4   = start buffer
	ld HL,sbufferA	; buffer A
	jr sintAB
sintB:	ld HL,sbufferB	; Buffer B
sintAB:	push HL
	inc HL
	inc HL		; skip readindex
	inc (HL)	; increment write index
	res 5,(HL)	; fold at character 64, 32
	ld E,(HL)	; DE is now i6 bit write index 
	inc HL		; get dataport
	ld C,(HL)
	inc HL		; point to first location in buffer
	add HL,DE	; add write index
	in A,(C)	; get character from dataport
	ld (HL),A	; store character
	pop HL		; retrieve datause
	inc (HL)	; increment data use
	ld A,CBUFHIGH
	cp (HL) 	; check for enough buffer space left
	jr nc,RTSlo	; buffer full?
	ld B,RTS_HIGH
	call setRTS
RTSlo:	pop AF
	pop DE
	pop BC
	pop HL
	ei
	reti


;------------------------------------------------------------------------------
; Console input routine
; Use the "primaryio" flag to determine which input port to monitor.
;------------------------------------------------------------------------------
conin:
	push HL
	push BC
	push DE
	ld A,(primaryIO)
	cp 0
	jr nz,coninB

			; (HL)   = buffUse
			; (HL+1) = outpointer
			; (HL+2) = inpointer
			; (HL+3) = dataport
			; HL+4   = start buffer
	ld HL,sbufferA
	jr coninAB
coninB:	ld HL,sbufferB
coninAB:
	push HL
	xor A		; clear A
	ld D,A
ciWait	cp (HL)		; check character ready (HL is bufferuse)
	jr z,ciWait	; wait if not (this is where all time is spent)
	di
	inc HL
	inc (HL)	; increment read index
	res 5,(HL)	; fold at character 64, 32
	ld E,(HL)	; DE is now 16 bit index
	inc HL		; skip write index
	inc HL		; get dataport
	ld C,(HL)
	inc HL 		; start of buffer
	add HL,DE	; add read index
	ld A,(HL)	; this is the next available character
	pop HL		; retriev data use
	push AF		; store the input character
	dec (HL)	; one character less in buffer
	ld A,CBUFLOW	; check data left in buffer
	cp (HL)		; when low
	jr c,RTShi	; turn on RTS
	ld B,RTS_LOW
	call setRTS
RTShi:	pop AF		; the input character
	pop DE
	pop BC
	pop HL
	ei
	ret


setRTS:	inc C		; c -> control port
	inc C
	ld A,05h	; clear RTS signal
	out (C),A	; signal not RTS
	ld A,B
	out (C),A
	ret
;------------------------------------------------------------------------------
; Console output routine
; Use the "primaryio" flag to determine which output port to send a character.
;------------------------------------------------------------------------------

conout:
	push AF		; Store character
	ld A,(primaryIO)
	add A,SIOA_C
	ld C,A
conout1:
	xor A
	out (C),A
	in A,(C)	; Statusdb D2=TX Buff Empty, D0=RX char ready
	bit 2,A		; Set Zero flag if still transmitting character
	jr z,conout1	; Loop until SIO flag signals ready
	pop AF		; Retrieve character
	dec C
	dec C
	out (C),A	; output the character
	ret

;------------------------------------------------------------------------------
; Initialise hardware and start main loop
;------------------------------------------------------------------------------

SIOCMD:	db 00h,18h	; reset channel
	db 04h,0C4h	; set clock/64, 1 stopbit
	db 01h,18h	; set interrupt on all Rx characters
	db 03h,0E1h	; set Rx enable, 8 bits data
	db 05h,RTS_LOW	; set Tx enable, 8 bits data, DTR & RTS
	db 02h,intvec	; set interrupt vector (channel B only)

INITTXT:
	db CS
	db 'Press [SPACE] to activate console',CR,LF,0

SIGNON:	db 'Z80 SBC Monitor ROM version 3.05 (multiboot)',CR,LF
	db 'based on "CP/M on breadboard" by G. Searle',CR,LF,LF
	db '  press ? for help',CR,LF,0

init:

;	make sure physical and logical memory match 
;	before seting the stack pointer

	ld A,0		; set memory bank 0
	out (BM_CTL),A	; 

	ld SP,stack	; Initialize Stack

;	init serial buffers
	xor A
	ld HL,sbufferA
	ld B,3
ba:	ld (HL),a
	inc HL
	djnz ba
	ld (HL),SIOA_D
	ld HL,sbufferB
	ld B,3
bb:	ld (HL),a
	inc HL
	djnz bb
	ld (HL),SIOB_D

;	Initialise SIOs

	ld HL,SIOCMD	; initialize SIO A
	ld B,10		; SIO A uses the first 5 commands
	ld C,SIOA_C
	otir

	ld HL,SIOCMD	; initialize SIO B
	ld B,12		; SIO B uses all 6 commands
	ld C,SIOB_C	; including set interrupt vector
	otir

	; Initialize CF card
	call cfWait
	ld A,CF_8BIT		; Set IDE to be 8bit
	out (CF_FEATURES),A
	ld A,CF_SET_FEAT
	out (CF_CMD),A

	call cfWait
	ld A,CF_NOCACHE		; No write cache
	out (CF_FEATURES),A
	ld A,CF_SET_FEAT
	out (CF_CMD),A

	; interrupt vector in page 0
	ld A,00h
	ld I,A

	im 2
	ei

	; display the "Press space to start" message on both consoles
	ld A,00h
	ld (primaryIO),A
	ld HL,INITTXT
	call print
	ld A,01h
	ld (primaryIO),A
	ld HL,INITTXT
	call print

	; wait until space is in one of the buffers to determine the active console
waitForSpace:

	call ckincharA
	jr z,notInA
	ld A,00h
	ld (primaryIO),A
	call conin
	cp ' '
	jp nz, waitForSpace
	jr spacePressed

notInA:
	call ckincharB
	jr z,waitForSpace
	ld A,01h
	ld (primaryIO),A
	call conin
	cp ' '
	jp nz, waitForSpace

spacePressed:
	ld A,(primaryIO)
	push AF
	xor A
	ld (primaryIO),A
	ld A,CS
	call conout
	ld A,1
	ld (primaryIO),A
	ld A,CS
	call conout
	pop AF
	ld (primaryIO),A

	; primaryIO is now set to the channel where SPACE was pressed

	call crlf	; TXCRLF
	ld HL,SIGNON	; Print SIGNON message
	call print

	jp main		; done with init jump to mail loop



; PRINT - display a zero-terminated string on console
;-------------------------------------------------------------
print:
	ld A,(HL)	; Get character
	and 7Fh		; strip high bit and set flags
	ret z		; Return on terminator
	rst 08h		; Print it
	inc HL		; Next Character
	jr print	; Continue until 00h



; GETARGS - extract the volume number and a DMA address from the command string
;-------------------------------------------------------------
volerr:	db CR,LF,'Bad Volumenumber',0
getargs:
	call getdec	; get volume in DE
	ld A,D
	or A
	jr nz, badvol	; number way too big
	ld A,E
	dec A		; 0 not allowed, 1-MAXVOLUME should pass
	cp MAXVOLUME
	jr nc,badvol	; number just too big or '0'
	inc A		; start at numer 1
	ld (volume),A	; store for client to use
	ld A,(HL)	; is the next character a ','
	cp ','
	ret nz		; a second argument?
	inc HL		; next character in string
	call gethex	; get the new DMA address
	ld A,D
	or E
	ret z		; empty string
	ld (dmaAddr),DE	; overwrite default
	ret ; getargs
badvol: ld HL, volerr
	call print
	pop HL		; pop calling subroutine
	ret		; return to main



;ISTRING - user adds arguments to the command string
;-------------------------------------------------------------
istring:
cloop:	call getchr	; get an U/C character
	cp CR		; CR - go process the command
	ret z
	cp BKSP		; BS - erase previous character
	jr z,erase
	cp CTRLC	; Ctrl-C
	jr z,escape
	cp ESC		; ESC 
	jr z,escape
	cp 'F'+1	; filter non desirables...
	jr nc,cloop	; all above F is rejected
	cp 'A'
	jr nc,charok	; A-F is ok
	cp '9'+1
	jr nc,cloop	; all over 9 is rejected
	cp '0'
	jr nc,charok	; 0-9 is ok
	cp ','		; as is ',' the argument separator
	jr nz,cloop	; the rest is rejected
charok:	ld (HL),A	; store accepted input
	call conout	; show on screen
	inc B		; increment counters
	inc HL
	ld (HL),0	; set end of string
	ld A,B
	cp 32
	jr z,erase	; string too long
	jr cloop

; erase last entry
erastr: db 08,' ',08,0	; BS SP BS
erase:
	push HL
	ld HL,erastr	; adjust display
	call print
	pop HL
	dec B		; last character entered
	jr z,escend	; wiping entire string
	dec HL		; step back in string
	ld (HL),0	; erase charcter
	jr cloop 	; go back



; ESCAPE - erase all user input and start over
;-------------------------------------------------------------
wipe:	db CR,'aborted                         ',CR,0
escape:
	ld HL,wipe	; clean up entry, start over
	call print
escend:	pop HL		; return to main
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
gethex:
	ld DE,0
	push DE
gloop:	ld A,(HL)
	sub '0'
	jr c,gdone	; either a '0' or a ','
	cp 0Ah
	jr c,noletter
	sub 7
noletter:
	ld E,A
	ld D,0
	ex (SP),HL
	add HL,HL	; previous result
	add HL,HL	; times 16
	add HL,HL
	add HL,HL
	add HL,DE	; add next entry
	ex (SP),HL
	inc HL		; go for next digit
	jp gloop
gdone:	pop DE		; reg de holds result
	ret ; gethex



; GETDEC - [0|,] terminated string is converted from ascii decimal to binary in DE
;-------------------------------------------------------------
getdec:
	ld DE,0		; result in DE
	push DE
dloop:	ld a,(HL)	; get character
	cp 'A'
	jr nc,doops	; number was hex.
	sub '0'
	jr c,ddone	; is it less than '0'? then were done
	ld E,A		; store in DE
	ex (SP),HL	; get result from stack
	ld B,H		; store it in bc
	ld C,L
	add HL,HL	; previous result times 10
	add HL,HL
	add HL,BC	; times 5
	add HL,HL	; times 2 (makes 10)
	add HL,DE	; add next digit
	ex (SP),HL	; back on stack
	inc HL		; go for next digit
	jr dloop
ddone:	pop DE		; reg de holds result
	ret
doops:	pop DE		; number out of range
	ld DE,0FF00h	; returns bogus result
	ret ; getdec



;  PRTHL - print HL or  LBYTE - print A  on console
;-------------------------------------------------------------
prtHL:
	ld A,H
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
conv:
	and 0Fh
	add A,90h
	daa
	adc A,40h
	daa
	ret



;-------------------------------------------------------------
;  MAIN - Main command loop
;-------------------------------------------------------------
MPROMPT:	db CR,LF,'> ',0
nocmd:	db CR,LF,'Unknown Command',0

main:
	ld HL,main	; Save entry point for Monitor
	push HL		; This is the return address
	ld HL,0
	ld (dmaAddr),HL	; set load address to invalid (ROM)

	ld HL,MPROMPT	; Entry point for Monitor, Normal
	call print	; Get a "> "

main1:	call getchr	; Get a character from the input port
	cp ' '		; <spc> or less?
	jr c,main1	; Go back

	; simple one character commands with immediate action
	; no echo
	cp ':'		; ":"?
	jp z,load	; First character of a HEX load
	cp '?'		; print instructions
	jp z,help
;	cp 'R'		; reset
;	jp z,reset
;	cp 'B'		; ROM Basic
;	jp z,basic

	; next, multi argument commands, execute on return
	ld HL,cbuff	; command buffer
	ld (HL),A	; store command
	inc HL		; next position
	ld (HL),0	; end of string
	ld B,1		; init counter
	call conout	; show command
	call istring	; get arguments
	dec HL
	ld A,(HL)
	cp ','		; last entry a comma?
	jr nz,main2
	ld (HL),0	; then make it a '0'
main2:	ld HL,cbuff	; reset pointer in command string
	ld A,(HL)	; get command 
	inc HL
	cp 'R'		; if 'R' goto Rxxxx
	jp z,goto
	cp 'S'		; if 'S' System start Sddd
	jp z,sysrun
	cp 'I'		; if 'I' Format Iddd
	jp z,format
	cp 'G'		; if 'G' getsys Gddd
	jp z,getsys
	cp 'P'		; if 'P' putsys Pddd[,xxxx]
	jp z,putsys
	cp 'D'		; if 'D' dump Dxxxx[,yyyy]
	jp z,dump
	cp 'C'		; if 'C' change Cxxxx,dd[,dd,dd]
	jp z,change
	ld HL,nocmd	; if none of these, express confusion
	call print
	ret ; to main



;  DUMP - display memory Dxxxx[,yyyy]
;-------------------------------------------------------------
dSep4:	db TAB,'  '
dsep2:	db '  ',0
dump:	ld DE,(lastMR)	; retrieve last address used by D or C command
	inc DE		; use next address
	xor A
	cp (HL)
	jr z,dskip	; if no address given, use last one
	call gethex	; get hex entry in DE
dskip:	ld A,E
	and 0F0h	; start at xxx0 boundary
	ld E,A
	push DE		; start address on stack
	push HL
	ld HL,07Fh	; default display 8 lines
	add HL,DE
	jr nc,dendok	; don't fold back to 0000h
	ld HL,0FFFFh
dendok:	ld (lastMR),HL	; save for later use
	ex DE,HL	; DE now valid endaddress
	pop HL
	ld A,(HL)
	cp ','		; if no second argument
	jr nz,darg2	; DE stays DE
	inc HL
	call gethex	; get DE
darg2:	pop HL		; start address in HL
dline:	call crlf	; start line
	push HL		; save for ascii
	call prtHL	; print address
	ld A,' '	; extra space
	call conout
	ld b,16		; 16 bytes
dbyte:	ld A,' '	; extra space
	call conout
	ld a,(hl)
	call lByte	; print byte
	inc HL		; next byte
	djnz dbyte	; repeat
	ld hl,dSep4	; print separator
	call print
	pop hl		; het start of lene back
	ld B,16		; now the same in ascii
t11:	ld A,(HL)	; get byte
	and 7Fh
	cp ' ' 		; don't print control characters
	jr nc,t33
t22:	ld a,'.'	; but print something
t33:	cp 07Fh		; also skip DEL and higher
	jr nc,t22
	call conout
	inc HL		; next byte
	djnz t11	; get next byte
	ld A,L		; pointer overflow?
	or H
	ret z		; then quit
	ld A,E		; compare DE and HL 
	sub L		; DE - HL
	ld A,D
	sbc A,H		; carry flag set if D+carry>H
	ret c
	jr dline



;  CHANGE - Change memory addresses : Cxxxx
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
	ld HL,cbuff	; command buffer
	xor A
	ld (HL),A	; start with end of string
	call istring	; get new byte (esc ends)
	ld HL,cbuff
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



crlf:	ld A,CR
	call conout
	ld A,LF
	jp conout



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
	db  'Checksum error',0
ldetxt:	db 'HEXload OK.',0

load:
	ld E,0		; First two Characters is the Record Length Field
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
	call print	; Print Message from (HL) and terminate the load
	ret

load00: ld HL,ldetxt	; Print load complete message
	call print
	ret
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
;	db '  R		Reset',CR,LF
;	db '  B		ROM Basic, Cold or Warmstart',CR,LF
	db '  :ccxxxxiinn..	Load Intel-Hex file record',CR,LF
	db '  Rxxxx		Run from address xxxx',CR,LF
	db '  Sddd		System boot',CR,LF
	db '  Iddd		Init: Format directory',CR,LF
	db '  Pddd[,xxxx]	PutSys: write system image[,loadaddress]',CR,LF
	db '		(No address: re-use last loadaddress)',CR,LF
	db '  Gddd		GetSys: load system track',CR,LF,LF
	db '  Dxxxx[,yyyy]	Dump memory from xxxx [,to yyyy]',CR,LF
	db '		D (no address) shows next block',CR,LF
	db '  Cxxxx		Change/show memory at xxxx',CR,LF
	db '		CR advances, "," quits.',CR,LF,LF
	db '  ddd is a decimal volume number 1-254,',CR,LF
	db '  xxxx, yyyy is a hexadecimal address.',CR,LF
;	db '  Loadaddres is stored with image',CR,LF
	db '  Leading zeros may be omitted.',CR,LF
	db '  ESC or ^C aborts.',CR,LF,0

help:
	ld HL,HLPTXT		; Print Help message
	jp print ; end help


; GOTO - jump to address
;-------------------------------------------------------------
goto:
	call gethex		; get hex entry in DE
	ex DE,HL
	jp (HL)



; SYSRUN - boot (load and run) from system track of selected volume
;-------------------------------------------------------------
sysrun:
	call getargs	; get volume
	call setDskIO	; set IO parameters
	call readsys	; read system track to buffer
	call getlen	; find loadaddress and length
	ldir		; move buffer to image
	ld A,(primaryIO)	; get primary console
	xor 01h		; convert to iobyte
	push AF		; save for BIOS
	ld C,A		; 2nd method
	ld A,(volume)	; get active bootvolume
	push AF		; save for BIOS
	ld B,A		; 2nd method
	exx		; also make b'=bootdisk, c'=console
	ld HL,(0FFFEh)	; pop and run location
	di		; stop interrupts
	jp (HL)		; bye bye



; GETSYS - load data from system track of selected volume to DMA address
;-------------------------------------------------------------
GETTXT:	db CR,LF,'System Read OK',0
getsys:
	call getargs
	call setDskIO
	call readsys	; rea system track to buffer
	call getlen	; find loadaddress and length
	ldir		; write buffer to image
	ld HL,GETTXT
	jp print ; end getsys



; PUTSYS - write data from DMA address to system track of selected volume
;-------------------------------------------------------------
PTSYSTXT:
	db CR,LF,'System Write OK',0
putsys:
	call getargs
	ld DE,(dmaAddr)
	xor A			; set to zero
	or D			; any bits in D
	or E			; and in E
	jr z,p1			; no loadaddres specified: just write buffer
	ld (LOADADDR),DE	; put loadaddres on top of buffer
	call getlen		; get buffer start and length
	ex DE,HL		; swap source/destination
	ldir			; fill buffer with image
p1:	call setDskIO		; set I/O parameters
	call writesys		; write system track
	ld HL,PTSYSTXT		; inform user
	jp print ; end putsys



; FORMAT - write empty directory to selected volume and add a volume label
;-------------------------------------------------------------
volImg:	db 0,'  Volume000'
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
FMTXT:	db CR,LF,'Format OK - ',0
format:
	call getargs	; if a loadaddress was entered we ignore it
	ld HL,volImg	; prepare the volumelabel
	ld DE,volumeID	; from ROM to RAM
	ld BC,34
	ldir
	; convert volume into decimal again
	ld A,(volume)
	ld L,A
	ld B,8		; b = count (8 bits to go)
	ld DE,0		; result, de=zero
unpack:	rl L		; unpack hex number in L to bcd in DE
	ld A,E		; rotate next highest bit in carry flag
	adc A,A		; shift and add next high bit of L
	daa		; adjust for BCD
	ld E,A
	ld A,D
	adc A,A		; shift and add carry of previous operation
	daa		; adjust for BCD
	ld D,A
	djnz unpack	; do  all 8 bits
	;insert volume in label
	ld HL,stack	; find a free byte
	ld (HL),E	; last two BCD digits
	ld A,D		; first BCD digit 
	ld B,3		; do all three
	ld DE,volumeID+9	; index to labeltext
	add A,'0'	; make ascii
labidx:	ld (DE),A	; store in label
	rld		; rotate next digit into A
	inc DE		; increment index
	djnz labidx	; all three of them
	ld HL,volumeID+9	; index to labeltext
	set 7,(HL)	; make read-only

	call fmtsys		; write to disk

	ld HL,FMTXT
	call print
	ld HL,volumeID+1	; display the volumelabel
	jp print ; end format


;   READSYS - perform I/O for physical sytem track read
;-------------------------------------------------------------
readsys:
	call cfWait
	ld A,CF_READ_SEC
	out (CF_CMD),A
rdNxtSec:
	call cfWait
	inir			; input 256 bytes
	inir			; input 256 bytes
	dec E
	jr nz,rdNxtSec
	ret



;   WRITESYS - perform I/O for physical system track write
;-------------------------------------------------------------
writesys:
	call cfWait
	ld A,CF_WRITE_SEC
	out (CF_CMD),A
wrNxtSec:
	call cfWait
	otir		; output 256 bytes
	otir		; output 256 bytes
	dec E
	jr nz,wrNxtSec	; as long as e > 0
	ret



; FMTSYS - perform I/O for the physical format
;-------------------------------------------------------------
fmtsys:
	ld A,32		; startsector
	ld (sector),A
	call setLbAdr

	ld A,DIRSIZE	; number of sectors to write
	ld E,A		; store in loopcounter
	out (CF_SECCNT),A	; tell CF too

	ld HL,volumeID	; where to find the disklabel
	ld C,CF_DATA	; output port

	call cfWait	; ready to write?
	ld A,CF_WRITE_SEC	; instruct CF-Card
	out (CF_CMD),A

	; write first sector
	ld B,32		; length of first entry
	call cfWait
	otir		; write label (32 bytes)
	ld D,15		; 15 entries left for this sector
fmEntry:
	ld B,32		; directory entry size
	ld A,0E5h	; first byte is E5
fmNxt
	out (C),A	; write byte
	xor A		; rest is zero
	djnz fmNxt	; finish entry
	dec D		; next entry
	jr nz,fmEntry	; do again if not last one
	call cfWait	; prepare for next sector
	ld D,16		; 16 entries per sector
	dec E		; decrement sector counter
	jr nz,fmEntry	; write them all

	ret ; fmtsys



; CFWAIT - Wait for disk to be ready (busy=0,ready=1)
;-------------------------------------------------------------
cfWait:
	in A,(CF_STAT)
	bit 7,A		; bit = 1, returns NONZERO
	jr NZ,cfWait
	ret


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


; SETDSKIO - prepare CF card for physical read/write block I/O
;-------------------------------------------------------------
setDskIO:
	xor A		; a is startsector
	ld (sector),A
	call setLbAdr	; address next sector on CF
	ld HL,BUFFADDR	; transfer buffer address
	ld E,32		; read/write the whole systemtrack
	ld A,E
	out (CF_SECCNT),A	; set CF sector count
	ld B,0		; output block counter
	ld C,CF_DATA	; set output port
	ret ;  setDskIO



; SETLBADR - convert volume and sector to Logic Block Address for the first 8 tracks (128k)
;-------------------------------------------------------------
setLbAdr:
	call cfWait
	ld A,(sector)
	out (CF_LBA0),A	; secno includes lower tracknumbers
	ld A,(volume)
	rrca
	rrca
	ld C,A
	and 0C0h
	out (CF_LBA1),A
	ld A,C
	and 3Fh
	out (CF_LBA2),A
	ld a,0E0H
	out (CF_LBA3),A
	ret

	ds 04000h - $,0FFh
