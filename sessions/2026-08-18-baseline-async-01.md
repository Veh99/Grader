# Baseline #1 — LINQ, Task.WhenAll и cancellation

Дата: 2026-08-18  
Assistance: independent  
Confidence: 30%  
Overall: 1.5/4 — learning, ниже Middle+ gate

## Наблюдаемое evidence

Кандидат правильно отметил давление 10 000 запросов на downstream, предложил предпочтительный batch endpoint и понял, что необработанная ошибка не позволит методу вернуть обычный результат.

Ошибочно указано, что операции запускаются непосредственно в `Select`, и что cancellation отменит только один текущий запрос с возвратом уже готовых результатов. Не разобраны deferred enumeration, eager/unbounded fan-out внутри `Task.WhenAll`, ожидание завершения всех задач, агрегация нескольких ошибок и отсутствие partial result contract.

## Оценка

| Измерение | Score |
|---|---:|
| Correctness | 1.0 |
| Depth | 1.0 |
| Trade-offs | 2.0 |
| Production judgment | 1.5 |
| Communication | 2.0 |

## Retest

Через 2–3 дня: новый код с deferred LINQ, несколькими faults, cancellation и bounded concurrency. Для pass нужны correctness/depth не ниже 3/4 без подсказки.

