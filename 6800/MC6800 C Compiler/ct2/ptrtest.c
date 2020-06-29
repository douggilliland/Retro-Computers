struct ss {
  int ss1;
  int ss2;
  int ss3;
  };

int ei, *pei, **ppei;
char ec, *pec, **ppec;
struct ss es, *eps, **epps;
int ia[5][4], *iap[5][4];

main() {
  int ai, *pai, **ppai;
  static si, *psi, **ppsi;
  struct ss as, *pas, **ppas;
  int i;

  i = *pei;
  i = **ppei;
  i = *epps;
  i = *psi;
  i = **ppsi;

  pei = pei+1;
  pei = *ppei+1;
  pei = pei+1;
  pei = *ppei+1;
  pei = eps+1;
  pei = *epps+1;
  pei = psi+1;
  pei = *ppsi+1;
}
