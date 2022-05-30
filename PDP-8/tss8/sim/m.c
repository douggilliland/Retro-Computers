#define bitmask(h,l) ((unsigned int)0xffffffff >> (31-(h-l)+1))

main()
{
#define bitmask(l) ((unsigned int)0xffffffff >> (32-(l)))
	printf("%08x ", bitmask(3));
	printf("%08x ", bitmask(2));
	printf("%08x ", bitmask(1));
}
