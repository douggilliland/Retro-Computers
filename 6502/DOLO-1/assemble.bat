echo off
color 81
cls
:compile
echo Compile started   : %date% %time%
as65 -x -l kernel\kernel.s
echo  db "Build : %date%\r" > kernel\build.s
echo Compile completed : %date% %time%
pause
goto compile
