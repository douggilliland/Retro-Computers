 file TRGNEG%.ALG                            GAE - Feb. 1982

Make a new version of file TRGNEG.ALG as follows:
(1)  Begin with the original file TRGNEG.ALG.
(2)  Delete everything from  FOURONPI: 4 / #PI $
          up to (but not including) PROPERTY SIN, *,
          (more than 50 lines).
(3)  Replace the deleted material with this file starting
          below this line:
-------------------------------------------------------------

FUNCTION SIN (EX1,
  % Local: %  EX2),
  WHEN NEGLT (EX1), -SIN(-EX1) EXIT,
  WHEN NUMBER(EX2:EX1/#PI),
    COSPI(HALF - EX2)  EXIT,
  WHEN POSMULT (TRGEXPD, 7),
    #I * (1/(EX2:#E^(#I*EX1)) - EX2) * HALF  EXIT,
  SIMPU ('SIN, EX1),
ENDFUN $

FUNCTION COS (EX1,
  % Local: %  EX2),
  WHEN NEGLT (EX1), COS(-EX1) EXIT,
  WHEN NUMBER(EX2:EX1/#PI),
    COSPI(EX2)  EXIT,
  WHEN POSMULT (TRGEXPD, 7),
    (1/(EX2:#E^(#I*EX1)) + EX2) * HALF  EXIT,
  SIMPU ('COS, EX1),
ENDFUN $


ROOT5: 5^HALF $
SIXRT5: 6*ROOT5 $

COSPION5:  ( 1+ROOT5)/4 $
COS2PION5: (-1+ROOT5)/4 $

COSPION15:  (-1+ROOT5+(30+SIXRT5)^HALF)/8 $
COS2PION15: ( 1+ROOT5+(30-SIXRT5)^HALF)/8 $
COS4PION15: ( 1-ROOT5+(30+SIXRT5)^HALF)/8 $
COS7PION15: (-1-ROOT5+(30-SIXRT5)^HALF)/8 $


FUNCTION COSPI(EX1,
  % local : % EX2),
  WHEN EX1 < 0,  COSPI(-EX1)  EXIT,
  BLOCK
    WHEN EX1 > 2,
      EX1: EX1 - 2*QUOTIENT(NUM(EX1),2*DEN(EX1))  EXIT,
  ENDBLOCK,
  BLOCK
    WHEN EX1 > 1, EX1: 2-EX1  EXIT,
  ENDBLOCK,
  WHEN MULTIPLE(DEN(EX1),2),
    WHEN EX1 > HALF,  -((1+COSPI(2*EX1))*HALF)^HALF  EXIT,
    ((1+COSPI(2*EX1))*HALF)^HALF  EXIT,
  EX1: DIVIDE(NUM(EX1), EX2: DEN(EX1)),
  WHEN MOD(POP(EX1),2) = 1, -COSPI1(EX1,EX2)  EXIT,
  COSPI1(EX1,EX2),
ENDFUN $

FUNCTION COSPI1(EX1,EX2),
  WHEN EX1 EQ 0, 1  EXIT,
  WHEN LESSER (EX2, 2*EX1), -COSPI1(EX2-EX1,EX2)  EXIT,
  WHEN EX2 EQ 3, HALF  EXIT,
  WHEN EX2 EQ 5,
    WHEN EX1 EQ 1, COSPION5  EXIT,
    COS2PION5  EXIT,
  WHEN EX2 EQ 15,
    WHEN EX1 EQ 1, COSPION15  EXIT,
    WHEN EX1 EQ 2, COS2PION15  EXIT,
    WHEN EX1 EQ 4, COS4PION15  EXIT,
    COS7PION15  EXIT,
  LIST('COS,#PI*EX1/EX2),
ENDFUN $


