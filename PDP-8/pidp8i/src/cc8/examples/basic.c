#define SMAX 10
#define CMAX 256
#define BMAX 64
#define LMAX 32
#define DMAX 32
#define CBMX 1024
#define LXMX 999

int E[SMAX];   /* subroutine line number stack */
int L[CMAX];   /* FOR loop beginning line number */
int M[CMAX];   /* FOR loop maximum index value */
int P[CMAX];   /* program variable value */
int Lb[CBMX];  /* Line buffer of CBMX chars */
int l,i,j;
int *C;         /* subroutine stack pointer */
int B[BMAX];  /* command input buffer */
int F[2];     /* temporary search string */
int *p,*q,*x,*y,*z,*s,*d;
int *m[LXMX]; /* pointers to lines of program. This is a real waste of space! */

int G(  ) {  /* get program line from buffer */
	atoi(B,&l);
	x=m[l];
	if(x){
		if(strstr(B," "))
			strcpy(x,B);
		else
			x=m[l]=0;
		return;
	}
	x=Lb;
	while(*x)
		x=x+DMAX;
	strcpy(x,B);
	m[l]=x;
} /* end G */

/* recursive descent parser for arithmetic/logical expressions */
int S(  ) {
	int o,tm;

	o=J( );
	tm=*p++;
	switch(tm){
	case '=': return o==S( );
		break;
	case '#': return o!=S( );
	default: p--; return o;
	}
} /* end S */

int J(  ) {
	int o,tm;

	o=K( );
	tm=*p++;
	switch(tm){
	case '<': return o<J( );
		break;
	case '>': return o>J( );
	default: p--; return o;
	}
} /* end J */

int K(  ) {
	int o,tm;

	o=V( );
	tm=*p++;
	switch(tm){
	case '$': return o<=K( );
		break;
	case '!': return o>=K( );
	default: p--; return o;
	}
} /* end K */

int V(  ) {
	int o,tm;

	o=W( );
	tm=*p++;
	switch(tm){
	case '+': return o+V( );
		break;
	case '-': return o-V( );
	default: p--; return o;
	}
} /* end V */

int W(  ) {
	int o,tm;

	o=Y( );
	tm=*p++;
	switch(tm){
	case '*': return o*W( );
		break;
	case '/': return o/W( );
	default: p--; return o;
	}
} /* end W */

int Y(  ) {
	int o;

	if(*p=='-'){
		p++;
		return -Y();
	}
	q=p;
	if(isnum(*p)){
		while(isnum(*p))
			p++;
		atoi(q,&o);
		return o;
	}
	if(*p=='('){
		p++; o=S( ); p++;
		return o;
	}
	return P[*p++];
} /* end Y */

int bfclr()
{
	memset(m,0,LXMX);
	memset(Lb,0,CBMX);
}

int main(  ) {
	int tmp;  /* temp var to fix bug 07Sep2005 Somos */

	bfclr();
	while(puts("Ok\r\n"),gets(B)) {
		switch(*B){
		case 'R': /* "RUN" command */
			C=E;
			l=1;
			for(i=0; i<CMAX; i++) /* initialize variables */
				P[i]=0;
			while(l){
				while(!(s=m[l])) l++;
				while(*s!=' ') s++;                      /* skip line number */
                while ((p=strstr(s,"<>"))){*p++='#';*p=' ';}
                while ((p=strstr(s,"<="))){*p++='$';*p=' ';}
                while ((p=strstr(s,">="))){*p++='!';*p=' ';}
				d=B;
				j=0;
				while(*s){
					if(*s=='"') j++;
					if((*s!=' ')|(j&1)) *d++=*s;
					s++;
				}
				*d=j=0;
				d--; /* backup to last char in line */
				if(B[1]!='='){
					switch(*B){
					case 'E': /* "END" */
						puts("End\r\n");
						l=-1;
						break;
					case 'R':                       /* "REM" */
						if(B[2]!='M') l=*--C;  /* "RETURN" */
						break;
					case 'I':
						if(B[1]=='N'){                         /* "INPUT" */
							tmp=*d;                         /* save for bug fix next line 07Sep2005 Somos */
							gets(p=B); P[tmp]=S( );
						} else {                                /* "IF" */
							tmp=strstr(B,"TH");        /* "THEN" */
							*tmp=0;
							p=B+2;
							if(S( )){
								p=tmp+4; l=S( )-1;
							}
						}
						break;
					case 'P': /* "PRINT" */
						tmp=',';
						p=B+5;
						while(tmp==','){
							if(*p=='"'){
                                p++;
								while(*p!='"')
									putc(*p++);
								p++;
							} else {
								printf("%d",S( ));
							}
							tmp=*p++;
							putc(' ');
						}
						puts("\r\n");
						break;
					case 'G':               /* "GOTO" */
						p=B+4;
						if(B[2]=='S'){ /* "GOSUB" */
							*C++=l; p++;
						}
						l=S( )-1;
						break;
					case 'F':                               /* "FOR" */
						tmp=strstr(B,"TO");        /* "TO" */
						*tmp=0;
						p=B+5;
						P[i=B[3]]=S( );
						p=tmp+2;
						M[i]=S( );
						L[i]=l;
						break;
					case 'N': /* "NEXT" */
						tmp=*d;
						if(P[tmp]<M[tmp]){
							l=L[tmp];
							P[tmp]=P[tmp]+1;
						}
						break;
					default:	break;
					}
				} else {
					p=B+2;
					P[*B]=S( );
				}
				l++;
			} /* end while l */
			break;
		case 'L': /* "LIST" command */
			for(j=0; j<LXMX; j++)
				if(m[j]){
					puts(m[j]);
					puts("\r\n");
				}
			break;
		case 'N': /* "NEW" command */
			bfclr();
			break;
		case 'B': /* "BYE" command */
			exit(0);
			break;
		case 0:
            G( );
            break;
		default:
			G( );
            break;
		}/* end switch *B */
     }
} /* end main */
