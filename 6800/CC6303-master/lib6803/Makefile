OBJ =  asreax8.o bneg.o compleax.o __cpu_to_le16.o __cpu_to_le32.o
OBJ += divide32x32.o divide.o laddeq.o ladd.o land.o lbneg.o lcmp.o lor.o
OBJ += lsave.o lsubeq.o ltest.o lxor.o makebool.o _memcpy.o _memset.o
OBJ += mulax10.o mulax12.o mulax3.o mulax5.o mulax6.o mulax7.o mulax9.o
OBJ += multiply32x32.o negeax.o pop2.o pop4.o
OBJ += shlax.o shleax.o shrax.o shr.o _strcpy.o sub.o swap.o
OBJ += tosasleax.o
OBJ += tosasreax.o tosdivax.o tosshlax.o tossubeax.o tosudivax.o tosumulax.o
OBJ += tosdiveax.o tosmodeax.o tosudiveax.o tosumodeax.o

OBJ += __cpu_to_le16.o __cpu_to_le32.o
OBJ += _isalnum.o _isalpha.o _isascii.o _isblank.o _iscntrl.o _isdigit.o
OBJ += _isgraph.o _islower.o _isprint.o _ispunct.o _isspace.o _isupper.o
OBJ += _isxdigit.o
OBJ += _tolower.o _toupper.o
OBJ += _memccpy.o _memchr.o _memrchr.o _memcpy.o _memset.o
OBJ += _strcat.o _strcpy.o _strlen.o _strnlen.o _strchr.o _strrchr.o
OBJ += _strcmp.o _strncmp.o _strlcpy.o _strlcat.o _strncpy.o
OBJ += _abs.o _labs.o _atoi.o
OBJ += _longjmp.o _setjmp.o

all: $(OBJ)

%.o: %.s
	../as68/as68 $^

clean:
	rm -f *.o *~
