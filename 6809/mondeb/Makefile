all: mondeb.s19

mondeb.s19: mondeb.asm
	as9 mondeb.asm -l s19 now

upload: mondeb.s19
	ascii-xfr -s mondeb.s19 -l 1 -c 1 >/dev/ttyUSB0

clean:
	$(RM) mondeb.s19 mondeb.lst

distclean: clean
