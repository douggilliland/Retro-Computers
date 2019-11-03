
  (PROGN (LISPXPRIN1 (QUOTE "TIC TAC TOE")
                     T)
         (LISPXPRIN1 (QUOTE " IN LISP 1-28-73")
                     T)
         (LISPXTERPRI T))
(DEFINEQ

(TTT
  [LAMBDA (LS MV)
    (COND
      ((XWIN LS)
        (PRINT (QUOTE (X WINS)))
        T)
      ((OWIN LS)
        (PRINT (QUOTE (O WINS)))
        T)
      ((TIE LS)
        (PRINT (QUOTE (TIE)))
        T)
      (T (SETQ N (MOVE LS MV))
         (SETQ BOARD (CHANGE LS MV N))
         (COND
           ((EQ MV (QUOTE O))
             (PM BOARD)))
         (TTT BOARD (REV MV)
              N])

(XWIN
  [LAMBDA (LS)
    (COND
      ((LESSP (COUNT (CX LS))
              3)
        NIL)
      ((EQ15 (CX LS])

(OWIN
  [LAMBDA (LS)
    (COND
      ((LESSP (COUNT (CO LS))
              3)
        NIL)
      ((EQ15 (CO LS])

(TIE
  [LAMBDA (LS)
    (COND
      ((NULL (CAV LS))
        T])

(MATRIX
  [LAMBDA (LS)
    (CADDDR LS])

(CX
  [LAMBDA (LS)
    (CAR LS])

(CO
  [LAMBDA (LS)
    (CADR LS])

(CAV
  [LAMBDA (LS)
    (CADDR LS])

(EQ15
  [LAMBDA (LS)
    (COND
      ((LESSP (COUNT LS)
              3)
        NIL)
      ((EQL15 LS)
        T)
      ((EQ15 (CDR LS])

(EQL15
  [LAMBDA (LS)
    (COND
      ((LESSP (COUNT LS)
              3)
        NIL)
      ((EQUAL15 (CAR LS)
                (SMPRS (CDR LS])

(EQUAL15
  [LAMBDA (I Y)
    (COND
      ((NULL Y)
        NIL)
      ((EQ 15 (IPLUS I (CAR Y)))
        T)
      ((EQUAL15 I (CDR Y])

(SMPRS
  [LAMBDA (X)
    (COND
      ((EQ (COUNT X)
           2)
        (SMPRS1 (CAR X)
                (CDR X)))
      ((APPEND (SMPRS1 (CAR X)
                       (CDR X))
               (SMPRS (CDR X])

(SMPRS1
  [LAMBDA (J Y)
    (COND
      [(NULL (CDR Y))
        (LIST (IPLUS J (CAR Y]
      ((CONS (IPLUS J (CAR Y))
             (SMPRS1 J (CDR Y])

(PM
  [LAMBDA (LS)
    (COND
      (T (PRINT (QUOTE (- 1 2 3)))
         [PRINT (CONS (QUOTE A)
                      (LA (MATRIX LS]
         [PRINT (CONS (QUOTE B)
                      (LB (MATRIX LS]
         [PRINT (CONS (QUOTE C)
                      (LC (MATRIX LS]
         (TERPRI NIL)
         (TERPRI NIL)
         (TERPRI NIL)
         (TERPRI NIL)
         T])

(LA
  [LAMBDA (LS)
    (LIST (CAR LS)
          (CADR LS)
          (CADDR LS])

(LB
  [LAMBDA (LS)
    (LA (CDDDR LS])

(LC
  [LAMBDA (LS)
    (LA (CDDDR (CDDDR LS])

(MTH
  [LAMBDA (X J)
    (CAR (NTH X J])

(REV
  [LAMBDA (MV)
    (COND
      ((EQ MV (QUOTE X))
        (QUOTE O))
      ((QUOTE X])

(MOVE
  [LAMBDA (LS MV)
    (COND
      ((EQ MV (QUOTE X))
        (GETMV LS))
      ((LOOK1 (CAV LS)
              (CO LS)))
      ((LOOK1 (CAV LS)
              (CX LS)))
      ((MTH (CAV LS)
            (RAND 1 (COUNT (CAV LS])

(CHANGE
  [LAMBDA (LS MV N)
    (LIST (COND
            ((EQ MV (QUOTE X))
              (INSERT N (CX LS)))
            ((CX LS)))
          (COND
            ((EQ MV (QUOTE O))
              (INSERT N (CO LS)))
            ((CO LS)))
          (REMOVE N (CAV LS))
          (MAKE (MATRIX LS)
                (TRANS N)
                MV])

(INSERT
  [LAMBDA (J X)
    (SORT (CONS J X])

(DELN
  [LAMBDA (X J)
    (COND
      ((EQ J 1)
        (CDR X))
      ((CONS (CAR X)
             (DELN (CDR X)
                   (SUB1 J])

(MAKE
  [LAMBDA (LS N ATOM)
    (COND
      ((EQ N 1)
        (CONS ATOM (CDR LS)))
      ((CONS (CAR LS)
             (MAKE (CDR LS)
                   (SUB1 N)
                   ATOM])

(GETMV
  [LAMBDA (LS)
    (COND
      ((SETQ N (READ))
        (COND
          ((MEMB (DECODE N)
                 (CAV LS))
            (DECODE N))
          ((PRINT (QUOTE (THAT SQUARE IS ALREADY FILLED)))
            (GETMV LS])

(DECODE
  [LAMBDA (N)
    (COND
      ((SETQ N1 (CAR N))
        (SETQ N2 (CADR N))
        (COND
          ((EQ N1 (QUOTE A))
            (COND
              ((EQ N2 1)
                6)
              ((EQ N2 2)
                1)
              ((EQ N2 3)
                8)))
          ((EQ N1 (QUOTE B))
            (COND
              ((EQ N2 1)
                7)
              ((EQ N2 2)
                5)
              ((EQ N2 3)
                3)))
          ((EQ N1 (QUOTE C))
            (COND
              ((EQ N2 1)
                2)
              ((EQ N2 2)
                9)
              ((EQ N2 3)
                4])

(TRANS
  [LAMBDA (N)
    (COND
      ((EQ N 1)
        2)
      ((EQ N 2)
        7)
      ((EQ N 3)
        6)
      ((EQ N 4)
        9)
      ((EQ N 5)
        5)
      ((EQ N 6)
        1)
      ((EQ N 7)
        4)
      ((EQ N 8)
        3)
      ((EQ N 9)
        8])

(TX
  [LAMBDA (LS)
    (TTT (QUOTE (NIL NIL
                     (1 2 3 4 5 6 7 8 9)

          (* * * * * * * * *)


                     ))
         (QUOTE X])

(TO
  [LAMBDA (LS)
    (TTT (QUOTE (NIL NIL
                     (1 2 3 4 5 6 7 8 9)

          (* * * * * * * * *)


                     ))
         (QUOTE O])

(LOOK1
  [LAMBDA (X Y)
    (COND
      ((NULL X)
        NIL)
      ((EQ15 (CONS (CAR X)
                   Y))
        (CAR X))
      ((LOOK1 (CDR X)
              Y])

(INST
  [LAMBDA (LS)
    (PROGN (PRIN1 

"     THIS IS AN EXTREMELY INEFFICIENT PROGRAM FOR PLAYING TIC TAC TOE.
HOWEVER, THE INEFFICIENCY IS JUSTIFIED BY THE FACT THAT IT PLAYS
VERY POORLY, ALLOWING YOU TO BEAT IT OFTEN.
     TO HAVE THE COMPUTER MOVE FIRST, TYPE TO).  THE BOARD WILL THEN
BE PRINTED WITH AN O SHOWING THE COMPUTERS FIRST MOVE.  TO ENTER YOUR
MOVE, USE ALGEBRAIC NOTATION ENCLOSED IN PARENTHESES.  THAT IS,
TYPE (B 2) TO PLAY IN THE MIDDLE, (A 1) FOR THE UPPER LEFT CORNER, ETC.
TO MAKE THE FIRST MOVE TYPE TX).  AFTER THE CARRIAGE RETURN, ENTER YOUR
MOVE.")
           (TERPRI NIL)
           T])
)
  (LISPXPRINT (QUOTE TCTCTOFNS)
              T)
  (RPAQQ TCTCTOFNS
         (TTT XWIN OWIN TIE MATRIX CX CO CAV EQ15 EQL15 EQUAL15 SMPRS 
              SMPRS1 PM LA LB LC MTH REV MOVE CHANGE INSERT DELN MAKE 
              GETMV DECODE TRANS TX TO LOOK1 INST))
STOP
