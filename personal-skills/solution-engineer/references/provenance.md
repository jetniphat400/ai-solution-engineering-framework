# Reference: provenance

Every rule in `SKILL.md` traces to a file in this framework's own repo.
This file records that attribution, section by section, plus the full
rationale text for the four places where `SKILL.md` extends canon
rather than restating it verbatim. This skill was derived fresh from
framework canon after an earlier externally-prototyped draft was lost —
not reconstructed from memory of the lost draft.

## Degradation rule

Not a carve-out invented for this skill — it's a direct application of
`ai-engineering/policies/instruction-authority.md`'s existing
resolution order, which ranks "Repository-specific instructions"
(tier 5) above "Specialist skill or plugin" (tier 8). This skill *is*
a tier-8 specialist skill; a target's own `AGENTS.md` is tier-5
repository-specific instruction. Tier 5 already outranks tier 8 —
deferring to it is what the existing order requires, not a new rule.

## DETECT — monorepo scoping (extension)

This scoping rule has no direct precedent in this framework's core
canon, which doesn't discuss monorepos; it extends
`ai-engineering/policies/risk-classification.md`'s existing
"local... vs. multiple files or integrations" blast-radius framing to
name package/module boundaries explicitly. Flagged here as this
skill's own extension, not restated canon.

## DETECT — numeric Fast criteria (extension)

These numbers are **not** in `ai-engineering/policies/
processing-lanes.md` — that file's Fast Lane criteria are qualitative
("small, clear, low-risk... describable in one sentence"). The specific
thresholds were supplied as an explicit design requirement for this
skill, not inferred from canon or invented unprompted. Flagged here,
not silently presented as pre-existing framework canon.

## DETECT — floor-rate / Standard / Controlled / "when uncertain, escalate"

- Floor-rate override: `ai-engineering/policies/risk-classification.md:7-12`
- Controlled Lane requirements: `ai-engineering/policies/processing-lanes.md`
- "When uncertain, escalate": `ai-engineering/policies/processing-lanes.md`

## Mid-task reclassification (extension)

Canon frames classification as an intake-time activity — one of
`ai-engineering/core/workflow.md`'s Phase 1 tasks. It doesn't
separately state that a classification must be revisited mid-task.
This rule extends `ai-engineering/policies/processing-lanes.md`'s
"when uncertain, escalate" principle from an intake-only rule to a
continuous one. Flagged as this skill's own extension.

## User overrides / status honesty (extension)

Not restated verbatim from canon — it extends
`ai-engineering/core/verification.md`'s "Prohibited verification
manipulation" list, which prohibits gaming a check to make it look
passed, to the adjacent case of a user-requested skip. Canon's list
doesn't explicitly name this case; flagged as this skill's own
extension of that principle.

## Verification

- Minimum verification requirements: `ai-engineering/core/verification.md:3-11`
- Evidence format: `ai-engineering/core/verification.md:26-38`
- Prohibited verification manipulation: `ai-engineering/core/verification.md:50-54`
- Claim confidence in flight: `ai-engineering/core/verification.md:40-48`

## Terminal statuses

Source: this framework's own `AGENTS.md:117-127` — inlined in
`SKILL.md` because a zero-install target has no `AGENTS.md` of its own
to point at.

The `SECURITY_BLOCKED`/`NEEDS_HUMAN` disambiguation: this skill's own
S2 scratch-repo test flagged this exact ambiguity as a judgment call;
cross-agent testing later confirmed it as a real, recurring gap, not a
one-off — see `docs/field-tests/2026-08-19-cross-agent-contract-test.md`.

## Gates

- Gates (investigation / study-only / decision): `ai-engineering/core/workflow.md`'s "Gates: investigation, study-only, decision" section. The local status legend and crosswalk table this used to also cite was retired 2026-08-26 — see `docs/field-tests/2026-08-26-status-vocabulary-study.md` for the study and decision, and `CHANGELOG.md` for which files predate the change.

## Protected assets and human approval

- Protected-by-default list: `ai-engineering/policies/protected-assets.md`
- Approval routing table: `ai-engineering/policies/approval-matrix.md`

## Instruction authority

Source: `ai-engineering/policies/instruction-authority.md`

## Redteam

Source: `ai-engineering/core/redteam.md`
