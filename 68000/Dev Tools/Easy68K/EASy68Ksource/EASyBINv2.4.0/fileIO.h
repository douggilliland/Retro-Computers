//---------------------------------------------------------------------------

#ifndef fileIOH
#define fileIOH
#include <system.hpp>
//---------------------------------------------------------------------------
bool loadSrec(char *name);
int loadBinary(char *name, int split); // load memory with contents of binary file
void saveBinary(int split);
void saveSRecord();
void finish(char *sRec, int bytes);

#endif
