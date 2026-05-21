# RDP: внутренняя ошибка, 3389 открыт (Event 227)

Памятка: [NOTE.txt](NOTE.txt) · **Команды без скриптов: [COMMANDS.md](COMMANDS.md)**

## Команды (copy-paste)

### С вашего ПК

```powershell
Test-NetConnection 192.168.0.171 -Port 3389
Test-NetConnection 192.168.0.171 -Port 445
```

### Jump → цель (PsExec)

```cmd
net use \\192.168.0.171\IPC$ /user:ИМЯПК\Administrator пароль
psexec \\192.168.0.171 -h cmd
```

### Починка на цели (по одной строке)

```cmd
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v SecurityLayer /t REG_DWORD /d 1 /f
```

```cmd
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v SSLCertificateSHA1Hash /f
```

```cmd
net stop UmRdpService
net stop TermService
net start TermService
net start UmRdpService
```

Полный список (диагностика, NLA, однострочник через psexec): **[COMMANDS.md](COMMANDS.md)**

---

## Скрипты (по желанию)

| Где | Файл |
|-----|------|
| На цели (VNC) | `local\fix-rdp-listener.cmd` |
| На цели | `local\Fix-RdpListener.ps1` |
| С jump | `remote\run-via-psexec.cmd \\192.168.0.171` |

## Online run

```powershell
irm https://raw.githubusercontent.com/shvshnkr/fixpack/main/fixes/windows-rdp-internal-error/local/Invoke-Fix.ps1 | iex
```

Только команды в терминале (без irm) — см. [COMMANDS.md](COMMANDS.md).

## NLA обратно

```cmd
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 1 /f
net stop UmRdpService
net stop TermService
net start TermService
net start UmRdpService
```
