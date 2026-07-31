# AI-Agnostic User-Centered Solution Engineering Framework v0.1

A portable engineering baseline for Claude Code, OpenAI Codex, and future coding agents.

## What this starter kit provides

- A vendor-neutral `AGENTS.md` repository contract
- A nine-phase user-to-production workflow
- Fast, Standard, and Controlled processing lanes
- Architecture assessment and incremental refactoring guidance
- Verification, protected test assets, adversarial red-team review, and human approvals
- Claude Code adapter with project settings, skills, rules, and a read-only reviewer
- OpenAI Codex adapter based on `AGENTS.md`
- Templates for specifications, plans, ADRs, refactoring, red-team, verification, and completion reports

## Recommended first use

Start with a non-critical repository that your team understands well.

1. Back up or commit the current repository.
2. Copy this starter kit into the repository root.
3. Replace all `[PROJECT ...]` placeholders in `AGENTS.md`.
4. Fill in the real build, test, lint, and run commands.
5. Review `.claude/settings.json` before using Claude Code.
6. Start in approval-based mode. Do not enable direct production access.
7. Run one Standard Lane pilot task and review the evidence.

See `SETUP.md` for detailed instructions.
