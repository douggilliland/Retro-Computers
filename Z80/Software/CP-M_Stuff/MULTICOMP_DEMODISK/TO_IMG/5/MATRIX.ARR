% File  MATRIX.ARR  (c)		04/26/81	The Soft Warehouse %

PROPERTY RBP, ., 125 $
PROPERTY LBP, ., 125 $

FUNCTION INPROD (LEX1, LEX2,
  % Local: %  EX1),
  EX1: 0,
  LOOP
    WHEN ATOM (LEX1)  OR  ATOM (LEX2),
      EX1  EXIT,
    EX1:  EX1 + POP(LEX1).POP(LEX2),
  ENDLOOP,
ENDFUN $

FUNCTION MAPDOTRT (LEX1),
  % Fluid var from OUTPROD or ".": EX1 %
  WHEN ATOM (LEX1), LEX1  EXIT,
  ADJOIN (EX1.POP(LEX1), MAPDOTRT(LEX1)),
ENDFUN $

FUNCTION OUTPROD (LEX1, LEX2,
  % Local: %  EX1),
  WHEN ATOM (LEX1),  LEX1  EXIT,
  EX1: POP(LEX1),
  ADJOIN (ADJOIN ('[, MAPDOTRT(LEX2)), OUTPROD(LEX1, LEX2)),
ENDFUN $

FUNCTION MAPDOTLFT (LEX1),
  % Fluid var from ".":  EX2 %
  WHEN ATOM (LEX1),  FALSE EXIT,
  ADJOIN (POP(LEX1) . EX2,  MAPDOTLFT(LEX1)),
ENDFUN $

FUNCTION . (EX1, EX2),
  WHEN ROW (EX1),
    WHEN COL (EX2),
      INPROD (REST(EX1), REST(EX2))  EXIT,
    WHEN ROW (EX2),
      ADJOIN ('[, MAPDOTRT(REST(EX2)))  EXIT,
    EX1 * EX2  EXIT,
  WHEN COL(EX1),
    WHEN ROW (EX2),
      ADJOIN ('{, OUTPROD (REST(EX1), REST(EX2)))  EXIT,
    WHEN COL (EX2),
      ADJOIN ('{, MAPDOTLFT(REST(EX1)))  EXIT,
    EX1 * EX2  EXIT,
  EX1 * EX2,
ENDFUN $


%******************* Optional Transpose Package ******************%


PROPERTY LBP, `, 170 $

FUNCTION ` (EX1),
  WHEN ATOM (EX1), EX1  EXIT,
  WHEN APPLY (GET('`, FIRST(EX1)), ARGEX(EX1))  EXIT,
  EX1,
ENDFUN $

PROPERTY `, {, FUNCTION (LEX1),
  ADJOIN ('[, MAPFUN('`, LEX1)),
ENDFUN $

PROPERTY `, [, FUNCTION (LEX1),
  ADJOIN ('{, MAPFUN('`, LEX1)),
ENDFUN $

PROPERTY LBP, TR, 170 $

MOVD ('`, 'TR) $

%***************** Optional Matrix Division Package **************%


FUNCTION APPEND (LEX1, LEX2),
  WHEN ATOM (LEX1), LEX2  EXIT,
  ADJOIN (POP(LEX1), APPEND(LEX1,LEX2)),
ENDFUN $

FUNCTION IDMAT (EX1,
  % Local: %  EX2),
  EX2: LIST (1),
  LOOP
    WHEN ZERO (EX1:EX1-1) EXIT,
    PUSH (0, EX2),
  ENDLOOP,
  EX1: FALSE,
  LOOP
    PUSH (ADJOIN ('[, EX2), EX1),
    WHEN ATOM (EX2:REST(EX2)),  ADJOIN ('{, EX1)  EXIT,
  ENDLOOP,
ENDFUN $

PROPERTY RBP, \, 125 $
PROPERTY LBP, \, 125 $

#ARB: 0 $

FUNCTION STARTBACK (LEX1,
  % Local: % EX1),
  % Global:  #ARB %
  WHEN ATOM (LEX1), FALSE EXIT,
  WHEN ZERO (EX1:POP(LEX1)),
    ADJOIN (ARB(#ARB:#ARB+1), STARTBACK(LEX1))  EXIT,
  WHEN ARRAY (EX1),
    ADJOIN (ADJOIN (FIRST(EX1),
      STARTBACK (REST(EX1))), STARTBACK(LEX1))  EXIT,
  ADJOIN (? (LIST ('/, EX1, 0)), STARTBACK(LEX1)),
ENDFUN $

FUNCTION BACKSUB(LEX3),
  % Fluid vars from \: LEX1 & LEX2 %
  LOOP
    WHEN ATOM (LEX1),
      ADJOIN ('{, LEX3)  EXIT,
    PUSH (POP(LEX2) - POP(LEX1).ADJOIN('{,LEX3),  LEX3),
  ENDLOOP,
ENDFUN $

FUNCTION COLMAT(EX1),
  WHEN FIRST(EX1) EQ '{,
    LOOP
      WHEN ATOM (EX1:REST(EX1))  EXIT,
      WHEN NOT ROW(FIRST(EX1)), FALSE EXIT
    ENDLOOP  EXIT
ENDFUN $

FUNCTION \ (EX1, EX2,
  % Local: %  EX3, EX4, LEX1, LEX2, LEX3, LEX4),
  WHEN (COLMAT(EX1) OR ROW(EX1) AND COLMAT(EX1: EX1.IDMAT(LENGTH(REST(EX1)))))
    AND (COL(EX2) OR ROW(EX2) AND COL(EX2: EX2.IDMAT(LENGTH(REST(EX2))))),
      EX1: REST(EX1),  EX2: REST(EX2),
      LOOP  % make EX1 unit upper triangular, then back substitute %
        LOOP  % make implied unit diagonal above a column of zeros %
          WHEN (EX4:REST(FIRST(EX1))) AND NOT ZERO(EX4:FIRST(EX4)),
            EX3: EX4 \ ADJOIN('[, RREST(POP(EX1))),
            EX4: EX4 \ POP(EX2),
            LOOP			% update remainder of EX1: %
              WHEN ATOM(EX1),
                EX1: LEX3,  EX2: APPEND(LEX4,EX2)  EXIT,
              PUSH (ADJOIN ('[, RREST(FIRST(EX1)))
                - SECOND(FIRST(EX1)).EX3,  LEX3),
              PUSH (POP(EX2) - SECOND(POP(EX1)).EX4,  LEX4),
            ENDLOOP EXIT,
          PUSH (ADJOIN ('[, RREST(POP(EX1))), LEX3),
          PUSH (FIRST(EX2), LEX4),
          WHEN ATOM(EX1) EXIT,		% Singular matrix: %
          EX2: REST(EX2),
        ENDLOOP,
        WHEN ATOM(EX1),  % do back substitution: %
          WHEN ATOM(LEX3), BACKSUB(ADJOIN(EX4,STARTBACK(EX2))) EXIT,
          EX3: LEX3,                     % have singular matrix: %
          LOOP
            WHEN ATOM(EX3),  BACKSUB(STARTBACK(EX2))  EXIT,
            WHEN REST(POP(EX3)),  % maybe a nonzero in next col %
              EX2: REST (ADJOIN ('{,LEX3) \ ADJOIN('{,LEX4)),
              BACKSUB(ADJOIN(POP(EX2:REVERSE(EX2)),REVERSE(EX2)))
              EXIT,
          ENDLOOP  EXIT,
        LEX3: LEX4: FALSE,
        PUSH (EX3, LEX1),  PUSH (EX4, LEX2),
      ENDLOOP  EXIT,
  EX2 / EX1,
ENDFUN $


%********* Optional Matrix Power & Inverse Package ****************%


PROPERTY BASE, [, FUNCTION (EX1, LEX1),
  WHEN COLMAT (LEX1: ADJOIN('[,LEX1).IDMAT(LENGTH(LEX1))),
    LEX1 ^ EX1  EXIT
ENDFUN $

PROPERTY BASE, {, FUNCTION (EX1, LEX1,
  % Local: %  EX2),
  WHEN ZERO(EX1), IDMAT (LENGTH(LEX1))  EXIT,
  WHEN COLMAT(EX2:ADJOIN('{,LEX1)) OR COLMAT(EX2.IDMAT(LENGTH(LEX1))),
    WHEN POSITIVE (EX1),
      WHEN EX1 EQ 1,  EX2  EXIT,
      EX2 . EX2^(EX1-1)  EXIT,
    WHEN NEGATIVE (EX1),
      WHEN EX1 EQ -1,  EX2 \ IDMAT (LENGTH(LEX1))  EXIT,
      (EX2 ^ -1)  ^  -EX1  EXIT EXIT,
ENDFUN $

%*****************  Optional Determinant Package  *****************%

FUNCTION DET (EX1,
  % Local: %  EX2, EX3, EX4, EX5, LEX3),
  WHEN COLMAT(EX1)
      OR ROW(EX1) AND COLMAT(EX1:EX1.IDMAT(LENGTH(REST(EX1)))),
    EX1: REST(EX1),  EX2: EX3: 1,
    LOOP
      LOOP
        WHEN (EX4:REST(FIRST(EX1))) AND NOT ZERO(EX4:FIRST(EX4)),
          EX2: EX2.EX4,
          EX4: EX4 \ ADJOIN('[,RREST(POP(EX1))),
          LOOP
            WHEN ATOM(EX1), EX1: LEX3  EXIT,
            PUSH (ADJOIN('[,RREST(FIRST(EX1)))
              - SECOND(POP(EX1)).EX4, LEX3)
          ENDLOOP EXIT,
        PUSH (ADJOIN('[,RREST(POP(EX1))), LEX3),
        EX5: NOT EX5,
        WHEN ATOM(EX1), EX2: 0  EXIT
      ENDLOOP,
      WHEN ATOM(EX1)
        WHEN (MOD(EX3,4) EQ 3) EQ EX5, EX2 EXIT,
        -EX2 EXIT,
      EX3: EX3+1, LEX3: FALSE
    ENDLOOP EXIT
ENDFUN $

RDS () $
