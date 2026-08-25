# Адаптивный план подготовки

Обновлено: 2026-08-18

План предварительный до завершения baseline. Приоритет пересчитывается как `важность для роли × дефицит навыка × ценность prerequisite`.

## Адаптивная корректировка 2026-08-18

Диагностика выявила критичный prerequisite gap по SQL transactions/isolation (`READ COMMITTED` неизвестен). Блок PostgreSQL/транзакций временно переносится вперёд остальных технических блоков. Сначала: ACID и границы транзакции → visibility/isolation anomalies → locking/MVCC → optimistic/pessimistic concurrency → idempotency и EF Core implementation.

## Адаптивная корректировка 2026-08-20

Кандидат работал через EF Core и не изучал SQL системно. До новых оценочных SQL-сценариев включён guided bridge:

1. LINQ expression → SQL → момент выполнения запроса.
2. Форма запроса: projection, joins/`Include`, N+1, pagination.
3. Индексы и чтение базового `EXPLAIN`.
4. Транзакции, `READ COMMITTED`, MVCC и locks на EF-примерах.
5. Optimistic concurrency, atomic updates и idempotency.
6. Практика на небольшом EF Core/PostgreSQL проекте; затем independent retest.

До завершения пунктов 1–4 сложные SQL/concurrency ответы не используются для дальнейшего снижения readiness estimate.

Для блока индексов начать с B-tree и связи `WHERE`/`JOIN`/`ORDER BY` с порядком колонок составного индекса; затем перейти к selectivity, covering indexes, write amplification и чтению `EXPLAIN (ANALYZE, BUFFERS)`.

### Testing prerequisite bridge

Диагностика показала отсутствие модели test boundaries. До оценочных testing-сценариев пройти:

1. Unit vs integration vs component/end-to-end: что именно доказывает каждый уровень.
2. Test doubles и границы mock: не мокать поведение, которое требуется доказать у PostgreSQL/EF provider.
3. Почему EF Core InMemory не заменяет relational database tests.
4. PostgreSQL integration tests: isolated schema/container, migrations, separate `DbContext` per concurrent operation.
5. Проверка constraints, transactions, concurrency и mapping DB errors в API contract.
6. Test reliability: deterministic synchronization, cleanup, parallel isolation и диагностика flaky tests.

## Распределение времени

- 60% — слабые must-have области.
- 25% — форматы интервью: rapid screen, coding, review, debugging, design, project deep-dive.
- 15% — Senior differentiators.

При подтверждённых 8 часах в неделю: 64–96 часов за 8–12 недель.

## Live-coding communication protocol

На каждой практической задаче использовать цикл:

1. Кратко переформулировать задачу и уточнить требования.
2. Назвать assumptions, edge cases и критерий готовности.
3. За 30–60 секунд объяснить план до написания кода.
4. Во время реализации проговаривать только значимые решения и изменения гипотез.
5. Перед запуском предсказать результат теста/компиляции.
6. При ошибке: наблюдение → гипотеза → проверка → вывод; не делать хаотичные правки.
7. В конце: complexity, tests, production hardening и что улучшить при дополнительном времени.

Молчание более 60–90 секунд допустимо с явной фразой о том, что кандидат обдумывает конкретный участок. Непрерывно озвучивать синтаксис и каждое нажатие клавиши не требуется.

## Этап 0 — baseline (неделя 1)

Проверить: C#/async/runtime; ASP.NET Core/API; SQL/EF Core; тестирование; debugging/production; distributed systems; system design; ownership.

Формат: короткие вопросы, разбор кода, небольшая coding-задача, architecture scenario и production scenario. Один вопрос за раз, без скрытой помощи.

Gate: получить независимые оценки и выделить 3 главных риска.

## Блок 1 — C#, async и runtime (недели 1–2)

- Результат: причинно объяснять async/cancellation/thread pool, lifetime ресурсов, allocations/GC и concurrency; находить дефекты в коде.
- Практика: реализация bounded-concurrency pipeline с отменой, таймаутами и тестами.
- Pass: не менее 3/4 по correctness и depth, без unsafe concurrency; delayed retest через 2–3 и 10–14 дней.

## Блок 2 — ASP.NET Core и контракты API (недели 2–3)

- Результат: проектировать HTTP-контракт, DI lifetimes, middleware, validation/problem details, auth и propagation cancellation/timeouts.
- Практика: production-shaped Web API endpoint с интеграционными тестами и observability.
- Pass: самостоятельное решение основных failure modes; delayed retest через 2–3 и 10–14 дней.

## Блок 3 — PostgreSQL, транзакции и EF Core (недели 3–4)

- Результат: индексы/query plans, isolation/locks/deadlocks, optimistic concurrency, N+1/projections, pagination, миграции без простоя.
- Практика: диагностировать медленный и некорректный data flow; предложить безопасную миграцию.
- Pass: не менее 3/4 по correctness/production judgment; delayed retest.

## Блок 4 — тестирование, диагностика и эксплуатация (недели 4–5)

- Результат: выбирать границы unit/integration/contract tests; вести incident от симптома к evidence; применять logs/metrics/traces.
- Практика: code review плюс incident scenario с mitigation, root cause и prevention.
- Pass: приоритизация correctness/data loss/operability; delayed retest.

## Блок 5 — messaging и distributed failure (недели 5–7)

- Результат: at-least-once, idempotency, outbox/inbox, ordering, retries/backoff/jitter, backpressure, caching/consistency.
- Практика: надёжная обработка платежного/заказного события с повторной доставкой и частичным отказом.
- Pass: отсутствие потери/двойного бизнес-эффекта в модели; delayed retest.

## Блок 6 — system design и Senior-сигналы (недели 7–9)

- Результат: уточнять NFR, оценивать capacity, выбирать границы и простейшую достаточную архитектуру, проектировать evolution/rollout/rollback.
- Практика: дизайн high-load сервиса банка или маркетплейса; защита trade-offs.
- Pass: 3/4+ во всех критичных измерениях rubric без interviewer rescue.

До архитектурных схем пройти framing prerequisite: primary journey, success metric, critical invariant, functional scope, NFR, security/compliance, external dependencies, data ownership и team/operational constraints. Запрещено выбирать конкретные технологии до фиксации этих входных данных.

## Блок 7 — интервью и финальный gate (недели 9–12)

- Rapid technical screen, live coding, code review, debugging, system design, project deep-dive и behavioral/ownership.
- Минимум два смешанных mock loop с разными заданиями.
- Ready: все must-have имеют свежее независимое evidence целевого уровня, без повторяющегося gating failure.

## Следующий checkpoint

После baseline пересобрать порядок блоков, зафиксировать фактический недельный бюджет и назначить первый delayed retest.
