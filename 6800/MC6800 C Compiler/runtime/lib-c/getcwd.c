/*
     char *getcwd(buf, size)
          char     *buf;
          int       size;

          This function generates a character-string containing
          the current working-directory name followed by an end-
          of-line character.  If <size> is less than the number
          of bytes in the character-string, the function returns
          NULL.  If (<buf> != (char *) NULL), the function copies
          the generated data into the (char) array referenced by
          <buf> and returns <buf> as its result.  Otherwise, it
          attempts to allocate a buffer of size <size> using
          "malloc()" and copies the character-string into the
          allocated buffer and returns a pointer to that buffer
          if successful, otherwise it returns NULL.

     Arguments:
          buf       char *
                    Target buffer (NULL indicates one should
                    be allocated using "malloc()")
          size      int
                    Size of the target buffer

     Returns:  char *
          References a buffer containing the current
          working directory-name or NULL if error

     Notes:
        - The allocated buffer may be freed using "free()".
        - Ideally, "getcwd()" should return a pointer to a string
          in static store containing the name of the current
          working-directory.  The function should have no arguments
          and the result should not end with an EOL character.
          "getcwd()" was implemented to maintain compatability
          with UNIX.

     Routine History:
          08/06/84 kpm - New
          11/09/84 kpm - Rewrote using mount table
*/

#include  "machine.h"
#include  <string.h>
#include  <stdio.h>
#include  <sys/dir.h>
#include  <sys/stat.h>
#include  <sys/mtab.h>

#define   dfileno(p)     (p->dd_fd)
#define   min(i,j)       ((i<j)?i:j)

#define   UNKNOWN        "/???"


char *getcwd(buf, size)
               char          *buf;
               int            size;
{
     /*
          Local declarations
     */

               char          *malloc();

     ADDRREG0  char          *p;
     ADDRREG1  char          *q;
     ADDRREG3  char          *r;
     ADDRREG2  DIR           *pdir;
     ADDRREG4  struct direct *pent;

     DATAREG0  int            i;
     DATAREG1  int            cntr;
     DATAREG2  int            mtfd;
     DATAREG3  int            no_error = TRUE;
     DATAREG4  int            not_found = TRUE;

               struct stat    dot;
               struct stat    slash;
               struct mtab    mt;
               char           name[256];


     /*
       Initializations:
        - Init char counter (count terminating '\0' and EOL)
        - Get information about the root of the filesystem
        - Get information about the working directory
     */
     if (((cntr = min(size, sizeof(name)) - 2) >= 0) &&
         (stat(".", &dot) == 0) && 
         (stat("/", &slash) == 0))
     {
       p = name + sizeof(name);
       *--p = '\0';
       while (no_error && (dot.st_ino != 1))
       {
         if ((pdir = opendir("..")) != NULL)
         {
           /*
             Leaf through our parent directory looking for
             the name of our working directory (match fdn's)
           */
           while (((pent = readdir(pdir)) != NULL) &&
                  (pent->d_ino != dot.st_ino)) ;
           if (pent != NULL)
             if ((cntr -= pent->d_namlen + 1) >= 0)
             {
               /*
                 Prepend the working directory name to the
                 string we're building
               */
               for (i = pent->d_namlen, q = pent->d_name + i ;
                    --i >= 0 ; *--p = *--q) ;
               *--p = '/';
               /*
                 Change directories to our parent directory
               */
               fstat(dfileno(pdir), &dot);
               chdir("..");
             }
             else
               no_error = FALSE;
           else
             no_error = FALSE;
           closedir(pdir);
         }
         else
           no_error = FALSE;
       }

       /*
         Return to the original directory (skip over the
         leading '/' -- we're at the root of the device,
         not of the file system
       */
       chdir(p+1);
     }
     else
       no_error = FALSE;


     if (no_error)
     {
       /*
         The following attempts to handle directory names
         which span devices
       */
       if (dot.st_dev != slash.st_dev)
       {
         if ((mtfd = open(MTFILE, 0)) != -1)
         {
           /*
             Leaf through the mount table looking for the
             directory onto which this device was mounted
           */
           while(not_found &&
                 (read(mtfd, &mt, sizeof(mt)) == sizeof(mt)))
             if (mt.m_devno == dot.st_dev)
                not_found = FALSE;
           close(mtfd);
         }
         /*
           Prepend the name of the directory onto which the
           device containing the current directory was mounted.
           If the mount directory is undeterminable (for whatever
           reason), use the UNKNOWN string
         */
         q = not_found ? UNKNOWN : mt.m_dir;
         if ((cntr -= (i = strlen(q))) >= 0)
           for (q += i ; --i >= 0 ; *--p = *--q) ;
         else
           no_error = FALSE;
       }
       else
         if (*p == '\0')
           if (--cntr >= 0)
             *--p = '/';
           else
             no_error = FALSE;
     }
     else 
       no_error = FALSE;

     /*
       Copy the generated pathname into a buffer whose address
       will be returned.  If the user supplies no buffer,
       allocate one.
     */

     if (no_error)
     {
       if (buf == NULL)
         no_error = ((r = q = malloc(size)) != NULL);
       else 
         r = q = buf;
       if (no_error)
       {
         while (*q++ = *p++) ;
         *(q-1) = '\n'; /* UNIX compatability braindamage */
         *q = '\0';
       }
     }
     return(no_error ? r : NULL);
}
