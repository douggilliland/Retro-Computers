/*
   Polish Pong game for H19/H89, RHH (Robert H. Halstead) August 1980: 

   Object is to guide the little ball around the screen by setting up
   and removing blockade sections. All control is via the keypad; "4"
   and "6" cause blockades to be formed at the current position of the
   roving ball, while pressing "5" at the exact moment the ball hits a
   blockade should make that blockade disappear. Oh yes, and the POINT
   of all this is to make the ball hit the little square target--once
   this is done, the square will disappear and reappear somewhere else,
   to be hit again. Go for hitting the target the specified number of
   times AS QUICKLY AS POSSIBLE. Your score is how many seconds you
   took; the lower the better.
   Keys "8" and "2" speed up and slow down the ball; as you get better,
   try it at a faster speed!
*/  

#include "bdscio.h"

#define	MAXX	78		/* horizontal size of board */
#define	MAXY	23		/* vertical size */
#define	MAXTARG	20		/* # of targets per game */
#define	ISPEED	400		/* initial ball speed */
#define	SPEEDINC 100		/* increments/decrements in ball speed */

#define	TIMX	50		/* locations of status strings */
#define	TIMY	23
#define	TARGX	30
#define	TARGY	23
#define	SPEEDX	10
#define	SPEEDY	23
#define	BESTX	70
#define	BESTY	23

#define	CONINF	1		/* console input FDOS function */

#define	MSPS	960		/* "millisecs" per second */

#define	QUITCH	3		/* ^C quits the program */
#define	DELETE	0177		/* DELETE restarts the game */

#define	XOFF	('S'&037)	/* flow control chars */
#define	XON	('Q'&037)

#define	EGRAPH	"\033F"		/* H19 escape sequences */
#define	XGRAPH	"\033G"
#define	REGKPM	"\033u\033>"

#define VBAR	'`'		/* H19 alternate graphic chars */
#define	HBAR	'a'
#define	SLASH	'x'
#define	BSLASH	'y'
#define	BALL	'^'
#define	TARGET	'i'

char board[MAXX][MAXY];		/* board with current layout */

int ballx,bally,ballxv,ballyv;	/* state of ball */
int Speed,Dist;			/* speed of ball */
int TargLeft;			/* number of targets left */
int MSecs,Secs;			/* bookkeeping for time elapsed */
int NewTime;			/* nonzero if time has changed */
int Best;			/* best score so far */
int InChar;			/* character read from input */

putchx(c)
 int c;
  {	if (++MSecs >= MSPS)
	  { MSecs = 0; Secs++; 
	    NewTime = 1;
	  }
	Dist += Speed;
	if (bios(2))
	  { InChar = bios(3) & 0177;
	    if (InChar == QUITCH)
	      {	InChar = -1;
		outs(0,MAXY-1,XGRAPH);
		prints(CURSORON);
		exit(0);
	      }
	    if (InChar == XOFF)
	      {	while (InChar != XON)
		  { while (!bios(2));
		    InChar = bios(3) & 0177;
		  }
		InChar = -1;
	      }
	  }
	bios(4,c);
	if (c == '\n') putchx('\r');
  }

/*
int getch()			/* get a char from console, no echo */
  {	int c;
	c = inp(CDATA);
	return(c);
  }
*/

prints(s)			/* put out a string */
 char *s;
  {	int c;
	while (c = *s++) putchx(c);
  }

puts(s)				/* same as prints, but "srand1" needs it */
 char *s;
  {
	prints(s);
  }

ouch(ch,x,y)			/* put character at position */
 int ch,x,y;
  {
	putchx(ESC); putchx('Y'); putchx(y+32); putchx(x+32); putchx(ch);
  }

outs(x,y,s)			/* put string at position (x,y) */
 int x,y;
 char *s;
  {
	putchx(ESC); putchx('Y'); putchx(y+32); putchx(x+32);
	prints(s);
  }

puttarg()
  {	char buff[100];
	sprintf(buff,"\033p%2d\033q",TargLeft);
	outs(TARGX,TARGY,buff);
  }

puttime()
  {	char buff[100];
	sprintf(buff,"\033p%3d\033q",Secs);
	outs(TIMX,TIMY,buff);
  }

putspeed()
  {	char buff[100];
	sprintf(buff,"\033p%3d\033q",Speed/10);
	outs(SPEEDX,SPEEDY,buff);
  }
	
int moveball()
  {	int i,nx,ny;
	Dist = 0;
	i = InChar;
	if (i > 0)
	  { InChar = -1;
	    switch (i)
	      {	case '4':			/* lay down backslash */
		    if (board[ballx][bally] == ' ')
		      board[ballx][bally] = BSLASH;
		     else putchx(7);
		    break;

		case '6':			/* lay down slash */
		    if (board[ballx][bally] == ' ')
		      board[ballx][bally] = SLASH;
		     else putchx(7);
		    break;

		case '5':			/* delete current char */
		    i = board[ballx][bally];
		    if (i == SLASH || i == BSLASH) board[ballx][bally] = ' ';
		     else putchx(7);
		    break;

		case '8':			/* go faster */
		    if (Speed < 1000) { Speed += SPEEDINC; putspeed(); }
		    break;

		case '2':			/* go slower */
		    if (Speed > SPEEDINC+50) { Speed -= SPEEDINC; putspeed(); }
		    break;

		case DELETE:			/* start a new game */
		    return(0);

		default:
		    putchx(7); break;
	      }
	  }
	switch (board[ballx][bally])
	  { case ' ':	break;
	    case VBAR:	ballxv = -ballxv; break;
	    case HBAR:	ballyv = -ballyv; break;
	    case BSLASH: i = ballxv; ballxv = ballyv; ballyv = i; break;
	    case SLASH:	i = ballxv; ballxv = -ballyv; ballyv = -i; break;
	    case TARGET:
		if (--TargLeft <= 0) return(0);
		puttarg();
		board[ballx][bally] = ' ';
		do {	nx = rand()%(MAXX-2) + 1;
			ny = rand()%(MAXY-2) + 1;
		   } while (board[nx][ny] != ' ');
		board[nx][ny] = TARGET;
		ouch(TARGET,nx,ny);
		break;
	  }
	nx = ballx + ballxv;
	ny = bally + ballyv;
	ouch(BALL,nx,ny);
	ouch(board[ballx][bally],ballx,bally);
	if (NewTime) { puttime(); NewTime = 0; }
	ballx = nx; bally = ny;
	while (Dist < (ballyv?22000:10000)) putchx(1);
					/* further delay to slow ball down */
	return(1);
  }

main()
  {	puts("Welcome to Polish Pong!\n"); sleep(10);
	Best = 32767;
	Speed = ISPEED;		/* governs how fast ball moves */
	while (playgame());
  }

int playgame()
  {	int i,j;
	char buff[100];		/* temp */
	InChar = -1;			/* initially, no char typed in */
	srand1("\033H\033GType any key to start game:  \033K");
	if (bdos(1) == QUITCH) 		/* clear the input character */
		exit();			/* and quit on control-C	*/
	InChar = -1;		/* clear space out of input buffer */
	ballx = rand()%(MAXX-2) + 1;
	bally = rand()%(MAXY-2) + 1;
	ballxv = ballyv = 0;
	i = (rand()&2) - 1;
	if (rand()&1) ballxv = i; else ballyv = i;
	for (i = 0; i < MAXX; i++) for (j = 0; j < MAXY; j++) board[i][j] = ' ';
	for (i = 0; i < MAXX; i++) board[i][0] = board[i][MAXY-1] = HBAR;
	for (i = 0; i < MAXY; i++) board[0][i] = board[MAXX-1][i] = VBAR;
	board[0][0] = 'f';		/* special corner pieces */
	board[0][MAXY-1] = 'e';
	board[MAXX-1][0] = 'c';
	board[MAXX-1][MAXY-1] = 'd';
	board[rand()%(MAXX-2)+1][rand()%(MAXY-2)+1] = TARGET;
					/* place initial target */
	TargLeft = MAXTARG;	/* start with full complement of targets */
	prints(REGKPM); prints(CLEARS); prints(EGRAPH); prints(CURSOROFF);
	for (j = 0; j < MAXY; j++)
	  { for (i = 0; i < MAXX; i++) putchx(board[i][j]);
	    putchx('\n');
	  }
	outs(TIMX-11,TIMY,"\033G\033pTime Used: ");
	outs(TARGX-14,TARGY,"Targets Left: ");
	if (Best < 32767)
	  { sprintf(buff,"Best Time: %3d",Best);
	    outs(BESTX-11,BESTY,buff);
	  }
	outs(SPEEDX-7,SPEEDY,"Speed: \033F\033q");
	putspeed();
	puttarg();
	MSecs = Secs = 0; puttime();
	ouch(BALL,ballx,bally);
	while (moveball());
	if (TargLeft == 0 && Secs < Best) Best = Secs;
	return(1);
  }
