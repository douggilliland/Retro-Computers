
/*
        "LIFE"

        The game invented by John Conway

        This version written by Leor Zolman to exemplify  
        PROPER use of "goto" statements in C programs!

	Note that the Universe is a toroid;
	The left extreme is adjacent to the right extreme,
	the top is adjacent to the bottom, and each corner
	is adjacent to each other corner.
	In other words, there ARE NO EXTREMES !!
	Or, in a more physical illustration: If you could
	look straight ahead through an infinitely powerful
	telescope, you'd eventually see the back of your
	head....

*/

#define HIGHT 16        /* # of lines on your terminal */
#define WIDTH 64        /* # of columns on your terminal */
#define XSIZE 100	/* length of cell array  */
#define YSIZE 100	/* width of cell array */
			/* To see how the toroid works,
			   try reducing XSIZE and YSIZE to
			   around 10 or 20.		*/
#define CENTER 1 	/* 1 = center; 0 = left justify  */

char *gets();
char cell[XSIZE][YSIZE];
int minx, maxx, miny, maxy, pop, gen;
int adj[16];
char doneflag;

main()
{
        initw(adj,"-1,-1,-1,0,-1,1,0,-1,0,1,1,-1,1,0,1,1");
        for (;;) {
          clear();
	  setup();
	  if (!pop) break;
          adjust();
          display();
          while (pop) {
                adjust();
                dogen();
                display();
		if (kbhit()) {getchar(); break;}
		if (doneflag) break;
           }
         }
 }

/* initialize the cell matrix to all dead */
clear()
{
	setmem(cell,(XSIZE*YSIZE),0);
}

/* get initial set-up from user */
setup()
{
	char c,y;
	char string[YSIZE], *ptr;
        y = pop = gen = minx = maxx = miny= maxy = 0;
        printf("\n\nEnter initial configuration (null line to end):\n");

	while (*gets(string)) {
		ptr = string;
		while (*ptr) {
			if ( *ptr++ != ' ') {
				cell[maxx][y] = 2;
				++pop;
			 }
			++y;
			if (y==YSIZE) {
			 printf("Truncated to %d chars\n",
				 YSIZE); break;
			 }
		 }
		--y;
		++maxx;
		if (y>maxy) maxy = y;
		if (maxx==XSIZE) break;
		y = 0;
	 }
	--maxx;
}

/* display the current generation */
display()
{
	int i,j,k,j9;
        char c;

        if(minx && prow(minx-1)) minx--;
        if(miny && pcol(miny-1)) miny--;
	if ((maxx < (XSIZE-1)) && prow(maxx+1)) maxx++;
        if((maxy<(YSIZE-1)) && pcol(maxy+1))maxy++;
        
        while (!prow(minx)) minx++;
        while (!prow(maxx)) maxx--;
        while (!pcol(miny)) miny++;
        while (!pcol(maxy)) maxy--;

	printf("\n\ngeneration = %1d   population = %1d  ",
		gen,pop);
        ++gen;

        putchar('\n');

	j9 = maxy - miny + 1;
        for (i = minx; i<=maxx; i++) {
                if (CENTER && j9<WIDTH)
                        for (k=0; k<(WIDTH-j9)/2; k++) putchar(' ');
                for (j=miny; j<=maxy; j++) {
                        switch(cell[i][j]) {
				case 1: cell[i][j] = 2;
                                case 2: putchar('*');
                                        break;
                                case 3: cell[i][j] = 0;
                                case 0: putchar(' ');
                        }
                }
		if (i != maxx) putchar('\n');
        }
}

/* test if given column is populated */
pcol(n)
{
	int i,hi;
	hi = (maxx == (XSIZE-1)) ? maxx : maxx+1;
	for (i = minx ? minx-1 : minx; i<=hi; ++i)
		if (cell[i][n]) return 1;
        return 0;
}

/* test if given row is populated */
prow(n)
{
	int i,hi;
	hi = (maxy == (YSIZE-1)) ? maxy : maxy+1;
	for (i = miny ? miny-1 : miny; i<=hi; ++i)
		if (cell[n][i]) return 1;
        return 0;
}



/* compute next generation */
dogen()
{
        int i,j,friends,i2,j2;
	int bigflag;
	int k;
        doneflag = 1;
	bigflag =  (minx<2 || maxx>(XSIZE-3) ||
		miny<2 || maxy>(YSIZE-3)) ;
	i2 = (maxx==(XSIZE-1)) ? maxx : maxx+1;
	j2 = (maxy==(YSIZE-1)) ? maxy : maxy+1;
	for (i=minx ? minx-1 : minx; i<=i2; ++i)
	  for (j=miny ? miny-1 : miny; j<=j2; ++j) {
                friends = 0;
		if(bigflag)
			for (k=0; k<16; ++k) {
			if (cell[mod(i+adj[k++],XSIZE)]
			   [mod(j+adj[k],YSIZE)] & 2)++friends;
			}
		else
			for (k=0; k<16; ++k)
			if (cell[i+adj[k++]][j+adj[k]]&2)
				++friends;

                if (cell[i][j] & 2) {
                        if (friends<2 || friends>3) {
                                 doneflag = 0;
                                 cell[i][j] = 3;
                                 --pop;
                        }
                 }
                  else if (friends==3) {
                        doneflag = 0;
                        cell[i][j] = 1; 
                        ++pop;
                  }
          }
}


int mod(a,b)
{
	if (a<0) return b+a;
	if (a<b) return a;
	return a-b;
}


/* If we're about to run off the matrix, adjust accordingly (if possible) */
adjust()
{
        adjx();
        adjy();
}

/* Adjust vertical position */
adjx()
{
        int delta, i,j;
        int savdelta;
	if (maxx - minx + 1 > XSIZE-2) return;
        if (minx==0) {
                delta = (XSIZE-maxx)/2+maxx;
                savdelta = delta;
                for (i=maxx; i >= 0; --i) {
                        for (j=miny; j<=maxy; ++j) {
                                cell[delta][j] = cell[i][j];
                                cell[i][j] = 0;
                         }
                --delta;
                }
                minx = delta+1;
                maxx = savdelta;
        }

        if (maxx == (XSIZE-1)) {
                delta = minx/2;
                savdelta = delta;
                for (i=minx; i<XSIZE; ++i) {
                        for (j=miny; j<=maxy; ++j) {
                                cell[delta][j] = cell[i][j];
                                cell[i][j] = 0;
                        }
                ++delta;
                }
                maxx = delta-1;
                minx = savdelta;
        }
}


/* Adjust horizontal position */
adjy()
{
        int delta, i, j;
        int savdelta;
	if (maxy - miny + 1 > YSIZE -2) return;
        if (miny == 0) {
                delta = (YSIZE-maxy)/2+maxy;
                savdelta = delta;
                for (i=maxy; i>=0; --i) {
                        for (j=minx; j<=maxx; ++j) {
                                cell[j][delta] = cell[j][i];
                                cell[j][i] = 0;
                        }
                --delta;
                }
                miny = delta+1;
                maxy = savdelta;
        }

        if (maxy == (YSIZE-1)) {
                delta = miny/2;
                savdelta = delta;
                for (i=miny; i<YSIZE; ++i) {
                        for (j=minx; j<=maxx; ++j) {
                                cell[j][delta] = cell[j][i];
                                cell[j][i] = 0;
                        }
                ++delta;
                }
                maxy = delta -1;
                miny = savdelta;
        }
}
