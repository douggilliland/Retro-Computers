all: basic.s19

basic.s19: basic.s
	as9 basic.s -l s19 now

upload: basic.s19
	ascii-xfr -s basic.s19 -l 1 -c 1 >/dev/ttyUSB0

clean:
	$(RM) basic.s19 basic.lst

distclean: clean
