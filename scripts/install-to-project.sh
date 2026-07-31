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

for item in AGENTS.md CLAUDE.md ai-engineering .claude; do
  source="$SOURCE_ROOT/$item"
  target="$TARGET_ROOT/$item"
  if [ -e "$target" ] && [ "$OVERWRITE" != "--overwrite" ]; then
    echo "SKIP existing: $target"
    continue
  fi
  if [ -e "$target" ]; then
    backup="$target.backup.$(date +%Y%m%d%H%M%S)"
    cp -R "$target" "$backup"
    echo "BACKUP: $backup"
  fi
  cp -R "$source" "$target"
  echo "INSTALLED: $target"
done

echo "Review AGENTS.md and .claude/settings.json before starting an agent."
