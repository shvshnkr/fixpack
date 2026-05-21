# Команды copy-paste (без скриптов)

Замените `192.168.0.171` и `ИМЯПК\логин` на свои значения. Выполняйте **по одной строке** в cmd (не склеивайте в PowerShell при PsExec).

---

## 1. Проверка с вашего ПК (клиент)

```powershell
Test-NetConnection 192.168.0.171 -Port 3389
Test-NetConnection 192.168.0.171 -Port 445
Test-NetConnection 192.168.0.171 -Port 135
```

`3389 = True` — сеть до RDP есть. `445 = True` — можно PsExec.

---

## 2. Доступ без RDP (jump → цель)

```cmd
net use \\192.168.0.171\IPC$ /user:ИМЯПК\Administrator пароль
```

```cmd
psexec \\192.168.0.171 -h cmd
```

Если `net use` уже успешен — PsExec **без** `-u` / `-p`:

```cmd
psexec \\192.168.0.171 -h cmd
```

---

## 3. Диагностика на цели (cmd, админ)

```cmd
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections
```

```cmd
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication
```

```cmd
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v SecurityLayer
```

```cmd
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v SSLCertificateSHA1Hash
```

```cmd
sc query TermService
```

```cmd
sc query UmRdpService
```

Журнал (после попытки mstsc):

```powershell
Get-WinEvent -LogName "Microsoft-Windows-RemoteDesktopServices-RdpCoreTS/Operational" -MaxEvents 5 | Format-List TimeCreated, Id, Message
```

Ожидаемо при этой поломке: **131** (TCP принят), **227** + `0x8007050c`.

---

## 4. Починка на цели (cmd, админ) — то, что помогло

**SecurityLayer 2 → 1:**

```cmd
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v SecurityLayer /t REG_DWORD /d 1 /f
```

**Опционально — удалить привязку к старому SSL-сертификату (если ключ есть):**

```cmd
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v SSLCertificateSHA1Hash /f
```

**Перезапуск RDP** (PsExec оборвётся на `net stop TermService` — зайти снова через минуту):

```cmd
net stop UmRdpService
```

```cmd
net stop TermService
```

```cmd
net start TermService
```

```cmd
net start UmRdpService
```

Проверка:

```cmd
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v SecurityLayer
```

С клиента: **mstsc** → `192.168.0.171`.

---

## 5. Тест NLA (если починка не помогла)

Временно отключить NLA:

```cmd
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 0 /f
```

```cmd
net stop UmRdpService
```

```cmd
net stop TermService
```

```cmd
net start TermService
```

```cmd
net start UmRdpService
```

Если **не помогло** — дело не только в NLA; смотрите SecurityLayer и лог 227.

---

## 6. Включить NLA обратно (после успешного RDP)

```cmd
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 1 /f
```

```cmd
net stop UmRdpService
```

```cmd
net stop TermService
```

```cmd
net start TermService
```

```cmd
net start UmRdpService
```

---

## 7. Всё с jump одной цепочкой (PsExec, без скачивания bat)

После `net use \\192.168.0.171\IPC$ ...` можно выполнить на цели одной строкой:

```cmd
psexec \\192.168.0.171 -h cmd /c "reg add \"HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\" /v SecurityLayer /t REG_DWORD /d 1 /f && reg delete \"HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\" /v SSLCertificateSHA1Hash /f 2>nul && net stop UmRdpService /y && net stop TermService /y && timeout /t 3 /nobreak >nul && net start TermService && net start UmRdpService"
```

Если сессия оборвалась — переподключиться и только:

```cmd
psexec \\192.168.0.171 -h cmd /c "net start TermService && net start UmRdpService"
```

---

## Скрипты (необязательно)

Те же шаги автоматизированы в `local\` и `remote\` — если удобнее, чем копировать блоки выше.
