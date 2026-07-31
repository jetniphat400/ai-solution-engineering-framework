#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 TARGET_PATH [--overwrite]"
  exit 1
fi

TARGET_PATH="$1"
OVERWRITE="${2:-}"
SOURCE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET_ROOT="$(cd "$TARGET_PATH" && pwd)"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

# Framework-owned paths, relative to repo root. Files copy as files;
# directories are walked and merged file-by-file. Never whole-directory
# cp -R: when the destination directory already exists, that call
# nests the source directory inside it instead of merging.
FRAMEWORK_FILES=(
  "AGENTS.md"
  "CLAUDE.md"
  ".claude/agents/independent-reviewer.md"
  ".claude/rules/engineering.md"
  ".claude/rules/security.md"
)
FRAMEWORK_DIRS=(
  "ai-engineering"
  ".claude/skills/engineer"
  ".claude/skills/redteam"
  ".claude/skills/engineering-workflow"
)

copy_framework_file() {
  local rel="$1"
  local source="$SOURCE_ROOT/$rel"
  local target="$TARGET_ROOT/$rel"
  [ -e "$source" ] || return 0
  mkdir -p "$(dirname "$target")"
  if [ -e "$target" ]; then
    if [ "$OVERWRITE" != "--overwrite" ]; then
      echo "SKIP existing: $target"
      return 0
    fi
    local backup="$target.backup.$TIMESTAMP"
    cp "$target" "$backup"
    echo "BACKUP: $backup"
  fi
  cp "$source" "$target"
  echo "INSTALLED: $target"
}

for item in "${FRAMEWORK_FILES[@]}"; do
  copy_framework_file "$item"
done

for dir in "${FRAMEWORK_DIRS[@]}"; do
  source_dir="$SOURCE_ROOT/$dir"
  [ -d "$source_dir" ] || continue
  while IFS= read -r -d '' file; do
    rel="${file#"$source_dir"/}"
    copy_framework_file "$dir/$rel"
  done < <(find "$source_dir" -type f -print0)
done

settings_source="$SOURCE_ROOT/.claude/settings.json"
settings_target="$TARGET_ROOT/.claude/settings.json"
if [ -e "$settings_target" ]; then
  echo "REPORT (manual merge required): $settings_target already exists -- union its deny rules with $settings_source, never loosen."
elif [ -e "$settings_source" ]; then
  mkdir -p "$(dirname "$settings_target")"
  cp "$settings_source" "$settings_target"
  echo "INSTALLED: $settings_target"
fi

echo "Review AGENTS.md and .claude/settings.json before starting an agent."
echo "Note: this script only touches framework-owned paths above. Anything else under .claude/ (custom skills, agents, launch.json, settings.local.json, etc.) is never modified."
