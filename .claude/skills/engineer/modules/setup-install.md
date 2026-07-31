# Module: setup-install

Second of three sequential setup modules (preflight -> install -> configure). Run only after `setup-preflight.md` ends `DONE_VERIFIED` and the human-approval gate has passed. Absorbs SETUP.md's "Step 2: Install the starter kit." SETUP.md remains the human-readable walkthrough; this module is the canonical agent-executable version.

## Parameters

- `{TargetPath}`, `{FrameworkSourcePath}` — carried over from `setup-preflight.md`.

## Procedure

Copy `AGENTS.md`, `CLAUDE.md`, `ai-engineering/`, and `.claude/` from `{FrameworkSourcePath}` to `{TargetPath}`, using one of:

- **Manual copy** — copy the four items directly.
- **Installer script** — `scripts/install-to-project.ps1 -TargetPath {TargetPath}` (PowerShell) or `scripts/install-to-project.sh {TargetPath}` (bash), run from `{FrameworkSourcePath}`.

Either way:

- Do not overwrite an existing `AGENTS.md`, `CLAUDE.md`, or `.claude/settings.json` in `{TargetPath}` without reviewing and merging the content first. The installer scripts default to skip-on-existing; pass their overwrite option only with explicit user approval, since it backs up and replaces files the target project already had.
- Report every item as installed, skipped (pre-existing), or backed-up-then-replaced.

## Completion

End with one status:

- `DONE_VERIFIED` — all four items installed cleanly, nothing pre-existing conflicted.
- `CONDITIONAL_PASS` — some items were skipped as pre-existing; list which, and that they need manual review/merge.
- `NEEDS_HUMAN` — a conflict needs a decision only the user can make (e.g. whether to overwrite a customized `.claude/settings.json`).
- `ENVIRONMENT_UNAVAILABLE` — source or target path unreachable, or the installer script is missing/fails.

## Human-approval gate

Do not proceed to `setup-configure.md` until the user has reviewed the installed/skipped/backed-up file list above, especially anything requiring manual merge.
