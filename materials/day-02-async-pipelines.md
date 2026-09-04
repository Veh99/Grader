# День 2 — async pipelines, cancellation и backpressure

Дата выдачи: 2026-09-01  
Theory package: 240 минут  
Практика после теории: 90–120 минут  
Режим проверки: closed-book, timed, один вопрос за раз

## Результат дня

После изучения материала кандидат должен уметь:

- причинно объяснить completion/fault/cancellation у `Task.WhenAll`;
- отличить OS scheduler, `TaskScheduler`, `ThreadPool` и continuation scheduling;
- объяснить, почему число CPU cores ограничивает полезный CPU parallelism;
- отделить отмену вызывающего кода от внутреннего fail-fast pipeline;
- описать полный жизненный цикл producer, channel и consumers;
- объяснить bounded queue и backpressure без формулы «ограничили число tasks»;
- выбрать между прямым `WhenAll`, `SemaphoreSlim`, `Parallel.ForEachAsync` и `Channel<T>`;
- не допустить зависания readers при producer fault;
- не проглотить cancellation или инфраструктурную ошибку;
- сохранить входной порядок без конкурентного `List<T>.Add` и последующей сортировки;
- защитить production-контракт исправленной реализацией и тестами.

## Маршрут на 240 минут

Проходить по порядку. Во время обязательного чтения выписывать только расхождения со своей текущей моделью.

| Время | Материал | Тип | Что получить на выходе |
|---:|---|---|---|
| 30 мин | Раздел `Корректирующий конспект` ниже, пункты 1–4; выборочно [managed execution process: CIL и JIT](https://learn.microsoft.com/en-us/dotnet/standard/managed-execution-process), [managed ThreadPool](https://learn.microsoft.com/en-us/dotnet/standard/threading/the-managed-thread-pool) и [`TaskScheduler`](https://learn.microsoft.com/en-us/dotnet/api/system.threading.tasks.taskscheduler?view=net-10.0) — назначение, `Default`, `Current` | original + official, required | Исправить модели concurrency, Task, continuation, CPU-bound; разделить JIT, OS scheduler, ThreadPool и TaskScheduler |
| 35 мин | [Task.WhenAll](https://learn.microsoft.com/en-us/dotnet/api/system.threading.tasks.task.whenall?view=net-10.0) и [Asynchronous programming: exceptions](https://learn.microsoft.com/en-us/dotnet/csharp/asynchronous-programming/) | official, required | Момент завершения aggregate task, status precedence, порядок результатов, несколько ошибок |
| 35 мин | [Task cancellation](https://learn.microsoft.com/en-us/dotnet/standard/parallel-programming/task-cancellation) и [CreateLinkedTokenSource](https://learn.microsoft.com/en-us/dotnet/api/system.threading.cancellationtokensource.createlinkedtokensource?view=net-10.0) | official, required | Cooperative cancellation, ownership, linked token, cancelled vs completed task |
| 45 мин | [System.Threading.Channels](https://learn.microsoft.com/en-us/dotnet/core/extensions/channels) | official, required | Bounded/unbounded channel, writer/reader, completion, full modes, backpressure |
| 35 мин | [YouTube, official dotnet: Working with Channels in .NET](https://www.youtube.com/watch?v=gT06qvQLtJ0) — 27 минут просмотра и 8 минут заметок по главам | official video, required | Producer/consumer model, public Channels API, bounded strategies, backpressure и границы in-process channel |
| 35 мин | Раздел `Корректирующий конспект` ниже, пункты 5–10; затем [thread-safe collections](https://learn.microsoft.com/en-us/dotnet/standard/collections/thread-safe/) и справочно [SemaphoreSlim](https://learn.microsoft.com/en-us/dotnet/api/system.threading.semaphoreslim?view=net-10.0) | original + official, required | Failure propagation, shared state, indexed results, сравнение механизмов ограничения |
| 25 мин | `Active notes` и failure matrix ниже | retrieval preparation, required | Собственная причинная модель без копирования текста |

Итого: **240 минут**.

## Проверка источников

| Источник | Почему включён | Проверка и caveat |
|---|---|---|
| Microsoft Learn: managed execution process | Показывает путь C# → CIL → JIT → native CPU instructions | Это обзор исполнения managed code, а не учебник по микроархитектуре CPU |
| Microsoft Learn: managed ThreadPool и `TaskScheduler` | Фиксирует назначение обоих механизмов и границу между очередью Task и выполнением на threads | Не путать с OS scheduler, который распределяет процессорное время между runnable threads |
| Microsoft Learn: Channels | Документация владельца платформы; покрывает current API, bounded modes и backpressure | Основной ground truth; страница актуализирована в 2026 году |
| Microsoft Learn: `Task.WhenAll` | Нормативно описывает terminal status и агрегацию ошибок | API reference; не объясняет архитектуру fail-fast pipeline |
| Microsoft Learn: task cancellation | Описывает cooperative model и связь cancellation exception с состоянием Task | Часть примеров относится к TPL delegate tasks; async-методы обсуждаются отдельно в конспекте |
| Microsoft Learn: linked tokens | Точный контракт `CreateLinkedTokenSource` | API reference, поэтому архитектурную ownership-модель дополняет конспект |
| Stephen Toub, .NET Blog | Автор — Partner Software Engineer команды .NET; статья строит channel-механику от примитивов до public API | Статья 2019 года, но базовая модель Channel остаётся актуальной; сигнатуры сверять с текущим Learn |
| YouTube: `Working with Channels in .NET` | Официальный канал `dotnet`, спикер Stephen Toub; показывает код и объясняет backpressure | Видео 2020 года; актуальность API сверена по current Learn. Failure completion и cancellation раскрыты недостаточно и закрываются конспектом |
| Microsoft Learn: thread-safe collections и `SemaphoreSlim` | Ground truth по concurrent collections и pairing `WaitAsync`/`Release` | Не доказывает, что concurrent collection является лучшей структурой для конкретного контракта |

### Карточка обязательного видео

`Working with Channels in .NET`: официальный канал `dotnet`, основной спикер Stephen Toub, 27 минут, английский; доступен автоматический дубляж. На 2026-09-01: опубликовано 2020-04-21, около 40,9 тыс. просмотров, 1 211 likes, 47 комментариев, канал около 355 тыс. подписчиков.

Главы:

- `00:55` — для чего нужны channels;
- `01:35` — построение базовой реализации;
- `09:15` — переход к `System.Threading.Channels`;
- `11:34` — преимущества библиотечной реализации;
- `14:11` — стратегии backpressure;
- `20:58` — разное число producers и consumers;
- `21:54` — Channels против Pipelines;
- `23:35` — почему это не межпроцессный transport;
- `24:30` — границы pub/sub.

Сигналы из комментариев: слушатели отмечают ясность объяснений Stephen Toub, возможность повторить код и полезность сравнения с Pipelines/pub-sub. Содержательный свежий комментарий указывает, что в видео не хватает способов корректно выйти из reader loop через writer completion/cancellation. Поэтому ролик обязателен для модели и backpressure, но completion/failure contract нужно брать из Microsoft Learn и разделов 6–9 этого конспекта.

Дополнительно, не входит в 240 минут: [Stephen Toub: An Introduction to System.Threading.Channels](https://devblogs.microsoft.com/dotnet/an-introduction-to-system-threading-channels/). Читать при необходимости более глубокого разбора внутренней реализации.

## Корректирующий конспект

### 1. Concurrency не является переключением потоков

Concurrency, или конкурентность, означает несколько незавершённых операций, чьи периоды жизни пересекаются. Это свойство организации работы, а не число потоков.

Один поток может:

1. инициировать запрос A;
2. вернуть управление на незавершённом ожидании;
3. инициировать запрос B;
4. обработать готовое продолжение C;
5. позднее продолжить A и B.

В каждый момент поток выполняет один участок кода, поэтому параллелизма пользовательского кода нет. Но A, B и C конкурентны, потому что одновременно находятся в прогрессе.

### 2. `Task` представляет завершение, а не поток

`Task` или `Task<T>` представляет eventual completion:

- успешное завершение;
- ошибку;
- отмену;
- для `Task<T>` ещё и результат типа `T`.

Task может быть связан с делегатом, выполняющимся в `ThreadPool`, но это только один источник completion. Другими источниками являются таймер, socket, файловая операция, другой Task, `TaskCompletionSource` или пользовательский awaitable.

Вопрос «какой поток выполняет Task?» часто поставлен неверно. Нужно разделять:

- кто инициировал операцию;
- кто выполняет фактическую работу;
- кто сообщает о completion;
- где запланировано продолжение;
- какой поток в итоге выполнит продолжение.

### 3. Причинная цепочка незавершённого `await`

Для упрощённой модели:

1. Вызов async-метода создаёт и запускает сгенерированный автомат состояний.
2. `MoveNext` выполняет код до `await`.
3. Получается awaiter и проверяется `IsCompleted`.
4. Если операция уже завершена, вызывается `GetResult`, и метод продолжает выполнение синхронно.
5. Если операция не завершена, автомат сохраняет номер состояния, awaiter и необходимые локальные данные.
6. Builder регистрирует продолжение через awaiter.
7. Async-метод возвращает вызывающему коду свой незавершённый Task.
8. Источник операции позднее завершает ожидаемый Task.
9. Completion активирует зарегистрированное продолжение.
10. Продолжение снова вызывает `MoveNext`; `GetResult` возвращает значение либо выбрасывает cancellation/failure.

Это регистрация callback, а не polling. Автомат состояний не опрашивает Task в цикле и не обнаруживает окончание таймера самостоятельно.

Для глубокого повторения использовать [How Async/Await Really Works in C#](https://devblogs.microsoft.com/dotnet/how-async-await-really-works/) как optional: разделы про awaiter, builder и compiler transform. Полное повторное чтение статьи в обязательные 240 минут не входит.

### 4. CPU-bound и `Task.Run`

CPU-bound означает, что доминирующий ограниченный ресурс — процессорное время. `Task.Run` отправляет делегат в `ThreadPool`, но не уменьшает объём вычислений и не создаёт дополнительные CPU cores.

- В UI `await Task.Run(CpuWork)` может сохранить отзывчивость, потому что UI thread не занят вычислением.
- В ASP.NET Core специального UI thread нет. Перенос вычисления с одного pool thread на другой обычно добавляет scheduling overhead и не повышает throughput.
- Для ускорения CPU calculation нужен алгоритм, допускающий полезное распараллеливание, достаточный размер работы и контролируемая степень параллелизма.
- Для долгой backend-работы может быть правильнее durable background job или отдельный compute service, если API contract допускает асинхронное завершение на уровне бизнеса.

#### Как код доходит до процессора

Упрощённая цепочка для .NET:

1. C# компилируется в IL и metadata.
2. CLR загружает метод, а JIT компилирует его в машинные инструкции для текущей архитектуры.
3. OS scheduler назначает runnable thread логическому процессору.
4. CPU исполняет инструкции, используя registers и несколько уровней cache; при отсутствии данных в cache обращение идёт дальше к RAM.
5. Несколько cores позволяют действительно выполнять несколько потоков одновременно, но shared cache, memory bandwidth, synchronization и serial sections ограничивают ускорение.

Thread — единица планирования ОС. Core — вычислительный ресурс. Hardware thread, или logical processor, позволяет одному physical core поддерживать несколько architectural execution contexts, но не превращает его в два полноценных независимых cores.

Context switch сохраняет состояние одного thread и восстанавливает другое. Он имеет цену: работа scheduler, потеря locality и возможные cache misses. Поэтому «создадим больше потоков» не означает «получим больше производительности».

#### `TaskScheduler`, `ThreadPool` и OS scheduler

- OS scheduler решает, какой runnable thread получает CPU time.
- `ThreadPool` управляет переиспользуемыми worker threads и очередями work items внутри процесса.
- `TaskScheduler` определяет, где и как планировать выполнение task delegates. `TaskScheduler.Default` использует `ThreadPool`.
- `Task.Run` обычно ставит delegate в default scheduler; он не создаёт отдельный процессор или гарантированный новый thread.
- Async I/O completion может активировать continuation без отдельного Task delegate для самой I/O операции. Место продолжения зависит от захваченного контекста/scheduler и awaiter semantics.

`TaskScheduler` не является scheduler операционной системы и не равен `ThreadPool`. Custom scheduler возможен, но в обычном ASP.NET Core коде применяется редко; важнее понимать default behavior, очереди и отсутствие гарантии thread affinity.

Глубокое изучение CPU caches, memory ordering, `Interlocked`/CAS и lock-free progress guarantees запланировано на дни 3–4 вместе с CLR memory model.

### 5. Что именно делает `Task.WhenAll`

`WhenAll` создаёт aggregate task и наблюдает переданные tasks. Он не запускает уже созданные операции, не владеет ими и не отменяет siblings автоматически.

Aggregate task переходит в конечное состояние только после завершения всех constituent tasks:

| Состояния входных tasks | Состояние `WhenAll` |
|---|---|
| Есть хотя бы один fault | `Faulted` |
| Fault нет, но есть cancellation | `Canceled` |
| Все успешны | `RanToCompletion` |

Fault имеет приоритет над cancellation для итогового статуса. При `Task.WhenAll<T>` массив результатов соответствует порядку входных tasks, а не порядку их завершения.

`await` faulted aggregate task обычно выбрасывает одно исходное исключение. Сам aggregate Task хранит набор ошибок в `Exception.InnerExceptions`; если контракт требует диагностировать все failures, нужно сохранить ссылку на aggregate task и явно исследовать её после completion.

### 6. Ожидание всех и fail-fast — разные свойства

`Task.WhenAll` даёт deterministic join: вызывающий код продолжится после terminal state всех задач. Но это не fail-fast orchestration.

Чтобы после первой критической ошибки быстро остановить siblings, им нужен общий механизм:

1. внутренний `CancellationTokenSource`;
2. его token передаётся producer, readers и I/O операциям;
3. критически упавшая задача вызывает `Cancel()` у этого source;
4. остальные операции cooperative завершаются;
5. `WhenAll` наблюдает terminal state всех задач и не оставляет фоновые операции без наблюдения.

Важно: если вызвать общий `Cancel()` только в `catch` вокруг `await Task.WhenAll(...)`, будет поздно — `WhenAll` уже дождался всех задач. Сигнал должен исходить из faulting producer/consumer либо из отдельного раннего наблюдателя.

### 7. Ownership cancellation

`CancellationToken` — read-only представление сигнала. Он не имеет `Cancel()`. Инициировать отмену может владелец `CancellationTokenSource`.

Для pipeline обычно есть два источника остановки:

- внешний token: caller отменил запрос или host завершает работу;
- внутренняя ошибка: producer либо consumer больше не может поддерживать контракт.

Они объединяются:

```csharp
using var pipelineCts =
    CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);

var pipelineToken = pipelineCts.Token;
```

Внешняя отмена распространяется внутрь. Внутренний `pipelineCts.Cancel()` не отменяет source, которому принадлежит внешний token, и не затрагивает посторонние операции, которым pipeline token не передавался.

`Cancel()` только сигнализирует. Если метод проверил сигнал и сделал обычный `return`, его Task завершается успешно. Если cancellation exception проброшено через async boundary, Task завершается как Canceled. Если исключение отмены проглочено и метод дошёл до конца, внешний Task обычно будет RanToCompletion.

### 8. Жизненный цикл channel

У channel есть независимые стороны:

- `ChannelWriter<T>` публикует элементы и сообщает, что записей больше не будет;
- `ChannelReader<T>` читает имеющиеся элементы и ожидает новые;
- completion сообщает readers, почему поток данных закончился.

Успешная последовательность:

1. Producer записывает все элементы.
2. Writer завершается без ошибки.
3. Consumers дочитывают буфер.
4. `ReadAllAsync` завершается.
5. Consumer tasks завершаются.

Producer fault без completion опасен: consumers опустошат буфер и навсегда останутся ждать данные, которые больше никто не запишет.

При ошибке writer должен завершить channel с причиной:

```csharp
Exception? completionError = null;

try
{
    // WriteAsync(...)
}
catch (Exception exception)
{
    completionError = exception;
    throw;
}
finally
{
    writer.TryComplete(completionError);
}
```

Пустой `TryComplete()` в `finally` скрывает причину producer failure от readers. `TryComplete(error)` сообщает downstream, что поток данных закончился аварийно.

### 9. Bounded channel и backpressure

У bounded channel есть capacity. При `FullMode = Wait` заполненный буфер не принимает следующую запись немедленно: `WriteAsync` остаётся незавершённым до появления места.

Это backpressure, или обратное давление: скорость producer вынужденно приближается к способности consumers обрабатывать данные.

Для capacity 100 и 20 sequential consumers:

- в очереди находится не больше 100 элементов;
- одновременно выполняется не больше 20 вызовов обработки;
- producer не может бесконечно наращивать очередь;
- число worker tasks постоянно и не зависит от числа входных элементов.

Итоговый массив размером `ids.Count` всё равно требует `O(n)` памяти. Это не делает рабочую очередь unbounded: output memory следует из контракта «вернуть результат для каждого входа». Нужно отдельно оценивать input, output, queued work и active work.

Остальные full modes (`DropNewest`, `DropOldest`, `DropWrite`) меняют контракт и допустимы только там, где потеря данных явно разрешена и наблюдаема.

### 10. Shared results и входной порядок

Обычный `List<T>` не поддерживает конкурентный `Add`: consumers одновременно меняют размер, позицию следующего элемента и иногда внутренний массив. Это может привести не только к неправильному порядку, но и к повреждению состояния.

Если producer присваивает каждому входу уникальный индекс, проще заранее выделить массив:

```csharp
var results = new ItemResult[ids.Count];

// Каждый index производится ровно один раз.
results[item.Index] = result;
```

Разные consumers записывают разные ячейки; структура массива не изменяется. После завершения всех consumers массив уже находится во входном порядке, поэтому `OrderBy` не нужен.

`ConcurrentDictionary<int, ItemResult>` тоже может обеспечить thread safety, но здесь добавляет hashing, более сложный контракт полноты и последующую сборку упорядоченного результата без полезного выигрыша.

## Выбор механизма

| Механизм | Что ограничивает | Что не решает автоматически | Когда выбирать |
|---|---|---|---|
| Прямой `Task.WhenAll` | Ничего | Fan-out, downstream overload, memory | Маленькое заранее ограниченное число независимых операций |
| `SemaphoreSlim` вокруг I/O | Число вошедших в критическую секцию | Создание outer task на каждый input, bounded queue, completion protocol | Простой метод с умеренным входом, когда очередь tasks допустима |
| `Parallel.ForEachAsync` | Число одновременно выполняемых iterations через `MaxDegreeOfParallelism` | Упорядоченный output и custom producer/consumer lifecycle | Простая bounded обработка enumerable без отдельной очереди |
| Bounded `Channel<T>` | Размер очереди и, через число workers, active work | Failure contract, cancellation ownership и output aggregation | Streaming, разные скорости producer/consumer, несколько stages, явный backpressure |

`SemaphoreSlim` требует строгого pairing:

```csharp
await semaphore.WaitAsync(cancellationToken);
try
{
    await operation(cancellationToken);
}
finally
{
    semaphore.Release();
}
```

`try/finally` начинается только после успешного `WaitAsync`. Если отменённый `WaitAsync` находится внутри `try`, `finally` может вызвать лишний `Release`, хотя semaphore не был захвачен.

## Failure matrix для `CollectAsync`

До реализации заполни ожидаемое поведение:

| Событие | Что происходит с item | Что происходит с pipeline | Чем завершается внешний Task |
|---|---|---|---|
| Все `LoadAsync` успешны | Success для каждого id | Полностью дренируется | RanToCompletion |
| Ожидаемая `ItemLoadException` | Failure в своём index | Остальные продолжают | RanToCompletion со всеми ItemResult |
| Неизвестная инфраструктурная ошибка | Результат не маскирует ошибку | Внутренняя отмена siblings | Faulted |
| Caller cancellation | Partial array не возвращается | Все stages получают сигнал | Canceled |
| Producer fault | Новых элементов не будет | Channel закрывается с ошибкой, siblings останавливаются | Faulted |
| Один consumer падает | Его ошибка не проглатывается | Producer и другие consumers останавливаются | Faulted |

## Active notes — 25 минут

Закрой источники и ответь письменно своими словами:

1. Почему `WhenAll` не является fail-fast orchestration?
2. Почему producer fault без `TryComplete(error)` способен навсегда оставить readers в ожидании?
3. Чем закрытие channel отличается от cancellation pipeline?
4. Кто имеет право вызывать `Cancel()` и почему `CancellationToken` не даёт этот метод?
5. Почему linked CTS не отменяет исходный source в обратную сторону?
6. Какие четыре независимые величины нужно оценить для boundedness: input, output, queue и active work?
7. Почему `SemaphoreSlim(20)` не обязательно ограничивает число созданных outer tasks?
8. Почему массив по уникальному index безопаснее общего `List<T>` для текущего контракта?
9. Почему `catch (Exception) { return Failure; }` нарушает fail-whole contract?
10. Когда `Parallel.ForEachAsync` проще `Channel<T>`, а когда channel оправдан?
11. Чем OS scheduler отличается от `TaskScheduler` и `ThreadPool`?
12. Почему 100 CPU-bound tasks на восьми cores не становятся в 12,5 раза быстрее только из-за `Task.Run`?
13. Какая цепочка проходит от C#-метода через JIT до выполнения машинных инструкций?

## Практика после теории

### Упражнение 1 — failure trace, 20 минут

Для каждого сценария из failure matrix выписать:

- какая задача первой меняет состояние;
- кто подаёт внутренний сигнал отмены;
- кто завершает writer;
- как выходят readers;
- когда может завершиться общий `WhenAll`.

### Упражнение 2 — исправленный `CollectAsync`, 35 минут

Переписать `sessions/2026-08-31-async-collectasync.md` по контракту:

- `ItemLoadException` становится `ItemResult.Failure`;
- cancellation и неизвестные ошибки завершают pipeline;
- producer completion всегда детерминирован;
- используется linked pipeline token;
- results хранятся по index;
- producer и consumers наблюдаются совместно.

### Упражнение 3 — тестовый дизайн, 25 минут

Спроектировать минимум пять детерминированных тестов без `Task.Delay` как основного средства синхронизации:

1. результаты сохраняют входной порядок при обратном порядке completion;
2. ожидаемая ошибка одного item не останавливает остальные;
3. producer fault не оставляет consumers висеть;
4. инфраструктурный consumer fault отменяет siblings;
5. caller cancellation завершает внешний Task как Canceled.

Для управления моментами completion использовать `TaskCompletionSource` с `RunContinuationsAsynchronously`, barrier/gate либо контролируемый fake client.

### Упражнение 4 — выбор primitive, 20 минут

Для трёх вариантов выбрать `WhenAll`, `SemaphoreSlim`, `Parallel.ForEachAsync` или `Channel<T>` и защитить решение:

1. Всегда не больше пяти заранее известных HTTP-запросов.
2. Обработка списка до 50 000 ids с лимитом 20, весь input уже в памяти.
3. Непрерывный поток событий, producer способен обогнать consumers, нужна ограниченная очередь.

## Timed assessment

После практики проводится:

- 4 определения по 90 секунд;
- 3 причинных сравнения по 2 минуты;
- один failure trace на 5 минут;
- review исправленного `CollectAsync` на 12 минут;
- защита тестового дизайна на 5 минут.

Pass дня 2 требует не менее `3/4` по correctness и production judgment на новом applied snippet. Исправленная сразу после объяснения версия остаётся provisional; retention проверяется новым wording через 1–3 дня.

## Checklist завершения дня 2

- [ ] Пройден обязательный theory route на 240 минут.
- [ ] Написаны active notes без источников.
- [ ] Заполнена failure matrix своими словами.
- [ ] Реализован исправленный `CollectAsync`.
- [ ] Спроектированы пять детерминированных тестов.
- [ ] Пройден timed assessment.
- [ ] Evidence обновлено в `fundamentals.md` и `progress.md`.
