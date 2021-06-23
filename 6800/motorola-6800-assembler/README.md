# Motorola 6800 Assembler

This repository contains the source code to build the Motorola Cross Assemblers for their 6800 family of 8bit processors.  This code was originally published in 1984 and then ported to the IBM PC and republished in 1987.  I want to give full credit to those you developed this code and my full respect for their work.

My intent is to keep the source code as close to the original as possible.  The original source code was written in pre-ANSI C, so it required some editing to bring it up the ANSI C standard.  It was also designed to have one main c file that included the correct *.h and *.c files to build the assemblers for the different microprocessors in the 6800 family.  I updated this to build each module into its own object file and then directed the linker to include the appropriate object files for the different assemblers for the various microprocessors.  I also added a directory structure where the source code is kept in the ./src directory, object files are placed in the ./obj directory, and binary files are place in the ./bin directory.

The code was ported to Linux and builds using the gcc compiler.

This module will build the following binaries for the specified Motorola microprocessors:

```
./bin/as0   6800/6802 processors
./bin/as1   6801 processor
./bin/as4   6804 processor
./bin/as5   6805 processor
./bin/as9   6809 processor
./bin/as11  68HC11 processor
```

## Compiling The Source Code

All you need to do to compile the assemblers is to go to the main directly for this repository and run make as in the example below.
```
cd /<path>/motorola-6800-assembler
make all
```
You can also build individual assemblers with statements similar to the following:
```
make as0
```
This will build just the 6800/6802 assembler.

You can enter the following command to remove all derived objects:
```
make clean
```
And you can remove all derived objects, binaries, and added directories with the following command:
```
make realclean
```

## Testing Your Binary

I've included a few programs written using the Motorola 6800 syntax.  The programs are examples from the MEK6802D5 Microcomputer Evaluation Board User's Manual.  The code is almost identical to the code in the book with the exception of the opt pre-assembler directive and the addition of a few comments of mine.  These programs are included in the ./test directory and can be used to verify the functionality of the assembler binaries.  A simple procedure follows that you can use to test the assemblers:
```
cd ./test
../bin/as0 used5.asm -l cre c s
```
Using the above command, the output to the terminal window from the as0 assembler should look like this:
```
<system>:~/motorola-6800-assembler/test$ ../bin/as0 used5.asm -l cre c s
0001                               *
0002                               *	    Copied from:
0003                               *	    MEK6802D5 Microcomputer Evaluation Board User's Manual
0004                               *	    Page 3-8
0005                               *
0006                               *	    Assemble with the following command:
0007                               *		as0 used5.asm -l cre c s
0008                               *
0009                                       nam     used5
0010                               *       Options set in file override command line option settings
0011                               *        opt     c       * options must be in lower case
0012 0000                                  org     $0
0013 e41d                          disbuf  equ     $e41d
0014 f0a2                          diddle  equ     $f0a2
0015 e419                          mnptr   equ     $e419
0016 f0bb                          put     equ     $f0bb
0017                               *
0018 0000 86 3e              [ 2 ] beg     ldaa    #$3e     "U"
0019 0002 b7 e4 1d           [ 5 ]         staa    disbuf   store to first display
0020 0005 86 6d              [ 2 ]         ldaa    #$6d     "S"
0021 0007 b7 e4 1e           [ 5 ]         staa    disbuf+1
0022 000a 86 79              [ 2 ]         ldaa    #$79     "E"
0023 000c b7 e4 1f           [ 5 ]         staa    disbuf+2
0024 000f 86 00              [ 2 ]         ldaa    #$00     blank
0025 0011 b7 e4 20           [ 5 ]         staa    disbuf+3
0026 0014 86 5e              [ 2 ]         ldaa    #$5e     "D"
0027 0016 b7 e4 21           [ 5 ]         staa    disbuf+4
0028 0019 86 6d              [ 2 ]         ldaa    #$6d     "5"
0029 001b b7 e4 22           [ 5 ]         staa    disbuf+5 store to last display
0030 001e 86 a2              [ 2 ]         ldaa    #diddle  adder of diddle routine
0031 0020 ff e4 19           [ 6 ]         stx     mnptr    establish as active sub of "PUT"
0032 0023 7e f0 bb           [ 3 ]         jmp     put      call display routine
0033                                       end

beg        0000
diddle     f0a2
disbuf     e41d
mnptr      e419
put        f0bb

beg        0000 *0018 
diddle     f0a2 *0014 0030 
disbuf     e41d *0013 0019 0021 0023 0025 0027 0029 
mnptr      e419 *0015 0031 
put        f0bb *0016 0032 
```

The as0 assembler produces the S-recored output file used5.s19.  This file is saved to the ./test directory.  A listing of the test directory should look like this:

```
<system>:~/motorola-6800-assembler/test$ ls -al
total 20
drwxrwxr-x 2 jim jim 4096 May 29 07:53 .
drwxrwxr-x 8 jim jim 4096 May 29 07:53 ..
-rw-rw-r-- 1 jim jim  657 May 26 18:56 help.asm
-rw-rw-r-- 1 jim jim  778 May 26 18:56 used5.asm
-rw-rw-r-- 1 jim jim  109 May 29 07:53 used5.s19
```

The first example, used5.asm, was written using only lower case characters and no tabs.  As a further test of the assembler, test case help.asm was written using only upper case characters along with tabs to set the spacing between the label, operator, operand, and comment fields.  You can assemble help.asm with the following command:

```
../bin/as0 help.asm -L CRE C S
```

This will produce the following output to the terminal window along with the help.s19 file being written to the ./test directory:

```
<system>:~/motorola-6800-assembler/test$ ../bin/as0 help.asm -L CRE C S
0001                               *
0002                               *	Copied from:
0003                               *	MEK6802D5 Microcomputer Evaluation Board User's Manual
0004                               *	Page 3-10
0005                               *
0006                               *	Assemble with the following command:
0007                               * 	as0 help.asm -L CRE C S
0008                               *
0009                               	NAM	HELP
0010                               *	Options set in file override command line option settings.
0011                               *	OPT	c		* options must be in lower case
0012                               *	OPT	cre		* one option per line
0013 0000                          	ORG	$0
0014                               * D5 DEBUT ROUTINES
0015 f0a2                          DIDDLE	EQU	$F0A2
0016 e41d                          DISBUF	EQU	$E41D
0017 e419                          MNPTR	EQU	$E419
0018 f0bb                          PUT	EQU	$F0BB
0019                               *
0020                               *
0021 0000 ce 76 79           [ 3 ] BEG	LDX	#$7679		"HE"
0022 0003 ff e4 1d           [ 6 ] 	STX	DISBUF		STORE TO FIRST 2 DISPLAYS
0023 0006 ce 38 73           [ 3 ] 	LDX	#$3873		"LP"
0024 0009 ff e4 1f           [ 6 ] 	STX	DISBUF+2
0025 000c ce 40 40           [ 3 ] 	LDX	#$4040		"--"
0026 000f ff e4 21           [ 6 ] 	STX	DISBUF+4	STORE THE LAST 2 DISPLAY
0027 0012 ce f0 a2           [ 3 ] 	LDX	#DIDDLE		ADDR OF DIDDLE ROUTINE
0028 0015 ff e4 19           [ 6 ] 	STX	MNPTR		ESTABLISH AS ACTIVE SUB OF PUT
0029 0018 7e f0 bb           [ 3 ] 	JMP	PUT		CALL DISPLAY ROUTINE

BEG        0000
DIDDLE     f0a2
DISBUF     e41d
MNPTR      e419
PUT        f0bb

BEG        0000 *0021 
DIDDLE     f0a2 *0015 0027 
DISBUF     e41d *0016 0022 0024 0026 
MNPTR      e419 *0017 0028 
PUT        f0bb *0018 0029 
```

## Documentation

I've included two files in the ./documentation directory.  File `assembler.txt` is the original documentation included with the sources for the assemblers.  The other file, `motorola_cross_asm_manual.pdf` is a manual for the Motorola assemblers that was published in 1990.  The information in this second file is not absolutely consistent with the assemblers used here, but it seems to be close and is a much more complete document than the text file.  So use at your own discretion.

That's it for now...

