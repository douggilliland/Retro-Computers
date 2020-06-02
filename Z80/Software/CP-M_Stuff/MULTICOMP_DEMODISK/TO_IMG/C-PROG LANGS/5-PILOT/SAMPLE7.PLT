R: FILE: SAMPLE7.PLT
R: DEMONSTRATES USE OF RANDOM, RND(), AND RANDOMIZE.
R: REQUIRES REAL NUMBERS. USE THE SUPPLIED FILE "PILOT/PR.HDR"
R: RENAME PILOT/PR.HDR TO PILOT/P.HDR; ONLY USE WHEN REAL NUMBERS
R: ARE REQUIRED.

	c:$s:=' '
	T:PRESS ANY KEY TO START;
	U:RANDOMIZE
	A:@ch@
	t:SEED=@SEED:1@
	c:FOR #i:=1 TO 50 DO BEGIN
	c:#r := RANDOM(SEED)
	t:@#i:4@ @#r:6:3@
	u:END
	r:
	c:WHILE TRUE DO BEGIN
	t:SEED=@SEED:1@
	t:ENTER LOW NUMBER:;
	a:#L
	t:ENTER UPPER LIMIT:;
	a:#H
	c:FOR #i:=1 TO 50 DO BEGIN
	c:#t := RND(#L,#H)
	t:@#i:2@@$s:#t@*@#t:1@
	c:END
	c:END
	E:
