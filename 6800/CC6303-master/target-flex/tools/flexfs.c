#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include <assert.h>
#include "flexfs.h"

/* FLEX stores text files in a slightly weird 'space compressed' format. This
   is the default automatic behaviour of FLEX and done by the OS itself so
   generally any 'text' file is in this format.
   
   0x00 is padding (usually to the end of sector as FLEX lacks byte level
   file sizes). It's not an EOF marker so you can APPEND files
   0x18 works like 0xDD (no idea why!)
   0x0D is a newline - we turn it into \n for Linux
   0x09 is a space compression marker and followed by a byte showing the
   number of spaces to replace it with (2-127)
   
   We blindly obey nonsense expansion sizes, it's better to have 250 spaces
   than an error code usually */
   
static uint8_t decompstate;

static void reset_decompress(void)
{
    decompstate = 0;
}

static void decompbyte(uint8_t c, FILE *fp)
{
    switch(decompstate) {
    case 0:
        if (c == 0)
            return;
        if (c == 0x18)
            return;
        if (c == 0x09) {
            decompstate = 1;
            return;
        }
        if (c == 0x0D)
            c = '\n';
        fputc(c, fp);
        break;
    case 1:
        while(c--)
            fputc(' ', fp);
        decompstate = 0;
        break;
    }
}

static void decompress(uint8_t *buf, int len, FILE *fp)
{
    while(len--)
        decompbyte(*buf++, fp);
}

/* Low level disk I/O */
static struct sir sir;
static int disk_fd;

static void sir_setsecfree(uint16_t secs)
{
    sir.secfreel = secs;
    sir.secfreeh = secs >> 8;
}

static off_t disk_offset(int track, int sec)
{
    off_t pos = track * sir.endsector;
    if (track == 0 && sec < 2)
        sec++;
    pos += sec - 1;
    pos *= 256;
    return pos;
}

static void disk_read(int track, int sec, uint8_t *buf)
{
    off_t pos = disk_offset(track, sec);
    int l;
    if (lseek(disk_fd, pos, SEEK_SET) < 0) {
        perror("lseek");
        exit(1);
    }
    if ((l = read(disk_fd, buf, 256)) != 256) {
        if (l < 0)
            perror("read");
        else
            fprintf(stderr, "read: short read (%d,%d)->%ld.\n", track, sec, pos);
        exit(1);
    }
}

static void disk_write(int track, int sec, uint8_t *buf)
{
    off_t pos = disk_offset(track, sec);
    int l;
    if (lseek(disk_fd, pos, SEEK_SET) < 0) {
        perror("lseek");
        exit(1);
    }
    if ((l = write(disk_fd, buf, 256)) != 256) {
        if (l < 0)
            perror("write");
        else
            fprintf(stderr, "write: short write.\n");
        exit(1);
    }
}

static int disk_read_next(uint8_t *buf)
{
    if (buf[0] ==0 && buf[1] == 0)
        return 0;
    disk_read(buf[0], buf[1], buf);
    return 1;
}

static uint8_t workbuf[256];
static uint8_t dirbuf[256];
static uint8_t dirtrk;
static uint8_t dirsec;
static int dirpt;
static uint16_t *flex_map;

static void dir_begin(void)
{
    disk_read(0, 5, dirbuf);
    dirtrk = 0;
    dirsec = 5;
    dirpt = 1;
}

static struct dir *dir_get(void)
{
    return (struct dir *)(dirbuf + 24 * dirpt + 16);
}

static int dir_next(void)
{
    dirpt++;
    if (dirpt == 10) {
        dirpt = 1;
        dirtrk = dirbuf[0];
        dirsec = dirbuf[1];
        return disk_read_next(dirbuf);
    } else
        return 1;
}

static void dir_write(void)
{
    disk_write(dirtrk, dirsec, dirbuf);
}

static int dir_match(const char *name, const char *ext)
{
    struct dir *d = dir_get();
    if (strncmp(name, d->name, 8) == 0 && strncmp(ext, d->ext, 3) == 0)
        return 1;
    return 0;
}

static struct dir *dir_find(const char *name, const char *ext)
{
    dir_begin();
    do {
        if (dir_match(name, ext))
            return dir_get();
    } while(dir_next());
    return NULL;
}

static struct dir *dir_findfree(void)
{
    dir_begin();
    do {
        struct dir *d = dir_get();
        if (d->name[0] == 0 || d->name[0] & 0x80)
            return d;
    } while(dir_next());
    return NULL;
}

static void timestamp(struct dir *d)
{
    long t = time(NULL);
    struct tm *tm = localtime(&t);
    d->day = tm->tm_mday;
    d->month = tm->tm_mon + 1;
    d->year = tm->tm_year % 100;
}

static int read_sir(void)
{
    if (lseek(disk_fd, 512 + 16, SEEK_SET) < 0)
        return -1;
    if (read(disk_fd, &sir, sizeof(struct sir)) != sizeof(struct sir))
        return -1;
    return 0;
}

static void write_sir(void)
{
    if (lseek(disk_fd, 512 + 16, SEEK_SET) < 0 || write(disk_fd, &sir, sizeof(struct sir)) != sizeof(struct sir)) {
        perror("write sir");
        exit(1);
    }
}

static int flex_mount(void)
{
    if (read_sir() < 0)
        return -1;
//    if (sir.month > 12 || sir.day > 31 || sir.day == 0)
//        return -1;
    if (sir.endtrack < 34 || sir.endsector < 9)
        return -1;
    printf("Mounting volume %-11.11s serial %d  %02d/%02d/%02d\n",
        sir.label, (sir.volh << 8) | sir.voll, 
        sir.day, sir.month, sir.year);
    printf("Disk geometry is %d tracks, %d sectors per track.\n",
        sir.endtrack + 1, sir.endsector);
    return 0;
}

static int mark_block_chain(const char *name, uint16_t code, uint8_t track, uint8_t sec, uint8_t etrack, uint8_t esec)
{
    int count = 0;
    int pos;
    while(track || sec) {
        if (sec == 0 || sec > sir.endsector || track == 0 || track > sir.endtrack) {
            fprintf(stderr, "%s: corrupt sector chain reference (%d,%d)\n",
                name, track, sec);
            break;
        }
        disk_read(track, sec, workbuf);
        pos = track * sir.endsector + (sec - 1);
        switch (flex_map[pos]) {
            case 0xFFFF:
                flex_map[pos] = code;
                break;
            case 0xFFFE:
                fprintf(stderr, "%s: block (%d,%d) is on free chain.\n", name, track, sec);
                break;
            case 0x0001:
                fprintf(stderr, "%s: block (%d,%d) is in another file.\n", name, track, sec);
                break;
            /* TODO: relace 0x0001 etc with the directory count from start of
               dir so we can report which file */
            default:
                fprintf(stderr, "%s: bad value %04X in map.\n", name, flex_map[pos]);
        }
        count++;
        if (*workbuf == 0 && workbuf[1] == 0)
            break;
        track = *workbuf;
        sec = workbuf[1];
    }
    if (track != etrack || sec != esec)
        fprintf(stderr, "%s: end of chain is (%d,%d) but should be (%d,%d).\n",
            name, track, sec, etrack, esec);
    return count;
}

static void mark_blocks_used(struct dir *d)
{
    char buf[16];
    int count;
    snprintf(buf, 16, "%.8s.%.3s", d->name, d->ext);
    count = mark_block_chain(buf, 0x0001, d->strack, d->ssec, d->etrack, d->esec);
    if (count != ((d->sech << 8) | d->secl))
        fprintf(stderr, "%s: block chain length does not match sectors (%d v %d).\n",
            buf, (d->sech << 8) | d->secl, count);
}

static void flex_buildmap(void)
{
    struct dir *d;
    int count;
    if (flex_map)
        free(flex_map);
    flex_map = calloc((sir.endtrack + 1) * sir.endsector, sizeof(uint16_t));
    if (flex_map == NULL) {
        fprintf(stderr, "Out of memory.\n");
        exit(1);
    }
    memset(flex_map, 0xFF, (sir.endtrack + 1) * sir.endsector * sizeof(uint16_t));

    dir_begin();
    do {
        d = dir_get();
        if (d->name[0] && !(d->name[0] & 0x80))
            mark_blocks_used(d);
    } while(dir_next());
    count = mark_block_chain("free", 0xFFFE, sir.ffreetrack, sir.ffreesec, sir.lfreetrack, sir.lfreesec);
    if (count != sir_secfree()) {
        fprintf(stderr, "%d blocks in the free chain, space free claims to be %d blocks.\n",
            count, sir_secfree());
    }
}

static int flex_unlink(const char *name, const char *ext)
{
    struct dir *d = dir_find(name, ext);
    uint16_t freesec;
    if (d == NULL)
        return -1;
    d->name[0] |= 0x80;
    if (d->etrack || d->esec) {
        disk_read(d->etrack, d->esec, workbuf);
        /* Hook the existing free list onto the end of the file chain */
        *workbuf = sir.ffreetrack;
        workbuf[1] = sir.ffreesec;
        /* Update the free sector count
         */
        freesec = sir_secfree();
        freesec += dir_sectors(d);
        sir_setsecfree(freesec);
        disk_write(d->etrack, d->esec, workbuf);
        /* Now add it to the SIR */
        sir.ffreetrack = d->strack;
        sir.ffreesec = d->ssec;
        write_sir();
    }
    d->etrack = d->esec = d->ssec = d->strack = 0;
    dir_write();
    return 0;
}

static struct dir *flex_create(const char *name, const char *ext)
{
    struct dir *d = dir_find(name, ext);
    if (d != NULL)
        return NULL;		/* Exists */
    d = dir_findfree();
    memset(d, 0, sizeof(*d));
    strncpy(d->name, name, 8);
    strncpy(d->ext, ext, 3);
    timestamp(d);
    d->strack = 0;
    d->ssec = 0;
    d->etrack = 0;
    d->esec = 0;
    dir_write();
    return d;
}

/* Add a 256 byte sector to a file */
static int flex_append(struct dir *d, const char *buf)
{
    uint8_t trk,sec;
    /* Space ? */
    if (sir_secfree() == 0)
        return -1;
    /* If we have sectors already then change the end pointer of the last one */
    if (d->esec || d->etrack) {
        disk_read(d->etrack, d->esec, workbuf);
        workbuf[0] = sir.ffreetrack;
        workbuf[1] = sir.ffreesec;
        disk_write(d->etrack, d->esec, workbuf);
    }
    /* Update the sir, dir and new sector */
    trk = sir.ffreetrack;
    sec = sir.ffreesec;
    disk_read(trk, sec, workbuf);
    sir.ffreetrack = *workbuf;
    sir.ffreesec = workbuf[1];
    /* First block - update the header */
    if (d->etrack == 0 && d->esec == 0) {
        d->strack = trk;
        d->ssec = sec;
    }
    d->etrack = trk;
    d->esec = sec;
    /* Adjust sec count in directory */
    d->secl++;
    if (d->secl == 0)
        d->sech++;
    *workbuf = 0;
    workbuf[1] = 0;
    /* Sectors have logical record numbers 1+ */
    workbuf[2] = d->sech;
    workbuf[3] = d->secl;
    /* Add the data */
    memcpy(workbuf + 4, buf, 252);
    disk_write(trk, sec, workbuf);
    /* Adjust sir.secfree */
    sir_setsecfree(sir_secfree() - 1);
    dir_write();
    write_sir();
    return 0;
}

static int flex_addfile(const char *name, const char *ext, FILE *inf)
{
    char buf[252];
    int l;
    struct dir *d;
    d = flex_create(name, ext);
    if (d == NULL)
        return -1;
    while((l = fread(buf, 1, 252, inf)) > 0) {
        /* Flex zeroes unused space and the Flex file formats need that */
        if (l != 252)
            memset(buf + l, 0,252 - l);
        flex_append(d, buf);
    }
    if (l == -1) {
        perror("read");
        exit(1);
    }
    return 0;
}

static int flex_dump(struct dir *d, FILE *outf, int ascii)
{
    int count = 0;
    reset_decompress();
    /* Dump each sector in turn */
    if (d->strack == 0 && d->ssec == 0)
        return 0;
    disk_read(d->strack, d->ssec, workbuf);
    do {
        count++;
        if (((workbuf[2] << 8) | workbuf[3]) != count)
            fprintf(stderr, "%s.%s: sector %d has a sector count of %d.\n",
                d->name, d->ext, count, (workbuf[2] << 8) | workbuf[3]);
        if (ascii)
            decompress(workbuf + 4, 252, outf);
        else if (fwrite(workbuf + 4, 252, 1, outf) != 1) {
            fprintf(stderr, "%s.%s: write error.\n", d->name, d->ext);
            exit(1);
        }
    } while(disk_read_next(workbuf));
    return 0;
}

static int flex_get(const char *name, const char *ext, FILE *outf, int ascii)
{
    struct dir *d = dir_find(name, ext);
    if (d == NULL) {
        fprintf(stderr, "File not found.\n");
        return -1;
    }
    return flex_dump(d, outf, ascii);
}

static void flex_get_all(void)
{
    FILE *outf;
    char buf[16];
    dir_begin();
    int txt;
    do {
        struct dir *d = dir_get();
        if (d->name[0] == 0 || d->name[0] & 0x80)
            continue;
        snprintf(buf, 16, "%.8s.%s.3s", d->name, d->ext);
        outf = fopen(buf, "w");
        if (outf == NULL) {
            perror(buf);
            continue;
        }
        txt = !memcmp(d->ext, "TXT", 3);
        flex_dump(d, outf, txt);
        fclose(outf);
    } while(dir_next());
}

static void flex_ls(void)
{
    struct dir *d;
    printf("Volume: %-11.11s   (%02d/%02d/%02d)\n",
        sir.label, sir.day, sir.month, sir.year);
    printf("Media format %d tracks, %d sectors per track.\n",
        sir.endtrack+1, sir.endsector);
    dir_begin();
    do {
        d = dir_get();
        if (*d->name != 0 && (*d->name & 0x80) == 0) {
            printf("  %-8.8s.%-3.3s     %5d %02d/%02d/%02d\n",
                d->name, d->ext, dir_sectors(d),
                d->day, d->month, d->year);
        }
    } while(dir_next());
    printf("%d sectors free.\n", sir_secfree());
}

static void flex_showmap(void)
{
    int t, s;
    uint16_t *p;

    flex_buildmap();
    
    p = flex_map;

    for (t = 0; t <= sir.endtrack; t++) {
        for (s = 0; s < sir.endsector - 1; s++) {
            switch(*p++) {
                case 0xFFFF:
                    putchar('.');
                    break;
                case 0xFFFE:
                    putchar('-');
                    break;
                case 0x0001:
                    putchar('F');
                    break;
                default:
                    putchar('?');
                    break;
            }
        }
        putchar('\n');
    }
}

static void usage(void)
{
    fprintf(stderr, "flexfs:\n");
    fprintf(stderr, "-a: do space compressed to ASCII conversion.\n");
    fprintf(stderr, "-d disk.dsk file.ext            : delete a file.\n");
    fprintf(stderr, "-g disk.dsk file.ext linuxfile  : get a file.\n");
    fprintf(stderr, "-g -A disk.dsk                  : extract all of the files.\n");
    fprintf(stderr, "-l disk.dsk                     : list contents of disk.\n");
    fprintf(stderr, "-m disk.dsk                     : check disk and show map.\n");
    fprintf(stderr, "-p disk.dsik file.ext linuxfile : put a file.\n");
    exit(1);
}

enum command {
    LIST,
    GET,
    PUT,
    DELETE,
    MAP
};

int main(int argc, char *argv[])
{
    int opt;
    int all = 0;
    int ascii = 0;
    enum command cmd = LIST;
    char *ext;
    char *name;

    assert(sizeof(struct dir) == 24);
    
    while((opt = getopt(argc, argv, "lgmpdaA")) != -1) {
        switch(opt) {
        case 'l':
            cmd = LIST;
            break;
        case 'g':
            cmd = GET;
            break;
        case 'p':
            cmd = PUT;
            break;
        case 'd':
            cmd = DELETE;
            break;
        case 'm':
            cmd = MAP;
            break;
        case 'a':
            ascii = 1;
            break;
        case 'A':
            all = 1;
            break;
        default:
            usage();
        }
    }
    if (all && cmd != GET) {
        fprintf(stderr, "flexfs: -A only supported with -g.\n");
        exit(1);
    }
    if (cmd == LIST || cmd == MAP || all == 1 ) {
        if (optind + 1 != argc)
            usage();
    } else {
        if (cmd == DELETE && optind + 2 != argc)
            usage();
        else if (optind + 3 != argc)
            usage();
        name = argv[optind + 1];
        ext = strchr(name, '.');
        if (ext)
            *ext++ = 0;
        else
            ext = "";
    }

    disk_fd = open(argv[optind], O_RDWR);
    if (disk_fd == -1) {
        perror(argv[optind]);
        exit(1);
    }
    if (flex_mount() < 0) {
        fprintf(stderr, "%s: not a FLEX volume.\n", argv[optind]);
        exit(1);
    }
    switch(cmd) {
        case LIST:
            flex_ls();
            break;
        case GET:
            if (all)
                flex_get_all();
            else {
                FILE *fp = fopen(argv[optind + 2], "w");
                if (fp == NULL) {
                    perror(argv[optind + 2]);
                    exit(1);
                }
                flex_get(name, ext, fp, ascii);
                if (fclose(fp) < 0) {
                    perror(argv[optind + 2]);
                    exit(1);
                }
            }
            break;
        case PUT:
            {
                FILE *fp = fopen(argv[optind + 2], "r");
                if (fp == NULL) {
                    perror(argv[optind + 2]);
                    exit(1);
                }
                flex_addfile(name, ext, fp);
                if (fclose(fp) < 0) {
                    perror(argv[optind + 2]);
                    exit(1);
                }
            }
            break;
        case DELETE:
            flex_unlink(name, ext);
            break;
        case MAP:
            flex_showmap();
    }
    return 0;
}
