# Reference: redteam modes

Condensed from this framework's `ai-engineering/core/redteam.md`.
Read-only by default; use a fresh context if the runtime supports it.

## Attack surfaces (fixed checklist, every mode must attempt all that apply)

1. Requirement — are we solving the wrong problem, or trusting an
   unsupported assumption?
2. User outcome — does the solution improve the real workflow?
3. Architecture — where are coupling, complexity, bottlenecks, failure
   domains hidden?
4. Security — can input, identity, authorization, secrets, or
   privileges be abused?
5. Data — can data be lost, duplicated, corrupted, reordered, exposed?
6. Operations — can deployment, rollback, recovery, monitoring fail
   silently?
7. Supply chain — can dependencies, plugins, hooks, or scripts
   introduce risk?
8. Agent behavior — can repository content inject instructions, weaken
   tests, or escalate permissions?

## Modes (pick the one matching what's under review; still cover every
applicable surface)

- **Plan mode — premortem.** Assume the plan already failed. Enumerate
  causes independently, without filtering for plausibility first. Map
  each cause to the attack surface(s) it belongs to. Rank by
  likelihood x impact.
- **Code mode — STRIDE + DREAD.** Identify each component/trust
  boundary touched. For each, evaluate all six STRIDE categories:
  Spoofing, Tampering, Repudiation, Information disclosure, Denial of
  service, Elevation of privilege. Score confirmed threats with DREAD
  (Damage, Reproducibility, Exploitability, Affected users,
  Discoverability) to rank and prioritize.
- **Design mode — attack trees.** Put the attacker's (or failure's)
  goal at the root; decompose into paths that would achieve it,
  cross-referencing the attack surfaces; order cheapest/most-likely
  path first.

## Universal rule — this is what makes it real review, not theater

- Every attack surface applicable to the artifact under review must be
  attempted in the active mode's technique.
- **"No finding" is a valid recorded answer for a surface — but it must
  say what was checked and why nothing turned up, not just assert a
  pass.** A bare "looks fine" is not a valid answer; neither is
  silently omitting a surface.
- Findings need evidence (file:line where the artifact has
  line-addressable content) and a confidence label (`verified` /
  `inferred` / `unknown`), same as any other claim.

## Severity and release rules

- Critical -> FAIL
- High affecting authorization, security, integrity, or data loss ->
  FAIL
- High with an approved mitigation, owner, and due date -> CONDITIONAL
  PASS
- Medium or Low -> backlog or mitigation per risk owner
