#include "bdscio.h"

#define BELL   "\007"
#define EOL    "\033K"
#define FF  '\014'

struct character {
	char cname[30];
	char str[10];
	char intel[10];
	char wis[10];
	char con[10];
	char dex[10];
	char chr[10];
	char hpoints[10];
	char level[7];
	char class[15];
	char aclass[7];
	char align[15];
	char specials[50];
	};

struct player {
	char name[15];
	int nchars;
	struct character owned[5];
	}gamers[10];

main()
{
	char inp[5];
	int players,i,j;

	puts(CLEARS);
	gotoxy(7,4);puts("\007Enter number of players: ");
	players = atoi(gets(inp));
	if((players<=0)||(players>=11)){
		gotoxy(7,4);puts("\033\007KUnable to handle that number");
		gotoxy(8,4);puts("of players.  Current limit is 10 people.");
		gotoxy(9,4);puts("Talk to Dann about changing me!!!!");
		exit();
		}
	for(i=0;i<players;i++)
		getplayer(i);
	puts(CLEARS);
	gotoxy(7,4);puts("Turn on the printer; Hit return to start ");
	pause(); getchar();
	puts(CLEARS);
	for(i=0;i<=players;i++){
		gotoxy(7,4);puts("\033KNow printing ");
		printf("%s's copy of the list",(i<players)?gamers[i].name:"DM");
		prlist(players);
		putlpr(FF);
		gotoxy(9,15);puts("Copy ready.  To resume, hit RETURN");
		pause(); getchar();
		gotoxy(9,15);puts(EOL);
		}
	puts(CLEARS);
	gotoxy(13,30);puts("Happy Dungeoning!!!!");
}

getplayer(num)
	int num;
{
	int limit,i;
	char inp[5];

	puts(CLEARS);
	gotoxy(3,4);puts("What is your name, please? ____________");
	gotoxy(3,31);puts(BELL);
	gets(gamers[num].name);
	gotoxy(3,4);puts("\033KThank you.   Now, how many characters do you have? ");
l1:	gotoxy(4,4);puts("(No more than 5 are allowed) : ");
	limit = atoi(gets(inp));
	if((limit<=0)||(limit>=6)){
		gotoxy(3,4);puts("\033K\007Illegal value; please re-enter.");
		gotoxy(4,34);puts(EOL);
		goto l1;
		}
	gamers[num].nchars = limit;
	puts(CLEARS);
	gotoxy(3,5);puts("Player's name: "); puts(gamers[num].name);
	gotoxy(5,5);puts("Character #");
	gotoxy(7,9);puts("Character name: ");
	gotoxy(8,9);puts("Strength: ");
	gotoxy(9,9);puts("Intelligence: ");
	gotoxy(10,9);puts("Wisdom: ");
	gotoxy(11,9);puts("Constitution: ");
	gotoxy(12,9);puts("Dexterity: ");
	gotoxy(13,9);puts("Charisma: ");
	gotoxy(15,9);puts("Level: ");
	gotoxy(16,9);puts("Hit points: ");
	gotoxy(17,9);puts("Class: ");
	gotoxy(18,9);puts("Armor class: ");
	gotoxy(19,9);puts("Alignment: ");
	gotoxy(21,9);puts("Specials: ");


	for(i=0;i<limit;i++){
		gotoxy(5,16);puts(EOL); printf("%d",i+1);
		gotoxy(7,25);puts("\033K___________________________");
		gotoxy(8,19);puts("\033K_______");
		gotoxy(9,23);puts("\033K_______");
		gotoxy(10,17);puts("\033K_______");
		gotoxy(11,23);puts("\033K_______");
		gotoxy(12,20);puts("\033K_______");
		gotoxy(13,19);puts("\033K_______");
		gotoxy(15,16);puts("\033K____");
		gotoxy(16,21);puts("\033K_______");
		gotoxy(17,16);puts("\033K____________");
		gotoxy(18,22);puts("\033K____");
		gotoxy(19,20);puts("\033K____________");
		gotoxy(21,19);puts("\033K_______________________________________________");
		gotoxy(7,25);puts(BELL); gets(gamers[num].owned[i].cname);
		gotoxy(8,19);puts(BELL); gets(gamers[num].owned[i].str);
		gotoxy(9,23);puts(BELL); gets(gamers[num].owned[i].intel);
		gotoxy(10,17);puts(BELL); gets(gamers[num].owned[i].wis);
		gotoxy(11,23);puts(BELL); gets(gamers[num].owned[i].con);
		gotoxy(12,20);puts(BELL); gets(gamers[num].owned[i].dex);
		gotoxy(13,19);puts(BELL); gets(gamers[num].owned[i].chr);
		gotoxy(15,16);puts(BELL); gets(gamers[num].owned[i].level);
		gotoxy(16,21);puts(BELL); gets(gamers[num].owned[i].hpoints);
		gotoxy(17,16);puts(BELL); gets(gamers[num].owned[i].class);
		gotoxy(18,22);puts(BELL); gets(gamers[num].owned[i].aclass);
		gotoxy(19,20);puts(BELL); gets(gamers[num].owned[i].align);
		gotoxy(21,19);puts(BELL); gets(gamers[num].owned[i].specials);
	}
}

prlist(num)
	int num;
{
	char linebuf[81];
	struct character *a;
	int i,j;

	for(i=0;i<num;i++){
		setmem(linebuf,80,' '); linebuf[80] = '\0';
		sprintf(linebuf," Player: %s\n",gamers[i].name);
		lputs(linebuf);
		for(j=0;j<gamers[i].nchars;j++){
			a = &gamers[i].owned[j];
			setmem(linebuf,80,' '); linebuf[80] = '\0';
			sprintf(linebuf+6,"Character: %s\n",a->cname);
			lputs(linebuf);
			setmem(linebuf,80,' '); linebuf[80] = '\0';
			lputs("           STR      INT      WIS      CON");
			lputs("      DEX      CHR      HIT POINTS\n");
			sprintf(linebuf+9,"%6s   %6s",a->str,a->intel);
			sprintf(linebuf+24,"   %6s   %6s",a->wis,a->con);
			sprintf(linebuf+42,"   %6s   %6s",a->dex,a->chr);
			sprintf(linebuf+60,"      %-6s\n",a->hpoints);
			lputs(linebuf);
			setmem(linebuf,80,' '); linebuf[80] = '\0';
			lputs("          LEVEL    CLASS     ARMOR CLASS     ALIGNMENT\n");
			sprintf(linebuf+10,"%3s    %10s     %3s         %3s\n",a->level,a->class,a->aclass,a->align);
			lputs(linebuf);
			setmem(linebuf,80,' '); linebuf[80] = '\0';
			sprintf(linebuf+6,"SPECIALS: %-50s\n\n",a->specials);
			lputs(linebuf);
			}
	}
}

putlpr(c)
	char c;
{
	if(c=='\n')bios(LIST,'\r');
	bios(LIST,c);
}

lputs(s)
	char *s;
{
	while(*s)putlpr(*s++);
}
