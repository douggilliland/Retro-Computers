/*
 * This file is part of the CC8 OS/8 C compiler.
 *
 * The CC8 OS/8 C compiler is free software: you can redistribute it
 * and/or modify it under the terms of the GNU General Public License 
 * as published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * The CC8 OS/8 C compiler is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied warranty
 * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with the CC8 OS/8 C compiler as ../GPL3.txt.  If not, see
 * <http://www.gnu.org/licenses/>.
 */

/*
 * This file is the code generator of the native C compiler for the PDP-8 series of computers.
 * Linked with LIBC.RL to create CC2.SV
 * Hardware requirements:
 * 1. PDP/8 processor with minimal EAE (MQ register is heavily used).
 * 2. 20K (5x4K banks) of core.
 * 3. OS/8 operating system with FORTRAN II library (LIB8.RL)
 * 4.                            SABR assembler (SABR.SV)
 * 5.                            Linking loader (LOADER.SV)
 *
 * 1. The compiler consists of 3 files: CC0.SV, CC1.SV, CC2.SV on system device. (SYS:)
 * The runtime support files are:
 * 1. The c library created from libc.c and assembled to LIBC.RL on the user device.
 * 2. A runtime support file: HEADER.SB on the user device (DSK:)

 * These 3 .SV files run in sequence:
 * CC0: C pre-processor: Asks for ONE source file and creates CC.CC for CC1.SV.
 *      And, generates an intermediate file (CASM.TX) used by CC2.SV.
 * CC1: C tokeniser: Reads CC.CC and converts the code to a token list in FIELD 4
 * CC2: SABR code generator: Reads token list and generates CC.SB from
 *      a collection of code fragments. 
 * Finally, the SABR assembler is used on CC.SB and the runtime is generated
 * by LOADER.SV using CC.RL and LIBC.RL

 */


#include <libc.h>
#include <init.h>

#define SMAX 10
#define CMAX 300
#define BMAX 64
#define LMAX 64
#define DMAX 32
#define CBMX 1024
#define LXMX 999

int ltbf[512];
int xlt[CMAX];
int gm[512];		/* Global symbol table */
int tkbf[DMAX];
int *p,*q,*s,*ltpt;
int gsym,lsym,gadr,ladr,stkp,lctr,*fptr,gsz,ctr,tm,ectr,glim;
int ltsz,pflg,t;
int tmstr[32];

fputx(str)
char *str;
{
    fputs(str);
}

main()
{
	iinit(128);
    fopen("CTBL.TX","r");
    fgets(xlt);
	fopen("CASM.TX","r");
	fopen("CC.SB","w");
	while (1) {
		t=fgetc();
		if (t=='!')
			break;
		fputc(t);
	}

	cupper(gm);
	while (strl()) {
		pflg=*tmstr=0;
		switch (strd()) {
			case 99:
				fputx("/\r");
				break; 
			case 1:
				fputx("\tJMSI PTSK\r");
				break;
			case 3:
				strcpy(tmstr,"\tCIA\r");
			case 2:
				fprintf("%s\tTADI STKP\r\tJMSI POP\r",tmstr);
				break;
			case 4:
				fprintf("\tCLA\r\tTAD (%o\r",strd());
				break;
			case 5:
				tm=strd();
				if (tm<0)
					tm=400-tm;
				fprintf("CC%o,\r",tm);
				break;
			case 6:
				if (strl()>1)
					fprintf("\tCLA\r\tTAD STKP\r\tTAD (%o\r\tDCA STKP\r",strl());
				else
					if (strl()>0)
						fputx("\tISZ STKP\r");
				strd();
				break;
			case 7:
				p=gm+strd();
				while (*p-' ')
					fputc(*p++);
				fputx(",\r");
				break;
			case -8:
				strcpy(tmstr,"\tDCA JLC\r\tTADI JLC\r");
			case 8:
				if (strl()>0)
					fprintf("\tCLA\r\tTAD (%o\r%s\tJMSI PSH\r",strd(),tmstr);
				else
					fprintf("\tCLA\r\tTAD STKP\r\tTAD (%o\r%s\tJMSI PSH\r",strd(),tmstr);
				break;
			case 9:
				tm=strd();
				p=gm+strd();
				strcpy(tkbf,"        ");
				memcpy(tkbf,p,7);
				if (p=strstr(xlt,tkbf)) {
					t=(p-xlt)>>3;
					if (t>29)                   /* Push arg count for sscanf, sprintf, printf, fprintf, scanf */
						fprintf("\tCLA\r\tTAD (%o\r\tJMSI PSH\r",tm++);
					fprintf("\tCLA\r\tTAD (%o\r\tMQL\r\tCALL 1,LIBC\r\tARG STKP\r\tCDF1\r",t);
				}
				else
					fprintf("\tCPAGE 2\r\tJMSI PCAL\r\t%s\r",tkbf);
				if (tm)
				    fprintf("\tMQL\r\tTAD (%o\r\tTAD STKP\r\tDCA STKP\r\tSWP\r",-tm);
				break;
			case 10:
				fprintf("\tCLA\r\tTAD GBL\r\tTAD (%o\r",strd());
				break;
			case -11:
				fputx("\tCIA\r\tTADI STKP\r\tJMSI POP\r\tSMA SZA CLA\r\tCMA\r");
				break;
			case 11:
				fputx("\tCIA\r\tTADI STKP\r\tJMSI POP\r\tSPA CLA\r\tCMA\r");
				break;
			case 12:
					fprintf("\tSNA\r\tJMP CC%o\r",strd());
				break;
			case 13:
				fputx("\tJMSI POP\r\tDCA JLC\r\tSWP\r\tCALL 1,MPY\r\tARG JLC\r\tCDF1\r");
				break;
			case -14:
				fputx("\tCALL 1,IREM\r\tARG 0\r\tCDF1\r");
				break;
			case 14:
				fputx("\tJMSI POP\r\tDCA JLC\r\tSWP\r\tCALL 1,DIV\r\tARG JLC\r\tCDF1\r");
				break;
            case -15:
                fputx("\tIAC\r");
			case 15:
				fputx("\tISZI JLC\r\tNOP\r");
				break;
			case 16:
				fprintf("\tMQL\r\tTAD STKP\r\tTAD (%o\r\tDCA STKP\r\tSWP\r\tJMPI POPR\r/\r",strd());
				break;
			case 17:
				pflg++;
			case -17:
				if (strl()>0) 
					fprintf("\tCLA\r\tTAD (%o\r\tDCA JLC\r\tTADI JLC\r",strd());
				else
					fprintf("\tCLA\r\tTAD STKP\r\tTAD (%o\r\tDCA JLC\r\tTADI JLC\r",strd());
				if (pflg==0)
					break;
			case 19:
				fputx("\tJMSI PSH\r");
				break;
			case 20:
				fputx("\tANDI STKP\r\tJMSI POP\r");
				break;
			case -20:
				fputx("\tJMSI POP\r\tMQA\r");
				break;
			case 21:
				if (strl()>0) 
					fprintf("\tCLA\r\tTAD (%o\r",strd());
				else
					fprintf("\tCLA\r\tTAD STKP\r\tTAD (%o\r",strd());
				break;
			case 22:
				fputx("\tDCA JLC\r\tTADI JLC\r");
				break;
			case 23:
				if (strl()<400)
					fprintf("\tJMP CC%o\r",strl());
				strd();
				break;
			case -23:
					fprintf("\tJMP CC%o\r",strd());
				break;
			case 24:
				fputx("\tCIA\r\tTADI STKP\r\tJMSI POP\r\tSNA CLA\r\tCMA\r");
				break;
            case -25:
                fputx("\tCLA CMA\r\tTADI JLC\r\tDCAI JLC\r\tTADI JLC\r");
                break;
			case 25:
				fputx("\tMQL\r\tCMA\r\tTADI JLC\r\tDCAI JLC\r\tSWP\r");
				break;
			case 26:
				fputx("\tSNA CLA\r");
			case -26:
				fputx("\tCMA\r");
				break;
			case 27:
				fputx("\tCIA\r");
				break;
            case 28:
                fputx("\tSZA CLA\r\tCMA\r");
                break;
			case 29:
				while (1) {
					t=fgetc();
					if (t=='$')
						break;
					fputc(t);
				}
                break;
            case 30:
                fputx("\CIA\r");
            case 31:
                fputx("\tMQL\r\tJMSI PCAL\r\tXXLL\r\tJMSI POP\r");
                break;
            case 32:
                fputx("\tMQL\r\tJMSI PCAL\r\tXXOR\r\tJMSI POP\r");
                break;
            case 40:
                fputx("\tCLA\r\tTAD JLC\r\tDCA TLOC\r");
                break;
            case 41:
                fputx("\tDCAI TLOC\r\tTADI TLOC\r");
		}
	}

    /* Dump literal table. Add 2 extra words as SABR can cause a problem. */

	ltsz=ltpt-ltbf+2;
	fprintf("\tLAP\rLCC0,\t%o\rXCC0,\tCC0\r\tCPAGE %o\rCC0,\r",-ltsz,ltsz);
	p=ltbf;
	while (ltsz) {
		fprintf("%o",*p++);
		if (ltsz>1)
			fputx("; ");
		if ((ltsz&7)==0) 
			fputc(13);
		ltsz--;
	}
	fprintf("\r\tEAP\rGBLS,\t%o\r",gadr);
	fputx("\rMCC0,\t0\r\tCDF1\r\tTAD LCC0\r\tSNA CLA\r\tJMP I MCC0\r\tTAD XCC0\r\tDCA JLC\rDCC0,\tCDF0\r\tTADI JLC\r");
	fputx("\tJMSI PSH\r\tCLA\r\tISZ JLC\r\tISZ LCC0\r\tJMP DCC0\r\tJMP I MCC0\rCCEND,\t0\r\t\END\r");

	fclose();

}
