#include <stdio.h>
#include <io.h>
#include <ctype.h>
#include <stddef.h>
#include <string.h>

#include <fcntl.h>    // O_RDWR...
#include <sys/stat.h> // S_IWRITE

typedef unsigned int uint32_t;

// Makedisk -M:outfile -L:lrl[128] -SI:input track size -SO:output track size 
//          -I:infile -F[T]:from -T[T]:to -D[T]:dest ... -P[T]:padsize
// T for whole tracks, else sectors

void copy( int out, int in, uint32_t from, uint32_t to, uint32_t dest, int lrl )
{
	char buf[1024];
	lseek( out, dest*lrl, SEEK_SET );
	lseek( in,  from*lrl, SEEK_SET );
	for ( ; from<to; ++from )
	{
		read( in, buf, lrl );
		write( out, buf, lrl );
	}
}

int main( int argc, char* argv[] )
{
	int infile=0, outfile=0;

	uint32_t	from=0;
	uint32_t	to=0;
	uint32_t	dest=0;
	int		mult;
	int		lrl=128;
	int		intrksize=26;
	int		outtrksize=128;
	char		c;
	int		i;

	puts( "Making disk\n" );
	for ( i=0; i<argc; ++i )
	{
		char *s = argv[i];
		if ( *s == '-' )
			++s;
		switch ( toupper( *s ) )
		{
		case 'M':
			++s;
			if ( *s == ':' )
				++s;
			printf( "Creating: %s\n", s );
			outfile = open( s, _O_CREAT | _O_RDWR | _O_BINARY, _S_IWRITE );
			break;
		case 'I':
			++s;
			if ( *s == ':' )
				++s;
			if ( infile )
				close( infile );
			printf( "Reading: %s\n", s );
			infile = open( (const char *)s, _O_RDONLY | _O_BINARY, _S_IREAD );
			break;
		case 'L':
			++s;
			if ( *s == ':' )
				++s;
			sscanf( s, "%d", &lrl );
			break;
		case 'S':
			++s;
			c = toupper( *s );
			if ( *s == ':' )
				++s;
			switch ( c )
			{
			case 'I':
				sscanf( s, "%d", &intrksize );
				break;				
			case 'O':
				sscanf( s, "%d", &outtrksize );
				break;				
			default:
				printf( "Unrecognized option: -S%c:%s", c, s );
				return 1;
			}
		case 'F':
			++s;
			if ( *s == ':' )
				++s;
			mult = 1;
			if ( toupper( *s ) == 'T' )
				mult = intrksize, ++s;
			sscanf( s, "%d", &from );
			from *= mult;
			break;
		case 'T':
			++s;
			if ( *s == ':' )
				++s;
			mult = 1;
			if ( toupper( *s ) == 'T' )
				mult = intrksize, ++s;
			sscanf( s, "%d", &to );
			to *= mult;
			break;
		case 'D':
			++s;
			if ( *s == ':' )
				++s;
			mult = 1;
			if ( toupper( *s ) == 'T' )
				mult = outtrksize, ++s;
			sscanf( s, "%d", &dest );
			dest *= mult;
			printf( "[%06X-%06X) -> %06X\n", from*lrl, to*lrl, dest*lrl);
			copy( outfile, infile, from, to, dest, lrl );
			break;
		case 'P':
			++s;
			if ( *s == ':' )
				++s;
			mult = 1;
			if ( toupper( *s ) == 'T' )
				mult = outtrksize, ++s;
			sscanf( s, "%d", &dest );
			dest *= mult;
			printf( "Padding to %06X\n", dest*lrl);
			chsize( outfile, dest*lrl );
			break;
		default:
			printf( "Unrecognized switch: -%s", s );
			return 1;
		}

		if ( errno )
		{
			puts( strerror( errno ) );
			return 1;
		}
	}
	return 0;	
}
