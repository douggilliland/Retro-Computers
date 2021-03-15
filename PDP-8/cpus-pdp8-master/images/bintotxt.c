#include <stdio.h>

#define MEMSIZE 32*1024
int M[32*1024];

main()
{
	int i;
	int rubout, newf, state, high, low, word, csum;
	int field, origin;

	rubout = 0;
	newf = 0;
	state = 0;
	csum = 0;

	while ((i = getchar()) != EOF) {		/* BIN format */
		if (rubout) {
			rubout = 0;
			continue;  }
		if (i == 0377) {
			rubout = 1;
			continue;  }
		if (i > 0200) {
			newf = (i & 070) << 9;
			continue;  }
		switch (state) {
		case 0:					/* leader */
			if ((i != 0) && (i != 0200)) state = 1;
			high = i;			/* save as high */
			break;
		case 1:					/* low byte */
			low = i;
			state = 2;
			break;
		case 2:					/* high with test */
			word = (high << 6) | low;
			if (i == 0200) {		/* end of tape? */
				if ((csum - word) & 07777) {
					printf("checksum bad\n");
					goto done;
				}

				printf("checksum ok\n");
				goto done;
			}
			csum = csum + low + high;
			if (word >= 010000) origin = word & 07777;
			else {
				if ((field | origin) >= MEMSIZE) {
					printf("SCPE_NXM\n");
				}

				M[field | origin] = word & 07777;
				printf("ram[12'o%o] = 12'o%o;\n", 
				       field | origin, word & 07777);

				origin = (origin + 1) & 07777;
			}
			field = newf;
			high = i;
			state = 1;
			break;
		}					/* end switch */
	}						/* end while */

 done:
	exit(0);
}
