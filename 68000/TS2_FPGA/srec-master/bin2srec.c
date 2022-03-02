/*
 * bin2srec.c: Read binary data, write Motorola SREC.
 *
 * By default reads from stdin and writes to stdout. The command-line
 * options `-i` and `-o` can be used to specify the input and output
 * file, respectively.
 *
 * Copyright (c) 2015 Kimmo Kulovesi, http://arkku.com
 * Provided with absolutely no warranty, use at your own risk only.
 * Distribute freely, mark modified copies as such.
 */

#include "kk_srec.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#define HEX_DIGIT(n) ((char)((n) + (((n) < 10) ? '0' : ('A' - 10))))

#if SREC_LINE_MAX_BYTE_COUNT >= 37
#define PAYLOAD_PER_LINE 32
#else
#define PAYLOAD_PER_LINE (SREC_LINE_MAX_BYTE_COUNT - 5)
#endif
#define MAX_HEADER_LENGTH (PAYLOAD_PER_LINE - 1)

// Write a byte as hex
static void
write_byte (const uint8_t byte, FILE * restrict outfile) {
    uint8_t n = (byte & 0xF0U) >> 4; // high nybble
    (void) fputc(HEX_DIGIT(n), outfile);
    n = byte & 0x0FU; // low nybble
    (void) fputc(HEX_DIGIT(n), outfile);
}

// Write a word of `word_size` bytes as hex, return the sum of bytes written 
static int
write_word (srec_address_t word, uint8_t word_size, FILE * restrict outfile) {
    const uint8_t b = word & 0xFF;
    int sum = b;
    if (--word_size) {
        sum += write_word(word >> 8, word_size, outfile);
    }
    write_byte(b, outfile);
    return sum;
}

// Write a string of length `len` as hex, return the sum of bytes written
static int
write_string (const char * restrict str, uint8_t len, FILE * restrict outfile) {
    int sum = 0;
    while (len--) {
        write_byte(*((const unsigned char *)str), outfile);
        sum += *str++;
    }
    return sum;
}

int
main (int argc, char *argv[]) {
    const char *header_text = NULL;
    FILE *infile = stdin;
    FILE *outfile;
    srec_address_t number_of_records = 0;
    srec_address_t address = 0;
    srec_address_t execution_start_address = 0;
    uint_fast8_t address_bytes = 0;
    uint_fast8_t count;
    uint8_t sum;
    srec_bool_t debug_enabled = 0;
    uint8_t buf[PAYLOAD_PER_LINE];

    outfile = stdout;

    while (--argc) {
        char *arg = *(++argv);
        if (arg[0] == '-' && arg[1] && arg[2] == '\0') {
            switch (arg[1]) {
            case 'b':   // number of bytes in address
            case 'a':   // address offset
            case 'x':   // execution start address
                if (--argc == 0) {
                    goto invalid_argument;
                }
                ++argv;
                errno = 0;
                {
                    char *eptr;
                    srec_address_t a = (srec_address_t) strtol(*argv, &eptr, 0);
                    if (errno || eptr == *argv) {
                        errno = errno ? errno : EINVAL;
                        goto argument_error;
                    }
                    if (arg[1] == 'a') {
                        address = a;
                    } else if (arg[1] == 'x') {
                        execution_start_address = a;
                    } else if (a >= 2 && a <= 4) {
                        address_bytes = (uint_fast8_t) a;
                    } else if (a == 16) {
                        address_bytes = 2;
                    } else if (a == 24) {
                        address_bytes = 3;
                    } else if (a == 32) {
                        address_bytes = 4;
                    } else {
                        goto invalid_argument;
                    }
                }
                break;
            case 'h':   // header text
                if (--argc == 0) {
                    goto invalid_argument;
                }
                header_text = *(++argv);
                break;
            case 'i':   // input file
                if (--argc == 0) {
                    goto invalid_argument;
                }
                ++argv;
                if (!(infile = fopen(*argv, "rb"))) {
                    goto argument_error;
                }
                if (!header_text) {
                    header_text = *argv;
                }
                break;
            case 'o':   // output file
                if (--argc == 0) {
                    goto invalid_argument;
                }
                ++argv;
                if (!(outfile = fopen(*argv, "w"))) {
                    goto argument_error;
                }
                break;
            case 'v':   // verbose
                debug_enabled = 1;
                break;
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
        (void) fprintf(stderr,
    "Usage: bin2srec [-a <address_offset>] [-o <out.bin>] [-i <in.srec>]\n"
    "                [-b <bytes_in_address>] [-x <exec_start_address>]\n"
    "                [-h <header_text>] [-v]\n"
    );
        return arg ? EXIT_FAILURE : EXIT_SUCCESS;
argument_error:
        perror(*argv);
        return EXIT_FAILURE;
    }

    if (!address_bytes) {
        if (fseek(infile, 0L, SEEK_END) == 0) {
            const long file_end = ftell(infile) + address;
            if (file_end >= 0) {
                if (file_end <= 0xFFFFL) {
                    address_bytes = 2;
                } else if (file_end <= 0xFFFFFFL) {
                    address_bytes = 3;
                } else {
                    address_bytes = 4;
                }
                if (debug_enabled) {
                    (void) fprintf(stderr, "Using %u-byte addresses.\n",
                                   address_bytes);
                }
            } else {
                goto no_address_length;
            }
        } else {
            if (debug_enabled) {
                perror("fseek");
            }
no_address_length:
            (void) fprintf(stderr, "Warning: Could not determine input size "
                                   "and no address length (-b) given.\n");
            address_bytes = 4;
        }
        rewind(infile);
    }

    // Header
    header_text = header_text ? header_text : "";
    {
        size_t len = strlen(header_text);
        if (len > MAX_HEADER_LENGTH) {
            (void) fprintf(stderr, "Warning: Header text too long "
                                   "(max. %u characters)!\n", MAX_HEADER_LENGTH);
            len = MAX_HEADER_LENGTH;
        }
        sum = (uint8_t) (len + 1 + 2 + 1);
        (void) fprintf(outfile, "S0%02x0000", sum);
        sum += write_string(header_text, (uint8_t) len, outfile);
        write_byte('\0', outfile);
        write_byte(~sum, outfile);
        if (debug_enabled && len) {
            (void) fprintf(stderr, "Wrote header: %.*s\n",
                           (int) len, header_text);
        }
    }

    // Payload
    while ((count = (uint_fast8_t) fread(buf, 1, sizeof(buf), infile))) {
        uint_fast8_t i;

        sum = (uint8_t) count + address_bytes + 1;
        (void) fprintf(outfile, "\nS%u%02x", address_bytes - 1, sum);
        sum += write_word(address, address_bytes, outfile);
        for (i = 0; i < count; ++i) {
            write_byte(buf[i], outfile);
            sum += buf[i];
        }
        write_byte(~sum, outfile);
        address += count;
        ++number_of_records;
    }

    // Number of records
    sum = (number_of_records <= 0xFFFFUL) ? 3 : 4;
    (void) fprintf(outfile, "\nS%x%02x", sum + 2, sum);
    sum += write_word(number_of_records, sum - 1, outfile);
    write_byte(~sum, outfile);
    sum = address_bytes + 1;

    // Execution start address + termination
    (void) fprintf(outfile, "\nS%x%02x", 11 - address_bytes, sum);
    sum += write_word(execution_start_address, address_bytes, outfile);
    write_byte(~sum, outfile);
    if (fputc('\n', outfile) == EOF) {
        perror("Output");
        return EXIT_FAILURE;
    }

    if (debug_enabled) {
        (void) fprintf(stderr, "Wrote %lu records\n",
                       (unsigned long) number_of_records);
    }
    if (infile != stdin) {
        (void) fclose(infile);
    }
    if (outfile != stdout) {
        (void) fclose(outfile);
    }

    return EXIT_SUCCESS;
}
