# Claude Code hooks (BACKLOG-v1.2 Items 6 and 14)

`.claude/settings.json` wires three hook events to mechanically enforce
parts of `AGENTS.md` and `ai-engineering/core/verification.md` that were
previously voluntary-compliance-only. Verified against the installed
Claude Code version (`2.1.246`) and the hooks reference at
`code.claude.com/docs/en/hooks`.

## Item 14 fixes (defects found in live use immediately after Item 6 shipped)

**Defect 1 — bash handler never ran on the reference dev host.** Every
bash-targeting hook entry emitted `WSL (10 - Relay) ERROR:
CreateProcessCommon:818: execvpe(/bin/bash) failed: No such file or
directory`. Diagnosed live: `where.exe bash` on this host resolves to
`C:\Windows\System32\bash.exe` (Windows's WSL launcher stub) *before*
the real Git Bash `bash.exe`, because Git's `bin` directory isn't on
this session's `PATH` (only `Git\cmd` is) — a per-user/per-machine
install quirk, not something a hardcoded path could fix portably. The
hook entries used **exec form** (`command: "bash"`, `args: [...]`),
which the hooks docs state resolves via standard OS executable
resolution — exactly what hits the WSL stub. **Fixed** by switching
the three bash-targeting entries to **shell form** (`command: "<script
path>"`, `"shell": "bash"`, no `args`) instead, trusting Claude Code's
own documented Git-Bash-presence detection (distinct from a bare OS
PATH lookup) rather than resolving `bash` ourselves. **Verified live,
not by inspection**: a real `Edit` PreToolUse invocation immediately
after the fix was decided by the bash script itself (`[pretooluse-
protected-path.sh] BLOCKED: ...`), with no WSL relay error anywhere —
both on a protected path (real block) and an unprotected one (silent
pass). The wrapper-self-detection fallback the fix was conditioned on
was **not needed** — shell form resolved correctly on the first try,
so no further invocation styles were tried, per the explicit
instruction not to keep iterating. On a Windows host where `bash`
genuinely only resolves to the WSL stub (no Git Bash installed at
all), protection is provided by the PowerShell handler alone — dual-
fire already tolerates one entry failing to spawn. A real bash-only
host (Linux/macOS, no WSL stub in the picture at all) is unaffected by
this change: shell form works identically there.

**Defect 2 — whole-message terminal-status counting.** A message that
named its outcome in prose (e.g. a summary sentence) and again in its
formal declaration line was flagged as ambiguous (">1 token"),
confirmed by two real live blocks immediately after Item 6 shipped.
**Fixed**: the count is now scoped to declaration-position lines only
— a line matching `^\s*(\*\*)?Terminal status\b`, or a line that,
after stripping markdown decoration, consists solely of one of the
seven tokens. Prose mentions elsewhere no longer count at all. Zero
declarations found still fails closed, unchanged.

**Defect 3 — missing baseline enforced on every turn.** Diagnosed
live: `session_id` extraction, file path, and BOM were all confirmed
correct; the real root cause is that `UserPromptSubmit` never re-fires
on a Stop-hook-forced continuation, so once a baseline is missing for
any reason, every forced continuation for the rest of that turn
repeats "no baseline" indefinitely. **Fixed** with a self-healing
RECOVERY baseline: on a missing baseline, the hook records one from
the current state and writes a sibling marker file — but, per explicit
instruction, a recovery baseline must never grant a clean-diff pass
within the same turn (that would silently erase evidence of edits made
before the recovery baseline was written, the worse failure). While
the marker is present, the evidence block is required for the rest of
the turn regardless of comparison result; `userpromptsubmit-
snapshot.sh`/`.ps1` clear the marker on the next genuine fresh prompt.
The message now says the baseline is missing and comparison is
impossible, not that the repo is assumed changed. Verified live and at
the script level: a missing baseline still fails closed and records a
recovery baseline; a same-session recheck with a clean diff and the
marker present still blocks; a fresh `UserPromptSubmit` clears the
marker and a subsequent clean-diff check passes immediately.

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

**Fails closed** on a missing baseline file, self-healing with a
RECOVERY baseline that does not grant a clean-diff pass for the rest of
the turn — see "Item 14 fixes" above (Defect 3).

**Declaration-scoped status count** (fixed in Item 14, Defect 2, after
firing live twice): the terminal-status count is scoped to
declaration-position lines, not a whole-message occurrence count. A
message that discusses or names the status vocabulary in prose no
longer trips the ">1 status token" case, as long as exactly one
declaration-position line exists.

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

## Cross-platform dispatch: shell form (bash) + exec form (PowerShell), dual registration

**Updated by Item 14, Defect 1** — the bash entries below changed from
exec form to shell form; this section is corrected to match, replacing
the exec-form description this file originally shipped with (see
"Item 14 fixes" above for why). Every hook is still registered twice
per event in `.claude/settings.json`, one entry per interpreter:

```json
{"type":"command","command":"${CLAUDE_PROJECT_DIR}/.../script.sh","shell":"bash"}
{"type":"command","command":"powershell.exe","args":["-NoProfile","-ExecutionPolicy","Bypass","-File","${CLAUDE_PROJECT_DIR}/.../script.ps1"]}
```

The bash entry uses **shell form** (`command` is the script path,
`shell: "bash"`, no `args`), trusting Claude Code's own documented
Git-Bash-presence detection to find a real `bash` rather than resolving
it via a bare OS PATH lookup — the PATH lookup a bare exec-form
`command: "bash"` used, and the reason Defect 1 existed. The
PowerShell entry is unchanged: **exec form** (`command` + `args`), spawning
`powershell.exe` directly with no shell deciding anything. On a host
missing one interpreter (or where its resolution fails, e.g. a
Windows box with no Git Bash where `bash` only resolves to the WSL
stub), that one entry fails to spawn or errors non-fatally (a
non-blocking error per Claude Code's own hook exit-code rules) while
the other does the real check. **Known, accepted tradeoff**: a host
with both interpreters present (e.g. Windows with Git Bash installed —
the reference dev host) runs both entries on every matched event —
redundant, and on a real block, two independent messages instead of
one, confirmed live (both a bash and a PowerShell Stop-hook block
fired for the same turn after Defect 1's fix). Each wrapper prefixes
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

## Independent review findings (BACKLOG-v1.2 Item 14, FAIL → remediated)

A second independent-reviewer pass, on Item 14's diff (the three
defect fixes above), returned **FAIL** — one blocking finding and one
high finding, both real regressions rather than judgment calls. Full
disposition recorded in `TEST-EVIDENCE.md`'s Item 14 remediation
section; summarized here:

- **B1 (blocking)** — `BACKLOG-v1.2.md` claimed, in present tense, that
  H2 "is tracked as its own item in `BACKLOG-v1.3.md`" before that
  file existed. Fixed by rewording to state the file doesn't exist yet
  and tracking there is planned (Part 3), not already true.
- **H1 (high)** — the declaration-line recognizer (Defect 2's fix)
  didn't recognize a line with a leading markdown list marker, so
  `"- Terminal status: X"` or a bulleted, backtick-wrapped token —
  **exactly the format `personal-skills/solution-engineer/SKILL.md`
  itself uses** to render the seven terminal statuses — was not
  counted as a declaration, reintroducing an over-blocking false
  positive of the same class Item 14 existed to fix. Fixed by
  stripping one leading list marker before the declaration checks, in
  both implementations; re-verified against the exact SKILL.md
  convention.
- **M1** — the RECOVERY baseline and its marker were written as two
  separate, non-atomic file writes (baseline first), leaving a
  transient window where a concurrent dual-fire sibling could see
  "baseline present, no marker" and take the fast clean-diff-pass
  branch — exactly the false pass Defect 3's fix says must never
  happen. Fixed by writing the marker first: the same transient window
  now reads as "no baseline yet" in either script, which correctly
  routes to the fail-closed branch instead.
- **M2** — this file's own "Cross-platform dispatch" section (above)
  was left describing bash as exec-form after Defect 1 switched it to
  shell form, contradicting this file's own "Item 14 fixes" section.
  Fixed.
- **M3** — a "recorded" claim in `BACKLOG-v1.2.md` pointed here before
  this section existed. Resolved by this section's own existence.
- **L1** — a stale "exec-form handlers" comment in
  `pretooluse-protected-path.sh`. Fixed.
- **L2** — `TEST-EVIDENCE.md`'s Case (2) evidence didn't show enough
  to confirm which code path produced its `exit:0`. Fixed by showing
  the actual message content and result.

All fixes re-verified by real invocation in both implementations after
being applied.

## Known limitations, stated rather than hidden

- **A turn that starts with no baseline (hooks just installed
  mid-turn, or a prior turn's baseline lost) no longer forces
  "no baseline" on every subsequent check within that turn** — fixed
  in Item 14, Defect 3, with a self-healing RECOVERY baseline (see
  "Item 14 fixes" above). `UserPromptSubmit` still only fires on a
  genuinely new prompt, never on a Stop-hook-forced continuation, so
  the *first* check in a turn can still find no baseline — that check
  still fails closed, correctly. What changed: it no longer repeats
  "no baseline" forever afterward, and — the harder requirement — a
  recovery baseline never grants a false clean-diff pass for the rest
  of that turn, so evidence made earlier in the turn is never silently
  dropped from consideration.
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
