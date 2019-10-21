#include "main.h"
#include "cf/cf.h"
#include <stdio.h>

uint8_t sector[512];
void main()
{
	cf_init();

	cf_read(0, sector);
	cf_dump_sector(sector);

	while(1)
	{

	}
}