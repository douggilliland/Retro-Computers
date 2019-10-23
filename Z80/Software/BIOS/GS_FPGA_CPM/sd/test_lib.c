#include <stdio.h>
#include <stdlib.h>

#include "fat16.h"

FILE * in;

// Provide disk access function for FAT16 library
void fat16_seek(unsigned long offset) {
    fseek(in, offset, SEEK_SET);
}

char fat16_read(unsigned char bytes) {
    return (char)fread(fat16_buffer, 1, bytes, in);
}

int main(int argc, char *argv[]) {
    FILE *out = fopen("HAMLET.TXT", "wb");
    char bytes_read;

    // Open disk image so fat16_seek and fat16_read work
    in = fopen("test.img", "rb");
    
    // Use FAT16 library
    fat16_init();
    fat16_open_file("HAMLET  ", "TXT");
        
    while(fat16_state.file_left) {
        bytes_read = fat16_read_file(FAT16_BUFFER_SIZE);
        fwrite(fat16_buffer, 1, bytes_read, out); // Write read bytes
    }
    
    // Close file handles
    fclose(out);
    fclose(in);
    
    return 0;
}
