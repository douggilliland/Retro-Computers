# $Id: Makefile,v 4.2.2.9 2005/02/07 10:55:53 albert Exp $
# Copyright(2000): Albert van der Horst, HCC FIG Holland by GNU Public License
#
# This defines the transformation from the generic file ci86.gnr
# into a diversity of Intel 86 assembly sources, and further into
# one of the $(TARGETS) Forth's.

#.SUFFIXES:
#.SUFFIXES:.bin.asm.m4.v.o.c

# Applicable suffixes : * are generated files
# + are generated files if they are mentionned on the next line
#
#* .dvi .tex .ps : as usual (See TeX)
#+ .texinfo : texinfo
#   menu.texinfo gloss.texinfo
#* .asm : input file for `nasm' assembler
#* .BLK : contains blocks usable by Forth
# .frt : text file : contains blocks in an \n separated stream
#* .msm : input file for `MASM' and `tasm' assembler
#* .s : input file for `gas' assembler  Experimental
#* .bin : a binary image without header (useful i.a. for msdos .com)
#* .gas : input file for `gas' assembler
#* .rawdoc : unsorted glossary items from the generic source.
#* .rawtest : unsorted and unexpanded tests.
#+ .m4 : m4 macro's possibly including other macro's
#   except constant.m4
# .cfg : m4 macro's generating files ( ci86.%.x + %.cfg -> ci86.%.y)
# .mi : files that after processed by m4 give a .texinfo file
# .mig : Currently in use for the wordset, which is a .mi file (WRONG!)
# It could be, but it has been stolen.

# ALL FILES STARTING IN ``ci86'' (OUTHER ``ci86.gnr'') ARE GENERATED

INGREDIENTS = \
header.m4       \
postlude.m4      \
prelude.m4       \
protect.m4       \
width16.m4       \
width32.m4       \
# That's all folks!

DOCTRANSFORMS = \
gloss.m4        \
glosshtml.m4    \
indexhtml.m4    \
manual.m4       \
menu.m4  \
names.m4        \
wordset.m4      \
# That's all folks!

# Normally tools are not supplied with the release.
# But this is a tool not otherwise available.
TOOLS=  \
ssort   \
# That's all folks!

# Index files used by info, some are empty for ciforth.
INDICES= cp fn ky pg tp vr

# Different assemblers should generate equivalent Forth's.
ASSEMBLERS= masm nasm gas
# The kinds of Forth assembler sources that can be made using any assembler
TARGETS= lina wina mina alone linux alonehd msdos32 alonetr
# The kinds of Forth's binaries that can be made using NASM (not used)
BINTARGETS= mina alone
# If this makefile runs under Linux, the following forth's can be made and
# subsequently run
LINUXFORTHS= ciforthc lina
# Auxiliary targets. Because of GNU make bug, keep constant.m4.
OTHERTARGETS= forth.lab forth.lab.lina forth.lab.wina toblock fromblock constant.m4 namescooked.m4
# C-sources with various aims. FIXME: start with .c names.
CSRCAUX= toblock fromblock stealconstant
CSRCFORTH= ciforth stealconstant
CSRC= $(CSRCAUX) $(CSRCFORTH)

# Texinfo files still to be processed by m4.
SRCMI= \
assembler.mi    \
cifgen.mi \
ciforth.mi \
intro.mi    \
manual.mi   \
rational.mi  \
# That's all folks!

# Documentation files and archives
DOC = \
COPYING   \
README.ciforth      \
testreport.txt     \
$(SRCMI) \
# That's all folks!

# The following must be updated on the website, whenever
# any typo's are fixed. Unfortunately, it has become a separate
# maintenance chore, and is in effect a separate project.
DOCOLD = \
figdoc.zip    \
# That's all folks!

# These files can easily be generated, if you have linux.
EXAMPLES = \
ci86.alone.asm  \
ci86.mina.msm  \
ci86.wina.asm  \
ci86.linux.asm  \
ci86.lina.asm  \
ci86.alonehd.asm  \
# That's all folks!

# Note that the generated file ``namescooked.m4'' is included,
# because it require RCS to generate.
RELEASECONTENT = \
ci86.gnr        \
$(CSRC:%=%.c)   \
$(TARGETS:%=%.cfg)      \
$(DOC)          \
namescooked.m4  \
Makefile        \
test.mak        \
tsuite.frt      \
$(INGREDIENTS)  \
$(ASSEMBLERS:%=%.m4)    \
$(DOCTRANSFORMS)        \
$(TOOLS)        \
blocks.frt      \
options.frt     \
genboot.bat     \
$(EXAMPLES)     \
wc              \
errors.linux.txt \
errors.dos.txt \
# That's all folks!

# 4.0 ### Version : an official release 4.0
# Left out : beta, revision number is taken from rcs e.g. 3.154
VERSION=  # Because normally VERSION is passed via the command line.
DATE=2030     # To get the newest version

RELEASELINA = \
COPYING   \
README.lina \
ci86.lina.info \
ci86.lina.html \
ci86.lina.pdf \
ci86.lina.ps \
ci86.lina.texinfo \
ci86.lina.asm      \
ci86.lina.s      \
lina      \
lina.1    \
forth.lab     \
$(CSRCAUX:%=%.c)    \
wc            \
# That's all folks!

TEMPFILE=/tmp/ciforthscratch

# Define NASM as *the* assembler generating bin files.
%.bin:%.asm
	nasm -fbin $< -o $@ -l $*.lst


# mina.cfg and alone.cfg are present (at least via RCS)
# allow to generate ci86.mina.bin etc.
ci86.%.rawdoc ci86.%.rawtest : ci86.%.asm ;

VERSION : ; echo 'define({M4_VERSION},$(VERSION))' >VERSION

ci86.%.asm : %.cfg VERSION nasm.m4 ci86.gnr
	make constant.m4
	cat $+ | m4 >$(TEMPFILE)
	sed $(TEMPFILE) -e '/Split here for doc/,$$d' >$@
	sed $(TEMPFILE) -e '1,/Split here for doc/d' | \
	sed -e '/Split here for test/,$$d' >$(@:%.asm=%.rawdoc)
	sed $(TEMPFILE) -e '1,/Split here for test/d' >$(@:%.asm=%.rawtest)
	rm $(TEMPFILE)

ci86.%.msm : VERSION %.cfg masm.m4 ci86.gnr ; \
	cat $+ | m4 >$(TEMPFILE)
	sed $(TEMPFILE) -e '/Split here for doc/,$$d' >$@
	sed $(TEMPFILE) -e '1,/Split here for doc/d' | \
	sed -e '/Split here for test/,$$d' >$(@:%.msm=%.rawdoc)
	sed $(TEMPFILE) -e '1,/Split here for test/d' >$(@:%.msm=%.rawtest)
	rm $(TEMPFILE)

# Now that gas has the .Intel_syntax option, its source can be
# generated by m4 alone. In particular the order of operands.
ci86.%.s : VERSION %.cfg gas.m4 ci86.gnr ; \
	make constant.m4
	cat $+ | m4 >$(TEMPFILE)
	sed $(TEMPFILE) -e '/Split here for doc/,$$d' >$@
	sed $(TEMPFILE) -e '1,/Split here for doc/d' | \
	sed -e '/Split here for test/,$$d' >$(@:%.s=%.rawdoc)
	sed $(TEMPFILE) -e '1,/Split here for test/d' >$(@:%.s=%.rawtest)
	rm $(TEMPFILE)

.PRECIOUS: ci86.%.rawdoc

.PHONY: default all clean boot filler moreboot allboot hdboot releaseproof zip mslinks release
# Default target for convenience
default : lina
ci86.$(s).bin :

# Put include type of dependancies here
$(TARGETS:%=%.cfg) : $(INGREDIENTS) ; if [ -f $@ ] ; then touch $@ ; else co $@ ; fi

# Some of these targets make no sense and will fail
all: $(TARGETS:%=ci86.%.asm) $(TARGETS:%=ci86.%.msm) $(BINTARGETS:%=ci86.%.bin) \
    $(LINUXFORTHS) $(OTHERTARGETS)

clean: \
; rm -f $(TARGETS:%=ci86.%.*)  $(CSRCS:%=%.o) $(LINUXFORTHS) VERSION spy\
; for i in $(INDICES) ; do rm -f *.$$i *.$$i's' ; done

cleanall: clean  testclean ; \
    rcsclean ; \
    rm -f $(OTHERTARGETS) ; \
    rm -f *.aux *.log *.ps *.toc *.pdf


#msdos32.zip doesn't work yet.
release : strip figdoc.zip zip msdos.zip lina.zip # as.zip

#Install it. To be run as root
install: ; @echo 'There is no "make install" ; use "lina -i <binpath> <libpath>"'

# You may need to run the following run as root.
# Make a boot floppy by filling the bootsector by a raw copy,
# then creating a dos file system in accordance with the boot sector,
# then copying the forth system to exact the first available cluster.
# The option BOOTFD must be installed into alone.m4.
boot: ci86.alone.bin
	cp $+ /dev/fd0H1440 || fdformat /dev/fd0H1440 ; cp $+ /dev/fd0H1440
	mformat -k a:
	mcopy $+ a:forth.com

# You may need to run the following run as root.
# Make a raw boot floppy with no respect for DOS.
# The Forth gets its information from the boot sector,
# that is filled in with care.
# The option BOOTSECTRK must be installed into alonetr.m4.
trboot: ci86.alonetr.bin lina forth.lab.wina
	rm fdimage || true
	echo \"ci86.alonetr.bin\" GET-FILE DROP HEX 10000 \
	     \"fdimage\" PUT-FILE BYE | lina
	cat forth.lab.wina >>fdimage
	cp fdimage /dev/fd0H1440 || fdformat /dev/fd0H1440 ; cp fdimage /dev/fd0H1440

filler.frt: ; echo This file occupies one disk sector on IBM-PCs >$@

# ciforth calculates whether the screen boundaries are off by a sector.
# You can copy the filler by hand if this calculation fails, e.g. 5" floppies.
# The symptom is 8 LIST show the electives screen half and half of some other screen.
filler: ci86.alone.bin lina filler.frt
	rm -f wc # Use the official `wc' command
	# Have forth calculate whether we need the filler sector
	(filesize=`cat ci86.alone.bin |wc -c`; \
	x=`echo $$filesize 1 - 512 / 1 + 2 MOD . BYE | lina`; \
	if [ 0 = $$x ] ; then mcopy filler.frt a:filler.frt ;fi)

moreboot: forth.lab.wina ci86.alone.bin  ci86.mina.bin
	mcopy forth.lab.wina a:forth.lab
	mcopy ci86.mina.bin      a:mina.com

allboot: boot filler moreboot

forth.lab.lina : toblock options.frt errors.linux.txt blocks.frt
	cat options.frt errors.linux.txt blocks.frt | toblock >$@
	ln -f $@ forth.lab

forth.lab.wina : toblock options.frt errors.dos.txt blocks.frt
	cat options.frt errors.dos.txt blocks.frt | toblock >$@
	ln -f $@ forth.lab

# Like above. However there is no attempt to have MSDOS reading from
# the hard disk succeed.
# The option BOOTHD must be installed into alone.m4.
hdboot: ci86.alonehd.bin
	cp $+ /dev/fd0H1440 || fdformat /dev/fd0H1440 ; cp $+ /dev/fd0H1440

figdoc.txt glossary.txt frontpage.tif memmap.tif : ; co -r1 $@
figdoc.zip : figdoc.txt glossary.txt frontpage.tif memmap.tif ; zip figdoc $+

zip : $(RELEASECONTENT) ; echo ciforth-$(VERSION).tar.gz $+ | xargs tar -cvzf

# For msdos truncate all file stems to 8 char's and loose prefix `ci86.'
# Compiling a simple c-program may be too much, so supply forth.lab
msdos.zip : $(RELEASECONTENT) mslinks ;\
	ln -f forth.lab.wina forth.lab ;\
    echo fg$(VERSION) $(RELEASECONTENT) forth.lab |\
    sed -e's/ ci86\./ /g' |\
    sed -e's/ gnr / ci86.gnr /g' |\
    xargs zip -k

# More messy things in behalf of msdos
mslinks :
	ln -sf ci86.lina.asm lina.asm
	ln -sf ci86.linux.asm linux.asm
	ln -sf ci86.mina.msm mina.msm
	ln -sf ci86.wina.asm wina.asm
	ln -sf ci86.mina.asm forth32.asm
	ln -sf ci86.mina.bin forth32.com
	ln -sf ci86.alone.asm alone.asm
	ln -sf ci86.alonehd.asm alonehd.asm
	ln -f forth.lab.wina forth.lab


forth.lab : forth.lab.lina forth.lab.wina

lina.zip : $(RELEASELINA) ;\
	make forth.lab.lina
	ln -f forth.lab.lina forth.lab
	ls $+ | sed s:^:lina-$(VERSION)/: >MANIFEST
	(cd ..; ln -s ciforth lina-$(VERSION))
	(cd ..; tar -czvf ciforth/lina-$(VERSION).tar.gz `cat ciforth/MANIFEST`)
	(cd ..; rm lina-$(VERSION))

releaseproof : ; for i in $(RELEASECONTENT); do  rcsdiff -w $$i ; done

ci86.lina.o : ci86.lina.asm ; nasm $+ -felf -o $@ -l $(@:.o=.lst)

ci86.%.o : ci86.%.asm ; nasm $+ -felf -o $@ -l $(@:.o=.lst)

# The tricky `link.script' has been dispensed with.
# However, now we need _fini and _init in ciforth.c and
# there are a few elf sections (.bss) that are mapped in the
# dictionary. But works.
ciforthc : ciforth.o ci86.linux.o
	 ld -static /usr/lib/gcrt1.o $+ -lc  -o ciforthc

# Linux native forth
lina : ci86.lina.o ; ld $+ -o $@

# Linux native forth by gnu tools
glina : ci86.lina.s ; as $+; \
    strip a.out --strip-unneeded -R .bss -R .data -R .text ; \
    ld a.out -o $@  ; strip $@ -s -R .bss

# This dependancy is problematic.
# Do `make constant.m4' explicitly beforehand.
# Because otherwise `constant.m4' is counted into the ``$+'' set.b
# ci86.alone.asm : constant.m4

# Convenience under linux. Steal the definitions of constants from c include's.
stealconstant: stealconstant.c ;  \
    cc $+ -o stealconstant

# Convenience under linux. Steal the definitions of constants from c include's.
constant.m4 : stealconstant ; $+ >$@

# Add termporary stuff for testing, if needed.
include test.mak
