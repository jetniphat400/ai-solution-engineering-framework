---
name: engineer
description: Single user-facing entry point for the AI engineering framework. Detects project scenario and task type from evidence, proposes a route and processing lane with confidence labels, waits for human confirmation, then loads only the module needed for the task. Use this as the default way to start any framework-governed piece of work; use a specific mode invocation (e.g. "/engineer redteam code") to skip detection when the task is already known.
---

Invocation: this skill is discovered automatically from this file's frontmatter, the same convention the `redteam` and `engineering-workflow` skills use — no separate `.claude/commands/` entry exists in this repo. Invoke as `/engineer` for full detection, or `/engineer <mode> [submode]` (e.g. `/engineer redteam code`, `/engineer setup-install`) to skip detection and jump straight to a module.

## Purpose

Collapse the framework's interface to one entry point without collapsing its modular backend. This skill only detects, proposes, and routes. It never contains task-execution rules itself — those live in `ai-engineering/core/`, in `ai-engineering/policies/`, and in the modules under `modules/`.

## DETECT

Every claim carries a confidence label — `verified` (directly observed), `inferred` (derived from indirect signals), or `unknown` — plus the evidence behind it. Never silently upgrade `inferred` to `verified`.

### Scenario: greenfield / existing / inherited

Signals to check, all evidence-based:

- Git history presence and continuity vs. codebase size — a large codebase with a shallow or absent history suggests inherited work, not greenfield.
- Whether `AGENTS.md` is present and its placeholders are filled in vs. still bracketed.
- Docs-vs-code agreement — do README/architecture docs describe what the code actually does, or has it drifted (a sign of inherited, under-maintained work)?
- Presence of lockfiles and tests — their absence in an otherwise substantial codebase suggests inherited work without engineering hygiene, not a fresh project.

### Task type

Read directly from the user's request: `bug` / `feature` / `refactor` / `review-redteam` / `onboard` / `setup-install` / `release`. This is normally `verified` — it's what the user asked for in their own words — unless the request is ambiguous, in which case label it `inferred` and say what you inferred it from.

### Risk -> lane

Apply `ai-engineering/policies/processing-lanes.md`, `risk-classification.md`, and `protected-assets.md` — do not re-derive lane criteria here. Ask: does the change touch a protected asset? Does it touch money or real (non-synthetic) data paths? How reversible is it? Route the answer through those policies to Fast / Standard / Controlled.

## PROPOSE

Always propose before acting — never auto-proceed, at any confidence level, including all-`verified`. Use this fixed 4-line format:

```
Detected: scenario=<value> (<confidence>, <evidence>); task=<value> (<confidence>, <evidence>)
Proposed route: <module or workflow path>
Lane: <Fast|Standard|Controlled> (<reason>)
Confirm?
```

**Exception:** an explicit mode invocation (e.g. `/engineer redteam code`, `/engineer setup-install`) skips DETECT entirely and goes straight to that module — the user has already told you the route.

For Standard or Controlled Lane work, confirmation here is what triggers entering plan mode before any file edit, per the adapter contract in `CLAUDE.md`.

## ROUTE table

| Task type | Scenario | Route |
|---|---|---|
| `onboard` | inherited / greenfield / existing | `modules/onboard-<scenario>.md` — **not yet built (Round 3); use FALLBACK** |
| `review-redteam` | any | `modules/redteam.md` |
| `setup-install` | any | `modules/setup-preflight.md` -> `modules/setup-install.md` -> `modules/setup-configure.md`, strictly sequential, each gated on human approval before the next starts |
| `bug` / `feature` / `refactor` | any | `ai-engineering/core/workflow.md`, phases run per the lane from DETECT |

## FALLBACK rule

If the routed module does not exist yet (currently: any `onboard` route), say so plainly — name the missing module and that it's scheduled for a later round — and offer the generic nine-phase workflow (`ai-engineering/core/workflow.md`) instead. Never improvise the content of a missing module.

## Scope note

This skill and its modules are project-agnostic by design: no project name, path, or domain belongs in any rule here. Project-specific facts (names, paths, commands, owners) live only in the target project's own `AGENTS.md`.
