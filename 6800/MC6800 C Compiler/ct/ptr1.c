main() {
  int i, *ip, *iap[10], (*ipa)[10];
  long *lp, *lap[10], (*lpa)[10];
  struct { int xxx[10]; long yyy; } *sp, *sap[10], (*spa)[10];

  i=ip+1;i=iap+1;i=ipa+1;
  i=lp+1;i=lap+1;i=lpa+1;
  i=sp+1;i=sap+1;i=spa+1;
  i=iap[2]+1;
}
