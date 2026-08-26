# Shared evidence-field vocabulary and colon-list detector for
# ai-engineering/core/verification.md's "Evidence format" (Command or
# procedure / Result / Pass or fail / Evidence location / Remaining
# risk). Extracted out of check-verification-report.ps1 so that script
# and the Stop hook's check-stop-evidence.ps1 check the same five field
# names from one place, per BACKLOG-v1.2 Item 6. Dot-sourced, not run
# directly -- it defines $Fields and Test-ColonList only.
#
# The markdown-table detection logic (Test-Table in
# check-verification-report.ps1) is NOT shared here: it hardcodes the
# five names in a header-row regex rather than looping over $Fields,
# and a Stop hook checking prose in a chat message has no reason to
# expect a markdown table shape.

$Fields = @("Command or procedure", "Result", "Pass or fail", "Evidence location", "Remaining risk")

function Test-ColonList {
    param([string[]]$Lines, [string]$File)
    $found = $false
    $problem = $false
    foreach ($field in $Fields) {
        $pattern = "^[\s>*-]*" + [regex]::Escape($field) + ":\s*(.*)$"
        $match = $Lines | Select-String -Pattern $pattern | Select-Object -First 1
        if ($match) {
            $value = $match.Matches[0].Groups[1].Value.Trim()
            if ($value.Length -eq 0) {
                Write-Host "  MISSING VALUE: '$field`:' present but empty in $File"
                $problem = $true
            }
            $found = $true
        }
    }
    if ($found -and -not $problem) { return 0 }
    if ($found) { return 2 }
    return 1
}
