LET;
;=====================================================
;=====================================================
;=====================================================
; This is the IL of the BASIC (or whatever) language.
; Because of the way macros are implemented by as65,
; labels can't be on the same line as a macro
; invocation, so that's why labels are on separate
; lines.
;
IL		equ	*

;THE IL CONTROL SECTION

START:
	INIT		;INITIALIZE
	NLINE		;WRITE CRLF
	ERRGOTO CO	;where to go after an error
	VINIT		;clear all variables
;
; This is where we jump to get a line of commands or
; a program from the user.
;
CO:
	GETLINE		;WRITE PROMPT AND GET LINE
	TSTL	XEC	;TEST FOR LINE NUMBER
	INSERT		;INSERT IT (MAY BE DELETE)
	IJMP	CO
XEC:
	XINIT		;INITIALIZE

;STATEMENT EXECUTOR

STMT:
	TST	S1,"LET"	;IS STATEMENT A LET
	TSTV	ERRVEC	;YES, PLACE VAR ADDRESS ON AESTK
	TST	ERRVEC,"="	;(This line originally omitted)
	CALL	EXPR	;PLACE EXPR VALUE ON AESTK
	DONE		;REPORT ERROR IF NOT NEXT
	STORE		;STORE RESULT
	NXT	CO	;AND SEQUENCE TO NEXT
	IJMP	STMT
S1:
	TST	S3,"GO"	;GOTO OT GOSUB?
	TST	S2,"TO"	;YES...TO, OR...SUB
	CALL	EXPR	;GET LABEL
	DONE		;ERROR IF CR NOT NEXT
	XFER		;SET UP AND JUMP
S2:
	TST	ERRVEC,"SUB"	;ERROR IF NO MATCH
	CALL	EXPR	;GET DESTINATION
	DONE		;ERROR IF CR NOT NEXT
	SAV		;SAVE RETURN LINE
	XFER		;AND JUMP
S3:
	TST	S8,"PRINT"	;PRINT
S4:
	TST	S7,QUOTE	;TEST FOR QUOTE
	PRS		;PRINT STRING
S5:
	TST	S6A,COMMA	;IS THERE MORE?
	SPC		;SPACE TO NEXT ZONE
	IJMP	S4	;YES JUMP BACK
;
; If a semicolon, don't do anything.
;
S6A:
	TST	S6,SEMICOLON
	IJMP	S4
S6:
	DONE		;ERROR IF CR NOT NEXT
	NLINE
	NXT	CO
	IJMP	STMT
;
; A jump for code too far away for relative branch
;
ERRVEC:
	IJMP	UNKNOWN
;
S7:
	CALL	EXPR
	PRN		;PRINT IT
	IJMP	S5	;IS THERE MORE?
S8:
	TST	S9,"IF"	;IF STATEMENT
	CALL	EXPR	;GET EXPRESSION
	CALL	RELOP	;DETERMINE OPR AND PUT ON STK
	CALL	EXPR	;GET EXPRESSION
	TST	UNKNOWN,"THEN"	;(This line originally omitted)
	CMPR		;PERFORM COMPARISON -- PERFORMS NXT IF FALSE
	IJMP	STMT
S9:
	TST	S12,"INPUT"	;INPUT STATEMENT
S10:
	TSTV	UNKNOWN	;GET VAR ADDRESS (Originally CALL VAR = nonexist)
	INNUM		;MOVE NUMBER FROM TTY TO AESTK
	STORE		;STORE IT
	TST	S11,COMMA	;IS THERE MORE?
	IJMP	S10	;YES

S11:
	DONE		;MUST BE CR
	NXT	CO	;SEQUENCE TO NEXT
	IJMP	STMT
S12:
	TST	S13,"RETURN"	;RETURN STATEMENT
	DONE		;MUST BE CR
	RSTR		;RESTORE LINE NUMBER OF CALL
	NXT	CO	;SEQUENCE TO NEXT STATEMENT
	IJMP	STMT
S13:
	TST	S14,"END"
	FIN
S14:
	TST	S15,"LIST"	;LIST COMMAND
	DONE
	LST
	IJMP	CO
S15:
	TST	S16,"RUN"	;RUN COMMAND
	DONE
	VINIT		;clear variables
	LIT	1	;GOTO line 1
	XFER		;Bob's addition
; EXIT
	IJMP	STMT	;and run!
S16:
	TST	S17A,"NEW"	;clear program
	DONE
	IJMP	START

S17A:
	TST	S17,"EXIT"	;allow them to exit BASIC
	EXIT

S17:
	TST	S17B,"REM"	;REMark.  Skip rest of line
	NXT	CO
	IJMP	STMT
;
; Commands related to saving/restoring programs
; to/from mass storage.
;
S17B:
	if	(XKIM || CTMON65) && DISK_ACCESS
	TST	S17C,"SAVE"
	OPENWRITE
	DLIST
	DCLOSE
	IJMP	CO

S17C:
	TST	UNKNOWN,"LOAD"
	OPENREAD
S17CLP:
	DGETLINE	;get line from file
	TSTL	S17EOL	;no line num means EOL
	INSERT		;put it into the program
	IJMP	S17CLP	;keep going
S17EOL
	DCLOSE		;close disk file
	IJMP	CO	;back to start
	endif
;
; Else, unknown command.
;
UNKNOWN:
	ERR	ERR_SYNTAX	;SYNTAX ERROR

;-----------------------------------------------------
EXPR:
	TST	E0,"-"
	CALL	TERM	;TEST FOR UNARY -.
	NEG		;GET VALUE
	IJMP	E1	;NEGATE IT
E0:
	TST	E1A,"+"	;LOOK FOR MORE
E1A:
	CALL	TERM	;TEST FOR UNARY +
E1:
	TST	E2,"+"	;LEADING TERM
	CALL	TERM
	ADD
	IJMP	E1
E2:
	TST	E3,"-"	;ANY MORE?
	CALL	TERM	;DIFFERENCE TERM
	SUB
	IJMP	E1
E3:
T2:
	RTN		;ANY MORE?
TERM:
	CALL	FACT
T0:
	TST	T1,"*"
	CALL	FACT	;PRODUCT FACTOR.
	MUL
	IJMP	T0
T1:
	TST	T2,"/"
	CALL	FACT	;QUOTIENT FACTOR.
	DIV
	IJMP	T0

UNKNOWNVEC:
	IJMP	UNKNOWN

;
; Factor an expression.  Always test for functions
; first or else they'll be confused for variables.
;
FACT:
	TST	F2A,"FREE()"
	FREE
	RTN
;
; RND() is supposed to have an argument but if none
; was provided, just assume a large value.
;
F2A:
	TST	F2B,"RND("
	TST	F2A1,")"
	LIT	32766
	RANDOM
	RTN
F2A1:
	CALL	FACT	;GET RANGE
	TST	UNKNOWN,")"
	RANDOM
	RTN

F2B:
	TST	F2C,"ABS("
	CALL	FACT	;get value
	TST	UNKNOWN,")"
	ABS
	RTN

F2C:
	TSTV	F0
	IND		;YES, GET THE VALUE.
	RTN
F0:
	TSTN	F1	;NUMBER, GET ITS VALUE.
	RTN
F1:
	TST	F2A,"("	;PARENTHESIZED EXPR.
	CALL	EXPR
	TST	F2,")"
	RTN

F2:
	ERR	ERR_SYNTAX	;ERROR.

RELOP:
	TST	iR0,"="
	LIT	2	;=
	RTN
iR0:
	TST	R4,"<"
	TST	iR1,"="
	LIT	3	;<=
	RTN
iR1:
	TST	R3,">"
	LIT	5	;<>
	RTN
R3:
	LIT	1	;<
	RTN
R4:
	TST	UNKNOWNVEC,">"
	TST	R5,"="
	LIT	6	;>=
	RTN
R5:
	TST	R6,"<"
	LIT	1
	RTN		;(This line originally omitted)
R6:
	LIT	4	;>???
	RTN

ILEND		equ	*
