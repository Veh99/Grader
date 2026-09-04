# Async code review — CollectAsync

Дата: 2026-08-31

## Режим

- Формат: code review, Middle+/Senior.
- Timebox: 12 минут.
- Режим: coaching, closed-book; подсказка фиксируется как assistance.
- Ожидаемый результат: blocker-level findings по приоритету, последствия и минимальные исправления.
- До ответа кандидата решение и rubric-specific findings не записывать в этот файл.

## Контракт

- На каждый `id` должен быть один `ItemResult`.
- Результаты возвращаются во входном порядке.
- Ошибка конкретного `LoadAsync` превращается в `ItemResult.Failure`.
- Отмена и инфраструктурные ошибки должны быстро завершать весь pipeline исключением.
- Очередь и число выполняемых операций должны оставаться ограниченными.
- `ProduceAsync` вызывает `TryComplete()` только при успешном завершении.

## Snippet

```csharp
public async Task<IReadOnlyList<ItemResult>> CollectAsync(
    IReadOnlyList<int> ids,
    CancellationToken cancellationToken)
{
    var channel = Channel.CreateBounded<(int Index, int Id)>(
        new BoundedChannelOptions(100)
        {
            FullMode = BoundedChannelFullMode.Wait
        });

    var results = new List<ItemResult>();

    var producer = ProduceAsync(ids, channel.Writer, cancellationToken);

    var consumers = Enumerable.Range(0, 20)
        .Select(_ => ConsumeAsync())
        .ToArray();

    async Task ConsumeAsync()
    {
        await foreach (var item in channel.Reader.ReadAllAsync(cancellationToken))
        {
            try
            {
                var value = await LoadAsync(item.Id, cancellationToken);

                results.Add(ItemResult.Success(
                    item.Index,
                    item.Id,
                    value));
            }
            catch (Exception exception)
            {
                results.Add(ItemResult.Failure(
                    item.Index,
                    item.Id,
                    exception));
            }
        }
    }

    await Task.WhenAll(consumers);
    await producer;

    return results
        .OrderBy(result => result.Index)
        .ToArray();
}
```

## Вопрос

Какие здесь есть blocker-level проблемы? Сначала разобрать producer fault, cancellation и конкурентную запись в `results`, затем оценить boundedness и сохранение порядка.

## Состояние

`pending`: кандидат ещё не отвечал. Перед возвратом к review проводится короткая foundation calibration по async.
