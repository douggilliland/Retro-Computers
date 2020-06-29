#include <stdio.h>
#include <sgtty.h>
#include <ctype.h>
#include "boolean.h"
#include "termcap.h"

#define NIL 0			/* Null pointer */
#define DIRSIZE 16		/* Terminal Directory Size */
#define NUMCAP 30		/* Number of capabilities */
#define DATABYTES 4		/* Number of bytes before pointers */
#define STDOUT 1		/* Standard output descriptor */
#define STDIN 0		/* Standard input descriptor */
#define DATA_READY 0x80	/* ttyget "data ready" bit */
#define QUEUE_SIZE 10		/* Input queue size */

static struct ttycap cap;	/* Terminal capabilities */
static int nrows;		/* Number of rows on screen */
static int ncols;		/* Number of columns on screen */
 int last_row;			/* Last row number (0 origin) */
 int last_column;		/* Last column number (0 origin) */
static int delay;		/* Screen settle time in seconds */
static int cu_size;		/* Size of cursor up string */
static int cd_size;		/* Size of cursor down string */
static int cl_size;		/* Size of cursor left string */
static int cr_size;		/* Size of cursor right string */
static int hm_size;		/* Size of home up string */
static int row;		/* Current row number (0 origin) */
static int column;		/* Current column number (0 origin) */
static char ique[QUEUE_SIZE];	/* Input character queue */
static int  q_in;		/* queue "in" pointer */
static int  q_out;		/* queue "out" pointer */

blank_line()		/* Blank from current position */

{
	int i;

	if (cap.c_blank != NULL) puts(cap.c_blank,stdout);
	else {
		i = column;
		while (column <= last_column) c_output(' ');
		move_to(i,row);
	}
}

static int check_cursor(s,v)	/* Check for cursor string */
char *s;	/* Cursor string */
int v;		/* Value (< 0) to be returned if match
		   0 returned if no match
		   1 returned if lead-in match */
{
	int value;

	if ( (value=comp_str(s))==0 ) return 0;
	if ( value < 0 ) return 1;
	q_out = (q_out+value >= QUEUE_SIZE) ?
			q_out+value-QUEUE_SIZE: q_out+value;
	return v;
}

clear_screen()		/* Clear screen */

{
	fputs(cap.c_clear,stdout);
	if (delay != 0) sleep(delay);
	row = column = 0;
}

command_line(n)	/* Move to column n in command line */
int n;

{
	last_row--;
	move_to(n,last_row);
	last_row++;
}

static int comp_str(s)		/* Compare queue to string */
char *s;	/* Object string */

/*	Returns:
		 0 if no match
		-1 if partial match (lead-in characters)
		>0 if exact match and value is string length
*/

{
	int i, j;	/* string pointers */

	if ( s==NULL || (j=q_out)==q_in ) return 0;
	i = 0;
	while (*s+i==ique[j]) {
		i++;
		if (*s+i == NULL) return i;
		j = (j<QUEUE_SIZE-1)? j++ : 0;
		if (j==q_in) return -1;
	}
	return 0;
}

c_output(c)		/* Output character at current position */
char c;

{
	if (column != last_column) {
		putchar(c);
		column++;
	}
}

home_up()		/* Home cursor */

{
	fputs(cap.c_home,stdout);
	row = column = 0;
}

int input(wait,echo)		/* Input character */
BOOLEAN wait;		/* True if should wait for character */
BOOLEAN echo;		/* True if should echo character */

/*	Value is the integer cast of the character.
	A value less than zero indicates that a cursor positioning
	key or function key was typed.  The corresponding values
	are given in "termcap.h".

	If the character typed is a printing character, the
	cursor position is moved right one position unless
	it is already in the rightmost column.
	The DEL character is not considered a printing character.

	If "wait" is FALSE and no data is available, NO_DATA
	is returned.
*/

{
	BOOLEAN possible();		/* TRUE if possible sequence */
	struct sgttyb ttbuf;
	char ch;
	int special;

	while (TRUE) {
		special=possible();
		if (special < 0) return special;
		if ( special==0 && q_in!=q_out ) {
			ch = ique[q_out++];
			if (q_out == QUEUE_SIZE) q_out=0;
			if (echo && isprint(ch)) {
				putchar(ch);
				if (column<last_column) column++;
			}
			return (int)ch;
		} else if (!wait) {
			gtty(STDIN,&ttbuf);
			if (ttbuf.sg_speed & DATA_READY != 0) 
				return NO_DATA;
		} else {
			ique[q_in++] = getchar();
			if (q_in == QUEUE_SIZE) q_in = 0;
		}
	}
}

move_down(n)		/* Move down n rows */
int n;

{
	while (n-- && row < last_row) {
		fputs(cap.c_down,stdout);
		row++;
	}
}

move_left(n)		/* Move left n columns */
int n;

{
	while (n-- && column != 0) {
		fputs(cap.c_left,stdout);
		column--;
	}
}

move_to(x,y)		/* Move cursor to specified position */
int	x;	/* column */
int	y;	/* row */

{
	int	direct;
	int	from_home;
	int	from_start;

	direct = (x>column? (x-column)*cr_size: (column-x)*cl_size) +
		(y>row? (y-row)*cd_size: (row-y)*cu_size);
	from_home = hm_size+x*cr_size+y*cl_size;
	from_start = 1 + x*cr_size +
		(y>row? (y-row)*cd_size: (row-y)*cu_size);
	if (direct <= from_home && direct <= from_start ) {
		if (y > row) move_down(y-row);
		else move_up(row-y);
		if (x > column) move_right(x-column);
		else move_left(column-x);
	}
	else if (from_home < from_start) {
		home_up();
		move_down(y);
		move_right(x);
	}
	else {
		fputs("\r",stdout);
		column = 0;
		if (y > row) move_down(y-row);
		else move_up(y-row);
		move_right(x);
	}
}

move_right(n)		/* Move right n columns */
int n;

{
	while (n-- && column < last_column) {
		fputs(cap.c_right,stdout);
		column++;
	}
}

move_up(n)		/* Move up n rows */
int n;

{
	while (n-- && row != 0) {
		fputs(cap.c_up,stdout);
		row--;
	}
}

static int possible()		/* Return possible cursor sequence */

/*	Response:
		0 if not sequence or lead-in to sequence
		> 0 if a lead-in to a sequence
		< 0 if a sequence, value should be returned to user
*/

{
	int value;

	if((value=check_cursor(cap.c_hmkey,HOME_KEY))!=0 ||
	   (value=check_cursor(cap.c_uarrow,UP_KEY))!=0 ||
	   (value=check_cursor(cap.c_darrow,DOWN_KEY))!=0 ||
	   (value=check_cursor(cap.c_larrow,LEFT_KEY))!=0 ||
	   (value=check_cursor(cap.c_rarrow,RIGHT_KEY))!=0 ||
	   (value=check_cursor(cap.c_fn0,KEY(0)))!=0 ||
	   (value=check_cursor(cap.c_fn1,KEY(1)))!=0 ||
	   (value=check_cursor(cap.c_fn2,KEY(2)))!=0 ||
	   (value=check_cursor(cap.c_fn3,KEY(3)))!=0 ||
	   (value=check_cursor(cap.c_fn4,KEY(4)))!=0 ||
	   (value=check_cursor(cap.c_fn5,KEY(5)))!=0 ||
	   (value=check_cursor(cap.c_fn6,KEY(6)))!=0 ||
	   (value=check_cursor(cap.c_fn7,KEY(7)))!=0 ||
	   (value=check_cursor(cap.c_fn8,KEY(8)))!=0 ||
	   (value=check_cursor(cap.c_fn9,KEY(9)))!=0) return value;
	return 0;
}

s_output(s)		/* Output string at current position */
char *s;

{
	int i;

	for (i=0; *s+i != NULL; i++) c_output(*s+i);
}

BOOLEAN termcap(cp)	/* Get terminal capabilities */
struct ttycap *cp;

{
	char	**cap_ptr;
	int	i;
	long	j;
	int	fd;
	int	direct[DIRSIZE];
	long	lseek();
	int	open(), read();

	if ( (fd=open("/etc/termcap",0)) == -1) return FALSE;
	if (
	 (i=read(fd,(char *)direct,sizeof(int)*DIRSIZE)) == -1 ||
	 i != sizeof(int)*DIRSIZE ||
	 (i=direct[termnumb(0)]) == 0 ||
	 (j=lseek(fd, (long)i, 0)) == -1L ||
	 (i=read(fd,(char *)cp,sizeof(struct ttycap))) == -1 ||
	 i != sizeof(struct ttycap)
	) {
		close(fd);
		return FALSE;
	}
	close(fd);
	cap_ptr = (char **)( (char *)cp+DATABYTES );
	for (i=NUMCAP; i--; cap_ptr++)
		if (*cap_ptr != NIL) *cap_ptr += (unsigned)cp;
	return TRUE;
}

BOOLEAN terminit()	/* Initialize terminal */

{
	if ( ! termcap(&cap) ) return FALSE;
	nrows = (int)cap.c_rows;
	ncols = (int)cap.c_cols;
	last_row = nrows-2;
	last_column = ncols-1;
	delay = (int)cap.c_wait;
	cu_size = strlen(cap.c_up);
	cd_size = strlen(cap.c_down);
	cl_size = strlen(cap.c_left);
	cr_size = strlen(cap.c_right);
	hm_size = strlen(cap.c_home);
	setbuf(stdout,0);
	if (cap.c_init != NIL) fputs(cap.c_init,stdout);
	clear_screen();
	return TRUE;
}
