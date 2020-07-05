# Unix
# Define CC, when no compiler with the name "cc" exists.

TARGET =
TARGETEXTENSION = 
OUTFMTS = -DOUTAOUT -DOUTBIN -DOUTELF -DOUTHUNK -DOUTSREC -DOUTTOS -DOUTVOBJ \
          -DOUTXFIL

CCOUT = -o 
COPTS = -c -O2 -DUNIX $(OUTFMTS)

LD = $(CC)
LDOUT = $(CCOUT)
LDFLAGS = -lm

RM = rm -f

include make.rules
