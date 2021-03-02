Two Disk Monitor System images are provided.

dms.df32      -- This is the standard DMS distribution
dms_demo.df32 -- This is dms.df32 with a sample Fortran and PAL program

The program stat.ascii is the Fortran program.  It will read from the
low speed (teletype) paper tape reader number and print the sum and
standard deviation.  The numbers will not echo while you are typing them.
If you change line 9 from read to accept it will.

The other is a program to punch a section of memory in rim format to the
low speed (teletype) paper tape punch.

To boot DMS, use the command BOOT -D DF.

This is a sample session using DMS.  The first we boot, then get a directory,
then assemble the PAL program, then compile and run the Fortran program.
The last is editing the Fortran file to convert the read to an accept 
statement.

^ followed by a letter is where I entered a control character.  ^C would
be control key and C. (Before the ^P the system prints a ^ as a prompt)

\ is normally the character echoed when you hit the rubout (delete) key to
delete a character.  What key this maps to on a modern terminal or an xterm
is configurable.

The manual for the disk monitor system is available at
http://www.pdp8.net/pdp8cgi/query_docs/view.pl?id=35
The programmers reference manual is available at
http://www.pdp8.net/pdp8cgi/query_docs/view.pl?id=451

The manuals for the various other programs that run under the disk monitor
system are available at 
http://www.pdp8.net/query_docs/query.shtml
Search for the particular program you are looking for.

If you have any questions feel free to contact me
djg@pdp8.net

[djg@munin 4KMon]$ ../pdp8

PDP-8 simulator V2.9-0
sim> set df enabled
sim> att df dms_demo.df32
DF: buffering file in memory
sim> boot -d df

.PIP
*OPT-L

*IN-S:

FB=0047

NAME  TYPE    BLK 

AF
PIP .SYS (0) 0025
EDIT.SYS (0) 0016
LOAD.SYS (0) 0011
.CD..SYS (0) 0007
PALD.SYS (0) 0037
DDT .SYS (0) 0002
.DDT.USER(0) 0022
.SYM.USER(0) 0022
FORT.SYS (0) 0010
.FT..SYS (0) 0035
.OS..SYS (0) 0025
FOSL.SYS (0) 0010
STBL.SYS (0) 0001
DIAG.SYS (0) 0004
STAT.ASCII   0003
PUNR.ASCII   0004

*OPT-^C
.PALD
*OUT-
*
*IN-S:PUNR
*
*OPT-

END    6101
LEN    6056
LLOOP  6042
LOC    6055
PLOOP  6007
PUN    6047
PUNLDR 6037
PUNRNG 6000
START  6100
WAITP  6052

.FORT
*OUT-S:STAT
*
*IN-S:STAT
*
^^P
*READY
^^P
ENTER THE NUMBER OF VALUES TO CACULATE STATISTICS ON
2
VALUE 1    IS 0.321321E+3    
VALUE 2    IS 0.342334E+4    
NUMBER OF VALUES 2    MEAN 0.187233E+4    STANDARD DEVIATION 0.155101E+4
    
!
.
.EDIT
*OUT-S:ST2
*
*IN-S:STAT
*
*OPT-

*R

*9S (1 typed after the 9S, not echoed and , typed after the first ^G and ^G
     typed after the second ^G)
        READ\\\\ACCEPT^G 1,\\^G110,V

*E
 
.FORT
*OUT-S:ST2
*
*IN-S:ST2
*
^
*READY
^
ENTER THE NUMBER OF VALUES TO CACULATE STATISTICS ON
5
1.234
VALUE 1    IS 0.123400E+1    
53532.532
VALUE 2    IS 0.535325E+5    
532.
VALUE 3    IS 0.532000E+3    
532.5
VALUE 4    IS 0.532500E+3    
53.5
VALUE 5    IS 0.535000E+2    
NUMBER OF VALUES 5    MEAN 0.109303E+5    STANDARD DEVIATION 0.213022E+5
    
!
.
Simulation stopped, PC: 07443 (JMP 7442)
sim> quit
Goodbye
DF: writing buffer to file
