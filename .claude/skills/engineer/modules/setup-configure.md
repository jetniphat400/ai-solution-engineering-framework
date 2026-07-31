# Module: setup-configure

Third of three sequential setup modules (preflight -> install -> configure). Run only after `setup-install.md` ends `DONE_VERIFIED` or `CONDITIONAL_PASS` and the human-approval gate has passed. Absorbs SETUP.md's "Step 3: Configure the repository contract." SETUP.md remains the human-readable walkthrough; this module is the canonical agent-executable version.

## Parameters

- `{TargetPath}` — carried over from the prior modules.

## Procedure

1. Open `{TargetPath}/AGENTS.md` and identify every bracketed placeholder: project name, purpose, project state, default risk, technical/business owner, project commands (install/run/build/format/lint/type-check/unit/integration/smoke), architecture summary, protected paths.
2. For each placeholder, propose a value only where it is derivable from the repo with evidence (e.g., commands from `package.json`/`Makefile`/`pyproject.toml`), labeled `inferred` with the evidence cited. Never guess business-context fields (purpose, owners, default risk) — label those `unknown` and ask.
3. Keep `AGENTS.md` concise; detailed procedures belong in `ai-engineering/`, not in the contract file itself.
4. Apply edits only after the human confirms each proposed and each unknown value.

## Completion

End with one status:

- `DONE_VERIFIED` — every placeholder replaced and confirmed by the user.
- `REQUIREMENT_AMBIGUOUS` — an owner, risk level, or protected-path list is still unclear after asking.
- `NEEDS_HUMAN` — a business-context field only the user can supply remains open.

## Human-approval gate

This is the last module in the setup sequence. Once it ends `DONE_VERIFIED`, hand off to the normal `engineering-workflow` skill (or `/engineer` with a `bug`/`feature`/`refactor` task) for the first real piece of work — do not chain further setup automatically.
