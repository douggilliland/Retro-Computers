all: ex1.s19 ex2.s19 ex3.s19 ex4.s19 ex5.s19 ex6.s19 ex7.s19 ex8.s19

ex1.s19: ex1.asm
	as9 ex1.asm -l s19

ex2.s19: ex2.asm
	as9 ex2.asm -l s19

ex3.s19: ex3.asm
	as9 ex3.asm -l s19

ex4.s19: ex4.asm
	as9 ex4.asm -l s19

ex5.s19: ex5.asm
	as9 ex5.asm -l s19

ex6.s19: ex6.asm
	as9 ex6.asm -l s19 now

ex7.s19: ex7.asm
	as9 ex7.asm -l s19 now

ex8.s19: ex8.asm
	as9 ex8.asm -l s19 now

upload1: ex1.s19
	ascii-xfr -s ex1.s19 -l 1 -c 1 >/dev/ttyUSB0

upload2: ex2.s19
	ascii-xfr -s ex2.s19 -l 1 -c 1 >/dev/ttyUSB0

upload3: ex3.s19
	ascii-xfr -s ex3.s19 -l 1 -c 1 >/dev/ttyUSB0

upload4: ex4.bas
	ascii-xfr -s ex4.bas -l 20 -c 2 >/dev/ttyUSB0

upload5: ex5.s19
	ascii-xfr -s ex5.s19 -l 1 -c 1 >/dev/ttyUSB0

upload6: ex6.s19
	ascii-xfr -s ex6.s19 -l 1 -c 1 >/dev/ttyUSB0

upload7: ex7.s19
	ascii-xfr -s ex7.s19 -l 1 -c 1 >/dev/ttyUSB0

upload8: ex8.s19
	ascii-xfr -s ex8.s19 -l 1 -c 1 >/dev/ttyUSB0

clean:
	$(RM) ex1.s19 ex1.lst
	$(RM) ex2.s19 ex2.lst
	$(RM) ex3.s19 ex3.lst
	$(RM) ex4.s19 ex4.lst
	$(RM) ex5.s19 ex5.lst
	$(RM) ex6.s19 ex6.lst
	$(RM) ex7.s19 ex7.lst
	$(RM) ex8.s19 ex8.lst

distclean: clean
