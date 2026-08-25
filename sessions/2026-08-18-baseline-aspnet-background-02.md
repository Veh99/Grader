# Baseline #2 — ASP.NET Core fire-and-forget

Дата: 2026-08-18  
Assistance: independent  
Confidence: 60%  
Overall: 2.0/4 — working, ниже Middle+ gate

## Passed evidence

- Распознана потеря незавершённой работы при рестарте процесса и недоступности email.
- Предложены durable outbox, broker и отдельный worker.
- После дополнительного размышления кандидат отказался от лишнего `Task.Run`.

## Gaps

- Scoped `DbContext` и email service захвачены request object graph и могут быть disposed после возврата response.
- Exception фоновой задачи не проходит через request exception middleware.
- Fire-and-forget создаёт unbounded concurrency без admission control/backpressure и способен исчерпать memory, DB/HTTP pools и thread-pool continuations.
- `202 Accepted` корректен, если работа надёжно принята и клиент получает job/status contract; он не обязан означать отправленное письмо.
- Outbox требует атомарной записи intent с изменением бизнес-состояния. Для email остаётся crash window после фактической отправки до отметки success; exactly-once требует idempotency support провайдера либо осознанной бизнес-семантики и дедупликации.

## Оценка

| Измерение | Score |
|---|---:|
| Correctness | 2.0 |
| Depth | 1.5 |
| Trade-offs | 2.0 |
| Production judgment | 2.0 |
| Communication | 2.5 |

## Retest

Через 2–3 дня: новый durable background-work scenario с несколькими replicas, crash windows и idempotency requirements.

