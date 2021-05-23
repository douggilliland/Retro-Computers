//  Created by Eric Pahl on 4/30/13.
//  Copyright (c) 2013 Oregon Institute of Technology. All rights reserved.
//  Modified by Tom Almy, March 2014

#include <stdio.h>


int v1,v2,v3,v4;
int ram[4096];
int addr;
int data;
int i;
FILE *infile, *outfile;

int main(int argc, char **argv)
{
	if (argc != 3) {
		fprintf(stderr, "Usage: rim2coe rimfile coefile\n where rimfile is input file in RIM format\n coefile is output file in COE format\n");
		return 1;
	}
	if ((infile = fopen(argv[1], "rb")) == NULL) {
		fprintf(stderr, "File %s not found\n", argv[1]);
		return 1;
	}
	if ((outfile = fopen(argv[2], "wb")) == NULL) {
		fprintf(stderr, "Cannot create %s\n", argv[2]);
		return 1;
	}
	v1 = fgetc(infile);
	while ((v1 & 0xc0) == 0x80) {
		v1 = fgetc(infile); /* keep reading until character is not leader */
	}

	while ((v1 & 0xc0) == 0x40) /* v1 is first byte of 4 */
	{ 
		v2 = fgetc(infile);
		v3 = fgetc(infile);
		v4 = fgetc(infile);
		addr = ((v1 & 0x3f) << 6) + v2;
		data = (v3 << 6) + v4;
		ram[addr] = data;
		v1 = fgetc(infile); /* get first byte of next 4 */
	}
// print to .coe file
	fprintf(outfile, "memory_initialization_radix = 10;\n");
	fprintf(outfile, "memory_initialization_vector =\n");
	for (i = 0; i < 4096; i++)
	{
		fprintf(outfile, "%d%c\n", ram[i], i==4095 ? ';' : ',');
	}
	return 0;
}
