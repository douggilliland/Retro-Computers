unsigned long SwapBBBB(unsigned long i)
{
	asm volatile
	(
		"rol.w #8,%0\n\t"
		"swap %0\n\t"
		"rol.w #8,%0\n\t"
	: "=r" (i) /* out */
	: "r" (i) 
	: /* no clobber */
	);	
	return i;
}

unsigned int SwapBB(unsigned int i)
{
	asm volatile
	(
		"rol.w #8,%0\n\t"
	: "=r" (i) /* out */
	: "r" (i) 
	: /* no clobber */
	);	
	return i;
}

unsigned long SwapWW(unsigned long i)
{
	asm volatile
	(
		"swap %0\n\t"
	: "=r" (i) /* out */
	: "r" (i) 
	: /* no clobber */
	);	
	return i;
}
