struct sgttyb { /* structure for 'stty' and 'gtty' */
    char sg_flags,      /* mode flag - see below */
         sg_delay,     /* delay type - see below */
         sg_kill,      /* line cancel character - default cntrl X */
         sg_erase,     /* backspace/rubout char.- default cntrl H */
         sg_speed,     /* terminal speed - unused */
         sg_spare;
};

/* terminal modes */
#define      RAW        01   /* raw - single char,no mapping,no echo etc. */
#define      ECHO       02   /* input character echo */
#define      XTABS      04   /* expand tabs on output */
#define      LCASE      010  /* map upper-case to lower-case on input */
#define      CRMOD      020  /* output cr-lf for cr */
#define      SCOPE      040  /* echo backspace echo char */
#define      CBREAK     0100 /* single char i/o */
#define      CNTRL      0200 /* ignore control characters */

/* delay types */
#define      DELNL      03   /* new line */
#define      DELCR      014  /* carriage-return */
#define      DELTB      020  /* tab */
#define      DELVT      040  /* vertical tab */
#define      DELFF      040  /* form-feed (as DELVT) */
