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

#include <libc.h>
#include <init.h>

/*
* This file is the c pre processor of the native C compiler for the PDP-8 series of computers.
* Linked with LIBC.RL to create CC0.SV
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

/* Ask for input file, copy to CC.CC and run CC1 */
/* Update Feb 2018 */
/* 1. Read file line by line */
/* 2. Exclude FF (12) */
/* 3. Implement simple #define directive **Warning** quoted text is not ignored */
/* 4. Implement #asm/#endasm directive */
/* Update April 2020 */
/* 5. Implement switch satement via re-write */
/* *** 1: default: must be included 2: Fall through is not implemented */
/*     3: Nesting is allowed */
/* 6: Implement logical operators !=,>=,<= via token symbols #,_,? */
/* 7. Permit multiline comments */

int ln[128],*p,*q,*tm,*dfp,tkbf[10],smbf[10];
int dflst[1024],tmln[80];
int asm[1024];
int *swp,swpbf[256],*swc,xm,cm;
int rh1[80],rh2[80],rh3[80],*n;
int ocntr,ccntr;

skpsp()
{
    while (isspace(*p))
        p++;
}

strlen(p)
char *p;
{
    int n;

    n=0;
    while (*p++)
        n++;
    return n;
}

getsym()
{
    q=tkbf;
    skpsp();
    while (isalnum(*p))
        *q++=*p++;
    *q=0;
    skpsp();
    return *tkbf;
}


parse()
{
    getsym();
    strcpy(dfp,tkbf);
    getsym();
    strcpy(dfp+512,tkbf);
    dfp+=10;
}

int dorep()
{
    p=dflst;
    while (*p) {
        q=strstr(ln,p);
        while (q) {
            memset(tmln,0,80);
            if (q-p)
                memcpy(tmln,ln,q-ln);
            strcat(tmln,p+512);
            strcat(tmln,q+strlen(p));
            memcpy(ln,tmln,80);
            q=strstr(ln,p);
        }
        p+=10;
    }
}


/* Set bit 7 in string constants to exclude from processing */
/* Also, translate control chara .. /n etc. to actual values */

int strip()
{
    int cm;

    cm=0;
    p=ln;
    while(*p) {
        if (*p==39 && !cm)
            p+=3;
        if (*p=='"') {
            cm=!cm;
            *p|=128;
        }
        if (cm) {
            q=p+1;
            if (*p==92) {
                switch (*q) {
                    case 't': *q=9;
                        break;
                    case 'r': *q=13;
                        break;
                    case 'n': *q=10;
                        break;
                }
                strcpy(p,q);
            }
            *p|=128;
        }
        p++;
    }
    p=ln;
}



main()
{
    int bfr;
    int fnm[10];

    putc('>');
    gets(fnm);
    cupper(fnm);
    fopen(fnm,"r");
    fopen("CC.CC","w");
    *asm=0;
    memset(dflst,0,1024);
    dfp=dflst;
    ocntr=ccntr=cm=0;

    while (1) {
        fgets(p=ln);
        if (!*ln)
            break;
        swc=swp=swpbf;

        /* Remove #include lines */

        if (strstr(ln,"#include")) 
            strcpy(ln,"\r\n");

        strip();

        /* Find comment. If partial, set cm */

        if (p=strstr(ln,"/*")) {
            if (!strstr(p,"*/"))
                cm++;
            *p=0;
            strcat(ln,"\r\n");
        }

        /* If cm, strip lines until terminating */

        if (cm) {
            while(1) {
                fgets(p=ln);
                strip();
                if (!cm)
                    break;
                if (strstr(p,"*/"))
                    cm=0;
            }
        }

        if (!*ln)
            break;

        /* Convert type char to int */

        p=ln;
        getsym();
        if (*tkbf) {
            if (!strcmp(tkbf,"char")) {
                q=strstr(ln,"char ");
                memcpy(q,"int ",4);
            } else
                if (!strcmp(tkbf,"void")) {
                    q=strstr(ln,"void ");
                    memcpy(q,"int ",4);
                }
        }

        /* Call dorep to replace #defines */

        dorep();

        /* Initial tokenise to convert digraphs to marker charcters */

        p=ln;
        while (*p) {
            tm=p;
            switch (*p++) {
                case '"':
                    while (*p++!='"');
                    break;
                case 12:
                case 9:
                    *tm=' ';
                    break;
                case '{':
                    ocntr++;
                    break;
                case '}':
                    ccntr++;
                    break;
                case 39:
                    sprintf(tmln,"%3d",*p);
                    memcpy(tm,tmln,3);
                    break;
                case '>':
                    switch (*p) {
                case '=':
                    *tm=' ';
                    *p='@';
                    break;
                case '>':
                    *tm=' ';
                    *p='.';
                    }
                    break;
                case '<':
                    switch (*p) {
                case '=':
                    *tm=' ';
                    *p='#';
                    break;
                case '<':
                    *tm=' ';
                    *p=':';
                    }
                    break;
                case '=':
                    if (*p=='=') {
                        *tm=' ';
                        *p='$';
                    }
                    break;
                case '!':
                    if (*p=='=') {
                        *tm=' ';
                        *p='_';
                    }
                    break;
                case '&':
                case '|':
                    if (*p==*tm) {
                        *tm=' ';
                        printf("W: ||,&& coversion\r\n");
                    }
                    break;

            }
        }

        /* Manage #asm/#endasm. Concatenate asm code into asm string */

        p=strstr(ln,"#asm");
        q=0;
        while (p) {
            fgets(ln);
            q=strstr(ln,"#endasm");
            if (q) {
                strcpy(ln,"`\r\n");
                break;
            }
            toupper(ln);
            strcat(asm,ln);
        }
        if (p)
            strcat(asm,"$");

        /* Rewrite switch statement using if within a while loop */

        p=strstr(ln,"switch");
        if (p) {
            p=p+6;
            while (*p!='{') {
                if (!*p) 
                    fgets(p=ln);
                *swp++=*p++;
            }
            *swp=0;
            xm=0;
            strcpy(ln,"while(1) {\r\n");
        }

        p=strstr(ln,"case ");
        if (p) {
            p=p+5;
            q=strstr(ln,":");
            *q++=0;
            strcpy(rh1,q);
            memcpy(tmln,p,q-p);
            if (xm)
                fputs("}\r\n");
            sprintf(ln,"if (%s $ %s) {\r\n",swc,tmln);
            strcat(ln,rh1);
            xm++;
        }

        p=strstr(ln,"default:");
        if (p) {
            if (xm)
                fputs("}");
            p=p+8;
            fprintf("\r\n%s",p);
            *ln=0;
        }

        /* Manage ternary operator ?: using if/else statements */

        while (1) {
            p=n=ln;
            memset(tmln,0,80);
            memset(rh1,0,80);
            memset(rh2,0,80);
            while (1) {
                getsym();
                switch (tm=*p++) {
                case '=':
                    memcpy(tmln,n,p-n);
                    n=p;
                    break;
                case '?':
                    memcpy(rh1,n,p-n-1);
                    n=p;
                    break;
                case ':':
                    memcpy(rh2,n,p-n-1);
                    strcpy(rh3,p);
                    tm=0;
                    break;
                }
                if (!tm) {
                    if (*rh1 && *rh2)
                        sprintf(ln,"\tif (%s)\r\n%s%s;\r\n\telse\r\n%s%s",rh1,tmln,rh2,tmln,rh3);
                    break;
                }
            }
            if (strstr(ln,"?") && *rh1 && *rh2) {
                fprintf("\tif (%s)\r\n%s%s;\r\n\telse\r\n",rh1,tmln,rh2);
                sprintf(ln,"\t%s%s\r\n",tmln,rh3);
            }
            else
                break;
        }

        /* Extract define symbols ... expected format #define <symbol to be replaced> <symbol> */
        /* Symbols may only be alhanumeric strings. No complex macros.... */
        /* Finally, strip bit 8 to return string constants to normal */

        p=strstr(ln,"#define ");
        if (p) {
            p=p+8;
            parse();
        } else {
            p=ln;
            while (*p)
                *p++&=127;
            fputs(ln);
        }
    }

    /* Close CC.CC and write CASM.TX */
    /* CC.CC is tokenised by CC1.SV and CASM.TX will be prepended to CC.SB by CC2.SV */

    fclose();
    fopen("HEADER.SB","r");
    fopen("CASM.TX","w");
    while (bfr=fgetc())
        fputc(bfr);
    fputc('!');
    p=asm;
    while (*p)
        fputc(*p++);
    fclose();

    /* The only error check for now! */

    if (ocntr!=ccntr) {
        printf("E: {} count mismatch\r\n");
        exit(0);
    }


#asm	
    CALL 1,CHAIN
        ARG FNM
        HLT
        FNM,	TEXT "CC1@@@"
#endasm


}
