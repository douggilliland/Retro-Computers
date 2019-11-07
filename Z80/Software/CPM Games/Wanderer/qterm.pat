Patching QTERM for your system.

The first thing to do is to back QTERM up, and then invoke DDT, SID, ZSID,
or whatever your local patch utility is, in the following way:

A>DDT QTERM.COM

DDT (etc.) will read in QTERM, and then prompt. The following is a list of
patch areas where QTERM should be changed to reflect your system. Some of
these are mandatory (i.e. QTERM won't work without them), whereas others
can be changed to null subroutines or empty data without preventing QTERM
from working, it just won't have all the features available.


1. Modem input status: 0110 - 011F

QTERM calls here to check RDR: status. Return with the zero flag set if
no character is available, or with the zero flag clear if a char is
available. Generally this can be an input from the usart / sio / dart
status port followed by an 'and'.

2. Read modem character: 0120 - 012F

This gets a character from the RDR: port once the input status has decided
it's there. Return the character in the a register. Generally this can be
an input from the usart / sio / dart data port.

3. Modem output status: 0130 - 013F

Check if the PUN: port can accept another character. Return with the zero
flag set if the PUN: port can't receive a character, or with the zero flag
clear if the PUN: port is ready. Generally this can be an input from the
usart / sio / dart status port followed by an 'and'.

4. Write modem character: 0140 - 014F

Send the character in the a register to the PUN: port. This will only be
called after the output status routine has returned a non-zero status.
Generally this can be an output to the usart / sio / dart data port.

These first four patches are all necessary for QTERM to work. The next few
are not necessary, but they will be useful.

5. Start break: 0150 - 015F
   End break: 0160 - 016F

The start break subroutine at 0150 should initiate a break condition on
the modem output line, and 0160 should clear the break condition. If these
are to be omitted, then just put return (C9) instructions at 0150 and 0160.

6. Drop DTR: 0170 - 017F
   Restore DTR: 0180 - 018F

The drop DTR subroutine causes DTR to be made inactive, and restore DTR
returns DTR to an active state. If your modem does not respond to DTR, but
can be made to hang up by sending a string, then put a return (C9) at 0170.
Use the space from 0171 to 018F to contain the string, with the following
notes: to transmit a break, use an 0FFH byte, to cause a two second delay
use an 0FEH byte, and use a 00 byte to terminate. Hence the following
could be used to hang up a Hayes compatible:

FE 2B 2B 2B FE 41 54 48 30 0D 00

FE - delay
2B - '+' sent three times
FE - delay
41 54 48 30 0D - ATH0 <return>

If neither DTR nor a string is to be used, then place a return (C9) at
0180 and 0171, and a nop (00) at 0170. The string is used only if a C9
is found at 0170, so by placing the C9 at 0171 the string print is
inhibited.

7. Baud rate setting: 0190 - 019F
   Baud rate table: 01A0 - 01AF

These two patch areas work together to allow QTERM to change the baud rate
of the modem port. The baud rate table holds pairs of bytes for setting the
baud rate to eight different values: 38400, 19200, 9600, 4800, 2400, 1200,
600 and 300, in that order. In these pairs, the first byte will be passed
to the subroutine at 0190, and the second byte is used to enable that baud
rate: an 0FFH in the second byte enables the rate, and a zero disables.
So if your system only went up to 9600, (using a value of 1 to get 9600)
the first six bytes in the table would be:

	00 00		no value for 38400: disable by the 00
	00 00		no value for 19200: disable by the 00
	01 FF		01 is the value for 9600: enable by the FF

In all cases of enabled baud rates, the subroutine at 0190 gets the
appropriate value in the a register and should use it to set the baud rate.
If this is to be omitted, then just put a return (C9) instruction at 0190,
and fill the table from 01A0 to 01AF with 00's.

8. Communication mode setting: 01B0 - 01BF
   Communication mode table: 01C0 - 01CB

These two patch areas work together to allow QTERM to change the
communications format of the modem port. The mode table holds bytes for
setting 12 different formats, selecting number of data bits (7 or 8)
parity (odd, even, or none) and number of stop bits (1 or 2). In order
the 12 values are for 7n1, 8n1, 7n2, 8n2, 7e1, 8e1, 7e2, 8e2, 7o1, 8o1,
7o2, and 8o2. The subroutine at 01B0 gets one of these values in the a
register and should use it to set the communications mode. If this is to
be omitted, then just put a return (C9) instruction at 01B0.

9. Protocol transfer size: 01CD

During protocol transfers, disk reads and writes take place every 8K. This
is normally possible without causing a timeout, and reduces disk access to
a minimum. However if your disk is slow, you can drop this to 4 or even 2
to reduce the size of transfer, and hence prevent timeouts. Note that there
is an unused byte between the end of the communications mode table, and the
transfer size (i.e. at 01CC). This bytes is reserved for future use, and
should not be changed.

10. Processor speed: 01CE

This is the speed in Mhz that your Z80 runs at: 4, 6 or whatever. For
a 2.5Mhz cpu, use 3.

11. Escape character: 01CF

All special functions of QTERM are activated by the use of escape sequences.
At 01CF is the byte used for the escape character (the default is ^\). Any
byte can be used, but a little used value is best selected, also using a
printable character (' ' thru '~') may have undesirable results. Note that to
transmit the escape value itself, just type it twice.

These previous three are necessary.

12. Signon message: 01D0 - 01EF

This must be a string that identifies your system / terminal. It must be
present, and is printed when QTERM first starts. It should be composed of
printable characters, and terminated by a zero byte.

13. Clear screen: 01F0 - 01FF

This must be a string that clears the terminal screen, and leaves the
cursor in the top left hand corner. This should also be terminated by a
zero byte.

14. Moveto: 0200 - 022E

QTERM requires the ability to move the cursor around the screen. It calls
this subroutine with the required coordinates in hl: where h is the row,
and l the column to move to. The top left hand corner of the screen is 0,0;
and the bottom right corner is 23,79. This subroutine will have to do
terminal output: at 0109H is a routine that prints a character in the c
register, and at 010CH is a routine to print a decimal number in hl (mainly
for the use of vt100 and vt220 compatibles). Note that the above two
subroutines will destroy all registers, and that this subroutine can also
destroy all registers.

15. Teminal capability bit map: 022F

This byte contains one bit set for each of the following terminal
capabilities:

bit 0: (01H)	bright (end highlight)
bit 1: (02H)	dim (start highlight)
bit 2: (04H)	delete line
bit 3: (08H)	insert line
bit 4: (10H)	delete character
bit 5: (20H)	insert character
bit 6: (40H)	clear to end of line
bit 7: (80H)	clear to end of screen

16. Terminal capability strings: 0230 - 026F

In this area are eight strings, each of which can be at most eight characters
long. They are the strings to be printed to perform the terminal capabilities
mentioned above. Each one of them should be terminated by a zero byte. Hence
at 0230 is the string for dim (start highlight), at 0238 is the string for
bright (end highlight), etc.; with 0268 being the string for clear to end of
screen. Programs that use these will check the terminal capability bitmap at
022F before using them, to determine if they are available.

17. Entry subroutine: 0270 - 0272

Upon entry to QTERM, this subroutine will be called. If it is not needed
then a return instruction (0C9H) should be placed at 0270, otherwise there
is enough space to put in a jump to code that is to be executed when QTERM
starts.

18. Exit subroutine: 0273 - 0275

After an <Escape> Q has been issued to exit QTERM, this subroutine will
be called immediately before exiting back to CP/M. As with the entry
subroutine, if not needed, a return instruction (0C9H) should be placed at
0273H, otherwise any termination code can be added.

19. Patch area: 0276 - 02FF

Since the area provided for the above patches is limited, it may be necessary
to use more space. The block of memory from 0276 to 02FF is set aside for
custom patches, this can be used if the individual spaces are not big enough.


Once all the patches have been made, exit the patch program (usually by
typing ^C), and finish up by saving a new copy of QTERM:

A>SAVE 51 QTERMNEW.COM

In addition, the patch area only can be saved as follows:

A>SAVE 2 QTERMPAT.XXX

Which will create a 1/2K file containing all the patches needed to make this
particular version of QTERM work. By doing this, when a new release of QTERM
needs to be patched, all that is necessary is to read in the new unpatched
version with DDT or whatever, then overlay the patch area. This is typically
done by typing:

IQTERMPAT.XXX

to DDT, SID, ZSID etc. to set up the command line to read QTERMPAT.XXX, then
follow this with a:

R

to read it. This should overlay the saved patch area on the new version,
hence doing all the patches at once. Then exit DDT with ^C, and do the
first save shown above to save the new working version.


NOTE: this "overlaying" of patches will NOT work with versions 2.8 and
earlier. In addition, three things have been added to the 3.3 patch
area.
1. changing the DTR manipulation area to include a hangup string
2. adding the transfer read / write size at 01CD
3. adding the entry and exit subroutine hooks
