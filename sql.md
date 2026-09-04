# SQL practice track

Обновлено: 2026-09-04, история восстановлена из задачи Codex `Найди последний вопрос по алгоритмам`

## Назначение

Этот файл — portable source of truth для практического SQL-трека. Он отделён от `algorithms.md`, хотя оба трека велись в одной задаче Codex. Основной диалект подготовки — PostgreSQL; появившийся в обучении MySQL-синтаксис не считать целевым.

## Текущая точка

- Текущая задача: `1661. Average Time of Process per Machine`.
- Последний шаг: кандидат попросил сначала подробно объяснить `FILTER`; разобраны синтаксис, условная агрегация и отличие от глобального `WHERE`.
- Самостоятельное итоговое решение `1661` после объяснения ещё не получено.
- Следующее действие: дать кандидату заново решить `1661` без готового запроса в PostgreSQL. Допустим self join либо conditional aggregation; потребовать объяснить промежуточные наборы и `AVG/GROUP BY`.

## Восстановленный список задач

Точные числовые оценки задним числом не выставлять: чат содержит решения и помощь, но изначально не использовал единый rubric.

| # | Задача | Evidence | Состояние и ключевой сигнал |
|---:|---|---|---|
| 1 | `1757. Recyclable and Low Fat Products` | guided | Логика фильтра верна; базовый SQL-синтаксис `SELECT/FROM/WHERE`, `=`, `AND` потребовал методички |
| 2 | `584. Find Customer Referee` | independent | Корректно учтён `NULL` через `referee_id != 2 OR referee_id IS NULL`; кандидат отметил задачу как лёгкую |
| 3 | `1148. Article Views I` | guided | Условие `author_id = viewer_id` найдено; расположение `DISTINCT`, alias и `ORDER BY` потребовали коррекции |
| 4 | `1683. Invalid Tweets` | independent | Корректное решение через `LENGTH(content) > 15` |
| 5 | `1378. Replace Employee ID With The Unique Identifier` | guided | Самостоятельно определена необходимость сохранить всех employees и получить `NULL`; синтаксис `LEFT JOIN` был неизвестен |
| 6 | `1068. Product Sales Analysis I` | independent | Корректный `INNER JOIN` по `product_id`; потребовалась только правка порядка выходных столбцов |
| 7 | `1581. Customer Who Visited but Did Not Make Any Transactions` | guided | Правильно выбран `LEFT JOIN` и идея `transaction_id IS NULL`; фильтр был пропущен. Затем разобраны `COUNT`, `GROUP BY`, `NOT EXISTS`, `NOT IN` и NULL trap |
| 8 | `197. Rising Temperature` | guided | Самостоятельно сформулировано сопоставление соседних дат, но не был известен self join. Первый пример интервьюера ошибочно использовал MySQL `DATEDIFF` при целевом PostgreSQL; затем исправлено на date arithmetic и разобран `LAG` |
| 9 | `1661. Average Time of Process per Machine` | learning | Идея self join для `start/end` верна; не были известны aggregation и вычисление среднего. Готовые варианты через self join, `FILTER`, `LAG` и correlated subquery уже показаны, поэтому нужен новый independent attempt |

## Освоенные или введённые конструкции

- синтаксический порядок `SELECT → FROM → JOIN/ON → WHERE → GROUP BY → ORDER BY → LIMIT`;
- логическая модель выполнения `FROM/JOIN → WHERE → GROUP BY/aggregates → SELECT → ORDER BY → LIMIT`;
- `NULL`, `IS NULL`, трёхзначная логика;
- `DISTINCT` как часть `SELECT`, а не функция;
- `INNER JOIN`, `LEFT JOIN`, self join;
- anti-join через `LEFT JOIN ... IS NULL`, `NOT EXISTS` и `NOT IN` с caveat про `NULL`;
- `COUNT(*)`, `COUNT(column)`, `COUNT(DISTINCT column)`, `COUNT(expression)`;
- `GROUP BY`, `AVG`, conditional aggregation через `FILTER` и `CASE`;
- PostgreSQL date arithmetic;
- window function `LAG` и необходимость отдельно проверять календарный разрыв;
- подзапрос/CTE как граница для фильтрации результата window function.

## Основные пробелы

- Базовый синтаксис пока не автоматизирован: логика задачи часто формулируется правильно раньше запроса.
- JOIN semantics понимаются на уровне идеи, но выбор и запись `ON/WHERE` ещё требуют помощи.
- Aggregation, grouping и conditional aggregation находятся в состоянии learning.
- Нужно закрепить различие PostgreSQL/MySQL и не переносить `DATEDIFF` в PostgreSQL.
- Текущие задачи не доказывают владение indexes, query plans, transactions, isolation или locking; это отдельный блок дней 7–8.

## Правила продолжения

1. Перед новой SQL-конструкцией объяснить назначение, синтаксис, логический порядок и показать промежуточные relation/table states.
2. После объяснения дать новую или переформулированную задачу без готового решения.
3. Не считать ответ, собранный сразу после показа запроса, independent evidence.
4. Использовать PostgreSQL по умолчанию и явно помечать другой диалект.
5. После каждой задачи записывать correctness, assistance, типичные ошибки и delayed retest.

## Ближайший маршрут

1. Новый independent attempt для `1661`.
2. Ещё одна задача на `GROUP BY` + conditional aggregation без self join.
3. Delayed retest `1581` через `NOT EXISTS`.
4. Затем продолжить SQL 50: aggregation, subqueries и basic window functions.
5. Индексы, `EXPLAIN`, MVCC и транзакции вести отдельно как production-shaped PostgreSQL practice.
