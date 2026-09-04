# Handoff

Обновлено: 2026-09-04, day 3 assigned

## Цель

- Минимум: уверенный Middle+ .NET backend.
- Желаемый результат: приблизиться к Senior и уверенно защищать production-решения.
- Рынок: российский бигтех, банки и маркетплейсы.
- Горизонт: сначала 14-дневный интенсив, затем адаптивное продолжение до 2–3 месяцев.
- Нагрузка: дни 1–12 — theory package около 4 часов плюс 1.5–2.5 часа практики/опроса; дни 13–14 — mock. Долгосрочно 8 часов в неделю.
- Язык: русский.

## Как продолжать

1. Прочитать `AGENTS.md`, `profile.md`, `plan.md`, `progress.md`, `fundamentals.md`, `timed-rubric.md`, `learning-sources.md`, `algorithms.md` и `sprints/accelerated-14-day.md`.
2. Считать `progress.md` source of truth для оценок; не повышать уровень по ответам после подсказки.
3. Продолжать по одному вопросу за раз.
4. Если теория неизвестна, сначала объяснить её и затем дать короткое закрепление; не оценивать незнакомую теорию как независимый провал.
5. Просить confidence там, где это даёт сигнал калибровки, но не после каждого ответа.
6. В каждой сессии выделять 10–15 минут на фундаментальный retrieval по `fundamentals.md`; определения и applied evidence оценивать раздельно.
7. В timed-вопросах сначала объявлять контракт из `timed-rubric.md`; не смешивать превышение времени с фактической ошибкой.

## Текущая точка

Спринт 1, день 3: выдан 240-минутный theory package `materials/day-03-clr-memory-gc.md`. Следующая точка — дождаться сообщения `День 3 изучен`, затем провести timed fundamentals, allocation/lifetime trace, GC-root investigation и production memory case. `CollectAsync` остаётся отложенным долгом дня 2; не повторять foundation-вопросы по async при возврате к нему.

Параллельные task tracks: алгоритмы продолжаются с `704. Binary Search` по `algorithms.md`; SQL продолжается с независимого повторного решения `1661. Average Time of Process per Machine` по `sql.md`. SQL-история восстановлена 2026-09-04 из задачи Codex `Найди последний вопрос по алгоритмам`.

2026-08-31 создан новый эквивалентный code-review snippet `CollectAsync` и сохранён в `sessions/2026-08-31-async-collectasync.md`, но кандидат ещё не отвечал. Перед ответом кандидат запросил постоянный фундаментальный слой подготовки: простые вопросы об async, памяти/GC, базах данных, брокерах и архитектуре. Изменение принято и записано в `AGENTS.md`, `plan.md`, `fundamentals.md` и текущий sprint.

День 1 и timed-опрос завершены. Полный отчёт: `sessions/2026-09-01-day-01-async-assessment.md`. Итог `learning`: сильнее всего throughput/latency, первый incomplete `await`, deferred enumeration и unbounded/shared-state review; слабо удержаны one-thread concurrency, Task/state-machine causality, cancellation state, `WhenAll` и компилируемый bounded rewrite.

Точка продолжения: theory package дня 2 выдан в `materials/day-02-async-pipelines.md`. Кандидат проходит 240 минут теории и active notes, включая CPU/OS thread/ThreadPool/`TaskScheduler` bridge, затем возвращается к полной реализации `CollectAsync` из `sessions/2026-08-31-async-collectasync.md`, failure trace и тестам. Дни 3–4 расширены CPU/cache/.NET memory model и lock-free темами. Не считать исправленный сразу после объяснения ответ независимым evidence. Delayed retest назначен на 2026-09-03 или 2026-09-04.

Важно: старый handoff от 2026-08-25 указывал остановку на вопросе `ProduceAsync`. 2026-08-28 кандидат сообщил, что фактическая последняя точка в интервью-чате уже была дальше — проверка другого метода, предположительно `CollectAsync`. Audit репозитория и GitHub показал, что исходный `CollectAsync` не был сохранён, поэтому `ProduceAsync` считается stale fallback. С 2026-08-31 переносимой заменой исходного вопроса является session-файл `sessions/2026-08-31-async-collectasync.md`.

Что точно разобрано и зафиксировано:

- вызов `async`-метода начинается сразу и идёт до первого incomplete `await`;
- `ToArray()` перечисляет LINQ и вызывает все 10 000 `LoadAsync`;
- `Task.WhenAll` не запускает задачи и сохраняет порядок входного массива результатов;
- `SemaphoreSlim(20)` ограничивает active I/O, но не количество ожидающих задач;
- bounded `Channel` ограничивает очередь и создаёт backpressure;
- `WhenAll` не отменяет остальные задачи автоматически;
- cancellation работает только при наблюдении токена нижележащей операцией;
- `WaitAsync` должен завершиться до входа в `try/finally`, иначе возможен лишний `Release`.

Как продолжить интервью-чат без отката:

1. Сначала восстановить из контекста чата последний snippet/вопрос по `CollectAsync` и записать его в `progress.md` или новый файл `sessions/YYYY-MM-DD-async-collectasync.md`.
2. Если контекст чата недоступен, прямо спросить кандидата прислать/пересказать `CollectAsync`; не начинать заново с `ProduceAsync`, кроме как для короткой consistency-check.
3. Оценить ответ по обычной rubric: correctness, depth, production judgment, communication. Отдельно отметить assistance type: если кандидат отвечает после восстановления из файла/объяснения, это не `independent` evidence.
4. После `CollectAsync` закрыть оставшиеся пункты async pipeline: producer completion/error propagation, per-item error contract, cancellation, input-order preservation и bounded worker implementation.
5. Выполнить delayed retest по EF tracking, индексам и READ COMMITTED.

Минимальный expected focus для `CollectAsync`, если snippet восстановить нельзя: проверить, не создаёт ли метод unbounded tasks/list growth; как он завершает consumers при producer/consumer fault; как агрегирует результаты, ошибки и cancellation; сохраняет ли input order; есть ли timeout/backpressure и deterministic completion.

## Второй чат: алгоритмические задачи

В проекте есть параллельный чат по алгоритмическим задачам. Portable source of truth для него: `algorithms.md`.

Текущая политика:

- не смешивать алгоритмический evidence с backend-readiness оценками в `progress.md`;
- после каждой значимой алгоритмической задачи обновлять `algorithms.md`;
- если во втором чате есть незаписанные задачи, сначала восстановить их из контекста того чата и только затем продолжать;
- оценивать не только факт AC, но и объяснение инварианта, сложность, edge cases и качество коммуникации.

На момент этого handoff подробная история алгоритмического чата не была сохранена в файлах проекта, поэтому `algorithms.md` содержит стартовый переносимый протокол и явный gap по фактическому evidence.
## Текущий readiness

Baseline: Middle по фундаментальному backend reasoning, отдельные Middle+ сигналы по messaging/idempotency. До стабильного Middle+/Senior пока не хватает независимого evidence по SQL/indexes/transactions, async semantics, testing и production diagnosis.

## Portability notes

- `$dotnet-interview-coach` — внешняя user-scoped зависимость и может отсутствовать на другом компьютере. При её отсутствии следовать `AGENTS.md` и текущим Markdown-файлам.
- Evidence-проекты должны быть read-only submodules на commit SHA, записанных в `.gitmodules` и Git index.
- Не читать и не публиковать значения секретов из конфигураций evidence-проектов.
- Перед сменой ПК: `git status`, `git add HANDOFF.md profile.md plan.md progress.md fundamentals.md timed-rubric.md learning-sources.md algorithms.md README.md materials sprints sessions`, `git commit`, `git push`.
