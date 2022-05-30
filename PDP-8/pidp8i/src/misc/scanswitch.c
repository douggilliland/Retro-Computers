/*
 * Scan switches for PiDP-8/I front panel
 * 
 * www.obsolescenceguaranteed.blogspot.com
 *
 * Copyright (c) 2015-2016 Oscar Vermeulen
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:

 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * THE AUTHORS LISTED ABOVE BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * Except as contained in this notice, the names of the authors above shall
 * not be used in advertising or otherwise to promote the sale, use or other
 * dealings in this Software without prior written authorization from those
 * authors.
 * 
*/

#include <pidp8i.h>

#define short_wait() sleep_us(100000)

#define pgpio (&gpio)


int main()
{
	int i,j,k,switchscan[2], tmp;

	extern struct bcm2835_peripheral gpio;
    if (map_gpio_for_pidp8i (1) != 0)
	{	printf("Failed to map the GPIO SoC peripheral into our VM space.\n");
		return 127;
	}
    init_pidp8i_gpio();

	// Read the switches
	for (uint8_t row=1;row<=2;row++)		// do rows 2 (for IF switches) and 3 (for STOP switch)
	{		
		INP_GPIO(rows[row]);
		OUT_GPIO(rows[row]);			// turn on one switch row
		GPIO_CLR = 1 << rows[row];		// and output 0V to overrule built-in pull-up from column input pin
	
		sleep_us(10);                   // unnecessarily long?
		switchscan[row-1]=0;

		for (j=0;j<NCOLS;j++)			// 12 switches in each row
		{	tmp = GPIO_READ(cols[j]);
			if (tmp==0)
				switchscan[row-1] += 1<<j;
		}
		INP_GPIO(rows[row]);			// stop sinking current from this row of switches
	}

	unmap_peripheral(&gpio);

	if ( ((switchscan[1] >> 6) & 1) == 1 )	// STOP switch enabled,
		return 8;				// 8: STOP enabled, no bootscript
	else
		return (switchscan[0] >> 6) & 07;	// 0-7: x.script to be used in PiDP-8/I
}

