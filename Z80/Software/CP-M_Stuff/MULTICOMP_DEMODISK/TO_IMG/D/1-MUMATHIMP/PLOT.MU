%							%
%	function plotter for muMath (trs-80)		%
%							%
FUNCTION BOX (XHIGH, A)
  CLS(),
  A:0,
  BLOCK
    WHEN A>XHIGH, EXIT
    LOOP
      SET(A,0), SET(A,47)
      A: A+1,
      WHEN A>XHIGH, EXIT
    ENDLOOP
  ENDBLOCK
  A:0,
  BLOCK
    WHEN A>47, TRUE EXIT,
    LOOP
      WHEN A>47, TRUE EXIT,
      SET(0,A), SET(XHIGH,A)
      A:A+1,
    ENDLOOP
  ENDBLOCK
ENDFUN $
%							%
DOT: '. $
%							%
%	this portion is the main program		%
%	this function may run out of vector		%
%	space on complex functions, if this		%
%	happens, use plot#1() below			%
%	if you don't want to use auto scaling		%
%	for the Y axis, then use plot#2() below		%
%							%
FUNCTION PLOT(EXPR, X, LOW, HIGH, YLIST, ZINT,
	INCX, INCY, A, B, Y, SLOPEY, INTERY, Q)
  WHEN (LOW=HIGH) OR
	(NUMBER(HIGH)=FALSE) OR (NUMBER(LOW)=FALSE),
		PRINT("ERROR IN LIMITS!") EXIT,
  CLS(), PRINT("THINKING"), YLIST: LIST(),
  INCX: (HIGH-LOW)/100, ZINT: 0
  %						%
  %	now find scaling factor for y-axis	%
  %						%
  UPY: EVSUB(EXPR,X,HIGH), LOWY: EVSUB(EXPR,X,LOW),
  WHEN (NUMBER(UPY)=FALSE) OR (NUMBER(LOWY)=FALSE),
  	PRINT("ONLY UNIVARIATE FUNCTIONS!") EXIT,
  A: LOW,
  LOOP
    BLOCK
      WHEN INTEGER(ZINT/10), PRTMATH(ZINT) EXIT,
      PRINT(DOT),
    ENDBLOCK
    ZINT: ZINT+1
    B: EVSUB(EXPR,X,A),
    YLIST: ADJOIN(B,YLIST)	% save generated points %
    UPY: MAX(UPY,B),
    LOWY: MIN(LOWY,B),
    A: A+INCX
    WHEN A>HIGH EXIT,
  ENDLOOP
  A: LOW, Q: 1, YLIST: REVERSE(YLIST),
  WHEN LOWY=UPY, PRINT("CHOOSE DIFFERENT X-LIMITS"), EXIT
  SLOPE: 45/(UPY-LOWY)
  INTER: 1-SLOPE*LOWY
%							%
%	ok, now that we have the scaling		%
%	factors, let's plot the function		%
%							%
  BOX(100),	% set up screen %
  LOOP
    WHEN Q>100, EXIT
    Y: 47 - INT(FIRST(YLIST)*SLOPE + INTER)
    YLIST:REST(YLIST)
    SET(Q,Y)
    Q: Q+1,
  ENDLOOP
%							%
%	now keep looping until any key is pressed	%
%	(see definition by PUTD below)  (another	%
%	way to do the loop would be:			%
%		LOOP					%
%		ENDLOOP					%
%	in which case the only way out is to use	%
%	the <CLEAR> key to exit)			%
%							%
  W#SCAN (),
ENDFUN $		%  end_plot  %
%							%
%	PLOT#1() is just like PLOT() except		%
%	that it doesn't store all the numbers, so	%
%	you won't have as much tendency to run out	%
%	of vector space due to storage			%
%							%
FUNCTION PLOT#1(EXPR,X,LOW,HIGH,ZINT,INCX,INCY,A,B,Y,
	SLOPEY,INTERY,Q)
  WHEN (LOW=HIGH) OR
  	(NUMBER(HIGH)=FALSE) OR (NUMBER(LOW)=FALSE),
  		PRINT("ERROR IN LIMITS!") EXIT,
  CLS(), PRINT("THINKING"),
  INCX: (HIGH-LOW)/126, ZINT:0
  UPY: EVSUB(EXPR,X,HIGH), LOWY: EVSUB(EXPR,X,LOW),
  WHEN (NUMBER(UPY)=FALSE) OR (NUMBER(LOWY)=FALSE),
  	PRINT("ONLY UNIVARIATE FUNCTIONS!") EXIT,
  A: LOW,
  LOOP
    BLOCK
      WHEN INTEGER(ZINT/10), PRTMATH(ZINT) EXIT,
      PRINT(DOT),
    ENDBLOCK
    ZINT: ZINT+1
    B: EVSUB(EXPR,X,A),
    UPY: MAX(UPY,B),
    LOWY: MIN(LOWY,B),
    A: A+INCX
    WHEN A>HIGH EXIT,
  ENDLOOP
  A: LOW, Q:1,
  WHEN LOWY=UPY, PRINT("CHOOSE DIFFERENT X-LIMITS!"), EXIT
  SLOPE: 45/(UPY-LOWY)
  INTER: 1-SLOPE*LOWY
  BOX(126),
  LOOP
    WHEN Q>126, EXIT
    Y: 47 - INT(EVSUB(EXPR,X,A)*SLOPE + INTER)
    SET(Q,Y)
    Q: Q + 1, A: A+INCX
  ENDLOOP
  W#SCAN(),
ENDFUN $		% end_plot#1 %
%							%
%	PLOT#2 is different in that you must 		%
%	enter the limits for x and y, rather		%
%	than have auto y-scaling.  The calling		%
%	sequence is:					%
%	PLOT#2(expr, X, X_low, X_high, Y_low, Y_high)	%
%							%
FUNCTION PLOT#2(EXPR,X,LOW,HIGH,LOWY,UPY,INCX,A,B,Y,
	SLOPEY,INTERY,Q)
  WHEN (LOW=HIGH) OR (LOWY=UPY) OR
  	(NUMBER(HIGH)=FALSE) OR (NUMBER(LOW)=FALSE) OR
  	(NUMBER(LOWY)=FALSE) OR (NUMBER(UPY)=FALSE),
  		PRINT("ERROR IN LIMITS!") EXIT,
  INCX: (HIGH-LOW)/126,
  A:LOW, Q:1,
  WHEN LOWY=UPY, PRINT("CHOOSE DIFFERENT X-LIMITS"), EXIT
  SLOPE: 45/(UPY-LOWY)
  INTER: 1-SLOPE*LOWY
  BOX(126),
  LOOP
    WHEN Q>126, EXIT
    Y: 47 - INT(EVSUB(EXPR,X,A)*SLOPE + INTER)
    SET(Q,Y)
    Q:Q+1, A:A+INCX
  ENDLOOP
  W#SCAN(),
ENDFUN $		% end_plot#2 %
%							%
%	define a function to find the maximum		%
%	of two arguments				%
%							%
FUNCTION MAX(X,Y)
  WHEN MIN(X,Y)=Y, X EXIT
  Y
ENDFUN $		% end_max %
%							%
%	define a function to find the integer		%
%	part of a rational number			%
%							%
FUNCTION INT(X)
  QUOTIENT(NUM(X), DEN(X))
ENDFUN $		% end_int %
%							%
%	define the trs-80 rom call at 0049h to be	%
%	W#SCAN(); it waits until a key is pressed	%
%							%
PUTD ('W#SCAN, 73) $
%							%
%	calling sequence:				%
%		PLOT(fun, var, low, high)		%
%	where						%
%		fun = function to be plotted		%
%		var = variable in the function		%
%		low & high are limits of the function	%
%							%
STOP() $
RDS () $
W,
  LOOP