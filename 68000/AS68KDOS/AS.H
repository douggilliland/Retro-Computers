/*
 *      machine independent definitions and global variables
 */

#define YES	1
#define NO	0
#define ERR	(-1)

#define MAXBUF  256     /* input line length */
#define MAXOP   20      /* space for longest mnemonic */
#define MAXLAB  30      /* longest label */
#define E_LIMIT 32      /* max. bytes per S-record */
#define P_LIMIT 64      /* max. bytes per line to listing */
#define OBJNAME "m.out" /* S-record filename */

#define MAXWORD 32767
#define MINWORD (-32768)
#define MAXUWORD 65535
#define MAXBYTE 127
#define MAXUBYTE 255
#define MINBYTE (-128)

/*      Debug flag values       */
#define PARSE   0x01
#define MATCH   0x02
#define EVAL    0x04
#define LOOKUP  0x08
#define FWDREF  0x10
#define XDEBUG  0x20    /* debug indexed indirect */
#define DUMP    0x40    /* internal table dump */

struct opts {   /* a list of allowed options */
	char    *opt_name;
	int     (*opt_func)();
	};

/* ================================================================ */
char mapdn();
char *alloc();

/* AS.C */
doflag(char *s);
make_pass(char *s);
getaline(FILE *f);
parse_line();
process();

/*  DO.C */
localinit();
do_op(int class, int op, int op2);
fsizchk(struct ea *e);
check(long const1, int type);
size76();
size109();
size109b();
adreg(struct ea *e);
modreg(struct ea *e);
finish(struct ea *e);
genxreg(struct ea *e);
getrlist(struct ea *e);
bitfld(struct ea *e, long r);
dump_regs();
do_opt(struct opts *l);
fsize();
checkfclist(long r, struct ea *e);
o_fpid(char *s);
pmmu_fc(struct ea *e);

/* EMIT.C */
elong(long wd);
eword(int wd);
emit(unsigned char byte);
f_record();
print_line();

/* EVAL.C */
exprinit();
expreinit();
eval(long *result);
get_term(long *result);

/* LOOKUP.C */
hash(char *s);
install(char *str, long val, char type);
struct nlist *lookup(char *name);
struct mne *mne_look(char *str);
dump_syms();
void  print_syms();

/*  MATCH.C */
struct tmpl *tmpl_match(struct tmpl *p, int n);
eamatch(int gen, long spec);
scanea(struct ea *e);
do_multi();
optsize(long v);
optscale();
do_indexed(struct ea *e);
do_xn(struct ea *e);
checkpair(struct ea *e);
checklist(struct ea *e);
regbit(int type, int reg);
oh_shit(struct ea *e);
dump_comp();
dump_mne();
psize(int s);
void do_xref();

/*  SREC.C */
srecinit(char *s);
srecdata(int count, unsigned long addr, char *buf);
srecend(long addr);
srec(char type, long count, unsigned long addr, char *buf);
put2hex(int b);


/* UTIL.H */
fatal(char *str);
error(char *str);
serror(char *fmt, char *s);
warn(char *str);
delim(char c);
char *skip_white(char *ptr);
any(char c, char *str);
char mapdn(char c);
loword(long i);
hiword(long i);
lobyte(long i);
hibyte(int i);
head(char *str1, char *str2);
alpha(char c);
alphan(char c);
white(char c);
reverse(long val);
char *next_str();
