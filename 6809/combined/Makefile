all: combined.s19 combined.hex

combined.s19: combined.asm
	as9 combined.asm -l s19 now

combined.hex: combined.s19
	srec_cat combined.s19 -Motorola -crop 0xc000 0x10000 -output combined.hex -Intel

clean:
	$(RM) combined.s19 combined.hex combined.lst

distclean: clean
