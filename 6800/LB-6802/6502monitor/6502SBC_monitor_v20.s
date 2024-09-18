; 6502SBC Monitor (c) 2014-2016 Sean Caron <scaron@umich.edu>
;
; version 1.0 / 24 oct 2014 / initial release
;  just print the banner endlessly to tty0
;  semaphore for synchronization between ISR and main loop
;
; version 1.1 / 1 jan 2015 / feature release
;  print banner once and prompt
;
; version 1.2 / 21 dec 2015 / feature release
;  accept user input at prompt and echo back to tty0 in
;  infinite loop
;
; version 1.3 / 6 sept 2015 / feature release
;  implement initial monitor feature set
;   h
;
; version 1.4 / 12 sept 2015 / feature release
;  implement initial monitor feature set
;   g rev1
;   r rev1
;
; version 1.5 / 12 sept 2015 / feature release
;  implement initial monitor feature set
;   e rev1
; build with: ./as65 -l -n -p -t -v test14.s
;
;
; version 1.6 / 8 december 2015 / buxfix release
;  improve and fix bugs in examine command now confirmed to work
;  added build script
; build with: ./build test15.s
;
;
; version 1.7 / 9 december 2015 / bugfix release
;  improve and fix bugs in go command now confirmed to work
; build with: ./build test16.s
;
;
; version 1.8 / 9 december 2015 / feature release
;  d rev1
;  deposit command tested and confirmed to work
; build with: ./build test17.s
;
;
; version 1.9 / 10 december 2015 / feature release
;  u rev1
; build with: ./build test18.s
;
; version 2.0 / 14 december 2015 / feature release
;  u rev2
;  f rev1
; fill command tested and confirmed to work
; dump command still needs a little work but runs of 0x10 and 0x20 work OK
; build with: ./build test19.s

; version 2.0b / 22 december 2015 / feature release
;  all features working except for the little bounds bug in dump
;  try to implement some init code for a VIA
;  objective: connect VIA, system behaves as usual prior to VIA installation
;
; build with: ./build 6502SBC_monitor_v20.s

; we want to develop printing a string as a general system call
; we will use the C convention of variable length strings that
;  are null-terminated.
;
; Monitor function APIs:
;
; To print a string ...
;  1. Deposit the base address of the string, that is string[0] at
;      the mailbox address
;  2. Write "1" to the start-print address
;
; To read string input ...
;  1. ISR will check RDRF (ACIA status reg. bit 3)
;   2. If high, ISR checks parity, overrun, framing error
;       (status reg. bits 0-2)
;   3. If no error bits set, ISR copies RxDR to memory 0x0200+offset
;   4. When newline is encountered, string ready is set
;   5. When 255 chars is encounted, string is arbitrarily truncated
;       string ready is set
;
; Global memory map:
;  Zero page 0x0000 - 0x00ff
;   See comments in code below for detailed zero page memory map.
;  Stack @ page 1 0x0100 - 0x01ff
;  ACIA text input buffer @ page 2 0x0200 - 0x02ff
;  String buildup area in 0x0300 - 0x03ff
;  Scratch area in 0x0400 - 0x04ff
;


; Set up vectors
	org $FFFA
VECTORS
	dw $E000	; NMI
	dw $E000	; RESET
	dw $E900	; IRQ

; String constants
	org $F000
BANNER
        db "\r\n\r\n6502 SBC Monitor V2.0 (c) Sean T. Caron & Associates\r\n\0"

PROMPT
        db "\r\n> \0"
HELP1
	db "\r\n\r\n6502 SBC Monitor V2.0 Help\r\n\r\n\0"
HELP2
	db "d [v] [a]: Deposit byte [v] at [a]\r\n\0"
HELP3
	db "e [a]: Examine byte [a]\r\n\0"
HELP4
	db "f [v] [a] [l]: Fill [l] bytes with [v] starting at [a]\r\n\0"
HELP5
	db "g [a]: Go beginning at [a]\r\n\0"
HELP6
	db "h: Print help\r\n\0"
HELP7
	db "r: Print register dump\r\n\0"
HELP8
	db "u [a] [l]: Dump [l] bytes beginning at [a]\r\n\0"
HELP9
	db "\r\n\r\nValid parameter input is [0123456789abcdef].\r\n\0"
HELP10
	db "\r\nAddresses are 2 bytes, little-endian, others are 1 byte.\r\n\0"
INVCMD
	db "\r\n! Invalid or null command.\r\n\0"
INVSYN
	db "\r\n! Invalid command syntax.\r\n\0"

; Main loop
	org $E000
MAIN
	ldx #$ff	; Initialize X, stack (0x0100-0x01ff)
	txs

	ldy #$00	; Initialize Y

			; --- BEGIN ACIA INITIALIZATION ---
	lda #$00	; Reset ACIA (write anything to status reg)
	sta $d001

	lda #$16	; Set ACIA control reg. for 300/8/1
	sta $d003

	lda #$c7	; Set ACIA command reg. for no parity,
	sta $d002	;  no rcv. echo mode, tx int, no rx dcd/dsr int.
			; --- END ACIA INITIALIZATION ---

			; --- BEGIN VIA INITIALIZATION ---
	lda #$00	; Basically just disable all functions and units
	sta $c00b	;  and more importantly, interrupts. If the user
	sta $c00c	;  needs VIA functionality, it can be done later
	sta $c00d	;  programmatically.
	sta $c00e	; Do we need pull up or pull down on wire-OR IRQ? R=?
			; --- END VIA INITIALIZATION ---
			
	lda #$00	; Configure base address for string input
	sta $0005	;  routine buffer (0x0200). Be sure to do
	lda #$02	;  this before turning interrupts on!!
	sta $0006

	lda #$00	; Initialize everything to zero
	sta $0000
	sta $0001
	sta $0002
	sta $0003
	sta $0004
	sta $0007
	sta $0008
	sta $0009
	sta $000a
	sta $000b
	sta $000c
	sta $000d
	sta $000e
	sta $000f
	sta $0010
	
	cld		; Disable decimal mode
	
	clc		; Clear carry and overflow flags
	clv
	
	cli		; Initialization complete; enable interrupts.


	; Zero page memory map -
	;  0x0000 : Print routine offset-in-string
	;           Initialized at 0 at program load, when ISR hits
	;           null-in-string or when offset reaches 255
	;  0x0001 : Address of input string for print routine (low)
	;  0x0002 : Address of input string for print routine (high)
	;  0x0003 : "go" bit. write 1 here to print, ISR will zero at
	;           end-of-string
	;  0x0004 : Read routine offset-in-string
	;  0x0005 : Address of input buffer for read routine (low)
	;  0x0006 : Address of input buffer for read routine (high)
	;  0x0007 : Read routine end-of-string/string ready flag
	;  0x0008 : Scratchpad #1
	;  0x0009 : Scratchpad #2
	;  0x000a : Scratchpad #3
	;  0x000b : Scratchpad #4
	;  0x000c : Scratchpad #5
	;  0x000d : Scratchpad #6
	;  0x000e : Scratchpad #7
	;  0x000f : Scratchpad #8
	;  0x0010 : Scratchpad #9

INITL	
	lda #$00	; Print banner
	sta $0001
	lda #$f0
	sta $0002
	lda #$01
	sta $0003

	jsr WAIT	; Wait until banner is done printing

PPMPT
	lda #$3b	; Print prompt
	sta $0001
	lda #$f0
	sta $0002
	lda #$01
	sta $0003

	jsr WAIT	; Wait until prompt done printing
LOOP
	lda $0007	; This is basically our main loop. Just idle
	cmp #$01	;  and keep looping until we hear back from
	bne LOOP	;  the ISR that we got a complete line in

			; We just fall through the above loop when the
			;  ISR decides it /does/ have a complete line

			; At this stage, we should have a complete line
			; sitting in our buffer starting at 0x0200.
			; Let's parse it. Commands are:
			;   h: print help
			;   e ad: examine byte at ad
			;   d val ad: deposit val in ad
			;   f val ad1 ad2: fill ad1 thru ad2 with val
			;   g ad: go beginning at ad
			;   r: print register dump
			;   u ad1 ad2: dump memory from ad1 thru ad2
			; h=0x68,d=0x64,f=0x66,g=0x67,u=0x75
			; 0-9=0x30-0x39, a-f=0x61-0x66

	lda $0200
	cmp #$68	; Is first character in buffer "h"?
	beq DOHELP	;  If so, do the help routine.

	lda $0200
	cmp #$67	; Is the first character in buffer "g"?
	beq DOGO	;  If so, do the go routine.

	lda $0200	; Is the first character in buffer "r"?
	cmp #$72	;  If so, do the register dump routine.
	beq DORDMP

	lda $0200	; Is the first character in buffer "e"?
	cmp #$65	;  If so, do the examine routine.
	beq DOEXAM
	
	lda $0200	; Is the first character in buffer "d"?
	cmp #$64	;  If so, do the deposit routine.
	beq DODEPOSI
	
	lda $0200	; Is the first character in buffer "u"?
	cmp #$75	;  If so, do the dump routine.
	beq DODUMP
	
	lda $0200	; Is the first character in buffer "f"?
	cmp #$66	;  If so, do the fill routine.
	beq DOFILL
	

INVCMDERR
			; If we have fallen through to this degree
			;  the user must have input a command that
			;  we dont recognize so just print the
			;  invalid command error, clear the read
			;  buffer and return us around for another go.

	lda #$be	; To print back user input: lda $0005 
	sta $0001
	lda #$f1	; To print back user input: lda $0006
	sta $0002
	lda #$01
	sta $0003

	jsr WAIT	; Wait for that string to be printed

	sei		; When done, reset string-present (be sure to
	lda #$00	;  (disable interrupts while messing with any
	sta $0007	;  variables internal to the ISR!)
	cli

	jmp PPMPT	; Print the prompt and do it all over again

			; *** This is basically the end of the main loop. ***
			; *** The following are basically subroutines. ***
WAIT
	lda $0003
	cmp #$01
	beq WAIT	; Loop as long as flag in 0x0003 is set to 1
	rts

DOGO			; Command handler jump table
	jmp DO_GO
DOHELP
	jmp DO_HELP
DORDMP
	jmp DO_RDMP
DOEXAM
	jmp DO_EXAM
DODEPOSI
	jmp DO_DEPOSI
DODUMP
	jmp DO_DUMP
DOFILL
	jmp DO_FILL

DO_HELP			; Help command handler
	lda #$40
	sta $0001
	lda #$f0
	sta $0002
	lda #$01
	sta $0003	; Print HELP1

	jsr WAIT

	lda #$63
	sta $0001
	lda #$f0
	sta $0002
	lda #$01
	sta $0003	; Print HELP2

	jsr WAIT

	lda #$88
	sta $0001
	lda #$f0
	sta $0002
	lda #$01
	sta $0003	; Print HELP3

	jsr WAIT

	lda #$a2
	sta $0001
	lda #$f0
	sta $0002
	lda #$01
	sta $0003	; Print HELP4

	jsr WAIT

	lda #$db
	sta $0001
	lda #$f0
	sta $0002
	lda #$01
	sta $0003	; Print HELP5

	jsr WAIT

	lda #$f8
	sta $0001
	lda #$f0
	sta $0002
	lda #$01
	sta $0003	; Print HELP6

	jsr WAIT

	lda #$08
	sta $0001
	lda #$f1
	sta $0002
	lda #$01
	sta $0003	; Print HELP7

	jsr WAIT

	lda #$21
	sta $0001
	lda #$f1
	sta $0002
	lda #$01
	sta $0003	; Print HELP8

	jsr WAIT

	lda #$4e
	sta $0001
	lda #$f1
	sta $0002
	lda #$01
	sta $0003	; Print HELP9

	jsr WAIT

	lda #$81
	sta $0001
	lda #$f1
	sta $0002
	lda #$01
	sta $0003	; Print HELP10

	jsr WAIT

        sei             ; When done, reset string-present (be sure to
        lda #$00        ;  (disable interrupts while messing with any
        sta $0007       ;  variables internal to the ISR!)
	cli

	jmp PPMPT

DO_INVSYNERR		; Syntax error
	lda #$dd	; Load syntax error string into print routine
	sta $0001
	lda #$f1
	sta $0002
	lda #$01
	sta $0003	; Set the flag to print it.

	jsr WAIT	; Wait for string to print

	sei		; Reset read input buffer
	lda #$00	;  (be sure to switch off interrupts first)
	sta $0007
	cli

	jmp PPMPT

INVSYNERR3		; Local jump table for DO_DEPOSI
	jmp DO_INVSYNERR
	
DO_DEPOSI		; Input will be > d xx yyyy to deposit byte 0xXX at address 0xYYYY
	lda $0201
	cmp #$20	; Check for space in second position i.e. "d ".
	bne INVSYNERR3
	lda $0204
	cmp #$20	; Check for space in fifth position i.e. "d xx ".
	bne INVSYNERR3
	
			; Convert data in ASCII to raw hex...
			; Data from user at 0x0202-0x0203
			; Data is big-endian; high nybble at 0x0202 low nybble at 0x0203
	
	lda $0202	; Begin ASCII to hex first character
	clc
	sbc #$2f	; Try: change from 0x30 to 0x2f
	cmp #$0a
	bcc DO_DEPOSI1
	clc
	sbc #$26	; Try: change from 0x27 to 0x26 -- this seems to have fixed the issue!
DO_DEPOSI1
	sta $0400	; Store ASCII to hex first character
	
	lda $0203	; Begin ASCII to hex second character
	clc
	sbc #$2f
	cmp #$0a
	bcc DO_DEPOSI2
	clc
	sbc #$26
DO_DEPOSI2
	sta $0401	; Store ASCII to hex second character
	
			; Convert address in ASCII to raw hex...
			; Address from user at 0x0202-0x0205
			; Low word 0x0202-0x0203, high word 0x0204-0205.
	
	lda $0205	; Begin ASCII to hex first character
	clc
	sbc #$2f	; Try: change from 0x30 to 0x2f
	cmp #$0a
	bcc DO_DEPOSI3
	clc
	sbc #$26	; Try: change from 0x27 to 0x26 -- this seems to have fixed the issue!
DO_DEPOSI3
	sta $0402	; Store ASCII to hex first character
	
	lda $0206	; Begin ASCII to hex second character
	clc
	sbc #$2f
	cmp #$0a
	bcc DO_DEPOSI4
	clc
	sbc #$26
DO_DEPOSI4
	sta $0403	; Store ASCII to hex second character
	
	lda $0207
	clc
	sbc #$2f
	cmp #$0a
	bcc DO_DEPOSI5
	clc
	sbc #$26
DO_DEPOSI5
	sta $0404	; Store ASCII to hex third character
	
	lda $0208	; Begin ASCII to hex fourth character
	clc
	sbc #$2f
	cmp #$0a
	bcc DO_DEPOSI6
	clc
	sbc #$26
DO_DEPOSI6
	sta $0405	; Store ASCII to hex fourth character
	
	lda $0402	; Condense the 4 words of ASCII input down to
	asl a		;  two words of raw hex...
	asl a
	asl a
	asl a
	sta $000a	; Save UUUU0000
	lda $0403
	and #$0f	; Mask s.t. A=0000LLLL
	clc
	adc $000a	; Result should be UUUULLLL
	sta $0008	; Low word of address in 0x0008

	lda $0404
	asl a
	asl a
	asl a
	asl a
	sta $000a	; Save UUUU0000
	lda $0405
	and #$0f	; Mask s.t. A=0000LLLL
	clc
	adc $000a	; Result should be UUUULLLL
	sta $0009	; High word of address in 0x0009.
			
	lda $0400	; Condense the 4 words of ASCII input down to
	asl a		;  two words of raw hex...
	asl a
	asl a
	asl a
	sta $000a	; Save UUUU0000
	lda $0401
	and #$0f	; Mask s.t. A=0000LLLL
	clc
	adc $000a	; Result should be UUUULLLL
	sta $000a	; Data word in 0x000a
	
	lda $000a	; Grab the data from the scratchpad and do the deposit.
	ldy #$00
	sta ($0008),y
	
	sei		; Reset input bufer ...
	lda #$00
	sta $0007
	cli

	jmp PPMPT	; ... and return.

INVSYNERR5		; Local jump table for DO_FILL
	jmp DO_INVSYNERR
	
DO_FILL			; Input will look like > f vv llhh nn
	lda $0201
	cmp #$20
	bne INVSYNERR5	; Check for space in second position i.e. "f ".
	lda $0204
	cmp #$20
	bne INVSYNERR5	; Check for space in fifth position i.e. "f vv ".
	lda $0209
	cmp #$20
	bne INVSYNERR5	; Check for space in tenth position i.e. "f vv llhh ".

			; Convert data in ASCII to raw hex...
			; Data from user at 0x0202-0x0203
			; Data is big-endian; high nybble at 0x0202 low nybble at 0x0203
	
	lda $0202	; Begin ASCII to hex first character
	clc
	sbc #$2f	; Try: change from 0x30 to 0x2f
	cmp #$0a
	bcc DO_FILL1
	clc
	sbc #$26	; Try: change from 0x27 to 0x26 -- this seems to have fixed the issue!
DO_FILL1
	sta $0400	; Store ASCII to hex first character
	
	lda $0203	; Begin ASCII to hex second character
	clc
	sbc #$2f
	cmp #$0a
	bcc DO_FILL2
	clc
	sbc #$26
DO_FILL2
	sta $0401	; Store ASCII to hex second character
	
			; Convert address in ASCII to raw hex...
			; Address from user at 0x0202-0x0205
			; Low word 0x0202-0x0203, high word 0x0204-0205.
	
	lda $0205	; Begin ASCII to hex first character
	clc
	sbc #$2f	; Try: change from 0x30 to 0x2f
	cmp #$0a
	bcc DO_FILL3
	clc
	sbc #$26	; Try: change from 0x27 to 0x26 -- this seems to have fixed the issue!
DO_FILL3
	sta $0402	; Store ASCII to hex first character
	
	lda $0206	; Begin ASCII to hex second character
	clc
	sbc #$2f
	cmp #$0a
	bcc DO_FILL4
	clc
	sbc #$26
DO_FILL4
	sta $0403	; Store ASCII to hex second character
	
	lda $0207
	clc
	sbc #$2f
	cmp #$0a
	bcc DO_FILL5
	clc
	sbc #$26
DO_FILL5
	sta $0404	; Store ASCII to hex third character
	
	lda $0208	; Begin ASCII to hex fourth character
	clc
	sbc #$2f
	cmp #$0a
	bcc DO_FILL6
	clc
	sbc #$26
DO_FILL6
	sta $0405	; Store ASCII to hex fourth character

			; Convert run length in ASCII to raw hex...
			; Run length from user at 0x020a-0x020b
			; High nybble at 0x020a , low nybble at 0x020b.

	lda $020a	; Begin ASCII to hex run length first character
	clc
	sbc #$2f	; Try: change from 0x30 to 0x2f
	cmp #$0a
	bcc DO_FILL7
	clc
	sbc #$26	; Try: change from 0x27 to 0x26 -- this seems to have fixed the issue!
DO_FILL7
	sta $0406	; Store ASCII to hex first character
	
	lda $020b	; Begin ASCII to hex second character
	clc
	sbc #$2f
	cmp #$0a
	bcc DO_FILL8
	clc
	sbc #$26
DO_FILL8
	sta $0407	; Store ASCII to hex second character

	lda $0402	; Condense the 4 words of ASCII input down to
	asl a		;  two words of raw hex...
	asl a
	asl a
	asl a
	sta $000a	; Save UUUU0000
	lda $0403
	and #$0f	; Mask s.t. A=0000LLLL
	clc
	adc $000a	; Result should be UUUULLLL
	sta $0008	; Low word of address in 0x0008

	lda $0404
	asl a
	asl a
	asl a
	asl a
	sta $000a	; Save UUUU0000
	lda $0405
	and #$0f	; Mask s.t. A=0000LLLL
	clc
	adc $000a	; Result should be UUUULLLL
	sta $0009	; High word of address in 0x0009.
			
	lda $0400	; Condense the two words of ASCII input down to
	asl a		;  two words of raw hex (data) ...
	asl a
	asl a
	asl a
	sta $000a	; Save UUUU0000
	lda $0401
	and #$0f	; Mask s.t. A=0000LLLL
	clc
	adc $000a	; Result should be UUUULLLL
	sta $000a	; Data word in 0x000a

	lda $0406	; Condense the two words of ASCII input down to
	asl a		;  two words of raw hex (run length) ...
	asl a
	asl a
	asl a
	sta $000b	; Save UUUU0000
	lda $0407
	and #$0f	; Mask s.t. A=0000LLLL
	clc
	adc $000b	; Result should be UUUULLLL
	sta $000b	; Run length in 0x000b

	sta $6667	; TEST store the run length in a location where we can examine it
	
	lda #$00
	sta $000c	; Loop counter in 0x000c

DO_FILL9
	lda $000a	; Grab data from scratchpad
	ldy $000c	; Grab loop counter from scratchpad
	sta ($0008),y	; Deposit data at the requisite address (base+loop counter)
	
	inc $000c	; Increment loop counter
	
	lda $000c
	clc
	cmp $000b	; Check if loop counter is less than run length
	
	bcc DO_FILL9	; If loop counter is less than run length, do another iteration

			; Otherwise we are done so fall through and return
	
	sei		; Reset input bufer ...
	lda #$00
	sta $0007
	cli

	jmp PPMPT	; ... and return.
	

INVSYNERR4		; Local jump table for DO_DUMP
	jmp DO_INVSYNERR

			; This command seems to work for bounds 0x10 and 0x20 but intermediate sizes
			;  unclear... and any run length greater than 0x20 just seems to get set to
			;  0x20 for some reason which needs to be investigated.
			
			; Input will look like > u llhh nn
DO_DUMP			; Output will look like HHLL: NN NN NN NN NN NN NN NN  NN NN NN NN NN NN NN NN
	lda $0201	;  repeating every 16 bytes until the specified bound is reached.
	cmp #$20	; Check for space in second position i.e. "u ".
	bne INVSYNERR4
	
	lda $0206
	cmp #$20	; Check for space in seventh position i.e. "u aaaa ".
	bne INVSYNERR4

	lda #$0d	; Begin composing the string "\r\n"
	sta $0300
	lda #$0a
	sta $0301

			; Convert address in ASCII to raw hex...
			; Address from user at 0x0202-0x0205
			; Low word 0x0202-0x0203, high word 0x0204-0205.
	
	lda $0202	; Begin ASCII to hex first character
	clc
	sbc #$2f	; Try: change from 0x30 to 0x2f
	cmp #$0a
	bcc DO_DUMP1
	clc
	sbc #$26	; Try: change from 0x27 to 0x26 -- this seems to have fixed the issue!
DO_DUMP1
	sta $0400	; Store ASCII to hex first character of address
	
	lda $0203	; Begin ASCII to hex second character of address 
	clc
	sbc #$2f
	cmp #$0a
	bcc DO_DUMP2
	clc
	sbc #$26
DO_DUMP2
	sta $0401	; Store ASCII to hex second character of address
	
	lda $0204
	clc
	sbc #$2f
	cmp #$0a
	bcc DO_DUMP3
	clc
	sbc #$26
DO_DUMP3
	sta $0402	; Store ASCII to hex third character of address
	
	lda $0205	; Begin ASCII to hex fourth character of address
	clc
	sbc #$2f
	cmp #$0a
	bcc DO_DUMP4
	clc
	sbc #$26
DO_DUMP4
	sta $0403	; Store ASCII to hex fourth character of address
	
	lda $0207	; Begin ASCII to hex first character of length
	clc
	sbc #$2f
	cmp #$0a
	bcc DO_DUMP5
	clc
	sbc #$26
DO_DUMP5
	sta $0404	; Store ASCII to hex first character of length
	
	lda $0208	; Begin ASCII to hex second character of length
	clc
	sbc #$2f
	cmp #$0a
	bcc DO_DUMP6
	clc
	sbc #$26
DO_DUMP6
	sta $0405	; Store ASCII to hex second character of length
	

	lda $0400	; Condense the 4 words of ASCII address input down to
	asl a		;  two words of raw hex...
	asl a
	asl a
	asl a
	sta $000a	; Save UUUU0000
	lda $0401
	and #$0f	; Mask s.t. A=0000LLLL
	clc
	adc $000a	; Result should be UUUULLLL
	sta $0008	; Low word in 0x0008

	lda $0402
	asl a
	asl a
	asl a
	asl a
	sta $000a	; Save UUUU0000
	lda $0403
	and #$0f	; Mask s.t. A=0000LLLL
	clc
	adc $000a	; Result should be UUUULLLL
	sta $0009	; High word in 0x0009.

	lda $0404	; Condense one word of ASCII length input down to one
	asl a		;  word of raw hex.
	asl a
	asl a
	asl a
	sta $000a
	lda $0405
	and #$0f
	clc
	adc $000a
	sta $000a

	sta $6667	; TEST store the bounds in some location where we can examine it
			;  result: bounds seem to be getting converted and stored OK
			;  the problem must be in the comparison?
			;  the problem only seems to affect DUMP, FILL works fine!
			
			; At this stage, we have a raw address with low word in 0x0008
			;  and high word at 0x0009. The raw length is at 0x000a.
			
	lda $0009	; Add the address specified by the user to the string
	lsr a		;  build-up buffer. 
	lsr a
	lsr a
	lsr a
	clc
	cmp #$0a
	bcc DO_DUMP7
	clc
	adc #$07
DO_DUMP7
	clc
	adc #$30
	sta $0302

	lda $0009
	and #$0f
	clc
	cmp #$0a
	bcc DO_DUMP8
	clc
	adc #$07
DO_DUMP8
	clc
	adc #$30
	sta $0303
	
	lda $0008
	lsr a
	lsr a
	lsr a
	lsr a
	clc
	cmp #$0a
	bcc DO_DUMP9
	clc
	adc #$07
DO_DUMP9
	clc
	adc #$30
	sta $0304
	
	lda $0008
	and #$0f
	clc
	cmp #$0a
	bcc DO_DUMP10
	clc
	adc #$07
DO_DUMP10
	clc
	adc #$30
	sta $0305
	
	lda #$3a	; Add ":" to the string.
	sta $0306
	lda #$20	; Add " " to the string.
	sta $0307	
	
			; Output at this stage will be:
			;  LLHH: 
			; Ready to print first value
			
			; ** Set up the loop to print memory values until we hit the bound ** 

	lda #$00
	sta $000b	; Initialize counters to 0
	sta $000c
	
	sta $000e	; Initialize X offset to 0
	
			; $000b will be our counter against the limit specified by the user (outer loop)
			; $000c will be our counter-to-16 to find newlines on long dumps (inner loop)

DO_DUMP_LOOP		
	ldy $000b	; Counter to Y for indirect addressing offset	
	lda ($0008),y	; Fetch the value

			; Perform raw hex to ASCII

	sta $000d	; Save a copy of the result

	and #$f0	; Process high nybble of the value
	lsr a		;  raw hex to ASCII
	lsr a
	lsr a
	lsr a
	clc
	cmp #$0a
	bcc DO_DUMP_LOOP1
	clc		; Shifting sets carry, be sure to clear it ...
	adc #$07
DO_DUMP_LOOP1
	clc
	adc #$30
	ldx $000e
	sta $0308,x	; Store in the string build-up buffer

	lda $000d	; Process low nybble of the value
	and #$0f	;  raw hex to ASCII
	clc
	cmp #$0a
	bcc DO_DUMP_LOOP2
	clc
	adc #$07
DO_DUMP_LOOP2
	clc
	adc #$30
	ldx $000e
	sta $0309,x	; Store in the string build-up buffer

	lda #$20
	ldx $000e
	sta $030a,x	; Add " " to the string build-up buffer

	inc $000b	; Increment counters
	inc $000c

	inc $000e	; Increment X offset
	inc $000e
	inc $000e
	
	lda $000b	; If 0x000b is equal to 0x000a we need to finish up
	clc
	cmp $000a
	beq DO_DUMP_LOOP_9_JT
	
	lda $000c	; If 0x000c is equal to 16 we need to start a new line
	clc
	cmp #$10
	beq DO_DUMP_LOOP_3

	jmp DO_DUMP_LOOP	; Otherwise do another iteration.

DO_DUMP_LOOP_9_JT
	jmp DO_DUMP_LOOP_9
	
DO_DUMP_LOOP_3

	lda #$00	; Terminate string "\0"
	sta $0337	; There will be a newline in beginning of next string so we dont need it here
			; This address will be fixed if we have gotten a full 16 word line.
	
	lda #$00	; Print the string
	sta $0001
	lda #$03
	sta $0002
	lda #$01
	sta $0003

	jsr WAIT	; Wait for it to be printed

			; At this stage we need to write out the header for the next line i.e.
			;  "HHLL: " with the correct, iterated address (previous base + 16). 

	lda #$0d	; Begin composing the string "\r\n"
	sta $0300
	lda #$0a
	sta $0301

	lda $0008	; Calculate our new address to print out
	clc
	adc $000b
	sta $000f	; Low nybble
	lda $0009
	bcc DO_DUMP_LOOP_4
	clc
	adc #$01	; Only increment high nybble if carry was set on low nybble
DO_DUMP_LOOP_4
	sta $0010	; High nybble

	lda $0010	; Add the incremented address calculated above to the string
	lsr a
	lsr a
	lsr a
	lsr a
	clc
	cmp #$0a
	bcc DO_DUMP_LOOP_5
	clc
	adc #$07
DO_DUMP_LOOP_5
	clc
	adc #$30
	sta $0302

	lda $0010
	and #$0f
	clc
	cmp #$0a
	bcc DO_DUMP_LOOP_6
	clc
	adc #$07
DO_DUMP_LOOP_6
	clc
	adc #$30
	sta $0303
	
	lda $000f
	lsr a
	lsr a
	lsr a
	lsr a
	clc
	cmp #$0a
	bcc DO_DUMP_LOOP_7
	clc
	adc #$07
DO_DUMP_LOOP_7
	clc
	adc #$30
	sta $0304
	
	lda $000f
	and #$0f
	clc
	cmp #$0a
	bcc DO_DUMP_LOOP_8
	clc
	adc #$07
DO_DUMP_LOOP_8
	clc
	adc #$30
	sta $0305

	lda #$3a	; Add ":" to the string.
	sta $0306
	lda #$20	; Add " " to the string.
	sta $0307	

			; Finished with string composition, ready to go back around for more data
			
	lda #$00	; Reset X offset
	sta $000e
	
	jmp DO_DUMP_LOOP	; Go and do another iteration.
	
DO_DUMP_LOOP_9

	lda #$0d	; Terminate string "\r\n\0" (newline needed here since after this back to prompt)
	sta $0337	;  If we printed 16 words this address will be fixed
	lda #$0a
	sta $0338	;  If we printed 16 words this address will be fixed
	lda #$00
	sta $0339	;  If we printed 16 words this address will be fixed
			;   otherwise we need to fix this to calculate the correct offset
			
	lda #$00	; Print the string
	sta $0001
	lda #$03
	sta $0002
	lda #$01
	sta $0003

	jsr WAIT	; Wait for it to be printed

	sei		; Reset input bufer ...
	lda #$00
	sta $0007
	cli

	jmp PPMPT	; ... and return.

INVSYNERR2		; Local jump table for DO_EXAM
	jmp DO_INVSYNERR

DO_EXAM			; Output will look like HHLL: NN
	lda $0201
	cmp #$20	; Check for space in second position i.e. "e ".
	bne INVSYNERR2	;  If not, report a syntax error

	lda #$0d	; Begin composing the string "\r\n"
	sta $0300
	lda #$0a
	sta $0301
			
			; Convert address in ASCII to raw hex...
			; Address from user at 0x0202-0x0205
			; Low word 0x0202-0x0203, high word 0x0204-0205.
	
	lda $0202	; Begin ASCII to hex first character
	clc
	sbc #$2f	; Try: change from 0x30 to 0x2f
	cmp #$0a
	bcc DO_EXAM1
	clc
	sbc #$26	; Try: change from 0x27 to 0x26 -- this seems to have fixed the issue!
DO_EXAM1
	sta $0400	; Store ASCII to hex first character
	
	lda $0203	; Begin ASCII to hex second character
	clc
	sbc #$2f
	cmp #$0a
	bcc DO_EXAM2
	clc
	sbc #$26
DO_EXAM2
	sta $0401	; Store ASCII to hex second character
	
	lda $0204
	clc
	sbc #$2f
	cmp #$0a
	bcc DO_EXAM3
	clc
	sbc #$26
DO_EXAM3
	sta $0402	; Store ASCII to hex third character
	
	lda $0205	; Begin ASCII to hex fourth character
	clc
	sbc #$2f
	cmp #$0a
	bcc DO_EXAM4
	clc
	sbc #$26
DO_EXAM4
	sta $0403	; Store ASCII to hex fourth character
			
			; At this stage, process is (1) condense 32
			; bits of ASCII to 16 bits of raw hex (2) use
			; that value to perform an indirect reference
			; to snarf that data and (3) append the result
			; to the output string.

	lda $0400	; Condense the 4 words of ASCII input down to
	asl a		;  two words of raw hex...
	asl a
	asl a
	asl a
	sta $000a	; Save UUUU0000
	lda $0401
	and #$0f	; Mask s.t. A=0000LLLL
	clc
	adc $000a	; Result should be UUUULLLL
	sta $0008	; Low word in 0x0008

	lda $0402
	asl a
	asl a
	asl a
	asl a
	sta $000a	; Save UUUU0000
	lda $0403
	and #$0f	; Mask s.t. A=0000LLLL
	clc
	adc $000a	; Result should be UUUULLLL
	sta $0009	; High word in 0x0009.

			; We should end up with a pair of words:
			; UUUULLLL UUUULLLL (high low)
			;  0x0009^  0x0008^

	lda $0009	; Add the address specified by the user to the string
	lsr a		;  build-up buffer. 
	lsr a
	lsr a		; By displaying what the CPU thinks the user entered
	lsr a		;  rather than just blindly copying the user input,
	clc		;  this may provide further insight into our problem.
	cmp #$0a
	bcc DO_EXAM5
	clc
	adc #$07
DO_EXAM5		; What we see is there is too much subtraction going on ...
	clc		;  If we feed in FFFF we get DDDD, AAAA gives 8888 (skips by two)
	adc #$30	;  If we feed in 9999 we get 8888, 8888 gives 7777 and so on (skips by one)
	sta $0302	; Test case 6666 coincidentally worked because we had the same data in 5555
			; Resolved by changing 0x30 to 0x2f and 0x27 to 0x26 in the ASCII to hex!
	lda $0009
	and #$0f
	clc
	cmp #$0a
	bcc DO_EXAM6
	clc
	adc #$07
DO_EXAM6
	clc
	adc #$30
	sta $0303
	
	lda $0008
	lsr a
	lsr a
	lsr a
	lsr a
	clc
	cmp #$0a
	bcc DO_EXAM7
	clc
	adc #$07
DO_EXAM7
	clc
	adc #$30
	sta $0304
	
	lda $0008
	and #$0f
	clc
	cmp #$0a
	bcc DO_EXAM8
	clc
	adc #$07
DO_EXAM8
	clc
	adc #$30
	sta $0305
	
	lda #$3a	; Add ":" to the string.
	sta $0306
	lda #$20	; Add " " to the string.
	sta $0307
	
			; Now with the address in hand, go fetch the data.

	ldy #$00	; Load the contents of the word specified by the
	lda ($0008),y	;  user into the accumulator.

	sta $000a	; Save a copy of the result

	and #$f0	; Process high nybble
	lsr a		;  raw hex to ASCII
	lsr a
	lsr a
	lsr a
	clc
	cmp #$0a
	bcc DO_EXAM9
	clc		; Shifting sets carry, be sure to clear it ...
	adc #$07
DO_EXAM9
	clc
	adc #$30
	sta $0308	; Store in the string build-up buffer

	lda $000a	; Process low nybble
	and #$0f	;  raw hex to ASCII
	clc
	cmp #$0a
	bcc DO_EXAM10
	clc
	adc #$07
DO_EXAM10
	clc
	adc #$30
	sta $0309	; Store in the string build-up buffer.

	lda #$0d	; Terminate string "\r\n\0"
	sta $030a
	lda #$0a
	sta $030b
	lda #$00
	sta $030c

	lda #$00	; Print the string
	sta $0001
	lda #$03
	sta $0002
	lda #$01
	sta $0003

	jsr WAIT	; Wait for it to be printed

	sei		; Reset input bufer ...
	lda #$00
	sta $0007
	cli

	jmp PPMPT	; ... and return.

DO_RDMP			; Output will look like A=aa X=xx Y=xx SP=pp

	sta $0008	; Save the accumulator state

	lda #$0d	; Add a leading CRLF to the string
	sta $0300
	lda #$0a
	sta $0301

	lda #$41	; Start building up the string "A="
	sta $0302
	lda #$3d
	sta $0303

	lda $0008	; Process high nybble of A
	and #$f0	;  Get MSBs
	lsr a
	lsr a
	lsr a
	lsr a
	cmp #$09	; If result > 9 we need to add an
	bmi RDMP1	;  extra 0x07 to do the ASCII
	beq RDMP1	;  (less than or equal to)
	clc
	adc #$07	;  conversion
RDMP1
	clc
	adc #$30	; Convert to ASCII
	sta $0304	; Save in the string build-up buffer

	lda $0008	; Process low nybble of A
	and #$0f	;  Get LSBs
	cmp #$09
	bmi RDMP2
	beq RDMP2	; (less than or equal to)
	clc
	adc #$07
RDMP2
	clc
	adc #$30
	sta $0305

	lda #$20	; Add " X=" to the string that we
	sta $0306	;  are constructing.
	lda #$58
	sta $0307
	lda #$3d
	sta $0308

	txa		; Process low nybble of X
	and #$f0	; Get MSBs
	lsr a		; For the MSBs, we need to shift them
	lsr a		;  down...
	lsr a
	lsr a
	cmp #$09
	bmi RDMP3
	beq RDMP3	; (less than or equal to)
	clc		; Shifting sets carry, be sure to clear it.
	adc #$07
RDMP3
	clc
	adc #$30
	sta $0309
	txa		; Process high nybble of X
	and #$0f	; Get LSBs
	cmp #$09
	bmi RDMP4
	beq RDMP4	; (less than or equal to)
	clc
	adc #$07
RDMP4
	clc
	adc #$30
	sta $030a

	lda #$20	; Add " Y=" to the string that we
	sta $030b	;  are constructing.
	lda #$59
	sta $030c
	lda #$3d
	sta $030d

	tya		; Process low nybble of Y
	and #$f0	; Get MSBs
	lsr a
	lsr a
	lsr a
	lsr a
	cmp #$09
	bmi RDMP5
	beq RDMP5	; (less than or equal to)
	clc
	adc #$07
RDMP5
	clc
	adc #$30
	sta $030e
	tya		; Process high nybble of Y
	and #$0f	; Get LSBs
	cmp #$09
	bmi RDMP6
	beq RDMP6	; (less than or equal to)
	clc
	adc #$07
RDMP6
	clc
	adc #$30
	sta $030f

	lda #$20	; Add " SP="
	sta $0310
	lda #$53
	sta $0311
	lda #$50
	sta $0312
	lda #$3d
	sta $0313

	tsx		; Process high nybble of SP
	txa
	and #$f0	; Get MSBs
	lsr a
	lsr a
	lsr a
	lsr a
	cmp #$09
	bmi RDMP7
	beq RDMP7	; (less than or equal to)
	clc
	adc #$07
RDMP7
	clc
	adc #$30
	sta $0314
	tsx		; Process low nybble of SP
	txa
	and #$0f	; Get LSBs
	cmp #$09
	bmi RDMP8
	beq RDMP8	; (less than or equal to)
	clc
	adc #$07
RDMP8
	clc
	adc #$30
	sta $0315

	lda #$0d	; Terminate string "\r\n\0"
	sta $0316
	lda #$0a
	sta $0317
	lda #$00
	sta $0318

	lda #$00	; Print the string
	sta $0001
	lda #$03
	sta $0002
	lda #$01
	sta $0003

	jsr WAIT	; Wait for it to be printed

	sei		; Reset read input buffer ...
	lda #$00
	sta $0007
	cli

	jmp PPMPT	;  ... and return.

INVSYNERR
	jmp DO_INVSYNERR

DO_GO			; Go command handler
	lda $0201
	cmp #$20	; Check for space in second position i.e. "g ".
	bne INVSYNERR	;  If not, report a syntax error.

			; So we should have an address specified by the
			;  user. Low word is in 0x0202 and high word is
			;  in 0x0203. The user must enter the address
			;  little-endian. We translate each of the two
			;  words from ASCII to hex.

	lda $0202	; Begin ASCII to hex first character
	clc
	sbc #$2f	; Try: change from 0x30 to 0x2f
	cmp #$0a
	bcc DO_GO1
	clc
	sbc #$26	; Try: change from 0x27 to 0x26 -- this seems to have fixed the issue!
DO_GO1
	sta $0400	; Store ASCII to hex first character
	
	lda $0203	; Begin ASCII to hex second character
	clc
	sbc #$2f
	cmp #$0a
	bcc DO_GO2
	clc
	sbc #$26
DO_GO2
	sta $0401	; Store ASCII to hex second character
	
	lda $0204
	clc
	sbc #$2f
	cmp #$0a
	bcc DO_GO3
	clc
	sbc #$26
DO_GO3
	sta $0402	; Store ASCII to hex third character
	
	lda $0205	; Begin ASCII to hex fourth character
	clc
	sbc #$2f
	cmp #$0a
	bcc DO_GO4
	clc
	sbc #$26
DO_GO4
	sta $0403	; Store ASCII to hex fourth character
	
	lda $0400	; Condense the 4 words of ASCII input down to
	asl a		;  two words of raw hex...
	asl a
	asl a
	asl a
	sta $000a	; Save UUUU0000
	lda $0401
	and #$0f	; Mask s.t. A=0000LLLL
	clc
	adc $000a	; Result should be UUUULLLL
	sta $0008	; Low word in 0x0008

	lda $0402
	asl a
	asl a
	asl a
	asl a
	sta $000a	; Save UUUU0000
	lda $0403
	and #$0f	; Mask s.t. A=0000LLLL
	clc
	adc $000a	; Result should be UUUULLLL
	sta $0009	; High word in 0x0009.

			; We should end up with a pair of words:
			; UUUULLLL UUUULLLL (high low)
			;  0x0009^  0x0008^

	sei		; Reset read buffer to clean up a little bit
	lda #$00	;  before we jump.
	sta $0007
	cli

	jmp ($0008)	; Jump to user-specified address.
			; Low nybble in 0x0008 high nybble in 0x0009.

			; End DO_GO

; Interrupt service routine
; Note that the 6502 implicitly disables interrupts when vectoring off to
; ISR, and implicitly re-enables them when it hits the RTI instruction

; Be sure to save the state of A,X,Y to the stack first thing we do, and
; be sure to restore them from same immediately before returning!

	org $E900
ISR
	pha		; Save accumulator to stack
	lda $0003	; Check if print go bit set
	cmp #$00
	beq CHKINP	; Nothing to print, move on to checking input
	ldy $0000	; Load offset to Y from memory
	lda ($0001),y	;  use that as index for next banner character
			;  ASCII value for that is now in A
	tay		; Save character to print later (if not null)
	cmp #$00	; One last check for null-in-string
	bne CHK		; Fall through when finished printing

FINISHED        
	lda #$00        ; When done printing the string, zero out offset
        sta $0000       ; and the go bit, then give it an opportunity to
        sta $0003       ; check input ( ...then return)
        jmp CHKINP

CHK
	lda #$10	; Load mask: 00010000 to check TxDR empty
	and $d001	; Query ACIA status reg (clears interrupt)
	cmp #$10	; Result is 0 if TxDR empty
	bne CHK		; Beyond this point, clear to transmit
	sty $d000	; Write Y to ACIA TxDR
	inc $0000	; Increment index (implied store)
	lda #$ff	; Check if bounds of index reached
	cmp $0000
	beq CONTINU
	jmp CHKINP	; If not, just jump right ahead to input processing
CONTINU
	lda #$00	; If so, zero out offset and the go bit
	sta $0000	;  before we consider any input
	sta $0003
CHKINP			; Now check for input
	lda $0007	; Check if string already present in buffer
	cmp #$01
	beq BUFFULL
	lda #$08	; Load mask: 00001XXX to check RxDR full (ignore err)
	and $d001	; Check ACIA status register: want to see XXXX1XXX
	cmp #$08	; We should get back: 00001000; When RxDR full this
			; operation should give zero
	bne RETN	; If no input, we can return
			; TEST: We are going to see what happens if we just
			; take whatever is in RxDR regardless of whether or
			; not the ACIA thinks it is OK i.e. bits 0-2 set in
			; status register
			; RESULT: Doesnt seem to actually hurt anything
			;  Might as well be liberal in what we accept
			; Beyond this point RxDR (not) assumed to be OK
			;  (but we will take it anyway)
	lda $d000	; Transfer contents of RxDR to accumulator
	asl a		; Get rid of the parity bit
	lsr a		; THIS FIXES OUR INPUT PROBLEM!
	tax		;  Also save a copy in index X
	ldy $0004	; Load received offset-in-string to index Y
	sta ($0005),y	; Transfer input character from acc. to memory
	cpx #$0a	; Test for LF
	beq INPUTDONE
			; WAIT! ASCII is a 7 bit code!!
			;  We assumedly get 8 bits from RxDR
			;  what is in bit 8?? Do we need to get rid of it?
			;  apparently the 8th bit is a parity bit, we can
			;  get rid of it...
	inc $0004
	lda #$ff	; Check if bounds of index reached
	cmp $0004
	beq TOOLONG	; If so, abruptly truncate and flag as complete
	jmp RETN	; Otherwise we are all done!
TOOLONG
	lda #$00
	sta ($0005),y	; Abruptly terminate string if buffer limit hit
	lda #$01	; Set input end-of-string hit flag
	sta $0007
	lda #$00
	sta $0004	; Zero input offset
	jmp RETN
INPUTDONE
	iny
	lda #$00
	sta ($0005),y	; Append null to terminate string
	lda #$01	; Set input end-of-string hit flag
	sta $0007
	lda #$00
	sta $0004	; Zero input offset
	jmp RETN
BUFFULL
	lda $d001	; Touch status reg to clear interrupt
	jmp RETN
RETN
	pla		; Restore accumulator from stack
	rti		; Return to normal execution (implicit CLI)
