REM               HCC FIG generic 8086 FORTH
REM $Id: genboot.bat,v 4.1 2002/10/17 13:44:05 albert Exp $
REM Copyright (2000): Albert van der Horst, HCC FIG Holland by GNU Public License
REM Generates a bootable disk from a TASM/MASM forth FigForth src in %1
REM It must be configured as USEBIOS and BOOTXX and for the proper disk format.

REM THE FOLLOWING IS TENTATIVE.
ECHO FLOPPY A: WILL BECOME A FORTH BOOTABLE DISK
ECHO ALL DATA WILL BE LOST!
ECHO HIT ^C IF YOU WANT TO STOP.
PAUSE

NASM16 %1.asm -o %1.com
REM Equally possible:
REM Tasm/la/zi %1        or       masm %1
REM                   plus
REM tlink/v %1         or       tlink/t %1

echo N > \tmp\fminput.$$$
echo N >> \tmp\fminput.$$$
echo N >> \tmp\fminput.$$$
Format a:/u <\tmp\fminput.$$$
REM BEWARE! This may have to be changed to %1.EXE if not using NASM
echo N %1.com> \tmp\dbinput.$$$
echo L >> \tmp\dbinput.$$$
REM WRITE BOOTSECTOR
echo W cs:100 0 0 1>> \tmp\dbinput.$$$
REM WRITE BOOTABLE FILE
echo N A:FORTH.COM>> \tmp\dbinput.$$$
echo W cs:0100>> \tmp\dbinput.$$$
echo Q>> \tmp\dbinput.$$$
DEBUG                < \tmp\dbinput.$$$

REM SUCCESFULL ENDING
REM USE THE FOLLOWING LINE IF THE SCREENS ARE SPLIT BY SECTOR BOUNDARIES
rem echo >a:FILLER
COPY BLOCKS.BLK A:
A:
ATTRIB +S +R +H FORTH.COM
C:
EXIT
