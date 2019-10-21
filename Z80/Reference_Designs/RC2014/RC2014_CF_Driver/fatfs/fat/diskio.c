#include "diskio.h"
#include "../cf/cf.h"
#include <string.h>

DSTATUS disk_initialize (void)
{
    cf_init();
    return RES_OK;
}

uint8_t cf_sector_read[512];
uint8_t cf_sector_write[512];

DRESULT disk_readp (BYTE* buff, DWORD sector, WORD offset, WORD count)
{
    cf_read(sector, cf_sector_read);
    memcpy(buff, cf_sector_read + offset, count);
    return RES_OK;
}

uint32_t currentSector; 
DRESULT disk_writep (const BYTE* buff, DWORD sc)
{
    if (buff)
    {
        memcpy(cf_sector_write, buff, sc);
    }
    else
    {
        if (sc)
        {
            // init sector write transaction
            memset(cf_sector_write, 0x00, 512);
            currentSector = sc;
        }
        else
        {
            // write sector
            cf_write(currentSector, cf_sector_write);
        }
        
    }
    
    return RES_OK;
}