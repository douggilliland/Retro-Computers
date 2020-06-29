#define        DIRSIZ  14 /* max length of file name */

struct direct  /* structure of directory entry */
{
       unsigned d_ino;         /* fdn number */
       char d_name[DIRSIZ];    /* file name */
};
