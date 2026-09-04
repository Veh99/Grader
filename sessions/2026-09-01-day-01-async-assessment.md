# День 1 — итоговый timed-опрос по async

Дата: 2026-09-01  
Режим: closed-book, один вопрос за раз  
Состояние evidence: `learning`; проверка проведена сразу после изучения, delayed retention ещё нет

## Итог

Базовая интуиция сформирована: кандидат понимает пользу неблокирующего I/O, различает latency и throughput, знает выполнение async-метода до первого незавершённого `await`, отличает `Task` от потока и замечает unbounded fan-out/shared mutable collection. До проходного уровня пока не хватает устойчивой причинной модели runtime semantics.

Ориентировочный итог по сессии: correctness `1.5–2.0/4`, depth `1.5/4`, communication `2.5/4`, timing/fluency `около 2.8/4`. Это не средний readiness score, а сводка неоднородных попыток. Gate 3/4 не пройден.

## Оценки попыток

| # | Проверяемая тема | Correctness | Depth | Communication | Timing | Assistance |
|---:|---|---:|---:|---:|---:|---|
| 1 | Определение async и throughput | 3.0 | 2.5 | 3.0 | 3 | independent |
| 2 | Async/concurrency/parallelism/multithreading | 1.5 | 1.5 | 3.0 | 3 | prompted |
| 3 | Process/thread/ThreadPool/Task, `Task.Delay` | 1.5 | 1.5 | 2.5 | 3 | prompted |
| 4 | I/O-bound, CPU-bound и `Task.Run` | 1.5 | 1.5 | 2.5 | 3 | prompted |
| 5 | Async state machine | 2.0 | 1.5 | 2.5 | 3 | prompted |
| 6 | Cooperative cancellation и состояния Task | 2.0 | 1.5 | 2.5 | 3 | prompted |
| 7 | `Thread.Sleep` и `Task.Delay` | 2.5 | 1.5 | 2.5 | 3 | independent |
| 8 | `TaskCompletionSource`, continuation ordering | 1.5 | 1.0 | 2.5 | 3 | prompted |
| 9 | `Task.WhenAll`: completion/fault/cancel | 1.0 | 1.0 | 2.0 | 3 | prompted |
| 10 | Review unbounded async collection | 2.5 | 2.0 | 3.0 | 3 | independent |
| 11 | Минимальный rewrite с результатом | 1.5 | 1.0 | 2.0 | 1 | independent |

Для ответов без явного сообщения о превышении применено пользовательское правило: timing `3/4`. В попытке 11 кандидат сообщил около 10 минут при лимите 5 минут, поэтому timing `1/4`.

## Что прошло

- Async I/O способен повысить throughput, не уменьшая latency внешнего запроса.
- Вызов async-метода начинается сразу и синхронно идёт до первого незавершённого `await`.
- `Thread.Sleep` блокирует поток, а ожидание `Task.Delay` не удерживает поток спящим.
- LINQ `Select` deferred; перечисление создаёт весь fan-out.
- Unbounded concurrency и конкурентная запись в `List<T>` распознаны как production-риски.
- Неизвестные места обозначались прямо, без выдуманного ответа.

## Блокирующие пробелы

1. Concurrency ошибочно привязана к нескольким потокам. Много незавершённых I/O операций может координироваться одним потоком.
2. `Task` пока воспринимается как контейнер полей или работа, ожидающая поток. Нужна модель eventual completion и отделение операции, scheduler и thread.
3. Не закреплены различия CPU-bound/I/O-bound и роль `Task.Run` в UI и ASP.NET Core.
4. State machine описывается как polling. На незавершённом await она сохраняет состояние, регистрирует continuation и возвращает управление; после completion снова вызывается `MoveNext`.
5. Cancellation cooperative: `Cancel()` только сигнализирует. `Task` становится Canceled, когда операция завершилась соответствующим cancellation exception/token contract, а обычный `return` даёт RanToCompletion.
6. `WhenAll` не завершает aggregate task при первом fault, не останавливает остальные операции и не отменяет их автоматически. Для `Task<T>` результаты расположены в порядке входных tasks.
7. Последний rewrite не компилируется: async-lambda не возвращает `value`, поэтому получается `IEnumerable<Task>`, а `WhenAll` не возвращает список. Boundedness не разобрана.

Минимальная неблокирующая коррекция последнего кода, если `_client.LoadAsync` возвращает `Task<int>`:

```csharp
var tasks = ids.Select(id => _client.LoadAsync(id, cancellationToken));
return await Task.WhenAll(tasks);
```

Она убирает shared collection и сохраняет входной порядок, но по-прежнему создаёт unbounded fan-out. Для ограниченного исполнения нужен отдельный механизм: indexed result storage плюс `Parallel.ForEachAsync`, фиксированный набор Channel workers либо эквивалентный bounded pipeline.

## Retest

- 2026-09-02, начало дня 2: короткий correction packet и новый immediate retrieval по шести блокирующим моделям.
- 2026-09-03 или 2026-09-04: closed-book delayed retest с другим wording и новыми snippets.
- 2026-09-08: второй delayed retest по retained fundamentals.
- `CollectAsync` и bounded pipeline дня 2 начинать после correction packet; оценивать отдельно от подсказанного материала.
