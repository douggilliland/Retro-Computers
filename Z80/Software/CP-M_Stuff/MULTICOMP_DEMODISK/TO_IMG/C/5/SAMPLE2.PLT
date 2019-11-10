R: FILE: SAMPLE2.PLT
R: PROGRAM USING SUBROUTINES.  AS IN ALL PASCAL PROGRAMS, PROCEDURES
R: MUST BE DECLARED FIRST.

	 %:TEST($x:strng; y:charset)
	 T:Name as many @$x@ as you can.
	 A:
	 C:#i:=1
*LOOP
	 X:ans[#i] in y
	CY:#s:=#s+1
	TN:Sorry, @ans[#i]@ is wrong.
	CY:y:=y-[ans[#i]]
	 C:#i:=#i+1
	 X:#i<length(ans)
	JY:*LOOP
	 E:

	 %:getchoice(var #c:integer)
	 r:accepts a number and checks its value
	 c:REPEAT writeln
	 t: What is your choice(1 to 10)?;
	 a: #c
	 x: #c in [1..10]
	tn: @#c:4@@chr(7)@ is out of range
	 c:UNTIL flag
	 e:

*BEGIN
	 U:test('stops',['d','t','p','b','k','g'])
	 U:test('bilabials',['p','b','m'])
	 U:test('labio-dentals',['f','v'])
	 U:test('apico-alveolars',['t','d','s','z','l','r','n'])
	 U:getchoice(#c)
	 T:Your score was @#s:1@ out of 18.
	 E:
