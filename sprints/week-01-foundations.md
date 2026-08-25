# Спринт 1 — фундамент Middle+ backend

Период: ближайшие 7 дней  
Бюджет: 8 часов (рабочее допущение)  
Цель: закрыть prerequisites, выявленные baseline; не гнаться за количеством interview questions.

Бюджет подтверждён кандидатом. Все упражнения выполняются с live-coding narration: requirements → assumptions → plan → meaningful decisions → predicted test result → debrief. Это входит в указанные 8 часов, а не добавляется сверху.

## Сессия 1 — EF Core query shape (75 минут)

### Observable outcomes

- Объяснить `IQueryable`, deferred execution и materialization.
- Найти premature `ToList`, N+1 и лишнюю entity materialization.
- Переписать read-only endpoint через projection/`AsNoTracking`.

### Scope и источник

- EF Core performance overview: https://learn.microsoft.com/en-us/ef/core/performance/
- Query shape, round trips, projection, tracking.

### Exercise

Взять один read endpoint из ValikuloDance или Secret Project, получить generated SQL, посчитать round trips и переписать минимально.

### Pass

Самостоятельно объяснить SQL boundary и устранить N+1/over-fetching без изменения контракта.

### Retest

Через 2–3 дня новый LINQ snippet; через 10–14 дней code-review task.

## Сессия 2 — индексы и планы (75 минут)

### Observable outcomes

- Объяснить назначение B-tree и цену индекса для writes/storage.
- Выбрать индекс из `WHERE`/`JOIN`/`ORDER BY`.
- Объяснить left-prefix составного индекса.
- Прочитать базовые узлы `EXPLAIN` и отличить sequential/index scan.

### Scope и источники

- EF Core indexes: https://learn.microsoft.com/en-us/ef/core/modeling/indexes
- PostgreSQL SQL/performance chapters: https://www.postgresql.org/docs/current/sql.html

### Exercise

Для запроса последних заказов пользователя выбрать составной индекс, создать migration и сравнить plan до/после на репрезентативных данных.

### Pass

Индекс обоснован query shape, а эффект подтверждён plan/measurement; кандидат называет write-amplification trade-off.

### Retest

Через 2–3 дня индекс с другим порядком predicates/order; через 10–14 дней диагностика slow query.

## Сессия 3 — транзакции и конкурентность (90 минут)

### Observable outcomes

- Объяснить atomicity, commit/rollback и default `READ COMMITTED`.
- Различить stale read-modify-write, atomic conditional update и `SELECT FOR UPDATE`.
- Защитить idempotency DB unique constraint.

### Scope и источники

- PostgreSQL isolation: https://www.postgresql.org/docs/current/transaction-iso.html
- EF Core transactions/concurrency: разделы Saving Data официальной документации Microsoft.

### Exercise

Реализовать inventory reservation двумя способами: atomic conditional update и pessimistic lock. Добавить unique `(OrderId, ProductId)`.

### Pass

Два конкурентных запроса не нарушают stock/idempotency invariants; решение содержит tests и объяснение trade-offs.

### Retest

Через 2–3 дня новый balance/capacity scenario; через 10–14 дней code review конкурентного кода.

## Сессия 4 — async и bounded pipeline (90 минут)

### Observable outcomes

- Объяснить task creation, execution до первого incomplete `await`, `WhenAll` ordering/fault/cancel semantics.
- Реализовать failure-safe semaphore с `finally`.
- Разделить bounded active I/O и bounded queued work.
- Реализовать bounded producer/consumer через `Channel`.

### Scope и источники

- Async programming: https://learn.microsoft.com/en-us/dotnet/csharp/asynchronous-programming/
- `Task.WhenAll`: https://learn.microsoft.com/en-us/dotnet/api/system.threading.tasks.task.whenall?view=net-10.0
- Channels: https://learn.microsoft.com/en-us/dotnet/core/extensions/channels

### Exercise

Обработать 10 000 IDs через bounded channel с 20 consumers, cancellation, error result contract и сохранением input order.

### Pass

Нет permit leak/unbounded tasks; cancellation завершается; порядок/partial-result semantics покрыты tests.

### Retest

Через 2–3 дня новый pipeline snippet; через 10–14 дней timed implementation.

## Сессия 5 — test boundaries и PostgreSQL integration (90 минут)

### Observable outcomes

- Различить unit/integration/component tests по доказательству, а не названию.
- Объяснить, почему InMemory/другая СУБД не доказывает PostgreSQL semantics.
- Запустить два независимых `DbContext` и проверить concurrency invariant.

### Scope и источник

- Testing against production DB system: https://learn.microsoft.com/en-us/ef/core/testing/testing-with-the-database

### Exercise

Integration test конкурентной регистрации одного normalized email на реальном PostgreSQL: exactly one row, один success, один expected conflict, одна outbox row.

### Pass

Тест воспроизводим, не использует один shared `DbContext`, не зависит от `Task.Delay`, изолирует данные и падает без DB constraint.

### Retest

Через 2–3 дня спроектировать test boundary для другого concurrency invariant.

## Checkpoint — mixed retrieval (60 минут)

- 10 минут: EF query reading.
- 10 минут: index selection.
- 15 минут: transaction/concurrency trace.
- 15 минут: async code review.
- 10 минут: test-boundary defense.

Gate: independent correctness/depth не ниже 3/4 в четырёх из пяти частей; ни одного 0 в correctness. Не прошедшие части возвращаются в learning и получают новый task, а не повтор того же ответа.
