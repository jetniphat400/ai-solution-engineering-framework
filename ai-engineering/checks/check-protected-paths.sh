#!/usr/bin/env bash
# Diffs changed files against the project's own AGENTS.md
# "Project-specific protected paths" block and flags any overlap.
# Mirrors AGENTS.md's "Protected assets" rule mechanically for the
# common case (a named file or directory) -- it cannot enforce a
# protection described only as a behavior with no extractable path.
#
# Usage:
#   check-protected-paths.sh [--advisory] [--ref REF] [--agents-file PATH] [--path PATH]
#
# Default mode diffs staged changes (git diff --cached --name-only) --
# suitable as a pre-commit hook. --ref diffs against a given ref
# instead (e.g. for CI, --ref origin/main). --path checks exactly one
# literal path with no git diff at all -- added for the PreToolUse hook
# wrapper (ai-engineering/checks/hooks/pretooluse-protected-path.sh),
# which is handed a single file path per tool call, not a diff. --path
# and --ref are mutually exclusive. This mode does not change the
# default or --ref behavior in any way -- both remain byte-for-byte
# what they were for existing manual/CI callers.
#
# What this does NOT do: verify a flagged change was actually approved
# (only that contact happened); reliably extract a protection described
# as prose with no file-shaped token in it; split a single line's
# "a.ext/b.ext"-looking compound token into two separate paths (a real,
# known limitation -- see README notes below); or treat a URL route
# pattern (anything starting with "/", e.g. "/api/trading/*") as a
# checkable file path -- those are discarded as non-file noise.
set -euo pipefail

ADVISORY=0
REF=""
AGENTS_FILE="AGENTS.md"
LITERAL_PATH=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --advisory) ADVISORY=1; shift ;;
    --ref) REF="$2"; shift 2 ;;
    --agents-file) AGENTS_FILE="$2"; shift 2 ;;
    --path) LITERAL_PATH="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [ -n "$LITERAL_PATH" ] && [ -n "$REF" ]; then
  echo "--path and --ref are mutually exclusive." >&2
  exit 2
fi

if [ ! -f "$AGENTS_FILE" ]; then
  echo "No $AGENTS_FILE found -- nothing to check against. Not an error: a repo with no AGENTS.md has no protected-paths list to enforce."
  exit 0
fi

# Isolate the fenced block after "Project-specific protected paths:".
BLOCK=$(awk '
  /^Project-specific protected paths:/ { flag=1; next }
  flag && /^```/ { fence++; if (fence==2) exit; next }
  flag && fence==1 { print }
' "$AGENTS_FILE")

if [ -z "$BLOCK" ]; then
  echo "No 'Project-specific protected paths' block found (or it is empty/still the [ADD PATHS] placeholder) in $AGENTS_FILE -- nothing to check against."
  exit 0
fi

TOKENS_RAW=$(
  while IFS= read -r line; do
    # Quoted phrases first (handles embedded spaces, e.g. "Stop PCC.bat").
    # `|| true` on both greps below is required, not decorative: under
    # `set -e`, a bare pipeline ending in "no match" (grep's normal,
    # expected exit 1 when a line has no quoted/path-shaped token) abo
    # rts this whole command substitution silently -- discovered as a
    # real, pre-existing bug: any AGENTS.md whose protected-paths block
    # has no extractable token (e.g. still the "[ADD PATHS]" placeholder)
    # made this script exit 1 with NO output at all, instead of the
    # "nothing to check against" message its own later exit-0 branch
    # documents. Fixed here rather than only worked around.
    echo "$line" | grep -oE '"[^"]+"' | sed -E 's/^"//; s/"$//' || true
    # Then bare path-shaped tokens from the line with quotes stripped out.
    stripped=$(echo "$line" | sed -E 's/"[^"]+"//g')
    echo "$stripped" | grep -oE '[A-Za-z0-9_./-]+\.[A-Za-z0-9]+|[A-Za-z0-9_./-]*/[A-Za-z0-9_./-]+' | sed -E 's/[,;:)]+$//' || true
  done <<< "$BLOCK"
)

# Discard anything that looks like a URL route (leading "/") rather than
# a repo-relative file path -- known non-file noise (e.g. "/api/trading/*"
# after its trailing "*" got stripped by the character class above).
TOKENS=()
while IFS= read -r tok; do
  [ -z "$tok" ] && continue
  case "$tok" in
    /*) continue ;;
  esac
  TOKENS+=("$tok")
done < <(echo "$TOKENS_RAW" | sort -u)

if [ "${#TOKENS[@]}" -eq 0 ]; then
  echo "No path-shaped tokens could be extracted from the protected-paths block -- nothing to check against. This does not mean the block is empty; it may describe protections this tool cannot parse into file paths."
  exit 0
fi

echo "Protected-path tokens recognized:"
for t in "${TOKENS[@]}"; do echo "  - $t"; done

if [ -n "$LITERAL_PATH" ]; then
  CHANGED="$LITERAL_PATH"
elif [ -n "$REF" ]; then
  CHANGED=$(git diff --name-only "$REF" 2>/dev/null || true)
else
  CHANGED=$(git diff --cached --name-only 2>/dev/null || true)
fi

if [ -z "$CHANGED" ]; then
  echo "No changed files to check."
  exit 0
fi

is_protected() {
  local file="$1" token
  for token in "${TOKENS[@]}"; do
    if [ "$file" = "$token" ]; then echo "$token"; return 0; fi
    case "$token" in
      */)
        case "$file" in "$token"*) echo "$token"; return 0 ;; esac
        ;;
      *)
        case "$file" in */"$token") echo "$token"; return 0 ;; esac
        ;;
    esac
  done
  return 1
}

FLAGGED=0
while IFS= read -r file; do
  [ -z "$file" ] && continue
  matched_token=""
  matched_token=$(is_protected "$file") || true
  if [ -n "$matched_token" ]; then
    echo "PROTECTED PATH TOUCHED: $file (matches: $matched_token)"
    FLAGGED=1
  fi
done <<< "$CHANGED"

if [ "$FLAGGED" -eq 1 ]; then
  echo "One or more changed files touch a protected path. AGENTS.md requires explicit human approval before this proceeds."
  if [ "$ADVISORY" -eq 1 ]; then
    exit 0
  fi
  exit 1
fi

echo "No protected-path contact detected in changed files."
exit 0
