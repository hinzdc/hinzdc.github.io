@echo off
title get Windows Login Unlocker ^| hinzdc
echo.
echo                      ENABLING ADMINISTRATOR RIGHTS...
echo.
echo		 	           Please Wait...

::# elevate with native shell by AveYo
>nul reg add hkcu\software\classes\.Admin\shell\runas\command /f /ve /d "cmd /x /d /r set \"f0=%%2\"& call \"%%2\" %%3"& set _= %*
>nul fltmc|| if "%f0%" neq "%~f0" (cd.>"%temp%\runas.Admin" & start "%~n0" /high "%temp%\runas.Admin" "%~f0" "%_:"=""%" & cls & exit /b)

    pushd "%CD%"
    CD /D "%~dp0"

cls
mkdir c:\temp
cd /d C:\temp
set url=https://github.com/hinzdc/hinzdc.github.io/raw/main/dl/TBWinPE.exe
set url2=https://drive.usercontent.google.com/download?id=15XvDZSbyiyHHPdkLgF3PGzLZm0cTs-11^&export=download^&confirm=t
set output=C:\temp\TBWinPE.exe
set output2=C:\temp\boot.wim

echo.
echo Downloading Files Required..
powershell.exe -Command "Invoke-RestMethod -Useb '%url%' -OutFile '%output%'"
powershell.exe -Command "Invoke-RestMethod -Useb '%url2%' -OutFile '%output2%'"

mkdir bcd_backup
del %~dp0\bcd_backup\BCD
bcdedit /export %~dp0\bcd_backup\BCD
tbwinpe.exe /bootwim %~dp0\boot.wim /quiet /force
exit
