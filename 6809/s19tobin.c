#include <u.h>
#include <libc.h>
#include <bio.h>

int procs1(char *, int *, uchar *);

void
usage(void)
{
	sysfatal("usage: s19tobin base file\n");
}

void
main(int argc, char *argv[])
{
	Biobuf *bp;
	char *line, *p;
	int addr, base;
	int n, fd;
	uchar buf[256];

	ARGBEGIN {
	default:
		usage();
	} ARGEND
	if(argc != 2)
		usage();
	base = strtol(argv[0], nil, 16);
	bp = Bopen(argv[1], OREAD);
	if(bp == nil)
		sysfatal("s19tobin: %r\n");
	p = strchr(argv[1], '.');
	if(p)
		*p = 0;
	fd = create(argv[1], OWRITE, 0664);
	if(fd < 0)
		sysfatal("s19tobin: %r\n");
	while(line = Brdstr(bp, '\n', 1)) {
		if(line[0] != 'S')
			sysfatal("bad s19 line: %s\n", line);
		switch(line[1]) {
		case '0':
			fprint(2, "S0 record: %s\n", line+2);
			break;
		case '1':
			n = procs1(line, &addr, buf);
			seek(fd, addr - base, 0);
			write(fd, buf, n);
			break;
		case '9':
			procs1(line, &addr, buf);
			fprint(2, "S9 record: %04ux\n", addr);
			break;
		default:
			sysfatal("unknown S record: %s\n", line);
		}
		free(line);
	}
}

int
gethex2(char *p)
{
	char buf[3];

	buf[0] = p[0];
	buf[1] = p[1];
	buf[2] = 0;
	return strtol(buf, nil, 16);
}

int
gethex4(char *p)
{
	char buf[5];

	buf[0] = p[0];
	buf[1] = p[1];
	buf[2] = p[2];
	buf[3] = p[3];
	buf[4] = 0;
	return strtol(buf, nil, 16);
}

int
procs1(char *line, int *addr, uchar *buf)
{
	char *p;
	int len;
	int i;

	p = line + 2;
	len = gethex2(p) - 3;
	p += 2;
	*addr = gethex4(p);
	p += 4;
	for(i = 0; i < len; ++i) {
		buf[i] = gethex2(p);
		p += 2;
	}
	return len;
}
