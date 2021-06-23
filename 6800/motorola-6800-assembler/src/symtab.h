/*
 *      install --- add a symbol to the table
 */

#ifndef _SYMTAB_H_
#define _SYMTAB_H_

int install(char *str, int val);
struct nlist *lookup(char *name);
struct oper *mne_look(char *str);

#endif // _SYMTAB_H_

