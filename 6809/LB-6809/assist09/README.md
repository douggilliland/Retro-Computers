This is the source for the Motorola ASSIST09 machine language monitor provided for their development boards. There are several versions here:

assist09-orig.asm - The original version that used a 6820 PIA for serial i/o and breakpoints and ran on a Motorola development board.

assist09-6522.asm - A version that was ported by A VD Horst to run on a system using a 6522 VIA.

assist09-6850.asm - A port that runs on Jeff Tranter's single board computer that uses a 6850 ACIA. The trace command is not supported.

The files will assemble with the as9 assembler found at http://home.hccnet.nl/a.w.m.van.der.horst/m6809.html

ASSIST09 Command List:

	B (reak)	 <cr>	- list break points
			 NNNN	- insert break point
			-NNNN	- delete break point
			-	- delete all break points

	C (all)		 <cr>	- call routine at PC as subroutine
			 NNNN	- call routine at NNNN as subroutine

	D (isplay)  NNNN NNNN	- display range mod16
			 NNNN	- display 16 bytes [NNNN]mod16
			 M	- display 16 bytes [M]mod16
			 P	- display 16 bytes [PC]mod16
			 W	- display 16 bytes [W]mod16
			 @	- following NNNN, M, P, or W displays
				  16 bytes indirectly

	E (ncode)	Encodes a 6809 postbyte based on the
			addressing mode syntax as follows:

				R = X, Y, U, or S

				Direct Addressing Modes
				------ ---------- -----

				     ,R		A,R
				    H,R		B,R
				   HH,R		D,R
				 HHHH,R		,-R
				   HH,PCR	,--R
				 HHHH,PCR	,R+
						,R++

				Indirect Addressing Modes
				-------- ---------- -----

				    [,R]	[A,R]
				    		[B,R]
				  [HH,R]	[D,R]
				[HHHH,R]
				  [HH,PCR]	[,--R]
				[HHHH,PCR]
				[HHHH]		[,R++]

	G (o)		<cr>	- Go to PC
			NNNN	- Go to NNNN

	L (oad)		Load a S1-S9 format data

	M (emory)	NNNN	- Display memory data at address NNNN
			<cr>	- Terminate memory function
			/	- Display current byte with address
			.	- Display next byte with address
			^	- Display previous byte with address
			,	- Skip byte
			SPACE	- Display next byte

			The / may be used as an immediate command.

			After any of the display commands the memory contents
			may be alterred by inputting a valid hex number or
			ascii 'string' enclosed by single quotes (').

	O (ffset)  NNNN NNNN	- Calculate the two and/or three byte offset

	P (unch)   NNNN NNNN	- Punch a S1-S9 format data

	R (egister)	Display 6809 registers and allow changes

			<cr>	- terminate command
			SPACE	- terminate value input or
				  skip to next register
			,	- terminate value input or
				  skip to next register

	V (erify)	Verify memory against S1-S9 format data

	W (indow)	NNNN	- Define a display window for the
				  D and M commands.

	Ctrl-X will abort any command.
