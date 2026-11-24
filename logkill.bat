@echo off
title Log Killer
color 7

rem wevtutil needs an elevated session - check before doing anything
net session >nul 2>&1 || (
    echo [!] This script must be run as Administrator.
    exit /b 1
)

echo  -==========================================-
echo -=               Log Killer               =-
echo  -==========================================-
timeout /t 3 /nobreak >nul

for /F "tokens=*" %%G in ('wevtutil.exe el') DO (call :clear "%%G")

echo.
echo all event logs deleted.
timeout /t 3 >nul
exit /b 0

:clear
echo [+] %~1
wevtutil.exe cl "%~1"
goto :eof
