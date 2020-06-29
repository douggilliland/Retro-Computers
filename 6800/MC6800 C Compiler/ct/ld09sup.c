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
cats(st1,st2)
        char st1[],st2[];
{
        register char *p,*k;

        p = st1;
        while(*p)p++;
        k = st2;
        while(*p++ = *k++);
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
islet(ch)
        char ch;
{
        if(((ch >= 'A')&&(ch <= 'Z'))||((ch >= 'a')&&(ch <= 'z'))) return (1);
        if(ch == '_')return(1);
        if((ch >= '0')&&(ch <= '9')) return(0);
        if((ch >= '!')&&(ch <= '/')) return(2);
        if((ch >= ':')&&(ch <= '?')) return(2);
        if((ch == '`')||(ch == '@')) return(2);
        if((ch >= '[')&&(ch <= '_')) return(2);
        if((ch >= '{')&&(ch <= '~')) return(2);
        return(3);
}
llu(world,keylist)              /*   List Look Up       */
        char *world,*keylist[];
{
        register char *p,*m;
        register i;

        i = 0;                          /*      point to first keylist                  */
        while(keylist[i] != -1){        /*      and if not all done with them:  */
                p = world;              /*      point to input string           */
                m = keylist[i++];       /*      point to current keylist string */

                while((*p++ == *m++)&&(*(p-1)));        /* eat up equal char.   */

                if((*--p == '\0')&&(*--m == '\0')) return(--i);
        }
        return(-1);
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
