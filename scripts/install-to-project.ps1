param(
    [Parameter(Mandatory=$true)][string]$TargetPath,
    [switch]$Overwrite
)

$ErrorActionPreference = "Stop"
$SourceRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$TargetRoot = (Resolve-Path $TargetPath).Path
$Timestamp = Get-Date -Format yyyyMMddHHmmss

# Framework-owned paths, relative to repo root. Files copy as files;
# directories are walked and merged file-by-file. Never whole-directory
# Copy-Item -Recurse: when the destination directory already exists,
# that call nests the source directory inside it instead of merging.
$FrameworkFiles = @(
    "AGENTS.md",
    "CLAUDE.md",
    ".claude/agents/independent-reviewer.md",
    ".claude/rules/engineering.md",
    ".claude/rules/security.md"
)
$FrameworkDirs = @(
    "ai-engineering",
    ".claude/skills/engineer",
    ".claude/skills/redteam",
    ".claude/skills/engineering-workflow"
)

function Copy-FrameworkFile {
    param([string]$RelativePath)
    $Source = Join-Path $SourceRoot $RelativePath
    $Target = Join-Path $TargetRoot $RelativePath
    if (-not (Test-Path $Source)) { return }
    $TargetDir = Split-Path -Parent $Target
    if ($TargetDir -and -not (Test-Path $TargetDir)) {
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    }
    if (Test-Path $Target) {
        if (-not $Overwrite) {
            Write-Host "SKIP existing: $Target"
            return
        }
        $Backup = "$Target.backup.$Timestamp"
        Copy-Item $Target $Backup -Force
        Write-Host "BACKUP: $Backup"
    }
    Copy-Item $Source $Target -Force
    Write-Host "INSTALLED: $Target"
}

foreach ($item in $FrameworkFiles) {
    Copy-FrameworkFile $item
}

foreach ($dir in $FrameworkDirs) {
    $SourceDir = Join-Path $SourceRoot $dir
    if (-not (Test-Path $SourceDir)) { continue }
    Get-ChildItem -Path $SourceDir -Recurse -File | ForEach-Object {
        $RelativePath = $_.FullName.Substring($SourceDir.Length + 1)
        Copy-FrameworkFile (Join-Path $dir $RelativePath)
    }
}

# .claude/settings.json is never auto-copied onto an existing file: its
# deny rules must be merged (union, never loosened), which this script
# cannot safely automate. It only installs fresh when absent.
$SettingsSource = Join-Path $SourceRoot ".claude/settings.json"
$SettingsTarget = Join-Path $TargetRoot ".claude/settings.json"
if (Test-Path $SettingsTarget) {
    Write-Host "REPORT (manual merge required): $SettingsTarget already exists -- union its deny rules with $SettingsSource, never loosen."
} elseif (Test-Path $SettingsSource) {
    New-Item -ItemType Directory -Path (Split-Path -Parent $SettingsTarget) -Force | Out-Null
    Copy-Item $SettingsSource $SettingsTarget -Force
    Write-Host "INSTALLED: $SettingsTarget"
}

Write-Host "Review AGENTS.md and .claude/settings.json before starting an agent."
Write-Host "Note: this script only touches framework-owned paths above. Anything else under .claude/ (custom skills, agents, launch.json, settings.local.json, etc.) is never modified."
