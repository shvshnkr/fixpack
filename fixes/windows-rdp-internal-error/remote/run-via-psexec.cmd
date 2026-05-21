@echo off
REM ============================================================================
REM run-via-psexec.cmd — запуск с jump-хоста (ваш ноутбук в VPN)
REM
REM Использование:
REM   run-via-psexec.cmd \\192.168.0.171
REM   run-via-psexec.cmd \\192.168.0.171 ИМЯПК\Administrator пароль
REM
REM Требует: PsExec в PATH, порт 445 до цели, админ на цели
REM После net stop TermService сессия PsExec оборвется — скрипт переподключится.
REM ============================================================================
setlocal EnableExtensions

set "TARGET=%~1"
if "%TARGET%"=="" (
    echo Usage: %~nx0 \\IP_or_HOST [DOMAIN\user password]
    exit /b 1
)

set "REMOTE_USER=%~2"
set "REMOTE_PASS=%~3"

REM Путь к target-скрипту рядом с этим bat
set "TARGET_SCRIPT=%~dp0fix-rdp-listener-target.cmd"
if not exist "%TARGET_SCRIPT%" (
    echo Missing: %TARGET_SCRIPT%
    exit /b 1
)

where psexec >nul 2>&1
if errorlevel 1 (
    echo PsExec not in PATH. Download Sysinternals PsExec.
    exit /b 1
)

echo === Step 1: IPC$ session (if credentials provided) ===
if not "%REMOTE_USER%"=="" (
    net use "%TARGET%\IPC$" /user:%REMOTE_USER% %REMOTE_PASS%
    if errorlevel 1 (
        echo net use failed. Check user/password. Hostname must be TARGET machine name.
        exit /b 1
    )
)

echo === Step 2: Run fix on target ===
if "%REMOTE_USER%"=="" (
    psexec %TARGET% -h -accepteula -c "%TARGET_SCRIPT%"
) else (
    psexec %TARGET% -u %REMOTE_USER% -p %REMOTE_PASS% -h -accepteula -c "%TARGET_SCRIPT%"
)
set "RC=%ERRORLEVEL%"

if %RC% neq 0 (
    echo PsExec exit code: %RC%
    echo If disconnected during TermService stop, wait 30s and run again:
    echo   psexec %TARGET% -h cmd
    echo   net start TermService
    echo   net start UmRdpService
)

echo === Step 3: Verify port 3389 from this machine (optional) ===
set "HOST=%TARGET%"
if "%HOST:~0,2%"=="\\" set "HOST=%HOST:~2%"
powershell -NoProfile -Command "Test-NetConnection -ComputerName '%HOST%' -Port 3389 | Select-Object TcpTestSucceeded"

echo.
echo Test RDP with mstsc to %TARGET%
exit /b %RC%
