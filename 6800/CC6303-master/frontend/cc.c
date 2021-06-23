#define DEBUG
/*
 *	It's easiest to think of what cc does as a sequence of four
 *	conversions. Each conversion produces the inputs to the next step
 *	and the number of types is reduced. If the step is the final
 *	step for the conversion then the file is generated with the expected
 *	name but if it will be consumed by a later stage it is a temporary
 *	scratch file.
 *
 *	Stage 1: (-c -o overrides object name)
 *
 *	Ending			Action
 *	$1.S			preprocessor - may make $1.s
 *	$1.s			nothing
 *	$1.c			preprocessor, no-op or /dev/tty
 *	$1.o			nothing
 *	$1.a			nothing (library)
 *
 *	Stage 2: (not -E)
 *
 *	Ending			Action
 *	$1.s			nothing
 *	$1.%			cc, opt - make $1.s
 *	$1.o			nothing
 *	$1.a			nothing (library)
 *
 *	Stage 3: (not -E or -S)
 *
 *	Ending			Action
 *	$1.s			assembler - makes $1.o
 *	$1.o			nothing
 *	$1.a			nothing (library)
 *
 *	Stage 4: (run if no -c -E -S)
 *
 *	ld [each .o|.a in order] [each -l lib in order] -lc
 *	(with -b -o $1 etc)
 *
 *	TODO:
 *
 *	Platform specifics
 *	Search library paths for libraries (or pass to ld and make ld do it)
 *	Turn on temp removal once confident
 *	Split I/D
 */

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>

#define CMD_AS		BINPATH"as68"
#define CMD_CC		LIBPATH"cc68"
#define CMD_COPT 	LIBPATH"copt"
#define COPT_FILE 	LIBPATH"cc68.rules"
#define COPT00_FILE 	LIBPATH"cc68-00.rules"
#define CMD_LD		BINPATH"ld68"
#define CRT0		LIBPATH"crt0.o"
#define LIBC		LIBPATH"libc.a"
#define LIB6800		LIBPATH"lib6800.a"
#define LIB6803		LIBPATH"lib6803.a"
#define LIB6303		LIBPATH"lib6303.a"
#define LIBIO6800	LIBPATH"libio6800.a"
#define LIBIO6803	LIBPATH"libio6803.a"
#define LIBMC10 	LIBPATH"libmc10.a"
#define LIBFLEX 	LIBPATH"libflex.a"
#define CMD_TAPEIFY 	LIBPATH"mc10-tapeify"
#define CMD_BINIFY 	LIBPATH"flex-binify"

struct obj {
	struct obj *next;
	char *name;
	uint8_t type;
#define TYPE_S			1
#define TYPE_C			2
#define TYPE_s			3
#define TYPE_C_pp		4
#define TYPE_O			5
#define TYPE_A			6
	uint8_t used;
};

struct objhead {
	struct obj *head;
	struct obj *tail;
};

struct objhead objlist;
struct objhead liblist;
struct objhead inclist;
struct objhead deflist;
struct objhead libpathlist;
struct objhead ccargs;		/* Arguments to pass on to the compiler */

int keep_temp;
int last_phase = 4;
int only_one_input;
char *target;
int strip;
int c_files;
int standalone;
int cpu = 6303;
int mapfile;
int targetos;
#define OS_NONE		0
#define OS_FUZIX	1
#define OS_MC10		2
#define OS_FLEX		3

#define MAXARG	64

int arginfd, argoutfd;
char *arglist[MAXARG];
char **argptr;
char *rmlist[MAXARG];
char **rmptr = rmlist;

static void remove_temporaries(void)
{
	char **p = rmlist;
	while (p < rmptr) {
		if (keep_temp == 0)
			unlink(*p);
		free(*p++);
	}
	rmptr = rmlist;
}

static void fatal(void)
{
	remove_temporaries();
	exit(1);
}

static void memory(void)
{
	fprintf(stderr, "cc: out of memory.\n");
	fatal();
}

static char *xstrdup(char *p, int extra)
{
	char *n = malloc(strlen(p) + extra + 1);
	if (n == NULL)
		memory();
	strcpy(n, p);
	return n;
}

static char *extend(char *p, char *e)
{
	char *n = xstrdup(p, strlen(e));
	strcat(n, e);
	return n;
}

static off_t filesize(char *path)
{
	struct stat st;
	if (stat(path, &st) < 0)
		return -1;
	return st.st_size;
}

static void append_obj(struct objhead *h, char *p, uint8_t type)
{
	struct obj *o = malloc(sizeof(struct obj));
	if (o == NULL)
		memory();
	o->name = p;
	o->next = NULL;
	o->used = 0;
	o->type = type;
	if (h->tail)
		h->tail->next = o;
	else
		h->head = o;
	h->tail = o;
}

static char *pathmod(char *p, char *f, char *t, int rmif)
{
	char *x = strrchr(p, '.');
	if (x == NULL) {
		fprintf(stderr, "cc: no extension on '%s'.\n", p);
		fatal();
	}
//	if (strcmp(x, f)) {
//		fprintf(stderr, "cc: internal got '%s' expected '%s'.\n",
//			p, t);
//		fatal();
//	}
	strcpy(x, t);
	if (last_phase > rmif) {
		*rmptr++ = xstrdup(p, 0);
	}
	return p;
}

static void add_argument(char *p)
{
	if (argptr == &arglist[MAXARG]) {
		fprintf(stderr, "cc: too many arguments to command.\n");
		fatal();
	}
	*argptr++ = p;
}

static void add_int_argument(int n)
{
	char buf[16];
	snprintf(buf, 16, "%d", n);
	return add_argument(xstrdup(buf, 0));
}

static void add_argument_list(char *header, struct objhead *h)
{
	struct obj *i = h->head;
	while (i) {
		if (header)
			add_argument(header);
		add_argument(i->name);
		i->used = 1;
		i = i->next;
	}
}

static char *resolve_library(char *p)
{
	static char buf[512];
	struct obj *o = libpathlist.head;
	if (strchr(p, '/') || strchr(p, '.'))
		return p;
	while(o) {
		snprintf(buf, 512, "%s/lib%s.a", o->name, p);
		if (access(buf, 0) == 0)
			return buf;
		o = o->next;
	}
	return NULL;
}

/* This turns -L/opt/cc68/lib  -lfoo -lbar into resolved names like
   /opt/cc68/lib/libfoo.a */
static void resolve_libraries(void)
{
	struct obj *o = liblist.head;
	while(o != NULL) {
		char *p = resolve_library(o->name);
		if (p == NULL) {
			fprintf(stderr, "cc: unable to find library '%s'.\n", o->name);
			exit(1);
		}
		add_argument(p);
		o = o->next;
	}
}

static void run_command(void)
{
	pid_t pid, p;
	int status;

	fflush(stdout);

	*argptr = NULL;

	pid = fork();
	if (pid == -1) {
		perror("fork");
		fatal();
	}
	if (pid == 0) {
#ifdef DEBUG
		{
			char **p = arglist;
			printf("[");
			while(*p)
				printf("%s ", *p++);
			printf("]\n");
		}
#endif
		fflush(stdout);
		if (arginfd != -1) {
			dup2(arginfd, 0);
			close(arginfd);
		}
		if (argoutfd != -1) {
			dup2(argoutfd, 1);
			close(argoutfd);
		}
		execv(arglist[0], arglist);
		perror("execv");
		exit(255);
	}
	if (arginfd)
		close(arginfd);
	if (argoutfd)
		close(argoutfd);
	while ((p = waitpid(pid, &status, 0)) != pid) {
		if (p == -1) {
			perror("waitpid");
			fatal();
		}
	}
	if (WIFSIGNALED(status) || WEXITSTATUS(status)) {
		printf("cc: %s failed.\n", arglist[0]);
		fatal();
	}
}

static void redirect_in(const char *p)
{
	arginfd = open(p, O_RDONLY);
	if (arginfd == -1) {
		perror(p);
		fatal();
	}
}

static void redirect_out(const char *p)
{
	argoutfd = open(p, O_WRONLY | O_CREAT | O_TRUNC, 0666);
	if (argoutfd == -1) {
		perror(p);
		fatal();
	}
}

static void build_arglist(char *p)
{
	arginfd = -1;
	argoutfd = -1;
	argptr = arglist;
	add_argument(p);
}

void convert_s_to_o(char *path)
{
	build_arglist(CMD_AS);
	add_argument(path);
	run_command();
	pathmod(path, ".s", ".o", 5);
}

void convert_c_to_s(char *path)
{
	char *tmp, *t;

	build_arglist(CMD_CC);
	add_argument_list("-I", &inclist);
	if (!standalone)
		add_argument("-I "INCPATH);
	add_argument_list("-D", &deflist);
	add_argument("-r");
	add_argument("--add-source");
	add_argument("--cpu");
	switch(cpu) {
		case 6800:
			add_argument("6800");
			add_argument("-D__6800__");
			break;
		case 6803:
			add_argument("6803");
			add_argument("-D__6803__");
			break;
		case 6303:
			add_argument("6303");
			add_argument("-D__6303__");
			break;
	}
	switch(targetos) {
	case OS_FUZIX:	/* Fuzix */
		add_argument("-D__FUZIX__");
		break;
	case OS_MC10:	/* MC-10 */
		add_argument("-D__TANDY_MC10__");
		break;
	case OS_FLEX: /* FLEX */
		add_argument("-D__FLEX__");
		break;
	}
	add_argument_list(NULL, &ccargs);
	add_argument(path);
	t = xstrdup(path, 0);
	tmp = pathmod(t, ".c", ".@", 0);
	if (tmp == NULL)
		memory();
	redirect_out(tmp);
	run_command();
	build_arglist(CMD_COPT);
	if (cpu == 6800)
		add_argument(COPT00_FILE);
	else
		add_argument(COPT_FILE);
	redirect_in(tmp);
	redirect_out(pathmod(path, ".@", ".s", 2));
	run_command();
	free(t);
}

void convert_S_to_s(char *path)
{
	build_arglist(CMD_CC);
	add_argument("-E");
	redirect_in(path);
	redirect_out(pathmod(path, ".S", ".s", 1));
	run_command();
}

void preprocess_c(char *path)
{
	build_arglist(CMD_CC);

	add_argument("-E");
	add_argument_list("-I", &inclist);
	add_argument_list("-D", &deflist);
	add_argument(path);
	/* Weird one .. -E goes to stdout */
	if (last_phase != 1)
		redirect_out(pathmod(path, ".c", ".%", 0));
	run_command();
}

void link_phase(void)
{
	build_arglist(CMD_LD);
	switch (targetos) {
		case OS_FUZIX:
			break;
		case OS_MC10:
			add_argument("-b");
			add_argument("-C");
			add_argument("17500");
			/* I/O at 0-31 */
			add_argument("-Z");
			add_argument("32");
			break;
		case OS_FLEX:
			add_argument("-b");
			add_argument("-C");
			add_argument("256");
			/* So we will work on 6303X etc */
			add_argument("-Z");
			add_argument("40");
			break;
		case OS_NONE:
		default:
			add_argument("-b");
			add_argument("-C");
			add_argument("256");
			break;
	}
	if (strip)
		add_argument("-s");
	add_argument("-o");
	add_argument(target);
	if (mapfile) {
		/* For now output a map file. One day we'll have debug symbols
		   nailed to the binary */
		char *n = malloc(strlen(target) + 5);
		sprintf(n, "%s.map", target);
		add_argument("-m");
		add_argument(n);
	}
	if (!standalone) {
		/* Start with crt0.o, end with libc.a and support libraries */
		add_argument(CRT0);
		append_obj(&libpathlist, LIBPATH, 0);
		append_obj(&liblist, LIBC, TYPE_A);
		if (targetos == OS_MC10) {
			append_obj(&liblist, LIBIO6803, TYPE_A);
			append_obj(&liblist, LIBMC10, TYPE_A);
		}
		if (targetos == OS_FLEX) {
			append_obj(&liblist, LIBFLEX, TYPE_A);
		}
	}
	if (cpu == 6303)
		append_obj(&liblist, LIB6303, TYPE_A);
	else if (cpu == 6803)
		append_obj(&liblist, LIB6803, TYPE_A);
	else
		append_obj(&liblist, LIB6800, TYPE_A);
	add_argument_list(NULL, &objlist);
	resolve_libraries();
	run_command();
	switch(targetos) {
	case OS_MC10:
		/* Tandy MC-10 */
		build_arglist(CMD_TAPEIFY);
		add_argument(target);
		add_argument(extend(target, ".tap"));
		add_int_argument(17500);
		add_int_argument(filesize(target) - 17500);
		add_int_argument(17500);
		run_command();
		break;
	case OS_FLEX:
		/* FLEX */
		build_arglist(CMD_BINIFY);
		add_argument("-s");
		add_int_argument(0x0100);
		add_argument("-l");
		add_int_argument(filesize(target) - 0x0100);
		add_argument("-x");
		add_int_argument(0x0100);
		add_argument(target);
		add_argument(extend(target, ".cmd"));
		run_command();
		break;
	}
}

void sequence(struct obj *i)
{
//	printf("Last Phase %d\n", last_phase);
//	printf("1:Processing %s %d\n", i->name, i->type);
	if (i->type == TYPE_S) {
		convert_S_to_s(i->name);
		i->type = TYPE_s;
		i->used = 1;
	}
	if (i->type == TYPE_C && last_phase == 1) {
		preprocess_c(i->name);
		i->type = TYPE_C_pp;
		i->used = 1;
	}
	if (last_phase == 1)
		return;
//	printf("2:Processing %s %d\n", i->name, i->type);
	if (i->type == TYPE_C_pp || i->type == TYPE_C) {
		convert_c_to_s(i->name);
		i->type = TYPE_s;
		i->used = 1;
	}
	if (last_phase == 2)
		return;
//	printf("3:Processing %s %d\n", i->name, i->type);
	if (i->type == TYPE_s) {
		convert_s_to_o(i->name);
		i->type = TYPE_O;
		i->used = 1;
	}
}

void processing_loop(void)
{
	struct obj *i = objlist.head;
	while (i) {
		sequence(i);
		remove_temporaries();
		i = i->next;
	}
	if (last_phase < 4)
		return;
	link_phase();
	/* And clean up anything we couldn't wipe earlier */
	last_phase = 255;
	remove_temporaries();
}

void unused_files(void)
{
	struct obj *i = objlist.head;
	while (i) {
		if (!i->used)
			fprintf(stderr, "cc: warning file %s unused.\n",
				i->name);
		i = i->next;
	}
}

void usage(void)
{
	fprintf(stderr, "usage...\n");
	fatal();
}

char **add_macro(char **p)
{
	if ((*p)[2])
		append_obj(&deflist, *p + 2, 0);
	else
		append_obj(&deflist, *++p, 0);
	return p;
}

char **add_library(char **p)
{
	if ((*p)[2])
		append_obj(&liblist, *p + 2, TYPE_A);
	else
		append_obj(&liblist, *++p, TYPE_A);
	return p;
}

char **add_library_path(char **p)
{
	if ((*p)[2])
		append_obj(&libpathlist, *p + 2, 0);
	else
		append_obj(&libpathlist, *++p, 0);
	return p;
}


char **add_includes(char **p)
{
	if ((*p)[2])
		append_obj(&inclist, *p + 2, 0);
	else
		append_obj(&inclist, *++p, 0);
	return p;
}

void dunno(const char *p)
{
	fprintf(stderr, "cc: don't know what to do with '%s'.\n", p);
	fatal();
}

void add_file(char *p)
{
	char *x = strrchr(p, '.');
	if (x == NULL)
		dunno(p);
	switch (x[1]) {
	case 'a':
		append_obj(&objlist, p, TYPE_A);
		break;
	case 's':
		append_obj(&objlist, p, TYPE_s);
		break;
	case 'S':
		append_obj(&objlist, p, TYPE_S);
		break;
	case 'c':
		/* HACK should be TYPE_C once we split cpp */
		append_obj(&objlist, p, TYPE_C_pp);
		c_files++;
		break;
	case 'o':
		append_obj(&objlist, p, TYPE_O);
		break;
	default:
		dunno(p);
	}
}

void one_input(void)
{
	fprintf(stderr, "cc: too many files for -E\n");
	fatal();
}

void uniopt(char *p)
{
	if (p[2])
		usage();
}

static char *passopts[] = {
	"*bss-name",
	" check-stack",
	"*code-name",
	"*data-name",
	" debug",
	" inline-stdfuncs",
	"*register-space",
	" register-vars",
	"*rodata-name",
	" signed-char",
	"*standard",
	" verbose",
	" writable-strings",
	NULL
};
	
char **longopt(char **ap)
{
	char *p = *ap + 2;
	char **x = passopts;
	while(*x) {
		char *t = *x++;
		if (strcmp(t + 1, p) == 0) {
			append_obj(&ccargs, p - 2, 0);
			if (*t == '*') {
				p = *++ap;
				if (p == NULL)
					usage();
				append_obj(&ccargs, p, 0);
			}
			return ap;
		}
	}
	usage();
}
	
int main(int argc, char *argv[])
{
	char **p = argv;
	signal(SIGCHLD, SIG_DFL);

	while (*++p) {
		/* filename or option ? */
		if (**p != '-') {
			add_file(*p);
			continue;
		}
		switch ((*p)[1]) {
		case '-':
			p = longopt(p);
			break;
			/* Don't link */
		case 'c':
			uniopt(*p);
			last_phase = 3;
			break;
			/* Don't assemble */
		case 'S':
			uniopt(*p);
			last_phase = 2;
			break;
			/* Only pre-process */
		case 'E':
			uniopt(*p);
			last_phase = 1;
			only_one_input = 1;
			break;
		case 'l':
			/* FIXME: need to expand to understand -lc as
			   "libc.a" etc */
			p = add_library(p);
			break;
		case 'I':
			p = add_includes(p);
			break;
		case 'L':
			p = add_library_path(p);
			break;
		case 'D':
			p = add_macro(p);
			break;
		case 'i':
/*                    split_id();*/
			uniopt(*p);
			break;
		case 'o':
			if (target != NULL) {
				fprintf(stderr,
					"cc: -o can only be used once.\n");
				fatal();
			}
			if ((*p)[2])
				target = *p + 2;
			else if (*p)
				target = *++p;
			else {
				fprintf(stderr, "cc: no target given.\n");
				fatal();
			}
			break;
		case 's':	/* FIXME: for now - switch to getopt */
			standalone = 1;
			break;
		case 'X':
			uniopt(*p);
			keep_temp = 1;
			break;
		case 'm':
			cpu = atoi(*p + 2);
			if (cpu != 6800 && cpu != 6803 && cpu != 6303) {
				fprintf(stderr, "cc: only 6800, 6803 or 6303 supported.\n");
				fatal();
			}
			break;	
		case 'M':
			mapfile = 1;
			break;
		case 't':
			if (strcmp(*p + 2, "fuzix") == 0)
				targetos = OS_FUZIX;
			else if (strcmp(*p + 2, "mc10") == 0)
				targetos = OS_MC10;
			else if (strcmp (*p + 2, "flex") == 0) {
				targetos = OS_FLEX;
				cpu = 6800;
			} else {
				fprintf(stderr, "cc: only fuzix and mc10 target types are known.\n");
				fatal();
			}
			break;
		default:
			usage();
		}
	}

	if (target == NULL)
		target = "a.out";
	if (only_one_input && c_files > 1)
		one_input();
	processing_loop();
	unused_files();
	return 0;
}
