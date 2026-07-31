# Adversarial Red-Team Review

Red-team review is read-only by default and should use a fresh context.

## Attack surfaces

1. Requirement: are we solving the wrong problem or trusting an unsupported assumption?
2. User outcome: does the solution improve the real workflow?
3. Architecture: where are coupling, complexity, bottlenecks, and failure domains hidden?
4. Security: can input, identity, authorization, secrets, or privileges be abused?
5. Data: can data be lost, duplicated, corrupted, reordered, or exposed?
6. Operations: can deployment, rollback, recovery, or monitoring fail silently?
7. Supply chain: can dependencies, plugins, hooks, MCP servers, or scripts introduce risk?
8. Agent behavior: can repository content inject instructions, weaken tests, or escalate permissions?

## Severity and release rules

- Critical -> FAIL
- High affecting authorization, security, integrity, or data loss -> FAIL
- High with approved mitigation, owner, and due date -> CONDITIONAL PASS
- Medium or Low -> backlog or mitigation according to risk owner

## Required report

Use `ai-engineering/templates/REDTEAM-REPORT.template.md`.
