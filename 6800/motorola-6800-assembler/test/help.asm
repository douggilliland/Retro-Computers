*
*	Copied from:
*	MEK6802D5 Microcomputer Evaluation Board User's Manual
*	Page 3-10
*
*	Assemble with the following command:
* 	as0 help.asm -L CRE C S
*
	NAM	HELP
*	Options set in file override command line option settings.
*	OPT	c		* options must be in lower case
*	OPT	cre		* one option per line
	ORG	$0
* D5 DEBUT ROUTINES
DIDDLE	EQU	$F0A2
DISBUF	EQU	$E41D
MNPTR	EQU	$E419
PUT	EQU	$F0BB
*
*
BEG	LDX	#$7679		"HE"
	STX	DISBUF		STORE TO FIRST 2 DISPLAYS
	LDX	#$3873		"LP"
	STX	DISBUF+2
	LDX	#$4040		"--"
	STX	DISBUF+4	STORE THE LAST 2 DISPLAY
	LDX	#DIDDLE		ADDR OF DIDDLE ROUTINE
	STX	MNPTR		ESTABLISH AS ACTIVE SUB OF PUT
	JMP	PUT		CALL DISPLAY ROUTINE
