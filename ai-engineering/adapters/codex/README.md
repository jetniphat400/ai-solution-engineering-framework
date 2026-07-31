# OpenAI Codex Adapter

Codex reads the root `AGENTS.md` as repository instructions. The common engineering logic remains under `ai-engineering/`.

Start Codex from the repository root and begin with an analysis-only request:

```text
Read AGENTS.md. Classify the project and requested change. Do not edit files yet.
Return facts, assumptions, unknowns, risk, processing lane, design options, and the smallest safe next step.
```

Use approval-based or sandboxed modes. Keep production credentials and destructive operations outside the coding session.
