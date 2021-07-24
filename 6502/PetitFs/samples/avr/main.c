/*---------------------------------------------------------------*/
/* Petit-FatFs module test program R0.03a (C)ChaN, 2019          */
/*---------------------------------------------------------------*/

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#pragma GCC diagnostic ignored "-Wstrict-aliasing"
#define __PROG_TYPES_COMPAT__
#include <string.h>
#include <avr/io.h>
#include <avr/pgmspace.h>
#include "diskio.h"
#include "pff.h"
#include "xitoa.h"
#include "suart.h"


FUSES = {0xE2, 0xDD, 0xFF};	/* Low, High and Extended */
/* This is the fuse settings of this project. The fuse data will be included
   in the output hex file with program code. However some old flash programmers
   may not support this sort of hex files. If it is the case, use these values
   to program the fuse bits.
*/


/*---------------------------------------------------------*/
/* Work Area                                               */
/*---------------------------------------------------------*/


char Line[128];		/* Console input buffer */


const prog_char help[] =
	" fi - Mount volume\n"
	" fo <file> - Open file\n"
	" fd - Dump 128 bytes of file data\n"
	" ft - Stream the file to console\n"
#if PF_USE_SEEK
	" fe <ofs> - Move r/w ptr\n"
#endif
#if PF_USE_WRITE
	" fw <len> <val> - Write data to file\n"
	" fp - Write console input to file\n"
#endif
#if PF_USE_DIR
	" fl [<path>] - Read directory\n"
#endif
	;


static void put_rc (FRESULT rc)
{
	const prog_char *p;
	static const prog_char str[] =
		"OK\0" "DISK_ERR\0" "NOT_READY\0" "NO_FILE\0" "NO_PATH\0"
		"NOT_OPENED\0" "NOT_ENABLED\0" "NO_FILE_SYSTEM\0";
	FRESULT i;

	for (p = str, i = 0; i != rc && pgm_read_byte_near(p); i++) {
		while (pgm_read_byte_near(p++)) ;
	}
	xprintf(PSTR("rc=%u FR_%S\n"), (WORD)rc, p);
}



static void put_drc (BYTE res)
{
	xprintf(PSTR("rc=%d\n"), res);
}



static void get_line (char *buff, BYTE len)
{
	BYTE c, i;

	i = 0;
	for (;;) {
		c = rcvr();
		if (c == '\r') break;
		if ((c == '\b') && i) i--;
		if ((c >= ' ') && (i < len - 1)) buff[i++] = c;
	}
	buff[i] = 0;
	xmit('\n');
}



static void put_dump (const BYTE *buff, DWORD ofs, int cnt)
{
	BYTE n;


	xitoa(ofs, 16, -8); xputc(' ');
	for(n = 0; n < cnt; n++) {
		xputc(' ');	xitoa(buff[n], 16, -2); 
	}
	xputs(PSTR("  "));
	for(n = 0; n < cnt; n++) {
		xputc(((buff[n] < 0x20)||(buff[n] >= 0x7F)) ? '.' : buff[n]);
	}
	xputc('\n');
}



/*-----------------------------------------------------------------------*/
/* Main                                                                  */


int main (void)
{
	char *ptr;
	long p1, p2;
	BYTE res;
	UINT s1, s2, s3, ofs, cnt, w;
	FATFS fs;			/* File system object */
	DIR dir;			/* Directory object */
	FILINFO fno;		/* File information */


	PORTB = 0b101011;	/* uzHLHu */
	DDRB =  0b001110;


	xfunc_out = xmit;
	xputs(PSTR("\nPFF test monitor\n"));

	for (;;) {
		xputc('>');
		get_line(Line, sizeof(Line));
		ptr = Line;

		switch (*ptr++) {
		case '?' :
			xputs(help);
			break;

		case 'd' :
			switch (*ptr++) {
			case 'i' :	/* di - Initialize physical drive */
				res = disk_initialize();
				put_drc(res);
				break;

			case 'd' :	/* dd <sector> <ofs> - Dump partial secrtor 128 bytes */
				if (!xatoi(&ptr, &p1) || !xatoi(&ptr, &p2)) break;
				s2 = p2;
				res = disk_readp((BYTE*)Line, p1, s2, 128);
				if (res) { put_drc(res); break; }
				s3 = s2 + 128;
				for (ptr = Line; s2 < s3; s2 += 16, ptr += 16, ofs += 16) {
					s1 = (s3 - s2 >= 16) ? 16 : s3 - s2;
					put_dump((BYTE*)ptr, s2, s1);
				}
				break;
			}
			break;

		case 'f' :
			switch (*ptr++) {

			case 'i' :	/* fi - Mount the volume */
				put_rc(pf_mount(&fs));
				break;

			case 'o' :	/* fo <file> - Open a file */
				while (*ptr == ' ') ptr++;
				put_rc(pf_open(ptr));
				break;
#if PF_USE_READ
			case 'd' :	/* fd - Read the file 128 bytes and dump it */
				p2 = fs.fptr;
				res = pf_read(Line, sizeof(Line), &s1);
				if (res != FR_OK) { put_rc(res); break; }
				ptr = Line;
				while (s1) {
					s2 = (s1 >= 16) ? 16 : s1;
					s1 -= s2;
					put_dump((BYTE*)ptr, p2, s2);
					ptr += 16; p2 += 16;
				}
				break;

			case 't' :	/* ft - Type the file data in streaming read mode */
				do {
					res = pf_read(0, 32768, &s1);
					if (res != FR_OK) { put_rc(res); break; }
				} while (s1 == 32768);
				break;
#endif
#if PF_USE_WRITE
			case 'w' :	/* fw <len> <val> - Write data to the file */
				if (!xatoi(&ptr, &p1) || !xatoi(&ptr, &p2)) break;
				for (s1 = 0; s1 < sizeof(Line); Line[s1++] = (BYTE)p2) ;
				p2 = 0;
				while (p1) {
					if ((UINT)p1 >= sizeof(Line)) {
						cnt = sizeof(Line); p1 -= sizeof(Line);
					} else {
						cnt = (WORD)p1; p1 = 0;
					}
					res = pf_write(Line, cnt, &w);	/* Write data to the file */
					p2 += w;
					if (res != FR_OK) { put_rc(res); break; }
					if (cnt != w) break;
				}
				res = pf_write(0, 0, &w);		/* Finalize the write process */
				put_rc(res);
				if (res == FR_OK) {
					xprintf(PSTR("%lu bytes written.\n"), p2);
				}
				break;

			case 'p' :	/* fp - Write console input to the file */
				xputs(PSTR("Enter string to write. A blank line finalize the write operation.\n"));
				for (;;) {
					get_line(Line, sizeof(Line));
					if (!Line[0]) break;
					strcat(Line, "\r\n");
					res = pf_write(Line, strlen(Line), &w);	/* Write a line to the file */
					if (res) break;
				}
				res = pf_write(0, 0, &w);		/* Finalize the write process */
				put_rc(res);
				break;
#endif
#if PF_USE_LSEEK
			case 'e' :	/* fe - Move file pointer of the file */
				if (!xatoi(&ptr, &p1)) break;
				res = pf_lseek(p1);
				put_rc(res);
				if (res == FR_OK) {
					xprintf(PSTR("fptr = %lu(0x%lX)\n"), fs.fptr, fs.fptr);
				}
				break;
#endif
#if PF_USE_DIR
			case 'l' :	/* fl [<path>] - Directory listing */
				while (*ptr == ' ') ptr++;
				res = pf_opendir(&dir, ptr);
				if (res) { put_rc(res); break; }
				s1 = 0;
				for(;;) {
					res = pf_readdir(&dir, &fno);
					if (res != FR_OK) { put_rc(res); break; }
					if (!fno.fname[0]) break;
					if (fno.fattrib & AM_DIR) {
						xprintf(PSTR("   <DIR>   %s\n"), fno.fname);
					} else {
						xprintf(PSTR("%9lu  %s\n"), fno.fsize, fno.fname);
					}
					s1++;
				}
				xprintf(PSTR("%u item(s)\n"), s1);
				break;
#endif
			}
			break;
		}
	}

}


