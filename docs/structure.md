# Структура репозитория

## Идея

Один репозиторий — много **независимых** тем в `fixes/<slug>/`. Платформа задаётся префиксом slug, не отдельным корнем репо:

- `windows-rdp-internal-error`
- `linux-ssh-tunnel-stale` (пример на будущее)

Темы не связаны между собой; папку можно копировать в тикет или на флешку.

## Именование slug

- латиница, дефис
- первый сегмент = платформа: `windows-`, `linux-`, `macos-`, …
- дальше — симптом или ID события, не маркетинговое имя

## Файлы в теме

| Файл | Назначение |
|------|------------|
| `NOTE.txt` | Памятка: симптомы, диагностика, что сработало |
| `README.md` | То же для GitHub + online run |
| `local/*` | Запуск **на целевой** машине |
| `remote/*` | Запуск **с jump-хоста** (опционально) |

Формат `local/` / `remote/` зависит от ОС:

| Платформа | local | remote (пример) |
|-----------|--------|------------------|
| Windows | `.cmd`, `.ps1` | PsExec + `.cmd` |
| Linux | `.sh` | `ssh target 'bash -s' < script.sh` |

## Online run

1. Одна точка входа в `local/` (`Invoke-Fix.ps1`, `run.sh`, …).
2. В README темы — строка `irm` / `curl | bash` на raw URL GitHub.
3. **Fallback** — тот же файл из клона/ZIP.

## Remote (Windows, PsExec)

```
[jump] run-via-psexec.cmd \\TARGET
         └─ psexec \\TARGET -h -c fix-....-target.cmd
```

После `net stop TermService` сессия обрывается — переподключиться и дозапустить службы.

## Remote (Linux, будущее)

Обычно `ssh` + скрипт в `remote/`; без PsExec/SMB.

## Новая тема

1. Скопировать ближайшую тему той же платформы.
2. Заполнить `NOTE.txt` (ОС, дата).
3. Строка в корневой `README.md`.

## Сделано с Cursor

См. [ATTRIBUTION.md](../ATTRIBUTION.md) в корне репозитория.
