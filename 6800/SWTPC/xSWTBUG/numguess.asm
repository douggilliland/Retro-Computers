;=====================================================
; Number guess program written 09/03/2014 by 
; Bob Applegate, bob@corshamtech.com
;
; When I interviewed at Microsoft in the mid 1980s,
; I was passed from person to person, each of whom
; asked a lot of questions and offered challenges.
;
; One of the people took out a pile of dimes, put 
; them on his desk and said this (more or less
; quoting):
;
;    "There are ten dimes in the pile.  I'm thinking of
;    a number from 1 to 100.  If you want to guess the 
;    number, there are rules:
;
;    "If you guess the number, you get to keep all the
;    dimes remaining in the pile.
;
;    "For each incorrect guess, I take away two dimes.
;
;    "If you run out of dimes and you still haven't
;    guessed the number, you have to give me two dimes
;    out of your pocket for each incorrect guess.
;
; "Would you play the game or not, and why."
;
; This game is a 6800 version of that interview
; question.  :-)
;
; Known bugs:
;
;    (1) If a player makes more than 99 incorrect
;        guesses, the dimes count is displayed wrong.
;
;    (2) If a player makes more than 255 incorrect
;        guesses, the dimes count is wrong.
;
;=====================================================
; Useful stuff in SWTBUG
;
	if	~IN_SWTBUG
PDATA1		equ	$e07e
OUT2HS		equ	$e0ca
;INCH		equ	$e1ac	;use my routine instead
;OUTCH		equ	$e1d1	;ditto
;
;=====================================================
; ASCII constants
;
EOT		equ	$04
BEL		equ	$07
BS		equ	$08
LF		equ	$0a
CR		equ	$0d
DEL		equ	$7f
	endif
;
;=====================================================
; Other stuff, including build options
;
BUFFSIZE	equ	4
;
	if	~IN_SWTBUG
false		equ	0
true		equ	~false
	endif
;
; This outputs lots of debug info, mainly useful for
; me to debug with.
;
DEBUG		equ	false
		page
;=====================================================
; Data!  Woohoo!
;
		bss
	if	IN_SWTBUG
		org	$A090
	else
		org	$0000
	endif
number		ds	1	;the random number
guess		ds	1	;their guess
dimes		ds	1	;how many dimes are left
buffer		ds	BUFFSIZE
		page
;=====================================================
; The actual program.  Woohoo!
;
		code
	if	~IN_SWTBUG
		org	$0100
	endif
NumGuess	ldx	#intro
		jsr	PDATA1
		lda	#10
		sta	dimes
clr_rnd		clra
		sta	number	;a legal starting value
;
; This waits for a key from the user.  While waiting,
; keep incrementing the random number.  Ie, the value
; depends on how quickly they press a key.  Pretty darn
; close to random, and probably a lot more random than
; many of the "random" number generators.
;
y_or_n		inc	number	;bump random number
		lda	number
		beq	y_or_n	;zero not valid
		cmpa	#100
		bgt	clr_rnd	;reset if > 100
;
		jsr	kbhit	;key waiting yet?
		bcc	y_or_n	;nope, keep randomizing
;
; A key is waiting
;
		jsr	getch	;get key
		cmpa	#'Y'
		beq	play
		cmpa	#'y'
		beq	play
		cmpa	#'n'
		beq	wimp
		cmpa	#'N'
		bne	y_or_n
;
; They pressed N or n.
;
wimp		ldx	#nomsg
		jsr	PDATA1
		ldx	#nextguy
		jsr	PDATA1
	if	IN_SWTBUG
		jmp	ExtCmd
	else
		bra	NumGuess
	endif
;
; They want to play a game!  How about thermonuclear war?
;
play		ldx	#yesmsg
		jsr	PDATA1
;
; number now contains a random number from 1 to 100.
;
gotrnd
	if	DEBUG
		ldx	#dbg1	;print number for them
		jsr	PDATA1
		ldx	#number
		jsr	OUT2HS
		jsr	crlf
	endif
;
; Collect their input
;
gameloop	lda	dimes	;positive or negative?
		bpl	posdime
;
; Show how many dimes they owe us!
; "You owe me X dimes!  "
;
		ldx	#owe1
		jsr	PDATA1
		jsr	NegAsPos	;print number
		ldx	#owe2
		jsr	PDATA1
		bra	cont
;
; There is a positive number of dimes so print a more
; polite message.  "There are X dimes left.  "
;
posdime		ldx	#pos1
		jsr	PDATA1
		jsr	printDimes
		ldx	#pos2
		jsr	PDATA1
;
cont		ldx	#prompt
		jsr	PDATA1
		jsr	getline	;get their guess
		jsr	todecimal
		stab	guess
	if	DEBUG
		ldx	#dbg2	;show their input
		jsr	PDATA1
		ldx	#guess
		jsr	OUT2HS
		jsr	crlf
	endif
;
; Now see if they got it or not.  Offer some
; hints if not.
;
		lda	guess
		cmpa	number
		beq	equal	;they won!
		blt	less	;they guessed too low
;
; They guessed too high.
;
		ldx	#high_msg
wrong		jsr	PDATA1
		dec	dimes	;that'll cost them twenty cents!
		dec	dimes
		bra	gameloop
;
; Guessed too low.
;
less		ldx	#low_msg
		bra	wrong
;
; They got it!  Getting it is good, but see if they
; get any money or if they owe me.
;
equal		ldx	#perfect
		jsr	PDATA1
;
; Decide which message based on whether they have
; any dimes left or not.
;
		lda	dimes
		bne	notzero
;
; They broke even.
;
		ldx	#evenmsg
		jsr	PDATA1
		jmp	NumGuess
;
notzero		bmi	lostbig
;
; They won!
;
		ldx	#wonmsg
		jsr	PDATA1
		jsr	printPosDimes
		ldx	#wonmsg2
		jsr	PDATA1
		jmp	NumGuess
;
; They lost
;
lostbig		ldx	#lostmsg
		jsr	PDATA1
		jsr	NegAsPos
		ldx	#lostmsg2
		jsr	PDATA1
		jmp	NumGuess
;
;=====================================================
; Convert the number in the buffer to a decimal value
; and return with it in A.  If bad input, this will
; return 0.
;
todecimal	ldx	#buffer
		clrb		;B contains return value
todec_1		lda	0,x	;get next digit
		cmpa	#EOT	;end?
		beq	todec_end
;
; See if it's a digit and convert to binary in A if so
;
		cmpa	#'0'
		blt	todec_bad	;bad input
		cmpa	#'9'
		bgt	todec_bad
		suba	#'0'	;to binary
		psha		;and save
;
; Multiple the existing number in B by 10.
;
		aslb		;*2
		tba		;save
		aslb		;*4
		aslb		;*8
		aba		;*10 in A
		tab		;back into B
;
; Now add in the new value
;
		pula
		aba
		tab
		inx		;move to next digit
		bra	todec_1
;
; End of input, return value.
;
todec_end	tba
		rts
;
; Bad input, so return 0.  This will result in an
; error message.
;
todec_bad	clra
		rts
;
;=====================================================
; Outputs a CR/LF.  Modifies A.
;
	if	~IN_SWTBUG
crlf		lda	#CR
		jsr	putch
		lda	#LF
		jmp	putch
	endif
;
;=====================================================
; This gets a line from the user and stores it in the
; buffer.  Imposes a size limit.  Returns when the user
; hits ENTER.
;
; Modifies A, B and X.
;
getline		ldx	#buffer	;where to put text
		clrb		;clear char count
getlchar	jsr	getch
		cmpa	#CR
		beq	getleol	;branch if end of line
;
		cmpa	#DEL	;delete?
		beq	getdel
		cmpa	#BS	;backspace?
		bne	getndel
;
; Erase the last character
;
getdel		cmpb	#0	;is buffer empty?
		beq	getlchar
		dex		;back up one
		decb		;one less char
;
; Erase old character with the old backspace-space-backspace
; sequence.
;
		jsr	putch	;move back
		lda	#' '
		jsr	putch	;erase last char
		lda	#BS
		jsr	putch	;and move back again
		bra	getlchar
;
; See if it's a legal character.
;
getndel		cmpa	#' '	;lowest allowed
		blt	getlchar
		cmpa	#'~'
		bgt	getlchar
;
; Is there room?
;
		cmpb	#BUFFSIZE-1
		beq	getlchar
;
; Finally, put the character into the buffer
; and echo it.
;
		sta	0,x
		inx
		incb
		jsr	putch
		bra	getlchar
;
; They hit ENTER.  Terminate the buffer and return.
; I stuck with the Moto tradition and used EOT ($04)
; to mark the end of the line.
;
getleol		lda	#EOT
		sta	0,x	;terminate line
		jmp	crlf
		page
;
;=====================================================
; This prints the number as a positive, and without
; the negative sign.  This only works if the number
; is positive.
;
printPosDimes	lda	dimes
		bra	positive
;
;=====================================================
; This displays the value in dimes as a decimal number.
; This value can range from 10 to -90, so this code
; must deal with negative numbers.
;
printDimes	lda	dimes
		bpl	positive	;it's a positive number
;
; Invert bits and add one to negative number to make
; it positive.  Also print the minus sign.
;
		lda	#'-'
		jsr	putch
;
; This prints a negative number as positive, but does
; not print the minus sign in front.  Handy for when
; you specifically tell someone the value is negative.
;
NegAsPos	lda	dimes
		coma		;make positive
		inca		;adjust
;
; Now we have a positive number to print.
;
positive	cmpa	#10
		blt	notens
		clrb		;clear 10s counter
;
cnt_10		suba	#10
		incb
		cmpa	#9
		bgt	cnt_10
;
		psha
		tba
		adda	#'0'
		jsr	putch
		pula
;
; The value in A are ones, so print it.
;
notens		adda	#'0'
		jmp	putch
;
;=====================================================
; Text messages and other constants
;
intro		db	CR,LF,LF,LF
		db	"I have a stack of ten dimes ($1) and am"
		db	CR,LF
		db	"thinking of a number from 1 to 100.  If"
		db	CR,LF
		db	"you play the game, then each time you guess"
		db	CR,LF
		db	"wrong I'm going to take away two dimes."
		db	CR,LF
		db	"If you guess right, you get the remaining"
		db	CR,LF
		db	"dimes.  If the pile runs out, then you have"
		db	CR,LF
		db	"to take dimes out of your pocket and pay me"
		db	CR,LF
		db	"for each incorrect guess."
		db	CR,LF,LF
		db	"Do you want to play or not (Y or N)? ",EOT
;
nextguy		db	CR,LF
		db	"Yeah, you looked kind of whimpy!  Step aside and "
		db	"give someone else a chance."
		db	CR,LF,LF,EOT
;
prompt		db	"Enter your guess, from 1 to 100: ",EOT
;
	if	DEBUG
dbg1:		db	"Computer's number: $",EOT
dbg2:		db	"User input: $",EOT
	endif
;
yesmsg		db	"Yes",CR,LF,EOT
nomsg		db	"No",CR,LF,EOT

high_msg	db	"Sorry, you guessed too high.",EOT
low_msg		db	"Sorry, you guessed too low.",EOT
perfect		db	CR,LF,LF
		db	"You got it!!!  Congratulations!"
		db	CR,LF,EOT
wonmsg		db	"You get to keep ",EOT
wonmsg2		db	" (virtual) dimes :-)"
		db	CR,LF,LF,EOT
lostmsg		db	"Unfortunately, you owe me ",EOT
lostmsg2	db	" real dimes.  :-("
		db	CR,LF,LF,EOT
evenmsg		db	"You used all ten dimes, so you win "
		db	"nothing, but you also don't owe anything!"
		db	CR,LF,LF,EOT
owe1		db	CR,LF
		db	"You owe me ",EOT
owe2		db	" dimes!  ",EOT
pos1		db	CR,LF
		db	"There are ",EOT
pos2		db	" dimes left.  ",EOT

		include	"console.asm"

