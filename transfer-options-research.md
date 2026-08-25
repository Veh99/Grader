# Варианты переноса `interview-prep` между Windows-компьютерами

Дата исследования: 2026-08-25. Рассматривался перенос текущего каталога `C:\Users\kasilov\Desktop\Grader\interview-prep`. Никакие репозитории и файлы никуда не публиковались.

## Краткая рекомендация

Основной вариант: **приватный GitHub-репозиторий для материалов подготовки + три публичных evidence-репозитория как Git submodules, закреплённые на текущих commit SHA**.

Для защиты от потери GitHub-аккаунта, ошибочного удаления или повреждения данных добавить независимый второй слой: **периодический зашифрованный 7z snapshot с SHA-256 checksum в OneDrive или на внешнем носителе**. Не синхронизировать OneDrive-ом живой рабочий каталог с `.git`: официальная Git FAQ прямо предупреждает, что файловая облачная синхронизация не понимает структуру Git и может привести к повреждению репозитория и потере данных ([Git FAQ: syncing a working tree](https://git-scm.com/docs/gitfaq#Documentation/gitfaq.txt-HowdoIsyncaworkingtreeacrosssystems)).

Итого: GitHub даёт удобную ежедневную синхронизацию и историю прогресса, а зашифрованный snapshot — независимое восстановление. Это соответствует практической схеме 3-2-1 лучше, чем любой из вариантов по отдельности.

## Что обнаружено в текущем проекте

- Верхний каталог `interview-prep` пока **не является Git-репозиторием**.
- Объём: около **12,1 МБ**, 1181 файл, включая служебные данные вложенных `.git`.
- Основной прогресс уже материализован в переносимых файлах: `plan.md`, `profile.md`, `progress.md`, `sessions/`, `sprints/`, `evidence/`.
- В `evidence/repositories/` находятся три самостоятельных, чистых Git-репозитория:

  | Репозиторий | Remote | Текущий commit |
  |---|---|---|
  | `LawyerAI` | `https://github.com/Veh99/LawyerAI.git` | `c3d995aaba464243bd2e10273fedfbcd749be7d3` |
  | `Secret_Project` | `https://github.com/eviolspirid777/Secret_Project.git` | `b1a702d957f08627da5c76b7c9b259c376b87a77` |
  | `ValikuloDance` | `https://github.com/Veh99/ValikuloDance.git` | `6c779f53c38611d1ad105cdb26d53b346de1639e` |

- `LawyerAI/Start-LawyerAI.Services.ps1` содержит абсолютный путь `C:\Users\kasilov\Desktop\Startup\LawyerAI`; на другом ПК этот default не сработает. Для evidence-копии лучше не менять upstream-код, а зафиксировать ограничение в setup-инструкции; если скрипт реально нужен, отдельным согласованным изменением заменить default на путь относительно `$PSScriptRoot`.
- В публичном `Secret_Project` Git отслеживает `SECRET_PROJECT_WEB/.env`. Это проверка только имени и статуса файла; содержимое не читалось. Перед использованием необходимо проверить значения. Если там есть реальные credentials, их нужно отозвать/ротировать независимо от выбранного способа переноса. GitHub рекомендует не коммитить незашифрованные credentials даже в приватные репозитории ([GitHub: keeping API credentials secure](https://docs.github.com/en/rest/authentication/keeping-your-api-credentials-secure)).
- Найдены `appsettings*.json`; их наличие само по себе не означает утечку, но перед первым push нужен secrets review содержимого и истории. `.gitignore` действует только на ещё не отслеживаемые файлы; уже отслеживаемые файлы он не исключит ([gitignore documentation](https://git-scm.com/docs/gitignore)).

## Сравнение вариантов

| Вариант | Удобство ежедневной работы | История | Точная копия локального состояния | Безопасность | Надёжность восстановления | Вердикт |
|---|---:|---:|---:|---:|---:|---|
| Приватный GitHub + submodules | Высокое | Полная для committed-файлов | Нет: не переносит uncommitted, локальные настройки и Codex user state | Высокая после secrets review и 2FA | Высокая, но нужен отдельный backup | **Основной** |
| Зашифрованный 7z snapshot в OneDrive/на носителе | Среднее | Только отдельные snapshots | Да, включая вложенные `.git` и локальные файлы | Высокая при сильной уникальной passphrase и шифровании заголовков | Высокая при проверке checksum и тестовом распаковывании | **Резервный слой / разовый перенос** |
| OneDrive-синхронизация живой папки | Очень высокое внешне | Версии отдельных файлов | Формально да, но неконсистентно во время записи | Зависит от аккаунта и локальных файлов | Низкая для Git working tree | **Не использовать для живого `.git`** |
| `git bundle` | Низкое/среднее | Полная история refs/commits одного репозитория | Нет | Файл bundle не зашифрован | Высокая после `git bundle verify`, но требует нескольких артефактов | **Air-gap/архив, не основной workflow** |

## Вариант 1 — приватный GitHub-репозиторий

### Почему это лучший основной вариант

- Private repository доступен владельцу и явно добавленным пользователям ([GitHub: about repositories](https://docs.github.com/en/repositories/creating-and-managing-repositories/about-repositories#about-repository-visibility)).
- Обычные `commit` / `push` / `pull` дают понятную историю изменений, конфликт-резолюцию и проверяемое состояние на обоих ПК.
- Материалы подготовки в основном текстовые и малы; Git подходит им лучше архивной синхронизации.
- Текущие публичные evidence-репозитории можно не дублировать. Submodule хранит URL и конкретный commit; `git clone --recurse-submodules` восстанавливает ровно закреплённые состояния, включая вложенные submodules ([Pro Git: Submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)).

### Предлагаемая структура

```text
interview-prep/                    # private superproject
  .gitignore
  .gitattributes
  AGENTS.md                        # только проектные инструкции, если нужны
  README.md                        # bootstrap и правила переноса
  dependencies.md                 # Git/.NET/Codex/skill dependencies
  plan.md
  profile.md
  progress.md
  sessions/
  sprints/
  evidence/
    repositories/
      LawyerAI/                    # submodule, pinned SHA
      Secret_Project/              # submodule, pinned SHA
      ValikuloDance/                # submodule, pinned SHA
```

После клонирования: `git clone --recurse-submodules <private-url>`. Если репозиторий уже клонирован без submodules: `git submodule update --init --recursive`. Git фиксирует submodule на определённом commit, поэтому доказательства не изменятся неожиданно при обновлении upstream.

### Security gates до первого push

1. Выполнить secrets review **всех добавляемых файлов и Git history**, включая `.env`, `appsettings*.json`, ключи, токены, connection strings и персональные данные из ответов/профиля.
2. Не переносить secrets в Git даже при private visibility. Хранить только `.env.example`/шаблоны без значений, реальные значения — в password manager или локальном ignored-файле.
3. Если credential когда-либо был committed, одного удаления файла недостаточно: сначала revoke/rotate, затем при необходимости переписать историю. GitHub подчёркивает, что удаление sensitive data из истории — координационно сложная процедура ([GitHub: removing sensitive data](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)).
4. Включить 2FA/passkey и сохранить recovery codes отдельно. GitHub предупреждает, что без доступного recovery method аккаунт может быть потерян безвозвратно ([GitHub: 2FA recovery](https://docs.github.com/en/authentication/securing-your-account-with-two-factor-authentication-2fa/recovering-your-account-if-you-lose-your-2fa-credentials)).
5. Перед каждым push проверять staged diff; не рассчитывать только на private visibility.

### Вложенные репозитории: почему именно submodules

Нельзя просто сделать `git add evidence/repositories/...` и ожидать, что внешний репозиторий сохранит содержимое вложенных `.git` как обычные файлы. Корректные модели:

- **Рекомендуется:** submodules — сохраняют provenance, upstream URL и точный SHA без копирования публичного исходного кода в private history.
- Альтернатива попроще: исключить `evidence/repositories/` и хранить manifest URL + SHA + bootstrap script. Минус — меньше автоматизации и выше риск клонировать не тот commit.
- Vendor-копия исходников без `.git` оправдана только если нужна независимость от исчезновения upstream. Здесь она раздувает private repo и теряет оригинальную Git-историю; для текущего сценария не рекомендуется.

Submodules требуют дисциплины: локальные изменения внутри submodule нужно отдельно commit/push в его remote; иначе superproject может ссылаться на недоступный commit. Официальное руководство рекомендует проверку `git push --recurse-submodules=check` ([Pro Git: Publishing Submodule Changes](https://git-scm.com/book/en/v2/Git-Tools-Submodules#_publishing_submodule_changes)). В этом проекте evidence-репозитории следует считать read-only.

### Ограничение: GitHub не является единственной резервной копией

GitHub документирует отдельную процедуру backup через `git clone --mirror`, что само по себе означает необходимость независимого disaster-recovery слоя; mirror clone сохраняет Git history, но не рабочее дерево и внешние данные ([GitHub: backing up a repository](https://docs.github.com/en/repositories/archiving-a-github-repository/backing-up-a-repository)). Поэтому нужен второй зашифрованный snapshot вне GitHub.

## Вариант 2 — зашифрованный portable archive

### Рекомендуемая реализация

1. Закрыть Codex/IDE и убедиться, что Git-операции не выполняются.
2. Создать 7z archive всего `interview-prep` с AES-256, сильной уникальной passphrase и **шифрованием заголовков** (`-mhe=on`), чтобы не раскрывать имена файлов. Официальная 7-Zip документация подтверждает AES-256 и password-based key derivation на SHA-256 ([7z format](https://www.7-zip.org/7z.html)); `-mhe` шифрует имена файлов ([7-Zip password switch](https://documentation.help/7-Zip/password.htm)).
3. Не передавать пароль рядом с архивом; сохранить его в password manager и убедиться, что доступен recovery method.
4. Рассчитать SHA-256 (`Get-FileHash ... -Algorithm SHA256`), сохранить checksum отдельно и выполнить `7z t` для теста архива.
5. Положить immutable-файл с датой в имени в OneDrive или на внешний носитель; не перезаписывать единственную копию.
6. На втором ПК сначала проверить SHA-256 и `7z t`, затем распаковать в локальный несинхронизируемый каталог.

### Плюсы и минусы

Плюсы: переносится точное состояние, включая вложенные `.git`, ignored/untracked-файлы и локальные артефакты; подходит для air-gap и аварийного восстановления.

Минусы: ручной snapshot быстро устаревает; нет удобного merge между двумя ПК; потеря passphrase означает потерю данных; переносит потенциальные secrets целиком. Архив нужно создавать только в спокойном состоянии: Git предупреждает, что файловое копирование репозитория во время записи может дать повреждённую копию ([git-bundle discussion](https://git-scm.com/docs/git-bundle#_discussion)).

### OneDrive — только транспорт архива, не Git working tree

OneDrive синхронизирует добавления, изменения и удаления в обе стороны ([Microsoft: sync files with OneDrive](https://support.microsoft.com/en-US/onedrive/sync-your-computer-s-files-and-folders-with-onedrive)). Он предоставляет version history для файлов и, для подходящих Microsoft 365 аккаунтов, восстановление OneDrive за последние 30 дней ([Microsoft: restore a previous version](https://support.microsoft.com/en-US/onedrive/restore-a-previous-version-of-a-file-stored-in-onedrive), [Microsoft: restore your OneDrive](https://support.microsoft.com/en-us/onedrive/restore-your-onedrive)). Это полезно для immutable `.7z`, но не делает непрерывную синхронизацию `.git` безопасной: Git официально запрещает рассчитывать на file-by-file cloud sync для репозитория из-за риска broken refs, missing objects и data loss ([Git FAQ](https://git-scm.com/docs/gitfaq#Documentation/gitfaq.txt-HowdoIsyncaworkingtreeacrosssystems)).

## Вариант 3 — `git bundle`

`git bundle create backup.bundle --all` создаёт self-contained перенос refs и reachable commits; bundle можно проверить `git bundle verify` и клонировать через `git clone backup.bundle <directory>` ([git-bundle documentation](https://git-scm.com/docs/git-bundle)).

Для текущей структуры это неудобно:

- верхний `interview-prep` ещё не Git-репозиторий;
- потребуется отдельный bundle для superproject и каждого из трёх evidence-репозиториев;
- bundle **не включает** index, working tree, stash, repository config, hooks и прочее локальное состояние — это прямо указано в официальной документации;
- bundle сам по себе не зашифрован, поэтому для облака/USB его всё равно следует помещать в зашифрованный контейнер;
- регулярный двухсторонний workflow с incremental bundles сложнее и более ошибкоопасен, чем push/pull.

Использовать `git bundle` стоит для offline/air-gapped передачи или дополнительного Git-native архива, но не как основной способ ежедневной работы.

## Codex, история подготовки и зависимости

Перенос каталога сохраняет только то, что находится в каталоге. Долговечное состояние подготовки уже правильно вынесено в `progress.md`, `sessions/`, `profile.md` и `plan.md`; именно эти файлы должны считаться source of truth. История текущего task/chat и локальное состояние приложения не являются частью Git working tree автоматически.

Codex-зависимости требуют отдельной bootstrap-проверки:

- проектные инструкции лучше хранить в корневом `AGENTS.md`: Codex читает его от Git root к текущему каталогу ([OpenAI Docs: AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md));
- переносимые project-specific настройки можно хранить в `.codex/config.toml`, но Codex загружает их только для trusted project; пользовательские настройки остаются в `~/.codex/config.toml` ([OpenAI Docs: config basics](https://learn.chatgpt.com/docs/config-file/config-basic));
- skill `dotnet-interview-coach` сейчас установлен вне проекта в пользовательском Codex home и **не попадёт** в Git/архив проекта, если архивируется только `interview-prep`. Codex ищет repo-scoped skills в `.agents/skills` от CWD до repository root, а user-scoped skills — в `$HOME/.agents/skills` ([OpenAI Docs: where Codex loads local skills](https://learn.chatgpt.com/docs/build-skills#where-codex-loads-local-skills));
- безопасный вариант: записать skill/plugin dependencies и процедуру установки в `dependencies.md`; если конкретный skill принадлежит пользователю и его лицензия допускает репликацию — можно отдельно согласовать vendoring в `.agents/skills/`. Не копировать автоматически system skills, plugin cache, credentials, токены, SSH-ключи или весь `~/.codex`;
- абсолютные пути в `.codex/config.toml`, skill metadata/scripts и проектных скриптах должны быть заменены на относительные или документированы как machine-local.

На новом ПК минимально понадобятся: Git for Windows, GitHub authentication, Codex/ChatGPT desktop app, подходящий .NET SDK для практических заданий, 7-Zip для recovery archive и отдельно восстановленные пользовательские skills/plugins.

## Предлагаемый план реализации после согласования

### План A — рекомендуемый

1. Сделать read-only secrets audit и сформировать точный allowlist файлов для superproject.
2. Добавить `.gitignore`, `.gitattributes`, `README.md`, `dependencies.md` и при необходимости project `AGENTS.md`/`.codex/config.toml` без secrets и абсолютных путей.
3. Инициализировать Git в `interview-prep`.
4. Оформить три чистых evidence-репозитория как submodules на указанных SHA.
5. Создать локальный первый commit и проверить воспроизводимость во временном каталоге через clone + recursive submodules.
6. Только после повторного secrets review создать **private** GitHub repository и push.
7. Включить 2FA/passkey, безопасно сохранить recovery codes.
8. Создать и проверить зашифрованный 7z snapshot как независимый backup.

### План B — если GitHub сейчас нежелателен

Создать проверенный AES-256 7z snapshot всего каталога и перенести через OneDrive/USB. Это быстрее, сохраняет всё локальное состояние, но дальнейшие изменения придётся переносить повторными immutable snapshots вручную.

### План C — если нужен полный air-gap

Сначала инициализировать/закоммитить superproject, затем создать четыре проверенных full bundles и manifest с SHA-256; упаковать bundles и необходимые non-Git файлы в один зашифрованный 7z. Это наиболее автономно, но заметно сложнее в эксплуатации.

## Решение, которое предлагается согласовать

Согласовать **План A: private GitHub superproject + pinned public submodules + отдельный encrypted 7z backup**. Перед публикацией обязательны filename/content/history secrets review и отдельное решение по отслеживаемому `.env` в публичном `Secret_Project`. До согласования никаких публикаций, Git-инициализации или изменений структуры выполнять не следует.
