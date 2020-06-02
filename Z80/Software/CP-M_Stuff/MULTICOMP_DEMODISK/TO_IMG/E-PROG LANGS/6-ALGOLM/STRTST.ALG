BEGIN
STRING A,B;
WHILE 1=1 DO
  BEGIN
     READ (A,B);
     IF A<B THEN WRITE("LSS");
     IF A=B THEN WRITE("EQL");
     IF A>B THEN WRITE("GTR");
     IF A>=B THEN WRITE("GTREQL");
     IF A<=B THEN WRITE("LSSEQL");
     IF A<>B THEN WRITE("NEQL");
  END;
END
