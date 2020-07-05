STARTUP(crt0.o)
OUTPUT_ARCH(m68k)
INPUT(idp.o)
SEARCH_DIR(.)
__DYNAMIC  =  0;

/*
 * Setup the memory map of the MC68ec0x0 Board (IDP)
 * stack grows up towards high memory. This works for
 * both the rom68k and the mon68k monitors.
 */
MEMORY
{
  ram     : ORIGIN = 0x10000, LENGTH = 2M
}

/*
 * stick everything in ram (of course)
 */
SECTIONS
{
  .text :
  {
    CREATE_OBJECT_SYMBOLS
    *(.text)
     etext  =  .;
     __CTOR_LIST__ = .;
     LONG((__CTOR_END__ - __CTOR_LIST__) / 4 - 2)
    *(.ctors)
     LONG(0)
     __CTOR_END__ = .;
     __DTOR_LIST__ = .;
     LONG((__DTOR_END__ - __DTOR_LIST__) / 4 - 2)
    *(.dtors)
     LONG(0)
     __DTOR_END__ = .;
    *(.lit)
    *(.shdata)
  }  > ram
  .shbss SIZEOF(.text) + ADDR(.text) :	{
    *(.shbss)
  } > ram
  .talias :	 { }  > ram
  .data  : {
    *(.data)
    CONSTRUCTORS
    _edata  =  .;
  } > ram

  .bss SIZEOF(.data) + ADDR(.data) :
  {
   __bss_start = ALIGN(0x8);
   *(.bss)
   *(COMMON)
      end = ALIGN(0x8);
      _end = ALIGN(0x8);
      __end = ALIGN(0x8);
  }
  .mstack : { }  > ram
  .rstack : { }  > ram
  .stab  . (NOLOAD) : 
  {
    [ .stab ]
  } > ram
  .stabstr  . (NOLOAD) :
  {
    [ .stabstr ]
  } > ram
}
