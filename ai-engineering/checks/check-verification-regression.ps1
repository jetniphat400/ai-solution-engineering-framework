# Mechanizes the cheap, common cases from
# ai-engineering/core/verification.md's "Prohibited verification
# manipulation" list: a test-count drop, and syntactic patterns
# associated with weakening a check (suppression comments added,
# assertion-like lines removed with no replacement).
#
# This is a tripwire for shortcuts, NOT a semantic verifier. It
# CANNOT: distinguish a legitimate test removal (dead code deleted,
# its test correctly went too) from a manipulative one; catch a
# weakened check that doesn't touch recognizable assert/expect syntax;
# or judge test quality. A flag here means "a human should look," not
# "manipulation confirmed."
#
# -TestCountCmd: a shell command that prints a single integer (the
#   test count) to stdout. This script does not parse any test
#   framework's own output format -- shaping that command to emit a
#   bare number is the calling project's responsibility.
param(
    [string]$TestCountCmd,
    [string]$BaselineFile,
    [string]$DiffRef,
    [switch]$UpdateBaseline,
    [switch]$Advisory
)

$ErrorActionPreference = "Stop"
$problem = $false

if ($TestCountCmd -and $BaselineFile) {
    $rawCount = Invoke-Expression $TestCountCmd
    $currentCount = ([regex]::Match(($rawCount -join ""), '\d+')).Value
    if (-not $currentCount) {
        Write-Host "WARNING: -TestCountCmd produced no parseable integer; skipping test-count regression check."
    } elseif (-not (Test-Path $BaselineFile)) {
        Write-Host "No baseline file at $BaselineFile yet -- recording current count ($currentCount) as the new baseline."
        $dir = Split-Path -Parent $BaselineFile
        if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        Set-Content -Path $BaselineFile -Value $currentCount
    } else {
        # First integer only, not a strip-and-concatenate of every digit
        # on the line (matches the bash version's equivalent fix).
        $baselineCount = [int]([regex]::Match((Get-Content $BaselineFile | Select-Object -First 1), '\d+')).Value
        $currentCountInt = [int]$currentCount
        Write-Host "Test count: baseline=$baselineCount current=$currentCountInt"
        if ($currentCountInt -lt $baselineCount) {
            Write-Host "REGRESSION: test count dropped from $baselineCount to $currentCountInt."
            $problem = $true
        }
        if ($UpdateBaseline -and $currentCountInt -ge $baselineCount) {
            Set-Content -Path $BaselineFile -Value $currentCountInt
            Write-Host "Baseline updated to $currentCountInt."
        }
    }
} else {
    Write-Host "No -TestCountCmd/-BaselineFile given; skipping test-count regression check."
}

if ($DiffRef) {
    $diff = git diff $DiffRef 2>$null
} else {
    $diff = git diff --cached 2>$null
}

if ($diff) {
    $diffText = $diff -join "`n"
    $suppressions = ([regex]::Matches($diffText, '(?m)^\+.*(# *noqa|# *type: *ignore|# *pragma: *no *cover|eslint-disable|// *nolint)')).Count
    if ($suppressions -gt 0) {
        Write-Host "SUPPRESSION COMMENT(S) ADDED: $suppressions line(s) in this diff add a lint/type/coverage suppression. A human should confirm this isn't hiding a real problem."
        $problem = $true
    }

    $removedAsserts = ([regex]::Matches($diffText, '(?m)^-.*(assert |assert\(|expect\(|assertEqual|assertTrue|assertFalse|self\.assert)')).Count
    $addedAsserts = ([regex]::Matches($diffText, '(?m)^\+.*(assert |assert\(|expect\(|assertEqual|assertTrue|assertFalse|self\.assert)')).Count
    if ($removedAsserts -gt $addedAsserts) {
        Write-Host "ASSERTION(S) REMOVED WITH NO REPLACEMENT: $removedAsserts removed vs $addedAsserts added assertion-like lines. A human should confirm this is a legitimate removal (e.g. dead code), not a weakened check."
        $problem = $true
    }
} else {
    Write-Host "No diff to scan for manipulation smells."
}

if ($problem) {
    Write-Host "One or more heuristics fired. These are tripwires for human review, not proof of manipulation -- a legitimate reason may well exist. Document it (a committed justification), don't just disable this check."
    if ($Advisory) { exit 0 }
    exit 1
}

Write-Host "No regression heuristics fired."
exit 0
