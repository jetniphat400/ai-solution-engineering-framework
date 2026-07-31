# Module: onboard-existing

For a project that already has a filled-in `AGENTS.md` and, usually,
an issue register — the contract already exists. This module's job is
mostly routing into the normal workflow, not archaeology; use
`onboard-inherited.md` instead if the contract turns out to be
missing or largely unfilled once you look.

## Parameters

- `{TargetPath}` — the existing project.

## Procedure

1. Read `{TargetPath}/AGENTS.md` and, if present,
   `ai-engineering/templates/ISSUES.template.md`'s populated instance
   for this project. If `AGENTS.md` turns out to still have
   unconfigured placeholders or there is no issue register at all,
   stop this module and switch to `onboard-inherited.md` — a contract
   that looks established but isn't is exactly the
   `PARTIAL_PREVIOUS_INSTALL` case `setup-preflight.md` names, not a
   case for this lighter module.
2. Verify staleness cheaply: for each recorded command in `AGENTS.md`'s
   project-commands section, confirm it still runs (per
   `context-mapping.md`'s rule that a command is only `verified` once
   actually run). Spot-check the architecture summary and protected
   paths against current repo structure. This is a cheap sanity pass,
   not a full re-mapping — if drift is substantial, escalate to
   `context-mapping.md` proper rather than patching fields ad hoc.
3. Classify the requested task (`bug` / `feature` / `refactor` /
   `review-redteam` / `release`) and its risk/lane per
   `ai-engineering/policies/risk-classification.md` and
   `processing-lanes.md`.
4. Hand off to `ai-engineering/core/workflow.md` for the classified
   task — this module does not duplicate the nine phases, it only
   gets the agent to the point of entering them with a trustworthy
   contract underneath.

## Completion

End with one status:

- `DONE_VERIFIED` — contract confirmed current, task classified,
  handed off to the workflow.
- `CONDITIONAL_PASS` — minor drift found and recorded, task classified,
  proceeding with the drift noted.
- `NEEDS_HUMAN` — the staleness check found the contract materially
  wrong (not just stale) and needs a human decision before proceeding.
- `REPLAN_REQUIRED` — the contract turned out unfilled enough that
  this module should not have been the entry point; switch to
  `onboard-inherited.md`.
