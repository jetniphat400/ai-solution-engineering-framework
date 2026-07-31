# Module: onboard-greenfield

Item 4 — greenfield mode. For a new project, the framework precedes
code: there is no existing codebase to map, so the agent joins at
discovery/design instead of archaeology, and the contract is an
*output* of that design work, not a form filled in retroactively once
code exists. Nothing here gets "retro-documented" — every field in
`AGENTS.md` and the issue register is written when the fact it
describes first becomes real, and stays empty until then.

## Parameters

- `{TargetPath}` — the new project's root (may not have a `.git` yet).

## Procedure

1. Route to `setup-preflight.md` for the git-baseline step (`git init`
   if none exists) — a restorable point still comes first, even with
   no code yet to protect.
2. Enter `ai-engineering/core/workflow.md` at **phase 2 (user and
   project discovery)**, not at implementation. There is no existing
   architecture to inspect, so discovery here is entirely about the
   user need, current process (if any), constraints, and desired
   outcome.
3. Continue into **phase 3 (problem definition)** and **phase 4
   (solution design and technology decision)** normally. Record every
   major decision — stack choice, architecture style, key trade-off —
   in an ADR (`ai-engineering/templates/ADR.template.md`) *as it is
   made*, not summarized after the fact.
4. Run `context-mapping.md` incrementally as design produces real
   facts, instead of once at the end:
   - Project identity, purpose, and project state (`GREENFIELD`)
     get filled as soon as they're decided — these come from the
     human/product decision, not the repo.
   - Architecture summary gets filled as phase 4 concludes, evidenced
     by the ADR(s) just written.
   - Project commands get filled only once the toolchain actually
     exists and each command has been run — before that, the
     placeholder stays a placeholder rather than a guess at what the
     command will eventually be.
   - Conventions get filled as the team agrees to them, not invented
     to fill the section early.
5. Initialize `ai-engineering/templates/ISSUES.template.md` empty,
   from day one — the register exists before there is anything to put
   in it, so the first real defect has somewhere to go immediately
   instead of triggering an "add the register" side-task later.
6. Proceed into phases 5 onward (plan, build, verify, release,
   observe) as normal `ai-engineering/core/workflow.md` phases once
   there is something to build.

## Completion

End with one status:

- `DONE_VERIFIED` — discovery through design complete, ADRs recorded,
  `AGENTS.md` and the issue register initialized to the current, real
  state (not pre-filled with guesses), ready to enter phase 5.
- `REQUIREMENT_AMBIGUOUS` — the user need or problem definition is
  still unclear; stay in phase 2/3 rather than proceeding to design.
- `NEEDS_HUMAN` — a technology or architecture decision needs owner
  approval before an ADR can be finalized.
