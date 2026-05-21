@echo off
REM Скачивает fix-rdp-listener-target.cmd с GitHub и запускает через PsExec -c
REM Usage: run-online-via-psexec.cmd \\192.168.0.171 USER
REM   USER = GitHub username (репозиторий fixpack)

setlocal
set "TARGET=%~1"
set "GH_USER=%~2"
if "%TARGET%"=="" goto :usage
if "%GH_USER%"=="" set "GH_USER=shvshnkr"

set "URL=https://raw.githubusercontent.com/%GH_USER%/fixpack/main/fixes/windows-rdp-internal-error/remote/fix-rdp-listener-target.cmd"
set "TMP=%TEMP%\fix-rdp-listener-target-%RANDOM%.cmd"

echo Download: %URL%
curl -fsSL -o "%TMP%" "%URL%"
if errorlevel 1 (
    echo curl failed. Use run-via-psexec.cmd with local copy instead.
    exit /b 1
)

psexec %TARGET% -h -accepteula -c "%TMP%"
del "%TMP%" 2>nul
exit /b %ERRORLEVEL%

:usage
echo Usage: %~nx0 \\target.ip GitHubUsername
exit /b 1
