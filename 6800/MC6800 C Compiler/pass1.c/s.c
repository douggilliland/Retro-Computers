/*
 * symbol table structure
 */
struct sym_rec
   {
    short qual_num;
    long sym_addr;
    short sym_flags;
    short sym_length;
   };
/*
 * relocation record structure
 */
struct reloc_rec
   {
    long bytes_addr;
    short   flags;
    short ext_length;
   };
/*
 * binary header format
 */
struct binary_header
   {
    short   info_flags;
    long text_size;
    long data_size;
    long bss_size;
    long reloc_size;
    long trans_addr;
    long text_addr;
    long data_addr;
    long init_stack_size;
    long sym_tab_size;
    short comment_size;
    short rec_name_size;
    short bit_flags;
    short min_page_alloc;
    short max_page_alloc;
    char max_task_size;
    char spare_bytes[7];
    short module_type;
    char vers_config[4];
    short serial_num;
   };

struct tnode
   {
    struct tnode *leftson,*rightson;
    long address;
    char *symbol;
    char over_seg;
    char attributes;
    char balance;
   };

struct mod_q
   {
    struct m_q_node *m_head;
    struct m_q_node *m_tail;
   };

struct m_q_node
   {
    struct m_q_node *m_back,*m_for;
    char *mf_name;
    char mm_name[15];
    char over_level;
    long m_text,m_data,m_bss;
    long m_seek_at;
    struct tnode *com_symbol;    /* ptr to common symbol */
   };

struct overlay_array
   {
    long base_text;
    long base_data;
    long base_bss;
   };

struct lib_entry
   {
    long ent_offset;
    short ent_length;
   };

#define TEXTFILE 0
#define BINFILE 1

/*
 * Debug control flags
 */

/*
#define BDEBUG 1
#define RDEBUG 1
#define UDEBUG 1
#define PROF 1
*/

struct binary_header s1;
main() {
  int a;
  char c;

  c = s1.max_task_size;
  c = s1.spare_bytes[0];
  a = s1.module_type;
  c = s1.vers_config[0];
  a = s1.serial_num;
  a = sizeof(struct binary_header);
}
