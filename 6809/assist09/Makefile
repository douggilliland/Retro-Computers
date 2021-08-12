all: assist09-orig.s19 assist09-6850.s19

assist09-orig.s19: assist09-orig.asm
	as9 assist09-orig.asm -l s19 now

assist09-6522.s19: assist09-6522.asm
	as9 assist09-6522.asm -l s19 now

assist09-6850.s19: assist09-6850.asm
	as9 assist09-6850.asm -l s19 now

clean:
	$(RM) assist09-orig.s19 assist09-orig.lst
	$(RM) assist09-6522.s19 assist09-6522.lst
	$(RM) assist09-6850.s19 assist09-6850.lst

distclean: clean
