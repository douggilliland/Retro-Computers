OBJS = copt.o
REGEX_OBJS = regex/regcomp.o  regex/regerror.o regex/regexec.o  regex/regfree.o

CFLAGS += -std=gnu99 -DLOCAL_REGEXP -I. -Wall -pedantic

OBJS += $(REGEX_OBJS)

all: copt killdeadlabel

copt:	$(OBJS)
	$(CC) -o copt $(LDFLAGS) $(OBJS)

killdeadlabel: killdeadlabel.o

%.o: %.c
	$(CC) -c -o $@ $(CFLAGS) $(LOCAL_CFLAGS) $(INCLUDES) $^

clean:
	rm -f $(OBJS) copt *~ */*~


#Dependencies

copt.o: copt.c 
killdeadlabel.o : killdeadlabel.c
