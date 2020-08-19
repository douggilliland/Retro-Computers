
# makefile for 68k simulator

CODE1.obj: CODE1.c def.h
	cl -c -AL CODE1.c

CODE2.obj : CODE2.c def.h
	cl -c -AL CODE2.c

CODE3.obj : CODE3.c def.h
	cl -c -AL CODE3.c

CODE4.obj : CODE4.c def.h
	cl -c -AL CODE4.c

CODE5.obj : CODE5.c def.h
	cl -c -AL CODE5.c

CODE6.obj : CODE6.c def.h
	cl -c -AL CODE6.c

CODE7.obj : CODE7.c def.h
	cl -c -AL CODE7.c

CODE8.obj : CODE8.c def.h
	cl -c -AL CODE8.c

CODE9.obj : CODE9.c def.h
	cl -c -AL CODE9.c

HELP.obj : HELP.c def.h
	cl -c -AL HELP.c

IOBOX.obj : IOBOX.c def.h
	cl -c -AL IOBOX.c

SCAN.obj : SCAN.c def.h
	cl -c -AL SCAN.c

RUN.obj : RUN.c def.h
	cl -c -AL RUN.c

SIM.obj : SIM.c def.h
	cl -c -AL SIM.c

SIMOPS1.obj : SIMOPS1.c def.h
	cl -c -AL SIMOPS1.c

SIMOPS2.obj : SIMOPS2.c def.h
	cl -c -AL SIMOPS2.c

STRUTILS.obj : STRUTILS.c def.h
	cl -c -AL STRUTILS.c

UTILS.obj : UTILS.c def.h
	cl -c -AL UTILS.c

sim.exe : sim.obj CODE1.obj CODE2.obj CODE3.obj CODE4.obj CODE5.obj \
	CODE6.obj CODE7.obj CODE8.obj CODE9.obj HELP.obj IOBOX.obj \
	SCAN.obj RUN.obj SIMOPS1.obj SIMOPS2.obj STRUTILS.obj UTILS.obj
	link @sim.lnk
