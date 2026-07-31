---
name: redteam
description: Perform a read-only adversarial review of requirements, user outcome, architecture, security, data integrity, operations, supply chain, and agent behavior. Use when the user requests red-team analysis, before high-risk design approval, before Standard or Controlled Lane release, or when review finds material uncertainty.
---

Run `.claude/skills/engineer/modules/redteam.md` — that module is the executor (mode selection, run procedure, reporting) and the rules live in `ai-engineering/core/redteam.md`. This file is a thin, directly-invocable alias so `/redteam` keeps working standalone; it does not duplicate the run procedure or the rules.

Also read `ai-engineering/core/security.md` and the relevant specification, plan, diff, tests, and deployment artifacts.
