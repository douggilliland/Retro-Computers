/*
 * grab tt output from verilog simulator log file
 * brad@heeltoe.com
 *
 * as in, "cat verilog.log | ./ushow"
 *
 * displays tt output in a rational manner
 */

#include <stdio.h>
#include <string.h>

int c;
char b[1024*16];

int show_cummulative = 0;
int show_rx = 0;
int show_int = 0;

void show(void)
{
	printf("\n-------\noutput: %s\n", b);
	printf("\n");
	fflush(stdout);
}

void show_part(void)
{
	printf("%s", b);
	fflush(stdout);
	c = 0;
}

void add_int(void)
{
	b[c++] = '*';
	b[c] = 0;
	if (show_cummulative) {
		show_part();
	}
}

void add_rx(int v)
{
	v &= 0x7f;
	b[c++] = '[';
	if (v >= ' ')
		b[c++] = v;
	else {
		c += sprintf(&b[c], "\\%03o", v);
	}
	b[c++] = ']';
	b[c] = 0;
	if (show_cummulative) {
		show_part();
	}
}

void add(int v)
{
	v &= 0x7f;
	if (v == 0) v = '@';
	b[c++] = v;
	b[c] = 0;
	if (show_cummulative) {
		show_part();
	}
}

main(int argc, char *argv[])
{
	char line[1024];
	int i;

	for (i = 1; i < argc; i++) {
		if (argv[i][0] == '-')
			switch (argv[i][1]) {
			case 's': show_cummulative = 1; break;
			case 'r': show_rx = 1; break;
			case 'i': show_int = 1; break;
			}
	}

	while (fgets(line, sizeof(line), stdin)) {
		int v;

		if (memcmp(&line[4], "tx_data ", 8) == 0) {
			sscanf(line, "xxx tx_data %o", &v);
			add(v);
		}

#if 0
		if (memcmp(&line[4], "rx_data ", 8) == 0) {
			sscanf(line, "xxx rx_data %o", &v);
			if (show_rx)
				add_rx(v);
		}
#else
		if (memcmp(&line[4], "dispense ", 9) == 0) {
			sscanf(line, "xxx dispense %o", &v);
			if (show_rx)
				add_rx(v);
		}
#endif
		if (memcmp(&line[4], "interrupt", 9) == 0) {
			if (show_int)
				add_int();
		}


		if (memcmp(&line[4], "rx input ", 9) == 0) {
			sscanf(line, "xxx rx input %o", &v);
			if (show_rx)
				add_rx(v);
		}
		if (memcmp(&line[4], "int_req ", 8) == 0) {
			if (show_int)
				add_int();
		}
		if (memcmp(line, "reset on", 8) == 0) {
			c = 0;
			printf("\n");
		}
	}

	show();
}
