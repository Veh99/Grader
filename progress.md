# Прогресс подготовки

Обновлено: 2026-08-18

## Текущий статус

- Фаза: baseline diagnostic.
- Целевой уровень: уверенный Middle+; Senior-сигналы как differentiator.
- Readiness: не оценена — пока отсутствует независимое evidence.
- Assistance policy: closed-book, без поиска и AI; ответы `independent`, если подсказки не запрошены.

## Домены

| Домен | Статус | Последний score | Assistance | Слабый сигнал | Retest |
|---|---|---:|---|---|---|
| C# / async / runtime | learning | 2.0/4 async delayed retest | independent | WhenAll ordering/task fan-out and semaphore failure handling not retained | 2026-08-22–23 |
| ASP.NET Core / API | learning | 2.0/4 | independent | Fire-and-forget, scoped lifetime, backpressure, 202 semantics | 2026-08-20–21 |
| SQL / EF Core | provisional | 2.5/4 guided application | assisted | Pessimistic flow понят; альтернативы и trade-offs ещё не проверены | 2026-08-20–21 |
| Testing / code quality | provisional | 2.5/4 focused retrieval | prompted-after-coaching | Граница real DB понятна; concurrent test design ещё не применён | after teaching |
| Debugging / observability | provisional | 3.0/4 guided incident | mixed | Transaction/pool incident понят; independent evidence triage ещё слабое | later retest |
| Distributed systems | provisional | 3.0/4 | independent | At-least-once/inbox/outbox понятны; replica race/external effect gaps | delayed retest |
| System design | provisional | 2.5/4 guided application | prompted | Durable async flow strong; worker ownership/exactly-once/failure state gaps | delayed novel design |
| Delivery / ownership | unassessed | — | — | — | — |

## Попытки

Оценка каждого упражнения: correctness, depth, trade-offs, production judgment и communication по шкале 0–4. Уверенность кандидата фиксируется отдельно.

### 2026-08-18 — baseline #1: LINQ + Task.WhenAll

- Assistance: `independent`.
- Confidence: 30%.
- Correctness: 1.0/4 — верно замечен общий failure метода, но неверно описаны момент старта и cancellation; отсутствует семантика нескольких faults/partial results.
- Depth: 1.0/4 — нет причинной модели deferred enumeration и выполнения async до первого incomplete await.
- Trade-offs: 2.0/4 — предложен batch API и сохранение `WhenAll`, но не разобраны batch limits, bounded fan-out и result contract.
- Production judgment: 1.5/4 — замечена пропускная способность downstream и logging, но `foreach + try/catch` не решает throughput либо unbounded concurrency; нет timeout/retry/backpressure.
- Communication: 2.0/4 — ответ структурирован и неопределённость заявлена честно, но важные assumptions/семантика результата не определены.
- Overall: 1.5/4, ниже Middle+ gate; тип пробела — factual model + production concurrency design.
- State: `learning`; delayed retest через 2–3 дня.
- Passed evidence: распознана польза batch endpoint и влияние 10 000 запросов на downstream.
- Required evidence: самостоятельно объяснить eager fan-out при enumeration, fault/cancel matrix и реализовать bounded concurrency с явным partial/fail-fast contract.

### 2026-08-18 — baseline #2: ASP.NET Core fire-and-forget

- Assistance: `independent`.
- Confidence: 60%.
- Correctness: 2.0/4 — верно найдены потеря при рестарте/недоступности email, необходимость durable work и лишний `Task.Run`; пропущен disposed request scope, неверно оценены middleware, high-load и семантика `202 Accepted`.
- Depth: 1.5/4 — outbox назван, но не раскрыты атомарность, claim/ack, retries, crash windows и невозможность exactly-once email без поддержки провайдера.
- Trade-offs: 2.0/4 — предложены outbox, broker и async; не разделены synchronous completion, durable acceptance и eventual delivery.
- Production judgment: 2.0/4 — учтены restart и logging; отсутствуют backpressure, idempotency/deduplication, DLQ/monitoring и bounded workers.
- Communication: 2.5/4 — ход мысли понятен и практичен, но несколько утверждений противоречат runtime/pipeline semantics.
- Overall: 2.0/4 (`working`), ниже Middle+ gate; прогресс относительно baseline #1.
- State: `learning`; delayed retest через 2–3 дня.
- Required evidence: спроектировать durable job/outbox с атомарной записью, bounded consumer, at-least-once/idempotency contract и наблюдаемыми статусами.

### 2026-08-18 — baseline #3: PostgreSQL isolation prerequisite

- Assistance: `independent`.
- Confidence: 10%.
- Correctness/depth: 0/4 — кандидат сообщил, что не знает `READ COMMITTED`; prerequisite для concurrency scenario отсутствует.
- Communication: положительный сигнал — неопределённость обозначена прямо, без выдуманного ответа.
- Exercise verdict: не оценивать сложный design как самостоятельное решение; перейти в mastery loop с основ транзакций и изоляции.
- Risk: critical must-have gap для целевого рынка.
- State: `learning`; первая проверка понимания в текущем цикле, delayed retest через 2–3 дня.

### 2026-08-18 — mastery #3.1: lost update retrieval

- Assistance: `prompted-after-coaching`; confidence не указан.
- Correctness: 3.0/4 — верно получено итоговое значение 15 вместо 20 и названа причина: обе транзакции вычислили результат из одного старого значения.
- Depth: 2.5/4 — кандидат предположил необходимость ожидания commit; требуется уточнение, что второй `UPDATE` может ждать row lock, но затем всё равно записать stale literal 15.
- Trade-offs/production judgment: не оценивались в этом узком retrieval.
- Topic state: `provisional`, не readiness evidence; нужен delayed independent retest и практическое применение.

### 2026-08-18 — mastery #3.2: atomic relative update

- Assistance: `prompted-after-coaching`; confidence не указан.
- Correctness: 1.5/4 — допущен вариант итогового значения 15 при двух успешных commit; при обновлении одной строки `SET value = value + 5` итог детерминированно равен 20.
- Depth: 1.5/4 — row lock и повторная проверка актуальной версии строки после ожидания пока не входят в причинную модель.
- Topic state: `learning`; предыдущий provisional сигнал не подтверждён новым wording.

### 2026-08-18 — mastery #3.3: stale literal vs relative update

- Assistance: `prompted-after-coaching`; confidence повторно не указан.
- Correctness: 2.5/4 — верно разделены предварительное незаблокированное чтение и блокировка изменения; распознано, что обе транзакции прочитали одно значение.
- Depth: 2.0/4 — требуется точнее формулировать, что `value + 5` вычисляется сервером БД над доступной после ожидания актуальной версией строки.
- Topic state: `provisional`; улучшение в пределах текущей обучающей сессии, не readiness evidence.

### 2026-08-18 — mastery #3.4: SELECT FOR UPDATE sequence

- Assistance: `prompted-after-coaching`; confidence 99%.
- Correctness: 2.5/4 — верно описаны ожидание второй транзакции, последующее чтение 15 и итог 20; ошибочно указано, что первый `SELECT FOR UPDATE` возвращает 15 вместо текущего 10.
- Depth: 2.5/4 — locking sequence понят, но чтение и последующее вычисление/UPDATE смешаны.
- Communication: 3.0/4 — ответ краткий и последовательный.
- Calibration signal: confidence 99% завышен относительно точности; на интервью перед высокой уверенностью полезно буквально пройти statement-by-statement.
- Topic state: `provisional`; перейти к application exercise на inventory reservation.

### 2026-08-18 — mastery #3.5: pessimistic inventory reservation

- Assistance: после постановки кандидат сообщил, что не знает, как реализовать решение.
- Application correctness: 0/4 — самостоятельного решения нет.
- Communication: положительный сигнал — отсутствие знания обозначено прямо.
- Topic state: `learning`; требуется guided implementation, затем новый самостоятельный application task и delayed retest.

### 2026-08-18 — mastery #3.6: simulate competing reservations

- Assistance: `assisted` — симуляция выполнялась по предоставленной реализации; confidence не указан.
- Correctness: 2.5/4 — верно определено, что B не зарезервирует уже занятую единицу.
- Depth: 2.0/4 — ожидание ошибочно приписано `READ COMMITTED`, а повторный reservation check — защите остатка. Фактически ожидание создаёт `FOR UPDATE`; после него B видит `Available = 0`, а повторный `AnyAsync` при разных order IDs остаётся false.
- Topic state: `provisional`; требуется различать isolation level, row lock, stock invariant и idempotency invariant.

### 2026-08-18 — mastery #3.7: duplicate-command idempotency

- Assistance: `assisted`; confidence не указан.
- Correctness: 3.0/4 focused — верно определено, что второй `AnyAsync` остановит повторное выполнение той же операции.
- Depth/communication: 2.0/4 — не проговорены commit A, ожидание B, новая statement snapshot при READ COMMITTED, отсутствие второго decrement и роль unique constraint как последней защиты.
- Topic state: `provisional`; pessimistic happy/concurrency path понят при наличии готовой реализации.

### 2026-08-20 — SQL learning route correction

- Кандидат сообщил: коммерчески работал с EF Core, системной теории SQL нет.
- Decision: остановить adversarial SQL assessment и перейти к guided bridge `EF Core → generated SQL → PostgreSQL execution/concurrency`.
- Existing 0/4 application evidence сохраняется как baseline, но не трактуется как неспособность после обучения.
- Next gate: самостоятельно объяснить выполнение LINQ-запроса, диагностировать N+1/лишнюю materialization и применить индекс; после этого вернуться к transactions/concurrency.

### 2026-08-20 — EF→SQL lesson #1: deferred execution

- Mode: guided learning; focused retrieval after explanation.
- Correctness: 3.0/4 — верно указано, что обращение к БД начинается на `ToListAsync`, а `Where`/`OrderBy`/`Select` формируют expression tree.
- Depth: 2.5/4 — базовая причинная связь сформулирована; ещё не проверены provider translation, client evaluation и повторное enumeration.
- Confidence: не указан.
- Topic state: `provisional`; перейти к server-side/client-side boundary.

### 2026-08-20 — EF→SQL lesson #1.2: premature materialization

- Mode: guided learning; confidence не указан.
- Correctness: 3.5/4 — верно определены загрузка всех полных `Order`, выполнение фильтрации/сортировки/`Take` на backend и предпочтительность server-side запроса.
- Depth: 3.0/4 — назван memory overload/OOM; дополнительно требуются DB scan, network, connection duration, GC и change-tracking costs.
- Production judgment: 3.0/4 — распознан опасный query shape на большой таблице.
- Topic state: `provisional`; focused EF evidence сильное, но дано сразу после обучения.

### 2026-08-20 — EF→SQL lesson #1.3: entity vs projection

- Mode: guided learning; confidence не указан.
- Correctness: 2.5/4 — верно описаны `SELECT` всех mapped columns для entity и только нужных columns для DTO projection, а также влияние на память.
- Depth: 2.0/4 — не дан ответ о change tracker: entity query tracking по умолчанию, scalar DTO projection не отслеживается.
- Production judgment: 2.0/4 — не выбран projection для явно указанного read-only API.
- Communication signal: требование `read-only` было в вопросе, но названо отсутствующим контекстом; требуется внимательнее фиксировать constraints.
- Topic state: `learning/provisional`; проверить tracking behavior отдельно.

### 2026-08-20 — EF→SQL lesson #1.4: AsNoTracking update

- Mode: focused retrieval; confidence 50%.
- Correctness: 1.5/4 — ответ неверный: изменение untracked entity не попадает в `SaveChanges`; при этом кандидат верно заметил `AsNoTracking` как сомнительный фактор.
- Depth: 1.5/4 — отсутствует модель `DbContext.ChangeTracker` → entity state/property changes → generated DML.
- Calibration: 50% адекватно отражает сомнение.
- Topic state: `learning`; требуется различать query/read model и command/update flow.

### 2026-08-20 — EF→SQL lesson #1.5: persist detached changes

- Mode: immediate retrieval; confidence не указан.
- Correctness: 2.0/4 — правильно предложено убрать `AsNoTracking`; `Attach(order)` без маркировки property/state недостаточен, если изменение сделано до attach.
- Depth: 2.0/4 — требуется закрепить entity states: tracked query → `Unchanged` → detected `Modified`; attach detached object → по умолчанию `Unchanged`.
- Topic state: `learning/provisional`.

### 2026-08-20 — EF→SQL lesson #1.6: N+1

- Mode: focused retrieval; confidence не указан.
- Correctness: 3.0/4 — верно посчитан 101 SQL-запрос и распознана избыточная нагрузка; предложено перенести получение count в projection первого запроса.
- Depth: 2.5/4 — требуется явно учитывать network round trips/latency и отличать aggregate projection от загрузки коллекции через `Include`.
- Production judgment: 3.0/4 — N+1 распознан как scalability defect.
- Topic state: `provisional`; перейти к aggregate projection и индексу FK.

### 2026-08-20 — SQL learning checkpoint: indexes

- Кандидат сообщил, что не силён в индексах, и попросил пропустить оценочный вопрос.
- Assessment: не оценивалось; тема отмечена как обязательная к изучению.
- Scope: B-tree, index-supported filter/join/order, composite index ordering, selectivity, cost for writes/storage, `EXPLAIN` basics.
- Decision: приостановить SQL mastery loop и продолжить baseline по другим доменам; вернуться после теоретического блока.

### 2026-08-20 — baseline #4: .NET GC

- Assistance: `independent`; confidence не указан.
- Correctness: 2.5/4 — верно названы Gen 0→2, проверка ссылок и удержание объекта singleton; не раскрыты promotion conditions, GC roots/reachability graph и LOH.
- Depth: 1.5/4 — модель пока на уровне общих понятий, без causal mechanics и failure modes.
- Trade-offs: 1.5/4 — `GC.Collect` назван излишним, но не объяснены pauses, full collections, promotion и нарушение adaptive heuristics.
- Production judgment: 2.0/4 — распознано удержание памяти долгоживущей ссылкой, но нет bounded-cache/diagnostics модели.
- Communication: 2.5/4 — неопределённость обозначена честно, ответы краткие и по пунктам.
- Overall: 2.0/4 (`working`), ниже Middle+ gate.
- Topic state: `learning`; после коррекции проверить LOH + unbounded singleton retention practically.

### 2026-08-20 — mastery #4.1: singleton cache retention

- Assistance: immediate application after GC correction; confidence не указан.
- Correctness: 3.0/4 — правильно описан reachability path через singleton, неограниченный рост и eventual OOM; 200 KB arrays названы Gen 2 вместо более точного LOH (LOH собирается вместе с Gen 2).
- Depth: 2.5/4 — требуется разделять managed heap size, process working set, GC frequency/CPU и container OOM kill.
- Trade-offs: 3.0/4 — предложены eviction/limit, compact representation и external persistence.
- Production judgment: 3.0/4 — bounded cache распознан; для больших blobs предпочтительно object storage/DB по требованиям, а cache должен иметь size budget, TTL/admission и hit-rate justification.
- Diagnostics: 1.5/4 — IDE/Task Manager недостаточны; нужны runtime/process/cache metrics и heap-specific tools.
- Overall: 3.0/4 in-session practical response; topic remains `provisional`, поскольку задание дано сразу после обучения.
- Required delayed evidence: новый retention/allocation scenario без подсказки через 2–3 дня.

### 2026-08-20 — delayed retest #1: async bounded concurrency

- Assistance: `independent`; confidence не указан.
- Correctness: 2.0/4 — верно определён лимит 20 и отсутствие обычного partial result; неверно описаны deferred enumeration/task creation, `Task.WhenAll` ordering и memory behavior.
- Depth: 1.5/4 — не найден permit leak из-за отсутствия `finally`; не разобраны fault/cancel precedence и возможность зависания waiting tasks после утечки permits.
- Trade-offs: 2.5/4 — самостоятельно предложен `Channel`, но ошибочно считается, что semaphore обрабатывает фиксированные batch по 20; следующий waiter проходит сразу после любого `Release`.
- Production judgment: 2.0/4 — bounded active I/O распознано, но 10 000 созданных task/state-machine/waiter объектов ошибочно считаются решённой memory problem.
- Communication: 2.5/4 — ответ структурирован и незнание API обозначено честно.
- Overall: 2.0/4, `independent`; delayed retention **не пройдена**.
- Topic state: `learning`, не `retention-passed`; повторить execution semantics + failure-safe semaphore + bounded producer/consumer и провести новый retest 2026-08-22–23.

### 2026-08-20 — baseline #5: testing boundaries

- Assistance: `independent`; confidence не указан.
- Correctness: 1.5/4 — интуитивно выбран integration test и верно определено, что оба запроса не должны создать двух пользователей.
- Depth: 0.5/4 — кандидат не знает различия unit/integration и EF Core InMemory provider.
- Production judgment: 1.5/4 — бизнес-инвариант распознан, но test environment/assertions/error contract не определены.
- Overall prerequisite: 1.0/4 (`recognition/learning`); сложное упражнение остановлено, перейти к guided testing bridge.
- Required evidence: объяснить test boundary, написать PostgreSQL integration test конкурентной регистрации и доказать exactly-one-row invariant.

### 2026-08-20 — testing bridge #5.1: InMemory limitation

- Assistance: immediate retrieval after explanation; confidence не указан.
- Correctness: 3.0/4 — верно объяснено, что симуляция не воспроизводит возможности/семантику реальной СУБД и может дать false positive.
- Depth: 2.5/4 — требуется конкретизировать constraints, transactions, locking/provider translation и возможность тихого нарушения инварианта, а не только падения.
- Topic state: `provisional`; перейти к separate scopes/DbContexts и deterministic concurrency test.

### 2026-08-20 — testing bridge #5.2: separate DbContexts

- Assistance: immediate retrieval; confidence не указан.
- Correctness: 2.0/4 — отдельные scopes связаны с независимыми вызовами/replicas, но это не основная и не полная причина.
- Missing model: `DbContext` не thread-safe; scoped lifetime создаёт отдельный unit of work/change tracker/transaction state на каждый request даже в одной replica.
- Topic state: `learning/provisional`.

### 2026-08-20 — testing bridge #5.3: concurrent EF operations

- Assistance: immediate retrieval after correction; confidence не указан.
- Correctness: 3.5/4 — верно названы ошибка второй незавершённой операции и необходимость отдельных contexts/scopes для истинного параллелизма.
- Trade-offs: 2.5/4 — самостоятельно не рассмотрены sequential execution, query combination и стоимость дополнительных connections.
- Topic state: `provisional`; prerequisite bridge усвоен в текущей сессии, нужен delayed application test.

### 2026-08-20 — baseline #6: DB saturation incident

- Assistance: `independent`; confidence не указан.
- Correctness: 2.5/4 — распознана связь с deployment и целесообразность rollback; предложена проверка изменённого кода.
- Depth: 1.5/4 — не определены discriminating signals для slow SQL/plan regression, N+1/query storm, pool wait и connection/transaction leak.
- Trade-offs: 2.0/4 — rollback выбран, но не рассмотрены stop rollout, feature flag, backward compatibility migrations и критерии безопасного отката.
- Production judgment: 2.0/4 — containment instinct хороший; root-cause/prevention сведены к integration tests без reproduction, load/performance test и observability regression guard.
- Communication: 2.5/4 — порядок понятен, неизвестность обозначена честно.
- Overall: 2.0/4 (`working`), ниже Middle+ production ownership gate.
- Topic state: `learning`; required evidence — hypothesis-driven triage, DB/runtime metrics, mitigation vs root cause, verification and prevention.

### 2026-08-20 — debugging bridge #6.1: idle in transaction

- Candidate evidence: термин неизвестен; по названию верно предположено зависание/удержание транзакции.
- Assessment: не снижать повторно; prerequisite gap уже отражён в baseline #6.
- Learning scope: session states, transaction lifetime, locks/snapshots, pool exhaustion, external await inside transaction, rollback/disposal and DB timeout safeguards.
- Next: guided C#/EF scenario linking open transaction to external I/O and outbox.

### 2026-08-20 — debugging bridge #6.2: external I/O inside transaction

- Assistance: immediate application after explanation; confidence не указан.
- Correctness: 3.5/4 — точно объяснены open transaction, удержание connection во время email wait и неизбежность повторного pool exhaustion при простом увеличении лимита.
- Depth: 3.0/4 — причинная цепочка корректна; дополнительно учитывать locks, old snapshots и connection-acquisition latency.
- Trade-offs: 3.0/4 — outbox применён правильно, но первоначально назван без стоимости eventual consistency/retries/duplicates/operations.
- Production judgment: 3.5/4 — предложена атомарная запись business state + outbox и commit до внешнего вызова.
- Topic state: `provisional`; сильное guided evidence, нужен independent novel incident retest.

### 2026-08-20 — baseline #7: at-least-once consumer

- Assistance: `independent`; confidence 70%.
- Correctness: 3.0/4 — верно предсказан duplicate DB effect после crash-before-ack, распознаны at-least-once, inbox и ACK after success.
- Depth: 2.5/4 — check-before-insert race не закрыт; `FOR UPDATE` не блокирует отсутствующую inbox row; после успешного ACK конкретная delivery обычно не повторяется без нового failure/duplicate publish.
- Trade-offs: 2.5/4 — предложены DB inbox и Redis, но Redis cache/distributed lock не должен заменять durable unique correctness invariant.
- Production judgment: 3.0/4 — правильно предложены same-DB inbox и outbox для external work; не раскрыта невозможность atomic transaction с HTTP API и необходимость provider idempotency/reconciliation.
- Communication: 3.0/4 — ответ структурирован, confidence 70% разумно калиброван.
- Overall: 3.0/4, independent focused evidence; потенциальный Middle+ сигнал, но пока `provisional` без applied implementation/delayed retest.

### 2026-08-20 — distributed bridge #7.1: concurrent inbox insert

- Assistance: immediate retrieval after explanation; confidence 90%.
- Correctness: 3.5/4 — верно описаны unique conflict, winner business effect и loser `commit/ack/return` без дубля.
- Depth: 3.0/4 — дополнительно учитывать ожидание uncommitted winner и сценарий, где winner rolls back, после чего waiter может успешно вставить inbox row.
- Communication: 3.5/4 — ответ короткий, точный и по шагам.
- Calibration: confidence 90% соответствует точности.
- Topic state: `provisional`; in-session understanding strong, delayed/applied evidence still required.

### 2026-08-21 — baseline #8: system-design requirements framing

- Assistance: `independent`; confidence не указан.
- Correctness: 1.0/4 — кандидат не сформулировал functional/business/NFR clarification questions и сразу перешёл к DB/broker/object-storage choices.
- Depth: 1.0/4 — отсутствует связь requirements → architecture decisions.
- Production judgment: 1.5/4 — инфраструктурные категории распознаны, но преждевременный technology-first подход создаёт риск неверной consistency/reliability/cost model.
- Communication: 2.0/4 — ограничение собственной модели обозначено прямо.
- Overall: 1.0/4 framing prerequisite; architecture proposal не оценивался.
- Topic state: `learning`; перейти к guided requirement-first loop: journey → invariants → scale/SLO/security/cost → boundaries → technology.

### 2026-08-21 — system-design bridge #8.1: timeout vs idempotency

- Assistance: guided follow-up; confidence не указан.
- Correctness: 2.0/4 — верно выбран результат «не создавать второй отчёт», но client HTTP retry смешан с internal job retry; вариант server error не определяет, была ли операция принята.
- Depth: 1.5/4 — отсутствуют `Idempotency-Key`, durable acceptance, same-job response и status resource.
- Trade-offs: 2.0/4 — экономия ресурсов распознана; не разделены transport retry, business retry и новая логическая операция.
- Production judgment: 2.0/4 — duplicate work предотвращается концептуально, но «игнорировать повторный запрос» оставляет клиента без детерминированного ответа.
- Topic state: `learning`; закрепить idempotent POST contract и durable job identity.

### 2026-08-21 — system-design terminology bridge

- Candidate gap: термины `job` и `payload` неизвестны; повторное упражнение остановлено до определения терминов.
- Assessment: дополнительный score не выставлять — это vocabulary prerequisite, а не новое evidence архитектурной ошибки.
- Definitions: job = durable record of asynchronous work; payload = input parameters/body describing requested work.
- Next: повторить idempotency scenario на конкретных параметрах отчёта без англоязычной абстракции.

### 2026-08-21 — system-design bridge #8.2: request identity

- Assistance: immediate retrieval after concrete explanation; confidence не указан.
- Correctness: 3.0/4 focused — верно распознана недопустимость молчаливого сопоставления одного key с разными report parameters.
- Depth: 2.5/4 — требуется точнее разделять existing request/result и new conflicting payload; production mechanism — stored normalized request hash + unique owner/key.
- Topic state: `provisional`; idempotent request identity понятна после обучения.

### 2026-08-21 — system-design bridge #8.3: report data cutoff

- Assistance: guided requirement exercise; confidence не указан.
- Correctness: 3.0/4 — самостоятельно выбран request-time snapshot и необходимость явно показывать актуальность; распознан вариант данных на момент генерации.
- Depth: 2.5/4 — второй вариант сформулирован как «что удалось получить», что допускает internally inconsistent reads; нужна одна явно определённая cutoff/snapshot time для всего отчёта.
- Production judgment: 3.0/4 — недопустимость скрытого несоответствия данных распознана.
- Topic state: `provisional`; framing улучшается после scaffolding.

### 2026-08-21 — system-design bridge #8.4: file security requirements

- Assistance: guided requirement exercise; confidence не указан.
- Correctness: 3.0/4 — самостоятельно подняты authorization, состав/актуальность данных и legal retention/deletion policy.
- Depth: 2.5/4 — автоматическое обновление относится скорее к product semantics; не названы encryption/key ownership, signed-link lifetime, audit, tenant isolation, residency and backup deletion.
- Production judgment: 3.0/4 — связь сроков хранения с законодательством распознана; требуется понимать, что soft delete не выполняет physical erasure requirement.
- Topic state: `provisional`; достаточно framing scaffolding для первой architecture application.

### 2026-08-21 — system-design application #8.5: report generation

- Assistance: requirements were scaffolded; architecture proposal produced by candidate; confidence not provided.
- Correctness: 3.0/4 — durable acceptance/outbox, status DB, broker, object storage, authorized download and async email flow are appropriate.
- Depth: 2.5/4 — gateway incorrectly owns durable business workflow; repeat request described only for unprocessed job; status state machine/data ownership not explicit.
- Trade-offs: 2.5/4 — async boundary justified; operational cost, queue backpressure, quotas/capacity and storage lifecycle not developed.
- Production judgment: 2.5/4 — signed URL/auth and retries/DLQ recognized; workers concurrency/lease model unclear, exactly-once email incorrectly promised, long-running generation cannot be rolled back as one DB transaction.
- Communication: 3.0/4 — flow is structured and component purposes are mostly defended.
- Overall: 2.5/4 guided application — strong Middle signal, approaching Middle+ in parts, below Senior system-design gate.
- Required evidence: novel independent design with explicit state machine, competing consumers/idempotency, bounded retry/backpressure, security/observability and recovery.

### 2026-08-21 — system-design follow-up #8.6: worker claim

- Assistance: focused follow-up after architecture correction; confidence not provided.
- Correctness: 2.5/4 — short transaction, row lock and status guard are valid claim ingredients.
- Depth: 1.5/4 — crash-after-claim scenario unanswered; no lease/heartbeat/recovery scanner.
- Production judgment: 2.0/4 — must not hold DB lock through long generation; losing internal worker should no-op/ack rather than return HTTP `409`.
- Topic state: `learning/provisional`; teach atomic claim + expiring ownership.

### 2026-08-21 — system-design follow-up #8.7: fencing token

- Assistance: immediate retrieval after explanation; confidence not provided.
- Correctness: 2.0/4 — lease expiration and reassignment to B understood; `lease_version` incorrectly treated as a status rather than monotonic ownership token.
- Depth: 1.5/4 — stale-owner completion behavior not identified.
- Correct behavior: completion from A with version 5 affects zero rows after B claims version 6; A must stop, discard/clean only its temporary artifact, emit diagnostic signal and never publish completion/email.
- Topic state: `learning`; fencing and external-side-effect idempotency require later retest.

### 2026-08-21 — sprint 1/session 1: BookingService query review

- Mode: coaching exercise on candidate repository; not a strict mock; confidence not requested.
- Correctness: 2.5/4 — correctly identified one DB round trip, deferred `Include` composition, large result and missing `CancellationToken`.
- Depth: 2.0/4 — tracking answer incomplete (root and all materialized related entities); suspected `Include` before `Where` as issue although provider composes a single query.
- Production judgment: 2.0/4 — 100k-row heavy query recognized, but over-fetching, tracking overhead, pagination/stable ordering and server-side DTO projection not proposed.
- Topic state: `learning`; next guided step — projection + bounded page + cancellation, then retrieval on generated query shape.

### 2026-08-21 — sprint 1/session 1.1: projection tracking

- Mode: immediate retrieval after guided rewrite.
- Correctness: 3.0/4 after self-correction — navigation access inside projection correctly linked to generated joins/subqueries; maximum result corrected from 1 to 100.
- Depth: 2.5/4 — no-tracking result understood, but initial justification relied only on `AsNoTracking`; key mechanism is that pure scalar DTO projection does not materialize entity instances for the change tracker.
- Communication: positive self-correction without prompting to final number.
- Topic state: `provisional`; compare pure DTO projection with projection that contains an entity.

### 2026-08-21 — sprint 1/session 1.2: nested entity projection

- Mode: focused retrieval; confidence not provided.
- Correctness: 1.0/4 — answers reversed. Pure `BookingResponse` scalar projection does not materialize/track `Booking`; anonymous projection containing `Entity = booking` materializes and tracks the mapped entity by default.
- Depth: 1.5/4 — mapped entity type confused with arbitrary DTO type; outer projection shape incorrectly assumed to determine tracking.
- Topic state: `learning`; reinforce materialization vs tracking as separate dimensions.

### 2026-08-21 — sprint 1/session 1.3: no-tracking entity vs DTO

- Mode: focused retrieval; confidence not provided.
- Correctness: 3.0/4 — correctly distinguished all mapped columns/full entity from two-column DTO projection; incorrectly claimed equal memory usage.
- Depth: 2.5/4 — tracking overhead is now separated from materialization conceptually, but network/materialization/allocation costs need reinforcement.
- Session 1 checkpoint: query execution/N+1/projection/pagination/cancellation mostly understood with guidance; tracking remains fragile.
- Topic state: `provisional`; schedule novel delayed retrieval in 2–3 days and begin indexes lesson.

### 2026-08-21 — sprint 1/session 2.1: composite indexes

- Mode: guided learning with immediate retrieval; confidence not provided.
- Correctness: 3.0/4 after self-correction — selected `(UserId, StartTime, Id)` for equality filter plus ordered range and `(StartTime, Id)` for the query without `UserId`.
- Depth: 2.0/4 — leftmost-prefix behavior was initially unknown; separate indexes versus one composite ordered access path required explanation.
- Production judgment: 2.5/4 — recognized that indexes must have measurable benefit and mentioned `EXPLAIN (ANALYZE, BUFFERS)`, but concrete read/write/storage costs and plan interpretation are not yet known.
- Topic state: `learning`; next step — index costs and basic PostgreSQL execution-plan reading, followed by delayed independent retrieval.

### 2026-08-24 — sprint 1/session 2.2: selectivity and plan reading

- Mode: delayed focused retrieval after a three-day gap; confidence not provided.
- Correctness: 3.5/4 — correctly chose index access for a predicate returning about 0.01% of the table and contrasted it with a sequential scan.
- Depth: 3.0/4 — correctly connected selectivity to the small number of heap lookups; wording was slightly absolute because heap accesses still occur, but there are few enough to be worthwhile.
- Prior plan-reading task: identified excessive sequential filtering and proposed `(UserId, StartTime, Id)`; separate `Sort` cost required a prompt.
- Topic state: `provisional`; basic concepts retained, but practical migration plus before/after plan measurement is still required for the session pass.

### 2026-08-24 — sprint 1/session 2.3: B-tree walkthrough and covering-index judgment

- Mode: guided explanation followed by immediate application; confidence not provided.
- Correctness: 3.5/4 — accurately traced root/internal/leaf traversal, recognized that matching index order removes a separate sort, and made a sound decision not to cover frequently changing `Status` by default for a 100-row result.
- Depth: 3.0/4 — lower-bound seek and the distinction between index payload versus heap visibility checks required correction; measurement answer remained generic rather than naming plan nodes, buffers, filtered rows and sort/heap-fetch evidence.
- Production judgment: 3.5/4 — explicitly balanced bounded heap lookups against write amplification and non-guaranteed index-only scans.
- Topic state: `provisional`; independent practical evidence is still missing: migration plus representative `EXPLAIN (ANALYZE, BUFFERS)` before/after.

### 2026-08-24 — sprint 1/session 3.1: atomic updates and idempotency constraints

- Mode: guided learning with scenario retrieval; confidence not provided.
- Atomic conditional update: 3.5/4 after correction — chose one conditional `UPDATE` for a single counter invariant and reserved `SELECT FOR UPDATE` for multi-step state-dependent work.
- READ COMMITTED detail: 2.5/4 — understood waiting and predicate recheck, but incorrectly said the losing `UPDATE ... RETURNING` would return the unchanged value instead of zero rows.
- Missing-row idempotency race: 2.5/4 — correctly diagnosed two `AnyAsync(false)` results, but proposed `SELECT FOR UPDATE`/`WHERE NOT EXISTS` without recognizing that no absent row is locked and a DB unique constraint is the final arbiter.
- Payload mismatch: 1.0/4 — proposed executing both requests with the same idempotency key; correct contract is to bind the key to a request fingerprint and reject a different payload without executing it.
- Topic state: `learning`; reinforce absent-row races, unique constraints and key-plus-payload semantics through a new scenario.

### 2026-08-24 — sprint 1/session 3.2: idempotency storage boundary

- Mode: guided design clarification and immediate retrieval; confidence not provided.
- Correctness: 3.5/4 — proposed storing `IdempotencyKey` and request hash on `Order`, returning `409` for a mismatched payload, and using conflict handling to prevent duplicate rows.
- Depth: 3.0/4 — must state that uniqueness is scoped by actor/operation plus key, while request hash is a compared payload column rather than part of the unique key; `DO NOTHING` must be followed by loading and comparing the winner.
- Production judgment: 4.0/4 — challenged an unnecessary standalone idempotency table and correctly recognized that `Order` can own the idempotency record for a one-request/one-order workflow; accepted atomic Order/result/outbox commit when separate records exist.
- Topic state: `provisional`; delayed novel retest required for READ COMMITTED, missing-row races and idempotency mismatch semantics.

### 2026-08-24 — sprint 1/session 4.1: async start and semaphore retest

- Mode: delayed novel retrieval; confidence not provided.
- Correctness: 1.5/4 — correctly stated that `Task.WhenAll<TResult>` returns results in input-task order, but said `ToArray()` creates ten tasks without starting them and that `WhenAll` starts execution in batches.
- Depth: 1.5/4 — missed deferred `Select` enumeration invoking all 10,000 async methods, synchronous execution to the first incomplete await, and continuous permit replacement rather than batches.
- Topic state: `learning`; retrain async invocation versus task observation and bounded active I/O versus unbounded waiting tasks before introducing Channels.

### 2026-08-24 — sprint 1/session 4.2: async and boundedness guided retrieval

- Mode: immediate retrieval after correction; confidence not provided.
- Async invocation: 4.0/4 immediate — correctly stated that `ToArray()` enumeration invokes the async methods even without `WhenAll`.
- Boundedness: 3.0/4 — distinguished bounded active `LoadFromApiAsync` work from the potentially million-task outer method and independently identified missing timeout as a second liveness risk; waiting tasks/state machines and result storage required elaboration.
- Channel capacity: 1.0/4 initially — treated shared capacity 100 with 20 consumers as roughly 2,000 in-flight items; after explanation correctly calculated 50 queued + 8 active = 58 total in a new immediate example.
- `Task.WhenAll` failure: 3.0/4 — correctly said it waits for all, `finally` releases and partial results are not returned; incorrectly said it cancels remaining tasks automatically.
- Cancellation: 3.5/4 — correctly separated waiting-task cancellation from active operations and stated that real cancellation depends on lower layers observing the token; final `Faulted` versus `Canceled` precedence required clarification.
- Semaphore permit safety: prerequisite unknown — did not know why `WaitAsync` inside `try` can cause `Release` without acquisition; taught safe placement and guarded-release alternative. Do not score the introduced `CurrentCount` terminology as a candidate gap.
- Topic state: `learning`; next step is Channel writer completion on producer failure, then per-item error/order semantics and practical implementation.

### 2026-08-25 — portability pause

- Interview preparation paused at the Channel producer-completion question while the workspace is made portable between computers.
- Exact continuation point is recorded in `HANDOFF.md`.

## Baseline checkpoint — 2026-08-21

- Likely demonstrated range: Middle in foundational backend reasoning, with isolated Middle+ signals in distributed messaging; confidence medium-low because evidence is sparse and much of the stronger work was guided.
- Strongest observed signal: at-least-once/inbox/outbox reasoning and recognition of durable asynchronous workflows.
- Primary must-have gaps: SQL/indexes/transactions, async execution semantics, testing boundaries, DB incident evidence and system-design framing.
- Execution pattern: honest uncertainty is a strength; recurring risk is selecting a mechanism before defining semantics, and high confidence occasionally precedes statement-by-statement verification.
- Current verdict: `not yet ready` for reliable Middle+/Senior interviews; this is a planning checkpoint, not a final readiness gate.
- Next phase: foundational learning sprint followed by independent delayed retrieval and practical tasks.

### 2026-08-18 — repository evidence review

- Тип evidence: `open-book artifact review`; не закрывает readiness gate.
- Положительные сигналы: ASP.NET Core, EF Core/PostgreSQL, gRPC, RabbitMQ, outbox/inbox-подобная идемпотентность, background workers; в LawyerAI есть тесты конкурентных и интеграционных сценариев.
- Критичный слабый сигнал: реальные-looking secrets закоммичены в публичные конфигурации Secret Project и ValikuloDance. Требуется немедленная ротация и очистка истории.
- Слабый сигнал: в Secret Project и ValikuloDance не обнаружено тестовых проектов/файлов.
- Verification: сборки не подтверждены — NuGet restore не завершился в среде анализа.
- Полный предварительный отчёт: `sessions/2026-08-18-repository-evidence.md`.

## Открытые данные

- При наличии — получить 2–5 конкретных вакансий/команд для уточнения contextual требований.

## Interview execution evidence

- 2026-08-21: недельный бюджет 8 часов подтверждён.
- Кандидат самостоятельно сформулировал ценность narration на live coding: демонстрация reasoning снижает неопределённость интервьюера и позволяет оценить правильный ход мысли при локальной ошибке.
- State: conceptual understanding; practical evidence ещё отсутствует. Narration protocol встроен во все coding exercises.
