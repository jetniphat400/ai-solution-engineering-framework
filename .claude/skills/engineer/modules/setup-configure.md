# Module: setup-configure

Third of three sequential setup modules (preflight -> install -> configure). Run only after `setup-install.md` ends `DONE_VERIFIED` or `CONDITIONAL_PASS` and the human-approval gate has passed. Absorbs SETUP.md's "Step 3: Configure the repository contract." SETUP.md remains the human-readable walkthrough; this module is the canonical agent-executable version.

## Parameters

- `{TargetPath}` — carried over from the prior modules.

## Procedure

1. Open `{TargetPath}/AGENTS.md` and identify every bracketed placeholder: project name, purpose, project state, default risk, technical/business owner, project commands (install/run/build/format/lint/type-check/unit/integration/smoke), architecture summary, protected paths, **and conventions** — project-specific, human-approved constraints (naming, style, module layout, process rules already agreed by the team). `AGENTS.md`'s own "Required behavior #6" ("preserve valid repository conventions") assumes such conventions are recorded somewhere project-specific; this module's inventory now names that slot explicitly so it isn't filled in ad hoc, off-procedure, per install (friction #15).
2. For each placeholder, propose a value only where it is derivable from the repo with evidence (e.g., commands from `package.json`/`Makefile`/`pyproject.toml`), labeled `inferred` with the evidence cited. Never guess business-context fields (purpose, owners, default risk, conventions) — label those `unknown` and ask. Conventions in particular are rarely derivable from code alone (a lint config proves a rule is enforced, not that the team agreed to it) — default to asking rather than inferring.
3. Keep `AGENTS.md` concise; detailed procedures belong in `ai-engineering/`, not in the contract file itself.
4. Apply edits only after the human confirms each proposed and each unknown value.
5. Review `{TargetPath}/.claude/settings.json`: verify `permissions.deny` covers the project's actual sensitive paths (secrets, credentials, and anything named in `AGENTS.md`'s protected-paths field from step 1/4 above). Extend the deny list additively only — never remove, narrow, or loosen an existing rule, and never introduce a bypass or allow rule that weakens what's already denied. This step exists because reviewing/extending `.claude/settings.json` was previously outside this module's stated scope even though it is clearly part of "configuring the repository contract" in practice (friction #18); apply edits here only after human confirmation, same as step 4.

## Completion

End with one status:

- `DONE_VERIFIED` — every placeholder (including conventions) replaced and confirmed by the user, and `.claude/settings.json` deny rules reviewed against the confirmed protected paths.
- `REQUIREMENT_AMBIGUOUS` — an owner, risk level, protected-path list, or conventions set is still unclear after asking.
- `NEEDS_HUMAN` — a business-context field only the user can supply remains open, or the settings.json review surfaces a gap needing a human decision.

## Human-approval gate

This is the last module in the setup sequence. Once it ends `DONE_VERIFIED`, hand off to the normal `engineering-workflow` skill (or `/engineer` with a `bug`/`feature`/`refactor` task) for the first real piece of work — do not chain further setup automatically.
