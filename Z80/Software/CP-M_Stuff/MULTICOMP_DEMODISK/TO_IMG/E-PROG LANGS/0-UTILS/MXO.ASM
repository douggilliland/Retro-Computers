YES:		EQU	0FFH
NO:		EQU	0
;
SMMODEM		EQU	NO		;YES for smartmodem
;
IO8250		EQU	YES
;
;
	 IF IO8250
;
;The following equates are for the H88-3 card.  You need only set the 
;DPORT and DEFLCR equates to match your configuration
;
DPORT:		EQU	068H		;data port for H89 <------------------
SPORT:		EQU	DPORT+5		;status port for H89
LCPORT		EQU	DPORT+3		;line control port
INTPORT		EQU	DPORT+1		;interrupt port
MCPORT		EQU	DPORT+4		;modem control port
SPDPORT0	EQU	DPORT		;first baud rate control port
SPDPORT1	EQU	DPORT+1		;second baud rate port
BRPORT		EQU	DPORT+3		;port to set the BREAK
;
MDRCVB:		EQU	1		;bit to test for received data
MDRCVR:		EQU	1		;modem receive ready
MDSNDB:		EQU	20H		;bit to test for ready to send
MDSNDR:		EQU	20H		;modem send ready bit
;
SDB8		EQU	00000011B	;set data bits to 8
SDB7		EQU	00000010B	;... and 7
SDB6		EQU	00000001B	;... and 6
SDB5		EQU 	0		;... and 5
RDB		EQU	11111100B	;reset data bits
DATBITM		EQU	00000011B	;data bit mask
;
SPOFF		EQU	0		;set parity to off
SPODD		EQU	00001000B	;set parity to odd
SPEVEN		EQU 	00011000B	;set parity to even
RPOFF  		EQU	11100111B	;reset parity bits (to off)
PARITYM		EQU	00011000B	;parity mask
;
SSB1		EQU	0		;set stop bits to 1
SSB15		EQU	00000100B	;... and 1.5
SSB2		EQU	00000100B	;... and 2
RSB		EQU	11111011B	;reset stop bits
STPBITM		EQU	00000100B	;stop bit mask
;
DEFLCR		EQU	SDB8+SPOFF+SSB1 ;default values for the line cont. reg
;
SDLAB		EQU	10000000B	;set divisor latch access bit
;
SBR   		EQU	01000000B	;set break
RBR   		EQU	10111111B	;reset break
;
SRTSDTR		EQU	00000011B	;set DTR & RTS true (on)
RRTSDTR		EQU	11111100B	;reset DTR & RTS
;
	 ENDIF		;IO8250
;
	 IF NOT IO8250
;
;
	 ENDIF		;NOT IO8250
;
;
;MEX service processor stuff
;
MEX		EQU	0D00H		;address of the service processor
INMDM		EQU	255		;get char from port to A, CY=no more in 100 ms
TIMER		EQU	254		;delay 100ms * reg B
TMDINP		EQU	253		;B=# secs to wait for char, cy=no char
CHEKCC		EQU	252		;check for ^C from KBD, Z=present
SNDRDY		EQU	251		;test for modem-send ready
RCVRDY		EQU	250		;test for modem-receive ready
SNDCHR		EQU	249		;send a character to the modem (after sndrdy)
RCVCHR		EQU	248		;recv a char from modem (after rcvrdy)
LOOKUP		EQU	247		;table search: see CMDTBL comments for info
PARSFN		EQU	246		;parse filename from input stream
BDPARS		EQU	245		;parse baud-rate from input stream
SBLANK		EQU	244		;scan input stream to next non-blank
EVALA		EQU	243		;evaluate numeric from input stream
LKAHED		EQU	242		;get nxt char w/o removing from input
GNC		EQU	241		;get char from input, cy=1 if none
ILP		EQU	240		;inline print
DECOUT		EQU	239		;decimal output
PRBAUD		EQU	238		;print baud rate
;
BELL:		EQU	07H		;bell
CR:		EQU	0DH		;carriage return
ESC:		EQU	1BH		;escape
LF:		EQU	0AH		;linefeed
TAB:		EQU	09H		;TAB
PRINT		EQU	09H		;BDOS print-string function
;
		ORG	100H
;
;Change the clock speed if needed, to match your system
;
		DS	3	;(for  "JMP   START" instruction)
;
		DS	1	;					103H
		DS	1	;					104H
TPULSE:		DB	'T'	;T=touch, P=pulse (Smartmodem-only)	105H
CLOCK:		DB	40	;clock speed in MHz x10, 25.5 MHz max.	106H
				;20=2 MHh, 37=3.68 MHz, 40=4 MHz, etc.
MSPEED:		DB	8	;0=110 1=300 2=450 3=600 4=710 5=1200	107H
				;6=2400 7=4800 8=9600 9=19200 default
BYTDLY:		DB	5	;0=0 delay  1=10ms  5=50 ms - 9=90 ms	108H
				;default time to send character in ter-
				;minal mode file transfer for slow BBS.
CRDLY:		DB	5	;0=0 delay 1=100 ms 5=500 ms - 9=900 ms 109H
				;default time for extra wait after CRLF
				;in terminal mode file transfer
COLUMS:		DB	5	;number of DIR columns shown		10AH
SETFLG:		DB	YES	;yes=user-added Setup routine		10BH
SCRTST:		DB	YES	;Cursor control routine 		10CH
		DS	1	;					10DH
BAKFLG:		DB	NO	;yes=change any file same name to .BAK	10EH
CRCFLG:		DB	YES	;yes=default to CRC checking		10FH
TOGCRC:		DB	YES	;yes=allow toggling of CRC to Checksum	110H
CVTBS:		DB	NO	;yes=convert backspace to rub		111H
TOGLBK:		DB	NO	;yes=allow toggling of bksp to rub	112H
ADDLF:		DB	NO	;no=no LF after CR to send file in	113H
				;terminal mode (added by remote echo)
TOGLF:		DB	YES	;yes=allow toggling of LF after CR	114H
		DS	1	;					115H
				;write logon sequence at location LOGON
SAVCCP:		DB	YES	;yes=do not overwrite CCP		116H
		DS	1	;					117H
		DS	1	;					118H
LSTTST:		DB	YES	;yes=printer available on printer port	119H
XOFTST:		DB	NO	;yes=checks for XOFF from remote while	11AH
				;sending a file in terminal mode
XONWT:		DB	NO	;yes=wait for XON after CR while	11BH
				;sending a file in terminal mode
TOGXOF:		DB	YES	;yes=allow toggling of XOFF checking	11CH
IGNCTL:		DB	YES	;yes=CTL-chars above ^M not displayed	11DH
NDELAY:		DB	30	;Modem no answer delay			11EH
EXTRA:		DS	1	;					11FH
BRKCHR:		DB	'@'-40H	;^@ = Send a 300 ms. break tone		120H
NOCONN:		DB	'N'-40H	;^N = Disconnect from the phone line	121H
LOGCHR:		DB	'L'-40H	;^L = Send logon			122H
LSTCHR:		DB	'P'-40H	;^P = Toggle printer			123H
UNSAVE:		DB	'R'-40H	;^R = Close input text buffer		124H
TRNCHR:		DB	'T'-40H ;^T = Transmit file to remote		125H
SAVCHR:		DB	'Y'-40H	;^Y = Open input text buffer		126H
EXTCHR:		DB	'^'-40H	;^^ = Send next character		127H
;
;
		DS	2		;				128H
;
INCTL1:		IN	SPORT ! RET	;in modem control port		12AH
		DS	7
OTDATA:		OUT	DPORT ! RET	;out modem data port		134H
		DS	7
INPORT:		IN	DPORT ! RET	;in modem data port		13EH
		DS	7
MASKR:		ANI	MDRCVB ! RET	;bit to test for receive ready	148H
TESTR:		CPI	MDRCVR ! RET	;value of rcv. bit when ready	14BH
MASKS:		ANI	MDSNDB ! RET	;bit to test for send ready	14EH
TESTS:		CPI	MDSNDR ! RET	;value of send bit when ready	151H
		DS	17		;				154H
DISCV:		JMP	DISCON		;disconnect			
GOODBV:		JMP	GOODBY		;				168H
INMODV:		JMP	DEFINI 		;go to user written routine	16BH
					;Note this change from earlier vers.
NEWBDV:		JMP	NEWBAUD		;Change baudrate		16EH
		RET  !	NOP  !	NOP	;				171H
		RET  !	NOP  !	NOP	;				174H
SETUPV:		JMP	SETCMD		;				177H
		DS	3		;Not used by MEX		17AH
VERSNV:		JMP	SYSVER		;				17DH
BREAKV:		JMP	SBREAK		;				180H
;
;
;Do not change the following six lines.
;
ILPRTV:		DS	3		;				183H
INBUFV:		DS	3		;				186H
INCMPV:		DS	3		;				189H
INMDMV:		DS	3		;				18CH
		DS	3		;				18FH
TIMERV:		DS	3		;				192H
;
;
;The following clear the screen for the H19 or H89 terminal
;
CLREOS:		LXI	D,EOSMSG
		MVI	C,PRINT
		CALL	MEX
		RET			
;
CLS:		LXI	D,CLSMSG
		MVI	C,PRINT
		CALL	MEX
		RET			
;
;
SYSVER:		CALL    MILP
		DB	'N*VEM version hacked from HZ89 '
		DB	'8250'
		DB	'.',CR,LF,0
		RET	
;------
;
;This routine sends a 300 ms. break tone to reset some time-share
;computers.

SBREAK:   IN	BRPORT
	  ORI	SBR	
	  OUT	BRPORT
	  JMP	DISC1

;------
GOODBY:	  RET			;Not done here

;------
;
;Disconnect the modem	

DISCON:	  XRA	A
	  OUT	MCPORT		;SET DTR AND RTS LOW
;
DISC1:	  MVI	B,3		;WAIT 300 MS.
	  MVI	C,TIMER
	  CALL	MEX	
	  LDA	LCR		;stored version of line control register
	  OUT	LCPORT 
	  MVI	A,SRTSDTR
	  OUT	MCPORT 		;set DTR & RTS high
	  RET
;.....
;
;The following is used to initialize the H89 UART.
;Note that on initialization the program jumps to DEFINI, which uses
;MSPEED to set the default modem speed, and the values at LCR: to set
;parity, data bits, etc.

DEFINI:	
	RET ; <-----------------------------------------
	  LDA	MSPEED
	  JMP	NEWBAUD
;
NITMOD:   MVI	A,0	;this is set by LOADBD
	  STA	MSPEED	;store new modem speed
	  DI		;disable interrupts
;	
	 IF IO8250
	  XRA	A
	  OUT	INTPORT 	;clear interrupts
	  MVI	A,SDLAB
	  OUT	LCPORT	;set devisor latch access bit
	 ENDIF		;IO8250
;
LSPSPD:	  MVI	A,0		;Value set by LOADBD.
	  OUT	SPDPORT0	;With the 2661 this is mode register 1 = LCR
				;With the 8250 this is the LSB of baud rate
MSPSPD:	  MVI	A,0		;Value set by LOADBD
	  OUT	SPDPORT1	;With 2661 this is mode register 2 = baud rate
				;With 8250 this is MSB of baud rate
;
	 IF IO8250
	  LDA	LCR		;Already done above if 2661
	  OUT	LCPORT
	 ENDIF			;IO8250
;
	  MVI	A,SRTSDTR	;Set RTS & DTR
	  OUT	MCPORT
	  EI			;restore interrupts to normal
	  RET
;.....
;
;Set command processor
;
SETCMD:	  MVI	C,SBLANK	;ANY ARGUMENTS?
	  CALL  MEX
	  JC	SETSHO		;IF NOT, DISPLAY DEFAULT(S)
	  LXI	D,CMDTBL
          MVI	C,LOOKUP
	  CALL  MEX		;PARSE THE ARGUMENT
	  PUSH	H		;SAVE ANY PARSED ARGUMENTS ON STACK
	  RNC			;IF WE HAVE ONE, RETURN TO IT
	  POP	H		;OOPS, INPUT NOT FOUND IN TABLE
SETERR:	CALL 	MILP
	  DB	CR,LF,'SET command error',CR,LF,0
	  RET
;
;Argument table
;
CMDTBL:   DB	'?'+80H			;HELP
	  DW	SETHELP
;
	   IF	SMMODEM
	  DB	'ORI','G'+80H		;ORIGINATE MODE
	  DW	ORIG
	  DB	'ANSWE','R'+80H		;ANSWER MODE
	  DW	ANS
	  DB	'TON','E'+80H		;TONE DIALING
	  DW	STTONE
	  DB	'PULS','E'+80H		;PULSE DIALING
	  DW	STPULSE
	  DB	'DELA','Y'+80H		;SET DELAY
	  DW	DELAY
           ENDIF		;SMMODEM
;
	  DB	'BAU','D'+80H		;SET BAUD
	  DW	STBAUD
	  DB	'PARIT','Y'+80H		;SET PARITY
	  DW	STPRTY
	  DB	'STOPBIT','S'+80H	;SET STOPBITS
	  DW    STSTOP
	  DB	'LENGT','H'+80H		;SET LENGTH
	  DW	STBITS
	  DB	0			;TABLE TERMINATOR
;
;
; "SET (no args): PRINT CURRENT STATISTICS
;
SETSHO:	  CALL  MILP	
	  DB	CR,LF
	  DB	'SET values:',CR,LF,CR,LF,0

           IF SMMODEM
	  CALL	MDSHOW
	  CALL	CRLF
	  CALL	TPSHOW
	  CALL	CRLF
	  CALL	DLSHOW
	  CALL	CRLF		
	   ENDIF		;SMMODEM
;
	  CALL	BDSHOW
	  CALL	CRLF
	  CALL  SHPRTY
	  CALL	CRLF
	  CALL	SHSTOP
	  CALL	CRLF
	  CALL  SHBITS
	  CALL	CRLF
	  RET
;
;"SET ?" processor
;
SETHELP:  CALL	MILP

  	   IF SMMODEM
	  DB	CR,LF,'SET ORIG'
	  DB	CR,LF,'SET ANSWER'
	  DB	CR,LF,'SET TONE'
	  DB	CR,LF,'SET PULSE'
	  DB	CR,LF,'SET DELAY     - <N> seconds'
	   ENDIF		;SMMODEM
;
	  DB	CR,LF,'SET PARITY    - OFF, EVEN or ODD'
	  DB	CR,LF,'SET STOPBITS  - 1, or 2'
	  DB	CR,LF,'SET LENGTH    - 5, 6, 7 or 8'
	  DB	CR,LF,'SET BAUD      - 300, 600, 1200, 2400, '
	  DB	'4800, 9600'
	  DB	CR,LF,CR,LF,0
	  RET
;
;
;"SET BAUD" processor
;
STBAUD:	  MVI	C,SBLANK	;
	  CALL	MEX
	  JC	SETERR		;
	  LXI	D,BDTBL
	  MVI	C,LOOKUP
	  CALL	MEX		;Parse argument
	  PUSH	H		;Save any parsed argument addrs on stack
	  RNC			;If we have one, return to it
	  POP	H		;Oops, input not found in table
	  CALL	MILP		;Tell user input not valid
	  DB	CR,LF,'That baudrate not supported by SET command',CR,LF,0
	  RET
;
BDTBL:	  DB	'30','0'+80H
	  DW	OK300
	  DB	'60','0'+80H
	  DW	OK600
	  DB	'120','0'+80H
	  DW	OK1200
	  DB	'240','0'+80H
	  DW	OK2400
	  DB	'480','0'+80H
	  DW	OK4800
	  DB	'960','0'+80H
	  DW	OK9600
	  DB	0
;
OK300:	  MVI	A,1		;MSPEED 300 baud value
	  LHLD	BD300		;get 300 baud parameters in HL
	  JMP	LOADBD		;go load them
;
OK600:	  MVI	A,3
	  LHLD	BD600
	  JMP	LOADBD
;
OK1200:	  MVI	A,5
	  LHLD	BD1200
	  JMP	LOADBD
;
OK2400:   MVI	A,6
	  LHLD	BD2400
	  JMP	LOADBD
;
OK4800:	  MVI	A,7
	  LHLD	BD4800
	  JMP	LOADBD
;
OK9600:	  MVI	A,8
	  LHLD	BD9600
	  JMP	LOADBD
;
LOADBD:	  STA	NITMOD+1	;store speed to show transfer time

	  MOV	A,L		;get least significant baud rate byte
	  STA	LSPSPD+1	;store in NITMOD
	  MOV	A,H		;get most signifcant baud rate byte

	  STA	MSPSPD+1	;store in NITMOD
	  JMP	NITMOD		;reset H89 8250
;
NEWBAUD:  CPI	1
	  JZ	OK300
	  CPI	3
	  JZ	OK600
	  CPI	5
	  JZ	OK1200
	  CPI	6
	  JZ	OK2400
	  CPI	7
	  JZ	OK4800
	  CPI	8
	  JZ	OK9600
	  RET
;
;Table of baud rate parameters
;

	 IF IO8250
BD300:	  DW	0180H
BD600:	  DW	00C0H
BD1200:	  DW	0060H
BD2400:	  DW	0030H
BD4800:	  DW	0018H
BD9600:   DW	000CH
	 ENDIF		;IO8250
;
BDSHOW:	  LDA	MSPEED		;GET CURRENT BAUD RATE
	  MVI	C,PRBAUD	;LET MEX PRINT IT
	  CALL	MEX
	  RET 
;
;
	  IF    SMMODEM
;
;SET MODE PROCESSOR 
;
ORIG:	  XRA	A
	  STA	ANSFLG		;SET ORIG FLAG
	  LXI	H,SMO		;SEND OUT ATS0=0
	  CALL	SMSEND
	  RET
;
ANS:	  MVI	A,0FFH
	  STA	ANSFLG		;SET ANS FLAG
	  LXI	H,SMA		;SEND OUT ATS0=1
	  CALL	SMSEND
	  RET			;EXIT 
;
;Send string to the SmartModem
;
SMSEND:	  MVI	C,SNDRDY	;WAIT FOR MODEM READY
	  CALL	MEX
	  JNZ	SMSEND
	  MOV	A,M		;FETCH NEXT CHARACTER
	  INX	H
	  ORA	A		;END?
	  RZ			;DONE IF SO
	  MOV	B,A		;NO, POSITION FOR SENDING
	  MVI	C,SNDCHR	;NOPE, SEND THE CHARACTER
	  CALL	MEX
	  JMP	SMSEND
;
;
MDSHOW:	  LDA	ANSFLG
	  ORA	A
	  JZ	MDORIG		
	  CALL	MILP
	  DB	'Auto-answer mode',0
	  RET
MDORIG:	  CALL	MILP
	  DB	'Originate mode',0
	  RET
;
SMO:	  DB	'ATS0=0',CR,0
SMA:	  DB	'ATS0=1',CR,0
;
;
;Set dial processor
;
STTONE:	  MVI	A,'T'
	  JMP	SDIAL1
STPULSE:  MVI	A,'P'
SDIAL1:   STA	TPULSE
	  RET
TPSHOW:	  LDA	TPULSE
	  CPI	'T'
	  JZ	TPTONE
	  CALL	MILP
	  DB	'Pulse Dial',0
	  RET
TPTONE:	  CALL	MILP
	  DB	'Tone Dial',0	  
	  RET
;
;
;Set delay processor
;
DELAY:	  MVI	C,EVALA
	  CALL	MEX
	  MOV	A,H
	  ORA	A
	  JNZ	SETERR
	  MOV	A,L
	  STA	NDELAY
	  RET
DLSHOW:	  CALL	MILP
	  DB	'Answer Delay is ',0
	  LHLD	NDELAY
	  MVI	H,0
	  MVI	C,DECOUT
	  CALL	MEX
	  CALL	MILP
	  DB	' seconds',0
	  RET
;
	  ENDIF		;SMMODEM
;
;------
;	SET PARITY command: reset transmit/receive parity
;
STPRTY:	  MVI	C,SBLANK	;check for parity code
	  CALL	MEX		;
	  JC	SETERR		;if none, print error
	  LXI	D,PARTBL	;check for proper syntax
	  MVI	C,LOOKUP
	  CALL	MEX
	  JC	SETERR
 	  LDA	LCR
	  ANI	RPOFF		;Reset parity bits (also sets parity off)
	  PCHL			;go to the proper section
;
PREVEN:	  ORI	SPEVEN
	  JMP	PARTB1
PRODD:	  ORI	SPODD
PARTB1:	  STA	LCR		;Also comes to this point if set parity to off
	  JMP	NITMOD
;
SHPRTY:	  CALL	MILP
	  DB	'Parity:  ',TAB,' ',0
	  LDA	LCR
	  ANI	PARITYM
	  CPI	SPOFF	;parity off?
	  JNZ	SHPRT1
	  CALL	MILP
	  DB	'Off',0
	  RET
SHPRT1:	  CPI	SPODD	;parity odd?
	  JNZ	SHPRT2
	  CALL	MILP
 	  DB	'Odd',0
	  RET
SHPRT2:	  CALL	MILP		;
	  DB	'Even',0	;
	  RET
;
;	SET PARITY command table
;
PARTBL:	  DB	'OF','F'+80H	;"set parity off"
	  DW	PARTB1
	  DB	'EVE','N'+80H	;"set parity even"
	  DW	PREVEN
	  DB	'OD','D'+80H	;"set parity odd"
	  DW	PRODD
	  DB	0		;<<== end of parity table
;
;-------
;	SET STOPBITS command: reset number of stop bits
;

STSTOP:	  MVI	C,SBLANK	;check for stop bits
	  CALL	MEX		;
	  JC	SETERR		;if none, print error
	  LXI	D,STPTBL	;check for proper syntax
	  MVI   C,LOOKUP
	  CALL	MEX		;
	  JC	SETERR		;print error
	  LDA	LCR
	  ANI	RSB		;reset stop bits
	  PCHL			;go do it

STOP01:	  ORI	SSB1
	  JMP	STSTP1
STOP15:	  ORI	SSB15
	  JMP	STSTP1
STOP02:	  ORI	SSB2
STSTP1:	  STA	LCR
	  JMP	NITMOD
;
;
SHSTOP:	  CALL	MILP		;display stop-bits
	  DB	'Stop bits:',TAB,' ',0
	  LDA	LCR		;
	  ANI	STPBITM
	  CPI	SSB1
	  JNZ	SHSTP2
	  CALL	MILP
	  DB	'1',0
	  RET
SHSTP2:	  CPI	SSB2
          JNZ	SHSTP15
	  CALL	MILP
	  DB	'2'
;
	 IF IO8250
	  DB	' or 1.5 if 5 bit data words'
	 ENDIF
;
	  DB 	0
	  RET
SHSTP15:	
	  CALL	MILP
	  DB	'1.5',0
	  RET

;
;	SET STOPBITS command table
;
STPTBL:	  DB	'1'+80H		;"set stop 1"
	  DW	STOP01
	  DB	'2'+80H		;"set stop 2"
	  DW	STOP02
	  DB	'1.','5'+80H	;1.5 stop bits
	  DW	STOP15
	  DB	0		;<<== End of stop-bits table
;
;-------
;	SET LENGTH command: set bits per character
 

STBITS:	  MVI	C,SBLANK	;check for bits/char
	  CALL	MEX		;
	  JC	SETERR		;if none, print error
	  LXI	D,BITTBL	;check for proper syntax
	  MVI	C,LOOKUP
	  CALL	MEX
	  JC	SETERR
	  LDA	LCR
	  ANI	RDB		;reset data bits (also = 5 bit)
          PCHL			;go do function

BIT6:	  ORI	SDB6	;6 bits
	  JMP	STBTS1	  
BIT7:	  ORI	SDB7	;7 bits
	  JMP	STBTS1
BIT8:	  ORI	SDB8	;8 bits
STBTS1:	  STA	LCR	;also comes here if set bits to 5
	  JMP	NITMOD

SHBITS:	  CALL	MILP		;display bits/char
	  DB	'Bits/char:',TAB,' ',0
	  LDA	LCR		;
	  ANI	DATBITM
	  JZ	SHDB5
	  CPI	SDB6
	  JZ	SHDB6
	  CPI	SDB7
	  JZ	SHDB7
	  CALL	MILP
	  DB	'8',0
	  RET
SHDB7:	  CALL 	MILP
	  DB	'7',0
	  RET
SHDB6:	  CALL	MILP
	  DB	'6',0
	  RET
SHDB5:	  CALL	MILP
	  DB	'5',0
	  RET

;
;	SET LENGTH command table
 
BITTBL:	  DB	'5'+80H		;"set bits 5"
	  DW	STBTS1
	  DB	'6'+80H		;"set bits 6"
	  DW	BIT6
          DB	'7'+80H		;7 BITS
	  DW	BIT7
       	  DB	'8'+80h		;8 bits
	  DW	BIT8
	  DB	0		;<<== end of bpc table
;
;General utility routines
;
MILP:	  MVI	C,ILP		;IN-LINE PRINT
	  JMP	MEX
	  RET
;
CRLF:	  CALL	MILP		;PRINT CARRIAGE RETURN, LINE FEED
	  DB	CR,LF,0
	  RET
;
;
;
;==========================================================================
;                           Data Area
;==========================================================================
;
LCR:	  DB	DEFLCR
ANSFLG:	  DB	0
;
;
BAUDBUF:  DB	10,0
	  DS	10
;
EOSMSG:	  DB	ESC,'J',0,0,0,'$'		  	
CLSMSG:	  DB	ESC,'E',0,0,0,'$'
;------------------------------------------------------------------
;
;NOTE:  MUST TERMINATE PRIOR TO 0B00H (with Smartmodem)
;
	  END

