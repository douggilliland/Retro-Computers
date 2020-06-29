/* example from pages 170 through 172 */

struct direct /* structure of a directory entry */
{
     int d_ino;  /* inode number */
     char d_name[14];  /* file name */
};

directry(name)    /* fsize for all files in name */
char *name;
{
     struct direct dirbuf;
     char *nbp, *nep;
     int i, fd;

     nbp = name+strlen(name);
     *nbp++ = '/';  /* add slash to directory name */
     if (nbp+16 >= name+100)  /* name too long */
           return;
     if ((fd = open(name, 0)) == -1)
           return;
     while (read(fd, (char *)&dirbuf, sizeof(dirbuf))>0) {
           if (dirbuf.d_ino == 0)  /* slot not in use */
                 continue;
           if (strcmp(dirbuf.d_name, ".") == 0
             || strcmp(dirbuf.d_name, "..") == 0)
                 continue;  /* skip self and parent */
           for (i=0, nep=nbp; i<14; i++)
                 *nep++ = dirbuf.d_name[i];
           *nep++ = '\0';
           fsize(name);
     }
     close(fd);
     *--nbp = '\0';  /* restore name */
}
