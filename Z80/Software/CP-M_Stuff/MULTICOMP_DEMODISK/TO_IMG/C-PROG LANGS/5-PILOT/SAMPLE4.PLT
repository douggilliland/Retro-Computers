R: FILE: SAMPLE4.PLT
R: DEMONSTRATES SENDING PRINTED OUTPUT TO EITHER THE CONSOLE DEVICE
R: OR THE LIST DEVICE.
R: NOTE: THE TEXT FILES "output", AND "input" HAVE BEEN DECLARED IN
R: THE FILE PILOT/P.HDR.
R:
	 %: print ( var output:text; message: strng )
	 c: writeln( output, message )
	 E:
R:------------------------------------
R: We combine Pascal and PILOT to send
R: output to the print device.
	 C: $a := 'the quick brown fox jumped over the lazy black dog.'
*again
	 T:
	 T: List output to C(onsole or P(rinter <Q=QUIT>? ;
	 A:
	 M:Q!q
	JY:*END
	 M:C!c
	 C: if flag then rewrite('CON:',output) else rewrite('LST:',output)
	 U: print(output,$a)
	 J: *again
*END
	E:
