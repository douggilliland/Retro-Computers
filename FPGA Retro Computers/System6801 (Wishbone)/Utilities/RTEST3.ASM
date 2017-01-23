       nam     rtest3
       idnt    Relocation TEST file #3 (Main Module)
*
*      This module contains the MAIN calling routine
*

*
*      External Definitions
*
       xdef    __start
       spc     1
*
*      External References
*
       xref    cnvt,1:stack
       spc     1

       section 3
indata fcc     /NOW IS THE TIME FOR ALL GOOD MEN.../
       fcb     0
       spc     1
*
*      The main calling routine
*
       section 4      
 bsz 82
__start  lds     #stack  . set the stack
       ldx     #indata . point at the data
       bsr     cnvt    . call the conversion routine
forevr bra     forevr  . hang when done
       spc     1
*
*      End of module
*
       end     __start
