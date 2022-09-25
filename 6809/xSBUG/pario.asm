;*****************************************************
; These are the low-level I/O routines to talk to the
; Arduino processor connected to a 6821 PIA.
;
; August 2014, Bob Applegate K2UT, bob@corshamtech.com
;
; Modified 08/08/2015 to build for 6809
;
; Which port bits are used for what:
;
; A0 = Data 0, alternates input/output
; A1 = Data 1, alternates input/output
; A2 = Data 2, alternates input/output
; A3 = Data 3, alternates input/output
; A4 = Data 4, alternates input/output
; A5 = Data 5, alternates input/output
; A6 = Data 6, alternates input/output
; A7 = Data 7, alternates input/output
;
; B0 = Direction bit, always output
; B1 = Write strobe or ACK, always output
; B2 = Read stroke or ACK, always input
;
;----------------------------------------------------
; Bits in the B register
;
DIRECTION	equ	%00000001
PSTROBE		equ	%00000010
ACK		equ	%00000100
;
;----------------------------------------------------
; Constants that might be defined elsewhere and might
; need to be removed
;
;false		equ	0
;true		equ	~false
;----------------------------------------------------
;
; Which slot the parallel board is in.  This needs to
; be set for the system in use.  As long as the user
; programs only call functions in here, no other
; file/application should know which slot the board
; is in.
;
PIASLOT		equ	6
;
; Computed addresses of 6821 registers
;
PIABASE		equ	$e000+(PIASLOT*16)
PIAREGA		equ	PIABASE		;data reg A
PIADDRA		equ	PIABASE		;data dir reg A
PIACTLA		equ	PIABASE+1	;control reg A
PIAREGB		equ	PIABASE+2	;data reg B
PIADDRB		equ	PIABASE+2	;data dir reg B
PIACTLB		equ	PIABASE+3	;control reg B
		code
		page
;*****************************************************
; This is the initialization function.  Call before
; doing anything else with the parallel port.
;
xParInit
;
; Set up the data direction register for port B so that
; the DIRECTION and PSTROBE bits are output.
;
		lda	#0	;select DDR
		sta	PIACTLB	;...for port B
		lda	#DIRECTION | PSTROBE
		sta	PIADDRB
		lda	#4	;select data reg
		sta	PIACTLB
;
; Fall through to set up for writes...
;
		page
;*****************************************************
; This sets up for writing to the Arduino.  Sets up
; direction registers, drives the direction bit, etc.
;
xParSetWrite	lda	#0	;select DDR
		sta	PIACTLA	;...for port A
		lda	#$ff	;set bits for output
		sta	PIADDRA
		lda	#4	;select data reg
		sta	PIACTLA
;
; Set direction flag to output, clear ACK bit
;
		lda	#DIRECTION
		sta	PIAREGB
		rts
		page
;*****************************************************
; This sets up for reading from the Arduino.  Sets up
; direction registers, clears the direction bit, etc.
;
xParSetRead	lda	#0	;select DDR
		sta	PIACTLA	;...for port A
		lda	#$00	;set bits for input
		sta	PIADDRA
		lda	#4	;select data reg
		sta	PIACTLA
;
; Set direction flag to input, clear ACK bit
;
		clr	PIAREGB
		rts
		page
;*****************************************************
; This writes a single byte to the Arduino.  On entry,
; the byte to write is in A.  This assumes ParSetWrite
; was already called.
;
; Destroys A, all other registers preserved.
;
; Write cycle:
;
;    1. Wait for other side to lower ACK.
;    2. Put data onto the bus.
;    3. Set DIRECTION and PSTROBE to indicate data
;       is valid and ready to read.
;    4. Wait for ACK line to go high, indicating the
;       other side has read the data.
;    5. Lower PSTROBE.
;    6. Wait for ACK to go low, indicating end of
;       transfer.
;
xParWriteByte	pshs	a	;save data
Parwl22		lda	PIAREGB	;check status
		anda	#ACK
		bne	Parwl22	;wait for ACK to go low
;
; Now put the data onto the bus
;
		puls	a
		sta	PIAREGA
;
; Raise the strobe so the Arduino knows there is
; new data.
;
		lda	PIAREGB
		ora	#PSTROBE
		sta	PIAREGB
;
; Wait for ACK to go high, indicating the Arduino has
; pulled the data and is ready for more.
;
Parwl33		lda	PIAREGB
		anda	#ACK
		beq	Parwl33
;
; Now lower the strobe, then wait for the Arduino to
; lower ACK.
;
		lda	PIAREGB
		anda	#~PSTROBE
		sta	PIAREGB
Parwl44		lda	PIAREGB
		anda	#ACK
		bne	Parwl44
		rts
		page
;*****************************************************
; This reads a byte from the Arduino and returns it in
; A.  Assumes ParSetRead was called before.
;
; This does not have a time-out.
;
; Preserves all other registers.
;
; Read cycle:
;
;    1. Wait for other side to raise ACK, indicating
;       data is ready.
;    2. Read data.
;    3. Raise PSTROBE indicating data was read.
;    4. Wait for ACK to go low.
;    5. Lower PSTROBE.
;
xParReadByte	lda	PIAREGB
		anda	#ACK	;is their strobe high?
		beq	xParReadByte	;nope, no data
;
; Data is available, so grab and save it.
;
		lda	PIAREGA
		pshs	a
;
; Now raise our strobe (their ACK), then wait for
; them to lower their strobe.
;
		lda	PIAREGB
		ora	#PSTROBE
		sta	PIAREGB
Parrlp1		lda	PIAREGB
		anda	#ACK
		bne	Parrlp1	;still active
;
; Lower our ack, then we’re done.
;
		lda	PIAREGB
		anda	#~PSTROBE
		sta	PIAREGB
		puls	a
		rts
