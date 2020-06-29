#define ERR (-1)
#include <stdio.h>
#include <stat.h>
#include <modes.h>
#include <dir.h>
#include <sys/sir.h>

int dflag, lflag;

#define TRUE (1)
#define FALSE (0)

    char buf[512];

main(argc,argv)   int argc; char *argv[];

{
  int j, options;
  char *ptr, opt;

  pflinit();

  if (argc<2) { printf("usage:  ++ verify <file or device ...> [+options]\n"); exit(1); }
  
  options=0;
  for (j=1; j<argc; j++) {
      if (*(ptr=argv[j])=='+' || *ptr=='-') {
         options++;
         while ((opt=*++ptr) != '\0')
               switch(opt) {
                      case 'd': dflag=TRUE;
                                break;
                      case 'l': lflag=TRUE;
                                break;
                      default : printf("%c is an invalid option\n",opt);
                                break;
                      }
         }
      }

  if (options==(argc-1)) {
     printf("A file, directory or device name must be specified\n");
     exit(255);
     }

  for (j=1; j<argc; j++) {
      if (*(ptr=argv[j])=='+' || *ptr=='-') continue;
      reader(argv[j]);
      }
}

reader(name)

char *name;
{   long i, lseek(), eof;
    int j,fd,bl, error, prev_bl;
    char *title;
    struct stat filetype;
    struct direct dirbuf;
    struct sir siro;

    if ((fd=open(name,0))==ERR)
                 { printf("Can't open \"%s\"\n",name); return; }
    if (fstat(fd,&filetype)==ERR)
                 { printf("Can't get stat for \"%s\"\n",name);
                   return;                                        }

    switch(filetype.st_mode & S_IFMT) {

       case S_IFREG:
          title = "File";
          goto bytewise;
       case S_IFDIR:
          title = "Directory";
          goto bytewise;
       bytewise:
          error=FALSE;
          for (i=0L; (bl=read(fd,buf,512))!=0; i++) {
              prev_bl=bl;
              if (bl==ERR) {
                 printf("Error in file \"%s\" at block %ld\n",name,i);
                 error=TRUE;
                 }
              }
          close(fd);
          if (!error) {
             if (strcmp(title,"Directory")==0 && dflag) {
                if (lflag)
                   printf("===> %s \"%s\", EOF at %ld bytes\n",
                          title, name, --i*512L+prev_bl);
                chdir(name);
                if ((fd=open(".",0))==ERR) {
                   printf("Can't open directory \"%s\"\n",name); return;}
                while (read(fd, (char *) &dirbuf, sizeof(dirbuf))>0) {
                      if (dirbuf.d_ino==0) continue;
                      if (strcmp(dirbuf.d_name,".")==0 ||
                          strcmp(dirbuf.d_name,"..")==0) continue;
                      reader(dirbuf.d_name);
                      }
                close(fd);
                chdir("..");
                }
             else if (lflag) printf("%s \"%s\", EOF at %ld bytes\n",
                                    title, name, --i*512L+prev_bl);
             }
          else if (strcmp(title,"Directory")==0 && dflag)
             printf("%s \"%s\" will not be searched due to error\n",title,name);
          break;

       case S_IFBLK:
          if (lseek(fd,512L,0)!=512L) {
             printf("Device:  \"%s\", SEEK ERROR searching for device",name);
             printf(" information\n");
             printf("Operation aborted.\n");
             close(fd);
             return;
             }
          if (read(fd,(char *) &siro, sizeof(siro)) != sizeof(siro)) {
             printf("Device:  \"%s\", READ ERROR while reading",name);
             printf(" device information\n");
             printf("Operation aborted.\n");
             close(fd);
             return;
             }
          l3tol(&eof,siro.ssizfr,1);
          eof=eof + (long) siro.sswpsz + 1L;
          error=FALSE;
          for (i=0L; i/512L<eof; i+=512L) {
             if (lseek(fd,i,0)!=i) {
                printf("Device: \"%s\", SEEK ERROR at block %ld\n",
                        name,i/512L);
                error=TRUE;
                }
             if (read(fd,buf,512)!=512) {
                printf("Device \"%s\", READ ERROR at block %ld\n",name,i/512L);
                error=TRUE;
                }
             }
          if (!error)
             if (lflag) printf("Device \"%s\", EOF at block %ld\n",name,i/512L);
          close(fd);
          break;

       default:
          close(fd);
          printf("Can't handle: \"%s\"\n",name);
          break;
    }
}
