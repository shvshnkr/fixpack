# fixpack

Короткие заметки и скрипты под повторяющиеся поломки — **Windows, Linux и дальше по мере надобности**. Без претензий на «экспертность»: то, что реально приходится чинить (RDP, службы, SSH, сервисы).

Сделано с помощью **[Cursor](https://cursor.com)** (AI-ассистент в IDE) по реальному кейсу; см. [ATTRIBUTION.md](ATTRIBUTION.md).

## Как пользоваться

| Способ | Когда |
|--------|--------|
| **Команды в README / COMMANDS.md** | Copy-paste в cmd/PowerShell, ничего не качать |
| **Online run** | `irm` с GitHub, если удобнее одной строкой |
| **Скрипты в репо** | Автоматизация тех же шагов |
| **Remote** | С jump-хоста (Windows: PsExec; Linux: ssh) |

Структура одной темы:

```
fixes/<platform>-<slug>/
  NOTE.txt          — краткая памятка
  COMMANDS.md       — все команды copy-paste (без скриптов)
  README.md         — кратко + ссылка на COMMANDS.md
  local/            — на проблемной машине
  remote/           — с другого хоста (опционально; формат зависит от ОС)
```

Префикс в slug: `windows-`, `linux-`, … — чтобы не путать платформы.

## Репозиторий

**https://github.com/shvshnkr/fixpack**

### RDP — команды без скачивания

Открыть в браузере и копировать:  
[fixes/windows-rdp-internal-error/COMMANDS.md](fixes/windows-rdp-internal-error/COMMANDS.md)

Минимум на цели (cmd, админ):

```cmd
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v SecurityLayer /t REG_DWORD /d 1 /f
net stop UmRdpService
net stop TermService
net start TermService
net start UmRdpService
```

### Online run / скрипты (необязательно)

```powershell
irm https://raw.githubusercontent.com/shvshnkr/fixpack/main/fixes/windows-rdp-internal-error/local/Invoke-Fix.ps1 | iex
```

## Ограничения

- Скрипты могут менять реестр, службы, конфиги — нужны права администратора/root.
- Remote-доступ (PsExec, SSH) — только там, где вам это разрешено.
- Перед массовым запуском — тест на одной машине.

## Список тем

| Slug | Платформа | Проблема |
|------|-----------|----------|
| [windows-rdp-internal-error](fixes/windows-rdp-internal-error/) | Windows | mstsc: «внутренняя ошибка», Event 227 / 0x8007050c, TCP 3389 открыт |

## Лицензия

MIT — на свой риск.
