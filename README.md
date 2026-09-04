# .NET interview preparation workspace

Переносимое рабочее пространство подготовки к Middle+/Senior .NET backend интервью для российского бигтеха.

## Source of truth

- `HANDOFF.md` — текущая точка и инструкция продолжения.
- `profile.md` — цель, опыт и калибровка роли.
- `plan.md` — адаптивная программа на 2–3 месяца.
- `progress.md` — оценки и наблюдаемое evidence.
- `fundamentals.md` — базовая терминология, foundation scores и интервалы повторения.
- `timed-rubric.md` — timeboxes и отдельная оценка fluency для определений, complexity и практики.
- `learning-sources.md` — правила отбора книг, документации, видео и внешних задач.
- `materials/` — ежедневные theory packages и маршруты практики.
- `algorithms.md` — отдельный трек алгоритмических задач из второго чата.
- `sql.md` — восстановленный практический SQL-трек и точка продолжения LeetCode SQL 50.
- `sprints/` — текущие учебные спринты.
- `sessions/` — отчёты отдельных сессий.
- `evidence/repositories/` — read-only Git submodules с проектами кандидата.

## Клонирование на новом компьютере

```powershell
git clone --recurse-submodules https://github.com/Veh99/Grader.git
Set-Location 'Grader'
git submodule status --recursive
./scripts/Test-Workspace.ps1
```

Если репозиторий уже клонирован без submodules:

```powershell
git submodule update --init --recursive
```

Открой каталог в Codex и попроси:

```text
Прочитай AGENTS.md и HANDOFF.md, затем продолжи подготовку с текущей точки.
```

## Работа с двух компьютеров

Перед занятием:

```powershell
git pull --ff-only
git submodule update --init --recursive
```

После занятия:

```powershell
git status
git add HANDOFF.md profile.md plan.md progress.md fundamentals.md timed-rubric.md learning-sources.md algorithms.md sql.md README.md materials sessions sprints
git commit -m "Record interview preparation progress"
git push
```

Перед сменой компьютера всегда выполни `push`. Evidence-submodules не обновляй без отдельного решения: superproject намеренно закрепляет точные commit SHA.

## Security

В публичных evidence-репозиториях ранее обнаружены реальные-looking credentials в tracked configuration files. Submodules не копируют их содержимое в историю этого superproject, но credentials необходимо отозвать/ротировать в исходных проектах. Не добавляй реальные секреты даже в private repository.

Точный checklist без значений credentials находится в `SECURITY.md`.

## Восстановление

После первого push выполни тестовое клонирование в отдельный каталог с `--recurse-submodules`. Дополнительно храни датированный AES-256 архив с проверенным SHA-256 вне GitHub. Не синхронизируй живой `.git` через файловую облачную синхронизацию.
