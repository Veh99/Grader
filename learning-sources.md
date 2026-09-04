# Политика учебных источников

Обновлено: 2026-09-01

## Назначение

Каждый из дней 1–12 получает theory package примерно на 4 часа чистого изучения. Это не список ссылок «на будущее», а конечный маршрут на один день. Практика и timed chat assessment идут сверх этих четырёх часов.

## Иерархия источников

1. `Ground truth`: актуальная официальная документация Microsoft/.NET, PostgreSQL и других владельцев технологии.
2. `Original digest`: агрегированный русскоязычный конспект, написанный специально под интервью и текущие пробелы кандидата.
3. `Deep model`: выбранные главы книг; используются идеи и структура, без длинного воспроизведения текста.
4. `Secondary explanation`: Metanit, проверенные статьи и YouTube. Они помогают с первым пониманием, но проверяются по ground truth.
5. `Practice`: LeetCode/HackerRank/SQL-площадки только для навыков, которые они реально измеряют; остальное — custom production-shaped tasks.

## Формат дневного маршрута

Каждый пункт содержит:

- название и прямую ссылку либо точное название главы;
- тип: `official`, `book`, `video`, `secondary`, `practice`;
- длительность;
- `required` или `optional`;
- что нужно уметь объяснить/сделать после изучения;
- caveat, если материал устарел, упрощает модель или использует другую версию стека.

Каждый день 1–12 обязательно содержит минимум одно YouTube-видео в `required` route. Видео входит в суммарные четыре часа, а не добавляется сверх дневного theory package.

## Проверка вторичных источников и видео

Перед включением ролика или статьи в `required` route проверяются: автор и его технический опыт, регулярность и учебная направленность канала, дата и версия стека, длительность, описание, главы/таймкоды или transcript, наличие кода/ссылок на первичные источники, точность ключевых тезисов и полезные исправления в комментариях. Просмотры, лайки, отзывы и репутация канала используются как сигналы отбора, но не как доказательство технической корректности.

Комментарии особенно полезны для поиска спорных мест и errata. Каждый существенный runtime/API тезис после этого сверяется с официальной документацией, исходным кодом или публикациями команды платформы. Недоступность комментариев или метаданных должна быть явно отмечена; такой источник нельзя объявлять проверенным только по названию.

Для каждого назначенного видео в дневном файле фиксируются:

- канал, автор/спикер, дата, длительность и язык;
- просмотры, likes и число комментариев на дату проверки;
- полезные таймкоды и ожидаемый результат просмотра;
- положительные сигналы из комментариев и найденные возражения/исправления;
- конкретный caveat: что ролик не покрывает или где его нельзя использовать как ground truth.

Сумма `required` theory items должна быть близка к 4 часам. Optional items не входят в обязательный дневной объём.

## Проверенный базовый пул

### C#/.NET и async

- Microsoft Learn, `Asynchronous programming with async and await`: https://learn.microsoft.com/en-us/dotnet/csharp/asynchronous-programming/
- Microsoft Learn, `Asynchronous programming scenarios`: https://learn.microsoft.com/en-us/dotnet/csharp/asynchronous-programming/async-scenarios
- C# reference, `await operator`: https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/operators/await
- Microsoft Learn, `Managed execution process` (CIL, JIT, native code): https://learn.microsoft.com/en-us/dotnet/standard/managed-execution-process
- Microsoft Learn, `The managed thread pool`: https://learn.microsoft.com/en-us/dotnet/standard/threading/the-managed-thread-pool
- Microsoft Learn, `TaskScheduler`: https://learn.microsoft.com/en-us/dotnet/api/system.threading.tasks.taskscheduler
- Microsoft Learn, `Task Parallel Library`: https://learn.microsoft.com/en-us/dotnet/standard/parallel-programming/task-parallel-library-tpl
- Metanit, актуальное оглавление C#/.NET: https://metanit.com/sharp/tutorial/
- Metanit, `Асинхронные методы, async и await`: https://metanit.com/sharp/tutorial/13.3.php
- Metanit, `Введение в многопоточность`: https://metanit.com/sharp/tutorial/11.1.php
- Metanit, `Task.WhenAll и Task.WhenAny`: https://metanit.com/sharp/tutorial/13.5.php
- YouTube, `ВСЁ О МНОГОПОТОЧНОСТИ В C#`: https://www.youtube.com/watch?v=8NW5vrhMfN0
- Видео, выбранное кандидатом для базового объяснения async: https://www.youtube.com/watch?v=n7rY4uyC50s&t=17s
- Видео, выбранное кандидатом для state machine deep dive: https://www.youtube.com/watch?v=_suxE9frTFA
- Microsoft Learn, `System.Threading.Channels`: https://learn.microsoft.com/en-us/dotnet/core/extensions/channels
- Microsoft Learn, `Task.WhenAll`: https://learn.microsoft.com/en-us/dotnet/api/system.threading.tasks.task.whenall
- Microsoft Learn, `Task cancellation`: https://learn.microsoft.com/en-us/dotnet/standard/parallel-programming/task-cancellation
- Microsoft Learn, `CreateLinkedTokenSource`: https://learn.microsoft.com/en-us/dotnet/api/system.threading.cancellationtokensource.createlinkedtokensource
- .NET Blog, Stephen Toub, `An Introduction to System.Threading.Channels`: https://devblogs.microsoft.com/dotnet/an-introduction-to-system-threading-channels/
- YouTube, official `dotnet`, Stephen Toub, `Working with Channels in .NET`: https://www.youtube.com/watch?v=gT06qvQLtJ0

Важный caveat: формулировки вторичных материалов о том, что async-метод «выполняется в отдельном потоке», нельзя принимать как общую модель. `async`/`await` сами по себе не гарантируют создание нового потока; I/O ожидание и CPU-bound offload рассматриваются отдельно по официальной документации.

Проверка выбранных кандидатом видео через браузер, 2026-09-01:

- `Асинхронность в C# и Asp Net Core на ПРАКТИКЕ`, Kirill Sachkov Development: опубликовано 2024-10-12, около 36,5 тыс. просмотров, 1 491 likes, 144 комментария, канал около 17,4 тыс. подписчиков. В описании есть подробные главы от sync/I/O/CPU до `Task.Run`, `ContinueWith`, `async/await`, `WhenAll` и `WhenAny`. Комментарии преимущественно отмечают ясные практические примеры; содержательные запросы указывают на отсутствующие cancellation и полноценный parallelism. Использовать как базовое объяснение, не как полный runtime/failure-contract материал.
- `CLRium #6: async/await. Машина состояний`, Дмитрий Тихонов: опубликовано 2020-02-07, около 12,5 тыс. просмотров, 375 likes, 14 комментариев. Полезные отметки сообщества: `17:03` state machine, `19:12` custom awaitables, `20:43` synchronous completion, `27:08` `GetAwaiter`, `30:42` method builder, `37:34` await не запускает Task. Комментарии высоко оценивают глубину, но спорят о формулировке параллельности около `38:00`, cancellation-through-exceptions и отсутствии ThreadPool. Использовать для compiler model с обязательной сверкой по Microsoft/.NET Blog.

### Русскоязычные общие материалы

- YouTube-канал `Диджитализируй!`: https://www.youtube.com/@t0digital

Канал может использоваться для общих инженерных, архитектурных и карьерных тем. Конкретный ролик включается в required route только после проверки его соответствия кластеру; название канала само по себе не является критерием качества или актуальности для .NET.

### CLR и управление памятью

- Microsoft Learn, `Managed execution process`: https://learn.microsoft.com/en-us/dotnet/standard/managed-execution-process
- Microsoft Learn, `Value types`: https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/builtin-types/value-types
- Microsoft Learn, `Reference types`: https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/keywords/reference-types
- Microsoft Learn, `Boxing and unboxing`: https://learn.microsoft.com/en-us/dotnet/csharp/programming-guide/types/boxing-and-unboxing
- Microsoft Learn, `Fundamentals of garbage collection`: https://learn.microsoft.com/en-us/dotnet/standard/garbage-collection/fundamentals
- Microsoft Learn, `Large object heap`: https://learn.microsoft.com/en-us/dotnet/standard/garbage-collection/large-object-heap
- Microsoft Learn, `Cleaning up unmanaged resources`: https://learn.microsoft.com/en-us/dotnet/standard/garbage-collection/unmanaged
- Microsoft Learn, `Implement a Dispose method`: https://learn.microsoft.com/en-us/dotnet/standard/garbage-collection/implementing-dispose
- .NET runtime design, `Garbage Collection`: https://github.com/dotnet/runtime/blob/main/docs/design/coreclr/botr/garbage-collection.md
- YouTube, Maoni Stephens, `The Journey of a .NET Object — from allocation to collection`: https://www.youtube.com/watch?v=1Qmvme70w9c

Проверка видео через браузер, 2026-09-04: опубликовано 2021-10-07, 42:31, 4 980 просмотров, 214 likes, 13 комментариев, канал Maoni Stephens — 822 подписчика. Автор указана Microsoft как `.NET GC Architect`, .NET Runtime Team. Главы покрывают allocation, segments, DRAM, virtual memory/paging, allocation context, caches, compaction и GC trace. Комментарии оценивают ролик как глубокий reference; технических errata в просмотренных комментариях нет. Caveat: implementation-shaped детали не заменяют current Microsoft Learn и не должны заучиваться как вечные гарантии runtime.

### SQL и базы данных

- PostgreSQL documentation: https://www.postgresql.org/docs/current/
- Metanit, `Реляционные базы данных и язык SQL`: https://metanit.com/sql/
- Metanit, `Проектирование реляционных баз данных`: https://metanit.com/sql/tutorial/
- LeetCode, `SQL 50`: https://leetcode.com/studyplan/top-sql-50/

Metanit-раздел по проектированию БД используется только как вводный материал и перепроверяется по PostgreSQL docs. LeetCode SQL 50 покрывает query syntax и basic/intermediate relational reasoning, но не доказывает владение PostgreSQL query plans, indexes, isolation, locks, migrations или EF Core semantics.

## Правила практики по кластерам

- Async/concurrency: custom C# snippets, tests, code review и bounded pipeline; обычные algorithm tasks почти не дают нужного evidence.
- CLR/memory: custom allocation/lifetime snippets и диагностические сценарии.
- ASP.NET Core: custom endpoint/middleware/DI review и integration tests.
- SQL: LeetCode SQL 50 для запросов плюс custom PostgreSQL tasks для индексов, планов и concurrency.
- Messaging/distributed systems: scenario analysis, state-machine design, failure injection и contract review.
- System design/operations: timed requirements framing, estimates, architecture defense и incident evidence.

## Книги

В дневные маршруты могут включаться точные главы из `C# in Depth`, `CLR via C#`, `Concurrency in C# Cookbook`, `Designing Data-Intensive Applications`, `Building Microservices`, `Microservices Patterns` и других релевантных книг. Перед назначением проверяется, соответствует ли глава текущей версии платформы; устаревшие API не используются как ground truth, даже если фундаментальная модель остаётся полезной.
