#ifndef _STDIO_H
#define _STDIO_H

struct __file {
    uint8_t con;
    uint8_t reserved;
    struct fms_fcb fcb;
};

typedef struct __file FILE;
typedef struct __file DIR;

extern int getchar(void);
extern int putchar(int);
extern int fgetc(FILE *);
extern int getc(FILE *);
extern int fputc(int, FILE *);
extern int putc(int, FILE *);
extern int puts(const char *);
extern int fputs(const char *, FILE *);

extern void rewind(FILE *);

extern int fseek(FILE *, long *, int);e
extern long ftell(FILE *);

extern int gets(char *);
extern int fgets(char *, int, FILE *);

extern FILE *fopen(const char *, const char *);
extern int fclose(FILE *);

#endif
