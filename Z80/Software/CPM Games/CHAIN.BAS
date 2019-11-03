INPUT "COMMAND : "; COMMAND$
IF COMMAND$="STOP" THEN STOP
CREATE "$$$.SUB" RECL 128 AS 1
FORMAT$="!&!!"
PRINT USING FORMAT$, #1,2; CHR$(LEN(COMMAND$)), COMMAND$, CHR$(0), "$"
PRINT USING FORMAT$, #1,1; CHR$(9), "CRUN CHAIN", CHR$(0), "$"
CLOSE 1
STOP
END
