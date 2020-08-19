*   seterrno.s
*
*   Copyright 1992 by Sierra Systems.  All rights reserved.
*
*   void set_errno(value in d0)
*
*   set_errno() sets __errno to the value in register d0

    .opt    proc=68020
    .text
    .align  2

    .globl  set_errno

    .extern __errno

set_errno:

 .ifdef INT_16
 .ifdef A5_16
    move.w  d0,(__errno.w,a5)
 .else
 .ifdef A5_32
    move.w  d0,(__errno.l,a5)
 .else
    move.w  d0,__errno
 .endif
 .endif

 .else
 .ifdef A5_16
    move.l  d0,(__errno.w,a5)
 .else
 .ifdef A5_32
    move.l  d0,(__errno.l,a5)
 .else
    move.l  d0,__errno
 .endif
 .endif
 .endif

    rts	
