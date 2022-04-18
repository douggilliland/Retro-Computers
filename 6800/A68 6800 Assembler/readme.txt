Contents of A68 ZIP file Feb 15 2019 HRJ

a68.exe	32-bit Windows command-line program
a68.c		A68 sources
a68.h
a68eval.c
a68util.c

swtb2.*	MIKBUG 6800 files assembled by A68

swtbugv10.lst MIKBUG 6800 listing, Motorola assembler format

test68.*	A68 opcode test ASM file, with Intel and Motorola
           hex files. 

Assembler currently produces 16-data-byte hex records. To change
length, reassemble with a68.h value HEXSIZE changed to desired length.

From http://www.retrotechnology.com/restore/a68.html

A68 6800 cross-assembler
A68 6800 cross-assembler
Last update Feb 5 2022. Edited by Herb Johnson, (c) Herb Johnson, except for content written by others. Contact Herb at www.retrotechnology.com, an email address is on that page..

Introduction:
This Web page is about a 2011 adaptation of the A68 cross-assembler to support 6800 assembly for various of my vintage computing projects. My current version of A68 will be at this Web link. The program runs under Windows (XP, 2000) as an MS-DOS 32-bit executable. That EXE will run under the DOS command prompt which is available in most Windows versions. Sometimes it's call the DOS commmand line. As for the assembler, I provide the C sources with my changes clearly marked. There are docs and sample assembly code. Check the "bugs and fixes" section below for any changes.

New for Feb 2022 is a S-record to binary conversion program.

I restore vintage computers of the 1970's and I support S-100 computers of the 70's and 80's and some others. That also includes SS-50 computers which use the 6800 or 6809 microprocessor, including this SWTP 6800 computer. I also assisted with some work on and Altair 680b 6800 computer. aAnd I owned a Motorola MEK6800D2 for awhile.- Herb

A68 history
A68, one of a series of 8-bit cross assemblers written in C, was freely distributed by the developer William C Colley III, through the "C Users Group" library of C programs of the 1980's and later. CUG "diskette" 267 has A68 and other assemblers. I (Herb Johnson) obtained that A68 copy, and adapted the C code to compile under the lcc-win32 Windows/MS-DOS C compiler to produce an MS-DOS command-line 32-bit executable. Check the A18 Web page for details on lcc-win32.

I contacted the author of A68 some years ago, when I adapted A18, another of his assemblers. He had no objections to that use of his work. Again, see this A18 Web page of mine for A18, and his response. Also go there, for more information about use of all these Colley assemblers, links to his other cross-assemblers for other microprocessors which I support. It's possible any questions you have about A68, can be answered on the A18 Web page.

Bugs & fixes, problems with running on Windows computers, more
Always, always, "read the fine manual" for more information about operation of A68.

Feb 2022: insufficient arguments for the instruction

A68 did not test for a condition, where no arguments were given after the instruction mnemonic, if the instruction needed arguments (a byte or two bytes of values). It failed to provide the correct opcode and assumed two zero bytes of value. But worse, it did not flag this as an error. This is now fixed and flagged as an "S" error (Syntax) and a plausible opcode with two zero bytes is passed to the listing and hex file. Since 6800 assemblers use the number of arguments to determine the opcode, and not the other way around, I can't second-guess if it needs one or two bytes of argument. But if NO bytes of argument are acceptable, then a lack of arguments is not an error.

This appears to be a successful fix. But watch out in your 6800 programming, for providing the wrong operand expression to a 6800 instructions. You will get a legal result but it may not be the operation you intended.

Jan 2022: NOT, LOW operations, extended vs immediate addressing

The NOT operation didn't preserve the byte or word value of its operand. Now it does, to the extent that 16 bit values with a high-byte of 00H are treated as byte-values. That matters in representing 7-bit plus sign values as byte values. See the disucssion below. Please inform me if the result is unsatisfactory: include examples please.

The 6800 assemblers from Motorola and others, have a feature started by Motorola. For immediate instructions as indicated by a "#" prefix on their operands, the Motorola assemblers choose an immediate opcode followed by the operand byte value. That value is limited to 0-0FFH (0-255D) as one would expect, plus -127 to -1 as a seven-bit plus sign value. A68 enforces that rule and may flag with a V error any immediate operand that exceeds those values. For non-immediate instructions called extended instructions, A68 assembles either an immediate opcode for operands from -127 to +255; or an extended opcode for operands 0-0FFFFH. Inform me if A68 does not produce a desirable result and include examples from both A68 and whatever-other assembler you are comparing it to.

One can force the selection to immediate with the "LOW" unary operator. Some 6800 assemblers have a unary operator "<" for that purpose. I don't have a "WORD" unary operator to force a word-size. See if you can fake it with say "value+0000H" or "value OR 0000H". But a value 0100H to 0FFFFH is a word-sized value already. The distribution ZIP file has example 6800 source to exercise this issue. Inform me if A68 does not produce a desirable result and include examples from both A68 and whatever-other assembler you are comparing it to.

Feb 2021: A68 doesn't support pseudo-ops like DB, DW, DS - That is true. Motorola's definitions for 6800 assembly, used FCB, FCC, FDB, RMB to define bytes, words, space and characters. It is not hard to add the Intel-like pseudo-ops to the A68 source. If I get asked to do so enough, I will. I've done so with other Colley assemblers.

Jan 2020: no JSR page 0 instruction? In discussion with an Altair 680 owner, he mentioned using another cross-assembler with an error in JSR assembly. I looked at my A68 for JSR instructions. They are:

01ce   9d 00         		JSR	DIRECT <-- this would be an error!
01ee   ad 00         		JSR	X, OFFSET
021b   bd 01 00      		JSR	EXTENDED
In documentation for the 6800, I find the AD and BD codes for offset and extended JSR's. "9D" is not supported on the 6800. It would in principle be a JSR direct-mode (call a page 0 byte addressed program) instruction. There's a series of 9X instructions in direct mode, that use page 0 byte values. It's not consistent to "call" a page-zero location to run a program there. Or so it seems to me. A68 only generates 0xAD or 0xBD for JSR instructions. If there's no operand for JSR, A68 generates an 0x8d instruction (happens to be BSR) but correctly flags the line as a "S"yntax error. [updated Feb 5 2022]

Aug 2019: added support for comment lines when "*" is in column 1. Comments in A68 assembly source, must otherwise begin with a semicolon ";". Motorola format for comments allowed any text after the opcode and operands to be accepted as comments. This A68 assembler doesn't accept that, you'll have to add a ";" before the comment, sorry. - Herb

Aug 2019: A or B register arguments Greg Simmons called to my attention, that early Motorola assemblers accepted assembly code like "ADD A,1", but later assemblers insist on "ADDA 1". I've documented that A68 accepts either syntax for those single-register instructions. Check the test assembly program included with A68, and the A68.DOC manual.

Feb 2019: A68 produces either Intel hex records or Motorola S-records. Intel hex records are a common format for all these Colley cross-assemblers; most PROM programmers accept Intel records. I added S-records as an alternative: read the documentation for details. A pure binary output is also possible, see my A18 cross assembler which has that option.

Note that A68 doesn't accept pure Motorola ASM syntax. Like the other Colley assemblers, it expects an Intel like format. Of course A68 accepts Motorola 6800 mnemonics and operands. With some effort one can re-edit the differences. For instance every comment must begin with a ';'; column 1 '*" comment lines must also begin with a ';'. Character constants like '? must be in paired single quotes like '?'. Again, "read the fine manual". I include a MIKBUG 6800 listing in both Motorola and A68 format for reference.

I have a number of these old MS-DOS cross assemblers on my Web site. Running them on today's Windows computers is challenging for some people. I've gathered my notes on the subject, on the Web page on the A18 1802 cross assembler. Read that page please. A18 is the most-updated and modified version of these cross assemblers. A68 is not updated. So look at A18 for any features you might request for A68.

For those who download this program, please advise me of any errors and issues. I make zero guarantees, offer zero warrenties. I am not responsible for any loss, injury or damage to person or property of any sort. Use entirely at your own risk.

Aug 2015: "Your A68 program deletes itself and does nothing!" Well, that's likely an issue with your anti-virus protection. Check this note for specifics. Also read the A18 Web page as noted above.

July 2018: To compile under Borland's MS-DOS based Turbo C, all I had to do was change a "malloc()" call to a "alloc()" call. Both a Win32 executable and the 16-bit MS-DOS executable are included in the Zipped package. If you don't know what I'm talking about, look for the details on my A18 1802 Web page. - Herb Johnson

6800 MIKBUG, SWTBUG: My friend Bill Beech, has some monitor programs for the 6800, among other microprocessors. Look on his site for software monitors and see MIKBUG and SWTBUG among them. If you must have a Motorola-format 6800 assembler, , he has some assemblers.

- Herb Johnson

Contact information:
Herb Johnson
New Jersey, USA
To email @ me, see see my home Web page.
This page and edited content is copyright Herb Johnson (c) 2022. Copyright of other contents beyond brief quotes, is held by those authors. Contact Herb at www.retrotechnology.com, an email address is available on that page..
