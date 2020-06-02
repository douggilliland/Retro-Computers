/*
	"Lines"

	written by:
		Leor Zolman
		173 Hampshire st. #2
		Cambridge, Massachussetts 02139

	This program requires that a 64 x 16 memory mapped
	video board be present in the system. For best
	results, use a Processor Technology VDM-1 addressed
	at CC00 hex.
	The function"Line" will only work for such a memory
	board; if you wish to run this program with a DMA board
	organized other than as 64 x 16, you will have to write
	your own line drawing program to work as follows:
		line (char, x1, y1, x2, y2)
	should draw a line from (x1,y1) to (x2,y2) consisting
	of the character `char';
		x's range from 0 to (# of rows)-1,
		y's range from 0 to (# of columns)-1.

	It has been rumored that the use of psychoactive
	chemicals and Tangerine Dream albums in conjunction
	with this program can lead to irreparable brain
	damage...for instance, one individual (who shall
	go nameless), following sufficient exposure to the
	aforementioned combination of sensory stimulants,
	began to exhibit extremely anti-social attitudes
	such as "Gee, after THIS, watching television seems
	a waste of TIME!" and "Wow, I'd rather be writing
	computer programs to do neat things like THIS
	instead of letting my natural ability for creative
	abstraction atrophy through overexposure to the
	inanity of Prime-Time tunnelvision."
		This poor individual has, needless to say,
	now suffered a total emotional and social breakdown.
	Even the THOUGHT of perfectly natural, socially
	accepted TV viewing sends him into fits of depression;
	he's become psychologically addicted to the manip-
	ulation of numbers and other unreal abstractions
	for the purpose of producing things like "compilers"
	which he, due to his tortured and twisted psyche,
	actually considers USEFUL. Poor guy; for him, the
	REALITY of television was just too much to cope with.

	I have related this sobering account with the sadistic
	hope that the same thing happens to YOU!!!!

	P.S.:
	 If only people would listen to Harlan Ellison...
*/


#define VDMBASE 0xfc00
#define ROWS 16
#define COLUMNS 64
#define MODULES 7
#define ESC '\033'
#define HOME 0x0c
#define RANDROW (rand() >> 5) % ROWS
#define RANDCOL (rand() >> 6) % COLUMNS

char speed, density, setcnt, erasmod, bkround;
char frontp, nactive, dchar, charcd, charmode;

struct module {
	char freq;
	int nfactor;
	char active;
 } mtab[MODULES];

char activet[MODULES];
char *modnames[MODULES];
int adj[16];

int flag;
main()
{
	char cmod, i, j, k, l, c;
	char x, y, x1, y1, x2, y2;
	char count,brkflg;
	int limit, d;

	startit();
	for(;;){
	if (nactive)
	 while (!kbhit()) {
		if(frontp) {
			speed = csw() >> 4;
			density = csw() & 15;
		 }
		if(erasmod == 1) clear();
		do
			cmod = rand() % nactive;
		 while (mtab[activet[cmod]].freq > rand()&15);

		limit = rand() % setcnt;
		for (i=0; i < limit; i++) {
		 if (kbhit()) break;
		 switch (erasmod) {
		   case 2: clear(); break;
		   case 3: if(!(rand()%(speed+speed)))clear();
		 }
		 outp(255, ~activet[cmod]);

		switch(activet[cmod]) {
		 case 0:	/* lines */
		  count = rand()%(density*5);
		  do {
			figure();
			dline(0, RANDROW,
				 RANDCOL,
				(rand(), RANDROW),
				 RANDCOL);
		   } while (count--);
		break;

		case 1:	    /* Connected Random lines */
		  count = rand()%(density*5);
		  x = RANDROW;
		  y = RANDCOL;
		  do {
			figure();
			x1 = RANDROW;
			y1 = RANDCOL;
			dline (0,x,y,x1,y1);
			x = x1;	
			y = y1;
		   }  while (count--);
		break;


		case 2: /* rectangles */
		  count = rand() % (density<<3);
		  do {
			figure();
			x1 = RANDROW;
			y1 = RANDCOL;	
			x2 = RANDROW;
			y2 = RANDCOL;
			dline (0, x1, y1, x1, y2);
			dline (0, x2, y1, x2, y2);
			dline (0, x1, y1, x2, y1);
			dline (0, x1, y2, x2, y2);
		   }  while (count--);
		break;


		case 3:	/* triangles */
		  count = rand() % (density<<2);
		  do {
			figure();
			x = rand()%ROWS;
			x1 = RANDROW;
			x2 = RANDROW;
			y = RANDCOL;
			y1 = RANDCOL;
			y2 = RANDCOL;
			dline (0, x, y, x1, y1);	
			dline (0,x1,y1,x2,y2);
			dline (0,x2,y2,x,y);
		 } while (count--);	
		break;

		case 4:	/* ECKS IS */
		  count = rand() % (density<<3);
		  do {
			figure();
			x = RANDROW;
			x1 = RANDROW;
			y = RANDCOL;

			y1 = RANDCOL;
			dline (0,x,y,x1,y1);
			dline (0,x,y1,x1,y);
		   } while (count--);
		  break;

		case 5:	/* vertices */
			count = rand() % density;
		   do {
			figure();
			x = RANDROW;
			y = RANDCOL;
			while (rand()&15)
			  dline(0,x,y,RANDROW,RANDCOL);
			} while (count--);
			break;

		case 6:		/* dart */
			x1 = RANDROW;
			y1 = RANDCOL;
			count = rand() % (density<<2);
			do {	
			  d = rand() % 8;
			  do {
				x = x1;
				y = y1;
				plot (x,y,rand());
				x1 += adj[d+d];
				y1 += adj[d+d+1];
			} while (x1<16 && y1<64);
			  x1=x; y1=y;
			} while (count--);
			break;
		

		}
	   }
	}
	c = getchar();
	flag = 1;
	brkflg=0;
	while (!brkflg) {
	putchar(HOME);
	if (!flag) {
		commands();
		printf("\nCommand: ");
	 }
	c = flag? c : getchar();
	flag = 0;
	  switch (c) {
		case '\n':
		  rand(); rand(); rand(); clear(); brkflg=1;
			break;
		case 's':
		  speed = gethd(
		"new speed factor (0=slow ... F=fast): ");
		   break;

		case 'd':
		  density = gethd(
		"new density factor (0=sparse ... F=dense): ");
		   break;

		case 'n':
		  setcnt = gethd(
		"new maximum set size (0 - F): ");
		   break;

		case 'f':
		  frontp = 1;
		  printf("\nOK; the high order 4 input switches");
		  printf(" at port 255 now control\n");
		  printf(" SPEED, and the low order 4 bits");
		  printf(" control DENSITY.\n");
		  printf("Type CR to continue...");
		  getchar();
		  break;

		case 'k':
		  frontp = 0; break;

		case 'q':
		  return;

		case 'b':
		  printf("\nEnter new backround character \
(or ESCAPE for inversion): ");
		  if ((bkround = getchar() ) == ESC ) {
		    printf("\nOK, now type the actual char: ");
		    bkround = getchar() | 0x80;
		   }
		break;

		case 'r':
		  display();
		  if ( !(c = getmod() ) || !mtab[c-1].active)
			break;
		  mtab[c-1].active = 0;
		  --nactive;
		  compile();
		  break;

		case 'm':
		  display();
		  if ( !(c = getmod() )) break;
		  mtab[c-1].freq = gethd(
			"Frequency factor (0 - F): ");
		  mtab[c-1].active = 1;
		  ++nactive;
		  compile();
		  break;

		case 'e':
		  putchar('\n');
		  printf("0 = never erase        1 = erase \
on module entry\n");
		  printf("2 = at start of sets   \
3 = randomly\n");
		  do erasmod = gethd(
		"Enter new erase mode (0 - 3): ");
			while (erasmod > 3);
		   break;

		case ' ':
			brkflg=1;
			break;

		case 'c':
		  printf("\n0 - fixed character           1 - random char per line\n");
		  printf("2 - rand char per figure      3 - randomness\n");
		  do charmode = gethd("Enter character choosing mode (0-3): ");
			while (charmode > 3);
		  if (!charmode) {
		   printf("\nType the character (or ESCAPE for inversion): ");
		   if ( (dchar = getchar()) == ESC) {
			printf("\nType the actual character: ");
			dchar = getchar() | 0x80;
		    }
		   break;
		   }
		  if (charmode == 3) charcd = rand() % 100;
		  break;

		}
	}
	brkflg=0;
    }
}


clear()
{
	setmem(VDMBASE, ROWS*COLUMNS, bkround);
	outp ( 0xc8, 0);
}


compile()
{
	char slot; int i;
	slot = 0;
	for (i=0; i<MODULES; i++)
	 if (mtab[i].active) activet[slot++] = i;
}


gethd(s)
char *s;
{
	char c;
   for(;;){
	putchar('\n');
	puts(s);
	while ((c = getch() ) == ' ' || c=='\t');
	if (c >= '0' && c <= '9') return c - '0';
	if (c>='a' && c <= 'f') return c - 87;
	}
}

getch()
{
	char c;
	c = getchar();
	if (c >= 'A' && c <= 'Z') return c+32;
	return c;
}


getmod()
{
	char c;
	printf("\nEnter module letter (a - %c): ",
		MODULES+'a'-1);
	while (( c = getch() ) == ' ' || c=='\t');
	if (c >= 'a' && c <= MODULES+'a'-1) return c-'a'+1;
	return 0;
}


display()
{
	int i,j,k;
	clrplot();	
	putchar('\n');
	for (i=0; i<MODULES; i++) {
		printf("%c: %c  %s", i+'A',
		 mtab[i].active ? hd(mtab[i].freq) : ' ',
		 modnames[i]);

		for (j=strlen(modnames[i])+7; j<32; j++)
			putchar(' ');
		if (i&1) putchar('\n');
		}
	putchar('\n');
}


hd(n)
char n;
{
	if (n>=0 && n<=9) return n+'0';
	return n+87;
}


figure()
{
	int delay;
	if (charmode==2) dchar = rand();
	if (15-speed) for (delay=0; delay<((15-speed)<<5);
				delay++);
}


dline(c,x1,y1,x2,y2)
char c;
int x1,y1,x2,y2;
{
	if (charmode==1) dchar= rand();
	else if (charmode == 3) if (!charcd--) {
				  dchar =
				   (rand()%4==1) ? bkround
					 : rand();
				  charcd = rand() % 100;
				}
	line(dchar,x1,y1,x2,y2);
}


startit()
{
	int i;
	srand(0);
	initw(adj,"-1,-1,-1,0,0,1,1,1,-1,0,1,-1,1,-1,0,1");
	speed = 15;
	density = 12;
	setcnt = 15;
	erasmod = 3;
	bkround = ' ';
	frontp = 0;
	nactive = 5;
	dchar = rand();
	charmode = 3;
	mtab[0].freq = 5;
	mtab[0].active = 1;
	mtab[1].active = 1;
	mtab[1].freq = 5;
	mtab[2].active = 1;
	mtab[2].freq = 2;
	mtab[3].active = 1;
	mtab[3].freq = 4;
	mtab[4].active = 1;
	mtab[4].freq = 3;
	modnames[0] ="Random Lines";
	modnames[1] ="Connected Random Lines";
	modnames[2] ="Rectangles";
	modnames[3] ="Triangles";
	modnames[4] ="Ecks Is";
	modnames[5] ="Vertices";
	modnames[6] ="Dart";
	mtab[0].nfactor=3;
	mtab[1].nfactor=3;
	mtab[2].nfactor = 1;
	mtab[3].nfactor = 1;
	mtab[4].nfactor = 2;
	mtab[5].nfactor = 1;
	mtab[6].nfactor = 1;
	setplot(VDMBASE,ROWS,COLUMNS);
	for (i=5; i<MODULES; i++) mtab[i].active = 0;
	compile();
	clear();
}

commands()
{
	printf("LINES commands:\n\n");
	printf("CR:	start LINES\n");
	printf("s:	set speed from console\n");
	printf("d:	set density from console\n");
	printf("n:	set set-duration\n");
	printf("f:	get speed and density from front panel\n");
	printf("k:	get speed & density from console\n");
	printf("b:	set backround character\n");
	printf("e:	set erase mode\n");
	printf("m:	turn modules ON\n");
	printf("r:	turn modules OFF\n");
	printf("c:	set character mode\n");
	printf("q:	quit\n");
}
