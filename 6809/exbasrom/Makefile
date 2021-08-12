all:	ExBasROM.s19 ExBasROM.hex

ExBasROM.s19: ExBasROM.asm
	as9 ExBasROM.asm -now l s19

ExBasROM.hex: ExBasROM.asm
	srec_cat ExBasROM.s19 -Motorola -crop 0xc000 0x10000 -output ExBasROM.hex -Intel

clean:
	$(RM) *.lst *.s19 *.hex
