#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <ctype.h>

static uint8_t checksum;
static int infd, outfd;
static uint8_t buffer[65536];

static void output(const uint8_t *ptr, uint8_t len) {
  if (write(outfd, ptr, len) != len) {
    perror("write");
    exit(1);
  }
}

static void output_begin(uint8_t type, uint8_t len) {
  static uint8_t header[4] = { 0x55, 0x3C, 0x00, 0x00 };
  checksum = type + len;
  header[2] = type;
  header[3] = len;
  output(header, 4);
}

static void output_data(const uint8_t *ptr, uint8_t len) {
  output(ptr, len);
  while(len--)
    checksum += *ptr++;
}

static void output_checksum(void) {
  static uint8_t cs[2] = { 0x00, 0x55 };
  cs[0] = checksum;
  output(cs, 2);
}

static void output_preamble(void) {
  static const uint8_t pre[128] = {
    0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55,
    0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55,
    0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55,
    0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55,
    0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55,
    0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55,
    0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55,
    0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55,
    0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55,
    0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55,
    0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55,
    0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55,
    0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55,
    0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55,
    0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55,
    0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55
  };
  output(pre, 128);
}

static void header_block(const char *name, uint16_t load, uint16_t start) {
  static uint8_t nbuf[15] = {
    0,0,0,0,0,0,0,0,
    0x02, 0x00, 0x01,
    0,0,0,0
  };
  int i;

  output_begin(0, 15);
  memcpy(nbuf, "        ", 8);
  for (i = 0; i < 8 && name[i]; i++)
    nbuf[i] = toupper(name[i]);
  nbuf[11] = start >> 8;
  nbuf[12] = start & 0xFF;
  nbuf[13] = load >> 8;
  nbuf[14] = load & 0xFF;
  output_data(nbuf, 15);
  output_checksum();
}

static void data_block(uint8_t *ptr, uint8_t len) {
  output_begin(1, len);
  output_data(ptr, len);
  output_checksum();
}

static void end_block(void) {
  output_begin(0xFF, 0);
  output_checksum();
}

static void program_blocks(uint8_t *ptr, uint16_t len)
{
  uint16_t lv;
  
  while(len) {
    lv = len;
    if (lv > 255)
      lv = 255;
    data_block(ptr, lv);
    ptr += lv;
    len -= lv;
  }
}

static uint16_t check_addr(const char *p) {
  long v;

  errno = 0;
  v = strtol(p, NULL, 0);
  if (errno) {
    fprintf(stderr, "%s: not a valid address\n", p);
    exit(1);
  }
  if (v < 0 || v > 0xFFFF) {
    fprintf(stderr, "%s: out of range\n", p);
    exit(1);
  }
  return (uint16_t)v;
}

int main(int argc, const char *argv[]) {
  uint16_t load, start, wlen;
  int len;

  if (argc != 6) {
    fprintf(stderr, "%s: binary cassette load len start\n", argv[0]);
    exit(1);
  }
  
  load = check_addr(argv[3]);
  wlen = check_addr(argv[4]);
  start = check_addr(argv[5]);

  infd = open(argv[1], O_RDONLY, 0666);
  if (infd == -1) {
    perror(argv[1]);
    exit(1);
  }
  outfd = open(argv[2], O_WRONLY|O_CREAT|O_TRUNC, 0666);
  if (outfd == -1) {
    perror(argv[2]);
    exit(1);
  }
  len = read(infd, buffer, 65536);
  if (len < 0) {
    perror("read");
    exit(1);
  }
  if (len != 65536) {
    fprintf(stderr, "%s: not an as1 memory image\n", argv[1]);
    exit(1);
  }
  close(infd);
  output_preamble();
  header_block(argv[2], load, start);
  output_preamble();
  program_blocks(buffer + load, wlen);
  end_block();
  close(outfd);
  return 0;
}
