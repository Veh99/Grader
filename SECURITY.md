# Security review and required actions

Обновлено: 2026-08-25. Значения credentials намеренно не записаны в этот документ.

## Superproject audit

- Staged history проверен до первого commit.
- В superproject нет `.env`, `appsettings*.json`, private keys или high-confidence GitHub/AWS token patterns.
- Evidence-проекты добавлены gitlink-записями режима `160000`; их конфигурации не скопированы в историю superproject.

## Findings in public evidence repositories

По именам параметров и признаку непустого значения обнаружены реальные-looking credentials:

- `LawyerAI`: database/RabbitMQ credentials, YooKassa secret key, Checko API key, object-storage access/secret keys.
- `Secret_Project`: database/RabbitMQ credentials и SMTP passwords; также Git отслеживает `SECRET_PROJECT_WEB/.env`.
- `ValikuloDance`: Telegram bot token и email password. Database/JWT values выглядят как placeholders, но должны быть проверены владельцем.

## Required owner actions

1. Считать опубликованные credentials скомпрометированными, пока не доказано обратное.
2. Отозвать/ротировать Telegram, SMTP, YooKassa, Checko, object-storage, database и RabbitMQ credentials.
3. Перенести реальные значения в environment variables, user-secrets или внешний secret manager.
4. Оставить в Git только безопасные templates (`.env.example`, placeholder configuration).
5. При необходимости очистить upstream Git history после ротации. Очистка истории не заменяет отзыв credential.
6. Повторно проверить публичные репозитории перед их использованием на другом компьютере.

Private visibility нового superproject не является защитой для секретов, уже опубликованных в upstream history.
