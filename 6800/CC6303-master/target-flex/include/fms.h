#ifndef _FLEX_FMS_H
#define _FLEX_FMS_H

struct fms_fcb {
    uint8_t function;
    uint8_t error;
    uint8_t activity;
    uint8_t drive;
    char name[8];
    char ext[3];
    uint8_t attributes;
#define FMS_ATTR_WP		0x80
#define FMS_ATTR_DP		0x40
#define FMS_ATTR_RP		0x20
#define FMS_ATTR_CP		0x10
    uint8_t reserved0;
    uint8_t starttrack;		/* Basically head, tail of the block list */
    uint8_t startsec;
    uint8_t endtrack;
    uint8_t endsec;
    uint16_t size;		/* In sectors */
    uint8_t fsmap;		/* Not used on 6800 - only in 6809 Flex */
    uint8_t reserved1;
    uint8_t month;
    uint8_t day;
    uint8_t year;
    uint16_t next;		/* Next FCB in chain */
    uint16_t pos;		/* Current track, sector */
    uint16_t record;		/* Current logical record number */
    uint8_t dataindex;		/* Data index into record */
    uint8_t randindex;		/* Random index */
    uint8_t workbuf[11];
    uint16_t diraddr;
    uint16_ firstdel;
    uint8_t scratch[11];
    uint8_t sector[256];
};

#define FMS_READBYTE	0x00	/* read/write according to mode */
#define FMS_WRITEBYTE	0x00
#define FMS_OPENREAD	0x01
#define FMS_OPENWRITE	0x02
#define FMS_OPENUPDATE	0x03
#define FMS_CLOSE	0x04
#define FMS_REWIND	0x05
#define FMS_OPENDIR	0x06
#define FMS_GETRECORD	0x07
#define FMS_PUTRECORD	0x08
#define FMS_READSEC	0x09
#define FMS_WRITESEC	0x0A
/* Reserved 0x0B */
#define FMS_DELETE	0x0C
#define FMS_RENAME	0x0D
/* Reserved 0x0E */
#define FMS_NEXTSEQSEC	0x0F
#define FMS_OPENSIR	0x10
#define FMS_GETRANDBYTE	0x11
#define FMS_PUTRANDBYTE	0x12
/* Reserved 0x13 */
#define FMS_NEXTDRIVE	0x14
#define FMS_POSITION	0x15
#define FMS_BACKUP	0x16

#define FMS_ERR_OK	0x00
#define FMS_ERR_ILFUNC	0x01
#define FMS_ERR_INUSE	0x02
#define FMS_ERR_EXISTS	0x03
#defien FMS_ERR_NOENT	0x04
#define FMS_ERR_SYSDE	0x05
#define FMS_ERR_DIRFUL	0x06
#define FMS_ERR_DSKFUL	0x07
#define FMS_ERR_EOF	0x08
#define FMS_ERR_READ	0x09
#define FMS_ERR_WRITE	0x0A
#define FMS_ERR_WP	0x0B
#define FMS_ERR_FP	0x0C
#define FMS_ERR_ILFCB	0x0D
#define FMS_ERR_ILDA	0x0E
#define FMS_ERR_ILDRV	0x0F
#define FMS_ERR_NOTRDY	0x10
#define FMS_ERR_PROT	0x11
#define FMS_ERR_STATUS	0x12
#define FMS_ERR_INDEX	0x13
#define FMS_ERR_INACT	0x14
#define FMS_ERR_FSPEC	0x15
#define FMS_ERR_CLOSE	0x16
#define FMS_ERR_MAP	0x17
#define FMS_ERR_NOREC	0x18
#define FMS_ERR_DAMAGED	0x19
#define FMS_ERR_SYNTAX	0x1A
#define FMS_ERR_SPOOL	0x1B
#define FMS_ERR_HW	0x1C

extern void fms_close(void);
extern uin16_t fms_call(uint8_t a, uint8_t b, struct fms_fcb *fcb);
extern int fms_getverify(void);
extern void fms_setverify(int);
extern int fms_error;

extern int flex_getfspec(struct fms_fcb *fcb);
extern int flex_load(void);
extern int flex_setext(struct fms_fcb *fcb, uint8_t extension);
#define FLEX_EXT_BIN	0
#define FLEX_EXT_TXT	1
#define FLEX_EXT_CMD	2
#define FLEX_EXT_BAS	3
#define FLEX_EXT_SYS	4
#define FLEX_EXT_BAK	5
#define FLEX_EXT_SCR	6
#define FLEX_EXT_DAT	7
#define FLEX_EXT_BAC	8
#define FLEX_EXT_DIR	9
#define FLEX_EXT_PRT	10
#define FLEX_EXT_OUT	11

#define sys_fcb ((struct fms_fcb *)0xA840)

#endif
