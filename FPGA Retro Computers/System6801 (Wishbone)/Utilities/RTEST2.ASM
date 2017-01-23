       nam     rtest2
       idnt    Relocation TEST file #2 (Stack Module)
*
*      This module contains the STACK memory
*
       spc     1
*
*      external Definitions
*
       xdef    stack,rtest1,reltst
       spc     1
*
*      stack   area
*
b$sect comm    1
       rmb     20
stack  equ     *-1
       psct
rtest1 equ     *
reltst rts
       spc     1
*
*      End of module
*
       end
