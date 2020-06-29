/*******************************************************************/
/*                                                                 */
/*                  Error Message Handler                          */
/*                                                                 */
/*******************************************************************/

#include  <errno.h>
#include  "boolean.h"
#include  "errnum.h"
#include  "miscdefs.h"

extern int errno;   /* system error number */
extern int fout;    /* output file desscriptor */

/*******************************************************************/
/*                                                                 */
/*   error - fatal error                                           */
/*                                                                 */
/*******************************************************************/

error(n)
int       n;        /* error number */

{
abort();
     rptern(n); /* report the error */
     exit(255); /* abort */
}

/*******************************************************************/
/*                                                                 */
/*   rptern - report nonfatal error                                */
/*                                                                 */
/*******************************************************************/

rptern(n)
int n;  /* error number */

{    register char *m;  /* message pointer */
     BOOLEAN print_system_error = FALSE;

     m = NULL;      /* clear pointer */
     switch(n) {
     case 0:        pfile();  /* print current filename */
                    p_sys_err(errno);  /* print system error */
                    break;
     case 44:       m = "*** Constant or left parenthesis expected.\n";
                    break;
     case 45:       m = "*** Right parenthesis expected.\n";
                    break;
     case MEMERR:   m = "*** Memory overflow.\n";
                    break;
     case FLNERR:   m = "*** Format error in \"include\" file name.\n";
                    break;
     case FNFERR:   m=  "\"Include\" file not found.\n";
                    break;
     case DEFNAM:   m = "*** Format error in definition name";
                    break;
     case IFNERR:   m = "*** Format error in name in \"if\" statement.\n";
                    break;
     case IFDERR:   m = "*** \"Endif\" without a matching \"if\".\n";
                    break;
     case IFLERR:   m = "*** \"Else\" without a matching \"if\".\n";
                    break;
     case CMDERR:   m = "*** Unknown preprocessor command.\n";
                    break;
     case DUPERR:   m = "*** Duplicate definition.\n";
                    break;
     case CLDEFNAM: m = "*** Format error in 'D' option name.\n";
                    break;
     case DEFARG:   m = "*** Missing ')' after macro argument list.\n";
                    break;
     case CLDEFARG: m = "*** Missing ')' after argument list in 'D' option.\n";
                    break;
     case CLDUPERR: m = "*** Duplicate definition in 'D' option.\n";
                    break;
     case NOENDIF:  m = "*** Missing \"endif\".\n";
                    break;
     case TOODEEP:  m = "*** Macro recursion depth exceeded.\n";
                    break;
     case PARERR:   m = "*** Macro parameter substitution error.\n";
                    break;
     case EXPERR:   m = "*** Variable found in \"if\" expression.\n";
                    break;
     default:       pfile();
                    perr_line();
                    p_sys_err(n);
                    flush();
                    fout = 1;
                    break;
     }
     if(m != NULL) {
          switch (n) {
          case CLDEFNAM:
          case CLDEFARG:
          case CLDUPERR: break;
          default:
               pfile();
               perr_line();  /* print the line */
               break;
          }
          to_std_error(m);
          if(print_system_error)p_sys_err(errno);
     }
}

/*******************************************************************/
/*                                                                 */
/*   p_sys_err - print system error                                */
/*                                                                 */
/*******************************************************************/

p_sys_err(n)
int       n;        /* error number */

/*   Error messages are read from a standard system error file.
     If the file cannot be accessed, the error number is printed. */

{    char m_buf[256];    /* message buffer */
     int  fd = -1;       /* file descriptor */
     BOOLEAN good = FALSE;    /* error control */
     short i;            /* scratch integer */
     long lseek();       /* seek routine */

     m_buf[0] = m_buf[255] = '\0';
     if(n != 0) {
          if( (fd=open("/gen/errors/system",0)) != -1 && n < 64 &&
               lseek(fd,(long)(sizeof(short)*n),0) != -1 &&
               read(fd,&i,sizeof(i)) == sizeof(i) &&
               lseek(fd,(long)(i+sizeof(short)),0) != -1 &&
               read(fd,m_buf,255) > 0) good = TRUE;

          if(good) printf(2,"%s\n",m_buf);
          else printf(2,"System error code: %d\n",n);
          flush();
          fout = 1;
          if(fd != -1) close(fd);  /* close message file */
     }
}
