
##

DISTCLEANFILES = *~ configure.scan *.in
CLEANFILES = *~ configure.scan *.da *.bbg *.gcov *.gcda *.gcno $(BUILT_SOURCES)

##

EXTRA_DIST = $(srcdir)/license $(srcdir)/changes

##

##

##

bin_PROGRAMS = macro11 dumpobj genblkram sdfmt
noinst_PROGRAMS = fontconvert

macro11_SOURCES = macro11.c macro11.h \
       mlb.c mlb.h \
       object.c object.h \
       stream2.c stream2.h \
       util.c util.h \
       rad50.c rad50.h

dumpobj_SOURCES = dumpobj.c \
       rad50.c rad50.h

genblkram_SOURCES = genblkram.c \
       rad50.c rad50.h

sdfmt_SOURCES = sdfmt.c

fontconvert_SOURCES = fontconvert.c

