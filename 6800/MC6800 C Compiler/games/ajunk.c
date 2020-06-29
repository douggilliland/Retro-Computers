#include "sgtty.h"

chaready(){
  struct sgttyb chrmds;

  gtty(0,&chrmds);
  return(chrmds.sg_speed & 0x80);
}
