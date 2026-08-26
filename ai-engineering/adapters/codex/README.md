# OpenAI Codex Adapter

Codex reads the root `AGENTS.md` as repository instructions. The common engineering logic remains under `ai-engineering/`.

Start Codex from the repository root and begin with an analysis-only request:

```text
Read AGENTS.md. Classify the project and requested change. Do not edit files yet.
Return facts, assumptions, unknowns, risk, processing lane, design options, and the smallest safe next step.
```

Use approval-based or sandboxed modes. Keep production credentials and destructive operations outside the coding session.

## Cross-model review fallback

When a second vendor (OpenAI Codex) is available, running the same
review through a genuinely different provider is the preferred
adversarial-review path for Controlled-lane work — it removes
same-vendor correlated blind spots that even a different Claude model
tier can't fully rule out. `.claude/agents/independent-reviewer.md`'s
pinned `fable` tier (see the Claude adapter's "Model tier mapping") is
the fallback when a second vendor isn't available, not the first
choice when one is.

To run it: start Codex from the repository root and give it the same
brief `independent-reviewer.md` uses — read `AGENTS.md`, the accepted
specification and plan, the current diff, relevant tests, and
verification evidence; try to disprove correctness rather than confirm
the implementer's narrative; report blocking findings, high/medium/low
findings, missing or weak verification, architecture and
maintainability concerns, security/data/operational risks, and a final
recommendation (PASS, CONDITIONAL PASS, or FAIL). Do not edit files or
execute shell commands during the review.
