OBJ = _fputs.o _getchar.o _putchar.o _puts.o

all: libio6803.a

libio6803.a: $(OBJ)
	ar rc libio6803.a $(OBJ)

%.o: %.s
	../../as68/as68 $^

clean:
	rm -f $(OBJ) ~*

