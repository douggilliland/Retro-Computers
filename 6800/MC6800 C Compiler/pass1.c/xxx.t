  if ((dtype&0x0f)>=STRUCT && (dtype&0x0f)<=ENUM) {
    ptinfo--;
    strhdr = ptinfo->header;
    strnum = ptinfo->number;
  }
