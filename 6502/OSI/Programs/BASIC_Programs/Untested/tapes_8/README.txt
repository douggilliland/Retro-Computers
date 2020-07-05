
sample_taxi.txt and sample_hectic.txt are the sample BASIC programs
which came on the tape sent with the machine.

All the other files in this directory are machine code,
and apart from the Extended Monotor (exmon), were written by me.

Files with "sb" in the name were modified to run on the Superboard.

Files with 48x32 in the name are for a 48x32 video display:
with 2K of RAM instead of the usual 1K.
This enhancement was usually implemented by "piggybacking"
extra RAM chips on top of the existing video RAM,
with one leg sticking out, attached to a flying lead, 
and a few changes to the circuitry.


assembler_exmon is a simple 6502 assembler.
The tape says: "1370--1800 + 1800--2000
Use checksum loader.
Press Reset M.1800G to start
Press "/" to enter assembler"

asteroids is my implementation of asteroids.

life is an implementation of Conway's "Game of Life",
together with a sample board.
The tape says: "start at 024E to clear, 027E to continue".
To set up the board: use keys W, A, D, and X to move the cursor around, 
use keys L, ; , UP-ARROW and / to move the displayed "window":
the screen displays a small window on a much larger 
Press RETURN to place a cell, SPACE to clear a cell,
and RUB OUT to start execution. Hold down right shift to stop.
You can move the window while the program is executing.

life+board+copy-600baud-003.txt is probably a machine code copy
routine for use from BASIC?

life-auto.txt will load the life game and the sample board
and start the program. The window shows a "glider gun".
Press RUB-OUT to start execution. Hold down right shift to stop.
You can move the window while the program is executing.

teletype_conversion is a small program to change the output
from 300 baud to 110 baud so that the RS232 port could
be connected to a Teletype.


pacman is my version of a pacman game. The tape says:
"Start at 0D60
0300--0500 + 0800--1000
Use checksum loader.
Press Reset M.0D60G to start"
pacman-48x32-auto.txt is a version which includes the loader
and all data and automatically starts the game.
Press Reset M L and start the tape. The game will load and play.
Use keys: / and RIGHT-SHIFT to move left and right,
CTRL and LEFT-SHIFT to move up and down.
Hold down space bar to start a new game.


prime-prog-001.txt is the contents of a tape labelled
"Prime no calc + result".
I must have written this program, but, to quote Gandalf:
"I have no memory of this place"!


space-invaders-48x32-001.txt
Load with the checksum loader, start game with:
RESET M.0890G


asteroids_sb_48x32_A.txt -- corrupt file

asteroids_sb_48x32_B.txt
Loads OK with checksum loader.
Start game with:
RESET M.0F4DG

asteroids16 asteroids32: Load with monitor,
starts automatically as 0FF0

LEFT SHIFT  Rotate left
Z           Rotate right
SPACE       Fire engines
: - RUBOUT  Fire missile (left, centre, right)







