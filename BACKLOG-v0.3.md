# Backlog v0.3

## Origin

Seeded from post-Round-3b discussion, once the v0.2 backlog closed and
the installer, conflict matrix, and onboard modules had all been
proven against the field-test pilot. Not yet scoped into rounds —
these are the two items on the table, recorded before they're lost.

## Items

### Item 1 — Tiered adoption

**Problem:** The only install path today is the full clone-install
ceremony (Steps 1-3 in `SETUP.md`) — a single tier, always requiring a
target repo to receive a full `AGENTS.md` + `ai-engineering/` +
`.claude/` copy before the agent can apply any framework discipline at
all.

**Proposal:** Three tiers, one GitHub source of truth:

- **Zero-install** — a personal-level `/engineer` skill (installed
  once, at the user's own agent-config level, not per-repo) that
  carries the framework's discipline (classify, propose before
  acting, evidence over assumption) into any repo the user opens,
  even one with no framework contract present. If it finds no
  `AGENTS.md`/`ai-engineering/` in the current repo, it offers the
  light or full install rather than silently operating without one.
- **Light** — a single `AGENTS.md`, produced via `context-mapping.md`,
  in one prompt. No `ai-engineering/` or `.claude/` copy. For a repo
  that wants the contract but not the full module tree.
- **Full** — the current ceremony: clone the framework source,
  install (merge-safe, per the Round 3a fix), then the clone itself is
  disposable — delete it once installed, since GitHub remains the
  durable source of truth and a future upgrade re-clones rather than
  keeping a long-lived local copy around to drift.

**Open questions:** how the zero-install tier is actually packaged and
installed at the personal level (mechanism is adapter-specific and
not yet designed); how a repo already on the light tier upgrades to
full without re-running the entire setup flow from scratch.

### Item 2 — Distribution polish

**Problem:** `SETUP.md` documents manual copy and the installer
script, but not the clone-install-delete pattern Item 1's full tier
now treats as the norm — the source clone is disposable, but nothing
tells a new user that.

**Proposal:** Document the clone → install → delete flow in
`SETUP.md` as the recommended full-install path, explicit about the
"delete the clone" step so users don't mistake it for something that
needs to persist locally. Consider a direct-from-URL install
(fetching the framework source without a manual clone step at all) as
a later polish item — deferred until the framework has left pilot
status, since it adds a new distribution mechanism to secure and
maintain and isn't needed to prove the tiered-adoption model first.

**Status:** Open, not yet scoped into a round.
