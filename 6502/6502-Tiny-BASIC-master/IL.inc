		nolist
;=====================================================
; IL.inc
; These are macros for IL instructions
;
XINIT		macro
		db	0
		endm
;
DONE		macro
		db	1
		endm
;
PRS		macro
		db	2
		endm
;
PRN		macro
		db	3
		endm
;
SPC		macro
		db	4
		endm
;
NLINE		macro
		db	5
		endm
;
; My NXT is a bit different in that it takes one
; parameter, which is an address.  If the BASIC
; program is currently running then move to the
; next line and continue execution.  However, if
; in direct mode, jump to the specified IL label.
;
NXT		macro	addr
		db	6
		dw	addr
		endm
;
XFER		macro
		db	7
		endm
;
SAV		macro
		db	8
		endm
;
RSTR		macro
		db	9
		endm
;
CMPR		macro
		db	10
		endm
;
INNUM		macro
		db	11
		endm
;
FIN		macro
		db	12
		endm
;
; ERR is followed by an error number.  The error
; code is printed along with the line number.
; Control is passed to the statement set with
; the ERRGOTO statement.
;
ERR		macro	ecode
		db	13
		dw	ecode
		endm
;
ADD		macro
		db	14
		endm
;
SUB		macro
		db	15
		endm
;
NEG		macro
		db	16
		endm
;
MUL		macro
		db	17
		endm
;
DIV		macro
		db	18
		endm
;
STORE		macro
		db	19
		endm
;
IND		macro
		db	20
		endm
;
LST		macro
		db	21
		endm
;
INIT		macro
		db	22
		endm
;
GETLINE		macro
		db	23
		endm
;
INSERT		macro
		db	24
		endm
;
RTN		macro
		db	25
		endm
;
EXIT		macro
		db	26
		endm
;
LIT		macro	value
		db	27
		dw	value
		endm
;
CALL		macro	addr
		db	28
		dw	addr
		endm
;
; IJMP will set the IL PC to the specified value.
;
IJMP		macro	addr
		db	29
		dw	addr
		endm
;
VINIT		macro
		db	30
		endm
;
; ERRGOTO sets the point in the code where the IL
; interpreter will go after any error.
;
ERRGOTO		macro	addr
		db	31
		dw	addr
		endm
;
TST		macro	addr,string
		db	32
		db	(addr-*)-1
		db	string,0
		endm
;
TSTV		macro	addr
		db	33
		db	(addr-*)-1
		endm
;
TSTL		macro	addr
		db	34
		db	(addr-*)-1
		endm
;
TSTN		macro	addr
		db	35
		db	(addr-*)-1
		endm
;
; FREE returns the amount of free RAM on top of
; the stack.  This is the amount of room the user
; program has available.
;
FREE		macro
		db	36
		endm
;
; RANDOM takes the top item off the stack and
; replaces it with a random number that is
; MOD the initial value.  Ie, if the TOS is
; 42 then RANDOM returns a value from 0 to 41.
;
RANDOM		macro
		db	37
		endm
;
; ABS will replace the top of stack with the 
; absolute value.
;
ABS		macro
		db	38
		endm
;
; OPENREAD opens a file for reading, as in getting
; statements from it.
;
OPENREAD	macro
		db	39
		endm
;
; OPENWRITE opens a file for writing, as in saving
; the current program to it.
;
OPENWRITE	macro
		db	40
		endm
;
; DCLOSE closes any open disk file.
;
DCLOSE		macro
		db	41
		endm
;
; DGETLINE gets one line from the disk file and puts it
; into LINBUFF.
;
DGETLINE	macro
		db	42
		endm
;
; DLIST saves the program to an open disk file.
;
DLIST		macro
		db	43
		endm
;
		list
