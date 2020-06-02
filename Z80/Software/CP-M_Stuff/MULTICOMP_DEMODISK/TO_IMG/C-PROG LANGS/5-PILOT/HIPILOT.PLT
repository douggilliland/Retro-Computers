R: FILE: HIPILOT.PLT
R: A TYPICAL INTERACTIVE SESSION.
R:
	 T: Hi there, is this your first time on a computer?
	 A:
	 C:ucase(ans)
	 M:YES!SURE!OK!YEAH
	TY: I hope you will enjoy your experience with me.
	  : In the area of education, what are your main interests?
*MORE
	 A:
	 C:ucase(ans)
	 M:TEACH!INSTR!LEARN!MATERIAL
	JY:*TEACHING
	 M:ADMIN!PROGRAM!TEST!GRAD!ANALYS!COURSE!CURR
	JY:*OTHER
	 T:Please tell me more about this.
	JN: *MORE
*TEACHING
	 T: An excellent way of using computers for teaching and learning
	  : is to give children an opportunity to write their own programs.
	  : How does this strike you?
	 A:
	 C:ucase(ans)
	 M:GOOD!EXCEL!FINE!YES!IMPORTANT!OK
	TN: I see you disagree. Will you explain further?
	JY: *YES
	 A:
*YES
	 T: Of course the teacher should write programs too, however,
	  : it isn't always necessary to use "packaged curricula"
	  : for effective use of the computer in learning situations.
	 E:
*OTHER
	 T: Are you interested in the computer's application to teaching?
	 A:
	 C:ucase(ans)
	 M:NO!NEVER
	JN: *TEACHING
	 T: Then perhaps 'PILOT' is not for you.  PILOT's intention is
	  : for it's use by teachers and children for interactive dialogues.
	  : Thank you for your time and interest.
	 E:
