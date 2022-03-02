/*
 * srec2bin.c: Read Motorola SREC format, write binary data.
 *
 * By default reads from stdin and writes to stdout. The command-line
 * options `-i` and `-o` can be used to specify the input and output
 * file, respectively. Specifying an output file allows sparse writes.
 *
 * NOTE: Many SREC files produced by compilers/etc have data beginning
 * at an address greater than zero, potentially causing initial padding
 * in the output (up to gigabytes of unnecessary length). The command-line
 * option `-a` can be used to specify an offset, i.e., the value will be
 * subtracted from the SREC addresses (the result must not be negative).
 *
 * Alternatively, the command-line option `-A` sets the address offset
 * to the first address that would be written (i.e., first byte of
 * data written will be at address 0).
 *
 * Copyright (c) 2015 Kimmo Kulovesi, http://arkku.com
 * Provided with absolutely no warranty, use at your own risk only.
 * Distribute freely, mark modified copies as such.
 */

#include "kk_srec.h"

#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#define AUTODETECT_ADDRESS (~(srec_address_t)0)

static FILE *outfile;
static unsigned long line_number = 1UL;
static srec_address_t file_position = 0L;
static srec_address_t address_offset = 0;
static bool debug_enabled = 0;

int
main (int argc, char *argv[]) {
    struct srec_state srec;
    FILE *infile = stdin;
    srec_count_t count;
    char buf[256];

    outfile = stdout;

    while (--argc) {
        char *arg = *(++argv);
        if (arg[0] == '-' && arg[1] && arg[2] == '\0') {
            switch (arg[1]) {
            case 'a':
                if (--argc == 0) {
                    goto invalid_argument;
                }
                ++argv;
                errno = 0;
                address_offset = (srec_address_t) strtol(*argv, &arg, 0);
                if (errno || arg == *argv) {
                    errno = errno ? errno : EINVAL;
                    goto argument_error;
                }
                break;
            case 'A':
                address_offset = AUTODETECT_ADDRESS;
                break;
            case 'i':
                if (--argc == 0) {
                    goto invalid_argument;
                }
                ++argv;
                if (!(infile = fopen(*argv, "r"))) {
                    goto argument_error;
                }
                break;
            case 'o':
                if (--argc == 0) {
                    goto invalid_argument;
                }
                ++argv;
                if (!(outfile = fopen(*argv, "wb"))) {
                    goto argument_error;
                }
                break;
            case 'v':
                debug_enabled = 1;
                break;
            case 'h':
            case '?':
                arg = NULL;
                goto usage;
            default:
                goto invalid_argument;
            }
            continue;
        }
invalid_argument:
        (void) fprintf(stderr, "Invalid argument: %s\n", arg);
usage:
        (void) fprintf(stderr, "kk_srec " KK_SREC_VERSION
                               " - Copyright (c) 2015 Kimmo Kulovesi\n");
        (void) fprintf(stderr, "Usage: srec2bin ([-a <address_offset>]|[-A])"
                                " [-o <out.bin>] [-i <in.srec>] [-v]\n");
        return arg ? EXIT_FAILURE : EXIT_SUCCESS;
argument_error:
        perror(*argv);
        return EXIT_FAILURE;
    }

    srec_begin_read(&srec);

    while (fgets(buf, sizeof(buf), infile)) {
        count = (srec_count_t) strlen(buf);
        srec_read_bytes(&srec, buf, count);
        line_number += (count && buf[count - 1] == '\n');
    }
    srec_end_read(&srec);

    if (infile != stdin) {
        (void) fclose(infile);
    }

    return EXIT_SUCCESS;
}

void
srec_data_read(struct srec_state *srec,
               srec_record_number_t record_type,
               srec_address_t address,
               uint8_t *data, srec_count_t length,
               srec_bool_t error) {
    if (srec->length != srec->byte_count) {
        if (srec->byte_count > SREC_LINE_MAX_BYTE_COUNT) {
            (void) fprintf(stderr, "Error: Byte count too high on line %lu\n",
                           line_number);
        } else {
            (void) fprintf(stderr, "Error: Byte count mismatch on line %lu\n",
                           line_number);
        }
        exit(EXIT_FAILURE);
    }
    if (error) {
        (void) fprintf(stderr, "Error: Checksum mismatch on line %lu\n",
                       line_number);
        exit(EXIT_FAILURE);
    }
    if (SREC_IS_DATA(record_type)) {
        if (!outfile) {
            (void) fprintf(stderr, "Error: Excess data after termination\n");
            exit(EXIT_FAILURE);
        }
        if (address < address_offset) {
            if (address_offset == AUTODETECT_ADDRESS) {
                // autodetect initial address
                address_offset = address;
                if (debug_enabled) {
                    (void) fprintf(stderr, "Address offset: 0x%lx\n",
                                    (unsigned long) address_offset);
                }
            } else {
                (void) fprintf(stderr, "Address underflow on line %lu\n",
                        line_number);
                exit(EXIT_FAILURE);
            }
        }
        address -= address_offset;
        if (address != file_position) {
            if (debug_enabled) {
                (void) fprintf(stderr,
                        "Seeking from 0x%lx to 0x%lx on line %lu\n",
                        (unsigned long) file_position,
                        (unsigned long) address,
                        line_number);
            }
            if (outfile == stdout || fseek(outfile, (long) address, SEEK_SET)) {
                if (file_position < address) {
                    // "seek" forward in stdout by writing NUL bytes
                    do {
                        (void) fputc('\0', outfile);
                    } while (++file_position < address);
                } else {
                    perror("fseek");
                    exit(EXIT_FAILURE);
                }
            }
            file_position = address;
        }
        if (!fwrite(data, (size_t) length, 1, outfile)) {
            perror("fwrite");
            exit(EXIT_FAILURE);
        }
        file_position += (srec_address_t) length;
    } else if (SREC_IS_TERMINATION(record_type)) {
        if (address || debug_enabled) {
            (void) fprintf(stderr, "Program start address: 0x%0*lx\n",
                           SREC_ADDRESS_BYTE_COUNT(record_type) * 2,
                           (unsigned long) address);
        }
        if (debug_enabled) {
            (void) fprintf(stderr, "%lu bytes written\n",
                           (unsigned long) file_position);
        }
        if (outfile != stdout) {
            (void) fclose(outfile);
        }
        outfile = NULL;
    } else if (record_type == 0) {
        // Print the header record unless it contains control characters
        srec_bool_t is_printable = 1;
        srec_count_t i;
        for (i = 0; i < length && data[i]; ++i) {
            if (iscntrl(data[i])) {
                is_printable = 0;
                break;
            }
        }
        if (is_printable) {
            data[length] = '\0';
            (void) fprintf(stderr, "Header on line %lu: %s\n",
                           line_number, data);
        }
    }
}
