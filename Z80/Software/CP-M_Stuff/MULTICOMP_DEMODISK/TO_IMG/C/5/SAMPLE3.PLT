R: FILE: SAMPLE3.PLT
R: THIS PROGRAM DEMONSTRATES THE USE OF MENUES, SELECTION, AND A SUBROUTINE.
R:
	%:ERROR
	T:   I'm sorry.  I need the number 1, 2, or
	T:   3. Please type just the single digit.
	E:
*START
	T:  Select one of the following options:
	T:      1>  Review Company Policy on this
	T:          type of Sale
	T:      2>  Review Current Inventory
	T:      3>  Review Customer Status by
	T:          typing its number and pressing RETURN.
	A:
	M: 1! 2! 3
	JY:*ACCEPT1
	UN: ERROR
	J: *START
*ACCEPT1
	M: 1
	JY: *POLICY
	JN: *ACCEPT2
*POLICY
	T:  What kind of Sale is it?
	T:      1>  Equipment
	T:      2>  Software
	T:      3>  Documentation
	A:
	M: 1! 2! 3
	JY:*SALETYPE
	UN:ERROR
	J:*POLICY
*SALETYPE
	M: 1
	TY:  Charge a markup of 25% on equipment.
	M: 2
	TY:  Charge a markup of 15% on software.
	M: 3
	TY:  We do not sell documentation only.
	J:*MOREQUEST
*ACCEPT2
	M: 2
	TY:  Sorry, the current inventory part of this program
	TY:  has not yet been written.
	JN:*ACCEPT3
	J:*MOREQUEST
*ACCEPT3
	T:  Sorry, the customer status part of this program
	T:  has not yet been written.
	J:*MOREQUEST
*MOREQUEST
	T:  Do you need to review other Company Policy,
	T:  Current Inventory, or Customer Status?
	A:
	M:YES!yes!Yes!Y!y
	JY:*START
	E:
