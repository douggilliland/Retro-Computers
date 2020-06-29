int x;
char y;
unsigned z;
char ar3[3];
long w;

struct s1
   {
    char s1c1;
    short s1s1;
    int s1i1;
    long s1l1;
   };

struct s2
   {
    short s2s1;
    short s2s2;
    int s2i1;
    char s2c1;
   };

struct operand {
  char optype;
  struct opkind {
      char nclass;
      int ntype;
      struct namekind {
        int nampos;
        char namext[8];
      } ndata;
  } name;
};

struct express {
  int rslt;
  char operator;
  int rtype;
  struct operand *op1;
  struct operand *op2;
};

struct addreg {
  int ar_ref;
  int ar_off;
  int ar_ofr;
  int ar_inc;
  int ar_ind;
  char ar_pre;
  char ar_chg;
  short *ar_con;
  union {
    int ad_val;
    char ad_nam[8];
    } ar_data;
};

struct dstruct {
  int d_ref;
  union {
    int d_val;
    char d_name[8];
  } d_data;
};

main(argc,argv)
int argc;
char **argv;
{
 int a,b,c;
 short d,e,f;
 struct s1 s1str1,s1str2;
 struct s2 s2str1,s2str2;
 struct operand ops1,ops2,*opptr;
 struct express ex1,ex2;
 struct addreg ad1,ad2;
 struct dstruct ds1,ds2;

 a = s1str1.s1i1 + 5;
 b = s1str1.s1s1 + s2str1.s2s2;
 e = s1str2.s1c1 + (s2str1.s2i1 - s2str2.s2c1);

ex1.op1.name.ndata.nampos = ops1.optype - (ops2.name.ntype +
          ops1.name.ndata.nampos);
ad1.ar_data.ad_val = ds1.d_data.d_val + ex2.op2.name.ntype;
opptr = ops1.op1;
opptr = ops1.op1->op2;
opptr = (ops2.op2)++;
}
