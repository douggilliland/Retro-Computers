#
# CP/M Callback Filesystem
# Visual Studio 2003
#
# Linker puts subsystem 6.00 in .exe by default (ie: Vista or later).
# Program works fine on XP, so we use 5.01.
# When compiling 64 bit, the earliest possible would be 5.02.
#

CBFS =		c:\cbfs5
CBFSINC =	$(CBFS)\CPP\VC2013\32bit\static_runtime(MT)
CBFSLIB =	$(CBFS)\CPP\VC2013\32bit\static_runtime(MT)
# CBFSINC =	$(CBFS)\CPP\VC2013\64bit\x64\static_runtime(MT)
# CBFSLIB =	$(CBFS)\CPP\VC2013\64bit\x64\static_runtime(MT)

DISKDEFS =	c:/cpmtools/diskdefs
FORMAT =	memotech-type18

CFLAGS =	/c /W3 /WX /DWIN32 /D_WINDOWS /DUNICODE /D_UNICODE /D_CRT_SECURE_NO_WARNINGS /DNDEBUG /DDISKDEFS=\"$(DISKDEFS)\" /DFORMAT=\"$(FORMAT)\" /I. /I$(CBFSINC) /Zc:wchar_t /MT /Ot /nologo
CPPFLAGS =	$(CFLAGS) /EHsc
LFLAGS =	/NOLOGO /SUBSYSTEM:CONSOLE,5.01 /INCREMENTAL:NO
# LFLAGS =	/NOLOGO /SUBSYSTEM:CONSOLE,5.02 /INCREMENTAL:NO

#

all:		cpmcbfs.exe cbfs.cab

#

cpmcbfs.exe:	cpmcbfs.obj cpmfs.obj device_windows.obj
		link $(LFLAGS) /OUT:$@ $** $(CBFSLIB)\cbfs.lib shell32.lib ole32.lib

cpmcbfs.obj:	cpmcbfs.cpp config.h device.h cpmfs.h regkey.h
		cl $(CPPFLAGS) cpmcbfs.cpp

cpmfs.obj:	cpmfs.c config.h device.h cpmdir.h cpmfs.h
		cl $(CFLAGS) /wd4101 /wd4244 cpmfs.c

device_windows.obj: device_windows.c config.h device.h
		cl $(CFLAGS) /wd4996 device_windows.c

#

cbfs.cab:	$(CBFS)\Drivers\cbfs.cab
		copy $(CBFS)\Drivers\cbfs.cab .


# Package

package:
		zip -q -r cpmcbfs.zip *
		zip -q -d cpmcbfs.zip *.bak */*.bak *.obj
		
