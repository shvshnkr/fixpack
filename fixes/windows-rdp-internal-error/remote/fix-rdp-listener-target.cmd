@echo off
REM ============================================================================
REM fix-rdp-listener-target.cmd
REM Выполняется НА целевом ПК (через PsExec -c, VNC, консоль).
REM Не используйте PowerShell в PsExec если команды "склеиваются" при вставке.
REM ============================================================================
setlocal EnableExtensions
set "RDP_KEY=HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"

echo [%COMPUTERNAME%] fix-rdp-listener-target

reg query "%RDP_KEY%" /v SecurityLayer
reg add "%RDP_KEY%" /v SecurityLayer /t REG_DWORD /d 1 /f
if errorlevel 1 exit /b 1

reg delete "%RDP_KEY%" /v SSLCertificateSHA1Hash /f 2>nul

echo Stopping RDP services...
net stop UmRdpService /y
net stop TermService /y
timeout /t 3 /nobreak >nul
net start TermService
if errorlevel 1 exit /b 1
net start UmRdpService

echo Done on %COMPUTERNAME%. Test mstsc.
reg query "%RDP_KEY%" /v SecurityLayer
exit /b 0
