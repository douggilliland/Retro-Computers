;RUN
;BASIC-E/65 Run Time Interpreter
;Version 2.05-A
;COPYRIGHT - RICHARD A. LEARY - 1982
;released:	30 october 1982
;last revision:
;	3 february 1983
;		corrected sle error
;	5 march 1983
;		corrected conrde error
;	17 november 1983
;		corrected error number in EX92
;		corrected line count in OUTMSG
;	28 july 1985
;		corrected or error
;		made page zero 6510 compatible
;	2 april 2008
;		reformatted for TASM and ASM211
;		moved multiple variables out of page zero
;external references
BOOT	=	$100		;boot entry
PEM	=	$103		;pem entry
DFLFCB	=	$107		;default fcb
BUF	=	$128		;default buffer
TEA	=	$800		;load address
;fixed parameters and constants
;CAUTION: When a register is set to TRUE, Z is set to 0 (i.e. NE).  If a
;register is set to FALSE then Z is set to 1 (i.e. EQ).
TRUE	=	$FF
FALSE	=	0
;ascii characters
TAB	=	9		;tab
LF	=	10		;linefeed
CR	=	13		;return and eol
EOF	=	26		;eof char
semico	=	59		;semicolon
;other parameters
NUMFIL	=	20		;max number user files
PRBFLN	=	132		;print buffer length
NRSTCK	=	24*4		;stack size * 4
MAXPSN	=	8		;max number tab positions (132 col paper)
;basic-e/65 opcodes
DAT	=	51
ILS	=	28
DEF	=	94
BRS	=	54
BRC	=	55
PRO	=	30
CON	=	46
;page zero variables
;all non-zero initial values are shown as i=xxxx where xxxx is the initial
;value. PL/M name is shown if significantly different.
	*=	2
EXH				;hold in ex81 and ex82
	*=	*+2
;console output variables
WTCHLD				;hold in wrttcn [write$to$console]
	*=	*+2
;file processing variables
RCRPNT				;record$pointer
	*=	*+2
DOBF				;buffer in disk$open
	*=	*+2
WTFPNT				;point in wrtofl (write$to$file)
	*=	*+2
dcbpnt				;dcb pointer
	*=	*+2
;generalized input variables
CONBPT				;conbuffptr
	*=	*+2
GTSTMP				;temp in get$string$field
	*=	*+2
;string processing variables
NWSTAD				;newstring address
	*=	*+2
PTRADR				;ptraddr in store
	*=	*+2
SPTR				;ptr in store
	*=	*+2
FRSTST				;firststring
	*=	*+2
SCNDST				;secondstring
	*=	*+2
SSTMP				;tempa in strseg [string$segment]
	*=	*+2
;array addressing variables
ARYADR				;array address
	*=	*+2
;dynamic storage allocation variables
SPACE
	*=	*+2
DSPNT
	*=	*+2
DSTMP
	*=	*+2
DSTMP1
	*=	*+2
DSTMP2
	*=	*+2
DSTMP3				;temp in unlink
	*=	*+2
;for move
MFROM				;from in move
	*=	*+2
MTO				;to in move
	*=	*+2
;fixed point accumulators
SX				;secondary
	*=	*+2
PX				;primary
	*=	*+4
FN				;n for fill
	*=	*+2
TRIGS				;trig function sign
	*=	*+1
LSB				;save lsb in int
	*=	*+1
SRPNT				;series evaluation pointer
	*=	*+2
SRCNT				;series evaluation counter
	*=	*+1
TY				;temp in fltout
	*=	*+1
DVZERO				;divide by zero flag
	*=	*+1
OVERFL				;overflow flag
	*=	*+1
ME				;memory pointer
	*=	*+2
SL				;store memory pointer
	*=	*+2
CNVIND				;number convert buffer index
	*=	*+1
SAVPR				;save for PR in ADPRSC
	*=	*+1
;input work area
NE				;exponent
	*=	*+1
DPFLG				;decimal point flag
	*=	*+1
DPOFF				;dp offset
	*=	*+1
NESFLG				;exponent sign flag
	*=	*+1
NS				;sign
	*=	*+1
;primary accumulator
PE				;exponent
	*=	*+1
PM				;mantissa
	*=	*+3
PS				;sign
	*=	*+1
PC				;carry
	*=	*+1
PR				;rounding
	*=	*+1
;secondary accumulator
SE				;exponent
	*=	*+1
SM				;mantissa
	*=	*+3
SS				;sign
	*=	*+1
;product staging area
QE				;exponent
	*=	*+1
QM				;mantissa
	*=	*+3
;other
SGNCMP				;primary . secondary sign comparison
	*=	*+1
;basic-e registers
RA				;address of register a
	*=	*+2
RB				;address of register b
	*=	*+2
RC				;address of register c
	*=	*+2
SB				;stack bottom
	*=	*+2
ST				;stack top
	*=	*+2
MPR				;base address of prt
	*=	*+2
MDA				;base address of data area
	*=	*+2
MCD				;base of code area
	*=	*+2
CURLIN				;current source line
	*=	*+2
DTARPT				;dataareaptr, current location in data area
	*=	*+2
MBASE				;beginning of free storage area
	*=	*+2
IBASE				;basein initmm [initmem]
	*=	*+2
PRBUFF				;printbuffer (index to buffer)
	*=	*+1
FILADR				;fileaddr, current fcb pointer base
	*=	*+2
EOFADR				;eofaddr
	*=	*+2
BUFEND				;buffer$end
	*=	*+2
INFSAT				;temp in infsa
	*=	*+1
SEDPTR				;pointer (ptr) in sedaad
	*=	*+2
SEDAAT				;temp in set$data$addr (sedaad)
	*=	*+1
BUFFER				;address of diskbuffer
	*=	*+2
FCB				;address of fcb
	*=	*+2
TIME4T				;temp in times4
	*=	*+1
LCLSED				;local seed for random number
	*=	*+2
BASE				;base address in build
	*=	*+2
AP				;accum index
	*=	*+1
TBASE				;temp in build
	*=	*+2
LZ
;ENTRY POINT
	*=	TEA
	JMP	BUILD
;special i/o routines
	JMP	SETLST
	JMP	CLRLST
	JMP	DOPEM
	JMP	DOSIM
;special i/o variables
AREG	.byte	0		;a
YREG	.byte	0		;y
XREG	.byte	0		;x
LSTFLG	.byte	FALSE		;list flag
;copyright notice
	.byte	"COPYRIGHT - RICHARD"
	.byte	" A. LEARY - 2008"
;general storage area - variables that were in page zero - section
;name is same as that used for remaining page zero variables
;file processing variables
EOFRA	.word	0		;eof location for ra
EOFRB	.word	0		;same for rb
BLKSZE	.word	0		;blocksize
BYTSWR	.word	0		;bytes written
FRSFLD	.byte	0		;firstfield
extsze	.byte	0		;extent size flag (0=16K, 128=8K)
dfldrv	.byte	0		;default drive
;generalized input variables
RERDAD	.word	0		;rereadaddr
INPTYP	.byte	0		;inputtype
INPIND	.byte	0		;inputindex
INPPTR	.word	0		;inputptr
;string processing variables
FRSTLN	.byte	0		;firststring length
SCSTLN	.byte	0		;secondstring length
NWSTLN	.byte	0		;newstring length
;array addressing variables
ASIZE	.word	0		;array size in clcrow
SAVERA	.word	0		;save for ra
SAVERB	.word	0		;save for rb
CI	.byte	0		;i in clcrow
CLCT	.byte	0		;temp in clcrow
LOCATN	.word	0		;location in clcsub
NUMDIM	.byte	0		;number dimensions
;dynamic storage allocation variables
NBYTES	.word	0
HOLD	.word	0
TOTAL	.word	0
AVLLT2	.word	0		;nbytes+5 in avll
AVLLT	.word	0		;temp in avll
;for move
MCOUNT	.word	0		;count in move
;data for BUILD
CURCHR	.byte	0		;current char from .int file
BUFF	.byte	0		;index for .int file
OFFSET	.word	0		;offset in build	
;convert lowercase to upper
lwrupr	cmp	#'a'		;see if under a
	bcc	notlwr		;skip if is
	cmp	#'z'+1		;see if over z
	bcs	notlwr		;skip if is
	and	#$5f		;else convert
notlwr	rts
;set list flag
SETLST	LDA	#TRUE
	STA	LSTFLG
	RTS
;clear list flag
CLRLST	LSR	LSTFLG
	RTS
;do direct pem call
DOPEM	LDA	AREG
	LDY	YREG
	LDX	XREG
	JSR	PEM
	STA	AREG
	STY	YREG
	STX	XREG
	RTS
;do direct sim call
DOSIM	LDA	BOOT+2
	STA	SIMJSR+2
	LDA	XREG
	STA	SIMJSR+1
	LDA	AREG
	LDY	YREG
SIMJSR	JSR	$FFFF
	STA	AREG
	STY	YREG
	STX	XREG
	RTS
;interpreter initialization routines
;get$parameters
GETPAR	LDA	MCD
	LDY	MCD+1
	STA	RC
	STY	RC+1		;rc:=mcd
	LDY	MDA+1
	LDX	MDA
	BNE	*+3
	DEY
	DEX
	STX	DTARPT
	STY	DTARPT+1	;dataareaptr:=mda-1
	CLC
	LDA	SB
	ADC	#NRSTCK
	STA	ST
	STA	MBASE
	LDY	SB+1
	BCC	*+3
	INY
	STY	ST+1
	STY	MBASE+1		;mbase,st:=sb+nrstack
	LDA	SB
	LDY	SB+1
	STA	RB
	STY	RB+1		;rb:=sb
	CLC
	ADC	#4
	STA	RA
	BCC	*+3
	INY
	STY	RA+1		;ra:=sb+4
	RTS
;initmem
INITMM	LDA	#<MEMORY
	LDY	#>MEMORY
	STA	MTO
	STY	MTO+1		;to:=.memory
	CLC
	ADC	OFFSET
	STA	MFROM
	TYA
	ADC	OFFSET+1
	STA	MFROM+1		;from:=.memory+offset
	SEC
	LDA	MPR
	SBC	#<MEMORY
	TAX
	LDA	MPR+1
	SBC	#>MEMORY
	TAY
	TXA
	JSR	MOVE		;move(begin+offset,begin,mpr-begin)
	SEC
	LDA	MBASE
	SBC	MPR
	STA	FN
	LDA	MBASE+1
	SBC	MPR+1
	STA	FN+1
	LDX	#0
	LDA	MPR
	LDY	MPR+1
	JSR	FILL		;fill(mpr,0,mbase-mpr)
	LDA	ST
	LDY	ST+1
	STA	IBASE
	STY	IBASE+1
	LDY	#0
	SEC
	LDA	PEM+1
	SBC	#4
	STA	(IBASE),Y
	INY
	LDA	PEM+2
	SBC	#0
	STA	(IBASE),Y	;a(0):=top-4
	LDA	#0
	LDY	#1*2		;word addressing
L051	STA	(IBASE),Y
	INY
	CPY	#3*2
	BNE	L051		;a(1),a(2):=0
	LDY	#0*2
	LDA	(IBASE),Y
	PHA
	INY
	LDA	(IBASE),Y
	TAY
	PLA
	STA	IBASE
	STY	IBASE+1		;base:=a(0)
	LDY	#0
	TYA
	STA	(IBASE),Y
	INY
	STA	(IBASE),Y	;a(0):=0
	INY
	LDA	ST
	STA	(IBASE),Y
	INY
	LDA	ST+1
	STA	(IBASE),Y	;a(1):=st
	RTS
;initialize$execute
INTLEX	JSR	GETPAR		;get$parameters
	JSR	INITMM		;initmem
	LDX	#NUMFIL*4
	LDA	#0
L052	STA	FILES-1,X
	DEX
	BNE	L052		;fill(.files,0,times4(numfiles))
	JMP	CLRPBF		;clear$print$buff
;generalized input routines
;console$read
CONRDE	LDA	#'?'
	JSR	PRNCHR		;printchar(?)
	LDA	#' '
	JSR	PRNCHR		;printchar(blank)
	LDA	#<INPBUF
	LDY	#>INPBUF
	JSR	READ		;read(.inputbuffer)
	jsr	dmppbf		;output cr/lf and clear pointer
	LDA	INPSPC+1
	CMP	#EOF		;if space(1) <> eof
	BNE	*+5		;then
	JSR	EXTINT		;else exit$interp
	LDA	#<INPSPC
	LDY	#>INPSPC
	STA	CONBPT
	STY	CONBPT+1	;conbuffptr:=.space
	LDX	INPSPC
	INX
	LDA	#CR
	STA	INPSPC,X	;space(space(0)+1):=eolchar
	RTS
;more$con$input
MRECIN	SEC
	LDA	CONBPT
	SBC	#<INPSPC
	CMP	INPSPC
	BCC	*+5		;if conbuffptr<.space(space(0))
	LDA	#FALSE
	RTS
	LDA	#TRUE
	RTS
;console$input$error
CONIER	JSR	POPSTK		;pop$stack
	LDA	RERDAD
	LDY	RERDAD+1
	STA	RC
	STY	RC+1		;rc:=rereadaddr
	LDA	#7		;illegal input warning
	JSR	WARNNG		;warning(ii)
	JMP	ERREXT		;error$exit
;get$data$char
GTDTCH	INC	DTARPT
	BNE	*+4
	INC	DTARPT+1	;dataareaptr:=dataareaptr+1
	LDA	DTARPT
	CMP	SB
	LDA	DTARPT+1
	SBC	SB+1
	BCC	*+7		;if dataareaptr<sb then ok
	LDA	#14		;else out of data error
	JMP	ERROR
	LDY	#0
	LDA	(DTARPT),Y	;a:=char
	RTS
;get$con$char
GTCNCH	INC	CONBPT
	BNE	*+4
	INC	CONBPT+1	;conbuffptr:=conbuffptr+1
	LDY	#0
	LDA	(CONBPT),Y	;a:=char
	RTS
;next$input$char
NXINCH	LDA	INPTYP
	BNE	L008
L009	LDA	#80
	CMP	INPIND
	BCS	*+7		;if inputindex<=conbuffsize then
	LDA	#25		;else data field too long
	JMP	ERROR
	JSR	GTDSCH		;getdiskchar
	LDX	INPIND
	STA	INPSPC,X	;space(inputindex):=
	CMP	#LF
	BNE	L010		;if not lf then
	JSR	VARBSZ
	BEQ	L009		;if not var$blocksize then ok
	LDA	#17		;else attempt to read past end error
	JMP	ERROR
L010	LDY	#0
	LDA	(RCRPNT),Y	;return nextdiskchar
	RTS
L008	CMP	#1		;if inputtype
	BNE	*+5		;<> 1 then
	JMP	GTCNCH		;else return getconchar
	CMP	#2		;if inputtype
	BNE	*+5		;<> 2 then
	JMP	GTDTCH		;else return getdatachar
	RTS
;count$input
;determines extent of next field and collect the field in the appropriate buff
IHOLD
	*=	*+1
DELIM
	*=	*+1
COUNTI	LDA	#0
	STA	INPIND		;input$index:=0
L011	JSR	NXINCH		;do while(hold:=next$input$char)=' '
	STA	IHOLD
	CMP	#' '
	BEQ	L011		;elimnates blanks
	LDA	INPTYP		;if inputtype
	BNE	L012		;<> 0 then
	LDA	#<INPSPC	;else
	LDY	#>INPSPC
	STA	INPPTR
	STY	INPPTR+1	;inputptr:=.space
	JMP	L014
L012	CMP	#1		;if inputtype
	BNE	L013		;<> 1 then
	LDA	CONBPT
	LDY	CONBPT+1
	STA	INPPTR
	STY	INPPTR+1	;inputptr:=conbuffptr
	JMP	L014
L013	CMP	#2
	BNE	L014		;if inputtype<>2 then
	LDA	DTARPT
	LDY	DTARPT+1
	STA	INPPTR
	STY	INPPTR+1
L014	LDA	IHOLD
	CMP	#'"'
	BEQ	L015		;if hold=" then
	LDA	#','
	STA	DELIM		;else delim:=,
	JMP	L017
L015	LDA	#'"'
	STA	DELIM		;delim:="
	LDA	INPTYP
	BEQ	L016		;if inputtype=0 then
	INC	INPPTR
	BNE	L016
	INC	INPPTR+1	;else inputptr:=inputptr+1
L016	JSR	NXINCH
	STA	IHOLD		;hold:=next$input$char
L017	LDA	IHOLD		;do while hold
	CMP	DELIM		;<> delim
	BEQ	L018		;and
	CMP	#CR		;<> eolchar
	BEQ	L018
	INC	INPIND		;inputindex:=inputindex+1
	JSR	NXINCH
	STA	IHOLD		;hold:=next$input$char
	JMP	L017
L018	LDA	DELIM
	CMP	#'"'		;if delim<>"
	BNE	L020		;then
L019	JSR	NXINCH
	STA	IHOLD		;hold:=next$input$char
	CMP	#','		;do while hold
	BEQ	L020		;<> ,
	CMP	#CR
	BNE	L019		;<> eolchar
L020	JMP	PSHSTK		;push$stack
;get$string$field
GTSTFL	JSR	COUNTI		;count$input
	CLC
	LDA	INPIND
	LDY	#0
	ADC	#1
	JSR	GETS
	STA	GTSTMP
	STY	GTSTMP+1	;temp:=getspace( )
	CLC
	ADC	#1
	BNE	*+3
	INY
	STA	MTO
	STY	MTO+1		;to:=temp+1
	LDA	INPPTR
	LDY	INPPTR+1
	STA	MFROM
	STY	MFROM+1		;from:=inputptr
	LDA	INPIND
	LDY	#0
	JSR	MOVE		;( , ,inputindex)
	LDY	#0
	LDA	GTSTMP
	STA	(RA),Y
	INY
	LDA	GTSTMP+1
	STA	(RA),Y		;ara:=temp
	LDA	#0
	JSR	FLSTRA		;flag$string$addr(0)
	LDY	#0
	LDA	INPIND
	STA	(GTSTMP),Y	;lng:=inputindex
	RTS
;get$numeric$field
GTNMFL	JSR	COUNTI		;count$input
	LDX	INPIND
	BEQ	L021		;if inputindex=0 then
	LDA	INPPTR
	LDY	INPPTR+1
	JSR	FLTINP		;else fp$input(inputindex,inputptr)
	LDA	RA
	LDY	RA+1
	JSR	STP		;store accum @ ra
	JMP	CHKOVR		;check$overflow
L021	LDA	INPTYP
	CMP	#1
	BNE	*+5		;if inputtype<>1 then
	JMP	CONIER		;else console$input$error
	LDY	#0
	TYA
	STA	(RA),Y		;braz:=0
	RTS
;file processing routines
;initialize$disk$buffer
INTDBF	LDY	#127
	LDA	#EOF
L030	STA	(BUFFER),Y	;insert eof
	DEY
	BPL	L030
	RTS
;buffer$status$byte
BUFSTB	LDY	#33
	LDA	(FILADR),Y
	RTS			;return fcb(33)
;set$buffer$status$byte(status)
STBFSB	LDY	#33
	STA	(FILADR),Y	;fcb(33)=status
	RTS
;write$mark
WRTMRK	JSR	BUFSTB
	AND	#1		;set flags
	RTS
;set$write$mark
SWRMRK	JSR	BUFSTB
	ORA	#1
	JMP	STBFSB
;clear$write$mark
CWRMRK	JSR	BUFSTB
	AND	#%11111110
	JMP	STBFSB
;active$buffer
ACTBUF	JSR	BUFSTB
	LSR	A
	AND	#1
	RTS
;set$buffer$inactive
SETBFI	JSR	BUFSTB
	AND	#%11111001
	JMP	STBFSB
;set$buffer$active
SETBFA	JSR	BUFSTB
	ORA	#%00000010
	JMP	STBFSB
;set$random$mode
SETRAN	JSR	BUFSTB
	ORA	#%10000000
	JMP	STBFSB
;random$mode
RANMDE	JSR	BUFSTB
	ROL	A
	ROL	A
	AND	#1
	RTS
;store$rec$ptr
STRRPT	LDY	#18*2		;word addressing
	LDA	RCRPNT
	STA	(FILADR),Y
	INY
	LDA	RCRPNT+1
	STA	(FILADR),Y	;fcbadd(18):=recordpointer
	RTS
;disk$eof
DSKEOF	LDA	EOFADR
	ORA	EOFADR+1	;if eofaddr <> 0
	BNE	*+7		;then
	LDA	#5		;else eof error
	JMP	ERROR
	LDX	EOFADR
	LDY	EOFADR+1
	INX
	STX	RC
	BNE	*+3
	INY
	STY	RC+1		;rc:=eofaddr+1
	LDA	EOFRA
	LDY	EOFRA+1
	STA	RA
	STY	RA+1		;ra:=eofra
	LDA	EOFRB
	LDY	EOFRB+1
	STA	RB
	STY	RB+1		;rb:=eofrb
	LDA	RCRPNT
	CMP	BUFFER
	BNE	RPBFNE		;if record$pointer <> buffer then
	LDA	RCRPNT+1
	CMP	BUFFER+1
	BEQ	L031
RPBFNE	JSR	BUFSTB
	ORA	#%00000100	;buffer$status$byte or 4
	JSR	STBFSB
L031	LDA	RCRPNT
	BNE	*+4
	DEC	RCRPNT+1
	DEC	RCRPNT		;record$pointer:=record$pointer-1
	JSR	STRRPT		;store$rec$ptr
	JMP	EOFEXT		;drop to outer loop
;fill$file$buffer
FILFBF	JSR	DSKRDE		;if diskread <> 0
	BNE	*+5		;then
	JMP	SETBFA		;else set$buffer$active
	JSR	RANMDE		;if random$mode
	BNE	*+5		;then
	JMP	DSKEOF		;else disk$eof
	JSR	INTDBF		;initialize$disk$buffer
	JSR	SETBFA		;set$buffer$active
	LDY	#32
	LDA	(FILADR),Y
	CLC
	ADC	#1
	STA	(FILADR),Y	;fcb(32):=fcb(32)+1
	RTS
;write$disk$if$req
WDIFRQ	JSR	WRTMRK		;if not write$mark
	BEQ	L032		;then just set recordpointers
	JSR	BUFSTB		;else
	AND	#4
	BEQ	L033		;if not shr(buffer$status$byte,2) then
	LDY	#32
	LDA	(FILADR),Y
	BEQ	L034		;if zero don't subtract
	SEC
	SBC	#1
	STA	(FILADR),Y	;else fcb(32):=fcb(32)-1
L034	JSR	BUFSTB
	AND	#%11111011
	JSR	STBFSB
L033	JSR	DSKWRT
	BEQ	*+7		;if ok then
	LDA	#3		;else disk write error
	JMP	ERROR
	JSR	CWRMRK		;clear$write$mark
	JSR	RANMDE
	BEQ	*+8		;if not$random$mode then
	JSR	SETBFI		;set$buffer$inactive
	JMP	L032
	JSR	INTDBF		;initialize$disk$buffer
L032	LDA	BUFFER
	LDY	BUFFER+1
	STA	RCRPNT
	STY	RCRPNT+1	;record$pointer:=buffer
	RTS
;at$end$disk$buffer
ATENDB	INC	RCRPNT
	BNE	*+4
	INC	RCRPNT+1	;record$pointer:=record$pointer+1
	LDA	RCRPNT
	CMP	BUFEND
	LDA	RCRPNT+1
	SBC	BUFEND+1
	BCS	*+5		;if record$pointer >= buffer$end then
	LDA	#FALSE		;else
	RTS
	LDA	#TRUE
	RTS
;var$block$size
VARBSZ	LDA	BLKSZE
	ORA	BLKSZE+1
	BNE	*+5		;if blocksize <> 0 then
	LDA	#FALSE		;else
	RTS
	LDA	#TRUE
	RTS
;write$a$byte(char)
WRABYT	PHA			;save char
	JSR	VARBSZ		;if not var$block$size
	BEQ	L035		;then ok
	INC	BYTSWR
	BNE	*+5
	INC	BYTSWR+1	;byteswritten:=byteswritten+1
	LDA	BLKSZE
	CMP	BYTSWR
	LDA	BLKSZE+1
	SBC	BYTSWR+1	;if blocksize >= byteswritten
	BCS	L035		;then ok
	LDA	#6		;else record size error
	JMP	ERROR
L035	JSR	ATENDB		;if not at$end$disk$buffer
	BEQ	*+5		;then
	JSR	WDIFRQ		;else write$disk$if$req
	JSR	ACTBUF		;if active$buffer
	BNE	L036		;then
	JSR	RANMDE		;or if not random$mode
	BEQ	L036		;then
	JSR	FILFBF		;else fill$file$buffer
	LDY	#32
	LDA	(FILADR),Y
	SEC
	SBC	#1
	STA	(FILADR),Y	;fcb(32):=fcb(32)-1
L036	PLA
	LDY	#0
	STA	(RCRPNT),Y	;nextdiskchar:=char
	JMP	SWRMRK		;set$write$mark
;get$file$number
GTFLNU	LDY	#0
	LDA	(RA),Y
	CMP	#NUMFIL
	BEQ	E21		;if braz=numfiles then ok
	BCC	E21		;or if braz<numfiles then ok
	LDA	#11		;else illegal file error
	JMP	ERROR
E21	RTS
;set$file$addr
STFLAD	JSR	GTFLNU
	ASL	A
	TAX
	LDA	FILES,X
	STA	FILADR
	LDA	FILES+1,X
	STA	FILADR+1	;fileaddr:=files(get$file$number)
	ORA	FILADR
	BNE	*+7		;if <> 0 then ok
	LDA	#9
	JMP	ERROR		;else unopened file error
	LDY	#0
	LDA	(RA),Y
	ASL	A
	TAX
	LDA	EOFBRN,X
	STA	EOFADR
	LDA	EOFBRN+1,X
	STA	EOFADR+1	;eofaddr:=eofbranch(braz)
	RTS
;set$file$pointers
STFLPT	CLC
	LDA	FILADR
	LDY	FILADR+1
	ADC	#38
	STA	BUFFER
	BCC	*+3
	INY
	STY	BUFFER+1	;buffer:=fileaddr+38
	CLC
	ADC	#128
	STA	BUFEND
	BCC	*+3
	INY
	STY	BUFEND+1	;buffer$end=buffer+diskrecsize
	LDY	#17*2		;word addressing
	LDA	(FILADR),Y
	STA	BLKSZE
	INY
	LDA	(FILADR),Y
	STA	BLKSZE+1	;blocksize:=fcbadd(17)
	INY
	LDA	(FILADR),Y
	STA	RCRPNT
	INY
	LDA	(FILADR),Y
	STA	RCRPNT+1	;recordpointer:=fcbadd(18)
	jsr	setdma		;setdma
	ldy	#0		;clear extent size flag
	sty	extsze
	lda	(filadr),y	;get drive
	bne	clcdrv		;use if not zero
	lda	dfldrv		;else get default
	jmp	setdrv
clcdrv	sec			;drop by one
	sbc	#1
setdrv	ldx	#14
	jsr	pem		;select drive
	ldx	#34
	jsr	pem		;read dcb address
	sta	dcbpnt
	sty	dcbpnt+1
	ldy	#6
	lda	(dcbpnt),y	;get block size
	bne	extstf		;done if not 1K
	ldy	#1
	lda	(dcbpnt),y	;get high of maxblk
	beq	extstf		;done if maxblk < 256
	sec
	ror	extsze		;else set flag
extstf	rts
;setup$file$extent
SUFLEX	JSR	OPEN		;if open ok
	BPL	E22		;then done
	JSR	CREATE		;then if create ok
	BPL	SUFLEX		;then open it
	LDA	#10		;else error while making file
	JMP	ERROR
E22	RTS
;test$legal
;test for illegal character in file name
;if illegal send error message and exit
tstlgl	cmp	#' '		;see if space or less
	bcc	ilgchr		;error if less
	beq	ilgchr		;or if space
	cmp	#'='
	beq	ilgchr		;error if =
	cmp	#'_'
	beq	ilgchr		;or if _
	cmp	#'.'
	beq	ilgchr		;or if .
	cmp	#':'
	beq	ilgchr		;or if :
	cmp	#semico
	beq	ilgchr		;or if ;
	cmp	#'<'
	beq	ilgchr		;or if <
	cmp	#'>'
	beq	ilgchr		;or if >
	cmp	#$7f
	beq	ilgchr		;or if delete
	cmp	#'*'
	beq	ilgchr		;or if *
	cmp	#'?'
	beq	ilgchr		;or if ?
	rts			;else ok
ilgchr	lda	#28		;file name error
	jmp	error
;disk$open
;opens the file - ra contains the address of the file name and rb contains the
;block size.  the array files will hold the address of the file control block
;in the fsa.  the fcb is followed by 3 flags - blocksize(addr),
;recordpointer(addr), writeflag(byte).  this is followed by the 128 byte buffer
;to do file i/o
NXTFLE				;nextfile
	*=	*+1
DOI				;i
	*=	*+1
DOIT				;type index
	*=	*+1
DOJ				;j
	*=	*+1
DSKOPN	LDA	#8
	STA	DOIT		;set type index
	LDX	#0		;nextfile:=0
L022	INX
	INX
	LDA	FILES,X
	ORA	FILES+1,X
	BNE	L022		;do while files( ) <> 0
	STX	NXTFLE
	LDA	#166
	LDY	#0
	JSR	GETS		;getspace(166)
	STA	FILADR
	STY	FILADR+1	;fileaddr:=
	LDX	NXTFLE
	STA	FILES,X
	TYA
	STA	FILES+1,X	;files(nextfile):=
	CLC
	LDA	FILADR
	LDY	FILADR+1
	ADC	#38
	STA	BUFFER
	BCC	*+3
	INY
	STY	BUFFER+1	;buffer:=fileaddr+38
	JSR	SETDMA
	LDY	#11
	LDA	#' '
L023	STA	(FILADR),Y
	DEY
	BNE	L023		;fill((filename:=fileaddr+1),' ',11)
	LDA	(RA),Y
	STA	DOBF
	INY
	LDA	(RA),Y
	STA	DOBF+1		;buff:=ara
	INY			;y:=2
	LDA	(DOBF),Y
	CMP	#':'		;if char(2) <> :
	BNE	L024		;then
	DEY			;y:=1
	LDA	(DOBF),Y
	jsr	lwrupr		;convert to upper case
	cmp	#'A'		;make sure is A or more
	bcc	ilgchr		;error if not
	cmp	#'H'+1
	bcs	ilgchr		;error if over H
	AND	#$F
	DEY			;y:=0
	STA	(FILADR),Y	;fcb(0):=char(1) and $f
	LDA	(DOBF),Y
	SEC
	SBC	#2
	STA	DOI		;i:=char(0)-2
	CLC
	LDA	DOBF
	ADC	#2
	STA	DOBF
	BCC	*+4
	INC	DOBF+1		;buff:=buff+2
	JMP	L026
L024	LDY	#0
	LDA	(DOBF),Y
	STA	DOI		;i:=char(0)
L026	LDA	DOI
	CMP	#12+1
	BCC	L027
	LDA	#12
	STA	DOI		;i:=12
L027	INC	DOBF
	BNE	*+4
	INC	DOBF+1		;buff:=buff+1
	LDA	#255
	STA	DOJ		;j:=255
L028	INC	DOJ
	LDY	DOJ
	LDA	(DOBF),Y
	jsr	lwrupr		;convert to uppercase
	CMP	#'.'		;if char(incj$)=.
	BEQ	L029		;then done
	CPY	DOI		;or if j >= i
	BCS	L029		;then done
	INY
	jsr	tstlgl		;make sure is legal
	STA	(FILADR),Y	;else put in fcb
	JMP	L028		;and loop
L029	INC	DOJ
	INC	DOIT		;bump type index
	LDY	DOJ
	CPY	DOI		;if j >= i
	BCS	L037		;then done
	LDA	(DOBF),Y
	jsr	lwrupr		;convert to uppercase
	LDY	DOIT		;get type index
	jsr	tstlgl		;make sure is legal
	STA	(FILADR),Y
	JMP	L029
L037	JSR	SUFLEX		;setup$file$extent
	JSR	INTDBF		;initialize$disk$buffer
	LDA	FILADR
	LDX	FILADR+1
	INX			;ax:=fileaddr+256
	LDY	#18*2		;word address
	STA	(FILADR),Y
	INY
	TXA
	STA	(FILADR),Y	;fcbadd(18):=fileaddr+256
	JSR	POPSTK		;pop$stack
	LDY	#0
	LDA	(RA),Y
	TAX
	INY
	LDA	(RA),Y
	LDY	#17*2+1		;high of word address
	STA	(FILADR),Y
	DEY
	TXA
	STA	(FILADR),Y	;fcbadd(17):=ara
	JMP	POPSTK		;pop$stack
;set$eof$stack
STEFST	LDA	RA
	LDY	RA+1
	STA	EOFRA
	STY	EOFRA+1		;eofra:=ra
	LDA	RB
	LDY	RB+1
	STA	EOFRB
	STY	EOFRB+1		;eofrb:=rb
	RTS
;setup$disk$io
SUDSIO	JSR	STFLAD		;set$file$addr
	JSR	STFLPT		;set$file$pointer
	LDA	#0
	STA	BYTSWR
	STA	BYTSWR+1	;bytes$written:=0
	LDA	#TRUE
	STA	FRSFLD		;firstfield:=true
	JMP	POPSTK		;pop$stack
;random$setup
RURC				;record
	*=	*+1
RANSTU	JSR	VARBSZ		;if var$block$size
	BNE	*+7		;then ok
	LDA	#18		;else unblocked file error
	JMP	ERROR
	JSR	RAZERA		;if ra$zero$address
	BNE	L038		;then error
	JSR	RANEG		;if positive
	BEQ	*+7		;then ok
L038	LDA	#8		;else invalid record #
	JMP	ERROR
	LDY	#0
	SEC
	LDA	(RA),Y
	SBC	#1
	STA	(RA),Y
	INY
	LDA	(RA),Y
	SBC	#0
	STA	(RA),Y
	JSR	SETRAN		;set$random$mode
	JSR	SETBFI		;set$buffer$inactive
	JSR	WDIFRQ		;write$disk$if$req
	LDA	BLKSZE
	ldy	blksze+1
	STA	PX
	sty	px+1		;px:=blocksize
	jsr	ara		;ay:=record number - 1
	JSR	MXAP		;ay:=ay*px
	AND	#$7F		;a:=bytecount and $7f
	CLC
	ADC	BUFFER
	LDY	BUFFER+1
	BCC	*+3
	INY
	TAX
	BNE	*+3
	DEY
	DEX
	STX	RCRPNT
	STY	RCRPNT+1	;recordpointer:=( )+buffer-1
	JSR	STRRPT		;store$rec$ptr
	jsr	shfpxl		;shift accum left
	lda	px+1		;get record byte
	and	#$7f		;clear msb
	bit	extsze		;test flag
	bpl	not8ke		;skip if 16K
	and	#$3f		;else trim some more
	jsr	shfpxl		;and shift extra time
not8ke	sta	rurc		;put in record
	jsr	shfpxl		;shift left again
	LDY	#12
	LDA	(FILADR),Y	;a:=fcb(12)
	cmp	px+2		;compare to low
	bne	chgext		;change if diff
	iny
	lda	(filadr),y
	cmp	px+3		;same for high
	BEQ	L040		;if extent=( ) then
chgext	JSR	CLOSE		;else close
	BPL	*+7		;if ok
	LDA	#1		;else file closing error
	JMP	ERROR
	LDY	#12
	lda	px+2
	STA	(FILADR),Y	;fcb(12):=extent
	iny			;same for high
	lda	px+3
	sta	(filadr),y
	JSR	SUFLEX		;setup$file$extent
L040	LDA	RURC
	LDY	#32
	STA	(FILADR),Y	;fcb(32):=low(record) and $7f
	JMP	POPSTK		;pop$stack
;shift fixed point accum left one bit
shfpxl	asl	px
	rol	px+1
	rol	px+2
	rol	px+3
	rts
;get$disk$char
GTDSCH	JSR	ATENDB		;if not at$end$disk$buffer
	BEQ	L041		;then
	JSR	WDIFRQ		;write$disk$if$req
	JSR	FILFBF		;fill$file$buffer
L041	JSR	ACTBUF		;if active$buffer
	BNE	*+5		;then
	JSR	FILFBF		;else fill$file$buffer
	LDY	#0
	LDA	(RCRPNT),Y	;if nextdiskchar
	CMP	#EOF		;<> eoffiller
	BNE	*+5		;then
	JSR	DSKEOF		;else disk$eof
	LDY	#0
	LDA	(RCRPNT),Y
	RTS			;return nextdiskchar
;inc$point
INCWFP	INC	WTFPNT
	BNE	*+4
	INC	WTFPNT+1
	RTS			;point:=point+1
;write$to$file(type)
;if type=0 then number, =1 then string
WFTYP				;type
	*=	*+1
WFI				;i
	*=	*+1
WFCNT				;count
	*=	*+1
WRTOFL	STA	WFTYP		;save type
	TAX
	BNE	*+5		;if string then
	JSR	NUMOUT		;else numericout
	BIT	FRSFLD
	BMI	L000		;if firstfield then
	LDA	#','
	JSR	WRABYT		;else write$a$byte(,)
	JMP	L001
L000	LDA	#FALSE
	STA	FRSFLD		;firstfield:=false
L001	LDY	#0
	LDA	(RA),Y
	STA	WTFPNT
	INY
	LDA	(RA),Y
	STA	WTFPNT+1	;point:=ara
	DEY
	LDA	(WTFPNT),Y
	STA	WFCNT		;count:=char
	LDA	WFTYP
	BNE	L002		;if type not numeric then
	DEC	WFCNT		;else count:=count-1
	JMP	L003
L002	LDA	#'"'
	JSR	WRABYT		;write$a$byte(")
L003	JSR	INCWFP		;inc$point
	LDA	#1
	STA	WFI		;i:=1
L004	LDA	WFCNT
	CMP	WFI		;if i > count
	BCC	L005		;then
	LDY	#0
	LDA	(WTFPNT),Y	;a:=char
	CMP	#'"'
	BNE	*+7		;if not quote then
	LDA	#24		;else write quote error
	JMP	ERROR
	JSR	WRABYT		;write$a$byte(char)
	JSR	INCWFP		;inc$point
	INC	WFI		;bump i
	JMP	L004		;and loop
L005	LDA	WFTYP
	BEQ	L006		;if type not string then
	LDA	#'"'		;else
	JSR	WRABYT		;write$a$byte(")
	JSR	STRFRE		;stringfree
L006	JMP	POPSTK		;pop$stack
;disk$close
DSKCLS	JSR	STFLPT		;set$file$pointers
	JSR	WDIFRQ		;write$disk$if$req
	JSR	CLOSE
	BPL	*+7		;if close ok then
	LDA	#1		;else close error
	JMP	ERROR
	LDA	FILADR
	LDY	FILADR+1
	JMP	RELS		;release(fileaddr)
;closefiles
CLSFLS	LDX	#0		;i:=0
L007	INX			;i:=i+1
	CPX	#NUMFIL
	BCC	*+5		;if i < numfiles then
	BEQ	*+3		;if i = numfiles then
	RTS
	TXA			;a:=i
	PHA			;save on stack
	ASL	A		;a:=a*2
	TAX
	LDA	FILES,X
	STA	FILADR
	LDA	FILES+1,X
	STA	FILADR+1	;fileaddr:=files(i)
	ORA	FILADR
	BEQ	*+5		;if fileaddr=0 then
	JSR	DSKCLS		;else disk$close
	PLA			;get i back
	TAX
	JMP	L007		;and loop
;routine to exit interpreter
;exit$interp
EXTINT	JSR	CLSFLS		;closefiles
	JSR	DMPPBF		;dump$print$buff
	JSR	CRLF
	JMP	BOOT
;store(type)
;store places ra in the prt location referenced by rb. ra may contain a
;floating point number or a reference to a string.  in the case of a string
;the following is also performed
;	(1)	If the prt cell already contains a reference to a string in the
;		fsa that string's counter is decremented and if equal to 1 then
;		the space is freed.
;	(2)	The new string counter is incremented.  If it is already 255
;		then a copy is made and the new counter set to 2.
STORE	PHA			;save type
	LDA	RB
	LDY	RB+1
	JSR	SEDAAD		;set$data$addr(rb)
	PLA			;get type
	AND	#1
	BNE	*+5		;if string continue
	JMP	JSTSTR		;if number just store
	LDA	#0
	JSR	FLSTRA		;flag$string$addr(0)
	JSR	ARB
	STA	PTRADR
	STY	PTRADR+1	;ptraddr:=arb
	LDY	#0
	LDA	(PTRADR),Y
	PHA
	INY
	LDA	(PTRADR),Y
	TAY
	PLA			;ay:=stringaddr
	JSR	INFSA		;in$fsa(stringaddr)
	BEQ	NTTHR		;branch if not
	LDY	#0
	LDA	(PTRADR),Y
	TAX
	INY
	LDA	(PTRADR),Y
	TAY
	TXA
	BNE	*+3
	DEY
	DEX			;stringaddr-1
	STX	SPTR
	STY	SPTR+1		;ptr:=
	SEC
	LDY	#0
	LDA	(SPTR),Y
	SBC	#1
	STA	(SPTR),Y	;counter:=counter-1
	CMP	#1
	BNE	NTTHR		;if <> 1 then
	LDA	(PTRADR),Y
	PHA
	INY
	LDA	(PTRADR),Y
	TAY
	PLA
	JSR	RELS		;else release(stringaddr)
NTTHR	JSR	ARA
	SEC
	SBC	#1
	BCS	*+3
	DEY
	STA	SPTR
	STY	SPTR+1		;ptr:=ara-1
	JSR	INFSA		;infsa(ptr)
	BEQ	JSTSTR		;if not then
	LDY	#0
	LDA	(SPTR),Y	;a:=counter
	CMP	#255		;if not 255
	BNE	BMPCNT		;just bump count
	INC	SPTR
	BNE	*+4
	INC	SPTR+1
	LDA	(SPTR),Y	;counter
	CLC
	ADC	#1		;a:=counter+1
	JSR	GETS		;getspace(counter+1)
	PHA			;save low
	TYA			;high to a
	LDY	#1
	STA	(RA),Y
	STA	MTO+1
	DEY
	PLA
	STA	(RA),Y		;ara:=getspace(counter+1)
	STA	MTO		;to:=ara
	LDA	SPTR
	LDY	SPTR+1
	STA	MFROM
	STY	MFROM+1		;from:=ptr
	LDY	#0
	LDA	(SPTR),Y
	CLC
	ADC	#1
	JSR	MOVE		;move( , , )
	LDY	#0
	LDA	(RA),Y
	TAX
	INY
	LDA	(RA),Y
	TAY
	TXA
	BNE	*+3
	DEY
	DEX
	STX	SPTR
	STY	SPTR+1		;ptr:=ara-1
BMPCNT	LDY	#0
	LDA	(SPTR),Y
	CLC
	ADC	#1
	STA	(SPTR),Y	;counter:=counter+1
JSTSTR	LDA	RA
	LDY	RA+1
	STA	MFROM
	STY	MFROM+1		;from:=ra
	JSR	ARB
	STA	MTO
	STY	MTO+1		;to:=arb
	JMP	MOVE4		;move4(from,to)
;array addressing routines
;calc$row
;sets up an array in the fsa in row major order. the byte of code following the 
;operator is the number of dimensions.  the stack contains the upper bound of
;each dimension - ra holds dimension n, rb n-1, etc.  the lower bound is always
;zero.
CLCROW	LDA	#1
	LDY	#0
	STA	ASIZE
	STY	ASIZE+1		;asize:=1
	JSR	STINCN		;step$ins$cnt
	LDA	RA
	LDY	RA+1
	STA	SAVERA
	STY	SAVERA+1	;savera:=ra
	LDA	RB
	LDY	RB+1
	STA	SAVERB
	STY	SAVERB+1	;saverb:=rb
	LDA	#1
	STA	CI		;i:=1
CLRP	LDY	#0
	LDA	(RC),Y		;get numdim
	CMP	CI		;if i>numdim
	BCC	GTALLD		;then
	JSR	ARA
	CLC
	ADC	#1
	BCC	*+3
	INY
	STA	PX
	STY	PX+1		;px:=ara+1
	LDA	ASIZE
	LDY	ASIZE+1
	JSR	MXAP		;ay:=asize*(ara+1)
	STA	ASIZE
	STY	ASIZE+1		;asize:=
	LDY	#0
	STA	(RA),Y
	INY
	LDA	ASIZE+1
	STA	(RA),Y		;ara:=asize
	JSR	POPSTK		;pop$stack
	INC	CI		;i:=i+1
	JMP	CLRP		;and loop
GTALLD	LDA	SAVERA
	LDY	SAVERA+1
	STA	RA
	STY	RA+1		;ra:=savera
	LDA	SAVERB
	LDY	SAVERB+1
	STA	RB
	STY	RB+1		;rb:=saverb
	LDY	#0
	LDA	(RC),Y		;a:=numdim
	CLC
	ADC	#1
	ASL	A
	STA	CLCT
	LDA	ASIZE
	LDY	ASIZE+1
	JSR	TIMES4		;times4(asize)
	CLC
	ADC	CLCT
	BCC	*+3
	INY
	JSR	GETS		;getspace()
	STA	SAVERA
	STY	SAVERA+1	;savera:=
	STA	ARYADR
	STY	ARYADR+1	;arrayaddr:=
	LDY	#0
	LDA	(RC),Y		;a:=numdim
	STA	(ARYADR),Y
	TYA
	INY
	STA	(ARYADR),Y	;:=0
	LDA	#1
	STA	CI		;i:=1
CALP	LDY	#0
	LDA	(RC),Y
	CMP	CI		;if i>numdim
	BCC	GTALAA		;then
	CLC
	LDA	ARYADR
	ADC	#2
	STA	ARYADR
	BCC	*+4
	INC	ARYADR+1	;arrayaddr:=arrayaddr+2
	LDY	#0
	LDA	(RA),Y
	STA	(ARYADR),Y
	INY
	LDA	(RA),Y
	STA	(ARYADR),Y	;arraypos:=ara
	JSR	POPSTK		;pop$stack
	INC	CI		;i:=i+1
	JMP	CALP
GTALAA	JSR	PSHSTK		;push$stack
	LDY	#0
	LDA	SAVERA
	STA	(RA),Y
	INY
	LDA	SAVERA+1
	STA	(RA),Y		;ara:=savera
	RTS
;inc$arrayaddr
INCAAD	CLC
	LDA	ARYADR
	ADC	#2
	STA	ARYADR
	BCC	*+4
	INC	ARYADR+1	;arrayaddr:=arrayaddr+2
	RTS
;calc$sub
;performs a subscript calculation for the array referenced by ra.  the value of
;each dimension is on the stack below the array address starting with the nth
;dimension.  a check is made to see if the selected element is outside the area
;assigned to the array
CLCSUB	JSR	ARA
	STA	ARYADR
	STY	ARYADR+1	;arrayaddr:=ara
	JSR	POPSTK		;pop$stack
	JSR	ARA
	STA	LOCATN
	STY	LOCATN+1	;location:=ara
	LDY	#0
	LDA	(ARYADR),Y
	STA	NUMDIM		;numdim:=arraypos
	LDA	#2
	STA	CI		;i:=2
CLSLP	LDA	NUMDIM
	CMP	CI		;if i>numdim
	BCC	CLALSB		;then
	JSR	POPSTK		;else pop$stack
	JSR	INCAAD		;inc$arrayaddr
	LDY	#0
	LDA	(ARYADR),Y
	STA	PX
	INY
	LDA	(ARYADR),Y
	STA	PX+1
	JSR	ARA
	JSR	MXAP		;ay:=ara*arraypos
	CLC
	ADC	LOCATN
	STA	LOCATN
	TYA
	ADC	LOCATN+1
	STA	LOCATN+1	;location:=ara*arraypos+location
	INC	CI		;i:=i+1
	JMP	CLSLP		;and loop
CLALSB	JSR	INCAAD		;inc$arrayaddr
	LDY	#0
	LDA	LOCATN
	CMP	(ARYADR),Y
	INY
	LDA	LOCATN+1
	SBC	(ARYADR),Y
	BCC	*+7		;if arraypos>location then ok
	LDA	#19		;else subscripting error
	JMP	ERROR
	LDA	LOCATN
	LDY	LOCATN+1
	JSR	TIMES4		;times4(location)
	CLC
	ADC	ARYADR
	TAX
	TYA
	ADC	ARYADR+1
	TAY			;+arrayaddr
	CLC
	TXA
	ADC	#2
	TAX
	BCC	*+3
	INY			;+2
	TYA
	LDY	#1		;high first
	STA	(RA),Y
	DEY
	TXA
	STA	(RA),Y		;ara:=
	RTS
;branching routines
;uncond$branch
UNCBRA	JSR	ARA
	CLC
	ADC	RC
	TAX
	TYA
	ADC	RC+1
	TAY			;ay:=ara+rc
	TXA
	BNE	*+3
	DEY
	DEX
	STX	RC
	STY	RC+1		;rc:=rc+ara-1
	JMP	POPSTK		;pop$stack
;cond$branch
CNDBRA	JSR	RBZER
	BEQ	*+8		;if not rbzero then
	JSR	UNCBRA		;else do branch
	JMP	POPSTK
	JSR	POPSTK		;pop$stack twice
	JMP	POPSTK
;absolute$branch
ABSBRA	JSR	STINCN		;step$ins$cnt
	JSR	ARC
	STA	RC
	STY	RC+1		;rc:=twobyteoperand
	RTS
;global string handling routines
CHKSAD	LDY	#2
	LDA	(RA),Y
	RTS
;string$free
STRFRE	JSR	CHKSAD
	AND	#1
	BNE	*+3		;if check$string$addr then
	RTS
	JSR	ARA
	JMP	RELS		;release(ara)
;get$string$len
GETSLN	STA	GETSL+1
	STY	GETSL+2
	ORA	GETSL+2
	BNE	*+3
	RTS
GETSL	LDA	$FFFF
	RTS
;comp$fix
COMFIX	AND	#1		;if not flag
	BEQ	NTCFLG		;then
	LDY	#3
COMFXL	LDA	MONE,Y		;move4(.minusone,ra)
	STA	(RA),Y
	DEY
	BPL	COMFXL
	RTS
NTCFLG	TAY			;braz:=0
	STA	(RA),Y
	RTS
;chkcarry
CHKSCY	BCC	*+7		;if c=0 then ok
	LDA	#20		;else string length error
	JMP	ERROR
	RTS
;concatenate
;the string pointed to by ra is concatenated to the string pointed to by rb and
;the pointer to the result is placed in rb.  the stack is popped and the result
;is flagged as a temporary string.
CONCAT	JSR	RAZERA		;if ra$zero$address
	BNE	E14		;then
	JSR	RBZERA		;else if not rb$zero$address
	BEQ	DOCAT		;then
	JSR	MVRARB		;else move$ra$rb
E14	JMP	POPSTK		;pop$stack
DOCAT	JSR	ARB
	JSR	GETSLN		;getstringlen(arb)
	CLC
	ADC	#1		;+1
	STA	FRSTLN		;firststringlength:=
	JSR	CHKSCY		;chkcarry
	JSR	ARA
	JSR	GETSLN		;getstringlen(ara)
	STA	SCSTLN		;secondstringlength:=
	CLC
	ADC	FRSTLN		;+firststringlength
	STA	NWSTLN		;newstringlength:=
	JSR	CHKSCY		;chkcarry
	LDA	NWSTLN
	LDY	#0
	JSR	GETS		;getspace(newstringlength)
	STA	NWSTAD
	STY	NWSTAD+1	;newstringaddress:=
	STA	MTO
	STY	MTO+1		;to:=
	LDY	#0
	LDA	(RB),Y
	STA	MFROM
	INY
	LDA	(RB),Y
	STA	MFROM+1		;from:=arb
	LDA	FRSTLN
	DEY			;length:=firststringlength
	JSR	MOVE		;( , , )
	LDY	#0
	LDA	(RA),Y
	STA	MFROM
	INY
	LDA	(RA),Y
	STA	MFROM+1
	INC	MFROM
	BNE	*+4
	INC	MFROM+1		;from:=ara+1
	CLC
	LDA	NWSTAD
	ADC	FRSTLN
	STA	MTO
	LDY	NWSTAD+1
	BCC	*+3
	INY
	STY	MTO+1		;to:=newstringaddress+firststringlength
	LDA	SCSTLN
	LDY	#0		;length:=secondstringlength
	JSR	MOVE		;move( , , )
	JSR	STRFRE		;stringfree
	JSR	POPSTK		;pop$stack
	JSR	STRFRE		;stringfree
	LDY	#0
	LDA	NWSTAD
	STA	(RA),Y
	INY
	LDA	NWSTAD+1
	STA	(RA),Y		;ara:=newstringaddress
	LDX	NWSTLN
	DEX
	TXA
	DEY			;y:=0
	STA	(NWSTAD),Y	;length:=newstringlength-1
	LDA	#TRUE
	JMP	FLSTRA		;flag$string$addr(true)
;fixstack
FIXSTK	JSR	STRFRE		;string$free
	JSR	POPSTK		;pop$stack
	JMP	STRFRE		;string$free
;inc$bra
INCBRA	LDY	#0
	LDA	(RA),Y
	CLC
	ADC	#1		;return braz+1
	RTS
;compare$string
;the string pointed to by rb is compared to the string pointed to by ra
;if rb < ra then return 1
;   rb > ra 		2
;   rb = ra		3
;two strings are equal if and only if the two strings have the same length and
;contain identical characters.  the ascii collating sequence is used to
;determine the relationship between equal length strings.  if two strings are
;not of equal length the shorter is always less than the longer one.  all null
;strings are equal and less than any other string.
CSI				;i
	*=	*+1
CSTL				;templength
	*=	*+1
CMPSTR	JSR	RAZERA		;if not ra$zero$address
	BEQ	L061		;then
	LDA	RA
	LDY	RA+1
	STA	SCNDST
	STY	SCNDST+1	;secondstring:=ra
	JMP	L062
L061	LDY	#0
	LDA	(RA),Y
	STA	SCNDST
	INY
	LDA	(RA),Y
	STA	SCNDST+1	;secondstring:=ara
L062	JSR	RBZERA		;if not rb$zero$address
	BEQ	L063		;then
	LDA	RB
	LDY	RB+1
	STA	FRSTST
	STY	FRSTST+1	;firststring:=rb
	JMP	L064
L063	LDY	#0
	LDA	(RB),Y
	STA	FRSTST
	INY
	LDA	(RB),Y
	STA	FRSTST+1	;firststring:=arb
L064	LDY	#0
	LDA	(FRSTST),Y
	STA	CSTL		;templength:=charstring1
	STY	CSI		;i:=0
L065	LDA	CSTL
	CMP	CSI		;if i>templength
	BCC	L068		;then
	LDY	#0
	LDA	(FRSTST),Y
	CMP	(SCNDST),Y
	BCS	L066		;if charstring1 >= charstring2 then
	JSR	FIXSTK		;fixstack
	LDA	#1
	RTS
L066	BEQ	L067		;if charstring1 = charstring2 then
	JSR	FIXSTK		;else
	LDA	#2
	RTS
L067	INC	FRSTST
	BNE	*+4
	INC	FRSTST+1
	INC	SCNDST
	BNE	*+4
	INC	SCNDST+1	;bump string pointers
	INC	CSI		;and index
	JMP	L065		;then loop
L068	JSR	FIXSTK		;fixstack
	LDA	#3
	RTS
;string$segment(type)
SSTYPE				;type
	*=	*+1
SSTMP2				;tempa2
	*=	*+2
SSTMPB				;tempb1
	*=	*+1
SSLNG2				;lng2
	*=	*+1
STRSEG	STA	SSTYPE		;save type
	LDX	#0
	STX	SSTMPB		;tempb1:=0
	CMP	#2
	BNE	L070		;if not mid then
	JSR	FLIP
	JSR	RANEG		;if ra$negative
	BNE	L069		;then error
	JSR	RAZER		;if not
	BEQ	*+7		;ra$zero then
L069	LDA	#21		;else second parm of mid
	JMP	ERROR		;zero or negative
	JSR	CNVBAD		;conv$to$bin$addr
	LDY	#0
	LDA	(RA),Y
	STA	SSTMPB		;tempb1:=braz
	JSR	POPSTK		;pop$stack
L070	JSR	RANEG
	BNE	L071		;if ra$negative then
	JSR	ARB
	JSR	GETSLN		;get$string$len(arb)
	CMP	SSTMPB		;if < tempb1
	BCC	L071		;then
	JSR	RAZER		;if not
	BEQ	L072		;ra$zero then
L071	JSR	POPSTK		;pop$stack
	JSR	STRFRE		;stringfree
	LDY	#0
	TYA
	STA	(RA),Y
	INY
	STA	(RA),Y		;ara:=0
	RTS
L072	JSR	CNVBAD		;conv$to$bin$addr
	JSR	ARB
	JSR	GETSLN		;get$string$len(arb)
	SEC
	SBC	SSTMPB		;-tempb1
	STA	SSLNG2		;lng2:=
	LDY	#0
	CMP	(RA),Y
	BCS	L074		;if >= braz then
	LDA	SSTYPE
	CMP	#2
	BNE	L073		;if not mid then
	CLC
	LDA	SSLNG2
	ADC	#1
	STA	(RA),Y		;braz:=lng2+1
	JMP	L074
L073	LDA	SSLNG2
	STA	(RA),Y		;braz:=lng2
L074	LDA	SSTYPE
	BNE	L075		;if type <> left then
	JSR	ARB
	STA	SSTMP2
	STY	SSTMP2+1	;tempa2:=arb
	JMP	L077
L075	CMP	#1
	BNE	L076		;if not right then
	JSR	ARB
	CLC
	ADC	SSLNG2
	BCC	*+3
	INY
	STY	SSTMP2+1
	SEC
	LDY	#0
	SBC	(RA),Y
	STA	SSTMP2
	BCS	*+5
	DEC	SSTMP2+1	;tempa2:=arb+lng2-braz
	JMP	L077
L076	JSR	ARB
	CLC
	ADC	SSTMPB
	BCC	*+3
	INY
	SEC
	SBC	#1
	BCS	*+3
	DEY
	STA	SSTMP2
	STY	SSTMP2+1	;tempa2:=arb+tempb1-1
L077	LDA	SSTMP2
	LDY	SSTMP2+1
	STA	MFROM
	STY	MFROM+1		;from:=tempa2
	JSR	INCBRA
	LDY	#0
	JSR	GETS		;getspace(inc$bra)
	STA	SSTMP
	STY	SSTMP+1		;tempa:=
	STA	MTO
	STY	MTO+1		;to:=
	JSR	INCBRA
	LDY	#0
	JSR	MOVE		;move(from,to,ay)
	LDY	#0
	LDA	(RA),Y
	STA	(SSTMP),Y	;lng:=braz
	JSR	POPSTK		;pop$stack
	JSR	STRFRE		;stringfree
	LDY	#0
	LDA	SSTMP
	STA	(RA),Y
	INY
	LDA	SSTMP+1
	STA	(RA),Y		;ara:=tempa
	LDA	#TRUE
	JMP	FLSTRA		;flag$string$addr(true)
;dos/65 interface routines
;crlf
CRLF	LDA	#CR
	JSR	PRNCHR
lfout	LDA	#LF
;printchar(char)
PRNCHR	BIT	LSTFLG		;test flag
	BMI	*+7		;if set do list
PRNCON	LDX	#2
	JMP	PEM
	LDX	#5
	JMP	PEM
;read(a)
;wait for first character and set localseed to be used to seed random number
;generator
READ	PHA			;save address on stack
	TYA
	PHA
READ1	LDX	#11
	JSR	PEM		;see if ready
	BNE	READ2		;branch if is
	INC	LCLSED
	BNE	*+4
	INC	LCLSED+1	;localseed:=localseed+1
	JMP	READ1		;and loop
READ2	PLA
	TAY
	PLA			;get address
	LDX	#10
	JMP	PEM		;read buffer
;open a file
OPEN	LDA	FILADR
	LDY	FILADR+1
	LDX	#15
	JMP	PEM
;close a file
CLOSE	LDA	FILADR
	LDY	FILADR+1
	LDX	#16
	JMP	PEM
;diskread
DSKRDE	LDA	FILADR
	LDY	FILADR+1
	LDX	#20
	JMP	PEM
;diskwrite
DSKWRT	LDA	FILADR
	LDY	FILADR+1
	LDX	#21
	JMP	PEM
;create
CREATE	LDA	FILADR
	LDY	FILADR+1
	LDX	#22
	JMP	PEM
;make
MAKE	LDA	FILADR
	LDY	FILADR+1
	LDX	#19
	JSR	PEM		;delete
	JMP	CREATE
;setdma
;set address for disk i/o
SETDMA	LDA	BUFFER
	LDY	BUFFER+1
	LDX	#26
	JMP	PEM
;print(location)
;print string pointed to by ay until $ is encountered
PRINT	LDX	#9
	JMP	PEM
;dynamic storage allocation routines
;available
AVLL	STA	NBYTES
	STY	NBYTES+1	;save input parm
	LDA	MBASE
	LDY	MBASE+1
	STA	DSPNT
	STY	DSPNT+1		;point:=mbase
	LDA	#0
	STA	TOTAL
	STA	TOTAL+1		;total:=0
AVLLP	LDA	DSPNT
	ORA	DSPNT+1		;do while point<>0
	BEQ	DSPNTZ
	LDY	#4
	LDA	(DSPNT),Y	;a:=switch(4)
	BNE	SW4NZ		;if <>0 then
	LDY	#0
	LDA	(DSPNT),Y
	TAX
	INY
	LDA	(DSPNT),Y
	TAY			;xy:=here
	SEC
	TXA
	SBC	DSPNT
	TAX
	TYA
	SBC	DSPNT+1
	TAY			;xy:=here-point
	SEC
	TXA
	SBC	#5
	BCS	*+3
	DEY
	STA	AVLLT		;temp:=here-point-5
	STY	AVLLT+1
	CLC
	ADC	TOTAL
	STA	TOTAL
	TYA
	ADC	TOTAL+1
	STA	TOTAL+1		;total:=total+temp
	LDA	NBYTES
	ORA	NBYTES+1	;if nbytes<>0 then
	BEQ	SW4NZ		;else
	CLC
	LDA	NBYTES
	LDY	NBYTES+1
	ADC	#5
	BCC	*+3
	INY
	STA	AVLLT2
	STY	AVLLT2+1	;save nbytes+5
	LDA	AVLLT
	CMP	AVLLT2
	LDA	AVLLT+1
	SBC	AVLLT2+1
	BCC	SW4NZ		;if nbytes+5>temp then
	LDA	DSPNT
	LDY	DSPNT+1
	RTS			;else return point
SW4NZ	LDY	#0
	LDA	(DSPNT),Y
	TAX
	INY
	LDA	(DSPNT),Y
	STX	DSPNT
	STA	DSPNT+1		;point:=here
	JMP	AVLLP		;loop to do while
DSPNTZ	LDA	NBYTES
	ORA	NBYTES+1
	BEQ	*+7		;ok if nbytes=0
	LDA	#23		;else no memory error
	JMP	ERROR
	LDA	TOTAL
	LDY	TOTAL+1
	RTS			;return total
;getspace
GETS	STA	NBYTES
	STY	NBYTES+1
	ORA	NBYTES+1
	BNE	*+3
	RTS			;return 0
	LDA	NBYTES		;get a back (y is ok)
	JSR	AVLL		;available(nbytes)
	STA	DSPNT
	STY	DSPNT+1		;point:=
	LDY	#4		;link up the space
	LDA	#1
	STA	(DSPNT),Y	;set switch(4):=1
	CLC
	LDA	NBYTES
	LDY	NBYTES+1
	ADC	#5
	BCC	*+3
	INY
	CLC
	ADC	DSPNT
	STA	DSTMP1
	TYA
	ADC	DSPNT+1
	STA	DSTMP1+1	;temp1:=point+nbytes+5
	LDY	#0
	LDA	(DSPNT),Y
	STA	(DSTMP1),Y
	INY
	LDA	(DSPNT),Y
	STA	(DSTMP1),Y	;adr1:=here
	LDY	#0
	LDA	(DSPNT),Y
	PHA
	INY
	LDA	(DSPNT),Y
	TAY
	PLA			;ay:=here
	CLC
	ADC	#2
	BCC	*+3
	INY
	STA	DSTMP2
	STY	DSTMP2+1	;temp2:=here+2
	LDY	#0
	LDA	DSTMP1
	STA	(DSPNT),Y
	STA	(DSTMP2),Y
	INY
	LDA	DSTMP1+1
	STA	(DSPNT),Y
	STA	(DSTMP2),Y	;here,adr2:=temp1
	LDY	#4
	LDA	#0
	STA	(DSTMP1),Y	;switch2(4):=0
	CLC
	LDA	DSTMP1
	ADC	#2
	STA	DSTMP1
	BCC	*+4
	INC	DSTMP1+1	;temp1:=temp1+2
	LDY	#0
	LDA	DSPNT
	STA	(DSTMP1),Y
	INY
	LDA	DSPNT+1
	STA	(DSTMP1),Y	;adr1:=point
	LDA	NBYTES
	LDY	NBYTES+1
	STA	FN
	STY	FN+1		;fill( , ,nbytes)
	CLC
	LDA	DSPNT
	ADC	#5
	STA	DSPNT
	BCC	*+4
	INC	DSPNT+1		;point:=point+5
	LDY	DSPNT+1		;ay:=point
	LDX	#0
	JSR	FILL		;fille(point,0, )
	LDA	DSPNT
	LDY	DSPNT+1
	RTS			;return point
;release(space)
RELS	SEC
	SBC	#5
	STA	SPACE
	STA	HOLD
	BCS	*+3
	DEY
	STY	SPACE+1
	STY	HOLD+1		;hold,space:=space-5
	LDY	#4
	LDA	#0
	STA	(SPACE),Y	;switch(4):=0
	JSR	UNLINK		;combine space if possible
	CLC
	LDA	SPACE
	ADC	#2
	STA	SPACE
	BCC	*+4
	INC	SPACE+1		;space:=space+2
	LDY	#0
	LDA	(SPACE),Y
	PHA
	INY
	LDA	(SPACE),Y
	TAY
	PLA
	STA	SPACE
	STY	SPACE+1		;space:=here
	ORA	SPACE+1
	BNE	*+3		;if ( ) <> 0 then
	RTS
	LDY	#4
	LDA	(SPACE),Y	;if switch(4)=0
	BEQ	*+3		;then
	RTS
	JSR	UNLINK		;unlink
	LDA	SPACE
	LDY	SPACE+1
	STA	HOLD
	STY	HOLD+1		;hold:=space
	RTS
;unlink
UNLINK	LDY	#0
	LDA	(SPACE),Y
	STA	DSTMP3
	INY
	LDA	(SPACE),Y
	STA	DSTMP3+1	;temp:=here
	LDA	(DSTMP3),Y
	DEY
	ORA	(DSTMP3),Y
	BNE	*+3		;if adrs<>0 then
	RTS
	LDY	#4
	LDA	(DSTMP3),Y
	BEQ	*+3		;if look(4)=0 then
	RTS
	LDY	#0
	LDA	(DSTMP3),Y
	STA	(SPACE),Y
	PHA
	INY
	LDA	(DSTMP3),Y
	STA	(SPACE),Y	;here:=adrs
	TAY
	PLA
	CLC
	ADC	#2
	STA	DSTMP3
	BCC	*+3
	INY
	STY	DSTMP3+1	;temp:=here+2
	LDY	#0
	LDA	SPACE
	STA	(DSTMP3),Y
	INY
	LDA	SPACE+1
	STA	(DSTMP3),Y	;adrs:=space
	RTS
;general purpose interpreter routines
;move4(from,to)
MOVE4	LDY	#3
L080	LDA	(MFROM),Y
	STA	(MTO),Y
	DEY
	BPL	L080
	RTS
;move
;assumes from and to pointers are prestored by calling routine and that count
;is in ay at entry
MOVE	STA	MCOUNT
	STY	MCOUNT+1
	LDY	#0
MOVELP	LDA	MCOUNT
	ORA	MCOUNT+1
	BNE	*+3		;if count<>0 then
	RTS			;else done
	LDA	MCOUNT
	BNE	*+5
	DEC	MCOUNT+1
	DEC	MCOUNT		;count:=count-1
	LDA	(MFROM),Y
	STA	(MTO),Y		;(to):=(from)
	INC	MFROM
	BNE	*+4
	INC	MFROM+1		;from:=from+1
	INC	MTO
	BNE	MOVELP
	INC	MTO+1
	JMP	MOVELP		;to:=to+1
;times4(n)
TIMES4	STY	TIME4T		;store high
	ASL	A
	ROL	TIME4T
	ASL	A
	ROL	TIME4T
	LDY	TIME4T
	RTS
;fill
;assumes number bytes is prestored at fn and ay contains first address and x
;contains fill char
FILL	STA	FILLIT+1
	STY	FILLIT+2	;set address
FILLLP	LDA	FN
	BNE	*+4
	DEC	FN+1
	DEC	FN		;n:=n-1
	LDA	FN
	AND	FN+1
	CMP	#$FF		;if n <> $FFFF
	BNE	*+3		;then more
	RTS			;else done
FILLIT	STX	$FFFF		;d:=char
	INC	FILLIT+1
	BNE	FILLLP
	INC	FILLIT+2	;dest:=dest+1
	JMP	FILLLP		;and loop
;output$msg
OUTMSG	ASL	A		;mult # bu two
	TAX			;make index
	LDA	ERMTBL,X
	LDY	ERMTBL+1,X	;get address
	JSR	PRINT		;print message
	LDA	CURLIN
	ORA	CURLIN+1
	BEQ	CCRLF		;if currentline=0 then
	LDA	#<INLMSG
	LDY	#>INLMSG
	JSR	PRINT		;print(' in line ')
	LDA	CURLIN
	LDY	CURLIN+1
	clc			;add one to number
	adc	#1
	bcc	*+3
	iny
	JSR	PRNDEC
CCRLF	LDA	#CR
	JSR	PRNCON
	LDA	#LF
	JMP	PRNCON
;print ay as decimal number
DECOUT				;accum
	*=	*+2
LZFLAG				;leading zero flag
	*=	*+1
PRNDEC	STA	DECOUT
	STY	DECOUT+1	;save number
	LDA	#FALSE
	STA	LZFLAG		;clear leading zero flag
	LDX	#'0'-1		;set digit to '0' minus one
	SEC
P10000	LDA	DECOUT
	SBC	#10000*256/256
	STA	DECOUT
	LDA	DECOUT+1
	SBC	#10000/256
	STA	DECOUT+1	;subtract 10000
	INX			;bump digit
	BCS	P10000		;loop if no borrow
	LDA	DECOUT
	ADC	#10000*256/256
	STA	DECOUT
	LDA	DECOUT+1
	ADC	#10000/256
	STA	DECOUT+1	;add 10000 back in
	JSR	DIGOUT		;send digit
P1000	LDA	DECOUT
	SBC	#1000*256/256
	STA	DECOUT
	LDA	DECOUT+1
	SBC	#1000/256
	STA	DECOUT+1	;subtract 1000
	INX
	BCS	P1000		;loop if no borrow
	LDA	DECOUT
	ADC	#1000*256/256
	STA	DECOUT
	LDA	DECOUT+1
	ADC	#1000/256
	STA	DECOUT+1	;add 1000 back in
	JSR	DIGOUT		;send digit
P100	LDA	DECOUT
	SBC	#100
	STA	DECOUT
	LDA	DECOUT+1
	SBC	#0
	STA	DECOUT+1	;subtract 100
	INX			;bump digit
	BCS	P100		;loop if no borrow
	LDA	DECOUT
	ADC	#100
	STA	DECOUT		;add 100 back in
	JSR	DIGOUT		;send digit
P10	LDA	DECOUT
	SBC	#10
	STA	DECOUT		;subtract 10
	INX			;bump digit
	BCS	P10		;loop if no borrow
	ADC	#10
	STA	DECOUT		;add 10 back in
	JSR	DIGOUT		;output digit
	LDA	#'0'
	ORA	DECOUT		;make one's
	JMP	PRNCON		;print one's always
;send a single digit in x and handle leading zeros
DIGOUT	LDA	#' '		;preset for leading zero
	BIT	LZFLAG		;test flag
	BMI	D2		;branch if set
	CPX	#'0'		;see if digit = 0
	BEQ	D3		;branch if is
	LDA	#TRUE
	STA	LZFLAG		;set flag
D2	TXA			;get char
D3	JSR	PRNCON		;print char
	LDX	#'0'-1		;preset digit
	SEC
	RTS
;error(ay)
ERROR	PHA
	JSR	CCRLF
	LDA	#<ERRMSG
	LDY	#>ERRMSG
	JSR	PRINT
	PLA
	JSR	OUTMSG
	JMP	BOOT
;warning(ay)
WARNNG	PHA
	JSR	CCRLF
	LDA	#<WRNMSG
	LDY	#>WRNMSG
	JSR	PRINT		;print('warning ')
	PLA
	JMP	OUTMSG
;stack manipulation routines
;ra$negative
RANEG	LDY	#1
	LDA	(RA),Y		;get bra(1)
	BMI	*+5
	LDA	#FALSE
	RTS
	LDA	#TRUE
	RTS
;rb$negative
RBNEG	LDY	#1
	LDA	(RB),Y		;get brb(1)
	BMI	*+5
	LDA	#FALSE
	RTS
	LDA	#TRUE
	RTS
;flag$string$addr(a)
FLSTRA	LDY	#2
	AND	#1		;only do lsb
	STA	(RA),Y		;bra(2)=a
	RTS
;move$rb$ra
MVRBRA	LDY	#3
MVBAL	LDA	(RB),Y
	STA	(RA),Y
	DEY
	BPL	MVBAL
	RTS
;move$ra$rb
MVRARB	LDY	#3
MVABL	LDA	(RA),Y
	STA	(RB),Y
	DEY
	BPL	MVABL
	RTS
;ra$zero
RAZER	LDY	#0
	LDA	(RA),Y		;get braz
	BEQ	*+5
	LDA	#FALSE
	RTS
	LDA	#TRUE
	RTS
;rb$zero
RBZER	LDY	#0
	LDA	(RB),Y		;get brbz
	BEQ	*+5
	LDA	#FALSE
	RTS
	LDA	#TRUE
	RTS
;ra$zero$address
RAZERA	LDY	#0
	LDA	(RA),Y		;get low(ara)
	INY
	ORA	(RA),Y		;or with high
	BEQ	*+5
	LDA	#FALSE
	RTS
	LDA	#TRUE
	RTS
;rb$zero$address
RBZERA	LDY	#0
	LDA	(RB),Y		;get low(arb)
	INY
	ORA	(RB),Y		;or with high
	BEQ	*+5
	LDA	#FALSE
	RTS
	LDA	#TRUE
	RTS
;flip
FLIP	LDY	#3
FLIPLP	LDA	(RA),Y
	TAX
	LDA	(RB),Y
	STA	(RA),Y
	TXA
	STA	(RB),Y
	DEY
	BPL	FLIPLP
	RTS
;pop$stack
POPSTK	LDA	RB
	LDY	RB+1
	STA	RA
	STY	RA+1		;ra:=rb
	SEC
	SBC	#4
	STA	RB
	BCS	*+4
	DEC	RB+1		;rb:=rb-4
	CMP	SB
	LDA	RB+1
	SBC	SB+1
	BCC	*+3		;if rb<sb then
	RTS
	SEC			;rb:=st-4
	LDA	ST
	SBC	#4
	STA	RB
	LDY	ST+1
	BCS	*+3
	DEY
	STY	RB+1
	RTS
;step$ins$cnt
STINCN	INC	RC		;rc:=rc+1
	BNE	*+4
	INC	RC+1
	RTS
;push$stack
PSHSTK	LDA	RA
	LDY	RA+1
	STA	RB
	STY	RB+1		;rb:=ra
	CLC
	ADC	#4
	STA	RA
	BCC	*+5
	INY
	STY	RA+1		;ra:=ra+4
	CMP	ST
	TYA
	SBC	ST+1		;if (ra:=ra+4) >= st
	BCS	*+3		;then
	RTS
	LDA	SB
	LDY	SB+1
	STA	RA
	STY	RA+1		;ra:=sb
	RTS
;in$fsa(location)
;returns true if location is in fsa
INFSA	STA	INFSAT
	LDA	ST
	CMP	INFSAT
	STY	INFSAT		;save y
	LDA	ST+1
	SBC	INFSAT		;if ay>st
	LDA	#TRUE
	BCC	*+4		;then return:=true
	LDA	#FALSE		;else return:=false
	RTS
;set$data$addr(ptr)
SEDAAD	STA	SEDPTR		;save ptr
	STY	SEDPTR+1
	LDY	#0		;set a
	LDA	(SEDPTR),Y
	TAX			;save low in x
	INY
	LDA	(SEDPTR),Y
	TAY
	TXA
	JSR	INFSA		;if in$fsa
	BNE	E12		;then done
	LDY	#0
	LDA	(SEDPTR),Y	;get low
	STA	SEDAAT		;and save
	INY
	LDA	(SEDPTR),Y
	DEY
	ASL	SEDAAT
	ROL	A
	ASL	SEDAAT
	ROL	A		;times4(a)
	TAX			;save high in x
	CLC
	LDA	MPR
	ADC	SEDAAT
	STA	(SEDPTR),Y
	INY
	TXA
	ADC	MPR+1
	STA	(SEDPTR),Y	;a:=mpr+times4(a)
E12	RTS
;load$ra
;(ara) to (ra)
LOADRA	LDA	RA
	LDY	RA+1
	JSR	SEDAAD		;set$data$addr(ra)
	JSR	ARA
	STA	MFROM
	STY	MFROM+1
	LDA	RA
	LDY	RA+1
	STA	MTO
	STY	MTO+1
	JMP	MOVE4		;move4(from,to)
;calculate arb
ARB	LDY	#0
	LDA	(RB),Y
	PHA
	INY
	LDA	(RB),Y
	TAY
	PLA
	RTS
;calculate ara
ARA	LDY	#0
	LDA	(RA),Y
	PHA
	INY
	LDA	(RA),Y
	TAY
	PLA
	RTS
;calculate twobyteoprnd (arc)
ARC	LDY	#0
	LDA	(RC),Y
	PHA
	INY
	LDA	(RC),Y
	TAY
	PLA
	RTS
;console output routines
;dump$print$buff
dmppbf	jsr	crlf		;do cr and lf
;clear$print$buff
clrpbf	lda	#0
	sta	prbuff		;printbuffr:=0
	rts
;numeric$out
NUMOUT	JSR	FLODRA		;prim:=(ra)
	JSR	FLTOUT		;convert to ascii
	LDA	PRNWRK		;get first
	CMP	#' '		;see if space
	BNE	L091		;skip ahead if not
	LDX	#255
L090	INX
	LDA	PRNWRK+1,X	;move everything
	STA	PRNWRK,X	;ahead one char
	BNE	L090		;until hit zero
L091	LDX	#0
L042	INX
	LDA	NUOWRK,X	;calc string length
	BNE	L042
	STX	NUOWRK		;make length first byte
	LDA	#' '
	STA	NUOWRK,X	;insert a blank in place of $00
	LDY	#0
	LDA	#<NUOWRK
	STA	(RA),Y
	INY
	LDA	#>NUOWRK
	STA	(RA),Y		;ara:=.numberoutworkarea
	RTS
;write$to$console
WTCI				;index
	*=	*+1
WRTTCN	LDY	#0
	LDA	(RA),Y
	STA	WTCHLD
	INY
	LDA	(RA),Y
	STA	WTCHLD+1	;hold:=ara
	ORA	WTCHLD
	BEQ	E13		;if hold=0 then
	STY	WTCI		;index:=1
L048	LDY	#0
	LDA	(WTCHLD),Y	;a:=h(0)
	CMP	WTCI
	BCC	E13		;if index > h(0) then
	LDY	WTCI
	LDA	(WTCHLD),Y
	jsr	prnchr		;output character
	INC	PRBUFF		;printbuffer:=printbuffer+1
	LDA	#131
	CMP	PRBUFF
	BCS	*+5		;if printbuffer <= printbuffend then
	JSR	DMPPBF		;else dump$print$buff
	INC	WTCI
	JMP	L048		;loop
E13	RTS
;fixed point routines
;multiply primary fixed point accum by (ay) and put result in ay
MXAP	STA	SX
	STY	SX+1		;sx:=ay
	LDA	#0		;clear high
	STA	PX+2
	STA	PX+3
	LDY	#16		;do 16 bits
MXAPL	LDA	PX
	LSR	A		;test lsb
	BCC	MXAPNA		;don't add if clear
	CLC
	LDA	PX+2
	ADC	SX
	STA	PX+2
	LDA	PX+3
	ADC	SX+1
	STA	PX+3
MXAPNA	ROR	PX+3		;shift all right
	ROR	PX+2
	ROR	PX+1
	ROR	PX
	DEY
	BNE	MXAPL		;loop if more
	LDA	PX
	LDY	PX+1
	RTS
;floating point interface routines
;round$conv$bin
RNCBRA	JSR	FLODRA		;get @ ra
	LDA	#<HALF
	LDY	#>HALF
	JSR	APA		;add .5
	JSR	FSTRRA		;store @ ra
	JSR	CHKOVR		;check for overflow and faal through
;conv$to$bin$addr
CNVBAD	JSR	CNVBRA		;conv$to$binary(ra)
	LDY	#3
	LDA	(RA),Y
	LDY	#0
	STA	(RA),Y		;bra(0):=bra(3)
	LDY	#2
	LDA	(RA),Y
	DEY
	STA	(RA),Y		;bra(1):=bra(2)
	RTS
;conv$to$binary(rb)
CNVBRB	LDA	RB
	LDY	RB+1
	JMP	CNVBIN
;conv$to$binary(ra)
CNVBRA	LDA	RA
	LDY	RA+1
;conv$to$bunary(ay)
;converts floating point number @ ay to 24 bit two's complement number and
;returns value to @ ay
CNVBIN	JSR	LPA		;prim:=(ay)
	JSR	FXU		;fix it
	LDA	#0
	STA	PR
	STA	PS		;clear rounding and sign
	LDX	#0		;preset for positive
	BIT	PM		;now sign extend into pe
	BPL	*+3
	DEX
	STX	PE
	LDA	ME		;ay saved in me and me+1
	LDY	ME+1
	JSR	STP		;store it
	LDY	#1		;redo mantissa
	LDA	PM
	STA	(SL),Y		;so sign is ok
	RTS
;conv$to$fp(rb)
CNVFRB	LDA	RB
	LDY	RB+1
	JMP	CNVFLT
;conv$to$fp(ra)
CNVFRA	LDA	RA
	LDY	RA+1
;conv$to$fp(ay)
;converts 24 bit integer @ ay to floating point number and store @ ay
CNVFLT	JSR	LPA		;prim:=(ay)
	LDY	#1
	LDA	(ME),Y		;redo first mantissa
	STA	PM		;so sign bit is ok
	LDX	#24+128
	STX	PE		;set exponent
	LDA	PM
	EOR	#$FF
	ROL	A		;set carry to -sign
	LDA	#0
	STA	PR
	STA	PS		;clear sign and rounding
	JSR	CYENT		;normalize
	LDA	ME
	LDY	ME+1		;ay saved in me and me+1
	JMP	STP		;store it
;float$addr(ay)
FLTADR	JSR	FLT16		;float ay
	JMP	FSTRRA		;and store
;compare$fp
;returns 1 if (rb)<(ra); 2 if (rb)>(ra); 3 if (rb)=(ra)
COMPFP	JSR	FLODRA		;load (ra)
	LDA	RB
	LDY	RB+1
	JSR	SPA		;prim:=(rb)-(ra)
	JSR	FSTRRA		;store @ (ra)
	JSR	RAZER
	BEQ	L049		;if not ra$zero then
	JSR	POPSTK		;else
	LDA	#3
	RTS
L049	JSR	RANEG
	BEQ	L050		;if not ra$negative then
	JSR	POPSTK
	LDA	#1
	RTS
L050	JSR	POPSTK
	LDA	#2
	RTS
;load (ra) into primary floating point accum
FLODRA	LDA	RA
	LDY	RA+1
	JMP	LPA		;prim:=(ra)
;store primary floating point accum at (ra)
FSTRRA	LDA	RA
	LDY	RA+1
	JMP	STP
;load (rb) into primary floating point accum
FLODRB	LDA	RB
	LDY	RB+1
	JMP	LPA
;store primary floating point accum at (rb)
FSTRRB	LDA	RB
	LDY	RB+1
	JMP	STP
;check$overflow
CHKOVR	BIT	OVERFL
	BPL	E24		;if not overflow then
	LDA	#26		;else send overflow warning
	JSR	WARNNG
	LDY	#3
L025	LDA	MAXNUM,Y
	STA	(RA),Y
	DEY
	BPL	L025		;(ra):=maxnum
	INY
	STY	OVERFL		;overflow:=false
	STY	PR
	STY	PC
	STY	PS		;clear sign, carry, and rounding
E24	RTS
;floating point routines
;constants
MAXNUM	.byte	$FF,$7F,$FF,$FF
HALF	.byte	$80,0,0,0	;(0.5)
FIVE9S	.byte	$91,$43,$4F,$F8	;(99999.9375)
SIX9S	.byte	$94,$74,$23,$F7	;(999999.4375)
MILLON	.byte	$94,$74,$24,0	;(1000000)
TEN	.byte	$84,$20,0,0	;(10)
ONE	.byte	$81,0,0,0	;(1)
PI2	.byte	$81,$49,$0F,$DB	;(PI/2)
SQR2	.byte	$81,$35,$04,$F3	;(SQR(2))
MHALF	.byte	$80,$80,0,0	;(-0.5)
LN2	.byte	$80,$31,$72,$18	;(LN(2))
LN2INV	.byte	$81,$38,$AA,$3B	;(1/LN(2))
SQR2D2	.byte	$80,$35,$04,$F3	;(SQR(2)/2)
TWOPI	.byte	$83,$49,$0F,$DB	;(2*PI)
QUARTR	.byte	$7F,0,0,0	;(0.25)
MONE	.byte	$81,$80,0,0	;(-1)
RNDWRK	.byte	$80,$3F,$C7,$52
RNDMUL	.byte	$98,$35,$44,$7A
RNDADD	.byte	$68,$28,$B1,$46
;conversion data tables
CNVTBL	.byte	$FE,$79,$60	;-100,000
	.byte	0,$27,$10	;10,000
	.byte	$FF,$FC,$18	;-1000
	.byte	0,0,100		;100
	.byte	$FF,$FF,$F6	;-10
	.byte	0,0,1		;1
;series evaluation chains
LOGCHN	.byte	2
	.byte	$80,$19,$56,$AA
	.byte	$80,$76,$22,$F0
	.byte	$82,$38,$AA,$40
EXPCHN	.byte	7
	.byte	$74,$94,$2E,$40
	.byte	$77,$2E,$4F,$70
	.byte	$7A,$88,$02,$6E
	.byte	$7C,$2A,$A0,$E6
	.byte	$7E,$AA,$AA,$50
	.byte	$7F,$7F,$FF,$FF
	.byte	$81,$80,0,0
	.byte	$81,0,0,0
SINCHN	.byte	4
	.byte	$86,$1E,$D7,$BA
	.byte	$87,$99,$26,$64
	.byte	$87,$23,$34,$58
	.byte	$86,$A5,$5D,$E0
	.byte	$83,$49,$0F,$DA
ATNCHN	.byte	8
	.byte	$78,$3B,$D7,$4A
	.byte	$7B,$84,$6E,$02
	.byte	$7C,$2F,$C1,$FE
	.byte	$7D,$9A,$31,$74
	.byte	$7D,$5A,$3D,$84
	.byte	$7E,$91,$7F,$C8
	.byte	$7E,$4C,$BB,$E4
	.byte	$7F,$AA,$AA,$6C
	.byte	$81,0,0,0
;float 8 bit value in a as positive number
FLT8	LDY	#0		;clear ms byte
;float 16 bit value in ay as positive number
FLT16	STA	PM+1
	STY	PM		;set mantissa
	LDX	#16+128		;exponent:=16
	SEC
	STX	PE
	LDA	#0
	STA	PM+2
	STA	PR
	STA	PS		;clear sign, mantissa (high), and rounding
	JMP	NORMLZ		;go normalize
;two's complement of primary accumulator
TCP	LDA	PS		;complement sign
	EOR	#$FF
	STA	PS
TCPNS	LDA	PM		;then mantissa
	EOR	#$FF
	STA	PM
	LDA	PM+1
	EOR	#$FF
	STA	PM+1
	LDA	PM+2
	EOR	#$FF
	STA	PM+2
	LDA	PR		;then rounding byte
	EOR	#$FF
	STA	PR
	INC	PR		;now add one to all
	BNE	E1
;increment primary mantissa
INP	INC	PM+2		;bump mantissa
	BNE	E1
	INC	PM+1
	BNE	E1
	INC	PM
E1	RTS
;extract sign of primary accumulator and test primary accumulator for zero.
;if primary zero then z=1 and a=0 else if positive then z=0 and a=1 else if
;negative then z=0 and a=$ff
ESP	LDA	PE		;get exponent
	BEQ	E2		;exit if zero
ESPS	LDA	PS		;get sign
ESPSRL	ROL	A		;move to carry
	LDA	#$FF		;preset for minus
	BCS	E2		;branch if is
	LDA	#1		;else positive
E2	RTS
;store primary accumulator at memory at (ay)
STP	STA	SL
	STY	SL+1		;sl:=ay
;store primary accumulator at (sl) after rounding
SPM	JSR	RNP		;round it
	LDY	#3
	LDA	PM+2
	STA	(SL),Y
	DEY
	LDA	PM+1
	STA	(SL),Y
	DEY
	LDA	PS		;now or sign with pm
	ORA	#$7F
	AND	PM
	STA	(SL),Y
	DEY
	LDA	PE
	STA	(SL),Y
	STY	PR		;clear rounding
	RTS
;load primary accumulator from memory at (ay)
LPA	STA	ME
	STY	ME+1		;me:=ay
;load primary accumulator from memory at (me)
LPM	LDY	#3		;four-one bytes
	LDA	(ME),Y
	STA	PM+2
	DEY
	LDA	(ME),Y
	STA	PM+1
	DEY
	LDA	(ME),Y
	STA	PS
	ORA	#$80
	STA	PM		;set implied 1
	DEY
	LDA	(ME),Y
	STA	PE
	STY	PR		;rounding:=0
	RTS
;load secondary accumulator from (ay)
LSA	STA	ME
	STY	ME+1		;me:=ay
;load secondary accumulator from (me)
LSM	LDY	#3
	LDA	(ME),Y
	STA	SM+2
	DEY
	LDA	(ME),Y
	STA	SM+1
	DEY
	LDA	(ME),Y
	STA	SS
	EOR	PS
	STA	SGNCMP
	LDA	SS
	ORA	#$80
	STA	SM
	DEY
	LDA	(ME),Y
	STA	SE
	RTS
;transfer secondary accumulator to primary and clear rounding
TSP	LDA	SS
	STA	PS
	LDA	SM+2
	STA	PM+2
	LDA	SM+1
	STA	PM+1
	LDA	SM
	STA	PM
	LDA	SE
	STA	PE
	LDA	#0
	STA	PR
	RTS
;transfer primary accumulator to secondary after rounding and clear rounding
TPS	JSR	RNP		;round primary
	LDA	PS
	STA	SS
	LDA	PM+2
	STA	SM+2
	LDA	PM+1
	STA	SM+1
	LDA	PM
	STA	SM
	LDA	PE
	STA	SE
	LDA	#0
	STA	PR
	RTS
;subtract primary accumulator from memory (ay)
;p:=(ay)-p
SPA	JSR	LSA		;move memory to secondary
;subtract primary accumulator from secondary
;p:=s-p
SPS	LDA	PS		;complement primary sign
	EOR	#$FF
	STA	PS
	EOR	SS
	STA	SGNCMP		;set compare status
	JMP	APS		;and add
;alternate entry to shift routine
SXRYAL	PHA			;save a
	JMP	SXRYE
;shift product staging area right one byte
SQR8	LDX	#QE
;shift number pointed to by x right a times. must be at least 8 times to start
;as entire bytes are shifted
SXR8	LDY	3,X		;move whole bytes
	STY	PR
	LDY	2,X
	STY	3,X
	LDY	1,X
	STY	2,X
	LDY	PC
	STY	1,X
;shift number pointed to by x right a times
SXRA	ADC	#8		;add 8
	BMI	SXR8		;loop if at least a byte
	BEQ	SXR8
	SBC	#8		;drop back to bits
	TAY			;move to y
	LDA	PR		;get rounding
	BCS	E4		;done if carry
SXRY	PHA
	LDA	1,X
	AND	#$80		;clear all but msb
	LSR	1,X		;shift right and clear cy
	ORA	1,X
	STA	1,X
SXRYE	ROR	2,X
	ROR	3,X
	PLA
	ROR	A
	INY
	BNE	SXRY		;loop if more
E4	CLC			;always clear carry
	RTS
;compare number at (ay) to primary accumulator
CPA	STA	SL
	STY	SL+1		;sl:=ay
;compare primary accumulator to number at (sl)
CPM	LDY	#0
	LDA	(SL),Y		;get exponent
	INY
	TAX			;test
	BNE	*+5		;continue if n <> 0
	JMP	ESP		;else go extract primary sign
	LDA	(SL),Y		;get mantissa
	EOR	PS		;test sign part
	BPL	*+5		;branch if same
	JMP	ESPS		;test primary
	CPX	PE		;compare exponents
	BNE	CPMSGN		;try signs if different
	LDA	(SL),Y		;get m again
	ORA	#$80		;set hidden bit
	CMP	PM		;compare to pm
	BNE	CPMSGN
	INY
	LDA	(SL),Y		;get next
	CMP	PM+1		;compare
	BNE	CPMSGN
	INY
	LDA	#127
	CMP	PR		;subtract
	LDA	(SL),Y
	SBC	PM+2
	BNE	CPMSGN
	RTS
CPMSGN	LDA	PS		;get sign
	BCC	*+4		;ok if borrow
	EOR	#$FF		;else complement
	JMP	ESPSRL		;now test
;add single byte in a into primary accumulator
ADP	PHA			;save digit
	LDA	#<T0
	LDY	#>T0
	JSR	STP		;t:=p
	PLA			;get digit
	STA	PM
	EOR	#$FF
	ROL	A
	LDX	#8+128
	STX	PE		;exp:=8
	LDA	#0
	STA	PM+1
	STA	PM+2
	STA	PR
	STA	PS
	JSR	CYENT		;normalize
	LDA	#<T0
	LDY	#>T0
	JMP	APA		;p:=p+a
;add primary accumulator to memory at (ay)
;p:=(ay)+p
APA	JSR	LSA		;load secondary with memory
;add primary accumulator to secondary and put result in primary
;p:=p+s
APS	LDA	PE		;get prim exp
	BNE	*+5		;use if p <> 0
	JMP	TSP		;else just move s to p
	LDX	PR		;get rounding
	STX	SAVPR		;save it
	LDX	#SE		;point to secondary
	LDA	SE		;get sec exp
SPE	TAY
	BEQ	E5		;done if zero
	SEC
	SBC	PE		;a:=se-pe
	BEQ	ENDALG		;branch if aligned
	BCC	PEGTSE		;branch if pe>se
	STY	PE		;move se to pe
	LDY	SS		;get sec sign
	STY	PS		;move to prim sign
	EOR	#$FF		;complement difference
	ADC	#0
	LDY	#0		;clear prim rounding
	STY	SAVPR		;save location
	LDX	#PE		;do primary rather than secondary
	JMP	DOALGN		;go align
PEGTSE	LDY	#0		;clear real rounding
	STY	PR
DOALGN	CMP	#$F9		;check exp difference
	BPL	ALGNP		;branch if less
	JSR	SXRA		;else shift right
	JMP	ENDALG		;then go ahead
ALGNP	TAY			;get difference
	LDA	PR
	LSR	1,X		;clear msb of first mantissa
	JSR	SXRYAL		;go shift
ENDALG	BIT	SGNCMP		;test sign compare
	BPL	DOADD		;go do if signs same
;subtract two values
	LDY	#PE
	CPX	#SE
	BEQ	*+4		;jump if same
	LDY	#SE		;else point to se
	SEC
	EOR	#$FF
	ADC	SAVPR
	STA	PR
	LDA	3,Y		;start subtraction
	SBC	3,X
	STA	PM+2
	LDA	2,Y
	SBC	2,X
	STA	PM+1
	LDA	1,Y
	SBC	1,X
	STA	PM
CYENT	BCS	NORMLZ		;if no borrow ok
	JSR	TCP		;else complement
NORMLZ	LDY	#0		;clear a y and cy
	TYA
	CLC
SPLL	LDX	PM		;get first part of mantissa
	BNE	SHFBTL		;go shift bits if not zero
	LDX	PM+1		;else shift whole bytes
	STX	PM
	LDX	PM+2
	STX	PM+1
	LDX	PR
	STX	PM+2
	STY	PR		;clear rounding
	ADC	#8		;bump exponent
	CMP	#32		;see if too small
	BNE	SPLL		;branch if more
ZRORSL	LDA	#0		;underflow therefore = 0
	STA	PE
	STA	PS
E5	RTS
;add two values
DOADD	ADC	SAVPR
	STA	PR
	LDA	PM+2
	ADC	SM+2
	STA	PM+2
	LDA	PM+1
	ADC	SM+1
	STA	PM+1
	LDA	PM
	ADC	SM
	STA	PM
	JMP	CHKCRY		;go see if carry and thus normalization
BITSL	ADC	#1		;bump exponent
	ASL	PR
	ROL	PM+2
	ROL	PM+1
	ROL	PM
SHFBTL	BPL	BITSL		;loop if msb not 1
	SEC
	SBC	PE
	BCS	ZRORSL		;zero if underflow
	EOR	#$FF		;two's complement
	ADC	#1
	STA	PE
CHKCRY	BCC	E6		;done if no carry
ADJPE	INC	PE		;bump exponent
	BEQ	APSOVF		;overflow if zero
	ROR	PM		;shift all right
	ROR	PM+1
	ROR	PM+2
	ROR	PR
E6	RTS
;add overflow trap
APSOVF	LDA	#TRUE
	STA	OVERFL		;overflow:=true
	RTS
;negate primary accumulator
NEG	LDA	PE
	BEQ	E10		;done if zero
	LDA	PS
	EOR	#$FF
	STA	PS		;complement sign
E10	RTS
;round primary accumulator
RNP	LDA	PE		;get exp
	BEQ	E3		;done if zero
	ASL	PR		;test msb of rounding
	BCC	E3		;done if zero
	JSR	INP		;else bump prim
	BNE	E3		;done if not zero
	JSR	ADJPE		;adjust exponent
E3	RTS
;setup multiplication and division
SUPMD	LDA	SE		;if s=0
SUPMDX	BEQ	MDZRO		;then p:=0
	CLC
	ADC	PE		;a:=pe+se
	BCS	*+6		;branch if carry
	BPL	MDZRO		;branch if 0 to 7f
	BMI	NZRO		;branch if 80 to ff
	BMI	MDZRO		;carry set and 80 to ff
;result not necessarily zero
NZRO	CLC
	ADC	#$80
	STA	PE		;pe:=pe+se+$80
	BEQ	*+4
	LDA	SGNCMP		;if different signs
	STA	PS		;then p < 0
	RTS
;result zero
MDZRO	PLA
	PLA			;clear stack
	LDA	#0
	STA	PE		;pe:=0
	STA	PS		;p positive
	RTS
;multiply by one byte
MULNZB	BNE	*+5		;if byte <> 0 then do slow
	JMP	SQR8		;else just shift whole bytes
MULBYT	LSR	A		;lsb to cy
	ORA	#%10000000	;set msb for counter
MULLPE	TAY			;save counter in y
	BCC	SHONLY		;shift only if zero
	CLC			;else q:=q+s
	LDA	QM+2
	ADC	SM+2
	STA	QM+2
	LDA	QM+1
	ADC	SM+1
	STA	QM+1
	LDA	QM
	ADC	SM
	STA	QM
SHONLY	ROR	QM		;shift all right
	ROR	QM+1
	ROR	QM+2
	ROR	PR
	TYA			;get counter
	LSR	A		;shift it
	BNE	MULLPE		;loop if more
	RTS
;multiply primary accumulator by 10 by shifting (for number conversion)
MPT	JSR	TPS		;s:=p
	LDA	PE		;if p=0
	BEQ	E9		;then done
	CLC
	ADC	#2		;pe:=pe+2
	BCS	MPTOVF		;error
	LDX	#0
	STX	SGNCMP		;clear sign compare
	JSR	SPE		;shift primary
	INC	PE		;pe:=pe+1
	BEQ	MPTOVF		;error
E9	RTS
MPTOVF	LDA	#TRUE
	STA	OVERFL		;overflow:=true
	RTS
;multiply primary accumulator by memory at (ay)
;p:=p*(ay)
MPA	JSR	LSA		;load memory into secondary
;multiply primary accumulator by secondary
;p:=p*s
MPS	LDA	PE		;test primary
	BEQ	E8		;done if zero
	JSR	SUPMD		;set up
	LDA	#0		;q:=0
	STA	QM
	STA	QM+1
	STA	QM+2
	LDA	PR		;multiply byte at a time
	JSR	MULNZB
	LDA	PM+2
	JSR	MULNZB
	LDA	PM+1
	JSR	MULNZB
	LDA	PM
	JSR	MULBYT
;transfer quotient to primary accum and normalize
TQP	LDA	QM		;p:=q
	STA	PM
	LDA	QM+1
	STA	PM+1
	LDA	QM+2
	STA	PM+2
	JMP	NORMLZ		;go normalize
E8	RTS
;divide primary accumulator by 10
DPT	JSR	TPS		;s:=p
	LDA	#0
	STA	SGNCMP		;clear sign comparison
	LDA	#<TEN
	LDY	#>TEN
	JSR	LPA		;p:=10
	JMP	DSP		;p:=p/10
;divide memory at (ay) by primry accumulator
;p:=(ay)/p
DAP	JSR	LSA		;s:=(ay)
;divide secondary accumulator by primary
DSP	LDA	PE		;if p=0
	BEQ	DIVZRO		;then error
	LDA	#0
	SEC
	SBC	PE
	STA	PE		;pe:=-pe
	JSR	SUPMD		;setup everything
	INC	PE
	BEQ	DIVOVF		;overflow error
	LDX	#$FD		;x:=-3
	LDA	#1		;set bit counter to 1
CMPSP	LDY	SM		;if s<>p
	CPY	PM
	BNE	SNEP		;then
	LDY	SM+1
	CPY	PM+1
	BNE	SNEP
	LDY	SM+2
	CPY	PM+2
SNEP	PHP			;save carry
	ROL	A		;bump counter
	BCC	MORE		;branch if more
	INX			;else bump index
	STA	QM+2,X		;set next byte
	BNE	*+6		;branch if x<>0
	LDA	#64		;do last byte
	BNE	MORE
	BPL	DDONE		;exit if last
	LDA	#1		;else reset bit counter
MORE	PLP			;get carry
	BCS	NOBRW		;branch if no borrow
SHFS	ASL	SM+2
	ROL	SM+1
	ROL	SM
	BCS	SNEP
	BMI	CMPSP
	BPL	SNEP
NOBRW	TAY			;save counter in y
	LDA	#0
	SBC	PR		;s:=s-p
	LDA	SM+2
	SBC	PM+2
	STA	SM+2
	LDA	SM+1
	SBC	PM+1
	STA	SM+1
	LDA	SM
	SBC	PM
	STA	SM
	TYA			;get count
	JMP	SHFS		;and loop
;exit from division
DDONE	ASL	A
	ASL	A
	ASL	A
	ASL	A
	ASL	A
	ASL	A
	STA	PR
	PLP
;now do p:=q and normalize
	JMP	TQP
;division error routines
DIVOVF	LDA	#TRUE
	STA	OVERFL
	RTS
DIVZRO	LDA	#TRUE
	STA	DVZERO
	RTS
;convert floating to fixed unsigned
FXU	LDA	PE
	BNE	ISNTZ
	STA	PM		;if p=0 clear all
	STA	PM+1
	STA	PM+2
	TAY			;and y
	RTS
ISNTZ	SEC
	SBC	#24+128
	BIT	PS		;test sign
	BPL	ISPOST		;if positive
	TAX
	LDA	#255
	STA	PC		;set carry
	JSR	TCPNS		;complement
	TXA
ISPOST	LDX	#PE		;point to prim
	CMP	#$F9
	BPL	NOSHFR
	JSR	SXRA		;shift right
	STY	PC		;clear carry
	RTS
NOSHFR	TAY			;set counter
	LDA	PS		;set msb of pm to ps
	AND	#$80
	LSR	PM		;set carry
	ORA	PM
	STA	PM
	JSR	SXRYAL		;go shift
	STY	PC		;clear carry
	RTS
;convert floating to signed 24 bit integer
INT	LDA	PE
	CMP	#24+128
	BCS	E7		;done if exact or too big
	JSR	FXU		;fix it
	STY	PR		;clear rounding
	LDA	PS		;get sign
	STY	PS		;then clear
	EOR	#$80
	ROL	A		;set carry by sign
	LDA	#24+128		;set exponent
	STA	PE
	LDA	PM+2
	STA	LSB		;save lsb
	JMP	CYENT		;go normalize
E7	RTS
;series evaluation for squared arguments with chain at (ay)
SRSAS	STA	SRPNT
	STY	SRPNT+1
;series evaluation for squared arguments with chain at (srpnt)
SRSS	LDA	#<T0
	LDY	#>T0
	JSR	STP		;save accum in temp 0
	LDA	#<T0
	LDY	#>T0
	JSR	MPA		;p:=x*x
	JSR	SRS		;evaluate series
	LDA	#<T0
	LDY	#>T0
	JMP	MPA		;p:=p*x
;series evauation for arguments with chain at (ay)
SRSA	STA	SRPNT
	STY	SRPNT+1
;series evauation for arguments with chain at (srpnt)
SRS	LDA	#<T1
	LDY	#>T1
	JSR	STP		;t1:=x
	LDY	#0
	LDA	(SRPNT),Y	;get count
	STA	SRCNT		;and save
	INC	SRPNT
	BNE	*+4
	INC	SRPNT+1		;srpnt:=srpnt+1
	LDA	SRPNT
	LDY	SRPNT+1		;get destination
SRSLPE	JSR	MPA		;p:=p*(srpnt)
	CLC
	LDA	SRPNT
	ADC	#4
	STA	SRPNT
	BCC	*+4
	INC	SRPNT		;srpnt:=srpnt+4
	LDY	SRPNT+1
	JSR	APA		;p:=p+(srpnt)
	LDA	#<T1
	LDY	#>T1
	DEC	SRCNT
	BNE	SRSLPE		;loop if more
	RTS
;get next char from accum, bump index for next access, and test for number
GETTST	INC	CNVIND		;bump index
	LDX	CNVIND		;get index
	LDA	ACCUM,X		;get char
;test for a number
;if a number then c=0 else c=1
TSTNUM	CMP	#'9'+1		;if <= '9'
	BCC	*+3		;may be a number
	RTS			;else isn't
	CMP	#'0'		;if <0
	BCC	*+4		;isn't
	CLC
	RTS			;else is
	SEC
	RTS
;add char at accum(cnvind) to input conversion exponent
ACE	LDA	NE
	ASL	A
	ASL	A		;a:=4*exp
	CLC
	ADC	NE		;a:=5*exp
	ASL	A		;a:=10*exp
	CLC
	LDY	CNVIND
	ADC	ACCUM,Y		;a:=accum(cnvind)
	SEC
	SBC	#'0'
	STA	NE		;ne:=10*ne+accum(cnvind)
	RTS
;move ascii string at (ay) to accum and convert x characters to floating
FLTINP	STA	GFLTIC+1
	STY	GFLTIC+2	;set address
	CPX	#0		;if 1 or more
	BNE	*+5		;go do
	JMP	ZRORSL		;else just clear accum
	LDY	#0		;clear index
GFLTIC	LDA	$FFFF,Y		;get char
	STA	ACCUM,Y		;put in accum
	INY
	DEX
	BNE	GFLTIC		;loop if more
	TXA
	STA	ACCUM,Y		;insert terminal char
	LDX	#9
CLRN	STA	NE,X
	DEX
	BPL	CLRN		;loop for more
	STX	CNVIND		;set index to -1
	JSR	GETTST		;get and test
	BCC	NOSIGN		;branch if is
	CMP	#'+'		;if a +
	BEQ	GNNC		;get next char
	CMP	#'-'		;if not a -
	BNE	NOTDIG		;try E and .
	LDX	#$FF
	STX	NS		;set sign to neg
GNNC	JSR	GETTST		;get and test
	BCS	NOTDIG		;branch if not number
NOSIGN	PHA			;save char
	BIT	DPFLG		;test for prior dec point
	BPL	*+4		;branch if none
	INC	DPOFF		;bump offset
	JSR	MPT		;p:=p*10
	PLA
	AND	#$0F
	JSR	ADP		;p:=p+num
	JMP	GNNC		;loop for more
NOTDIG	CMP	#'.'		;if a .
	BEQ	DPHNDL		;go handle it
	CMP	#'E'		;if not E
	BNE	NESSET		;go ahead
	JSR	GETTST		;get next char
	BCC	DOEN		;number so is exponent
	CMP	#'-'		;if -
	BEQ	EXPMIN		;exp is minus
	CMP	#'+'
	BEQ	GNEC		;if plus get exp
	BNE	ENDEXP		;else end
EXPMIN	ROR	NESFLG		;shift cy into flag
GNEC	JSR	GETTST		;get and test
	BCS	ENDEXP		;done if not number
DOEN	JSR	ACE		;add to exponent
	JMP	GNEC		;and loop
ENDEXP	BIT	NESFLG		;test neg exp flag
	BPL	NESSET		;branch if pos
	LDA	#0
	SEC
	SBC	NE		;-ne
	JMP	NESSUB
DPHNDL	ROR	DPFLG		;set dec pt flag
	BIT	DPFLG		;test for two
	BVC	GNNC		;branch if none
NESSET	LDA	NE
NESSUB	SEC
	SBC	DPOFF		;ne-dpoffset
	STA	NE
	BEQ	SETSGN		;done if zero
	BPL	MUL10		;muklt if +
DIV10	JSR	DPT		;else divide by ten
	INC	NE
	BNE	DIV10		;until done
	JMP	SETSGN
MUL10	JSR	MPT		;mult by 10
	DEC	NE
	BNE	MUL10
SETSGN	LDA	NS		;get sign
	BPL	E11		;done if pos
	LDA	PE
	BEQ	E11		;or if p=0
	LDA	PS
	EOR	#$FF
	STA	PS		;else complement sign
E11	RTS
;convert contents of primary accumulator to 12 digit number at printworkarea
;CAUTION: primary accumulator contents destroyed
FLTOUT	LDY	#1
	LDA	#' '		;preset for positive
	BIT	PS		;test sign
	BPL	*+4		;branch if pos
	LDA	#'-'		;else get -
	STA	PRNWRK-1,Y	;put in buffer
	STA	PS		;make sign positive
	STY	CNVIND		;save index
	INY
	LDA	#'0'
	LDX	PE		;get exponent
	BNE	*+5		;ok if not zero
	JMP	ONEZRO		;else is zero
	LDA	#0
	CPX	#128		;see if >= 0
	BEQ	*+4		;branch if =
	BCS	SVEDOF		;branch if > 0
	LDA	#<MILLON	;mult by million
	LDY	#>MILLON
	JSR	MPA
	LDA	#$FA		;offset = -6
SVEDOF	STA	DPOFF		;save offset
TRY69S	LDA	#<SIX9S		;point to 999999.4375
	LDY	#>SIX9S
	JSR	CPA		;and compare
	BEQ	TRY59S		;branch
	BPL	MUSTDV		;must divide
TRY59S	LDA	#<FIVE9S	;point to 99999.9375
	LDY	#>FIVE9S
	JSR	CPA		;and compare
	BEQ	*+4		;mult if =
	BPL	EXTMDP		;exit
	JSR	MPT		;multiply by 10
	DEC	DPOFF		;drop offset
	BNE	TRY59S		;loop if more
MUSTDV	JSR	DPT		;divide pri by 10
	INC	DPOFF		;bump offset
	BNE	TRY69S		;loop if more
EXTMDP	LDA	#<HALF		;round
	LDY	#>HALF
	JSR	APA
	JSR	FXU		;and make integer
	LDX	#1
	LDA	DPOFF		;get offset
	CLC
	ADC	#7		;add seven
	BMI	JUSTS		;subtract if minus
	CMP	#8
	BCS	JUSTS		;or if >= 8
	ADC	#255		;else add -1
	TAX			;save
	LDA	#2		;a:=2
JUSTS	SEC
	SBC	#2
	STA	NE		;save exponent
	STX	DPOFF		;save offset
	TXA
	BEQ	*+4
	BPL	NODP		;branch if no dp
	LDY	CNVIND		;get index
	LDA	#'.'		;get period
	INY
	STA	PRNWRK-1,Y	;put in
	TXA
	BEQ	NZYET
	LDA	#'0'		;put in a zero
	INY
	STA	PRNWRK-1,Y
NZYET	STY	CNVIND		;save index
NODP	LDY	#0		;clear add/sub index
	LDX	#128
PRIOLP	CLC
	LDA	PM+2
	ADC	CNVTBL+2,Y
	STA	PM+2
	LDA	PM+1
	ADC	CNVTBL+1,Y
	STA	PM+1
	LDA	PM
	ADC	CNVTBL,Y
	STA	PM
	INX
	BCS	*+6
	BPL	PRIOLP		;loop if no overflow
	BMI	*+4		;else got digit
	BMI	PRIOLP		;also loop
	TXA			;move count to a
	BCC	*+6
	EOR	#$FF
	ADC	#10
	ADC	#'0'-1		;make ascii
	INY
	INY
	INY			;adjust index
	STY	TY		;save it
	LDY	CNVIND		;get index
	INY			;bump
	TAX
	AND	#$7F		;clear msb
	STA	PRNWRK-1,Y	;insert char
	DEC	DPOFF		;drop offset-
	BNE	STLNDP		;branch if still no dp
	LDA	#'.'
	INY
	STA	PRNWRK-1,Y	;insert .
STLNDP	STY	CNVIND		;save index
	LDY	TY		;get y back
	TXA
	EOR	#$FF
	AND	#$80
	TAX
	CPY	#18		;see if y at max
	BNE	PRIOLP		;loop if not
	LDY	CNVIND
SKPZRO	LDA	PRNWRK-1,Y	;get char
	DEY			;and backup past leading zeros
	CMP	#'0'
	BEQ	SKPZRO
	CMP	#'.'		;if dp
	BEQ	*+3		;ok
	INY			;else forward
	LDA	#'+'		;preset for exp sign
	LDX	NE		;get exponent
	BEQ	PUTSTP		;done if none
	BPL	EXPPOS		;if pos go
	SEC
	LDA	#0
	SBC	NE
	TAX			;adjust exponent
	LDA	#'-'
EXPPOS	STA	PRNWRK+1,Y	;put in sign
	LDA	#'E'		;then E
	STA	PRNWRK,Y
	TXA
	LDX	#'0'-1		;preset 10s
	SEC
CLC10S	INX
	SBC	#10
	BCS	CLC10S
	ADC	#'0'+10		;calc ones
	STA	PRNWRK+3,Y	;insert it
	TXA
	STA	PRNWRK+2,Y	;then 10s
	LDA	#0
	STA	PRNWRK+4,Y	;insert stopper
	RTS
ONEZRO	STA	PRNWRK-1,Y	;insert char
PUTSTP	LDA	#0
	STA	PRNWRK,Y
	RTS
;TRANSCENDENTAL ROUTINES
;generate random number and leave in prim accumulator
RND	LDA	#<RNDWRK
	LDY	#>RNDWRK
	JSR	LPA		;move old to accum
	LDA	#<RNDMUL
	LDY	#>RNDMUL
	JSR	MPA		;multiply my scale
	LDA	#<RNDADD
	LDY	#>RNDADD
	JSR	APA		;add offset
NEWRND	LDX	PM+2		;shuffle things around
	LDA	PM
	STA	PM+2
	STX	PM
	LDA	#0
	STA	PS		;must be positive
	LDA	PE
	STA	PR
	LDA	#0+128
	STA	PE		;< 1
	JSR	NORMLZ		;normalize it
	LDA	#<RNDWRK
	LDY	#>RNDWRK
	JMP	STP		;save new random number
;natural log of primary accumulator
LOG	JSR	ESP		;test sign of primary
	BEQ	LOGOVF		;error if zero
	BMI	LOGOVF		;error if minus
	LDA	PR
	ORA	PM+2
	ORA	PM+1
	BNE	DOLOG		;can't be 1.000000
	LDA	PM
	AND	#$7F		;see if only 1
	BNE	DOLOG		;isn't
	LDA	PE
	CMP	#1+128		;must be 1*2
	BNE	DOLOG		;isn't
	LDA	#0		;result
	STA	PE		;exactly zero
	STA	PM
	RTS
DOLOG	SEC
	LDA	PE
	SBC	#128		;get for exp*log(2)
	PHA			;save for later
	LDA	#0+128		;set to <1
	STA	PE
	LDA	#<SQR2D2
	LDY	#>SQR2D2
	JSR	APA		;add sqr(2)/2
	LDA	#<SQR2
	LDY	#>SQR2
	JSR	DAP		;sqr(2)/p
	LDA	#<ONE
	LDY	#>ONE
	JSR	SPA		;1-p
	LDA	#<LOGCHN
	LDY	#>LOGCHN
	JSR	SRSAS		;do series for x*x
	LDA	#<MHALF
	LDY	#>MHALF
	JSR	APA		;-.5+p
	PLA			;get exp
	JSR	ADP		;add digit
	LDA	#<LN2
	LDY	#>LN2
	JMP	MPA		;multiply by ln 2
;illegal log (i.e. neg or zero argument)
LOGOVF	LDA	#TRUE
	STA	OVERFL
	RTS
;e to the primary accumulator
EXP	LDA	#<T0
	LDY	#>T0
	JSR	STP		;t0:=p
	LDA	#<LN2INV
	LDY	#>LN2INV
	JSR	MPA		;p:=p/(ln(2))
	LDA	PE
	CMP	#8+128		;if pe < 8
	BCC	EXPOK		;then ok
	BIT	PS		;else test sign
	BPL	EXPOVF		;overflow if positive
	LDA	#0
	STA	PE
	STA	PS		;else set p to 0
	RTS
EXPOK	JSR	INT		;find integer part
	CLC
	LDA	LSB
	ADC	#1+128		;add to check for overflow
	BEQ	EXPOVF		;error if result 127
	PHA			;else save
	LDA	#<ONE
	LDY	#>ONE
	JSR	APA		;p:=p+1
	LDA	#<LN2
	LDY	#>LN2
	JSR	MPA		;p:=p*ln(2)
	LDA	#<T0
	LDY	#>T0
	JSR	SPA		;p:=x-p
	JSR	NEG		;p:=-p
	LDA	#<EXPCHN
	LDY	#>EXPCHN
	JSR	SRSA		;do series
	LDA	#0
	STA	SGNCMP		;clear comparison
	PLA			;get integer part
	JSR	SUPMDX		;handle it
	RTS
;illegal exponent argument
EXPOVF	LDA	#TRUE
	STA	OVERFL		;set overflow to true
	RTS
;cos of primary accumulator
COS	LDA	#<PI2
	LDY	#>PI2
	JSR	APA		;add pi/2
;sin of primary accumulator
SIN	JSR	TPS		;move to secondary
	LDA	SS
	STA	SGNCMP		;set comparison to secondary sign
	LDA	#<TWOPI
	LDY	#>TWOPI
	JSR	LPA		;p:=2*pi
	JSR	DSP		;divide to get revolutions
	JSR	TPS		;s:=p
	JSR	INT		;get whole revs
	LDA	#0
	STA	SGNCMP		;clear sign comparison
	JSR	SPS		;p:=rev-int(rev)
	LDA	#<QUARTR
	LDY	#>QUARTR
	JSR	SPA		;p:=p-.25
	LDA	PS
	PHA			;save ps
	BPL	SINPPS		;branch if positive
	LDA	#<HALF
	LDY	#>HALF
	JSR	APA		;p:=p+.5
	LDA	PS
	BMI	SINSSM		;branch if still neg
	LDA	TRIGS
	EOR	#$FF
	STA	TRIGS		;complement trig sign
SINPPS	JSR	NEG		;p:=-p
SINSSM	LDA	#<QUARTR
	LDY	#>QUARTR
	JSR	APA		;p:=p+.25
	PLA			;get ps back
	BPL	*+5		;skip if pos
	JSR	NEG		;else negate
	LDA	#<SINCHN
	LDY	#>SINCHN
	JMP	SRSAS		;do squared series
;arctangent of primary accumulator
ATN	LDA	PS
	PHA			;save ps
	BPL	*+5		;ok if pos
	JSR	NEG		;else p:=-p
	LDA	PE
	PHA			;save pe
	CMP	#1+128		;if < 1
	BCC	ATNEL1		;then skip ahead
	LDA	#<ONE
	LDY	#>ONE
	JSR	DAP		;p:=1/p
ATNEL1	LDA	#<ATNCHN
	LDY	#>ATNCHN
	JSR	SRSAS		;do series
	PLA			;get exp
	CMP	#1+128		;if less than 1
	BCC	NOMPI2		;skip ahead
	LDA	#<PI2
	LDY	#>PI2
	JSR	SPA		;else p:=pi/2-p
NOMPI2	PLA			;get sign
	BPL	*+5		;done if pos
	JMP	NEG		;else p:=-p
	RTS
;pseudo machine opcode execution routine
EXECUT	LDY	#0
	LDA	(RC),Y
	BPL	L060		;if msb=0 then not lit or li-lod
	JSR	PSHSTK		;push$stack
	LDY	#1
	LDA	(RC),Y
	DEY
	STA	(RA),Y		;bra(0):=cv(1)
	LDA	(RC),Y
	AND	#$3F
	INY
	STA	(RA),Y		;bra(1):=c and $3f
	DEY
	LDA	(RC),Y
	ASL	A
	BPL	*+5		;if not rol(c,2) then
	JSR	LOADRA		;load$ra
	JSR	STINCN		;step$ins$cnt
	JSR	STINCN
	JMP	EXECUT		;do forever
L060	ASL	A
	TAX			;make an index
	LDA	EXTBL,X
	STA	DOOP+1
	LDA	EXTBL+1,X
	STA	DOOP+2		;set address
	JSR	DOOP		;do op
	JSR	STINCN		;step$ins$cnt
	JMP	EXECUT		;do forever
DOOP	JMP	$FFFF		;dummy
;execute vector table
EXTBL	.word	EX0,EX1,EX2,EX3,EX4,EX5,EX6,EX7
	.word	EX8,EX9,EX10,EX11,EX12,EX13,LOADRA,EX15
	.word	EX16,POPSTK,EX18,FLIP,EX20,EX21,EX22,EX23
	.word	EX24,EX25,EX26,EX27,EX28,CONCAT,EX30,EX31
	.word	CLCROW,CLCSUB,EX34,EX35,EX36,EX37,EX38,EX39
	.word	EX40,EX41,EX42,EX43,EX44,DSKOPN,EX46,EX47
	.word	EX48,EX49,EXNOP,EXNOP,DMPPBF,EX53,ABSBRA,EX55
	.word	CNDBRA,UNCBRA,CNVBRA,EX59,EX60,EX61,EX62,EX63
	.word	EX64,EX65,EX66,EX67,EX68,EX69,EX70,EX71
	.word	EX72,EX73,EX74,EX75,EX76,EX77,EX78,EX79
	.word	EX80,EX81,EX82,EX83,EX84,EX85,EX86,EX87
	.word	EX88,EX89,EX90,RNCBRA,EX92,EX93,EX94,EX95
	.word	EX96
; opcode execution routines
;do nothing
EXNOP	RTS
;0	fad:	rb:=ra+rb
EX0	JSR	FLODRA
	LDA	RB
	LDY	RB+1
	JSR	APA
	JSR	FSTRRB
	JSR	POPSTK
	JMP	CHKOVR
;1	fmi:	rb:=rb-ra
EX1	JSR	FLODRA
	LDA	RB
	LDY	RB+1
	JSR	SPA
	JSR	FSTRRB
	JSR	POPSTK
	JMP	CHKOVR
;2	fmu:	rb:=rb*ra
EX2	JSR	FLODRA
	LDA	RB
	LDY	RB+1
	JSR	MPA
	JSR	FSTRRB
	JSR	POPSTK
	JMP	CHKOVR
;3	fdi:	rb:=rb/ra
EX3	JSR	RAZER		;if not ra$zero
	BEQ	*+7		;then
	LDA	#4		;else div by zero warning
	JSR	WARNNG
EX3A	JSR	FLODRA
	LDA	RB
	LDY	RB+1
	JSR	DAP
	JSR	FSTRRB
	JSR	POPSTK
	JMP	CHKOVR
;4	exp:	rb:=rb**ra
EX4	JSR	RBZER		;if not rb$zero then
	BEQ	EX4B
	JSR	RAZER		;if not ra$zero then
	BEQ	EX4C
	LDY	#3
EX4A	LDA	ONE,Y
	STA	(RB),Y
	DEY
	BPL	EX4A		;else move4(.plusone,rb)
	BMI	EX4C		;done
EX4B	JSR	RBNEG		;if not rb$negative
	BEQ	*+7		;then ok
	LDA	#12		;else attempt to raise neg number to power
	JMP	ERROR
	JSR	FLODRB
	JSR	LOG
	LDA	RA
	LDY	RA+1
	JSR	MPA
	JSR	EXP
	JSR	FSTRRB
EX4C	JSR	POPSTK
	JMP	CHKOVR
;5  lss
EX5	JSR	COMPFP
	CMP	#1
	BEQ	EX5T
EX5F	LDA	#FALSE
	JMP	COMFIX
EX5T	LDA	#TRUE
	JMP	COMFIX
;6  gtr
EX6	JSR	COMPFP
	CMP	#2
	BEQ	EX5T
	BNE	EX5F
;7  equ
EX7	JSR	COMPFP
	CMP	#3
	BEQ	EX5T
	BNE	EX5F
;8  neq
EX8	JSR	COMPFP
	CMP	#3
	BNE	EX5T
	BEQ	EX5F
;9  geq
EX9	JSR	COMPFP
	CMP	#1
	BNE	EX5T
	BEQ	EX5F
;10 leq
EX10	JSR	COMPFP
	CMP	#2
	BNE	EX5T
	BEQ	EX5F
;11 not
EX11	JSR	CNVBRA		;conv$to$binary(ra)
	LDY	#3
EX11A	LDA	(RA),Y
	EOR	#$FF
	STA	(RA),Y
	DEY
	BNE	EX11A		;(ra):=not (ra)
	JMP	CNVFRA		;conv$to$floating(ra)
;12 and
EX12	JSR	CNVBRA		;conv$to$binary(ra)
	JSR	CNVBRB		;rb
	LDY	#3
EX12A	LDA	(RA),Y
	AND	(RB),Y
	STA	(RB),Y
	DEY
	BNE	EX12A		;(rb):=(rb) and (ra)
	JSR	POPSTK		;pop$stack
	JMP	CNVFRA		;conv$to$floating(ra)
;13 or
EX13	JSR	CNVBRA
	JSR	CNVBRB
	ldy	#3		;set index
EX13A	LDA	(RA),Y
	ORA	(RB),Y
	STA	(RB),Y
	DEY
	BNE	EX13A		;(rb):=(rb) or (ra)
	JSR	POPSTK
	JMP	CNVFRA
;15 sto
EX15	LDA	#0
	JSR	STORE		;store(0)
	JSR	MVRARB		;move$ra$rb
	JMP	POPSTK		;pop$stack
;16 xit
EX16	PLA
	PLA			;clear stack
	RTS			;and return to outer loop
;18 dup
EX18	JSR	PSHSTK
	JMP	MVRBRA
;20 std
EX20	LDA	#0
	JSR	STORE
	JSR	POPSTK
	JMP	POPSTK
;21 slt
EX21	JSR	CMPSTR
	CMP	#1
	BEQ	EX21T
EX21F	LDA	#FALSE
	JMP	COMFIX
EX21T	LDA	#TRUE
	JMP	COMFIX
;22 sgt
EX22	JSR	CMPSTR
	CMP	#2
	BEQ	EX21T
	BNE	EX21F
;23 seq
EX23	JSR	CMPSTR
	CMP	#3
	BEQ	EX21T
	BNE	EX21F
;24 sne
EX24	JSR	CMPSTR
	CMP	#3
	BNE	EX21T
	BEQ	EX21F
;25 sge
EX25	JSR	CMPSTR
	CMP	#1
	BNE	EX21T
	BEQ	EX21F
;26 sle
EX26	JSR	CMPSTR
	CMP	#2
	BNE	EX21T
	BEQ	EX21F
;27 sts
EX27	LDA	#1
	JSR	STORE
	JSR	POPSTK
	JMP	POPSTK
;28 ils
EX28	JSR	PSHSTK
	JSR	STINCN
	LDY	#0
	LDA	RC
	STA	(RA),Y
	INY
	LDA	RC+1
	STA	(RA),Y		;ara:=rc
	DEY
	LDA	(RC),Y		;a:=c
	CLC
	ADC	RC
	STA	RC
	BCC	*+4
	INC	RC+1		;rc:=rc+c
	LDA	#FALSE
	JMP	FLSTRA		;flag$string$address(false)
;30 pro
EX30	JSR	STINCN
	JSR	PSHSTK
	CLC
	LDA	RC
	LDY	RC+1
	ADC	#2
	PHA
	BCC	*+3
	INY
	TYA
	LDY	#1
	STA	(RA),Y
	PLA
	DEY
	STA	(RA),Y		;ara:=rc+1+1
	LDA	(RC),Y
	TAX
	INY
	LDA	(RC),Y
	STA	RC+1
	STX	RC		;rc:=twobyteoprand
	RTS
;31 rtn
EX31	JSR	ARA
	SEC
	SBC	#1
	BCS	*+3
	DEY
	STA	RC
	STY	RC+1
	JMP	POPSTK
;34 rdv	reads a number from console
EX34	JSR	MRECIN
	BNE	*+5
	JSR	CONIER
	JMP	GTNMFL		;get$numeric$field
;35 wrv	prints the number on the top of the stack
EX35	JSR	NUMOUT		;numeric$out
	JSR	WRTTCN		;write$to$console
	JMP	POPSTK
;36 wst prints the string whose address is on top of stack
EX36	JSR	WRTTCN		;write$to$console
	JSR	STRFRE		;string$free
	JMP	POPSTK
;37 rdf ready a random block
EX37	JSR	SUDSIO		;setup$disk$io
	JSR	RANSTU		;random$setup
	JMP	STEFST		;set$eof$stack
;38 rdb ready next sequential block
EX38	JSR	SUDSIO
	JMP	STEFST
;39 ecr
EX39	JSR	MRECIN		;if not more$con$input
	BEQ	EX39A		;then
	JSR	PSHSTK
	JMP	CONIER		;console$input$error
EX39A	RTS
;40 out	actually poke
EX40	JSR	ARA
	STA	POKE+1
	STY	POKE+2		;location is ara
	LDY	#0
	LDA	(RB),Y		;a:=braz
POKE	STA	$FFFF
	JSR	POPSTK
	JMP	POPSTK
;41 rdn	read a number from disk
EX41	LDA	#0
	STA	INPTYP
	JMP	GTNMFL		;get$numeric$field
;42 rds read a string from disk
EX42	LDA	#0
	STA	INPTYP
	JMP	GTSTFL		;get$string$field
;43 wrn write a number to disk
EX43	LDA	#0
	JMP	WRTOFL		;write$to$file(0)
;44 wrs write a string to disk
EX44	LDA	#1
	JMP	WRTOFL		;write$to$file(1)
;46 con
EX46	JSR	PSHSTK
	JSR	STINCN		;step$ins$cnt
	LDY	#0
	LDA	(RC),Y
	STA	MFROM
	INY
	LDA	(RC),Y
	STA	MFROM+1
	LDA	RA
	LDY	RA+1
	STA	MTO
	STY	MTO+1
	JSR	MOVE4
	JMP	STINCN
;47 rst reset pointer to beginning of data area
EX47	LDY	MDA+1
	LDX	MDA
	BNE	*+3
	DEY
	DEX
	STX	DTARPT
	STY	DTARPT+1	;data$area$ptr:=mda-1
	RTS
;48 neg
EX48	JSR	FLODRA		;prim:=(ra)
	JSR	NEG		;prim:=-prim
	JSR	FSTRRA		;(ra):=prim
	JMP	CHKOVR		;check$overflow
;49 res read string
EX49	JSR	MRECIN		;if more$con$input
	BNE	*+5		;then
	JSR	CONIER		;else console$input$error
	JMP	GTSTFL		;get$string$field
;53 nsp
ex53	lda	prbuff		;get current position
	cmp	#112		;if under 112 then ok
	bcc	*+5
	jmp	dmppbf		;else do a cr and lf
ex53a	lda	#' '		;send a space
	jsr	prnchr
	inc	prbuff		;and bump index
	sec
	lda	prbuff		;get index
ex53b	sbc	#14		;subtract 14
	bcc	ex53a		;if borrow then not there
	bne	ex53b		;if not zero may be more
	rts			;else done
;55 brc
EX55	JSR	RAZER		;if ra$zero
	BNE	EX55A		;then
	CLC
	LDA	RC
	ADC	#2
	STA	RC
	BCC	*+4
	INC	RC+1		;else rc:=rc+2
	JMP	POPSTK
EX55A	JSR	ABSBRA		;absolute$branch
	JMP	POPSTK
;59 rch
EX59	LDA	#1
	STA	INPTYP		;inputtype:=1
	LDA	RC
	LDY	RC+1
	STA	RERDAD
	STY	RERDAD+1	;rereadaddr:=rc
	JMP	CONRDE		;console$read
;60 drs read string from data area
EX60	LDA	#2
	STA	INPTYP		;inputtype:=2
	JMP	GTSTFL		;get$string$field
;61 drf read floating point number from data area
EX61	LDA	#2
	STA	INPTYP
	JMP	GTNMFL		;get$numeric$field
;62 edr end of record for read
EX62	JSR	VARBSZ
	BEQ	EX62B		;if not var$block$size then
EX62A	JSR	GTDSCH		;else
	CMP	#LF
	BNE	EX62A		;do while get$disk$char <> lf
EX62B	JMP	STRRPT		;store$rec$ptr
;63 edw end of record for write
EX63BS				;blocksize-2
	*=	*+2
EX63	JSR	VARBSZ
	BEQ	EX63B		;if not var$block$size then
	SEC
	LDA	BLKSZE
	LDY	BLKSZE+1
	SBC	#2
	STA	EX63BS
	BCS	*+3
	DEY
	STY	EX63BS+1	;calculate blocksize-2
EX63A	LDA	BYTSWR
	CMP	EX63BS
	LDA	BYTSWR+1
	SBC	EX63BS+1
	BCS	EX63B		;if bytes$written >= blocksize-2 then
	LDA	#' '		;else
	JSR	WRABYT		;write$a$byte(blank)
	JMP	EX63A
EX63B	LDA	#CR
	JSR	WRABYT
	LDA	#LF
	JSR	WRABYT
	JMP	STRRPT		;store$rec$ptr
;64 cls close a file
EX64	JSR	STFLAD		;set$file$addr
	JSR	DSKCLS		;disk$close
	LDY	#0
	LDA	(RA),Y
	ASL	A
	TAX			;x:=2*braz
	TYA
	STA	FILES,X
	STA	FILES+1,X
	STA	EOFBRN,X
	STA	EOFBRN+1,X	;files(braz),eofbranch(braz):=0
	JMP	POPSTK
;65 absolute
EX65	LDY	#1
	LDA	(RA),Y
	AND	#$7F
	STA	(RA),Y		;bra(1):=bra(1) and $7f
	RTS
;66 integer
EX66	JSR	FLODRA		;prim:=(ra)
	JSR	INT
	JSR	FSTRRA		;(ra):=int(prim)
	JMP	CHKOVR		;check$overflow
;67 random number generator
EX67	JSR	RND		;calculate number
	JSR	PSHSTK		;make room for number
	JMP	FSTRRA		;put on stack
;68 sgn
EX68	JSR	RANEG
	PHA
	JSR	RAZER
	EOR	#$FF
	JSR	COMFIX		;comp$fix(not ra$zero)
	PLA
	BNE	*+5		;if ra$negative then
	JMP	EX48		;else change sign
	RTS
;69 sin
EX69	JSR	FLODRA
	JSR	SIN
	JSR	FSTRRA
	JMP	CHKOVR
;70 cos
EX70	JSR	FLODRA
	JSR	COS
	JSR	FSTRRA
	JMP	CHKOVR
;71 atn
EX71	JSR	FLODRA
	JSR	ATN
	JSR	FSTRRA
	JMP	CHKOVR
;72 tan
EX72	JSR	PSHSTK		;extend stack
	JSR	MVRBRA		;duplicate param
	JSR	EX69		;calculate sin
	JSR	POPSTK
	JSR	EX70		;now do cos
	JSR	PSHSTK		;sin still there
	JSR	RBZER
	BEQ	*+7		;if cos not zero then
	LDA	#22		;else tan(pi/2) error
	JMP	ERROR
	JSR	FLIP
	JMP	EX3A		;divide
;73 sgr
EX73	JSR	FLODRA
	BIT	PS
	BPL	*+7		;ok if positive
	LDA	#12		;else negative number to power error
	JMP	ERROR
	JSR	LOG
	LDA	#<HALF
	LDY	#>HALF
	JSR	MPA		;1/2 * log()
	JSR	EXP		;exp()
	JSR	FSTRRA
	JMP	CHKOVR
;74 tab
EX74	JSR	CNVBAD		;conv$to$bin$addr
	LDY	#0
	lda	(ra),y		;get low
	cmp	#133		;see if too big
	bcs	ex74e		;error if is
	iny
	lda	(ra),y		;if anything in high
	bne	ex74e		;is error
	DEY
	sec
	LDA	(RA),Y
	beq	ex74z		;special case if zero
	SBC	#1
	STA	(RA),Y		;ara:=ara-1  (low only)
	LDA	PRBUFF
	CMP	(RA),Y
	BCC	EX74D		;if ara > printbuffer then
	beq	ex74x		;but if same done
	JSR	DMPPBF		;dump$print$buffer
	ldy	#0		;get dest again
	lda	(ra),y
	beq	ex74x		;done if zero
ex74d	lda	#' '		;send a blank
	jsr	prnchr		;to console
	inc	prbuff		;and bump index
	ldy	#0
	lda	(ra),y		;get end position back
	cmp	prbuff		;see if there
	bne	ex74d		;loop if not
ex74x	JMP	POPSTK
ex74z	sta	prbuff		;clear pointer
	lda	#cr		;then send carriage return
	jsr	prnchr
	jmp	popstk		;and pop stack pointer
ex74e	lda	#27		;illegal argument
	jmp	error
;75 exp
EX75	JSR	FLODRA
	JSR	EXP
	JSR	FSTRRA
	JMP	CHKOVR
;76 free area in fsa
EX76	JSR	PSHSTK
	LDA	#0
	TAY
	JSR	AVLL		;available(0)
	JMP	FLTADR		;float$addr()
;77 irn randomize
EX77	LDA	LCLSED
	LDY	LCLSED
	STA	RNDWRK+1
	STY	RNDWRK+2
	JMP	RND
;78 log
EX78	JSR	FLODRA
	JSR	LOG
	JSR	FSTRRA
	JMP	CHKOVR
;79 position of print buffer ptr
EX79	JSR	PSHSTK
	LDA	PRBUFF
	CLC
	ADC	#1
	LDY	#0
	JMP	FLTADR		;float$addr(printbuffer-printbufferloc+1)
;80 inp [actually peek]
EX80	JSR	RNCBRA
	JSR	ARA
	STA	PEEK+1
	STY	PEEK+2
PEEK	LDA	$FFFF
	LDY	#0
	JMP	FLTADR
;81 ascii conversion
EX81	JSR	ARA
	STA	EXH
	STY	EXH+1		;hold:=ara
	ORA	EXH+1		;if = 0
	BEQ	EX81A		;then error
	LDY	#0
	LDA	(EXH),Y
	BNE	*+7		;if h(0) <> 0 then ok
EX81A	LDA	#0		;else null string error
	JMP	ERROR
	LDY	#1
	LDA	(EXH),Y		;a:=h(1)
	PHA
	JSR	STRFRE		;string$free
	PLA
	LDY	#0
	JMP	FLTADR		;float$addr(temp)
;82 chr converts to ascii
EX82	JSR	CNVBAD		;conv$to$bin$addr
	LDA	#2
	LDY	#0
	JSR	GETS		;getspace(2)
	STA	EXH
	STY	EXH+1		;hold:=
	LDY	#0
	LDA	#1
	STA	(EXH),Y		;loc(0):=1
	LDA	(RA),Y
	INY
	STA	(EXH),Y		;loc(1):=bra(0)
	LDA	EXH+1
	STA	(RA),Y
	DEY
	LDA	EXH
	STA	(RA),Y		;ara:=hold
	LDA	#TRUE
	JMP	FLSTRA		;flag$string$addr(true)
;83 left end of string
EX83	LDA	#0
	JMP	STRSEG		;string$segment(0)
;84 length of string
EX84	JSR	ARA
	JSR	GETSLN		;get$string$len(ara)
	PHA
	JSR	STRFRE
	PLA
	LDY	#0
	JMP	FLTADR		;float$addr(length)
;85 middle of string
EX85	LDA	#2
	JMP	STRSEG		;string$segment(2)
;86 right end of string
EX86	LDA	#1
	JMP	STRSEG		;string$segment(1)
;87 conversion to string
EX87	JSR	NUMOUT
	CLC
	LDA	NUOWRK
	ADC	#1
	PHA
	LDY	#0
	JSR	GETS		;get$space()
	STA	MTO
	STY	MTO+1
	LDY	#0
	STA	(RA),Y
	INY
	LDA	MTO+1
	STA	(RA),Y		;ara:=
	LDA	#<NUOWRK
	LDY	#>NUOWRK
	STA	MFROM
	STY	MFROM+1
	PLA
	LDY	#0
	JSR	MOVE		;move(from,to,ay)
	LDA	#TRUE
	JMP	FLSTRA		;flag$string$addr(true)
;88 value
EX88	JSR	ARA
	JSR	GETSLN		;get$string$len(ara)
	TAX
	JSR	ARA
	CLC
	ADC	#1
	BCC	*+3
	INY
	JSR	FLTINP
	JSR	STRFRE		;string$free
	JMP	FSTRRA		;(ra):=prim
;89 call
EX89	JSR	CNVBAD		;convert to address
	JSR	ARA
	STA	CALL+1
	STY	CALL+2
CALL	JSR	$FFFF		;do call
	JMP	FLTADR		;float and return
;90 sinh
EX90	JSR	FLODRA
	LDA	PE		;test for zero
	BNE	*+3		;continue if not
	RTS			;else done
	LDA	#<T2
	LDY	#>T2
	JSR	STP		;save in t2
	JSR	EXP
	LDA	#<T3
	LDY	#>T3
	JSR	STP		;save exp(x) in t3
	LDA	#<T2
	LDY	#>T2
	JSR	LPA		;get x back
	JSR	NEG		;-x
	JSR	EXP		;log(-x)
	JSR	NEG		;-log(-x)
	LDA	#<T3
	LDY	#>T3
	JSR	APA		;log(x)-log(-x)
	LDA	#<HALF
	LDY	#>HALF
	JSR	MPA		;sinh(x)
	JSR	FSTRRA		;store at ra
	JMP	CHKOVR		;checkoverflow
;92 cko
;ra contains max number labels in the on statement
;rb contains selected label
;checks to insure that slected label exists. if not an error is noted
EX92T
	*=	*+1
EX92	LDY	#0
	LDA	(RB),Y
	SEC
	SBC	#1
	STA	(RB),Y		;brbz:=brbz-1
	STA	EX92T		;save for comparison
	SEC
	LDA	(RA),Y
	SBC	#1		;braz-1
	CMP	EX92T
	BCS	*+7		;if braz-1 >= brbz then ok
	LDA	#16		;else index in on statement out of bounds
	JMP	ERROR
	JSR	POPSTK		;pop$stack
	LDY	#0
	LDA	(RA),Y
	CLC
	ADC	#1
	STA	EX92T		;save
	LDA	(RA),Y
	ASL	A
	CLC
	ADC	EX92T
	STA	(RA),Y		;braz:=
	RTS
;93 exr
EX93	JSR	CNVBRA
	JSR	CNVBRB
	LDY	#3
EX93A	LDA	(RA),Y
	EOR	(RB),Y
	STA	(RB),Y
	DEY
	BPL	EX93A
	JSR	POPSTK		;pop$stack
	JMP	CNVFRA
;94 def
EX94	JSR	STINCN		;step$ins$cnt
	JSR	GTFLNU		;get$file$number
	ASL	A
	TAX
	JSR	ARC		;twobyteoprand
	STA	EOFBRN,X
	TYA
	STA	EOFBRN+1,X	;eofbranch():=
	JSR	STINCN		;step$ins$cnt
	JMP	POPSTK		;pop$stack
;95 bol
EX95	JSR	ARA
	STA	CURLIN
	STY	CURLIN+1	;currentline:=ara
	JMP	POPSTK		;pop$stack
;96 adj
EX96	JSR	ARA
	CLC
	ADC	MCD
	PHA
	TYA
	ADC	MCD+1		;ara+mcd
	LDY	#1
	STA	(RA),Y
	DEY
	PLA
	STA	(RA),Y		;ara:=
	RTS
;MAIN PROGRAM
MAIN	JSR	CRLF
	JSR	INTLEX		;initialize$execute
EOFEXT
ERREXT	LDX	#$FF
	TXS			;reset stack
	JSR	EXECUT		;execute
	JMP	EXTINT		;exit interpreter
;messages
ERRMSG	.byte	"ERROR - $"
WRNMSG	.byte	"WARNING - $"
INLMSG	.byte	" IN LINE $"
;error messages
ERM0	.byte	"NULL STRING PASSED AS "
	.byte	"PARAMETER TO ASC FUNCTION$"
ERM1	.byte	"ERROR WHILE CLOSING A FILE$"
ERM2	.byte	"DISK READ ERROR - UNWRITTEN"
	.byte	" DATA IN RANDOM ACCESS$"
ERM3	.byte	"DISK WRITE ERROR$"
ERM4	.byte	"DIVISION BY ZERO$"
ERM5	.byte	"EOF FOR DISK FILE AND"
	.byte	" NO ACTION SPECIFIED$"
ERM6	.byte	"RECORD SIZE EXCEEDED "
	.byte	"FOR BLOCKED FILE$"
ERM7	.byte	"INVALID INPUT FROM CONSOLE$"
ERM8	.byte	"INVALID RECORD IN RANDOM "
	.byte	"ACCESS$"
ERM9	.byte	"ACCESSING AN UNOPENED FILE$"
ERM10	.byte	"ERROR WHILE CREATING FILE$"
ERM11	.byte	"FILE IDENTIFIER TOO LARGE "
	.byte	"OR ZERO$"
ERM12	.byte	"ATTEMPT TO RAISE A NEGATIVE "
	.byte	"NUMBER TO A POWER$"
ERM13	.byte	"NO INT FILE FOUND IN "
	.byte	"DIRECTORY$"
ERM14	.byte	"ATTEMPT TO READ PAST END "
	.byte	"OF DATA AREA$"
ERM15	.byte	"ERROR WHILE OPENING A FILE$"
ERM16	.byte	"INDEX IN ON STATEMENT OUT "
	.byte	"OF BOUNDS$"
ERM17	.byte	"ATTEMPT TO READ PAST END OF"
	.byte	" RECORD ON BLOCKED FILE$"
ERM18	.byte	"UNBLOCKED FILE USED WITH "
	.byte	"RANDOM ACCESS$"
ERM19	.byte	"ARRAY SUBSCRIPT OUT OF "
	.byte	"BOUNDS$"
ERM20	.byte	"STRING LENGTH EXCEEDS 255$"
ERM21	.byte	"SECOND PARAMETER OF MID IS "
	.byte	"NEGATIVE$"
ERM22	.byte	"ATTEMPT TO EVALUATE TANGENT "
	.byte	"OF PI OVER TWO$"
ERM23	.byte	"OUT OF MEMORY$"
ERM24	.byte	"ATTEMPT TO WRITE A QUOTE "
	.byte	"TO DISK$"
ERM25	.byte	"DISK DATA FIELD TOO LONG "
	.byte	"DURING READ$"
ERM26	.byte	"OVERFLOW IN ARITHMETIC "
	.byte	"OPERATION$"
ERM27	.byte	"ILLEGAL TAB ARGUMENT$"
ERM28	.byte	"ILLEGAL CHARACTER IN "
	.byte	"FILE NAME$"
;error table
ERMTBL	.word	ERM0,ERM1,ERM2,ERM3,ERM4,ERM5,ERM6,ERM7
	.word	ERM8,ERM9,ERM10,ERM11,ERM12,ERM13,ERM14,ERM15
	.word	ERM16,ERM17,ERM18,ERM19,ERM20,ERM21,ERM22,ERM23
	.word	ERM24,ERM25,ERM26,ERM27,ERM28
;string accumulator
ACCUM
	*=	*+32
;input buffer
INPBUF	.byte	80
INPSPC
	*=	*+81
;numeric out work area
NUOWRK	.byte	0
;print work area
PRNWRK
	*=	*+14
;temp number storage locations
T0
	*=	*+4
T1
	*=	*+4
T2
	*=	*+4
T3
	*=	*+4
;fcb pointer arrays
FILES			;files(numfiles)
	*=	NUMFIL*2+*
EOFBRN			;eofbranch(numfiles)
	*=	NUMFIL*2+*
MEMORY
;BUILD
;The build routine gains control at initial execution of RUN.COM.  It
;initializes page zero storage and then opens the .int file and builds
;the BASIC-E/65 machine in the following order.
;	(1)	Numeric constants are read from the .int file, converted to
;		internal representation (i.e. four byte floating point) and
;		stored in the fsa.
;	(2)	The size of the code area, data area, and number of prt entries
;		are read from the .int file.  BUILD then determines the
;		absolute address of each section of the BASIC-E/65 machine.
;		These addresses are passed to the main interpreter via fixed
;		page zero locations.
;	(3)	Finally instructions are read from the file and placed in
;		either the data area or the code area.  In the case of BRS,
;		BRC, PRO, CON, and DEF operators the address following the
;		instruction is relocated to reflect actual machine addresses
;		(minus 1 because program counter gets incremented prior to use
;		(except for CON) !!) after (reapeat after) the machine has been
;		repositioned by the main interpreter.  The end of the .int file
;		is indicated by a machine instruction of $7F.
;open$int$file
OPNINT	LDA	#'I'		;set extension to INT
	STA	DFLFCB+9
	LDA	#'N'
	STA	DFLFCB+10
	LDA	#'T'
	STA	DFLFCB+11
	LDA	#<DFLFCB
	LDY	#>DFLFCB
	LDX	#15
	JSR	PEM		;try to open
	BMI	*+3		;if error
	RTS
	LDA	#13		;no int file error
	JMP	ERROR
;read$int$file
;next record is read from int file
;returns 0 if ok or a 1 if eof
RDEINT	LDA	#<DFLFCB
	LDY	#>DFLFCB
	LDX	#20
	JMP	PEM
;
INCBUF	INC	BUFF		;bump index
	BPL	BE1		;done of < 128
	LDA	#0
	STA	BUFF		;else clear index
	JSR	RDEINT		;read record
	BEQ	BE1		;done if ok
	LDA	#$7F
	STA	BUF		;else char:=$7F
BE1	RTS
;sto$char$inc
;get next char from int file and place in code area then increment ptr into
;code area
STOINC	LDY	BUFF
	LDA	BUF,Y
	LDY	#0
	STA	(BASE),Y	;b:=char
	INC	BASE
	BNE	*+4
	INC	BASE+1		;base:=base+1
	RTS
;next$char
NXTCHR	JSR	INCBUF
	LDY	BUFF
	LDA	BUF,Y
	STA	CURCHR		;curchr:=char
	RTS
;get$two$bytes
;get next two bytes from the int file and place in the code area in reverse
;order
GETTWO	JSR	NXTCHR
	LDY	#1
	STA	(BASE),Y	;bv(1)=next$char
	JSR	NXTCHR
	LDY	#0
	STA	(BASE),Y	;bv(0)=next$char
	RTS
;inc$base$two
INCB2	CLC
	LDA	BASE
	ADC	#2
	STA	BASE
	BCC	*+4
	INC	BASE+1		;base:=base+1+1
	RTS
;getparm
;read a 16 bit parameter from int file and convert it to a 6502 address
;quantity
GETPRM	JSR	NXTCHR		;high
	PHA			;save
	JSR	NXTCHR		;low
	TAX			;save in x as temp
	PLA
	TAY			;get high
	TXA			;and low
	RTS
;main build routine
BUILD
;clear all of page zero
	LDX	#2
	LDA	#0
CLRZP	STA	0,X
	inx			;bump index
	cpx	#lz		;see if at end
	BNE	CLRZP
	LDA	#127
	STA	BUFF		;set buff to illegal
	ldx	#25
	jsr	pem		;read default drive
	sta	dfldrv		;and save
	LDA	#<OPNMSG
	LDY	#>OPNMSG
	JSR	PRINT		;print opening
	JSR	CRLF
	JSR	OPNINT		;open int file
	LDX	#>BMEM
	INX
	STX	BASE+1		;base:=(.memory+$100) and $ff00
	SEC
	LDA	BASE
	SBC	#<MEMORY
	STA	OFFSET
	LDA	BASE+1
	SBC	#>MEMORY
	STA	OFFSET+1	;offset:=base-.memory
;initialize floating point package - page zero clear did it
;process constants - each constant is terminated by an  $ and the last is
;followed by a *
BLDCON	JSR	NXTCHR
	STA	ACCUM		;accum(0):=next$char
	CMP	#'*'
	BEQ	ENDCON		;done if *
	LDA	#0
	STA	AP		;ap:=0
;do one constant
BLD1C	INC	AP		;ap:=ap+1
	JSR	NXTCHR
	LDY	AP
	STA	ACCUM,Y		;accum(ap:=ap+1):=next$char
	CMP	#'$'
	BNE	BLD1C		;do while <> $
	LDA	#<ACCUM		;(actually moves data from accum to accum)
	LDY	#>ACCUM
	LDX	AP
	JSR	FLTINP		;convert to floating
	LDA	BASE
	LDY	BASE+1
	JSR	STP		;store at (base)
	CLC
	LDA	BASE
	ADC	#4
	STA	BASE
	BCC	BLDCON
	INC	BASE+1		;base:=base+4
	JMP	BLDCON
;setup machine address
;base will now be next position in code area
;mbase will be next position in data area
ENDCON	JSR	GETPRM
	CLC
	ADC	BASE
	STA	MBASE
	TYA
	ADC	BASE+1
	STA	MBASE+1		;mbase:=getparm+base
;actual data area addr
	SEC
	LDA	MBASE
	SBC	OFFSET
	STA	MDA
	LDA	MBASE+1
	SBC	OFFSET+1
	STA	MDA+1		;mda:=mbase-offset
;actual code area addr
	SEC
	LDA	BASE
	SBC	OFFSET
	STA	MCD
	LDA	BASE+1
	SBC	OFFSET+1
	STA	MCD+1		;mcd:=base-offset
;actual beginning of prt
	JSR	GETPRM
	CLC
	ADC	MDA
	STA	MPR
	TYA
	ADC	MDA+1
	STA	MPR+1		;mpr:=getparm+mda
;ensure there is enough memory
	LDA	MPR
	CMP	PEM+1
	LDA	MPR+1
	SBC	PEM+2
	BCC	*+7		;ok if mpr<max
	LDA	#23
	JMP	ERROR		;out of memory error
	JSR	GETPRM
	STA	SB
	STY	SB+1
	ASL	SB
	ROL	SB+1
	ASL	SB
	ROL	SB+1		;shl(getparm,2)
	CLC
	LDA	SB
	ADC	MPR
	STA	SB
	LDA	SB+1
	ADC	MPR+1
	STA	SB+1		;sb:=shl(getparm,2)+mpr
;build machine at last
;as opcodes are read they may be:
;	(1)	dat-which means all characters following dat go into data area
;		until a binary zero is encountered
;	(2)	greater than 127 - which is a lit or lid.  Treat this as a 16
;		opcode an put in code area in order they are in int file
;	(3)	irs - which means all characters following go into code area
;		until a binary zero is encountered - but first put an ils in
;		code area and the next byte is set to zero and incremented
;		for each charcetr in the string.  THus a string constant is an
;		ils opcode, a length, and a string
;	(4)	a normal opcode - put in code area - but if it is a brs, brc,
;		def, or pro then the next two bytes are an address which must
;		be relocated to the actual code area minus 1 - it could also
;		be a con which is relocated to the fda.
BLDMCH	JSR	NXTCHR
	CMP	#$7F
	BNE	*+5		;do while next$char <> $7F
	JMP	MAIN		;else go to main
;see if dat
	CMP	#DAT		;if curchar <> dat
	BNE	NOTDAT		;then
BLDDAT	JSR	NXTCHR
	LDY	#0
	STA	(MBASE),Y	;mf:=next$char
	CMP	#0		;do while () <> 0
	BEQ	BLDMCH		;start over if is 0
	INC	MBASE
	BNE	BLDDAT
	INC	MBASE+1		;mbase:=mbase+1
	JMP	BLDDAT
;see if lit or lid
NOTDAT	CMP	#128		;if curchar < 128
	BCC	NOTLIT		;then
	JSR	STOINC		;else sto$char$inc
	JSR	INCBUF
	JSR	STOINC
	JMP	BLDMCH		;and loop
;see if ils
NOTLIT	CMP	#ILS
	BNE	NOTILS
	JSR	STOINC		;sto$char$inc
	LDA	BASE
	LDY	BASE+1
	STA	TBASE
	STY	TBASE+1		;temp:=base
	LDY	BUFF
	LDA	#0
	STA	BUF,Y		;char:=0
	JSR	STOINC		;sto$char$inc
BLDILS	JSR	NXTCHR		;do while next$char <> 0
	BEQ	BLDMCH
	JSR	STOINC		;sto$char$inc
	LDY	#0
	LDA	(TBASE),Y	;t:=t+1
	CLC
	ADC	#1
	STA	(TBASE),Y
	JMP	BLDILS		;loop for more
;is an opcode
NOTILS	JSR	STOINC		;sto$char$inc
	LDA	CURCHR
	CMP	#BRS
	BEQ	DOADDR
	CMP	#BRC
	BEQ	DOADDR
	CMP	#DEF
	BEQ	DOADDR
	CMP	#PRO
	BNE	TRYCON		;if brs or brc or def or pro then else
DOADDR	JSR	GETTWO
	LDY	#0
	LDA	(BASE),Y	;low
	TAX
	INY
	LDA	(BASE),Y
	TAY
	TXA
	CLC			;add mcd
	ADC	MCD
	TAX
	TYA
	ADC	MCD+1
	TAY
	TXA			;test low
	BNE	*+3
	DEY
	DEX			;drop by one
	TYA			;high to a
	LDY	#1
	STA	(BASE),Y
	DEY
	TXA
	STA	(BASE),Y	;set
	JSR	INCB2		;inc$base$two
	JMP	BLDMCH
;may be con
TRYCON	CMP	#CON
	BEQ	*+5		;continue if is
	JMP	BLDMCH		;else get next
	JSR	GETTWO		;get$two$bytes
	LDY	#0
	LDA	(BASE),Y
	ASL	A		;low * 2
	TAX
	INY
	LDA	(BASE),Y
	ROL	A
	TAY
	TXA
	ASL	A
	TAX
	TYA
	ROL	A
	TAY
	CLC
	TXA
	ADC	#<MEMORY	;add offset
	TAX
	TYA
	ADC	#>MEMORY
	LDY	#1
	STA	(BASE),Y
	DEY
	TXA
	STA	(BASE),Y
	JSR	INCB2		;inc$base$two
	JMP	BLDMCH		;and loop
;build messages
OPNMSG	.byte	"BASIC-E/65 INTERPRETER"
	.byte	" - VERSION 2.05-A$"
;build memory
BMEM
	.END
