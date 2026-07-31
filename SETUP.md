# Setup Guide

`/engineer` is the framework's single agent-driven entry point, for setup and for every task afterward. For an agent-driven install, run `/engineer setup-install` — it executes Steps 1-3 below as `.claude/skills/engineer/modules/setup-preflight.md`, `setup-install.md`, and `setup-configure.md`, each gated on your approval. This page remains the human-readable walkthrough; the modules are canonical if the two ever diverge. Once set up, run `/engineer` again for any real task — it detects whether the project is greenfield, existing, or inherited and routes to the matching `onboard-*.md` module, or straight into the nine-phase workflow for a named bug/feature/refactor.

## Step 1: Prepare the target repository

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

## Step 2: Install the starter kit

### Option A: Copy manually

Copy these items to the project root:

- `AGENTS.md`
- `CLAUDE.md`
- `.claude/`
- `ai-engineering/`

`.claude/` is not atomic — it mixes framework-owned and project-owned content, and different subpaths need different treatment. Do not overwrite anything blind; follow the per-subpath conflict matrix in `.claude/skills/engineer/modules/setup-install.md` (`AGENTS.md`/`CLAUDE.md`, `.claude/settings.json`, framework-owned skills, everything else) instead of a one-line rule here.

### Option B: Use the installer

PowerShell:

```powershell
.\scripts\install-to-project.ps1 -TargetPath "C:\path\to\project"
```

Bash:

```bash
bash scripts/install-to-project.sh /path/to/project
```

The installer refuses to overwrite existing files unless an overwrite option is explicitly supplied.

## Step 3: Configure the repository contract

Edit `AGENTS.md` and replace the placeholders:

- Project purpose
- Project type and risk
- Architecture summary
- Approved technologies
- Build, test, lint, type-check, and run commands
- Protected assets
- Deployment and rollback instructions

Keep the file concise. Put detailed procedures in `ai-engineering/`.

## Step 4: Claude Code setup

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

## Step 5: OpenAI Codex setup

Install Codex CLI, authenticate, then run it from the project root. Codex discovers `AGENTS.md` automatically.

Recommended first prompt:

```text
Read AGENTS.md and classify this task. Do not edit files yet.
Return the project state, risk level, processing lane, assumptions, and proposed next step.
```

Start with approval-based or sandboxed operation. Do not grant production credentials.

## Step 6: Run the first pilot

Choose a low-to-medium risk task. Good examples:

- Refactor one oversized module without changing behavior
- Add one API endpoint with tests
- Fix one reproducible bug and add a regression test

Expected flow:

```text
Classify -> Discover -> Define -> Design -> Plan -> Build small batch
-> Verify -> Independent review -> Red-team -> Completion report
```

If the project was inherited rather than started fresh, run `/engineer onboard` first — it routes to `onboard-inherited.md` (or `onboard-existing.md` if the contract is already established) before this pilot task begins.

## Step 7: Review and tune

After the pilot, update only rules that solved a real failure or recurring ambiguity.
Avoid turning `AGENTS.md` into a long handbook.
