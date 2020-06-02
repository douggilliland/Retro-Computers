* Program..: SP-HELP.PRG
* Author(s): Debby Moody
* Date.....: 02/06/84
* Notice...: Copyright 1984, ASHTON-TATE, All Rights Reserved.
*      May not be reproduced without permission.
* Notes....: This program uses the TEXT ENDTEXT commands to
*      present text information to the user.
*
*
ERASE
@ 2,0 SAY "dBASE II Sample Programs Help Facility"
@ 3,0 SAY "========================================"
@ 3,40 SAY "========================================"
TEXT

Option #1, Mailing Labels, will activate the program LB-PRINT which will
print mailing labels for the LB-NAMES database. The program will prompt
the user for the label specifications. In order to print mailing labels
from your mailing list, rename and restructure your database to look
like the LB-NAMES DBF or alter the LB-PRINT program to read your database.

Option #2, Inventory Program, will activate the main menu of the inventory  
system. This system provides for on-line additions and updates to inventory.
It also has reporting capabilities for inventory and reorder information as  
well as a summary of inventory totals.

Option #3, Checkbook Program, will activate the main menu of the checkbook
balancing system. This system encompasses all aspects of checkbook balancing
from writing a check to reconciling a bank statement.

ENDTEXT
STORE " " TO answer
@ 23,0 SAY "(N)ext screen of (R)eturn [N/R]" GET answer PICTURE "!"
READ
IF answer # "N"
   RETURN
ELSE
ERASE
TEXT
The files on the disk that control the labels program are:
ENDTEXT
DISPLAY FILES LIKE LB-*.*
TEXT
The files on the disk that control the inventory program are:
ENDTEXT
DISPLAY FILES LIKE IN-*.*
TEXT
The files on the disk that control the checkbook program are:
ENDTEXT
DISPLAY FILES LIKE CB-*.*

@ 23,0 SAY "Strike any key to continue..."
SET CONSOLE OFF
WAIT
SET CONSOLE ON
RETURN
*EOF SP-HELP.PRGP-HELP.PRG================================="
@ 3,40 SAY "========================================"
TEXT

Option #1, Mailing Labels, will ac