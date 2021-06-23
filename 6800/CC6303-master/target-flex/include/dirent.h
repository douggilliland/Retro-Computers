#ifndef _DIRENT_H
#include _DIRENT_H

#include <stdio.h>

typedef int16_t d_ino;

struct __dir {
    struct dirent d;
    FILE fp;
};

struct dirent
{
    char name[13];
    ino_t d_ino;	/* Meaningless but POSIX required */
};

extern DIR *opendir(const char *);
extern int closedir(DIR *);
extern struct dirent *readdir(DIR *);

#endif
