/*---------------------------------------------------------------*/
/* Petit-FatFs module test program R0.03a (C)ChaN, 2019          */
/*---------------------------------------------------------------*/

#include <string.h>
#include <p24FJ64GA002.h>
#include "pic24f.h"
#include "uart.h"
#include "xprintf.h"
#include "diskio.h"
#include "pff.h"


_CONFIG1(JTAGEN_OFF & GCP_OFF & GWRP_OFF & BKBUG_OFF & COE_OFF & ICS_PGx1 & FWDTEN_OFF & WINDIS_OFF & FWPSA_PR32 & WDTPS_PS32768)
_CONFIG2(IESO_OFF & FNOSC_PRIPLL & FCKSM_CSDCMD & OSCIOFNC_OFF & IOL1WAY_OFF & I2C1SEL_PRI & POSCMOD_HS)


/*---------------------------------------------------------*/
/* Work Area                                               */
/*---------------------------------------------------------*/


char Line[128];		/* Console input buffer */



static void put_rc (FRESULT rc)
{
	const char *p;
	FRESULT i;
	static const char str[] =
		"OK\0DISK_ERR\0NOT_READY\0NO_FILE\0NOT_OPENED\0NOT_ENABLED\0NO_FILE_SYSTEM\0";

	for (p = str, i = 0; i != rc && *p; i++) {
		while(*p++) ;
	}
	xprintf("rc=%u FR_%S\n", rc, p);
}



static void put_drc (BYTE res)
{
	xprintf("rc=%d\n", res);
}



static void IoInit (void)
{
	/* Initialize GPIO ports */
	AD1PCFG = 0x1FFF;
	LATB =  0xD00C;
	TRISB = 0x1C08;
	LATA =  0x0001;
	TRISA = 0x0000;
	_CN15PUE = 1;
	_CN16PUE = 1;

	/* Attach UART1 module to I/O pads */
	RPOR1 = 0x0003;		/* U1TX -- RP2 */
	RPINR18 = 0x1F03;	/* U1RX -- RP3 */

	/* Attach SPI1 module to I/O pads */
	RPINR20 = 0x1F0C;	/* SDI1 -- RP12 */
	RPOR6 = 0x0800;		/* SCK1OUT -- RP13 */
	RPOR7 = 0x0007;		/* SDO1 -- RP14 */

	_EI();

	uart_init();	/* Initialize UART driver */

	_LATA0 = 0;		/* LED ON */
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


	IoInit();

	xdev_out(uart_put);
	xdev_in(uart_get);
	xputs("\nPetit FatFs test monitor\n");

	for (;;) {
		xputc('>');
		xgets(Line, sizeof Line);
		ptr = Line;

		switch (*ptr++) {

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
					put_dump((BYTE*)ptr, s2, s1, 16);
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
				ofs = fs.fptr;
				res = pf_read(Line, sizeof Line, &s1);
				if (res != FR_OK) { put_rc(res); break; }
				ptr = Line;
				while (s1) {
					s2 = (s1 >= 16) ? 16 : s1;
					s1 -= s2;
					put_dump((BYTE*)ptr, ofs, s2, DW_CHAR);
					ptr += 16; ofs += 16;
				}
				break;

			case 't' :	/* ft - Type the file data via dreadp function */
				do {
					res = pf_read(0, 32768, &s1);
					if (res != FR_OK) { put_rc(res); break; }
				} while (s1 == 32768);
				break;
#endif
#if PF_USE_WRITE
			case 'w' :	/* fw <len> <val> - Write data to the file */
				if (!xatoi(&ptr, &p1) || !xatoi(&ptr, &p2)) break;
				for (s1 = 0; s1 < sizeof Line; Line[s1++] = (BYTE)p2) ;
				p2 = 0;
				while (p1) {
					if ((UINT)p1 >= sizeof Line) {
						cnt = sizeof Line; p1 -= sizeof Line;
					} else {
						cnt = (UINT)p1; p1 = 0;
					}
					res = pf_write(Line, cnt, &w);	/* Write data to the file */
					p2 += w;
					if (res != FR_OK) { put_rc(res); break; }
					if (cnt != w) break;
				}
				res = pf_write(0, 0, &w);		/* Finalize the write process */
				put_rc(res);
				if (res == FR_OK)
					xprintf("%lu bytes written.\n", p2);
				break;

			case 'p' :	/* fp - Write console input to the file */
				xputs("Enter lines to write. A blank line finalize the write operation.\n");
				for (;;) {
					xgets(Line, sizeof Line);
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
				if (res == FR_OK)
					xprintf("fptr = %lu(0x%lX)\n", fs.fptr, fs.fptr);
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
					if (fno.fattrib & AM_DIR)
						xprintf("   <DIR>   %s\n", fno.fname);
					else
						xprintf("%9lu  %s\n", fno.fsize, fno.fname);
					s1++;
				}
				xprintf("%u item(s)\n", s1);
				break;
#endif
			}
			break;
		}
	}

}


