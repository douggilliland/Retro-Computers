kk_srec
=======

A small library for reading the
[Motorola S-Record](http://en.wikipedia.org/wiki/SREC_(file_format))
(or SREC) format. The library is mainly intended for embedded systems and microcontrollers, such as Arduino, AVR, PIC, ARM, STM32, etc - hence the
emphasis is on small size rather than features, generality, or error handling.

Also included is a program to convert binary files to SREC format - this
is not part of the library since writing the format is fairly trivial and
thus perhaps better hardcoded into embedded applications with the correct
settings (number of address bytes, etc).

See the header file `kk_srec.h` for documentation, or below for simple examples.

~ [Kimmo Kulovesi](http://arkku.com/), 2015-03-06

Reading
=======

Basic usage for reading ASCII SREC into binary data:

    #include "kk_srec.h"
     
    struct srec_state srec;
    srec_begin_read(&srec);
    srec_read_bytes(&srec, my_ascii_bytes, my_ascii_length);
    srec_end_read(&srec);

The function `srec_read_bytes` may be called multiple times to pass any
amount of data at a time (including partial lines, or even individual bytes).

The reading functions call the function `srec_data_read`, which must be
implemented by the caller to store the binary data, e.g., as follows:

    void srec_data_read (struct srec_state *srec,
                         srec_record_number_t record_type,
                         srec_address_t address,
                         uint8_t *data, srec_count_t length,
                         srec_bool_t checksum_error) {
        if (checksum_error || srec->length != srec->byte_count) {
            // error in input data
        } else if (SREC_IS_DATA(record_type)) {
            (void) fseek(outfile, address, SEEK_SET);
            (void) fwrite(data, 1, length, outfile);
        } else if (SREC_IS_TERMINATION(record_type)) {
            (void) fclose(outfile);
        }
    }

Of course an actual implementation is free to do with the data as it chooses,
e.g., burn it on an EEPROM instead of writing it to a file.

For an example complete with error handling, see the included program
`srec2bin.c`.


Example Program
===============

The included example program, `srec2bin`, implements a very simple conversion
from SREC to binary data. Usage by example:

    # Simple conversion from SREC to binary:
    srec2bin <infile.srec -o outfile.bin

    # Manually specify the initial address written (i.e., subtract
    # an offset from the input addresses):
    srec2bin -a 0x8000000 -i infile.srec -o outfile.bin

    # Start output at the first data byte (i.e., make the address offset
    # equal to the address of the first data byte read from input):
    srec2bin -A -i infile.srec -o outfile.bin

The other program, `bin2srec`, converts arbitrary binary files to SREC.
Usage by example:

    # Simple conversion from binary to SREC (use the least amount of
    # address bytes necessary):
    bin2srec -i infile.bin -o outfile.srec

    # Add an offset to the addresses, and specify execution start address:
    bin2srec -a 0x8000 -x 0x2000 -i infile.bin -o outfile.srec

    # Manually specify the number of address bytes (4 bytes = 32 bits):
    bin2srec -b 4 -i infile.bin -o outfile.srec

Both programs also accept the option `-v` to increase verbosity.

When using `srec2bin` on SREC files produced by compilers and such,
it is a good idea to specify the command-line option `-A` to autodetect
the address offset. Otherwise the program will simply fill any unused
addresses, starting from 0, with zero bytes, which may total mega- or
even gigabytes.

