

#include "bdscio.h"

/*
	STDLIB1.C -- for BDS C v1.41 -- 10/14/80

	The files STDLIB*.C contain source for all DEFF.CRL
	functions which are written in C; Any functions which
	appear in DEFF.CRL but have no corresponding source
	were written in machine code and converted to .CRL
	format (as described in the User's Guide.)

	All functions written by Leor Zolman....who is
	soley responsible for their kludginess.

	Functions appearing in this file:

	fopen		getc		ungetc		getw
	fcreat		putc		putw
	fflush		fclose
	atoi
	strcat		strcmp		strcpy		strlen
	isalpha		isupper		islower		isdigit
	isspace		toupper		tolower
	qsort
	initw		initb		getval
	alloc *		free *
	abs		max		min

	* -- Compilation of alloc and free must be explicitly enabled by
	     swapping the commenting of the ALLOC_ON and ALLOC_OFF definitions
	     in BDSCIO.H.

*/


/*
	Buffered I/O for C:
*/

int fopen(filename,iobuf)
struct _buf *iobuf;
char *filename;
{
	if ((iobuf -> _fd = open(filename,0))<0) return ERROR;
	iobuf -> _nleft = 0;
	return iobuf -> _fd;
}


int getc(iobuf)
struct _buf *iobuf;
{
	int nsecs;
	if (iobuf == 0) return getchar();
	if (iobuf == 3) return bdos(3);
	if (iobuf -> _nleft--) return *iobuf -> _nextp++;
	if ((nsecs = read(iobuf -> _fd, iobuf -> _buff, NSECTS)) <= 0)
				return ERROR;
	iobuf -> _nleft = (NSECTS * SECSIZ - 1);
	iobuf -> _nextp = iobuf -> _buff;
	return *iobuf->_nextp++;
}

/*
	Buffered "unget" a character routine. Only ONE
	byte may be "ungotten" between consecutive "getc" calls.
*/

int ungetc(c, iobuf)
struct _buf *iobuf;
char c;
{
	if (iobuf == 0) return ungetch(c);
	if (iobuf -> _nleft == (NSECTS * SECSIZ)) return ERROR;
	*--iobuf -> _nextp = c;
	iobuf -> _nleft++;
	return OK;
}
	

int getw(iobuf)
struct _buf *iobuf;
{
	int a,b;	
	if (((a=getc(iobuf)) >= 0) && ((b= getc(iobuf)) >=0))
			return 256*b+a;
	return ERROR;
}


int fcreat(name,iobuf)
char *name;
struct _buf *iobuf;
{
	unlink(name);
	if ((iobuf -> _fd = creat(name)) < 0 ) return ERROR;
	iobuf -> _nextp = iobuf -> _buff;
	iobuf -> _nleft = (NSECTS * SECSIZ);
	return iobuf -> _fd;
}


int putc(c,iobuf)
char c;
struct _buf *iobuf;
{
	if (iobuf == 1) return putchar(c);
	if (iobuf == 2) return (bdos(5,c));
	if (iobuf == 3) return (bdos(4,c));
	if (iobuf -> _nleft--) return *iobuf -> _nextp++ = c;
	if ((write(iobuf -> _fd, iobuf -> _buff, NSECTS)) != NSECTS)
			return ERROR;
	iobuf -> _nleft = (NSECTS * SECSIZ - 1);
	iobuf -> _nextp = iobuf -> _buff;
	return *iobuf -> _nextp++ = c;
}


int putw(w,iobuf)
unsigned w;
struct _buf *iobuf;
{
	if ((putc(w%256,iobuf) >=0 ) && (putc(w / 256,iobuf) >= 0))
				return w;
	return ERROR;
}


int fflush(iobuf)
struct _buf *iobuf;
{
	int i;
	if (iobuf < 4) return OK;
	if (iobuf -> _nleft == (NSECTS * SECSIZ)) return OK;

	i = NSECTS - iobuf->_nleft / SECSIZ;
	if (write(iobuf -> _fd, iobuf -> _buff, i) != i)
			return ERROR;
	i = (i-1) * SECSIZ;

	if (iobuf -> _nleft) {
		movmem(iobuf->_buff + i, iobuf->_buff, SECSIZ);
		iobuf -> _nleft += i;
		iobuf -> _nextp -= i;
		return seek(iobuf->_fd, -1, 1);
	 }

	iobuf -> _nleft = (NSECTS * SECSIZ);
	iobuf -> _nextp = iobuf -> _buff;
	return OK;
}

int fclose(iobuf)
struct _buf *iobuf;
{
	return close(iobuf -> _fd);
}



/*
	Some string functions
*/


int atoi(n)
char *n;
{
	int val; 
	char c;
	int sign;
	val=0;
	sign=1;
	while ((c = *n) == '\t' || c== ' ') ++n;
	if (c== '-') {sign = -1; n++;}
	while (  isdigit(c = *n++)) val = val * 10 + c - '0';
	return sign*val;
}


char *strcat(s1,s2)
char *s1, *s2;
{
	char *temp; temp=s1;
	while(*s1) s1++;
	do *s1++ = *s2; while (*s2++);
	return temp;
}


int strcmp(s,t)
char s[], t[];
{
	int i;
	i = 0;
	while (s[i] == t[i])
		if (s[i++] == '\0')
			return 0;
	return s[i] - t[i];
}


char *strcpy(s1,s2)
char *s1, *s2;
{
	char *temp; temp=s1;
	while (*s1++ = *s2++);
	return temp;
}


int strlen(s)
char *s;
{
	int len;
	len=0;
	while (*s++) len++;
	return len;
}


/*
	Some character diddling functions
*/

int isalpha(c)
char c;
{
	return isupper(c) || islower(c);
}


int isupper(c)
char c;
{
	return c>='A' && c<='Z';
}


int islower(c)
char c;
{
	return c>='a' && c<='z';
}


int isdigit(c)
char c;
{
	return c>='0' && c<='9';
}


int isspace(c)
char c;
{
	return c==' ' || c=='\t' || c=='\n';
}


char toupper(c)
char c;
{
	return islower(c) ? c-32 : c;
}


char tolower(c)
char c;
{
	return isupper(c) ? c+32 : c;
}




/*
	Other stuff...
*/


/*
	This is the new qsort routine, utilizing the shell sort
	technique given in the Software Tools book (by Kernighan 
	& Plauger.)

	NOTE: this "qsort" function is different from the "qsort" given
	in some old releases (pre 1.32) -- here, the items are sorted
	in ASCENDING order. The old "qsort" sorted stuff in DESCENDING
	order, and was in part responsible for the atrocious play of
	the "Othello" program (it always made the WORST moves it could
	find...) 
*/

qsort(base, nel, width, compar)
char *base; int (*compar)();
{	int gap,ngap, i, j;
	int jd, t1, t2;
	t1 = nel * width;
	for (ngap = nel / 2; ngap > 0; ngap /= 2) {
	   gap = ngap * width;
	   t2 = gap + width;
	   jd = base + gap;
	   for (i = t2; i <= t1; i += width)
	      for (j =  i - t2; j >= 0; j -= gap) {
		if ((*compar)(base+j, jd+j) <=0) break;
			 _swp(width, base+j, jd+j);
	      }
	}
}

_swp(w,a,b)
char *a,*b;
int w;
{
	char tmp;
	while(w--) {tmp=*a; *a++=*b; *b++=tmp;}
}




/*
 	Initialization functions
*/


initw(var,string)
int *var;
char *string;
{
	int n;
	while ((n = getval(&string)) != -32760) *var++ = n;
}

initb(var,string)
char *var, *string;
{
	int n;
	while ((n = getval(&string)) != -32760) *var++ = n;
}

int getval(strptr)
char **strptr;
{
	int n;
	if (!**strptr) return -32760;
	n = atoi(*strptr);
	while (**strptr && *(*strptr)++ != ',');
	return n;
}



/*
	Storage allocation routines, taken from chapter 8 of K&R, but
	simplified to ignore the storage allignment problem and not
	bother with the "morecore" hack (a call to "sbrk" under CP/M is
	a relatively CHEAP operation, and can be done on every call to
	"alloc" without degrading efficiency.)

	Note that compilation of "alloc" and "free" is disabled until
	the "#define ALLOC_ON 1" statement is un-commented in the header
	file ("BDSCIO.H"). This is done so that the external storage
	required by alloc and free isn't declared unless the user
	actually needs the alloc and free functions. As soon as BDS C
	gets static variables, this kludge will go away.
*/


#ifdef ALLOC_ON		/* Compilation of alloc and free is enabled only
			   when the ALLOC_ON symbol is #defined in BDSCIO.H */

char *alloc(nbytes)
unsigned nbytes;
{
	struct _header *p, *q, *cp;
	int nunits; 
	nunits = 1 + (nbytes + (sizeof (_base) - 1)) / sizeof (_base);
	if ((q = _allocp) == NULL) {
		_base._ptr = _allocp = q = &_base;
		_base._size = 0;
	 }
	for (p = q -> _ptr; ; q = p, p = p -> _ptr) {
		if (p -> _size >= nunits) {
			if (p -> _size == nunits)
				q -> _ptr = p -> _ptr;
			else {
				p -> _size -= nunits;
				p += p -> _size;
				p -> _size = nunits;
			 }
			_allocp = q;
			return p + 1;
		 }
		if (p == _allocp) {
			if ((cp = sbrk(nunits * sizeof (_base))) == ERROR)
				return NULL;
			cp -> _size = nunits; 
			free(cp+1);	/* remember: pointer arithmetic! */
			p = _allocp;
		}
	 }
}


free(ap)
struct _header *ap;
{
	struct _header *p, *q;

	p = ap - 1;	/* No need for the cast when "ap" is a struct ptr */

	for (q = _allocp; !(p > q && p < q -> _ptr); q = q -> _ptr)
		if (q >= q -> _ptr && (p > q || p < q -> _ptr))
			break;
	if (p + p -> _size == q -> _ptr) {
		p -> _size += q -> _ptr -> _size;
		p -> _ptr = q -> _ptr -> _ptr;
	 }
	else p -> _ptr = q -> _ptr;

	if (q + q -> _size == p) {
		q -> _size += p -> _size;
		q -> _ptr = p -> _ptr;
	 }
	else q -> _ptr = p;

	_allocp = q;
}

#endif



/*
	Now some really hairy functions to wrap things up:
*/

int abs(n)
{
	return (n<0) ? -n : n;
}

int max(a,b)
{
	return (a > b) ? a : b;
}

int min(a,b)
{
	return (a <= b) ? a : b;
}

