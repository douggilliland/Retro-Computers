/*                                                    */
/* ****** ****** **** Find Utility **** ****** ****** */
/* Most of the subroutines are adaptations of the     */
/* find rountines found in SOFTWARE TOOLS, by Brian   */
/* Kernighan and P.J. Plauger. The concepts of OR     */
/* and AND were added to those in this program. 7/81  */
/*                                                    */
#include <stdio.h>
#define    MAXLIN  512
#define    NDGT    6
#define    Y       1
#define    N       0
#define    AND    '&'
#define    ANY    '?'
#define    BEGLIN '<'
#define    CHR    'a'
#define    CCL    '['
#define    CCLEND ']'
#define    DASH   '-'
#define    ENDLIN '>'
#define    EOS     0
#define    ESCAPE '\\'
#define    NCCL   'n'
#define    NOT    '!'
#define    OR     '|'
#define    OPARA  '('
#define    CPARA  ')'
#define    MAXPAT  200
#define    ERR    -1
#define    ZERO   '0'

char       line[MAXLIN],pat[MAXPAT];
int        yflag,cflag,nflag,fflag,long_line;

main(argc,argv) /* Main for find utility */
int argc;
char *argv[];
{
int i,c,fp;
char *arg;
extern char pat[MAXPAT];
extern int yflag,cflag,nflag,fflag;
i=1;
yflag=cflag=nflag=fflag=N;
      /* Print syntax if number of arguements < 3 */
if (argc<2) {
   printf("usage:  ++ find [+options] \"pattern\" <file ...>\n");
   exit(1);
   }
      /* If Options list, deal with them */
if (*argv[i]=='+') {
  arg=argv[i];
  while ((c=*(++arg))!='\0') {
     if (c=='u') yflag=Y;
     else if (c=='c') cflag=Y;
     else if (c=='n') nflag=Y;
     else printf("\n%c is an illegal option.\n",c); }
  i++; }
      /* Assign next arg to pat and go on */
if(makpat(argv[i])< 0)  exit(1);
    /* printf("\nPAT = %s\n",pat);     debug  */
i++;
if (argc-i > 0) {
     /* Begin search for pattern in file(s)  */
   for (; i<argc; i++) {
       if ((fp=fopen(argv[i],"r"))==NULL)
          printf("Can't open \"%s\"\n",argv[i]);
       else {
          search(fp,argv[i]);
          fclose(fp);
          }
       }
   printf("\n");
   }
else printf("usage:  ++ find [+options] \"pattern\" <file ...>\n");
}

makpat(arg)     /* Function to assimilate the pattern */
char *arg;
{
extern char pat[MAXPAT];
int i,j,lastj,lastcl,lj,junk;
lastj=0;
lastcl=0;
j=0;
 for(i=0;;i++)
   { if ((*(arg+i)=='\0') || (j>=MAXPAT)) break;
     lj=j;
     if(*(arg+i)==ANY) addset(ANY,(&j));
     else if((*(arg+i)==BEGLIN) && (i==0)) addset(BEGLIN,(&j));
     else if((*(arg+i)==ENDLIN) && (*(arg+i+1)==EOS))
             addset(ENDLIN,(&j));
     else if(*(arg+i)==CCL)
            { if(getccl(arg,(&i),(&j))==-1)
                { printf("Char. class not closed.\n");
                  exit(1); }}
     else if(*(arg+i)==OPARA)
            { if(getcon(arg,(&i),(&j))==-1)
                { printf("Conditional pattern group was incorrect.\n");
                  exit(1); }}
     else if((*(arg+i)==AND) && (i!=0))
            addset(AND,(&j));
     else { addset(CHR,(&j));
            if((*(arg+i)==ESCAPE) && (*(arg+i+1)!=EOS)) i++;
              addset(*(arg+i),(&j));
          }
 lastj=lj;
 }
if(addset(EOS,(&j))==-1) return(-1);
else return(i);
}


addset(c,pj)
char c; int *pj;
{
extern char pat[MAXPAT];
if(*pj>MAXPAT) return(-1);
else { pat[*pj]=c;
     *pj=*pj + 1;
     return(0); }
}


getccl(arg,ip,jp)  /* Expand char class at arg[i] to pat[j] */
char *arg; int *ip,*jp;
{
extern char pat[MAXPAT];
int jstart,temp;
*ip=*ip + 1;;
if(*(arg+*ip)==NOT) { addset(NCCL,jp);
                      *ip=*ip + 1;}
else addset(CCL,jp);
jstart=*jp;
addset(ZERO,jp);   /* Leave room for count */
filset(CCLEND,arg,ip,jp);
temp=(*jp)-jstart-1;
pat[jstart]=temp;
if(arg[*ip]==CCLEND) return(1);
else return(-1);
}


filset(delim,array,ip,jp)
char delim,*array; int *ip,*jp;
{ extern char pat[MAXPAT];
  char *digits,*lowalf,*upalf;
digits="0123456789";
lowalf="abcdefghijklmnopqrstuvwxyz";
upalf="ABCDEFGHIJKLMNOPQRSTUVWXYZ";
 /* Now parse the char. class and fill out */
for(*ip;;*ip=*ip + 1)
  { if((array[*ip]==delim) || (array[*ip]=='\0')) break;
    if (array[*ip]==ESCAPE)
      { if (array[(*ip)+1]!=EOS) *ip++;
        addset(array[*ip],jp);}
    else if(array[*ip]!=DASH)
      addset(array[*ip],jp);
    else if((*jp<=1) || (array[(*ip)+1]==EOS))
      addset(DASH,jp);
    else if(strindex(digits,pat[(*jp)-1])>=0)
      dodash(digits,array,ip,jp);
    else if(strindex(lowalf,pat[(*jp)-1])>=0)
      dodash(lowalf,array,ip,jp);
    else if(strindex(upalf,pat[(*jp)-1])>=0)
      dodash(upalf,array,ip,jp);
    else addset(DASH,jp);
  }
return;
}


strindex(str,c)
char *str,c;
{ int i;
for(i=0;str[i]!=EOS;i++)
  if(str[i]==c) return(i);
return(-1);
}


dodash(valid,array,pi,pj)  /* Expand set short-hand */
int *pi,*pj; char *valid,*array;
{ int limit,k;
extern char pat[MAXPAT];
*pi=*pi + 1;
*pj=*pj - 1;
if((array[*pi]==ESCAPE) && (array[*pi]!=EOS)) *pi=*pi + 1;;
limit=strindex(valid,array[*pi]);
for(k=strindex(valid,pat[*pj]);k<=limit;k++)
   addset(*(valid+k),pj);
return;
}


getcon(arg,ip,jp)  /* to setup conditional pattern grp struct. */
char *arg; int *ip,*jp;
{ int tl,l1,l2;
  extern char pat[MAXPAT];
  char c;
  int jstart;
addset(OR,jp);
jstart=*jp;
addset(ZERO,jp);
addset(ZERO,jp);
addset(ZERO,jp);
*ip=*ip + 1;
tl=l2=l1=0;
while((c=*(arg+*ip))!=OR)
  { if(c==EOS) return(-1);
    addset(c,jp);
    *ip=*ip + 1;
    l1++; }
if(l1==0) return(-1);
*ip=*ip + 1;
while((c=*(arg+*ip))!=CPARA)
  { if(c==EOS) return(-1);
    addset(c,jp);
    *ip=*ip + 1;
    l2++; }
if(l2==0) return(-1);
tl=l1+l2;
pat[jstart++]=l1;
pat[jstart++]=l2;
pat[jstart++]=tl;
return(tl);
}


search(fp,file)
char *file; int fp;
{ int lcnt,mcnt;
  extern char line[];
  extern int  cflag;
mcnt=lcnt=0;
long_line=0;
while (getline(line,MAXLIN,fp)!=NULL)
  { ++lcnt;
    if (match(line,0,0)>=0)
      { ++mcnt;
        if(cflag==N)
          { if(mcnt==1 && fflag==N) printf("File:  %s\n",file);
            if (long_line==1) {
               printf("     Line longer than 512 characters.  Line numbers should be disregarded.\n");
               long_line=0;
               }
            if(nflag==N)
                printf("%6d=  %s",lcnt,line);
            else printf("%s",line); }}}
if (cflag==Y){
   if (mcnt==1) printf("%d matching line in file: %s\n",mcnt,file);
   else        printf("%d matching lines in file: %s\n",mcnt,file); }
return;
}


getline(buf,len,iop)       /* Function to get a line from a file */
int   iop,len;  char *buf;
{ int c; char *bp;
bp=buf;
while ((len--)>0 && (c=getc(iop))!=EOF)
  if ((*bp++=c)==EOL) break;
*bp='\0';
if (len<=0 && c!=EOL) long_line=1;
if (c==EOF) return NULL;
return buf;
}


match(line,i,j)
char line[]; int i,j;
{ int temp;
for(i;line[i]!='\0';i++)
  {
  temp=amatch(line,i,j);
  if(temp>=0) return(temp);
   }
return(-1);
 }


amatch(line,from,at)    /* Anchored match at line[from] */
                        /*   in pat[at] */
char line[]; int from,at;
{ int i,j,b,res;
  extern char pat[MAXPAT];
i=from;
j=at;
for(j;pat[j]!='\0';j=j+patsiz(j))
  {
    if(pat[j]==OR)
      { if((b=door(line,i,j))<0) return(-1);}
    else if(pat[j]==AND)
      { j++;
        res=match(line,0,j);
        if(res>=0) return(res);
        else return(-1); }
    else { if((b=omatch(line,i,j))<0) return(-1);}
    i=i+b; }
return(i);
}


door(line,i,j) /* do match on OR string */
int i,j; char line[];
{ int len1,len2,total,k;
  extern char pat[MAXPAT];
++j;
len1=pat[j++];
len2=pat[j++];
total=pat[j++];
if((len1+len2)!=total) { printf("In DOOR: total len. OR pat not right\n");
                         exit(1); }
 for(k=0;k<len1;k++)
   { if(pat[j+k]!=line[i+k]) k=len1+1; }
if(k<=len1) return(len1); /* if matched return len1 */
j = j + len1;    /* skip onve subpat1 */
 for(k=0;k<len2;k++)
   { if(pat[j+k]!=line[i+k]) return(-1); }
return(total);
}


omatch(line,i,j)    /* Match line[i] to pat[j] */
char line[]; int i,j;
{ int bump;
  extern char pat[MAXPAT];
bump=-1;
if(line[i]=='\0') return(bump);
if(pat[j]==CHR) { if(line[i]==pat[j+1])
                     bump=1;
                  else if(yflag==Y)
                         if((line[i]>='A') && (line[i]<='Z'))
                           if(pat[j+1]==(line[i]+32))
                             bump=1;
                }
else if(pat[j]==ANY) { if(line[i]!='\n')
                       bump=1; }
else if(pat[j]==BEGLIN) { if(i==0)
                          bump=0; }
else if(pat[j]==ENDLIN) { if(line[i]=='\n')
                          bump=0; }
else if(pat[j]==CCL) { if(locate(line[i],(j+1))==Y)
                       bump=1; }
else if(pat[j]==NCCL)
        { if((line[i]!='\n') && (locate(line[i],(j+1))==N))
          bump=1; }
else { printf("In OMATCH: can't happen.\n");
       exit(3); }
return(bump);
}


locate(c,offset)    /* To locate in a char. class */
char c; int offset;
{ int i;
  extern char pat[MAXPAT];
for(i=offset+pat[offset];i>offset;i--)
 if(c==pat[i]) return(Y);
return(N);
}


patsiz(n)   /* Returns size of subpattern */
int n;
{ extern char pat[MAXPAT];
  int len;
if(pat[n]==CHR) return(2);
else if((pat[n]==BEGLIN) || (pat[n]==ENDLIN) || (pat[n]==ANY) || (pat[n]==AND))
     return(1);
else if((pat[n]==CCL) || (pat[n]==NCCL))
       { len=pat[n+1] + 2;
         return(len); }
else if (pat[n]==OR)
       { len=pat[n+3]+4;
         return(len); }
else { printf("In PATSIZ: can't happen.\n");
       exit(4); }
return(1);
}
