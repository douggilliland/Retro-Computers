;;;
;;; Retrochallenge Summer 2014
;;; 6502 ROM Monitor
;;;
;;; Last Updated: 2014-JUL-03
;;;

	.feature labels_without_colons
	.include "basic.asm"

;;;************************************************************************
;;; Enhanced 6502 BASIC Integration
;;;************************************************************************

	IRQ_vec = VEC_SV + 2
	NMI_vec = IRQ_vec + $0A

;;;************************************************************************
;;; Macro Definitions.
;;;************************************************************************

;;;
;;; STR <ADDR>
;;;
;;; Print out the null-terminated string located at address <ADDR>
;;;
;;; Modifies: Accumulator, STRLO, STRHI
;;;
.macro	STR	ADDR
	LDA	#<ADDR		; Grab the low byte of the address
	STA	STRLO
	LDA	#>ADDR		; ... and the high byte
	STA	STRHI
	JSR	STOUT		; then call STOUT.
.endmacro

;;;
;;; CRLF
;;;
;;; Print a Carriage Return / Line Feed pair
;;;
;;; Modifies: Accumulator
;;;
.macro	CRLF
	LDA	#CR
	JSR	COUT
	LDA	#LF
	JSR	COUT
.endmacro

;;;************************************************************************
;;; Non-monitor code, e.g. BASIC, utilities, etc., resides
;;; in the bottom 14KB of ROM
;;;************************************************************************

;;; ----------------------------------------------------------------------
;;; Memory Definitions
;;; ----------------------------------------------------------------------

	STRLO	= $de		; Low byte of STRING (used by STR macro)
	STRHI	= $df		; Hi byte of STRING (used by STR macro)
	HTMP	= $e0		; Hex parsing temp
	OPADDRL = $e1		; Addr of current operand (low)
	OPADDRH	= $e2		; Addr of current operand (high)

	OPBYT	= $02a0		; # of bytes parsed in 16-bit operands
	TKCNT	= $02a1		; Count of parsed tokens
	IBLEN	= $02a2		; Input buffer length
	CMD		= $02a3		; Last parsed command
	TKST	= $02a4		; Token start pointer
	TKND	= $02a5		; Token end pointer
	OPBASE	= $02a6		; Operand base
	IBUF	= $02c0		; Input buffer base

;;; ----------------------------------------------------------------------
;;; Constants
;;; ----------------------------------------------------------------------

	CR	= $0A
	LF	= $0D
	BS	= $08
	IBMAX	= $40		; Maxiumum length of input buffer

	PROMPT	= '*'

;;; ----------------------------------------------------------------------
;;; IO Addresses
;;  DGG - Modified for LB-65CXX-1
;;; ----------------------------------------------------------------------

	ACIA	= $8000
	IOST	= ACIA		; ACIA status register
	IOCMD	= ACIA		; ACIA command register
	IOCTL	= ACIA		; ACIA control register
	IORW	= ACIA+1	; ACIA base address, R/W registers

.segment "CODE"
	.org	$C000

	;; BASIC lives here.

;;;************************************************************************
;;; ROM monitor code resides in the top 2KB of ROM
;;;************************************************************************
.segment "MONITOR"
	.org	$FB00

;;; ----------------------------------------------------------------------
;;; Main ROM Entry Point
;;; ----------------------------------------------------------------------

MSTART:	CLI
	CLD
	LDX	#$FF		; Init stack pointer to $FF
	TXS

	;;
	;; Initialize IO
	;;
IOINIT: 
	LDA	#$03		; RESET ACIA
	STA	IOCTL
	LDA	#$15		; Set ACIA to 8N1, 115,200 baud
	STA	IOCTL		;   ($15 = 8 bits, 1 stop bit, 115,200)
	LDA	#0			; TURN OFF LED
	STA	$C000
; DGG - COMMENTED OUT NEXT 2 LINES
;	LDA	#$0B		;   ($0B = no parity, irq disabled)
;	STA	IOCMD		;

	;;
	;; Hard Reset. Initialize page 2.
	;;
HRESET:	LDA	#$02	; Clear page 2
	STA	STRHI		;   (We're borrowing STRHI,STRLO here
	LDA	#$00		;    just becuase it's convenient and
	STA	STRLO		;    they're not being used right now)
	TAY			; Pointer into page 2
@loop:	DEY
	STA	(STRLO),Y
	BNE	@loop

	;; Set up vectors for BASIC.
VECS:	LDA	LABVEC-1,Y
	STA	VEC_IN-1,Y
	DEY
	BNE	VECS

	;; Now jump to BASIC
	JMP	LAB_COLD

;;; ----------------------------------------------------------------------
;;; Welcome the User to the Monitor
;;; ----------------------------------------------------------------------

	;; Start the monitor by printing a welcome message.
WELCM:	STR	BANNR

;;; ----------------------------------------------------------------------
;;; Main Eval Loop - Get input, act on it, and return here.
;;; ----------------------------------------------------------------------

EVLOOP:	CRLF
	LDA	#PROMPT		; Print the prompt
	JSR	COUT

	LDA	#$00		; Reset state by zeroing out
	TAX			;  all registers and temp storage.
	TAY
	STA	IBLEN
	STA	HTMP

	;; NXTCHR is responsible for getting the next character of
	;; input.
	;;
	;; If the character is a CR, LF, or BS, there's special
	;; handling. Otherwise, the character is added to the IBUF
	;; input buffer, and then echoed to the screen.
	;;
	;; This routine uses Y as the IBUF pointer.
NXTCHR:	JSR	CIN		; Get a character, blocking until Carry
	BCC	NXTCHR		;    is set.
	BEQ	BSPACE
	CMP	#CR		; Is it a carriage-return?
	BEQ	PARSE		; Done. Parse buffer.
	CMP	#LF		; Is it a line-feed?
	BEQ	PARSE		; Done. Parse buffer.
	CMP	#BS		; Is it a backspace?
	BEQ	BSPACE		; Yes, handle it.
	CPY	#IBMAX		; Is the buffer full?
	BEQ	NXTCHR		; Yes, ignore it, don't even echo.
	;; It wasn't a CR,LF, or BS
	JSR	COUT		; Echo it
	STA	IBUF,Y		; Store the character into $200,Y
	INY			; Move the pointer
	BNE	NXTCHR		; Go get the next character.

	;; Handle a backspace by decrementing Y (the IBUF pointer)
	;; unless Y is already 0.
BSPACE:	CPY	#0	       ; If Y is already 0, don't
	BEQ	NXTCHR	       ;   do anything.
	DEY
	LDA	#BS
	JSR	COUT
	JMP	NXTCHR


;;; ----------------------------------------------------------------------
;;; Parse the input buffer (IBUF) by tokenizing it into a command and
;;; a series of operands.
;;;
;;; When the code reaches this point, Y will hold the length of the
;;; input buffer.
;;; ----------------------------------------------------------------------

PARSE:	TYA			; Save Y to IBLEN.
	STA	IBLEN
	BEQ	EVLOOP		; No command? Short circuit.

	;; Clear operand storage
	LDY	#$10
	LDA	#$00
@loop:	STA	OPBASE,Y	; Clear operands.
	DEY
	BPL	@loop

	;; Reset parsing state
	LDX	#$FF		; Reset Token Pointer
	LDA	#$00
	STA	TKCNT		; Number of tokens we've parsed
	STA	CMD		; Clear command register.
	TAY			; Reset IBUF pointer.

	;;
	;; Tokenize the command and operands
	;;

	;; First character is the command.
	LDA	IBUF,Y
	STA	CMD

	;; Now start looking for the next token. Read from
	;; IBUF until the character is not whitespace.
SKIPSP:	INY
	CPY	IBLEN		; Is Y now pointing outside the buffer?
	BCS	EXEC		; Yes, nothing else to parse

	LDA	IBUF,Y
	CMP	#' '
	BEQ	SKIPSP		; The character is a space, skip.

	;; Here, we've found a non-space character. We can
	;; walk IBUF until we find the first non-digit (hex),
	;; at which point we'll be at the end of an operand

	STY	TKST		; Hold Y value for comparison

TKNEND:	INY
	CPY	IBLEN		; >= IBLEN?
	BCS	TKSVPTR
	LDA	IBUF,Y

	CMP	#' '		; Is it a space?
	BNE	TKNEND		; No, keep going.
	;; Yes, fall through.

	;; Y is currently pointing at the end of a token, so we'll
	;; remember this location.
TKSVPTR:
	STY	TKND

	;; Now we're going to parse the operand and turn it into
	;; a number.
	;;
	;; This routine will walk the operand backward, from the least
	;; significant to the most significant digit, placing the
	;; value in OPBASE,X and OPBASE,X+1 as it "fills up" the value

	LDA	#$02
	STA	OPBYT

	;; Token 2 Binary
TK2BIN:	INX
	;; low nybble
	DEY			; Move the digit pointer back 1.
	CPY	TKST		; Is pointer < TKST?
	BCC	TKDONE		; Yes, we're done.

	LDA	IBUF,Y		; Grab the digit being pointed at.
	JSR	H2BIN		; Convert it to an int.
	STA	OPBASE,X	; Store it in OPBASE + X

	;; high nybble
	DEY			; Move the digit pointer back 1.
	CPY	TKST		; Is pointer < TKST?
	BCC	HIBCHK		; We might be done

	LDA	IBUF,Y		; Grab the digit being pointed at.
	JSR	H2BIN		; Convert it to an int.
	ASL			; Shift it left 4 bits.
	ASL
	ASL
	ASL
	ORA	OPBASE,X	; OR it with the value from the
	STA	OPBASE,X	;   last digit, and re-store it.

	;; Next byte - only if we're parsing the first two
	;; operands, which are treated as 16-bit values.
	;;
	;; (Operands 2 through F are treated as 8-bit values)

HIBCHK:	LDA	TKCNT		; If TKCNT is > 2, we can skip
	CMP	#$02		;   the low byte
	BCS	TKDONE

	DEC	OPBYT		; Have we done 2 bytes?
	BNE	TK2BIN		; If not, do next byte

	;; We've finished converting a token.

TKDONE:	INC	TKCNT		; Increment the count of tokens parsed

	CMP	#$10		; Have we hit our maximum # of
				;    operands? (16 max)
	BCS	EXEC		; Yes, we're absolutely done, no more.

	LDA	TKND		; No, keep going. Restore Y to end of
	TAY			;   token position
	CPY	IBLEN		; Is there more in the buffer?
	BCC	SKIPSP		; Yes, try to find another token.

	;; No, the buffer is now empty. Fall through to EXEC

;;; ----------------------------------------------------------------------
;;; Execute the current command with the decoded operands.
;;; ----------------------------------------------------------------------

EXEC:	LDX	#$00		; Reset X

	LDA	CMD
	CMP	#'D'
	BEQ	@nolf
	CRLF			; CRLF (unless the command is DEP)
@nolf:	LDA	CMD		; Have to reload CMD, CRLF will mess
				;    with it.
	CMP	#'H'		; Help requires no arguments,
	BEQ	HELP		;    so comes first.
	CMP	#'Q'		; 'Quit' just jumps to BASIC warm
	BEQ	QUIT			; start

	LDA	TKCNT		; Now we check operand count.
	BEQ	@err		; No operands? Error.

	LDA	CMD		; Dispatch to the appropriate command.
	CMP	#'E'
	BEQ	EXDEP
	CMP	#'D'
	BEQ	EXDEP
	CMP	#'G'
	BEQ	GO
	;; No idea what to do, fall through

@err:	LDA	CMD		; More spaghetti code to deal with the
	CMP	#'D'		;    missing CRLF if the command was 'D',
	BNE	@nolf2		;    vs. all other commands.
	CRLF
@nolf2:	JSR	PERR
	JMP	EVLOOP

;;; HELP command
HELP:	STR	HELPS
	JMP	EVLOOP

;;; QUIT command
QUIT:	JMP	LAB_1274	; BASIC Warm Start.

;;; GO command
GO:	JMP	(OPBASE)	; Just jump to the appropriate address

;;; EXAMINE and DEPOSIT commands share code, and start the same way.
EXDEP:	LDA	OPBASE		; Transfer the address we want to load
	STA	OPADDRL		;    from to OPADDRL
	LDA	OPBASE+1	;
	STA	OPADDRH		;    and OPADDRH

	LDA	CMD		; Are we in DEPOSIT?
	CMP	#'D'
	BEQ	DEP		; Yes. Go there.

	;; Examine. How many operands?
	LDA	TKCNT
	CMP	#$02		; Two?
	BEQ	PRANGE		; Print a range.
	;; If just one...
	JSR	PRADDR		; Print the address
	LDA	(OPADDRL,X)	; Get data pointed at by address

	JSR	PRBYT		; Print it.
	JMP	EVLOOP		; Done.

;;; DEPOSIT command
DEP:	LDA	TKCNT		; We need at least 2 arguments
	CMP	#$02		;   (but more is OK)
	BCC	@err		; If not, error out.

	;; Now we enter a loop, parsing each argument from
	;; OPBASE+2 to OPBASE+TKCNT
	LDY	#$02
	DEC	TKCNT
	LDA	OPBASE,Y
	STA	(OPADDRL,X)
	INY
	INY
	INC	OPADDRL
	BNE	@loop
	INC	OPADDRH
@loop:	LDA	OPBASE,Y	; Grab the data to store
	STA	(OPADDRL,X)	; Store it
	INY
	DEC	TKCNT
	BEQ	@done
	INC	OPADDRL
	BNE	@loop
	INC	OPADDRH
	JMP	@loop


	;; We don't print anything back to the console on deposit
	;; because we want to make it easy to pipe in data from a
	;; serial console. All we do is jump back and print the prompt
	;; again. Silence means success.
@done:	JMP	EVLOOP		; Done.
@err:	CRLF
	JSR	PERR
	JMP	EVLOOP

;;; Print a range
PRANGE:
	;; Do a 16-bit signed comparison of START and END addresses
	;; to make sure the range is valid. If it's not, error out and
	;; don't continue.
	SEC
	LDA	OPBASE+3	; Compare high bytes
	SBC	OPBASE+1
	BVC	@l1
	EOR	#$80
@l1:	BMI	@err
	BVC	@l2
	EOR	#$80
@l2:	BNE	@start
	LDA	OPBASE+2	; Compare low bytes
	SBC	OPBASE
	BCC	@err		; START is > END, no good.

	;; Now we know the range is valid. We can actually print the
	;; contents of memory between [OPBASE,OPBASE+1] and
	;; [OPBASE+2,OPBASE+3]

@start:	JSR	PRADDR		; Print the starting address
@loop:	LDA	(OPADDRL,X)	; Grab the contents of OPADDRL,H
	JSR	PR1B		; Print it

	;; After printing each byte, check to see if we're at the end
	;; of the range. If we are, we're done. Otherwise, continue.
	LDA	OPBASE+3	; Compare high
	CMP	OPADDRH
	BNE	@next
	LDA	OPBASE+2	; Compare low
	CMP	OPADDRL
	BEQ	@done

	;; Now we increment OPADDRL,H so we can get the next location
	;; in memory.
@next:	INC	OPADDRL		; Read next location in memory.
	BNE	@endck		; If L was incremented to 00,
	INC	OPADDRH		;   inc H too.

	;; Now we check to see if we're at the end of a line. We want
	;; to insert a carriage return after every address which ends
	;; in F (e.g. 100F, 3F, 1F0F, whatever) so we get consistent
	;; starting addresses along the left-hand side of the
	;; terminal.
@endck:	LDA	OPADDRL
	AND	#$0F
	BNE	@loop		; No CRLF/ADDR needed
	CRLF
	JMP	@start		; Restart at new address.

@done:
	JMP	EVLOOP


@err:	JSR	PERR
	JMP	EVLOOP

;;; Print a space and the byte in A
PR1B:	PHA
	LDA	#' '
	JSR	COUT
	PLA
	JSR	PRBYT
	RTS

;;; ----------------------------------------------------------------------
;;; Print the last stored address as four consecutive ASCII hex
;;; characters.
;;;
;;; Input:  EMEMH/EMEML
;;; Output: ACIA
;;; ----------------------------------------------------------------------

PRADDR:	LDA	OPADDRH 	; Load the byte at OPBASE+1.
	JSR	PRBYT		; Print it out.
	LDA	OPADDRL		; Load the byte at OPBASE.
	JSR	PRBYT		; Print it out.
	LDA	#':'		; Print a ": " separator.
	JSR	COUT
	LDA	#' '
	JSR	COUT
	RTS			; Return.

;;; ----------------------------------------------------------------------
;;; Check to see if the value in A is a hex digit.
;;; Input: Accumulaotr
;;; Output: C - Clear if digit, set if not digit.
;;; ----------------------------------------------------------------------

ISNUM:	CMP	#'0'		; < '0'?
	BCC	@fail		; It's not a digit.
	CMP	#'9'+1		; <= '9'?
	BCC	@succ		; Yup, it's a digit.
	CMP	#'A'		; < 'A'
	BCC	@fail		; It's not a digit.
	CMP	#'F'+1		; <= 'F'?
	BCC	@succ		; Yup, it's a digit.
	;; Fall through to failure
@fail:	SEC
@succ:	RTS

;;; ----------------------------------------------------------------------
;;; Check to see if the value in A is printable.
;;; Input: Accumulator
;;; Output: C - Clear if printable, Set if not printable
;;; ----------------------------------------------------------------------

PRTBLE:	CMP	#$20		; < space?
	BCC	@fail		; It's not printable
	CMP	#$7F		; < DEL?
	BCC	@succ		; Yes, it's printable.
	;; Fall through to failure
@fail:	SEC
@succ:	RTS

;;; ----------------------------------------------------------------------
;;; Convert a single ASCII hex character to an unsigned int
;;; (from 0 to 16).
;;;
;;; Input:  Accumulator
;;; Output: Accumulator
;;; ----------------------------------------------------------------------

H2BIN:	JSR	ISNUM		; If this isn't a valid digit, error out.
	BCS	@err

	SEC
	SBC	#'0'		; Subtract '0' from the digit.
	CMP	#10		; Is the result <= 10? Digit was 0-9.
	BCC	@done		; We're done.

	CMP	#23		; Is this a hex digit? (<= 'F' - 30)
	BCS	@err		; No, it's not a hex digit.
	SEC
	SBC	#7		; OK, it's a hex digit.
@done:	RTS
@err:	CRLF
	JSR	PERR
	RTS

;;; ----------------------------------------------------------------------
;;; Parse Error
;;;
;;; Abort the current operation, print an error prompt ("?") and
;;; get next line.
;;; ----------------------------------------------------------------------

PERR:	LDA	#'?'
	JSR	COUT
	JMP	EVLOOP
	RTS

;;; ----------------------------------------------------------------------
;;; Print the content of the accumulator as two consecutive ASCII
;;; hex characters.
;;;
;;; Input:  Accumulator
;;; Output: ACIA
;;; ----------------------------------------------------------------------

PRBYT:	PHA			; We'll need A later.
	LSR			; Shift high nybble to low nybble
	LSR
	LSR
	LSR
	JSR	PRHEX		; Print it as a single hex char
	PLA			; Get A back
	;; Fall through to PRHEX

;;; ----------------------------------------------------------------------
;;; Print the low nybble of of the accumulator as a single
;;; ASCII hex character.
;;;
;;; Input:  Accumulator
;;; Output: ACIA
;;; ----------------------------------------------------------------------

PRHEX:	AND	#$0F		; Mask out the high nybble
	CMP	#$0A		; Is it less than 10?
	BCC	@done
	ADC	#6
@done:	ADC	#'0'
	JSR	COUT
	RTS

;;; ----------------------------------------------------------------------
;;; Print the character in the Accumulator to the ACIA's output
;;; ----------------------------------------------------------------------


COUT:	PHA			; Save accumulator
@loop:	LDA	IOST		; Is TX register empty?
	AND	#$02
	cmp #$02
	BNE	@loop		; No, wait for empty
	PLA			; Yes, restore char & print
	STA	IORW
	RTS			; Return

;;; ----------------------------------------------------------------------
;;; Read a character from the ACIA and put it into the accumulator
;;; ----------------------------------------------------------------------

	;; Rather ugly, but Enhanced BASIC requires this subroutine to
	;; return immediately rather than block polling for data, so...

CIN:
	LDA	IOST
	AND	#$01		; Is RX register full?
	CMP	#$01
	BNE	@nochr		; No, wait for it to fill up.
	LDA	IORW		; Yes, load character.
	;;
	;; If the char is 'a' to 'z', inclusive, mask to upper case.
	;;
	CMP	#'a'		; < 'a'?
	BCC	@done		; Yes, done.
	CMP	#'{'		; >= '{'?
	BCS	@done		; Yes, done.
	AND	#$5f		; No, convert lower case -> upper case,
@done:
	SEC			; Flag byte received, for BASIC
	RTS			; and return.
@nochr:	CLC
	RTS

;;; ----------------------------------------------------------------------
;;; Print the null-terminated string located at STRLO,STRHI
;;; ----------------------------------------------------------------------

STOUT:	LDY	#$00		; Initialize string pointer
@loop:	LDA	(STRLO),Y	; Get character
	BEQ	@done		; If char == 0, we're done
	JSR	COUT		; Otherwise, print it
	INY			; Increment pointer
	BNE	@loop		; Continue
@done:	RTS			; Return

STUB_SAVE:
STUB_LOAD:
	RTS

;;; ----------------------------------------------------------------------
;;; Data
;;; ----------------------------------------------------------------------

;;; Vectors used by EhBASIC
LABVEC:	.word	CIN
	.word	COUT
	.word	STUB_SAVE
	.word	STUB_LOAD

;;; Strings
BANNR:	.byte	"RETROCHALLENGE 2014 ROM MONITOR",0
HELPS:	.byte	"COMMANDS ARE:",CR,LF
	.byte	"H                             HELP",CR,LF
	.byte	"E <addr> [<addr>]             EXAMINE",CR,LF
	.byte	"D <addr> <val> [<val> ...]    DEPOSIT",CR,LF
	.byte	"G <addr>                      GO",CR,LF,0

;;;************************************************************************
;;; Reset and Interrupt vectors
;;;************************************************************************
.segment    "VECTORS"

	.org	$FFFA
	.word	MSTART		; NMI vector
	.word	MSTART		; Reset vector
	.word	MSTART		; IRQ vector
