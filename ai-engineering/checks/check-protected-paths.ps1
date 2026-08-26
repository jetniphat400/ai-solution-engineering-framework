# Diffs changed files against the project's own AGENTS.md
# "Project-specific protected paths" block and flags any overlap.
# Mirrors AGENTS.md's "Protected assets" rule mechanically for the
# common case (a named file or directory) -- it cannot enforce a
# protection described only as a behavior with no extractable path.
#
# Default mode diffs staged changes (git diff --cached --name-only) --
# suitable as a pre-commit hook. -Ref diffs against a given ref
# instead. -LiteralPath checks exactly one literal path with no git
# diff at all -- added for the PreToolUse hook wrapper
# (ai-engineering/checks/hooks/pretooluse-protected-path.ps1), which is
# handed a single file path per tool call. -LiteralPath and -Ref are
# mutually exclusive. Does not change the default or -Ref behavior.
#
# What this does NOT do: verify a flagged change was actually approved
# (only that contact happened); reliably extract a protection described
# as prose with no file-shaped token in it; split a single line's
# "a.ext/b.ext"-looking compound token into two separate paths (a real,
# known limitation); or treat a URL route pattern (anything starting
# with "/", e.g. "/api/trading/*") as a checkable file path -- those
# are discarded as non-file noise.
param(
    [switch]$Advisory,
    [string]$Ref,
    [string]$AgentsFile = "AGENTS.md",
    [string]$LiteralPath
)

$ErrorActionPreference = "Stop"

if ($LiteralPath -and $Ref) {
    Write-Host "-LiteralPath and -Ref are mutually exclusive."
    exit 2
}

if (-not (Test-Path $AgentsFile)) {
    Write-Host "No $AgentsFile found -- nothing to check against. Not an error: a repo with no AGENTS.md has no protected-paths list to enforce."
    exit 0
}

$lines = Get-Content -Path $AgentsFile
$blockLines = @()
$flag = $false
$fence = 0
foreach ($line in $lines) {
    if (-not $flag) {
        if ($line -match '^Project-specific protected paths:') { $flag = $true }
        continue
    }
    if ($line -match '^```') {
        $fence++
        if ($fence -eq 2) { break }
        continue
    }
    if ($fence -eq 1) { $blockLines += $line }
}

if ($blockLines.Count -eq 0) {
    Write-Host "No 'Project-specific protected paths' block found (or it is empty/still the [ADD PATHS] placeholder) in $AgentsFile -- nothing to check against."
    exit 0
}

$tokensRaw = New-Object System.Collections.Generic.List[string]
foreach ($line in $blockLines) {
    foreach ($m in [regex]::Matches($line, '"([^"]+)"')) {
        $tokensRaw.Add($m.Groups[1].Value)
    }
    $stripped = [regex]::Replace($line, '"[^"]+"', '')
    foreach ($m in [regex]::Matches($stripped, '[A-Za-z0-9_./-]+\.[A-Za-z0-9]+|[A-Za-z0-9_./-]*/[A-Za-z0-9_./-]+')) {
        $tokensRaw.Add(($m.Value -replace '[,;:\)]+$', ''))
    }
}

$tokens = $tokensRaw | Where-Object { $_ -and -not $_.StartsWith("/") } | Select-Object -Unique

if (-not $tokens -or $tokens.Count -eq 0) {
    Write-Host "No path-shaped tokens could be extracted from the protected-paths block -- nothing to check against. This does not mean the block is empty; it may describe protections this tool cannot parse into file paths."
    exit 0
}

Write-Host "Protected-path tokens recognized:"
foreach ($t in $tokens) { Write-Host "  - $t" }

if ($LiteralPath) {
    $changed = @($LiteralPath)
} elseif ($Ref) {
    $changed = git diff --name-only $Ref 2>$null
} else {
    $changed = git diff --cached --name-only 2>$null
}

if (-not $changed) {
    Write-Host "No changed files to check."
    exit 0
}

function Test-Protected {
    param([string]$File, [string[]]$Tokens)
    foreach ($token in $Tokens) {
        if ($File -eq $token) { return $token }
        if ($token.EndsWith("/")) {
            if ($File.StartsWith($token)) { return $token }
        } else {
            if ($File -eq $token -or $File.EndsWith("/$token")) { return $token }
        }
    }
    return $null
}

$flagged = $false
foreach ($file in $changed) {
    if (-not $file) { continue }
    $matchedToken = Test-Protected -File $file -Tokens $tokens
    if ($matchedToken) {
        Write-Host "PROTECTED PATH TOUCHED: $file (matches: $matchedToken)"
        $flagged = $true
    }
}

if ($flagged) {
    Write-Host "One or more changed files touch a protected path. AGENTS.md requires explicit human approval before this proceeds."
    if ($Advisory) { exit 0 }
    exit 1
}

Write-Host "No protected-path contact detected in changed files."
exit 0
