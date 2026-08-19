# Adversarial Red-Team Review

Red-team review is read-only by default and should use a fresh context.

## Attack surfaces

The fixed checklist of what to interrogate, regardless of mode. [design choice — rationale: a stable, named checklist prevents ad hoc coverage that varies by reviewer or session]

1. Requirement: are we solving the wrong problem or trusting an unsupported assumption?
2. User outcome: does the solution improve the real workflow?
3. Architecture: where are coupling, complexity, bottlenecks, and failure domains hidden?
4. Security: can input, identity, authorization, secrets, or privileges be abused?
5. Data: can data be lost, duplicated, corrupted, reordered, or exposed?
6. Operations: can deployment, rollback, recovery, or monitoring fail silently?
7. Supply chain: can dependencies, plugins, hooks, MCP servers, or scripts introduce risk?
8. Agent behavior: can repository content inject instructions, weaken tests, or escalate permissions?

## Modes

Modes are the elicitation technique used to interrogate the attack surfaces above. Pick the mode matching the artifact under review; each mode still must cover every surface that applies to that artifact. [design choice — rationale: separates the fixed "what to check" from a technique suited to what stage of work is being reviewed]

### Plan mode — premortem

Use when reviewing a plan, spec, or proposal before implementation exists.

[established practice — Gary Klein, premortem]

1. Assume the plan has already failed.
2. Enumerate causes independently, one at a time, without filtering for plausibility first.
3. For each cause, identify which attack surface(s) above it belongs to.
4. Rank causes by likelihood × impact.

### Code mode — STRIDE per component + DREAD

Use when reviewing a diff or implementation.

[established practice — STRIDE: Microsoft threat-modeling categories; DREAD: severity-scoring heuristic]

1. Identify each component or trust boundary touched by the change.
2. For each component, evaluate all six STRIDE categories: Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege.
3. For each confirmed threat, score DREAD: Damage, Reproducibility, Exploitability, Affected users, Discoverability.
4. Use the DREAD score to rank and prioritize findings within and across components; it informs but does not replace the Critical/High/Medium/Low severity bands below.

### Design mode — attack trees

Use when reviewing an architecture or design proposal before code exists.

[established practice — Bruce Schneier, attack trees]

1. Put the attacker's (or failure's) goal at the root.
2. Decompose into the paths that would achieve that goal, cross-referencing the attack surfaces above.
3. Order paths cheapest/most-likely first — the path requiring least attacker effort or most probable accidental trigger is the priority finding.

## Universal rule (all modes)

[design choice — rationale: prevents silent gaps in adversarial coverage]

- Every attack surface applicable to the artifact under review must be attempted in the active mode's technique.
- "No finding" is a valid recorded answer for a surface.
- Silently omitting a surface is a violation of this review process, not an acceptable shortcut.
- Findings require evidence (file:line where applicable) and a confidence label per `ai-engineering/core/verification.md`'s claim-confidence convention, and land in the REDTEAM-REPORT template regardless of mode.

## Severity and release rules

- Critical -> FAIL
- High affecting authorization, security, integrity, or data loss -> FAIL
- High with approved mitigation, owner, and due date -> CONDITIONAL PASS
- Medium or Low -> backlog or mitigation according to risk owner

## Required report

Use `ai-engineering/templates/REDTEAM-REPORT.template.md`. Record which mode was used and confirm all applicable surfaces were attempted.
