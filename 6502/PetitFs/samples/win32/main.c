/*---------------------------------------------------------------*/
/* Petit FAT file system module test program R0.03 (C)ChaN, 2014 */
/*---------------------------------------------------------------*/


#include <string.h>
#include <stdio.h>
#include "diskio.h"
#include "pff.h"


/*--------------------------------------------------------------------------*/
/* Monitor                                                                  */

/*----------------------------------------------*/
/* Get a value of the string                    */
/*----------------------------------------------*/
/*	"123 -5   0x3ff 0b1111 0377  w "
	    ^                           1st call returns 123 and next ptr
	       ^                        2nd call returns -5 and next ptr
                   ^                3rd call returns 1023 and next ptr
                          ^         4th call returns 15 and next ptr
                               ^    5th call returns 255 and next ptr
                                  ^ 6th call fails and returns 0
*/

int xatoi (			/* 0:Failed, 1:Successful */
	char **str,		/* Pointer to pointer to the string */
	long *res		/* Pointer to a valiable to store the value */
)
{
	unsigned long val;
	unsigned char r, s = 0;
	char c;


	*res = 0;
	while ((c = **str) == ' ') (*str)++;	/* Skip leading spaces */

	if (c == '-') {		/* negative? */
		s = 1;
		c = *(++(*str));
	}

	if (c == '0') {
		c = *(++(*str));
		switch (c) {
		case 'x':		/* hexdecimal */
			r = 16; c = *(++(*str));
			break;
		case 'b':		/* binary */
			r = 2; c = *(++(*str));
			break;
		default:
			if (c <= ' ') return 1;	/* single zero */
			if (c < '0' || c > '9') return 0;	/* invalid char */
			r = 8;		/* octal */
		}
	} else {
		if (c < '0' || c > '9') return 0;	/* EOL or invalid char */
		r = 10;			/* decimal */
	}

	val = 0;
	while (c > ' ') {
		if (c >= 'a') c -= 0x20;
		c -= '0';
		if (c >= 17) {
			c -= 7;
			if (c <= 9) return 0;	/* invalid char */
		}
		if (c >= r) return 0;		/* invalid char for current radix */
		val = val * r + c;
		c = *(++(*str));
	}
	if (s) val = 0 - val;			/* apply sign if needed */

	*res = val;
	return 1;
}


/*----------------------------------------------*/
/* Dump a block of byte array                   */

void put_dump (
	const unsigned char* buff,	/* Pointer to the byte array to be dumped */
	unsigned long addr,			/* Heading address value */
	int cnt						/* Number of bytes to be dumped */
)
{
	int i;


	printf("%08lX:", addr);

	for (i = 0; i < cnt; i++)
		printf(" %02X", buff[i]);

	putchar(' ');
	for (i = 0; i < cnt; i++)
		putchar(((buff[i] >= ' ' && buff[i] <= '~') ? buff[i] : '.'));

	putchar('\n');
}


/*----------------------------------------------*/
/* Put API result code                          */

void put_rc (FRESULT rc)
{
	const char *p;
	static const char str[] =
		"OK\0DISK_ERR\0NOT_READY\0NO_FILE\0NOT_OPENED\0NOT_ENABLED\0NO_FILE_SYSTEM\0";
	FRESULT i;

	for (p = str, i = 0; i != rc && *p; i++) {
		while(*p++);
	}
	printf("rc=%u FR_%s\n", (UINT)rc, p);
}



/*-----------------------------------------------------------------------*/
/* Main                                                                  */


int main (int argc, char *argv[])
{
	char *ptr, line[128];
	long p1, p2, p3;
	BYTE res, buff[1024];
	UINT w, cnt, s1, s2, ofs;
	FATFS fs;			/* File system object */
	DIR dir;			/* Directory object */
	FILINFO fno;		/* File information */


	printf("Petit FatFs module test monitor for Windows2k/XP\n");
	if (!assign_drives(argc, argv)) {
		printf("\nUsage: pffdev <pd#>\n<pd#> is the physical drive number recognized as \\\\.\\PhysicalDrive<pd#>\n");
		return 2;
	}

	for (;;) {
		printf(">");
		gets(ptr = line);

		switch (*ptr++) {

		case 'q' :	/* Exit program */
			return 0;

		case 'T' :
			while (*ptr == ' ') ptr++;

			// Quick test space

			break;

		case 'd' :
			switch (*ptr++) {
			case 'd' :	/* dd <sector> <ofs> <count> - Dump secrtor */
				if (!xatoi(&ptr, &p1) || !xatoi(&ptr, &p2) || !xatoi(&ptr, &p3)) break;
				p2 %= 512;
				res = disk_readp(buff, p1, (UINT)p2, (UINT)p3);
				if (res) { printf("rc=%d\n", res); break; }
				printf("Sector:%lu\n", p1);
				p3 = p2 + p3;
				for (ptr=(char*)buff; p2 < p3; ptr+=16, p2+=16) {
					if (p3 - p2 >= 16) 
						put_dump((BYTE*)ptr, p2, 16);
					else
						put_dump((BYTE*)ptr, p2, p3 - p2);
				}
				break;

			case 'w' :	/* dw <sector> <count> <dat> - Write sector */
				if (!xatoi(&ptr, &p1) || !xatoi(&ptr, &p2) || !xatoi(&ptr, &p3)) break;
				memset(buff, (BYTE)p3, 512);
				res = disk_writep(0, p1);
				if (res) { printf("rc=%d\n", res); break; }
				res = disk_writep(buff, p2);
				if (res) { printf("rc=%d\n", res); break; }
				res = disk_writep(0, 0);
				if (res) { printf("rc=%d\n", res); break; }
				break;

			case 'i' :	/* di - Initialize physical drive */
				res = disk_initialize();
				printf("rc=%d\n", res);
				break;
			}
			break;

		case 'f' :
			switch (*ptr++) {

			case 'i' :	/* fi - Mount the volume */
				put_rc(pf_mount(&fs));
				break;

			case 's' :	/* fs - Show logical drive status */
				if (!fs.fs_type) { printf("Not mounted.\n"); break; }
				printf("FAT type = %u\nBytes/Cluster = %lu\n"
						"Root DIR entries = %u\nNumber of clusters = %lu\n"
						"FAT start (lba) = %lu\nDIR start (lba,clustor) = %lu\nData start (lba) = %lu\n\n",
						fs.fs_type, (DWORD)fs.csize * 512,
						fs.n_rootdir, (DWORD)fs.n_fatent - 2,
						fs.fatbase, fs.dirbase, fs.database
				);
				break;

			case 'l' :	/* fl [<path>] - Directory listing */
				res = pf_opendir(&dir, ptr);
				if (res) { put_rc(res); break; }
				p1 = s1 = s2 = 0;
				for(;;) {
					res = pf_readdir(&dir, &fno);
					if (res != FR_OK) { put_rc(res); break; }
					if (!fno.fname[0]) break;
					if (fno.fattrib & AM_DIR) {
						s2++;
					} else {
						s1++; p1 += fno.fsize;
					}
					printf("%c%c%c%c%c %u/%02u/%02u %02u:%02u %9lu  %s",
							(fno.fattrib & AM_DIR) ? 'D' : '-',
							(fno.fattrib & AM_RDO) ? 'R' : '-',
							(fno.fattrib & AM_HID) ? 'H' : '-',
							(fno.fattrib & AM_SYS) ? 'S' : '-',
							(fno.fattrib & AM_ARC) ? 'A' : '-',
							(fno.fdate >> 9) + 1980, (fno.fdate >> 5) & 15, fno.fdate & 31,
							(fno.ftime >> 11), (fno.ftime >> 5) & 63, fno.fsize, fno.fname);
					putchar('\n');
				}
				printf("%4u File(s),%10lu bytes total\n%4u Dir(s)\n", s1, p1, s2);
				break;

			case 'o' :	/* fo <file> - Open a file */
				put_rc(pf_open(ptr));
				break;

			case 'e' :	/* fe - Move file pointer of the file */
				if (!xatoi(&ptr, &p1)) break;
				res = pf_lseek(p1);
				put_rc(res);
				if (res == FR_OK)
					printf("fptr = %lu(0x%lX)\n", fs.fptr, fs.fptr);
				break;

			case 'r' :	/* fr <len> - Read the file */
				if (!xatoi(&ptr, &p1)) break;
				p2 =0;
				while (p1) {
					if ((UINT)p1 >= sizeof buff) {
						cnt = sizeof buff; p1 -= sizeof buff;
					} else {
						cnt = (UINT)p1; p1 = 0;
					}
					res = pf_read(buff, cnt, &w);
					if (res != FR_OK) { put_rc(res); break; }
					p2 += w;
					if (cnt != w) break;
				}
				printf("%lu bytes read.\n", p2);
				break;

			case 'w' :	/* fw <len> <dat> - Read the file */
				if (!xatoi(&ptr, &p1) || !xatoi(&ptr, &p2)) break;
				memset(buff, (BYTE)p2, sizeof buff);
				p3 =0;
				while (p1) {
					if ((UINT)p1 >= sizeof buff) {
						cnt = sizeof buff; p1 -= sizeof buff;
					} else {
						cnt = (UINT)p1; p1 = 0;
					}
					res = pf_write(buff, cnt, &w);
					if (res != FR_OK) { put_rc(res); break; }
					p3 += w;
					if (cnt != w) break;
				}
				res = pf_write(0, 0, &w);
				if (res != FR_OK) { put_rc(res); break; }
				printf("%lu bytes written.\n", p3);
				break;

			case 'd' :	/* fd <len> - Read and dump the file */
				if (!xatoi(&ptr, &p1)) break;
				ofs = fs.fptr;
				while (p1) {
					if ((UINT)p1 >= 16) { cnt = 16; p1 -= 16; }
					else 				{ cnt = (UINT)p1; p1 = 0; }
					res = pf_read(buff, cnt, &w);
					if (res != FR_OK) { put_rc(res); break; }
					if (!w) break;
					put_dump(buff, ofs, cnt);
					ofs += 16;
				}
				break;

			case 't' :	/* ft - Type the file via streaming function */
				do {
					res = pf_read(0, 16384, &w);
					if (res != FR_OK) { put_rc(res); break; }
				} while (w == 16384);
				break;

			}
			break;

		}
	}

}


