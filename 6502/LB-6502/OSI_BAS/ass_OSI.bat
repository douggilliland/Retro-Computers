..\ca65 osi_bas.s -o osi_bas.o -l
..\ld65 -C osi_bas.cfg osi_bas.o -o osi_bas.bin
..\srec_cat.exe osi_bas.bin -binary -o osi_bas.hex -Intel
