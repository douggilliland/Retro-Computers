#define _BUFSIZE  512
#define _NFILE    12

typedef struct _iobuf {
  char *_ptr;    /* next character position */
  int  _cnt;     /* number of characters left */
  char *_base;   /* location of buffer */
  int  _flag;    /* mode of file access */
  int  _fd;      /* file descriptor */
} FILE;
extern FILE _iob[_NFILE];

#define stdin     (&_iob[0])
#define stdout    (&_iob[1])
#define stderr    (&_iob[2])

#define _READ     01   /* file open for reading */
#define _WRITE    02   /* file open for writing */
#define _UNBUF    04   /* file is unbuffered */
#define _BIGBUF   010  /* big buffer allocated */
#define _EOF      020  /* EOF has occurred on file */
#define _ERR      040  /* error has occurred on file */
#define NULL      0
#define EOF       (-1)

#define getc(p)   (--(p)->_cnt >= 0 \
             ? *(p)->_ptr++ & 0377 : _fillbuf(p))
#define getchar() getc(stdin)

#define putc(x,p) (--(p)->_cnt >= 0 \
             ? *(p)->_ptr++ = (x) : _flushbuf((x),p))
#define putchar(x) putc(x,stdout)

