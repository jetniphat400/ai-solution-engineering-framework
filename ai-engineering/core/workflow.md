# Nine-Phase Engineering Workflow

[design choice — rationale: the specific split into nine phases and their boundaries is this framework's own structure, not one named external model. The general lifecycle it's built from — intake through production feedback — is established practice, tagged per phase below.]

## 1. Intake and governance
Classify project state, change type, risk, trust, processing lane, permission profile, and decision owners. [established practice — SDLC intake/governance gate]

## 2. User and project discovery
Understand the user need, current process, evidence, constraints, and project state. For existing systems, inspect architecture, conventions, dependencies, tests, delivery, and operational constraints. [established practice — SDLC / DevOps discovery stage; the user-need framing also draws on Jobs-to-be-Done / 5-Whys]

## 3. Problem definition and success criteria
Create a testable problem contract with scope, non-scope, assumptions, measurable outcomes, and acceptance criteria. [established practice — SDLC requirements definition / Definition of Ready]

## 4. Solution design and technology decision
Compare meaningful options. Select the simplest design that meets user, security, reliability, maintainability, and deployment needs. Record major decisions in an ADR. [established practice — SDLC design phase; ADR, Nygard 2011]

## 5. Engineering plan and baseline
Break work into small vertical slices. Identify files, interfaces, migrations, tests, risks, permissions, deployment, rollback, and definition of done. [established practice — SDLC planning phase / small-batch planning, Agile / XP]

## 6. Build in small batches
Implement one coherent slice, run focused checks, refactor, review the diff, and create a checkpoint before continuing. [established practice — Agile / XP small batches]

## 7. Verify, red-team, and independently review
Run deterministic checks, protect verification assets, challenge assumptions and failure modes, then use a fresh-context reviewer. [established practice — TDD / Definition of Done, combined with independent-review practice]

## 8. Release and deploy
Use a change record or pull request, CI, risk-based approval, controlled deployment, and smoke verification. [established practice — SDLC release phase / continuous delivery, Humble & Farley]

## 9. Observe, learn, and improve
Verify health and user outcomes. Roll back or contain failures. Feed findings into requirements, tests, architecture, policies, and backlog. [established practice — SDLC / DevOps feedback loop]

## Return paths

[design choice — rationale: this framework's own explicit re-entry map from failure mode to phase; not part of a named external model]

- Wrong user need -> phase 2
- Ambiguous success criteria -> phase 3
- Invalid architecture -> phase 4
- Plan or baseline gap -> phase 5
- Implementation defect -> phase 6
- Verification or review failure -> phase 6 or phase 4
- Deployment failure -> rollback, then phase 5 or 6
- Production outcome failure -> phase 2 through 4
