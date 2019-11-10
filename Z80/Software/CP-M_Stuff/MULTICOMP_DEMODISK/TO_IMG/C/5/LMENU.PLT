R: FILE: LMENU.PLT

%:QUIRY( message: strng; goodchars: charset; var c: char )
T:@message@;
C:REPEAT keyin(ch)
C:  c := toupper(ch)
C:  IF c IN goodchars THEN writeln(ch) ELSE write(chr(7))
C:UNTIL c IN goodchars
E:

*BEGIN
	 T:@$c@
	 x: #f=1
	TY:         WELCOME @$n@ TO USAGE OF A COMPUTER.
	TY:
	CY: #f:=0
	TN:
	TN:
*AGAIN
	 T:YOU HAVE THESE OPTIONS:
	 T:      0) END TODAYS SESSION.
	 T:      1) BEGINNING USE OF THE COMPUTER.
	 T:      2) MORE ADVANCED USES OF THE COMPUTER.
	 T:
	 U:QUIRY(' YOUR CHOICE?',['0','1','2'],ch)
	 C: ans[1]:=ch; setlength(ans,1)
	 M:0
	JY:*END
	 M:1
	JY:*LESSON1
	 M:2
	JY:*LESSON2
	 J:*AGAIN

*LESSON1
	 L:LESSON1

*LESSON2
	 L:LESSON2

*END
	 T: THANK YOU FOR COMING @$n@.
	 T: GOODBYE.
	 E:
