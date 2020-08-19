/*
 *			  RAM-DISK FILE SYSTEM
 *
 *	  Copyright 1992 by Sierra Systems.  All rights reserved.
 */

#include <io.h>
#include <stdio.h>
#include <string.h> 
#include <stdlib.h>

/* file_descriptor_table is the address of the file system file descriptor */
/* table and it must be set by the user application that initializes the   */
/* file system.	 The first 4 bytes of the file descriptor table must also  */
/* be set to zero by the same initialization routine.			   */

extern char *file_descriptor_table;

typedef struct file_info {
    char *beg;
    char *end;
    char *cur;
    char *max;
    char name[40];
} FILE_INFO;

/*
 *   File Descriptor Memory Map
 *  +--------------------------+ <-- file_descriptor_table
 *  |	      4 bytes	       | <-- max_fd value
 *  +--------------------------+ <-- file_descriptor_table + 4
 *  |			       |
 *  |	     56 bytes	       | <-- FILE_INFO 1
 *  |			       |
 *  +--------------------------+
 *  |			       |
 *  |	     56 bytes	       | <-- FILE_INFO 2
 *  |			       |
 *  +- - - - - - - - - - - - - +
 *		 :
 *  +- - - - - - - - - - - - - +
 *  |			       |
 *  |	     56 bytes	       | <-- FILE_INFO N
 *  |			       |
 *  +--------------------------+
 */

/* max_fd is the value of the next new file descriptor.	 If there are no   */
/* empty slots because of a deleted file, a newly opened file is assigned  */
/* max_fd and max_fd is incremented.					   */

#define max_fd	(*((long *)file_descriptor_table))

#define fi_ptr1	((FILE_INFO *)(file_descriptor_table + 4))

/* name of standard i/o device						   */

char *stdio_name = "dev_tty";

/* end_of_file marker -- any string that will not match the contents of	   */
/* any text or binary file						   */

char *end_of_file = "EnDoFfIlE";

/*------------------------------- open() ------------------------------------*/

/*
 * open opens a file or creates it if it does not exist.  The flags argument
 * is ignored.
 */

int open(const char *name, int flags, ...)
{
    register FILE_INFO *fi_ptr = fi_ptr1;
    int fd;
    int fd1;
    int fd_found;
    long length;
    char buf[50];

    fd = -1;
    fd_found = -1;

    /* check to see if the file already exists */

    for( fd1 = 0; fd1 < max_fd; fd1++ ) {
	if( !strcmp(name, fi_ptr[fd1].name) ) {	/* file exists		 */
	    fd_found = fd1;
	    if( fi_ptr[fd1].cur == 0 ) {    /* file was closed		 */
		fd = fd1;		    /* file descriptor available */
		break;
	    }
	}
	else if( fi_ptr[fd1].name == '\0' ) /* file was deleted		 */
	    fd = fd1;			    /* file descriptor available */
    }

    /* no empty slots, get next available file descriptor */

    if( fd < 0 )
	fd = max_fd++;

    /* fd is now the file descriptor for the new file */

    strcpy(fi_ptr[fd].name, name);

    if( !strcmp(stdio_name, name) ) {
	fi_ptr[fd].cur = (void *)-1;
	return(fd);
    }
    
    if( fd_found >= 0 ) {		/* file already in file system	*/
	if( fd_found != fd ) {		/* copy information if new fd	*/
	    fi_ptr[fd].beg = fi_ptr[fd_found].beg;
	    fi_ptr[fd].end = fi_ptr[fd_found].end;
	    fi_ptr[fd].max = fi_ptr[fd_found].max; 
	}
    }
    else {

	/* Request file information -- note that it is necessary that	*/
	/* stdin and stdout be opened before any file system files are	*/
	/* opened to allow printf() to operate.

	/* prompt for file address and size (if not already loaded)	*/

	printf("Enter base address of file %s: ", name);
	fgets(buf, 48, stdin);
	fi_ptr[fd].beg = (void *)(long)strtoul(buf, NULL, 0);
	printf("Enter maximum size of file %s: "
	"(<cr> if already loaded) ", name);
	fgets(buf, 48, stdin);
	length = strtoul(buf, NULL, 0);

	fi_ptr[fd].end = fi_ptr[fd].beg;

	/* if length entered is 0, file is already downloadead, look */
	/* for end_of_file marker to determine length		     */

	if( length == 0 ) {
	    length = strlen(end_of_file);
	    while( (*fi_ptr[fd].end != *end_of_file) ||
	    (*(fi_ptr[fd].end + 1) != *(end_of_file + 1)) ||
	    strncmp(fi_ptr[fd].end, end_of_file, length) )
		fi_ptr[fd].end++;
	    fi_ptr[fd].end--;
	    length = fi_ptr[fd].end - fi_ptr[fd].beg + 1;
	}
	else
	    fi_ptr[fd].end = fi_ptr[fd].beg - 1;
	fi_ptr[fd].max = fi_ptr[fd].beg + length - 1; 
    }
    fi_ptr[fd].cur = fi_ptr[fd].beg;
    return(fd);
}

/*---------------------------------- creat() --------------------------------*/

int creat(const char *name, int perms)
{
    return(open(name, O_CREAT));
}

/*---------------------------------- unlink() -------------------------------*/

int unlink(const char *name) 
{
    register FILE_INFO *fi_ptr = fi_ptr1;
    int fd1;

    for( fd1 = 0; fd1 < max_fd; fd1++ ) {
	if( !strcmp(name, fi_ptr[fd1].name) ) {
	    if( fd1 == max_fd )
		max_fd--;		/* last file in the file system */
	    fi_ptr[fd1].name[0] = '\0';
	    fi_ptr[fd1].cur = 0;
	    break;
	}
    }
    return(0);
}
	    
/*---------------------------------- close() --------------------------------*/

int close(int fd) 
{
    register FILE_INFO *fi_ptr = fi_ptr1;

    /* no such fd or file already closed */

    if( (fd > max_fd) || (fi_ptr[fd].cur == 0) )
	return(-1);

    fi_ptr[fd].cur = 0;

    /* add an end-of-file marker if not stdio and not at end-of-file */
	
    if( strcmp(fi_ptr[fd].name, stdio_name) &&
    strncmp(fi_ptr[fd].end, end_of_file, strlen(end_of_file)) )
	strcpy((fi_ptr[fd].end + 1), end_of_file);

    return(0);
}

/*---------------------------------- lseek() --------------------------------*/

long lseek(int fd, long offset, int origin)
{
    register FILE_INFO *fi_ptr = fi_ptr1;
    char *tmp;

    /* no such fd or file already closed */

    if( (fd > max_fd) || (fi_ptr[fd].cur == 0) )
	return(-1);

    /* save the current pointer -- used in case of an error */

    tmp = fi_ptr[fd].cur;

    switch( origin ) {
    case 0:
	fi_ptr[fd].cur = fi_ptr[fd].beg + offset;
	break;
    case 1:
	fi_ptr[fd].cur += offset;
	break;
    case 2:
	fi_ptr[fd].cur = fi_ptr[fd].end + offset;
    }

    /* out of range error */

    if( (fi_ptr[fd].cur < fi_ptr[fd].beg) ||
    (fi_ptr[fd].cur > fi_ptr[fd].max) ) {
	fi_ptr[fd].cur = tmp;		    /* restore value */
	return(-1);
    }
    if( fi_ptr[fd].cur > fi_ptr[fd].end )
	fi_ptr[fd].end = fi_ptr[fd].cur - 1;
    return(fi_ptr[fd].cur - fi_ptr[fd].beg);
}

void putchx(long);

/*---------------------------------- read() ---------------------------------*/

int read(int fd, void *buf, unsigned int count)
{
    register FILE_INFO *fi_ptr = fi_ptr1;
    register char *ptr;
    register int c;
    static short end_of_file;
    extern int _raw_mode;

    /* no such fd or file already closed */

    if( (fd > max_fd) || (fi_ptr[fd].cur == 0) )
	return(-1);

    /* if it is a terminal input, just call getchx() */

    if( !strcmp(stdio_name, fi_ptr[fd].name) ) {
	if( end_of_file ) {
	    end_of_file = 0;
	    return(0);
	}
	for( ptr = buf; count > 0; ) {
	    c = getchx();
	    if( !_raw_mode ) {
		c &= 0x7f;
		switch( c ) {
		case '\r':			/* carriage-return */
		    putchx(c);
		    *ptr++ = '\n';
		    putchx('\n');
		    goto end_line;
		case 0x4:			/* control-d */
		    putchx('^');
		    putchx('D');
		    end_of_file = (ptr != buf);
		    goto end_line;
		case 0x3:			/* control-c */
		    exit(1);
		case '\b':			/* erase */
		    if( ptr > buf ) {
			putchx('\b');
			putchx(' ');
			putchx('\b');
			*--ptr = '\0';
			count++;
		    }
		    break;
		case 0x18:			/* kill, control-x */
		    while( ptr > buf ) {
			putchx('\b');
			putchx(' ');
			putchx('\b');
			*--ptr = '\0';
			count++;
		    }
		    break;
		default:
		    putchx(c);
		    *ptr++ = c;
		    count--;
		    break;
		}
	    }
	    else
		*ptr++ = c;
	}
    end_line:
	return(ptr - (char *)buf);
    }

    if( fi_ptr[fd].cur > fi_ptr[fd].end )
	return 0; 
    if( count > (fi_ptr[fd].end - fi_ptr[fd].cur + 1) )
	count = fi_ptr[fd].end - fi_ptr[fd].cur + 1;
    memcpy(buf, fi_ptr[fd].cur, count);
    fi_ptr[fd].cur += count;
    return(count);
}

/*-------------------------------- write() ----------------------------------*/

int write(int fd, void *buf, unsigned int count)
{
    register FILE_INFO *fi_ptr = fi_ptr1;
    register char *ptr;

    /* no such fd or file already closed */

    if( (fd > max_fd) || (fi_ptr[fd].cur == 0) )
	return(-1);

    /* if it is a terminal input, just call putchx() */

    if( !strcmp(stdio_name, fi_ptr[fd].name) ) {
	for( ptr = buf; ptr < ((char *)buf + count); ptr++ ) {
	    putchx(*ptr);
	    if( *ptr == '\n' )
		putchx('\r');
	}
	return(count);
    }

    /* do not allow writing beyond the maximum allowed size */

    if( count > (fi_ptr[fd].max - fi_ptr[fd].cur + 1) )
	count = fi_ptr[fd].max - fi_ptr[fd].cur + 1;

    memcpy(fi_ptr[fd].cur, buf, count);
    fi_ptr[fd].cur += count;
    if( fi_ptr[fd].cur > fi_ptr[fd].end )
	fi_ptr[fd].end = fi_ptr[fd].cur - 1;
    return(count);
}
