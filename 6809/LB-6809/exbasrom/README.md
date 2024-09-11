This is a port of Microsoft Extended BASIC, as used in the Tandy
Color Computer 2, modified for the SBC with all I/O via serial.

See http://searle.x10host.com/6809/Simple6809.html

It can be cross-assembled using the AS9 assembler found at
http://home.hccnet.nl/a.w.m.van.der.horst/m6809.html

Here are notes on some quirks of this variant of BASIC where it
differs from some other versions of Microsoft BASIC. This may help in
porting programs such as games:

General: All keywords and variables must be entered in upper case,
although you can use lower case in strings.

RND() function:

RND(0) returns a random floating point number between 0 and 1. RND(n),
where n is greater than 0, returns an integer between 0 and n. Most
BASICs return a value between 0 and 1 for any argument value (1 seems
to be commonly used in many programs).

FRE() function:

This is not present, but you can use the pseudo-variable MEM instead
to report the amount of free memory.

INPUT command:

The command does not allow you to specify a prompt string to be
displayed, as many other versions of BASIC do. You can work around
this by using a PRINT statement to display the prompt before calling
INPUT.
