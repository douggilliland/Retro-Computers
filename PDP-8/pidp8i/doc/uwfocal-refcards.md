# U/W FOCAL V4E Reference Cards

### Introduction

The following material is reformatted from the `CARD[1-4].DA` files
contained within the U/W FOCAL V4E distribution which we used in
creating the PiDP-8/I software project's U/W FOCAL feature.

Some minimal effort has been made to make this document print well,
though it doesn't paginate the same as the original material.

Since these files were likely created [before 1978][cl78] and probably
did not have their copyright renewed — if it was in fact applied for,
not an automatic thing at the time in the United States — we believe
this text to be in the public domain. If the authors of the text below
request it, we will remove this file from the PiDP-8/I software
distribution.

[cl78]: https://en.wikipedia.org/wiki/Copyright_law_of_the_United_States#Works_created_before_1978

<style type="text/css">
    @media print {
        h2         { page-break-before: always; }
        h1, h2, h3 { page-break-after:  avoid; }
        p          { page-break-before: avoid; }

        div.header, div.mainmenu, div.footer {
            display:    none;
            visibility: hidden; 
        }
    }
</style>


## <a id="card1"></a>U/W FOCAL Quick Reference Card (`CARD1.DA`)


### Single Letter Commands

| `A` | Ask [`"QUERY"`,`X`,`:`,`!`]  | Accepts value of `X` from input device                   |
| `B` | Break [_L1_]%                | Exits from a FOR loop, continuing at _L1_                |
| `C` | Comment                      | Ignores the rest of the line                             |
| `D` | Do [_G1_,_G2_,_G3_,etc.]     | Calls a line or a group as a subroutine                  |
| `E` | Erase [_G1_]                 | Deletes all or part of the program                       |
| `F` | `For X=`_E1_`,`[_E2_`,`] _E3_`;`(_commands_) | Executes line `1+(_E3_-_E1_)/_E2_` times |
| `G` | Goto [_L1_]                  | Branches to line _L1_                                    |
| `H` | Hesitate [_E1_]\*            | Delays (or synchronizes) the program                     |
| `I` | If `(E1)` [_L1_,_L2_,_L3_]%  | Transfers to _L1_,_L2_,_L3_ on sign of _E1_              |
| `J` | Jump `(`_E1_`)` [_G1_,_G2_,_G3_,_G4_...]%  |   Calls the subroutine selected by _E1_    | 
| `K` | Kontrol [_E1_,_E2_,etc]\*    | Controls relays or other digital output                  |
| `L` | Library/List                 | Two-letter commands, see the next page                   |
| `M` | Modify [_L1_,_L2_]           | Edits and/or Moves line L1 - see below                   |
| `N` | Next [_L1_]%                 | Ends a `FOR` loop, branches to _L1_ when finished        |
| `O` | On `(`_E1_`)` [_G1_,_G2_,_G3_]%  | Calls subroutine selected by sign of _E1_            |
| `P` | Plot [_X_,_Y_,_L_,_M_]\*     | Controls an analog or digital plotter                    |
| `Q` | Quit [_L1_]%                 | Stops program, allows restart at _L1_                    |
| `R` | Return [_L1_]%               | Exits from a subroutine call, continuing at _L1_         |
| `S` | Set [_E1_,_E2_,_E3_,etc.]    | Evaluates arithmetic expressions                         |
| `T` | Type [_E1_,`"TEXT"`,`!`,`#`,`:`,`%`,`$`]   | Generates alphanumeric output              |
| `U` | User                         |                                                          |
| `V` | View [_X_,_Y_,_Z_]\*         | Generates graphic output on a CRT                        |
| `W` | Write [_G1_,_G2_,_G3_,etc.]  | Lists all or part of a program                           |
| `X` | Xecute                       |  Equivalent to SET                                       |
| `Y` | Yncrement [_X_,_Y_`-`_Z_]    | Increments or decrements variables                       |
| `Z` | Zero [_X_,_Y_,...]           | Sets some or all of the variables to zero                |

\* Indicates a non-standard (installation dependent) feature

% If the line number is omitted (or=0) no branch will occur

_En_ are Arithmetic Expressions - - [] Enclose optional items
       
_Ln_ are Line Numbers from `0.01` to `31.99` - excluding integers

_Gn_ are Line or Group Numbers from `0` to `+31` (`0` = next or all)

Line numbers `.01` to `.99` refer to lines in the current group Negative
or Integer line numbers denote a 'Group' operation. Arithmetic
expressions may be used as Line or Group numbers


### Arithmetic Operators

|   | ( )  [ ]  < >           | Three equivalent sets of enclosures     |
| ' | Character value         | `'A` is the value of the letter `A`     |
| ^ | Exponentiation          | Positive or negative integer powers     |
| * | Multiplication          | Note especially that multiplication     |
| / | Division                | has a higher priority than division     |
| - | Subtraction or Negation | Example: (to illustrate priorities)     |
| + | Addition                | `-5^4/3*A=2+1` is `0-<5^4>/[3*(A=2+1)]` |
| = | Replacement             | May be used anywhere in expressions     |


### Ask/Type Operators

| , | COMMA or SPACE           | Separates variables and/or expressions         |
| ! | Carriage return/linefeed | Starts a new line for input or output          |
| " | String delimiter         | Case shift option uses `\`: `"A\B\C"=AbC`      |
| # | Return or Clear Screen   | Used for plotting or overprinting              |
| $ | Symbol table listing     | `TYPE $4` prints 4 variables per line          |
| : | Tabulation               | `ASK :-15`  skips over the next 15 characters  |
|   | (:0 is ignored)          | `TYPE :15`  spaces to column 15 if not beyond  |
| % | Format control           | `%3` Produces 3 Digits in an integer format    |
|   | (for output only)        | `%0.04` =  4 Digits using scientific notation  |
|   | (input is unformatted)   | `%5.02` =  5 Digits, 2 decimal places maximum  |

Letters (but only one E) are legal numeric input: `YES=25E19`. `ALTMODE`
or `ESCAPE` aborts input, with the variable unchanged. `_` deletes all
digits during input — `RUBOUT` is ignored.


### Modify / Move Operators

| `CTRL/F`                     | Aborts the command leaving the line unchanged |
| `CTRL/G` (bell)              | Selects a new search character                |
| `CTRL/L` (does not echo)     | Searches for next occurrence of character     |
| `_` (backarrow or underline) | Deletes all characters to the left            |
| `RETURN`                     | Terminates the line at the current position   |
| `LINEFEED`                   | Copies the remainder of the line unchanged    |
| `RUBOUT`/`DELETE`            | Removes the previous character, echos a `\`   |

`RUBOUT` or `DELETE` and `_` also work during command input

`LINEFEED` retypes the corrected input line for verification


## <a id="commands" name="card2"></a>Command Summary (`CARD2.DA`)

In the descriptions below, arguments in square brackets are optional.
Specify the argument, but don't include the square brackets. If a space
is in the square brackets, a space is required to provide the argument.


### Miscellaneous Commands

| `O D`   | Output Date           | Prints system date in the form `DD.MM.YY`  |
| `L E`   | Logical Exit          | Returns to the OS/8 keyboard monitor       |
| `L B`   | Logical Branch _L1_   | Branches to _L1_ if -no- input from TTY    |
| `J  `   | Jump _L1_.            | Equivalent to the Logical Branch command   |


### Filesystem Directory Commands

| `L A,E` | List All [name][`,E`]         | Lists all files after the one specified  |
| `L O`   | List Only [_name_]\*          | Verifies the existence of one `.FC` file |
| `O L`   | Only List [_name_]\*          | Verifies the existence of one `.DA` file |
| `L L`   | Library List [_name_]%        | Shows files with the same extension      |
| `L D`   | Library Delete name [ _L1_]   | Removes a name from the directory        |
| `L Z`   | Library Zero dev:[_length_]   | Zeros directory using length given       |

Notes on Directory Commands:

`E`  Adding the phrase `,E` will list all of the 'empties' too

*  Omitting the name lists all files with the same extension

%  A null extension will list all files having the same name


### Program Commands

| `L C`   | Library Call name          | Loads a program, then Quits        |
| `L G`   | Library Gosub name [ _G1_] | Calls a program as a subroutine    |
| `L R`   | Library Run name [ _L1_]   | Loads a program and starts at _L1_ |
| `L N`   | Library Name [_name_]      | Changes the program header         |
| `L S`   | Library Save name [ _L1_]  | Saves the current program          |

[ _G1_] indicates which line or group will be called by `L G`

[ _L1_] specifies an error return, except for the `L R` command


### Input / Output Commands

| `O A`   | Output Abort [_E1_]                  | Terminates output file with length _E1_  |
| `O B`   | Output Buffer                        | Dumps buffer without closing the file    |
| `O C`   | Output Close [_E1_]                  | Ends output, saves file with length _E1_ |
| `O I,E` | Open Input [`,Echo`]                 | Selects the terminal for input           |
| `O O`   | Open Output                          | Selects the terminal for output          |
| `O S`   | Output Scope                         | Selects CRT for output (if available)    |
| `O I -` | Open Input name [`,E`] [ _L1_]       | Switches input to an OS/8 device         |
| `O S -` | Open Second name [`,Echo`] [ _L1_]   | Selects a second input file              |
| `O O -` | Open Output name [`,Echo`] [ _L1_]   | Initiates OS/8 (file) output             |
| `O E -` | Output Everything device [`,Echo`]   | Changes error/echo device                |
| `O R R` | Open Restart Read [`,Echo`]          | Restarts from the beginning              |
| `O R I` | Open Resume Input [`,Echo`] [ _L1_]  | Returns to file input                    |
| `O R O` | Open Resume Output [`,Echo`] [ _L1_] | Returns to file output                   |
| `O R S` | Open Resume Second [`,Echo`] [ _L1_] | Returns to second input file             |

The `INPUT ECHO` sends characters to the current `OUTPUT` device

The `OUTPUT ECHO` sends characters to the current 'O E' device


### Filename Expressions

Device and filenames may be written explicitly: `RXA1:`, `MYSTUF`,
`0123.45`. Numeric parts can be computed from (expressions):
`DTA(N):PROG(X).(A+B)`. Negative values specify single characters:
`F(-201)L(-197,.5,PI)=FILE03`. An \<OS/8 block number\> can be
substituted for the name: `LTA1:<20*BN+7>`. Expressions in square
brackets indicate the size: `TINY[1]`, `<LOC>[SIZE]`.


### <a id="variables"></a>Variables

Variable names may be any length, but only the first two characters are
stored; the first character may not be an `F`. Both single and double
subscripts are allowed - a subscript of 0 is assumed if none is given.
The variables `!`, `"`, `#`, `$`, `%` and `PI` are protected from the
`ZERO` command and do not appear in table dumps. `!` is used for double
subscripting and should be set to the number of rows in the array.  `#`,
`$`, `%` are used by [FOCAL Statement Functions](#fsf). The `ZVR`
feature permits non-zero variables to replace any which are zero. This
includes `FOR` loop indices, so use a protected variable if the index
runs through zero.  Undefined or replaced variables are automatically
set to zero before their first use.


### <a id="fsf"></a>FOCAL Statement Functions

`F(G1,E1,E2,E3)` executes line or group `G1` after first setting the
variables `#`,`$`,`%` to the values of `E1`,`E2`,`E3` (if any).  The
function returun with the value of the last arithmetic expression
processed by the sub routine, including line number & subscript
evaluations.   For example:

    8.1 S FSIN(#)/FCOS(#) is the TANGENT function = F(TAN,A) if 'TA' = 8.1
    9.1 S FEXP($*FLOG(#)) computes X^Y for any value of Y using F(9.1,X,Y)


## <a id="misc" name="card3"></a>Miscellaneous Material (`CARD3.DA`)

### Internal Functions

| `FABS(`_E1_`)`      | Returns the absolute value of the argument                  |
| `FADC(`_N_`)`       | Reads A/D converter channel N (LAB/8e or PDP12`)`           |
| `FATN(`_A_`)`       | Computes the arctangent of _A_, result in radians           |
| `FBLK(``)`          | OS/8 block number of the current input file                 |
| `FBUF(`_I_`,`_V_`)` | Display buffer storage (single-precision)                   |
| `FCOM(`_I_`,`_V_`)` | Extended data storage in Fields 2 and 4-7                   |
| `FCOS(`_A_`)`       | Computes the cosine of _A_ (_A_ is in radians)              |
| `FCTR(`_N_`)`       | Reads a frequency counter using timebase _N_                |
| `FDAC(`_N_`,`_V_`)` | Sets D/A converter channel _N_ to the value _V_             |
| `FDAY(`_MONTH*256+DAY*8+YEAR-78_`)` | Reads/Sets the OS/8 system date             |
| `FDIN(`_B1_`,`_B2_`,`...`,`_Bn_`)`  | Reads selected bits from the input register |
| `FDVM(`_N_`,`_R_`)` | Reads a digital voltmeter, channel _N_, range _R_           |
| `FEXP(`_E1_`)`      | Base 'e' exponential function  `\|`_E1_`\|<1420`            |
| `FIN()`             | Reads a single character, returns the ASCII value           |
| `FIND(`_C_`)`       | Searches for code _C_, returning _C_ if found, 0 if `EOF`   |
| `FITR(`_E1_`)`      | Returns the integer part of the argument                    |
| `FJOY(`_I_`)`       | Places the cursor (joystick) coordinates in _XJ_,_YJ_       |
| `FLEN(`_I_`)`       | File length: _I_=`0` for `O`utput, _I_=`1` for `I`nput      |
| `FLOG(`_E1_`)`      | Natural logarithm of the absolute value of _E1_             |
| `FLS()`             | Returns unsigned value of the Left Switches (PDP12)         |
| `FMIN(`A_`,`_B`)`   | Returns the minimum or argument                             |
| `FMAX(`A_`,`_B`)`   | Returns the maximum argument                                |
| `FMQ(`_N_`)`        | Displays the lower 12 bits of _N_ in the `MQ` register      |
| `FOUT(`_C_`)`       | Outputs character code _C_, returns the value `0`           |
| `FRA(`_I_`,`_V_`)`  | Reads or writes in a binary file at location I              |
| `FRAC(`_E1_`)`      | Returns the fractional part of the argument                 |
| `FRAN(``)`          | Pseudo-random number function, range 0-1                    |
| `FSAM(`_N_`)`       | Samples _N_ channels and stores results in buffer           |
| `FSGN(`_E1_`)`      | Returns `-1`,`0`,`+1` for _E1_ negative, zero, positive     |
| `FSIN(`_A_`)`       | Computes the sine of _A_ (_A_ is in radians)                |
| `FSQT(`_E1_`)`      | Finds the square root using Newton's method                 |
| `FSR()`             | Reads the Switch Register                                   |
| `FRS()`             | Reads the Right Switches on a PDP-12                        |
| `FSS(`_N_`)`        | Tests Sense Switch _N_: `-1` = `OFF`, `+1` = `ON`           |
| `FTIM(`_N_`)`       | Reads, sets or clears the elapsed time counter              |
| `FTRG(`_N_`)`       | Returns status and clears Schmitt trigger _N_               |
| `FTRM(``)`          | Returns the last input terminator                           |
| `FXL(`_N_`)`        | Tests external level _N_ (PDP12) returning `-1` or `+1`     |

And others. There are a total of 36 possible function names

Functions indicated by a * are not available in all versions. The
functions `FBLK` & `FLEN` are useful in filename expressions. `FIN`,
`FOUT`, `FIND` and `FTRM` use decimal ASCII codes - see below.


### <a id="ascii"></a>Decimal ASCII Character Codes

| Code | Character            | Code  | Char             | Code  | Char   | Code  | Char      |
| ---- | -------------------- | ----- | ---------------- | ----- |------- | ----- | --------- |
| 128  | `CTRL/@` (leader/    | 152   | `CTRL/X`         | 176   | `0`    | 201   | `I`       |
|      | trailer-ignored)     | 153   | `CTRL/Y`         | 177   | `1`    | 202   | `J`       |
| 129  | `CTRL/A`             | 154   | `CTRL/Z` (`EOF`) | 178   | `2`    | 203   | `K`       |
| 130  | `CTRL/B`             | 155   | `ESCAPE`  or     | 179   | `3`    | 204   | `L`       |
| 131  | `CTRL/C` (OS/8)      |       | `CTRL/[`         | 180   | `4`    | 205   | `M`       |
| 132  | `CTRL/D`             | 156   | `CTRL/\`         | 181   | `5`    | 206   | `N`       |
| 133  | `CTRL/E`             | 157   | `CTRL/]`         | 182   | `6`    | 207   | `O`       |
| 134  | `CTRL/F` (`BREAK`)   | 158   | `CTRL/^`         | 183   | `7`    | 208   | `P`       |
| 135  | `CTRL/G` (`BELL`)    | 159   | `CTRL/_`         | 184   | `8`    | 209   | `Q`       |
| 136  | `CTRL/H` (`BACKSP`)  | 160   | `SPACE`          | 185   | `9`    | 210   | `R`       |
| 137  | `CTRL/I` (`TAB`)     | 161   |  `!`             | 186   | `:`    | 211   | `S`       |
| 138  | `LINEFEED`           | 162   |  `"`             | 187   | `;`    | 212   | `T`       |
| 139  | `CTRL/K` (`LINEUP`)  | 163   |  `#`             | 188   | `<`    | 213   | `U`       |
| 140  | FORMFEED             | 164   |  `$`             | 189   | `=`    | 214   | `V`       |
| 141  | RETURN               | 165   |  `%`             | 190   | `>`    | 215   | `W`       |
| 142  | `CTRL/N`             | 166   |  `&`             | 191   | `?`    | 216   | `X`       |
| 143  | `CTRL/O`             | 167   |  `'` (`APOST`)   | 192   | `@`    | 217   | `Y`       |
| 144  | `CTRL/P`             | 168   |  `(`             | 193   | `A`    | 218   | `Z`       |
| 145  | `CTRL/Q` (`X-ON`)    | 169   |  `)`             | 194   | `B`    | 219   | `[`       |
| 146  | `CTRL/R`             | 170   |  `*`             | 195   | `C`    | 220   | `\`       |
| 147  | `CTRL/S` (`X-OFF`)   | 171   |  `+`             | 196   | `D`    | 221   | `]`       |
| 148  | `CTRL/T`             | 172   |  `,` (comma)     | 197   | `E`    | 222   | `^`       |
| 149  | `CTRL/U`             | 173   |  `-` (minus)     | 198   | `F`    | 223   | `_`       |
| 150  | `CTRL/V`             | 174   |  `.` (period)    | 199   | `G`    | 253   | `ALTMODE` |
| 151  | `CTRL/W`             | 175   |  `/`             | 200   | `H`    | 255   | `RUBOUT`  |

Codes 224-250 are lower case letters.  Codes 000-127 are similar
to codes 128-255 except that the parity bit has been eliminated.

Many keyboards use `SHIFT/K`, `/L`, `/M`, `/N`, `/O` for `[`, `\`, `]`, `^` and `_`

A single quote before a character indicates the-value-of: `'A=193`
Use `CTRL/@` to page the TV display to avoid getting error `12.40`

To erase the screen on a Tektronix terminal: `S FOUT(27) FOUT(12)`

To make a copy: `S FOUT(27) FOUT(23)`.  Note:  `FOUT(27)` = `ESCAPE`

To make bold letters on a Centronics printer: `T :FOUT(14) "text"`

To set 'Hold Screen' mode (VT50 terminals):  `S FOUT(27) FOUT(91)`

To rubout the last character on the PDP12/LAB8e display `FOUT(92)`


## <a id="errors" name="card4"></a>Error Code Table (`CARD4.DA`)

For extreme economy of memory, FOCAL does not print error message strings.
Instead, an error routine prints a question mark followed by a four digit
fixed point number corresponding to where in the FOCAL runtime executable
the error was encountered.

I.E. If an error was encountered in the FOCAL interpreter's parsing
of a variable name, the error message prints out the error message
traceable to that parser within FOCAL.

This means that an error table must be produced, and every time code shifts
around, the error table must be updated.

The U/W FOCAL manual contains an error table, but it is incomplete.
Here is a complete one which comes from the file CARD4.DA in the
U/W FOCAL archive from which this distribution is taken.

Errors appearing in bold face denotes an error from a command with an
optional error return.

|     Error     |        Meaning                                                |
| ------------- | ------------------------------------------------------------- |
|   `?`         | Keyboard interrupt or restart from location 10200             |
| __`?01.03`__  | Secondary input file missing                                  |
| __`?01.11`__  | No secondary input file to resume                             |
|   `?01.50`    | Group number greater than 31                                  |
|   `?01.93`    | Non-existent line number in a MODIFY or MOVE command          |
|   `?03.10`    | Line called by `GO`, `IF`, `J`, `R`, `Q`, `L` `B`, or `L R` is missing |
|   `?03.30`    | Illegal command                                               |
|   `?03.47`    | Line or group missing in `DO`, `ON`, `JUMP`, `L GOSUB` or a `FSF` |
|               |                                                               |  
|   `?04.35`    | Bad syntax in a `FOR` command (missing semicolon?)            |
|   `?06.03`    | Illegal use of a function or number: `ASK`, `YNCREMENT`, `ZERO` |
|   `?06.41`    | Too many variables (ZERO unnecessary ones)                    |
|   `?07.44`    | Operator missing or illegal use of an equal sign              |
|   `?07.67`    | Variable name begins with `F` or improper function call       |
|   `?07.76`    | Double operators or an unknown function                       |
|   `?08.10`    | Parentheses don't match                                       |
|   `?10.50`    | Program too large                                             |
|               |                                                               |
|   `?12.10`    | Error detected in the `BATCH` input file                      |
|   `?12.40`    | Keyboard buffer overflow (eliminated in 8/e versions)         |
|   `?13.65`    | Insufficient memory for `BATCH` operation                     |
|   `?14.15`    | Display buffer overflow                                       |
|   `?14.50`    | Bad Sense Switch number on a PDP12 (range is 0-5)             |
|   `?14.56`    | Illegal external sense line (PDP12 range is 0-11)             |
|   `?17.22`    | `FRA` not initialized                                         |
|   `?17.33`    | `FRA` index too large (exceeds file area)                     |
|   `?17.62`    | `FRA` mode error: only modes 0,1,2,4 allowed                  |
|               |                                                               |
|   `?18.42`    | `FCOM` index too large: reduce program size                   |
|   `?19.72`    | Logarithm of zero                                             |
|   `?21.57`    | Square root of a negative number                              |
|   `?22.65`    | Numeric overflow: too many digits in a string                 |
|   `?23.18`    | `OUTPUT` `ABORT` or `CLOSE` requested too much space          |
|   `?23.37`    | Output file overflow: recover with: `O O name;O A FLEN()`     |
| __`?23.82`__  | Cannot open output file (file open, too big or no name)       |
| __`?24.05`__  | No output file to resume                                      |
|               |                                                               |
|   `?24.25`    | Illegal `OPEN` command                                        |
|   `?24.35`    | Illegal `RESUME` command                                      |
| __`?24.40`__  | Input file not found (wrong name? wrong device?)              |
|   `?24.47`    | No input file to restart                                      |
| __`?24.52`__  | No input file to resume                                       |
|   `?25.02`    | Stack overflow: reduce nested subroutines and expressions     |
| __`?25.60`__  | Device does not exist or illegal 2-page handler               |
|   `?26.07`    | Illegal `LIBRARY` command                                     |
|   `?26.32`    | File specified is already deleted (wrong extension?)          |
|               |                                                               |
|   `?26.39`    | File loaded is not a FOCAL program - __better reload UWF!__   |
|   `?26.56`    | Program requested is missing (wrong device?)                  |
|   `?26.66`    | `LIBRARY SAVE` error: no name, device full, or no directory   |
|   `?27.18`    | Attempted `LIBRARY` operation on a device without a directory |
|   `?27.75`    | No length specified in a `LIBRARY ZERO` command               |
|   `?27.90`    | Zero divisor                                                |
|   `?29.25`    | Cannot use the '<>' construction with `OPEN OUTPUT`           |
|   `?29.38`    | Device error (write-lock, bad checksum or illegal request)  |

`_`   Indicates EOF detected in input - I/O continues from terminal

`?....?`   TRACE feature: Text enclosed by `?` marks is typed during execution
to help find the source of an error. The value of each expression in a SET
command is also printed
