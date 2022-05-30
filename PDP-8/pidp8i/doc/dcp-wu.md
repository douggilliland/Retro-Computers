# DCP Disassembler for PDP-8

This document is based on the file DCP.WU found with DCP binaries.

| Author              | A.E. Brouwer, Math. Center, Amsterdam |
| Date                | 73-10-03                              |
| Version Number      | DCP AB-V21                            |
| Last Update         | 74-11-12                              |
| Environment         | OS/8 operating system                 |
| Memory Requirements | 16K, Optional 24K mode                |


## DCP (Preliminary Description)

DCP (sometimes called `deass`) is a program to deassemble (or disassemble)
a PAL program given in binary or in core image format as 1st input file.
Information about the program and meaningful tags can be given
in a second input file. A well readable listing with meaningful
tags but without comment can be obtained in a few passes
(typically four). The first time no information is supplied; while
reading the output one recognizes certain parts as messages
("NO ROOM FOR OUTPUT") or numeric tables (6030,7634,7766,7777)
or simple subroutines (TTYOUT, PUSH, PRINT).

Putting these things in an information file and then running
dcp again gives you a much nicer output the second time.
Now you may embark on the program itself and obtain after a small
number of passes (depending on the complexity of the program and
your laziness.) A source that might have been the original one except
for its lack of comment. At this moment you could profitably use
the CTRL/E feature of MCEDIT to provide the whole source of comment.
(For example, we obtained a source of a fortran compiler in three
days after five passes.)

Below we will describe the OS/8 version of the program

## Assembly Instructions

(Alas, we do not yet have source.)

    .R PAL8
    *102,DCP_SBIN,DCPZ/L$
    .SAVE SYS DCP

## Operating Instructions

    .R DCP
    *OUTPUT<INPUT,INFO(OPTIONS)

## Command Line Interpretation

1.  If no input and no output specified then delete <kbd>DSK:DCPLS.TM<kbd>
    If command closed with altmode then exit to OS/8 monitor
    else call command decoder again.

2.  If no output given but an output file is required because
    chaining to CREF.SV is requested then DSK:DCPLS.TM is used.

3.  If no input given then use output filename with extensions
    .SV and .SM (if present.)
    E.G.
   
        *DEASS<

    is equivalent to

        *DEASS<DEASS.V
       
    if DEASS.SM does not exist, and to

       *DEASS<DEASS.SV,DEASS.SM

    otherwise.

    In this case a previous version of the output file is
    deleted first (if necessary).

4.  If the output file has no explicit extension then add
    .DC if a source is produced, and .LS otherwise
    (One would expect .PA instead of .DC but that proved dangerous.)

## Options Affecting Interpretation of Command Line

| /B    | Expect .BN rather than .SV format in first inputfile     |
|       | This changes the default extension into .BN if no        |
|       | input is specified.                                      |
| /L    | Produce .LS rather than .DC output                       |
| /X    | Chain to CREF.SV                                         |
|       | (1st output becomes input and 2nd output becomes output) |
|       | This option implies the options /L and /T                |

e.g.

    .R DCP
    *DEASS,TTY:</X/B
    
is equivalent to

    .R PIP
    *DEASS.LS</D$
    .R DCP
    *DEASS.LS<DEASS.BN,DEASS.SM/L/T/B
    .R CREF
    *TTY:<DEASS.LS
    
also

     DCP
     *
     *DEAS.SV,SPECS1,SPECS2,SPECS3/S
     
means

    .R PIP
    *DEASS.TM</D$
    .R DCP
    *DCPLS.TM<DEASS.SV,SPECS1,SPECS2,SPECS3/L/T
    .R CREF
    *DCPLS.TM

## Options

| /A    | Do not generate a 'START' label.
|       | (By default a label 'START' is generated when decoding
|       | core image file. This is possible since the core control
|       | contains the starting address.)
| /B    | Expect .BN instead of .SV input.
| /C    | The info file after the output
| /D    | 'JMP .-3', 'JMP I .+1' instructions
|       | for each reference a tag is generated)
| /H    | Do not generate literals.
| /K    | allow modification of literals.
|       | (Normally an instruction like 1377 will be translated as
|       | 'TAD (1234' but 2377 as 'ISZ A177' since no decent programmer
|       | ever writes 'ISZ (1234'. It was found however that several
|       | DEC programs contain such constructs.)
| /L    | Produce output in .LS format.
| /N    | Do not generate table of undefined symbols.
| /S    | Generate table of all symbols.
| /T    | Convert tabs into spaces.
| /W    | Do not interpret 6141 as the PDP12 'LINC' instruction.
| /X    | Chain to CREF.SV.
| /(F)  | (Where F designates a digit between 0 and 7.)
|       | Translate field F of the program (default: /0)
| =NNNNMMMM | The = OPTION can be used to specify a part of the program to be decoded. NNN gives begin and MMMM end+1 of the range. (Note that if begin>3777 the command has to be closed with altmode instead of return.)

## Translation Is Done One Field at A Time

Therefore, binaries that load into extended memory must be
disassembled with /(F) for all memory fields used.

This causes some flaws in the output:

    CIF 10
    JMS I   (200

is translated as:

    CIF 10
    JMS I   (START

If LOC 200 in the current field is labeled START.
Note that assembling the produced source gives the
correct binary.)

## Input Format

Each input section starts with $X (where X is a letter indicating
the type of the section) and ends with $ .

$\<CR\> indicates the end of all input (when not within a secion).
Between the sections comment not containing $ may be inserted.

### Section Types

| $A    | Translate as 6bit ASCII (TEXT "STRING")
| $D    | Dont translate
| $I    | Translate as instruction (overriding other specs)
| $L    | Translate as identifier rather than as instruction
| $N    | Translate octal
| $S    | Subroutine with args
| $T    | Symbol definitions
| $Z    | Special coding
| $     | End of input

### Content of Section

1.  Sections $X where X is A,D,I,L or N.

    Contents: Lines of the form:

        MMMM-NNNN

    or

        NNNN

    Where NNNN and MMMM are octal addresses.
   
    e.g. the section:

        $N
        1717-1730
        1750
        $

    specifies that the locations 1717-1730 and 1750 are
    to be translated as octal numbers.

2.  Sections $S.

    Contents: Lines of the form:

        SSSS:XXXXX

    Where SSSS is a subroutine address and XXXXX specifies
    the kind of arguments the subroutine has.

    e.g. the section:

        $S
        1000:NL
        $

    indicates that each call to the subroutine at LOC 1000 has two
    arguments of type octal and label respectively.

3. Sections $T.

    Contents: Lines of the form:

        TAG=NNNN

    or

        TAG

    Meaning: If no octal value of a tag is specified then its value is
    taken as one more than the value of the previous tag.

4. Section $Z.

    This is an ad hoc construct to enable the translation of
    symbol tables like those of PAL8 and CREF.
   
    e.g.

        $Z=52;0=240;1=301;40=260
        NNNN-MMMM:(UUUL)
        $
       
    indicates that the range NNNN-MMMM is a table of four-word entries
    three words in a special format and one label.

    The special format is as follows:

    The value is divided by 52 giving a quotient and a remainder.
    Both are converted into a character as follows: 0 gives a space,
    1-37 give letters A-_, and 40-51 give digits 0-9.

    The coding here is not foolproof yet: A strange command might
    give strange output instead of an error message.

    In later versions this command will be generalized, so we don't
    describe it in full here.

## Error Messages

These are very poor (because of lack of space): HLTNNNN,
where NNNN indicates the address of the routine in DCP that
detected the error.

Errors are almost always violations of the input format.

A complete list will appear in the final report.

| Name    | DCP (ERROR TABLE)
| Author  | A.E. Brouwer
| Date    | 75-02-13

As noted: The error messages of DCP look like 'HLT....'
where .... stands for the octal address of the routine
that detected the error.

(Of course giving intelligible messages is highly desirable
but lack of space prevented this. Some future version of DCP
will chain to a file `DECPERR.SV` containing the messages.)

Below the error numbers are given for DCP AB-V21.
[Note: These numbers may change slightly each time that
DCP is assembled anew.]

### DCP16 Error Table

| Number | ERROR
| ------ | -------------------------------------------------------------|
| 0000   | PREMATURE END OF .BN INPUT                                   |
| 0230   | CLOSE ERROR                                                  |
| 0301   | LOOKUP FOR SYS:CREV.SV FAILED                                |
| 1414   | OUTPUT ERROR OR NO ROOM FOR OUTPUT                           |
| 1451   | INPUT ERROR (INFO FILE)                                      |
| 1522   | NO CARRIAGE RETURN WHERE EXPECTED IN THE INFO FILE           |
| 1755   | UPPER BOUND IN BOUND PAIR LESS THAN LOWER BOUND              |
| 2031   | ASCII STRING CONTAINED A SIXBIT ZERO, BUT NOT AT THE END     |
|        | (I.E. A WORD 00XX). (THIS MIGHT HAVE BEEN AN @,              |
|        | BUT IS USUALLY AN ERROR.)                                    |
| 2046   | ASCII STRING WITHOUT TRAILING ZERO                           |
| 2061   | DCP COULD NOT FIND A SUITABLE DELIMITER FOR THE ASCII STRING |
|        | IN THE RANGE "" TO "?                                        |
| 2125   | IMPOSSIBLE                                                   |
| 2214   | TEXT BUFFER OVERFLOW (TOO MANY OR TOO LONG IDENTIFIERS).     |
| 2234   | NO IDENTIFIER WHERE EXPECTED (IN A $T SECTION).              |
| 2666   | ZERO SUBROUTINE ADDRESS SPECIFIED IN A $S SECTION            |
| 2705   | S-BUFFER OVERFLOW (TOO MANY SUBROUTINES WITH ARGS.)          |
| 2761   | UNKNOWN TYPE LETTER IN SPECIFICATION OF SUBROUTINE ARGS      |
| 3006   | $Z NO FOLLOWED BY =                                          |
| 3011   | $Z= NOT FOLLOWED BY A NONZERO NUMBER                         |
| 3022   | NO CARRIAGE RETURN OR SEMICOLON WHERE EXPECTED IN $Z HEADER  |
| 3030   | NO = WHERE EXPECTED IN $Z HEADER LINE                        |
| 3041   | ZERO LOWER BOUND IN BOUND PAIR IN $Z SECTION                 |
| 3064   | Z-BUFFER OVERFLOW                                            |
| 3117   | PREMATURELY EXHAUSTED Z-FORMAT                               |
| 3135   | UNKNOWN Z-FORMAT SYMBOL                                      |
| 3470   | T-BUFFER OVERFLOW                                            |
| 3723   | NO VALUE ASSIGNED TO FIRST TAG IN $T SECTION                 |
| 4213   | NO INPUT AND NO OUTPUT AND NO DSK:DCPLS.TM TO DELETE         |
| 4245   | HANDLER FETCH ERROR                                          |
| 4341   | LOOKUP FOR INPUTFILE FAILED                                  |
| 4442   | OUTPUT OPEN ERROR                                            |
| 4456   | NO 16K MEMORY AVAILABLE                                      |
| 4470   | CHECKSUM OR FORMAT ERROR IN BINARY INPUT FILE                |
| 4613   | FORMAT ERROR IN CORE CONTROL BLOCK OF .SV INPUT FILE         |
| 4647   | ERROR READING CORE CONTROL BLOCK OF .SV INPUT                |
| 4723   | ERROR READING .SV INPUT FILE                                 |

## DCP24

DCP Version 24 is a 24K version of DCP.

| Name   | DCP-AB-WW-V24
| Author | W.F. Wakker, Math. Center, Amsterdam
| Date   | 76-03-25

### The Following Extensions Are Made

-   DCP24 Translates EAE instructions in both A and B mode

    (For mode switching, see below.)

    Example:

        1200    DAD;1234

    is translated as if the info-file contains the following info:

        $I
        1200
        $
        $L
        1201
        $
        $N
        1234+
        $

-   In the info-file one can give : NNNN+ which has the same
    effect as NNNN-MMMM where MMMM=NNNN+1.

-   Several buffers have been enlarged.

-   The output is paginated and has a heading on each page.
    (The page number is in octal ....)

-   Error messages are unfortunately as poor as before (See DCP24
    error table).

-   New sections, now possible in the info-file are:

    | $B    | TRANSLATE AS 8-BIT ASCII  |
    | $C    | GIVE COMMENT              |
    | $E    | FORCE EAE MODE A          |
    | $F    | FORCE EAE MODE B          |
    | $M    | TRANSLATE NEGATIVE        |

- Section $B

        $B
        NNNN-MMMM
        $

    Causes the location NNNN-MMMM to be translated as
    8-bit ASCII, E.G. 0301 is translated as "A.
    Values less then 241 are translated as octal numbers.

- Sections $E and $F

    When DCP encounters EAE instructions, some slight heuristics
    are done to determine the mode. The mode is initially A; SWAB,
    DAD, and DST cause the mode to change to mode B etc.
    When these heuristics are too poor, you can use  the $E section
    to force mode A and the $F section to force mode B.

- Section $M

    This section has the same effect as section $N, only all
    octals are given negative, E.G. 7770 becomes -10.
    It is also possible to give $B and $M to the same LOC.
    Example: 7477 is now translated as -"A.

- Section $C

    Now you can give comment!!

    | Format    | NNNN:THIS IS COMMENT
    | Effect    | NNNN    ........    /THIS IS COMMENT
    | Attention | The $C section must be the last one in the info-file:

    When $C is seen in the info-file, a setup is made to
    give the comment and no more input will be read ( E.G. The program
    acts like $$ on the end is seen). The comments are added to
    the listing in the last pass of the program.

    __YOU MUST SORT THE ADDRESSES.__

        300:COMM1
        200:COMM2

    Has as effect that from adress 300 on, no more comment will
    be given, since address 200 is not found any more.

    __DO NOT GIVE COMMENT ON ADDRESSES WHICH DO NOT BELONG
    TO THE PROGRAM__

- Extension of $S section

    As arguments in the $S section you can give N, L, A, I, B, M,
    (with the obvious meaning, see above ) and also U.
    U should only be used for the addresses 200 and 7700.
    It marks the entrypoint of the user service routine and gives
    a nice translation of each USR call.

- Extension of $Z section

    New possible arguments: M, B.

### DCP-V24 (ERROR TABLE)

| Number | ERROR
| ------ | -------------------------------------------------------------|
| 0000   | PREMATURE END OF .BN INPUT                                   |
| 0237   | CLOSE ERROR                                                  |
| 0305   | LOOKUP FOR SYS:CREF.SV FAILED                                |
| 1414   | OUTPUT ERROR OR NO ROOM FOR OUTPUT                           |
| 1511   | NO CARRIAGE RETURN WHERE EXPECTED IN THE INFO FILE           |
| 1707   | NO : AS SEPARATOR IN $C SECTION                              |
| 2145   | UPPER BOUND IN BOUND PAIR LESS THAN LOWER BOUND              |
| 2235   | NO : AS SEPARATOR IN FIRST LINE OF $C SECTION                |
| 2331   | INPUT ERROR (INFO FILE)                                      |
| 2431   | ASCII STRING CONTAINED A SIXBIT ZERO, BUT NO AT THE END      |
|        | (I.E. A WORD 00XX). (THIS MIGHT HAVE BEEN AN @,              |
|        | BUT IS USUALLY AN ERROR.)                                    |
| 2446   | ASCII STRING WITHOUT TRAILING ZERO                           |
| 2461   | DCP COULD NOT FIND A SUITABLE DELIMITER FOR THE ASCII STRING |
|        | IN THE RANGE "" TO "?                                        |
| 2525   | IMPOSSIBLE                                                   |
| 2614   | TEXT BUFFER OVERFLOW (TOO MANY OR TOO LONG IDENTIFIERS)      |
| 2634   | NO IDENTIFIER WHERE EXPECTED (IN A $T SECTION)               |
| 3266   | ZERO SUBROUTINE ADDRESS SPECIFIED IN A $S SECTION            |
| 3305   | S-BUFFER OVERFLOW (TOO MANY SUBROUTINES WITH ARGS)           |
| 3367   | UNKNOWN TYPE LETTER IN SPECIFICATION OF SUBROUTINE ARGS      |
| 3406   | $Z NOT FOLLOWED BY =                                         |
| 3411   | $Z= NOT FOLLOWED BY A NONZERO NUMBER                         |
| 3422   | NO CARRIAGE RETURN OR SEMICOLON WHERE EXPECTED IN $Z HEADER  |
| 3430   | NO = WHERE EXPECTED IN $Z HEADER LINE                        |
| 3441   | ZERO LOWER BOUND IN BOUND PAIR IN $Z SECTION                 |
| 3463   | Z-BUFFER OVERFLOW                                            |
| 3517   | PREMATURELY EXHAUSTED Z-FORMAT                               |
| 3541   | UNKNOWN Z-FORMAT SYMBOL                                      |
| 4070   | T-BUFFER OVERFLOW                                            |
| 4324   | NO VALUE ASSIGNED TO FIRST TAG IN $T SECTION                 |
