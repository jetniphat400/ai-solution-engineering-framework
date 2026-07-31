# Changelog

## Versioning rule

Each completed backlog round bumps the `VERSION` file's minor version
and records an entry below, in the same commit that closes the round.
A round is "closed" when its items are marked done in the active
backlog file — not before. This keeps `VERSION` and the backlog in
lockstep so a git-log-depth guess is never needed to answer "what
version is this" (see Round 3a below, which existed to fix exactly
that ambiguity).

## 0.2.0 — Round 3a

Repairs from the first field-test pilot (`docs/field-tests/2026-07-31-pcc-pilot.md`):
merge-safe installer scripts, a per-subpath `.claude/` conflict
matrix, upgrade detection in `setup-preflight.md`, a thin
`engineering-workflow` alias, and `setup-configure.md` scope gaps
(conventions placeholder, `.claude/settings.json` review). See
`BACKLOG-v0.2.md` for the full item list.

## 0.1.0 — Baseline

Framework v0.1 as designed: `AGENTS.md`, `CLAUDE.md`, `ai-engineering/`
core/policies/templates, and the Claude Code adapter.
