
#
# Program: asm
#

.c.obj:
	cl -c -AS $*.c

codegen.obj : codegen.c \
	asm.h 

directiv.obj : directiv.c \
	asm.h 

error.obj : error.c \
	asm.h 

eval.obj : eval.c \
	asm.h 

globals.obj : globals.c \
	asm.h 

instlook.obj : instlook.c \
	asm.h 

listing.obj : listing.c \
	asm.h 

main.obj : main.c \
	asm.h 

movem.obj : movem.c \
	asm.h 

object.obj : object.c \
	asm.h 

opparse.obj : opparse.c \
	asm.h 

symbol.obj : symbol.c \
	asm.h 

assemble.obj : assemble.c \
	asm.h 

build.obj : build.c \
	asm.h 

insttabl.obj : insttabl.c \
	asm.h 

asm.exe : codegen.obj directiv.obj error.obj eval.obj globals.obj  \
		instlook.obj listing.obj main.obj movem.obj object.obj  \
		opparse.obj symbol.obj assemble.obj build.obj insttabl.obj 
	del asm.lnk
	echo codegen.obj+ >>asm.lnk
	echo directiv.obj+ >>asm.lnk
	echo error.obj+ >>asm.lnk
	echo eval.obj+ >>asm.lnk
	echo globals.obj+ >>asm.lnk
	echo instlook.obj+ >>asm.lnk
	echo listing.obj+ >>asm.lnk
	echo main.obj+ >>asm.lnk
	echo movem.obj+ >>asm.lnk
	echo object.obj+ >>asm.lnk
	echo opparse.obj+ >>asm.lnk
	echo symbol.obj+ >>asm.lnk
	echo assemble.obj+ >>asm.lnk
	echo build.obj+ >>asm.lnk
	echo insttabl.obj  >>asm.lnk
	echo asm.exe >>asm.lnk
	echo asm.map >>asm.lnk
	link @asm.lnk /NOI $(LDFLAGS);
