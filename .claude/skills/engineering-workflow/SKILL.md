---
name: engineering-workflow
description: Apply the repository's user-centered nine-phase engineering workflow for new projects, existing codebases, features, bugs, refactoring, modernization, architecture decisions, verification, and release planning. Use for any non-trivial software change that requires discovery, design, planning, implementation, testing, review, or deployment evidence.
---

Read `ai-engineering/core/workflow.md` — that file is the nine-phase rule set. The `engineer` skill's ROUTE table routes `bug`/`feature`/`refactor` task types to it after DETECT/PROPOSE; this file is a thin, directly-invocable alias so `/engineering-workflow` keeps working standalone under the name external docs (`SETUP.md`) reference — it does not duplicate the nine phases or their return paths.

Also read `AGENTS.md` and the relevant files under `ai-engineering/policies/` for lane, risk, and protected-asset rules before proposing a design.
