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
 * This file is the core of the native C compiler for the PDP-8 series of computers.
 * Linked with LIBC.RL to create CC1.SV
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
int dumy[DMAX];
int *p,*q,*s,*ltpt;
int gsym,lsym,gadr,ladr,stkp,lctr,*fptr,gsz,ctr,tm,ectr,glim;
int cop,*n,ccm;
int tmp;
int tkn[BMAX];
int bfr[LXMX];
int smbf[DMAX];
int lm[CMAX];		/* Auto symbol table */
int fstk[BMAX];		/* Push down stack for For etc. */
int inproc,addr,cbrk;
int izf,idf,ssz,mode,ppflg,opeq,vl,vf,mkr;
int dstk[DMAX],dptr;
int Lb[128];
int tmbf[128];
int tkbf[128];

getln()
{
    if (!fgets(p=Lb)) {
        stri(0);
#asm
					CALL 1,CHAIN
					ARG FNM
					HLT
FNM,				TEXT "CC2@@@"
#endasm
    }
}

gtch()
{
    if (!*p)
        getln();
    return *p++;
}

skpsp()
{
        while (isspace(gtch()));
        p--;
}


sksps()
{
	while (isspace(*p))
		p++;
}


strpad(sym)
char *sym;
{
    strpd(smbf,sym);
}


addsym(sym,sz,flg)
char *sym;
int sz,flg;
{
    strpad(sym);
    smbf[8]=sz;           /* Allow for 0 size symbols ... alloc via <symb>=const int */
    if (inproc+(sz<0)) {
        smbf[7]=stkp+1;
        stkp=stkp+sz;
        strcat(lm,smbf);
        if (flg) {
            stri(6);
            stri(sz);
        }
        return;
    }
    smbf[7]=gadr;
    gadr=gadr+sz;
    strcat(gm,smbf);
    gsz=gsz+9;
}

fndlcl(sym)
char *sym;
{
    strpad(sym);
    smbf[7]=0;
    if (s=strstr(lm,smbf)) {
        ssz=s[8];             /* Correct */
        s=s+7;
        return *s-stkp;
    }
    if (s=strstr(gm,smbf)) {
        ssz=s[8];             /* Correct */
        s=s+7;
        return *s;
    }
    return 0;

}

ckop()
{
            if (opeq) {
                stri(41);
                opeq=0;
            }
}

/* recursive descent parser for arithmetic/logical expressions */


S(  ) {
int rtv;

	cop=rtv=0;
	J( );
	switch(*p++){
	case '=':
		S();
		stri(1);
		stkp--;
		break;
	case ']':
	case ')':
		rtv++;
		break;
	case ',':
        ccm++;
        break;
    case ';':
        ppflg++;
		break;
	default: 
		p--;
	}
	sksps();
	return rtv;
} /* end S */

J(  ) {

	K( );
	switch(*p++){
	case '&': J( ); stri(20); break;
	case '|': J( ); stri(4076); break;
    case '^': J( ); stri(32); break;
	default: p--; return;
	}
	stkp--;
} /* end J */

K(  ) {

	V( );
	switch(*p++){
    case '.': K( ); stri(30); break;
    case ':': K( ); stri(31); break;
	case '<': K( ); stri(11); break;
	case '>': K( ); stri(4085); break;          /* -11 */
	case '@': K( ); stri(11); stri(4070); break;
    case '#': K( ); stri(4085); stri(4070); break;
    case '_': K( ); stri(24); stri(4070); break;
	case '$': K( ); stri(24); break;
	default: p--; return;
	}
	stkp--;
} /* end K */

V(  ) {

	W( );
	switch(*p++){
	case '+': V(); stri(2); break;
	case '-': V(); stri(3); break;
	default: p--; return;
	}
	stkp--;
} /* end V */

W(  ) {

	Y( );
	sksps();
	switch(cop=*p++) {
	case '*': W( ); stri(13); break;
	case '/': W( ); stri(14); break;
	case '%': W( ); stri(14);stri(4082); break;
	default: p--; return;
	}
	stkp--;
} /* end W */


Y(  ) {
	int o,ctx,ixf;
	int txbf[10];

	sksps();

	if (!*p)
		return;

	if (cop) {
		stri(19);
		stkp++;
		cop=0;
	}

	if (*p=='"') {
		stri(10);
		stri(ltpt-ltbf);
		while (*++p-'"') 
			*ltpt++=*p;
		*ltpt++=0;
		p++;
		return;
	}
	if(isdigit(*p)) {
		stri(4);
		p=p+atoi(p,&tmp);
		stri(tmp);
		return;
	}
	ixf=izf=idf=0;
	if (!getsym()) {
		switch (*p++) {
			case '&':
				getsym();
				stri(21);
				stri(fndlcl(tkbf));
				return;
            case '*':
                getsym();
                if (*tkbf) {
                    ixf++;
                    break;
                }
                J();
                if (*p=='=') {
                    stri(19);
                    stkp++;
                }
                else 
                    stri(22);
                return;
			case '!':
				Y();
				stri(26);
				return;
			case '~':
				Y();
				stri(4070);
				return;
	        case '`':
		        stri(29);
                return;
			case '(':
				S();
				return;
			case ')':
				return;
            case '+':
                if (*p=='+') {
                    izf=-15;
                    p++;
                    getsym();
                    break;
                }
                Y();
                break;
            case '-':
                 if (*p=='-') {
                    izf=-25;
                    p++;
                    getsym();
                    break;
                }
               Y();
                stri(27);
                return;
            case '=':
                stri(40);
                Y();
                opeq++;
            case ';':
                return;
		}
	}
    if(*p=='('){
        strcpy(txbf,tkbf);
        ctx=o=0;p++;
        sksps();
        while (*p && !o && *p-')') {
            o=S( );
            ckop();
            stkp++;
            stri(19);
            ctx++;		/* arg count */
        }
        ckop();
        if (!ctx)
            p++;
        stri(9);
        stri(ctx);
        stkp-=ctx;
        if ((o=strstr(gm,txbf))){
            stri(o-gm);
        }
        else {
            stri(gsz);
            strpad(txbf);
            strcat(gm,smbf);
            gsz=gsz+9;
        }
        ccm=0;
        return;
    }
	/* Digraphs */

	q=p+1;
	if (tmp=*q==*p) 
		switch (*p) {
		case '+':
			izf=15;
			p=p+2;
			break;
		case '-':
			idf=-tmp;
			p=p+2;
			break;
	}

	o=fndlcl(tkbf);
	tmp=-17;
	if (ssz>1) {
        if (*p=='[') {
            stri(21);
            stri(o);
            stri(19);
            stkp++;
            p++;S();
            stri(2);
            if (ixf)
                stri(22);
            if (*p=='=')
                stri(19);
            else {
                stri(22);
                stkp--;
            }
            ixf=0;
			return;
		}
		tmp=21;
	}
	switch (*p) {
		case '=':
            if (izf<0)
                break;
			tmp=8;
			if (ixf && ssz==1)
				tmp=-8;
			ixf=0;
			stkp++;
	}
	stri(tmp);
	stri(o);
	if (izf)
		stri(izf);
	if (idf)
		stri(25);
	if (ixf)
		stri(22);
} /* end Y */

popfr()
{
	while (*fptr==inproc) {
		cbrk=*--fptr;
		stri(23);
        fptr--;
        if (*dptr) {
            stri(*dptr);
            *dptr=0;
        }
        else
		    stri(*fptr);
		stri(5);
		stri(*fptr+2);
		fptr--;
	}
}

gtexp2()
{
    q=bfr;
    mkr=0;
    while (1) {
        tm=*q=gtch();
        if (tm=='"')
            mkr=!mkr;
        if (mkr) {
            q++;
            continue;
        }
        if (mode==1)
            switch (*q) {
        case '(':
            *q=0;
            stri(7);
            stri(gsz);
            strcpy(tkbf,bfr);
            if (strstr("main",tkbf))
                strcpy(tkbf,"XMAIN");
            addsym(tkbf,1,1);
            q=p;
            ctr=2;
            while(*q)
                if (*q++==',')
                    ctr++;
            stkp=-ctr;
            sksps();
            while (*p-')') {
                if (getsym()) {
                    addsym(tkbf,-1,1);
                    stkp=stkp+2;
                }
                else
                    p++;
            }
            mode=0;
            stkp=0;             /* Setup for locals */
            cbrk=200;			/* No break at top level */
            p++;
            return;
        case ';':
            *q=0;
            dodecl();
            mode=0;
            return;
        }
        else
        switch(*q) {
        case '{':
            inproc++;
            dptr++;
        case ';':
            *q=ctr=mode=0;
            return;
        case '}':
            popfr();
            inproc--;
            dptr--;
            *q=0;
            if (!inproc) {
                stri(5);
                stri(ectr++);
                stri(16);
                stri(-stkp);
                stkp = *lm = 0;
            }
            return;
        }
        q++;
    }
}


getsym()
{
    q=tkbf;
    skpsp();
    while (isalnum(*p))
        *q++=*p++;
    *q=0;
    tm=*p;
    if (*p)
        skpsp();
    return *tkbf;
}


cmst()
{
    do {
        ccm=0;
        S();
        ckop();
     } while (ccm);
}


dodecl()
{

    if (ctr)
        return;             /* No dec from func arg list */

    p=bfr; 
    while (*p) {
        vl=vf=1;
        getsym();
        strcpy(tmbf,tkbf);
        if (*p)
        switch (*p++) {
            case '=':
                Y();
                stri(19);
                vf=0;
                break;
            case '[':
                p=p+atoi(p,&vl)+1;
                sksps();
                if (*p=='=') {
                    p++;
                    sksps();
                    while (*p++-'}') {
                        Y();
                        sksps();
                        stri(19);
                        vl++;
                    }
                    vf=0;
                }
        }
        if (*tmbf) 
            addsym(tmbf,vl,vf);
        sksps();
    }
}



main()
{
    int i,fflg;

    memset(ltbf,0,tmbf-ltbf);
    fopen("CC.CC","r");
    strcpy(tkn,"int   if    else  while for   break returndo    ");
	lctr = 10;
	ectr = 900;
	ltpt = ltbf;
	fptr = fstk;
    dptr = dstk;
	*fptr = 4095;
	gadr = 128; /* Start of globals */
	iinit(128);
    ppflg++;
    getln();
    while (1) {
        fflg=lctr;
        stri(99);
        mode=0;
        if (getsym()) {
            strpad(tkbf);
            smbf[6]=0;
            if (q=strstr(tkn,smbf))
                mode=1+(q-tkn)/6;
        }
        if (ppflg && mode-3)
            popfr();
        switch (mode) {
            case 0:
                gtexp2();
                strcat(tkbf,bfr);
                strcpy(bfr,tkbf);
                n=p;
                p=bfr;
                cmst();
                p=n;
                if (*p)
                    ppflg++;
               break;
            case 1:
                gtexp2();
                break;
            case 3:
                stri(4073);
                stri(400+lctr+2);
                popfr();
                *++fptr=400+lctr++;
                *++fptr=cbrk;
                *++fptr=inproc;
                ppflg=0;
                break;
            case 2:
				fflg=fflg+400;
            case 4:
				stri(5);
				*++fptr=fflg;
				stri(fflg);
                ppflg=0;
                p++;
				cmst();
				stri(12);
				stri(tm=*fptr+2);
				*++fptr=cbrk;
				if (fflg<400)
					cbrk=tm;
				*++fptr=inproc;
				lctr=lctr+3;
				tm=0;
               break;
            case 5:
				cmst();
				stri(5);
				stri(lctr++);
				*++fptr=lctr;
				cmst();
				stri(12);
				stri(lctr+2);
				stri(23);
				stri(lctr+1);
				stri(5);
				stri(lctr++);
				cmst();
				*++fptr=cbrk;
				*++fptr=inproc;
				stri(23);
				stri(lctr-2);
				stri(5);
				stri(lctr++);
				cbrk=lctr++;
				tm=ppflg=0;
                break;
            case 6:
                stri(23);
                stri(cbrk);
                ppflg++;
                break;
            case 7:
			    S();
				stri(4073);     /* -23 */
				stri(ectr);
                ppflg++;
                break;
            case 8:
                stri(5);
                stri(*dptr=lctr+++200);
        }
    }
}
