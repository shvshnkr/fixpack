# fixpack

Короткие заметки и скрипты под повторяющиеся поломки — **Windows, Linux и дальше по мере надобности**. Без претензий на «экспертность»: то, что реально приходится чинить (RDP, службы, SSH, сервисы).

Сделано с помощью **[Cursor](https://cursor.com)** (AI-ассистент в IDE) по реальному кейсу; см. [ATTRIBUTION.md](ATTRIBUTION.md).

## Как пользоваться

| Способ | Когда |
|--------|--------|
| **Online run** | Есть интернет, доверяете raw.githubusercontent.com |
| **Скачал — запустил** | Клонировали репо или скачали ZIP |
| **Remote** | С jump-хоста (на Windows часто PsExec + SMB; на Linux — ssh) |

Структура одной темы:

```
fixes/<platform>-<slug>/
  NOTE.txt          — симптомы, диагностика, что помогло
  README.md         — команды copy-paste + online run
  local/            — на проблемной машине
  remote/           — с другого хоста (опционально; формат зависит от ОС)
```

Префикс в slug: `windows-`, `linux-`, … — чтобы не путать платформы.

## Online run

Репозиторий: **https://github.com/shvshnkr/fixpack**

```powershell
# Windows: локально на проблемном ПК (админ)
irm https://raw.githubusercontent.com/shvshnkr/fixpack/main/fixes/windows-rdp-internal-error/local/Invoke-Fix.ps1 | iex
```

```cmd
REM Windows: с jump-хоста через PsExec
fixes\windows-rdp-internal-error\remote\run-via-psexec.cmd \\192.168.0.171
```

Fallback: [скачать ZIP](https://github.com/shvshnkr/fixpack/archive/refs/heads/main.zip) и запустить скрипт из папки темы.

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
