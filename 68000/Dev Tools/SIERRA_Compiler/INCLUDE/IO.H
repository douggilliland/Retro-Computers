/*----------------------------------- io.h ----------------------------------*/

/*
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

/* file permissions - used for chmod() and creat() */

#define READ_P		0x80
#define WRITE_P		0x100

/* open modes - used for open() and chmod() */

#define O_RDONLY	0x0
#define O_WRONLY	0x1
#define O_RDWR		0x2
#define O_APPEND	0x8
#define O_CREAT		0x100
#define O_TRUNC		0x200
#define O_EXCL		0x400
#define O_TEXT		0x4000
#define O_BINARY	0x8000

/* serial i/o modes */

#define RAW		0x8
#define CBREAK		0x10
#define COOKED		0x20
#define NOCBREAK	0x200

/* operating system functions referenced but not supplied by Sierra C */

int chmod(const char *filename, int permission);
int close(int fd);
int creat(const char *filename, int permission);
long lseek(int fd, long offset, int whence);
int open(const char *filename, int oflag, ...);
int read(int fd, void *buf, unsigned int count);
int write(int fd, void *buf, unsigned int count);

/* functions supplied by Sierra C, to be replaced by functions supplied */
/* by operating system							*/ 

int ioctl(int fd, int request, void *arg);
void *sbrk(unsigned long size);

