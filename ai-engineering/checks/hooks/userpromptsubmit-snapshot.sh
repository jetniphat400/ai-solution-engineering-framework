#!/usr/bin/env bash
# Claude Code UserPromptSubmit hook: snapshots `git status --porcelain`
# for this session so the Stop hook (check-stop-evidence.sh) can tell
# whether THIS turn modified the repository, vs. an ordinary
# conversation turn -- a question, discussion, or a PROPOSE turn
# waiting for human confirmation -- that never touched a file.
# Enforcing the evidence-block requirement on every turn regardless
# would deadlock any non-edit turn (BACKLOG-v1.2 Item 6 design note
# (iv)); this snapshot is how that scope restriction is implemented.
#
# Also resets this session's Stop-hook block counter (see
# check-stop-evidence.sh's loop-guard), since a fresh user turn should
# not inherit a previous turn's block count.
#
# Never blocks: always exits 0, even if session_id can't be read or
# git fails. A missing/failed snapshot is treated by
# check-stop-evidence.sh as "no baseline recorded", which THAT script
# fails CLOSED on and self-heals with a RECOVERY baseline (see its
# header) -- this script clears that recovery marker on every genuine
# fresh prompt (BACKLOG-v1.2 Item 14, Defect 3), since a real
# UserPromptSubmit means a trustworthy turn-start snapshot now exists
# and the degraded recovery state no longer applies.
set -uo pipefail

INPUT=$(cat)

SESSION_ID=$(printf '%s\n' "$INPUT" \
  | grep -oE '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' \
  | head -1 \
  | sed -E 's/^"session_id"[[:space:]]*:[[:space:]]*"//; s/"$//')

if [ -z "$SESSION_ID" ]; then
  exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$SCRIPT_DIR/../../.." && pwd)}"
STATE_DIR="${TMPDIR:-${TEMP:-/tmp}}"

BASELINE_FILE="$STATE_DIR/claude-hooks-${SESSION_ID}-git-baseline.txt"
COUNTER_FILE="$STATE_DIR/claude-hooks-${SESSION_ID}-stop-blocks.txt"
RECOVERY_MARKER="$STATE_DIR/claude-hooks-${SESSION_ID}-baseline-recovery.marker"

(cd "$REPO_ROOT" && git status --porcelain 2>/dev/null) > "$BASELINE_FILE" 2>/dev/null || true
echo 0 > "$COUNTER_FILE" 2>/dev/null || true
rm -f "$RECOVERY_MARKER" 2>/dev/null || true

exit 0
