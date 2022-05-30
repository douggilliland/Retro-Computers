/*
 * tss/8 rf08 disk maker
 * merge .bin files into existing rf08 disk image using script
 * brad@heeltoe.com 3/2010
 */

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string.h>

typedef unsigned short u12;

unsigned char binfile[16*1024];

u12 fields[7][4096];
char filled[7][4096];

#define RFSIZE (1024*1024)
u12 rf[RFSIZE];
int rf_size;
int rf_fd;
int clear_flag;
int patch_flag;
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


int field_patch(int field)
{
    switch (field) {
    case 0:
	fields[0][07600] = 0323; /* login message */
	fields[0][07601] = 0331;
	fields[0][07602] = 0323;
	fields[0][07603] = 0324;
	fields[0][07604] = 0305;
	fields[0][07605] = 0315;
	fields[0][07606] = 0240;
	fields[0][07607] = 0311;
	fields[0][07610] = 0323;
	fields[0][07611] = 0240;
	fields[0][07612] = 0304;
	fields[0][07613] = 0317;
	fields[0][07614] = 0327;
	fields[0][07615] = 0316;
	fields[0][07616] = 0254;
	fields[0][07617] = 0240;
	fields[0][07620] = 0311;
	fields[0][07621] = 0316;
	fields[0][07622] = 0303;
	fields[0][07623] = 0256;
	fields[0][07624] = 0215;
	fields[0][07625] = 0212;
	fields[0][07626] = 0215;
	fields[0][07627] = 0212;
	fields[0][07630] = 0000;
	fields[0][07631] = 0323;
	fields[0][07632] = 0310;
	fields[0][07633] = 0301;
	fields[0][07634] = 0322;
	fields[0][07635] = 0311;
	fields[0][07636] = 0316;
	fields[0][07637] = 0307;
	fields[0][07640] = 0000;
        break;
    case 2:
	fields[2][01403] = 6; /* CORFLD */
        break;
    }

    return 0;
}

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

int field_unsave(int field)
{
    int i, offset;

    printf("extracting field %d\n", field);

    offset = field * 4096;
    for (i = 0; i < 4096; i++) {
	fields[field][i] = rf[offset+i];
    }
}

int field_load(int dstfield, char *filename)
{
    int f, ch, o, binfile_size;
    int rubout, newfield, state, high, low, done;
    int word, csum, bad;
    u12 origin, field;

    f = open(filename, O_RDONLY);
    if (f < 0) {
	perror(filename);
	return -1;
    }

    binfile_size = read(f, binfile, sizeof(binfile));

    close(f);

    if (binfile_size < 0) {
	perror(filename);
	return -1;
    }

    printf("%s: field %d, %d bytes\n", filename, dstfield, binfile_size);

    done = 0;
    rubout = 0;
    state = 0;
    csum = 0;
    bad = 0;

    field = -1;
    newfield = dstfield;

    for (o = 0; o < binfile_size && !done; o++) {
	ch = binfile[o];

	if (rubout) {
	    rubout = 0;
	    continue;
	}

	if (ch == 0377) {
	    rubout = 1;
	    continue;
	}

	if (ch > 0200) {
	    newfield = (ch & 070) >> 3;
	    continue;
	}

	switch (state) {
	case 0:
	    /* leader */
	    if ((ch != 0) && (ch != 0200)) state = 1;
	    high = ch;
	    break;

	case 1:
	    /* low byte */
	    low = ch;
	    state = 2;
	    break;

	case 2:
	    /* high with test */
	    word = (high << 6) | low;
	    if (ch == 0200) {
		if ((csum - word) & 07777) {
		    printf("%s: checksum error\n", filename);
		    bad++;
		}
		done = 1;
		continue;
	    }
	    csum = csum + low + high;
	    if (word >= 010000) {
		origin = word & 07777;
	    } else {
		int ignore, allow;

		if (field > 7 || origin >= MEMSIZE) {
		    printf("%s: too big; field %o, origin %o\n", filename, field, origin);
		    bad++;
		}

		if (0) printf("mem[%o] = %o\n", field|origin, word&07777);

		ignore = 0;
		allow = 1;

		/* ignore RIM loader at start of init.pal */
		if (dstfield == 2 && field == 0) {
		    ignore = 1;
		    allow = 0;
		}

		/* allow ts8 to load fields 3 & 4 */
		if (dstfield == 3 && field == 4) {
		    ignore = 1;
		    allow = 1;
		}

		if (field != dstfield) {
		    if (!ignore) {
			printf("%s: field %d, addr %o; not in dest field %d\n",
			       filename, field, origin, dstfield);
			bad++;
		    }
		}

		if (allow) {
		    if (filled[field][origin]) {
			printf("%s: field %d, addr %o; duplicate (old %04o new %04o)\n",
			       filename, field, origin,
			       fields[field][origin], word & 07777);
		    }

		    fields[field][origin] = word & 07777;
		    filled[field][origin]++;
		}

		origin = (origin + 1) & 07777;
	    }
	    field = newfield;
	    high = ch;
	    state = 1;
	    break;
	}
    }

    return bad ? -1 : 0;
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

    if (strcmp(word1, "patch") == 0) {
        patch_flag++;
    }

    if (strcmp(word1, "field") == 0) {
	if (count < 3) {
	    fprintf(stderr, "missing field arg\n");
	    return -1;
	}
	fld = atoi(word2);
	if (fld < 0 || fld > 4) {
	    fprintf(stderr, "bad field number\n");
	    return -1;
	}

	field_load(fld, word3);
	if (patch_flag)
            field_patch(fld);
	field_save(fld);
	if (fld == 3)
	    field_save(4);

        return 0;
    }

    if (strcmp(word1, "dump") == 0) {
	if (count < 2) {
	    fprintf(stderr, "missing field arg\n");
	    return -1;
	}
	fld = atoi(word2);
	if (fld < 0 || fld > 4) {
	    fprintf(stderr, "bad field number\n");
	    return -1;
	}

	field_unsave(fld);
	field_dump(fld, word3);

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
