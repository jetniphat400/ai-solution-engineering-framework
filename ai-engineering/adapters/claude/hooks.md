# Claude Code hooks (BACKLOG-v1.2 Item 6)

`.claude/settings.json` wires three hook events to mechanically enforce
parts of `AGENTS.md` and `ai-engineering/core/verification.md` that were
previously voluntary-compliance-only. Verified against the installed
Claude Code version (`2.1.246`) and the hooks reference at
`code.claude.com/docs/en/hooks`.

## PreToolUse — protected-path block

`ai-engineering/checks/hooks/pretooluse-protected-path.sh`/`.ps1` run
before every `Edit`/`Write`/`MultiEdit` call. Each extracts
`tool_input.file_path`, reduces it to a repo-relative path, and calls
`ai-engineering/checks/check-protected-paths.sh --path`/
`check-protected-paths.ps1 -LiteralPath` against AGENTS.md's
"Project-specific protected paths" block. A match blocks the tool call
(exit 2) with a message naming the matched pattern and the Controlled-
lane approval requirement.

**Fails closed.** If `tool_name`/`file_path` cannot be extracted from
the hook's stdin JSON, or the underlying check script exits anything
other than 0 or 1, the wrapper exits 2 rather than allowing the call
through. A security hook that silently passes on malformed input is
worse than no hook.

**Override.** Set `AI_ENGINEERING_PROTECTED_PATH_OVERRIDE=1` for the
session to downgrade a block to a visible warning — printed on every
use, no allowlist. Setting this variable is itself a Controlled-lane
action a human must do deliberately; see
`ai-engineering/policies/protected-assets.md`.

## UserPromptSubmit — per-turn baseline

`ai-engineering/checks/hooks/userpromptsubmit-snapshot.sh`/`.ps1` run
when a prompt is submitted. Each snapshots `git status --porcelain`
into a per-session temp file and resets that session's Stop-hook block
counter. This exists solely so the Stop hook below can tell an
ordinary conversation turn from one that edited the repository —
without it, the Stop hook would have to enforce an evidence block on
every turn, including a question or a PROPOSE turn waiting for human
confirmation, which deadlocks (BACKLOG-v1.2 Item 6 design note (iv)).
Never blocks; always exits 0.

## Stop — evidence-block enforcement

`ai-engineering/checks/hooks/check-stop-evidence.sh`/`.ps1` run when
Claude finishes responding. Each compares `git status --porcelain` now
against the UserPromptSubmit baseline for this session:

- **Unchanged** (ordinary conversation, a question, a PROPOSE turn) →
  exits 0 immediately, no evidence check at all.
- **Changed** (this turn edited the repository, via any tool —
  catches `Bash`-driven edits too, not only `Edit`/`Write`/`MultiEdit`)
  → the final message must contain exactly one of `AGENTS.md`'s seven
  terminal statuses and the five-field evidence block from
  `ai-engineering/core/verification.md` (field names shared with
  `check-verification-report.sh`/`.ps1` via
  `ai-engineering/checks/lib/evidence-fields.sh`/`.ps1`, one source of
  truth). Missing or ambiguous → exit 2, with a message stating exactly
  what's missing.

**Fails closed** on a missing baseline file (treats "no snapshot
recorded" as "assume the repo changed," not as "skip the check").

**Known false positive**: the terminal-status count is a whole-message
occurrence count, not scoped to one declared final line. A message
that discusses or quotes the status vocabulary (routine in this
framework's own sessions) can trip the ">1 status token" case even
when exactly one status was validly declared. Shipped as literally
specified — over-blocking, never under-blocking — not hidden.

**Loop guard.** `stop_hook_active`, which some Claude Code versions'
docs describe for exactly this purpose, does **not** appear anywhere in
the hooks reference for the installed version (`2.1.246`) — checked by
direct, repeated documentation search before writing this, not
assumed present, per this item's explicit instruction. In its place,
the script keeps its own per-session block counter (reset every new
turn by the UserPromptSubmit hook) and gives up after 3 consecutive
blocks, exiting 0 with a loud, unmissable warning instead of looping
forever. This fails *open* only for the loop guard itself, specifically
to guarantee the turn terminates — the missing evidence is still
reported, never silently treated as satisfied.

## Extraction: two different approaches, on purpose

`tool_input.file_path` (PreToolUse) and `last_assistant_message` (Stop)
are extracted differently, and the difference is deliberate, not an
oversight:

- **File paths** rarely contain literal quote characters, so both
  bash wrappers use a `grep`/`sed` best-effort flat `"key":"value"`
  extractor with no new dependency. `jq` is confirmed absent from this
  repo's Git Bash.
- **The final message** routinely contains embedded quotes, backticks,
  and newlines. A hand-written POSIX-ERE "escaped-quote-aware" regex
  (the usual `(\\.|[^"\\])*` idiom) was tried and **empirically failed**
  to extract a string with an embedded escaped quote correctly under
  GNU grep 3.0 — confirmed by a direct failing repro before
  `check-stop-evidence.sh` was written this way, not assumed unsafe in
  the abstract. That script therefore shells out to `python`/`python3`
  for real JSON parsing, for this one field only — a new runtime
  dependency for the **bash implementation specifically**, accepted
  only after the no-dependency approach was shown broken, not by
  default. On Windows, `python3` can silently resolve to the
  non-functional Microsoft Store execution-alias stub even when real
  Python is installed as `python` — confirmed on the reference dev
  machine — so the script tries both names and checks the *actual*
  exit code and output, not just whether a `python*` command exists on
  PATH. If neither interpreter works, it fails closed (exit 2).
  `check-stop-evidence.ps1` needs none of this: `ConvertFrom-Json` is
  native and correct regardless of escaping.

**Residual risk**: on a POSIX host with no working Python and no
PowerShell fallback (a real, if less common, contributor environment),
the Stop hook will always fail closed on any turn that modified the
repository, effectively requiring the override... except there is no
Stop-hook override by design (see below) — that contributor's only
path forward on a real edit turn is to actually supply the evidence
block, which is the intended outcome, just reached by "extraction
always fails" rather than "extraction succeeds and finds it missing."
Flagged here rather than hidden.

**No Stop-hook override exists**, unlike the PreToolUse override.
Bypassing your own completion-status gate is a materially more
dangerous thing to make easy than bypassing a protected-file-edit
block, so none was added.

## Cross-platform dispatch: exec form, dual registration

Every hook is registered twice per event in `.claude/settings.json`,
using **exec form** (`command` + `args`, no shell interpolation at
all):

```json
{"type":"command","command":"bash","args":["${CLAUDE_PROJECT_DIR}/.../script.sh"]}
{"type":"command","command":"powershell.exe","args":["-NoProfile","-ExecutionPolicy","Bypass","-File","${CLAUDE_PROJECT_DIR}/.../script.ps1"]}
```

Exec form spawns the named program directly — no shell decides which
script runs, so there is no ambiguity about which of `bash`/
`powershell.exe` a given host's default shell would have picked. On a
host missing one interpreter, that one entry fails to spawn (a
non-blocking error per Claude Code's own hook exit-code rules) while
the other does the real check. **Known, accepted tradeoff**: a host
with both interpreters present (e.g. Windows with Git Bash installed)
runs both entries on every matched event — redundant, and on a real
block, two independent messages instead of one. Each wrapper prefixes
its message with its own script name so the two are distinguishable
rather than confusing duplicates.

## Independent review findings (BACKLOG-v1.2 Item 6, CONDITIONAL PASS)

An independent-reviewer pass returned CONDITIONAL PASS on this item's
diff. Fixed: M1 (nested `powershell.exe` call now passes
`-ExecutionPolicy Bypass`, so it no longer fails closed on every edit —
not just protected ones — on hosts with a restrictive default policy);
M3 (the bash wrapper's path-prefix comparison is now case-insensitive
via `shopt -s nocasematch`, matching the PowerShell twin's
`OrdinalIgnoreCase` — note `nocasematch` affects the `case` match
itself but not `${var#pattern}` removal, confirmed by direct testing,
so the actual strip uses a length-based substring instead); L2 (the
bash terminal-status regex now has `\b` word-boundary anchors,
matching the PowerShell twin). All three re-verified after fixing; see
`TEST-EVIDENCE.md`.

Documented rather than fixed, with reasoning:

- **H1 — the deadlock-avoidance guarantee is conditional on
  `session_id` extraction succeeding.** If `session_id` can't be
  extracted from the Stop hook's input (schema drift, a future
  version renaming the field), both `check-stop-evidence.sh`/`.ps1`
  fail closed unconditionally — including on an ordinary, no-edit
  turn — which is exactly the deadlock this design exists to prevent.
  Not fixed because there is no safe alternative: the script cannot
  know which baseline file to compare against without a session
  identifier, so failing open here (skip enforcement when
  unidentifiable) would be worse than the deadlock risk it trades for.
- **M2 — dual-fire shares per-session state files with no locking.**
  On a host where both bash and PowerShell hook entries genuinely fire
  for the same event, both read-modify-write the same counter file
  (and, harmlessly, the same baseline file) with no mutual exclusion —
  a lost-update race on the loop-guard counter. Not fixed: the
  consequence is bounded (the counter might release one attempt early
  or late; the underlying git-status decision is recomputed fresh from
  git every time and is unaffected), and a real fix (file locking
  across two different language runtimes) is a disproportionate amount
  of complexity for a bounded, non-security-relevant race. Not tested
  under genuine concurrent dual-fire in this item — only sequential,
  isolated per-implementation runs.
- **L1 — an edit-then-revert nets to a clean diff.** The Stop hook only
  compares `git status --porcelain` at turn-start vs. turn-end; a turn
  that edits a file and reverts it to identical content triggers no
  evidence-block requirement even though a real edit happened
  mid-turn. Protected-path blocking is unaffected (PreToolUse fires
  before any write, regardless of later reversion) — this only affects
  the Stop-hook evidence requirement. Not fixed: catching this would
  require tracking every individual tool call rather than the net
  diff, a materially larger redesign than this item's scope.
- **L3 — PowerShell scripts dot-source with backslash-separated
  relative paths** (e.g. `"..\lib\evidence-fields.ps1"`). Fine given
  the design explicitly targets Windows `powershell.exe`, not
  cross-platform `pwsh` — noted only in case that assumption is ever
  revisited.

## Known limitations, stated rather than hidden

- **Enabling these hooks mid-session leaves the turn they were added
  in without a baseline, for the rest of that turn.** `UserPromptSubmit`
  only fires when the user submits a genuinely new prompt, not when a
  Stop-hook block forces the conversation to continue. If hooks are
  wired into `settings.json` partway through an already-running turn
  (exactly what happened while building this item), no
  `UserPromptSubmit` ever fires for that turn's original prompt, so no
  baseline is ever recorded for it — every `Stop` check for the rest of
  that turn falls into the "no baseline found" fail-closed branch,
  requiring a valid evidence block every time regardless of whether
  anything changed since the last attempt, until the loop guard
  releases it. Confirmed live: two real `Stop` blocks in the same turn
  hooks were installed in both reported "No git-status baseline found
  for this session." This is a one-time transitional artifact, not a
  standing defect — any turn that starts with the hooks already in
  `settings.json` gets a real baseline from the start, as verified by
  every other real and script-level test in `TEST-EVIDENCE.md`.
- Both PowerShell scripts originally wrote their baseline and counter
  files with `Out-File -Encoding utf8`, which writes a UTF-8 BOM.
  `Get-Content` strips a BOM automatically on read, so a pure
  PowerShell-to-PowerShell round trip was unaffected, but a `bash`
  implementation reading a PowerShell-written file would not strip it
  — `cat`/shell reads see the BOM bytes as real content, corrupting a
  numeric counter comparison (`case ... in *[!0-9]*)`) and permanently
  breaking the baseline string-equality check for the dual-fire case
  where both interpreters are present. Found by inspecting the raw
  bytes of a real state file, not by inspection of the code alone.
  Fixed by writing both files with `[System.IO.File]::WriteAllText`
  and an explicit BOM-less `UTF8Encoding`/`ASCII` encoding instead.
- **The PreToolUse protected-path hook only matches `Edit`/`Write`/
  `MultiEdit`, exactly as scoped in this item's design.** A `Bash` tool
  call that writes to a protected path (`cat >>`, `sed -i`, a heredoc,
  `git apply`, ...) is NOT covered at all and passes through with no
  block, no warning, and no override needed — confirmed directly while
  implementing this item: appending to the now-protected
  `ai-engineering/policies/protected-assets.md` via a `Bash` heredoc
  succeeded with zero hook involvement, in the same session where the
  same file was correctly blocked through `Edit`. This is a real,
  material gap in what "protected" means in practice, not a
  theoretical one — anyone (agent or human) editing a protected file
  through `Bash` instead of `Edit`/`Write`/`MultiEdit` bypasses this
  mechanism entirely. Closing it would mean either matching `Bash` too
  (much harder: it would need to parse shell commands for file-write
  targets, a fundamentally different and much less reliable problem
  than reading `tool_input.file_path`) or accepting this as the
  boundary of what a PreToolUse hook can practically enforce. Left
  open rather than silently scoped out, for a future item to weigh.
- Absolute-to-relative path reduction in the PreToolUse wrapper falls
  back to the absolute path if it can't confidently recognize
  `CLAUDE_PROJECT_DIR` as a prefix (e.g. drive-letter casing mismatch
  on Windows) — directory-style protected tokens may then fail to
  match while exact-file tokens (matched by suffix) still would.
- `git status`-based turn-change detection misses edits to gitignored
  files, and can cross-contaminate between two Claude Code sessions
  sharing one working directory.
- The bash JSON extractors are not general-purpose JSON parsers; see
  the field-specific notes above.
- Two real, pre-existing bugs were found and fixed while building this
  item, unrelated to anything new added by it: (1)
  `check-protected-paths.sh` crashed silently (bare `set -e` abort, no
  message, exit 1) whenever the protected-paths block had no
  path-shaped token — exactly this repo's own placeholder state before
  this item populated it — instead of the graceful "nothing to check
  against" exit 0 its own comments describe; (2) the PowerShell
  wrapper scripts' error-reporting originally used `Write-Error` under
  `$ErrorActionPreference = "Stop"`, which throws a terminating error
  and corrupts the script's intended exit code into PowerShell's own
  `1` — fixed by writing to `[Console]::Error` directly instead.
