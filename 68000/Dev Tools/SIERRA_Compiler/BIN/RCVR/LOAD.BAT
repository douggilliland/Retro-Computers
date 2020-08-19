ECHO OFF
REM The following script uses Motorola S records to load the 68020 parallel
REM receiver starting at memory location 0x50000.  The address of the
REM parallel reveiver can be changed by simply changing the .text offset.
REM As written, this load script must be run from the current directory. If a
REM full path to the receiver program is specified, LOAD.BAT can be run from
REM any directory.

sldr -o .text = 0x50000 prcvr020.out

