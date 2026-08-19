# Lists non-framework-owned skills under .claude/skills/ and flags any
# with no corresponding row in ai-engineering/policies/skill-supply-chain.md's
# allowlist table. Advisory only -- this makes the gap visible and
# auditable, per that policy's own scoped proposal; it does not attempt
# real enforcement.
#
# What this does NOT do: verify a recorded pinned commit matches the
# skill's current on-disk content (no hash-checking); audit whether an
# allowlisted skill's content is actually safe (paperwork presence
# check, not a security review); or see anything loaded from outside
# .claude/skills/ (a marketplace plugin, an MCP server).
$ErrorActionPreference = "Stop"

$SkillsDir = ".claude/skills"
$PolicyFile = "ai-engineering/policies/skill-supply-chain.md"
$FrameworkOwned = @("engineer", "redteam", "engineering-workflow")

if (-not (Test-Path $SkillsDir)) {
    Write-Host "No $SkillsDir directory -- nothing to check."
    exit 0
}

if (-not (Test-Path $PolicyFile)) {
    Write-Host "No $PolicyFile found -- cannot cross-check an allowlist that doesn't exist. This itself is worth noting if the repo has a Full install."
    exit 0
}

$lines = Get-Content -Path $PolicyFile
$registered = New-Object System.Collections.Generic.List[string]
$header = $false
foreach ($line in $lines) {
    if ($line -match '^\| *Name *\|') { $header = $true; continue }
    if ($header -and $line -match '^\|[ -]+\|') { continue }
    if ($header -and $line.StartsWith("|")) {
        $cols = $line.Trim('|') -split '\|'
        if ($cols.Count -gt 0) {
            $name = $cols[0].Trim()
            if ($name.Length -gt 0) { $registered.Add($name) }
        }
    }
}

$unregisteredCount = 0
Get-ChildItem -Path $SkillsDir -Directory | ForEach-Object {
    $name = $_.Name
    if ($FrameworkOwned -contains $name) { return }
    if ($registered -contains $name) {
        Write-Host "OK (registered): $name"
    } else {
        Write-Host "UNREGISTERED SKILL: $name (present in $SkillsDir, no row in $PolicyFile's allowlist)"
        $script:unregisteredCount++
    }
}

if ($unregisteredCount -gt 0) {
    Write-Host "$unregisteredCount unregistered skill(s) found. Advisory only -- per skill-supply-chain.md's own preflight audit checklist before adding a row, not a hard gate. A legitimately in-progress audit is not a failure."
}
exit 0
