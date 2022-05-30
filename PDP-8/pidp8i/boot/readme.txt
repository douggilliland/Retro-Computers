On startup, scanswitch passes the script number to run on to pidp8,
based on the IF switch settings.

Standard boot scripts:

IF switches   filename   description
----------------------------------------------------------------------
   000        0.script : OS/8 on 32K PDP-8 with RK05 disk cartridge
   001        1.script : RIM Loader installed at 7756
   010        2.script : TSS/8
   011        3.script : OS/8 on DECtape. This uses SLOW td0, not dt0
   100        4.script : spacewar! with vc8e output on localhost:2222
   101        5.script : (empty)
   110        6.script : ETOS Multi-user on OS/8 boot disk
   111        7.script : OS/8. Same as 0.script.
----------------------------------------------------------------------
Default initial startup script - when no IF switches are set is 0.script
