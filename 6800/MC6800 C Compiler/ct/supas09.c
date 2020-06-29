#define NUMSYM 700
        extern char symn[];
        extern int symll;
fsyml1(s)
        char *s;                /* symbol table lookup  */
{
        register char *p,*ps;
        register int i;
        char *pp;
        int j;
        p = &symn[0];
        i = 0;
        while(i++ < symll){
            j = 0;      pp = p;   ps = s;
            if(*p == *ps){
                while(*p == *ps++){
                        if(*p++ == '\0')return(--i);
                        if(++j >= 8)return(--i);
                        }
                }
            p = pp + 8;
            }
        return(-1);
}
fsyml2(s)
        char *s;
{
        return(fsyml1(s));
}
fsyms(s)
        char *s;
{
        register char *p,*pp;
        register i;
        int j;
        p = &symn[0];   pp = s;   i = 0;        j = 0;
        while(i++ < symll){
                if(*p == '\0'){
  fsymsl:               while(*pp && (j < 8)){
                                *p++ = *pp++;  j++;
                                }
                        if(j < 7)*p = '\0';
                        return(--i);
                        }
                p += 8;
                }
        if(i > NUMSYM){
                return(-1);
                }
        symll++;
        goto fsymsl;
}
llu(world,keylist)              /*   List Look Up       */
        char *world,*keylist[];
{
        register char *p,*m;
        register i;

        i = 0;                          /* point to first keylist */
        while(keylist[i] != -1){        /*      if more then:   */
                p = world;              /* point to input string */
                m = keylist[i++];       /* current keylist string */

                while((*p++ == *m++)&&(*(p-1)));   /* eat equal char */

                if((*--p == '\0')&&(*--m == '\0')) return(--i);
        }
        return(-1);
}
cement(item,table)
        char **table;
        char item[];
{
        register char *p,*j;
        register *i;
        j = item;
        i= table;
        while(*i++ != -1);
        *i = -1;
        i -= 2;
        p = *i;
        while(*p++);
        *++i = p;
        while(*p++ = *j++);
}
chisel(index,table)
        int index,*table;
{
        register t,f;
        register *i;
        t = table[index] - table[0];
        f = table[index + 1] - table[0];
        bumpd(table[0],t,f,lost(table));
        i = table;
        while(*++i != -1)if(i >= (table+ index+ 1)){
                                *i-= f-t;
                                }
        slide(table,index,index+1,(i- table));
}

lost(a)
        char **a;
{
        register *i;
        register char *p;
        i = a;
        while(*i++ != -1);
        i -= 2;
        p = *i;
        while(*p++);
        return((--p) - *a);
}
island(ch)
        char ch;
{
        if(((ch >= 'A')&&(ch <= 'Z'))||((ch >= 'a')&&(ch <= 'z'))) return (1);
        if((ch >= '0')&&(ch <= '9')) return(1);
        if(ch == '_')return(1);
        if(ch == '.')return(1);
        if(ch == '$')return(1);
        if(ch == '%')return(1);
        return(0);
}
islet(ch)
        char ch;
{
        if(((ch >= 'A')&&(ch <= 'Z'))||((ch >= 'a')&&(ch <= 'z'))) return (1);
        if(ch == '_')return(1);
        if(ch == '.')return(1);
        if(ch == '$')return(1);
        if(ch == '%')return(1);
        if((ch >= '0')&&(ch <= '9')) return(0);
        if((ch >= '!')&&(ch <= '/')) return(2);
        if((ch >= ':')&&(ch <= '?')) return(2);
        if((ch == '`')||(ch == '@')) return(2);
        if((ch >= '[')&&(ch <= '_')) return(2);
        if((ch >= '{')&&(ch <= '~')) return(2);
        return(3);
}
slide(table,fmto,tmfrom,ltable)
        int *table;
        int fmto,tmfrom,ltable;
{
        register *f,*t;
        register c;
        if((fmto >= tmfrom)||(tmfrom > ltable))return(-1);
        t = table + fmto;
        f = table + tmfrom;
        c = tmfrom;
        c = ltable - c + 1;
        for(;c;c--)*t++ = *f++;
        return(0);
}
mixerup(table,texts)
        int *table;     char *texts;
{
        register *p;
        p = table;
        *p++ = texts;
        *p = -1;
        p = texts;
        *p = '\0';
}
bumpd(table,fmto,tmfrom,ltable)
        char *table;
        int fmto,tmfrom,ltable;
{
        register char *f,*t;
        register c;
        if((fmto >= tmfrom)||(tmfrom > ltable))return(-1);
        t = table + fmto;
        f = table + tmfrom;
        c = ltable- tmfrom + 1;
        for(;c;c--)*t++ = *f++;
        return(0);
}
alsort2(list,vtable)
        char **list;
        int *vtable;
{
        char change;
        register *next;
        register *end;
        register i;
        int *temp,temp2;
/* find end of list */
        next = list;
        while(*next != -1)next++;
        if(next == list)return;         /* zero lenght list     */
        next--;                         /* point to last -1     */
        if(next == list)return;         /* 1 element list       */
        change = 1;
        end = next;             /* point to next to last string */
        while(change){
                change = 0;
                i = 0;
                for(next = list;next != end;next++){
                        if(alsrtx(*next,*(next+1))){
                                temp = *(next + 1);
                                *(next + 1) = *next;
                                *next = temp;
                                change = 1;
                                temp2 = vtable[i];
                                vtable[i] = vtable[i+1];
                                vtable[i+1] = temp2;
                                }
                        i++;
                        }
                }
}
alsrtx(next,one)                /* return 1 if "next" > "one"   */
        char *next,*one;
{
        register char *next2,*up;

        next2 = next;
        up = one;
        while(*next2 && *up){
                if(*next2 < *up)return(0);
                if(*next2 > *up)return(1);
                next2++;        up++;
                }
        if(*next2 == *up == '\0')return(0);
        if(*next2)return(1);
        return(0);
}
basout(n,base)
        unsigned int n,base;
{
        register i;
        register k;

        i = n % base;
        if( k = (n / base) )
                basout(k,base);
        i += '0';
        putchar(i < ':' ? i : i + 'a' - ':');
}
cats(st1,st2)
        char st1[],st2[];
{
        register char *p,*k;

        p = st1;
        while(*p)p++;
        k = st2;
        while(*p++ = *k++);
}
comstr(s1,s2)
        char *s1,*s2;
{
        register char *p,*m;

        p= s1;
        m= s2;

        while((*p++ == *m++)&&(*(p-1) != '\0'));
        if((*--p == '\0')&&(*--m == '\0'))return(1);
        return(0);
}
copystr(st1,st2)
        char *st1,*st2;
{
        register char *p,*k;

        p = st1;        k = st2;
        while(*p++ = *k++);
}
eatspace(p)
        char **p;
{
        while((**p == ' ')||(**p == '\t'))(*p)++;
}
jnum(n,base,nchar,jus)
  int n,base,nchar,jus;
{
register i;
  i=nchar-(digcnt(n,base));
  if(jus==1){
        basout(n,base);
        for(;i> 0;i--)putchar(' ');
        }
  else {
        for(;i> 0;i--)putchar(' ');
        basout(n,base);
        }
}
lfs(target,string)
        char *target,*string;
{
        register char *t,*p,*s;

        t = string;
   while(1){
        s = t;
        p = target;
        for(;(*s!=*p)&&((*s!='\n')&&(*s!='\0'));*s++);
        if(((*s)== '\0')||(*s == '\n'))return(0);
        t= s + 1;               /*save stat of scan for when bomb*/
        while((*s++)==(*p++));  /*eat up char until not equal*/
        if((*--p)=='\0')return(1);
        }
}
sscan(world,string)
        char *world,**string;
{
        register char *p,**c;
        register i;
        p = world;
        *p = '\0';
        c = string;

        while((island(**c)!= 1)&&(**c!= '\n')&&(**c != '\0')&&(**c != ';'))(*c)++;

        if(**c == '\n') return(-1);
        if(**c == '\0') return(-2);
        if(**c == ';')return(**c);
        *p++ = *(*c)++;
        i = 1;
        while(island(*p++ = *(*c)++))
                        if(++i > 20) --p;
        (*c)--;
                if(*(--p) == '\0') return(-2);
                if(*p == '\n'){
                        *p = '\0';
                        return(-1);
                        }
        else {i = *p;   *p = '\0';}
        return(i);
}
basin(string,base)
        char *string;
        int base;
{
        char s[21];
        register number;
        register p;
        int i;
        register exponent;
        for(i=0;(s[i]= string[i])!='\0';i++);
        for(p=0;s[p]!='\0';p++);
        for(i=0;(s[i]!='\0');i++){
                if((s[i] == 'o') || (s[i] == 'O'))s[i] = '0';
                if((s[i] >= 'A') && (s[i] <= 'Z'))s[i] += 32;
                if(s[i] > '9')s[i]=
                        (s[i]-('a'-':'));
                }
        number=0;exponent=1;p=p-1;
                while(p!=(-1)){
                        number=number+(((s[p--])-48)*exponent);
                        exponent=exponent*base;}
        return(number);
}
digcnt(n,p)
        unsigned int n,p;
{
        register i;
        for( i= 0;n != 0;i++)n = n/p;
        if(i==0)i++;
        return(i);
}
