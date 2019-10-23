CC = gcc
CFLAGS = -DDEBUG
OBJECTS = fat16.o test_lib.o

all: $(OBJECTS)
	$(CC) $(CFLAGS) $^ -o test_lib.exe
    
clean:
	$(RM) *.o
    
%.exe: %.c
	$(CC) $(CFLAGS) $< -o $@
	
%.o: %.c	
	$(CC) $(CFLAGS) -c $< -o $@
