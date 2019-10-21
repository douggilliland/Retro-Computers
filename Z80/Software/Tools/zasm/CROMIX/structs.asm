;
; super block definitions
;
frbcount        equ     80      ;free block list size
fricount        equ     80      ;free inode list size
frbsize         equ     frbcount*4+2    ;free list size in bytes
frisize         equ     fricount*2+2    ;free list size in bytes
                struct  0
sb.version      defs    2       ;version number
sb.cromix       defs    6       ;'cromix'
sb.istart       defs    2       ;first inode block
sb.isize        defs    2       ;number of inodes
sb.fsize        defs    4       ;max block number
sb.time         defs    6       ;last modified time
                mend    struct
                struct  512-frbsize-frisize
sb.nfree        defs    2       ;free block count
sb.free         defs    frbcount*4      ;free list address
sb.ilist        defs    0       ;i-list address
sb.ninode       defs    2       ;free inode count
sb.inode        defs    fricount*2      ;free inodes
                mend    struct
        eject
;
; inode buffer definitions
;
                struct  0
                defs    2       ;avail list pointers
                defs    2
in.devn         defs    2       ;inode device number
in.inum         defs    2       ;inode number
in.flags        defs    1       ;flags byte
in.ucount       defs    1       ;usage count

in.begin        defs    0       ;beginning of inode on disk
in.owner        defs    2       ;file owner's user id
in.group        defs    2       ;file owner's group id
in.aowner       defs    1       ;owner access
in.agroup       defs    1       ;group access
in.aother       defs    1       ;other access
in.stat         defs    1       ;file status
in.nlinks       defs    1       ;number of links to inode
                defs    1
in.size         defs    4       ;file total size (in bytes)
in.inode        defs    2       ;this inode number
in.parent       defs    2       ;parent inode number (for directories only)
in.sdevn        defs    0       ;special device major & minor numbers
in.dcount       defs    2       ;number entries in a directory
in.usage        defs    4       ;number blocks actually used in file
in.tcreate      defs    6       ;time created
in.tmodify      defs    6       ;time last modified
in.taccess      defs    6       ;time last accessed
in.tdumped      defs    6       ;time last dumped (backed up)

in.index        defs    4*20    ;block pointers
inosize         defs    0       ;total inode size in bytes
                mend    struct
 
inocount        equ     20      ;size of inode table
 
is.type         defl    7       ;file type mask (in.stat)
is.ordin        defl    0       ;ordinary file
is.direct       defl    1       ;directory file
is.char         defl    2       ;character device
is.block        defl    3       ;block device
is.pipe         defl    4       ;pipe file

is.alloc        defl    7       ;inode allocated (bit in in.stat)

if.lock         defl    0       ;inode locked (in use by a process)
if.want         defl    1       ;inode wanted by another process
if.modf         defl    2       ;inode has to be written out
if.modt         defl    3       ;update time modified
if.acct         defl    4       ;update time accessed

ac.read         defl    0       ;read access bit
ac.exec         defl    1       ;execute access bit
ac.writ         defl    2       ;write access bit
ac.apnd         defl    3       ;append access bit
 
        eject
;
; directory format definitions
;
                struct  0
dr.name         defs    24      ;name of entry
namsize         defs    0       ;size of name
                defs    4       ;reserved
dr.stat         defs    2       ;status & flags
dr.inum         defs    2       ;inode number of file
dirsize         defs    0       ;directory entry size (32 bytes)
                mend    struct

ds.alloc        equ     7       ;entry allocated bit
