char mapdn();
char *alloc();
/*
 *      as ---  cross assembler main program
 *      This requries a very peculiar set of arguments:
 *      First come *all* the file names.
 *      Then comes the first option, with a dash
 *      Then come the, possibly multichar, options without dash.
 */
main(argc,argv)
int     argc;
char    **argv;
{
        char    **np;
        char    *pc;
        FILE    *fopen();
        int     j = 0;

        if(argc < 2){
                printf("Usage: %s [files]\n",argv[j]);
                exit(1);
                }
          Argv = argv;
          initialize();
          while ( (j<argc) && (*argv[j] != '-') )
           j++;
          N_files = j-1;
         if (j < argc )
          {
          argv[j]++;
          while (j<argc)
             {
             for (pc = argv[j]; *pc != 0; pc++)
               *pc = tolower( (unsigned char)*pc );

             if (strcmp(argv[j],"l")==0)
               Lflag = 1;
             else if (strcmp(argv[j],"nol")==0)
               Lflag = 0;
             else if (strcmp(argv[j],"c")==0)
               Cflag = 1;
             else if (strcmp(argv[j],"noc")==0)
               Cflag = 0;
             else if (strcmp(argv[j],"s")==0)
               Sflag = 1;
             else if (strcmp(argv[j],"cre")==0)
               Rflag = 1;
             else if (strcmp(argv[j],"bin")==0)
               Bflag = 1;
             else if (strcmp(argv[j],"s19")==0)
               Oflag = 1;
             else if (strcmp(argv[j],"w")==0)
               Wflag = 1;
             else if (strcmp(argv[j],"now")==0)
               Wflag = 0;
             else
               fatal("Unknown option");
             j++;
             }
          }
        root = NULL;

        Cfn = 0;
        np = argv;
        Line_num = 0; /* reset line number */
        while( ++Cfn <= N_files )
                if((Fd = fopen(*++np,"r")) == NULL)
                        printf("as: can't open %s\n",*np);
                else{
                        make_pass();
                        fclose(Fd);
                }
        if( Err_count == 0 ){
                Pass++;
                re_init();
                Cfn = 0;
                np = argv;
                Line_num = 0;
                open_files();               /* open all necessary files */
                while( ++Cfn <= N_files)
                        if((Fd = fopen(*++np,"r")) != NULL)
                            {
                                make_pass();
                                fclose(Fd);
                             }
                        if (Sflag == 1)
                          {
                           stable (root);
                          }
                        if (Rflag == 1)
                          {
                           cross (root);
                          }

                if ( Oflag )
                    fprintf(Objfil,"S9030000FC\n"); /* at least give a decent ending */
                }
        exit(Err_count);
}

initialize()
{
        FILE    *fopen();
        int     i = 0;

#ifdef DEBUG
        printf("Initializing\n");
#endif
        Err_count = 0;
        Pc        = 0;
        Pass      = 1;
        Lflag     = 0;
        Cflag     = 0;
        Ctotal    = 0;
        Sflag     = 0;
        Rflag     = 0;
        Bflag     = 0;
        Oflag     = 0;
        N_page    = 0;

        strcpy(Obj_name,Argv[1]); /* copy object file name into array */
        strcpy(Bin_name,Argv[1]); /* copy binary file name into array */
        strcpy(Lst_name,Argv[1]); /* copy list   file name into array */
        strcpy(Sym_name,Argv[1]); /* copy symbol file name into array */
        strcpy(Crf_name,Argv[1]); /* copy crf    file name into array */

        do {
            if (Obj_name[i]=='.')
               Obj_name[i]=0;
            if (Bin_name[i]=='.')
               Bin_name[i]=0;
            if (Lst_name[i]=='.')
               Lst_name[i]=0;
            if (Sym_name[i]=='.')
               Sym_name[i]=0;
            if (Crf_name[i]=='.')
               Crf_name[i]=0;
        }
        while (Crf_name[i++] != 0);
        fwdinit();      /* forward ref init */
        localinit();    /* target machine specific init. */
}

re_init()
{
#ifdef DEBUG
        printf("Reinitializing\n");
#endif
        Pc      = 0;
        E_total = 0;
        P_total = 0;
        Ctotal  = 0;
        N_page  = 0;
        fwdreinit();
}

open_files()
{
        if(Oflag){
          strcat(Obj_name,".s19");  /* append .s19 to object file name. */
            if( (Objfil = fopen(Obj_name,"wt")) == NULL)
                fatal("Can't create object file");
        }

        if(Bflag){
          strcat(Bin_name,".bin");  /* append .bin to binary file name. */
            if( (Binfil = fopen(Bin_name,"wb")) == NULL)
                fatal("Can't create binary file");
        }

        if(Lflag){
          strcat(Lst_name,".lst");  /* append .lst to list file name. */
            if( (Lstfil = fopen(Lst_name,"wt")) == NULL)
                fatal("Can't create list file");
        }

        if(Sflag){
          strcat(Sym_name,".sym");  /* append .sym to symbol file name. */
            if( (Symfil = fopen(Sym_name,"wt")) == NULL)
                fatal("Can't create symbol file");
        }

        if(Rflag){
          strcat(Crf_name,".crf");  /* append .crf to cross reference file name. */
            if( (Crffil = fopen(Crf_name,"wt")) == NULL)
                fatal("Can't create cross reference file");
        }
}

make_pass()
{
        char *pc;
#ifdef DEBUG
        printf("Pass %d\n",Pass);
#endif
        while( fgets(Line,MAXBUF,Fd) ){
                pc = Line+strlen(Line);  /* Past character. */
                if ( '\r'==pc[-2] ) { pc[-2]='\n';pc[-1]=0;}
                Line_num++;
                P_force = 0;    /* No force unless bytes emitted */
                N_page = 0;
                if(parse_line())
                        process();
                if(Pass == 2 && Lflag && !N_page)
                        print_line();
                P_total = 0;    /* reset byte count */
                Cycles = 0;     /* and per instruction cycle count */
                }
        f_record();
}


/*
 *      parse_line --- split input line into label, op and operand
 */
parse_line()
{
        register char *pcfrm = Line;
        register char *pcto;
        char    *skip_white();

        if( *pcfrm == '*' || *pcfrm == '\n' ||
            *pcfrm == ';' )
                return(0);      /* a comment line */
        /***************************/
        pcto = Label;
        while( delim(*pcfrm)== NO )   *pcto++ = *pcfrm++;
        /* allow trailing : */
        if(*pcfrm == ':')   pcfrm++;
        *pcto = EOS;

        pcfrm = skip_white(pcfrm);

        /***************************/
        pcto = Op;
        while( delim(*pcfrm) == NO)   *pcto++ = mapdn(*pcfrm++);
        *pcto = EOS;

        pcfrm = skip_white(pcfrm);

        /***************************/
        pcto = Operand;  /* Can contain comment */
        while( *pcfrm != NEWLINE && *pcfrm != EOS )
        {
                *pcto++ = *pcfrm++;
        }
        *pcto = EOS;

#ifdef DEBUG
        printf("Label-%s-\n",Label);
        printf("Op----%s-\n",Op);
        printf("Operand-%s-\n",Operand);
#endif
        return(1);
}

/*
 *      process --- determine mnemonic class and act on it
 */
process()
{
        register struct oper *i;
        struct oper *mne_look();
        char    *skip_white();

        Old_pc = Pc;            /* setup `old' program counter */
        Optr = Operand;         /* point to beginning of operand field */

        if(*Op==EOS){           /* no mnemonic */
                if(*Label != EOS)
                        install(Label,Pc);
                }
        else if( (i = mne_look(Op))== NULL)
                error("Unrecognized Mnemonic");
        else if( i->class == PSEUDO )
                do_pseudo(i->opcode);
        else{
                if( *Label )install(Label,Pc);
                if(Cflag)Cycles = i->cycles;
                do_op(i->opcode,i->class);
                if(Cflag)Ctotal += Cycles;
                }

        if ( Wflag && 2 == Pass )
            if ( EOS!=*Optr ) {
                /* Yes I'm ashamed f this hack, (AH) */
                if ( ']' == *Optr ) Optr += 1;
                Optr = skip_white(Optr);
                if ( EOS!=*Optr && ';'!=*Optr ){
                   printf("<<<%s>>>\n", Optr);
                   warn("Comment doesnot start with comment symbol");
                   }
            }
}
