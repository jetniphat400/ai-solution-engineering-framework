#!/usr/bin/env bash
# Claude Code PreToolUse hook wrapper: blocks Edit/Write/MultiEdit on a
# path AGENTS.md's "Project-specific protected paths" block names, by
# invoking check-protected-paths.sh --path against the single edited
# file (see that script's own header for why --path exists).
#
# FAILS CLOSED. If tool_name or tool_input.file_path cannot be
# extracted from stdin, or check-protected-paths.sh exits anything
# other than 0 (clean) or 1 (flagged), this exits 2 and blocks -- never
# exit 0 on a parsing/tooling failure. A security hook that silently
# passes on malformed input is worse than no hook.
#
# No jq/python dependency: `jq` is confirmed absent from this repo's
# Git Bash. tool_name and tool_input.file_path are extracted with
# grep/sed against the documented flat "key":"value" JSON shape, not a
# real JSON parser. This truncates at the first double-quote character
# inside the value (escaped or not) -- acceptable for a file path,
# which does not contain literal quote characters in practice, but NOT
# a general JSON-string parser. (The Stop hook's last_assistant_message
# needed a stronger guarantee than this -- see check-stop-evidence.sh's
# header for why that one uses Python instead.)
#
# Override: set AI_ENGINEERING_PROTECTED_PATH_OVERRIDE=1 to downgrade a
# real block to a visible warning (printed on every use -- no
# allowlist, no silent bypass). Setting this variable is itself a
# Controlled-lane action requiring deliberate human intent -- see
# ai-engineering/policies/protected-assets.md.
#
# Dual-fire by design: this script and its PowerShell twin
# (pretooluse-protected-path.ps1) are both registered in
# .claude/settings.json for the same event via exec-form handlers
# ("bash" / "powershell.exe"), so whichever interpreter a host lacks
# fails harmlessly (non-blocking, per Claude Code's hook exit-code
# rules) while the other does the real check. On a host with BOTH
# interpreters, both run on every matched tool call -- redundant but
# not wrong. Each wrapper prefixes its message with its own name so
# two independent block messages are distinguishable, not confusing
# duplicates.
set -uo pipefail

INPUT=$(cat)

extract_json_string() {
  # Best-effort flat "key":"value" extractor -- see header limitation.
  local key="$1"
  printf '%s\n' "$INPUT" \
    | grep -oE "\"${key}\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" \
    | head -1 \
    | sed -E "s/^\"${key}\"[[:space:]]*:[[:space:]]*\"//; s/\"\$//" \
    | sed -E 's/\\\\/\\/g'
}

TOOL_NAME=$(extract_json_string "tool_name")
FILE_PATH=$(extract_json_string "file_path")

if [ -z "$TOOL_NAME" ] || [ -z "$FILE_PATH" ]; then
  echo "[pretooluse-protected-path.sh] BLOCKED: could not extract tool_name/file_path from hook input -- failing closed, not silently allowing." >&2
  exit 2
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$SCRIPT_DIR/../../.." && pwd)}"

# Reduce an absolute file_path to a repo-relative path. This matters:
# check-protected-paths.sh's directory-style tokens (ending in "/",
# e.g. "ai-engineering/checks/") match by PREFIX, so an absolute path
# like "/d/repo/ai-engineering/checks/foo.sh" would never match
# "ai-engineering/checks/" without this step -- only exact-file tokens
# (which match by suffix) would still work on an absolute path. Known
# limitation: if the prefix-strip below can't confidently recognize
# REPO_ROOT as a prefix (e.g. a drive-letter casing mismatch on
# Windows), it falls back to the path as-is, and directory tokens may
# then fail to match while exact-file tokens still would.
REPO_ROOT_NORM=$(printf '%s' "$REPO_ROOT" | tr '\\' '/')
FILE_PATH_NORM=$(printf '%s' "$FILE_PATH" | tr '\\' '/')
# Case-insensitive, to match the PowerShell twin's OrdinalIgnoreCase
# comparison -- reviewer finding M3: without this, the two "twins"
# could reach different pass/fail decisions on a drive-letter-casing
# or path-casing mismatch on the same host. `nocasematch` makes the
# `case` match itself case-insensitive but -- confirmed by direct
# testing, not assumed -- does NOT extend to `${var#pattern}` removal,
# so the actual strip uses a length-based substring instead once the
# case-insensitive prefix match confirms it's safe to do so.
shopt -s nocasematch
case "$FILE_PATH_NORM" in
  "$REPO_ROOT_NORM"/*)
    REL_PATH="${FILE_PATH_NORM:$(( ${#REPO_ROOT_NORM} + 1 ))}"
    ;;
  *)
    REL_PATH="$FILE_PATH_NORM"
    ;;
esac
shopt -u nocasematch

RESULT=$(cd "$REPO_ROOT" && "$SCRIPT_DIR/../check-protected-paths.sh" --path "$REL_PATH" 2>&1)
STATUS=$?

if [ "$STATUS" -eq 0 ]; then
  exit 0
fi

if [ "$STATUS" -ne 1 ]; then
  echo "[pretooluse-protected-path.sh] BLOCKED: check-protected-paths.sh exited unexpectedly ($STATUS) -- failing closed. Output: $RESULT" >&2
  exit 2
fi

MATCHED_LINE=$(printf '%s\n' "$RESULT" | grep "PROTECTED PATH TOUCHED" | head -1)

if [ -n "${AI_ENGINEERING_PROTECTED_PATH_OVERRIDE:-}" ]; then
  echo "[pretooluse-protected-path.sh] OVERRIDE ACTIVE (AI_ENGINEERING_PROTECTED_PATH_OVERRIDE is set): allowing $TOOL_NAME on protected path '$REL_PATH'. $MATCHED_LINE" >&2
  exit 0
fi

echo "[pretooluse-protected-path.sh] BLOCKED: $MATCHED_LINE. AGENTS.md's Protected assets rule requires a distinct explanation, independent review, and explicit human approval (Controlled lane) before this proceeds. To proceed anyway, a human must deliberately set AI_ENGINEERING_PROTECTED_PATH_OVERRIDE=1 for this session -- see ai-engineering/policies/protected-assets.md." >&2
exit 2
