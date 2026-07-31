# Module: setup-preflight

First of three sequential setup modules (preflight -> install -> configure). Absorbs SETUP.md's "Step 1: Prepare the target repository." SETUP.md remains the human-readable walkthrough; this module is the canonical agent-executable version for `/engineer setup-install` — if the two ever diverge, this module governs for agent-driven installs.

## Parameters (supplied by the user, never hardcoded)

- `{TargetPath}` — the project the framework is being installed into.
- `{FrameworkSourcePath}` — where this framework's own repo lives (defaults to the current repo if the agent is already running from it).

## Procedure

1. Confirm `{TargetPath}` with the user before touching anything in it — this is external, shared-repo territory, not the framework's own working tree.
2. Run `git status` in `{TargetPath}`.
   - Clean tree -> proceed.
   - Dirty tree -> stop; ask the user to commit or stash before continuing. Do not commit or stash on their behalf without explicit instruction.
   - No `.git` (new project) -> ask before running `git init`; it is reversible but still an action taken in a directory outside this framework's own repo.
3. Confirm `{FrameworkSourcePath}` exists and contains `AGENTS.md`, `CLAUDE.md`, `ai-engineering/`, and `.claude/`.

## Completion

End with one status:

- `DONE_VERIFIED` — clean tree (or fresh `git init` approved and done) in `{TargetPath}`, source root confirmed.
- `NEEDS_HUMAN` — dirty tree, missing target path, or ambiguous instruction on `git init`.
- `ENVIRONMENT_UNAVAILABLE` — git not available or `{TargetPath}`/`{FrameworkSourcePath}` unreachable.

## Human-approval gate

Do not proceed to `setup-install.md` until the user has confirmed `{TargetPath}`, `{FrameworkSourcePath}`, and the preflight status above.
