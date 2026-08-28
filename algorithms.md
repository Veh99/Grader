# Алгоритмический трек

Обновлено: 2026-08-28, audit update

## Назначение

Этот файл — portable source of truth для второго чата, где кандидат решает алгоритмические задачи. Backend readiness хранится в `progress.md`; алгоритмы фиксируются здесь, чтобы можно было продолжить подготовку с другого ПК без потери контекста.

## Текущий статус

- Фаза: отдельный параллельный трек.
- Readiness: не оценена по repository evidence — история конкретных решённых задач не была сохранена в файлах проекта на момент checkpoint.
- Нужно при следующем открытии второго чата восстановить фактический список задач, решений, ошибок и оценок.

## Как вести трек

После каждой значимой задачи записывать:

- дату и название задачи;
- режим: `independent`, `guided`, `immediate retrieval` или `delayed retrieval`;
- краткое условие и выбранный подход;
- итог: accepted/failed/not run;
- сложность по времени и памяти;
- ошибки и edge cases;
- оценку correctness, depth, production-style communication по шкале 0–4;
- дату delayed retest, если тема была слабой.

## Рекомендуемая структура подготовки

1. Arrays/strings: two pointers, sliding window, prefix sums.
2. Hashing: set/map, frequency counters, duplicate detection.
3. Stack/queue: monotonic stack, parentheses, next greater element.
4. Binary search: answer-space search and boundary conditions.
5. Linked list and intervals.
6. Trees: DFS/BFS, recursion depth, iterative traversal.
7. Graphs: BFS/DFS, topological sort, shortest paths basics.
8. Dynamic programming only after устойчивых fundamentals.

## Текущий gap

Нет сохранённого независимого evidence по конкретным алгоритмическим задачам. Не повышать оценку алгоритмической готовности по памяти или общим заявлениям; сначала зафиксировать задачи из второго чата и провести 1–2 delayed retest.

## Audit 2026-08-28

Проверены `HANDOFF.md`, `profile.md`, `plan.md`, `progress.md`, `README.md`, `sessions/`, `sprints/` и GitHub `main`. Детальная история второго алгоритмического чата в репозитории не найдена.

Следующее действие во втором чате: восстановить фактический список решённых задач из chat context и записать сюда минимум последние 3–5 упражнений или все упражнения после последней зафиксированной точки. Если chat context недоступен, начать с короткого recalibration set:

1. one arrays/strings task;
2. one hashing task;
3. one binary-search or stack task;
4. delayed retest по первой слабой теме.
