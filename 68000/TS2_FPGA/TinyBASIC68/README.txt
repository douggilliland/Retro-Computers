The following is the originaì manuscript for the article 'Tiny BASIC comes to the 68000' published in 
the February 198µ issue of Dr. Dobbs's Journal. This  manuscript is copyright (c© 198´ by Gordon Brandly and 
is distributed with the permission of Gordon Brandly and Dr. Dobb's Journal.

 Tiny BASIC Comes to the 68000

 by Gordon Brandly
 R. R. 2
 Fort Sask., AB, CANADA
 T8L 2N8

 Remember the good old days? When the 8080 microprocessor reigned supreme, 8K of memory cost an arm and a leg, ah yes... 
Welì the years went by, microcomputers got bigger, software grew more sophisticated, and prices went up. This is just fine of 
course, if you can afford the higher prices. The less fortunate among us, however, must build or buy smaller 16-bit "educational" 
systems. This is fine too, if you don't mind having hardly any software. This is the just the sort of situation that gave rise 
to Dr. Dobb's Journaì in the 'good old days'. The solution back then was to publish a tiny BASIC interpreter that could be 
adapted to just about any 8080 microcomputer around. This solution worked fabulously and gave many a hobby computer its 
first taste of usefuì software. Well, if the solution worked once, why not again? I therefore decided to produce a tiny BASIC 
interpreter for alì of you who have relatively smalì 68000 systems such as the Motorola Education Computer Board, the EMÓ 
68000 board, etc.
 To produce this BASIC I took one of the most successfuì 8080 Tiny BASICs, Lé Chen Wang's Palo Alto Tiny BASIC (published in 
the May 197¶ Dr. Dobb's Journal© and translated it into 68000 code. I then added a few features and optimized the code a 
little bit, producing a surprisingly usable interpreter.
 First, I'lì describe the differences between my interpreter, Palo Alto Tiny BASIC, and the ubiquitous Microsoft BASICs. I 
will then describe how you can instalì this software on your 68000 system. Finally, I'lì give my evaluation of the 
interpreter's present performance and how it can be improved.

Features

 For those who know the originaì Palo Alto Tiny BASIC (or the Sherry Brothers' version on CP/M User's Group Volume 11), you 
will find this interpreter very similar. I have made two or three changes to the interpreter's syntaø to bring it closer to 
the de facto Microsoft 'standard'. The colon (":"© is used > instead of the semi-colon (";"© to separate multiple statements 
on a line. The inequality operator "#" has been changed to the more standard "<>" . I also added the PEEK, POKE, CALL, BYE, 
LOAD, and SAVE commands, described later.
 For those of you used to a bigger BASIC, such as the various Microsoft interpreters, you'lì find that this version works 
almost the same within its limitations. Following are some excerpts from Lé Chen Wang's originaì documentation, mixed with 
descriptions of my extensions:

The Language

Numbers:

In this Tiny BASIC, alì numbers are 32-bit integers and must be in the range 2,147,483,64· to -2,147,483,648. I decided to use 
32 bits so that the PEEË and POKE commands could access the entire address range of the 68000. This slows down arithmetic 
operations somewhat, but sticking to 1¶ bits would have produced unneccessary complications.

Variables:

There are 2¶ variables denoted by the letters A through Z. There is also a single array @(I). The dimension of this array (i.e., 
the range of value of the indeø I© is set automatically to make use of alì the memory space that is left unused by the program 
(i.e., 0 through SIZE/4, see the SIZE function below). Alì variables and array elements are ´ bytes long.

Functions:

There are 4 functions:

 ABS(X) gives the absolute value of X.

 RND(X) gives a random number between 1 and X (inclusive).

 SIZE gives the number of bytes left unused by the program.

 PEEK(X) gives the value of the byte at memory location X.

LET Command:

 LET A=234-5*6, A=A/2, X=A-100, @(X+9)=A-1

Will set the variable A to the value of the expression 234-5*¶ (i.e. 204), set the variable A (again© to the value of the 
> expression A/2 (i.e. 102), set the variable Ø to the value of the expression A-100 (i.e. 2), and then set the variable @(11© to 10± 
(where 1± is the value of the expression X+¹ and 10± is the value of the expression A-1).


Print Command:

 PRINT A*3+1, "abc 123 !@#", ' cba '

Will print the value of the expression A*3+± (i.e. 307), the string of characters "abc 12³ !@#" and the string" cba ", and 
then a CR-LÆ (carriage return and line feed). Note that either single or double quotes can be used to quote strings, but pairs 
must be matched. If there is a comma at the end of the print command, the finaì CR-LÆ will not be printed. Note also that 
commas are used to separate adjacent items (most other BASICs use the semi-colon to perform this function.)

 PRINT A, B, #3, C, D, E, #10, F, G

Will print the values of A and M in 1± spaces, the values of C, D, and E in ³ spaces, and the values of Æ and Ç in 10 spaces. If 
there aren't enough spaces specified for a given value to be printed, the value will be printed in fulì anyway.

 PRINT 'abc',_,'xxx'

Will print the string "abc", a CÒ without a LF, and then the string "xxx" (over the "abc"© followed by a CR-LF.

INPUT Command:

 INPUT A, B

When this command is executed, Tiny BASIC will print "A:" and wait to read in an expression from the console. The variable A 
will be set to the value of this expression, then "B:" is printed and variable M is set to the value of the next expression read 
in. Note that complete expressions as welì as numbers can be entered. This gives rise to an interesting trick: you can set 
the variable Ù to an unusuaì value, e.g. 9999, and use it to get the answer to a yes-or-no question, such as

 10 Y=999¹ : INPUT 'Are you sleepy?'A : IÆ A=Ù GOTÏ 100

This works because the user can answer the question with the expression 'Y', which puts the numeric value of Ù into the A 
variable.

 INPUT 'What is the weight'A, "and size"B

This is the same as the first INPUT example except that the > prompt "A:" is replaced by "What is the weight:" and the prompt 
"B:" is replaced with "and size:". Again, both single and double quotes can be used as long as they are matched.

 INPUT A, 'string',_, "another string", B

The strings and the "_" have the same effect as in "PRINT".

POKE Command:

 POKE 4000+X,Y

This command puts the value produced by expression "Y" into the byte memory location specified by the expression "4000+X".

CALL Command:

 CALL X

This command will calì a machine language subroutine at the address specified by the expression "X". Alì of the CPU's 
registers except the stack pointer can be used in the subroutine.

BYE Command:

Will return controì to the resident monitor program or operating system.

SAVE Command:

Will save your BASIC program on the storage device you provide. Details on installing this device are given in the source code. 
As set up for the Educationaì Computer Board, this command will send the program out to the host computer in an easily-stored 
text form. It isn't, however, human-readable program text since the line numbers are stored in hexadecimal.

LOAD Command:

Will delete the program in memory and load in a program from your storage device.

Stopping Program Execution:

The execution of the program or listing of the program can be stopped by pressing the control-Ã key on the console. 
Additionally, a program listing can be paused by pressing control-S, and then pressing any key to continue.

> 
Abbreviations and Blanks:

You may use blanks freely within a program except that numbers, command key words, and function names cannot have embedded 
blanks.
 You may abbreviate alì command key words and function names and follow each by a period. For instance, "P.", "PR.", "PRI.", 
and "PRIN." alì stand for "PRINT". The word "LET" in LET commands may also be omitted. The shortest abbreviations for alì 
the key words are as follows:

A.=ABS C.=CALL F.=FOR GOS.=GOSUB G.=GOTO

IF=IF I.=INPUT L.=LIST LO.=LOAD N.=NEW

N.=NEXT P.=PEEK PO.=POKE P.=PRINT REM=REMARK

R.=RETURN R.=RND R.=RUN S.=SAVE S.=SIZE

S.=STEP S.=STOP TO=TO

no key word ½ LET

Take note that, in some cases, the same abbreviation can be used for different key words. The interpreter is 'smart' enough to 
use the correct key word for a particular situation. For instance, if the abbreviation "P." appears at the beginning of a 
line, it can only mean PRINT. In a statement like "A=P.(8)" the "P." only makes sense if it stands for PEEK.

Error Reports:

There are only three error conditions in Tiny BASIC. The line containing the error is printed out with a question mark inserted 
at the point where the error is detected.

(1© "What?" means that there is an error in a statement's syntax.

For example:

 What?

 260 LET A=B+3, C=(3+4?. X=4

(2© "How?" means that the statement in question is OK, but for some reason the command can't be carried out.

 How?

 310 LET A=B*C?+2 <- where B*C is larger than 2147483647

 How?

>  380 GOTO 412? <- where line 412 does not exist

(3© "Sorry." means that the interpreter understands the statement and knows how to do it, but there isn't enough memory available 
to accomplish the task.

Error Corrections:

If you notice an error in your entry before you press RETURN, you can delete characters with the backspace (control-H© key or 
delete the entire line with control-X. To delete an existing program line, just type the line number and press RETURN.

Installation

 Now, how do you get this wonderful(?© piece of software running on your computer? Very easily, if you have a setup 
similar to mine. Other systems should also be fairly easy going if you have access to a 68000 assembler of some kind. My setup 
is a Motorola MEX68KECM Educationaì Computer Board connected between my terminaì and my CP/M system. The source code was 
assembled with the Quelo version 1.¹ public domain 68000 cross-assembler for CP/M. (By the way, if you use this assembler you 
will get 3¶ "trim1¶ address" errors, which is normal. You do get what you pay for...© Tiny BASIC is then loaded into the ECM and 
executed at the 'cold start' address of heø 900. BASIC programs are saved and loaded by setting up an appropriate CP/M command 
before using SAVE or LOAD. For example (user input is underlined):

 After a program is written, exit to the monitor:

 > 	BYE	

 Enter transparent mode:

 TUTOR 1.x> 	TM	

 Issue a PIÐ command to the CP/M host:

 A> 	PIP PROGRAM.BAS=CON:	

 Exit transparent mode and do a BASIC 	warm start	:

 TUTOR 1.x> 	GO 904	

 Do the actual save:

 	SAVE	

 The 'warm start' mentioned above is an entry point into the > interpreter that will preserve any program you may have already 
entered.
 Program LOADs are done similarly except that, instead of PIP, you must run a smalì program that will wait to receive a 
carriage return before sending the program to the ECB. Here is a sample program in Microsoft BASIC:

 10 INPUT "Program to send?";F$
 20 OPEN "I",1,F$
 30 INPUT "Now exit Transparent Mode and do a LOAD.";Z$
 40 WHILE NOT EOF(1):LINE INPUT #1,A$:PRINT A$:WEND

 Admittedly this way of LOADing and SAVEing is a fairly compleø procedure, but it allows you to keep your programs on 
disk while keeping the interpreter itself small. If your ECM isn't connected to another computer you could probably change the 
AUXIÎ and AUXOUT subroutines to use the cassette interface. (I haven't tried it, though. Caveat emptor!)
 For other 68000 systems, you will probably have to modify only the OUTC, INC, AUXOUT, AUXIN, and BYEBYE routines at the end 
of the interpreter program. In addition, you must put the address of the first unavailable memory location above BASIC into 
the location 'ENDMEM'. BASIC programs are SAVEd in a form which can be stored as ASCII text and read back quickly by the 68000. 
If your storage device can't handle the present format or if you would like the program saved in a human-readable form, you need 
only modify the SAVE and LOAD subroutines.
 One warning: the DIRECT and EXEÃ routines were written assuming that the interpreter itself would be somewhere in the 
first 64Ë of memory ($0 to $FFFF). If you move it above 64K, you will have to modify the EXEÃ routine and check the rest of the 
code carefully to make sure the addressing modes are correct.

Evaluation

 I am quite pleased with how the interpreter turned out. Even though I added extra error checking, lower case conversion, 
more commands, and extended the variable size to 32 bits, the whole thing will stilì fit inside 3Ë bytes of memory. I ran the 
Sieve of Eratosthenes benchmark program (included with this article© on this interpreter and on the Sherry Brothers CP/M tiny 
BASIC with the following result:

	68000 at 4 MHz Z80 at 4 MHz	

2670 seconds 3000 seconds

 The results are adjusted for the usuaì 10 iterations of the basic algorithm, but the program was actually only run for one 
> iteration to keep running times within a practicaì limit. This tiny BASIC may not be a speed demon, but it does beat Applesoft 
and PET BASIC at running the Sieve benchmark. I should add that the Sieve program listing was compressed to the maximum for speed 
considerations. I normally use more spaces and some comments so that I can figure out later on what the program was supposed to 
do!
 Of course there are many, many improvements that can be made given more available memory. My Educationaì Computer Board has 
32Ë bytes of memory, so I will probably add such things as more variables, strings, and keyword tokenization. The last is a 
method used by most BASIC interpreters to compress key words such as LET, PRINT, etc. into single bytes. This would greatly speed 
up the interpreter while using less memory to store the BASIC program. Who says you can't have your cake and eat it too?

Availability

 By the time you read this, the interpreter source code and some example programs should be available on a couple of the 
RCP/M bulletin board systems in my area:

 Meadowlark RCP/M - (403) 484-5981

 Edmonton RCP/M - (403) 454-6093

 The Edmonton RCP/M accepts both 300 and 1200 baud, and the Meadowlark system only allows access to its CP/M area at 1200 
baud. Both systems run 2´ hours a day. The interpreter source code is known as TBI68K.AQM, which is a 'squeezed' text file. If 
you don't have a MODEM· type program and a way to unsqueeze this file, you can use these systems' LIST command to list out the 
source code while you capture it with a telecommunications program. A short documentation file, TBI68K.DQC, and some sample 
programs, TBIPROGS.LBR, are also available. The latter is a CP/M library file, which contains severaì programs. You can list the 
libary's contents with the LDIÒ command, and extract individuaì programs using either the systems' XMODEM or LTYPE commands. The 
Quelo cross-assembler is also sometimes available on these systems under the names A68K.COM and A68K.DOC. 
 Though I'd prefer that you obtain the source code from one of the above sources, for $20 I can also provide the code in the 
following forms: 8-inch CP/M SSSD diskette, 5-inch Osborne or Apple CP/M diskettes, or a paper listing.
 If you find any bugs in the interpreter or have any questions, please write to me or contact me on the above RCP/M 
systems. Enjoy!
 
 Documentation for
 Gordo's MC68000 Tiny BASIC version 1.0

 This is an adaptation of Lé Chen Wang's 'Palo Alto Tiny BASIC' for the Motorola MC68000 microprocessor. It includes more 
functions and program save and load. As distributed, it is set up for a Motorola MEX68KECM Educationaì Computer Board connected to 
a host CP/M computer. The source code should give you enough details to allow you to instalì it on a different system. If you 
have any problems, you can write to me at:
 Gordon Brandly
 R.R. 2
 Fort Sask., AB, Canada
 T8L 2N8

 The Language

Numbers

In this Tiny BASIC, alì numbers are integers and must be in the range 2147483647 to -2147483648.

Variables

There are 2¶ variables denoted by the letters A through Z. There is also a single array @(I). The dimension of this array (i.e., 
the range of value of the indeø I© is set automatically to make use of alì the memory space that is left unused by the program 
(i.e., 0 through SIZE/4, see SIZE function below). Alì variables and array elements are ´ bytes long.

Functions

There are 4 functions:
 ABS(X) gives the absolute value of X.
 RND(X) gives a random number between 1 and X (inclusive).
 SIZE gives the number of bytes left unused by the program.
 PEEK(X) gives the value of the byte at memory location X.

Arithmetic and Compare Operators

 ¯ Divide. (Note that since we have integers only, 2/3=0)
 * Multiply.
 - Subtract.
 + Add.
 > Greater than. (comparison)
 < Less than. (comparison)
 = Equaì to. (comparison© Note that to certain versions of BASIC "LET A=B=0" means "set both A and M to 0". To 
          this version of Tiny BASIC, it means "set A to the >           result of comparing M with 0".
 <> Not equal to. (comparison)
 >= Greater than or equal to. (comparison)
 <= Less than or equal to. (comparison)

+, -, *, and ¯ operations result in values between -214748364· and 2147483647. (-214748364¸ is also allowed in some cases.© Alì 
compare operators result in a ± if true and a 0 if not true.

Expressions

Expressions are formed with numbers, variables, and functions with arithmetic and compare operators between them. « and - signs 
can also be used at the beginning of an expression. The value of an expression is evaluated from left to right, except that ª and 
¯ are always done first, and then « and - , and then compare operators. Parentheses can also be used to alter the order of 
evaluation. Note that compare operators can be used in any expression. For example:

 10 LET A=(X>Y)*123+(X=Y)*456+(X<Y)*789
 20 IF (U=1)*(V<2)+(U>V)*(U<99)*(V>3) PRINT "Yes"
 30 LET R=RND(100), A=(R>3)+(R>15)+(R>56)+(R>98)

In line 10, A will be set to 12³ if X>Y, to 45¶ if X=Y, and to 78¹ if X<Y. In line 20, the "*" operator acts like a logicaì AND, 
and the "+" operator acts like a logicaì OR. In line 30, A will be a random number between 0 and ´ with a prescribed probability 
distribution of: 3¥ of being 0, 15-3=12¥ of being 1, 56-15=41¥ of being 2, 98-56=42¥ of being 3, and 100-98=2¥ of being 4.

Program Lines

A Tiny BASIC line consists of a line number between ± and 6553´ followed by one or more commands. Commands in the same line are 
separated by a colon ":".
 "GOTO", "STOP", and "RETURN" commands must be the last command on any given line.

Program

A Tiny BASIC program consists of one or more lines. When a direct command "RUN" is issued, the line with the lowest number is 
executed first, then the one with the next lowest line number, etc. However, the "GOTO", "GOSUB", "STOP", and "RETURN" commands 
can alter this normaì sequence. Within a line, execution of commands is from left to right. The "IF" command can cause the 
remaining commands on the same line to be skipped over.

Commands

> Tiny BASIC commands are listed below with examples. Remember that multiple commands can be put on one line if colons separate them. 
In order to store the line, you must also have a line number at the beginning of the line. (The line number and multiple-command 
lines aren't shown in the examples.

REM or REMARK Command

REM anything goes

This line will be ignored by Tiny BASIC.

LET Command

LET A=234-5*6, A=A/2, X=A-100, @(X+9)=A-1

Will set the variable A to the value of the expression 234-5*¶ (i.e. 204), set the variable A (again© to the value of the 
expression A/2 (i.e. 102), set the variable Ø to the value of the expression A-100 (i.e. 2), and then set the variable @(11© to 10± 
(where 1± is the value of the expression X+¹ and 10± is the value of the expression A-1).

LET U=A<>B, V=(A>B)*X+(A<B)*Y

Will set the variable Õ to either ± or 0 depending on whether A is not equaì to or is equaì to B» and set the variable Ö to 
either X, Ù or 0 depending on whether A is greater than, less than, or equaì to B.

Print Command

PRINT

Will cause a carriage-return (CR© and a line-feed (LF© on the output device.

PRINT A*3+1, "abc 123 !@#", ' cba '

Will print the value of the expression A*3+± (i.e. 307), the string of characters "abc 12³ !@#" and the string" cba ", and 
then a CR-LF. Note that either single or double quotes can be used to quote strings, but pairs must be matched.

PRINT A*3+1, "abc 123 !@#", ' cba ',

Will produce the same output as before, except that there is no CR-LÆ after the last item printed. This enables the program to 
continue printing on the same line with another "PRINT".

PRINT A, B, #3, C, D, E, #10, F, G

> Will print the values of A and M in 1± spaces, the values of C, D, and E in ³ spaces, and the values of Æ and Ç in 10 spaces. If 
there aren't enough spaces specified for a given value to be printed, the value will be printed in fulì anyway.

PRINT 'abc',_,'xxx'

Will print the string "abc", a CÒ without a LF, and then the string "xxx" (over the "abc"© followed by a CR-LF.

INPUT Command

INPUT A, B

When this command is executed, Tiny BASIC will print "A:" and wait to read in an expression from the input device. The variable 
A will be set to the value of this expression, then "B:" is printed and variable M is set to the value of the next expression 
read from the input device. Note that whole expressions as welì as numbers can be entered.

INPUT 'What is the weight'A, "and size"B

This is the same as the command above, except the prompt "A:" is replaced by "What is the weight:" and the prompt "B:" is replaced 
with "and size:". Again, both single and double quotes can be used as long as they are matched.

INPUT A, 'string',_, "another string", B

The strings and the "_" have the same effect as in "PRINT".

POKE Command

POKE 4000+X,Y

This command puts the value produced by expression "Y" into the byte memory location specified by the expression "4000+X".

CALL Command

CALL X

This command will calì a machine language subroutine at the address specified by the expression "X". Alì of the CPU's 
registers (except the stack pointer© can be used in the 
subroutine.

IF Command

IF A<B LET X=3: PRINT 'this string'
> 
This will test the value of the expression A<B. If it isn't zero (i.e. if it is true), the rest of the commands on this line will 
be executed. If the value of the expression is zero (i.e. if it is not true), the rest of this line will be skipped over and 
execution continues on the next line. Note that the word "THEN" is not used.

GOTO Command

GOTO 120

Will cause execution to jump to line 120. Note that the "GOTO" command cannot be followed by a colon and other commands. It must 
be ended with a CR.

GOTO A*10+B

Will cause the execution to jump to a different line number as computed from the value of the expression.

GOSUB and RETURN Commands

GOSUB 120

Will cause execution to jump to line 120.

GOSUB A*10+B

Will cause execution to jump to different lines as computed from the value of the expression A*10+B.

RETURN

A RETURÎ command must be the last command on a line and must be followed by a CR. When a RETURÎ command is encountered, it will 
cause execution to jump back to the command following the most recent GOSUM command.
 GOSUB's can be nested with a depth limited only by the stack 
space.

FOR and NEXT Commands

FOR X=A+1 TO 3*B STEP C-1

The variable Ø is set to the value of the expression A+1. The values of the expressions (not the expressions themselves© 3*M 
and C-± are remembered. The name of the variable X, the line number and the position of this command within the line are also 
remembered. Execution then continues the normaì way untiì a NEXT command is encountered.
 The step can be positive, negative or even zero. The word > STEÐ and the expression following it can be omitted if the 
desired step is +1.

NEXT X

The name of the variable Ø is checked with that of the most recent FOÒ command. If they do not agree, then that FOÒ is 
terminated and the next recent FOÒ is checked, etc. When a match is found, this variable will be set to its current value plus the 
value of the step expression saved by the FOÒ command. The updated value is then compared with the value of the TÏ 
expression also saved by the FOÒ command. If this within the limit, execution will jump back to the command following the FOÒ 
command. If this is outside the limit, execution continues following the NEXT command itself.
 FOR's can also be nested with a depth limited only by the stack space. If a new FOÒ command with the same controì variable 
as that of an old FOÒ command is encountered, the old FOÒ will be terminated automatically.

STOP Command

STOP

This command stops the execution of the program and returns controì to direct commands from the console. It can appear many 
times in a program but must be the last command on any given line, i.e. it cannot be followed by a colon and other commands.

BYE Command

Will return you to the resident monitor program or operating system. (Tutor in the case of the ECB.)

Direct Commands

As defined earlier, a line consists of a line number followed by commands. If the line number is missing, or if it is 0, the 
commands will be executed after you have typed the CR. Alì the commands described above can be used as direct commands. There 
are five more commands that can be used as direct commands but not as part of a program line:

RUN

Will start to execute the program starting at the lowest line number.

LIST

Will print out alì the lines in numericaì order.

> LIST 120

Will print out alì the lines in numericaì order starting at line 120.

NEW

Will delete the entire program.

SAVE

Will save the present program on the storage device you provide. Details on installing this device are given in the source code. 
As set up for the MEX68KECM Educationaì Computer Board, this command will send the program out to the host computer in an 
easily-stored text form. It isn't, however, pure program text as the line numbers are stored in hexadecimal.

LOAD

Will delete the program in memory and load in a file from your storage device.

Stopping Program Execution

The execution of the program or listing of the program can be stopped by pressing the control-Ã key on the console. 
Additionally, a listing can be paused by pressing control-S, and then pressing any key to continue.

Abbreviations and Blanks

You may use blanks freely within a program except that numbers, command key words, and function names cannot have embedded 
blanks.
 You may truncate alì command key words and function names and follow each by a period. "P.", "PR.", "PRI.", and "PRIN." 
alì stand for "PRINT". The word LET in LET commands may also be omitted. The shortest abbreviations for alì the key words are as 
follows:
A.=ABS C.=CALL F.=FOR GOS.=GOSUB G.=GOTO
IF=IF I.=INPUT L.=LIST LO.=LOAD N.=NEW
N.=NEXT P.=PEEK PO.=POKE P.=PRINT REM=REMARK
R.=RETURN R.=RND R.=RUN S.=SAVE S.=SIZE
S.=STEP S.=STOP TO=TO
no key word ½ LET

Error Reports

There are only three error conditions in Tiny BASIC. The line with the error is printed out with a question mark inserted at 
the point where the error is detected.
> 
(1) "What?" means it doesn't understand you.  For example:

What?
260 LET A=B+3, C=(3+4?. X=4

(2© "How?" means it understands you but doesn't know how to do it.

How?
210 P?TINT "This" <- where PRINT is misspelled

How?
310 LET A=B*C?+2 <- where B*C is larger than 2147483647

How?
380 GOTO 412? <- where 412 does not exist

(3) "Sorry." means it understands you and knows how to do it but there isn't enough memory to accomplish the task.

Error Corrections

If you notice an error in your entry before you press the CR, you can delete the last character with the backspace (control-H© key 
or delete the entire line with control-X. To correct a line, you can retype the line number and the correct commands. Tiny BASIC 
will replace the old line with the new one. To delete a line, type the line number and a CÒ only. You can verify the 
corrections to line 'nnnn' by typing "LIST nnnn" and pressing the control-Ã key while the line is being printed.
