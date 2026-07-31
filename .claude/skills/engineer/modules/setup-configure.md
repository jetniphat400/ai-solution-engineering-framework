# Module: setup-configure

Third of three sequential setup modules (preflight -> install -> configure). Run only after `setup-install.md` ends `DONE_VERIFIED` or `CONDITIONAL_PASS` and the human-approval gate has passed. Absorbs SETUP.md's "Step 3: Configure the repository contract." SETUP.md remains the human-readable walkthrough; this module is the canonical agent-executable version.

## Parameters

- `{TargetPath}` — carried over from the prior modules.

## Procedure

1. Run `context-mapping.md` against `{TargetPath}/AGENTS.md`. That module is the canonical placeholder-filling procedure — every placeholder including `## Conventions`, evidence-backed confidence labels, the human-approval gate on `inferred`/`unknown` fields, and cross-checking human-supplied facts against the repo. This module sequences that procedure as its own step 1; it does not restate how it works.
2. Keep `AGENTS.md` concise; detailed procedures belong in `ai-engineering/`, not in the contract file itself.
3. Review `{TargetPath}/.claude/settings.json`: verify `permissions.deny` covers the project's actual sensitive paths (secrets, credentials, and anything named in the now-confirmed protected-paths field from step 1). Extend the deny list additively only — never remove, narrow, or loosen an existing rule, and never introduce a bypass or allow rule that weakens what's already denied. This step exists because reviewing/extending `.claude/settings.json` was previously outside this module's stated scope even though it is clearly part of "configuring the repository contract" in practice (friction #18); apply edits here only after human confirmation, same as `context-mapping.md`'s own gate.

## Completion

End with one status:

- `DONE_VERIFIED` — `context-mapping.md` ended `DONE_VERIFIED`, and `.claude/settings.json` deny rules reviewed against the confirmed protected paths.
- `REQUIREMENT_AMBIGUOUS` — `context-mapping.md` ended `REQUIREMENT_AMBIGUOUS` (an `unknown` field still open after asking).
- `NEEDS_HUMAN` — `context-mapping.md` ended `NEEDS_HUMAN`, or the settings.json review surfaces a gap needing a human decision.

## Human-approval gate

This is the last module in the setup sequence. Once it ends `DONE_VERIFIED`, hand off to the normal `engineering-workflow` skill (or `/engineer` with a `bug`/`feature`/`refactor` task) for the first real piece of work — do not chain further setup automatically.
