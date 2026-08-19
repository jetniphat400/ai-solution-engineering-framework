#!/usr/bin/env bash
# Lists non-framework-owned skills under .claude/skills/ and flags any
# with no corresponding row in ai-engineering/policies/skill-supply-chain.md's
# allowlist table. Advisory only -- this makes the gap visible and
# auditable, per that policy's own scoped proposal; it does not attempt
# real enforcement.
#
# What this does NOT do: verify a recorded pinned commit matches the
# skill's current on-disk content (no hash-checking -- likely
# adapter-specific and not attempted here); audit whether an
# allowlisted skill's content is actually safe (this is a paperwork
# presence check, not a security review); or see anything loaded from
# outside .claude/skills/ (a marketplace plugin, an MCP server) -- out
# of scope for this mechanical check even though the policy's own text
# covers that broader surface in prose.
set -euo pipefail

SKILLS_DIR=".claude/skills"
POLICY_FILE="ai-engineering/policies/skill-supply-chain.md"
FRAMEWORK_OWNED=("engineer" "redteam" "engineering-workflow")

if [ ! -d "$SKILLS_DIR" ]; then
  echo "No $SKILLS_DIR directory -- nothing to check."
  exit 0
fi

if [ ! -f "$POLICY_FILE" ]; then
  echo "No $POLICY_FILE found -- cannot cross-check an allowlist that doesn't exist. This itself is worth noting if the repo has a Full install."
  exit 0
fi

is_framework_owned() {
  local name="$1" f
  for f in "${FRAMEWORK_OWNED[@]}"; do
    [ "$name" = "$f" ] && return 0
  done
  return 1
}

# Registry rows: skip the header and separator lines, take the first
# pipe-delimited column (Name) from each remaining non-empty row.
REGISTERED=$(awk -F'|' '
  /^\| *Name *\|/ { header=1; next }
  header && /^\|[ -]+\|/ { next }
  header && NF > 1 {
    name=$2
    gsub(/^[ \t]+|[ \t]+$/, "", name)
    if (length(name) > 0) print name
  }
' "$POLICY_FILE")

UNREGISTERED=0
for dir in "$SKILLS_DIR"/*/; do
  [ -d "$dir" ] || continue
  name=$(basename "$dir")
  is_framework_owned "$name" && continue
  if echo "$REGISTERED" | grep -qxF "$name"; then
    echo "OK (registered): $name"
  else
    echo "UNREGISTERED SKILL: $name (present in $SKILLS_DIR, no row in $POLICY_FILE's allowlist)"
    UNREGISTERED=$((UNREGISTERED + 1))
  fi
done

if [ "$UNREGISTERED" -gt 0 ]; then
  echo "$UNREGISTERED unregistered skill(s) found. Advisory only -- per skill-supply-chain.md's own preflight audit checklist before adding a row, not a hard gate. A legitimately in-progress audit is not a failure."
fi
exit 0
