/*	-------------------------------------------------------
	*** Template for Procedure Heading ***

	Name:
	Result:
	Errors:
	Globals:
	Macros:
	Procedures:

	Action:

	------------------------------------------------------- */

/*	: : : : : : : : : : : : : : : : : : : : : : : : : : : :

	ucsd2cpm -- Transfer '.TEXT' files from a UCSD directory
		    formatted disk to a CP/M directory formatted
		    disk.

		1) header blocks removed
		2) linefeeds added after carriage returns
		3) indents converted to appropriate # of spaces
		4) filler nulls removed
		5) control-A's removed	(added 2/13/80 hrm)

	: : : : : : : : : : : : : : : : : : : : : : : : : : : : */





/*	: : : : : : : : : : : : : : : : : : : : : : : : : : : :

		Constants

	: : : : : : : : : : : : : : : : : : : : : : : : : : : : */


#define	DLE	0x10		/* Data Link Escape -- indent flag */
#define CR	0x0D		/* carriage return */
#define LF	0x0A		/* linefeed */
#define NULL	0		/* ascii null */
#define CPM_EOF	0X1A		/* CP/M ascii endfile mark */

#define	TRUE	1		/* booleans */
#define	FALSE	0

#define	SEL_DSK	14		/* bdos function number */
#define	SET_DMA	26		/* bdos function number */

#define	SET_TRK	9		/* bios index number */
#define	SET_SEC	10		/* bios index number */
#define	READ	12		/* bios index number */

#define	DUMMY	0		/* dummy parameter for bios routine */

#define	EOF_F	0xFFFF		/* end of file flag */
#define	D_ENT_SZ 26		/* UCSD directory entry size */
#define	D_TITLE	6		/* offset to entry title */
#define	UCSD_NAM_SZ 20		/* size of the name part of ucsd dir entry */
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
char ucsdbuf[BLOK_SIZE]; /* 1 block buffer for ucsd file */
char *ptr;		/* pointer to current byte in ucsd file buffer */




/*	: : : : : : : : : : : : : : : : : : : : : : : : : : : :

		Global structure type

	: : : : : : : : : : : : : : : : : : : : : : : : : : : : */

	struct buf {
	  int fd;
	  int nleft;
	  char *nextp;
	  char buff[SECT_SIZE];
	  };

/*	-------------------------------------------------------

	Name:		main(argc,argv)
	Result:		---
	Errors:		invocation syntax
	Globals:	lsn,lstlsn,nbytes,ptr,ucsdbuf
	Macros:		CPM_FILE,UCSD_FILE,UCSD_NAM_SZ

	Procedures:	puts(),exit(),force_upr(),printf()
			putchar(),close(),unlink(),strcpy()
			strcat(),getchar(),open(),copy()
			tolower()

	Action:		Call copy() to copy a '.TEXT' file
			from a UCSD formatted disk in drive B
			to a user specified file name in
			drive A

			Handle invocation errors
			Handle case of already existing
			destination  file

	------------------------------------------------------- */

#define CPM_FILE argv[1]
#define UCSD_FILE argv[2]

main(argc,argv)
	int argc;
	char *argv[];
	{
	int file_id;
	char ucsdname[UCSD_NAM_SZ];

	lsn = lstlsn = nbytes = 0;	/* init globals */
	ptr = ucsdbuf;

	if( argc != 3 )	{
	  puts("Proper invocation form is:\n\n");
	  puts("UCSD2CPM <cpm-file-name> <ucsd-file-name>\n");
	  puts("This copies B:<ucsd-file-name>.TEXT to A:<cpm-file-name>\n");
	  exit(1);
	  }
	force_upr(UCSD_FILE);	/* make <ucsd-file-name> upper case */
	if( (file_id = open(CPM_FILE,0)) >= 0 ) {
	  printf("%s already exists. Delete it ? ",CPM_FILE);
	  if( tolower(getchar()) != 'y' ) {
	    puts("\naborted\n");
	    exit(1);
	    }
	  putchar('\n');
	  close(file_id);
	  unlink(CPM_FILE);
	  }
	else
	  close(file_id);
	strcpy(ucsdname,UCSD_FILE);
	strcat(ucsdname,".TEXT");
	if(copy(ucsdname,CPM_FILE))
	  printf("\n\nno such file %s .. aborted\n",ucsdname);
	exit(0);
	}

/*	-------------------------------------------------------

	Name:		copy (ucsd_file,cpm_file)
	Result:		TRUE if error , FALSE if transfer ok

	Errors:		no such '.TEXT' file

	Globals:	struct buf,
	Macros:		TRUE,EOF_F,CR,DLE,NULL,CPM_EOF,FALSE

	Procedures:	find_file(),fcreat(),getbyte()
			putc(),fflush(),fclose()

	Action:		Find '.TEXT' file in UCSD directory
			on drive B
			Create user specified file on
			drive A
			copy file content from UCSD to CP/M
			car by char translating:
				Skip header block
				Ignore NULL's
				Add LF after CR
				Convert DLE <count> to
				appropriate number of spaces
			close output file

	------------------------------------------------------- */

copy(ucsd_file,cpm_file)
	char *ucsd_file,*cpm_file;
	{
	struct buf tofile;
	int c;

	if( ! find_file(ucsd_file) )		/* no such file */
	  return TRUE;
	fcreat(cpm_file,&tofile);
	while( (c = getbyte()) != EOF_F )
	  switch(c) {

	    case CR:	putc(CR,&tofile);	/* LF after CR */
			putc(LF,&tofile);
			break;

	    case DLE:	for( c = (getbyte() - 32); c; c-- )
			  putc(' ',&tofile);	/* fill spaces */
			break;

	    case '\1':				/* ignore ^A's */
	    case NULL:	break;			/* ignore nulls */

	    default:	putc(c,&tofile);	/* pass char unmodified */
			break;
	    }
	putc(CPM_EOF,&tofile);			/* send cp/m ascii endfile */
	fflush(&tofile);
	fclose(&tofile);
	return FALSE;				/* signal transfer ok */
	}

/*	-------------------------------------------------------

	Name:		getbyte()
	Result:		next sequential byte from UCSD '.TEXT' file
	Errors:
	Globals:	lsn,lstlsn,nbytes,ptr,ucsdbuf[]
	Macros:		EOF_F,BLOK_SIZE,SECT_PER_BLOK
	Procedures:	read_ucsd()

	Action:		read block at a time
			pass along byte at a time
			return EOF_F if end of UCSD file

	------------------------------------------------------- */


getbyte()
	{
	if( lsn > lstlsn)
	  return EOF_F;
	if( nbytes-- )
	  return *ptr++;
	read_ucsd(ucsdbuf,lsn,1);
	nbytes = (BLOK_SIZE-1);
	ptr = ucsdbuf;
	lsn += SECT_PER_BLOK;
	return *ptr++;
	}


/*	-------------------------------------------------------

	Name:		fclose(file)
	Result:		status of closing action
	Errors:		---
	Globals:	struct buf
	Macros:		---
	Procedures:	close()

	Action:		file open for buffered input
			or output is closed

	------------------------------------------------------- */


fclose(file)
	struct buf *file;
	{
	return close( file->fd );
	}

/*	-------------------------------------------------------

	Name:		find_file(ucsd_name)
	Result:		TRUE if found, FALSE if not found
	Errors:
	Globals:	lsn,lstlsn
	Macros:		D_ENT_SZ,SECT_PER_BLOK,D_TITLE
			TRUE,FALSE,UCSD_DIR_SZ

	Procedures:	read_ucsd()

	Action:		---

	------------------------------------------------------- */


find_file(ucsd_name)
	char *ucsd_name;
	{
	char ucsd_dir[UCSD_DIR_SZ];
	char *dir,*saved_dir,*name;
	int name_len;

	name = ucsd_name;
	read_ucsd(ucsd_dir,(2*SECT_PER_BLOK),4);
	dir = &ucsd_dir[D_TITLE + D_ENT_SZ];	/* skip title block */
	while ( dir < &ucsd_dir[UCSD_DIR_SZ] ) {
	  saved_dir = dir;
	  if( (name_len = *dir++) <=0 || name_len > 19 )
	    return FALSE;
	  while( *dir++ == *name++ ) {
	    if( --name_len )	/* continue comparison check */
	      ;
	    else {				/* entry found */
	      dir = saved_dir - D_TITLE;	/* point to alloc. info. */
	      lsn = *dir++;
	      lsn += *dir++ << 8;   /* lsn = starting logical block number */
	      lsn += 2;		    /* bypass header blocks */
	      lsn *= SECT_PER_BLOK; /* 1'st logical sector number */

	      lstlsn = *dir++;
	      lstlsn += *dir++ << 8;	/* lstlsn = ending logical block # */
	      lstlsn *= SECT_PER_BLOK;	/* lstlsn = last logical sector # */
	      return TRUE;		/* indicate file found */
	      }
	    }
	  name = ucsd_name;		/* reset comparison name pointer */
	  dir = saved_dir + D_ENT_SZ;	/* point at next entry name */
	  }
	return FALSE;				/* no such file */
	}

/*	-------------------------------------------------------

	Name:		read_ucsd()
	Result:		status of selecting drive A
	Errors:		sector read error
	Globals:	---
	Macros:		SEL_DSK,SET_DMA,SET_TRK,SET_SEC
			READ,DUMMY,SECT_SIZE
	Procedures:	bios(),bdos(),printf(),exit()

	Action:		Read count blocks from drive B
			into buf starting at UCSD logical
			record number rn

	------------------------------------------------------- */


read_ucsd(buf,rn,count)
	char *buf;
	unsigned rn;
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
	Result:		absolute sector number
	Errors:		---
	Globals:	---
	Macros:		---
	Procedures:	---

	Action:		convert logical record number
			to absolute sector

			maps logical records to physical sectors
			by selecting every second sector in order
			(accounting for the modulo 26 process)
			on the diskette except that at a track
			switchover point there is an additional
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
	Result:		absolute track number
	Errors:		---
	Globals:	---
	Macros:		---
	Procedures:	---

	Action:		convert logical sector number to
			absolute track This is simply the modulo
			26 process except that track 0 is not
			considered part of the logical
			sector space.

	------------------------------------------------------- */


track(rn)
	unsigned rn;
	{
	return rn/26 + 1;
	}

/*	-------------------------------------------------------

	Name:		index(str,sstr)
	Result:		position of string sstr in string str
			-1 if not a substring
	Errors:		---
	Globals:	---
	Macros:		---
	Procedures:	---

	Action:		---

	------------------------------------------------------- */


index(str,sstr)
	char *str,*sstr;
	{
	int first_match;

	if( *sstr == 0 )  /* null string is a substring of all strings */
	  return 0;
	for( first_match=0; *str != *sstr; first_match++)
	  if( *str == 0 )
	    return -1;
	  else
	    str++;
	while( *sstr )
	  if( *str++ != *sstr++ )
	    return -1;
	return first_match;
	}

/*	-------------------------------------------------------

	Name:		force_upr(string)
	Result:		---
	Errors:		---
	Globals:	---
	Macros:		---
	Procedures:	---

	Action:		force each char of string to upper case

	------------------------------------------------------- */

force_upr(string)
	char *string;
	{
	while(*string)
	  *string = *string++;
	return;
	}

/*	-------------------------------------------------------

	Name:		print(string,n)
	Result:		---
	Errors:		---
	Globals:	---
	Macros:		---
	Procedures:	putchar()

	Action:		print n chars to console starting
			at char pointer string

	------------------------------------------------------- */

print(string,n)
	char *string;
	int n;
	{
	while(n--)
	  putchar(*string++);
	return;
	}

