OBJ = 
CRT = crt0.o

all: libc.a $(CRT)

libc.a: $(OBJ)
	ar rc libc.a $(OBJ)

%.o: %.s
	../as68/as68 $^

clean:
	rm -f $(OBJ) $(CRT) libc.a *~

	