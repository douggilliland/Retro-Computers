#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>

/*
 *	Turn a binary block into a Flex .BIN file. Optionally add an execute
 *	address marker. Written to work as a filter as we may eventually hook
 *	it into the tool chain.
 *
 *	See the FLEX Advanced Programmer's Guide.
 */

void usage(void) {
    fprintf(stderr, "binify [-s start] [-l length] [-x execaddr] [-o offset]  binary binary.bin.\n");
    exit(1);
}

int main(int argc, char *argv[]) {
    uint16_t start = 0x0100, len = 0x2000, offset = 0;
    uint16_t exec = 0;
    int pos = 0;
    int setexec = 0;
    FILE *in, *out;
    int i;
    
    int opt;
    
    while((opt = getopt(argc, argv, "s:l:x:o:")) != -1) {
        switch(opt) {
        case 's':
            start = atoi(optarg);
            break;
        case 'l':
            len = atoi(optarg);
            break;
        case 'x':
            exec = atoi(optarg);
            setexec = 1;
            break;
        case 'o':
            offset = atoi(optarg);
            break;
        default:
            usage();
        }
    }
    if (optind + 2 != argc) {
        usage();
    }
    if (offset > start) {
        fprintf(stderr, "binify: offset cannot exceed start.\n");
        exit(1);
    }
    in = fopen(argv[optind], "r");
    if (in == NULL) {
        perror(argv[optind]);
        return 1;
    }
    out = fopen(argv[optind+1], "w");
    if (out == NULL ) {
        perror(argv[optind+1]);
        return 1;
    }

    /* Read through all the bytes before the block we want */
    while(pos < start - offset) {
        fgetc(in);
        pos++;
    }
    while(len >= 255) {
        fputc(0x02, out);		/* Block marker */
        fputc(start >> 8, out);		/* 255 byte block at working address */
        fputc(start, out);
        fputc(255, out);
        for(i = 0; i < 255; i++)
            fputc(fgetc(in), out);
        len -= 255;
        start += 255;
    }
    if (len) {
        fputc(0x02, out);
        fputc(start >> 8, out);
        fputc(start, out);
        fputc(len, out);
        while(len--)
            fputc(fgetc(in), out);
    }

    if (feof(in)) {
        fprintf(stderr, "binify: source too short.\n");
        exit(1);
    }
    fclose(in);

    if (setexec) {
        fputc(0x16, out);
        fputc(exec >> 8, out);
        fputc(exec, out);
    }
    if (fclose(out) == -1) {
        perror(argv[optind+1]);
        return 1;
    }
    return 0;
}
