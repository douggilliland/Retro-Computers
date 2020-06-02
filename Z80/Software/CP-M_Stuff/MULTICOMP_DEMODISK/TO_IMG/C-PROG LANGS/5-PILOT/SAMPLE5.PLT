R: FILE: SAMPLE5.PLT
R: DEMONSTRATES THE OPENING OF A DATA FILE AND PRINTING THE FILE TO
R: THE CONSOLE DEVICE (IF FOUND).
R: NOTE: THE TEXT FILES "output", AND "input" HAVE BEEN DECLARED IN
R: THE FILE PILOT/P.HDR.
R:
	 T:@CHR(27)@E
	 T:ENTER INPUT FILE NAME:;
	 A:
	 R: RESET OPENS AN EXISTING FILE.
	 U:RESET(ans,INPUT)
	 X:EOF(INPUT)
	TY:FILE NOT FOUND
	JY:*END
	 C:#i := 0
	 T:
	 U:WHILE NOT EOF(INPUT) DO BEGIN
	 U:READLN(INPUT,$t)
	 C:#i := #i + 1
	 T:@#i:3@: @$t@
	 U:END
*END
	 E:
