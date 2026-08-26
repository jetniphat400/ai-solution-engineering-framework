# Claude Code Stop hook: enforces that the final assistant message
# contains exactly one AGENTS.md terminal status and the five-field
# evidence block -- but ONLY on a turn that actually modified the
# repository. See check-stop-evidence.sh's header for the full
# rationale (BACKLOG-v1.2 Item 6 design notes (iv)/loop guard, Item 14
# defects 2/3) -- this is its PowerShell twin, same behavior.
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
# See check-stop-evidence.sh's header (BACKLOG-v1.2 Item 14, Defect 3):
# this marker's presence means $baselineFile is a mid-turn RECOVERY
# snapshot, not a genuine turn-start one -- a clean diff against it
# must not be treated as "nothing changed," or edits made earlier in
# the turn (before the recovery baseline was written) would be
# silently erased from consideration.
$recoveryMarker = Join-Path $stateDir "claude-hooks-$sessionId-baseline-recovery.marker"

Push-Location $repoRoot
$currentStatus = (git status --porcelain 2>$null) -join "`n"
Pop-Location

if ((Test-Path $baselineFile) -and -not (Test-Path $recoveryMarker)) {
    $baselineStatus = (Get-Content -Path $baselineFile -Raw)
    if ($null -eq $baselineStatus) { $baselineStatus = "" }
    if ($currentStatus.Trim() -eq $baselineStatus.Trim()) {
        [System.IO.File]::WriteAllText($counterFile, "0", [System.Text.Encoding]::ASCII)
        exit 0
    }
} elseif ((Test-Path $baselineFile) -and (Test-Path $recoveryMarker)) {
    Write-Stderr "[check-stop-evidence.ps1] A recovery baseline is in effect for this turn (the real turn-start baseline was missing earlier in this turn and could not be confirmed) -- still enforcing the evidence block for the rest of this turn regardless of git-status comparison, since under-enforcing on a turn that did modify the repo is the worse failure."
} else {
    Write-Stderr "[check-stop-evidence.ps1] No git-status baseline was recorded for this session -- cannot determine whether this turn changed anything, so failing closed and requiring the evidence block. A recovery baseline is now being recorded so this isn't silently repeated verbatim, but evidence will still be required for the rest of this turn."
    # Marker written BEFORE baseline (independent-review finding
    # M1): this makes the unsafe transient window read as "no
    # baseline yet" (falls back into this same else branch,
    # fail-closed) rather than "baseline present, no marker" (the
    # fast clean-diff-pass branch), closing the race where a
    # concurrent dual-fire sibling could read a just-written
    # recovery baseline as a genuine one and grant a false pass.
    try {
        [System.IO.File]::WriteAllText($recoveryMarker, "1", [System.Text.Encoding]::ASCII)
    } catch {}
    try {
        [System.IO.File]::WriteAllText($baselineFile, $currentStatus, [System.Text.UTF8Encoding]::new($false))
    } catch {}
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

# --- Terminal-status count: declaration position only (BACKLOG-v1.2
# Item 14, Defect 2) -- a message that names its outcome in prose and
# again in its formal declaration must not be flagged as ambiguous. A
# line counts as a declaration only if it matches
# ^\s*(\*\*)?Terminal status\b, or if the line, after stripping
# markdown decoration from both ends, equals exactly one of the seven
# known tokens. Prose mentions elsewhere are excluded entirely.
$knownTokens = @("DONE_VERIFIED", "CONDITIONAL_PASS", "REPLAN_REQUIRED", "REQUIREMENT_AMBIGUOUS", "SECURITY_BLOCKED", "ENVIRONMENT_UNAVAILABLE", "NEEDS_HUMAN")
$statusPattern = '\b(DONE_VERIFIED|CONDITIONAL_PASS|REPLAN_REQUIRED|REQUIREMENT_AMBIGUOUS|SECURITY_BLOCKED|ENVIRONMENT_UNAVAILABLE|NEEDS_HUMAN)\b'

$messageLines = $messageText -split "`n"
$declarationLines = @()
foreach ($line in $messageLines) {
    $isDecl = $false
    # Strip one leading list marker (-, +, *, or "N.") before checking,
    # so "- Terminal status: X" and "- `DONE_VERIFIED`" are recognized
    # (independent-review finding H1: this repo's own SKILL.md renders
    # the seven tokens as exactly this kind of bulleted list).
    $listStripped = $line -replace '^\s*([-+*]|\d+\.)\s+', ''
    if ($listStripped -match '^\s*(\*\*)?Terminal\s+status\b') {
        $isDecl = $true
    } else {
        $stripped = $listStripped.Trim() -replace '^[`*_.:\s]+', '' -replace '[`*_.:\s]+$', ''
        if ($knownTokens -contains $stripped) {
            $isDecl = $true
        }
    }
    if ($isDecl) { $declarationLines += $line }
}
$declarationText = $declarationLines -join "`n"
$statusMatches = [regex]::Matches($declarationText, $statusPattern)
$statusCount = $statusMatches.Count

$fieldStatus = Test-ColonList -Lines $messageLines -File "<final message>"

$problems = @()
if ($statusCount -eq 0) {
    $problems += "no terminal status found in a formal declaration position (a 'Terminal status' line, or a line consisting solely of a status token) in the final message"
} elseif ($statusCount -gt 1) {
    $problems += "$statusCount terminal-status tokens found in declaration position in the final message, expected exactly 1"
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
Write-Stderr "[check-stop-evidence.ps1] BLOCKED (evidence required for this turn): $joined. AGENTS.md requires ending with exactly one terminal status and the five-field evidence block."
exit 2
