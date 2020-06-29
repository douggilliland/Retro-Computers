#define ASVENO 1        /* assembler version number     */
#define NUMEXT  500     /* max. number of external refernces */
#define NINCL 10        /* max # of recursive includes - 2 */
#define NUMSYM 800      /* max # of symbols     */
#define NUMGLOB 70      /* max # of globals     */
#define NUMLOAD 15      /* max. # of force loaded moduals       */
#define NUMMAC 35       /* max # of macros      */
#define NCIM 400        /* max # of charactors in a macro       */
#define MAXED 60        /* max. # of external variables */
#define NINTVAR 1       /* number of internal variables */
#define ABS 0           /* absolute psect               */
#define TEXT 1          /* text psect                   */
#define DATA 2
#define BSS 3
#define STACK 4


/*
*
*       6809 relocatible macro assembler
*
*       Peter D Hallenbeck
*
*       (c) copyright May, 1979
*
*/
#include "putchar.c"
#include "getchar.c"
#include "printf.c"


        int clobber;            /* this variable gets clobbered */
        int symll;              /* last index of symbol table   */
        char symn[NUMSYM*8];    /* names of symbols             */
        int symv[NUMSYM];       /* values for the symbols       */
        char symp[NUMSYM];      /* psect of the symbol          */

        int mbody[NUMMAC];              /* macro body table*/
        char mmbody[NUMMAC*70];
        int mdef[NUMMAC];               /* macro name definition table */
        char mmdef[NUMMAC*10];
        int edtab[MAXED];               /* external definition table */
        char eedtab[MAXED*9];
        int exrtab[NUMEXT];     /* ext. ref. index to name of ext. */
        int exatab[NUMEXT];     /* ext. ref. tab. phys. address in program */
        char exptab[NUMEXT];    /* ext.ref. pshs. addr. psect   */
        int rrtab[NUMEXT];      /* ext. relative ref. index     */
        int ratab[NUMEXT];      /* ext. rel. tab. phys. address */
        char rptab[NUMEXT];
        int globs[NUMGLOB];     /* global symbol table  */
        char gglobs[NUMGLOB*8];
        int loadtab[NUMLOAD];   /* force loaded modaul table    */
        char lloadtb[NUMLOAD*7];

        char *MI = "Missing operhand";  /* error messages */
        char *BL = "Lables can't start with '$' or '%'.";
        char *IDIN = "Invalid digits in number";
        char *SYN = "Bad Syntax";
        char *UND = "Undefinded symbol";
        char *UCS = "%%%%\t%s\n";
        char *SOI = "Only on operhand allowed.";


        extern char *soptab[],*mot[],*mot10[],*mot11[],*spmot[];
        extern char spmots[],spmotd[][6];
        extern char mvt[][6],mlt[],lmlt10[],lmlt11[];

        int pc[16];     /* program counter      */
        int psect;      /* current psect                */
        int spsect;     /* symbol psect (operhand psect)        */
        int pass;       /* pass number          */
        char rlpass[24];/* nested pass # for macro lables hack  */
        int lineno;     /* line number          */
        int passend;    /* end of pass flag     */
        int poe;        /* Point of Entry (or, Pasos on Everthing) */
        int stlen;      /* symbol table lenght  */
        int mtlen;      /* macro table lenght   */
        int filler[2];          /* gard space for errors */
        int prebyte;    /* prebyte definition   */
        int b1,b2,b3,b4,b5,b6,fb2,fb3,fb4,fb5,fb6;
        int fd;         /* file descriptor */
        int pcolpc;     /* last pc      */
        int pcoch;      /* checksum     */
        int pcocnt;     /* punch out count */
        int pcob[34];   /* punch buffer */
        int pcobs;      /* p.o. buffer start location   */
        int pcobsp;     /* p.o. buffer start psect      */
        int pcost;      /* start-up flag */
        char ppsect[34]; /*punch buffer psect                   */
        int numerrs;    /* number of errors in a pass */
        int nestc;      /* nested stack level counter */
        char *nest[50]; /* nested stack stack */
        int ifcount;    /* nested if counter */
        int relob;      /* relocation bits      */
        int symtabr;    /* symbol table referance counter       */
        int relocate;   /* relocatoion flag     */
        int exttabr;    /* ext. ref. table flag */
        int extrtp;     /* ext. ref. table next entry pointer */
        int rtrtp;      /* ext. rel. ref. table next entry ponter */
        int curbase;    /*  current radix for numbers   */
        int macnest;    /* nested macro counter         */
        int macstack[50];/*nested macro variable list stack pointer*/
        char listflag;  /* flag for list suppression            */
        char macflag;   /* 0 = list expanded macro code */
        char binflag;   /* flag for supprision of binary out    */
        char sorflag;   /* flag to turn of sort on symbol table */
        char malflag;   /* master list control flag     */
        char mabflag;   /* master binary output control flag    */
        char mamflag;   /* master macro expand control flag     */
        char exflag;    /* undefined = automatic external flag  */
        char dbuff[513];/* object output data buffer    */
        int dbuffc;     /*  "      "   buffer charactor counter */
        int ifd[NINCL]; /* 'include' file descriptors   */
        int ifdc;       /* counter for 'include' file descriptors */
        char ibuff[513];/* 1st include file buffer      */
        char *ibuffp;   /* 1st include file buffer pointer      */
        int ibuffc;     /* 1st include file buffer counter      */
        char indir;     /* indirect flag        */
        char p2evnf;    /* p2 evaluate number is valid flag */
        int p2evnn;     /* p2 evaluate number data return   */
        char bytef;     /* control listing of byte commands (ds,db)*/
        char bytep;     /* current postitin for byte listing    */


main(argc,argv)
        int argc;
        char **argv;
{
        char line [121];
        register char *k,c;
        register i;
        char arg[22];
        int j,bc,s;
        int ii,jj;
        int **ss;
        char b;
        int *kaboom;
        int tvec[3];

        if(argc == 1){
                printf("Usage: as09 filename\n");
                flush();
                return;
                }

        pass = 1;
        lineno = 0;
        passend = 1;
        poe = 0;
        extrtp = 0;
        rtrtp = 0;
        symv[0] = 0;
        symp[0] = 0;
        stlen = 1;
        mtlen = 1;
        macnest = 0;
        curbase = 10;
        listflag = 1;
        macflag = 0;    /* enable listing of expanded macro code */
        binflag = 0;
        malflag = 1;    /* master list flag, like listflag      */
        mamflag = 0;    /* master macro list flag, like macflag */
        mabflag = 0;    /* master binary list flag, like binflag.  */
        exflag = 0;     /* undefined = error, not auto. external  */
        sorflag = 1;    /* enable sort of symbol table */
        bytef = 1;      /* enable listinf of byte inst. ds,db */
        dbuffc = 0;
        ifdc = 0;
        ibuffc = 0;     /* zero 1st include buffer counter */
        symll = 0;      /* symbol table is zero                 */

        mixerup(mbody,mmbody);
        mixerup(mdef,mmdef);
        mixerup(edtab,eedtab);
        mixerup(globs,gglobs);
        mixerup(loadtab,lloadtb);
        pcocnt = 0;
        pcolpc = 0;
        k = symn;
        for(i = 0;i != 8*NUMSYM;i++)*k++ = 0;

        psect = ABS;
        spsect = ABS;
        for(i = 0;i != 16;i++)pc[i] = 0;
        symv[0] = 0;
        numerrs = 0;
        nestc = 0;
        fin = open(argv[1],0);
        if(fin == -1){
            printf("Can't find '%s'.\n",argv[1]);
             return;
             }

/* proccess user specified options for the assembly */
    if(argc > 2){
        for(i = argc-1;i > 1;i--){
            if(argv[i][0] == '-'){
                j = 1;
                while(argv[i][j] != '\0'){
                    switch(argv[i][j]){
                        case 'l':               /* no listing   */
                            malflag = 0;
                            break;
                        case 's':               /* no symbol sort */
                            sorflag = 0;
                            break;
                        case 'b':               /* no binary out */
                            mabflag = 1;
                            break;
                        case 'm':               /* no macro listing */
                            mamflag = 1;
                            break;
                        case 'u':               /* auto-extern on */
                            exflag = 1;
                            break;
                        default:
                            printf("Bad option- '%c'.\n",argv[i][j]);
                        }
                    j++;
                    }
                }
            }
        }

/* Enter various user-type symbols into symbol table    */
        fsyms(".");

foobar: while(passend){         /* in memory of AI Lab  */
        getline(line);
        cline(line);            /* get and process line */
        }
        if((pass == 2) && !mabflag){
                if(pcocnt)pdump();
                while(loadtab[1] != -1){
                        dput('S');      dput('3');
                        k = loadtab[1];
                        while(*k)dput(*k++);
                        dput('\n');
                        chisel(1,loadtab);
                        }
                j = 1;
                while(globs[j] != -1){
                        if((i = fsyml1(globs[j])) == -1){
                                panic("Undefined global:");
                                printf(UCS,globs[j]);
                                }
                            else {
                                dput('S');      dput('4');
                                pdumb((symv[i] >> 8) & 0377);
                                pdumb(symv[i] & 0377);
                                pdumb(symp[i]);
                                k = globs[j];
                                while(*k)dput(*k++);
                                dput('\n');
                                }
                        j++;
                        }
                dput('S');
                dput('6');
                pdumb(poe >> 8);        pdumb(poe & 0377);
                dput('\n');
                i = 0;
                while(i < extrtp){
                    dput('S');
                    dput('7');
                    pdumb((exatab[i])>> 8);
                    pdumb(exatab[i] & 0377);
                    pdumb(exptab[i]);
                    k = edtab[exrtab[i]];
                    while(*k != '\0'){
                        dput(*k++);
                        }
                    dput('\n');
                    i++;
                    }
                for(i = 0;i !=  16;i++){        /* dump lenghts */
                    if(pc[i]){
                        dput('S');  dput('8');
                        pdumb((pc[i]>>8) & 0377); pdumb(pc[i] & 0377);
                        dput('0');  dput(i + '0');  dput('\n');
                        }
                    }
                i = 1;          /* dump symbols */
                while(i < symll){
                    if(llu(k = &symn[i*8],globs) == -1){
                        dput('S');      dput('A');
                        pdumb((symv[i] >> 8) & 0377);
                        pdumb(symv[i] & 0377);
                        pdumb(symp[i]);
                        ii = 0;
                        while((*k != '\0') && (ii < 8)){dput(*k++);ii++;}
                        dput('\n');
                        }
                    i++;
                    }
                i = 0;
                while(i < rtrtp){
                    dput('S');
                    dput('B');
                    pdumb((ratab[i])>> 8);
                    pdumb(ratab[i] & 0377);
                    pdumb(rptab[i]);
                    k = edtab[rrtab[i]];
                    while(*k != '\0'){
                        dput(*k++);
                        }
                    dput('\n');
                    i++;
                    }
                dput('S');
                dput('9');
                dput('\n');
                fdput();
                flush();
                close(fd);
                flush();
                }
        if(pass == 2){
                fout = 1;
                if(numerrs){
                   printf("%d error%s\n",numerrs,numerrs==1?"":"s");
                        }
                flush();
                if(numerrs)exit(-1);
                exit(0);
                }
        while(getchar() != -1);
        lseek(fin,0L,0);
        flush();
        if(malflag){
                k = argv[1];    i = 0;
                while(line[i++] = *k++);
                cats(line,".lst");
                fout = creat(line,0644);
                }

        if(!mabflag){
                k = argv[1];    i = 0;
                while(line[i++] = *k++);
                cats(line,".rel");
                fd = creat(line,0644);
                dput('S');      dput('0');
                k = argv[1];
                while(*k)dput(*k++);
                dput('\n');
                }

        pass = 2;
        lineno = 0;
        passend = 1;
        psect = 0;
        for(i = 0;i != 16;i++)pc[i] = 0;
        pcocnt = 0;
        relob = 0;
        relocate = 0;
        exttabr = 0;
        pcost = 1;
        numerrs = 0;
        nestc = 0;
        listflag = 1;
        macflag = 0;
        bytef = 1;
        goto foobar;
}


getline(line)
        char *line;
{
        register char *k;
        register char c;
        register i;
        int p,j;

getlinl: if(nestc){
                c = *nest[nestc]++;
                }
           else {
                c = gchar();
                if(ifdc == 0)lineno += 1;
                }
        k = line;
        i = 0;
        while((c != '\n')&&(c != -1)&&(c != '\0')&&(i < 119)){
                *k++ = c;
                i++;
                if(nestc)c = *nest[nestc]++;
                   else c = gchar();
                }

        if(i >= 119){
                panic("Warning- input line too long.  Line truncated");
                k--;    *k = '\0';
                while((c != '\n')&&(c != '\0')&&(c != -1)){
                        if(nestc)c = *nest[nestc]++;
                            else c = gchar();
                        }
                }
        if((c == -1)||(c == '\0')){
                if(ifdc == 0){
                        panic("No end statement");
                        passend = 0;
                        line[0] = '\0';
                        }
                    else {
                        if(ifdc == 1)ibuffc = 0;
                        close(ifd[ifdc--]);
                        goto getlinl;
                        }
                }
        if(c == '\n'){
                *k++ = ';';
                *k = '\0';
                }
}

gchar()
{
        char data;
        int count;

        if(ifdc){
                if(ifdc == 1){
                        if(ibuffc == 0){
                                ibuffc = read(ifd[ifdc],&ibuff[0],512);
                                ibuffp = ibuff;
                                if(ibuffc == 0)return(-1);
                                }
                        ibuffc--;
                        return(*ibuffp++);
                        }
                    else {
                        count = read(ifd[ifdc],&data,1);
                        if(count == 0)data = -1;
                        }
                }
            else data = getchar();
        return(data);
}

mexp(body,arglist,flag)
        char *body,**arglist;
        int flag;
{
        char line[120];
        char bline[NCIM];
        register char *p,*k,c;
        int i,j;
    if(flag != 0){
        k = bline;
        while(*body != '\0'){
                switch(c = *body++){
                        case '&':
                            if(flag){
                                c = *body++;
                                if(c >= 'A'){
                                        line[0] = c;
                                        line[1] = '\0';
                                        j = fsyml1(line);
                                        if(j == -1){
                                                panic("Undef?");
                                                j = 1;
                                                }
                                        j = symv[j];
                                        i = *body++ - '0';
                                        *k++ = arglist[i][j];
                                        }
                                  else {
                                        i = c - '0';
                                        p = arglist[i];
                                        while(*k++ = *p++);
                                        k --;
                                        }
                                }
                                else {
                                   *k++ = c;
                                   }
                                break;
                        case '\\':
                                if((*body == '&')&&flag){
                                        *k++ = '&';
                                        body++;
                                        }
                                else *k++ = c;
                                break;
                        default:
                                *k++ = c;
                        }
                }
        *k = '\0';
        k = bline;
        }
    else k = body;
        nestc++;
        while(*k != '\0'){
                p = line;
                while((*p++ = *k++)!= '\n');
                *p = '\0';
                nest[nestc] = k;
                cline(line);
                k = nest[nestc];
                }
        nestc--;
}


dumpst()
{
        register *p;
        register i;
        register char *k;
        int j,jj,w;

        if(!malflag)return;
        if(sorflag){
/*
                alsort2(stable,symv);
*/
                }
        i = 1;
        j = 1;
        while(i < symll){
                jnum(symv[i],16,4,0);
                putchar(' ');
                k = &symn[i*8];
                i++;
                w = 0;
                while((w < 8) && *k){
                        putchar(*k++);
                        w++;
                        }
                while(w < 14){putchar(' ');w++;}
                if((j++ % 3) == 0)putchar('\n');
                    else printf("     ");
        }
        putchar('\n');
}

commaerr(ss)
        char **ss;
{
        eatspace(ss);
        if(**ss == ','){
                (*ss)++;
                panic(MI);
                }
        eatspace(ss);
        while(**ss == ','){
                (*ss)++;
                eatspace(ss);
                }
}

panic(s)
        char *s;
{
        putchar('%');   putchar('%');
        jnum(lineno,10,4,0);
        printf(": %s\n",s);
        numerrs += 1;
}

eqs(c)
        char c;
{
        return(((c == '\n')||(c == ';')));
}

neqs(c)
        char c;
{
        return((c != '\n')&&(c != ';'));
}

p1cnc(p)                /* count # of commas for pass 1 stuff */
        char **p;
{
        register i;
        i = 1;
        eatspace(p);
        if(eqs(**p)){
                panic(MI);
                return(1);
                }
        while(neqs(**p)){
                if(**p == ','){
                        i++;
                        (*p)++;
                        if(**p == ','){
                                while(*(*p)++ == ',')i++;
                                panic(SYN);
                                }
                        }
                (*p)++;
                }
        return(i);
}

p2evn(p)                /* evaluate numbers for pass 2 */
        char **p;
{
        p2evnn = 0;
        eatspace(p);
        if(eqs(**p)){
                p2evnf = 0;             /* signal end of data */
                return;
                }
        if(**p == ',')(*p)++;
        p2evnn = evolexp(p);
        p2evnf = 1;
        return;
}

prn()
{
    register i;
    if(!ifdc && listflag && malflag && !(nestc && macflag && mamflag)){
        jnum(lineno,10,4,0);
        putchar(' ');
        jnum(pc[psect],16,4,0);
        printf("  ");
        if(prebyte)phexd(prebyte);
                else printf("  ");
        b1 &= 0377;
        phexd(b1);
        putchar(' ');
        if(fb2)phexd(b2);
                else printf("  ");
        if(fb3)phexd(b3);
                else printf("  ");
        if(fb4)phexd(b4);
                else printf("  ");
        printf(" ");
        }
    pbytes();
}

prsn(n)                         /* print a single number */
        int n;                  /* used with equ stuff */
{
        if(!canlist())return;
        jnum(lineno,10,4,0);
        printf("            ");
        jnum(n,16,4,0);
        printf("   ");
}

prsnb()                         /* print the single byte in b1 */
{
    if(bytef && canlist()){
        if(bytep == 0){
                prspc();
                putchar(' ');
                }
        phexd(b1);
        putchar(' ');
        if(bytep++ >= 15){
                putchar('\n');
                bytep = 0;
                }
        }
}
/* note: can end line correctly via: "if(bytep)putchar('\n');"   */
/* Note also that bytep must be zero for correct start up        */

prs()
{
     if(canlist()){
        jnum(lineno,10,4,0);
        printf("                   ");
        }
}

prspc()
{
     if(canlist()){
        jnum(lineno,10,4,0);
        putchar(' ');
        jnum(pc[psect],16,4,0);
        printf("              ");
        }
}
prl(line)
        char *line;
{
        register char *k;
        register char delay;
        if(!canlist())return;
        k = line;
        putchar (' ');
        if(*k == '\0')return;
        if(line[1] == '\0')return;
        delay = *k++;
        while(*k != '\0'){
                putchar(delay);
                delay = *k++;
                }
        putchar('\n');
}

prsl(line)
        char *line;
{
        if(!canlist())return;
        prs();
        prl(line);
}

canlist()
{       return(listflag && malflag && !ifdc & !(nestc && macflag && mamflag));
}
pbytes()
{
        if(binflag)return;
        if(mabflag)return;
        if(pcost){
                pcost = 0;
                pcolpc = pc[psect];
                }
pbyteq: if(pcocnt == 0){
                pcolpc = pc[psect];
                pcobs = pc[psect];
                pcobsp = psect;
                }
        if(pc[psect] != pcolpc){
                pdump();
                goto pbyteq;
                }
        if(prebyte){
            pcob[pcocnt]= prebyte;      /* if prefix byte */
            ppsect[pcocnt++] = psect;
            pcolpc++;
            relob = relob << 1;
            }
        pcob[pcocnt]= b1;
        relob <<= 1;
        if(relocate == 1){
                relob |= 1;     ppsect[pcocnt++] = spsect;
                }
           else ppsect[pcocnt++] = psect;
        pcolpc += 1;
        if(fb2){
            pcob[pcocnt] = b2;  /* enter bytes */
            pcolpc += 1;
            relob <<= 1;
            if(relocate == 2){
                relob |= 1;     ppsect[pcocnt++] = spsect;
                }
            else if(relocate == 1)ppsect[pcocnt++] = spsect;
                else ppsect[pcocnt++] = psect;
            }
        if(fb3){
            pcob[pcocnt] = b3;
            pcolpc += 1;
            relob <<= 1;
            if(relocate == 3){
                relob |= 1;     ppsect[pcocnt++] = spsect;
                }
            else if(relocate == 2)ppsect[pcocnt++] = spsect;
                else ppsect[pcocnt++] = psect;
            }
        if(fb4){
            pcob[pcocnt] = b4;
            pcolpc += 1;
            relob <<= 1;
            if(relocate == 3)ppsect[pcocnt++] = spsect;
                else ppsect[pcocnt++] = psect;
            }
        if(fb5){
            pcob[pcocnt] = b5;
            pcolpc += 1;
            relob <<= 1;
            ppsect[pcocnt++] = psect;
            }
        if(pcocnt > 10){
            pdump();            /* if line is full */
            return;
                }
}
/*      Note: relocation bits are a right-justified template
                for the bytes                                   */

pdump()
{
        register i;
        int j;
        dput('S');      dput('2');
        i = 0;
        pcoch = 0;
        pdumb(pcocnt+5);
        pdumb(relob >> 8);
        pdumb(relob & 0377);
        pdumb(pcobs >> 8);
        pdumb(pcobs & 0377);
        pdumb(pcobsp);
        while(pcocnt){
                pdumb(ppsect[i]);
                pdumb(pcob[i++]);
                pcocnt--;
                }
        pdumb(~pcoch);
        dput('\n');
        relob = 0;
}

pdumb(n)
        int n;
{
        int     i;
        register j;
        i = n;
        i = (i & 0360)>>4;
        dput(phexdm(i));
        i = n & 017;
        dput(phexdm(i));
        pcoch += n;
}

dput(data)
        char data;
{
        dbuff[dbuffc++] = data;
        if(dbuffc == 512){
                write(fd,&dbuff[0],512);
                dbuffc = 0;
                }
}

fdput(){
        if(dbuffc)write(fd,&dbuff[0],dbuffc);
}


phexd(n)
        int n;          /* type a hex byte      */
{
        register i,j;
        i = n;
        i = (i & 0360) >> 4;
        putchar(phexdm(i));
        i = n & 017;
        putchar(phexdm(i));
}

phexdm(i)
        int i;
{
        i += '0';
        if(i > '9')i += ('A' - ('9' + 1));
        return(i);
}

ppb(c)
        char c;         /* return push/pull bit for register */
{
        switch(c){
                case 'a':
                        return(2);
                case 'b':
                        return(4);
                case 'x':
                        return(020);
                case 'p':
                        return(0200);
                case 'u':
                        return(0100);
                case 'y':
                        return(040);
                case 'c':
                        return(1);
                case 'd':
                        return(6);
                case 'z':
                        return(010);    /* direct page register */
                }
        panic("Bad psh/pul register operhand");
}

ibr(c)
        char c;
/*                      return bits for index stuff     */
{
        switch(c){
        case 'x':
                return(0);
        case 'y':
                return(1);
        case 'u':
                return(2);
        case 's':
                return(3);
        }
        panic("Bad index register");
}

setpre(s)
        char *s;
{
        if(llu(s,mot10) != -1)prebyte = 16;
        if(llu(s,mot11) != -1)prebyte = 17;
}

tfrb(c)
        char c;
{
        switch(c){
                case 'd':
                        return(0);
                case 'x':
                        return(1);
                case 'y':
                        return(2);
                case 'u':
                        return(3);
                case 's':
                        return(4);
                case 'p':
                        return(5);
                case 'a':
                        return(010);
                case 'b':
                        return(011);
                case 'c':
                        return(012);
                }
        panic("Bad tfr/exg register operhand");
        return(0);
}

opsize(k)               /* see if operhand is a simple single number */
        char **k;
{
        register i;
        register char *p,*sp;
        char iflag;

        p = *k;                 /* get copy of pointer */
        sp = p;
        iflag = 0;
        if(*p == '['){
                iflag = 1;
                p++;
                }
        if(*p == ',')return(0);         /* indexed, no offset */
        if(*(p+1) == ','){
                if((*p == 'a')||(*p == 'b')||(*p == 'd'))
                        return(0);      /* register offset */
                }
        if(*p == '-')p++;
        if(islet(*p) == 0){
                p++;
                while((*p != ',')&&(*p != ';')&&(*p != '\n')){
                    if(island(*p++) != 1)return(2);     /* not number*/
                    }
                i = evolexp(k); /* evaluate number */
                *k = sp;        /* restore pointer for world    */
                if(i < 0)i = -i;
                if(i <16){
                        if(iflag)return(1);
                        return(0);
                        }
                if(i < 128)
                        return(1);
                return(2);
                }
        return(2);
}

swapit(ss)
        char *ss;
{
        register char *s;
        s = ss;
        if(*s != '-')return;
        if(*(s+1) == '-'){      /* --R case */
                *s = *(s+2);
                *(s+1) = *(s+2) = '-';
                return;
                }
        *s = *(s+1);    /* -R case */
        *(s+1) = '-';
}

/*
        get an A/N argument from the current string and return in arg
        return 1 if got something, return 0 if got nothing.
*/
getarg(ss,arg)
        char **ss;
        char arg[];
{
        register char *p;
        eatspace(ss);
        p = arg;        *p = '\0';
        if(**ss == ','){
                (*ss)++;                /* step over comma */
                eatspace(ss);
                if(eqs(**ss)){
                        panic(MI);
                        return(0);
                        }
                }
        commaerr(ss);
        if(eqs(**ss))return(0);
        while(island(**ss)){
                *p++ = *(*ss)++;
                }
        *p = '\0';
        return(1);
}

cline(line)
        char *line;
{
        char arg[21];
        char sarg[21];
        char lline[NCIM];
        char llline[100];
        int s;
        char **ss;
        char *savess;           /* ss save space */
        char ncount;            /* # extra bytes for index stuff */
        char fasciz;    /* Flag for asciiz, creates zero bytes */
        int hlable;
        int hclable;
        int hdclable;
        int ii,jj;
        int marg[10];
        char mmarg[100];
        int maclab[15];         /* macro lable save table       */
        int mmaclab[116];
        register char c;
        register i,j;

        hlable = 0;
        hclable = 0;
        hdclable = 1;
        mixerup(marg,mmarg);
        mixerup(maclab,mmaclab);
        s = line;
        ss = &s;
        arg[0] = '\0';
        symv[0]++;
        fasciz = 0;
        bytep = 0;
        p2evnf = 1;                     /* prive p2evn() func.  */
        symv[0] = pc;
        spsect = ABS;

        if( pass == 1 )  {


   if(islet(**ss)== 1){
        if((i = (sscan(arg,ss)))== ':'){
p1hslb:         (*ss)++;                        /* ignor : */
                hclable = 1;
                if(**ss == ':'){        /* ::   */
                        (*ss)++;
                        hdclable = 0;
                        }
                }
        eatspace(ss);
        if(i == -1){
                panic("Missing Opcode");
                goto eocline;
                }
        if((i = fsyml1(arg))!= -1){
            if(**ss == '='){
                (*ss)++;
                j = i;
                sarg[0] = arg[0];       sarg[1] = arg[1];
                goto p1plwas;
                }
              else
            if(i > NINTVAR){
                panic("Double defined symbol:");
                printf(UCS,arg);
                }
            }
        if(i == -1){
            if((arg[0] == '$')||(arg[0] == '%')){
                panic(BL);
                }
              else {
                i = fsyms(arg); /* put into stable */
                symp[i] = psect;
                symv[i] = pc[psect];
                hlable ++;
                if(macnest && (hdclable || rlpass[macnest] == 1))
                        cement(arg,macstack[macnest]);
                if(**ss == '='){        /* create and assing */
                        (*ss)++;
                        j = i;
                        sarg[0] = arg[0];       sarg[1] = arg[1];
                        goto p1plwas;
                   }
                }
            }
      }
   else {
        if((**ss == ';')||(**ss == '*'))goto eocline;
        if((**ss != ' ')&&(**ss != '\t')){
                if(**ss == '\n')goto eocline;
                panic("Invalid lable");
                eatspace(ss);
                if(**ss == '\n')goto eocline;
                }
        }
   i = sscan(sarg,ss);          /* get opcode/psydo-op  */
   if(i == ':'){
        copystr(arg,sarg);
        goto p1hslb;            /* mutiple lable per line case */
        }
   if(sarg[0] == '\0'){
        goto eocline;
        }
   eatspace(ss);
   if(**ss == '='){                     /* .= or symb = expr    */
        (*ss)++;                        /* skip =               */
        if((j = fsyml1(sarg)) == -1){
                panic(UND);
                goto eocline;
                }
p1plwas:
        symv[j] = evolexp(ss);
        symp[j] = spsect;
        if((sarg[0] == '.')&&(sarg[1] == '\0')){
                pc[psect] = symv[j];
                }
        goto eocline;
        }

   if((j = llu(sarg,mdef))!= -1){       /* if macro     */
        p1mac:  ii = 0;
        eatspace(ss);
        hlable = 0;
        while(neqs(**ss)){
            jj = 0;
            llline[0] = '\0';
            while((**ss != ',')&&(neqs(**ss))){
                llline[jj++] = *(*ss)++;
                }
        llline[jj]= '\0';
        if(jj > 80)panic("Too many charactors in macro arg.");
          else cement(llline,marg);
        if(**ss == ',')(*ss)++;
        eatspace(ss);
        if(hlable++ > 9)panic("Too many macro arguments");
        eatspace(ss);
        }
        while(hlable++ < 10)cement("",marg);
        macstack[++macnest]= maclab;
        rlpass[macnest] = pass;
        if(pass == 2){
            pass = 1;
            i = pc[psect];
            mexp(mbody[j],marg,1);
            pass = 2;
            pc[psect] = i;
            mexp(mbody[j],marg,1);
            }
          else mexp(mbody[j],marg,1);
        --macnest;
        while(maclab[1] != -1){
            if((i = fsyml1(maclab[1])) != -1){
                symn[i] = '\0';
                }
            chisel(1,maclab);
            }
        goto eocline;
        }
  else
   if((j = llu(sarg,soptab))!= -1){             /* pysdo op     */

     switch(j){

      case 1:                                   /* equ          */
  p1equ:  if(arg[0]== '\0'){panic("EQU with no symbol");goto p1equa;}
        eatspace(ss);
        if((i == -1) || eqs(**ss)){
                panic(MI);
                i = fsyml1(arg);
                symn[i] = '\0';
                goto p1equa;
                }
        symv[i = fsyml1(arg)] = evolexp(ss);
        if(hlable > 1)panic("Only 1 lable per equ");
   p1equa:      if(pass == 2){
                        prsn(symv[i]);  prl(line);
                        }
        goto eocline;


     case 41:                                   /* .end */
     case 2:                                    /* end  */
        passend = 0;
        goto eocline;


     case 15:                                   /* fcb */
     case 31:                                   /* .byte */
     case 3:                                    /* db */
  p1db: if(i == -1){
                panic(MI);
                pc[psect] += 1;
                goto eocline;
                }
        pc[psect] += p1cnc(ss);         /* count number of commas */
        goto eocline;


    case 34:                                    /* asciiz */
    case 35:                                    /* asciz  */
        fasciz = 1;

   case 17:                                     /* fcc    */
   case 33:                                     /* .ascii */
   case 4:                                      /* ds     */
        eatspace(ss);
        if((i == -1)||eqs(**ss)){
                panic(MI);
                goto eocline;
                }
        while(neqs(**ss)){
            if(**ss != '"'){
                panic(SYN);
                goto eocline;
                }
            i = 0;
            (*ss)++;
            while((**ss != '"')&&(**ss != '\n')&&(**ss)){
                if(**ss == '\\'){
                        (*ss)++;
                        if(**ss == '^')
                                (*ss)++;        /* \^G for beep */
                        }
                (*ss)++;
                i++;
                }
            if((**ss == '\n')||(**ss == '\0'))
                panic("Missing \".");
            (*ss)++;
            if(fasciz)pc[psect]++;
            pc[psect] += i;
            eatspace(ss);
            if(**ss == ',')(*ss)++;
            eatspace(ss);
            }
        goto eocline;


   case 16:                                     /* fdb */
   case 32:                                     /* .word */
   case 5:                                      /* dw   */
   p1dw: if(i == -1){panic(MI);
                pc[psect] += 2;
                goto eocline;
                }
        pc[psect] += p1cnc(ss) << 1;            /* really p1cnc * 2 */
        goto eocline;


   case 6:                                      /* org  */
   p1org:       eatspace(ss);
        if((i == -1)||(eqs(**ss))){
                panic(MI);
                goto p1orga;
                }
        pc[psect] = evolexp(ss);
        eatspace(ss);
        if(**ss == ',')
          panic(SOI);
p1orgb: if(arg[0] != 0){
                if((j = fsyml1(arg))!= -1){
                        symv[j] = pc[psect];
                        symp[j] = psect;
                        }
                }
    p1orga:     if(pass == 2){
                        prspc();        prl(line);
                        }
        goto eocline;


   case 7:                                      /* eval */
        eatspace(ss);
        if((i == -1)||eqs(**ss)){
                panic(MI);
                goto eocline;
                }
        evolexp(ss);
        goto eocline;


   case 8:                                      /* entry        */
        eatspace(ss);
        if((i == -1)||eqs(**ss)){
                panic(MI);
                goto eocline;
                }
        goto eocline;


   case 9:                                      /* repeat */
 p1rep: eatspace(ss);
        if((i == -1)||eqs(**ss)){
                panic(MI);
                goto p1repa;
                }
        i = evolexp(ss);
        if(i < 0){
                panic("Can't repeat a negative number of times");
                i = 1;
                }
        if((pass == 2)&&(canlist()))prsl(line);
        getline(lline);
        if(i){
                cline(lline);
                i -= 1;
                }
        j = 0;
        while((lline[j]!= ' ')&&(lline[j] != '\t')&&(lline[j] != '\0'))
                lline[j++] = ' ';       /* blot out any lable */
        while(i--)cline(lline);
        goto eocline;
  p1repa:  if((pass == 2)&&(canlist()))prsl(line);
        goto eocline;



   case 10:                                     /* dup  */

 p1dup: eatspace(ss);
        if((i == -1)||eqs(**ss)){
                panic(MI);
                goto eocline;
                }
        i = evolexp(ss);
        if((pass == 1)&&(i < 0)){
                panic("Can't duplicate by negative number of times");
                i = 1;
                }
        if(i < 0)i = 1;
        jj = i;
        j = 0;
        ii = 0;
        i = 0;
        while(1){               /* Allways wanted to use a while(1) */
           getline(llline);
           if(lfs("enddup",llline)){
                if(ii <= 0)goto lop4;
                ii -= 2;
                }
           if(lfs("endalldup",llline))goto lop4;
           if(lfs("dup",llline)){
                ii += 1;
                }
           i = 0;
          while(((lline[j] = llline[i++])!= '\0')&&(j < NCIM)){
                j++;
                }
           lline[j++] = '\n';
           if(j >= NCIM){
                panic("Too many charactors in 'dup' argument");
                lline[NCIM-1] = '\n';
                lline[NCIM] = '\0';
                j--;
                }
           }
  lop4:
        lline[j] = '\0';
    if(jj)mexp(lline,marg,0);
        j = 0;
        jj -= 1;
        while(lline[j] != '\0'){                /* remove symbols */
            if((lline[j] != ' ')&&(lline[j] != '\t')){
                while((lline[j] != ' ')&&(lline[j] != '\t'))
                    lline[j++] = ' ';
                }
            while((lline[j] != '\n')&&(lline[j] != '\0'))j++;
            if(lline[j] == '\n')j++;
            }
        while(jj--)mexp(lline,marg,0);
        goto eocline;


   case 11:                                     /* external */
        eatspace(ss);
        commaerr(ss);
        if(eqs(**ss)){
                panic(MI);
                goto eocline;
                }
        while(getarg(ss,arg)){
                if(llu(arg,edtab) != -1){
                    panic("Warning -double defined external");
                    printf(UCS,arg);
                    }
                  else cement(arg,edtab);
                }
        goto eocline;


  case 12:                                      /* defmacro */

   p1defm:      hlable = 0;
        b1 = 1;
        eatspace(ss);
        if((i == -1)||eqs(**ss)){panic(MI);goto eocline;}
        sscan(arg,ss);
        if(llu(arg,mdef)!= -1){
                if(pass== 1){
                        panic("Double defined macro");
                        printf(UCS,arg);
                        b1 = 0;
                        }
                }
          else hlable = 1;
        if(((pass == 1)||(hlable))&& b1 )cement(arg,mdef);
        eatspace(ss);
        if(**ss == ',')
           panic("Only one operhand in a defmacro statemnt -first one used");
        j = 0;
        lline[0] = '\n';
        ii = 0;
        i = 0;
        while(1){
           getline(llline);
           if(lfs("endmacro",llline)){
                if(ii <= 0)goto lop5;
                ii -= 1;
                }
           if(lfs("endallmacro",llline))goto lop5;
           if(lfs("defmacro",llline)){
                s = &line;
                ss = &s;
                if((llline[0] != ' ')&&(llline[0] != '\t'))break;
                sscan(arg,ss);
                if(comstr(arg,"defmacro"))ii += 1;
                }
         i = 0;
         while(((lline[j] = llline[i++])!= '\0')&&(j < NCIM)){
                j++;
                }
           lline[j++] = '\n';
           if(j >= NCIM){
                panic("Too many charactors in 'defmacro' argument");
                lline[NCIM-1] = '\n';
                lline[NCIM] = '\0';
                j--;
                goto lop5;
                }
           }
   lop5: lline[j] = '\0';
        if(((pass == 1)||(hlable))&& b1)cement(lline,mbody);
        goto eocline;


   case 13:                                     /* endmacro */
   p1endm:   panic("Extra 'endmacro'");
        goto eocline;


   case 14:                                     /* enddup */
   p1endd:   panic("Extra 'enddup'");
        goto eocline;


    case 36:                            /* rs   */
    case 18:                            /* rmb  */
p1rmb:  if(i == -1){
                panic(MI);
                if((pass == 2)&&(canlist()))prsl(line);
                goto eocline;
                }
        while(p2evnf){                          /* fala numbers */
                p2evn(ss);
                pc[psect] += p2evnn;
                }
        if((pass == 2)&&(canlist())){
                prspc();
                prl(line);
                }
        goto eocline;


   case 19:                                     /* if   */
        p1if:  j =  evolexp(ss);
        ifcount++;
        if(j)goto eocline;
        j = 1;
        ii = 0;
        while(j){
                getline(llline);
                s = llline;
                ss = &s;
                if(islet(**ss) == 1)sscan(arg,ss);
                if(eqs(**ss)){
                        if(passend == 0){
                                panic("Broken 'if' statment");
                                goto eocline;
                                }
                        }
                  else {
                        sscan(arg,ss);
                        if(comstr(arg,"endif")){
                                if(ii == 0){j = 0;
                                ifcount--;
                                        }
                                   else ii--;
                                }
                        else if(comstr(arg,"else")){
                                if(ii == 0)j = 0;
                                }
                        else if(comstr(arg,"if"))ii++;
                        }
                }
        goto eocline;


   case 20:                                     /* else */
    p1else:   if(ifcount == 0){
                panic("Extra 'else' statment");
                goto eocline;
                }
        j = 1;
        ii = 0;
        while(j){
                getline(llline);
                s = llline;
                ss = &s;
                if(islet(**ss) == 1)sscan(arg,ss);
                if(eqs(**ss)){
                        if(passend == 0){
                                panic("Broken if statment");
                                goto eocline;
                                }
                        }
                   else {
                        sscan(arg,ss);
                        if(comstr(arg,"endif")){
                                if(ii == 0){j = 0;
                                ifcount--;
                                        }
                                   else ii--;
                                }
                                else if(comstr(arg,"if"))ii++;
                        }
                }
        goto eocline;


   case 21:                                     /* endif        */
        p1endif:        if(ifcount == 0){
                panic("extra 'endif'");
                goto eocline;
                }
        ifcount--;
        goto eocline;

    case 22:                                    /* base         */
p1base: eatspace(ss);
        if(eqs(**ss)){
                panic(MI);
                goto eocline;
                }
        curbase = 10;
        curbase = evolexp(ss);
        goto eocline;

    case 23:                                    /* listoff */
        listflag = 0;
        goto eocline;

    case 24:                                    /* liston       */
        listflag = 1;
        goto eocline;


    case 25:                                    /* include */
p1incl: eatspace(ss);
        if(eqs(**ss)){panic(MI); goto eocline;}
        if(ifdc == NINCL){panic("Too many nested includes"); goto eocline;}
        i = 0;
        while(neqs(**ss))llline[i++] = *(*ss)++;
        llline[i] = '\0';
        ifd[++ifdc] = open(llline,0);
        if(ifd[ifdc] == -1){
                panic("Can't read include file");
                --ifdc;
                }
        goto eocline;

    case 26:                                    /* macoff       */
        goto eocline;

    case 27:                                    /* macon        */
        goto eocline;

    case 39:                                    /* .global      */
    case 40:                                    /* .globl       */
    case 28:                                    /* global       */
        eatspace(ss);
        if(eqs(**ss))panic(MI);
        goto eocline;

   case 29:                                     /* loadmod */
        eatspace(ss);
        commaerr(ss);
        if(eqs(**ss)){
                panic(MI);
                goto eocline;
                }
        while(getarg(ss,arg)){
                if(llu(arg,loadtab) != -1){
                        panic("Warning- double defined loadmod");
                        printf(UCS,arg);
                        }
                    else cement(arg,loadtab);
                }
        goto eocline;

    case 30:                                    /* message      */
p1err:  printf("%%%% User message:\t");
p1errl: while(neqs(**ss) && (**ss != '%'))putchar(*(*ss)++);
        if(eqs(**ss)){
                putchar('\n');
                numerrs++;
                goto eocline;
                }
        sscan(arg,ss);
        if((i = fsyml1(arg)) != -1){
                basout(symv[i],16);
                }
            else printf(UND);
        goto p1errl;

    case 37:                                    /* byteson      */
        bytef = 1;
        goto eocline;

    case 38:                                    /* bytesoff     */
        bytef = 0;
        goto eocline;

    case 42:                                    /* .even        */
     p1even:
        pc[psect]++;    pc[psect] &= ~1;
        goto p1orgb;

    case 43:                                    /* .odd         */
     p1odd:
        pc[psect] &= ~1;        pc[psect]++;
        goto p1orgb;

    case 44:                                    /* .page        */
     p1page:
        pc[psect] += 07777;     pc[psect] &= ~07777;
        goto p1orgb;

    case 45:                                    /* psect        */
    case 46:                                    /* .psect       */
p1psect:
        eatspace(ss);
        if((i == -1)||eqs(**ss)){
                panic(MI);
                goto p1orgb;
                }
        psect = evolexp(ss);
        eatspace(ss);
        if(**ss == ',')panic(SOI);
        goto p1orgb;

    case 47:                                    /* .abs         */
        psect = ABS;
        goto p1orgb;

    case 48:                                    /* .text        */
        psect = TEXT;
        goto p1orgb;

    case 49:                                    /* .data        */
        psect = DATA;
        goto p1orgb;

    case 50:                                    /* .bss         */
        psect = BSS;
        goto p1orgb;

    case 51:                                    /* .stack       */
        psect = STACK;
        goto p1orgb;


       }                /*  END OF SWITCH  */
     }

    else if((j = llu(sarg,spmot)) != -1){
        pc[psect] += spmots[j];
        goto eocline;           /* special 6800 look-alike cases */
        }

  else if((j = llu(sarg,mot))!= -1){
        eatspace(ss);
        savess = *ss;           /* save ss for later analyisis */
        if(mvt[j][4] != 1){
                pc[psect] += 1;
                j = mvt[j][4];
                if((j >= 52) && (j <= 55))pc[psect]++;  /* psh and pul */
                if((j == 30) || (j == 31))pc[psect]++;  /* tfr or exg */
                if(llu(sarg,mot10) != -1)pc[psect] += 1;
                if(llu(sarg,mot11) != -1)pc[psect] += 1;
                goto eocline;           /* inherant */
                }
        if(eqs(**ss))panic(MI);
        if((**ss)== '#'){
                if((llu(sarg,mot10) != -1) || (llu(sarg,mot11)!= -1)){
                        pc[psect] += 4;
                        }
                    else pc[psect] += mlt[mvt[j][0] & 0377];
                if(mvt[j][0] == 1)panic("Invalid mode");
                goto eocline;
                }
        ncount = opsize(ss);
        while((**ss != ';')&&(**ss != ','))(*ss)++;
        if(**ss == ','){
                (*ss)++;
                swapit(*ss);    /* process "--R"s */
                if((**ss == 'x')||(**ss == 'y')||(**ss == 's')||(**ss == 'u')){
                        if((llu(sarg,mot10)!= -1) || (llu(sarg,mot11)!= -1)){
                                pc[psect] += 3; /* indexed */
                                }
                            else pc[psect] += mlt[mvt[j][2] & 0377];
                        if(*savess != ','){
                                savess++;
                                if((*savess != 'a')&&(*savess != 'b')&&(*savess != 'd'))pc[psect] += ncount;
                                    else{
                                        savess++;
                                        if(*savess != ',')pc[psect] += ncount;
                                        }
                                }
                        if(mvt[j][2] == 1)panic("Invalid mode");
                        goto eocline;
                        }
                if(**ss == 'd'){
                                /* base-mode address */
                        if((llu(sarg,mot10)!= -1) || (llu(sarg,mot11)!= -1)){
                                pc[psect] += 3;
                                }
                            else pc[psect] += mlt[mvt[j][1] & 0377];;
                        if(mvt[j][1] == 1)panic("Invalid mode");
                        goto eocline;
                        }
                if(**ss == 'p'){                /* Pc relative  */
                        if((llu(sarg,mot10)!= -1) || (llu(sarg,mot11)!= -1)){
                                pc[psect] += 5;
                                }
                            else pc[psect] += 4;
                        if(mvt[j][2] == 1)panic("Invalid mode");
                        goto eocline;
                        }
                panic("Odd addressing mode");
                }
        if(mvt[j][3] != 1){
                if((llu(sarg,mot10)!= -1) || (llu(sarg,mot11)!= -1)){
                        pc[psect] += 4;
                        }               /* extended     */
                    else pc[psect] += mlt[mvt[j][3] & 0377];
                if(*savess == '[')pc[psect] += 1;       /* if extended indirect */
                goto eocline;
                }
        if(mvt[j][5] != 1){
                if((llu(sarg,mot10)!= -1) || (llu(sarg,mot11)!= -1)){
                        pc[psect] += 4;
                        }               /* relative     */
                    else pc[psect] += mlt[mvt[j][5] & 0377];
                goto eocline;
                }
        panic("Valid instruction with invalid mode");
        }
     panic("Undefined instruction:");
        printf(UCS,sarg);
       goto eocline;



   }

                /* IN PASS TWO   */


        symtabr = 0;    exttabr = 0;    relocate = 0;
        fb2 = fb3 = fb4 = fb5 = prebyte = indir = 0;
        b1 = 18;
        if(symll > NUMSYM){
                panic("Out of external symbol referance table space");
                panic("Internally, change 'NUMSYM' to increase table");
                extrtp -= 1;
                }

        if((**ss == ';')&&(*(*ss+1) == '\0')){putchar('\n');goto eocline;}
        if(islet(**ss) == 1){
           if((i = sscan(arg,ss))== ':'){
p2hslb:         (*ss)++;
                hclable = 1;            /* ignore :*/
                if(**ss == ':'){        /* ::   */
                        (*ss)++;
                        hdclable = 0;
                        }
                }
           eatspace(ss);
           if(i == -1){
                panic("Missing opcode");
                prsl(line);
                goto eocline;
                }
           if((i = fsyml1(arg)) != -1){
                if(**ss == '='){
                        (*ss)++;
                        symv[i] = evolexp(ss);
                        symp[i] = spsect;
                        sarg[0] = arg[0];
                        sarg[1] = arg[1];
                        j = i;
                        goto p2plwas;
                        }
                }
           if(i == -1){
              if((arg[0] == '$')||(arg[0] == '%')){
                panic(BL);
                }
               else {
                i = fsyms(arg);
                symv[i] = pc[psect];
                hlable = 1;
                if(macnest && (hdclable || rlpass[macnest] == 1))
                        cement(arg,macstack[macnest]);
                if(**ss == '='){
                        (*ss)++;
                        symv[i] = evolexp(ss);
                        sarg[0] = arg[0];
                        sarg[1] = arg[1];
                        j = i;
                        goto p2plwas;
                        }
                }
              }
            }
        else {
            if((**ss == ';')||(**ss == '*')){prsl(line);goto eocline;}
            if((**ss != ' ')&&(**ss != '\t')){
                if(**ss == '\n'){putchar('\n');goto eocline;}
                panic("Invalid lable");
                while((**ss != ' ')&&(**ss != '\t')&&(**ss != '\n'))
                        (*ss)++;
                if(**ss == '\n'){prsl(line);goto eocline;}
                }
             }
   i = sscan(sarg,ss);
   if(i == ':'){
        copystr(arg,sarg);
        goto p2hslb;            /* mutiple lable per line case */
        }
        if(sarg[0] == '\0'){
            if(hlable && (hclable == 0)){
                panic("Warning -lable with no opcode");
                printf(UCS,arg);
                }
            prsl(line);
            goto eocline;
           }

   eatspace(ss);
   if(**ss == '='){                     /* .= or symb = expr    */
        (*ss)++;                        /* skip =               */
        if((j = fsyml1(sarg)) == -1){
                panic(UND);
                prsl(line);
                goto eocline;
                }
        symv[j] = evolexp(ss);
p2plwas:
        if((sarg[0] == '.')&&(sarg[1] == '\0')){
                pc[psect] = symv[j];
                prspc();
                }
            else prsn(symv[j]);
        prl(line);
        goto eocline;
        }

        if((j = llu(sarg,mdef))!= -1){          /*  if macro */
                prsl(line);
                goto p1mac;
                }

        if((j = llu(sarg,soptab))!= -1){        /*  psdo -op    */

    switch(j){

    case 1:                                     /*  equ */
        goto p1equ;

    case 41:                                    /* .end */
    case 2:                                     /* end  */
        passend = 0;
        prsl(line);
        dumpst();
        return;

    case 15:                                    /* fcb   */
    case 31:                                    /* .byte */
    case 3:                                     /*  db  */
        prsl(line);
        while(p2evnf){
                p2evn(ss);
                if(!p2evnf)break;
                b1 = p2evnn;
                prsnb();
                pbytes();
                pc[psect]++;
                }
        if(bytep && canlist() && bytef)putchar('\n');
        goto eocline;

    case 34:                                    /* asciiz */
    case 35:                                    /* ascii  */
        fasciz = 1;


    case 17:                                    /* fcc    */
    case 33:                                    /* .ascii */
    case 4:                                     /*  ds    */
        prsl(line);
        eatspace(ss);
        while(neqs(**ss)){
            (*ss)++;                            /* skip the " */
            while((**ss != '"')&&(**ss != '\n')&& **ss){
                b1 = *(*ss)++;
                if(b1 == '\\'){
                        switch(**ss){
                                case '!':       b1 = 7;   /* beep */
                                        break;
                                case 'N':
                                case 'n':       b1 = '\n';
                                        break;
                                case 'T':
                                case 't':       b1 = '\t';
                                        break;
                                case 'R':
                                case 'r':       b1 = '\r';
                                        break;
                                case 'B':
                                case 'b':       b1 = 010;
                                        break;
                                case 'E':
                                case 'e':       b1 = 033;  /* esc */
                                        break;
                                case 'F':
                                case 'f':       b1 = 014;  /* FF */
                                        break;
                                case '0':       b1 = 0;
                                        break;
                                case '^':
                                        (*ss)++;
                                        if(**ss == '?')b1 = 0177;
                                            else b1 = **ss & 037;
                                        break;
                                default:        b1 = **ss;
                                }
                        (*ss)++;
                        }
                prsnb();        pbytes();       pc[psect]++;
                }
            if(fasciz){
                b1 = 0;
                prsnb();        pbytes();       pc[psect]++;
                }
            if(**ss == '"')(*ss)++;             /* step over last " */
            eatspace(ss);
            if(**ss == ',')(*ss)++;
            eatspace(ss);
            }
        if(canlist() && bytef && bytep)putchar('\n');
        goto eocline;

    case 16:                                    /* fdb   */
    case 32:                                    /* .word */
    case 5:                                     /*  dw  */
        prsl(line);
        fb2 = 1;
        while(p2evnf){
                symtabr = 0;    exttabr = 0;
                p2evn(ss);
                if(!p2evnf)break;
                b1 = (p2evnn >> 8) & 0377;
                b2 = p2evnn & 0377;
                if(symtabr)relocate = 1;
                if(exttabr){
                        exrtab[extrtp] = exttabr;
                        exatab[extrtp] = pc[psect];
                        exptab[extrtp++] = psect;
                        }
                pbytes();
                prsnb();
                b1 = b2;
                prsnb();
                pc[psect] += 2;
                }
        if(bytep && canlist() && bytef)putchar('\n');
        goto eocline;


    case 6:                                     /*   org        */
        goto p1org;

    case 7:                                     /*  eval        */
        evolexp(ss);
        prsl(line);
        goto eocline;

    case 8:                                     /* entry */
        prsl(line);
        eatspace(ss);
        if(eqs(**ss)){
                panic(MI);
                goto eocline;
                }
        poe = evolexp(ss);
        goto eocline;

    case 9:                                     /*  repeat      */
        goto p1rep;

    case 10:                                    /*  dup */
        prsl(line);
        goto p1dup;

    case 11:                                    /*  external    */
        prsl(line);
        goto eocline;                   /* all handled in pass one */

    case 12:                                    /*  defmacro */
        goto p1defm;

    case 13:                                    /*  end macro */
        prsl(line);
        goto p1endm;

    case 14:                                    /*  enddup      */
        prsl(line);
        goto p1endd;

    case 36:                                    /* rs   */
    case 18:                                    /* rmb  */
        goto p1rmb;

    case 19:                                    /* if   */
        prsl(line);
        goto p1if;

    case 20:                                    /* else */
        prsl(line);
        goto p1else;

    case 21:                                    /* endif        */
        prsl(line);
        goto p1endif;

    case 22:                                    /* base         */
        prsl(line);
        goto p1base;

    case 23:                                    /* listoff      */
        listflag = 0;
        goto eocline;

    case 24:                                    /* liston       */
        listflag = 1;
        goto eocline;

    case 25:                                    /* include */
        prsl(line);
        goto p1incl;

    case 26:                                    /* macoff       */
        macflag = 1;
        goto eocline;

    case 27:                                    /* macon        */
        macflag = 0;
        goto eocline;

    case 39:                                    /* .global      */
    case 40:                                    /* .globl       */
    case 28:                                    /* global       */
        prsl(line);
        commaerr(ss);
        while(getarg(ss,arg)){
                if(llu(arg,globs) != -1){
                        panic("Double defined global:");
                        printf(UCS,arg);
                        }
                    else cement(arg,globs);
                }
        goto eocline;

    case 29:                                    /* loadmod      */
        prsl(line);
        goto eocline;

    case 30:                                    /* message      */
        goto p1err;

    case 37:                                    /* byteson      */
        prsl(line);
        bytef = 1;
        goto eocline;

    case 38:                                    /* bytesoff     */
        prsl(line);
        bytef = 0;
        goto eocline;

    case 42:                                    /* .even        */
        goto p1even;

    case 43:                                    /* .odd         */
        goto p1odd;

    case 44:                                    /* .page        */
        goto p1page;

    case 45:                                    /* psect        */
    case 46:                                    /* .psect       */
        goto p1psect;

    case 47:                                    /* .abs         */
        psect = ABS;
        goto p1orgb;

    case 48:                                    /* .text        */
        psect = TEXT;
        goto p1orgb;

    case 49:                                    /* .data        */
        psect = DATA;
        goto p1orgb;

    case 50:                                    /* .bss         */
        psect = BSS;
        goto p1orgb;

    case 51:                                    /* .stack       */
        psect = STACK;
        goto p1orgb;


           }    /*  END SWITCH  */
        }

        if((j = llu(sarg,spmot)) != -1){        /* special 6800 */
                b1 = spmotd[j][0] & 0377;
                if(spmots[j] >= 2){
                        b2 = spmotd[j][1] & 0377;
                        fb2 = 1;
                        }
                if(spmots[j] >= 3){
                        b3 = spmotd[j][2] & 0377;
                        fb3 = 1;
                        }
                if(spmots[j] >= 4){
                        b4 = spmotd[j][3] & 0377;
                        fb4 = 1;
                        }
                if(spmots[j] >= 5){
                        b5 = spmotd[j][4] & 0377;
                        fb5 = 1;
                        }
                eatspace(ss);
                if(neqs(**ss))panic(SYN);
                goto dumper;
                }

        j = llu(sarg,mot);
        if(j == -1){
                panic("Undefined  Instruction:");
                printf(UCS,sarg);
                prsl(line);
                goto eocline;
                }

        eatspace(ss);
        fb2 = fb3 = fb4 = fb5 = indir = prebyte = 0;
        if(mvt[j][4] != 1){             /*      if inherant     */
                b1 = mvt[j][4];
                b2 = 0;
                setpre(sarg);           /* set up any pre-byte */
                if((b1 >= 52) && (b1 <= 55)){   /* push or pull */
                        if(eqs(**ss))panic(MI);
                        while(neqs(**ss)){
                            if((**ss == 'd') && (*(*ss + 1) == 'p'))
                                b2 |= 010;
                              else b2 |= ppb(*(*ss)++); /* flag bits */
                                while((**ss != ',')&& neqs(**ss))(*ss)++;
                                if(**ss == ',')(*ss)++;
                                }
                        fb2 = 1;
                        }
                if((b1 == 30) || (b1 == 31)){   /* tfr or exg */
                        if(eqs(**ss))panic(MI);
                        if((**ss == 'd') && (*(*ss + 1) == 'p'))
                                b2 = 0260;
                            else b2 = tfrb(**ss) << 4;  /* source reg */
                        while((**ss != ',') && neqs(**ss))(*ss)++;
                        if(eqs(**ss))panic(MI);
                        (*ss)++;                /* skip over ',' */
                        if((**ss == 'd')&& (*(*ss + 1) == 'p')){
                                b2 += 013;
                                (*ss)++;
                                }
                            else b2 += tfrb(**ss);      /* dest. */
                        fb2 = 1;
                        if(((b2 & 0200)>> 4) ^ (b2 & 010))
                            panic("tfr/exg between different sized registers.");
                        (*ss)++;
                        if(**ss == 'c')(*ss)++;
                        }
                eatspace(ss);
                if(neqs(**ss))panic(SYN);
                goto dumper;
                }
        if(eqs(**ss))panic(MI);
        if(**ss == '#'){                /*      if imidiate     */
                b1 = mvt[j][0];
                setpre(sarg);
                (*ss)++;
                b2 = evolexp(ss);
                if(mlt[mvt[j][0] & 0377] == 3){
                    b3 = b2 & 0377;
                    b2 = (b2>>8) & 0377;
                    fb2 = 1;
                    fb3 = 1;
                    if(symtabr){
                        relocate = 2;
                        }
                    if(exttabr){
                        exrtab[extrtp] = exttabr;
                        if(prebyte)exatab[extrtp] = pc[psect] + 2;
                            else exatab[extrtp] = pc[psect] + 1;
                        exptab[extrtp++] = psect;
                        }
                    }
                else {
                        fb2 = 1;
                        b2 &= 0377;
                           }
                if(mvt[j][0] == 1){
                    panic("Imed. mode on non-imed. instruction");
                    }
                if(neqs(**ss))panic(SYN);
                if(indir)panic(SYN);
                goto dumper;
                }
        ii = ss;
        i  = (*ss);
        ncount = opsize(ss);            /* get number of extra bytes */
        while((**ss != ',')&&(**ss != ';'))(*ss)++;
        if(**ss == ','){                /* indexed or base mode */
            (*ss)++;
            swapit(*ss);        /* process "--R"s */
            if((**ss == 'x')||(**ss == 'y')||(**ss == 'u')||(**ss == 's')){
                b2 = ibr(**ss) << 5;    fb2 = 1;
                b1 = mvt[j][2];
                ss = ii;        (*ss) = i;
                if(mvt[j][2] == 1)
                    panic("Indirect mode on non-indirect instruction.\n");
                setpre(sarg);
                if(**ss == '['){
                        (*ss)++;        b2 += 020;      /* indirect */
                        indir++;
                        };
                if(**ss == ','){        /* ,R or ,R++ or ,R- ... */
                    (*ss)++;            /* skip over ','        */
                    (*ss)++;            /* skip over 'R'        */
                    switch(*(*ss)++){
                        case '+':
                            if(**ss == '+')
                                b2 += 0201;     /* ,R++ */
                              else b2 += 0200;
                            break;
                        case '-':
                            if(**ss == '-')
                                b2 += 0203;     /* ,R-- */
                              else b2 += 0202;
                            break;
                        default:                /* ,R   */
                            b2 += 0204;
                        }
                    goto dumper;
                    }
                if(((**ss == 'a')||(**ss == 'b')||(**ss == 'd'))&&
                    (*(*ss + 1) == ',')){       /* Acc. offset  */
                    switch(**ss){
                        case 'a':
                            b2 += 0206;
                            break;
                        case 'b':
                            b2 += 0205;
                            break;
                        case 'd':
                            b2 += 0213;
                            break;
                        }
                    *ss += 3;           /* skip over ,R */
                    if((**ss == '+')||(**ss == '-'))
                        panic("Can't mix increments with offsets");
                    goto dumper;
                    }
/*                              must be n,R     */
                b4 = evolexp(ss);
                *ss += 2;               /* skip over ,R */
                if((**ss == '-')||(**ss == '+'))
                    panic("Can't mix increments with offsets");
                if(ncount == 0){
                        if(indir)goto indr8;
                        b2 += b4 & 037;
                        fb2 = 1;
                        goto dumper;
                        }
                if(ncount == 1){
indr8:                  b2 += 0210;     fb2 = fb3 = 1;
                        b3 = b4 & 0377;
                        goto dumper;
                        }
                b3 = (b4 >> 8) & 0377;
                b4 = b4 & 0377;
                b2 += 0211;     fb2 = fb3 = fb4 = 1;
                goto dumper;
                }               /* ends " if((**ss == 'x'))||(**ss ... */
            if(**ss == 'p'){            /*   n,pcr              */
                b1 = mvt[j][2];
                if(b1 == 1)
                    panic("Indexed addressing on non-indexed instruction");
                ss = ii;        (*ss) = i;
                setpre(sarg);
                b2 = 0215;
                fb2 = fb3 = fb4 = 1;
                b4 = evolexp(ss) - pc[psect] - 4;
                if(prebyte)b4--;
                if(exttabr){
                        b4 += pc[psect];
                        if(prebyte){
                                b4 += 5;
                                }
                            else b4 += 4;
                        }
                b3 = (b4 >> 8) & 0377;
                b4 &= 0377;
                if(exttabr){
                    rrtab[rtrtp] = exttabr;
                    if(prebyte)ratab[rtrtp] = pc[psect] + 3;
                        else ratab[rtrtp] = pc[psect] + 2;
                    rptab[rtrtp++] = psect;
                    }
                if(indir)b2 += 020;
                goto dumper;
                }
            if(**ss == 'd'){            /*      direct          */
                ss = ii;
                (*ss) = i;
                b2 = evolexp(ss);
                fb2 = 1;
                b1 = mvt[j][1];
                if(b1 == 1){
                    panic("Direct mode on non-direct instruction");
                    }
                if(indir)panic(SYN);
                goto dumper;
                }
            panic(SYN);         /* ,? */
            }
        ss = ii;
        (*ss) = i;
        if(mvt[j][3] != 1){             /*      extended        */
            setpre(sarg);
            if(**ss != '['){
                b1 = mvt[j][3];
                j = evolexp(ss);
                b2 = (j>>8)& 0377;
                b3 = j & 0377;
                fb2 = 1;
                fb3 = 1;
                if(symtabr){
                        relocate = 2;
                    }
                if(exttabr){
                    exrtab[extrtp] = exttabr;
                    if(prebyte)exatab[extrtp] = pc[psect] + 2;
                        else exatab[extrtp] = pc[psect] + 1;
                    exptab[extrtp++] = psect;
                    }
                goto dumper;
                }
            (*ss)++;                    /* step over the '['    */
            b1 = mvt[j][2];
            b2 = 0237;  fb2 = fb3 = fb4 = 1;
            j = evolexp(ss);
            b3 = (j >> 8) & 0377;
            b4 = j & 0377;
            if(symtabr)relocate = 3;
            if(exttabr){
                exrtab[extrtp] = exttabr;
                exatab[extrtp] = pc[psect] + 2;
                exptab[extrtp++] = psect;
                }
            goto dumper;
            }
        if(mvt[j][5] != 1){             /*      relative        */
            b1 = mvt[j][5];
            setpre(sarg);
            if((llu(sarg,mot10) == -1)&&(b1 != 22)&&(b1 != 23)){
                j = evolexp(ss);
                if(indir)panic(SYN);
                if(((j - pc[psect]) > 129)||((pc[psect] - j) > 125)){ /* range error */
                    panic("Relative address out of range");
                    j = 0;
                    }
                if(pc[psect] <= j){                     /* forward      */
                    b2 = (j - pc[psect] - 2);
                    }
                if(pc[psect] > j){              /* backward     */
                    b2 = ~(pc[psect] - j +1);
                    }
                fb2 = 1;
                goto dumper;
                }
            if((llu(sarg,mot10) != -1)||(b1 == 22)||(b1 == 23)){
                                                /* long branch  */
                j = evolexp(ss);
                if(indir)panic(SYN);
                j -= pc[psect] + 4;                     /* get offset */
                if((b1 == 22)||(b1 == 23))j++;  /* lbsr or lbra */
                if(exttabr){
                        j += pc[psect];
                        if((b1 == 22)||(b1 == 23)){
                                j += 3;
                                }
                            else j += 4;
                        }
                b2 = (j >> 8) & 0377;
                b3 = j & 0377;
                fb2 = fb3 = 1;
                if(exttabr){
                    rrtab[rtrtp] = exttabr;
                    if(prebyte)ratab[rtrtp] = pc[psect] + 2;
                        else ratab[rtrtp] = pc[psect] + 1;
                    rptab[rtrtp++] = psect;
                    }
                goto dumper;
                }
            }
        panic("Internal error- type of instruction unknown");
        printf("J is %d, instruction is %s.\n",j,sarg);
for(i=0;i!=5;i++)printf("%d  ",mvt[j][i]);
putchar('\n');
        goto dumper;
bdumper:        panic(MI);

dumper: prn();
        prl(line);
        pc[psect]++;    if(prebyte)pc[psect]++;
        if(fb2)pc[psect]++;     if(fb3)pc[psect]++;     if(fb4)pc[psect]++;     if(fb5)pc[psect]++;
eocline:  symv[0] = pc[psect];          /* fill in value for "." */
          symp[0] = psect;
        return;


}


evolexp(p)
        char **p;
{
        char s[22];
        int q,d;
        register char *k;
        int nf,o,of;
        int j_type,i_type;
        register i,j;
        char c;

        i =  nf = of  = 0;
        j_type = i_type = ABS;
        o = ' ';
        /* Old Macdonald had a farm, e = i = e = i = 0          */

loop:   c = *(*p)++;
        if(c == ')'){
                if(of == 0){
                        spsect = i_type;
                        return(i);
                        }
popout:         if(of){panic("Paren garbege");  return(i);}
                if(of == 0){(*p)--;spsect = i_type;return(i);}
                }
        if(c == '\0'){panic("UnExEOF??");(*p)--;return(i);}
        if((c == '[') || (c == ']')){
                indir++;                /* tag as using indirect adddressing */
                goto loop;
                }
        if(c == '('){
                j = evolexp(p);
                j_type = spsect;
                goto numerin;
                }
/* stuff to ingore backquotes thing (`x) in any line   6/6/80  DEBUG */
        if(c == '`'){
                if(**p != ';')(*p)++;   /* eat up next charactor */
                goto loop;
                }
/* end of patch to ignore " `x " stuff                               */
        if(c == '\''){
                c = *(*p)++;
                if(c == '\\'){
                    c = *(*p)++;
                        switch(c){
                                case '!':       c = 7;   /* beep */
                                        break;
                                case 'n':       c = '\n';
                                        break;
                                case 't':       c = '\t';
                                        break;
                                case 'r':       c = '\r';
                                        break;
                                case 'b':       c = 010;
                                        break;
                                case 'e':       c = 033;  /* esc */
                                        break;
                                case 'f':       c = 014;  /* FF */
                                        break;
                                case '^':
                                        if(**p == '?')c = 0177;
                                            else c = **p & 037;
                                        (*p)++;
                                        break;
                                case '0':
                                if(islet(**p)== 0){
                                        c = penum(p);
                                        }
                                        else c = '\0';
                                        break;
                                }
                        }
                j = c;
                j_type = ABS;
                if(**p == '\'')(*p)++;
                goto numerin;
                }
        if((c == '.')&&(island(**p) == 0)){
                j = pc[psect];                          /* . is pc */
                j_type = psect;
                symtabr++;
                goto numerin;
                }
        if(c == '$'){
                j = penum(p);
                j_type = ABS;
                goto numerin;
            }
        if(islet(c) == 0){
                j = penum(p);
                j_type = ABS;
numerin:
                if(nf == 0){
                        i = j;  i_type = j_type;
                        nf = 1;
                        goto loop;
                        }
                if(of == 0){panic("2 #, no ops. ??");goto loop;}
                i = eval(i,j,o);        /* evaluate the binary  */
                if(i_type != j_type){
                        if((i_type != ABS) && (j_type != ABS))
                            panic("Mixed psects in an expresion.");
                        }
                if(j_type != ABS)i_type = j_type;
                of = 0;
                o = ' ';
                goto loop;
                }

        if(c == '='){
                if(**p == '='){
                        *(*p)++;
                        o = '==';
                        of = 1;
                        goto loop;
                        }
                if(((d = **p) == '+')||(d == '-')||(d == '*')||
                        (d == '/')||(d == '%')||(d == '>')||
                        (d == '<')||(d == '&')||(d == '^')||
                        (d == '|')){
                        if(d == '>'){d= '>>';*(*p)++;}
                        if(d == '<'){d= '<<';*(*p)++;}
                        *(*p)++;
                        j = evolexp(p);
                        j_type = spsect;
                        if((q = fsyml1(s))== -1)
                                panic(UND);
                          else {
                                symtabr++;
                                symv[q]= eval(symv[q],j,d);
                                j = symv[q];    }
                        goto closee;
                        }
                j = evolexp(p);
                j_type = spsect;
                if((q = fsyml1(s))== -1)
                        panic(UND);
                  else {
                        symtabr++;
                        symv[q]= j;
                        }
        closee: if((*((*p)-1)== ')')||(*((*p)-1)== ';')||
                (*((*p)-1)== ',')||(*((*p)-1)== '\n'))(*p)--;
                nf = 0;
                goto numerin;
                }

  /*    Not (,# or ) .  Should be operator or filler    */
oper:   if((islet(c) == 2)||(c == '%')){
        if( of || !nf){
                switch(c){
                        case '-':
                                j = -uneval(p);
                                j_type = spsect;
                                goto numerin;
                        case '~':
                                j = ~uneval(p);
                                j_type = spsect;
                                goto numerin;
                        case '!':
                                j = !uneval(p);
                                j_type = spsect;
                                goto numerin;
                        case '*':
                                j = pc[psect];
                                j_type = psect;
                                goto numerin;
                        case ';':
                                goto popout;
                        case '+':
                                goto loop;
                        case ',':
                                goto popout;
                        case '\n':
                                goto popout;
                        default:
                                panic("Invalid Unary -");
                                printf("%%%%\t\'");
                                putchar(c & 0177);
                                printf("\'\n");
                                goto loop;
                        }
                }
        if(c == ';')goto popout;
        if(c == ',')goto popout;
        if(c == '\n')goto popout;
        if(nf && of){
                if(c == '*'){
                        j = pc[psect];
                        j_type = psect;
                        goto numerin;
                        }
                panic("1 #, 2 ops ??");
                }
        if((islet(**p)==2)&&(**p != '(')&&(**p != '\'')&&
        (**p != '*')&&(**p != '-')&&(**p != '~')&&(**p != '!')){        /* compound op  */
                o = c << 8;
                o = o + *(*p)++;
                }
        else o = c;
        of = 1;
        }

        if(island(c) && (c != '%')){
                k = s;
                (*p)--;
                while(island(*k++ = *(*p)++));
                (*p)--;
                *--k = '\0';
                if((q = fsyml1(s)) == -1){
                        if((q = llu(s,edtab))!= -1){
                                if(binflag == 0)exttabr = q;
                                j = 0;
                                j_type = ABS;
                                goto numerin;
                                }
                        if(exflag){
                            cement(s,edtab);
                            q = llu(s,edtab);
                            if(binflag == 0)exttabr = q;
                            j = 0;
                            j_type = ABS;
                            goto numerin;
                            }
                          else {
                            panic(UND);
                            printf(UCS,s);
                            }
                        goto loop;
                        }
                symtabr++;
                j = symv[q];
                j_type = symp[q];
                goto numerin;
                }
        goto loop;
}

ishex(c)
        char(c);
{
        if((c >= '0')&&(c <= '9'))return(1);
        if((c >= 'a')&&(c <= 'f'))return(1);
        return(0);
}


penum(p)
        char **p;
{
        char s[22];
        register char *pp;
        register char *ll;
        register base;
        char    flag;
        flag = 1;
        (*p)--;
        pp = s;
        base = curbase;
        if(**p == '$'){
                base = 16;
                flag = 0;
                (*p)++;
                }
        if((**p == '0')&&((*(*p +1) == 'x')||(*(*p +1) == 'X'))){
                base = 16;
                flag = 0;
                (*p)++; (*p)++;
                }
        while(ishex(*pp++ = *(*p)++));  /* copy string */
        (*p)--;
        *--pp = '\0';
        ll = --pp;
        pp = s;
        if(flag){
                if(*pp == '0')base = 8;
                if(**p == 'h'){base = 16;(*p)++;}
                if(**p == 'q'){base = 16;(*p)++;}
                }
        pp = s;
        while(*pp != '\0'){
            if(islet(*pp) != 0){
                base = 16;
                }
              else {
                if((*pp - '0') >= base)
                    panic(IDIN);
                }
            pp++;
            }
        return(basin(s,base));
}

eval(a1,a2,o)
        int a1,a2,o;
{
        switch(o){

        case '+':
                return(a1 + a2);
        case '-':
                return(a1 - a2);
        case '*':
                return(a1 * a2);
        case '&&':
                return(a1 && a2);
        case '||':
                return(a1 || a2);
        case '==':
                return(a1 == a2);
        case '=!':              /* really !=    */
                return(a1 != a2);
        case '>>':
                return(a1 >> a2);
        case '<<':
                return(a1 << a2);
        case '^':
                return(a1 ^ a2);
        case '>':
                return(a1 > a2);
        case '<':
                return(a1 < a2);
        case '=<':              /* really >=    */
                return(a1 <= a2);
        case '=>':              /* really >=    */
                return(a1 >= a2);
        case '&':
                return(a1 & a2);
        case '|':
                return(a1 | a2);
        case '/':
                return(a1 / a2);
        case '%':
                return(a1 % a2);
        default:
                panic("invalid operator -\");
                o = o & 0177;
                printf("%%%%\t\'");
                putchar(o);
                printf("\'\n");
                return(0);
        }
}


uneval(p)
        char **p;
{
        int *ss,*sss,s[50];
        register char c;
        register char *k;
        register i;

        ss = &s[0];
        sss = &ss;
        k = s;
        i = 0;
more:   while(island(c = (*k++ = *(*p)++)));
        if((c == ' ')||(c == '\t'))goto more;
        if(c == '(')i++;
        if((c == ')')&& i )i--;
        if(i)goto more;
        if(c != ')')k--;
        *k++ = ';';
        *k = '\0';
        (*p)--;
        return(evolexp(sss));
}
