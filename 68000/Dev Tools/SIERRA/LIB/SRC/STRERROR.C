/*
 *  strerror.c
 *
 *  Copyright 1987, 1992 by Sierra Systems.  All rights reserved.
 */

#include <string.h>
#include <errno.h>

/*------------------------------ strerror() ---------------------------------*/

/*
 * strerror maps the the error_number to an error message string.  strerror()
 * returns a pointer to the string which are implementation defined.
 */

char *strerror(int error_number )
{
    char *rval;

    switch( error_number ) {
    case NOERROR:   rval = "no error";				    break;
    case ENOENT:    rval = "no such file entry";		    break;
    case EIO:	    rval = "I/O error";				    break;
    case ENOTTY:    rval = "not a serial device";		    break;
    case ENOMEM:    rval = "out of memory";			    break;
    case EACCES:    rval = "permission denied";			    break;
    case ENOTBLK:   rval = "block device required";		    break;
    case ENODEV:    rval = "no such device";			    break;
    case EINVAL:    rval = "invalid argument";			    break;
    case EMFILE:    rval = "file table is full";		    break;
    case EDRFUL:    rval = "device directory is full";		    break;
    case ENOSPC:    rval = "no space left on device";		    break;
    case ENOABLK:   rval = "no more allocation blocks";		    break;
    case ENODBLK:   rval = "no more data blocks on device";	    break;
    case EFILEO:    rval = "file is open";			    break;
    case ENORAM:    rval = "no RAM space configured";		    break;
    case ENOHEAP:   rval = "no heap space configured";		    break;
    case EISEEK:    rval = "seek can't extend read only file";	    break;
    case EBADF:	    rval = "bad file descriptor - file not open";   break;
    case EINSIG:    rval = "invalid signal number";		    break;
    case EDOM:	    rval = "argument out of range";		    break;
    case ERANGE:    rval = "result out of range";		    break;
    default:	    rval = "undefined errno value";		    break;
    }
    return(rval);
}
