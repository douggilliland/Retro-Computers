/* This program converts a HEX file developed under CP/M into an Amsdos
BIN file. See the CPC 464 DD1-1 Firmware specification for details of
the file header used.
*/
#include <crun2.lib>
#include <file2.lib>
#include <conio2.lib>
int ichan;
/* array for file header and start of machine code buffer
 buff MUST be declared last */
char head[128],buff[1];
main(argc,argv)
int argc,argv[];
{char ch,*cptr,*iptr,*optr,fname[20],ifname[16],ofname[16];
/* Use char pointers for 16 bit unsigned numbers */
 char *start,*finish,*chksum;
 int count,loop,ochan;
 puts("\nCP/M HEX to AMSDOS BIN loader   (J.M.H.Hill  Nov 1985)\n\n");
 start=finish=chksum=0;
 iptr=ifname;
 optr=ofname;
 for(count=0;count<69;count++)head[count]=0;
 head[18]=2; /* Binary file */
 if(argc!=2)
 {puts("Give name of input file: ");
  gets(fname);
  crlf();
  cptr=fname;
 }
 else cptr=argv[1];
/* Analyse file name and generate full names for I/P and O/P */
 while((ch=*cptr)==' ')cptr++;
 count=1;
 while(ch=*cptr++)
  {if(count>8)break;
   if(ch==' ')break;
   if(ch=='.')break;
   if(ch==':')count=0;
   *iptr++=*optr++=ch;
   if(count!=0)
    head[count]=ch;
   count++;
  }
 while(count<=8)head[count++]=' ';
 *iptr++ = *optr++ = '.';
 *iptr++ ='H';*iptr++ ='E';*iptr++='X';
 *optr++ =head[9] ='B';*optr++ =head[10] ='I';*optr++ =head[11]='N';
 *iptr=*optr=0;
 if((ichan=fopen(ifname,"r"))==0){puts("\nI/P file error\n");exit();}
 if((ochan=fopen(ofname,"w"))==0){puts("\nO/P file problem\n");exit();}
/* Files are open. Get HEX file in, and transfer code to buffer */
 while(1)
 {
  while((ch=getc(ichan))!= ':');
  count=fgethex(2);
  if(count==0)break;
  cptr=fgethex(4);
  if(finish<(cptr+count))finish=cptr+count;
  if(start==0)start=cptr;
  cptr=cptr-start+&buff[0];
  if(fgethex(2)!=0)break;
  for(loop=count;loop>0;loop--)
  *cptr++ =fgethex(2);
  fgethex(2); /* Throw away checksum */
 }
/* Fill in the rest of the header and save the BIN file */
 istore(start,21);
 istore(finish-start,24);
 istore(start,26);
 istore(finish-start,64);
 chksum=0;
 for(count=0;count<67;count++)chksum=chksum+(head[count]&0xff);
 istore(chksum,67);
 for(count=0;count<128;count++)
  putc(head[count],ochan);
 cptr=&buff[0];
 while(cptr<=(finish-start+&buff[0]))putc(*cptr++,ochan);
 fclose(ochan);
}
fgethex(nchs)
int nchs;
{char chin;
 int val,loop;
 val=0;
 for(loop=nchs;loop>0;loop--)
 {chin=getc(ichan);
  chin=chin-'0';
  if(chin>9)chin=chin-7;
  val=16*val+chin;
 }
 return val;
}

/* Store an integer in header */
istore(val,loc)
int val,loc;
{int *ptr;
 ptr=head+loc;
 *ptr=val;
}
tion with its final code in EP