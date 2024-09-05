/*
 *      fatal --- fatal error handler
 */
fatal(str)
char    *str;
{
        printf("%s\n",str);
        exit(-1);
}

/*
 *      error --- error in a line
 *                      print line number and error
 */
error(str)
char    *str;
{
        if(N_files > 1)
                printf("%s,",Argv[Cfn]);
        printf("%d: ",Line_num);
        printf("ERROR %s\n",str);
        Err_count++;
}
/*
 *      errors --- error in a line
 *                      print line number and error and string
 */
errors(char *msg, char *str)
{
        if(N_files > 1)
                printf("%s,",Argv[Cfn]);
        printf("%d: ",Line_num);
        printf("ERROR %s\n   %s\n",msg,str);
        Err_count++;
}
/*
 *      warn --- trivial error in a line
 *                      print line number and error
 */
warn(str)
char    *str;
{
        if(N_files > 1)
                printf("%s,",Argv[Cfn]);
        printf("%d: ",Line_num);
        printf("Warning --- %s\n",str);
}


/*
 *      delim --- check if character is a delimiter
 *      Slightly bizar: !@#$%^&()_+ are all accepted
 *      as valid label characters.
 *      Blank and the comment sign are delimiters.
 */
delim(c)
char    c;
{
        if( any(c," :;\t\n") || EOS==c )
                return(YES);
        return(NO);
}

/*
 *      skip_white --- move pointer to next non-whitespace char
 */
char *skip_white(ptr)
char    *ptr;
{
        while( any(*ptr," \n\t\r") )
                ptr++;
        return(ptr);
}

/*
 *      eword --- emit a word to code file
 */
eword(wd)
int     wd;
{
        emit(hibyte(wd));
        emit(lobyte(wd));
}

/*
 *      emit --- emit a byte to code file
 */
emit(byte)
{
#ifdef DEBUG
        printf("%2x @ %4x\n",byte,Pc);
#endif
        if(Pass==1){
                Pc++;
                return(YES);
                }
        if(P_total < P_LIMIT)
                P_bytes[P_total++] = byte;
        E_bytes[E_total++] = byte;
        Pc++;
        if(E_total == E_LIMIT)
                f_record();
}

/*
 *      f_record --- flush record out to S19 and Bin files if neccesary
 */
f_record()
{
        int     i;
        int     chksum;

        if(Pass == 1)
          return;
        if(E_total==0)
        {
          E_pc = Pc;
          return;
        }
        chksum =  E_total+3;    /* total bytes in this record */
        chksum += lobyte(E_pc);
        chksum += E_pc>>8;
        if (Oflag)
        {
          fprintf(Objfil,"S1");   /* record header preamble */
          hexout(E_total+3);      /* byte count +3 */
          hexout(E_pc>>8);        /* high byte of PC */
          hexout(lobyte(E_pc));   /* low byte of PC */
        }
        for(i=0;i<E_total;i++)
        {
          chksum += lobyte(E_bytes[i]);
          if (Oflag)
            hexout(lobyte(E_bytes[i])); /* data byte */
          if (Bflag)
            binout(E_bytes[i]);         /* binary data */
        }
        chksum =~ chksum;               /* one's complement */
        if (Oflag)
        {
          hexout(lobyte(chksum));       /* checksum */
          fprintf(Objfil,"\n");
        }
        E_pc = Pc;
        E_total = 0;
}

char    *hexstr = { "0123456789ABCDEF" } ;

hexout(byte)
int     byte;
{
        char hi,lo;

        byte = lobyte(byte);
        fprintf(Objfil,"%c%c",hexstr[byte>>4],hexstr[byte&017]);
}

binout(byte)
int     byte;
{
        fprintf(Binfil,"%c",byte);
}

/*
 *      print_line --- pretty print input line to List file
 */
print_line()
{
        int     i;

        if (Lflag==0)
          return;
        else
        {
          fprintf (Lstfil,"%04d ",Line_num);
          if(P_total || P_force)
            fprintf(Lstfil,"%04x",Old_pc);
          else
            fprintf(Lstfil,"    ");
          for(i=0;i<P_total && i<6;i++)
            fprintf(Lstfil," %02x",lobyte(P_bytes[i]));
            for(;i<6;i++)
              fprintf(Lstfil,"   ");
            fprintf(Lstfil,"  ");

            if(Cflag){
              if(Cycles)
                fprintf(Lstfil,"[%2d ] ",Cycles);
              else
                fprintf(Lstfil,"      ");
            }
            Line[strlen(Line)-1] = EOS;  /* No \n */
            fprintf(Lstfil,"%s",Line);  /* just echo the line back out */
            for(;i<P_total;i++)
            {
              if( i%6 == 0 )
                fprintf(Lstfil,"\n    ");
              fprintf(Lstfil," %02x",lobyte(P_bytes[i]));
            }
          fprintf(Lstfil,"\n");
        }
      }
/*
 *      any --- does str contain c?
 */
any(c,str)
char    c;
char    *str;
{
        while(*str != EOS)
                if(*str++ == c)
                        return(YES);
        return(NO);
}

/*
 *      mapdn --- convert A-Z to a-z
 */
char mapdn(c)
char c;
{
        if( c >= 'A' && c <= 'Z')
                return(c+040);
        return(c);
}

/*
 *      lobyte --- return low byte of an int
 */
lobyte(i)
int i;
{
        return(i&0xFF);
}
/*
 *      hibyte --- return high byte of an int
 */
hibyte(i)
int i;
{
        return((i>>8)&0xFF);
}

/*
 *      head --- is str2 the head of str1?
 */
int head( char *str1, char *str2 )
{
        int l=strlen(str2);
        return !strncasecmp(str1, str2, l) &&
               ( EOS==str1[l] ||  any(str1[l]," \t\n,+-];*"));
}

/*
 *      alpha --- is character a legal letter
 */
alpha(c)
char c;
{
        if( c<= 'z' && c>= 'a' )return(YES);
        if( c<= 'Z' && c>= 'A' )return(YES);
        if( c== '_' )return(YES);
        if( c== '.' )return(YES);
        return(NO);
}
/*
 *      alphan --- is character a legal letter or digit
 */
alphan(c)
char c;
{
        if( alpha(c) )return(YES);
        if( c<= '9' && c>= '0' )return(YES);
        if( c == '$' )return(YES);      /* allow imbedded $ */
        return(NO);
}

/*
 *      white --- is character whitespace?
 */
white(c)
char c;
{
        return any(c," \n\t\r")? YES: NO ;
}

/*
 *      alloc --- allocate memory
 */
char *
alloc(nbytes)
int nbytes;
{
        char *malloc();

        return(malloc(nbytes));
}
