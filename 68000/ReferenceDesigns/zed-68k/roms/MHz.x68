*************************************************************************************
*														*
*	MHz benchmark for the EASy68k simulator	2004/4/4					*
*														*
*	This code attempts to guage the effective 68000 clock speed in MHz. This	*
*	is not a serious benchmark test as there are too many factors to take into	*
*	account when running in a multitasking environment. This is demonstrated	*
*	by the, sometimes wildly, varying results.						*
*														*
*	A 1.8GHz PIII system gives results that vary around 16MHz				*
*														*
*	More 68000 and other projects can be found on my website at ..			*
*														*
*	 http://mycorner.no-ip.org/index.html							*
*														*
*	mail : leeedavison@googlemail.com								*
*														*
*************************************************************************************

*************************************************************************************
* code start.

	ORG		$1000			* set origin

start
	LEA		(LAB_MMHz,PC),a0	* get pointer to "Too fast!",[CR][LF]
	MOVEQ		#-$80,d7		* set initial mask for 128 100ths, this is the
						* q value used later in the speed calculations

* this is the code that is used to gauge the speed of the CPU. the longer this
* code runs the more accurate the result will be but the user will eventually
* get bored and walk away, so the code can't run for too long. in this case it
* runs for up to about four seconds depending on when it starts and how fast
* the simulated processor runs. If you know that the count loop will overflow
* the initial value of d7 can be set to take this into account. This will produce
* results more frequently. e.g. if you know the loop count will overflow the first
* time then use ..

*	MOVEQ		#-$C0,d7		* set initial mask for 64 100ths...

* first setup the timing variables

LAB_time
	MOVE.l	d7,d2			* copy mask
	MOVEQ		#0,d3			* clear n counter
	MOVEQ		#0,d4			* clear m counter

* now wait for the start of the next q time period

	MOVEQ		#8,d0			* get 100ths of a second since midnight
	TRAP		#15
	AND.l		d1,d2			* mask and copy q 100ths
LAB_1_wait
	MOVEQ		#8,d0			* get 100ths of a second since midnight
	TRAP		#15			*
	AND.l		d7,d1			* mask q 100ths
	CMP.l		d1,d2			* compare with last q 100ths
	BEQ.s		LAB_1_wait		* wait more if not yet changed

* now loop and count until the next q time period

	MOVE.l	d1,d2			* [4] copy q 100ths
LAB_1_count
	ADDQ.w	#1,d3			* [8] increment counter
	BCC.s		LAB_1_ccc		* [10/.] branch if no overflow

* if there is an overflow here then the period over which the count is done needs to
* be reduced. this is done by shifting the mask in d7 and re-running the code from the
* start. for this reason the /.] part of the branch timing, and that for this section,
* never needs to be taken into account

	ASR.b		#1,d7			* effectively divide the measure time (q) by 2
	BCS		LAB_speederror	* branch if simulator is too fast to time
						* this will happen at approximately 380MHz simulated

	BRA.s		LAB_time		* go re-run the code

LAB_1_ccc
	MOVEQ		#8,d0			* [4] get 100ths of a second since midnight
	TRAP		#15			* [x]
	AND.l		d7,d1			* [8] mask q 100ths
	CMP.l		d1,d2			* [6] compare with last q 100ths
	BEQ.s		LAB_1_count		* [10/8] loop if not yet changed

* speed of the 68000 is 100*n*(46+x)/128 cycles/s where x is the time the TRAP #15
* call takes. from this it's not easy to get the effective speed because we don't
* know x so we go measure a slightly different loop ......

LAB_2_wait
	MOVEQ		#8,d0			* get 100ths of a second since midnight
	TRAP		#15
	AND.l		d7,d1			* mask q 100ths
	CMP.l		d1,d2			* compare with last q 100ths
	BEQ.s		LAB_2_wait		* wait more if not yet changed

	MOVE.l	d1,d2			* copy q 100ths
LAB_2_count
	ADDQ.l	#2,d4			* [8] increment counter twice
	BCC.s		LAB_2_ccc		* [10/.] branch if no overflow

* if there is an overflow here then the period over which the count is done needs to
* be reduced. this is done by shifting the mask in d7 and re-running the code from the
* start. for this reason the /.] part of the branch timing, and that for this section,
* never needs to be taken into account. actually this code should /never/ be executed
* but, as with all things that should never happen, if the first loop runs a little
* slow, this one doesn't and the simulator is fast enough that an overflow /could/
* happen then it's better to be safe than wrong. it also saves us padding this loop to
* ensure that it's slower than the above loop to make the math easier later

	ASR.b		#1,d7			* effectively divide the measure time (q) by 2
	BCS		LAB_speederror	* branch if simulator is too fast to time
						* this will happen at approximately 380MHz simulated

	BRA.s		LAB_time		* go re-run the code

LAB_2_ccc
	SUBQ.l	#1,d4			* [8] decrement counter
	MOVEQ		#8,d0			* [4] get 100ths of a second since midnight
	TRAP		#15			* [x]
	AND.l		d7,d1			* [8] mask q 100ths
	CMP.l		d1,d2			* [6] compare with last q 100ths
	BEQ.s		LAB_2_count		* [10/8] loop if not yet changed

* ... now we have another measure of speed of the 68000 which is 100*m*(54+x)/q
* cycles/s. as both loops take the same ammount of time we can find x from these
* two loops by doing the following ..
*
*      100*m*(54+x)/q = 100*n*(46+x)/q
*							.. let x = x+46 to simplify loop counts ..
*       100*m*(8+x)/q = 100*n*x/q
*							.. remove common factors ..
*             m*(8+x) = n*x
*							.. multiply out ..
*             8m + mx = nx
*							.. swap x to left hand side ..
*             nx - mx = 8m
*							.. factorise ..
*           x*(n - m) = 8m
*							.. rearrange to give x gives ..
*                   x = 8m/(n - m)
*
* as a test, run the code and try some returned values, m is 38008 n is 43083
* and q is 16
*
*   x = 8m/(n - m)
*
*   x = 8*38008/(43083 - 38008) =  304064/(5075) = 59.91
*
* having found x it can be substituted in either of the simplified loop equations
* to give the effective processor speed in Hz. for this use 100*n*x/q which is the
* simpler of the two
*
* speed = 100*n*x/q
*
* speed = 100*43083*59.91/16 = 16131890.8125 Hz = 16.132MHz
*
* .. or 16.132MHz, which isn't too bad. this is on a 1.8GHz processor so it works
* out at around 112 real clocks for each 68000 clock.
*
* let the 68000 do this calculation but, as the accuracy is probably not great,
* these equations can be arranged to reduce the risk of overflows should this
* code ever run on a simulator that fast
*
* m is in d4.w and n is in d3.w, the high words are cleared ..

						* x = 8m/(n - m)
	MOVE.l	d3,d5			* copy n
	SUB.w		d4,d5			* (n - m) now in d5.w
	LEA		(LAB_LMHz,PC),a0	* get pointer to "Count error!",[CR][LF]
	BEQ.s		LAB_speederror	* branch if the simulator is too slow to time

* at this point x can be calculated and then used in the speed equation but, as x is a
* small value, some resolution will be lost in the integer nature of the result. to
* preserve the resolution 8*m/(n - m) is substitutes for x in the 100*n*x/q equation,
* which expands to 100*n*8*m/(n - m)/q, and the calculation order is changed

* m is in d4.w and n is in d3.w, the high words are cleared ..
* (n - m) is in d5.w, -q is in d7

	MOVEQ		#0,d0			* clear divide result high word register

	MULU.w	d4,d3			* n*m in d3.l
	MOVE.l	d3,d4			* copy n*m
	MOVE.w	d0,d4			* clear n*m low word
	SWAP		d4			* swap high word to low word

	DIVU.w	d5,d4			* high word divide result in d4.w

	MOVE.w	d4,d0			* copy divide result
	SWAP		d0			* swap to high word (and clear low word)

	MULU.w	d5,d4			* multiply back
	SUB.l		d4,d3			* subtract from n*m

	DIVU.w	d5,d3			* low word n*m/(n - m) now in d3

	MOVEQ		#0,d2			* set value for rounding
	SWAP		d3			* remainder from n*m/(n - m) into d3 low word
	ASL.w		#1,d3			* shift the high bit of the remainder into Xb
	CLR.w		d3			* clear the rest of the remainder
	SWAP		d3			* swap the result back to the low word (Xb unchanged)
	ADDX.w	d2,d3			* add the rounding bit into the result

	ADD.l		d0,d3			* add in the high word result

	LSL.l		#3,d3			* now do the *8 part, d3 = 8*n*m/(n - m)

* as q is always a power of 2, it starts at 128 and gets smaller, it's easy to divide
* by it by shifting the resut right by the correct number of bits. to do this the mask
* is shifted by 1 and tested each loop, if a divide is needed the result is shifted
* and the loop taken again

LAB_divq
	LSR.b		#1,d7			* shift q
	BCS.s		LAB_doneq		* exit loop if the /q is done

	LSR.l		#1,d3			* shift the (unsigned) result
	BRA.s		LAB_divq		* go test again

* now d3 holds 8*n*m/(n - m)/q which is 100th the effective CPU Hz or, looked at
* in MHz, 10,000th the result. this can be output as a fixed point decimal number
* without needing to be further scalled

LAB_doneq
	LEA		(B2dec,PC),a1	* get table address
	MOVEQ		#0,d1			* set table index
	MOVEQ		#'0',d7		* output check character
LAB_chrloop
	MOVE.l	(a1,d1.w),d6	* get table value
	BEQ.s		LAB_alldone		* exit if end marker

	MOVEQ		#'0'-1,d4		* set character to "0"-1
LAB_subloop
	ADDQ.w	#1,d4			* next numeric character
	SUB.l		d6,d3			* subtract table value
	BPL.s		LAB_subloop		* not overdone so loop

	ADD.l		d6,d3			* correct value
	CMP.w		#sB2dec-B2dec,d1	* test index
	BNE.s		LAB_notdp		* branch if not decimal point

	MOVE.w	d4,-(sp)		* save d4
	TST.b		d7			* test if zero output
	BEQ		LAB_no0out		* branch if leading character done

	MOVE.l	d7,d4			* "0" character
	BSR.s		VEC_OUT		* go print the character
LAB_no0out
	MOVEQ		#'.',d4		* "." character
	BSR.s		VEC_OUT		* go print the character
	MOVE.w	(sp)+,d4		* restore d4

LAB_notdp
	BPL.s		LAB_nolead0s	* branch if no leading 0 supress

	CMP.b		d4,d7			* compare with check character
	BEQ.s		LAB_lead0s		* branch if leading '0' supressed

LAB_nolead0s
	MOVEQ		#0,d7			* eliminate check character
	BSR		VEC_OUT		* character out to display
LAB_lead0s
	ADDQ.w	#4,d1			* increment table pointer
	BRA.s		LAB_chrloop		* loop

LAB_alldone
	LEA		(LAB_MHz,PC),a0	* get pointer to " MHz",[CR][LF]
LAB_speederror
	BSR.s		LAB_string		* output null terminated string
	BRA		start			* loop forever


* output null terminated string

LAB_sstring
	BSR.s		VEC_OUT		* else go print the character
LAB_string
	MOVE.b	(a0)+,d4		* get byte from string
	BNE.s		LAB_sstring		* output character if not end

	RTS


* output character to the console from register d4

VEC_OUT
	MOVEM.l	d0-d1,-(sp)		* save d0, d1
	MOVE.b	d4,d1			* copy character
	MOVEQ		#6,d0			* character out
	TRAP		#15			* do I/O function
	MOVEM.l	(sp)+,d0-d1		* restore d0, d1
	RTS


* binary to unsigned decimal table

B2dec
	dc.l	$3B9ACA00			* 10000.00000
	dc.l	$05F5E100			* 1000.00000
	dc.l	$00989680			* 100.00000
	dc.l	$000F4240			* 10.00000
	dc.l	$000186A0			* 1.00000
	dc.l	$00002710			* 0.10000
sB2dec
	dc.l	$000003E8			* 00.10000
	dc.l	$00000064			* 000.10000
	dc.l	$0000000A			* 0000.10000
	dc.l	$00000000			* 0 end marker


* messages

LAB_MHz
	dc.b	' MHz',$0D,$0A,$00
LAB_MMHz
	dc.b	'Too fast!',$0D,$0A,$00
LAB_LMHz
	dc.b	'Count error!',$0D,$0A,$00

	END	start


*************************************************************************************

