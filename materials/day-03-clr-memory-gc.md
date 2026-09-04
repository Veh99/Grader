# День 3 — CLR, CPU, stack/heap и Garbage Collector

Дата выдачи: 2026-09-04  
Theory package: 240 минут  
Практика после теории: 90–120 минут  
Режим проверки: closed-book, timed, один вопрос за раз

## Результат дня

После изучения материала кандидат должен уметь:

- провести путь метода от C# source до CIL, JIT и машинных инструкций;
- различить CPU core, hardware thread, OS thread, register, cache, RAM и virtual memory;
- объяснить stack frame и managed heap без мифа «value type всегда на stack»;
- предсказать семантику копирования value/reference types и увидеть boxing;
- объяснить allocation, GC roots, достижимость, поколения и compaction;
- объяснить LOH и цену долгоживущих/крупных объектов без магических правил оптимизации;
- различить освобождение managed memory и детерминированное освобождение ресурса;
- найти managed memory leak через сохраняющуюся цепочку достижимости;
- назвать измерения, которые нужны до оптимизации памяти.

## Маршрут на 240 минут

Проходить по порядку. Не читать все ссылки целиком: в таблице указаны нужные части и результат.

| Время | Материал | Тип | Что получить на выходе |
|---:|---|---|---|
| 30 мин | Разделы 1–2 конспекта ниже и [Managed execution process](https://learn.microsoft.com/en-us/dotnet/standard/managed-execution-process): overview, CIL, JIT, run code | original + official, required | Нарисовать путь C# → CIL/metadata → JIT → native code → CPU и отделить CLR от ОС |
| 50 мин | [YouTube: The Journey of a .NET Object — from allocation to collection](https://www.youtube.com/watch?v=1Qmvme70w9c), Maoni Stephens: 42:31 просмотра + 7:29 заметок | expert video, required | Связать allocation с virtual memory, pages, DRAM/cache, GC heap, compaction и GC trace |
| 40 мин | Разделы 3–4; [Value types](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/builtin-types/value-types), [Reference types](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/keywords/reference-types), [Boxing and unboxing](https://learn.microsoft.com/en-us/dotnet/csharp/programming-guide/types/boxing-and-unboxing) | original + official, required | Объяснить copy semantics и фактическое место хранения значения; найти boxing в коде |
| 55 мин | Разделы 5–7; [Fundamentals of garbage collection](https://learn.microsoft.com/en-us/dotnet/standard/garbage-collection/fundamentals) и [Large object heap](https://learn.microsoft.com/en-us/dotnet/standard/garbage-collection/large-object-heap) | original + official, required | Roots/reachability, allocation, поколения, mark/relocate/compact, LOH, pauses |
| 35 мин | Разделы 8–9; [Cleaning up unmanaged resources](https://learn.microsoft.com/en-us/dotnet/standard/garbage-collection/unmanaged) и [Implement a Dispose method](https://learn.microsoft.com/en-us/dotnet/standard/garbage-collection/implementing-dispose) | original + official, required | Разделить GC, finalization, `Dispose`, `using`, `SafeHandle` и managed leak |
| 15 мин | `Active notes`: три схемы и таблица lifetime ниже | retrieval preparation, required | Воспроизвести модель без копирования текста |
| 15 мин | Вопросы самопроверки в конце файла | closed-book recap, required | Найти пробелы до практики |

Итого: **240 минут**.

## Проверка обязательного видео

`The Journey of a .NET Object — from allocation to collection`:

- автор и канал: Maoni Stephens; Microsoft указывает её как `.NET GC Architect`, .NET Runtime Team;
- опубликовано: 2021-10-07;
- длительность: 42:31, язык: английский;
- на 2026-09-04: 4 980 просмотров, 214 likes, 13 комментариев, 822 подписчика канала;
- описание содержит ссылку на slides и говорит, что это отредактированный внутренний доклад;
- комментарии немногочисленны, но содержательно оценивают материал как deep internals/reference; технических errata в просмотренных комментариях нет.

Полезные главы:

- `00:00` — introduction;
- `01:11` — создание теста и путь наблюдаемого объекта;
- `03:33` — memory;
- `03:58` — allocation;
- `06:04` — segments;
- `10:10` — DRAM;
- `11:03` — virtual memory;
- `14:22` — paging;
- `21:56` — reserved memory;
- `26:22` — allocation context;
- `27:21` — CPU caches;
- `28:11` — cache latency;
- `35:02` — почему GC не собирает объект;
- `37:04` — heap;
- `37:43` — compacting;
- `39:02` — когда измерять;
- `40:29` — GC trace.

Caveat: видео специально идёт глубже обычного интервью и показывает implementation-shaped детали. Не пытаться запомнить адреса, размеры страниц и конкретные цифры latency. Контракты поколений, LOH и `Dispose` сверять по current Microsoft Learn.

## Корректирующий конспект

### 1. От C# до процессора

Исходный C# обычно не исполняется процессором напрямую:

```text
C# source
    ↓ компилятор C#
CIL + metadata в assembly
    ↓ CLR загружает assembly
JIT компилирует вызываемый метод
    ↓
native instructions для текущей архитектуры
    ↓
OS thread получает CPU time
    ↓
CPU выполняет инструкции
```

`CIL` — процессорно-независимое промежуточное представление. Metadata описывает типы, методы и их сигнатуры. CLR загружает managed assembly и предоставляет runtime services: GC, type safety, exceptions, interop и diagnostics.

JIT переводит CIL конкретного метода в native code, когда этот код требуется выполнить. Современный runtime может перекомпилировать горячий метод с более агрессивными оптимизациями; это называется tiered compilation. Для интервью важна причинная модель, а не обещание «каждый метод компилируется ровно один раз».

JIT не выполняет бизнес-логику и не назначает потоки на CPU. Он производит инструкции. Выполняет их CPU, а процессорное время runnable OS threads распределяет scheduler операционной системы.

### 2. CPU, cache, RAM и virtual memory

Упрощённая иерархия:

```text
CPU registers
    ↓
L1 cache
    ↓
L2/L3 cache
    ↓
RAM
    ↓
disk/page file при вытеснении страниц
```

Чем дальше данные от ядра, тем дороже их получение. Но нельзя заключать, что «stack всегда быстрее heap»: реальную стоимость определяют cache locality, pattern доступа, allocation, indirection, GC pressure и оптимизации JIT.

Процесс работает с virtual address space. Адрес, который видит процесс, является виртуальным; ОС отображает virtual pages на physical memory. Часть адресного пространства может быть reserved без немедленного предоставления всей физической памяти; committed pages уже обеспечены backing storage согласно правилам ОС.

`CPU core` физически выполняет инструкции. `Hardware thread` — аппаратный execution context core. `OS thread` — программная сущность scheduler ОС. Эти количества не обязаны совпадать один к одному.

Context switch позволяет CPU переключиться между OS threads, но имеет цену: scheduler work, сохранение/восстановление состояния и возможное ухудшение cache locality. Поэтому тысячи runnable CPU-bound threads не превращают восемь cores в тысячи параллельных вычислителей.

### 3. Stack frame и managed heap

Каждый thread имеет свой call stack. Вызов метода создаёт stack frame, который концептуально содержит return information, параметры, locals и временные данные. Конкретное значение JIT может держать в register, удалить или разместить иначе, поэтому исходный C# не является точной схемой памяти.

Managed heap — область, в которой CLR размещает managed objects и которой управляет GC. Ссылка на объект и сам объект — разные вещи:

```csharp
Person person = new("Ann");
```

Локальная переменная `person` содержит reference; объект `Person` находится в managed heap. Но reference также может быть полем другого heap-объекта, элементом массива или частью state machine.

Главное правило:

> Категория type определяет семантику значения, а storage location определяется контекстом его хранения и оптимизациями runtime.

Примеры, разрушающие миф «value type всегда на stack»:

```csharp
sealed class Order
{
    public decimal Total; // Value type хранится внутри heap-объекта Order.
}

var values = new int[100]; // Элементы value type находятся внутри heap-массива.
object boxed = 42;          // Копия int находится внутри нового heap-объекта.
```

Локальная reference variable часто связана со stack frame, но объект, на который она указывает, — нет. Захваченный lambda/async код может продлить lifetime локальных значений и хранить их в compiler-generated object/state machine.

### 4. Value/reference semantics и boxing

Value-type variable содержит само значение. Обычное присваивание копирует это значение:

```csharp
var a = new Point(1, 2);
var b = a;
b.X = 10; // a.X не меняется, если Point — mutable struct.
```

Reference-type variable содержит reference. Присваивание копирует reference, поэтому обе переменные указывают на один объект:

```csharp
var a = new Person("Ann");
var b = a;
b.Name = "Bob"; // Изменение видно через a.
```

Если struct содержит reference-type field, копирование struct копирует reference, а не глубоко клонирует объект. Поэтому mutable structs и ожидание deep copy создают ошибки.

Boxing происходит при преобразовании value type в `object` или реализуемый им interface:

```csharp
int value = 42;
object boxed = value; // Allocation + копирование 42 в boxed object.
int copy = (int)boxed; // Type check + копирование значения наружу.
```

Generics часто позволяют избежать boxing:

```csharp
var good = new List<int>();    // int хранится как int.
var costly = new List<object>();
costly.Add(42);                // boxing.
```

Не каждое использование value type гарантированно избавляет от allocation, а не каждое heap allocation является проблемой. Оптимизацию подтверждают profiler/counters/benchmark, а не тип поля сам по себе.

### 5. Allocation и GC roots

Allocation небольшого объекта в managed heap часто сводится к проверке места и продвижению allocation pointer. Это может быть дёшево. Цена появляется из-за инициализации, объёма памяти, cache effects и будущей работы GC.

GC не удаляет объект потому, что переменная вышла из lexical scope. Он определяет достижимость от GC roots. К типичным roots относятся:

- ссылки из stack/registers выполняемых threads, которые runtime считает живыми;
- static fields;
- GC handles;
- finalization infrastructure и runtime roots.

```text
GC root → Service → Cache → Entry → Payload
```

Пока цепочка существует, `Payload` достижим и не является garbage. Цикл сам по себе не удерживает объекты:

```text
A ↔ B, но от roots пути к A/B нет → оба могут быть собраны.
```

Это tracing GC, а не простой reference counting.

### 6. Что делает сборка

Упрощённая модель compacting collection:

1. GC определяет roots.
2. Прослеживает достижимые объекты и отмечает их живыми.
3. Считает недостижимые объекты мусором.
4. При необходимости перемещает/уплотняет живые объекты.
5. Исправляет references на перемещённые объекты.
6. Возобновляет выполнение managed threads.

Некоторые фазы требуют приостановки managed execution. Background/concurrent механизмы уменьшают часть пауз, но не означают «GC всегда работает параллельно приложению без остановок».

GC запускается по allocation pressure и внутренним эвристикам, а также может быть запрошен явно. Он не обязан собирать объект сразу после потери последней ссылки и не работает по простому фиксированному таймеру. Ручной `GC.Collect()` редко является правильным production-решением без измеренного специального сценария.

### 7. Поколения и LOH

Managed heap использует generations:

- `Gen 0` — новые короткоживущие объекты;
- `Gen 1` — промежуточный буфер между коротко- и долгоживущими;
- `Gen 2` — пережившие несколько сборок долгоживущие объекты.

Идея generational hypothesis: большинство новых объектов умирает быстро. Поэтому выгодно часто проверять молодую часть heap, не обходя всю долгоживущую память.

Выживший объект может быть promoted в старшее поколение. Promotion — не награда и не признак утечки. Проблема возникает, когда ненужные объекты остаются достижимыми или allocation rate/working set создаёт неприемлемые паузы и нагрузку.

Объекты размером от 85 000 bytes обычно размещаются в Large Object Heap. LOH логически относится к generation 2 и собирается вместе с соответствующими collections. Крупные объекты дороги по объёму, clearing, copying и fragmentation; LOH обычно не compacted на каждой сборке.

Не нужно дробить каждый массив только ради порога. Сначала измеряются allocation rate, heap size, Gen 2 collections, pause time и retained objects.

### 8. Dispose, finalizer и GC — разные контракты

GC управляет managed memory. Он не знает, когда бизнес-коду больше не нужны file handle, socket handle, native buffer или другой scarce unmanaged resource.

`IDisposable.Dispose` даёт детерминированный cleanup:

```csharp
using var stream = File.OpenRead(path);
// Работа со stream.
// Dispose гарантированно вызывается при выходе из scope.
```

`using` компилируется в форму с `try/finally`; это не указание GC немедленно удалить объект.

Finalizer — недетерминированная страховка для типа, непосредственно владеющего unmanaged resource. Он выполняется не в момент выхода из scope, добавляет стоимость lifetime и усложняет объект. Предпочтительно оборачивать native handles через `SafeHandle`, а не писать собственный finalizer без необходимости.

Если класс только владеет другими `IDisposable` managed objects, обычно достаточно реализовать `Dispose` и вызвать их `Dispose`; собственный finalizer не требуется.

### 9. Managed memory leak и диагностика

В managed приложении leak означает не обязательно потерянный raw pointer. Чаще это объекты, которые больше не нужны логически, но всё ещё достижимы:

- бесконечно растущий static cache;
- publisher дольше живёт, чем subscriber, и удерживает его event handler;
- timer/callback удерживает closure;
- background task удерживает большой object graph;
- список запросов никогда не очищается;
- DI singleton удерживает request-scoped data через ошибочную границу владения.

Диагностическая последовательность:

1. Подтвердить устойчивый рост после прогрева и collections.
2. Разделить managed heap, native memory и process working set.
3. Найти типы с растущим retained size/count.
4. Найти path to GC root.
5. Исправить ownership/lifetime, затем повторить измерение.

Фраза «память процесса растёт» ещё не доказывает managed leak: runtime может удерживать committed/reserved memory для повторного использования, а working set зависит от ОС.

## Active notes

Закрыть источники и самостоятельно воспроизвести:

1. Схему `C# → CIL → JIT → native code → OS thread → CPU`.
2. Схему `root → object graph → reachable/unreachable` с одним циклом объектов.
3. Таблицу из четырёх примеров: local struct, struct field in class, `int[]`, boxed int. Для каждого назвать semantics и вероятное storage location без абсолютных обещаний JIT.
4. Одним абзацем: почему GC не заменяет `Dispose`.
5. Пять метрик/артефактов, которые потребуются перед оптимизацией памяти.

## Вопросы самопроверки

1. Кто переводит CIL в native instructions и кто реально их выполняет?
2. Почему CLR, JIT, OS scheduler и CPU — не один механизм?
3. Что такое stack frame? Обязан ли каждый local физически находиться в stack?
4. Почему `int` может находиться в managed heap без boxing?
5. Что копируется при присваивании struct и class variable?
6. Когда возникает boxing и почему он может создавать GC pressure?
7. Что такое GC root? Соберёт ли GC недостижимый цикл объектов?
8. Почему выход переменной из scope не гарантирует немедленную сборку объекта?
9. Зачем нужны поколения и что означает promotion?
10. Что такое LOH и почему порог 85 000 bytes не является автоматическим приказом переписать код?
11. Чем `Dispose` отличается от finalizer и от освобождения managed memory?
12. Назови три способа сохранить ненужный объект достижимым.
13. Почему рост process memory недостаточен для диагноза managed leak?

## Практика после теории

Практика выдаётся отдельно после сообщения `День 3 изучен`. Она включает:

- allocation/lifetime trace по C# snippet;
- поиск boxing и скрытых allocations;
- GC-root investigation по object graph;
- review неправильного dispose/finalizer pattern;
- production-кейс: память сервиса растёт под нагрузкой;
- timed определения по stack, heap, GC root, generation, LOH и disposal.

## Optional deep dives — не входят в 240 минут

- [.NET runtime source: Garbage Collector design](https://github.com/dotnet/runtime/blob/main/docs/design/coreclr/botr/garbage-collection.md) — после базовой модели, для runtime internals.
- `CLR via C#`, 4th edition: главы 4–5 и 21. Фундаментальная модель полезна, но конкретные implementation details книги относятся к более старому runtime и проверяются по current docs.
- [Maoni Stephens on the .NET Blog](https://devblogs.microsoft.com/dotnet/author/maoni/) — version-specific GC evolution и diagnostics.

## Pass criteria

- definitions: correctness и communication не ниже `3/4` в timebox;
- trace: не использовать тип как единственное доказательство physical placement;
- GC: причинно пройти от roots к reachability и collection;
- resources: не обещать, что GC своевременно освободит unmanaged resource;
- production judgment: сначала измерение и root path, затем оптимизация.
