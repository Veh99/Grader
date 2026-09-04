# День 1 — async, concurrency, multithreading и parallelism

Дата выдачи: 2026-08-31  
Theory package: 240 минут  
Практика после теории: 90–120 минут  
Режим проверки: closed-book, timed, один вопрос за раз

## Результат дня

После изучения материала кандидат должен уметь:

- за 90 секунд определить асинхронность;
- за 2 минуты различить async, concurrency, parallelism и multithreading;
- объяснить process, thread, ThreadPool и `Task` без отождествления этих понятий;
- проследить выполнение async-метода до первого незавершённого `await` и после continuation;
- выбрать корректный подход для I/O-bound и CPU-bound работы;
- объяснить последовательный и конкурентный запуск задач;
- описать cooperative cancellation и распространение исключений;
- заметить базовые race conditions и объяснить, почему async-код тоже может иметь shared-state bugs.

Day 1 не закрывает bounded pipelines, Channels и полный failure contract. Это applied-часть дня 2 вместе с `CollectAsync`.

## Маршрут на 240 минут

Проходить по порядку. Время — рабочий лимит, а не требование читать страницу до последней ссылки.

| Время | Материал | Тип | Что получить на выходе |
|---:|---|---|---|
| 40 мин | Раздел `Original digest` ниже | original, required | Связная карта терминов и механизм `async`/`await` |
| 40 мин | [Microsoft: Asynchronous programming scenarios](https://learn.microsoft.com/en-us/dotnet/csharp/asynchronous-programming/async-scenarios) | official, required | I/O-bound vs CPU-bound, TAP, state machine, `await` без блокировки |
| 35 мин | [Threads and threading](https://learn.microsoft.com/en-us/dotnet/standard/threading/threads-and-threading) и [The managed thread pool](https://learn.microsoft.com/en-us/dotnet/standard/threading/the-managed-thread-pool) | official, required | Process/thread/ThreadPool, стоимость блокировки и область применения |
| 35 мин | [Task Parallel Library](https://learn.microsoft.com/en-us/dotnet/standard/parallel-programming/task-parallel-library-tpl) и начало [Task-based asynchronous programming](https://learn.microsoft.com/en-us/dotnet/standard/parallel-programming/task-based-asynchronous-programming) | official, required | `Task` как abstraction, scheduling, concurrency/parallelism |
| 40 мин | [Stephen Toub: How Async/Await Really Works in C#](https://devblogs.microsoft.com/dotnet/how-async-await-really-works/) — introduction, callbacks/continuations и compiler/state-machine sections | official deep dive, required | Причинная модель продолжения метода без мифа «await создаёт поток» |
| 30 мин | [ВСЁ О МНОГОПОТОЧНОСТИ В C#](https://www.youtube.com/watch?v=8NW5vrhMfN0) | video, required | Повтор терминов: thread/process, async, ThreadPool, race, semaphore, `WhenAll` |
| 20 мин | Active notes по шаблону ниже | retrieval preparation, required | Собственный конспект без копирования формулировок |

Дополнительный русскоязычный материал, не входящий в 240 минут: [Metanit — async/await](https://metanit.com/sharp/tutorial/13.3.php). Использовать только как второе объяснение. Caveat: утверждение, что async-методы в общем случае выполняются в отдельных потоках, некорректно как универсальная модель; сверять с Microsoft docs.

## Original digest

### 1. Четыре разных понятия

#### Синхронное выполнение

Синхронный вызов не возвращает управление вызывающему коду, пока вызываемая операция не завершит текущий участок работы. Если поток вызывает блокирующее чтение из сети, этот поток не может обслуживать другую работу до возврата вызова.

Синхронность не означает «один поток во всей программе». Несколько потоков могут каждый выполнять синхронный код.

#### Асинхронность

Асинхронность — способ организовать операцию так, чтобы инициатор мог не удерживать поток в заблокированном ожидании результата. Операция представляется объектом или callback-механизмом, через который позднее сообщается completion: success, failure или cancellation.

В .NET основной прикладной контракт — Task-based Asynchronous Pattern: операция возвращает `Task` или `Task<T>`, а вызывающий код может применить `await`.

Ключевой смысл для backend: пока запрос к БД или сети ожидает внешнюю систему, поток может вернуться в пул и обслуживать другую работу. Асинхронность не ускоряет сам внешний сервис; она улучшает использование ограниченного ресурса — потоков.

#### Concurrency, или конкурентность

Concurrency означает, что несколько работ находятся в прогрессе в пересекающийся период времени. Они могут чередоваться на одном CPU core или действительно выполняться одновременно. Concurrency описывает структуру программы и управление несколькими незавершёнными работами.

Один поток event loop может конкурентно координировать много I/O операций, хотя в конкретный момент выполняет инструкции только одной continuation.

#### Parallelism, или параллелизм

Parallelism означает фактическое одновременное выполнение вычислений, обычно на нескольких ядрах. Он полезен для достаточно крупной независимой CPU-bound работы. Параллелизм — один из способов реализации concurrency, но не вся concurrency является parallelism.

#### Multithreading, или многопоточность

Multithreading означает наличие нескольких потоков выполнения внутри процесса. Потоки могут работать параллельно на разных ядрах либо конкурентно делить процессорное время. Многопоточность — механизм исполнения; асинхронность — модель ожидания и композиции операций.

Короткая формула:

- async: как не блокировать вызывающий поток во время ожидания;
- concurrency: как управлять несколькими незавершёнными работами;
- parallelism: как одновременно выполнять вычисления;
- multithreading: как использовать несколько потоков исполнения.

### 2. Process, thread и ThreadPool

Process — изолированный экземпляр программы со своим виртуальным адресным пространством и ресурсами ОС.

Thread — единица выполнения, которой ОС выделяет процессорное время. У потока есть стек и execution context. Потоки одного процесса разделяют heap и другие process resources. Поэтому shared mutable state создаёт race conditions.

Создание отдельного `Thread` относительно дорого: нужны ресурсы ОС и stack reservation, а управление жизненным циклом ложится на приложение.

ThreadPool — управляемый runtime-пул переиспользуемых worker threads. Короткая CPU-работа и многие continuations могут планироваться в него без создания отдельного потока на каждую операцию. Пул регулирует число активных потоков и ставит лишнюю работу в очередь.

Если pool threads массово блокируются через `Thread.Sleep`, `.Result`, `.Wait()` или долгие synchronous I/O, новые работы ждут свободные потоки. Это может проявляться как ThreadPool starvation: растущая latency, очередь work items и медленное увеличение числа потоков.

ThreadPool не является бесконечным и не является очередью бизнес-задач с durability. Это runtime-механизм исполнения.

### 3. Что такое Task

`Task` — объект, представляющий eventual completion операции. У него есть состояние, completion, результат для `Task<T>`, exception либо cancellation.

`Task` не равен `Thread`:

- I/O task может быть незавершённым, хотя никакой поток не выполняет пользовательский код;
- несколько continuations могут в разное время выполняться на разных pool threads;
- одна thread-pool thread последовательно выполняет множество разных task continuations;
- `Task.FromResult` уже завершён и не требует потока;
- `TaskCompletionSource<T>` может представить completion внешнего события без отдельного worker thread.

`Task.Run` обычно ставит delegate на ThreadPool. Это полезно для CPU-bound работы, которую нужно снять с текущего потока, но не требуется для естественно асинхронного HTTP/DB/file API. Обёртывание `HttpClient.GetAsync` в `Task.Run` добавляет scheduling overhead и не превращает I/O в «более async».

### 4. Как начинается async-метод

Рассмотрим:

```csharp
static async Task<int> LoadLengthAsync(HttpClient client, string url)
{
    Console.WriteLine("A");
    var text = await client.GetStringAsync(url);
    Console.WriteLine("B");
    return text.Length;
}
```

Вызов `LoadLengthAsync` начинает выполнять тело синхронно на текущем потоке. Выполняется `A`, вызывается `GetStringAsync`, затем проверяется awaiter.

Если task уже завершён, `await` не обязан приостанавливать метод: выполнение может сразу пойти дальше к `B`.

Если task не завершён:

1. метод сохраняет нужное состояние;
2. регистрирует continuation;
3. возвращает вызывающему коду незавершённый `Task<int>`;
4. текущий поток освобождается для другой работы;
5. после completion ожидаемой операции continuation планируется согласно awaiter/context rules;
6. метод возобновляется с сохранённого состояния.

`async` modifier сам по себе не запускает метод в фоне. Он разрешает `await` и заставляет компилятор преобразовать метод в state machine, когда это требуется.

### 5. State machine и continuation

Компилятор должен сохранить локальные значения, точку продолжения и информацию о незавершённой операции. Концептуально async-метод превращается в state machine с методом `MoveNext`.

Continuation — оставшаяся после `await` часть логического метода. Она выполняется, когда awaited operation завершилась. «Тот же метод» до и после `await` может физически выполняться на разных потоках, особенно в ASP.NET Core, где нет требования возвращаться на UI thread.

SynchronizationContext или scheduler может влиять на место продолжения. Для backend-интервью важно не повторять desktop-правило как универсальное: современный ASP.NET Core обычно не имеет request SynchronizationContext, поэтому классический UI deadlock model нельзя механически переносить на сервер. Но sync-over-async всё равно блокирует потоки и ухудшает scalability.

### 6. I/O-bound и CPU-bound

I/O-bound операция большую часть wall-clock времени ждёт сеть, диск, БД или другую внешнюю систему. Предпочтение: использовать естественный async API и `await`, передавать cancellation token, задавать timeout и не занимать поток ожиданием.

CPU-bound операция тратит время на вычисления. `await` сам по себе не уменьшает CPU cost. В UI приложении `Task.Run` может снять тяжёлое вычисление с UI thread. В backend бессмысленное `Task.Run` часто просто переносит CPU work с одного pool thread на другой; для throughput важнее ограничение параллелизма, алгоритм и capacity.

Примеры:

- HTTP request, DB query, `FileStream.ReadAsync`: обычно I/O-bound;
- compression, image transform, hashing большого блока, сложная математика: CPU-bound;
- JSON parsing после HTTP response: CPU phase внутри I/O-heavy flow;
- `Thread.Sleep`: блокирующее ожидание, не полезная CPU работа и не настоящий async I/O;
- `Task.Delay`: timer-backed asynchronous wait, не удерживающий поток на всё время задержки.

### 7. Последовательность и concurrency задач

```csharp
var a = await LoadAsync("a");
var b = await LoadAsync("b");
```

Второй вызов начинается после завершения первого. Это последовательная композиция.

```csharp
var aTask = LoadAsync("a");
var bTask = LoadAsync("b");
await Task.WhenAll(aTask, bTask);
```

Оба async-метода вызваны до ожидания общего completion, поэтому операции могут находиться in-flight конкурентно.

`Task.WhenAll` не запускает переданные tasks и не создаёт потоки. Он создаёт task, завершающийся после завершения всех входных tasks. Для `Task<T>[]` массив результатов соответствует порядку входных tasks, а не порядку фактического completion.

Concurrency должна быть ограниченной. Создать миллион async calls — не то же самое, что создать миллион потоков, но это всё равно может создать миллион `Task`/state-machine объектов, очередь ожиданий, pressure на downstream и память.

### 8. Cancellation — запрос, а не принудительное убийство

`CancellationTokenSource.Cancel()` только сигнализирует. Операция должна наблюдать token:

- передать его нижележащему async API;
- периодически вызвать `ThrowIfCancellationRequested()` в длинном цикле;
- зарегистрировать callback, если это действительно нужно.

Если нижний API игнорирует token, верхний метод не может гарантировать остановку физической операции. Он может прекратить своё ожидание или вернуть timeout, но внешний side effect иногда продолжится. Поэтому timeout и cancellation не равны rollback.

Для статуса `Canceled` task обычно завершает работу через `OperationCanceledException` с соответствующим token. Если просто `return` после проверки флага, task может завершиться успешно, хотя caller запрашивал cancellation.

Не следует ловить общий `Exception` и превращать `OperationCanceledException` в обычный business failure, если контракт требует отменить весь pipeline.

### 9. Exceptions в async-коде

Исключение до первого фактического suspension и исключение после continuation сохраняются в возвращаемом task для методов `async Task`/`Task<T>`. Caller наблюдает его при `await`.

`async void` не предоставляет вызывающему task для ожидания и нормального наблюдения ошибок. Он допустим главным образом для event handlers с соответствующим контрактом.

`Task.WhenAll` ожидает завершения всех входных tasks. Если хотя бы одна faulted, общий task faulted; если faults нет, но есть cancellation, общий task canceled; иначе completion successful. `WhenAll` сам не отменяет остальные работы после первого failure.

Fire-and-forget без явного owner означает потерю контроля над exception, cancellation, lifetime и graceful shutdown. В backend durable работа обычно требует очереди/outbox/background service с явным ownership, а не отброшенного task.

### 10. Race condition и thread safety

Async не устраняет shared mutable state. После `await` другая операция могла изменить данные. Несколько consumers могут продолжиться на разных pool threads и одновременно вызвать не-thread-safe API.

```csharp
var results = new List<int>();

await Task.WhenAll(
    Enumerable.Range(0, 20).Select(async i =>
    {
        await Task.Delay(10);
        results.Add(i);
    }));
```

`List<T>` не поддерживает concurrent writes. Возможны потерянные updates, повреждение внутреннего состояния или exceptions. Исправление зависит от контракта: lock, concurrent collection, отдельный slot по index, single-writer aggregation или channel.

Thread-safe collection не делает атомарной произвольную последовательность «проверить, затем изменить». Инвариант нужно защищать на уровне всей критической секции либо заменять операцию на atomic primitive.

### 11. Как отвечать на интервью

На вопрос «что такое асинхронность?» не начинай сразу с `async`/`await`. Сначала дай модель:

1. это организация ожидания без удержания вызывающего потока;
2. в .NET операция обычно представлена `Task`;
3. `await` приостанавливает логический метод, а не блокирует thread;
4. это особенно полезно для I/O-bound backend;
5. async не означает новый thread и не равен parallelism.

На сравнительный вопрос используй одну ось на понятие: ожидание, структура in-flight work, физическое одновременное вычисление, механизм потоков.

### 12. Типичные ошибочные утверждения

- «`async` запускает новый поток» — нет, сам modifier этого не делает.
- «`await` запускает task» — обычно операция уже была инициирована вызовом; await наблюдает completion.
- «`Task` — лёгкий поток» — task представляет completion и не имеет взаимно-однозначной связи с thread.
- «Асинхронность ускоряет код» — она может улучшить responsiveness/scalability, но добавляет overhead и не ускоряет CPU calculation или downstream.
- «`WhenAll` выполняет задачи параллельно» — он наблюдает уже предоставленные tasks; фактическая concurrency зависит от их создания и реализации.
- «Cancellation останавливает всё немедленно» — она cooperative.
- «Нет shared threads, значит нет race» — interleaving continuations уже достаточно для race, а backend continuations часто работают на разных threads.

## Active notes — 20 минут

Закрой источники и письменно заполни без копирования:
1. Асинхронность — это процесс, который не заставляет вызывающий код ждать выполнение внешнего вызова. В качестве сигнатуры используются ключевые слова
async, await. В качестве возвращаемого результата используется класс Task, Task<T>, которые ползволяют отслеживать статус процесса, и получать результат
2. Concurrency отличается от parallelism тем, что параллелизм используется для вычислительных задач, а конкуренция возникает из-за того что потоки конкурируют между собой при
выполнении задач, к примеру по типу записи, несколько потоков могут пытаться в одну ячейку вписать разные значения
3. Multithreading — это механизм многопоточности, который позволяет управлять несколькими потоками исполнения, но он не обязателен для асинхронности
4. `Task` представляет объект не то чтобы наблюдения, но как будто контроля выполнения задач, он отслеживает статусы(completion, faul, cancel) и результат(Task.Result), а не поток
5. Async-метод до первого incomplete `await`... уже начинает выполняться, await не означает запуск задачи, а скорее наблюдение за тем когда эта задача завершится, чтобы вернуть результат
6. При incomplete `await` runtime/compiler... не понимаю терминологию пиши по русски или давай альтернативу русскую и лучше формулируй вопросы, больше контекста
7. Для I/O-bound выбираю стандартную асинхронность с помощью async await, потому что она позволяет не блокировать поток из-за ожидания выполнения задачи внешним io сервисами
8. Для CPU-bound рассматриваю parallelism, но в backend проверяю ????
9. Cancellation cooperative, потому что не факт что метод куда мы передаем токен, этот токен как-то учитывается
10. Три production-риска unbounded concurrency: не знаю, выражайся понятно, а то получается что половина текста на русском половина на английсмком и не понятно ничего

После заполнения сравни только фактические расхождения с digest. Не переписывай весь текст.

## Практика после теории

Ответы заранее в файл не записываются. Выполнить до запуска chat assessment.

### Упражнение 1 — классификация, 15 минут

Для каждого случая указать: I/O-bound или CPU-bound; нужен ли async API; нужен ли `Task.Run`; где возникает concurrency/parallelism.

1. ASP.NET endpoint вызывает PostgreSQL и ждёт строки. - I/o bound(что такое bound??), нужен async API, task.run не нужен(не знаю почему), concurrency может возникнуть когда несколько потоков попытаюся взаимодействовать с одной ячейкой, строкой, таблицей
2. Endpoint вычисляет SHA-256 для 2 GB уже находящихся в памяти данных. - cpu bound, не нужен, потому что async не влияет на cpu bound, можно использовать task.run чтобы не зависало выполнение программы, но рискуем потерять ошибки потому что это fire-and-forget, поэтому вероятнее task.run использовать нельзя, лучше попробовать использовать parallelism или multithreading(не понимаю в чем у них принципиальная разница)
3. WPF UI генерирует большой отчёт CPU-heavy алгоритмом. - cpu bound очевидно, ты же в вопросе это сам написал, async api тут не поможет, task.run тоже бессмысленен
4. Worker одновременно вызывает 50 HTTP endpoints. - тут уже i/o bound где async уже хорошо смотрится, task.run не нужен(если честно так и не понял для каких-таких случваев он может быть полезен, если вреда от него как будто больше), не возникает
5. `Parallel.ForEach` преобразует 10 миллионов независимых чисел. - i/o bound, нужен параллелизм/многопоточность чтобы эти вычисления выполнять одновременно разными потоками и быстрее получить результат 

### Упражнение 2 — code trace, 20 минут

Без запуска кода выписать гарантированный порядок, возможный порядок и приблизительное время:

```csharp
static async Task WorkAsync(string name, int delay)
{
    Console.WriteLine($"{name}:start");
    await Task.Delay(delay);
    Console.WriteLine($"{name}:end");
}

Console.WriteLine("main:start");

var first = WorkAsync("A", 300);
var second = WorkAsync("B", 100);

Console.WriteLine("main:created");
await Task.WhenAll(first, second);
Console.WriteLine("main:end");
```
Гарантированный порядок:
maincreated
сначала будет delay 400мс а потом выйдет сразу результат по всем таскам
А :start,A:end, В:start, B:end, mainend

task.whenall ничего не запускал, а если и запускал, то наблюдение за статусом задач, и когда они все выполнились он вернул освободил поток и вызывающий код продолжил работу - вызвал Console.WriteLine("main:end");

Отдельно ответить: что здесь «запустил» `WhenAll`?

### Упражнение 3 — исправление sequential async, 20 минут

Переписать метод так, чтобы независимые запросы выполнялись конкурентно, cancellation доходила до каждого вызова, а результат сохранял поля пользователя, заказов и баланса.

```csharp
public async Task<Dashboard> LoadDashboardAsync(
    Guid userId,
    CancellationToken cancellationToken)
{
    var transaction = _dbContext.newTransaction() - не знаю как правильно создавать

    так же еще надо использовать sql запрос с read commited чтобы все данные были синхронизированы, потому что пока мы запрошиваем пользователя, таблица заказов может измениться
    try
    {
    var user = _users.GetAsync(userId, cancellationToken);
    var orders = _orders.GetRecentAsync(userId, cancellationToken);
    var balance = _billing.GetBalanceAsync(userId, cancellationToken);
    }
    catch(UserEx ex){
    }
     catch(OrdersEx ex){
    }
     catch(BillingEx ex){
    }
     catch(OperationCanceled ex){
    }
    finally{
         transaction.Rollback
    }
    await Task.WhenAll(user, orders, balance);
    transaction.Commit
    return new Dashboard(user, orders, balance);
}
```

До кода сформулировать contract при failure одного dependency. На день 1 допустим fail-whole; partial-result contract будет позже.

### Упражнение 4 — cancellation review, 20 минут

Найти минимум четыре проблемы или неоднозначности:

```csharp
public async Task ProcessAsync(CancellationToken cancellationToken)
{
    try
    {
        for (var i = 0; i < 1_000_000; i++)
        {
            await _client.SendAsync(CreateRequest(i));
        }
    }
    catch (Exception exception)
    {
        _logger.LogWarning(exception, "Processing failed");
    }
}

1. Может создаться миллион тасок(state-machine c move-next внутри)
2. Нет cancellation token, хоть он и передается в сигнатуре
3. Кроме выписывания лога ничего не происходит, то есть мы практически молча пропускаем часть задач, нет повторных попыток или информирования вызывающего сервиса о результате

```

### Упражнение 5 — короткое объяснение, 15 минут

Записать ответ на 90 секунд: «Почему асинхронный ASP.NET Core endpoint способен повысить throughput при I/O, хотя запрос не выполняется быстрее?»

потому что не требудет thread ui или что то такое, видимо не требует чтобы тот же поток который брал задачу, ее же и возвращал, в асп нет любой свободный поток, енобязательно вызывающий может вернуть результат задачи
## Запуск опроса в чате

После теории и практики написать:
вместо твоего видео я предпочел другое https://www.youtube.com/watch?v=n7rY4uyC50s&t=17s, всегда опирайся на комментарии и отзывы, репутацию канала, серьезно ли настроен канал на обучение или делает видео просто ради того чтобы делать видео
и посмотрел еще более глубокую версию асинхронности где рассказывается про state machine https://www.youtube.com/watch?v=_suxE9frTFA

далее не забывай тоже что по всем темам надо знать не только поверхностое использование но и как это устроено "под капотом" это тоже могут спросить и повлияет на уровень зп, грейд
```text
День 1 изучен. Готов к timed-опросу.
```

Опрос проводится closed-book, по одному вопросу:

- 6 определений по 90 секунд;
- 3 сравнения по 2 минуты;
- 2 code-reading вопроса по 5 минут;
- один причинный follow-up по weakest signal.

Каждый ответ завершается `T=мм:сс`. Оценки: correctness, depth, communication и timing/fluency. После опроса отдельно разбираются ошибки; во время первичной попытки ответы не подсказываются.

## Checklist завершения дня 1

- [x] Пройден обязательный theory route на 240 минут.
- [x] Написаны active notes без источников.
- [x] Выполнены пять упражнений.
- [x] Пройден timed chat assessment.
- [x] Ошибки записаны в `fundamentals.md`/`progress.md` после оценки.

Итоговый отчёт: `sessions/2026-09-01-day-01-async-assessment.md`.
