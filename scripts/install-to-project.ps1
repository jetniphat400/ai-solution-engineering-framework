param(
    [Parameter(Mandatory=$true)][string]$TargetPath,
    [switch]$Overwrite
)

$ErrorActionPreference = "Stop"
$SourceRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$TargetRoot = (Resolve-Path $TargetPath).Path
$Items = @("AGENTS.md", "CLAUDE.md", "ai-engineering", ".claude")

foreach ($Item in $Items) {
    $Source = Join-Path $SourceRoot $Item
    $Target = Join-Path $TargetRoot $Item
    if (Test-Path $Target) {
        if (-not $Overwrite) {
            Write-Host "SKIP existing: $Target"
            continue
        }
        $Backup = "$Target.backup.$(Get-Date -Format yyyyMMddHHmmss)"
        Copy-Item $Target $Backup -Recurse -Force
        Write-Host "BACKUP: $Backup"
    }
    Copy-Item $Source $Target -Recurse -Force
    Write-Host "INSTALLED: $Target"
}

Write-Host "Review AGENTS.md and .claude/settings.json before starting an agent."
