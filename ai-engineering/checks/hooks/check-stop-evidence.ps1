# Claude Code Stop hook: enforces that the final assistant message
# contains exactly one AGENTS.md terminal status and the five-field
# evidence block -- but ONLY on a turn that actually modified the
# repository. See check-stop-evidence.sh's header for the full
# rationale (BACKLOG-v1.2 Item 6 design notes (iv)/loop guard) -- this
# is its PowerShell twin.
#
# Unlike the bash twin, this needs no Python dependency:
# ConvertFrom-Json parses last_assistant_message natively and
# correctly regardless of embedded quotes/newlines.
$ErrorActionPreference = "Continue"

function Write-Stderr([string]$Message) {
    [Console]::Error.WriteLine($Message)
}

$rawInput = [Console]::In.ReadToEnd()

try {
    $parsed = $rawInput | ConvertFrom-Json
} catch {
    Write-Stderr "[check-stop-evidence.ps1] BLOCKED: could not parse hook input as JSON -- failing closed."
    exit 2
}

$sessionId = $parsed.session_id
if (-not $sessionId) {
    Write-Stderr "[check-stop-evidence.ps1] BLOCKED: could not extract session_id from hook input -- failing closed."
    exit 2
}

$scriptDir = $PSScriptRoot
$repoRoot = $env:CLAUDE_PROJECT_DIR
if (-not $repoRoot) {
    $repoRoot = (Resolve-Path (Join-Path $scriptDir "..\..\..")).Path
}
$stateDir = $env:TEMP
if (-not $stateDir) { $stateDir = [System.IO.Path]::GetTempPath() }

$baselineFile = Join-Path $stateDir "claude-hooks-$sessionId-git-baseline.txt"
$counterFile = Join-Path $stateDir "claude-hooks-$sessionId-stop-blocks.txt"

Push-Location $repoRoot
$currentStatus = (git status --porcelain 2>$null) -join "`n"
Pop-Location

if (Test-Path $baselineFile) {
    $baselineStatus = (Get-Content -Path $baselineFile -Raw)
    if ($null -eq $baselineStatus) { $baselineStatus = "" }
    if ($currentStatus.Trim() -eq $baselineStatus.Trim()) {
        [System.IO.File]::WriteAllText($counterFile, "0", [System.Text.Encoding]::ASCII)
        exit 0
    }
} else {
    Write-Stderr "[check-stop-evidence.ps1] No git-status baseline found for this session -- failing closed (assuming the repo changed this turn)."
}

# --- Loop guard ---
$blockCount = 0
if (Test-Path $counterFile) {
    $raw = (Get-Content -Path $counterFile -Raw).Trim()
    if ($raw -match '^\d+$') { $blockCount = [int]$raw }
}

if ($blockCount -ge 3) {
    Write-Stderr "[check-stop-evidence.ps1] LOOP GUARD RELEASED: this turn was blocked $blockCount times in a row for a missing/invalid evidence block. Allowing it to stop rather than looping indefinitely -- the evidence requirement is still NOT satisfied; this is not a pass."
    [System.IO.File]::WriteAllText($counterFile, "0", [System.Text.Encoding]::ASCII)
    exit 0
}

$messageText = $parsed.last_assistant_message
if ($null -eq $messageText) {
    Write-Stderr "[check-stop-evidence.ps1] BLOCKED: last_assistant_message field missing from hook input -- failing closed."
    $blockCount++
    [System.IO.File]::WriteAllText($counterFile, "$blockCount", [System.Text.Encoding]::ASCII)
    exit 2
}

. (Join-Path $scriptDir "..\lib\evidence-fields.ps1")

$statusPattern = '\b(DONE_VERIFIED|CONDITIONAL_PASS|REPLAN_REQUIRED|REQUIREMENT_AMBIGUOUS|SECURITY_BLOCKED|ENVIRONMENT_UNAVAILABLE|NEEDS_HUMAN)\b'
$statusMatches = [regex]::Matches($messageText, $statusPattern)
$statusCount = $statusMatches.Count

$messageLines = $messageText -split "`n"
$fieldStatus = Test-ColonList -Lines $messageLines -File "<final message>"

$problems = @()
if ($statusCount -eq 0) {
    $problems += "no terminal status from AGENTS.md's vocabulary found in the final message"
} elseif ($statusCount -gt 1) {
    $problems += "$statusCount terminal-status tokens found in the final message, expected exactly 1 (this counts every mention anywhere in the text, including discussion/quotation of the vocabulary -- a known false-positive source, see check-stop-evidence.sh's header)"
}
if ($fieldStatus -eq 1) {
    $problems += "no five-field evidence block found (no recognized 'Field: value' lines)"
} elseif ($fieldStatus -eq 2) {
    $problems += "five-field evidence block incomplete"
}

if ($problems.Count -eq 0) {
    [System.IO.File]::WriteAllText($counterFile, "0", [System.Text.Encoding]::ASCII)
    exit 0
}

$blockCount++
[System.IO.File]::WriteAllText($counterFile, "$blockCount", [System.Text.Encoding]::ASCII)
$joined = $problems -join "; "
Write-Stderr "[check-stop-evidence.ps1] BLOCKED (this turn modified the repository, per git status): $joined. AGENTS.md requires ending with exactly one terminal status and the five-field evidence block."
exit 2
