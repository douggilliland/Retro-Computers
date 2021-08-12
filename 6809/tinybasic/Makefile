all:	tinybasic.s19

tinybasic.s19: tinybasic.asm
	as9 tinybasic.asm -l s19 now

clean:
	$(RM) tinybasic.lst tinybasic.s19

distclean: clean

upload: tinybasic.s19
	ascii-xfr -s tinybasic.s19 -l 1 -c 1 >/dev/ttyUSB0
