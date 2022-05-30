/*
 * dump pdp-8 "bin" format files
 * brad@heeltoe.com
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>

typedef unsigned char u8;
typedef unsigned short u12;

size_t binfile_size;

#define MEMSIZE (32*1024)
u12 mem[MEMSIZE];

u8 binfile[16*1024];

int loadbin(char *fn, int skipz)
{
    int f, ch, o;
    int rubout, newfield, state, high, low, done;
    int word, csum;
    u12 origin, field;

    f = open(fn, O_RDONLY);
    if (f < 0) {
	perror(fn);
	return -1;
    }

    if (skipz) {
        char ch;
        while (1) {
            int ret;
            ret = read(f, &ch, 1);
            if (ret != 1)
                return -1;
            if (ch == 'Z'-'@')
                break;
        }
    }

    binfile_size = read(f, binfile, sizeof(binfile));

    if (0) printf("loadbin: %d bytes\n", binfile_size);

    done = 0;
    rubout = 0;
    state = 0;
    field = 0;
    origin = 0;
    csum = 0;
    newfield = 0;

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
	    newfield = (ch & 070) << 9;
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
		    printf("loadbin: checksum error\n");
		}
		done = 1;
		continue;
	    }
	    csum = csum + low + high;
	    if (word >= 010000) {
		origin = word & 07777;
	    } else {
		if ((field | origin) >= MEMSIZE) {
		    printf("loadbin: too big\n");
		}

		if (0) printf("mem[%o] = %o\n", field|origin, word&07777);
		if (1) printf("%05o %04o\n", field|origin, word&07777);

		mem[field | origin] = word & 07777;
		origin = (origin + 1) & 07777;
	    }
	    field = newfield;
	    high = ch;
	    state = 1;
	    break;
	}
    }

    close(f);
    return 0;
}

main(int argc, char *argv[])
{
    int skipz = 0;

    if (argc > 2 && strcmp(argv[1], "-z") == 0) {
        skipz = 1;
        argc--;
        argv++;
    }

    if (argc > 1) {
        if (loadbin(argv[1], skipz))
            exit(1);
    }

    exit(0);
}


/*
 * Local Variables:
 * indent-tabs-mode:nil
 * c-basic-offset:4
 * End:
*/
