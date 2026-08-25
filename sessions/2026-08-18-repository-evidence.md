# Repository evidence review

Дата: 2026-08-18

Статус: первичное статическое ознакомление. Это `open-book artifact evidence`, а не независимое доказательство интервью-навыка. Авторство отдельных решений и способность защитить их будут проверены на project deep-dive.

## Scope

- `Secret_Project`: мессенджер, 267 C#-файлов, 17 `.csproj`, gateway/services/data projects, SignalR/gRPC/RabbitMQ/PostgreSQL/MinIO; тестовые файлы не обнаружены.
- `LawyerAI`: 317 C#-файлов, 23 `.csproj`, API и worker services, gRPC/RabbitMQ/PostgreSQL/pgvector/MinIO/Ollama; обнаружено 20 тестовых C#-файлов.
- `ValikuloDance`: 90 C#-файлов, один `.csproj`, ASP.NET Core/EF Core/PostgreSQL, auth, bookings/subscriptions и hosted services; тестовые файлы не обнаружены.

Репозитории загружены shallow-клонами, поэтому история авторства и эволюция решений пока не оценивались.

## Критичный blocker — credentials в публичном Git

В tracked `appsettings.json` Secret Project и ValikuloDance присутствуют реальные-looking пароли, JWT signing material, Telegram bot token и SMTP credentials. Значения намеренно не дублируются в отчёте.

Действия:

1. Немедленно отозвать и перевыпустить все обнаруженные credentials у Telegram/email/DB и иных провайдеров.
2. Перенести секреты в environment variables, user-secrets для локальной разработки или secret manager в deployment.
3. Оставить в Git только placeholders и документированный пример конфигурации.
4. Очистить всю Git-историю (`git filter-repo`/BFG) и force-push только после координации со всеми пользователями репозитория.
5. Подключить secret scanning/pre-commit и CI gate.

Удаление значений новым коммитом не устраняет компрометацию: старые blobs остаются доступными.

## Сильные инженерные сигналы

### Secret Project

- Реализован messaging infrastructure с manual ack, retry queue, DLQ, persistent messages и cancellation propagation.
- Есть transactional outbox при регистрации и `ProcessedEvent` для идемпотентной обработки consumers.
- Сервисы разделены по gateway/auth/user/channels/file/email и используют gRPC-контракты.

### LawyerAI

- Наиболее зрелый из трёх артефактов: разделены API и workers, есть общая инфраструктура DB/messaging и contract-first gRPC.
- В outbox/recovery коде используются транзакции и PostgreSQL `FOR UPDATE SKIP LOCKED`, что показывает понимание конкурентного claim batch.
- В account/billing присутствуют транзакции и row locking для конкурентных изменений.
- Есть unit/integration-shaped тесты, включая organization membership concurrency, hybrid retrieval database, internal authentication, billing domain и prompt injection.
- Предметная декомпозиция охватывает account, billing, documents, AI/RAG, file storage, counterparty и Telegram gateway.

### ValikuloDance

- Выделены application/domain/infrastructure/API области внутри одного deployable — разумная стартовая форма модульного монолита.
- Есть JWT/refresh-token логика, фоновые процессы, EF migrations и транзакционные business flows.
- Присутствуют отдельные модели для subscriptions, bookings, schedules и Telegram delivery hardening.

## Риски и вопросы для deep-dive

### Общие

- Наличие большого числа сервисов и инфраструктурных паттернов не доказывает оправданность микросервисной декомпозиции. Нужно защитить границы, независимость данных/deployment, failure model и эксплуатационную стоимость.
- Не обнаружена полноценная observability story: требуется проверить structured logs, metrics, traces, correlation IDs, health checks и alertable failure states.
- Сборки не верифицированы: NuGet restore завис в среде анализа; это не считается build failure проекта.

### Secret Project

- Отсутствие тестов — высокий риск для messaging/idempotency/auth flows.
- Outbox processor выбирает строки без конкурентного claim/lock. При нескольких replicas вероятна повторная публикация одной записи; consumers должны выдерживать at-least-once, а publisher требует lock/lease или `SKIP LOCKED` стратегию.
- Publish-then-ack retry/DLQ flow требует publisher confirms: без подтверждения брокера возможна потеря при сбое между publish и ack.
- Обнаружены закомментированные `[Authorize]`; проверить, не оставляют ли они доступ к чувствительным операциям.
- Одновременно присутствуют legacy net8 application и новые net10 services; нужно объяснить миграционную стратегию и устранение дублирования.

### LawyerAI

- 23 проекта и несколько deployables для недавнего продукта могут быть оправданы учебной целью, но для production требуют защиты стоимости: local/dev orchestration, migrations, distributed debugging, versioning и deployment.
- Не все gRPC endpoints визуально имеют одинаковую service-to-service authorization policy; проверить threat model, особенно AI Legal и File Storage.
- `MaxReceiveMessageSize = null` / `MaxSendMessageSize = null` в File Storage снимают лимиты: нужны явные size limits, streaming/backpressure и защита от resource exhaustion.
- Проверить гарантии RabbitMQ publisher confirms, consumer idempotency, poison-message policy и shutdown semantics.
- Тестов больше, чем в других проектах, но требуется запустить suite и проверить реальные external boundaries через Testcontainers.

### ValikuloDance

- Отсутствие тестов особенно рискованно для booking capacity, пересечений расписаний, subscription usage, refresh tokens и background transitions.
- В booking flow внешняя отправка Telegram выполняется внутри DB-транзакции. Это удлиняет lock time и связывает доступность записи с внешним провайдером; предпочтительнее commit бизнес-состояния + outbox/асинхронная доставка с явной product semantics.
- Проверка вместимости через `CountAsync` перед insert уязвима к race condition без row/advisory lock, serializable isolation или DB-enforced invariant.
- CancellationToken почти не проходит через application/EF methods; HTTP disconnect/shutdown не отменяет значимую часть I/O.
- `KnownNetworks.Clear()` и `KnownProxies.Clear()` доверяют forwarded headers от любого источника. Это безопасно только за корректно изолированным trusted proxy/network; иначе возможен spoofing scheme/client IP.

## Темы для project deep-dive

1. Secret Project: гарантии at-least-once между outbox, RabbitMQ и `ProcessedEvent`; сценарий падения после publish до mark/ack.
2. LawyerAI: почему выбран набор сервисов, где границы транзакций и как деградирует система при недоступности RabbitMQ/Ollama/PostgreSQL/MinIO.
3. ValikuloDance: как обеспечить невозможность overbooking при 100 одновременных запросах на последнее место.
4. Для всех: rollout migrations, secrets, health/readiness, logs/metrics/traces, backup/recovery и test pyramid.

## Предварительное влияние на план

- Поднять security/secret management в ближайший блок, а не оставлять до конца.
- Использовать собственные outbox, consumer и booking flows как упражнения по debugging/code review.
- LawyerAI выбрать основным проектом для Senior-style deep-dive; ValikuloDance — для concurrency/data integrity; Secret Project — для messaging reliability.

