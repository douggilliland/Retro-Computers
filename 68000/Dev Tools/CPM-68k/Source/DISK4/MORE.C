#include "stdio.h"
#define EOF (-1)

main(acnt,avar)
int acnt;
char *avar[];
{
    static FILE *fchan, *fopen();

    if(acnt != 2) error(1);

    if(!(fchan=fopen(avar[1],"r"))) error(2);

    dopage(fchan);
    while(TRUE){
        switch(prompt()){
            case 'Q': case 'E': case 3:
                exit(0);
            case ' ': dopage(fchan); break;
            case 0xD: doline(fchan); break;
            }
        }
}

error(n)
int n;
{
    switch(n){
        case 1: printf("Usage: more filename.ext\n"); break;
        case 2: printf("File not found\n"); break;
        }
    exit(1);
}

prompt(){
    static struct { int funcnum; long int vp1, vp2; } bpb;
    static int ch;

    printf("--More--");
    bpb.funcnum = 3;
    ch = toupper(bdos(50,&bpb));
    printf("\b\b\b\b\b\b\b\b        \b\b\b\b\b\b\b\b");
    return ch;
}

toupper(ch)
int ch;
{
    return((ch >= 'a' && ch <= 'z') ? ch - 'a' + 'A' : ch);
}

dopage(fchan)
FILE *fchan;
{
    static int i;

    for(i=20; i--;) doline(fchan);
}

doline(fchan)
FILE *fchan;
{
    static int c;

    while((c = getc(fchan)) != EOF && putchar(c &= 0x7F) != '\n');
    if(c == EOF) exit(0);
}
