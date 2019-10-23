#ifdef DEBUG
    #include <stdio.h>
#endif

#include "fat16.h"

unsigned char fat16_buffer[FAT16_BUFFER_SIZE];
Fat16State fat16_state;

// Initialize the library - locates the first FAT16 partition,
// loads the relevant part of its boot sector to calculate
// values needed for operation, and finally positions the
// file reading routines to the start of root directory entries
char fat16_init() {
    char i;
    unsigned long root_start;
    
    fat16_seek(0x1BE);
        
    for(i=0; i<4; i++) {        
        fat16_read(sizeof(PartitionTable));
        
        if(FAT16_part->partition_type == 4 || 
           FAT16_part->partition_type == 6 ||
           FAT16_part->partition_type == 14)
            break;
    }
    
    if(i == 4) // none of the partitions were FAT16
        return FAT16_ERR_NO_PARTITION_FOUND;
    
    fat16_state.fat_start = 512 * FAT16_part->start_sector; // temporary
    	
    fat16_seek(fat16_state.fat_start + FAT16_BOOT_OFFSET);
    fat16_read(sizeof(Fat16BootSectorFragment));
    
    if(FAT16_boot->sector_size != 512)
        return FAT16_ERR_INVALID_SECTOR_SIZE;
    
    fat16_state.fat_start += FAT16_boot->reserved_sectors * 512;
    
    root_start = fat16_state.fat_start + (unsigned long)FAT16_boot->fat_size_sectors * 
        (unsigned long)FAT16_boot->number_of_fats * 512;
	
    fat16_state.data_start = root_start + sizeof(Fat16Entry) * 
        (unsigned long)FAT16_boot->root_dir_entries;
        	
    fat16_state.sectors_per_cluster = FAT16_boot->sectors_per_cluster;
    
    // Prepare for fat16_open_file(), cluster is not needed
    fat16_state.file_left = FAT16_boot->root_dir_entries * sizeof(Fat16Entry);
    fat16_state.cluster_left = 0xFFFFFFFF; // avoid FAT lookup with root dir

#ifdef DEBUG    
    printf("FAT start at %08X, root dir at %08X, data at %08X\n", 
           fat16_state.fat_start, root_start, fat16_state.data_start);
#endif
           
    fat16_seek(root_start);

    return 0;
}

// Assumes we are at the beginning of a directory and fat16_state.file_left
// is set to amount of file entries. Reads on until a given file is found,
// or no more file entries are available.
char fat16_open_file(char *filename, char *ext) {  
    char i, bytes;
    
#ifdef DEBUG
    printf("Trying to open file [%s.%s]\n", filename, ext);
#endif

    do {
        bytes = fat16_read_file(sizeof(Fat16Entry));
        
        if(bytes < sizeof(Fat16Entry))
            return FAT16_ERR_FILE_READ;
		
#ifdef DEBUG
        if(FAT16_entry->filename[0])
            printf("Found file [%.8s.%.3s]\n", FAT16_entry->filename, FAT16_entry->ext);
#endif

        for(i=0; i<8; i++) // we don't have memcmp on a MCU...
            if(FAT16_entry->filename[i] != filename[i])
                break;        
        if(i < 8) // not the filename we are looking for
            continue;
		
        for(i=0; i<3; i++) // we don't have memcmp on a MCU...
            if(FAT16_entry->ext[i] != ext[i])
                break;
        if(i < 3) // not the extension we are looking for
            continue;
            
#ifdef DEBUG
        printf("File found at cluster %d!\n", FAT16_entry->starting_cluster);
#endif

        // Initialize reading variables
        fat16_state.cluster = FAT16_entry->starting_cluster;
        fat16_state.cluster_left = (unsigned long)fat16_state.sectors_per_cluster * 512;
        
        if(FAT16_entry->filename[0] == 0x2E || 
           FAT16_entry->attributes & 0x10) { // directory
            // set file size so large that the file entries
            // are not limited by it, but by the sectors used
            fat16_state.file_left = 0xFFFFFFFF;
        } else {
            fat16_state.file_left = FAT16_entry->file_size;
        }
        
        // Go to first cluster
        fat16_seek(fat16_state.data_start + (unsigned long)(fat16_state.cluster-2) * 
            (unsigned long)fat16_state.sectors_per_cluster * 512);
        return 0;
    } while(fat16_state.file_left > 0);
    
#ifdef DEBUG    
    printf("File not found: [%s.%s]!\n", filename, ext);
#endif
    
    return FAT16_ERR_FILE_NOT_FOUND;
}

char fat16_read_file(char bytes) { // returns the bytes read
#ifdef DEBUG   
    //printf("fat16_read_file: Cluster %d, bytes left %d/%d\n", fat16_state.cluster, fat16_state.file_left, fat16_state.cluster_left);
#endif
 
    if(fat16_state.file_left == 0)
        return 0;
    
    if(fat16_state.cluster_left == 0) {
        fat16_seek(fat16_state.fat_start + (unsigned long)fat16_state.cluster*2);
        fat16_read(2);
        
        fat16_state.cluster = FAT16_ushort[0];
        fat16_state.cluster_left = (unsigned long)fat16_state.sectors_per_cluster * 512;
        
        if(fat16_state.cluster == 0xFFFF) { // end of cluster chain
            fat16_state.file_left = 0;
            return 0;
        }
            
        // Go to first cluster
        fat16_seek(fat16_state.data_start + (unsigned long)(fat16_state.cluster-2) * 
            (unsigned long)fat16_state.sectors_per_cluster * 512);
        
#ifdef DEBUG    
        printf("Next cluster %d\n", fat16_state.cluster);
#endif
    }
    
    if(bytes > fat16_state.file_left)
        bytes = fat16_state.file_left;
    if(bytes > fat16_state.cluster_left)
        bytes = fat16_state.cluster_left;
        
    bytes = fat16_read(bytes);
    
    fat16_state.file_left -= bytes;
    fat16_state.cluster_left -= bytes;

#ifdef DEBUG   
    //printf("%d bytes read: Cluster %d, bytes left %d/%d\n", bytes, fat16_state.cluster, fat16_state.file_left, fat16_state.cluster_left);
#endif
    
    return bytes;
}
