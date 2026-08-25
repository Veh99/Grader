# Baseline checkpoint

Дата: 2026-08-21

## Предварительный уровень

Продемонстрированный диапазон: Middle по части базового backend reasoning; отдельные Middle+ сигналы в messaging reliability. Confidence: medium-low из-за ограниченного independent applied evidence.

Verdict: **not yet ready** для стабильного прохождения Middle+/Senior интервью.

Это не оценка потенциала. Основная причина verdict — несколько must-have prerequisite gaps, а не один провал mock interview.

## Сильные сигналы

- Честно обозначает незнание и не выдумывает API/термины.
- Распознаёт outbox, inbox, at-least-once и необходимость идемпотентности.
- Хорошо понял connection-pool exhaustion из-за external I/O внутри DB transaction.
- После scaffolding способен последовательно рассуждать о durable async flow, object storage и signed download.
- EF Core deferred execution, premature materialization и N+1 распознаны после короткого обучения.

## Главные риски

1. SQL/PostgreSQL: отсутствует база по индексам, isolation, locking и query plans.
2. Async/concurrency: delayed retest не пройден; ошибки в `Task.WhenAll` ordering, task fan-out, semaphore failure handling.
3. Testing: нет устойчивой модели unit/integration boundaries и real-DB concurrency tests.
4. Production diagnostics: верный rollback instinct, но слабая evidence model для DB saturation.
5. System design: исходно technology-first; после guidance framing улучшился, но leases/fencing/failure-state mechanics пока не закреплены.

## Самый выгодный следующий шаг

Первый учебный спринт должен закрыть prerequisites, а не продолжать сложные system-design вопросы:

- EF Core → SQL/query shape → indexes;
- transactions/isolation/atomicity;
- async execution + bounded producer/consumer;
- test boundaries + PostgreSQL integration test;
- один delayed mixed retest без подсказок.

