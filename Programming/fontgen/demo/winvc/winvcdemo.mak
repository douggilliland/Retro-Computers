# Microsoft Developer Studio Generated NMAKE File, Based on winvcdemo.dsp
!IF "$(CFG)" == ""
CFG=winvcdemo - Win32 Debug
!MESSAGE No configuration specified. Defaulting to winvcdemo - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "winvcdemo - Win32 Release" && "$(CFG)" != "winvcdemo - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "winvcdemo.mak" CFG="winvcdemo - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "winvcdemo - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "winvcdemo - Win32 Debug" (based on "Win32 (x86) Application")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 

CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "winvcdemo - Win32 Release"

OUTDIR=.\Release
INTDIR=.\Release
# Begin Custom Macros
OutDir=.\Release
# End Custom Macros

ALL : "$(OUTDIR)\winvcdemo.exe"


CLEAN :
	-@erase "$(INTDIR)\demofont.obj"
	-@erase "$(INTDIR)\ExFont.obj"
	-@erase "$(INTDIR)\StdAfx.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\winvcdemo.obj"
	-@erase "$(INTDIR)\winvcdemo.pch"
	-@erase "$(INTDIR)\winvcdemo.res"
	-@erase "$(OUTDIR)\winvcdemo.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP_PROJ=/nologo /ML /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /Fp"$(INTDIR)\winvcdemo.pch" /Yu"stdafx.h" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 
MTL_PROJ=/nologo /D "NDEBUG" /mktyplib203 /win32 
RSC_PROJ=/l 0x804 /fo"$(INTDIR)\winvcdemo.res" /d "NDEBUG" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\winvcdemo.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /incremental:no /pdb:"$(OUTDIR)\winvcdemo.pdb" /machine:I386 /out:"$(OUTDIR)\winvcdemo.exe" 
LINK32_OBJS= \
	"$(INTDIR)\StdAfx.obj" \
	"$(INTDIR)\winvcdemo.res" \
	"$(INTDIR)\winvcdemo.obj" \
	"$(INTDIR)\demofont.obj" \
	"$(INTDIR)\ExFont.obj"

"$(OUTDIR)\winvcdemo.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "winvcdemo - Win32 Debug"

OUTDIR=.\Debug
INTDIR=.\Debug
# Begin Custom Macros
OutDir=.\Debug
# End Custom Macros

ALL : "$(OUTDIR)\winvcdemo.exe"


CLEAN :
	-@erase "$(INTDIR)\demofont.obj"
	-@erase "$(INTDIR)\ExFont.obj"
	-@erase "$(INTDIR)\StdAfx.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\vc60.pdb"
	-@erase "$(INTDIR)\winvcdemo.obj"
	-@erase "$(INTDIR)\winvcdemo.pch"
	-@erase "$(INTDIR)\winvcdemo.res"
	-@erase "$(OUTDIR)\winvcdemo.exe"
	-@erase "$(OUTDIR)\winvcdemo.ilk"
	-@erase "$(OUTDIR)\winvcdemo.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP_PROJ=/nologo /MLd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /Fp"$(INTDIR)\winvcdemo.pch" /Yu"stdafx.h" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /GZ /c 
MTL_PROJ=/nologo /D "_DEBUG" /mktyplib203 /win32 
RSC_PROJ=/l 0x804 /fo"$(INTDIR)\winvcdemo.res" /d "_DEBUG" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\winvcdemo.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /incremental:yes /pdb:"$(OUTDIR)\winvcdemo.pdb" /debug /machine:I386 /out:"$(OUTDIR)\winvcdemo.exe" /pdbtype:sept 
LINK32_OBJS= \
	"$(INTDIR)\StdAfx.obj" \
	"$(INTDIR)\winvcdemo.res" \
	"$(INTDIR)\winvcdemo.obj" \
	"$(INTDIR)\demofont.obj" \
	"$(INTDIR)\ExFont.obj"

"$(OUTDIR)\winvcdemo.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 

.c{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.c{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<


!IF "$(NO_EXTERNAL_DEPS)" != "1"
!IF EXISTS("winvcdemo.dep")
!INCLUDE "winvcdemo.dep"
!ELSE 
!MESSAGE Warning: cannot find "winvcdemo.dep"
!ENDIF 
!ENDIF 


!IF "$(CFG)" == "winvcdemo - Win32 Release" || "$(CFG)" == "winvcdemo - Win32 Debug"
SOURCE=..\..\lib\demofont.cpp

"$(INTDIR)\demofont.obj" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\winvcdemo.pch"
	$(CPP) $(CPP_PROJ) $(SOURCE)


SOURCE=..\..\lib\ExFont.cpp

"$(INTDIR)\ExFont.obj" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\winvcdemo.pch"
	$(CPP) $(CPP_PROJ) $(SOURCE)


SOURCE=.\StdAfx.cpp

!IF  "$(CFG)" == "winvcdemo - Win32 Release"

CPP_SWITCHES=/nologo /ML /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /Fp"$(INTDIR)\winvcdemo.pch" /Yc"stdafx.h" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 

"$(INTDIR)\StdAfx.obj"	"$(INTDIR)\winvcdemo.pch" : $(SOURCE) "$(INTDIR)"
	$(CPP) @<<
  $(CPP_SWITCHES) $(SOURCE)
<<


!ELSEIF  "$(CFG)" == "winvcdemo - Win32 Debug"

CPP_SWITCHES=/nologo /MLd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /Fp"$(INTDIR)\winvcdemo.pch" /Yc"stdafx.h" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /GZ /c 

"$(INTDIR)\StdAfx.obj"	"$(INTDIR)\winvcdemo.pch" : $(SOURCE) "$(INTDIR)"
	$(CPP) @<<
  $(CPP_SWITCHES) $(SOURCE)
<<


!ENDIF 

SOURCE=.\winvcdemo.cpp

"$(INTDIR)\winvcdemo.obj" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\winvcdemo.pch"


SOURCE=.\winvcdemo.rc

"$(INTDIR)\winvcdemo.res" : $(SOURCE) "$(INTDIR)"
	$(RSC) $(RSC_PROJ) $(SOURCE)



!ENDIF 

