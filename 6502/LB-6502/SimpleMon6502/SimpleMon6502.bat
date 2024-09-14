CLS
..\ca65 SimpleMon6502.s -o SimpleMon6502.o -l
..\ld65 -C LB65022.cfg SimpleMon6502.o -o SimpleMon6502.bin
..\srec_cat.exe SimpleMon6502.bin -binary -o SimpleMon6502.hex -Intel
