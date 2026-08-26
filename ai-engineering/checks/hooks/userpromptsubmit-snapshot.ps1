# Claude Code UserPromptSubmit hook: snapshots `git status --porcelain`
# for this session so the Stop hook (check-stop-evidence.ps1) can tell
# whether THIS turn modified the repository. See
# userpromptsubmit-snapshot.sh's header for the full rationale
# (BACKLOG-v1.2 Item 6 design note (iv)) -- this is its PowerShell
# twin, same behavior.
#
# Never blocks: always exits 0.
$ErrorActionPreference = "Continue"

$rawInput = [Console]::In.ReadToEnd()

$sessionMatch = [regex]::Match($rawInput, '"session_id"\s*:\s*"([^"]*)"')
if (-not $sessionMatch.Success) {
    exit 0
}
$sessionId = $sessionMatch.Groups[1].Value

$scriptDir = $PSScriptRoot
$repoRoot = $env:CLAUDE_PROJECT_DIR
if (-not $repoRoot) {
    $repoRoot = (Resolve-Path (Join-Path $scriptDir "..\..\..")).Path
}
$stateDir = $env:TEMP
if (-not $stateDir) { $stateDir = [System.IO.Path]::GetTempPath() }

$baselineFile = Join-Path $stateDir "claude-hooks-$sessionId-git-baseline.txt"
$counterFile = Join-Path $stateDir "claude-hooks-$sessionId-stop-blocks.txt"

try {
    Push-Location $repoRoot
    $status = git status --porcelain 2>$null
    Pop-Location
    [System.IO.File]::WriteAllText($baselineFile, ($status -join "`n"), [System.Text.UTF8Encoding]::new($false))
} catch {
    # Best-effort snapshot -- a failure here is not fatal; the Stop
    # hook fails closed on a missing baseline.
}

[System.IO.File]::WriteAllText($counterFile, "0", [System.Text.Encoding]::ASCII)

exit 0
