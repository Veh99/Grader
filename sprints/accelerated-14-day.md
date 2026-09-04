# 14-дневный интенсив подготовки к .NET backend интервью

Старт: следующий учебный день после 2026-08-31  
Рабочая нагрузка: дни 1–12 — около 4 часов theory package плюс 1.5–2.5 часа практики/опроса; дни 13–14 — mock; всего около 70–82 часов  
Цель: быстро закрыть screening fundamentals, получить applied evidence, начать реальные интервью и построить точную карту пробелов.

## Ограничение цели

Интенсив не делает все темы mastered за две недели. Он формирует связную базовую модель, проверяет ключевые навыки под таймером и находит knowledge frontier. Mastery по-прежнему требует delayed retrieval, практического применения и последующей проверки на новых задачах.

## Материалы каждого дня

Перед началом каждого из дней 1–12 интервьюер подготавливает один учебный пакет примерно на 4 часа чистого изучения:

1. Original theory digest на русском языке: определения, механизм, причинные связи, типичные ошибки и production-пример.
2. Карта терминов для timed retrieval.
3. Ссылки на актуальную официальную документацию.
4. Рекомендованные главы из известных книг и 1–2 существующих видео, если они дают высокий signal-to-time.
5. Маршрут с длительностью, `required`/`optional` и ожидаемым результатом каждого материала.

После четырёхчасового theory package отдельно выдаются:

1. timed chat retrieval по всему материалу дня;
2. внешние задачи, если площадка действительно проверяет нужный навык;
3. custom production-shaped tasks для тем, которые нельзя доказать типовой платформой;
4. критерии pass и итоговый error log.

Книги используются как источники идей и структуры: конспект формулируется оригинально, без воспроизведения длинных фрагментов. Версионно-зависимые детали проверяются по текущей официальной документации. Вторичные материалы вроде Metanit и YouTube не считаются ground truth и при необходимости получают caveat. Политика источников находится в `learning-sources.md`.

## Ритм двухдневного кластера

### День A — модель и терминология

- 60 минут: original theory digest.
- 90 минут: official documentation route.
- 60 минут: selected book chapters/secondary Russian materials/video.
- 30 минут: active notes и карта терминов.
- После theory package: 30–45 минут timed retrieval, 60–90 минут micro-practice, 15 минут error log.

### День B — углубление и применение

- 45 минут: delayed retrieval notes и устранение factual gaps дня A.
- 75 минут: advanced theory, failure modes и trade-offs.
- 90 минут: official docs/book/video route по advanced части.
- 30 минут: самостоятельный конспект без источников.
- После theory package: 30 минут delayed chat retrieval, 90–120 минут production-shaped task, 45 минут разбор/quiz и 15 минут progress update.

## Календарь

### Дни 1–2 — async, concurrency, multithreading и parallelism

Foundation: synchronous/asynchronous, concurrency/parallelism, process/thread/ThreadPool, базовая модель выполнения инструкций на CPU, `Task`, `TaskScheduler`, `async`/`await`, state machine, cancellation, exception propagation, synchronization, semaphore, bounded queue и backpressure.

Практика: code reading и исправление bounded pipeline; основной applied exercise — `sessions/2026-08-31-async-collectasync.md`.

Gate: объяснить различия терминов за timebox и самостоятельно найти blocker-level fault/cancellation/thread-safety проблемы в pipeline.

### Дни 3–4 — C#, CLR, CPU/memory model, stack/heap и GC

Foundation: managed code, CLR/IL/JIT и переход к машинным инструкциям; CPU cores, hardware threads, registers, cache hierarchy, RAM, OS scheduling/context switch и cache coherence; .NET memory model, atomicity, reordering и memory barriers; `Volatile`, `Interlocked`, compare-and-swap; blocking, lock-free, wait-free и obstruction-free progress guarantees; ABA и false sharing; value/reference semantics, stack frames, managed heap, boxing, strings, allocations, GC roots, generations, LOH, finalization, `IDisposable` и memory leaks через достижимость.

Практика: разобрать allocation/lifetime snippet; диагностировать race из read-modify-write; исправить счётчик через `Interlocked`; объяснить CAS-loop, ABA и memory-order assumptions; сравнить lock, concurrent collection и lock-free подход; найти удержание объектов и предложить измерение через runtime diagnostics.

Gate: не использовать ложные правила «value type всегда на стеке», «volatile делает составную операцию атомарной», «lock-free всегда быстрее» и «GC освобождает всё автоматически»; причинно объяснить lifetime, visibility, atomicity, progress guarantee и cleanup.

### Дни 5–6 — HTTP, ASP.NET Core и API contracts

Foundation: HTTP semantics, request pipeline, middleware ordering, DI lifetimes, validation/problem details, authentication/authorization, cancellation/timeouts, background work, health checks и graceful shutdown.

Практика: review endpoint с scoped dependency, fire-and-forget, неверным статусом и отсутствующим cancellation/error contract; затем минимальный fix и tests.

Gate: корректный HTTP/API contract и отсутствие request-lifetime/background-work ошибок.

### Дни 7–8 — relational databases, PostgreSQL и EF Core

Foundation: table/row/key/constraint/index, normalization, joins, B-tree и query plan, transaction/ACID, `READ COMMITTED`, MVCC, locks, anomalies, optimistic/pessimistic concurrency, EF tracking/projection и migrations.

Практика: query/index review плюс конкурентное изменение данных двумя `DbContext`; объяснить SQL boundary и DB-enforced invariant.

Gate: не путать constraint с index, tracking с materialization и application check с защитой от race condition.

External practice: выбрать задания из LeetCode SQL 50 на `SELECT`, joins, aggregation и subqueries. Индексы, планы, транзакции, блокировки и EF Core проверять custom PostgreSQL/.NET задачами, потому что SQL challenge не моделирует эти runtime semantics.

С дня 7 начать отправлять целевые отклики. Цель — получить первые реальные screens на дни 10–14 или следующую неделю.

### Дни 9–10 — brokers, distributed systems и service boundaries

Foundation: queue/topic, producer/consumer, ack, retry/DLQ, delivery semantics, ordering/partitioning, idempotency, outbox/inbox, eventual consistency, monolith/modular monolith/microservices и data ownership.

Практика: спроектировать обработку заказа/платежа при duplicate delivery, consumer crash и недоступности downstream; защитить выбор границ и более простой вариант.

Gate: модель не обещает недостижимое exactly-once и не теряет/дублирует бизнес-эффект без явного контракта.

### Дни 11–12 — testing, observability, delivery и system design

Foundation: unit/integration/component/e2e, test doubles, deterministic tests, logs/metrics/traces, health/SLI/SLO, deployment/rollback, containers, capacity, availability, scalability, consistency и fault tolerance.

Практика: incident mini-case и design небольшого high-load backend: requirements, estimates, API/data ownership, critical path, failures, observability и rollout.

Gate: тесты доказывают нужную границу, диагностика опирается на evidence, system design начинается с требований и инвариантов, а не со списка технологий.

### День 13 — итоговое интервью, часть 1

- Strict mode, closed-book.
- Rapid ladder: C#/CLR, async/concurrency, HTTP/ASP.NET Core.
- Один compact code-reading/code-review task.
- В каждом домене идти от определения к failure modes до stop condition из `timed-rubric.md`.
- Ничего не объяснять между доменами; только фиксировать frontier.

### День 14 — итоговое интервью, часть 2 и решение о выходе на рынок

- Strict mode, closed-book.
- Rapid ladder: PostgreSQL/EF, messaging/distributed systems, testing/operations.
- System-design segment 45–60 минут.
- После завершения: debrief, readiness verdict, top-5 gaps и план на следующие 7 дней.
- Сопоставить mock evidence с результатами реальных откликов/screens и определить, какие интервью продолжать назначать немедленно.

## Ежедневный evidence

После каждого дня обновляются:

- `fundamentals.md`: вопросы, scores, timing и даты повторения;
- `progress.md`: applied exercise, assistance, weakest dimension и state;
- `HANDOFF.md`: текущий день, незавершённый вопрос и следующий шаг;
- при существенной практике — отдельный файл в `sessions/`.

## Exit criteria

Интенсив считается завершённым, если пройдены оба final mock segments, для каждого домена записан knowledge frontier и сформирован короткий post-intensive plan. Отсутствие пробелов не является критерием; цель — точно узнать, где они находятся, и уже иметь достаточную базу для начала реальных собеседований.
