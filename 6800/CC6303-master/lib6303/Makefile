OBJ = divide.o laddeq.o lsubeq.o tosudivax.o

all: $(OBJ)

%.o: %.s
	../as68/as68 $^

clean:
	rm -f *.o *~
