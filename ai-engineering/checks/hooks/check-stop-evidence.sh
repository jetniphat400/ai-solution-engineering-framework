#!/usr/bin/env bash
# Claude Code Stop hook: enforces that the final assistant message
# contains exactly one AGENTS.md terminal status and the five-field
# evidence block from ai-engineering/core/verification.md -- but ONLY
# on a turn that actually modified the repository. An ordinary
# conversation turn, a question, or a PROPOSE turn waiting for human
# confirmation never touched a file and must be allowed to end without
# an evidence block; enforcing it unconditionally deadlocks every
# non-edit turn (BACKLOG-v1.2 Item 6 design note (iv)).
#
# CHANGE DETECTION: compares `git status --porcelain` now against the
# baseline userpromptsubmit-snapshot.sh recorded at the start of this
# user turn. This catches any repo change made during the turn,
# including one made via the Bash tool (git apply, sed -i, etc.), not
# only Edit/Write/MultiEdit -- broader coverage than a PostToolUse
# marker restricted to those three tools would give. Known
# limitations: a change to a gitignored file won't show as dirty and
# won't trigger enforcement; two Claude Code sessions sharing one
# working directory can cross-contaminate each other's git-status
# comparison. FAILS CLOSED on a missing baseline file (treats "no
# recorded baseline" as "assume the repo changed") rather than
# silently skipping enforcement.
#
# LOOP GUARD: `stop_hook_active` -- the field Claude Code's own Stop
# hook is documented elsewhere to carry for exactly this purpose in
# some versions -- was checked and does NOT appear anywhere in the
# hooks reference for the installed version (2.1.246): verified absent
# by direct, repeated doc search, not assumed present, per this item's
# explicit instruction not to rely on it without checking. In its
# place, this script keeps its own per-session block counter (reset
# each new turn by userpromptsubmit-snapshot.sh) and gives up after 3
# consecutive blocks, exiting 0 with a loud warning rather than looping
# forever. This fails OPEN only for the loop guard itself, specifically
# so the turn is guaranteed to terminate -- the missing evidence is
# still reported as missing, never silently treated as satisfied.
#
# EXTRACTION: last_assistant_message is a full free-text message that
# routinely contains embedded quotes, backticks, and newlines. Testing
# during this item's implementation showed a hand-written POSIX-ERE
# "escaped-quote-aware" regex (the usual (\\.|[^"\\])* idiom) does NOT
# reliably extract such a value with GNU grep 3.0 -- confirmed by a
# direct failing repro before this script was written, not assumed.
# `jq` is confirmed absent from this repo's Git Bash. This script
# therefore uses `python`/`python3` (real JSON parsing) for this one
# field only -- a real, new runtime dependency for the bash
# implementation specifically, introduced only after the no-dependency
# approach was empirically shown unsafe, not by default. On Windows,
# `python3` can silently resolve to the non-functional Microsoft Store
# stub even when real Python is installed as `python` -- confirmed on
# the reference dev machine -- so both names are tried and the ACTUAL
# exit code/output is checked, not just whether a `python*` command
# exists on PATH. If neither interpreter actually works, this fails
# CLOSED (exit 2), per this item's fail-closed requirement, rather than
# silently skip the evidence check. The PowerShell twin
# (check-stop-evidence.ps1) has no such dependency: ConvertFrom-Json is
# native and robust.
#
# FALSE-POSITIVE NOTE: the terminal-status count below is a whole-
# message occurrence count, not scoped to a single declared "final"
# status line. A message that discusses or quotes AGENTS.md's status
# vocabulary (exactly the kind of message this framework's own sessions
# produce) can trip the ">1 status token" case even when a single
# status was validly declared. Documented here and in
# ai-engineering/adapters/claude/hooks.md rather than hidden; shipped
# as literally specified, over-blocking rather than under-blocking.
set -uo pipefail

INPUT=$(cat)

extract_flat_string() {
  local key="$1"
  printf '%s\n' "$INPUT" \
    | grep -oE "\"${key}\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" \
    | head -1 \
    | sed -E "s/^\"${key}\"[[:space:]]*:[[:space:]]*\"//; s/\"\$//"
}

SESSION_ID=$(extract_flat_string "session_id")

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$SCRIPT_DIR/../../.." && pwd)}"
STATE_DIR="${TMPDIR:-${TEMP:-/tmp}}"

if [ -z "$SESSION_ID" ]; then
  echo "[check-stop-evidence.sh] BLOCKED: could not extract session_id from hook input -- failing closed." >&2
  exit 2
fi

BASELINE_FILE="$STATE_DIR/claude-hooks-${SESSION_ID}-git-baseline.txt"
COUNTER_FILE="$STATE_DIR/claude-hooks-${SESSION_ID}-stop-blocks.txt"

CURRENT_STATUS=$(cd "$REPO_ROOT" && git status --porcelain 2>/dev/null)

if [ -f "$BASELINE_FILE" ]; then
  BASELINE_STATUS=$(cat "$BASELINE_FILE")
  if [ "$CURRENT_STATUS" = "$BASELINE_STATUS" ]; then
    echo 0 > "$COUNTER_FILE" 2>/dev/null || true
    exit 0
  fi
else
  echo "[check-stop-evidence.sh] No git-status baseline found for this session -- failing closed (assuming the repo changed this turn)." >&2
fi

# --- Loop guard ---
BLOCK_COUNT=0
if [ -f "$COUNTER_FILE" ]; then
  BLOCK_COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
fi
case "$BLOCK_COUNT" in ''|*[!0-9]*) BLOCK_COUNT=0 ;; esac

if [ "$BLOCK_COUNT" -ge 3 ]; then
  echo "[check-stop-evidence.sh] LOOP GUARD RELEASED: this turn was blocked $BLOCK_COUNT times in a row for a missing/invalid evidence block. Allowing it to stop rather than looping indefinitely -- the evidence requirement is still NOT satisfied; this is not a pass." >&2
  echo 0 > "$COUNTER_FILE" 2>/dev/null || true
  exit 0
fi

# --- Extract last_assistant_message via a real JSON parser ---
MESSAGE_TEXT=""
EXTRACT_OK=0
for interp in python python3; do
  if command -v "$interp" >/dev/null 2>&1; then
    OUT=$(printf '%s' "$INPUT" | "$interp" -c '
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(3)
msg = d.get("last_assistant_message")
if msg is None:
    sys.exit(4)
sys.stdout.write(msg)
' 2>/dev/null)
    RC=$?
    if [ "$RC" -eq 0 ]; then
      MESSAGE_TEXT="$OUT"
      EXTRACT_OK=1
      break
    fi
  fi
done

if [ "$EXTRACT_OK" -ne 1 ]; then
  echo "[check-stop-evidence.sh] BLOCKED: could not extract last_assistant_message (no working python/python3 interpreter found, or malformed JSON) -- failing closed." >&2
  BLOCK_COUNT=$((BLOCK_COUNT + 1))
  echo "$BLOCK_COUNT" > "$COUNTER_FILE" 2>/dev/null || true
  exit 2
fi

# --- Terminal-status count ---
STATUS_TOKENS_REGEX='\b(DONE_VERIFIED|CONDITIONAL_PASS|REPLAN_REQUIRED|REQUIREMENT_AMBIGUOUS|SECURITY_BLOCKED|ENVIRONMENT_UNAVAILABLE|NEEDS_HUMAN)\b'
STATUS_COUNT=$(printf '%s' "$MESSAGE_TEXT" | grep -oE "$STATUS_TOKENS_REGEX" | wc -l | tr -d ' ')

# --- Five-field evidence block, reusing the shared field list ---
# shellcheck source=../lib/evidence-fields.sh
source "$SCRIPT_DIR/../lib/evidence-fields.sh"

TMP_MSG_FILE=$(mktemp)
printf '%s\n' "$MESSAGE_TEXT" > "$TMP_MSG_FILE"
FIELD_OUTPUT=$(check_colon_list "$TMP_MSG_FILE")
FIELD_STATUS=$?
rm -f "$TMP_MSG_FILE"

PROBLEMS=()
if [ "$STATUS_COUNT" -eq 0 ]; then
  PROBLEMS+=("no terminal status from AGENTS.md's vocabulary found in the final message")
elif [ "$STATUS_COUNT" -gt 1 ]; then
  PROBLEMS+=("$STATUS_COUNT terminal-status tokens found in the final message, expected exactly 1 (this counts every mention anywhere in the text, including discussion/quotation of the vocabulary -- a known false-positive source, see this script's header)")
fi
if [ "$FIELD_STATUS" -eq 1 ]; then
  PROBLEMS+=("no five-field evidence block found (no recognized 'Field: value' lines)")
elif [ "$FIELD_STATUS" -eq 2 ]; then
  PROBLEMS+=("five-field evidence block incomplete -- $FIELD_OUTPUT")
fi

if [ "${#PROBLEMS[@]}" -eq 0 ]; then
  echo 0 > "$COUNTER_FILE" 2>/dev/null || true
  exit 0
fi

BLOCK_COUNT=$((BLOCK_COUNT + 1))
echo "$BLOCK_COUNT" > "$COUNTER_FILE" 2>/dev/null || true
PROBLEMS_JOINED=$(printf '%s; ' "${PROBLEMS[@]}")
PROBLEMS_JOINED="${PROBLEMS_JOINED%; }"
echo "[check-stop-evidence.sh] BLOCKED (this turn modified the repository, per git status): ${PROBLEMS_JOINED}. AGENTS.md requires ending with exactly one terminal status and the five-field evidence block." >&2
exit 2
