/*--------------------------------- stdio.h ---------------------------------*/

/*
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#ifndef _STDIO_H
#define _STDIO_H

#ifndef _SIZE_T
#define _SIZE_T
typedef unsigned long size_t;	/* type returned by sizeof operator */
#endif

#ifndef _VA_LIST
#define _VA_LIST
typedef char *va_list;
#endif

#define NULL (void *)0

#define EOF -1

typedef struct _iobuf {
    char *ptr;		    /* pointer to current position in I/O buffer */
    char *base;		    /* pointer to base of I/O buffer		 */
    int cnt;		    /* nbr of bytes currently in I/O buffer	 */
    int fd;		    /* file descriptor				 */
    int bufsize;	    /* size of user specified buffer		 */
    int save_cnt;	    /* count saved by ungetc()			 */
    short flags;	    /* bit flags				 */
    char ungch;		    /* single character buffer for ungetc()	 */
} FILE;

typedef	unsigned long fpos_t;

extern	FILE _iob[];

#ifndef FOPEN_MAX
#define FOPEN_MAX	3	/* nbr files which can be open at same time */
#endif

#define stdin		(&_iob[0])
#define stdout		(&_iob[1])
#define stderr		(&_iob[2])

#ifdef MULTI_CHANNEL
#undef FOPEN_MAX
#define FOPEN_MAX	7
#define stdin1		(&_iob[3])
#define stdout1		(&_iob[4])
#define stdin2		(&_iob[5])
#define stdout2		(&_iob[6])
#endif

#define BUFSIZ		1024	/* nbr bytes in I/O buffer (block size)	    */
#define FILENAME_MAX	256	/* maximum file name length		    */
#define L_tmpnam	15	/* size of char array needed hold a tmpnam  */
#define SEEK_CUR	1	/* fseek third argument - from current	    */
#define SEEK_END	2	/* fseek third argument - from end	    */
#define SEEK_SET	0	/* fseek third argument - from beginning    */
#define TMP_MAX		65535	/* nbr of unique file names from tmpnam()   */

/* the following bits are defined for FILE member flags */

#define _IOREAD		0x1	/* file open for reading		  */
#define _IOWRITE	0x2	/* file open for writing		  */
#define _IORW		0x4	/* file open for updating		  */
#define _IOFBF		0x8	/* stream is fully buffered		  */
#define _IOLBF		0x10	/* stream is line buffered		  */
#define _IONBF		0x20	/* stream is unbuffered			  */
#define _IOSTRING	0x40	/* _iob struct for strings (not I/O)	  */
#define _IOMYBUF	0x80	/* buf allocated by _fillbuf or _flushbuf */
#define _IOERR		0x100	/* I/O error on stream			  */
#define _IOEOF		0x200	/* end-of-file on stream		  */
#define _TMPFILE	0x400	/* file will be removed when closed	  */
#define _IOAPPEND	0x800	/* seek to EOF before every write	  */
#define _UNGCH		0x1000	/* last read operation was ungetc	  */

int remove(const char *filename);
int rename(const char *old, const char *new);
FILE *tmpfile(void);
char *tmpnam(char *str);
int fclose(FILE *stream);
int fflush(FILE *stream);
FILE *fopen(const char *filename, const char *mode);
FILE *freopen(const char *filename, const char *mode, FILE *stream);
void setbuf(FILE *stream, char *buf);
int setvbuf(FILE *stream, char *buf, int mode, size_t size);
int fprintf(FILE *stream, const char *format, ...);
int fscanf(FILE *stream, const char *format, ...);
int printf(const char *format, ...);
int scanf(const char *format, ...);
int sprintf(char *str, const char *format, ...);
int sscanf(char *str, const char *format, ...);
int vfprintf(FILE *stream, const char *format, va_list arg);
int vprintf(const char *format, va_list arg);
int vsprintf(char *str, const char *format, va_list arg);
int fgetc(FILE *stream);
char *fgets(char *str, int count, FILE *stream);
int fputc(int c, FILE *stream);
int fputs(const char *str, FILE *stream);
int getchar(void);
char *gets(char *buf);
int putc(int c, FILE *stream);
int putchar(int c);
int puts(const char *str);
int ungetc(int c, FILE *stream);
size_t fread(void *ptr, size_t size, size_t nbr_mbrs, FILE *stream);
size_t fwrite(const void *ptr, size_t size, size_t nbr_mbrs, FILE *stream);
int fgetpos(FILE *stream, fpos_t *pos);
int fseek(FILE *stream, long offset, int whence);
int fsetpos(FILE *stream, const fpos_t *pos);
long ftell(FILE *stream);
void rewind(FILE *stream);
void clearerr(FILE *stream);
int feof(FILE *stream);
int ferror(FILE *stream);
void perror(const char *str);
int fileno(FILE *stream);
int _fillbuf(FILE *stream);
int _flushbuf(unsigned char c, FILE *stream);
void putchx(long c);

#define getc(f)	    (((f)->cnt-- > 0) ? \
		    ((int)((unsigned char)(*(f)->ptr++))) : _fillbuf(f))

/*
 * to get the function version of one or more of the following macros,
 * #undef the macro name after including stdio.h
 */

#define getchar()   getc(stdin)
#define putc(c,f)   (((f)->cnt-- > 0) ? \
		    (int)(*(f)->ptr++ = (unsigned char)(c)) : \
		    _flushbuf((unsigned char)(c),f))
#define putchar(c)  putc(c,stdout)
#define clearerr(f) ((f)->flags &= ~_IOERR)
#define feof(f)	    ((f)->flags & _IOEOF)
#define ferror(f)   ((f)->flags & _IOERR)
#define fileno(f)   ((f)->fd)

#endif
