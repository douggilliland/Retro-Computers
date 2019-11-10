% File EQN.ALG	(c)	     04/21/81	    The Soft Warehouse %


FUNCTION MAPFUN (LOP1, LEX1),
  WHEN ATOM(LEX1), FALSE  EXIT,
  ADJOIN (LOP1(POP(LEX1)), MAPFUN(LOP1,LEX1)),
ENDFUN $

FUNCTION SIMPU (LOP1, EX1),
  WHEN NAME(EX1), LIST(LOP1,EX1)  EXIT,
  WHEN APPLY (GET(LOP1,FIRST(EX1)), ARGEX(EX1))  EXIT,
  WHEN MEMBER (FIRST(EX1), '("==" [ {)),
     ADJOIN (POP(EX1), MAPFUN(LOP1,EX1))  EXIT,
  LIST (LOP1, EX1),
ENDFUN $

PROPERTY RBP, "==", 80 $
PROPERTY LBP, "==", 80 $

PROPERTY +, "==", FUNCTION (EX1, EX2, EX3),
  WHEN FIRST(EX1) = '"==",
    SECOND(EX1) + EX2 "==" THIRD(EX1) + EX3,  EXIT,
  EX1 + EX2 "==" EX1 + EX3,
ENDFUN $

PROPERTY *, "==", FUNCTION (EX1, EX2, EX3),
  WHEN FIRST(EX1) = '"==",
    SECOND(EX1) * EX2 "==" THIRD(EX1) * EX3,  EXIT,
  EX1 * EX2 "==" EX1 * EX3,
ENDFUN $

PROPERTY BASE, "==", FUNCTION (EX1, EX2, EX3),
  WHEN FIRST(EX1)='"==",
    EX2^SECOND(EX1) "==" EX3^THIRD(EX1)  EXIT,
  EX2 ^ EX1 "==" EX3 ^ EX1,
ENDFUN $

PROPERTY EXPON, "==", FUNCTION (EX1, EX2, EX3),
  EX1 ^ EX2 "==" EX1 ^ EX3,
ENDFUN $

PROPERTY LOG, "==", FUNCTION (EX1, EX2, EX3),
  LOG (EX2,EX1) "==" LOG (EX3,EX1),
ENDFUN $

PROPERTY INFIX, =, EQPARSE (SCAN) $

FUNCTION EQPARSE (EX2),
  WHEN EX2 EQ '=,
    LIST ('"==", EX1, PARSE (SCAN(), 80)) EXIT,
  LIST ('=, EX1, PARSE (SCAN, 80)),
ENDFUN $

FUNCTION LN (EX1),
  LOG (EX1, #E),
ENDFUN $

RDS () $
