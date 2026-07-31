# Skill Supply-Chain Policy

An external skill, plugin, or agent definition is a set of instructions
the agent will follow, not inert data. A compromised skill attacks the
agent's decisions directly — approvals, permissions, verification — which
makes it more dangerous than a compromised runtime dependency. Treat
skill adoption with at least the rigor applied to a new dependency with
elevated access.

## Rule

Not on the allowlist means do not load. This applies to skills, plugins,
and agent definitions from outside the project's own `ai-engineering/`
and adapter directories.

## Preflight audit checklist

Before adding a skill to the allowlist:

- Read the full `SKILL.md` (or equivalent definition), not a summary.
  Hunt for embedded directives that exfiltrate data, escalate
  permissions, or instruct the agent to bypass approval or verification.
- Audit every bundled script for network access, environment or
  credential access, and external process execution.
- Classify provenance tier: named team > starred community project >
  anonymous or unverifiable source. Lower tiers require more scrutiny,
  not a blanket ban.
- Pin the exact commit or version the audit covers.
- No auto-update. An update is a new artifact and requires re-audit
  before the pin is moved.

## Allowlist registry

| Name | Pinned commit | Audit date | Approver | Applicable phase |
|---|---|---|---|---|
| | | | | |

Add a row only after the preflight audit above is complete and a human
approver has signed off.
