# Dependencies and bootstrap

## Required

- Git for Windows.
- Codex desktop app or another environment capable of reading `AGENTS.md` and workspace files.
- .NET SDK matching the exercises; modern exercises target .NET 8+ unless a task says otherwise.

## Practical exercises

- Docker Desktop or a local PostgreSQL instance for relational integration tests and `EXPLAIN (ANALYZE, BUFFERS)`.
- An editor/IDE such as Visual Studio, Rider or VS Code.
- Node.js only when a reviewed repository's frontend must be built.

## Codex coaching dependency

The original environment had the user-scoped skill `dotnet-interview-coach` installed outside this repository. It is intentionally not copied because its distribution source and license have not been established.

On another machine:

1. Install the same skill from its trusted original source if available.
2. If unavailable, use `AGENTS.md` plus `HANDOFF.md`, `profile.md`, `plan.md` and `progress.md` as the portable fallback.
3. Do not copy the entire Codex home: it can contain credentials, machine-specific paths, plugin caches and private configuration.

## Optional backup tooling

- 7-Zip for an AES-256 recovery snapshot.
- GitHub CLI (`gh`) for creating/authenticating the private remote; the browser UI is an equivalent option.

## Known portability limitation

`evidence/repositories/LawyerAI/Start-LawyerAI.Services.ps1` has a machine-specific default path. It does not affect evidence review. If the launcher must be used, configure its `BaseDirectory` explicitly or change it in the upstream repository as a separate task.
