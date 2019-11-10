ren n8vem_*.* "      ????????.*"
ren zeta_*.*  "     z????????.*"

rem pause

for %%v in ("*.*") do (
        ren "%%v" %%v
)

rem pause

@echo off
for /f "delims=" %%a in ('dir /a:-d /o:n /b') do call :next "%%a"
rem pause
GOTO:EOF


:next
set "newname=%~nx1"

set "newname=%newname:_=x%"
set "newname=%newname:)=x%"
set "newname=%newname:(=x%"
set "newname=%newname:&=x%"
set "newname=%newname:^=x%"
set "newname=%newname:$=x%"
set "newname=%newname:#=x%"
set "newname=%newname:@=x%"
set "newname=%newname:!=x%"
set "newname=%newname:-=x%"
set "newname=%newname:+=x%"
set "newname=%newname:}=x%"
set "newname=%newname:{=x%"
set "newname=%newname:]=x%"
set "newname=%newname:[=x%"
set "newname=%newname:;=x%"
set "newname=%newname:'=x%"
set "newname=%newname:`=x%"
set "newname=%newname:,=x%"

ren %1 "%newname%


