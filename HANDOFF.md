# Handoff

Обновлено: 2026-08-28, audit update

## Цель

- Минимум: уверенный Middle+ .NET backend.
- Желаемый результат: приблизиться к Senior и уверенно защищать production-решения.
- Рынок: российский бигтех, банки и маркетплейсы.
- Горизонт: 2–3 месяца.
- Нагрузка: 8 часов в неделю.
- Язык: русский.

## Как продолжать

1. Прочитать `AGENTS.md`, `profile.md`, `plan.md`, `progress.md`, `algorithms.md` и `sprints/week-01-foundations.md`.
2. Считать `progress.md` source of truth для оценок; не повышать уровень по ответам после подсказки.
3. Продолжать по одному вопросу за раз.
4. Если теория неизвестна, сначала объяснить её и затем дать короткое закрепление; не оценивать незнакомую теорию как независимый провал.
5. Просить confidence там, где это даёт сигнал калибровки, но не после каждого ответа.

## Текущая точка

Спринт 1, сессия 4: async и bounded pipeline. Тема находится в состоянии `learning`.

Важно: старый handoff от 2026-08-25 указывал остановку на вопросе `ProduceAsync`. 2026-08-28 кандидат сообщил, что фактическая последняя точка в интервью-чате уже была дальше — проверка другого метода, предположительно `CollectAsync`. Audit репозитория и GitHub показал, что `CollectAsync` нигде не сохранён, а `progress.md` заканчивается записью `sprint 1/session 4.2`. Поэтому `ProduceAsync` считать stale fallback, а не актуальной точкой продолжения.

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
- Перед сменой ПК: `git status`, `git add HANDOFF.md profile.md plan.md progress.md algorithms.md README.md sprints sessions`, `git commit`, `git push`.
