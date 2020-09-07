#include "uart.h"
#include "spi.h"
#include "board.h"
#include "timer.h"
#include "fat.h"
#include "rafile.h"

#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <fcntl.h>

#include "malloc.h"
#include "fileio.h"

#include "small_printf.h"


#define SYS_ftruncate 3000
#define SYS_isatty 3001

/* Set to 1 if we are running on hardware. The config instruction is 
 * always emulated on the simulator. The emulation code pokes this 
 * variable to 1.
 */
extern int _hardware;

/* _cpu_config==0 => Abel
 * _cpu_config==1 => Zeta
 * _cpu_config==2 => Phi
 */
extern int _cpu_config;

extern int main(int argc, char **argv);

static char *args[]={"dummy.exe"};

// File table

#define MAX_FILES 8
static RAFile *Files[MAX_FILES];
#define File(x) Files[(x)-2]



// FIXME - bring these in.
extern void _init(void);

// Hardware initialisation
// Sets up RS232 baud rate and attempts to initialise the SD card, if present.

static int sdcard_present;
static int filesystem_present;

static int _init_sd()
{
	filesystem_present=0;
	if((sdcard_present=spi_init()))
	{
		printf("SD card successfully initialised\n");
		filesystem_present=FindDrive();
	}
	else
		printf("No SD card found\n");
	return(filesystem_present);
}

static void _initIO(void)
{
	HW_UART(REG_UART_CLKDIV)=(1000*HW_BOARD(REG_CAP_CLOCKSPEED))/1152;
	HW_TIMER(REG_TIMER_DIV0)=HW_BOARD(REG_CAP_CLOCKSPEED)*2; // Clocks 1 through 6 are now based on 100kHZ base clock.
	_init_sd();
}


extern char _romend; // Defined by the linker script
extern char *heap_ptr;
int _stack;

int *__errno(void)
{
	return(&errno);
}

void exit(int i)
{
	while(1);
}


void __attribute__ ((weak)) _premain()  
{
	int t;
	size_t size;
	size_t low;
	low=(size_t)&_romend;
	low+=15;
	low&=0xfffffff0; // Align to SDRAM burst boundary

	_initIO();
	printf("Initialising files\n");
	for(t=0;t<MAX_FILES;++t)
		Files[t]=0;

	size=1L<<HW_BOARD(REG_CAP_RAMSIZE);
	size-=low;
	size-=0x1000; // Leave room for the stack
	printf("Heap_low: %lx, heap_size: %lx\n",low,size);
	malloc_add((void*)low,size);

//	_init();
	t=main(1, args);
	exit(t);
	for (;;);
}

// Re-implement sbrk, since the libgloss version doesn't know about our memory map.
char *_sbrk(int nbytes)
{
	// Since we add the entire memory in _premain() we can skip this.
	printf("Custom sbrk asking for %d bytes\n",nbytes);
	return(0);
#if 0
	char *base;

	if (!heap_ptr)
		heap_ptr = (char *)&_end;
	base = heap_ptr;

	heap_ptr += nbytes;

	if ((int)heap_ptr>RAMTOP)
		return (char *)-1;

	return base;
#endif
}

//char *sbrk(int nbytes)
//{
//	return(_sbrk(nbytes));
//}

/* NOTE!!!! compiled with -fomit-frame-pointer to make sure that 'status' has the
 * correct value when breakpointing at _exit
 */
void __attribute__ ((weak)) _exit (int status)  
{
	/* end of the universe, cause memory fault */
//	__asm("breakpoint");
	for (;;);
}

void __attribute__ ((weak)) _zpu_interrupt(void)  
{
	/* not implemented in libgloss */
//	__asm("breakpoint");
	for (;;);
}


// Rudimentary filesystem support

int __attribute__ ((weak))
_DEFUN (write, (fd, buf, nbytes),
       int fd _AND
       char *buf _AND
       int nbytes)  
{
	if((fd==1) || (fd==2)) // stdout/stderr
	{
		int c=nbytes;
		// Write to UART
		// FIXME - need to save any received bytes in a ring buffer.
		// FIXME - ultimately need to use interrupts here.

		while(nbytes--)
		{
			while(!(HW_UART(REG_UART)&(1<<BIT_UART_TXREADY)))
				;
			HW_UART(REG_UART)=*buf++;
		}
		return(nbytes);
	}
	else
	{
		if(File(fd))
		{
			// We have a file - but we don't yet support writing.
			errno=EACCES;
		}
		errno=EBADF;
	}
	return (nbytes);
}


/*
 * read  -- read bytes from the serial port if fd==0, otherwise try and read from SD card
 */

int __attribute__ ((weak))
_DEFUN (read, (fd, buf, nbytes),
       int fd _AND
       char *buf _AND
       int nbytes)  
{
	printf("Reading %d bytes from fd %d\n",nbytes,fd);
	if(fd==0) // stdin
	{
		// Read from UART
		while(nbytes--)
		{
			int in;
			while(!((in=HW_UART(REG_UART))&(1<<BIT_UART_RXINT)))
				;
			*buf++=in&0xff;
		}
		return(nbytes);
	}
	else
	{
		// Handle reading from SD card
		if(File(fd))
		{
			if(RARead(File(fd),buf,nbytes))
				return(nbytes);
			else
			{
				errno=EIO;
				return(0);
			}
		}
		else
			errno=EBADF;
	}
	return(0);
}



/*
 * open -- open a file descriptor.
 */
int __attribute__ ((weak)) open(const char *buf,
       int flags,
       ...)  
{
	// FIXME - Take mode from the first varargs argument
	printf("in open()\n");
	if(filesystem_present) // Only support reads at present.
	{
		// Find a free FD
		int fd=3;
		while((fd-2)<MAX_FILES)
		{
			if(!File(fd))
			{
				printf("Found spare fd: %d\n",fd);
				File(fd)=malloc(sizeof(RAFile));
				if(File(fd))
				{
					if(RAOpen(File(fd),buf))
						return(fd);
					else
						free(File(fd));
					errno = ENOENT;
					return(-1);
				}
			}
			++fd;
		}
	}
	else
	{
		printf("open() - no filesystem present\n");
		errno = EIO;
	}
	return (-1);
}



/*
 * close
 */
int __attribute__ ((weak))
_DEFUN (close ,(fd),
       int fd)  
{
	if(fd>2 && File(fd))
		free(File(fd));
	return (0);
}




int __attribute__ ((weak))
ftruncate (int file, off_t length)  
{
	return -1;
}


/*
 * unlink -- we just return an error since we don't support writes yet.
 */
int __attribute__ ((weak))
_DEFUN (unlink, (path),
        char * path)  
{
	errno = EIO;
	return (-1);
}


/*
 * lseek --  Since a serial port is non-seekable, we return an error.
 */
off_t __attribute__ ((weak))
_DEFUN (lseek, (fd,  offset, whence),
       int fd _AND
       off_t offset _AND
       int whence)  
{
	if(fd<3)
	{
		errno = ESPIPE;
		return ((off_t)-1);
	}
	else if(File(fd))
	{
		switch(whence)
		{
			case SEEK_SET:
			case SEEK_CUR:
				RASeek(File(fd),offset,whence);
				return((off_t)File(fd)->ptr);
				break;
			case SEEK_END:
				errno = EINVAL;
				printf("SEEK_END not yet supported\n");
				return((off_t)-1);
				break;
			default:
				break;
		}
	}
}

/* we convert from bigendian to smallendian*/
static long conv(char *a, int len) 
{
	long t=0;
	int i;
	for (i=0; i<len; i++)
	{
		t|=(((int)a[i])&0xff)<<((len-1-i)*8);
	}
	return t;
}

static void convert(struct fio_stat *gdb_stat, struct stat *buf)
{
	memset(buf, 0, sizeof(*buf));
	buf->st_dev=conv(gdb_stat->fst_dev, sizeof(gdb_stat->fst_dev));
	buf->st_ino=conv(gdb_stat->fst_ino, sizeof(gdb_stat->fst_ino));
	buf->st_mode=conv(gdb_stat->fst_mode, sizeof(gdb_stat->fst_mode));
	buf->st_nlink=conv(gdb_stat->fst_nlink, sizeof(gdb_stat->fst_nlink));
	buf->st_uid=conv(gdb_stat->fst_uid, sizeof(gdb_stat->fst_uid));
	buf->st_gid=conv(gdb_stat->fst_gid, sizeof(gdb_stat->fst_gid));
	buf->st_rdev=conv(gdb_stat->fst_rdev, sizeof(gdb_stat->fst_rdev));
	buf->st_size=conv(gdb_stat->fst_size, sizeof(gdb_stat->fst_size));
}

int __attribute__ ((weak))
_DEFUN (fstat, (fd, buf),
       int fd _AND
       struct stat *buf)  
{
/*
 * fstat -- Since we have no file system, we just return an error.
 */
	memset(buf,0,sizeof(struct stat));
	if(fd<3)
	{
		buf->st_mode = S_IFCHR;	/* Always pretend to be a tty */
		buf->st_blksize = 0;
	}
	else if(File(fd))
	{
		buf->st_size = File(fd)->size;
	}
	return (0);
}


int __attribute__ ((weak))
_DEFUN (stat, (path, buf),
       const char *path _AND
       struct stat *buf)  
{
	errno = EIO;
	return (-1);
}



int __attribute__ ((weak))
_DEFUN (isatty, (fd),
       int fd)  
{
	/*
	 * isatty -- returns 1 if connected to a terminal device,
	 *           returns 0 if not. Since we're hooked up to a
	 *           serial port, we'll say yes and return a 1.
	 */
	return (1);
}

