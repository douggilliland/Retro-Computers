#
/*      Psect-able Linking Loader for 6809

        Peter D Hallenbeck

        (c) copyright June 1981

        If progam tosses cookies without  explanation and you think
        you are using > NUMSYM worth of total charactors for all your
        external moduale names, try increasing 'NUMSYM'.  All other
        violations should be anounced to you.
*/
#include "putchar.c"
#include "getchar.c"
#include "printf.c"
#define NUMMOD  200
#define NUMSYM  2000
#define NMXREF  500
#define NUMGLOB 200
        int wlist[NUMMOD];      /* want list    */
        char wwlist[NUMSYM];
        int hlist[NUMMOD];      /* have list    */
        char hhlist[NUMSYM];
        int hldir[NUMMOD];      /* which directory has the hlist */
        int glist[NUMGLOB];     /* global symbol list           */
        char gglist[NUMGLOB*8];
        int stlist[NUMMOD][16]; /* start address list           */
        int flist[NUMMOD][16];  /* finish address list          */
        int rlist[NUMMOD];      /* ROM list. 1 = rom.           */
        int galist[NUMGLOB];    /* globl variable address list  */
        int gplist[NUMGLOB];    /* globl var. psect list        */
        int rpc;                /* relative pc                  */
        int psect;              /* current psect                */
        int gwpsect;            /* get-word psect               */
        int pc[16];             /* progam counter               */
        int psects[16];         /* psect starting addresses     */
        int usps;               /* User Spec. Psect Start flag  */
        int lastmod;            /* index of last moduale        */
        int bc;                 /* byte counter                 */
        int reloc;              /* relocation bits              */
        int rxloc[NMXREF];      /* rel. extern. location data   */
        int rrloc[NMXREF];      /* rel. extern. loc. variable   */
        int rploc[NMXREF];      /* rel. ext. location psect     */
        int xloc[NMXREF];       /* external location data       */
        int rloc[NMXREF];       /* external location variable   */
        int ploc[NMXREF];       /* ext. loc. psect              */
        int wln;                /* want list number             */
        int gli;                /* global list index            */
        int havedir;            /* have directory(s) flag       */
        int dirpath;            /* start in argv[] of dir. paths*/
        char s[50];             /* current opened file string   */
        int fdi;                /* input file descriptor        */
        int fdo;                /* output file descriptor       */
        int pfdo[16];           /* psect output file descriptor */
        int ibuff[513];         /* input buffer                 */
        int ibuffc;             /* input buffer counter         */
        char *ibuffp;           /* input buffer pointer         */
        int obuff[513];         /* output buffer                */
        int obuffc;             /* output buffer counter        */
        char *obuffp;           /* output buffer pointer        */
        int pobuff[10][513];    /* psect output buffer          */
        int pobuffc[10];        /* psect output buff. count     */
        char *pobuffp[10];      /* psect ouput buff. pointer    */
        int pcocnt;             /* counter                      */
        int ppcocnt[16];        /* psect dump counter           */
        int pcolpc;             /* last pc                      */
        int ppcolpc[16];        /* psect last pc value          */
        int pcoch;              /* checksum                     */
        int pcob[30];           /* buffer                       */
        int ppcob[10][30];      /* psect buffers                */
        int pcobs;              /* buffer start location        */
        int ppcobs[16];         /* psect buffer start location  */
        int pcost;              /* start-up flag                */
        int ppcost[16];         /* psect start-up flag          */
        int b1;                 /* punchout bytes               */
        int numerrs;            /* error counter                */
        int verbose;            /* verbose flag                 */

        char *files[] = {
                ".abs", ".text", ".data", ".bss", ".stack",
                ".ps5", ".ps6",  ".ps7",  ".ps8", ".ps9",
                -1};


main(argc,argv)
        int argc;       char **argv;
{
        register i,j;   register char c;
        int ii,jj,index,rindex,curmod,mask,high,low,startadd,tmp,tmpp;
        int hits;
        long lenght;    /* about 7 feet, no doubt       */
        char opener[50],ss[50],*p;

        if(argc == 1){
                printf("Usage: ld09 file [address] [-as] [directorys]\n");
                flush();
                exit(-1);
                }

        fout = dup(1);
        pcost = 1;
        verbose = 1;
        usps = 0;
        for(i = 0;i != 10;i++){
                ppcost[i] = 1;
                ppcocnt[i] = 0;
                pobuffc[i] = 0;
                psects[i] = 0;
                }
        mixerup(wlist,wwlist);
        mixerup(hlist,hhlist);
        mixerup(glist,gglist);
        for(i = 0;i != NUMMOD;i++){
                rlist[i] = 0;                   /* clear rom list */
                hldir[i] = 0;
                galist[i] = 0;  gplist[i] = 0;
                for(j = 0;j != 16;j++){
                        stlist[i][j] = 0;
                        flist[i][j] = 0;        /* zero the pc's */
                        }
                }
        cement(argv[1],hlist);                  /* seed the search */
        index = 1;
        startadd = 256; havedir = 0;    gli = 1;        dirpath = 100;
        i = 2;  hits = 1;
        while((i < argc) && hits){
            hits = 0;
            if(islet(argv[i][0] == 0)){
                startadd = basin(argv[i],16);
                hits++;
                }
            if(argv[i][0] == '-'){
                hits++;
                j = 1;
                while(argv[i][j]){
                    switch(argv[i][j]){
                        case 'a':               /* auto pilot */
                            break;              /* (default)  */
                        case 's':               /* Spec. psect */
                            usps = 1;
                            break;
                        default:
                            printf("Warning- Unknown option -'%c'.\n",argv[i][j]);
                            numerrs++;
                        }
                    j++;
                    }
                }
            if(hits == 0){
                havedir = 1;
                dirpath = i;
                }
            i++;
            }
        argc--;
        copystr(opener,argv[1]);
        cats(opener,".rel");
        fdi = open(opener,0);
        if(fdi == -1){printf("Can't find '%s'.\n",opener);flush();exit(-1);}
        ibuffc = 0;     obuffc = 0;     obuffp = obuff;
        while((c = get())!= '\0'){
            if(c == 'S'){
                c = get();
                switch(c){
                    case '3':           /* load modual  */
                        p = s;
                        while(((c= get())!= '\0')&&(c != '\n'))*p++ = c;
                        *p = '\0';
                        if(llu(s,wlist)== -1)cement(s,wlist);
                        break;
                    case '4':           /* global */
                        tmp = getwrd();
                        gplist[gli] = getbyte();
                        p = s;
                        while(((c= get())!= '\0')&&(c != '\n'))*p++ = c;
                        *p = '\0';
                        if(llu(s,glist) == -1){
                                cement(s,glist);
                                galist[gli] = tmp;
                                }
                        gli++;
                        break;
                    case '5':
                        printf("Can not have ROM modual as main program.\n");
                        numerrs++;
                        break;
                    case '7':           /* external */
                        getwrd();
                        getbyte();
                        p = s;
                        while(((c= get())!= '\0')&&(c != '\n'))*p++ = c;
                        *p = '\0';
                        if(llu(s,wlist)== -1)cement(s,wlist);
                        break;
                    case '8':
                        high = getwrd();
                        if(high == 0)high = 1;
                        high--;
                        tmp = getbyte();
                        j = flist[1][tmp] = stlist[1][tmp] + high;
                        j++;
                        if(tmp)
                           for(i = 2;i != NUMMOD;i++){
                                stlist[i][tmp] = j;
                                flist[i][tmp] = j;
                                }
                        break;
                    case 'A':           /* Symbol dump */
                        while(((c=get())!= '\n')&&(c != '\0'));
                        break;
                    case 'B':           /* relative external */
                        getwrd();
                        getbyte();
                        p = s;
                        while(((c= get())!= '\0')&&(c != '\n'))*p++ = c;
                        *p = '\0';
                        if(llu(s,wlist)== -1)cement(s,wlist);
                        break;
                    }
                }
            }
        close(fdi);             /* now have mains' externals in list */
        flush();
        index = 2;      ibuffc = 0;     wln = 1;
  next: while(wlist[wln] != -1){        /* get info on all externals */
            if(llu(wlist[wln],glist) != -1){    /* if global can */
                chisel(wln,wlist);              /* satisfy extern.*/
                goto next;
                }
            j = dirpath;
            s[0] = '\0';
            cats(s,wlist[wln]);
            cats(s,".rel");
            i = open(s,0);
            while((i == -1) && (j <= argc)){
                hldir[index] = j;
                copystr(s,argv[j++]);
                cats(s,"/");
                cats(s,wlist[wln]);
                cats(s,".rel");
                i = open(s,0);
                }
            if(i == -1){
                wln++;
                goto next;
                }
if(verbose){
        printf("Am opening '%s'.\n",s);
        }
            cement(wlist[wln],hlist);
            chisel(wln,wlist);
            fdi = i;
globomb:    while((c = get()) != '\0'){
                if(c == 'S'){
                    c = get();
                    switch(c){
                        case '3':       /* loadmodual           */
                            p = s;
                            while(((c=get())!= '\0')&&(c != '\n'))*p++ = c;
                            *p = '\0';
                            if((llu(s,wlist)== -1)&&(llu(s,hlist)== -1))
                                cement(s,wlist);
                            break;
                        case '4':       /* global       */
                            tmp = getwrd();
                            tmpp = getbyte();
                            p = s;
                            while(((c=get())!= '\0')&&(c != '\n'))*p++ = c;
                            *p = '\0';
                            if(llu(s,glist)!= -1){
                                printf("Double-defined global: %s.\n",s);
                                numerrs++;
                                goto globomb;
                                }
                            cement(s,glist);
                            if(tmpp)galist[gli] = tmp + stlist[index][tmpp];
                                else galist[gli] = tmp;
                            gplist[gli] = tmpp;
                            gli++;
                            if((tmp = llu(s,wlist))!= -1)chisel(tmp,wlist);
                            break;
                        case '5':       /* rom modual */
                            flist[index][1] = getwrd();
                            stlist[index][1] = flist[index][1];
                            rlist[index] = 1;
                            break;
                        case '7':       /* external referance   */
                            getwrd();
                            getbyte();
                            p = s;
                            while(((c = get()) != '\0')&&(c != '\n'))*p++ = c;
                            *p = '\0';
                            if((llu(s,hlist)== -1)&&(llu(s,wlist)== -1))
                                cement(s,wlist);
                            break;
                        case '8':       /* lenght of modual     */
                            tmp = getwrd();
                            if(tmp == 0)tmp = 1;
                            tmp--;
                            tmpp = getbyte();
                            if(tmpp){
                                j = flist[index][tmpp] = stlist[index][tmpp]+tmp;
                                j++;
                                for(i = index+1;i != NUMMOD;i++){
                                    stlist[i][tmpp] = j;
                                    flist[i][tmpp] = j;
                                    }
                                }
                            break;
                        case 'A':       /* symbol */
                            while(((c = get())!= '\0')&&(c != '\n'));
                            break;
                        case 'B':       /* rel. external referance */
                            getwrd();
                            getbyte();
                            p = s;
                            while(((c = get()) != '\0')&&(c != '\n'))*p++ = c;
                            *p = '\0';
                            if((llu(s,hlist)== -1)&&(llu(s,wlist)== -1))
                                cement(s,wlist);
                            break;
                        }
                    }
                }
            wln = 1;
            index++;
            if(index == NUMMOD){
                printf("Too many moduales.  'NUMMOD' must be increased.\n");
                numerrs++;
                index--;
                chisel(index,hlist);
                }
            close(fdi); ibuffc = 0;
            flush();
            }
        index--;        gli--;
        lastmod = index;

/* make all the psects continues in memory.     */

        psects[0] = 0;  psects[1] = startadd;

        for(i = 1;i <= lastmod;i++){
                stlist[i][1] += startadd;
                flist[i][1] += startadd;
                }

        for(i = 2;i != 9;i++){                  /* for each psect */
                tmp = psects[i] = flist[lastmod][i-1] + 1;
                for(j = 1;j <= lastmod;j++){
                        stlist[j][i] += tmp;
                        flist[j][i] += tmp;
                        }
                }


 /* move glbals around to correct area          */
        for(i = 0;i <= gli;i++)
                galist[i] += psects[gplist[i]];

        wln = 1;
        while(wlist[wln] != -1){
                printf("Can't find '%s.rel'.\n",wlist[wln]);
                numerrs++;
                wln++;
                }

/* have all data on routines in the hlist and other tables      */

  /* open 10 files, 1 for each printed psect.   */

        for(i = 0;i != 10;i++){
                copystr(s,argv[1]);     cats(s,files[i]);
                pfdo[i] = creat(s,0644);
                pobuffp[i] = &pobuff[i][0];
                pobuffc[i] = 0;
                operr(pfdo[i],s);
                }

        curmod = 1;     rpc = 0;
 loop2: while(hlist[curmod] != -1){     /* relocate all moduals */
            if(hldir[curmod] == 0){
                s[0] = '\0';
                cats(s,hlist[curmod]);
                cats(s,".rel");
                i = open(s,0);
                }
             else {
                copystr(s,argv[hldir[curmod]]);
                cats(s,"/");
                cats(s,hlist[curmod]);
                cats(s,".rel");
                i = open(s,0);
                }
            if(i == -1){
                printf("Can't find '%s' anymore.\n",hlist[curmod]);
                printf("Actual file was '%s'.\n",s);
                numerrs++;
                curmod++;
                goto loop2;
                }
            fdi = i;
            j = 0;      jj = 0;
            while((c = get())!= '\0'){  /* get mods. external referances*/
                if(c == 'S'){
                    if((c = get()) == '7'){
                        xloc[j] = getwrd();
                        ploc[j] = getbyte();
                        p = ss;
                        while(((c= get())!= '\n')&&(c!= '\0'))*p++ = c;
                        *p = '\0';
                        i = llu(ss,glist);
                        if(i == -1){
/*      redundent error situation
                            printf("Table error on %s.\n",ss);
*/
                            }
                          else rloc[j++] = galist[i];
                        if(j == NMXREF){
                            printf("Too many externals in moduale '");
                            printf("%s'.  Increase 'NMXREF.\n",s);
                            numerrs++;
                            j--;
                            }
                        }
                    else if(c == 'A'){
                        while(((c=get()) != '\0')&&(c != '\n'));
                        c = 'A';
                        }
                    else if(c == 'B'){
                        rxloc[jj] = getwrd();
                        rploc[jj] = getbyte();
                        p = ss;
                        while(((c= get())!= '\n')&&(c!= '\0'))*p++ = c;
                        *p = '\0';
                        i = llu(ss,glist);
                        if(i == -1){
/*      redundant error situation
                                printf("Table error on %s.\n",ss);
*/
                            }
                          else rrloc[jj++] = galist[i];
                        if(jj == NMXREF){
                            printf("Too many relative externals in moduale '");
                            printf("%s'.  Increase 'NMXREF.\n",s);
                            numerrs++;
                            jj--;
                            }
                        }
                    }
                }
            close(fdi);         xloc[j] = -1;   rxloc[jj] = -1;
            flush();    ibuffc == 0;

/* have read this moduales externals and can now relocate       */

            for(i = 0;i != 16;i++)
                pc[i] = stlist[curmod][i];
            index = 0;  rindex = 0;
            fdi = open(s,0);
            if(fdi == -1){printf("Can't find '%s' anymore.\n",s);
                          numerrs++;}
            rpc = 0;
            while((c = get()) != '\0'){         /* read object mod. */
                if(c == 'S'){
                    if(get() == '2'){

/* S2 BC RRRR AAAA SS  SS DD [ SS DD ] CK               */

                        bc = getbyte() - 5;
                        reloc = getwrd();
                        mask = 1 << (bc -1);
                        rpc = getwrd();
                        psect = getbyte();
                        if(psect >9)psect = 9;
                        while(bc > 0){
                            if((mask & reloc)||((xloc[index]== rpc) && (ploc[index] == psect))||((rxloc[rindex]== rpc) && (rploc[index] == psect))){
                                pc[psect] = stlist[curmod][psect]+rpc;
                                gwpsect = getbyte();
                                ii = getbyte() << 8;
                                getbyte();
                                ii += getbyte();
                                if(mask & reloc){
                                    ii += stlist[curmod][gwpsect];
                                    }
                                if((xloc[index] == rpc) && (ploc[index] == psect)){
                                    ii += rloc[index++];
                                    }
                                if((rxloc[rindex] == rpc) && (rploc[rindex] == psect)){
                                    ii += rrloc[rindex++] - pc[psect] - 2;
                                    }
                                b1 = (ii >> 8) & 0377;
                                pprb();
                                pc[psect] += 1;
                                b1 = ii & 0377;
                                pprb();
                                pc[psect] += 1;
                                rpc += 2;
                                bc = bc - 2;
                                mask = (mask >> 2) & 077777;
                                }
                              else {
                                psect = getbyte();
                                if(psect >9)psect = 9;
                                pc[psect] = stlist[curmod][psect]+rpc;
                                b1 = getbyte();
                                pprb();
                                rpc += 1;
                                bc -= 1;
                                mask = (mask >> 1) & 077777;
                                }
                            }
                        }
                    }
                }
            curmod++;
            close(fdi); ibuffc = 0;     flush();
            }                           /* while(hlist... done. */

/*      have relocated and dumped everything.                   */
/*  Close the 10 psect files                                    */

        for(i = 0;i != 10;i++){
                psect = i;
                if(ppcocnt[i])ppdump();
                }
        pfput();

/*  Now concatinate the 10 psect files to argv.out              */

        copystr(s,argv[1]);     cats(s,".out");
        fdo = creat(s,0644);
        if(fdo == -1){
                printf("Can't create '%s'.\n",s);
                flush();        exit(-1);
                }
        obuffc = 0;     obuffp = &obuff[0];

        for(i = 0;i != 10;i++){
                copystr(s,argv[1]);     cats(s,files[i]);
                fdi = open(s,0);
                if(fdi == -1){
                        printf("Can't find %s anymore.\n",s);
                        numerrs++;
                        }
                ibuffc = 0;
                while((c = get()) != '\0'){
                        put(c);
                        }
                close(fdi);
                }
        put('S');  put('9');  put('\n');   fput();
        close(fdo);

        for(i = 0;i != 10;i++){
                copystr(s,argv[1]);     cats(s,files[i]);
                unlink(s);
                }

 /*   Dump out symbol table     */
        copystr(opener,argv[1]);
        cats(opener,".rel");
        ibuffc = 0;     fdi = open(opener,0);
        if(fdi == -1){printf("Can't open %s anymore.\n",opener);flush();exit(-1);}
        obuffp = obuff; obuffc = 0;
        copystr(opener,argv[1]);        cats(opener,".sym");
        fdo = creat(opener,0644);
        if(fdo== -1){printf("Can't create '%s'.\n",opener);flush();exit(-1);}
crock1: while((c = get()) != '\0'){     /* main mods symbols */
            if(c == 'S'){
                if(get() == 'A'){
                    j = getwrd();
                    tmp = getbyte();
                    c = get();
                    put('0');
                    putwrd(stlist[1][tmp] + j);
                    put(':');
                    put(c);
                    while(put(get()) != '\n');
                    goto crock1;        /* bug patch 1/18/80 pdh */
                    }
                while(((c=get()) != '\0')&&(c != '\n'));
                }
            }
        i = 1;
        while(glist[i] != -1){          /* all global symbols */
                put('0');
                putwrd(galist[i]);
                put(':');
                p = glist[i++];
                while(*p)put(*p++);
                put('\n');
                }
        fput();
                                        /* symbol file done */

        copystr(opener,argv[1]);        cats(opener,".map");
        i = creat(opener,0644);
        if(i == -1){printf("Can't create '%s'.\n",opener);flush();exit(1);}
        flush();
        fout = i;
        i = 1;
        printf("Name\t\ttext\tdata\tbss\n");
        while(hlist[i] != -1){
            if((i - 1)% 5 == 0){
                printf("+-------+-------+-------+-------+----\n");
                }
            pn16(hlist[i]);
            if(rlist[i]){
                    printf("Rom\t");
                    printf("Modual\t");
                    }
                else {
                    basout(stlist[i][1],16);    putchar('\t');
                    basout(stlist[i][2],16);    putchar('\t');
                    basout(stlist[i][3],16);    putchar('\n');
                    }
            i++;
            }

        printf("\nPsect starting addresses:\n");
        printf("text=%h  data=%h  bss=%h  stack=%h",psects[1],psects[2],psects[3],psects[4]);
        printf("\nps5=%h  ps6=%h  ps7=%h  ps8=%h\n\n",psects[5],psects[6],psects[7],psects[8]);

        printf("Globals are:\tpsect\tabs-address\n");
        i = 1;
        while(glist[i] != -1){
                pn16(glist[i]);
                pn8(files[gplist[i]]);
                basout(galist[i++],16); putchar('\n');
                }
        if(glist[1] == -1)printf(" [ NONE ] \n");
        flush();

        if(numerrs)exit(-1);
        exit(0);
}

get()
{
        if(ibuffc == 0){
                ibuffc = read(fdi,ibuff,512);
                if(ibuffc == 0)return('\0');
                if(ibuffc == -1)return('\0');
                ibuffp = ibuff;
                }
        ibuffc--;
        return((*ibuffp++) & 0177);
}

getbyte()
{
        register i;     register char c;

        c = get() - 060;
        if(c > 9)c -= ('A' - ':');
        i = (c << 4) & 0360;
        c = get() - 060;
        if(c > 9)c -= ('A' - ':');
        return(i + c);
}

getwrd()
{
        register i;
        i = getbyte() << 8;
        return(i + getbyte());
}

put(data)
        char data;
{
        if(obuffc == 512){
                obuffc = write(fdo,obuff,512);
                obuffc = 0;     obuffp = obuff;
                }
        *obuffp++ = data;
        obuffc++;
        return(data);
}

putbyte(data)
        int data;
{
        register i;
        i = (data >> 4) & 017;  i += '0';
        if(i > '9')i += ('A' - ':');
        put(i);
        i = data & 017; i+= '0';
        if(i > '9')i += ('A' - ':');
        put(i);
}

putwrd(data)
        int data;
{
        putbyte((data >> 8) & 0377);
        putbyte(data & 0377);
}

fput()
{
        obuffc = write(fdo,obuff,obuffc);
        close(fdo);
        flush();
}

prb()
{
        if(pcost){pcost = 0;    pcolpc = pc;}
 prbq:  if(pcocnt == 0){
                pcolpc = pc;
                pcobs = pc;
                }
        if(pc != pcolpc){
                pdump();
                goto prbq;
                }
        pcob[pcocnt++] = b1;
        pcolpc += 1;
        if(pcocnt > 25)pdump();
}

pdump()
{
        register i;

        put('S');       put('1');
        i = 0;
        putbyte(pcocnt + 3);
        pcoch = pcocnt + 3;
        putwrd(pcobs);
        pcoch += pcobs >> 8;
        pcoch += pcobs & 0377;
        while(pcocnt){
                putbyte(pcob[i]);
                pcocnt--;
                pcoch += pcob[i++];
                }
        putbyte(~pcoch);
        put('\n');
}

operr(i,s)
        int i;  char *s;
{
        if(i == -1){
                printf("Can't create %s.\n",s);
                flush();
                exit(-1);
                }
}

pput(data)
        char data;
{
        if(pobuffc[psect] == 512){
            pobuffc[psect] = write(pfdo[psect],&pobuff[psect][0],512);
            pobuffc[psect] = 0; pobuffp[psect] = &pobuff[psect][0];
            }
        *(pobuffp[psect])++ = data;
        pobuffc[psect]++;
        return(data);
}

pputbyte(data)
        int data;
{
        register i;
        i = (data >> 4) & 017;  i += '0';
        if(i > '9')i += ('A' - ':');
        pput(i);
        i = data & 017; i+= '0';
        if(i > '9')i += ('A' - ':');
        pput(i);
}

pputwrd(data)
        int data;
{
        pputbyte((data >> 8) & 0377);
        pputbyte(data & 0377);
}

pfput()
{
        register i;
        for(i = 0;i != 10;i++){
                write(pfdo[i],&pobuff[i][0],pobuffc[i]);
                close(pfdo[i]);
                }
}

pprb()
{
        if(ppcost[psect]){ppcost[psect] = 0;   ppcolpc[psect] = pc[psect];
                ppcocnt[psect] = 0;}
 pprbq: if(ppcocnt[psect] == 0){
                ppcolpc[psect] = pc[psect];
                ppcobs[psect] = pc[psect];
                }
        if(pc[psect] != ppcolpc[psect]){
                ppdump();
                goto pprbq;
                }
        ppcob[psect][ppcocnt[psect]++] = b1;
        ppcolpc[psect] += 1;
        if(ppcocnt[psect] > 25)ppdump();
}

ppdump()
{
        register i;

        pput('S');      pput('1');
        i = 0;
        pputbyte(ppcocnt[psect] + 3);
        pcoch = ppcocnt[psect] + 3;
        pputwrd(ppcobs[psect]);
        pcoch += ppcobs[psect] >> 8;
        pcoch += ppcobs[psect] & 0377;
        while(ppcocnt[psect]){
                pputbyte(ppcob[psect][i]);
                ppcocnt[psect]--;
                pcoch += ppcob[psect][i++];
                }
        pputbyte(~pcoch);
        pput('\n');
}

pn16(s)
        char *s;
{
        register i;
        register char *p;
        p = s;
        i = 0;
        while(*p){
                putchar(*p++);
                i++;
                }
        while(i++ < 16)putchar(' ');
}

pn8(s)
        char *s;
{
        register i;
        register char *p;
        p = s;
        i = 0;
        while(*p){
                putchar(*p++);
                i++;
                }
        while(i++ < 8)putchar(' ');
}
