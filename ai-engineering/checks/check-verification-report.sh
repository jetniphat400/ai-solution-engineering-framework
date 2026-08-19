#!/usr/bin/env bash
# Checks that a verification report has all five required evidence
# fields present and non-empty, per ai-engineering/core/verification.md's
# "Evidence format" (Command or procedure / Result / Pass or fail /
# Evidence location / Remaining risk).
#
# What this does NOT do: verify the evidence is true, verify a cited
# evidence location exists, or detect a check that silently never ran.
# It also only recognizes two shapes -- a colon-list ("Field: value")
# or a markdown table with all five field names as column headers
# (ai-engineering/templates/VERIFICATION-REPORT.template.md's shape).
# Evidence recorded any other way (e.g. inline prose in an issue
# register) is invisible to this tool -- that is a known limitation,
# not something this script tries to guess at.
set -euo pipefail

STRICT=0
FILES=()
for arg in "$@"; do
  case "$arg" in
    --strict) STRICT=1 ;;
    *) FILES+=("$arg") ;;
  esac
done

if [ "${#FILES[@]}" -eq 0 ]; then
  while IFS= read -r -d '' f; do
    FILES+=("$f")
  done < <(find . -iname "*VERIFICATION-REPORT*.md" -not -iname "*.template.md" -not -path "*/.git/*" -print0 2>/dev/null)
fi

if [ "${#FILES[@]}" -eq 0 ]; then
  echo "No VERIFICATION-REPORT-shaped files found."
  exit 0
fi

FIELDS=("Command or procedure" "Result" "Pass or fail" "Evidence location" "Remaining risk")
ANY_PROBLEM=0

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

check_table() {
  local file="$1"
  local header_line
  header_line=$(grep -niE "^\|.*Command or procedure.*\|.*Result.*\|.*Pass or fail.*\|.*Evidence location.*\|.*Remaining risk.*\|" "$file" | head -1) || true
  [ -z "$header_line" ] && return 1

  local header_lineno
  header_lineno=$(grep -niE "^\|.*Command or procedure.*\|.*Result.*\|.*Pass or fail.*\|.*Evidence location.*\|.*Remaining risk.*\|" "$file" | head -1 | cut -d: -f1)
  local problem=0
  local rows=0
  local total_lines
  total_lines=$(wc -l < "$file")
  local lineno=$((header_lineno + 2)) # skip header + separator row
  while [ "$lineno" -le "$total_lines" ]; do
    local row
    row=$(sed -n "${lineno}p" "$file")
    case "$row" in
      \|*) ;;
      *) break ;;
    esac
    rows=$((rows + 1))
    # Split on | and count non-empty (post-trim) cells, excluding the leading/trailing empty from the outer pipes.
    local cellcount
    cellcount=$(echo "$row" | awk -F'|' '{
      n=0
      for (i=2; i<NF; i++) {
        cell=$i
        gsub(/^[ \t]+|[ \t]+$/, "", cell)
        if (length(cell) > 0) n++
      }
      print n
    }')
    if [ "$cellcount" -lt 5 ]; then
      echo "  EMPTY CELL(S): row $lineno of $file has only $cellcount/5 non-empty fields: $row"
      problem=1
    fi
    lineno=$((lineno + 1))
  done
  if [ "$rows" -eq 0 ]; then
    echo "  TABLE FOUND BUT NO CHECK ROWS: $file's evidence table has a header but no entries"
    return 2
  fi
  [ "$problem" -eq 1 ] && return 2
  return 0
}

for file in "${FILES[@]}"; do
  echo "Checking: $file"
  # Initialize to 0 (success) -- `||` only overwrites on actual failure,
  # so a genuine success must not be pre-set to a failure sentinel.
  colon_status=0
  table_status=0
  # `|| var=$?` (not `; var=$?`) is required here -- under `set -e`, a
  # bare non-zero-returning function call at top level aborts the whole
  # script before the exit code is ever captured; `||` is exempt.
  check_colon_list "$file" || colon_status=$?
  if [ "$colon_status" -eq 1 ]; then
    check_table "$file" || table_status=$?
  fi
  if [ "$colon_status" -eq 1 ] && [ "$table_status" -eq 1 ]; then
    echo "  NO RECOGNIZED EVIDENCE BLOCK: neither a colon-list nor the template's table shape was found. This tool cannot see evidence recorded any other way (e.g. inline prose)."
    ANY_PROBLEM=1
  elif [ "$colon_status" -eq 2 ] || [ "$table_status" -eq 2 ]; then
    ANY_PROBLEM=1
  else
    echo "  OK: all five evidence fields present and non-empty."
  fi
done

if [ "$ANY_PROBLEM" -eq 1 ] && [ "$STRICT" -eq 1 ]; then
  exit 1
fi
exit 0
