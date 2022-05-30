1 REM Copyright (c) 2016 by Warren Young
2 REM Released under the terms of ../SIMH-LICENSE.md
3 REM ------------------------------------------------------------------
10 FOR I = 1 TO 999
20 A = I / 3 \ B = I / 5
30 IF INT(A) = A GOTO 60
40 IF INT(B) = B GOTO 60
50 GOTO 70
60 T = T + I
70 NEXT I
80 PRINT "TOTAL: "; T
90 END
