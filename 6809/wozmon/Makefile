all: wozmon.s19

wozmon.s19: wozmon.asm
	as9 wozmon.asm -l s19 now

upload: wozmon.s19
	ascii-xfr -s wozmon.s19 -l 1 -c 1 >/dev/ttyUSB0

clean:
	$(RM) wozmon.s19 wozmon.lst

distclean: clean
