all: disasm.s19

disasm.s19: disasm.asm
	as9 disasm.asm -l s19 now

# Change line above for different assemblers:
# as9 disasm.asm -l s19 now
# asm6809 -v -S -o disasm.s19 -l disasm.lst disasm.asm
# lwasm --6809 --format=srec --list=disasm.lst --output=disasm.s19 disasm.asm

upload: disasm.s19
	ascii-xfr -s disasm.s19 -l 1 -c 1 >/dev/ttyUSB0

clean:
	$(RM) disasm.s19 disasm.lst

distclean: clean
