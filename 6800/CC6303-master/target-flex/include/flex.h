#ifndef _FLEX_FLEX_H
#define _FLEX_FLEX_H

extern int flex_inch(void);
extern int flex_inch2(void);
extern void flex_outch(char c);
extern void flex_outch2(char c);
extern int flex_getchr(void);
extern void flex_putchr(char c);
extern void flex_inbuff(void);
extern void flex_pstring(char *p);
extern int flex_class(char c);
extern void flex_pcrlf(void);
extern int flex_nxtch(void);
extern void flex_rstrio(void);
extern void flex_outdec(uint8_t *p, uint8_t pad);
extern void flex_outhex(uint8_t *p);
extern int flex_gethex(int *v);
extern void flex_outaddr(int v);
extern int flex_indec(int *v);
extern void flex_docmd(void);
extern int flex_stat(void);

struct flexconf {
    char linebuf[128];
    char bs;
    char del;
    char eol;
    uint8_t depth;
    uint8_t width;
    uint8_t nuls;
    char tab;
    uint8_t echobs;
    uint8_t eject;
    uint8_t pause;
    uint8_t esc;
    uint8_t sysdrive;
    uint8_t workdrive;
    uint8_t scratch0;
    uint8_t month;
    uint8_t day;
    uint8_t year;
    uint8_t lastterm;
    struct usercmd *usercmd;
    char *lineptr;
    void (*escfunc)();
    char curch;
    char prevch;
    char line;
    uint16_t loadoff;
    uint8_t xferflag;
    uint16_t xferaddr;
    uint8_t errtype;
    uint8_t specialio;
    uint8_t outsw;
    uint8_t insw;
    struct fms_fcb *outfcb;
    struct fms_fcb *infcb;
    uint8_t cmdflag;
    uint8_t col;
    uint8_t scratch1;
    uint16_t memend;
    char *errname;
    uint8_t fileecho;
};

#define flex_config	((struct flexconf *)0xAC00U)
    
#endif
