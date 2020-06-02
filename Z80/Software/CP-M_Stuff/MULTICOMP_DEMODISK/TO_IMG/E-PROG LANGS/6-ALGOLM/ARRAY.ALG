BEGIN
INTEGER A,B,C,D,E,F;
WRITE("INPUT THE UPPER AND LOWER BOUNDS OF A 3 DIMENSIONAL ARRAY");
WRITE("THE FIRST TWO ENTRIES ARE FOR THE 1ST DIMENSION");
WRITE("AND SO ON FOR THE OTHER DIMENSIONS.  THE PROGRAM");
WRITE("EXPECTS SIX ENTRIES: A LOWER AND UPPER BOUND FOR EACH");
WRITE("DIMENSION. SAMPLE DATA AT THIS POINT IS 1,3,5,6,11,13");
READ(A,B,C,D,E,F);
  BEGIN
   INTEGER ARRAY THREE[A:B,C:D,E:F]; INTEGER I,J,K;
    WRITE(TAB 14,"THREE DIMENSION ARRAY"); WRITE(" ");
    WRITE(TAB 8,"ARRAY SUBSCRIPTS",TAB 17,"CONTENTS"); WRITE(" ");
    WRITE(TAB 1,"ROW",TAB 11,"COLUMN",TAB 10,"PAGE"); WRITE(" ");
    WRITE("INPUT VARIOUS INTEGER VALUES TO FILL THE ARRAY");
    FOR I:=A STEP 1 UNTIL B DO
      BEGIN
       FOR J:= C STEP 1 UNTIL D DO
         BEGIN
          K:=E;
          WHILE K<= F DO
            BEGIN
             READ(THREE[I,J,K]); 
             WRITE(I,TAB 8,J,TAB 8,K,TAB 5,THREE[I,J,K]); WRITE(" ");
             K:=K+1;
            END;
          END;
       END; WRITE(" ");

    BEGIN INTEGER X,P;
      WRITE("INPUT A VALUE FOR P, IF P<0 X WILL BE SET TO");
      WRITE("TO THE FIRST ELEMENT IN THE ARRAY, IF P>0 THEN");
      WRITE("X WILL BE SET TO THE LAST ELEMENT OF THE ARRAY");
      WRITE("SAMPLE INPUT 3");
      READ(P);
      X:= IF P<0 THEN THREE[A,C,E] ELSE THREE[B,D,F];
      WRITE("X= ",X," FIRST ELEMENT = ",THREE[A,C,E]," LAST ELEMENT = ",
              THREE[B,D,F]); WRITE(" ");

      IF P<> 1 THEN
        BEGIN
          WRITE(TAB 14,"SECOND PAGE OF ARRAY"); WRITE(" ");
    WRITE(TAB 8,"ARRAY SUBSCRIPTS",TAB 17,"CONTENTS"); WRITE(" ");
      WRITE(TAB 1,"ROW",TAB 11,"COLUMN",TAB 10,"PAGE"); WRITE(" ");
          FOR I:=A STEP 1 UNTIL B DO
            BEGIN 
              FOR J:=C STEP 1 UNTIL D DO
                WRITE(I,TAB 8,J,TAB 8,E+1,TAB 5,THREE[I,J,E+1]);
            END;
        END
      ELSE
        BEGIN
          WRITE(TAB 14,"SECOND ROW OF ARRAY"); WRITE(" ");
       WRITE(TAB 8,"ARRAY SUBSCRIPTS",TAB 17,"CONTENTS"); WRITE("  ");
       WRITE(TAB 1,"ROW",TAB 11,"COLUMN",TAB 10, "PAGE"); WRITE(" ");
          FOR I:=C STEP 1 UNTIL D DO
            BEGIN
             J:=E;
             WHILE J<=F DO
               BEGIN
                 WRITE(THREE[A+1,I,J]);
                 J:=J+1;
               END;
            END;
         END;
      END;
 WRITE(" ");

   BEGIN
     INTEGER Z,Y;
     WRITE("INPUT A VALUE TO TEST THE ALGOL-M CASE STATEMENT");
     WRITE("THE VALUE MUST BE BETWEEN 0 AND 4 SAMPLE 3");
     WRITE("FOR THIS INPUT A RESULT OF 13 WILL BE RETURNED");
     READ(Z);
       CASE Z OF
        BEGIN
          Y:=10;
          Y:=11;
          Y:=12;
          Y:=13;
          Y:=14;
        END;
     WRITE(TAB 4,"Y = ",Y);
     WRITE(" ");
  END;
END;
END
