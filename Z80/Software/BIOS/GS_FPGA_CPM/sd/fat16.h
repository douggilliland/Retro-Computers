#ifndef __FAT16_H
#define __FAT16_H

// Partition information, starts at offset 0x1BE
typedef struct {
    unsigned char first_byte;
    unsigned char start_chs[3];
    unsigned char partition_type;
    unsigned char end_chs[3];
    unsigned long start_sector;
    unsigned long length_sectors;
} __attribute((packed)) PartitionTable;

// Bytes omitted from the start of Fat16BootSectorFragment
#define FAT16_BOOT_OFFSET 11

// Partial FAT16 boot sector structure - non-essentials commented out
typedef struct {
    /*unsigned char jmp[3];
    char oem[8];*/
    unsigned short sector_size;
    unsigned char sectors_per_cluster;
    unsigned short reserved_sectors;
    unsigned char number_of_fats;
    unsigned short root_dir_entries;
    unsigned short total_sectors_short; // if zero, later field is used
    unsigned char media_descriptor;
    unsigned short fat_size_sectors;
    /*unsigned short sectors_per_track;
    unsigned short number_of_heads;
    unsigned long hidden_sectors;
    unsigned long total_sectors_long;
    
    unsigned char drive_number;
    unsigned char current_head;
    unsigned char boot_signature;
    unsigned long volume_id;
    char volume_label[11];
    char fs_type[8];
    char boot_code[448];
    unsigned short boot_sector_signature;*/
} __attribute((packed)) Fat16BootSectorFragment;

// FAT16 file entry
typedef struct {
    unsigned char filename[8];
    unsigned char ext[3];
    unsigned char attributes;
    unsigned char reserved[10];
    unsigned short modify_time;
    unsigned short modify_date;
    unsigned short starting_cluster;
    unsigned long file_size;
} __attribute((packed)) Fat16Entry;

// State data required by FAT16 library
typedef struct {
   unsigned long fat_start; // FAT start position
   unsigned long data_start; // data start position
   unsigned char sectors_per_cluster; // cluster size in sectors
   unsigned short cluster; // current cluster being read
   unsigned long cluster_left; // bytes left in current cluster
   unsigned long file_left; // bytes left in the file being read
} __attribute((packed)) Fat16State;

#define FAT16_BUFFER_SIZE 32

// Global variables for read data and library state
extern unsigned char fat16_buffer[FAT16_BUFFER_SIZE];
extern Fat16State fat16_state;

// Aliases for fat16_buffer in different formats
#define FAT16_part ((PartitionTable *)((void *)fat16_buffer))
#define FAT16_boot ((Fat16BootSectorFragment *)((void *)fat16_buffer))
#define FAT16_entry ((Fat16Entry *)((void *)fat16_buffer))
#define FAT16_ushort ((unsigned short *)((void *)fat16_buffer))

// The following functions need to be provided for the library

// Go to specified offset. Next fat16_read should continue from here
void fat16_seek(unsigned long offset);
// Read <bytes> to fat16_buffer, and return the amount of bytes read
char fat16_read(unsigned char bytes);

// The following functions are provided by the library

// Error codes for fat16_init()
#define FAT16_ERR_NO_PARTITION_FOUND -1
#define FAT16_ERR_INVALID_SECTOR_SIZE -2

// Initialize the FAT16 library. Nonzero return value indicates
// an error state. After init, the file stream is pointed to
// the beginning of root directory entry.
char fat16_init(); // nonzero return values indicate error state

// Error codes for fat16_open_file()
#define FAT16_ERR_FILE_NOT_FOUND -1
#define FAT16_ERR_FILE_READ -2

// Open a given file. Assumes that the stream is currently at
// a directory entry and fat16_state.file_left contains the
// amount of file entries available. Both conditions are satisfied
// after fat16_init(), and also after opening a directory with this.
char fat16_open_file(char *filename, char *ext);

// Read <bytes> from file. Returns the bytes actually read, and
// 0 if end of file is reached. This method will automatically
// traverse all clusters of a file using the file allocation table
char fat16_read_file(char bytes);

#endif
