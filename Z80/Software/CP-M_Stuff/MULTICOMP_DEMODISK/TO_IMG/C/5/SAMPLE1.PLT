R: FILE: SAMPLE1.PLT
R: SIMPLE EXAMPLE OF THE COMMANDS TYPE, ACCEPT, MATCH, AND X:
R: NOTE THAT UPPER AND LOWER CASE MATTERS IN THE MATCH LIST.
R:----------------------------------------------------------
*START
	 C: #t:=#t+1
	 T: What is the verb in "Peter Piper picked pickled peppers."?
	 A:
	 M: picked
	ty: Right!
	ey:
	 X: #t>3
	tn: Wrong! Try again.
	jn: *START
	 T: The verb was "picked"
	 E:
