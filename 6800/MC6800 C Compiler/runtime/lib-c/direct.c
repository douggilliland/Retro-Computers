/*******************************************************************/
/*                                                                 */
/*                   Directory Manipulation Routines               */
/*                                                                 */
/*******************************************************************/

#include <sys/dir.h>
#include <sys/stat.h>
#define ERROR (-1)   /* the general error status */

struct aslot {    /* structure of one slot */
   short fdn;                       /* fdn number */
   char name[DIR_CHARS_PER_SLOT];   /* name portion */
};

/*******************************************************************/
/*                                                                 */
/*    closedir - close a directory stream.                         */
/*                                                                 */
/*******************************************************************/

void closedir(dp)
register DIR *dp;    /* pointer to the directory information structure */

{
   if(dp != NULL) {
      close(dp->dd_fd);     /* close the file */
      free((char *)dp); /* return information structure */
   }
}

/*******************************************************************/
/*                                                                 */
/*    opendir - open a directory stream.                           */
/*                                                                 */
/*******************************************************************/

DIR *opendir(n)
char *n;       /* pointer to the directory name */

/*
   Return a pointer to the directory information structure.

   Returns the null pointer if
   1. the directory cannot be accessed, or
   2. the argument does not refer to a directory, or
   3. sufficient memory to hold the directory information structure
      cannot be obtained.
*/

{  struct stat sbuf;       /* status buffer */
   register DIR *info;     /* pointer to information structure */
   char *malloc();         /* memory allocator */

   if(stat(n,&sbuf) == ERROR ||
      (sbuf.st_mode & S_IFMT) != S_IFDIR ||
      (info = (DIR *)malloc(sizeof(DIR))) == NULL) return NULL;

   info->dd_size = sbuf.st_size; /* store raw directory size */
   if((info->dd_fd = open(n,0)) == ERROR) {  /*
      free((char *)info)   /* return information structure */
      return NULL;         /* return an error */
   }

   /* Initialize the rest of the information structure. */

   info->dd_loc = 0L;      /* initialize location */
   info->dd_first = info->dd_limit = info->dd_out = &info->dd_buf[0];
   return info;   /* return pointer to information structure */
}

/*******************************************************************/
/*                                                                 */
/*    readdir - read a directory stream.                           */
/*                                                                 */
/*******************************************************************/

struct direct *readdir(dp)
register DIR *dp;    /* pointer to the directory structure */

/*
   Return a pointer to the reformatted directory entry.

   Returns the null pointer if
   1. the end of the directory is reached, or
   2. an invalid "telldir" value was passed to "seekdir".
*/

{
   register char *cp;   /* scratch character pointer */
   register char*s_ptr; /* scratch character pointer */
   register struct direct *e_ptr;   /* an entry pointer */
   register struct aslot *slot;  /* slot pointer */
   short sl;            /* string length */
   short slot_count;    /* loop control */
   short char_count;    /* loop control */
   struct aslot *get_slot();  /* get address of slot */

   e_ptr = &dp->dd_entry;  /* set a pointer to the entry */
   do
     if((slot = get_slot(dp)) == NULL) return NULL;
   while (slot->fdn == 0);
    e_ptr->d_ino = slot->fdn;   /* copy fdn number */
    s_ptr = &e_ptr->d_name[0];   /* set string pointer */
   if((slot->name[0] & 0x80) == 0) { /* if a short name */
      strncpy(s_ptr,slot->name,DIR_CHARS_PER_SLOT); /* copy name */
      *(s_ptr+DIR_CHARS_PER_SLOT) = '\0'; /* guarantee terminated */
   }
   else {   /* process a long name */
      do {
         cp = &slot->name[0];  /* initialize name pointer */
         if((*cp & 0x80) == 0) break; /* error check */
         char_count = 0;   /* initialize character count */
         *cp &= 0x7f;      /* remove flag bit */
         slot_count = 0;   /* initialize loop control */
         while (char_count < DIR_CHARS_PER_SLOT && *cp != '\0') {
            *s_ptr++ = *cp++; /* copy the character */
            ++char_count;     /* count the character */
         }
         if(char_count < DIR_CHARS_PER_SLOT) break; /* if end of name */
      } while (slot_count < DIR_MAX_SLOTS &&
               (slot = get_slot(dp)) != NULL);

      /*
         End of name reached.  It is possible to have reached here
         because of an error condition, viz. the name does not have
         a trailing null character in it.  Because we have no way
         of returning an error, the name is left as is.
      */

      *s_ptr = '\0'; /* terminate the name */
   }
   e_ptr->d_namlen = strlen(e_ptr->d_name); /* store size */
   return e_ptr;  /* return pointer to entry */
}

/*******************************************************************/
/*                                                                 */
/*    readdir/get_slot - locate next slot in buffer.               */
/*                                                                 */
/*******************************************************************/

static struct aslot *get_slot(dp)
register DIR *dp;    /* pointer to directory information structure */

{  struct aslot *response;    /* function response */
   int char_count;            /* amount of data read */

   if(dp->dd_limit == dp->dd_out) { /* if buffer is empty */
      if(dp->dd_loc >= dp->dd_size) return NULL;   /* if end of directory */
      if((char_count = read(dp->dd_fd,dp->dd_first,DIRBUFSIZE)) > 0) {
         dp->dd_out = dp->dd_first; /* set pointers */
         dp->dd_limit = dp->dd_first + char_count; /* set limit */
      }
      else return NULL;    /* end of directory */
   }
   response = (struct aslot *)dp->dd_out; /* set response */
   dp->dd_out += sizeof(struct aslot); /* advance pointer */
   dp->dd_loc += sizeof(struct aslot); /* advance location */
   return response;  /* return */
}

/*******************************************************************/
/*                                                                 */
/*    rewinddir - rewind the directory stream.                     */
/*                                                                 */
/*******************************************************************/

void rewinddir(dp)
register DIR *dp;    /* pointer to directory information structure */

{  long lseek();     /* seek routine */

   dp->dd_limit = dp->dd_out = dp->dd_first;  /* empty the buffer */
   lseek(dp->dd_fd,(dp->dd_loc = 0L),0);   /* rewind the directory */
}

/*******************************************************************/
/*                                                                 */
/*    seekdir - set current position of the stream.                */
/*                                                                 */
/*******************************************************************/

void seekdir(dp,loc)
register DIR *dp;    /* pointer to directory information structure */
long loc;            /* seek location */

/*
   If the seek location is not a multiple of DIR_SLOT_SIZE, the
   location is set to the end of the directory.  This causes
   "readdir" to return a NULL.
*/

{  long lseek();     /* seek routine */

   dp->dd_limit = dp->dd_out = dp->dd_first;  /* empty the buffer */
   if(loc % (long)DIR_SLOT_SIZE != 0L) dp->dd_loc = dp->dd_size;
   else lseek(dp->dd_fd,(dp->dd_loc = loc),0);   /* seek to requested position */
}

/*******************************************************************/
/*                                                                 */
/*    telldir - return current position of the stream.             */
/*                                                                 */
/*******************************************************************/

long telldir(dp)
DIR *dp;    /* pointer to directory information structure */

{
   return dp->dd_loc;   /* return current location */
}
