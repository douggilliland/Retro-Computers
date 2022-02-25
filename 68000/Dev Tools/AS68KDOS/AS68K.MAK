I=D:\include
TFILES = GEN20 FLOAT PMMU COPROC PSEUDO
COPT =  -DGEN20 -DFLOAT -DPMMU -DCOPROC -DPSEUDO -DM68020

.c.obj:
  tcc -c -ml -N -K -wnod -w-aus -w-par $(COPT) -ID:\include $< 

as68k.exe: as.obj do.obj emit.obj eval.obj lookup.obj match.obj \
           srec.obj util.obj table.obj
	tlink @as68k.rsp



as.obj:  as.h table.h lookup.h

do.obj:  as.h table.h lookup.h regs.h

emit.obj:  as.h table.h lookup.h

eval.obj:  as.h lookup.h table.h

lookup.obj:  as.h table.h lookup.h

match.obj:  as.h table.h lookup.h

srec.obj:  as.h table.h lookup.h

util.obj:  as.h table.h lookup.h

table.obj:  table.c table.h

table.c:    $(TFILES) table.awk table.end
        bldtab  -o table.c $(TFILES)
	copy table.c+mne.sor+table.end table.c
