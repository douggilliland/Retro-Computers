
/* Done this way so it packs and is safe to access */
struct sir {
    char label[11];
    uint8_t volh;
    uint8_t voll;
    uint8_t ffreetrack;	/* These are effectively head, tail of the free list */
    uint8_t ffreesec;
    uint8_t lfreetrack;
    uint8_t lfreesec;
    uint8_t secfreeh;
    uint8_t secfreel;
    uint8_t month;
    uint8_t day;
    uint8_t year;
    uint8_t endtrack;
    uint8_t endsector;
};

struct dir {
    char name[8];
    char ext[3];
    uint8_t pad0;
    uint8_t pad1;
    uint8_t strack;
    uint8_t ssec;
    uint8_t etrack;
    uint8_t esec;
    uint8_t sech;
    uint8_t secl;
    uint8_t rndf;	/* Only on Flex 6809 afaik */
    uint8_t pad2;
    uint8_t month;
    uint8_t day;
    uint8_t year;
};

#define sir_secfree()	(sir.secfreel + (sir.secfreeh << 8))
#define dir_sectors(d)	(((d)->sech << 8) + ((d)->secl))