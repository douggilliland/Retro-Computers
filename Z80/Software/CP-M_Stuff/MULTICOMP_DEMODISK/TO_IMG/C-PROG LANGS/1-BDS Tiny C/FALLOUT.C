/*
	FALLOUT for the H19

	This is a logical extension of "flyby.c"

	written by Leor Zolman
		   July 18, 1980 (I promise to stop playing with the H19
				  and put more work into the v1.4 code
				  optimizer...tomorrow!)
*/				  

#include "bdscio.h"

#define MAXTHINGS 50		/* Maximum # of objects on the screen
				   at once				*/
#define INACTIVE  0

struct thing {
	char what;	/* Either an Ascii value, or INACTIVE */
	char rev;	/* True if character to be displayed in reverse */
	int rowp;	/* Row position of thing */
	int colp;	/* Column position of thing */
	int speedd;	/* Down speed	*/
	int speeda;	/* Across speed (signed to indeciate left or right) */
	char trail;	/* True if displaying trail */
	char zigzag;	/* True if zigzag-ing */
	int zigmag;	/* if zigzag-ing, magnitude of zig and zag */
	int zigpos;	/* Count of how many zigs or zags have been done */
};

char halt;		/* goes true when user aborts */

main(argc,argv)
char **argv;
{
	struct thing thingtab[MAXTHINGS], *thingie;
	int dspeedt[20], aspeedt[20];	/* Tables of possible speeds	*/
	int i,nthings;		/* loop variable, and # of active things */
	char inrev;		/* true if in reverse video */
	char trails;		/* true if displaying all trails */
	char point_source;	/* true if all things coming from one point */
	int source_point;	/* if point_source true, the horiz pos */

	printf("Welcome to H19 Fallout!\r\nWritten by Leor Zolman   7/80");
	initw(dspeedt,"1,1,1,1,1,1,1,1,1,1,2,2,2,2,3,3,3,4,4,5");
	initw(aspeedt,"0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,7");
	point_source = trails = FALSE;

start:	do {
		puts(CLEARS); puts(INTOREV);
		puts("\33y5");  /* cursor on */
		printf(" How many things should I display (1-%d,",
			MAXTHINGS);
		srand1(" or q to quit) ?   \b\b");
		if (!scanf("%d",&nthings)) {
			puts(OUTAREV);
			exit();
		 }
	} while (nthings < 1 || nthings > MAXTHINGS);

	puts(CLEARS);	puts(OUTAREV);
	halt = inrev = FALSE;
	puts("\33x5");	/* cursor off */
	for (i=0; i<nthings; i++) thingtab[i].what = INACTIVE;

	while (!halt) {

	   if (!(rand() % 99)) {		/* if point source off, make */
		point_source = TRUE;		/* it tough to get it turned */
		source_point = rand() % 79;	/* on...		     */
	   }
						/* but easier to turn off    */
	   if (point_source && !(rand() % 50)) point_source = FALSE;

	   if ( trails && !(rand() % 2))
		trails = FALSE;	/* if trails on, lean toward turning off */

	   else if (!trails && !(rand() % (MAXTHINGS - nthings + 20)))
		trails = TRUE;	/* if trails off, lean to keeping 'em off */

	   if (!(rand() % ((2 * MAXTHINGS + 5) - nthings * 2 ))) puts(CLEARS);

	   for (i=0; i<nthings; i++) {	 /* now process each thing */
		thingie = thingtab[i];	 /* get pointer to current thing */

		if (!thingie -> what) {	    /* if it is inactive, create it: */
			thingie -> what = rand() % 96 + ' ';
			thingie -> rev = rand() % 2;
			thingie -> trail = rand() % 30 ? trails : !trails;

			thingie -> speedd = dspeedt[rand() % 20];
			thingie -> speeda = aspeedt[rand() % 20] *
						((rand() % 2) * 2 - 1);
			if (thingie -> zigzag = !(rand() % 5)) {
			   thingie -> zigmag =
				 (rand() % 25 + 2) / abs(thingie -> speeda);
			   thingie -> zigpos = thingie -> zigmag / 2;
			 }
			thingie -> rowp = 0;

			if (!point_source)
				thingie -> colp = thingie -> zigzag ?
				   thingie->zigzag / 2 + 1 + 
				   rand() % (TWIDTH - thingie -> zigmag) :
				   rand() % TWIDTH;
			else
				thingie -> colp = source_point;
		 }

		 else {		/* else move it down one iteration */
			if (!thingie -> trail) {  /* if don't need trails, */
				if (inrev) {	  /* erase last position.  */
					puts(OUTAREV);  /* no reverse video */
					inrev--;
				 }
				gotoxy(thingie -> rowp, thingie -> colp,' ');
			 }
			if (thingie -> zigzag &&	/* if in zigzag mode */
			   ++thingie -> zigpos > thingie -> zigmag) {
				thingie -> zigpos = 0;	/* then reverse dir */
				thingie -> speeda = -thingie -> speeda;
			   }
			thingie -> rowp += thingie -> speedd;
			thingie -> colp += thingie -> speeda;
			if (  thingie -> rowp > (TLENGTH-1) /* if outa range */
			   || thingie -> colp < 0
			   || thingie -> colp > (TWIDTH-1) )
			  thingie -> what = INACTIVE; /* then turn off */
			else {
				if (thingie -> rev) {  /* not out of range;  */
				     if (!inrev) {     /* if a reverse char, */
					puts(INTOREV); /* make sure we're in */
					inrev = TRUE;  /* reverse video mode */
				      }
				 }
				else if (inrev) {      /* if not a rev char  */
					puts(OUTAREV); /* make sure we're in */
					inrev--;       /* normal video mode  */
				 }
				gotoxy(thingie -> rowp, thingie -> colp,
					thingie -> what);
			}
		}

	   }
	}
	goto start;
}

putchar(c)
{
	bios(4,c);
}

gotoxy(x,y,c)
{
	char c2;
	if (y <= 78 || x != 23) {
		putchar (ESC);
		putchar ('Y');
		putchar (x + ' ');
		putchar (y + ' ');
		putchar (c);
	 }
	if (!bios(2)) return;
	if ((c2 = bios(3)) != 0x13) halt = 1;
	if (c2 == 0x13)
	    while (1) {
		while (!bios(2)) rand();
		if (bios(3) == 0x11) break;
	     }
}
