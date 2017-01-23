all:   rtest.s19

rtest1.ro : rtest1.asm
  rmca00 -l rtest1.asm

rtest2.ro : rtest2.asm
  rmca00 -l rtest2.asm

rtest3.ro : rtest3.asm
  rmca00 -l rtest3.asm

rtest.l   : rtest2.ro rtest3.ro
  copy rtest2.ro+rtest3.ro rtest.l

rtest.s19 : rtest1.ro rtest.l
  rmcl @rtest
