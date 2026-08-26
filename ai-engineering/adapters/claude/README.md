# Claude Code Adapter

The project root `CLAUDE.md` imports `AGENTS.md`. Claude-specific extensions live under `.claude/`.

Recommended validation commands inside Claude Code:

```text
/memory
/skills
/agents
/permissions
/doctor
```

Use approval-based operation. Review `.claude/settings.json` before sharing the repository.

## Model tier mapping

`ai-engineering/policies/model-tiers.md` defines four provider-neutral
capability tiers. Claude Code's concrete mapping:

| Tier | Claude Code model |
|---|---|
| `FAST_MODEL` | `haiku` |
| `STANDARD_CODING_MODEL` | `sonnet` |
| `STRONG_REASONING_MODEL` | `opus` |
| `CRITICAL_REVIEW_MODEL` | `fable` (falls back to `opus` where Fable 5 isn't available for the org or session — zero-data-retention accounts, or plans without usage-credit access) |

`.claude/agents/independent-reviewer.md` pins `model: fable` to
implement `CRITICAL_REVIEW_MODEL` directly, rather than inheriting the
implementer's model. Whenever the implementer's session is not already
running the top tier, this guarantees the reviewer runs on a different,
stronger model tier than the implementer — the two are not the same
model evaluating its own work. When the implementer's session is
already on `fable`, both implementer and reviewer run on the top tier;
that is expected, not a gap this mapping needs to close.
