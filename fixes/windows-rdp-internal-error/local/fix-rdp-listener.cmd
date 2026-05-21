@echo off
REM ============================================================================
REM fix-rdp-listener.cmd — локально на проблемном ПК (консоль, VNC, KVM)
REM Симптом: mstsc "внутренняя ошибка", 3389 открыт, Event 227 / 0x8007050c
REM Требует: запуск от администратора
REM ============================================================================
setlocal EnableExtensions
set "RDP_KEY=HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
set "LOG=%TEMP%\fix-rdp-listener-%COMPUTERNAME%-%DATE:~-4%%DATE:~3,2%%DATE:~0,2%.log"

echo [%date% %time%] fix-rdp-listener start >>"%LOG%"
echo Log: %LOG%

REM --- диагностика до изменений ---
echo.
echo === Before ===
reg query "%RDP_KEY%" /v SecurityLayer 2>nul
reg query "%RDP_KEY%" /v UserAuthentication 2>nul
reg query "%RDP_KEY%" /v SSLCertificateSHA1Hash 2>nul
if errorlevel 1 echo SSLCertificateSHA1Hash: (not set)
sc query TermService | findstr /i STATE
sc query UmRdpService | findstr /i STATE

REM --- правки ---
echo.
echo === Apply fix ===
REM SecurityLayer 2 (SSL only) часто ломается без валидного listener cert
reg add "%RDP_KEY%" /v SecurityLayer /t REG_DWORD /d 1 /f
if errorlevel 1 goto :fail

reg delete "%RDP_KEY%" /v SSLCertificateSHA1Hash /f 2>nul
if errorlevel 1 echo SSLCertificateSHA1Hash: nothing to delete

REM --- перезапуск RDP ---
echo.
echo === Restart RDP services ===
net stop UmRdpService /y
net stop TermService /y
timeout /t 3 /nobreak >nul
net start TermService
net start UmRdpService

echo.
echo === After ===
reg query "%RDP_KEY%" /v SecurityLayer
sc query TermService | findstr /i STATE

echo [%date% %time%] done >>"%LOG%"
echo.
echo Готово. Проверьте mstsc с клиента.
echo NLA сейчас не трогаем. Включить обратно: UserAuthentication=1 (см. NOTE.txt)
pause
exit /b 0

:fail
echo [%date% %time%] FAILED >>"%LOG%"
echo Ошибка reg/add. Нужны права администратора.
pause
exit /b 1
