R:FILE: SAMPLE6.PLT
R: THIS PROGRAM DEMONSTRATES THE USE OF THE WAIT STATEMENT.

*START
	 T:@CHR(27)@E;
	  :                            SAMPLE PROGRAM
	  :
	  :
	  :
	  :              A - LESSON 1
	  :              B - LESSON 2
	  :              C - LESSON 3
	  :              D - QUIT
	  :
	  :              CHOSE:
	 W:5
	 R:IF NO KEY HAS BEEN PRESSED, THE CHARACTER IN ans[1] IS A NULL.
	 X:ORD(ans[1])=0
	TY:@CHR(7)@I CAN'T WAIT ALL DAY
	WY:1
	JY:*start
	 X:ans[1] IN ['A','B','C','D']
	JN:*START
	 M:D
	JY:*END
	 M:A
	JY:*L1
	 M:B
	JY:*L2
	 M:C
	JY:*L3
*L1
	T:NOW WE WILL DO LESSON #1.
	W:2
	J:*START
*L2
	T:NOW WE WILL DO LESSON #2.
	W:2
	J:*START
*L3
	T:NOW WE WILL DO LESSON #3.
	W:2
	J:*START
*END
	T:HOPE YOU HAD FUN.
	E:
