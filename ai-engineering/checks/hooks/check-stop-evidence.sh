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
# comparison.
#
# MISSING BASELINE (BACKLOG-v1.2 Item 14, Defect 3): FAILS CLOSED on a
# missing baseline file, and says so plainly -- "no baseline was
# recorded," not "the repo changed" -- since a missing baseline proves
# nothing about the repo, only that no comparison is possible. Root
# cause diagnosed live: UserPromptSubmit never re-fires on a Stop-hook-
# forced continuation, so once a baseline is missing for any reason
# (hooks installed mid-turn; a baseline removed out from under the
# session), every forced continuation for the REST of that turn would
# otherwise repeat "no baseline" forever. This script self-heals by
# recording a RECOVERY baseline from the current state and writing a
# sibling marker file. Critically, a recovery baseline does NOT grant a
# future clean-diff pass within the same turn: while the marker is
# present, evidence is required for the rest of the turn regardless of
# comparison result, specifically so edits made earlier in the turn
# (before the recovery baseline was written) are never silently
# erased from consideration. userpromptsubmit-snapshot.sh clears the
# marker on the next genuine fresh prompt, since a real UserPromptSubmit
# means a trustworthy turn-start snapshot exists again. Under-
# enforcing on a turn that did modify the repo is the worse failure.
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
# DECLARATION-SCOPED STATUS COUNT (BACKLOG-v1.2 Item 14, Defect 2,
# fixing a real false positive found in live use): the terminal-status
# count below only counts tokens in a formal declaration position -- a
# line matching ^\s*(\*\*)?Terminal status\b, or a line that, after
# stripping markdown decoration, consists solely of one of the seven
# tokens. A message that names its outcome in prose (e.g. a summary
# sentence) and again in its formal declaration line no longer counts
# as two declarations -- only the declaration line is counted. Fixed
# after this exact false positive fired live, twice, immediately after
# Item 6 shipped.
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
# A recovery marker's mere presence means BASELINE_FILE was
# reconstructed mid-turn (the real turn-start snapshot was missing),
# not recorded by UserPromptSubmit at this turn's actual start.
# BACKLOG-v1.2 Item 14, Defect 3: while this marker is present, a
# clean git-status diff must NOT be treated as "nothing changed" --
# edits made earlier in the turn, before the recovery baseline was
# written, would otherwise be silently erased from consideration.
# Under-enforcing on a turn that did modify the repo is the worse
# failure, so enforcement continues for the rest of the turn
# regardless of comparison result until a genuine new turn (a real
# UserPromptSubmit) clears the marker.
RECOVERY_MARKER="$STATE_DIR/claude-hooks-${SESSION_ID}-baseline-recovery.marker"

CURRENT_STATUS=$(cd "$REPO_ROOT" && git status --porcelain 2>/dev/null)

if [ -f "$BASELINE_FILE" ] && [ ! -f "$RECOVERY_MARKER" ]; then
  BASELINE_STATUS=$(cat "$BASELINE_FILE")
  if [ "$CURRENT_STATUS" = "$BASELINE_STATUS" ]; then
    echo 0 > "$COUNTER_FILE" 2>/dev/null || true
    exit 0
  fi
elif [ -f "$BASELINE_FILE" ] && [ -f "$RECOVERY_MARKER" ]; then
  echo "[check-stop-evidence.sh] A recovery baseline is in effect for this turn (the real turn-start baseline was missing earlier in this turn and could not be confirmed) -- still enforcing the evidence block for the rest of this turn regardless of git-status comparison, since under-enforcing on a turn that did modify the repo is the worse failure." >&2
else
  echo "[check-stop-evidence.sh] No git-status baseline was recorded for this session -- cannot determine whether this turn changed anything, so failing closed and requiring the evidence block. A recovery baseline is now being recorded so this isn't silently repeated verbatim, but evidence will still be required for the rest of this turn." >&2
  # Marker written BEFORE baseline (independent-review finding M1):
  # this makes the unsafe transient window read as "no baseline yet"
  # (falls back into this same else branch, fail-closed) rather than
  # "baseline present, no marker" (the fast clean-diff-pass branch),
  # closing the race where a concurrent dual-fire sibling could read a
  # just-written recovery baseline as a genuine one and grant a false
  # pass.
  touch "$RECOVERY_MARKER" 2>/dev/null || true
  printf '%s\n' "$CURRENT_STATUS" > "$BASELINE_FILE" 2>/dev/null || true
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

# --- Terminal-status count: declaration position only (BACKLOG-v1.2
# Item 14, Defect 2) -- a message that names its outcome in prose and
# again in its formal declaration must not be flagged as ambiguous. A
# line counts as a declaration only if it matches
# ^\s*(\*\*)?Terminal status\b, or if the line, after stripping
# markdown decoration (`*_.: and whitespace) from both ends, equals
# exactly one of the seven known tokens. Prose mentions elsewhere in
# the message are excluded from the count entirely.
STATUS_TOKENS_REGEX='\b(DONE_VERIFIED|CONDITIONAL_PASS|REPLAN_REQUIRED|REQUIREMENT_AMBIGUOUS|SECURITY_BLOCKED|ENVIRONMENT_UNAVAILABLE|NEEDS_HUMAN)\b'
KNOWN_TOKENS=("DONE_VERIFIED" "CONDITIONAL_PASS" "REPLAN_REQUIRED" "REQUIREMENT_AMBIGUOUS" "SECURITY_BLOCKED" "ENVIRONMENT_UNAVAILABLE" "NEEDS_HUMAN")

is_known_token() {
  local candidate="$1" tok
  for tok in "${KNOWN_TOKENS[@]}"; do
    [ "$candidate" = "$tok" ] && return 0
  done
  return 1
}

DECLARATION_TEXT=""
while IFS= read -r line; do
  IS_DECL=0
  # Strip one leading list marker (-, +, *, or "N.") before checking,
  # so "- Terminal status: X" and "- `DONE_VERIFIED`" are recognized
  # (independent-review finding H1: this repo's own SKILL.md renders
  # the seven tokens as exactly this kind of bulleted list).
  LIST_STRIPPED=$(printf '%s' "$line" | sed -E 's/^[[:space:]]*([-+*]|[0-9]+\.)[[:space:]]+//')
  if printf '%s' "$LIST_STRIPPED" | grep -qiE '^[[:space:]]*(\*\*)?Terminal[[:space:]]+status\b'; then
    IS_DECL=1
  else
    STRIPPED=$(printf '%s' "$LIST_STRIPPED" | sed -E 's/^[[:space:]]*[`*_.:]*[[:space:]]*//; s/[[:space:]]*[`*_.:]*[[:space:]]*$//')
    if is_known_token "$STRIPPED"; then
      IS_DECL=1
    fi
  fi
  if [ "$IS_DECL" -eq 1 ]; then
    DECLARATION_TEXT="$DECLARATION_TEXT
$line"
  fi
done <<< "$MESSAGE_TEXT"


STATUS_COUNT=$(printf '%s' "$DECLARATION_TEXT" | grep -oE "$STATUS_TOKENS_REGEX" | wc -l | tr -d ' ')

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
  PROBLEMS+=("no terminal status found in a formal declaration position (a 'Terminal status' line, or a line consisting solely of a status token) in the final message")
elif [ "$STATUS_COUNT" -gt 1 ]; then
  PROBLEMS+=("$STATUS_COUNT terminal-status tokens found in declaration position in the final message, expected exactly 1")
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
echo "[check-stop-evidence.sh] BLOCKED (evidence required for this turn): ${PROBLEMS_JOINED}. AGENTS.md requires ending with exactly one terminal status and the five-field evidence block." >&2
exit 2
