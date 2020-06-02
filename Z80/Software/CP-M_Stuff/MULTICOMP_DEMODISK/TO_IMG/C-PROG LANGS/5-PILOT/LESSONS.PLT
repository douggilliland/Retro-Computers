R: FILE: LESSONS.PLT
R: BY COMBINING PILOT AND PASCAL/Z WE CAN CHAIN TO OTHER PROGRAMS.
R: THIS PROGRAM DEMONSTRATES HOW TO CHAIN WITH PASCAL/Z.
R: YOU MUST FOLLOW THE DIRECTIONS GIVEN IN THE PASCAL/Z MANUAL CONCERNING
R: CHAINING AND THE PROGRAM CHAINED TO MUST FOLLOW THE CP/M FILE NAMING
R: CONVENTION.

T:WELCOME
T:
T:WHAT IS YOUR NAME?;
A:$n
t:THANK YOU @$n@.  NOW WE WILL TAKE AN ADVENTURE.

r: first time flag; = 1 means 1st time here; = 0 means not 1st time.
c: #f := 1

r: clear screen string for Zenith terminal.
c:$c[1]:=chr(27); $c[2]:='E'; setlength($c,2)

r: string to home up the cursor but not clear the screen.
c:$h[1]:=chr(27); $h[2]:='H'; setlength($h,2)

T:
L:LMENU
