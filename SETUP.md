# Setup Guide

Two install tiers, one GitHub source of truth. Pick one:

- **Full** — the complete module tree: `ai-engineering/`'s policies and
  workflow modules, plus the Claude Code adapter (`.claude/skills`,
  `.claude/agents`, `.claude/rules`, `.claude/settings.json`). Gives you
  `/engineer`-driven routing, red-team review, the Gate procedure, and
  the onboarding modules, permanently available in the target repo.
- **Light** — a single, evidence-filled `AGENTS.md` and nothing else.
  No module tree, no Claude Code skills. For a repo that wants the
  contract documented but not the machinery that enforces it.

Both tiers start from the same temporary source checkout and both end
with that checkout deleted — neither leaves a long-lived clone behind.
`/engineer` is the framework's single agent-driven entry point once
either tier is installed: for a Full install, run `/engineer
setup-install` and it executes Steps 1-3 below as `setup-preflight.md`,
`setup-install.md`, and `setup-configure.md`, each gated on your
approval. This page is the human-readable walkthrough for both tiers;
the modules are canonical for Full if the two ever diverge.

## Step 0: Get the framework source

```bash
git clone https://github.com/jetniphat400/ai-solution-engineering-framework.git
```

This checkout is temporary for both tiers below — each tier's steps say
exactly where to delete it. GitHub remains the durable source of truth;
a future upgrade re-clones fresh rather than reusing a long-lived local
copy that can drift out of date.

If you're already reading this file from inside a checkout of this
repository, you can use it directly as the framework source instead of
cloning again — it's still meant to be temporary for the target
project's install, not a permanent dependency of that project.

## Full install

### Step 1: Prepare the target repository

Use a clean Git working tree.

```bash
git status
git add -A
git commit -m "chore: checkpoint before AI engineering setup"
```

For a new project, initialize Git first:

```bash
git init
```

### Step 2: Install the starter kit

#### Option A: Copy manually

Copy these items to the project root:

- `AGENTS.md`
- `CLAUDE.md`
- `.claude/`
- `ai-engineering/`

`.claude/` is not atomic — it mixes framework-owned and project-owned content, and different subpaths need different treatment. Do not overwrite anything blind; follow the per-subpath conflict matrix in `.claude/skills/engineer/modules/setup-install.md` (`AGENTS.md`/`CLAUDE.md`, `.claude/settings.json`, framework-owned skills, everything else) instead of a one-line rule here.

#### Option B: Use the installer

PowerShell:

```powershell
.\scripts\install-to-project.ps1 -TargetPath "C:\path\to\project"
```

Bash:

```bash
bash scripts/install-to-project.sh /path/to/project
```

The installer refuses to overwrite existing files unless an overwrite option is explicitly supplied.

### Step 3: Configure the repository contract

Edit `AGENTS.md` and replace the placeholders:

- Project purpose
- Project type and risk
- Architecture summary
- Approved technologies
- Build, test, lint, type-check, and run commands
- Protected assets
- Deployment and rollback instructions

Keep the file concise. Put detailed procedures in `ai-engineering/`.

### Step 4: Delete the clone

Once Steps 1-3 are done and committed in your target project, delete the framework source checkout from Step 0:

```bash
rm -rf /path/to/ai-solution-engineering-framework
```

```powershell
Remove-Item -Recurse -Force C:\path\to\ai-solution-engineering-framework
```

There is nothing left to keep in it — your project now owns its own copy of everything the framework installed. A future upgrade re-clones from GitHub rather than reusing this checkout, so keeping it around only invites drift against upstream.

### Step 5: Claude Code setup

Install Claude Code using the current official installation method for your operating system, then open a terminal in the project root and run:

```bash
claude
```

On the first session:

```text
/memory
/skills
/agents
/permissions
/doctor
```

Confirm that:

- `CLAUDE.md` loaded and imported `AGENTS.md`
- `engineer`, `engineering-workflow`, and `redteam` skills are visible
- `independent-reviewer` is visible
- permission deny rules are active

Use this first prompt:

```text
Classify this project and task using the framework. Do not modify files yet.
Read AGENTS.md and the relevant ai-engineering policies, identify missing project placeholders,
and propose the smallest safe setup changes.
```

### Step 6: OpenAI Codex setup

Install Codex CLI, authenticate, then run it from the project root. Codex discovers `AGENTS.md` automatically.

Recommended first prompt:

```text
Read AGENTS.md and classify this task. Do not edit files yet.
Return the project state, risk level, processing lane, assumptions, and proposed next step.
```

Start with approval-based or sandboxed operation. Do not grant production credentials.

### Step 7: Run a first task

Choose a low-to-medium risk task. Good examples:

- Refactor one oversized module without changing behavior
- Add one API endpoint with tests
- Fix one reproducible bug and add a regression test

Expected flow:

```text
Classify -> Discover -> Define -> Design -> Plan -> Build small batch
-> Verify -> Independent review -> Red-team -> Completion report
```

If the project was inherited rather than started fresh, run `/engineer onboard` first — it routes to `onboard-inherited.md` (or `onboard-existing.md` if the contract is already established) before this task begins.

### Step 8: Review and tune

After this first task, update only rules that solved a real failure or recurring ambiguity.
Avoid turning `AGENTS.md` into a long handbook.

## Light install

### What Light gives up vs Full

Light gives you a filled-in, evidence-backed `AGENTS.md` — project
identity, required behavior, conventions, engineering baseline,
protected assets, completion-status vocabulary — that any competent
coding agent can read and try to honor. It does not give you:

- The `/engineer` router or any of its scenario/task detection
- The nine-phase workflow module library (`ai-engineering/core/`)
- Red-team modes or the Gate procedure
- The `independent-reviewer` agent
- `.claude/settings.json`'s permission deny-rule baseline

Nothing routes a future agent session into plan-mode-before-editing or
a red-team pass automatically. A human, or the agent's own reading of
`AGENTS.md`'s "Required behavior" list, has to carry that discipline
instead — Light trades enforcement machinery for a much smaller
footprint.

### When Light is the right choice

- A repo whose maintainers don't want a `.claude/` tree committed
- A quick, single-session engagement where the full module library is
  more ceremony than the task needs
- A repo that wants the contract's discipline named and evidence-backed,
  without adopting an agent-specific skill setup

If you're not sure, start Light — Full remains a later upgrade (see
below), and nothing about starting Light forecloses it.

### Steps

1. Prepare the target repository — same as Full's Step 1 (clean or
   freshly initialized Git tree).
2. From the Step 0 checkout, copy only two files into the target
   project root: `AGENTS.md` (with its placeholders intact) and a
   one-line `CLAUDE.md` containing just:

   ```text
   @AGENTS.md
   ```

   Do not copy `.claude/skills`, `.claude/agents`, `.claude/settings.json`,
   or `ai-engineering/`. Codex needs no adapter file — it discovers
   `AGENTS.md` automatically, the same as in Step 6 above.
3. In one prompt to your coding agent, point it at the Step 0
   checkout's placeholder-filling procedure and run it against your
   project's `AGENTS.md`:

   ```text
   Read {path-to-framework-checkout}/.claude/skills/engineer/modules/context-mapping.md
   and run its procedure against this repository's AGENTS.md. Fill every
   placeholder with a confidence-labeled (verified/inferred/unknown) value
   and its evidence. Do not edit AGENTS.md until I've reviewed the inferred
   and unknown rows.
   ```
4. Review the `inferred`/`unknown` rows the agent reports, confirm or
   correct them, then let it apply the edits.
5. Delete the framework source checkout — same as Full's Step 4.

### Upgrading Light to Full later

Re-run Full's Steps 0-4 above against the same target project. The
conflict matrix in `.claude/skills/engineer/modules/setup-install.md`
already handles a locally-edited `AGENTS.md` (back up, surface the
diff for a human merge, never silently overwrite), so upgrading is
safe even though your `AGENTS.md` is no longer in its unfilled,
just-installed state.
