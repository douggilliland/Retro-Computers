/*
 * tss/8 rf08 disk file system utility
 * list directory, copy files in/out
 * brad@heeltoe.com 1/2014
 */

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string.h>

typedef unsigned short u12;

unsigned char binfile[16*1024];

#define RFSIZE (1024*1024)
u12 rf[RFSIZE];
int rf_size;
int rf_fd;
int clear_flag;
int debug;

#define MEMSIZE (32*1024)

int disk_load(char *filename)
{
    int fd, ret;

    if (clear_flag) {
        rf_size = 524288 / 2;
        memset((void *)rf, 0, sizeof(rf));
        printf("creating rf disk, word size %d\n", rf_size);

        rf_fd = open(filename, O_CREAT | O_RDWR, 0666);
        if (rf_fd < 0) {
            perror(filename);
            return -1;
        }
    } 
    else
    {
        rf_fd = open(filename, O_RDWR);
        if (rf_fd < 0) {
            perror(filename);
            return -1;
        }
    }

    ret = read(rf_fd, rf, sizeof(rf));
    if (ret < 0) {
	perror(filename);
    } else {
	rf_size = ret / 2;
	printf("loaded rf disk, word size %d\n", rf_size);
	ret = 0;
    }

    if (debug) printf("rf_fd %d\n", rf_fd);

    return ret;
}

int disk_save(void)
{
    int ret;

    printf("saving rf disk, word size %d\n", rf_size);

    ret = (int)lseek(rf_fd, (off_t)0, SEEK_SET);
    if (ret != 0) {
	perror("seek");
	return -1;
    }

    ret = write(rf_fd, rf, rf_size*2);
    if (ret != rf_size*2) {
	printf("write failed; wrote %d, ret %d\n", rf_size*2, ret);
	perror("write");
	return -1;
    }

    return 0;
}

#if 0
int field_save(int field)
{
    int i, offset;

    printf("saving field %d\n", field);

    offset = field * 4096;
    for (i = 0; i < 4096; i++) {
        if (filled[field][i]) {
            rf[offset+i] = fields[field][i];
        }
    }
}

int field_dump(int srcfield, char *filename)
{
    FILE *f;
    int i;
    f = fopen(filename, "w");
    if (f == NULL) {
        perror(filename);
        return -1;
    }

    for (i = 0; i < 4096; i++) {
        fprintf(f, "%d%04o %04o\n", srcfield, i, fields[srcfield][i]);
    }

    fclose(f);
}
#endif

char sixbit(int six)
{
    six &= 0x3f;
    return six + ' ';
}

#define MAX_MFD 32

struct {
    int proj, pgmr;
    char pw[6];
    int next;
    int ptr;
} mfd_entry[MAX_MFD];
int mfd_count;

int show_ufd(int base, int w[])
{
    int i, seg, dbase, o, b;

    // 0400 words/segment
    b = 0;
    o = 0;

    while (1) {
        seg = w[b+1];
        if (seg == 0)
            return;

        dbase = base + ((seg-1) * 0400);
        //printf("show_ufd; base %o, seg %o dbase %o\n", base, seg, dbase);

        {
            int w1, w2, w3, next, ptr, prot, scnt, adate, ext;
            char c[12];

            w1 = rf[dbase+o+0];
            w2 = rf[dbase+o+1];
            w3 = rf[dbase+o+2];
            next = rf[dbase+o+3];
            prot = rf[dbase+o+4];
            scnt = rf[dbase+o+5];
            adate = rf[dbase+o+6];
            ptr = rf[dbase+o+7];

            ext = prot >> 6;
            prot &= 077;

            c[0] = sixbit(w1 >> 6);
            c[1] = sixbit(w1);
            c[2] = sixbit(w2 >> 6);
            c[3] = sixbit(w2);
            c[4] = sixbit(w3 >> 6);
            c[5] = sixbit(w3);
            c[6] = 0;

            o = next % 0400;
            b = next / 0400;

            if (o > 0) {
                printf("%s %o %4d prot %o next %o ptr %o ", c, ext, scnt, prot, next, ptr);
                printf("; -> %o[%o]\n",  b, o);
            }

            if (next == 0)
                break;
        }
    }
}

int read_mfd(void)
{
    int i, base, o;

    base = 0310000;
    o = 0;
    for (i = 0; i < MAX_MFD; i++) {
        int w1, w2, w3, next, ptr, proj, pgmr;
        char c[12];

        w1 = rf[base+o+0];
        w2 = rf[base+o+1];
        w3 = rf[base+o+2];
        next = rf[base+o+3];
        ptr = rf[base+o+7];

        c[0] = sixbit(w1 >> 6);
        c[1] = sixbit(w1);
        c[2] = sixbit(w2 >> 6);
        c[3] = sixbit(w2);
        c[4] = sixbit(w3 >> 6);
        c[5] = sixbit(w3);
        c[6] = 0;

        //printf("0%o 0x%x ", w1, w1);
        proj = w1 >> 6;
        pgmr = w1 & 077;

        if (o > 0) {
            mfd_entry[mfd_count].proj = proj;
            mfd_entry[mfd_count].pgmr = pgmr;
            strcpy(mfd_entry[mfd_count].pw, c);
            mfd_entry[mfd_count].next = next;
            mfd_entry[mfd_count].ptr = ptr;
            mfd_count++;

            printf("[%2o, %2o] %s next %o ptr %o\n", proj, pgmr, c+2, next, ptr);

            while (1) {
                int j, w[8], n;
                for (j = 0; j < 8; j++) {
                    w[j] = rf[base+ptr+j];
                }
                n = w[0];
                printf(" next %o; %o %o %o %o %o %o %o\n",
                       w[0], w[1], w[2], w[3], w[4], w[5], w[6], w[7]);

                show_ufd(base, w);
                if (n == 0)
                    break;
            }
        }

        o = next;
        if (next == 0)
            break;
    }
}

int show_dir(void)
{
    read_mfd();

    return 0;
}

int eval_scriptline(char *line)
{
    char word1[256], word2[256], word3[256];
    int count, fld;

    count = sscanf(line, "%s %s %s", word1, word2, word3);

    if (strcmp(word1, "clear") == 0) {
        rf_size = 524288 / 2;
        memset((void *)rf, 0, sizeof(rf));
    }

    if (strcmp(word1, "disk") == 0) {
	if (count < 2) {
	    fprintf(stderr, "missing disk arg\n");
	    return -1;
	}

	return disk_load(word2);
    }

    if (strcmp(word1, "dir") == 0) {
        show_dir();
        return 0;
    }

    if (strcmp(word1, "copy") == 0) {
        return 0;
    }

    if (strcmp(word1, "dump") == 0) {
        return 0;
    }

    if (strcmp(word1, "save") == 0) {
        if (disk_save())
            return -1;

        return 0;
    }

    return -1;
}

int eval_scriptfile(char *filename)
{
    FILE *f;
    char line[1024];

    f = fopen(filename, "r");
    if (f == NULL) {
	perror(filename);
	return -1;
    }

    while (fgets(line, sizeof(line), f)) {
	eval_scriptline(line);
    }

    fclose(f);

    return 0;
}

extern char *optarg;
extern int optind;

main(int argc, char **argv)
{
    int c;
    char *scriptfile;

    scriptfile = NULL/*"script"*/;
    clear_flag = 0;

    while ((c = getopt(argc, argv, "cs:")) != -1) {
        switch (c) {
        case 'c':
            clear_flag++;
            break;
        case 's':
            scriptfile = strdup(optarg);
            break;
        }
    }

    if (optind < argc && scriptfile == NULL) {
        scriptfile = argv[optind];
    }

    printf("scriptfile: %s\n", scriptfile);
    if (eval_scriptfile(scriptfile))
	exit(1);

    exit(0);
}


/*
 * Local Variables:
 * indent-tabs-mode:nil
 * c-basic-offset:4
 * End:
*/
