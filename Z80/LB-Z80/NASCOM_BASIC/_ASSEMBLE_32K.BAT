set TASMTABS=..
..\tasm -80 -fff -c bas32k.asm bas32k.hex
..\tasm -80 -fff -c int32k.asm int32k.hex
..\srec_cat.exe int32k.hex -Intel BAS32K.HEX -Intel -fill 0xff 0x0144 0x014f -o rom32.hex -Intel
