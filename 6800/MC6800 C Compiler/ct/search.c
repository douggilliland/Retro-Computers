
#include <stdio.h>
#include <stat.h>
#include <dir.h>
#include <modes.h>
#include <timeb.h>

#define BUFSIZE 256

struct types {
       int  relational;
       char ftype;
       };

struct users {
       int  urelational;
       char name[10];
       };

struct logical {
       int size_upper;
       int size_lower;
       int link_upper;
       int link_lower;
       int date_upper;
       int date_lower;
       int opers[3];
       struct types types1[4];
       struct users users1[4];
       };


struct logical blog[2];

struct stat stbuf;
struct direct dirbuf;

char path_name[BUFSIZE];
char execute_list[50];

int type[2];
int user[2];
char filename[15];
int spec_options[2][8];
int number, options;
int xtrue;
int ids[2][4];
int nums[2];

main(argc, argv)
int argc;
char *argv[];
{
  char name[BUFSIZE];
  char *ptr, ch, *k;
  int i, j, fd, n;
  struct stat current;
  struct stat backwards;

  stat(".", &backwards);
  j=1;
  path_name[0]='/';
  while (backwards.st_ino != 1) {
        fd = open("..",0);
        fstat(fd, &current);
        while (read(fd,(char *) &dirbuf, sizeof(dirbuf)) > 0) {
              if (dirbuf.d_ino == backwards.st_ino) {
                 i=0;
                 while (dirbuf.d_name[i] != '\0') {
                       path_name[j] = dirbuf.d_name[i];
                       j++; i++;
                       }
                 path_name[j] = '/';
                 j++;
                 }
              }
        chdir("..");
        close(fd);
        fd = open(".",0);
        fstat(fd, &backwards);
        close(fd);
        }
  path_name[j] = '\0';
  i=1;
  name[0]='/';
  j=strlen(path_name) - 1;
  while (j >= 0) {
        path_name[j] = '\0';
        k = rindex(path_name,'/');
        if (k == '\0')
           break;
        for (n=k-path_name+1; n<j; n++) {
            name[i] = path_name[n];
            i++;
            }
        j = k - path_name;
        if (j==0)
           break;
        name[i] = path_name[j];
        i++;
        }
  name[i] = '\0';
  strcpy(path_name,name);

  for (i=0; i <= 1; i++)
      {
      blog[i].size_upper=30000;
      blog[i].size_lower=-1;
      blog[i].date_lower=-1;
      blog[i].date_upper=20000;
      blog[i].link_upper=30000;
      blog[i].link_lower=-1;
      type[i]=-1;
      user[i]=-1;
      nums[i]=-1;
      for (j=0; j<=2; j++)
          blog[i].opers[j] = -1;
      for (j=0; j<=3; j++)
          {
          blog[i].types1[j].relational=-1;
          blog[i].types1[j].ftype='\0';
          blog[i].users1[j].urelational=-1;
          blog[i].users1[j].name[0]='\0';
          ids[i][j]=-1;
          }
      }

  if (argc==1)
     printf("Command syntax error\n");
  else {
     ptr = argv[1];
     ch = *ptr;
     if (ch != '+' && ch != '-') {
        number=1;
        strcpy(filename,argv[1]);
        }
      if (number==0) {
         if (ch == '-') {
            printf("If no filename is present, the first\n");
            printf("option must be preceded by a '+'\n");
            exit(255);
            }
         j=1;
         }
      else j=2;
      for (i=j; i <= argc-1; i++)
         {
         scan_options(argv[i]);
         options++;
         }
      for (i=0; i<2; i++) {
          if (spec_options[i][3]==1) {
             read_password(i);
             if (nums[i]==-1) {
                printf("User name not found in password file\n");
                exit(255);
                }
             }
          }
      strcpy(name,path_name);
      process(name);
      }

}

scan_options(option)

char *option;

{
  char ch, *c, string[5], oper;
  int i, j, index;
  int *lower, *upper, temp_int;
  char *substring();

  i=1;
  ch = *option;
  c = &option[i++];
  switch (*c) {
       case 'n':  j=0;
                  break;
       case 'p':  j=1;
                  break;
       case 't':  j=2;
                  break;
       case 'u':  j=3;
                  break;
       case 's':  j=4;
                  break;
       case 'd':  j=5;
                  break;
       case 'l':  j=6;
                  break;
       case 'x':  if (xtrue==1) {
                     printf("Only one x option is allowed\n");
                     exit(255);
                     }
                  xtrue = 1;
                  j=7;
                  break;
       default:   printf("%c is an invalid option\n", *c);
                  exit(255);
       }

  if (ch=='+')
     index=0;
  else
     index=1;
  spec_options[index][j]=1;

  if (j != 0) {
     oper = option[i++];
     if (oper!='=' && oper!='#' && oper!='<' && oper!='>') {
        printf("%c is an invalid operator\n",oper);
        exit(255);
        }

     if (j==1) {
        if (oper != '=') {
           printf("WARNING:  only equal operator allowed with p option\n");
           printf("          Default operator will be equal operand\n");
           }
        strcpy(path_name,substring(option, i++, strlen(option)));
        }

     else if (j==2 || j==3) {
        if (oper != '=' && oper != '#') {
           printf("WARNING:  only equal or not equal operators allowed ");
           printf("with %c option\n",*c);
           printf("          Default operator will be equal operand\n");
           oper = "=";
           }
        if (j==2) {
           type[index]++;
           blog[index].types1[type[index]].ftype = option[i];
           if (blog[index].types1[type[index]].ftype != 'f' &&
               blog[index].types1[type[index]].ftype != 'd' &&
               blog[index].types1[type[index]].ftype != 'c' &&
               blog[index].types1[type[index]].ftype != 'b') {
              printf("%c is an invalid file type\n",option[i]);
              exit(255);
              }
           if (oper=='=')
              blog[index].types1[type[index]].relational = 0;
           else
              blog[index].types1[type[index]].relational = 1;
           }
        else {
           user[index]++;
           if (user[index] > 3) {
              printf("Too many user names\n");
              exit(255);
              }
           strcpy(blog[index].users1[user[index]].name,
                  substring(option,i++,strlen(option)));
           if (oper=='=')
              blog[index].users1[user[index]].urelational = 0;
           else
              blog[index].users1[user[index]].urelational = 1;
           }
        }

     else if (j==4 || j==5 || j==6) {
        if (blog[index].opers[j-4] == -1) {
            if (oper == '=')
               blog[index].opers[j-4] = 0;
            if (oper == '#')
               blog[index].opers[j-4] = 1;
            }
        else {
              printf("Only one equal or not equal operator");
              printf(" is allowed with %c option\n",*c);
              exit(255);
              }
        strcpy(string,substring(option,i++,strlen(option)));
        temp_int = atoi(string);
        if (j==4) {
           lower = &blog[index].size_lower;
           upper = &blog[index].size_upper;
           }
        else if (j==5) {
           lower = &blog[index].date_lower;
           upper = &blog[index].date_upper;
           }
        else {
           lower = &blog[index].link_lower;
           upper = &blog[index].link_upper;
           }
        if (oper != '<')
           *lower = temp_int;
        else
           *upper = temp_int;
        if (*lower > *upper) {
           printf("Invalid range for option\n");
           exit(255);
           }
        }

     else {
        if (oper != '=') {
           printf("Only equal operator is allowed with x option\n");
           exit(255);
           }
        strcpy(execute_list,substring(option, i++, strlen(option)));
        }
     }
}


char *substring(string,x,y)

char *string;
int x,y;

{
  char string2[BUFSIZE];
  char ch;
  int i;

  for(i=x; i <= y; i++) {
     ch = string[i];
     string2[i-x] = ch;
     }
  string2[y+1]='\0';

  return(string2);

}

process(name)

char *name;
{

  int x;

  if (stat(name, &stbuf) == -1) {
     printf("Can't find %s\n",name);
     exit(255);
     }

  if (number==0)
     x = opt_chek();
  else if (options==0)
     x = file_chek(name);
  else
     x = both_chek(name);

  if (x != 0) {
     print(name);
     if (spec_options[0][7] != 0)
        exec_command(name);
     }

  if ((stbuf.st_mode & S_IFMT) == S_IFDIR)
     dir(name);
}

dir(name)

char *name;
{

  char *nbp, *nep;
  int i, fd;

  nbp = name + strlen(name);
  if (strcmp(name,"/")!=0)
     *nbp++='/';
  if (nbp+DIRSIZ+2 >= name+BUFSIZE)
     return;
  if ((fd=open(name,0)) == -1)
     return;
  while (read(fd, (char *)&dirbuf, sizeof(dirbuf))>0) {
        if (dirbuf.d_ino == 0)
           continue;
        if (strcmp(dirbuf.d_name,".") == 0
           || strcmp(dirbuf.d_name,"..") == 0)
           continue;
        for (i=0, nep=nbp; i < DIRSIZ; i++)
           *nep++ = dirbuf.d_name[i];
        *nep++ = '\0';
        process(name);
        }
  close(fd);
  *--nbp = '\0';
}

print(name)

char *name;
{
  if (spec_options[0][0] == 0 && spec_options[1][0] == 0)
     printf("%s\n",name);
}

both_chek(name)

char *name;
{

  if (file_chek(name) != 0) {
     if (opt_chek() != 0)
        return(1);
     else
        return(0);
     }
  else if (or_chek() != 0)
        return(1);
  else
        return(0);
}

opt_chek ()
{
  if (and_chek() != 0)
     return(1);
  else if (or_chek() != 0)
     return(1);
  else
     return(0);
}

or_chek()
{
  if (size1(1) + date1(1) + link1(1) + type1(1) + user1(1) > 0)
     return(1);
  else
     return(0);
}

and_chek()
{
  if (size1(0) + date1(0) + link1(0) + type1(0) + user1(0) == 5)
     return(1);
  else
     return(0);
}

size1(num)

int num;
{
  long blocks;

  if (spec_options[num][4]==0) {
     if (num==0)
        return(1);
     else
        return(0);
     }
  else {
     if (((stbuf.st_mode & S_IFMT) == S_IFCHR) ||
         ((stbuf.st_mode & S_IFMT) == S_IFBLK))
        return(0);
     blocks = stbuf.st_size/512;
     if (stbuf.st_size%512 != 0)
        blocks++;
     if (blog[num].opers[0]==0) {
        if (blocks==blog[num].size_lower)
           return(1);
        else
           return(0);
        }
     if (blog[num].opers[0]==1) {
        if (blocks!=blog[num].size_lower)
           return(1);
        else
           return(0);
        }
     if (blog[num].size_lower<blocks && blog[num].size_upper>blocks)
        return(1);
     else
        return(0);
     }
}

link1(num)

int num;
{


  if (spec_options[num][6] == 0) {
     if (num==0)
         return(1);
     else
         return(0);
     }
  else {
       if (blog[num].opers[2]==0) {
          if (stbuf.st_nlink==blog[num].link_lower)
             return(1);
          else
             return(0);
          }
       if (blog[num].opers[2]==1) {
          if (stbuf.st_nlink!=blog[num].link_lower)
             return(1);
          else
             return(0);
          }
       if (blog[num].link_lower < stbuf.st_nlink &&
           blog[num].link_upper > stbuf.st_nlink)
          return(1);
       else
          return(0);
     }
}

date1(num)

int num;
{

  long time();
  long tp, days_file, days;

  if (spec_options[num][5]==0) {
     if (num==0)
        return(1);
     else
        return(0);
     }
  else {
     time(&tp);
     days = tp/86400;
     days_file = stbuf.st_mtime/86400;
     if (blog[num].opers[1]==0) {
        if (days-blog[num].date_lower == days_file)
           return(1);
        else
           return(0);
        }
     if (blog[num].opers[1]==1) {
        if (days-blog[num].date_lower != days_file)
           return(1);
        else
           return(0);
        }
     if (days-days_file > blog[num].date_lower &&
         days-days_file < blog[num].date_upper)
        return(1);
     else
        return(0);
      }
}

type1(num)

int num;
{

  int i, j, typenum;

  if (spec_options[num][2]==0) {
     if (num==0)
        return(1);
     else
         return(0);
     }
  else {
      j=0;
      typenum = type[num]+1;
      for (i=0; i<=type[num]; i++)
          j = j + type2(num,i);
      if (num==1 && j>0)
         return(1);
      else if (num==0 && j==typenum)
         return(1);
      else
         return(0);
      }
}

type2(num,i)

int num, i;
{
  if (blog[num].types1[i].ftype=='f') {
     if (blog[num].types1[i].relational==0) {
        if ((stbuf.st_mode & S_IFMT) == S_IFREG)
           return(1);
        else
           return(0);
        }
     if (blog[num].types1[i].relational==1) {
        if ((stbuf.st_mode & S_IFMT) != S_IFREG)
           return(1);
        else
           return(0);
        }
     }
  else if (blog[num].types1[i].ftype=='d') {
     if (blog[num].types1[i].relational==0) {
        if ((stbuf.st_mode & S_IFMT) == S_IFDIR)
           return(1);
        else
           return(0);
        }
     if (blog[num].types1[i].relational==1) {
        if ((stbuf.st_mode & S_IFMT) != S_IFDIR)
           return(1);
        else
           return(0);
        }
     }
  else if (blog[num].types1[i].ftype=='c') {
     if (blog[num].types1[i].relational==0) {
        if ((stbuf.st_mode & S_IFMT) == S_IFCHR)
           return(1);
        else
           return(0);
        }
     if (blog[num].types1[i].relational==1) {
        if ((stbuf.st_mode & S_IFMT) != S_IFCHR)
           return(1);
        else
           return(0);
        }
     }
  else if (blog[num].types1[i].ftype=='b') {
     if (blog[num].types1[i].relational==0) {
        if ((stbuf.st_mode & S_IFMT) == S_IFBLK)
           return(1);
        else
           return(0);
        }
     if (blog[num].types1[i].relational==1) {
        if ((stbuf.st_mode & S_IFMT) != S_IFBLK)
           return(1);
        else
           return(0);
        }
     }
  else return(0);
}

user1(num)

int num;
{
  int j, i, usernum;

  if (spec_options[num][3]==0) {
     if (num==0)
        return(1);
     else
        return(0);
     }
  else {
       i=0;
       usernum=user[num]+1;
       for (j=0; j <= user[num]; j++)
           i = i + user2(num,j);
       if (num==1 && i>0)
          return(1);
       else if (num==0 && i==usernum)
          return(1);
       else
          return(0);
       }
}

user2(num,j)

int num,j;
{
  int i, k;

  if (blog[num].users1[j].urelational==0) {
     for (i=0; i <= nums[num]; i++) {
         if (ids[num][i] == stbuf.st_uid)
            return(1);
         }
     return(0);
     }
  k=-1;
  if (blog[num].users1[j].urelational==1) {
     for (i=0; i <= nums[num]; i++) {
         if (ids[num][i] != stbuf.st_uid)
            k++;
         }
     if (k==nums[num])
        return(1);
     else
        return(0);
     }
}

file_chek(name)

char *name;
{
  char tempfile[15];
  char *i;

  i=rindex(name,'/');
  strcpy(tempfile,substring(name,i-name+1,strlen(name)));
  if (match_char(tempfile,filename)==1)
     return(1);
  else
     return(0);
}

match_char(name,filename)

char *name, *filename;
{
  int i, j, l, n;
  char *c, *k, ch, tempfile[15], *substring();

  i=0; j=0;
  while (name[i] != '\0' || filename[j] != '\0') {
        if (filename[j] == '*') {
           ch=filename[j+1];
           if (ch=='\0')
              return(1);
           if (ch=='?') {
              if (name[i]=='\0')
                 return(0);
              if (filename[j+2]=='\0')
                 return(1);
              i++;
              ch = filename[j+2];
              j++;
              }
           if (ch=='*') {
              j++;
              continue;
              }
           if (ch=='[') {
              j++;
              strcpy(tempfile,substring(filename,j+1,strlen(filename)));
              k = index(tempfile,']');
              c = index(tempfile,'[');
              if ((k == '\0') || (c!='\0' && (c-tempfile < k-tempfile))) {
                 printf("No matching brace found\n");
                 exit(255);
                 }
              for (n=strlen(name)-1; n>=i; n--) {
                  for(l=j+1; l<k-tempfile+j; l++) {
                      if ((filename[l] == '-' && (filename[l-1]<name[n] &&
                                                  filename[l+1]>name[n])) ||
                          (filename[l] == name[n]))
                         goto found;
                      }
                  }
              return(0);
              found: j = k-tempfile+j+2;
              i=n+1;
              continue;
              }
           strcpy(tempfile,substring(name,i,strlen(name)));
           k = rindex(tempfile,ch);
           if (k=='\0')
              return(0);
           i=k-tempfile+i-1;
           }
        else if (filename[j]=='?') {
           if (name[i]=='\0')
              return(0);
           i++; j++;
           continue;
           }
        else if (filename[j]=='[') {
           strcpy(tempfile,substring(filename,j+1,strlen(filename)));
           k = index(tempfile,']');
           c = index(tempfile,'[');
           if ((k=='\0') || (c!='\0' && (c-tempfile < k-tempfile))) {
              printf("No matching brace found\n");
              exit(255);
              }
           for (l=j+1; l<k-tempfile+j; l++) {
               if ((filename[l] == '-' && (filename[l-1]<name[i] &&
                                           filename[l+1]>name[i])) ||
                   (filename[l] == name[i]))
                  break;
               if (l==k-tempfile+j-1)
                  return(0);
               }
           j = k-tempfile+j+1;
           }
        else if (filename[j] != name[i])
           return(0);
        i++; j++;
        }
  return(1);
}

compare(name,file)

char *name, *file;
{
  int i, j;

  i=strlen(name);
  j=strlen(file);
  if (i != j)
     return(0);
  for (i=0; i < j; i++) {
      if (name[i] != file[i])
         return(0);
      }
  return(1);
}
read_password(num)

int num;
{
  int i, fd, j;
  char ch, userid[4], username[10];

  if ((fd=open("/etc/log/password",0))==-1) {
     printf("Can't open password file\n");
     exit(255);
     }
  while (read(fd,(char *) &ch,1)>0) {
        for (i=0; i<=9; i++) {
            if (ch==':') {
               username[i]='\0';
               break;
               }
            username[i]=ch;
            read(fd,(char *) &ch,1);
            }
        for (j=0; j<=user[num]; j++) {
            if (compare(username,blog[num].users1[j].name)==1) {
               read(fd,(char *) &ch,1);
               while (ch != ':')
                     read(fd,(char *) &ch,1);
               for (i=0; i<=3; i++) {
                   read(fd,(char *) &ch,1);
                   if (ch==':') {
                      userid[i]='\0';
                      break;
                      }
                    userid[i]=ch;
                    }
                nums[num]++;
                ids[num][nums[num]]=atoi(userid);
                }
             }
         read(fd,(char *) &ch,1);
         while (ch != '\n')
                read(fd,(char *) &ch,1);
         }
  close(fd);
}
exec_command(name)

char *name;
{
  char *k, *j, argument, command_line[100];
  char tempfile[50], *substring(), temp_execute_list[50];
  int taskid, status, count, num;

  strcpy(temp_exec_list,execute_list);
  tempfile[0]='\0';
  do {
     j = index(temp_execute_list,';');
     if (j == '\0')
        strcpy(tempfile,temp_execute_list);
     else
        strcpy(tempfile,substring(temp_execute_list,0,j-temp_execute_list-1));
     k = index(tempfile,'&');
     if (k != '\0') {
        tempfile[k-tempfile] = ' ';
        strcpy(command_line,substring(tempfile,0,k-tempfile));
        strcat(command_line,name);
        strcpy(tempfile,substring(tempfile,k-tempfile,strlen(tempfile)));
        k = index(tempfile,'&');
        if (k != 0) {
           tempfile[k-tempfile] = ' ';
           strcat(command_line," ");
           strcat(command_line,name);
           }
        strcat(command_line,substring(tempfile,k-tempfile+1,strlen(tempfile)));
        }
     else
        strcpy(command_line,tempfile);
     taskid = fork();
     if (taskid==0) {
        execl("/bin/shell","shell","+c",command_line,0);
        exit(255);
        }
     taskid=wait(&status);
     if (status != 0) {
        printf("Syntax error in x option command\n");
        exit(255);
        }
     if (j != 0) {
     strcpy(tempfile,substring(temp_execute_list,j-temp_execute_list+1,
                                   strlen(temp_execute_list)));
     strcpy(temp_execute_list,tempfile);
        }
     } while(j != '\0');
}
