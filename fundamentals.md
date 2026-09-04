# Фундаментальный retrieval-трек

Обновлено: 2026-09-01

Активный график вопросов определяется `sprints/accelerated-14-day.md`; лимиты и оценка времени — `timed-rubric.md`.

## Цель

Уметь уверенно и точно отвечать на базовые вопросы раннего technical screen до перехода к глубоким сценариям. Этот трек дополняет applied-практику, но не заменяет её.

## Формат ответа

Стандартный лимит на определение — 90 секунд, closed-book, без вариантов ответа. Точный режим задаётся по `timed-rubric.md`:

1. Краткое определение простыми словами.
2. Базовый механизм работы.
3. Зачем или где применяется.
4. Один конкретный пример.
5. Отличие от соседнего понятия либо важное ограничение.

Интервьюер задаёт один основной вопрос за раз и максимум один причинный follow-up до фиксации первичного evidence.

## Оценка

- `Correctness` 0–4: точность определения и механизма.
- `Communication` 0–4: краткость, структура и отсутствие противоречий.
- `Depth` фиксируется только по причинному follow-up и не смешивается с applied score.
- Pass отдельного термина: independent delayed retrieval не ниже 3/4 по correctness и communication.
- Ответ после объяснения: `immediate retrieval`, состояние максимум `provisional`.

## Повторение

Новый или ошибочный термин повторяется в следующий учебный день, затем через 3, 7 и 14 дней. Используется новое wording и другой простой пример. После двух успешных delayed retrieval термин переводится в `retention-passed`; практическое владение фиксируется только в `progress.md`.

## Карта тем

### C# и CLR

- managed code, CLR, IL и JIT;
- value type и reference type;
- stack, managed heap и lifetime данных;
- boxing/unboxing;
- GC roots, generations, LOH, finalization и disposal;
- process, thread и ThreadPool;
- CPU core, hardware thread, context switch, cache и RAM;
- OS scheduler, `TaskScheduler` и их отличие от `ThreadPool`;
- synchronous/asynchronous, concurrency и parallelism;
- `Task`, `async`/`await`, cancellation и exception propagation;
- deferred execution, iterator и `IAsyncEnumerable<T>`;
- race condition, lock, semaphore и thread safety;
- atomicity, memory visibility, reordering и memory barrier;
- `Volatile`, `Interlocked`, compare-and-swap и ABA;
- blocking, lock-free, wait-free и obstruction-free guarantees.

### ASP.NET Core и HTTP

- HTTP request/response, methods и status codes;
- middleware pipeline;
- DI и singleton/scoped/transient;
- authentication и authorization;
- model validation и API error contract;
- cancellation, timeout, retry и rate limiting;
- background service, health check и graceful shutdown.

### Базы данных

- DBMS, relational model, table, row и column;
- primary key, foreign key, unique constraint;
- normalization и denormalization;
- index и B-tree;
- SQL query, join и execution plan;
- transaction и ACID;
- isolation levels, anomalies, locks и MVCC;
- optimistic/pessimistic concurrency;
- ORM, EF Core tracking и migrations.

### Messaging и распределённые системы

- broker, queue, topic, producer и consumer;
- acknowledgment, retry и dead-letter queue;
- at-most-once, at-least-once и exactly-once claims;
- ordering, partitioning и consumer group;
- backpressure и load shedding;
- idempotency, outbox/inbox и eventual consistency.

### Архитектура

- monolith, modular monolith и microservices;
- service/module boundary и data ownership;
- synchronous и asynchronous communication;
- scalability, availability и fault tolerance;
- consistency и distributed transaction;
- cache и cache invalidation;
- vertical/horizontal scaling и load balancing.

### Testing и эксплуатация

- unit, integration, component и end-to-end tests;
- mock, stub и fake;
- deterministic и flaky test;
- logs, metrics и traces;
- CI/CD, container и orchestration basics;
- deployment, rollback, SLI/SLO и incident.

## Текущее evidence

| Тема | Состояние | Последний score | Assistance | Следующее повторение |
|---|---|---:|---|---|
| Асинхронность vs concurrency/parallelism | learning | 1.5/4 | prompted | 2026-09-03–04 |
| Process, thread, ThreadPool и Task | learning | 1.5/4 | prompted | 2026-09-03–04 |
| Async state machine и continuation | learning | 2.0/4 | prompted | 2026-09-03–04 |
| Cooperative cancellation | learning | 2.0/4 | prompted | 2026-09-03–04 |
| `Task.WhenAll` semantics | learning | 3.0/4 status; 1.0/4 multiple errors | independent | next async retest |
| `ThreadPool`, `TaskScheduler`, `SynchronizationContext` | learning | 2.0/4 | independent | next async retest |
| Channel capacity и backpressure | provisional | 3.0/4 | independent | delayed retest |
| Cancellation vs broad `catch (Exception)` | learning | 1.5/4 | independent | next async retest |
| Stack, managed heap и GC | unassessed | - | - | after async |
| Базовые понятия реляционной БД | unassessed | - | - | pending |
| Queue и broker fundamentals | unassessed | - | - | pending |
| Monolith vs microservices | unassessed | - | - | pending |

## Первый calibration set

1. Что такое асинхронность? Чем она отличается от параллелизма и многопоточности?
2. Что обычно называют stack и managed heap в .NET? Почему правило «value type всегда на стеке» неверно?
3. Зачем нужен GC? Что такое GC roots и поколения?
4. Что такое транзакция и какие свойства описывает ACID?
5. Чем primary key, foreign key, unique constraint и index отличаются друг от друга?
6. Как работают queue, producer, consumer и acknowledgment в брокере сообщений?
7. Чем monolith, modular monolith и microservices отличаются по границам и эксплуатационной цене?
8. Чем unit, integration и end-to-end test отличаются по доказательству, которое дают?
