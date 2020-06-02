R:FILE: TUTORIAL.PLT
R: READS AN EXTERNAL DATA FILE AND DISPLAYS THE TEXT ON THE CONSOLE
R: A SCREENFUL AT A TIME.

%: pause
t:@$h@
r:home down 21 lines.
c:for #i:=1 to 21 do writeln
t:@$s:27@Press any key to continue;
u:keyin(ch)
e:

%: do_process
 t:@$c@;
 c:done := FALSE
 c:while not done do begin
 u:readln(f2,ans)
 x:ans[1]='.'
tn:@ans@
jn:*break
 x:ans = '.end'
cy:done := TRUE
jy:*break
 x:ans = '.pause'
uy:pause
jy:*break
 x:ans = '.break'
ty:@$c@
*break
c:end{while}
E:

*BEGIN
r: a space character
c:$s := ' '

r: STRING TO CLEAR THE SCREEN AND HOME UP THE CURSOR.
c:$c[1] := chr(27); $c[2] := 'E'; setlength($c,2)

r: STRING TO HOME UP THE CURSOR BUT NOT CLEAR THE SCREEN.
c:$h[1] := chr(27); $h[2] := 'H'; setlength($h,2)

r: THE INPUT DATA FILE.
c:$n := 'CPM.HLP'

r:ATTEMPT TO OPEN FILE $n FOR READ.
u:reset($n,f2)
x:eof(f2)
ty:CP/M HELP FILE NOT FOUND.
jy:*END

*MENU
t:@$c@
t:		A - General Information on CP/M
t:		B - CP/M File References
t:		C - CP/M Line Editing and Output Control
t:		D - CP/M Built-In Commands
t:		E - CP/M Transient Commands
t:		F - Physical Device Assignments for ARIES-1
t:		G - CP/M STAT Command
t:		H - CP/M PIP Command
t:		I - CP/M ED Command
t:		J - CP/M ASM Command
t:		K - CP/M LOAD Command
t:		L - The UNLOAD Command
t:		M - CP/M DDT Command
t:		N - The ZDT Command
t:		O - CP/M SYSGEN Command
t:		P - CP/M SUBMIT and XSUB Commands
t:		Q - CP/M BIOS -- Basic I/O Operations
t:		R - CP/M BDOS -- Basic Disk Operations
t:		S - CP/M File Types
t:		T - CP/M BIOS Jump Vector
t:@$s:10@Which would you like to review?<escape to end>;
 u:repeat keyin(ch)
 x:  ord(ch)=27
jy:  *END
 c:  ch:=toupper(ch)
 u:until ch in ['A'..'T']
 c:#F := ord(ch)

 r:REWIND THE DATA FILE.
 u:reset($n,f2)

 c:while not eof(f2) do begin
 u:   readln(f2,ans)
 x:   isdigit(ans[1])
jn:   *around
 x:   ivalue(ans,1)=#F
uy:   do_process
jy:   *quitloop
*around
 c:end{while}
*quitloop
 j:*MENU
*END
 E:
