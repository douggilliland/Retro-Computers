all: trace.s19

trace.s19: trace.asm
	as9 trace.asm -l s19 now

# Change line above for different assemblers:
# as9 trace.asm -l s19 now
# asm6809 -v -S -o trace.s19 -l trace.lst trace.asm
# lwasm --6809 --format=srec --list=trace.lst --output=trace.s19 trace.asm

upload: trace.s19
	ascii-xfr -s trace.s19 -l 1 -c 1 >/dev/ttyUSB0

clean:
	$(RM) trace.s19 trace.lst

distclean: clean
