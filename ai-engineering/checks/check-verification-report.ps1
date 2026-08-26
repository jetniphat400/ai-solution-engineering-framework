# Checks that a verification report has all five required evidence
# fields present and non-empty, per ai-engineering/core/verification.md's
# "Evidence format" (Command or procedure / Result / Pass or fail /
# Evidence location / Remaining risk).
#
# What this does NOT do: verify the evidence is true, verify a cited
# evidence location exists, or detect a check that silently never ran.
# It also only recognizes two shapes -- a colon-list ("Field: value")
# or a markdown table with all five field names as column headers
# (ai-engineering/templates/VERIFICATION-REPORT.template.md's shape).
# Evidence recorded any other way (e.g. inline prose in an issue
# register) is invisible to this tool -- that is a known limitation,
# not something this script tries to guess at.
param(
    [switch]$Strict,
    [string[]]$Path
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib\evidence-fields.ps1")

if (-not $Path -or $Path.Count -eq 0) {
    $Path = Get-ChildItem -Path . -Recurse -Filter "*VERIFICATION-REPORT*.md" -File |
        Where-Object { $_.FullName -notmatch '\\\.git\\' -and $_.Name -notlike "*.template.md" } |
        ForEach-Object { $_.FullName }
}

if (-not $Path -or $Path.Count -eq 0) {
    Write-Host "No VERIFICATION-REPORT-shaped files found."
    exit 0
}

function Test-Table {
    param([string[]]$Lines, [string]$File)
    $headerIndex = -1
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        if ($Lines[$i] -match '^\|.*Command or procedure.*\|.*Result.*\|.*Pass or fail.*\|.*Evidence location.*\|.*Remaining risk.*\|') {
            $headerIndex = $i
            break
        }
    }
    if ($headerIndex -eq -1) { return 1 }

    $problem = $false
    $rows = 0
    $i = $headerIndex + 2  # skip header + separator row
    while ($i -lt $Lines.Count -and $Lines[$i].TrimStart().StartsWith("|")) {
        $row = $Lines[$i]
        $cells = $row.Trim().Trim('|') -split '\|' | ForEach-Object { $_.Trim() }
        $nonEmpty = ($cells | Where-Object { $_.Length -gt 0 }).Count
        if ($nonEmpty -lt 5) {
            Write-Host "  EMPTY CELL(S): row $($i + 1) of $File has only $nonEmpty/5 non-empty fields: $row"
            $problem = $true
        }
        $rows++
        $i++
    }
    if ($rows -eq 0) {
        Write-Host "  TABLE FOUND BUT NO CHECK ROWS: $File's evidence table has a header but no entries"
        return 2
    }
    if ($problem) { return 2 }
    return 0
}

$anyProblem = $false
foreach ($file in $Path) {
    Write-Host "Checking: $file"
    $lines = Get-Content -Path $file
    $colonStatus = Test-ColonList -Lines $lines -File $file
    $tableStatus = 1
    if ($colonStatus -eq 1) {
        $tableStatus = Test-Table -Lines $lines -File $file
    }
    if ($colonStatus -eq 1 -and $tableStatus -eq 1) {
        Write-Host "  NO RECOGNIZED EVIDENCE BLOCK: neither a colon-list nor the template's table shape was found. This tool cannot see evidence recorded any other way (e.g. inline prose)."
        $anyProblem = $true
    } elseif ($colonStatus -eq 2 -or $tableStatus -eq 2) {
        $anyProblem = $true
    } else {
        Write-Host "  OK: all five evidence fields present and non-empty."
    }
}

if ($anyProblem -and $Strict) {
    exit 1
}
exit 0
