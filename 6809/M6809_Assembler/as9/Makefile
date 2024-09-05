

SRCH=   \
as.h    \
table9.h \
#

SRCC=   \
as9.c   \
as.c    \
do9.c   \
eval.c  \
ffwd.c  \
output.c        \
pseudo.c        \
symtab.c        \
util.c          \
#

# This is peculiar, as9 only includes other files.
# The main program sits in as.c
as9 : $(SRCC) $(SRCH) ; gcc -g $< -o $@
#as9 : $(SRCC) $(SRCH) ; gcc -g -DDEBUG $< -o $@

as9.tgz : $(SRCC) $(SRCH) as9 changes.doc Makefile; tar cfz $@ $^

as9.zip : $(SRCC) $(SRCH) as9n.c as9 as9.exe as9_changes.txt Makefile; zip $@ $^

m6809src.zip : assist09.asm forth9.asm ; zip $@ $^

testrom :  as9
	as9 rom.asm -l c s bin s19 cre
	diff -b -B rom.lst results/rom.lst
	diff -b -B rom.bin results/rom.bin
	diff -b -B rom.s19 results/rom.s19

testassist09 :  as9
	as9 assist09.asm -l c s bin s19 cre now
	diff -b -B assist09.lst results/assist09.lst
	diff -b -B assist09.bin results/assist09.bin
	diff -b -B assist09.s19 results/assist09.s19

testforth9 :  as9
	as9 forth9.asm -l c s bin s19 cre
	diff -b -B forth9.lst results/forth9.lst
	diff -b -B forth9.bin results/forth9.bin
	diff -b -B forth9.s19 results/forth9.s19

test : testrom testassist09 testforth9
