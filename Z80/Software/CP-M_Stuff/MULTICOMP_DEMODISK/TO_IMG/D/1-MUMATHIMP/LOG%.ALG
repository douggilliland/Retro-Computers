 file LOG%.ALG
Make a new version of LOG.ALG as follows:
(1)  Start with the original LOG.ALG.
(2)  Replace FUNCTION LOG (near the beginning of the file)
          with this file below the line:
-----------------------------------------------------------

FUNCTION LOG (EX1, % Optional: % EX2),
  WHEN EMPTY(EX2), LOG (EX1, LOGBAS) EXIT,
  WHEN ZERO(EX1),  ?(LIST('LOG, EX1, EX2))  EXIT,
  WHEN EX2 EQ 1, ?(LIST('LOG, EX1, EX2))  EXIT,
  WHEN PBRCH AND EX1 EQ 1, 0 EXIT,
  WHEN PBRCH AND EX1=EX2, 1 EXIT,
  WHEN NEGMULT(TRGEXPD,7) AND EX2=#E,
    2*#I*ATAN(#I*(1-EX1)/(1+EX1))  EXIT,
  WHEN PBRCH AND ZERO (MOD(EX1,EX2)),
    1 + LOG (QUOTIENT(EX1,EX2), EX2)  EXIT,
  WHEN NOT(EX2 EQ LOGBAS) AND POSMULT(LOGEXPD,2),
    LOG(EX1,LOGBAS) / LOG(EX2,LOGBAS)  EXIT,
  WHEN ATOM(EX1), LIST('LOG, EX1, EX2)  EXIT,
  WHEN APPLY(GET('LOG,FIRST(EX1)), ADJOIN(EX2,ARGEX(EX1)))  EXIT,
  LIST('LOG, EX1, EX2),
ENDFUN $

