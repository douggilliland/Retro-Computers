%	floating point Taylor series function		%
%	you must enter the expression and the		%
%	accuracy desired in number of digits		%
%							%
%	NOTE: the float.mu package is required		%
%	The function must be one for which		%
%	muMath knows the value at point A		%
%							%
FUNCTION FLTTAY (EXPR,X,A,ACC,VAL,NUM,I,D,DONE,RES1,RES,
		POINT,NUMNUM,DENNUM,DOT)
  POINT:ACC, DOT:'., DONE:FALSE,
  ACC: 1/RADIX()^ACC		% accuracy of result %
  NUMNUM:DENNUM:30,
  RES:0, D:I:1, RES1: -(RADIX()^10),
  PRINT("I'M THINKING  ")
  LOOP
    PRINT(DOT)
    RES: RES + EVSUB(EXPR,X,A) * D
%							%
%	now, test every so often, to see if		%
%	the series is converging or has met		%
%	the convergence criterion			%
%							%
    BLOCK
      WHEN I<3 EXIT
      WHEN INTEGER(I/4), RES1:RES, EXIT
      WHEN INTEGER(I/2),
        WHEN ABS(RES-RES1) < ACC, NEWLINE(),
        PRINT("ACCURACY REQUIRED "), PRTMATH(I),
        PRINT("ITERATIONS"), NEWLINE(),
        PRINT("ANSWER IS "), PRTMATH(RES),
        DONE:TRUE, EXIT,
      PRINT("ITERATION #"), PRINT(I)
      PRINT(", CURRENT VALUE IS "),
      PRTMATH(RES), NEWLINE(), EXIT
    ENDBLOCK
    WHEN DONE, NEWLINE(), PRTMATH(RES), "" EXIT
%							%
%	now, if after 500 terms, we haven't		%
%	gotten there yet, we probably never will	%
%							%
    WHEN I>500,
      NEWLINE(),
      PRINT("DID NOT CONVERGE"), NEWLINE(),
      PRINT("VALUE IS "), PRTMATH(RES), NEWLINE(),
      PRINT("NUMBER OF ITERATIONS "), I EXIT,
      EXPR: DIF(EXPR,X)
      I: I+1
      D: D * EVSUB((X-A)/(I-1),X,VAL)
    ENDLOOP
ENDFUN $	% END_FLTTAY %
%							%
%		Calling Sequence			%
%	FLTTAY(fun, var, exp pt, #_of_digits, eval pt)	%
% where fun = the function to be evaluated		%
%	accuracy = the number of digits desired		%
%	variable = the variable of the function		%
%	expansion point = the point of expansion	%
%	evaluation point = the point of evaluation	%
%		of the Taylor series			%
% for example:  FLTTAY(SIN(X),X,0,10,5716/100)		%
%	(this particular example also requires		%
%	the trigonometric packages to be loaded)	%
%							%
STOP() $
RDS () $
curacy desired in number of digits		