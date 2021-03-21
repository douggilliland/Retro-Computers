;***************************************************************************************************
;*  C02BIOS 2.01 (c)2013-2018 by Kevin E. Maier   *     New Hardware design with the following:    *
;* - BIOS in pages $F8-$FF, less I/O in page $FE  *  - W65C02 with clock rate up to 6.0 MHz        *
;* - Full duplex interrupt-driven/buffered I/O    *  - AS6C66256 32KB Static RAM                   *
;* - Extendable BIOS structure with soft vectors  *  - AT28H256 32KB EEPROM for ROM                *
;* - Soft config parameters for I/O devices       *  - ATF22V10CQZ Single Glue Logic               *
;* - Monitor cold/warm start soft vectored        *  - NXP SCC2691 UART for console/timer          *
;* - Fully relocatable code (sans page $FF)       *  - Hardware map is flexible via Glue logic     *
;* - Precision timer services w/10ms accuracy     *  - 5 I/O selects @ 32-bytes wide               *
;* - RTC based Jiffy Clock, Sec, Min, Hour, Days  *  - 4 I/O selects available on expansion bus    *
;* - Accurate delays from 10ms to ~497 days       *  - 1 I/O select used by SCC2691 UART           *
;*                                                *   Note default HW system memory map as:        *
;*  Uses ~2KB EEPROM - JMP table page at $FF00    *         RAM - $0000 - $7FFF                    *
;*    Uses <one page for I/O: default at $FE00    *         ROM - $8000 - $FDFF                    *
;*        Default assembly start at $F800:        *         I/O - $FE00 - $FE9F (5 in total)       *
;*            04/02/2018 (DD/MM/YYYY)             *         ROM - $FEA0 - $FFFF                    *
;***************************************************************************************************
	PL	66	;Page Length
	PW	132	;Page Width (# of char/line)
	CHIP	W65C02S	;Enable WDC 65C02 instructions
;******************************************************************************
;	Page Zero definitions $00 to $AF reserved for user routines
PGZERO_ST	.EQU	$B0	;Start of Page Zero usage
;16-bit Monitor variables required for BIOS:
INDEXL		.EQU	PGZERO_ST+16	;Index for address - multiple routines
INDEXH		.EQU	PGZERO_ST+17
;
;	BIOS variables, pointers, flags located at top of Page Zero.
BIOS_PG0	.EQU	PGZERO_ST+48	;Start of BIOS page zero use ($E0-$FF)
;	- BRK handler routine
PCL				.EQU	BIOS_PG0+00	;Program Counter Low index
PCH				.EQU	BIOS_PG0+01	;Program Counter High index
PREG			.EQU	BIOS_PG0+02	;Temp Status reg
SREG			.EQU	BIOS_PG0+03	;Temp Stack ptr
YREG			.EQU	BIOS_PG0+04	;Temp Y reg
XREG			.EQU	BIOS_PG0+05	;Temp X reg
AREG			.EQU	BIOS_PG0+06	;Temp A reg
;
;	- 2691 IRQ handler pointers and status
ICNT			.EQU	BIOS_PG0+07	;Input buffer count
IHEAD			.EQU	BIOS_PG0+08	;Input buffer head pointer
ITAIL			.EQU	BIOS_PG0+09	;Input buffer tail pointer
OCNT			.EQU	BIOS_PG0+10	;Output buffer count
OHEAD			.EQU	BIOS_PG0+11	;Output buffer head pointer
OTAIL			.EQU	BIOS_PG0+12	;Output buffer tail pointer
UART_IRT	.EQU	BIOS_PG0+13	;2691 Interrupt Status byte
UART_SRT	.EQU	BIOS_PG0+14	;2691 Status Register byte
;
;	- Real-Time Clock variables
TICKS			.EQU	BIOS_PG0+15	;# timer countdowns for 1 second (100)
SECS			.EQU	BIOS_PG0+16	;Seconds: 0-59
MINS			.EQU	BIOS_PG0+17	;Minutes: 0-59
HOURS			.EQU	BIOS_PG0+18	;Hours: 0-23
DAYSL			.EQU	BIOS_PG0+19	;Days: Low-Order byte 0-65535
DAYSH			.EQU	BIOS_PG0+20	;Days: High-Order byte >179 Years ;-)
;
;	- Delay Timer variables
MSDELAY		.EQU	BIOS_PG0+21	;Timer delay countdown byte (255 > 0)
MATCH			.EQU	BIOS_PG0+22	;Delay Match flag, $FF is set, $00 is cleared
SETIM			.EQU	BIOS_PG0+23	;Set timeout for delay routines - BIOS use only
DELLO			.EQU	BIOS_PG0+24	;Delay value BIOS use only
DELHI			.EQU	BIOS_PG0+25	;Delay value BIOS use only
XDL				.EQU	BIOS_PG0+26	;XL Delay count
;
;Spare BIOS bytes for future use
SPARE_B0	.EQU	BIOS_PG0+27	;Spare BIOS page zero byte
SPARE_B1	.EQU	BIOS_PG0+28	;Spare BIOS page zero byte
SPARE_B2	.EQU	BIOS_PG0+29	;Spare BIOS page zero byte
SPARE_B3	.EQU	BIOS_PG0+30	;Spare BIOS page zero byte
SPARE_B4	.EQU	BIOS_PG0+31	;Spare BIOS page zero byte
;
;Default for RTC tick count - number of IRQs for 1 second
DF_TICKS	.EQU	#100	;counter/timer is 10 milliseconds (100 x 10ms = 1 second)
;******************************************************************************
IBUF			.EQU	$0200	;Console Input Buffer - 128 bytes
OBUF			.EQU	$0280	;Console Output Buffer - 128 bytes
;******************************************************************************
SOFTVEC		.EQU	$0300	;Start of soft vectors
;The Interrupt structure is vector based. During startup, Page $03 is loaded from ROM
; The soft vectors are structured to allow inserting additional routines either before
; or after the core routines. This allows flexibility and changing of routine priority
;
;The main set of vectors occupy the first 16 bytes of Page $03. The ROM handler for
; NMI, BRK and IRQ jump to the first 3 vectors. The following 3 vectors are loaded with
; returns to the ROM handler for each. The following 2 vectors are the cold and warm
; entry points for the Monitor. After the basic initialization, the monitor is entered
;
;The following vector set allows inserts, pre or post for NMI/BRK/IRQ. There a total of 8 inserts
; which occupy 16 bytes. They can be used as required. Currently, all of these are available.
;
NMIVEC0		.EQU	SOFTVEC+00	;NMI Vector Entry 0
BRKVEC0		.EQU	SOFTVEC+02	;BRK Vector Entry 0
IRQVEC0		.EQU	SOFTVEC+04	;IRQ Vector Entry 0
;
NMIRTVEC0	.EQU	SOFTVEC+06	;NMI Vector Return 0
BRKRTVEC0	.EQU	SOFTVEC+08	;BRK Vector Return 0
IRQRTVEC0	.EQU	SOFTVEC+10	;IRQ Vector Return 0
;
CLDMNVEC0	.EQU	SOFTVEC+12	;Monitor Cold Entry Vector 0
WRMMNVEC0	.EQU	SOFTVEC+14	;Monitor Warm Entry Vector 0
;
VECINSRT0	.EQU	SOFTVEC+16	;1st Vector Insert
VECINSRT1	.EQU	SOFTVEC+18	;2nd Vector Insert
VECINSRT2	.EQU	SOFTVEC+20	;3rd Vector Insert
VECINSRT3	.EQU	SOFTVEC+22	;4th Vector Insert
VECINSRT4	.EQU	SOFTVEC+24	;5th Vector Insert
VECINSRT5	.EQU	SOFTVEC+26	;6th Vector Insert
VECINSRT6	.EQU	SOFTVEC+28	;7th Vector Insert
VECINSRT7	.EQU	SOFTVEC+30	;8th Vector Insert
;
;******************************************************************************
SOFTCFG		.EQU SOFTVEC+32	;Start of hardware config parameters
;Soft Config values below are loaded from ROM and are the default I/O setup configuration data that
; the INIT_x routines use. As a result, you can write a routine to change the I/O configuration data
; and use the standard ROM routines to initialize the I/O without restarting or changing ROM. A Reset
; (HW or coded) will reinitialize the I/O with the ROM default I/O configuration.
;There are a total of 32 Bytes configuration data reserved starting at $0320
LOAD_2691	.EQU	SOFTCFG+00	;SCC2691 SOFT config data start
;******************************************************************************
IOPAGE		.EQU	$FE00	;I/O Page Base Start Address
;******************************************************************************
SCC2691_BASE	.EQU	IOPAGE+$80	;Beginning of Console UART address
;
UART_MODEREG	.EQU	SCC2691_BASE+$00 	;MR1/MR2 same address, sequential read/write
UART_STATUS		.EQU	SCC2691_BASE+$01	;UART Status Register (READ)
UART_CLKSEL		.EQU	SCC2691_BASE+$01	;UART Clock Select Register (WRITE)
UART_BRGTST		.EQU	SCC2691_BASE+$02	;UART BRG Test register (READ)
UART_COMMAND	.EQU	SCC2691_BASE+$02	;UART Command Register (WRITE)
UART_RECEIVE	.EQU	SCC2691_BASE+$03	;UART Receive Register (READ)
UART_TRANSMIT	.EQU	SCC2691_BASE+$03	;UART Transmit Register (WRITE)
UART_CLKTEST	.EQU	SCC2691_BASE+$04	;X1/X16 Test Register (READ)
UART_AUXCR		.EQU	SCC2691_BASE+$04	;Aux Command Register (WRITE)
UART_ISR			.EQU	SCC2691_BASE+$05	;Interrupt Status Register (READ)
UART_IMR			.EQU	SCC2691_BASE+$05	;Interrupt Mask Register (WRITE)
UART_CNTU			.EQU	SCC2691_BASE+$06	;Counter/Timer Upper Register (READ)
UART_CNTUP		.EQU	SCC2691_BASE+$06	;Counter/Timer Upper Preset Register (WRITE)
UART_CNTL			.EQU	SCC2691_BASE+$07	;Counte/Timerr Lower Register (READ)
UART_CNTLP		.EQU	SCC2691_BASE+$07	;Counter/Timer Lower Preset Register (WRITE)
;
;******************************************************************************
;	Monitor JUMP table: 32 JUMP calls are available. Calls 02-10 are currently Reserved.
M_MONITOR		.EQU	$E000	;Call 00
M_WRM_MON		.EQU	$E003	;Call 01
;
M_PRSTAT1		.EQU	$E021	;Call 11
M_DIS_LINE	.EQU	$E024	;Call 12
M_INCINDEX	.EQU	$E027	;Call 13
M_DECINDEX	.EQU	$E02A	;Call 14
M_RDLINE		.EQU	$E02D	;Call 15
M_RDCHAR		.EQU	$E030	;Call 16
M_HEXIN2		.EQU	$E033	;Call 17
M_HEXIN4		.EQU	$E036	;Call 18
M_HEX2ASC		.EQU	$E039	;Call 19
M_BIN2ASC		.EQU	$E03C	;Call 20
M_ASC2BIN		.EQU	$E03F	;Call 21
M_BEEP			.EQU	$E042	;Call 22
M_DOLLAR		.EQU	$E045	;Call 23
M_CROUT			.EQU	$E048	;Call 24
M_SPC				.EQU	$E04B	;Call 25
M_PRBYTE		.EQU	$E04E	;Call 26
M_PRWORD		.EQU	$E051	;Call 27
M_PRASC			.EQU	$E054	;Call 28
M_PROMPT		.EQU	$E057	;Call 29
M_PROMPTR		.EQU	$E05A	;Call 30
M_CONTINUE	.EQU	$E05D	;Call 31
;
;******************************************************************************
			.ORG	$F800	;2KB reserved for BIOS, I/O device selects (160 bytes)
;******************************************************************************
;START OF BIOS CODE
;******************************************************************************
;C02BIOS version used here is 2.01 updated release (minor)
; Contains the base BIOS routines in top 2KB of EEPROM
; - $F800 - $F9FF 512 bytes for BIOS SCC2691, NMI Panic routine
; - $FA00 - $FDFF reserved for BIOS expansion (1KB)
; - $FE00 - $FE7F reserved for HW (4-I/O devices, 32 bytes wide)
; - $FE80 - $FE9F SCC2691 UART (32 bytes wide, only 8 bytes used)
;	- $FEA0 - $FEFF used for Vector and Hardware configuration data
; - $FF00 - BIOS JMP table, CPU startup, NMI/BRK/IRQ pre-post routines, BIOS msg.
; - Input/Feedback from "BDD" - modified CHR-I/O routines - saves 12 bytes
;******************************************************************************
;	The following 32 functions are provided by BIOS via the JMP Table
;	$FF00	- $FF33 are Reserved for future expansion
;
;	$FF36 CHRIN_NW		;(character input from console, no waiting, clear carry if none)
;	$FF39 CHRIN				;(character input from console)
;	$FF3C CHROUT			;(character output to console)
;	$FF3F SET_DLY			;(set delay value for milliseconds and 16-bit counter)
;	$FF42 EXE_MSDLY		;(execute millisecond delay 1-256 * 10 milliseconds)
;	$FF45 EXE_LGDLY		;(execute long delay; millisecond delay * 16-bit count)
;	$FF48 EXE_XLDLY		;(execute extra long delay; 8-bit count * long delay)
;	$FF4B INIT_VEC		;(initialize soft vectors at $0300 from ROM)
;	$FF4E INIT_CFG		;(initialize soft config values at $0320 from ROM)
;	$FF51 INIT_2691		;(initialize SCC2691 console 38.4K, 8-N-1 RTS/CTS)
;	$FF54 RESET_2691	;(reset SCC2691) - called before INIT_2691
;	$FF57 MONWARM			;(Monitor warm start - jumps to page $03)
;	$FF5A MONCOLD			;(Monitor cold start - jumps to page $03)
; $FF5D	COLDSTRT		;(System cold start - RESET vector for 65C02)
;******************************************************************************
; Character In and Out routines for Console I/O buffer
;******************************************************************************
;Character Input routines
;CHRIN_NW uses CHRIN, returns if a character is not available from the buffer with carry flag set
; else returns with character in A reg and carry flag clear. CHRIN waits for a character to be in the
; buffer, then returns with carry flag clear. Receive is IRQ driven/buffered with a size of 128 bytes.
;
CHRIN_NW	SEC	:Set Carry flag for no character
					LDA	ICNT	;Get character count
					BNE	GET_CH	;Branch if buffer is not empty
					RTS	;and return to caller
;
CHRIN			LDA	ICNT	;Get character count
					BEQ	CHRIN	;If zero (no character, loop back)
;
GET_CH		PHY	;Save Y reg
					LDY	IHEAD	;Get the buffer head pointer
					LDA	IBUF,Y	;Get the character from the buffer
;
					INC	IHEAD	;Increment head pointer
					RMB7	IHEAD	;Strip off bit 7, 128 bytes only
;
					DEC	ICNT	;Decrement the buffer count
					PLY	;Restore Y Reg
					CLC	;Clear Carry flag for character available
					RTS	;Return to caller with character in A reg
;
;Character Output routine: puts the character in the A reg into the xmit buffer, character in
; A Reg is preserved on exit. Transmit is IRQ driven/buffered with a size of 128 bytes.
;
CHROUT		PHY	;Save Y reg
OUTCH			LDY	OCNT	;Get character output count in buffer
					BMI	OUTCH	;Check against limit, loop back if full
;
					LDY	OTAIL	;Get the buffer tail pointer
					STA	OBUF,Y	;Place character in the buffer
;
					INC	OTAIL	;Increment Tail pointer
					RMB7	OTAIL	;Strip off bit 7, 128 bytes only
					INC	OCNT	;Increment character count
;
					LDY	#%00000100	;Get mask for xmit on
					STY	UART_COMMAND	;Turn on xmt
;
					PLY	;Restore Y reg
					RTS	;Return	to caller
;
;******************************************************************************
;Delay Routines: SET_DLY sets up the MSDELAY value and can also set the Long Delay variable
; On entry, A reg = millisecond count, X reg = High multipler, Y reg = Low multipler
;	these values are used by the EXE_MSDLY and EXE_LGDLY routines. Minimum delay is 10ms Jiffy Clock
;	values for MSDELAY are $00-$FF ($00 = 256 times)
;	values for Long Delay are $0000-$FFFF (0-65535 times MSDELAY)
;	longest delay is 65,535*256*10ms = 16,776,960 * 0.01 = 167,769.60 seconds
;
SET_DLY		STA	SETIM	;Save Millisecond count
					STY	DELLO	;Save Low multipler
					STX	DELHI	;Save High Multipler
					RTS	;Return to caller
;
;EXE MSDELAY routine is the core delay routine.	It sets the MSDELAY count value from the
; SETIM variable, enables the MATCH flag, then waits for the MATCH flag to clear.
;
EXE_MSDLY	PHA	;Save A Reg
					SMB7	MATCH	;Set MATCH flag bit
					LDA	SETIM	;Get delay seed value
					STA	MSDELAY	;Set MS delay value
;
MATCH_LP	BBS7	MATCH,MATCH_LP	;Test MATCH flag, loop until cleared
					PLA	;Restore A Reg
					RTS	;Return to caller
;
;EXE LONG Delay routine is the 16-bit multiplier for the MS DELAY routine
;	It loads the 16-bit count from DELLO/DELHI, then loops the MSDELAY
;	routine until the 16-bit count is decremented to zero
;
EXE_LGDLY	PHX	;Save X Reg
					PHY	;Save Y Reg
					LDX	DELHI	;Get high byte count
					INX	;Increment by one (checks for $00 vs $FF)
					LDY	DELLO	;Get low byte count
					BEQ	SKP_DLL	;If zero, skip to high count
DO_DLL		JSR	EXE_MSDLY	;Call millisecond delay
					DEY	;Decrement low count
					BNE	DO_DLL	;Branch back until done
;
SKP_DLL		DEX	;Decrement high byte index
					BNE	DO_DLL	;Loop back to DLL (will run 256 times)
					PLY	;Restore Y Reg
					PLX	;Restore X Reg
					RTS	;Return to caller
;
;EXE EXTRA LONG Delay routine uses XDL variable as an 8-bit count	and calls the EXE LONG Delay routine
; XDL times. On entry, XDL contains the number of interations This can increase the delay by 256 times
; the above value of 167,769.60 seconds
;
EXE_XLDLY	JSR	EXE_LGDLY	;Call the Long Delay routine
					DEC	XDL	;Decrement count
					BNE	EXE_XLDLY	;Loop back until XDL times out
					RTS	;Done, return to caller
;
;******************************************************************************
;START OF PANIC ROUTINE
;The Panic routine is for debug of system problems, i.e., a crash. The design requires a
; debounced NMI trigger button which is manually operated when the system crashes or malfunctions,
; user presses the NMI (panic) button. The NMI vectored routine will perform the following tasks:
; 1- Save registers in page $00 locations
; 2- Copy pages $00, $01, $02 and $03 to locations $0400-$07FF
; 3- Zero all I/O buffer pointers
; 4- Call the ROM routines to init the vectors and config data (page $03)
; 5- Call ROM routines to reset/init the Console UART (SCC2691)
; 6- Toggle the X1/X16 Test Mode register (might require pressing Panic twice*)
; 7- Restart the Monitor via warm start vector
; No memory is cleared except the required pointers to restore the system
;
;* Note: it's possible to lockup the SCC2691 so that the Reset/Init routines can not recover it.
; The problem is one of two possibilities: 1- The BRG Test mode has been toggled via a read of the
; BRG Test Register. 2- The X1/X16 Test mode has been toggled via a read of the X1/X16 Test Register
;
;The first scenario can be avoided if the baud rate is setup for 19.2K or 38.4K as the test mode uses
; the same baud rate as normal mode. Note that this does not lock up the UART in any way, but simply
; changes the baud rate per the BRG Test mode table. A second read to the BRG Test mode register will
; change the baud rate back to normal. As a default, the baud rate is set for 38.4K. If the default
; baud rate is changed, then this may become an issue and additional coding may be required.
;
;The second scenario is more difficult to workaround. There's no telling if a read was done to the
; X1/X16 test mode register. There are only two options to correct this; 1- a second read of the
; X1/X16 Test Register, or 2- a hardware Reset applied to the UART. In the interest of being able to
; use the NMI Panic routine, the code does a read of the X1/X16 Test Mode register. If pressing the
; Panic button doesn't restore the UART, hitting it a second time might, unless the vector has changed!
;
;NOTE: The X1/X16 Test mode is toggled via the INIT_2691 routine below! This is the result of a bug
; in the W65C02 as explained in the Init section below. This is noted here for awareness only.
; Please read the text below preceding the initialization routines for more detail.*
;
NMI_VECTOR	;This is the ROM start for NMI Panic handler
					STA	AREG	;Save A Reg
					STX	XREG	;Save X Reg
					STY	YREG	;Save Y Reg
					PLA	;Get Processor Status 
					STA	PREG	;Save in PROCESSOR STATUS preset/result
					TSX	;Get Stack pointer
					STX	SREG	;Save STACK POINTER
					PLA	;Pull low byte RETURN address from STACK
					STA	PCL	;Store Low byte
					PLA	;Pull high byte RETURN address from STACK
					STA	PCH	;Store High byte
;
					STZ	UART_IMR	;Disable ALL interrupts from UART
					LDA	UART_STATUS	;Get UART status register
					STA	UART_SRT	;Save it in Page 0
					LDA	UART_ISR	;Get UART Interrupt status register
					STA	UART_IRT	;Save it in Page 0
					LDA	UART_CLKTEST	;Toggle the X1/X16 Test mode*
;
					LDY	#$00	;Zero Y reg
					LDX	#$04	;Set index to 4 pages
					STX	$03	;Set to high order
					STZ	$02	;Zero remaining pointers
					STZ	$01 ;for target
					STZ	$00 ;and source
;
PLP0			LDA	($00),Y	;get byte
					STA	($02),Y	;store byte
					DEY	;Decrement index
					BNE	PLP0	;Loop back till done
;
					INC	$01	;Increment source page address
					INC	$03	;Increment destination page address
					DEX	;Decrement page count
					BNE	PLP0	;Branch back for next page
;
					LDX	#$08	;Get count of
PAN_LP1		STZ	ICNT-1,X	;Clear console I/O pointers/Status
					DEX	;Decrement index
					BNE	PAN_LP1	;Branch back till done
;
					JSR	INIT_PG03	;Xfer default Vectors/HW Config to $0300
					JSR	INIT_IO	;Reset and Init the UART for Console
					JMP	(NMIRTVEC0)	;Jump to Monitor Warm Start Vector
;
;******************************************************************************
;BRK/IRQ Interrupt service routine
;The pre-process routine located in page $FF soft-vectors to here:
;	The following routines handle BRK and IRQ functions
;	The BRK handler saves CPU details for register display
;	- A Monitor can provide a disassembly of the last executed instruction
;	- A Received Break is also handled here (ExtraPutty)
;
; SCC2691 handler
;	The 2691 IRQ routine handles transmit, receive, timer and Break interrupts
;	- Transmit and receive each have a 128 byte circular FIFO buffer in memory
;	- Xmit IRQ is controlled by the handler and the CHROUT routine
; The 2691 Timer resolution is 10ms and used as a Jiffy Clock RTC and delays
;
UART_BRK	LDA	UART_STATUS	;Get UART Status register
					BMI	BREAKEY	;If bit 7 set, received Break was detected
					LDX	#UART_RDATAE-UART_RDATA	;Get index count
UART_RST1	LDA	UART_RDATA-1,X	;Get Reset commands
					STA	UART_COMMAND	;Send to UART CR
					DEX	;Decrement the command list
					BNE	UART_RST1	;Loop back until all are sent
					BRA	REGEXT0	;Exit
;
BREAKEY		LDA	#%01000000	;Get Reset Received Break command
					STA	UART_COMMAND	;Send to UART to reset
					LDA	#%01010000	;Get Reset Break Interrupt command
					STA	UART_COMMAND	;Send to UART to reset
					CLI	;Enable IRQ
;
BRKINSTR0	PLY	;Restore Y reg
					PLX	;Restore X Reg
					PLA	;Restore A Reg
					STA	AREG	;Save A Reg
					STX	XREG	;Save X Reg
					STY	YREG	;Save Y Reg
					PLA	;Get Processor Status
					STA	PREG	;Save in PROCESSOR STATUS preset/result
					TSX	;Xfrer STACK pointer to X reg
					STX	SREG	;Save STACK pointer
;
					PLX	;Pull Low RETURN address from STACK then save it
					STX	PCL	;Store program counter Low byte
					STX	INDEXL	;Seed Indexl for DIS_LINE
					PLY	;Pull High RETURN address from STACK then save it
					STY	PCH	;Store program counter High byte
					STY	INDEXH	;Seed Indexh for DIS_LINE
					BBR4	PREG,DO_NULL	;Check for BRK bit set
;
; The following three subroutines are contained in the base Monitor code These calls
; do a register display and disassembles the line of code that caused the BRK to occur.
					JSR	M_PRSTAT1	;Display CPU status
					JSR	M_DECINDEX	;Decrement Index to BRK ID Byte
					JSR	M_DECINDEX	;Decrement Index to BRK instruction
					JSR	M_DIS_LINE	;Disassemble BRK instruction
;
DO_NULL		LDA	#$00	;Clear all PROCESSOR STATUS REGISTER bits
					PHA	;Push it to Stack
					PLP	;Pull it Processor Status
					STZ	ITAIL	;Zero out input buffer pointers
					STZ	IHEAD	;
					STZ	ICNT	;
					JMP	(BRKRTVEC0)	;Done BRK service process, re-enter monitor
;
;******************************************************************************;
;BIOS routines to handle interrupt-driven I/O for the SCC2691
;NOTE: MPI Pin is used for RTS, which is automatically handled in the chip. As a result,
; the upper 2 bits of the ISR are not used in the handler. The Lower 5 bits are used, but
; the lower two are used to determine when to disable transmit after the buffer is empty.
;The UART_ISR bits are defined as follows:
;	7-	MPI Pin change 0=No, 1=Yes
;	6-	MPI Pin current state 0=Low, 1=High
;	5-	Unused (always active 1)
;	4-	Counter Ready 0=No, 1=Yes
;	3-	Delta Break 0=No, 1=Yes
;	2-	RxRDY/Full 0=No, 1=Yes
;	1-	TxEMT 0=No, 1=Yes
;	0-	TXRDY 0=No, 1=Yes
;
;******************************************************************************;
; Buffer Full code moved here to allow "BRA REGEXT0" at end of RTC handler
;
BUFF_FUL	LDA #%00001100 ;Get buffer overflow flag
					BRA IRQEXT0 ;Branch to exit
;Start of 2691 code - interrupt handler starts here!
;
INTERUPT0	LDA	UART_ISR	;Get the UART Interrupt Status Register
					CMP	#%00100000	;Check for no active IRQ source
					BEQ	REGEXT0	;If no bits are set, exit handler
;
					BIT	#%00001000	;Test for Delta Break
					BNE	UART_BRK	;If yes, Reset the UART receiver
					BIT	#%00000100	;Test for RHR having a character
					BNE	UART_RCV	;If yes, put the character in the buffer
					BIT	#%00000001	;Test for THR ready to receive a character
					BNE	UART_XMT	;If yes, get character from buffer
					BIT	#%00010000	;Test for Counter ready (RTC)
					BNE	UART_RTC	;If yes, go increment RTC variables
;
IRQEXT0		STA	UART_IRT	;Else, save the 2691 IRS for later use
					LDA	UART_STATUS	;Get 2691 Status Register
					STA	UART_SRT	;Save 2691 Status Register for later use
REGEXT0		JMP	(IRQRTVEC0)	;Return to ROM IRQ handler
;
UART_RCV	LDY ICNT	;Get buffer counter
					BMI	BUFF_FUL	;Check against limit, branch if full
					LDA UART_RECEIVE	;Else, get character from 2691
;
					LDY ITAIL ;Get the tail pointer to buffer
					STA IBUF,Y ;Store into buffer
					INC	ITAIL	;Increment tail pointer
					RMB7	ITAIL	;Strip off bit 7, 128 bytes only
					INC ICNT ;increment character count
;	
					LDA UART_STATUS ;Get 2691 status reg
					BIT #%00000010 ;Check for xmit active
					BEQ REGEXT0	;Exit if not
;
UART_XMT	LDA OCNT ;Any characters to xmit?
					BEQ NODATA ;No, turn off xmit
;
OUTDAT		LDY OHEAD ;Get the head pointer to buffer
					LDA OBUF,Y ;Get the next character
					STA UART_TRANSMIT ;Send the character to 2691
;
					INC	OHEAD	;Increment head pointer
					RMB7	OHEAD	;Strip off bit 7, 128 bytes only
					DEC OCNT ;Decrement counter
					BNE	REGEXT0	;If not zero, exit and continue normal stuff
;
;No more buffer data to send, check 2691 status and disable transmit if it's finished
NODATA		LDA	UART_STATUS	;Get status register
					BIT	#%00001000	;Check for THR empty
					BNE	REGEXT0	;Exit if character still loaded
					BIT	#%00000100	;Check for TxRDY active
					BEQ	REGEXT0	;Exit if not active, another character in THR
					LDY	#%00001000	;Else, get mask for xmit off
					STY UART_COMMAND ;Turn off xmit
					BRA REGEXT0 ;Exit IRQ handler
;
;NOTE: Stop timer cmd resets the interrupt flag, counter continues to generate interrupts.
;
UART_RTC	LDA	#%10010000	;Get Command mask for stop timer
					STA	UART_COMMAND	;Send command to 2691
;
; Check the MATCH flag to see if a Delay is active. If yes, decrement the MSDELAY
; variable once each pass until it is zero, then clear the MATCH flag
					BBR7	MATCH,SKIP_DLY	;Skip Delay if flag clear
					DEC	MSDELAY	;Decrement Millisecond delay variable
					BNE	SKIP_DLY	;If not zero, skip
					RMB7	MATCH	;Else clear MATCH flag
;
SKIP_DLY	DEC	TICKS	;Decrement RTC tick count
					BNE	REGEXT0	;Exit if not zero
					LDA	#DF_TICKS ;Get default tick count
					STA	TICKS	;Reset Tick count
;
					INC	SECS	;Increment seconds
					LDA	SECS	;Load it to A reg
					CMP	#60	;Check for 60 seconds
					BCC	REGEXT0	;If not, exit
					STZ	SECS	;Else, reset seconds, inc Minutes
;
					INC	MINS	;Increment Minutes
					LDA	MINS	;Load it to A reg
					CMP	#60	;Check for 60 minutes
					BCC	REGEXT0	;If not, exit
					STZ	MINS	;Else, reset Minutes, inc Hours
;
					INC	HOURS	;Increment Hours
					LDA	HOURS	;Load it to A reg
					CMP	#24	;Check for 24 hours
					BCC	REGEXT0	;If not, exit
					STZ	HOURS	;Else, reset hours, inc Days
;
					INC	DAYSL	;Increment low-order Days
					BNE	REGEXT0	;If not zero, exit
					INC	DAYSH	;Else increment high-order Days
					BRA	REGEXT0	;Then exit IRQ handler
;
;*********************************************************************
INIT_PG03	JSR	INIT_VEC	;Init the Vectors first
INIT_CFG	LDY	#$40	;Get offset to data
					BRA	DATA_XFER	;Go move the data to page $03
INIT_VEC	LDY	#$20	;Get offset to data
;
DATA_XFER	SEI	;Disable Interrupts, can be called via JMP table
					LDX	#$20	;Set count for 32 bytes
DATA_XFLP	LDA	VEC_TABLE-1,Y	;Get ROM table data
					STA	SOFTVEC-1,Y	;Store in Soft table location
					DEY	;Decrement index
					DEX	;Decrement count
					BNE	DATA_XFLP	;Loop back till done
					CLI	;re-enable interupts
					RTS	;Return to caller
;
;Initializing the SCC2691 UART as the Console
;An undocumented bug in the W65C02 processor requires a different approach for programming the
; SCC2691 for proper setup/operation. The SCC2691 uses two Mode Registers which are accessed at
; the same register in sequence. There is a command that Resets the Mode Register pointer (to MR1)
; that is issued first. Then MR1 is loaded followed by MR2. The problem with the W65C02 is a false
; read of the register when using indexed addressing (i.e., STA UART_REGISTER,X). This results in
; the mode register pointer being moved to the second register, so the write to MR1 never happens.
; While the indexed list works fine for all other register functions/commands, the loading of the
; Mode Registers needs to be handled separately.
;
;NOTE: The W65C02 will function properly "if" a page boundary is crossed as part of the STA
; (i.e., STA $FDFF,X) where the value of the X register is high enough to cross the page boundary.
; Programming in this manner would be confusing and require modification if the base I/O address
; is changed for a different hardware I/O map. Not worth the aggravation in my view.
;
;The same bug in the W65C02 also creates a false read when sending any command to the Command
; Register (assumed indexed addressing), as the read function of that hardware register is the
; BRG Test register. This can result in a different baud rate being selected, depending on the
; baud rate tables listed in the Datasheet. When using either 19.2K or 38.4K baud rate, the tables
; are the same for both normal and BRG Test mode, so the UART will operate normally. Changing to a
; different baud rate via the BRG Test register requires additional coding to use any of the
; extended baud rates.
;
;NOTE: As a result of the bug mentioned above, the X1/X16 Test Mode register will be toggled twice
; when the INIT_2691 routine is executed. The end result is the 2691 UART is correctly configured
; after the routine completes. Also note that the NMI PANIC routine above also toggles the X1/X16
; Test Mode register in case it was inadvertantly invoked (toggled).
;
;There are two basic routines to setup the 2691 UART
;
;The first routine is a basic RESET of the UART.
; It issues the following sequence of commands:
; 1- Send a Power On command to the ACR
; 2- Reset Break Change Interrupt
; 3- Reset Receiver
; 4- Reset Transmitter
; 5- Reset All errors
;
;The second routine initializes tha 2691 UART for operation. It uses two tables of data; one for the
; register offset and the other for the register data. The table for register offsets is maintained in
; ROM. The table for register data is copied to page $03, making it soft data. If needed, operating
; parameters can be altered and the UART re-initialized.
;
; Updated BIOS version to Ver. 2.01 on 2nd April 2018. Shorten INIT_IO routine by moving up the
; INIT_2691 to remove the "JMP INIT_2691", saves a few bytes and some clock cycles.
;
INIT_IO		JSR	RESET_2691	;Power-Up Reset of SCC2691 UART
					LDA	#DF_TICKS	;Get divider for jiffy clock for 1-second
					STA	TICKS	;Preload TICK count
;
INIT_2691	;This routine sets the initial operating mode of the UART
					SEI	;Disable interrupts
					LDX	#INIT_DATAE-INIT_DATA	;Get the Init byte count
2691_INT	LDA	LOAD_2691-1,X	;Get Data for 2691 register
					LDY	INIT_OFFSET-1,X	;Get Offset for 2691 register
					STA	SCC2691_BASE,Y	;Store to selected register
					DEX	;Decrement count
					BNE	2691_INT	;Loop back until all registers are loaded
;
					LDA	MR1_DAT	;Get Mode Register 1 Data
					STA	UART_MODEREG	;Send to 2691
					LDA	MR2_DAT	;Get Mode Register 2 Data
					STA	UART_MODEREG	;Send to 2691
					CLI	;Enable interrupts
					RTS	;Return to caller
;
RESET_2691	;This routine does a basic Reset of the SCC2691
					LDA	#%00001000	;Get Power On mask
					STA	UART_AUXCR	;Send to 2691 (ensure it's on)
;
					LDX	#UART_RDATAE-UART_RDATA1	;Get the Init byte count
UART_RES1	LDA	UART_RDATA1-1,X	;Get Reset commands
					STA	UART_COMMAND	;Send to UART CR
					DEX	;Decrement the command list
					BNE	UART_RES1	;Loop back until all are sent
					RTS	;Return to caller
;
;END OF BIOS CODE for Pages $F8 through $FD
;******************************************************************************
			.ORG	$FE00	;Reserved for I/O page - do NOT put code here
; There are 5- I/O Selects, each 32-bytes wide.
; I/O-0 = $FE00-$FE1F	;Available on BUS expansion connector
; I/O-0 = $FE20-$FE3F	;Available on BUS expansion connector
; I/O-0 = $FE40-$FE5F	;Available on BUS expansion connector
; I/O-0 = $FE60-$FE7F	;Available on BUS expansion connector
; I/O-0 = $FE80-$FE9F ;SCC2691 UART resides here
;******************************************************************************
			.ORG	$FEA0	;Reserved space for vector and I/O initalization data
;START OF BIOS DEFAULT VECTOR DATA AND HARDWARE CONFIGURATION DATA
;
;There are 96 bytes of ROM space remaining on page $FE from $FEA0 - $FEFF
; 64 bytes of this are copied to page $03 and used for soft vectors and hardware soft configuration.
; 32 bytes are for vectors and 32 bytes are for hardware the last 32 bytes are only held in ROM and
; are used for hardware configuration that should not be changed.
;
;The default location for the NMI/BRK/IRQ Vector data is at $0300. Layout definition is listed at the
; top of the source file. There are 8 main vectors and 8 vector inserts, all are free for base config.
;
;The default location for the hardware configuration data is at $0320. It is mostly a freeform table
; which gets copied from ROM to page $03. The default size for the hardware config table is 32 bytes.
;
VEC_TABLE	;Vector table data for default ROM handlers
;Vector set 0
			.DW	NMI_VECTOR	;NMI Location in ROM
			.DW	BRKINSTR0	;BRK Location in ROM
			.DW	INTERUPT0	;IRQ Location in ROM
;
			.DW	M_WRM_MON	;NMI return handler in ROM
			.DW	M_WRM_MON	;BRK return handler in ROM
			.DW	IRQ_EXIT0	;IRQ return handler in ROM
;
			.DW	M_MONITOR	;Monitor Cold start
			.DW	M_WRM_MON	;Monitor Warm start
;
;Vector Inserts (total of 8)
; these can be used as required, all are free for now, as NMI/BRK/IRQ and the Monitor are vectored,
; all can be extended by using these reserved vectors.
			.DW	$FFFF	;Insert 0 Location
			.DW	$FFFF	;Insert 1 Location
			.DW	$FFFF	;Insert 2 Location
			.DW	$FFFF	;Insert 3 Location
			.DW	$FFFF	;Insert 4 Location
			.DW	$FFFF	;Insert 5 Location
			.DW	$FFFF	;Insert 6 Location
			.DW	$FFFF	;Insert 7 Location
;
;Configuration Data - The following tables contains the default data used for:
;	- Reset of the SCC2691 (RESET_2691 routine)
;	- Init of the SCC2691 (INIT_2691 routine)
;	- Basic details for register definitions are below, consult SCC2691 DataSheet
; and Application Note AN405 for details and specific operating conditions.
;
; Mode Register 1 definition ($93)
;	Bit7		;RxRTS Control - 1 = Yes
;	Bit6		;RX-Int Select - 0 = RxRDY
;	Bit5		;Error Mode - 0 = Character
;	Bit4/3	;Parity Mode - 10 = No Parity
;	Bit2		;Parity Type - 0 = Even (doesn't matter)
;	Bit1/0	;Bits Per Character - 11 = 8
;
;	Mode Register 2 Definition ($17)
;	Bit7/6	;Channel Mode	- 00 = Normal
;	Bit5		;TxRTS Control - 0 = Yes
;	Bit4		;CTS Enable - 1 = Yes
;	Bit3-0	;Stop Bits - 0111 = 1 Stop Bit
;
;	Baud Rate Clock Definition ($CC)
;	Upper 4 bits = Receive Baud Rate
;	Lower 4 bits = Transmit Baud Rate
;	for 38.4K setting is %11001100
;	Also set ACR Bit7 = 0 for standard rates
;
;	Command Register Definition
;	Bit7-4	;Special commands
;	Bit3		;Disable Transmit
;	Bit2		;Enable Transmit
;	Bit1		;Disable Receive
;	Bit0		;Enable Receive
;
;	Aux Control Register Definition ($68)
;	Bit7		;BRG Set Select - 0 = Default
;	Bit654	;Counter/Timer operating mode 110 = Counter mode from XTAL
;	Bit3		;Power Down mode 1 = Off (normal)
;	Bit210	;MPO Pin Function 000 = RTSN (active low state)
;
;	Interrupt Mask Register Definition ($1D)
;	Bit7	;MPI Pin Change Interrupt 1 = On
;	Bit6	;MPI Level Interrupt 1 = On
;	Bit5	;Not used (shows as active on read)
;	Bit4	;Counter Ready Interrupt 1 = On
;	Bit3	;Delta Break Interrupt 1 = On
;	Bit2	;RxRDY Interrupt 1 = On
;	Bit1	;TxEMT Interrupt 1 = On
;	Bit0	;TxRDY Interrupt 1 = On
;
CFG_TABLE	;Configuration table for hardware devices
;Data commands are sent in reverse order from list. This list is the default initialization for
; the UART as configured for use as a Console connected to ExtraPutty. The data here is copied
; to page $03 and is used to configure the UART during boot up. The soft data can be changed
; and the the core INIT_2691 can be called to reconfigure the UART. NOTE: the Register offset
; data is not kept in soft config memory as the initialization sequence should not be changed!
INIT_DATA		;Start of UART Initialization Data
			.DB	%00010000	;Reset Mode Register pointer
			.DB	%10100000	;Enable RTS (Receiver)
			.DB	%00001001	;Enable Receiver/Disable Transmitter
			.DB	%00011101	;Interrupt Mask Register setup
			.DB	%01101000	;Aux Register setup for Counter/Timer
			.DB	%01001000	;Counter/Timer Upper Preset
			.DB	%00000000	;Counter/Timer Lower Preset
			.DB	%11001100	;Baud Rate clock for Rcv/Xmt
			.DB	%10010000	;Disable Counter/Timer
			.DB	%00001010	;Disable Receiver/Transmitter
			.DB	%10110000	;Disable RTS (Receiver)
			.DB	%00000000	;Interrupt Mask Register setup
			.DB	%00001000	;Aux Register setup for Power On
INIT_DATAE	;End of UART Initialization Data
;
;Mode Register Data is defined separately. Using a loop routine to send this data to the
; UART does not work properly. See the description of the problem using Indexed addressing
; to load the UART registers above. This data is also kept in soft config memory in page $03.
MR1_DAT	.DB	%10010011	;Mode Register 1 Data
MR2_DAT	.DB	%00010111	;Mode Register 2 data
;
;Reserved for additional I/O devices
			.DB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
;
;Reset UART Data is listed here. The sequence and commands do not require changes for any reason.
; These are maintained in ROM only. A total of 32 bytes is available for hard configuration data.
;These are the register offsets and Reset data for the UART
UART_RDATA	;UART Reset Data for Received Break (ExtraPutty/Terminal Send Break)
			.DB	%00000001	;Enable Receiver
UART_RDATA1	;Smaller list for entry level Reset (RESET_2691)
			.DB	%01000000	;Reset All Errors
			.DB	%00110000	;Reset Transmitter
			.DB	%00100000	;Reset Receiver
			.DB	%01010000	;Reset Break Change Interrupt
UART_RDATAE	;End of UART Reset Data 
;
INIT_OFFSET	;Start of UART Initialization Register Offsets
			.DB	$02	;Command Register
			.DB	$02	;Command Register
			.DB	$02	;Command Register
			.DB	$05	;Interrupt Mask Register
			.DB	$04	;Aux Command Register
			.DB	$06	;Counter Preset Upper
			.DB	$07	;Counter Preset Lower
			.DB	$01	;Baud Clock Register
			.DB	$02	;Command Register
			.DB	$02	;Command Register
			.DB	$02	;Command Register
			.DB	$05	;Interrupt Mask Register
			.DB	$04	;Aux Command Register
INIT_OFFSETE	;End of UART Initialization Register Offsets
;
;Reserved for additional I/O devices
			.DB	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
;
;END OF BIOS VECTOR DATA AND HARDWARE DEFAULT CONFIGURATION DATA
;******************************************************************************
;START OF TOP PAGE - DO NOT MOVE FROM THIS ADDRESS!! JUMP Table starts here.
				.ORG	$FF00	;BIOS JMP Table, Cold Init and Vector handlers
;	- BIOS calls are listed below - total of 32, Reserved calls are for future hardware support
; - "B_" JUMP Tables entries are for BIOS routines, provides isolation between Monitor and BIOS
;
B_Reserve00		JMP	RESERVE	;Call 00
B_Reserve01		JMP	RESERVE	;Call 01
B_Reserve02		JMP	RESERVE	;Call 02
B_Reserve03		JMP	RESERVE	;Call 03
B_Reserve04		JMP	RESERVE	;Call 04
B_Reserve05		JMP	RESERVE	;Call 05
B_Reserve06		JMP	RESERVE	;Call 06
B_Reserve07		JMP	RESERVE	;Call 07
B_Reserve08		JMP	RESERVE	;Call 08
B_Reserve09		JMP	RESERVE	;Call 09
B_Reserve10		JMP	RESERVE	;Call 10
B_Reserve11		JMP	RESERVE	;Call 11
B_Reserve12		JMP	RESERVE	;Call 12
B_Reserve13		JMP	RESERVE	;Call 13
B_Reserve14		JMP	RESERVE	;Call 14
B_Reserve15		JMP	RESERVE	;Call 15
B_Reserve16		JMP	RESERVE	;Call 16
B_Reserve17		JMP	RESERVE	;Call 17
;
B_CHRIN_NW		JMP	CHRIN_NW		;Call 18
B_CHRIN				JMP	CHRIN				;Call 19
B_CHROUT			JMP	CHROUT			;Call 20
;
B_SET_DLY			JMP	SET_DLY			;Call 21
B_EXE_MSDLY		JMP	EXE_MSDLY		;Call 22
B_EXE_LGDLY		JMP	EXE_LGDLY		;Call 23
B_EXE_XLDLY		JMP	EXE_XLDLY		;Call 24
;
B_INIT_VEC		JMP	INIT_VEC		;Call 25
B_INIT_CFG		JMP	INIT_CFG		;Call 26
B_INIT_2691		JMP	INIT_2691		;Call 27
B_RESET_2691	JMP	RESET_2691	;Call 28
;
B_WRMMNVEC0		JMP	(WRMMNVEC0)	;Call 29
B_CLDMNVEC0		JMP	(CLDMNVEC0)	;Call 30
B_COLDSTRT		JMP	COLDSTRT		;Call 31
;
COLDSTRT	SEI	;Disable Interrupts (safety)
					CLD	;Clear decimal mode (safety)
					LDX	#$00	;Index for length of page
PAGE0_LP	STZ	$00,X	;Zero out Page Zero
					DEX	;Decrement index
					BNE	PAGE0_LP	;Loop back till done
					DEX	;LDX #$FF ;-)
					TXS	;Set Stack Pointer
;
					JSR	INIT_PG03	;Xfer default Vectors/HW Config to $0300
					JSR	INIT_IO	;Init I/O - UART (Console/Timer)
;
; Send BIOS init msg to console	- note: X reg is zero on return from INIT_IO
;
BMSG_LP		LDA	BIOS_MSG,X	;Get BIOS init msg
					BEQ	B_CLDMNVEC0	;If zero, msg done, goto cold start monitor
					JSR	CHROUT	;Send to console
					INX	;Increment Index
					BRA	BMSG_LP	;Loop back until done
;
IRQ_VECTOR	;This is the ROM start for the BRK/IRQ handler
					PHA	;Save A Reg
					PHX	;Save X Reg
					PHY	;Save Y Reg
					TSX	;Get Stack pointer
					LDA	$0100+4,X	;Get Status Register
					AND	#$10	;Mask for BRK bit set
					BNE	DO_BRK	;If set, handle BRK
					JMP	(IRQVEC0)	;Jump to Soft vectored IRQ Handler
DO_BRK		JMP	(BRKVEC0)	;Jump to Soft vectored BRK Handler
NMI_ROM		JMP	(NMIVEC0)	;Jump to NMI soft vectored NMI handler routine
;
IRQ_EXIT0	;This is the standard return for the IRQ/BRK handler routines
					PLY	;Restore Y Reg
					PLX	;Restore X Reg
					PLA	;Restore A Reg
					RTI	;Return from IRQ/BRK routine
RESERVE		RTS	;Reserve call RTS
;
; This BIOS version does not rely on CPU clock frequency for any timings. Timings are based on the
; SCC2691 UART Timer/Counter which has a fixed frequency of 3.6864MHz and a Jiffy clock set at 10ms.
; NOTE: The SCC2691 UART can run with a CPU clock frequency up to 6MHz! Edit clock rate as needed.
;
			.ORG	$FFD0	;Hard code the BIOS message to the top of memory
;BIOS init message - sent before jumping to the monitor coldstart vector
;
BIOS_MSG	.DB	$0D,$0A
					.DB	"BIOS 2.01"	;Updated Release (minor)
					.DB	$0D,$0A
					.DB	"W65C02 @ 6MHz"	;Assumed CPU clock frequency
					.DB	$0D,$0A
					.DB "02/04/2018"	;BIOS Date - DD/MM/YYYY
					.DB	$00	;Terminate string
;
			.ORG	$FFFA	;65C02 Vectors:
					.DW	NMI_ROM	;NMI
					.DW	COLDSTRT	;RESET
					.DW	IRQ_VECTOR	;IRQ
					.END