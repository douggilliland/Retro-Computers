RC2014/Z80 CF card implementation
---------------------

fatfs-folder contains the CF card driver together with [Petit FAT](http://elm-chan.org/fsw/ff/00index_p.html).  
rawsectors-folder just contains the CF card driver and an example program to read/write single sectors.   

__Functions:__  
`void cf_init();`  
Initiates the CF card driver  
`void cf_read(uint32_t sector, uint8_t* data);`  
Reads a single sector into the data-buffer  
`void cf_write(uint32_t sector, uint8_t* data);`  
Writes a single sector with content from the data-buffer  
`void cf_dump_sector(uint8_t* data);`  
Hex-Dumps a complete sector via printf  

![RC2014 CF card module](http://tbspace.de/content/images/_A125799.jpg)