A version of TSC Micro BASIC PLUS ported to my 6809 Single Board Computer.

The 6809 port was found here: https://www.cs.drexel.edu/~bls96/6809sbc/

I found the original 6800 version and info here: http://www.swtpc.com/mholley/TSC_MicroBasic/TSC_MicroBasic.htm

Notes about this port:

The MONITOR command jumps to the ASSIST09 Monitor. You cannot return
to BASIC unless you call the warm start entry RESTRT.

A running program can be interrupted with Control-C.

I enhanced it to show full error messages rather than just numbers.

Known issues:

The program occasionally crashes randomly. This needs to be investigated further.
The language is pretty limited as compared to other BASICs (e.g. integer math only, no string variables).

------------------------------------------------------------------------

Instruction Summary

Commands: LIST MONITOR RUN SCRATCH

Statements: DATA DIM END EXTERNAL FOR GOSUB GOTO IF INPUT LET NEXT ON PRINT READ REM RESTORE RETURN THEN

Functions: ABS RND SGN SPC TAB

Math Operators: - + * / ^

Relational Operators: = < > <= >= <>

Other:

Line Numbers: 0 to 9999
Constants: -99999 to +99999
Variables: single letters, A to Z, may be subscripted
Backspace: Control-H
Line cancel: Control-X

Error Codes:

10 Unrecognizable keyword
14 Illegal variable
16 No line number referenced by GOTO or GOSUB
20 Expression syntax, unbalanced parens, or dimension error
21 Expression expected but not found
22 Divided by zero
23 Arithmetic overflow
24 Expression too complex
31 Syntax error in PRINT statement
32 Missing closing quote in printed string
40 Bad DIM statement
45 Syntax error in INPUT statement
51 Syntax error in READ statement
62 Syntax error in IF statement
73 RETURN with no GOSUB
81 Error with FOR-NEXT
90 Memory overflow
99 "BREAK" detected
