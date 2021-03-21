/*
  This program clears the top bit of the characters in text files.
  Just run it. The program will prompt for file names.
*/
#include crun2.lib
#include conio2.lib
#include file2.lib
#define CZ 26
char fibuf[20],fobuf[20];
main()
{
int ichan,ochan;
char ch;
puts("Give full input file name: ");
gets(fibuf);
if((ichan=fopen(fibuf,"r"))==0)
	{puts("\nProgram aborted\n\n");exit();}
puts("\nGive full output file name: ");
gets(fobuf);
if((ochan=fopen(fobuf,"w"))==0)
	{puts("\File opening error.\n\n");exit();}
while(1)
{
	ch=getc(ichan);
	ch=ch&127;
	putc(ch,ochan);
	if(ch==CZ)break;
}
fclose(ochan);exit();
}
file: ");
  gets(fname);
  crlf();
  cptr=fname;
 }
 else cptr=argv[1];
 while((ch=*cptr)==' ')cptr++;
 count=1;
 w