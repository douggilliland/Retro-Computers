*-----------------------------------------------------------
* Title      :T68kBug
* Written by :H Shen
* Date       :6/4/2017
* Description:fork from v003 of T030bug
*-----------------------------------------------------------
* fork from v003 of T030bug 
* 6/4/2017
* memory map: DRAM 0-ff7fff, I/O is ff8000 to ffffff, 68681: fff000-ffffff
* CF-IDE: cs0:ffe000-ffe00f, cs1:ffe010-ffe01f
* 7/11/17: add 'bo' command to boot into CP/M stored in LA 1 of compact flash
* 7/12/17: add 'sw' command to swap monitor to $FE8000.  This allow new monitor to be loaded
*   in $400 and test out its functionality
* 11/1/17: 7-seg display will display critical steps during booting.
*   Only have one 7-seg display in rev 1 pc board.


DUART	equ $FFF000	* base address of 68692 DUART
MRA	equ $FFF001	* mode reg A
SRA	equ $FFF003	* status A (read)
CSRA	equ $FFF003	* clock select reg (write)
CRA	equ $FFF005	* command register (write only)
RHRA	equ $FFF007	* Rx Hold reg A (read)
THRA	equ $FFF007	* Tx Holding reg (write)
IPCR	equ $FFF009	* Input port change reg (read)
ACR	equ $FFF009	* Aux control reg (write)
ISRD	equ $FFF00B	* interrupt status reg (read)
IMRD	equ $FFF00B	* interrupt mask reg (write)			
CTU	equ $FFF00D	* Counter/timer upper (read)
CTL	equ $FFF00F	* counter/timer lower (read)
CTUR	equ $FFF00D	* Counter/timer preload upper (write)
CTLR	equ $FFF00F	* counter/timer preload lower (write)
MR1B	equ $FFF011	* mode reg B
SRB	equ $FFF013	* status reg B
RHRB	equ $FFF017	* Rx holding reg B
IVRD	equ $FFF019	* interrupt vector reg
STOPCTR	equ $FFF01F	* stop counter command reg (read)
STARTCTR equ $FFF01D	* start counter command reg (read)
SETOPR	equ $FFF01D	* bit set output register bits (write)
CLROPR	equ $FFF01F	* bit clear output register (write)
OPCR	equ $FFF01B	* output configuration register(write)


True	equ 0
False	equ 1
Error	equ $ff

	org	$FF0000		* top 32K of RAM is for stack and global variables
ROMver	ds.l 1			* this is 1st variable of a task descriptor block
wallclock ds.l 1		* global wall clock
downtimer1 ds.w 1		* this is always the 3rd variable of a TDB, room for 2
				* down timers
downtimer2 ds.w 1
amrsvp	ds.l 1			* reserve fix long word for future

savd0	ds.l 1			* allocate for 68302 registers
savd1	ds.l 1
savd2	ds.l 1
savd3	ds.l 1
savd4	ds.l 1
savd5	ds.l 1
savd6	ds.l 1
savd7	ds.l 1
sava0	ds.l 1
sava1	ds.l 1
sava2	ds.l 1
sava3	ds.l 1
sava4	ds.l 1
sava5	ds.l 1
sava6	ds.l 1
savsp	ds.l 1
savpc	ds.l 1
	
cUErr	ds.w 1
fWval	ds.b 1			* write flag
fSerr	ds.b 1			* S record error
pStr	ds.l 1			* string pointer for DUARTisr
bAnswer	ds.l 5			* 20 bytes of response buffer, byte order:
			* LF, CR, A, A, A, A, A, A, A, A ':', 
			* D, D, D, D, LF, CR, '>', ' ', 0
bByteAns ds.l 1		* buffer for a byte of data for printing: space-ascii-ascii-null
bCmdline ds.l 5		* command line, handle up to 20 characters
pCmdln	ds.l 1		* pointer into the command line buffer
cCmd	ds.b 1		* count number of bytes in command buffer
fDoCmd	ds.b 1		* flag for command ready to execute	
cCmdparam ds.b 1	* number of command parameters
fCmdDone ds.b 1		* flag for command in progress (0) or done (1)
cmdparam ds.l 4		* command parameters
RegASCII ds.b 10	* ASCII value of a register, null terminated
corner7seg ds.b 1	* value of corner 7-segment display
          ds.b 1	* reserve
cntIdle	ds.l 1		* idle loop counter
maxIdle	ds.l 1		* Idle loop count for this time period
nullchar ds.b 2		* string terminator, two characters, 
			* one will be modified for mr command use
fTxDone	ds.b 1		* flag for ISR finishs transmitting string
fbpverbose ds.b 1	* verbose flag for breakpoint
bkptaddr ds.l 1		* address where illegal instruction is inserted
bkptinstr ds.w 1	* instruction swapped out for breakpoint
fdobkpt	ds.b 1		* indicating whether breakpoint is in progress or not
fSerrAll ds.b 1		* reserve byte
cTrace	ds.w 1		* number of trace to perform
seconds	ds.b 1		* time register (seconds) in RTC72423
sInteractive ds.b 1	* Interactive session state, 0=none, 1=mm cmd, 2=mr cmd
startaddr ds.l 1	* starting address for the S record file load
pidle7seg ds.l 1	* pointer to which 7-segment to display in idle routine
mmaddress ds.l 1	* address value from mm command saved for interactive session
cTxChar	ds.w 1		* count of how many characters to transmit. -1 to disable 
fTxChar	ds.b 1		* enable (1) or disable (0) transmission of character in DUART isr
exitCode ds.b 1		** error code for command execution.  0=normal, 1=error
          ds.b 1	         * reserve
sav7seg	ds.b 1		* saved data for manipulated 7-seg display
fEASyTEcho ds.b 1         * echo flag for EASy trap 15 task 12 echo is default to on, 
                           * 0=echo off 
fEASyTCRLF ds.b 1          * flag to signify adding CR LF to output string
LA2427   ds.b     1        * head 
LA1623   ds.b     1        * cylinder high
LA815    ds.b     1        * cylinder low
LA07     ds.b     1        * sector
	
	org	$0		
* This program will be serially loaded in DRAM at start up
	dc.l $FF7FFC		* stack at the top task space
	dc.l Tiny68kbug	* start address of Tiny68kbug
	dc.l buserr	* BERR handler
	dc.l addrerr	* address error handler
	dc.l breakpt	* illegal instruction used as breakpoint
	dcb.l 4,unknown
	dc.l trace	* trace handling
	dcb.l 37,unknown
	dc.l EASyTrap     * trap 15 implementing EASy68K trap services	
	dcb.l 81,unknown	
	dc.l DUARTisr	* No. $81, service DUART connected to PB8
	dcb.l 126,unknown	* the rest to unknown

	org $400		* not necessary, but just in case...
Tiny68kbug:			* starting point when tiny020 is boot off flash
* this part of code will not execute when Tiny68kbug is loaded in RAM
	move.w #$2700,sr	* mask off interrupts
	lea $FF7FFC,sp	* initialize stack to top of task descriptor block
	bra entry
RAMstart:		* starting point for tiny68kbug loaded in RAM
	move.w #$2700,sr	* mask off interrupts
	lea $FF7FFC,sp	* initialize stack to top of task descriptor block
	bra entry

* User command dispatch tables
commands:
	dc.l do_dm-exec_cmd	* display memory
	dc.l do_dr-exec_cmd	* display register
	dc.l do_mm-exec_cmd	* modify memory
	dc.l do_mr-exec_cmd	* modify register
	dc.l do_go-exec_cmd	* go
	dc.l do_bp-exec_cmd	* breakpoint
	dc.l do_help-exec_cmd	* help message
	dc.l do_du-exec_cmd	* dump memory content command
	dc.l do_sw-exec_cmd        * swap monitor software to $FE8000
	dc.l do_bo-exec_cmd        * boot CP/M 68K
* corresponding mnemonic for the user command table
mnemonictbl:
	dc.w 'dm'
	dc.w 'dr'
	dc.w 'mm'
	dc.w 'mr'
	dc.w 'go'
	dc.w 'bp'
	dc.w 'he'
	dc.w 'du'
	dc.w 'sw'
	dc.w 'bo'         * boot CP/M68k from Compact flash
	dc.w $0	
entry:
	reset		* reset peripherals
	bsr iDUART	* initialize 68681 and drive the display immediately
	move.b #$ff,SETOPR	* clear display
	move.b #$c,CLROPR	* drive the value '1' on a 7-seg display
	move.l #$1e1e1e1e,$FF7FFC	* mark memory beyond top of the stack as a
				* way to check stack underflow		
	clr.l d1		* clear all data and address registers, except a5
	clr.l d2
	clr.l d3
	clr.l d4
	clr.l d5
	clr.l d6
	clr.l d7
	lea $0,a1
	lea $0,a2
	lea $0,a3
	lea $0,a4
	lea $0,a6
* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Change rev # here @@@@@@@@@@@@@@@@@@@@@@@@@@
	move.l #$30303036,ROMver	* version number need a better way of doing this
	move.b #$5b,corner7seg	* diagnostic, put '2' out on 7-segment displays
	clr.l bkptaddr		* no breakpoint
	clr.b fdobkpt
	move.b #1,fbpverbose	* the verbose flag for breakpoint
	bsr iBuffer
	move.b #$ff,SETOPR	* clear display
	move.b #$9e,CLROPR	* drive the value '3' on a 7-seg display
	clr.b cCmd		* clear command line state
	clr.b fDoCmd		* clear command ready to execute flag
	move.l #bCmdline,pCmdln	* initialize command line pointer to the beginning
	clr.b sInteractive	* set interactive session state to none
	clr.w nullchar		* null terminator for the register string
	clr.b fEASyTCRLF	* no carriage return & line feed to put string
	move.b #$20,bByteAns	* initialize byte answer buffer, bByteAns
	clr.b bByteAns+3	* space, high-nibble, low-nibble, null-terminator
	bsr idleinit		* initialize idling 7 segment display variables
	clr.b fSerr		* clear s record error flag
	move.b #' ',RegASCII+8	* put a space character at the end of register string
	clr.b RegASCII+9	* null terminate the register string
	move.w #-1,cTxChar	* disable counting how many character to transmit
	clr.b fTxChar		* disable transmission of character in DUART ISR
	clr.b fSerrAll		* clear cumulated S record error flag
	clr.l cntIdle		* reset idle loop counter
	move.b #True,fTxDone	* initialize to transmission done
mpuinit1:		
	move.b #5,CRA		* enable transmit and receive
	move.b #$ff,SETOPR	* clear display
	move.b #$cc,CLROPR	* drive the value '4' on a 7-seg display
	move.w #$2000,SR	         * lower interrupt level
	lea signon(pc),a1	         * output signon message
	move.b #14,d0
	trap #15
	move.b #$7d,corner7seg	* put version # on 7-seg displays
******************************************
* value in corner7seg     value displayed	
*	$3F		 0
*	$06		 1
*	$5B		 2	
*	$4F		 3	
*	$66		 4	
*	$6D		 5	
*	$7D		 6	
*	$07		 7	
*	$7F		 8	
*	$6F		 9
******************************************
* write to CLROPR   value displayed
*        $7E               0
*        $0C               1
*        $B4               2
*        $9E               3
*        $CC               4
*        $DA               5
*        $FA               6
*        $0E               7
*        $FE               8
*        $DE               9
****************************************
* foreground loop
fore:
	bsr newidle7seg		* idle routine moving 7-segment display
	bsr Tiny68kcmd		* processing console command
*@@@@ add additional tasks here @@@@*******

fore9:
	add.l #1,cntIdle	* increment idle loop counter
	bra fore
******************************************
idleinit:
	pea inv7segtbl(pc)	* initialize pointer to segment manipulation table
	move.l (sp)+,pidle7seg	* save pointer
	clr.w downtimer2	* clear downtimer2 so circulating segments will commence
	rts

newidle7seg:
* a new idle routine, every 1/2 second it will invert a segment of display.  It visits
* 6 segments in a circular fashion
* restore the manipulation 200ms second later, so the display will just flicker for 200ms
	movem.l d0-d1/a0-a1,-(sp)	* save registers
	cmp.w #30,downtimer2	* if downtimer is at 300ms, undo the manipulation
	beq uninv7seg
	tst.w downtimer2
	bne newidle7seg9
	move.w #50,downtimer2	* set downtimer to expire in half second
	move.l pidle7seg,a0	* get pointer to manipulate next segment of display
	lea 8(a0),a0		* point to next segment to manipulate
	lea inv7segEnd(pc),a1	* get end of table
	cmp.l a1,a0		* end of the table?
	blt newnxtidle7seg
	lea inv7segtbl(pc),a0	* reload segment manipulation table
newnxtidle7seg:
	move.l (a0),a1		* get the address of display into a2
	move.b 7(a0),d1		* get the bit to manipulate
	eor.b d1,(a1)		* invert the manipulated bit
	move.b (a1),sav7seg	* save the manipulated data
	move.l a0,pidle7seg	* save pointer
newidle7seg9:
	movem.l (sp)+,d0-d1/a0-a1	* restore registers
	rts
uninv7seg:
	move.l pidle7seg,a0	* get pointer to manipulate next segment of display
	move.l (a0),a1		* get the address of display into a2
	move.b 7(a0),d1		* get the bit to manipulate
	move.b (a1),d0		* if saved manipulated data is different than current data,
	cmp.b sav7seg,d0	* then new data has been written since, don't flicker
	bne uninv7seg1
	eor.b d1,(a1)		* invert the manipulated bit
uninv7seg1:
	sub.w #1,downtimer2	* change it so this routine execute once every 1/2 sec
	bra newidle7seg9
	
inv7segtbl:
*	  00000		Segments patterns represented by 
*	 5     1		data bits 0 through 6
*	 5     1	
*	  66666	
*	 4     2	
*	 4     2	
*	  33333
* 
* start with 2 and works clockwise "figure 8" pattern
	dc.l corner7seg
	dc.l $4		* data bit 2
	dc.l corner7seg
	dc.l $8		* data bit 3
	dc.l corner7seg
	dc.l $10	         * data bit 4
	dc.l corner7seg
	dc.l $20	         * data bit 5
	dc.l corner7seg
	dc.l $1		* data bit 0
	dc.l corner7seg
	dc.l $2		* data bit 1
inv7segEnd:
	
Tiny68kcmd:	
* when in interactive session, look for difference sources of inputs depending on the session
* session #1, looks for fDoCmd ready (keyboard inputs)
* interactive session of mm command	
	tst.b sInteractive
	beq doCmd
	movem.l a0-a5/d0-d7,-(sp)	* save registers 
	cmp.b #1,sInteractive
	bne interact9
	tst.b fDoCmd		* Is a command ready for execution?
	beq dodo9
	bsr mminteractive	         *mm command interactive session
	bra dodo9
interact9:
	clr.b sInteractive		* error condition, 
* should print error message 
	bra dodo9

doCmd:
	tst.b fDoCmd		* Is a keyboard command ready for execution?
	beq doPrompt		* check if prompt needs to be output
cmdtodo:
	movem.l a0-a5/d0-d7,-(sp)	* save registers 
	cmp.b #2,cCmd		* need at least 2 char in command line before
				* a valid CR
	blo badcommand
	lea mnemonictbl(pc),a0	* point to command mnemonic
	lea commands(pc),a1	* the corresponding command entry point
	move.w bCmdline,d0	* current command
parsecmd:
	cmp.w (a0)+,d0		* look for command
	beq cmdproc
	add.l #4,a1		* bump to next command
	cmp.w #0,(a0)		* end of mnemonic table?
	beq badcommand
	bra parsecmd
cmdproc:
	bsr cmdreformat
	bsr enableNextCmd	* ready for next command while current command is running 
	tst.l d0
	bne badcommand
	move.l (a1),a1		* get the actual subroutine address in a1
exec_cmd:
	jsr *(pc,a1)
	bra dodo9
	
doPrompt:
** check fCmdDone.  If set, issue a prompt depend on the exit code.  check fTxDone first
** to make sure previous output has completed.
	tst.b fCmdDone	** every command subroutine should mark completion with fCmdDone set
	beq dodo9n	** end of AMbug task list
	cmp.b #False,fTxDone	** check if still outputting previous message
	beq dodo9n
	movem.l a0-a5/d0-d7,-(sp)	** save registers
	clr.b fCmdDone	** this is where fCmdDone is cleared
	tst.b exitCode	** exit code of a command execution determines what prompt to display
			** 0=normal exit, 1=error condition
	beq OKcommand	** normal prompt
	bra badcommand	** exit with error prompt
	
* don't like this approach because D0 may contains values returned from user program via 
* 'go' command.  The content of D0 is unpredictable.  On the other hand, the value of D0
* is displayed when user program terminates, so maybe this is all right...
	cmp.w #0,d0		* test result to chose the right prompt, 0=normal prompt
				* 1=error prompt, 2=no prompt (interactive session in progress)
	beq OKcommand		* normal prompt
	cmp.w #1,d0		* check for error condition
	beq badcommand
	cmp.w #2,d0		* chk for interactive session
	beq dodo9		* interactive session in progress
	bra OKcommand		* normal prompt for all other values
badcommand:
	pea qprompt(pc)		* load error prompt
	move.l (sp)+,a1		* output error prompt
	move.b #14,d0
	trap #15
	bra docommand9
OKcommand:
	pea prompt(pc)		* a different way to put string address into pStr
	move.l (sp)+,a1		* bounce off stack so no register is altered
	move.b #14,d0		* output normal prompt
	trap #15
docommand9:
        bsr enableNextCmd		* ready for next command
dodo9:
	movem.l (sp)+,a0-a5/d0-d7	* restore registers
dodo9n:
	rts

***********************
* convert ascii inputs to hex values in cmdline buffer into cmdparam
* Able to hold up to 4 long word parameters in cmdparam, cCmdparam contains the number of param
* d0.w returns valid values (0), or invalid values (1)
cmdreformat:
	movem.l d1-d2/a0/a1,-(sp)	* save
	lea bCmdline+2,a0	         * start after the command mnemonic
* get rid of extra space characters
* routine here to eliminate extra spaces and no space after the last parameter
cmdrf0:
	clr.b cCmdparam		* clear command parameter count
	sub.b #2,cCmd		* if there are only two bytes, then there are no parameter
	beq cmdrf7		* exit with zero parameter count
	
	cmp.b #' ',(a0)		* first space after command is different than subsequent space
	bne cmdrf1
	lea 1(a0),a0		* same as (a0)+
	sub.b #1,cCmd		* reduce byte count for command line buffer
cmdrf1:

	move.b cCmd,d2		* d2 contains number of bytes in command buffer
	ext.w d2		         * sign extend, prepare for dbra operation
	clr.l d1		         * d1 accumulate each nibble of ASCII input
	lea cmdparam,a1		* a1 points to parameters
	bra cmdrf6
cmdrf2:
	move.b (a0)+,d0
	cmp.b #' ',d0		* space is parameter delimiter
	bne cmdrf3
	add.b #1,cCmdparam	* increment parameter count
	move.l d1,(a1)+	
	clr.l d1		         * ready for next parameter
	bra cmdrf6
cmdrf3:
	bsr asc2hex	`	* accumulate valid ASCII into hex value
	cmp.b #$FF,d0
	beq cmdrf8
	lsl.l #4,d1
	add.b d0,d1
cmdrf6:
	dbra d2,cmdrf2
	cmp.b #4,cCmdparam	* can't have more than 4 parameters
	beq cmdrf8
	add.b #1,cCmdparam	* last parameter
	move.l d1,(a1)+
cmdrf7:
	clr.l d0		         * signal a good command line
	clr.b fCmdDone		* flag the command in progress
	bra cmdrf9
cmdrf8:
	move.l #1,d0		* signal a bad command line
	move.b #1,fCmdDone	* flag the command is finished
cmdrf9:
	movem.l (sp)+,d1-d2/a0/a1	* restore
	rts

*************************** User Commands ************************************
* display memory in word, address, <count>
do_dm:
	clr.l d3		         * loop count
	and.l #$FFFFFFFE,cmdparam	* make sure address is even
	move.l cmdparam,a0	* this is starting address to be displayed
	cmp.b #0,cCmdparam
	beq do_dm8		* no parameter, exit with error prompt
	cmp.b #2,cCmdparam	* one or two parameters
	bgt do_dm8
	move.b #0,bAnswer+15	* modify the bAnswer message string so not to print prompt
	cmp.b #1,cCmdparam
	beq do_dm1		* do one line of display memory
	move.l cmdparam+4,d3	* number of words to display
	bra do_dm9	
do_dm1:
	move.l a0,d1		* copy of a0
	move.w (a0)+,d0		* read the specified memory location
	bsr compuAnswer		* forming the answer in buffer
	move.l #bAnswer,a1	* send out the answer
	move.b #14,d0
	trap #15

do_dm9:
	cmp.b #True,fTxDone	* must wait for string transmission done, otherwise bAnswer
        	                * will be overwritten with next value.  This problem can
        	                * be solved by copying data into another buffer in trap #15
	bne do_dm9		* OS swap task here
	dbra d3,do_dm1
	move.b #$a,bAnswer+15	* restore bAnswer message string to print prompt	
	clr.l d0		         * signal regular prompt
	clr.b exitCode		** exit normally
	bra do_dm9x
do_dm8:
	moveq.l #1,d0		* signal error prompt
	move.b #1,exitCode	** exit with error
do_dm9x:
	move.b #1,fCmdDone	* flag the command is finished
	rts
* display register <a|d> <0-7>
* dr without parameter displays all registers, dr a|d displays all address or data registers
* dr a0-7 displays address a0-a7, dr d0-7 displays d0-d7
do_dr:
	movem.l d0-d7/a0-a7,savd0	* save data & addr registers into system RAM
do_bp_dr:			* entry point for dr command in breapoint handler
				* the register array is already saved, do not save again
	move.l cmdparam,d2	* this is address or data register select
	cmp.b #0,cCmdparam
	beq do_dr1		* no parameter, display all registers
	cmp.b #1,cCmdparam
	bgt do_dr8		* greater than 1 parameters, exit with error prompt
	cmp.l #$a,d2		
	beq do_dr_a		* 1st parameter = $a 
	cmp.l #$d,d2		
	beq do_dr_d		* 1st parameter = $d
	cmp.l #$a0,d2		* $a0 <= parameter <= $a7
	blo do_dr8
	cmp.l #$a7,d2
	bhi do_dr_dx		* check for $d0-$d7
	moveq.l #0,d1		* display just one register
	sub.l #$a0,d2
	move.l d2,d3
	mulu.w #RegStrLen,d3	* compute string array address offset
	lsl.l #2,d2		* compute register array offset
	bra do_dra0_7
do_dr_dx:
	cmp.l #$d0,d2		* $d0 <= parameter <= $d7
	blo do_dr8		* exit with error prompt
	cmp.l #$d7,d2
	bhi do_dr8		* exit with error prompt
	moveq.l #0,d1		* display just one register
	sub.l #$d0,d2
	move.l d2,d3
	mulu.w #RegStrLen,d3	* compute string array address offset
	lsl.l #2,d2		* compute register array offset
	bra do_drd0_7
do_dr_a:
	moveq.l #7,d1		* all 8 address registers
	clr.l d3		         * no string offset
	clr.l d2		         * no register array offset
do_dra0_7:
	lea savA0,a0
	adda.l d2,a0
	lea regA0(pc),a1
	adda.l d3,a1
	bra do_dr2
do_dr_d:
	moveq.l #7,d1		* display all data registers
	clr.l d3		         * no string offset
	clr.l d2		         * no register array offset	
do_drd0_7:
	lea savD0,a0
	adda.l d2,a0
	lea regD0(pc),a1
	adda.l d3,a1
	bra do_dr2	
do_dr1:
	lea savd0,a0		* point to the register array 
	moveq.l #16,d1		* loop count +1
	lea regD0(pc),a1
do_dr2:
	bsr do_dr_reg
	adda.l #RegStrLen,a1	* increment to next message string
	adda.l #4,a0		* next register in the register array
	dbra d1,do_dr2
do_dr9:	
	clr.l d0		
	clr.b exitCode		** exit normally
	bra do_dr9x
do_dr8:
	moveq.l #1,d0
	move.b #1,exitCode	** exit with error prompt
do_dr9x:
	move.b #1,fCmdDone
	rts
do_dr_reg:	
* a1 points to a null terminated message
* a0 points to save register array
        movem.l d0,-(sp)            * save registers used in trap 15 call
* a1 is already points at the null terminated message
        move.b #14,d0               * send message without CR LF
        trap #15
        movem.l (sp)+,d0            * restore registers
* no need to wait for string transmission done because RegASCII is not reused immediately
*  The label for RegASCII needs to be output first, trap #15 task 14 checks for transmit
*  done before transmit next string.	
         move.l (a0),d0             
	bsr reg2ascii		* convert d0 to ASCII equivalent
         movem.l a1,-(sp)           * save registers used in trap 15 call
         lea RegASCII,a1            * sign on message
         move.b #14,d0              * send message without CR LF
         trap #15
         movem.l (sp)+,a1           * restore registers	
	rts
	
do_mm:	
	and.l #$FFFFFFFE,cmdparam	* make sure address is even
	move.l cmdparam,a0	* this is starting address to be modified
	cmp.b #0,cCmdparam
	beq do_mm8		* no parameter, exit with error prompt
	cmp.b #2,cCmdparam	* one or two parameters
	bgt do_mm8		* more than two parameters, exit with error prompt
	move.b #0,bAnswer+15	* modify the bAnswer message string so not to print prompt
	cmp.b #1,cCmdparam
	beq do_mm3		* do memory modify submenu
	move.w cmdparam+6,(a0)	* modify the address with word size data, 
				* discard the upper word
	move.w (a0),d0		* read back and display
	move.l a0,d1
	bsr compuAnswer
        movem.l a1,-(sp)            * save registers used in trap 15 call
        lea bAnswer,a1              * sign on message
        move.b #14,d0               * send message without CR LF
        trap #15
        movem.l (sp)+,a1            * restore registers	
	clr.l d0		         * signal regular prompt
	clr.b exitCode		** normal exit
	bra do_mm9x	
do_mm8:
	moveq.l #1,d0		* signal error prompt
	move.b #1,exitCode	** exit with error prompt
do_mm9x:	
	bsr iBuffer		* restore the bAnswer buffer
	bra do_mm9y
do_mm3:
* interactive session, period (.) to end session, minus (-) to go back, CR for next address
	move.b #':',bAnswer+15	* add a colon to prompt for new value
	move.b #0,bAnswer+16	* terminate string after colon
do_mm4:
	move.w (a0),d0		* read memory and display
	move.l a0,d1		* d1 contains the address
	bsr compuAnswer		* 
        movem.l a1,-(sp)            * save registers used in trap 15 call
        lea bAnswer,a1              * sign on message
        move.b #14,d0               * send message without CR LF
        trap #15
        movem.l (sp)+,a1            * restore registers	
        bsr enableNextCmd           * get ready for a new command
	move.b #1,sInteractive	* set the mm command interactive session flag
	move.l a0,mmaddress	* save the address for next interactive session
	move.l #2,d0		* signal interactive session in progress
do_mm9y:
	move.b #1,fCmdDone	* flag the command is finished
	rts			
do_mr:
	movem.l d0-d7/a0-a7,savd0	* capture current register values
do_bp_mr:			* entry point for mr command in breakpoint handler
				* register array is already saved
	cmp.b #2,cCmdparam	* expect one or two parameters
	bhi do_mr8
	cmp.b #0,cCmdparam	* if no parameter, exit with error prompt
	beq do_mr8
	move.l cmdparam,d2	* get the parameter
	cmp.l #$a0,d2		* $a0 <= parameter <= $a7
	blo do_mr8
	cmp.l #$a7,d2
	bhi do_mr_dx		* check for $d0-$d7
	sub.l #$a0,d2
	move.l d2,d3
	mulu.w #RegStrLen,d3	* compute string array address offset
	lsl.l #2,d2		* compute register array offset
	lea savA0,a0		* offset from address register 0
	lea regA0(pc),a1	* array base is address register 0 string
	bra do_mr2
do_mr_dx:
	cmp.l #$d0,d2		* $d0 <= parameter <= $d7
	blo do_mr8		* exit with error prompt
	cmp.l #$d7,d2
	bhi do_mr8
	sub.l #$d0,d2
	move.l d2,d3
	mulu.w #RegStrLen,d3	* compute string array address offset
	lsl.l #2,d2		* compute register array offset
	lea savD0,a0		* array base is the data register 0
	lea regD0(pc),a1	* array base is the data register 0 string
do_mr2:
	adda.l d2,a0		* compute correct offset from base
	adda.l d3,a1		* compute correct string to display
	cmp.b #1,cCmdparam	* if one parameter, go to interactive session
	beq do_mr3
	move.l cmdparam+4,(a0)	* modified the specified register
	bsr do_dr_reg
	bra do_mr9
do_mr3:
* interactive session, period (.) to end session, minus (-) to go back, CR for next address
	move.b #':',nullchar	* replace first null character with colon prompt
do_mr4:
	bsr do_dr_reg
        bsr enableNextCmd          * initialize for new command
	bsr wUserInput		* wait for fDoCmd flag
	tst.b cCmd		* if just CR, examine/modify next register
	beq do_mr7
	cmp.b #'.',bCmdline	* period terminate the session
	beq do_mr9i
	cmp.b #'=',bCmdline	* = re-display the same register
	beq do_mr4
	cmp.b #' ',bCmdline	* no blank allow
	beq do_mr8i
	cmp.b #'-',bCmdline	* minus go back one register
	bne do_mr5
	cmp.l #savd0,a0		* make sure we are within the register array
	beq do_mr4		* don't go back one register if already register d0
	suba.l #4,a0
	suba.l #RegStrLen,a1
	bra do_mr4
do_mr5:
* cCmd may be 0 - 8.  If 0, advanced to next address, else write data to current
* register and advnced to next address.  exit session with error prompt if illegal value	
	cmp.b #8,cCmd		* no more than 8 characters should be entered
	bgt do_mr8i
	move.b cCmd,d3		* d3 is loop counter
	ext.w d3
	sub.w #1,d3		* this is the actual loop count
	clr.l d2		         * d2 contains the new value for register
	move.l a1,a2		* save copy of a1
	lea bCmdline,a1
do_mr6:
	move.b (a1)+,d0		* accumulate value one nibble at a time
	bsr asc2hex
	cmp.b #$FF,d0		* exit interactive session if illegal hex value
	beq do_mr8i
	lsl.l #4,d2
	add.b d0,d2
	dbra d3,do_mr6
	move.l a2,a1		* restore original a1
	move.l d2,(a0)		* write new value into current register
do_mr7:
	cmp.l #savpc,a0		* don't increment beyond pc register
	beq do_mr4
	adda.l #4,a0		* bump to next register array
	adda.l #RegStrLen,a1	* bump to next message array
	bra do_mr4
do_mr8i:
* Interactive command consumed in this session, don't carry into next command
        bsr enableNextCmd          * initialize for new command	
	bra do_mr8
do_mr9i:
* Interactive command consumed in this session, don't carry into next command
        bsr enableNextCmd          * initialize for new command
do_mr9:
	tst.b fdobkpt		* check for breakpoint in progress
	bne do_mr9y		* skip over the save register array if 
				* executing from breakpoint service routine
	movem.l savd0,d0-d7/a0-a7	* copy save registers back to real registers
do_mr9y:
	move.b #0,nullchar	* restore the null terminator for normal use
	clr.l d0
	clr.b exitCode		** normal exit
	bra do_mr9x
do_mr8:
	moveq.l #1,d0
	move.b #1,exitCode	** exit with error prompt
do_mr9x:
	move.b #1,fCmdDone	* flag the command is finished
	rts			
do_go:
* if no parameter, use the save register array
	cmp.b #0,cCmdparam	* if no parameter, use the save register array
	beq do_go6
	cmp.b #2,cCmdparam	* 2 parameters means breakpoint on the 2nd parameter location
	beq do_go2
	cmp.b #1,cCmdparam	* 1 parameter is the address
	bne do_go8
do_go3:
	and.l #$FFFFFFFE,cmdparam	* make sure address is even
	move.l cmdparam,a0
	jsr (a0)
	bra do_go7
do_go2:
	tst.l bkptaddr			* check if valid breakpoint already exists
	bne do_go8x
	and.l #$FFFFFFFE,cmdparam+4	* make sure the breakpoint address is even
	move.l cmdparam+4,bkptaddr	* save the breakpoint address
	move.l cmdparam+4,a0
	move.l (a0),bkptinstr		* save the instruction
	move.w #$48FC,(a0)		* insert illegal instruction
	cmp.w #$48FC,(a0)		* verify breakpoint inersertion successful
	bne do_bp8x
	bra do_go3	
do_go6:
* abandon the idea of setting up register array with certain set of value and go
* this is something that can be done interactively during breakpoint and trace
* this function is used exclusively to support S record loading with starting address
	move.l savpc,a0			* except a0
	jsr (a0)
do_go7:
	move.l d0,savd0		* display returned value of d0
	lea savd0,a0
	lea procdonemsg(pc),a1
	bsr do_dr_reg		* display process terminated message
	move.l savd0,d0		* restore the returned value of d0
	bra do_go9x
do_go9:
	clr.l d0
	clr.b exitCode		** normal exit
	bra do_mr9x
do_go8x:
        lea badgomsg(pc),a1          * sign on message
        move.b #14,d0               * send message without CR LF
        trap #15
do_go8:
	moveq.l #1,d0
	move.b #1,exitCode	** exit with error prompt
do_go9x:
	move.b #1,fCmdDone	* flag the command is finished
	rts
do_bp:
* breakpoint insert/display/clear
* no parameter display the current breakpoint, one parameter swap out the word in specified
*  address with illegal instruction.  bp 0 clear breakpoint
	cmp.b #0,cCmdparam	* no parameter means display breakpoint
	beq do_bp5
	cmp.b #1,cCmdparam	
	bne do_bp8
	tst.l cmdparam		* if parameter is zero, restore breakpoint
	beq do_bp3
	and.l #$FFFFFFFE,cmdparam	* make sure address is even
	move.l cmdparam,a0
	move.l cmdparam,bkptaddr	* update the breakpoint address
	move.w (a0),bkptinstr		* save the original instruction
	move.w #$48FC,(a0)		* insert illegal instr to specified location
	cmp.w #$48FC,(a0)		* verify insertion successful
	bne do_bp8x
	bra do_bp6			* display breakpoint
do_bp3:
	tst.l bkptaddr			* if no breakpoint found, display no breakpoint message
	beq do_bp7
	move.l bkptaddr,a0		* address of the original instruction
	move.w bkptinstr,(a0)		* restore original instruction
	lea bkptaddr,a0
	lea bpremovemsg(pc),a1		* display the breakpoint removed message
	bsr do_dr_reg
	clr.l bkptaddr			* no breakpoint exists
	bra do_bp9
do_bp5:	
	tst.l bkptaddr			* check if valid breakpoint exists
	beq do_bp7
do_bp6:
	lea bkptaddr,a0
	lea bkptmsg(pc),a1		* print display current breakpoint
	bsr do_dr_reg			* a0 is pointed at the address of breakpoint	
	bra do_bp9
do_bp7:
        lea nobpmsg(pc),a1          * sign on message
        move.b #14,d0               * send message without CR LF
        trap #15	
do_bp9:
	clr.l d0
	clr.b exitCode		** normal exit
	bra do_mr9x
do_bp8x:
* unable to insert breakpoint
	clr.l bkptaddr		* remove breakpoint
        lea badbpmsg(pc),a1          * sign on message
        move.b #14,d0               * send message without CR LF
        trap #15
do_bp8:
	moveq.l #1,d0
	move.b #1,exitCode	** exit with error prompt
do_bp9x:
	move.b #1,fCmdDone	* flag the command is finished
	rts

do_help:
         lea helpmsg(pc),a1         * A1 points at the help message
         move.b #14,d0              * output null terminated string without LR/CF
         trap #15
	clr.l d0
	clr.b exitCode		** normal exit
	move.b #1,fCmdDone	* flag the command is finished	
	rts
	
mminteractive:
* this is the interactive session for mm command
	move.l mmaddress,a0	* restore address to be modified
	tst.b cCmd		* if just CR, modify next address
	beq mminteract1
	cmp.b #'.',bCmdline	* period terminate the session
	beq mminteract9
	cmp.b #'=',bCmdline	* = re-display the same address
	beq mminteract2
	cmp.b #' ',bCmdline	* no blank allow
	beq mminteract8
	cmp.b #'-',bCmdline	* minus go back one word address
	beq mminteract3
* cCmd may be 0 - 4.  If 0, advanced to next address, else write data to current
* memory and advnced to next address.  exit session with error prompt if illegal value	
	cmp.b #4,cCmd
	bgt mminteract8
	move.b cCmd,d3		* d3 is loop count
	ext.w d3		* get d3 ready for dbra operation
	sub.w #1,d3		* the actual loop count is one less
	clr.l d2		* d2 contains the new data value
	lea bCmdline,a1
mminteract6:
	move.b (a1)+,d0		* accumulate value one nibble at a time
	bsr asc2hex
	cmp.b #$FF,d0		* exit session if illegal hex value
	beq mminteract8
	lsl.l #4,d2
	add.b d0,d2
	dbra d3,mminteract6
	move.w d2,(a0)		* write new data value into current address
mminteract1:	
	add.l #2,a0		* next address location
	bra mminteract2
mminteract3:
	sub.l #2,a0
mminteract2:
	move.w (a0),d0		* read memory and display
	move.l a0,d1		* d1 contains the address
	bsr compuAnswer		* 
        movem.l a1,-(sp)            * save registers used in trap 15 call
        lea bAnswer,a1              * sign on message
        move.b #14,d0               * send message without CR LF
        trap #15
        movem.l (sp)+,a1            * restore registers	
        bsr enableNextCmd          * initialize for new command
	move.l a0,mmaddress	* save the address for next interactive session
	move.l #2,d0		* signal interactive session in progress
	bra mminteract9y	
mminteract8:
	moveq.l #1,d0		* error prompt
	move.b #1,exitCode	** exit with error prompt
	bra mminteract9x
mminteract9:
	clr.l d0		         * normal prompt
	clr.b exitCode		** normal exit
mminteract9x:
	clr.b sInteractive	* interactive session is over
	bsr iBuffer		* restore the bAnswer buffer content
	move.b #1,fCmdDone	* flag the command is finished
mminteract9y:			** return without setting the fCmdDone flag
				** session not over
* Interactive command consumed in this session, don't carry into next command
        bsr enableNextCmd          * initialize for new command
	rts
	
do_du:	
* display specified lines of data in hex and ascii
* each line is 16 bytes of data in the format:
* address hex data (16x) ascii-equivalent
* 01234560 00 01 02 03 04 05 06 07 08 09 31 11 12 13 14 32  .........1.....2
	and.l #$FFFFFFF0,cmdparam	* make sure address is on 16-byte boundary
	move.l cmdparam,a2		* starting address to dump data
	cmp.b #1,cCmdparam		* expect 1 or 2 parameters
	blt do_du8		* if lesser than 1 parameter, exit with error
	beq do_du3
	cmp.b #2,cCmdparam	* if 2, load the line count
	bgt do_du8		* error if greater than 2 parameters
	move.l cmdparam+4,d3	* d3 is line count
	bra do_du2
do_du3:
* display one line of data
	pea CRLF(pc)		* pc-relative address of CRLF message
	move.l (sp)+,a1		* 
	move.b #14,d0		* output null-terminated string with task 14
	trap #15
	move.l a2,d0		* display the address value
	bsr reg2ascii		* convert to ASCII and store in RegASCII buffer
	lea RegASCII,a1		* output content of RegASCII
	move.b #14,d0		* using trap #15, task 14
	trap #15
	move.l a2,a3		* save a2
	lea bByteAns,a0		* point to bByteAns buffer for printing
	move.w #15,d2		* do 16 bytes of data
do_du4:
	move.b (a2)+,d0		* fetch data
	bsr hex2asc
* trap #15 task #14 ensures the previous string is finished transmission before	submit
* next string for output.  It does not check the string is done transmitting before return
* So if the same string buffer is to be used repeatly, the calling routine must make sure
* the data in the string buffer is already consumed before putting in new data.  Otherwise
* the new data may overwritten the data waiting to be transmitted.  
* fTxDone is the mechanism to make sure string is consumed
wBufDu:
	cmp.b #True,fTxDone	* wait for the previous string is transmitted before 
	bne wBufDu		*   writing new data
* 68000 can not handle misaligned word write, so do this in two byte writes
         move.b d0,2(a0)            * write lsb first to print buffer
         lsr.w #8,d0                * shift the msb of word into lower byte
         move.b d0,1(a0)            * write the msb to print buffer
	move.l a0,a1		* output null-terminated string with trap 15, task 14
	move.b #14,d0
	trap #15
	dbra d2,do_du4		* do a line of 16 data
wBufDu1:
	cmp.b #True,fTxDone	* wait for the previous string is transmitted before 
	bne wBufDu1		*   writing new data
* 68000 can not handle misaligned word write, so do this in two byte writes
         move.b #$20,1(a0)          * put a space in print buffer
         move.b #$20,2(a0)          * put another space in print buffer 
	move.l a0,a1		* output null-terminated string with trap 15, task 14
	move.b #14,d0
	trap #15
	move.w #15,d2		* display 16 hex as ascii characters on the same line
do_du7:
	move.b (a3)+,d1
	and.b #$7F,d1		* print 7-bit ASCII character set
	cmp.b #$7f,d1		* 'del' character is not printable
	bne do_du5
	move.b #'.',d1		* replace 'del char with '.'
do_du5:
	cmp.b #$20,d1		* anything lesser than 0x20 is not printable
	bge do_du6
	move.b #'.',d1
do_du6:
	move.b #6,d0		* output single ascii character in d1.b with trap 15 task 6
	trap #15
	dbra d2,do_du7
do_du2:
	dbra d3,do_du3		* do the specified number of lines
	clr.l d0		         * signal regular prompt
	clr.b exitCode		** normal exit
	bra do_du9x
do_du8:	
	moveq.l #1,d0		* signal error prompt
	move.b #1,exitCode	** exit with error prompt
do_du9x:
	move.b #1,fCmdDone	* flag the command is finished
	rts
	
do_bo:
* boot CP/M 68K from compact flash
* The program is stored starting from Logical Address 1
* copy program into $15000 to $20000 and then jump into $15000
CFdata   equ $FFE000       * CF data register
CFerr    equ $FFE002       * CF error reg
CFsectcnt equ $FFE005      * CF sector count reg
CF07     equ $FFE007       * CF LA0-7
CF815    equ $FFE009       * CF LA8-15
CF1623   equ $FFE00B       * CF LA16-23
CF2427   equ $FFE00D       * CF LA24-27
CFstat   equ $FFE00F       * CF status/command reg
         lea bootCPM(pc),a1         * print boot CPM message
         move.b #14,d0              * print without adding CRLF
         trap #15    
         lea $15000,a2              * clear memory from $15000-$20000
         move.w #$b000/4-1,d6       * ($20000-$15000)/4-1
clrmembo:
         move.l #0,(a2)+            * clear memory
         dbra d6,clrmembo
         clr.l d5                   * d5 is checksum of CP/M-68K code      
         move.l #$40000001,LA2427   * select logical addressing mode, start from LA 1        
         move.b LA2427,CF2427       * write logical address
         move.b LA1623,CF1623
         move.b LA815,CF815
         move.b LA07,CF07           * least significant address bits
         lea $15000,a2               * CP/M 68K starts from $15000 to $20000
         move.w #$58-1,d6            * total number of sectors is 0x58
nextsect:
         bsr readCF
         add.l #1,LA2427            * next logical address
         move.b LA2427,CF2427       * write logical address
         move.b LA1623,CF1623
         move.b LA815,CF815
         move.b LA07,CF07           * least significant address bits
         dbra d6,nextsect
endreadCF:
         lea $15000,a2              * point to first line of CPM         
         cmp.l #$4ef90001,(a2)+     * is the first two long words correct?
         bne badCPM
         cmp.l #$50504ef9,(a2)
         bne badCPM
         lea crcCPM(pc),a1          * print checksum accumulated in d5
         move.b #14,d0              * print string without adding CRLF
         trap #15
         bsr wTxDone                * finish sending message out
         move.l d5,d0               * print content of d5
         bsr TxRegD0
         lea runCPM(pc),a1          * print execute CP/M message
         move.b #14,d0              * print string without adding CRLF
         trap #15 
	bsr wTxDone                * finish sending message out before start CPM
         jmp $15000                 * start CP/M will not return
badCPM:   
         lea noCPM(pc),a1           * print CP/M code does not exist
         move.b #14,d0              * print string without adding CRLF
         trap #15
do_bo9:
	moveq.l #1,d0		* signal error prompt
	move.b #1,exitCode	** exit with error
	move.b #1,fCmdDone	* flag the command is finished
         rts       
readCF:         
* read a sector of CF data, accumulate checksum in d5
         move.l d7,-(sp)            * save d7
         move.l #0,d7               * clear d7
         move.b #1,CFsectcnt        * read one sector count
         move.b #$20,CFstat         * read sector command

chkdrq:
         btst.b #3,CFstat          * check data request bit set before reading
         beq chkdrq        
         move.w #$ff,d2            * read 512 bytes
readCF1:
         move.w CFdata,d7           * get data and put in destination
         move.w d7,(a2)+
         add.l d7,d5                * accumulate checksum
         dbra d2,readCF1
         move.l (sp)+,d7            * restore d7
         rts
do_sw:
* move monitor program from $400 to $FE8000 and jump into $FE8000.  This frees up the space
* in $400 so a updated monitor can be loaded and check out.
* Check to make sure sw has not executed already.
* change exception table to point to $FE8000
* copy relocatable code from $400 to $8000
         cmp.l #$400,4              * Is reset location equal to 0x400?
         bne do_sw8                 * if not, already switched, exit with error message
         pea switchmsg(pc)          * output
         move.l (sp)+,a1            * output null-terminated string with trap 15, task 13
         move.b #13,d0
         trap #15
         lea $400,a0                * current monitor code
         lea $FE8000,a1             * destination of the swiched monitor code
         move.w #$1f00-1,d2         * copy $1f00-1 long words
do_sw2:
         move.l (a0)+,(a1)+         * copy code from $400 to $FE8000
         dbra d2,do_sw2	
         lea 4,a0                   * modify exception table to point to $FE8000
         move.w #$100-2,d2          * copy $100-2 long words (loc 0 is not copied)
do_sw3:
         add.l #$fe7c00,(a0)+       * adjust exception vectors
         dbra d2,do_sw3
         bsr wTxDone       * wait for transmission done before jump into $FE8000
         jmp $FE8000       * restart the monitor, no return to here         

do_sw8:
         pea switchedmsg(pc)        * monitor already switched to $FE8000, do nothing
         move.l (sp)+,a1            * output null-terminated string with trap 15, task 13
         move.b #13,d0
         trap #15
	moveq.l #1,d0		* signal error prompt
	move.b #1,exitCode	** exit with error prompt
	move.b #1,fCmdDone	* flag the command is finished
	rts
* consolidate waiting for string transmission done here to facilitate OS later
wTxDone:
	cmp.b #True,fTxDone	* wait for string transmission done before returning
	bne wTxDone		* OS swap task here
	rts
enableNextCmd:
* These are setup for next command
         move.l #bCmdline,pCmdln  * point to beginning of command line
         clr.b fDoCmd               * clear the command ready flag
         clr.b cCmd                 * clear the command buffer character count
         rts 
wUserInput:
	tst.b fDoCmd		* wait for user input
	beq wUserInput		* OS swap task here
	rts
signon	dc.b $a,$d,'Tiny68kbug',$a,$d,'11/5/17 v0.6, type "he" for help',$a,$d,'> ',0
CRLF	dc.b $a,$d,0
prompt 	dc.b $a,$d,'> ',0
qprompt	dc.b $a,$d,'?> ',0
zmemmsg	dc.b $a,$d,'register memory cleared',$a,$d,'> ',0
berrmsg	dc.b $a,$d,'Bus Error!',$a,$d,'Faulted address is: ',0
illegalmsg dc.b $a,$d,'Illegal instruction at: ',0
pcmsg	dc.b $a,$d,'Program counter is: ',0
addrerrmsg dc.b $a,$d,'Address Error!',$a,$d,'Faulted address is: ',0
badgomsg dc.b $a,$d,'Breakpoint already in use, unable to execute go to breakpoint',0
runSrecord dc.b $a,$d,'Valid S record received, executing from starting address',0
rundoneSR dc.b $a,$d,'S record execution completed',0
procdonemsg dc.b $a,$d,'Process completed.  Reg D0 returns: ',0
bootCPM  dc.b $a,$d,'Copying CP/M 68K from Compact Flash...',0
crcCPM   dc.b 'checksum is ',0
noCPM    dc.b $a,$d,'no valid CP/M code, command cancelled',0
runCPM   dc.b $a,$d,$a,$d,'CP/M-68K V1.3 COPYRIGHT (C) 1982, 1984, 1985 Digital Research',$a,$d,0
switchedmsg dc.b $a,$d,'Already switched, monitor is currently at $FE8000',0
switchmsg dc.b $a,$d,'Switch monitor to $FE8000 and start monitor execution at $FE8000',0
helpmsg dc.b $a,$d,'Commands are in lower case, <>optional, []mandatory'
	dc.b $a,$d,'dm [address] <count>'
	dc.b $a,$d,'dr <a|d|a0-a7|d0-d7>  Display all registers if no parameter'
	dc.b $a,$d,'mm [address] <value>  If only address entered, a submenu will follow:'
	dc.b $a,$d,'      . terminates submenu session',$a,$d,'      - go back one word address'
	dc.b $a,$d,'      [value] modify current address and display next address'
	dc.b $a,$d,'      CR not modify current address but display next address'
	dc.b $a,$d,'mr [a0-a7|d0-d7] <value>  If only register entered, a submenu will follow:'
	dc.b $a,$d,'      . terminates submenu session',$a,$d,'      - go back one register'
	dc.b $a,$d,'      [value] modify current register and display next register'
	dc.b $a,$d,'      CR not modify current register but display next register'
	dc.b $a,$d,'go <from_addr> <to_addr> If no address specified, use save register values'
	dc.b $a,$d,'bp <addr>  If no address specified, display current break point'
	dc.b $a,$d,'      special case: bp 0 removes breakpoint'
	dc.b $a,$d,'du [address] <line count> dump specified number of lines'
	dc.b $a,$d,'sw switch monitor to $FE8000 and start execution at $FE8000'
         dc.b $a,$d,'bo boot CP/M 68K from compact flash',0

bphelpmsg dc.b $a,$d,'dm [address] <count>'
	dc.b $a,$d,'dr <a|d|a0-a7|d0-d7>  Display all registers if no parameter'
	dc.b $a,$d,'mm [address] <value>  If only address entered, a submenu will follow:'
	dc.b $a,$d,'      . terminates submenu session',$a,$d,'      - go back one word address'
	dc.b $a,$d,'      [value] modify current address and display next address'
	dc.b $a,$d,'      CR not modify current address but display next address'
	dc.b $a,$d,'mr [a0-a7|d0-d7] <value>  If only register entered, a submenu will follow:'
	dc.b $a,$d,'      . terminates submenu session',$a,$d,'      - go back one register'
	dc.b $a,$d,'      [value] modify current register and display next register'
	dc.b $a,$d,'      CR not modify current register but display next register'
	dc.b $a,$d,'gt <addr>  Set a breakpoint at specified address and resume program execution'
	dc.b $a,$d,'      if no address specified, resume normal program execution'
	dc.b $a,$d,'bp <addr>  If no address specified, display current break point'
	dc.b $a,$d,'      special case: bp 0 removes breakpoint'
	dc.b $a,$d,'tr <count>  Trace instruction execution <count> times'
	dc.b $a,$d,'      if no parameter specified, trace one instruction'
	dc.b $a,$d,'vb  Toggle verbose mode on or off'
	dc.b $a,$d,'[carriage return] trace one instruction',0
	
q_no_cr	dc.b '?',0
bpprompt dc.b $a,$d,'BP> ',0	* prompt used in breakpoint session
bpqprompt dc.b $a,$d,'BP?> ',0
bppromptnc dc.b ' BP>',0	         * prompt without carriage return.
nobpmsg	dc.b $a,$d,'No breakpoint specified',0
badbpmsg dc.b $a,$d,'Unable to insert breakpoint',0
bkptmsg dc.b $a,$d,'Breakpoint at: ',0
bpremovemsg dc.b $a,$d,'Breakpoint removed from: ',0
tracemsg dc.b $a,$d,'Trace --> Next instr:',0
tracepcmsg dc.b ' at addr:',0
tracestmsg dc.b ' current Status:',0
verbosemsg dc.b $a,$d,'Verbose mode is On',0
simplemsg dc.b $a,$d,'Verbose mode is Off',0				
regD0	dc.b $a,$d,'Register D0: ',0
regD1	dc.b $a,$d,'Register D1: ',0
regD2	dc.b $a,$d,'Register D2: ',0
regD3	dc.b $a,$d,'Register D3: ',0
regD4	dc.b $a,$d,'Register D4: ',0
regD5	dc.b $a,$d,'Register D5: ',0
regD6	dc.b $a,$d,'Register D6: ',0
regD7	dc.b $a,$d,'Register D7: ',0
regA0	dc.b $a,$d,'Register A0: ',0	
regA1	dc.b $a,$d,'Register A1: ',0
regA2	dc.b $a,$d,'Register A2: ',0
regA3	dc.b $a,$d,'Register A3: ',0
regA4	dc.b $a,$d,'Register A4: ',0
regA5	dc.b $a,$d,'Register A5: ',0
regA6	dc.b $a,$d,'Register A6: ',0
regA7	dc.b $a,$d,'Register A7: ',0
regPC	dc.b $a,$d,'Program Counter (for "go" command use only): ',0	*PC had different length
regD0short dc.b $a,$d,'D0: ',0
regD1short dc.b '  D1: ',0
regD2short dc.b '  D2: ',0
regD3short dc.b '  D3: ',0
regD4short dc.b $a,$d,'D4: ',0
regD5short dc.b '  D5: ',0
regD6short dc.b '  D6: ',0
regD7short dc.b '  D7: ',0
regA0short dc.b $a,$d,'A0: ',0
regA1short dc.b '  A1: ',0
regA2short dc.b '  A2: ',0
regA3short dc.b '  A3: ',0
regA4short dc.b $a,$d,'A4: ',0
regA5short dc.b '  A5: ',0
regA6short dc.b '  A6: ',0
regA7short dc.b '  A7: ',0
regstrlen equ regA7-regA6	* compute the length of each string

	org (*+1)&-2      * force word alignment
******************* subroutines*************************
*
* initialize the various buffers
*
* clear a chunk of RAM area as pointed by a5
clrRAMa5:
	movem.l d0/a5,-(sp)	* save
	move.w #$1000,d0		* clear a 16K block
clrRAM0:
	clr.l (a5)+
	dbra d0,clrRAM0
	movem.l (sp)+,d0/a5	* restore
	rts
*
* clear the saved register area in the system RAM
clrsavr:
	lea savd0,a0		* savd0 is the beginning of register block
	move.w #16,d0		* 17 registers total
clrsavr0:
	clr.l (a0)+
	dbra d0,clrsavr0
	clr.w (a0)+		* this clear the exception counter
	lea $FE0000,a5		* $FE0000 to FE3FFF is diagnostic area
	bsr clrRAMa5
	rts
iBuffer:
	move.b #$a,bAnswer	* start with LF, CR
	move.b #$d,bAnswer+1
	move.b #':',bAnswer+10	* separator
	move.b #$a,bAnswer+15
	move.b #$d,bAnswer+16
	move.b #'>',bAnswer+17
	move.b #' ',bAnswer+18
	move.b #0,bAnswer+19	* zero terminator
	rts

*
* initialize the DUART 68692, only lower byte is connected to data bus d0-d7
**HH 10/25/17 enable hardware handshake of serial port A
iDUART:
*	move.b #$13,MRA		* write to MR1A as follow:
			* no RxRTS, RxRDY int, Char error, no parity, 8 bits
	move.b #$93,MRA		* write to MR1A as follow:
			**HH RxRTS, RxRDY int, Char error, no parity, 8 bits
*	move.b #$07,MRA		* now write to MR2A as follow:
			* normal, no TxRTS, no CTS, 1 stop
	move.b #$17,MRA		* now write to MR2A as follow:
			**HH normal, no TxRTS, CTS, 1 stop
	move.b #$0,IMRD		* mask off interrupt
	move.b #$81,IVRD	* vector number 0x81 is where DUART ISR is located
	move.b #0,OPCR		* make output register general purpose
	move.b #$ff,SETOPR	* clear display
	move.b #$7e,CLROPR	* drive the value '0' on a 7-seg display
	move.b #$70,ACR		* clear ACR[7] bit, timer mode, 16x prescaler
	move.b #$80,CTLR	* to get 10ms interrupt, timer preload value is 0x480
	move.b #$4,CTUR
	move.b #$CC,CSRA	* 38.4K baud
	move.b STOPCTR,d0	* read clear the interrupt bit associated with timer
	move.b #$A,CRA		* disable Chan A transmit and receive
	rts
*
* check for valid ascii representation of hexdecimal
* d0 contains input, return 0xFF if invalid, otherwise hex value
asc2hex:
	cmp.b #'f',d0		
	bhi aschex9		* not valid, >'f'
	cmp.b #'a'-1,d0
	bhi aschex1		* 'f'> valid >'a'
	cmp.b #'F',d0		
	bhi aschex9		* not valid, >'F'
	cmp.b #'A'-1,d0
	bhi aschex3		* 'F'> valid >'A'
	cmp.b #'9',d0
	bhi aschex9		* not valid >'9'
	cmp.b #'0'-1,d0
	bhi aschex2		* '9'> valid >'0'
aschex9:
	move.b #$FF,d0		* return 0xFF in not hex
	bra aschex0
aschex3:
	sub.b #$37,d0
	bra aschex0
aschex2:
	sub.b #$30,d0
	bra aschex0
aschex1:
	sub.b #$57,d0		* 'a'-'f'
aschex0:	
	rts
*
* hex to ascii
* byte value in d0.b is converted to ascii in d0.w
hex2asc:
	movem.l d1,-(sp)
	move.b d0,d1
	lsr.b #4,d1		* get the high nibble first
	add.b #$30,d1
	cmp.b #'9',d1		* '0' to '9'
	bls hex2asc7
	add.b #7,d1		* or 'A' to 'F'
hex2asc7:
	lsl.w #8,d1		* put result in high byte
	move.b d0,d1		* work on the low nibble
	and.b #$F,d1		* isolate low nibble
	add.b #$30,d1
	cmp.b #'9',d1		* '0' to '9'
	bls hex2asc8
	add.b #7,d1		* or 'A' to 'F'
hex2asc8:
	move.l d1,d0		* done
	movem.l (sp)+,d1
	rts
*
* convert content of register d0 into ASCII equivalent and store in RegASCII system buffer
reg2ascii:
	movem.l d1,-(sp)	         * save
	move.l d0,d1	         * save a copy
	rol.l #8,d0	         * do MSB first
	bsr hex2asc
	move.w d0,RegASCII
	move.l d1,d0	         * restore the copy
	swap d0		         * do MUB next
	bsr hex2asc
	move.w d0,RegASCII+2
	move.l d1,d0
	ror.l #8,d0	         * do MLB next
	bsr hex2asc
	move.w d0,RegASCII+4
	move.l d1,d0	         * do LSB last
	bsr hex2asc
	move.w d0,RegASCII+6
	movem.l (sp)+,d1	         * restore
	rts
*
* transmit a null-terminated string pointed by a0
TxStringA0:
	movem.l d0/a0,-(sp)	* save regs
TxStr1:
	btst.b #2,SRA		* look for transmit ready
	beq TxStr1
	move.b (a0)+,d0
	beq Txstr9
	move.b d0,THRA
	bra TxStr1
TxStr9:
	btst.b #2,SRA		* wait for transmit done before restart
	beq TxStr9
	movem.l (sp)+,d0/a0	* restore regs
	rts
*
* transmit the content of d0 register
TxRegD0:
	movem.l d1/d2,-(sp)	* save
	move.w #3,d2
txregd01:
	rol.l #8,d0	         * do the MSB first
	move.l d0,d1	         * save a copy
	bsr hex2asc
	ror.w #8,d0	         * print the high nibble of byte first
	bsr txregd0q			
	bsr txregd0q
	move.l d1,d0
	dbra d2,txregd01
	movem.l (sp)+,d1/d2	* restore
	rts
txregd0q:
	btst.b #2,SRA		* look for transmit ready
	beq txregd0q
	move.b d0,THRA
	ror.w #8,d0
	rts
* form the answer in buffer
* d0 is the value, d1 is the address
* 3/29/17 change to 32-bit address field
compuAnswer:
	movem.l d1/d2,-(sp)	* save 
	move.w d0,d2		* save a copy of d0
	bsr hex2asc
	move.b d0,bAnswer+14	
	lsr.w #8,d0		* get the middle-lowerbyte
	move.b d0,bAnswer+13	* get the LSB byte
	move.w d2,d0
	lsr.w #8,d0
	bsr hex2asc
	move.b d0,bAnswer+12	* do the MSB byte
	lsr.w #8,d0
	move.b d0,bAnswer+11
	move.b d1,d0		* do the address value
	bsr hex2asc
	move.w d0,bAnswer+8	* LSB of address
	lsr.l #8,d1
	move.b d1,d0
	bsr hex2asc
	move.w d0,bAnswer+6	* middle lower byte of address
	lsr.l #8,d1
	move.b d1,d0
	bsr hex2asc
	move.w d0,bAnswer+4	* MUB of address
	lsr.l #8,d1
	move.b d1,d0
	bsr hex2asc
	move.w d0,bAnswer+2	* MSB of address (32-bit address)
	movem.l (sp)+,d1/d2	* restore
	rts
*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
* unexpected exception
* stay here and output values on 7-segment display 
**************  save this for later **********888
unknown:
	add.w #1,cUErr
	movem.l d0-d7/a0-a7,savd0	* save away registers
	move.l $2(sp),savpc
unknown3:
	move.l #77000,d0	* 100ms of spin
unknown1:
	sub.l #1,d0
	bne unknown1
	move.l #154000,d0	* 200ms of red
unknown2:
	sub.l #1,d0
	bne unknown2
	bra unknown3		* never exit here
*
* address error
* stay here and blink light red/green at 1/5 second rate
addrerr:
	add.w #$100,cUErr
	movem.l d0-d7/a0-a7,savd0	* save away registers
	move.l $A(sp),savpc

	lea addrerrmsg(pc),a0
	bsr TxStringA0
	move.l 2(sp),d0		* print the access address
	bsr TxRegD0
	lea pcmsg(pc),a0	         * print program counter
	bsr TxStringA0
	move.l $a(sp),d0
	bsr TxRegD0
	bra unknown		* blink lights forever
*
* Use illegal instruction as breakpoint.  original instruction is stored in bkptinstr
* 
breakpt:
	movem.l d0-d7/a0-a7,savd0	* save all registers
	move.l 2(sp),d0		* get the breakpoint address
	cmp.l bkptaddr,d0	* if equal, this is the user specified breakpoint
	bne breakpt8
	lea bkptmsg(pc),a1	* print breakpoint message
	lea bkptaddr,a0		* breakpoint location
	bsr do_dr_reg
	tst.b fbpverbose	* if verbose flag is set, display all registers
	bne breakpt1
        movem.l d0/a1,-(sp)         * save registers used in trap 15 call
        lea bppromptnc(pc),a1          * sign on message
        move.b #14,d0               * send message without CR LF
        trap #15
        movem.l (sp)+,d0/a1         * restore registers	
	bra breakpt2
breakpt1:	
	bsr displayall
        movem.l d0/a1,-(sp)         * save registers used in trap 15 call
        lea bpprompt(pc),a1          * sign on message
        move.b #14,d0               * send message without CR LF
        trap #15
        movem.l (sp)+,d0/a1         * restore registers
breakpt2:
	move.l 2(sp),a0
	move.w bkptinstr,(a0)	* restore original instruction
	clr.l bkptaddr		* remove breakpoint
	move.b #1,fdobkpt
        bsr enableNextCmd          * initialize for new command
bpcmdloop:
	bsr wUserInput		* wait for user input	
	cmp.b #0,cCmd		* if a carriage return, do one trace instruction
	beq do_crlf
	cmp.b #2,cCmd		* need at least 2 char in command line before
				* a valid CR
	blo badbpcmd
	lea bpmnemonictbl(pc),a0	* point to command mnemonic
	lea bpcommands(pc),a1	* the corresponding command entry point
	move.w bCmdline,d0	* current command
parsebpcmd:
	cmp.w (a0)+,d0		* look for command
	beq bpcmdproc
	add.l #4,a1		* bump to next command
	cmp.w #0,(a0)		* end of mnemonic table?
	beq badbpcmd
	bra parsebpcmd
bpcmdproc:
	bsr cmdreformat
        bsr enableNextCmd          * initialize for new command
	tst.l d0
	bne badbpcmd
	move.l (a1),a1		* get the actual subroutine address in a1
exec_bpcmd:
	jsr *(pc,a1)		* PC relative jsr
	tst.w d0		         * test result to chose the right prompt
	beq nobpcmd
badbpcmd:
        movem.l d0/a1,-(sp)         * save registers used in trap 15 call
        lea bpqprompt(pc),a1          * sign on message
        move.b #14,d0               * send message without CR LF
        trap #15
        movem.l (sp)+,d0/a1         * restore registers	
	bra nobpcmd9
nobpcmd:
        movem.l d0/a1,-(sp)         * save registers used in trap 15 call
        lea bpprompt,a1             * sign on message
        move.b #14,d0               * send message without CR LF
        trap #15
        movem.l (sp)+,d0/a1         * restore registers
nobpcmd9:
        bsr enableNextCmd           * initialize for new command
	bra bpcmdloop
do_crlf:			         * carriage return trace one instruction
	clr.w cTrace
	move.w (sp),d0		* locate the status register of breakpoint exception
	and.w #$3FFF,d0		* enable trace
	or.w #$8000,d0
	move.w d0,(sp)
	bra breakpt9
do_tr:
	clr.w cTrace		* clear the trace count for now
	cmp.b #1,cCmdparam	* expect one parameters
	bhi do_tr8
	cmp.b #0,cCmdparam	* if no parameter, do trace once
	beq do_tr4
	move.w cmdparam+2,cTrace	* trace loop count	
do_tr4:
	move.w 4(sp),d0		* locate the status register for breakpoint
	and.w #$3FFF,d0		* trace every instruction
	or.w #$8000,d0
	move.w d0,4(sp)
	add.l #4,sp		* adjust stack, not returning back to subroutine
	bra breakpt9		* exit breapoint exception with specified trace bits
do_tr8:
	move.l #1,d0		* return to BP session with error prompt
	rts
breakpt8:	
	lea illegalmsg(pc),a0
	bsr TxStringA0
	move.l 2(sp),d0
	bsr TxRegD0
	bsr do_dr1		* display all registers
	bra unknown
do_goto:
	cmp.b #0,cCmdparam	* expect zero or one parameter
	beq do_gt2
	cmp.b #1,cCmdparam
	bne do_tr8		* same error handling as in trace parameter handling
	move.l cmdparam,bkptaddr	* save to bkpt address
	move.l cmdparam,a0
	move.w (a0),bkptinstr	* save the instruction
	move.w #$48FC,(a0)	* insert illegal instruction to specified location
do_gt2:
	move.w 4(sp),d0		* locate the status register for breakpoint
	and.w #$3FFF,d0		* turn trace bits to zero
	move.w d0,4(sp)		* put it back
	add.l #4,sp		* adjust stack, not returning back to subroutine
breakpt9:
        bsr enableNextCmd          * initialize for new command
	clr.b fdobkpt		* clear the breakpoint in progress flag
	movem.l savd0,d0-d7/a0-a7	* restore registers	
	rte	

* BP command dispatch tables
bpcommands:
	dc.l do_dm-exec_bpcmd		* display memory
	dc.l do_bp_dr-exec_bpcmd	* display register
	dc.l do_mm-exec_bpcmd		* modify memory
	dc.l do_bp_mr-exec_bpcmd	* modify register
	dc.l do_goto-exec_bpcmd	* go till next breakpoint
	dc.l do_bp-exec_bpcmd		* breakpoint
	dc.l do_tr-exec_bpcmd		* trace
	dc.l do_vb-exec_bpcmd		* verbose flag
	dc.l do_bphelp-exec_bpcmd	* help message		
* corresponding mnemonic for the breakpoint command table
bpmnemonictbl:
	dc.w 'dm'
	dc.w 'dr'
	dc.w 'mm'
	dc.w 'mr'
	dc.w 'gt'
	dc.w 'bp'
	dc.w 'tr'
	dc.w 'vb'
	dc.w 'he'
	dc.w $0	

***********************BP commands***************************
do_vb:
* toggle the verbose mode, whatever additional parameters are ignored
	tst.b fbpverbose
	bne do_vb2
	lea verbosemsg(pc),a1          * sign on message
        move.b #14,d0               * send message without CR LF
        trap #15	
	move.b #1,fbpverbose	* verbose mode is On
	bra do_vb9
do_vb2:
	move.b #0,fbpverbose	* verbose mode is off
        lea simplemsg(pc),a1          * sign on message
        move.b #14,d0               * send message without CR LF
        trap #15	
do_vb9:	
	clr.l d0
	clr.b exitCode		** normal exit
	move.b #1,fCmdDone	* flag the command is finished
	rts
do_bphelp:
        lea bphelpmsg(pc),a1          * sign on message
        move.b #14,d0               * send message without CR LF
        trap #15
	clr.l d0
	clr.b exitCode		** normal exit
	move.b #1,fCmdDone	* flag the command is finished	
	rts
displayall:
	lea regD0short(pc),a1
	lea savd0,a0
	bsr do_dr_reg
	lea regD1short(pc),a1
	lea savd1,a0
	bsr do_dr_reg
	lea regD2short(pc),a1
	lea savd2,a0
	bsr do_dr_reg
	lea regD3short(pc),a1
	lea savd3,a0
	bsr do_dr_reg
	lea regD4short(pc),a1
	lea savd4,a0
	bsr do_dr_reg
	lea regD5short(pc),a1
	lea savd5,a0
	bsr do_dr_reg	
	lea regD6short(pc),a1
	lea savd6,a0
	bsr do_dr_reg	
	lea regD7short(pc),a1
	lea savd7,a0
	bsr do_dr_reg	
	
	lea regA0short(pc),a1
	lea savA0,a0
	bsr do_dr_reg
	lea regA1short(pc),a1
	lea savA1,a0
	bsr do_dr_reg
	lea regA2short(pc),a1
	lea savA2,a0
	bsr do_dr_reg
	lea regA3short(pc),a1
	lea savA3,a0
	bsr do_dr_reg
	lea regA4short(pc),a1
	lea savA4,a0
	bsr do_dr_reg
	lea regA5short(pc),a1
	lea savA5,a0
	bsr do_dr_reg	
	lea regA6short(pc),a1
	lea savA6,a0
	bsr do_dr_reg	
	lea regA7short(pc),a1
	lea savsp,a0
	bsr do_dr_reg
	rts
	
*
* trace exception handling
* display PC, status, and instruction
trace:
	movem.l d0-d7/a0-a7,savd0	* save all registers
	bsr enableNextCmd          * initialize for new command
trace1:
	lea tracemsg(pc),a0
	bsr TxStringA0		* send out trace message
	move.l 2(sp),a0		* get program counter of instruction
	move.l (a0),d0		* get the instruction being traced
	bsr TxRegD0
	lea tracepcmsg(pc),a0
	bsr TxStringA0		* next line of trace message
	move.l 2(sp),d0
	bsr TxRegD0		* print pc value
	lea tracestmsg(pc),a0
	bsr TxStringA0
	clr.l d0
	move.w (sp),d0
	bsr TxRegD0
	sub.w #1,cTrace		* decrement trace loop count
				* if zero, no more trace, insert breakpoint for next instruction
	bgt trace7
trace5:
	move.w (sp),d0
	and.w #$3FFF,d0		* remove trace
	move.w d0,(sp)		* put back status word
	move.l 2(sp),a0		* breakpoint for next instruction
	move.w (a0),bkptinstr	* save original instruction
	move.w #$48FC,(a0)	* illegal instruction
	move.l 2(sp),bkptaddr	* save away breakpoint address
	bra trace9
trace7:
	tst.b fbpverbose
	beq trace9
	bsr displayall
trace9:
	movem.l savd0,d0-d7/a0-a7
	rte
	
************ EASy68K trap routines *********************         
EASyTrapTbl:	
***** Text I/O *****
	bra.w EASy0
	bra.w EASy1
	bra.w EASy2
	bra.w EASy3
	bra.w EASy4
	bra.w EASy5
	bra.w EASy6
	bra.w EASy7
	bra.w EASy8
	bra.w EASy9
	bra.w EASy10
	bra.w EASy11
	bra.w EASy12
	bra.w EASy13
	bra.w EASy14
	bra.w EASy15
	bra.w EASy16
	bra.w EASy17
	bra.w EASy18
	bra.w EASy19
	bra.w EASy20
	bra.w EASy21
	bra.w EASy22
	bra.w EASy23
	bra.w EASy24
	bra.w EASy25
	bra.w EASy32		* hardware display service
	bra.w EASy80
        bra.w EASy81
        bra.w EASy82
        bra.w EASy83
        bra.w EASy84
        bra.w EASy85
        bra.w EASy86
        bra.w EASy87
        bra.w EASy88
        bra.w EASy89
        bra.w EASy90
        bra.w EASy91
        bra.w EASy92
        bra.w EASy93
        bra.w EASy94
        bra.w EASy95
        bra.w EASy96

******* Graphic ****
	
* not yet implemented trap
EASy2:
EASy3:
EASy4:
EASy9:
EASy10:
EASy11:
EASy15:
EASy16:
EASy17:
EASy18:
EASy19:
EASy20:
EASy21:
EASy22:
EASy23:
EASy24:
EASy25:
EASy80:
EASy81:
EASy82:
EASy83:
EASy84:
EASy85:
EASy86:
EASy87:
EASy88:
EASy89:
EASy90:
EASy91:
EASy92:
EASy93:
EASy94:
EASy95:
EASy96:
	rts

EASyTrap:
* EASy68K trap services
 
	movem.l a3/d0/d3,-(sp)     * save registers
        lea EASyTrapTbl(pc),a3      * a position independ table of trap routines
        cmp.b #25,d0                * modify index if taks # is greater than 25
        ble calcEASyTask
	cmp.b #32,d0		* modify index if task # is 32
	ble calcEASyTask32
        sub.b #54,d0                * modified index for task #80 and up
	bra calcEASyTask
calcEASyTask32:
	sub.b #6,d0
calcEASyTask:
	clr.l d3		         * setup to index into the trap service table
	move.b d0,d3               * d0 contains the index value
	lsl.l #2,d3	         * compute long word offset
	jsr (a3,d3)                * jsr into array of trap routines        
EASyT15z: 
	movem.l (sp)+,a3/d0/d3 * restore register
	rte	
EASy0:
EASy1:
* Task 0: Display n characters of string at (A1), n is D1.W (stops on NULL or max 255) 
*   with CR, LF. 
* Task 1: Display n characters of string at (A1), n is D1.W (stops on NULL or max 255) 
*   without CR, LF. 
* if transmitter is unavailable, wait until it is available
	cmp.b #True,fTxDone	* wait for string transmission done before proceeding
	bne EASy1		* possible OS swap task here
	move.l a1,pStr		* pStr points to the string
	and.w #$ff,d1		* maximum of 255 character to transmit
	move.w d1,cTxChar	         * number of character to transmit
	move.b #False,fTxDone	* start transmission
	clr.b fEASyTCRLF           * assume it is task 1 (no CR LF)
	cmp.b #1,d0               
        beq EASy0z	         * if task 1, don't change CR/LF flag
        move.b #1,fEASyTCRLF        * task 0, add carriage, line feed to the end of message        
EASy0z:
	move.b #1,fTxChar	         * enable transmit in DUART ISR
	move.b #$B,IMRD		* enable Chan A TxRDY/RxRdy interrupts
	rts
EASy5:   
* Read single ASCII character from the keyboard into D1.B
	btst.b #0,SRA		* Does receiver has a char input
	beq EASy5		* wait until it has an input
	move.b RHRA,d1	         * get character into d1.b
	tst.b fEASyTEcho
	bne EASy6                  * echo back char for T15Echo != 0	
	rts	         		    
EASy6:	
* Display single ASCII character in D1.B.
	cmp.b #True,fTxDone	* wait for previous string transmission done
	bne EASy6
	btst.b #2,SRA		* look for transmit ready
	beq EASy6                                 
	move.b d1,THRA             * put char in d1.b out to serial port    
	rts
EASy7:
* Check for keyboard input. Set D1.B to 1 if keyboard input is pending, otherwise set to 0.
* Use task 2 or 5 to read pending key.
        move.b #0,d1       * assume there is no char input
        btst.b #0,SRA      * Does receiver has a char input?
        beq EASy7z
        move.b #1,d1       * A char input is ready
EASy7z:
        rts

EASy8:
* Return time in hundredths of a second since midnight in D1.L. 
	move.l wallclock,d1	* wallclock is increment every 10ms
	rts
EASy12:  
* Keyboard Echo. 
* D1.B = 0 to turn off keyboard echo. 
* D1.B = non zero to enable. (default). 
* Echo is restored on 'Reset' or when a new file is loaded
	move.b d1,fEASyTEcho       * store echo value
        rts
EASy13:
EASy14:
* task 13: Display the NULL terminated string at (A1) with CR, LF.
* task 14: Display the NULL terminated string at (A1) without CR, LF.
* send null terminated string pointed by A1 to console.  No CR, LF added
* if transmitter is unavailable, wait until it is available
	cmp.b #True,fTxDone	* wait for string transmission done before proceeding
	bne EASy14		* possible OS swap task here
	move.l a1,pStr		* pStr points to null-terminated message
	move.b #False,fTxDone	* start transmission
	clr.b fEASyTCRLF           * assume it is task 14 (no CR LF)
	cmp.b #14,d0               
        beq EASy14z	         * if task 14, don't change CR/LF flag
        move.b #1,fEASyTCRLF       * task 13, add carriage, line feed to the end of message        
EASy14z:
	move.b #1,fTxChar	         * enable transmit in DUART ISR
	move.b #$B,IMRD		* enable Chan A TxRDY/RxRdy interrupts
	rts
EASy32:
* 7-segment display service, ignore subtask 0 (hardware display), 5 (enable exception)
* 6 (set auto IRA).
	cmp.b #1,d1		* address of 7-seg display
	beq EASy32a
	cmp.b #2,d1		* address of LEDs
	beq EASy32b
	cmp.b #3,d1		* address of toggle switches
	beq EASy32c
	cmp.b #4,d1		* SIM68K version number
	beq EASy32d
	cmp.b #7,d1		* address of push buttons
	beq EASy32g
	bra EASy32z
EASy32a:
	move.l #corner7seg,d1	* base address of 7-seg display
	bra EASy32z
EASy32b:
	move.l #0,d1	* address of LEDs, none for now
	bra EASy32z
EASy32c:
	move.l #0,d1	* address of toggle switches, none for now
	bra EASy32z
EASy32d:
	move.l #$1,d1		* version number of the trap service
	bra EASy32z
EASy32g:
	move.l #0,d1	* address of push buttons, none for now	
EASy32z:
	rts
************ EASy68K trap routines *********************  	

*
* interrupt service for TxRdyA
* look for timer interrupt first
* look at receive data first and process if needed and shut off background transmit
* then look at transmit data.  If in the middle of transmitting, keep on transmitting
* send next byte as pointed by a2.  When zero is encountered, shut off the transmitter
DUARTisr:
	movem.l d0-d4/a0-a2,-(sp)	* save
	btst.b #3,ISRD		* look for timer interrupt set first
	beq rcvrA
	add.l #1,wallclock	* increment the wallclock, 1 tick equals 10ms
	tst.w downtimer1		* if downtimer is not zero, decrement it
	beq dntimer2
	sub.w #1,downtimer1
dntimer2:
	tst.w downtimer2	* check the 2nd downtimer, if not zero, decrement it
	beq timerisr6
	sub.w #1,downtimer2
timerisr6:
         move.b #$ff,SETOPR         **HH clear the display
	move.b corner7seg,d0	* get the value for the corner 7-seg display
	lsl.b #1,d0		* shift by one bit to conform to EASy68K format
	move.b d0,CLROPR	* put value out to display
timerisr9:
	move.b STOPCTR,d0	* read clear the timer interrupt flag
rcvrA:	
	btst.b #0,SRA		* look at receiver next
	beq chktx		* if no char received, check char to send
	move.b RHRA,d3	* get character
	tst.b cCmd		* if non zero, fill command buffer til CR
	bne getcmdline
	cmp.b #'R',d3
	beq dorwg
	cmp.b #'W',d3
	beq dorwg
	cmp.b #'G',d3
	beq dorwg
	cmp.b #'Z',d3
	beq doz
	cmp.b #'S',d3
	beq doload1
getCmdline:
	cmp.b #$d,d3		* CR terminates the command line
	bne echo_rx		* if not CR, echo back the char entered in the command buffer
	move.b #1,fDoCmd	         * make command ready to execute
	move.l pCmdln,a0
	cmp.b #' ',-1(a0)	* if trailing space, discard the space character
	beq gobackone
	bra edisr1
echo_rx:
	btst.b #2,SRA		* echo back 
	beq echo_rx
	cmp.b #8,d3		* backspace?
	beq echo_rubout
	move.b d3,THRA
	bra chkextrasp
echo_rubout
	move.b #$8,THRA	* try rubout character instead of 0x8, didn't work
	tst.b cCmd		* don't backspace past the first character
	beq what_no_CR		* try this approach, no perfect either
gobackone:
	sub.l #1,pCmdln		* backspace, go back one character
	sub.b #1,cCmd
	bra edisr1		* get next character
chkextrasp:
	move.l pCmdln,a0	         * get pointer into command line buffer
	cmp.b #' ',d3		* if extra space, do not store
	bne fillcmdbuf
	cmp.b #' ',-1(a0)		* if previous is also space
	beq edisr1
fillcmdbuf
	move.b d3,(a0)
	add.l #1,pCmdln		* bump up one character	
	add.b #1,cCmd
	cmp.b #20,cCmd		* up to 20 characters. 
	bne edisr1
what:
	pea qprompt(pc)		* push error prompt pointer into stack
	move.l (sp)+,pStr	         * pStr points to error prompt string
	clr.b fDoCmd		* abort command ready
	clr.b cCmd		* reset command line 
	move.l #bCmdline,pCmdln
	bra txen
what_no_CR:
	pea q_no_cr(pc)		* put a single ? mark
	move.l (sp)+,pStr
	clr.b fDoCmd		* abort command ready
	clr.b cCmd		* reset command line 
	move.l #bCmdline,pCmdln
	bra txen
dorwg:
	btst.b #2,SRA		* echo back character
	beq dorwg
	move.b d3,THRA	         * echo back 'r' or 'w', 'g'
	clr.l d1		         * d1 is the address pointer
	clr.l d4		         * d4 is modified value for write command
	clr.b fWval		* existance of valid value for read/write cmd
* handle read/write the same, but the 2nd parameter has different meaning:
* for read, it indicates how many words to print
* for write, it indicates the modified value
* if 2nd parameter is not present, read the current address and write nothing
sp_1st:
	btst.b #0,SRA		* loop for the 1st space char after command
	beq sp_1st
	move.b RHRA,d0		
	cmp.b #' ',d0
	bne dorwg5		* valid inputs at this point are hex values
	bra echo_chr		* echo back
more_sp:
	tst.b fWval
	bne what		* if fWval already set and ' ' entered print ?>
	move.b #1,fWval		* mark write cmd with valid value
	bra echo_chr		* echo back
get_char:
	btst.b #0,SRA		* look for character
	beq get_char
	move.b RHRA,d0		* check for valid characters
	cmp.b #' ',d0
	beq more_sp		* space is separator for read/write
	cmp.b #$d,d0
	beq dorwg9		* CR also marks the end of command
dorwg5:
	move.b d0,d2		* save a copy
	bsr asc2hex
	cmp.b #$FF,d0		* valid hex?
	beq what		
	tst.b fWval		* r address or w data?
	bne dorwg6
	lsl.l #4,d1		* shift existing value one nibble to left
	add.b d0,d1		* append new address to existing one.
dorwg7:
	move.b d2,d0		* echo back	
echo_chr:
	btst.b #2,SRA
	beq echo_chr
	move.b d0,THRA		* echo back typed char
	bra get_char		* get more data
dorwg6:
	lsl.l #4,d4		* d4 contains the second parameter
	add.b d0,d4
	bra dorwg7
dorwg9:
	and.l #$00FFFFFE,d1	* make sure it is even address and 24-bit addr
	move.l d1,a0
	cmp.b #'W',d3
	beq dowrite
	cmp.b #'G',d3
	beq dorunrun
	tst.w d4		* if d4 equals 0, do one line of display memory
	beq dorwg8
	sub.w #1,d4		* for read cmd, print the number of words specified by d4
dorwg8:
	move.w (a0),d0		* read the specified memory location
	bsr compuAnswer		* forming the answer in buffer
	move.l #bAnswer,pStr	* send out the answer
	cmp.b #'W',d3		* if write cmd, print the memory content outside of ISR
	beq txen		* if read cmd, print number of words specified by d4
	tst.b fwval		* check valid 2nd parameter for read cmd
	beq txen		* if no 2nd parameter, print the memory content outside of ISR
	lea bAnswer,a2
	move.b #0,bAnswer+15	* modify the bAnswer message string so not to print prompt
dorwg8b:
	btst.b #2,SRA		* txRdy
	beq dorwg8b
	move.b (a2)+,d0
	beq dorwg8c
	move.b d0,THRA
	bra dorwg8b	
dorwg8c:
	add.l #2,a0		* next memory content, a0 contains the address value
	move.l a0,d1		* 
	dbra d4,dorwg8		* else print memory content d4 times within ISR
	move.b #$a,bAnswer+15	* replace the prompt back into bAnswer message string
	bra txprompt		* put out a prompt
dorunrun:
	clr.l d0		         * status is passed back in d0
	jsr (a0)		         * jump into whatever address user is entered
	tst.l d0
	bne what
txprompt:
	lea prompt(pc),a0	         * relocatable code
	move.l a0,pStr		* pStr points to prompt string
txen:
	move.b #1,fTxChar	         * enable transmit in DUART ISR
	move.b #$B,IMRD		* enable tx/rx interrupts, enable timer
	bra edisr1		
dowrite:
	tst.b fWval		* chk for valid write value
	beq dorwg8		* don't write if invalid
	move.w d4,(a0)		* write value out
	bra dorwg8		* read back value
* clear memory
doz:
	btst.b #2,SRA		* echo back
	beq doz
	move.b d3,THRA
doz1:
	btst.b #0,SRA		* read next char, must be $0d
	beq doz1
	move.b RHRA,d0
	cmp.b #$d,d0
	bne what
	bsr clrsavr
	lea zmemmsg(pc),a0
	move.l a0,pStr
	bra txen
*
* S record format as generated by qlink, ignore S0
* only echo back '.' per S record. send prompt if OK, send qprompt if error
* S1: byte count, 16 bit address, end with checksum 
* a0 is address, d1 is data, store value as they are received
* d2 is nibble count, d3 is srecord byte count, d4 is accumulated checksum
doload:
	move.w #$2700,sr	* mask off all interrupt so vector table can be
				* modified without crashing the code
	btst.b #0,SRA		* look for another 'S'
	beq doload
	move.b RHRA,d0
	cmp.b #$d,d0		* put out '.' when CR encountered
	bne doload2
	tst.b fSerr		* if error, put out '?'
	beq doload3
	clr.b fSerr
	move.b #1,fSerrAll	* flag S record error in file load
doload3b
	btst.b #2,SRA		* look for tx ready before sending character
	beq doload3b
	move.b #'?',THRA
	bra doload2
doload3:
	btst.b #2,SRA		* look for tx ready before sending char
	beq doload3
	move.b #'.',THRA
doload2:
	cmp.b #'S',d0
	bne doload
doload1:
	btst.b #0,SRA		* look for S1 or exit with ?>
	beq doload1
	move.b RHRA,d0
	cmp.b #'0',d0
	beq doload
	cmp.b #'1',d0		* S1 record?
	beq doS1
	cmp.b #'2',d0		* S2 record?
	beq doS2
	cmp.b #'3',d0		* S3 record?
	beq doS3
	cmp.b #'7',d0		* S7 record?
	beq doS7
	cmp.b #'8',d0		* S8 record?
	beq doS8
	cmp.b #'9',d0		* S9 record?
	beq doS9
	not.b fSerr		* mark the line as error
	bra doload
doS7:
* if the address field is 0, or there are checksum error, exit
* if the address field is non zero, and no checksum error, jump to the specified address
* There are only 5 bytes: 4-byte address and checksum 
	clr.l d4		         * prepare checksum
	move.w #1,d2		* get Srecord byte count
	bsr char2hex
	add.b d1,d4		* accumulate checksum
	cmp.b #5,d1		* should have a length of 5 exactly
	bne doS7x
	move.w #7,d2		* get 4-byte starting address
	bsr char2hex
	add.b d1,d4		* accumulate checksum, low address
	ror.l #8,d1
	add.b d1,d4		* accumulate checksum, mid-low address
	ror.l #8,d1
	add.b d1,d4		* accumulate checksum, mid-high address
	ror.l #8,d1
	add.b d1,d4		* accumulate checksum, msb address
	ror.l #8,d1		* restore original value
	move.l d1,startaddr	* save the start address
	not.b d4		         * checksum expected next
	move.w #1,d2
	bsr char2hex
	cmp.b d1,d4		* compare calculated checksum
	bne doS7x
	tst.b fSerrAll		* check for total error count
	bne doS7x
	bsr wCRquitX		* wait for CR and mark end of SR load before continuing
	tst.l startaddr		* If starting address is 0, return to prompt
	beq doS7y
	lea runSrecord(pc),a0	* notify S record is loaded and running
	bsr TxStringA0		* not using interrupt service to put out string	

* delay 0.1 second before jump into application
	move.l #$30000,d6	* diagnostic
w3abit:
	sub.l #1,d6		* diagnostic
	bne w3abit		* diagnostic

	move.l startaddr,a1	* else jump into the start address
	jsr (a1)			
	lea rundoneSR(pc),a0	* notify that s record execution completed
	bsr TxStringA0	
doS7y:	
	lea prompt(pc),a0	         * relocatable code
	move.l a0,pStr		* pStr points to prompt string
	bra txen
doS7x:
	bsr wCRquitX		* wait for CR and exit SR loader
	pea qprompt(pc)
	move.l (sp)+,pStr
	clr.b fSerrAll
	bra txen	
doS8:
* if the address field is 0, or there are checksum error, exit
* if the address field is non zero, and no checksum error, jump to the specified address
* There are only 4 bytes: 3-byte address and checksum 
	clr.l d4		         * prepare checksum
	move.w #1,d2		* get Srecord byte count
	bsr char2hex
	add.b d1,d4		* accumulate checksum
	cmp.b #4,d1		* should have a length of 4 exactly
	bne doS8x
	move.w #5,d2		* get 3-byte starting address
	bsr char2hex
	add.b d1,d4		* accumulate checksum, low address
	ror.l #8,d1
	add.b d1,d4		* accumulate checksum, mid address
	ror.l #8,d1
	add.b d1,d4		* accumulate checksum, high address
	ror.l #8,d1
	ror.l #8,d1		* restore original value
	move.l d1,startaddr	* save the start address
	not.b d4		         * checksum expected next
	move.w #1,d2
	bsr char2hex
	cmp.b d1,d4		* compare calculated checksum
	bne doS8x
	tst.b fSerrAll		* check for total error count
	bne doS8x
	bsr wCRquitX		* wait for CR and mark end of SR load before continuing
	tst.l startaddr		* If starting address is 0, return to prompt
	beq doS8y
	lea runSrecord(pc),a0	* notify S record is loaded and running
	bsr TxStringA0		* not using interrupt service to put out string	

* delay 0.1 second before jump into application
	move.l #$30000,d6	         * diagnostic
w2abit:
	sub.l #1,d6		* diagnostic
	bne w2abit		* diagnostic

	move.l startaddr,a1	* else jump into the start address
	jsr (a1)			
	lea rundoneSR(pc),a0	* notify that s record execution completed
	bsr TxStringA0	
doS8y:	
	lea prompt(pc),a0	         * relocatable code
	move.l a0,pStr		* pStr points to prompt string
	bra txen
doS8x:
	bsr wCRquitX		* wait for CR and exit SR loader
	pea qprompt(pc)
	move.l (sp)+,pStr
	clr.b fSerrAll
	bra txen	
doS9:
* if the address field is 0, or there are checksum error, exit
* if the address field is non zero, and no checksum error, jump to the specified address
* There are only 3 bytes: 2-byte address and checksum 
	clr.l d4		         * prepare checksum
	move.w #1,d2		* get Srecord byte count
	bsr char2hex
	add.b d1,d4		* accumulate checksum
	cmp.b #3,d1		* should have a length of 3 exactly
	bne doS9x
	move.w #3,d2		* get 2-byte starting address
	bsr char2hex
	add.b d1,d4		* accumulate checksum, lower address
	ror.w #8,d1
	add.b d1,d4		* accumulate checksum, higher address
	ror.w #8,d1		* restore original value
	move.l d1,startaddr	* save the start address
	not.b d4		         * checksum expected next
	move.w #1,d2
	bsr char2hex
	cmp.b d1,d4		* compare calculated checksum
	bne doS9x
	tst.b fSerrAll		* check for total error count
	bne doS9x
	bsr wCRquitX		* wait for CR and mark end of SR load before continuing
	tst.l startaddr		* If starting address is 0, return to prompt
	beq doS9y
	lea runSrecord(pc),a0	* notify S record is loaded and running
	bsr TxStringA0		* not using interrupt service to put out string	
* delay 0.1 second before jump into application
	move.l #$30000,d6	         * diagnostic
w1abit:
	sub.l #1,d6		* diagnostic
	bne w1abit		* diagnostic

	move.l startaddr,a1	* else jump into the start address
	jsr (a1)			
	lea rundoneSR(pc),a0	* notify that s record execution completed
	bsr TxStringA0
doS9y:	
	lea prompt(pc),a0	         * relocatable code
	move.l a0,pStr		* pStr points to prompt string
	bra txen
doS9x:
	bsr wCRquitX		* wait for CR and exit SR loader
	pea qprompt(pc)
	move.l (sp)+,pStr
	clr.b fSerrAll
	bra txen
doS1:
* 2-byte address field
	clr.l d4
	move.w #1,d2		* get Srecord byte count
	bsr char2hex
	add.b d1,d4		* accumulate checksum
	move.w d1,d3
	sub.w #4,d3		* don't count CRC byte nor 2-byte address		
	move.w #3,d2		* get 2-byte starting address
	bsr char2hex
	add.b d1,d4		* accumulate checksum, lower address
	ror.w #8,d1		
	add.b d1,d4		* accumulate checksum, higher address
	ror.w #8,d1		* restore
	move.l d1,a0
srdata:
	move.w #1,d2		* get byte data
	bsr char2hex
	add.b d1,d4		* accumulate checksum
	move.b d1,(a0)		* store value to destination
	cmp.b (a0)+,d1		* write verify
	beq srdatax
	move.b #1,fSerr
srdatax:	
	dbra d3,srdata
	not.b d4		         * checksum expected
	move.w #1,d2
	bsr char2hex
	cmp.b d1,d4
	beq doload
	move.b #1,fSerr		* send out a question mark
	bra doload
doS2:
* 3-byte address field
	clr.l d4
	move.W #1,d2		* get Srecord byte count
	bsr char2hex
	add.b d1,d4		* accumulate checksum
	move.W d1,d3
	sub.W #5,d3		* don't count CRC byte nor 3-byte address		
	move.W #5,d2		* get 3-byte starting address
	bsr char2hex
	add.b d1,d4		* accumulate checksum, lower address
	ror.l #8,d1		
	add.b d1,d4		* accumulate checksum, middle address
	ror.l #8,d1		* 
	add.b d1,d4		* accumulate checksum, upper address
	ror.l #8,d1
	ror.l #8,d1		* restore
	move.l d1,a0
srdata2:
	move.w #1,d2		* get byte data
	bsr char2hex
	add.b d1,d4		* accumulate checksum
	move.b d1,(a0)		* store value to destination
	cmp.b (a0)+,d1		* write verify
	beq srdata2x
	move.b #1,fSerr		* flag if not able to write
srdata2x:
	dbra d3,srdata2
	not.b d4		         * checksum expected
	move.w #1,d2
	bsr char2hex
	cmp.b d1,d4
	beq doload
	move.b #1,fSerr		* send out a question mark
	bra doload	

doS3:
* 4-byte address field
	clr.l d4
	move.w #1,d2		* get Srecord byte count
	bsr char2hex
	add.b d1,d4		* accumulate checksum
	move.w d1,d3
	sub.w #6,d3		* don't count CRC byte nor 4-byte address		
	move.w #7,d2		* get 3-byte starting address
	bsr char2hex
	add.b d1,d4		* accumulate checksum, lsb address
	ror.l #8,d1		
	add.b d1,d4		* accumulate checksum, mid-lower address
	ror.l #8,d1		* 
	add.b d1,d4		* accumulate checksum, mid-upper address
	ror.l #8,d1
	add.b d1,d4		* accumulate checksum, msb address
	ror.l #8,d1		* restore
	move.l d1,a0
srdata3:
	move.w #1,d2		* get byte data
	bsr char2hex
	add.b d1,d4		* accumulate checksum
	move.b d1,(a0)		* store value to destination
	cmp.b (a0)+,d1		* write verify
	beq srdata3x
	move.b #1,fSerr		* flag if not able to write
srdata3x:
	dbra d3,srdata3
	not.b d4		         * checksum expected
	move.w #1,d2
	bsr char2hex
	cmp.b d1,d4
	beq doload
	move.b #1,fSerr		* send out a question mark
	bra doload		
chktx:
	tst.b fTxChar		* is transmit enabled?
	beq edisr1
	btst.b #2,SRA		* look for transmit ready
	beq edisr1		* nothing, exit
	move.l pStr,a0		* load the string pointer
	cmp.w #-1,cTxChar	* use character count to terminate string transmission?
	beq chktx1		* default to not use char count except task 0 & 1
	tst.w cTxChar		* has character count reached zero?
	beq chkfCRLF		* if reached the end, check if need to append CR/LF
	sub.w #1,cTxChar	* transmit a char, reduce char count by 1
chktx1:
	move.b (a0),d0
	bne txNxtChar              * if end of string, check if need to append CR/LF
chkfCRLF:
* null terminator reached, check if need to append CR/LF
        tst.b fEASyTCRLF           * if flag set, add append CR LF to message
        beq edisr                  * no CR LF, transmission completed
* apend a carriage return/line feed string here
	clr.b fEASyTCRLF	* clear the CRLF flag
	move.w #-1,cTxChar	* disable string transmission based on character count
	pea CRLF(pc)		* append the CRLF message
	move.l (sp)+,pStr	* update string pointer
	bra chktx
txNxtChar:
	move.b d0,THRA	* put out the next byte as pointed by a0
	add.l #1,pStr		* update the string pointer
	bra edisr1	
edisr:
	move.w #-1,cTxChar	* disable string transmission based on character count
	move.b #0,fTxChar	* disable transmit in DUART ISR
	move.b #$A,IMRD		* mask off transmit interrupts, enable timer
	move.b #True,fTxDone	* flag transmission of string finished
edisr1:
	movem.l (sp)+,d0-d4/a0-a2	* restore
	rte
* 
* subroutine wait for CR then quit with 'X' output
wCRquitX:
	btst.b #0,SRA		* look for CR and quit
	beq wCRquitX
	move.b RHRA,d0
	cmp.b #$d,d0
	bne wCRquitX
	move.b #'X',THRA
wCRquitX1:
	btst.b #2,SRA		* look for transmit done before returning
	beq wCRquitX1
	rts
*
* subroutine to get prescribed number of characters in d2+1, convert to hex and put in
* d1 
char2hex:
	clr.l d1		         * important to clear all d1 when start
c2h1:
	btst.b #0,SRA
	beq c2h1
	move.b RHRA,d0
	bsr asc2hex
	cmp.b #$FF,d0
	bne c2h1_1
	move.b #1,fSerr		* mark this as an error and go on
c2h1_1:
	lsl.l #4,d1		
	add.b d0,d1		* append to existing value
	dbra d2,c2h1
	rts
*
* Bus error handling
* print "Bus error" in polling mode and return
buserr:
	add.w #$1000,cUErr
	movem.l d0-d7/a0-a7,savd0	* save away registers
	move.l $A(sp),savpc

	lea berrmsg(pc),a0
	bsr TxStringA0
	move.l 2(sp),d0		* print the access address
	bsr TxRegD0
	lea pcmsg(pc),a0	* print PC value
	bsr TxStringA0
	move.l $a(sp),d0
	bsr TxRegD0
	bra unknown		* blink lights forever

	nop			* extra pad
	nop
	
* that's all folks!

	end RAMstart



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~9~
