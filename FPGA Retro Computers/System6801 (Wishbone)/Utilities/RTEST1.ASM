       nam     rtest1
       idnt    Relocation TEST file #1 (Conversion Module)

*
*      This module contains the conversion routine
*

*
*      External References
*
       xref    __start,reltst

*
*      External Definitions
*
       xdef    cnvt
       spc     1
       org     $80
       rmb     $80
*
*      The temporary buffer
*
b$sect comm    1
otbuff rmb     40      . the output buffer
srcptr rmb     2       . SOURCE pointer
dstptr rmb     2       . DESTINATION pointer
       spc     1
*
*      The routine to do the job
*
       section 4
cnvt   stx     srcptr  . save the pointer
       ldx     #dstptr . set the destination pointer
       spc     1
*
*      the conversion loop
*
cvtlp0 ldx     srcptr  . get the source pointer
       ldaa    0,x     . get a byte
       inx             . update the pointer
       stx     srcptr
       spc     1
*
*      convert the data
*
       cmpa    #'A     . see if it needs conversion
       blo     no$cvt
       cmpa    #'Z
       bhi     no$cvt

       adda    #$20    . convert it

no$cvt equ     *
       spc     1
*
*      store the byte
*
       ldx     dstptr  . get the destination pointer
       stab    0,x     . save the data
       inx             . update the pointer
       stx     dstptr
       tsta            . are we finished?
       bne     cvtlp0  . no, loop back

       rts             . yes, return to caller
       bra     reltst
       spc     1
lbl1   fdb     __start
*
*      End of conversion module
*
       end
