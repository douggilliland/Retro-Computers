/*------------------------------ file_fmt.h ---------------------------------*/

/*
 *  Copyright 1987 - 1992 by Sierra Systems. All rights reserved.
 *
 *  System V COFF Common Object File Format structures
 */

/* file header structure */

typedef struct file_hdr {
    unsigned char fh_magic[2];
    unsigned char fh_nbr_sections[2];
    unsigned char fh_time_date[4];
    unsigned char fh_symtab_ptr[4];
    unsigned char fh_nbr_symtab_ents[4];
    unsigned char fh_size_opt_hdr[2];
    unsigned char fh_flags[2];
} FILE_HDR;

/* file header flags */

#define FH_REL_STRPD	0x1	/* relocation information stripped from file */
#define FH_EXECUTABLE	0x2	/* file is executable, ie no unresolved refs */
#define FH_LNNO_STRPD	0x4	/* line numbers stripped from file	     */
#define FH_LSYMS_STRPD	0x8	/* local symbols stripped from file	     */
#define FH_GSYMS_STRPD	0x10	/* global symbols stripped from file	     */
#define FH_ERR_IN_FILE	0x80	/* error in object file			     */

#define MAGIC_68000	0x150	/* file header magic number for 68000 family */

/* optional a.out header structure */

typedef struct a_out_hdr {
    unsigned char magic[2];
    unsigned char version[2];
    unsigned char tsize[4];
    unsigned char dsize[4];
    unsigned char bsize[4];
    unsigned char entry[4];
    unsigned char text_start[4];
    unsigned char data_start[4];
} A_OUT_HDR;

/* section header structure */

#define SEC_NAME_LEN	8

typedef struct section_hdr {
    char sh_name[SEC_NAME_LEN];
    unsigned char sh_phys_addr[4];
    unsigned char sh_virt_addr[4];
    unsigned char sh_size[4];
    unsigned char sh_data_ptr[4];
    unsigned char sh_reloc_ptr[4];
    unsigned char sh_line_nbr_ptr[4];
    unsigned char sh_nbr_reloc_ents[2];
    unsigned char sh_nbr_line_ents[2];
    unsigned char sh_flags[4];
} SECTION_HDR;

/* section header flags */

#define SH_REG	    0x0	    /* regular section: ALLOC'D, RELOC'D, LOAD'D    */
#define SH_DSECT    0x1	    /* dummy section: \alloc'd, RELOC'D, \load'd    */
#define SH_NOLOAD   0x2	    /* noload section: ALLOC'D, RELOC'D, \load'd    */
#define SH_RESIDENT 0x2	    /* noload section: ALLOC'D, RELOC'D, \load'd    */
#define SH_GROUP    0x4	    /* grouped section: formed from input sections  */
#define SH_PAD	    0x8	    /* padding section: \alloc'd, \reloc'd, LOAD'D  */
#define SH_FILLONLY 0x8	    /* fill only section: filled at run-time	    */
#define SH_COPY	    0x10    /* copy section: copied at run-time from	    */
			    /* desitination address to virtual address	    */
#define SH_TEXT	    0x20    /* section contains executable text		    */
#define SH_DATA	    0x40    /* section contains initialized data	    */
#define SH_BSS	    0x80    /* section contains only uninitialized data	    */
#define SH_ORG	    0x100   /* section contains ORG'd (absolute) data	    */
#define SH_INFO	    0x200   /* comment section: \alloc'd, \reloc'd, \load'd */
#define SH_OVERT    0x400   /* overlay section: RELOC'D, \alloc'd, \load'd  */
#define SH_LIB	    0x800   /* for .lib section: treated like STYP_INFO	    */

#define SH_TEXT_NAME	    ".text"
#define SH_DATA_NAME	    ".data"
#define SH_BSS_NAME	    ".bss"
#define SH_LOAD_TBL_NAME    ".ld_tbl"

/* relocation information structure */

typedef struct reloc_info {
    unsigned char r_virt_addr[4];
    unsigned char r_sym_index[4];
    unsigned char r_type_info[2];
} RELOC_INFO;

/* WARNING: do not use relocation type flags that use bits in the high order */
/* byte of ->r_type_info.  A Sierra Systems extension to COFF depends on     */
/* ->r_type_info[0] and r_sym_index[0] being avaialable for internal use in  */
/* the assembler and linker.						     */

#define RL_FIXED    0x0
#define RL_DIR_BYTE 0xf
#define RL_DIR_WORD 0x10
#define RL_DIR_LONG 0x11
#define RL_PC_BYTE  0x12
#define RL_PC_WORD  0x13
#define RL_PC_LONG  0x14

/* line number information structure */

typedef struct line_nbr {
    unsigned char l_phys_addr[4];
    unsigned char l_line_nbr[2];
} LINE_NBR;

#define l_sym_index	l_phys_addr

/* symbol table defines */

#define SYM_NAME_LEN	    8
#define COFF_FILE_NAME_LEN  14
#define NBR_OF_DIMS	    4

/* main symbol table structure */

typedef struct sym_ent {
    union {
	char _sym_name[SYM_NAME_LEN];
	struct {
	    unsigned char _sym_name_zeroes[4];
	    unsigned char _sym_name_offset[4];
	} _sym_str_tbl;
    } _name;
    unsigned char sym_value[4];
    unsigned char sym_sec_nbr[2];
    unsigned char sym_type[2];
    unsigned char sym_sclass[1];
    unsigned char sym_nbr_aux[1];
} SYM_ENT;

#define sym_name    _name._sym_name
#define sym_zeroes  _name._sym_str_tbl._sym_name_zeroes
#define sym_offset  _name._sym_str_tbl._sym_name_offset

/* auxiliary symbol table structure */

typedef union aux_ent {
    char aux_file_name[COFF_FILE_NAME_LEN];
    struct {
	unsigned char tag_index[4];
	union {
	    struct {
		unsigned char c_line_nbr[2];
		unsigned char size[2];
	    } s;
	    unsigned char func_size[4];
	} u1;
	union {
	    struct {
		unsigned char line_ptr[4];
		unsigned char end_index[4];
	    } s;
	    unsigned char array_dim[NBR_OF_DIMS][2];
	} u2;
	unsigned char high_size[2];
    } symbol;
    struct {
	unsigned char len[4];
	unsigned char nbr_rel_ents[2];
	unsigned char nbr_line_nbrs[2];
    } sec;
} AUX_ENT;

#define FILE_HDR_SIZE	    sizeof(FILE_HDR)
#define A_OUT_HDR_SIZE	    sizeof(A_OUT_HDR)
#define SECTION_HDR_SIZE    sizeof(SECTION_HDR)
#define SYM_ENT_SIZE	    sizeof(SYM_ENT)
#define RELOC_INFO_SIZE	    sizeof(RELOC_INFO)
#define LINE_NBR_SIZE	    sizeof(LINE_NBR)

/* COFF DEBUG DEFINES */

/* Storage Class */

#define C_EFCN	    -1	    /* physical end of function		 */
#define C_NULL	    0
#define C_AUTO	    1	    /* automatic variable		 */
#define C_EXT	    2	    /* external symbol			 */
#define C_STAT	    3	    /* static				 */
#define C_REG	    4	    /* register variable		 */
#define C_EXTDEF    5	    /* external definition		 */
#define C_LABEL	    6	    /* label				 */
#define C_ULABEL    7	    /* undefined label			 */
#define C_MOS	    8	    /* member of structure		 */
#define C_ARG	    9	    /* function argument		 */
#define C_STRTAG    10	    /* structure tag			 */
#define C_MOU	    11	    /* member of union			 */
#define C_UNTAG	    12	    /* union tag			 */
#define C_TPDEF	    13	    /* type definition			 */
#define C_USTATIC   14	    /* uninitialized static		 */
#define C_ENTAG	    15	    /* enumeration tag			 */
#define C_MOE	    16	    /* member of enumeration		 */
#define C_REGPARM   17	    /* register parameter		 */
#define C_FIELD	    18	    /* bit field			 */
#define C_ARRAY	    19	    /* array dimension information	 */
#define C_SUE	    20	    /* struct, union or enum		 */
#define C_SKIP	    21	    /* symbol that should not be output	 */
#define C_BLOCK	    100	    /* beginning and end of block	 */
#define C_FCN	    101	    /* beginning and end of function	 */
#define C_EOS	    102	    /* end of structure			 */
#define C_FILE	    103	    /* file name			 */
#define C_ALIAS	    105	    /* duplicate tag			 */
#define C_HIDDEN    106	    /* like static, avoids name conflict */

/* Section Number Field */

#define N_DEBUG	    -2	    /* special symbolic debugging symbol */
#define N_ABS	    -1	    /* absolute symbol			 */
#define N_UNDEF	    0	    /* undefined external symbol	 */
#define N_SCNUM	    1 - 127 /* section nbr where sym is defined	 */

/* fundemental types */

#define T_NULL	    0	    /* type not assigned */
#define T_LDOUBLE   1	    /* long double	 */
#define T_CHAR	    2	    /* character	 */
#define T_SHORT	    3	    /* short		 */
#define T_INT	    4	    /* integer		 */
#define T_LONG	    5	    /* long integer	 */
#define T_FLOAT	    6	    /* float		 */
#define T_DOUBLE    7	    /* double		 */
#define T_STRUCT    8	    /* structure	 */
#define T_UNION	    9	    /* union		 */
#define T_ENUM	    10	    /* enumeration	 */
#define T_MOE	    11	    /* member of enum	 */
#define T_UCHAR	    12	    /* unsigned char	 */
#define T_USHORT    13	    /* unsigned short	 */
#define T_UINT	    14	    /* unsigned integer	 */
#define T_ULONG	    15	    /* unsigned long	 */

/* defined types */

#define DT_NON	    0	    /* no derived type	 */
#define DT_PTR	    1	    /* pointer		 */
#define DT_FCN	    2	    /* function		 */
#define DT_ARY	    3	    /* array		 */
