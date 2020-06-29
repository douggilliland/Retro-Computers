struct addreg {
  int ar_ref;                  /* reference type */
  int ar_off;                  /* offset */
  int ar_ofr;                  /* register offset */
  int ar_inc;                  /* increment */
  int ar_ind;                  /* indirection level */
  char ar_pre;                 /* pre or post increment */
  char ar_chg;                 /* changed flag */
  int *ar_con;                 /* pointer to constant value */
  union {
    int ad_val;
    char ad_nam[8];
    } ar_data;                 /* data */
};

extern int locop1, locop2, explev;
extern struct addreg adregs[];
extern char ccok, dvalid;
extern int curtyp;

/* Generate code for pointer minus pointer operation. */

ptrsub() {
  register struct addreg *p1, *p2;
  int ref1, ref2;

  p1 = &adregs[locop1 & (10-1)];
  p2 = &adregs[locop2 & (10-1)];
  p1->ar_ind++;
  p2->ar_ind++;
  finarx(locop1);
  finarx(locop2);
  p1->ar_ind--;
  p2->ar_ind--;
  ref1 = p1->ar_ref;
  ref2 = p2->ar_ref;
  if (ref1==(3|1) || ref1==(3|2)) {
    tfrxd();
    if (ref2==(3|1))
      freex();
    else if (ref2==(3|2))
      stacku(locop2);
  }
  else {
    loadi(locop1);
    if (ref2==(3|1) || ref2==(3|2)) {
      if (ref2==(3|1))
        freex();
      else
        stacku(locop2);
    }
    else
      finar(locop2);
  }
  ccok++;
  outcode(" subd ");
  genadr(locop2 & (10-1));
  dvalid = '\0';
  rsltd();
}
