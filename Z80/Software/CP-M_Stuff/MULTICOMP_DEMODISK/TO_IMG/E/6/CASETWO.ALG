BEGIN
 INTEGER TEST;
 WHILE 1=1 DO
   BEGIN
     WRITE( "INPUT AN INTEGER VALUE BETWEEN 0 AND 4");
     READ(TEST);
     CASE TEST OF
       BEGIN
         WRITE("0",TEST);
         WRITE("1",TEST);
         WRITE("2",TEST);
         WRITE("3",TEST);
         WRITE("4",TEST);
       END;
   END;
END
EOF
