echo off
echo THIS assumes MSDOS runnable DDTZ, SLRMAC, SLRNKP exist
echo and that Z80 (Z80MU by Joan Riff) emulator exists.
echo Note that Z80 is faulty and will not run SLR's SLRMAC and SLRNKP
echo This is easier with DOSPLUS/CCPLUS/JOB/XJOB (native system)
slrmac ccinstal,ddtz/r,ddtdisa/r
slrnkp ddtzero/n,/v:5,/m:5,/p:0,ddtdisa,ddtz,/e
slrnkp ddtone/n,/p:100,ddtdisa,ddtz,/e
del ddtz.slr
del ddtdisa.slr
del temp.cpm
echo With batch cannot automate the run of DDTZ below, so...
echo  after DDTZ loads ccinstal.cpm DO
echo -nddtzero.cim
echo -l100
echo -d203,204
echo -nddtone.cpm
echo -l19e1              (only if d203,204 gave e1 18)
echo -ntemp.cpm
echo -w
echo -q
ddtz ccinstal.cpm
echo AFTER z80 loads DO
echo temp                (will announce save value, usually 29)
echo save nn ddtznew.cpm (must convert decimal above to hex, usually 1d)
echo exit
z80
del ddtzero.cim
del ddtone.cpm
del ccinstal.cpm
õ,