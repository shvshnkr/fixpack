@echo off
REM Быстрая диагностика на целевом ПК (не чинит, только вывод)
setlocal
set "RDP_KEY=HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"

echo Computer: %COMPUTERNAME%
ver
echo.
echo --- Registry ---
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections
reg query "%RDP_KEY%" /v UserAuthentication
reg query "%RDP_KEY%" /v SecurityLayer
reg query "%RDP_KEY%" /v SSLCertificateSHA1Hash 2>nul || echo SSLCertificateSHA1Hash: (not set)
echo.
echo --- Services ---
sc query TermService | findstr /i "STATE NAME"
sc query UmRdpService | findstr /i "STATE NAME"
sc query SessionEnv | findstr /i "STATE NAME"
echo.
echo --- Last RdpCoreTS events (run RDP attempt first) ---
powershell -NoProfile -Command "Get-WinEvent -LogName 'Microsoft-Windows-RemoteDesktopServices-RdpCoreTS/Operational' -MaxEvents 5 -ErrorAction SilentlyContinue | Select-Object TimeCreated,Id,Message | Format-List"
pause
