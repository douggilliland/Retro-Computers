This is a new version (v 2.0.9) of the 8080\z80\z180 assembler and 8080/Z80 Disassembler (v 1.0.13)
(8:12 AM 9/29/14)

Requires Courior New Font

The assembler uses Intel Mnemonics with TDL extensions.

The Disassembler generates either Zilog or Intel with TDL extensions. 

The Assembler was originally written to bootstrap a Z80 system with CPM/80. It is not designed to be an everyday assembler. But it will assemble most CPM source without modifications to the source. It uses symantics from several different assemblers, so it will assemble most stuff with little or NO modifications.

It has been hacked to provide much compatability with MAC. A recursive parser and complete recursive expression evaluation has been added. Plus Macro capabilities simular to MAC's.

You may save the results as a listing, Motorola sRec, Intel Hex, binary, or a DDT input file. The DDT view consists of the DDT commands to load memory, and can be cut and pasted to a terminal program to make DDT load memory with the results.

You can edit the resulting "View"s but this does not affect the source file.

Errors are printed before the line with the error

Assemble the sample sources to see what is and is not allowed. These are sources, which I used to test the assembler. There are lots of errors and warnings... that's normal for the sample files.

-----

Included is a Disassembler which produces  source code which the Assembler can assemble. The Disassembler can produce code which can be assembled by ASM or MAC. Z80 instructions can be either Zilog mnemonics or in TDL format, NOT MACLIB format. 

The file extension is used to determine binary or text format. The Disassemler will disassemble files with a .bin, .com, .hex, .mx or .dump extension.

DR's DUMP ascii formated files can be disassembled.(but not recommended) Addressses are extracted from the dump file. The dump may contain ASCII representations at the end of the line.

Binary files can be disassembled. Addressses are sequential starting at the address specified in the Offset field. To disassemble a binary image of a ROM origined at F000h, put "f000" in the "Offset" box, then , open a .bin or .com file. Click "Disassemble".

HEX and SREC files are loaded according to the addresses in the file. The disassembler can also load symbols found in a HEX file. 

"Save" will save the current "View" results in whatever format is listed in the "Save Format" selector.

"Listing" presents a view that looks like an assembler listing of the disassembled file. Instructions will be Color Coded.

"Source" presents a view that looks like the assembler source of the disassembled file.

"Hex" presents a view that looks like a hex dump of the disassembled file.

"Binary" presents a binary statistics view. You can save a binary image of the disassembled file.

You can also save as an iHEX file with symbols. 

-----

Included is a program which can convert a binary or a dump listing into commands which can be used to Set memory with DDT or the SD systems firmware monitor. (not usesful to most)

------

None of these programs are guaranteed to work in every situation in which one may wish to use them. They may contain bugs which produce erroneous binary code. The programs may contain bugs which cause them to abend. Once you have a workable cpm system, use the commercial development programs to produce a final system.

See individual help files. Context help is availible by pressing the F1 key.

----
--Assembler
----


---Numeric values

Numeric values can be numbers in hex dec oct or binary or single quoted chars

123 5d6h 377o 101010b &h8d &o377

'a'  '6'  '='  '"'  '''


---Symbolic values

Symbols can be case sensitive

Xyz is a different symbol than xyz or XYZ or xYz

Any symbol which starts with two periods is a redefinable backward reference

symbolic values may be preceded by # to logically NOT the symbol's value
	(NUMERIC values can not be NOTted by a #)

	mvi	a,#xyz|1010b

Symbols can NOT be constructed which contain a separator (space, comma, semicolon, colon, tab, lf, cr)
Symbols can be defined which contain operators, but can NOT be referenced.
Symbols can be defined which appear to be numeric values, but can NOT be referenced.

---Expressions

Expressions are handled by a recursive parser which allows hust about anything that you can do in most high level languages.


---Operators

+ 	addition
- 	subtraction
* 	Multiplication
\ idiv	integer division
/ 	division
% mod 	modulo
|or 	logical OR
& and 	logical AND
xor 	logical exclusive OR
^	raise to a power

---Directives

org
set
equ
ds
db	- single quoted chars, expressions an quoted strings allowed 
dw	- single quoted chars allowed but no strings
text,dt	- one multicharacter string allowed
	 (fisrt char of operand is the quote mark char)

	text	'He said, "string"'		; ' is the quote mark
	dt	"string's"			; " is the quote mark
	text	qHe asked, "What's he doing?"q	; q is the quote mark

textz	- string terminated with null(0)
texts	- string terminated with last byte's sign bit set

z80	- no warning on z80 use
z180	- no warning on z180 use
i8080	- default - warns on z80 use

end	- specifies starting address for Srecs and HEX files(default =0)

page	- does nothing
title	- does nothing

if ift ifnz ifne -assembles if operand expression is not 0 (true=not 0)
iff ifz	ifeq	 -assembles if operand expression is zero (false = 0)

ifgt		 -assembles if operand expression is greater than 0
ifge		 -assembles if operand expression is greater than or equal 0
iflt		 -assembles if operand expression is less than 0
ifle		 -assembles if operand expression is less than or equal 0

else		
endif

---Labels


Any label which starts with two periods is a redefinable backward reference

..loop	mvi 	m,6
	dcx	hl
	jnz	..loop	; jumps to ..loop at MVI instruction
..loop	dcr 	b
	jz	..loop	; jumps to ..loop at DCR instruction 

A label can be terminated with a :(colon)

label: jmp	label

Labels may start in a column other than column one if and only if the label is terminated by ':'

The bang '!' is a logical line separator

----
--Disassembler
---

The disassembler can accept either a raw binary file (.bin, .com)or a text representation file (iHex, Srec, Dump).

If input is a binary file you must specify the Origin. Default is 0100h.

If input is a dump listing, the addresses must be contiguous and all lines must contain 16 bytes of data. If not, the program may crash. Prior to using a dump listing you must edit it to ensure that there are 16 bytes per line and that the addresses are contiguous. Ascii listings at the end of each line are allowed and are ignored.

You may save a listing(simular to an assembler listing),or a source file which can be edited and assembled by the included assembler, or a dump listing, or a binary file.

If you have a dump listing and you want to create a binary file, after loading use the view binary and save. A binary file will be created. 

If you have a binary file and you want to create a dump listing, load and after "Make Dump" use the view Hex Dump and then save. A dump listing file will be created. 

You can also save as iHex with symbols.

----
-- BinToSde
---
This program i depricated. It originally served to download a program into a real s100 bus Z80 system, via a serial link. 

BinToSde is a kludge. It can convert a binary file to either DDT set memory format or SDsystems firmware monitor Examine memory format or a dump listing. The resulting data can either be pasted to the a terminal tranfer program or saved and sent latter as a text file to the a target system. If DDT or equivalent is running, as data is sent via a terminal tranfer program, data from the original binary will be loaded into memory. Afterward you may use the CPM save command to write it to disk.

If a binary file is to large to fit into available memory, BinToSde can be used to break the large file into 16k or smaller blocks. Each chunck can be tranfered to cpm and then concatenated with PIP (use binary/object option - o)to create the original file. To accomplish, check "direct" and "split" and "binary". The original binary will be split into smaller files named "out0.bin" though "outX.bin"

To create a dump listing of a binary file, check "dump" then save as text. If you select "direct" an output file named out0.dmp is created with out having to "save". If you dont check "direct" then you may save with any name you chose. "Binary", also, only, creates a file directly.

(The BinToSDE program was writen and modified as needed, it is a kludge, it does not attempt to prevent you from making errors. All controls remain enabled whether they are valid for the choosen function or not. When "direct" is chosen, this program writes to only a fixed set of filenames. If they already exist, they will be deleted first!) This is to break a large transfer into many smaller transters. 

-----

Here are the nmemonics for the z180

			z180
0000	ED83		otim		
0002	ED93		otimr		
0004	ED8B		otdm		
0006	ED9B		otdmr		
0008	ED387C		in0	a,07ch	
000B	ED007C		in0	b,07ch	
000E	ED307C		in0	m,07ch	
0011	ED397C		out0	07ch,a	
0014	ED017C		out0	07ch,b	
0017	ED317C		out0	07ch,m	
-ix or iy NOT allowed - 5(ix),07ch
001A	DDED30057C	in0	5(ix),07ch	
001F	ED4C		mult	bc	
0021	ED5C		mult	de	
0023	ED6C		mult	hl	
0025	ED7C		mult	sp	
-Illegal use of  - ix
0027	ED6C		mult	ix	
0029	ED04		tst	b	
002B	ED0C		tst	c	
002D	ED34		tst	m	
002F	ED6455 		tsti	055h	
0032	ED747C 		tstio	07cH	
    