cl65 --start-addr 0x300 -Wl -D,__HIMEM__=$2000,-D,__STACKSIZE__=$0200 -t osic1p -vm -m %1.map --listing %1.lst -o %1.o  screen-c1p-48x16.s %1.c
"C:\Users\HPz420\Documents\GitHub\Doug Gilliland\Retro-Computers\6502\RetroAssembler\retroassembler.exe" -d -D=0x0300 %1.o %1.DIS
"..\..\..\PC Tools\srecord\srec_cat.exe" %1.o -bin -of 0x300 -o %1.c1p -os -esa=0x300
