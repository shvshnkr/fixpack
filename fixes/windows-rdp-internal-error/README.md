# RDP: внутренняя ошибка, 3389 открыт (Event 227)

Полная памятка: [NOTE.txt](NOTE.txt)

## Быстрый фикс на цели (консоль / VNC)

```cmd
local\fix-rdp-listener.cmd
```

или PowerShell (админ):

```powershell
.\local\Fix-RdpListener.ps1
```

## С jump-хоста (PsExec, 445 открыт)

```cmd
remote\run-via-psexec.cmd \\192.168.0.171
```

С учёткой в параметрах:

```cmd
remote\run-via-psexec.cmd \\192.168.0.171 ИМЯПК\Administrator пароль
```

## Online run (после заливки на GitHub)

```powershell
irm https://raw.githubusercontent.com/shvshnkr/fixpack/main/fixes/windows-rdp-internal-error/local/Invoke-Fix.ps1 | iex
```

С jump-хоста (скачивает target-скрипт и гоняет через PsExec — нужен интернет на jump):

```cmd
curl -fsSL -o %TEMP%\fix-rdp-target.cmd https://raw.githubusercontent.com/shvshnkr/fixpack/main/fixes/windows-rdp-internal-error/remote/fix-rdp-listener-target.cmd
psexec \\192.168.0.171 -h -c %TEMP%\fix-rdp-target.cmd
```

## Fallback

1. Скачать репозиторий ZIP с GitHub.
2. На цели: `fixes\windows-rdp-internal-error\local\fix-rdp-listener.cmd`
3. Или с jump: `remote\run-via-psexec.cmd \\IP`

## После скрипта

Проверить mstsc. При необходимости включить NLA обратно:

```cmd
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 1 /f
net stop UmRdpService & net stop TermService & net start TermService & net start UmRdpService
```
