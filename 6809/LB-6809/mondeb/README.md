This is a port of the MONDEB monitor debugger, written by Don Peters
and described in the book "MONDEB, An Advanced M6800 Monitor
Debugger", to the 6809 processor.

The original 6800 version is available here: https://github.com/jefftranter/6800/tree/master/mondeb

For full functionality (e.g. setting interrupt vectors), you can burn
it into an EPROM and run it standalone. It can also be assembled and
loaded into RAM (e.g. from ASSIST09) for test purposes.

To use the code or port it to another computer, you will want to
obtain a copy of the book.

Porting notes:
- Converted to 6809 mnemonics.
- Added support for additional registers (Y, DP, U).
- Changed address of ACIA to match my board.
- Removed output of nulls.
- Added some additional bug fixes and commands based on a 6809 version
  written by Alan R. Baldwin.

Below is an explanation of the features, taken from the original book
with some updates to reflect the changes in this version.

------------------------------------------------------------------------

General Features

The general features of MONDEB are listed below:

- Liberally commented source code.
- A prompt character signifies readiness to accept a command.
- Commands are generally self-explanatory English words.
- Commands may be abbreviated.
- Command may be modified by succeeding words called modifiers.
- A space or command separates a modifier from the command and other
  modifiers.
- "Backspace" may be used to delete the previous character(s).
- Several commands may be placed on one line, separated from one
  another by a semi-colon.
- "Control-C" may be used to abort a line being typed.
- "Control-Z" will repeat the previous command line.
- Lower case alphabetic input is automatically converted to upper case.
- If a syntax error is made, its position in the input line is pointed
  to.
- Input lines may be 72 characters long.
- If output lines are over 72 characters long, an automatic carriage
  return and line feed is inserted after the 72nd character (this is
  called "folding").
- If a space occurs within the last 10 characters on an oversize line,
  folding occurs on that space.
- The input and display bases may be set to hexadecimal, decimal,
  octal or binary (display only).
- ACIA input and output from the terminal or any ACIA address.
- Many routines may be externally accessed through addresses,
  independent of revision number, decreasing the memory requirements
  for the application programs.

Command Summary

In the following command summary:

- Capital letters are typed as is.
- Lower case text within "<" and ">" represents a variable quantity.
- Text within "[" and "]" is optional.
- A vertical bar "|" separates alternatives.
- A "..." represents repetition of the following pattern.

HELP
REG
SET <address> <value> [<value>...]
SET <address range> <value>
SET .<register> <value>
DISPLAY <address range> [DATA|USED]
DBASE [?|HEX|DEC|OCT|BIN]
IBASE [?|HEX|DEC|OCT]
GOTO [>address>]
BREAK [?|<address>]
CONTINUE
TEST <address range>
VERIFY [ <address range>]
SEARCH <address range> <value> [<value>...]
COPY <address range> <address>
COMPARE <value1> <value2>
DUMP <address range> [TO <address>]
LOAD [FROM <address>]
DELAY <value>
FIRQ <address>
INT <address>
NMI <address>
SWI <address>
SWI2 <address>
SWI3 <address>
RSRVD <address>
SEI
CLI
SEF
CLF

Command Description

Whenever MONDEB is waiting for a line of input, it prompts with an
asterisk ("). When finished typing the line of input, the user types a
carriage return and MONDEB begins processing that line. Until the
carriage return is typed, the line can be aborted by typing Control-C,
or one or more preceding characters can be deleted by typing one or
more backspaces. There are two exceptions to this. One is that the
first character typed (after the prompt) may be a Control-Z. This will
cause the prior line of input to be used for the current line as well.
The other exception is that several logical lines may be put on one
physical line by separating one logical line from another by a
semi-colon (;). Any number of spaces may surround this semi-colon.

In the descriptions that follow, an address range is often called for.
This range may be specified as "a:b" which means "address a through
address b", or "a!b" which means "starting at address a and for b more
bytes." For example, both 100:103 and 100:3 imply the addresses 100,
101, 102, and 103.

Note also that all commands could conceivably be abbreviated to the
point where ambiguity sets in. For example, R, RE or REG might each
display the "display registers" command.

REG

The REG command is used to display the contents of the internal
registers, as in the following example:

*REG
 .CC=3C .A=01 .B=F02 .DP=00 .X=1234 .Y=2345 .U=4000 .PC=0156 .S=70A4

The period preceding the register name is used to distinguish its
name from and ordinary hexadecimal number.

SET

The SET command is used to set the contents of memory or
the internal registers to specified data. Example:

*SET 150 2 10 AA FF

This example sets memory location 150 to 2, location 151 to 10,
152 to AA and location 153 to FF. Note that all values are in
hexadecimal.

If several locations are to be set, it is sometimes useful to
"continue" a line with a line feed (LF). This will cause a typeout of
the following line of the next address to be set. Simply continue
typing input data. Terminate the last byte with a carriage return
(CR). In the following example, which illustrates the line feed mode
of data entry, the control characters CR (carriage return) and LF
(line feed) are shown in parentheses.

*SET 100 0 1 2 3 (LF)
0104 4 5 6 (LF)
017 7 (CR)

When more than one memory location is to be set to the same value,
specify a range with the SET command. For example, to set locations
100 through 200 to hexadecimal 3F, enter:

*SET 100:200 3F

The address range in this form of SET command may only be one data
byte.

The internal registers may be set as in the following example:

*SET .A 27 .B FF .PC 1234

This causes register A to be set to 27, B to FF, and PC to 1234.
Again, all values are hexadecimal. Note that a period must precede the
register name to distinguish it from a memory address specified in
hexadecimal. Those registers that may be set are

CC A B DP X Y U PC S

Since these registers correspond to stack locations, they only become
effective with the issuance of a CONTINUE command. Note also that
changing the value of the stack pointer (S) effectively changes all
register values.

DISPLAY

The DISPLAY command is used to display the contents of a memory
address range. For example:

*DIS 100:104
0100=01 0101=5A 0102=23 0103=00 0104=FF

Lines exceeded 72 characters in length are folded.

For faster displays of memory, the DATA modifier may be used. It
causes the output of records of 16 bytes of data per line with the
address of the first byte preceding the data, as shown in the
following example:

*DIS 100:123,DATA
0100 01 5A 23 00 FF 01 07 21 00 00 14 14 32 67 00 00
0110 00 00 CE FA AC A5 54 71 39 00 75 88 72 33 11 22
0120 AA 01 00 31

For even faster displays, a USED modifier will cause
a period (.) to represent a zero byte and a plus sign (+)
to represent a non-zero byte, as in the example below:

*DISPLAY 100:123 USED
0100 +++.++++..++++..
0110 ..+++++++.++++++
0120 ++.+

Note that 16 data values per line are printed when the DATA or USED
modifiers are specified and the display base is hexadecimal. If the
input base is decimal, ten data values per line are output; for octal,
eight values per line. So, the number of values printed per line
indicates the base of the numbers.

DBASE

This command sets the display base to HEX (hexadecimal), DEC
(decimal), OCT (octal), or BIN (binary). If no modifier follows this
command, HEX is assumed. The following example illustrates this
command:

*DIS 104
0104=80
DBASE OCT
*DIS 104
000404=200
*DBASE BIN
*DIS 104
0000000100000100=10000000
*DBASE
*DIS 104
0104=80

Note that the memory address as well as the value is translated to the
desired base, but that the input conversion is still hexadecimal in
each case (see IBASE below).

If there is any doubt as to which display base is in effect, follow
the DBASE command with a question mark, as:

*DBASE ?
OCT

The base in effect will be typed on the succeeding line.

IBASE

Similar in function to the above DBASE command, IBASE is used to set
the input base to HEX (hexadecimal), DEC (decimal), or OCT (octal).
Its format is the same as the DBASE command, including the question
mark option. The only difference is that it operates on input values
instead of output values.

GOTO

The GOTO command is used to transfer control to a specified memory
address, as:

*GO 103

The address specified is saved so that typing the GOTO command at some
future time without a following address value will cause transfer to
the last given GOTO address.

BREAK

The BREAK command is used to set a breakpoint at a specified memory
address. This is done by replacing the content of the specified
address with 3F (hexadecimal) which indicates a "software interrupt"
(SWI) instruction. The original content is saved. This saved code is
restored when the BREAK command is types without an address. For
example:

*BR 763

will put an SWI instruction at location 763. Subsequently,
typing

*BR

will remove the SWI and restore the original instruction.

Upon encountering an SWI instruction, MODEB will type "SWI:",
automatically execute the REG command, and transfer control to command
level. The debugged program could be continued, perhaps after
exercising some MONDEB commands, by typing the CONTINUE command,
providing that the most recent breakpoint has been removed.

If a breakpoint is set while a prior breakpoint is in effect, the
prior breakpoint is automatically removed, i.e. only one breakpoint
can be set and in effect at a time.

To display the current breakpoint, type BREAK followed by a question
mark, as shown in the following example:

*BREAK ?
NOT SET
*BR 123
*BR ?
SET @ 0123

CONTINUE

This command is used to continue a program that has been interrupted
via a breakpoint inserted SWI instruction. Execution will continue at
the address of the SWI instruction. Therefore, it is assumed that the
SWI instruction at that address has been removed by entering

*BREAK

alone to restore the former instruction, or by resetting the
breakpoint at some other location.

The CONTINUE command also causes the set register command to become
effective.

TEST

The TEST command is used to test a programmable memory range for bad
memory locations. The test is a simple one in that each location on
the range is checked to see if it can store all zeros and then all
ones. The addresses of faulty locations and the associated contents
are typed out after the check has been completed.

It should be noted that the original content of the memory location
being tested is preserved. This, the TEST command doesn't alter
memory, making it possible to test memory already loaded with a
program or data.

An example of the test command follows. Note that memory locations
above hexadecimal FFF are undefined:

:TEST 800:1002
1000=00 CAN'T SET TO ONES
1001=00 CAN'T SET TO ONES
1002=00 CAN'T SET TO ONES
1003=00 CAN'T SET TO ONES

VERIFY

The VERIFY command is used to initially compute the checksum of a
memory range, and then subsequently to compare this reference checksum
to a new one generated for the same address range, as shown below:

*VERIFY 0:FFF
3C
*VER
OK

*SET 0013 23
*VER
CHECKSUM ERROR

This command is useful when checking out new software to ensure that
some unforeseen bug has not causes it do destroy part of itself.

The Motorola MIKBUG definition of the checksum of a range is simply
the complement of the sum of all the bytes in the range.

SEARCH

SEARCH is used to search a memory range for a specified string of
bytes. When the sequence is found, the address of the first matching
byte is displayed. The maximum length of a search string is six bytes.
Note that the locations of all matching strings in the search range
are typed, not just the first.

A good use for this command is in program conversion, where, for
instance, all jumps to a certain subroutine must be changed to another
subroutine, as in input and output conversions. Example:

*SEARCH 800:FFF BD FD 06

Note that the address range (800:FFF) is followed by the byte string
(BD FD 06, hexadecimal) being searched for.

COPY

The COPY command is used to copy a range of bytes from one memory
location to another. The source range is followed by the start of the
destination range, as shown in the example below:

*COPY 750!4 20

Note that the copy will not work properly if the source range partly
overlays the destination range and if the first address of the
destination range exceeds the first address of the source range. In
other words, you can shift a range down a few bytes, but not up.

COMPARE

The COMPARE command simply types out the sum and difference between to
specified numbers. This eases the burden of mental computations in
non-decimal bases. For example, when trying to patch in a BSR
instruction, the relative difference of the two addresses may be
needed, as in:

*COMPARE 53F 4FF
SUM IS 0A3E, DIFF is 0040

Note that in subtraction, the second number is subtracted from the
first.

INT

This command allows you to define the location to which control will
transfer upon receipt of an interrupt other than a non-maskable or
software interrupt. For example:

*INT 6074

NMI

Similar to the INT command, NMI defines the location to which control
will transfer upon receipt of a non-maskable interrupt.

SWI

The SWI command is also similar to the INT command, but defines the
location to which control will transfer upon encountering a software
interrupt (SWI) instruction.

SEI

SEI sets the interrupt mask bit, causing interrupts to be ignored. It
has no modifiers.

CLI

CLI clears the interrupt mask bit, causing subsequent interrupts to be
processed normally. CLI also has no modifiers.

DUMP

Dump provides a way to save a portion of memory on paper tape or
cassette tape. The format of the dumped data is identical to that of
the Motorola MIKBUG monitor, except that header (type S0) and trailer
(type S9) records are also included. The example of this command:

*DUMP 600:2400

will dump the address range 600 thru 2400, inclusive. If an address
range is not given, the range stored in RANGLO and RANGHI (see source
listing) is used. This provides the capability of having an external
program set up this range for a subsequent DUMP by MONDEB.

By default, the dumped information will go to the user's terminal. The
dump may be sent to another device (such as a cassette) if that device
is interfaced through a 6850 ACIA. Use the optional TO keyword
followed by the address of the ACIA to dump the information to some
device other than the terminal. For example, a paper tape punch might
be interfaced through an ACIA whose data address is 7F45 (and control
address is 7F44). To dump memory locations 1000 through 2000 to the
paper tape punch, the following command would be used:

*DUMP 1000:2000 TO 7F45

Note that the display base should be set to HEX if the dump is to be a
normal Motorola MIKBUG hexadecimal dump.

LOAD

Motorola MIKBUG formatted tapes can be loaded with the LOAD command.
To load from the terminal, simply type the LOAD command with no
modifiers.

To load from another 6850 ACIA controlled device, append "FROM" and
the data address of the ACIA receiving the formatted load information,
as:

*LOAD FROM 7F41

The loading will terminate when an S9 record is encountered.

DELAY

The DELAY command will delay the prompt for (and processing of) the
next line of input for the specified number of milliseconds. This
feature is intended for the testing of peripheral devices. It possibly
attains its greatest value when interspersed with several other commands
on a composite input line creating delays between the commands. For example,
the following could be used to send three characters to an ACIA controlled
remote terminal at 256 millisecond intervals:

*SET 7F45 30;DELAY 100;SET 7F45 31;DELAY 100;SET 7F45 32

Note that the values are all in hexadecimal.

The delay is generated by an internal loop. The loop time in turn is
dependent on the microprocessor clock rate and a preset variable at
memory location TIMCON.

FIRQ

Similar to the INT command, FIRQ defines the location to which control
will transfer upon receipt of a fast interrupt.

SWI2

Similar to the SWI command, this defines the
location to which control will transfer upon encountering a software
interrupt 2 (SWI2) instruction.

SWI3

Similar to the SWI command, this defines the
location to which control will transfer upon encountering a software
interrupt 2 (SWI2) instruction.

RSRVD

Similar to the INT command, this defines the location to which control
will transfer upon receipt of a reserved interrupt (this is unused on
the 6809 but may exist on other compatible CPUs like the Hitachi
6309).

SEF

Similar to SEI, this sets the fast interrupt mask bit.

CLF

Similar to CLI, this clears the fast interrupt mask bit.

HELP

This command simply displays a list of the valid commands, as below:

REG         GOTO        SEI         CLI
COPY        BREAK       IBASE       DBASE
CONTINUE    DISPLAY     SET         VERIFY
SEARCH      TEST        INT         NMI
SWI         COMPARE     DUMP        LOAD
DELAY       HELP        CLF         SEF
FIRQ        RSRVD       SWI2        SWI3
