/*
 * remove comment + ^Z from paper tape files
 * brad@heeltoe.com
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>

size_t binfile_size;

unsigned char binfile[64*1024];

main(int argc, char *argv[])
{
    if (argc > 1) {
	    int f, ret;
	    char ch;

	    f = open(argv[1], O_RDONLY);
	    if (f < 0) {
		    perror(argv[1]);
		    return -1;
	    }

	    while (1) {
		    ret = read(f, &ch, 1);
		    if (ret != 1)
			    return -1;
		    if (ch == 'Z'-'@')
			    break;
	    }

	    binfile_size = read(f, binfile, sizeof(binfile));
	    ret = write(1, binfile, binfile_size);
	    close(f);
    }

    exit(0);
}


/*
 * Local Variables:
 * indent-tabs-mode:nil
 * c-basic-offset:4
 * End:
*/
