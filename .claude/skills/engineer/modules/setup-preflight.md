# Module: setup-preflight

First of three sequential setup modules (preflight -> install -> configure). Absorbs SETUP.md's "Step 1: Prepare the target repository." SETUP.md remains the human-readable walkthrough; this module is the canonical agent-executable version for `/engineer setup-install` — if the two ever diverge, this module governs for agent-driven installs.

## Parameters (supplied by the user, never hardcoded)

- `{TargetPath}` — the project the framework is being installed into.
- `{FrameworkSourcePath}` — where this framework's own repo lives.

### Topology

Three locations are potentially distinct and every one of them must be confirmed explicitly at run time — never default any of them to "the current repo":

1. **Agent cwd** — where this session is actually running from.
2. **`{FrameworkSourcePath}`** — where the framework's own repo lives.
3. **`{TargetPath}`** — the project being installed into.

The common case in practice is all three being different: the agent runs from the target project, the framework source is a separate checkout elsewhere, and neither coincides with the agent's cwd by default. Treat "agent is already running from the framework source" or "agent is already running from the target" as things to verify, not assume. Confirming `{TargetPath}`/`{FrameworkSourcePath}` once earlier in the conversation does not carry forward automatically — re-confirm both explicitly at the point this module actually executes, since a stale path from earlier in a long conversation (a relocated or version-bumped source, in particular) is a real and costly failure mode.

## Procedure

1. Confirm `{TargetPath}` with the user before touching anything in it — this is external, shared-repo territory, not the framework's own working tree.
2. Run `git status` in `{TargetPath}`.
   - Clean tree -> proceed.
   - Dirty tree -> stop; ask the user to commit or stash before continuing. Do not commit or stash on their behalf without explicit instruction.
   - No `.git` (new project) -> ask before running `git init`; it is reversible but still an action taken in a directory outside this framework's own repo.
3. Confirm `{FrameworkSourcePath}` exists and contains `AGENTS.md`, `CLAUDE.md`, `ai-engineering/`, and `.claude/`.
4. Inspect `{TargetPath}` for pre-existing framework artifacts and classify the scenario before any install decision is made:
   - Check for `AGENTS.md`, `CLAUDE.md`, `ai-engineering/`, and each framework-owned skill (`.claude/skills/engineer/`, `.claude/skills/redteam/`, `.claude/skills/engineering-workflow/`).
   - **`FRESH_INSTALL`** — none of the above present.
   - **`UPGRADE`** — all of the above present (a complete prior install), regardless of version.
   - **`PARTIAL_PREVIOUS_INSTALL`** — some present, some absent (e.g. `AGENTS.md`/`CLAUDE.md`/`ai-engineering/` copied but `.claude/skills/` never installed, or vice versa). This is not a hypothetical edge case — it is exactly what a manual, ad hoc, or interrupted prior install looks like in practice.
   - Report the verdict with the evidence (which specific artifacts were found/missing) — this verdict is `{InstallVerdict}`, carried forward as a parameter into `setup-install.md`, whose conflict-matrix decisions depend on it.

## Completion

End with one status:

- `DONE_VERIFIED` — clean tree (or fresh `git init` approved and done) in `{TargetPath}`, source root confirmed, target inspected and `{InstallVerdict}` reported.
- `NEEDS_HUMAN` — dirty tree, missing target path, ambiguous instruction on `git init`, or an ambiguous `PARTIAL_PREVIOUS_INSTALL` finding that needs the user's read before proceeding.
- `ENVIRONMENT_UNAVAILABLE` — git not available or `{TargetPath}`/`{FrameworkSourcePath}` unreachable.

## Human-approval gate

Do not proceed to `setup-install.md` until the user has confirmed `{TargetPath}`, `{FrameworkSourcePath}`, the `{InstallVerdict}`, and the preflight status above.
