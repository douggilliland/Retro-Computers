BEGIN
COMMENT THIS PROGRAM TESTS THE ALGOL-M BOOLEAN TESTS FOR INTEGER
        VALUES;

INTEGER X,Y,Z;
WHILE 1=1 DO
  BEGIN
    READ(X,Y);
    IF X>5 AND X<100 THEN WRITE("5-100");
    IF NOT X<5 OR X>100 THEN WRITE("NOT 5-100");
    IF X>Y AND Y>5 AND X>10 THEN WRITE("5-10-X>Y");
    IF X=5 OR X=10 OR X<Y OR Y=5 OR Y=10 THEN WRITE("5-10-X<Y-5-10");
    IF X=5 AND Y=7 OR X=7 AND Y=5 THEN WRITE("5-7");
  END;
END
