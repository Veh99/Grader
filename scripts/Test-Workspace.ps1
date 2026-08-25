[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$workspaceRoot = Split-Path -Parent $PSScriptRoot

$requiredFiles = @(
    'README.md',
    'HANDOFF.md',
    'AGENTS.md',
    'dependencies.md',
    'SECURITY.md',
    'profile.md',
    'plan.md',
    'progress.md',
    'sprints/week-01-foundations.md'
)

$expectedSubmodules = [ordered]@{
    'evidence/repositories/LawyerAI' = 'c3d995aaba464243bd2e10273fedfbcd749be7d3'
    'evidence/repositories/Secret_Project' = 'b1a702d957f08627da5c76b7c9b259c376b87a77'
    'evidence/repositories/ValikuloDance' = '6c779f53c38611d1ad105cdb26d53b346de1639e'
}

$failures = [System.Collections.Generic.List[string]]::new()

foreach ($relativePath in $requiredFiles) {
    $fullPath = Join-Path $workspaceRoot $relativePath
    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        $failures.Add("Missing required file: $relativePath")
    }
}

foreach ($entry in $expectedSubmodules.GetEnumerator()) {
    $submodulePath = Join-Path $workspaceRoot $entry.Key

    if (-not (Test-Path -LiteralPath $submodulePath -PathType Container)) {
        $failures.Add("Missing submodule directory: $($entry.Key)")
        continue
    }

    $actualCommit = git -C $submodulePath rev-parse HEAD 2>$null
    if ($LASTEXITCODE -ne 0) {
        $failures.Add("Submodule is not initialized: $($entry.Key)")
        continue
    }

    if ($actualCommit.Trim() -ne $entry.Value) {
        $failures.Add("Unexpected commit for $($entry.Key): $actualCommit")
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Host 'Workspace verification passed.' -ForegroundColor Green
Write-Host "Root: $workspaceRoot"
Write-Host "Required files: $($requiredFiles.Count)"
Write-Host "Pinned submodules: $($expectedSubmodules.Count)"
