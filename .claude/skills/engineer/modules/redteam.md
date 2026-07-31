# Module: redteam

Executor for red-team review. The rules (attack surfaces, modes, severity/release gates, universal coverage rule) live in `ai-engineering/core/redteam.md` — this module does not restate them, only how to run them.

Do not edit files during this review. Use a fresh context.

## 1. Determine the mode

If the parent `/engineer` DETECT/PROPOSE already ran, or the mode was given explicitly (e.g. `/engineer redteam code`, `/redteam design`), use it directly — no re-detection needed.

Otherwise, infer the mode from the artifact under review:

- A plan, spec, or proposal with no implementation yet -> plan mode (premortem).
- A diff or existing implementation -> code mode (STRIDE + DREAD).
- An architecture or design document before code exists -> design mode (attack trees).

If the artifact type is genuinely ambiguous, ask which mode applies rather than guessing.

## 2. Propose before running

State: the artifact under review, the mode (with confidence and evidence if inferred), and which attack surfaces from `ai-engineering/core/redteam.md` apply. Confirm before running the review — this mirrors the parent skill's PROPOSE discipline even when this module is entered directly via `/redteam`.

## 3. Run

Follow the active mode's procedure from `ai-engineering/core/redteam.md` exactly. Attempt every applicable attack surface; record "no finding" explicitly where nothing surfaces. Every finding needs evidence — file:line where the artifact has line-addressable content.

## 4. Report

Fill `ai-engineering/templates/REDTEAM-REPORT.template.md`, including the Mode and Surfaces-attempted fields. Apply the Severity and release rules from `ai-engineering/core/redteam.md` to reach one release recommendation: PASS, CONDITIONAL PASS, or FAIL.

## Relationship to `.claude/skills/redteam/`

`.claude/skills/redteam/` is the pre-existing direct-invocation entry point (`/redteam`). It now delegates its execution to this module rather than duplicating the run procedure — see that file for the one-line pointer. Both entry points converge here so the run procedure exists in exactly one place.
