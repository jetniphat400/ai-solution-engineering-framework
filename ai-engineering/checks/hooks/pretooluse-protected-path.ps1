# Claude Code PreToolUse hook wrapper: blocks Edit/Write/MultiEdit on a
# path AGENTS.md's "Project-specific protected paths" block names, by
# invoking check-protected-paths.ps1 -LiteralPath against the single
# edited file.
#
# FAILS CLOSED. If tool_name or tool_input.file_path cannot be
# extracted from stdin, or check-protected-paths.ps1 exits anything
# other than 0 (clean) or 1 (flagged), this exits 2 and blocks -- never
# exit 0 on a parsing/tooling failure.
#
# Uses ConvertFrom-Json (native, robust) -- no truncation limitation
# the bash twin has for embedded quote characters, though file paths
# are unlikely to contain any in practice either way.
#
# Override: set AI_ENGINEERING_PROTECTED_PATH_OVERRIDE=1 to downgrade a
# real block to a visible warning. See pretooluse-protected-path.sh's
# header for the dual-fire design this participates in, and
# ai-engineering/policies/protected-assets.md for why setting the
# override is itself a Controlled-lane action.
$ErrorActionPreference = "Stop"

# Write-Error under $ErrorActionPreference="Stop" throws a terminating
# error and corrupts the script's own `exit N` into PowerShell's own
# exit code (1) -- discovered as a real bug while testing this script,
# not a style preference. Write directly to stderr instead so the
# intended exit code actually reaches Claude Code.
function Write-Stderr([string]$Message) {
    [Console]::Error.WriteLine($Message)
}

$rawInput = [Console]::In.ReadToEnd()

try {
    $parsed = $rawInput | ConvertFrom-Json
} catch {
    Write-Stderr "[pretooluse-protected-path.ps1] BLOCKED: could not parse hook input as JSON -- failing closed, not silently allowing."
    exit 2
}

$toolName = $parsed.tool_name
$filePath = $parsed.tool_input.file_path

if (-not $toolName -or -not $filePath) {
    Write-Stderr "[pretooluse-protected-path.ps1] BLOCKED: could not extract tool_name/file_path from hook input -- failing closed, not silently allowing."
    exit 2
}

$scriptDir = $PSScriptRoot
$repoRoot = $env:CLAUDE_PROJECT_DIR
if (-not $repoRoot) {
    $repoRoot = (Resolve-Path (Join-Path $scriptDir "..\..\..")).Path
}

# Reduce an absolute file_path to a repo-relative path -- see the bash
# twin's header for why this matters for directory-style tokens.
$repoRootNorm = $repoRoot -replace '\\', '/'
$filePathNorm = $filePath -replace '\\', '/'
if ($filePathNorm.StartsWith("$repoRootNorm/", [System.StringComparison]::OrdinalIgnoreCase)) {
    $relPath = $filePathNorm.Substring($repoRootNorm.Length + 1)
} else {
    $relPath = $filePathNorm
}

$checkScript = Join-Path $scriptDir "..\check-protected-paths.ps1"
Push-Location $repoRoot
$result = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $checkScript -LiteralPath $relPath 2>&1
$status = $LASTEXITCODE
Pop-Location

if ($status -eq 0) {
    exit 0
}

if ($status -ne 1) {
    Write-Stderr "[pretooluse-protected-path.ps1] BLOCKED: check-protected-paths.ps1 exited unexpectedly ($status) -- failing closed. Output: $result"
    exit 2
}

$matchedLine = ($result | Select-String "PROTECTED PATH TOUCHED" | Select-Object -First 1).Line

if ($env:AI_ENGINEERING_PROTECTED_PATH_OVERRIDE) {
    Write-Stderr "[pretooluse-protected-path.ps1] OVERRIDE ACTIVE (AI_ENGINEERING_PROTECTED_PATH_OVERRIDE is set): allowing $toolName on protected path '$relPath'. $matchedLine"
    exit 0
}

Write-Stderr "[pretooluse-protected-path.ps1] BLOCKED: $matchedLine. AGENTS.md's Protected assets rule requires a distinct explanation, independent review, and explicit human approval (Controlled lane) before this proceeds. To proceed anyway, a human must deliberately set AI_ENGINEERING_PROTECTED_PATH_OVERRIDE=1 for this session -- see ai-engineering/policies/protected-assets.md."
exit 2
