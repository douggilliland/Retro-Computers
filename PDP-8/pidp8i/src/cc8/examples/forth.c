char bfr[100];
int stk[100];
char num[100];
char dict[101];		/* Room for 25 predefined dictionary entries (101!!!)*/
char func[1000];
char fp[20],ip[20],dp[20];
int rsl,*stkp,noex,tm,ed;
char *p,*q,*r,*f,*i,*d;

int prcln()
{
	int stp;

	if (*p==' ')
		return;

	if (noex) {
		if (*p==';') {
			f--;
			p=*f;
			return;
		}
		if (atoi(p,&tm) & !tm) {
			*stkp++=0;
			return;
		}

		if (*p=='.') {		/* Print TOS */
			r=p+1;
			if (*r=='"') {
				p=p+3;
				while((*p!='"') & *p)
					putc(*p++);
				return;
			}
			stkp--;
			printf("%d ",*stkp);
			if (*r=='S')
				stkp++;
			return;
		}


		if (*p==':') {
			ed=1;
			p++;
			while(*p==' ')
				p++;	/* skip spaces */
			q=num;
			*q++='$';		/* Function marker */
			while(1) {
			while(*p)
				if((*q++=*p++)==';')
					ed=0;
			*q++=' ';
			*q=0;
			r=strcat(func,num);
			if (!ed) break;
			puts(":");
			gets(p=bfr);
			q=num;
			}
			strcat(func,"\r\n");
			return;
		}

		stp=1;
		q=stkp-2;
		*num=' ';
		r=p+1;
		switch(*p) {
			case '+':
				stkp--;
				if (*r=='L') {	/* probably +LOOP */
					stp=*stkp;
					p++;
					break;
				}
				*q=*q + *stkp;
				return;
			case '-':
				if (isnum(*r)) {
					p=p+atoi(p,stkp++);
					return;
				}
				stkp--;
				*q=*q - *stkp;
				return;
			case '*':
				stkp--;
				*q=*q * *stkp;
				return;
			case '/':
				stkp--;
				*q=*q / *stkp;
				return;
			case '>':
				stkp--;
				*q=*q > *stkp;
				return;
			case '<':
				stkp--;
				if (*r=='>') {
					*q=*q != *stkp;
					p++;
					return;
				}
				*q=*q < *stkp;
				return;
			case '=':
				stkp--;
				*q=*q == *stkp;
				return;
			case '(':
				while (*p++!=')');
				return;
			default:
				break;
		}

		if(isnum(*p)) {
			p=p+atoi(p,stkp++);
			return;
		}

	}
	if (isalpha(*p)) {
		q=num;
		*q++='$';
		while(*p & (*p!=' ') & (*p!=';'))
			*q++=*p++;
		*q++=0;
		rsl=strstr(dict,num+1);
		if (rsl==0) {
			if (noex==0)
				return;
			rsl=strstr(func,num);
			if (rsl==0) {
				printf("? %s\r\n",num);
				stkp=stk;	 /* Zero the stack after invalid token */
				return;
			}
			*f++=p;		 /* Push current text pointer*/
			p=rsl;
			while (*p!=' ') p++; /* Skip name and then execute to ; */
			return;
		}
		rsl=(rsl-dict)/4;
		q=stkp-1;
		if ((!noex) & (rsl>1))
			return;
		switch(rsl) {
			case 0:
				if (i>ip)
					i--;
				noex=1;
				break;
			case 1:
				r=i-1;
				noex=!*r;
				break;
			case 2:
                			r=d-3;
				*stkp++=*r;
				break;
			case 3:
				*stkp++=*q;
				break;
			case 4:
				stkp--;
				break;
			case 5:
				q--;
				*stkp++=*q;
				break;
			case 6:
				if (!noex) {
					*i++=0;
					break;
				}
				stkp--;
				*i++=noex=(*stkp!=0);
				break;
			case 7:
				rsl=*q;
				r=q-1;
				*q=*r;
				*r=rsl;
				break;
			case 8:
				puts("Bye\r\n");
				exit(0);
				break;
			case 9:
				puts("\r\n");
				break;
			case 10:
				puts(func);
				break;
			case 11:
                			stkp--;
				*d++=*stkp;	/* Start */
                			stkp--;
				*d++=*stkp;	/* Limit */
				*d++=p;		/* Buffer* */
				break;
			case 12:
				q=d-3;
				*q=*q+stp;
				rsl=*q++;
				if (stp < 0) {
					if (rsl>*q++)
						p=*q;	/* repeat loop -ve */
					else
						d=d-3;	/* exit loop */
					break;
				}
				if (*q++>rsl) 
					p=*q;	/* repeat loop +ve */
				else
					d=d-3;	/* exit loop */
				break;
			case 13:
				stkp--;
				putc(*stkp);
				break;
			case 14:
				if (*q)
					*stkp++=*q;
				break;
			case 15:
				q=stkp-2;
				stkp--;
				*q=*q % *stkp;
				break;
			case 16:
				*stkp++=getc();
				break;
			case 17:
				fopen("FORTH.TX","r");
				q=func;
                			while((*q++=fgetc()));
				break;
			case 18:
				fopen("FORTH.TX","w");
				q=func;
				while(*q)
					fputc(*q++);
				fclose();
				break;
			case 19:
				q=stkp-3;
				tm=*q;
				r=stkp-2;
				*q++=*r++;
				*q++=*r++;
				*q=tm;
				break;
			case 20:
				rsl=*q;
				r=q-1;
				*q=*r;
				*r=rsl;
				*stkp++=rsl;
				break;
			case 21:
				q--;
				stkp--;
				*q=*q & *stkp;
				break;;
			case 22:
				q--;
				stkp--;
				*q=*q | *stkp;
				break;
			default:
				break;
		}
	}
}

int main()
{
	xinit();
	puts("Forth interpreter\r\n>");
	strcpy(dict,"THENELSEI   DUP DROPOVERIF  SWAPBYE CR  SEE DO  ");
	strcat(dict,"LOOPEMIT?DUPMOD KEY LOADSAVEROT TUCKAND OR  ");
	memset(stk-1,0,101);
	stkp=stk;
	f=fp;
	*func=0;

	while(1) {
		p=bfr;
		gets(bfr);
		noex=-1;
		i=ip;		/* Init DO and IF stacks here */
		d=dp;
		while(*p) {
			prcln();
			if (*p) p++;
		}
		if (stkp<stk) {
			puts(" Stack?\r\n");
			stkp=stk;
		}
		puts(">");
	}
}
