       nam     rtest0
       ttl     Relocation TEST file #0 (NON-Relocating)
*
*      This module contains routines to move some data
*      from one buffer to another, convert it to LOWER case
*      and then return.
*
       spc     1
*
*      The DATA to be moved and converted
*
       org     $1000
indata fcc     /NOW IS THE TIME FOR ALL GOOD MEN.../
       fcb     0
       spc     1
*
*      The temporary buffer
*
       org     $00
otbuff rmb     40      . the output buffer
srcptr rmb     2       . SOURCE pointer
dstptr rmb     2       . DESTINATION pointer
       rmb     20      . some stack space
stack  equ     *-1
       spc     1
*
*      The main calling routine
*
       org     $e000
start  lds     #stack  . set the stack
       ldx     #indata . point at the data
       jsr     cnvt    . call the conversion routine
forevr bra     forevr  . hang when done
       spc     1
*
*      The routine to do the job
*
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
       staa    0,x     . save the data
       inx             . update the pointer
       stx     dstptr
       tsta            . are we finished?
       bne     cvtlp0  . no, loop back

       rts             . yes, return to caller
       spc     1
*
*      End of module
*
       end     start
