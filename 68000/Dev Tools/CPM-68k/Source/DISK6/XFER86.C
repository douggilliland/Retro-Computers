/*	@(#)xfer86.c	3.1		*/
/*
 * this program modifies the disk parameter block
 * so that files may be transferred between CP/M-68K
 * and CCP/M-86.  it requires that a disk be inserted
 * so that it can be selected in order to obtain the
 * address of the disk parameter block.
 */

#include "biostyps.h" /* defines portable variable types */

LONG BIOS();
#define MBIOS(a,b,c) BIOS((WORD)a,(LONG)b,(LONG)c)

#define BSH86 4
#define BLM86 15
#define EXM86 1
#define DSM86 157
#define DRM86 63
#define CKS86 ((DRM86 / 4) + 1)
#define OFF86 1

#define BSH68K 4
#define BLM68K 15
#define EXM68K 1
#define DSM68K 153	/* assumes 48 tpi disk */
#define DRM68K 127
#define CKS68K ((DRM68K / 4) + 1)
#define OFF68K 2

#define SELECT 9

/* disk parameter block structure */
struct dpb {
  WORD  spt;
  BYTE  bsh;
  BYTE  blm;
  BYTE  exm;
  BYTE  dpbjunk;
  WORD  dsm;
  WORD  drm;
  BYTE  al0;
  BYTE  al1;
  WORD  cks;
  WORD  off;
};
/* disk parameter header structure */
struct dph {
  BYTE  *xltp;
  WORD   sphscr[3];
  BYTE  *dirbufp;
  struct dpb *dpbp;
  BYTE  *csvp;
  BYTE  *alvp;
};

main() {
  struct dph *dphp;
  struct dpb *ldpbp;
  char line[80];

  printf("\n\rCCP/M-86 file transfer\n\r");
  do {
    printf("\n\rinsert disk for transfer into drive A then");
    do {
      printf("\n\rtype c (configure for CCP/M-86) and return or");
      printf("\n\rtype r (restore to CP/M-68K) and return: ");
      scanf("%s",line);
    } while ( !( (line[0] == 'c') || (line[0] == 'r') ) );
    if ( (dphp = MBIOS(SELECT,0,0)) == 0L ) {
      printf("\n\rselect error\n\r");
    }
  } while ( !dphp );
  if ( line[0] == 'c' ) {
    ldpbp = dphp->dpbp;
    ldpbp->bsh = BSH86;
    ldpbp->blm = BLM86;
    ldpbp->exm = EXM86;
    ldpbp->dsm = DSM86;
    ldpbp->drm = DRM86;
    ldpbp->cks = CKS86;
    ldpbp->off = OFF86;
    printf("\n\rdisk parameter block configured for CCP/M-86.\n\r");
  } else { /* reconfigure for CP/M-68K */
    ldpbp = dphp->dpbp;
    ldpbp->bsh = BSH68K;
    ldpbp->blm = BLM68K;
    ldpbp->exm = EXM68K;
    ldpbp->dsm = DSM68K;
    ldpbp->drm = DRM68K;
    ldpbp->cks = CKS68K;
    ldpbp->off = OFF68K;
    printf("\n\rdisk parameter block reconfigured for CP/M-68K.\n\r");
  }
}
dpbp