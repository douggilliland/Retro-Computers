
//=======================================================
//    Convert macro11 paper-tape-binary output file
//    to Intel hex format
//
//    copyright (c) Scott L Baker 2016
//=======================================================

#include <stdio.h>
#include <stdlib.h>

FILE *fp1;        // input file
FILE *fp2;        // output file

char *line, buffer[8192];
int  address = 0;
int  bcount  = 0;
int  gotta3  = 0;
int  lastrec = 0;

void convert(void);
int  bytecount(void);
int  getf(void);
void writeline (int);
void writelast ();
char hex (int);
void puthex (int, int);
void ferr (char *);
void where(void);

main (int argc, char *argv[]) {

  char *s;

  while(--argc) {
    s = *++argv;
    if(*s++ != '-')
      ferr("Expected '-' and an option");

    switch(*s++) {

    case 'i':    // input filename
      if(argc < 2)
        ferr("No input file");
      argc--;
      if((fp1 = fopen(*++argv, "rb")) == NULL)
        ferr("Cannot open input file");
      continue;

    case 'o':    // output filename
      if(argc < 2)
        ferr("No output file");
      argc--;
      if((fp2 = fopen(*++argv, "w")) == NULL)
        ferr("Cannot create output file");
      continue;

    default:
      ferr("Unknown option");
    }
  }

  convert();

  fclose(fp1);
  fclose(fp2);
  return 0;
}

// Get a record
void getrecord(void) {
  int  len;
  unsigned char ch;

  // expect a start char
  if(getf() != 1)
    ferr("Expected start char");

  // expect null char after start char
  if(getf() != 0)
    ferr("Expected null char after start char");

  len  = getf();
  len += getf()*16;

  // ignore non-data-type records
  if(ch = getf() != 3) {
    // fprintf (stderr, "Record type = %d  ", ch);  // debug
    // fprintf (stderr, "length = %d\n", len);      // debug
    if ((gotta3 == 1) && (len == 6)) {
      lastrec = 1;
    }
    while (len-- > 4) {
      ch = getf();
    }
  } else {
    // fprintf (stderr, "Record type = 3  ");       // debug
    // fprintf (stderr, "length = %d\n", len);      // debug
    gotta3 = 1;
    getf();  // skip
    getf();  // skip
    getf();  // skip
    while (len-- > 8) {
      ch = getf();
      // fprintf (stderr, "ch = %02x\n", ch);  // debug
      buffer[bcount++] = ch;
    }
    ch = getf();  // read and discard the checksum
  }
}

// Read the paper-tape-binary format data
// and output Intel Hex
void convert(void) {
  int i, j;

  // read the records and fill the buffer
  while (lastrec == 0) {
    getrecord();
  }

  // now process the buffer and output hex data
  line = buffer;

  if (bcount <= 16) {
    writeline (bcount);
  } else {
    i = bcount;
    j = 0;
    while (i > 16) {
      // fprintf (stderr, "Writing i= %d\n", i);     // debug
      writeline (16);
      i -= 16;
      j += 16;
      address += 16;
      line = &buffer[j];
    }
    if (i > 0) {
      // fprintf (stderr, "Writing i= %d\n", i);     // debug
      writeline (i);
    }
  }
  writelast();
}

// get the byte count of a file
int bytecount() {
  int x;
  fseek(fp1, 0L, SEEK_END);
  x = ftell(fp1);
  rewind(fp1);
  return x;
}

// read a character
int getf() {
  int ch;
  ch = fgetc(fp1);
  return ch;
}

// write a hex line
//
void writeline (int count) {
  int sum = 0;
  int i;
  char ch, h1, h2;

  sum += address >> 8;        // Checksum high address byte
  sum += address & 0xff;      // Checksum low address byte
  sum += count;               // Checksum record byte count
  putc (':', fp2);
  puthex (count, 2);          // Byte count
  puthex (address, 4);        // Do address and increment
  puthex (0, 2);              // Record type
  for (i=count; i; i--) {     // Then the actual data
    ch = *line++;
    sum += ch;                // Checksum each character
    puthex (ch, 2);
  }
  puthex (0 - sum, 2);        // Checksum is 1-byte 2's comp
  fprintf (fp2, "\n");
}

// write an end record
//
void writelast () {
  fprintf (fp2, ":00000001FF\n");
}

// return ASCII hex character for binary value
//
char hex (int ch) {
  if ((ch &= 0x000f) < 10)
    ch += '0';
  else
    ch += 'A' - 10;
  return ((char) ch);
}

// put the specified number of digits in ASCII hex
//
void puthex(int val, int digits) {
  char ch;
  if (--digits) puthex (val >> 4, digits);
  ch = hex (val & 0x0f);
  putc (ch, fp2);
}

// handle a fatal error
void ferr(char *text) {
  fprintf(stderr, text);
  where();
  exit(1);
}

// output the character position
void where() {
  long position;
  if(fp1 && (position = ftell(fp1)) != -1)
    fprintf(stderr, " at character position %ld\n", position);
  else
    fprintf(stderr, "\n");
}

