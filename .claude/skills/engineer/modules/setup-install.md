# Module: setup-install

Second of three sequential setup modules (preflight -> install -> configure). Run only after `setup-preflight.md` ends `DONE_VERIFIED` and the human-approval gate has passed. Absorbs SETUP.md's "Step 2: Install the starter kit." SETUP.md remains the human-readable walkthrough; this module is the canonical agent-executable version.

## Parameters

- `{TargetPath}`, `{FrameworkSourcePath}` — carried over from `setup-preflight.md`.
- `{InstallVerdict}` — `FRESH_INSTALL` / `UPGRADE` / `PARTIAL_PREVIOUS_INSTALL`, carried over from `setup-preflight.md`'s target inspection. Drives which rows of the conflict matrix below are actually exercised: a `FRESH_INSTALL` hits no conflicts at all; `UPGRADE` and `PARTIAL_PREVIOUS_INSTALL` hit them by definition.

## Procedure

Copy `AGENTS.md`, `CLAUDE.md`, `ai-engineering/`, and the framework-owned parts of `.claude/` (see matrix) from `{FrameworkSourcePath}` to `{TargetPath}`, using one of:

- **Manual copy** — copy each item per its row in the matrix below.
- **Installer script** — `scripts/install-to-project.ps1 -TargetPath {TargetPath}` (PowerShell) or `scripts/install-to-project.sh {TargetPath}` (bash), run from `{FrameworkSourcePath}`. The script already walks files individually and merges into existing destination directories rather than nesting; it never touches non-framework-owned `.claude/` content and never auto-overwrites `.claude/settings.json`.

### Conflict matrix

`.claude/` is **not atomic** — it routinely mixes framework-owned and project-owned content (custom skills, agents, local settings, IDE config). Mixed ownership is the norm on any target that isn't a brand-new project, not an edge case to special-case around. Decide per subpath, never per top-level directory:

| Subpath | Rule |
|---|---|
| `AGENTS.md`, `CLAUDE.md` | If the file still has unconfigured bracketed placeholders (`[PROJECT NAME]` etc.) — back up, then replace. If it has been locally edited (placeholders filled, or content diverges from the framework's shipped version beyond placeholder substitution) — `MERGE_REVIEW_REQUIRED`: back up, do not silently replace, surface the diff for human merge. |
| `.claude/settings.json` | Merge: union the `permissions.deny` rules from source into target. Never remove or loosen an existing target rule to make room for a source rule. Never auto-apply — this always needs a human look even though it's a mechanical union. |
| `.claude/skills/<framework-owned>` — currently `engineer/`, `redteam/`, `engineering-workflow/` | Replace file-by-file (back up first if `{InstallVerdict}` is `UPGRADE`/`PARTIAL_PREVIOUS_INSTALL`). These are named explicitly because "framework-owned" is not visually obvious from the skill name alone. |
| `.claude/agents/independent-reviewer.md`, `.claude/rules/engineering.md`, `.claude/rules/security.md` | Replace file-by-file, back up first — these are framework-owned singletons, same treatment as the skills above. |
| `.claude/` anything else (other skills, other agents, `launch.json`, `settings.local.json`, IDE-generated files, etc.) | Never touch. Not framework-owned; do not read intent into it. |
| `ai-engineering/**` | Replace file-by-file — this is framework-owned canon, not project content. Back up first. |
| Anything else encountered under `{TargetPath}` during install that doesn't match a row above | Stop and ask. Do not guess a bucket for it. |

### Reporting

Report every item as installed, skipped (pre-existing, no `-Overwrite`), backed-up-then-replaced, `MERGE_REVIEW_REQUIRED`, or stopped-for-decision — matching the bucket it fell into above, not a generic "conflict."

## Completion

End with one status:

- `DONE_VERIFIED` — everything installed cleanly per the matrix; nothing fell into `MERGE_REVIEW_REQUIRED` or "stop and ask."
- `CONDITIONAL_PASS` — some items were skipped as pre-existing-and-unconfigured or backed-up-then-replaced with no ambiguity; list which.
- `NEEDS_HUMAN` — anything landed in `MERGE_REVIEW_REQUIRED` (locally-edited `AGENTS.md`/`CLAUDE.md`), the `.claude/settings.json` union needs a human look, or the walk hit a path outside the matrix.
- `ENVIRONMENT_UNAVAILABLE` — source or target path unreachable, or the installer script is missing/fails.

## Human-approval gate

Do not proceed to `setup-configure.md` until the user has reviewed the installed/skipped/backed-up file list above, especially anything requiring manual merge.
