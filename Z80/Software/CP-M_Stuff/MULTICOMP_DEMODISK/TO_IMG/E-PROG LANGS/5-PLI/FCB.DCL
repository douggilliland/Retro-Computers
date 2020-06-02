		  2 name1,
		    3 drive fixed(7),       /* drive number */
		    3 fname character(8),   /* file name */
		    3 ftype character(3),   /* file type */
		    3 fext  fixed(7),       /* file extent */
		    3 space (3) bit(8),     /* filler */
		  2 name2,                  /* used in rename */
		    3 drive2 fixed(7),
		    3 fname2 character(8),
		    3 ftype2 character(3),
		    3 fext2  fixed(7),
		    3 space2 (3) bit(8),
		  2 crec  fixed(7),    /* current record */
		  2 rrec  fixed(15),   /* random record */
		  2 rovf  fixed(7);    /* random rec overflow */
