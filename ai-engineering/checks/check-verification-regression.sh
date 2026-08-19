#!/usr/bin/env bash
# Mechanizes the cheap, common cases from
# ai-engineering/core/verification.md's "Prohibited verification
# manipulation" list: a test-count drop, and syntactic patterns
# associated with weakening a check (suppression comments added,
# assertion-like lines removed with no replacement).
#
# This is a tripwire for shortcuts, NOT a semantic verifier. It
# CANNOT: distinguish a legitimate test removal (dead code deleted,
# its test correctly went too) from a manipulative one; catch a
# weakened check that doesn't touch recognizable assert/expect syntax
# (e.g. a business-logic threshold changed elsewhere, not the test);
# or judge test quality -- a suite can hold its count and still
# degrade into no-ops. A flag here means "a human should look," not
# "manipulation confirmed."
#
# Usage:
#   check-verification-regression.sh --test-count-cmd "CMD" \
#     --baseline-file PATH [--diff-ref REF] [--update-baseline] [--advisory]
#
# --test-count-cmd: a shell command that prints a single integer (the
#   test count) to stdout. This script does not parse any test
#   framework's own output format -- shaping that command to emit a
#   bare number is the calling project's responsibility, since no
#   single format works across ecosystems (pytest, jest, go test, ...).
set -euo pipefail

TEST_COUNT_CMD=""
BASELINE_FILE=""
DIFF_REF=""
UPDATE_BASELINE=0
ADVISORY=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --test-count-cmd) TEST_COUNT_CMD="$2"; shift 2 ;;
    --baseline-file) BASELINE_FILE="$2"; shift 2 ;;
    --diff-ref) DIFF_REF="$2"; shift 2 ;;
    --update-baseline) UPDATE_BASELINE=1; shift ;;
    --advisory) ADVISORY=1; shift ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

PROBLEM=0

# --- Test-count regression ---
if [ -n "$TEST_COUNT_CMD" ] && [ -n "$BASELINE_FILE" ]; then
  # First integer in the output only -- not a strip-and-concatenate of
  # every digit, which would mangle output containing more than one
  # number (e.g. pytest's "219 tests collected in 5.10s" would become
  # "219510" under a naive tr -dc '0-9').
  CURRENT_COUNT=$(eval "$TEST_COUNT_CMD" | grep -oE '[0-9]+' | head -1)
  if [ -z "$CURRENT_COUNT" ]; then
    echo "WARNING: --test-count-cmd produced no parseable integer; skipping test-count regression check."
  elif [ ! -f "$BASELINE_FILE" ]; then
    echo "No baseline file at $BASELINE_FILE yet -- recording current count ($CURRENT_COUNT) as the new baseline."
    mkdir -p "$(dirname "$BASELINE_FILE")"
    echo "$CURRENT_COUNT" > "$BASELINE_FILE"
  else
    BASELINE_COUNT=$(grep -oE '[0-9]+' "$BASELINE_FILE" | head -1)
    echo "Test count: baseline=$BASELINE_COUNT current=$CURRENT_COUNT"
    if [ "$CURRENT_COUNT" -lt "$BASELINE_COUNT" ]; then
      echo "REGRESSION: test count dropped from $BASELINE_COUNT to $CURRENT_COUNT."
      PROBLEM=1
    fi
    if [ "$UPDATE_BASELINE" -eq 1 ] && [ "$CURRENT_COUNT" -ge "$BASELINE_COUNT" ]; then
      echo "$CURRENT_COUNT" > "$BASELINE_FILE"
      echo "Baseline updated to $CURRENT_COUNT."
    fi
  fi
else
  echo "No --test-count-cmd/--baseline-file given; skipping test-count regression check."
fi

# --- Manipulation-smell greps over the diff ---
if [ -n "$DIFF_REF" ]; then
  DIFF=$(git diff "$DIFF_REF" 2>/dev/null || true)
else
  DIFF=$(git diff --cached 2>/dev/null || true)
fi

if [ -n "$DIFF" ]; then
  SUPPRESSIONS=$(echo "$DIFF" | grep -cE '^\+.*(# *noqa|# *type: *ignore|# *pragma: *no *cover|eslint-disable|// *nolint)' || true)
  if [ "$SUPPRESSIONS" -gt 0 ]; then
    echo "SUPPRESSION COMMENT(S) ADDED: $SUPPRESSIONS line(s) in this diff add a lint/type/coverage suppression. A human should confirm this isn't hiding a real problem."
    PROBLEM=1
  fi

  REMOVED_ASSERTS=$(echo "$DIFF" | grep -cE '^-.*(assert |assert\(|expect\(|assertEqual|assertTrue|assertFalse|self\.assert)' || true)
  ADDED_ASSERTS=$(echo "$DIFF" | grep -cE '^\+.*(assert |assert\(|expect\(|assertEqual|assertTrue|assertFalse|self\.assert)' || true)
  if [ "$REMOVED_ASSERTS" -gt "$ADDED_ASSERTS" ]; then
    echo "ASSERTION(S) REMOVED WITH NO REPLACEMENT: $REMOVED_ASSERTS removed vs $ADDED_ASSERTS added assertion-like lines. A human should confirm this is a legitimate removal (e.g. dead code), not a weakened check."
    PROBLEM=1
  fi
else
  echo "No diff to scan for manipulation smells."
fi

if [ "$PROBLEM" -eq 1 ]; then
  echo "One or more heuristics fired. These are tripwires for human review, not proof of manipulation -- a legitimate reason may well exist. Document it (a committed justification), don't just disable this check."
  if [ "$ADVISORY" -eq 1 ]; then
    exit 0
  fi
  exit 1
fi

echo "No regression heuristics fired."
exit 0
