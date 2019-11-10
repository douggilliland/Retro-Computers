
/*	: : : : : : : : : : : : : : : : : : : : : : : : : : : :
	ucsdir -- List the  directory of a UCSD Pascal diskette

		H.Moran 10/27/79

		column labels added 2/13/80
		quick and dirty sort added 2/14/80

	: : : : : : : : : : : : : : : : : : : : : : : : : : : : */




/*	: : : : : : : : : : : : : : : : : : : : : : : : : : : :
	Constants
	: : : : : : : : : : : : : : : : : : : : : : : : : : : : */

#define	SEL_DSK	14		/* bdos function number */
#define	SET_DMA	26		/* bdos function number */

#define	SET_TRK	10		/* bios index number */
#define	SET_SEC	11		/* bios index number */
#define	READ	13		/* bios index number */

#define	DUMMY	0		/* dummy parameter for bios routine */

#define	D_ENT_SZ 26		/* UCSD directory entry size */
#define	D_TITLE	6		/* offset to entry title */
#define	UCSD_NAM_SZ 17		/* size of the name part of ucsd dir entry */
#define UCSD_DIR_SZ 2048	/* size of UCSD directory in bytes */

#define	SECT_SIZE 128		/* bytes per physical sector */
#define BLOK_SIZE 512		/* bytes per UCSD logical block */
#define	SECT_PER_BLOK 4		/* physical sectors per logical block */


/*	: : : : : : : : : : : : : : : : : : : : : : : : : : : :
	Globals	-- these would be static if it were available
	: : : : : : : : : : : : : : : : : : : : : : : : : : : : */

int lsn;		/* logical sector number */
int lstlsn;		/* last logical sector number */
int nbytes;		/* number of bytes remaining in ucsd file buffer */
char ucsdbuf[BLOK_SIZE]; /* 1 block buffer for ucsd directory */
char *ptr;		/* pointer to current byte in ucsd buffer */



main(argc,argv)
	int argc;
	char *argv[];
	{

	lsn = lstlsn = nbytes = 0;	/* init globals */
	ptr = ucsdbuf;

	if( argc != 1 )	{
	  printf("Proper invocation form is:\n\n");
	  printf("ucsdir\n");
	  printf("Will list the directory of the UCSD disk on drive B\n");
	  exit(1);
	  }
	ucsdir();
	exit(0);
	}




/*	-------------------------------------------------------

	Name:		ucsdir()
	Result:		---
	Errors:		sector read error (aborts)
	Globals:	lsn,lstlsn
	Macros:		D_TITLE,UCSD_NAM_SZ,UCSD_NAM_SZ
			D_ENT_SZ,SECT_PER_BLOK
	Procedures:	read_ucsd(),putchar(),puts()

	Action:		Read from the diskette on drive B
			and print on the console
			the directory of a presumed
			UCSD Pascal formatted disk

	------------------------------------------------------- */


ucsdir()
	{
	char ucsd_dir[UCSD_DIR_SZ];
	char *dir,*saved_dir;
	int name_len,colct,entries,dunno;
	int cmpare(),i;

	read_ucsd(ucsd_dir,(2*SECT_PER_BLOK),4); /* get entire directory */

	dir = &ucsd_dir[D_TITLE];		/* print volume label */
	puts("\nDirectory of : ");
	name_len  = *dir++;
	while ( name_len-- )
	  putchar(*dir++);
	puts("\n\n");

	dir = &ucsd_dir[(D_TITLE + D_ENT_SZ)];	/* point to 1'st entry */
	i = 0;
	while( *(dir+i) != 0 && (dir+i) < &ucsd_dir[UCSD_DIR_SZ] )
	 i += D_ENT_SZ;
	qsort((dir-D_TITLE),(i)/D_ENT_SZ,D_ENT_SZ,&cmpare);
	entries = 0;
	puts("\nFilename         locn len  type");
	puts("  Filename         locn len  type");
	puts("\n---------------- ---- ---- ----");
	puts("  ---------------- ---- ---- ----\n");
	while ( dir < &ucsd_dir[UCSD_DIR_SZ] ) {/* print directory entries */
	  saved_dir = dir;
	  colct = 1;
	  name_len = *dir++;
	  if( name_len <= 0 || name_len > (UCSD_NAM_SZ-1) )
	    break;
	  while( name_len-- ) {		/* print the file name */
	    putchar(*dir++);
	    colct++;
	    }
	  while( colct++ <UCSD_NAM_SZ )	/* print spaces to max name length */
	    putchar(' ');

	  dir = saved_dir - D_TITLE;	/* point to begin of entry */
					/* i.e. block alloc. indicators */

	  lsn = *dir++ + ( *dir++ << 8);/* lsn = starting logical block # */
	  lstlsn= *dir++ +(*dir++ << 8);/* lstlsn = ending logical block # */
	  dunno = *dir++ + (*dir++ <<8);/* file type */


	  printf(" %4d %4d %4d",lsn,lstlsn-lsn,dunno);
	  dir = saved_dir + D_ENT_SZ;	/* dir = pointer to next entry */
	  entries & 1 ? puts("\n") : puts("  ");
	  entries++;
	  }
	return;
	}



read_ucsd(buf,rn,count)
	char *buf;
	int rn;
	int count;
	{
	char bios();
	int seccnt; seccnt = count*4;

	bdos(SEL_DSK,1);
	while( seccnt-- ) {
	  bdos(SET_DMA,buf);
	  bios(SET_TRK,track(rn));
	  bios(SET_SEC,sector(rn));
	  if( bios(READ,DUMMY) ) {
	    printf("read error @ track %2d sector %2d",track(rn),sector(rn));
	    exit(1);
	    }
	  buf += SECT_SIZE;
	  rn++;
	  }
	return bdos(SEL_DSK,0);
	}

/*	-------------------------------------------------------

	Name:		sector(rn)
	Result:		physical sector number
	Errors:		---
	Globals:	---
	Macros:		---
	Procedures:	---

	Action:		This code maps logical sectors to physical
			sectors	by selecting every second sector
			in order (accounting for the modulo 26
			process) on the diskette except	that at a
			track switchover point there is an additional
			'gap' of 6 sectors (total of 7) to allow
			for the drive to seek. This is UCSD's
			attempt to minimize disk access	time.

	------------------------------------------------------- */


sector(rn)
	unsigned rn;
	{
	unsigned t1,t2,trk,t3,sect;

	t1 = rn % 26;
	t2 = t1 << 1;
	if(t1 > 12)
	  t2++;
	trk = rn/26;		/* zero based absolute track */
	t3 = t2 + 6*trk;	/* new logical sector number */
	sect = t3 % 26;		/* new zero based absolute sector */
	return ++sect;		/* one based absolute sector */
	}

/*	-------------------------------------------------------

	Name:		track(rn)
	Result:		physical track number
	Errors:		---
	Globals:	---
	Macros:		---
	Procedures:	---

	Action:		convert logical sector number to
			absolute track number. This is simply
			the modulo 26 process except that
			track 0 is not considered part of the
			logical sector space.

	------------------------------------------------------- */


track(rn)
	unsigned rn;
	{
	return rn/26 + 1;
	}


/* tacked on compare of filenames */


cmpare(x,y)
	char *x,*y;
	{
	int i,j,k;

	x += D_TITLE;
	y += D_TITLE;
	for( i = *x++, j = *y++; j & i; i--, j--, x++, y++ ) {
	  if( *x > *y )
	    return -1;
	  if( *x < *y )
	    return 1;
	  }
	if( i && ! j )
	  return 1;
	if( j && ! i )
	  return -1;
	return 0;
	}



