#!/usr/bin/env bash
# Shared evidence-field vocabulary and colon-list detector for
# ai-engineering/core/verification.md's "Evidence format" (Command or
# procedure / Result / Pass or fail / Evidence location / Remaining
# risk). Extracted out of check-verification-report.sh so that script
# and the Stop hook's check-stop-evidence.sh check the same five field
# names from one place, per BACKLOG-v1.2 Item 6. Sourced, not run
# directly -- it defines FIELDS and check_colon_list only.
#
# The markdown-table detection logic (check_table in
# check-verification-report.sh) is NOT shared here: it hardcodes the
# five names in a header-row regex rather than looping over FIELDS, and
# a Stop hook checking prose in a chat message has no reason to expect
# a markdown table shape.

FIELDS=("Command or procedure" "Result" "Pass or fail" "Evidence location" "Remaining risk")

check_colon_list() {
  local file="$1"
  local found=0
  local problem=0
  for field in "${FIELDS[@]}"; do
    # Match "Field:" at line start, optionally with leading ">" (blockquote) or "- " (list), then require non-whitespace after the colon.
    if grep -qiE "^[[:space:]>*-]*${field}:[[:space:]]*$" "$file"; then
      echo "  MISSING VALUE: '$field:' present but empty in $file"
      problem=1
      found=1
    elif grep -qiE "^[[:space:]>*-]*${field}:[[:space:]]*[^[:space:]]" "$file"; then
      found=1
    fi
  done
  [ "$found" -eq 1 ] && [ "$problem" -eq 0 ] && return 0
  [ "$found" -eq 1 ] && return 2
  return 1
}
