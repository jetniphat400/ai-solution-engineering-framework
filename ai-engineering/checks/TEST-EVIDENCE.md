# Test Evidence: v1.1 Round 2 enforcement checkers

**Date:** 2026-08-19
**Method:** each of the four checkers below (bash + PowerShell
implementations) was tested against hand-built synthetic fixtures
covering both the passing and failing branch of its logic, then run
read-only against the pilot repo (`D:\PCC_invesment_source\PCC`) as a
real target. Every PCC interaction was either non-mutating inspection
or a read-only git/pytest command (`git diff --name-only`, `git log`,
`pytest --collect-only`) — confirmed via `git status --short` before
and after: clean, no files changed, no hooks installed, nothing
written into PCC. What a PCC pass/fail proves, and what it doesn't, is
stated per item below — a real-target run is not automatically stronger
evidence than a synthetic one; it depends what the real target actually
exercises.

One real bug was found and fixed during this testing, not before it —
recorded here rather than smoothed over.

---

## Item 1 — verification & completion-status evidence linting

**A pre-existing framework inconsistency was found before this checker
could even be written**, not during testing: `ai-engineering/core/
verification.md`'s stated 5-field evidence format (`Command or
procedure` / `Result` / `Pass or fail` / `Evidence location` /
`Remaining risk`) did not match `ai-engineering/templates/
VERIFICATION-REPORT.template.md`'s actual table, which had only 4
columns and was missing `Pass or fail` entirely. Fixed the template to
match its own cited policy before building anything against it — the
checker below is built against the corrected, canonical format.

**Synthetic fixtures (both bash and PowerShell):**

| Fixture | Expected | Result |
|---|---|---|
| Complete table-format report | OK, all 5 fields present | PASS |
| Table report with 2 empty cells | Flags `EMPTY CELL(S)`, row and file cited | PASS |
| Complete colon-list report | OK, all 5 fields present | PASS |
| Colon-list report with 1 empty field | Flags `MISSING VALUE` for that field | PASS |
| File with no recognizable evidence block | Flags `NO RECOGNIZED EVIDENCE BLOCK`, explains the limitation | PASS |
| `--strict`/`-Strict` on a broken report | Exit 1 | PASS |
| `--strict`/`-Strict` on a clean report | Exit 0 | PASS |

**A real bug was caught and fixed here**: a bash `set -e` footgun —
calling a function that `return`s non-zero at the top level of a
script under `set -euo pipefail` aborts the whole script silently,
*before* the caller ever captures the exit code via `$?`. The original
version of this checker silently exited (with no output at all after
"Checking: ...") on every file using the table format, since
`check_colon_list` correctly returns 1 (not found) for those files and
that non-zero return killed the script before `check_table` ever ran.
Fixed by using the `cmd || var=$?` idiom (exempted from `errexit`)
instead of `cmd; var=$?`. Re-tested afterward — all 7 fixtures above
are the *post-fix* results.

**PCC validation:** found zero real `VERIFICATION-REPORT`-shaped files
(after excluding the blank `.template.md` copies PCC's own
`ai-engineering/` install carries) — exactly as predicted, since PCC's
real evidence practice is rich inline prose in `docs/ISSUES.md`/
`docs/REFACTOR-REGISTER.md`, not this template's shape. This proves the
tool behaves correctly on a large real repo (no crash, correct "none
found" report) and nothing more — it does not exercise the field-
checking logic itself, which is what the synthetic fixtures above
validate. Also refined the default glob to exclude `*.template.md`
after PCC's own blank template copies showed up as noisy false
"NO RECOGNIZED EVIDENCE BLOCK" hits on a genuinely blank template.

---

## Item 2 — protected-path change detection

**Synthetic fixtures:** a scratch repo with `AGENTS.md` protecting
`backend/app/auth.py` and `docs/SECRETS.md`.

| Scenario | Expected | Result |
|---|---|---|
| Staged change to an unprotected file | Clean, exit 0 | PASS |
| Staged change to a protected file | `PROTECTED PATH TOUCHED`, exit 1 | PASS |
| Same, with `--advisory`/`-Advisory` | Flags but exit 0 | PASS |

**PCC validation (read-only — no hook installed, no write to PCC):**

Ran the extractor against PCC's real, messy protected-paths block
verbatim. Extracted 10 tokens from 5 prose lines:
`backend/app/main.py`, `backend/app/routers/trading.py`,
`backend/app/services/settrade_client.py`, `backend/backups/`,
`backend/pcc.db`, `backend/scripts/import_excel.py`, `docs/ISSUES.md`,
`start.bat`, `start-dev.bat/stop-dev.bat`, `Stop PCC.bat`. Confirmed
real limitations, not hidden: the quoted route pattern
`(/api/trading/*)` was correctly discarded as non-file noise (leading
`/`); the compound `start-dev.bat/stop-dev.bat` extracted as one token
rather than two separate files — a real false-negative if either file
is touched alone, a known parsing limitation, not silently patched
over with a fragile heuristic.

Cross-checked detection accuracy against real history: `git log`
(read-only) found `3ebedfd` ("fix: apply Settrade order-value ceiling
to all price types (ISSUES.md #66)") as a real commit touching
`backend/app/services/settrade_client.py` — the money-path batch from
pilot #2's field-test report. That exact path is in the extracted
token list, confirming the extractor would have flagged the file the
project itself already treats as protected. (Note: `git diff --name-
only <ref>` diffs a ref against the *current working tree*, not against
another specific commit — using `--ref 3ebedfd~1` shows everything
changed since, not just that one commit. The accuracy claim above is a
direct comparison of the known 2 files that commit changed against the
extracted token list, not a live invocation of `--ref` for historical
inspection, which isn't what that flag is for.)

---

## Item 3 — CI regression-gate template

**Synthetic fixtures:**

| Scenario | Expected | Result |
|---|---|---|
| No baseline file yet | Bootstraps, records current count | PASS |
| Same count next run | No regression | PASS |
| Test removed, count drops | `REGRESSION` flagged, exit 1 | PASS |
| Suppression comment (`# noqa`) added | `SUPPRESSION COMMENT(S) ADDED` flagged | PASS |
| Assertion removed, none added | `ASSERTION(S) REMOVED` flagged | PASS |
| `--advisory`/`-Advisory` on a flagged diff | Flags but exit 0 | PASS |

**A real bug was caught and fixed here**: the test-count extraction
used `tr -dc '0-9'` (bash) / `-replace '\D',''` (PowerShell), which
strips all non-digit characters and *concatenates every remaining
digit* rather than taking the first number. Realistic tool output like
pytest's `"219 tests collected in 5.10s"` would become `"219510"`, not
`219`. Caught only once tested against PCC's real pytest output, not
by any of the clean synthetic fixtures above (which all used bare-
number command output). Fixed in both implementations to take the
first `[0-9]+` match only; re-verified against the exact
`"219 tests collected in 5.10s"` string, and against two consecutive
real runs, before moving on.

**PCC validation (read-only — `pytest --collect-only` does not execute
tests; baseline file written to a scratch path outside PCC, nothing
written into PCC itself):** ran the fixed counting logic against PCC's
real backend suite via its existing `.venv`:

```
219 tests collected in 5.10s
```

**Extracted count: 219 — exactly matching `docs/REFACTOR-REGISTER.md`'s
own independently-recorded "219 final" figure.** This is real,
non-trivial validation: the counting mechanism works against a large,
genuine test suite and cross-checks against a number PCC recorded
itself, through a completely different process (its own campaign
closeout), not fabricated for this test.

**What this does not validate**: the manipulation-smell heuristics
(suppression comments, assertion removal) were only exercised against
synthetic diffs above — no real malicious PCC diff exists to test
against, and none was manufactured against PCC's actual history.

**Deliberately not implemented this round**: a "decreased numeric
threshold near a keyword like coverage/min_score" heuristic was
considered in the original plan and scoped out — matching before/after
line pairs for a semantically-similar threshold robustly, in a portable
shell script, has a much higher false-positive/complexity cost than the
two heuristics shipped. Noted as a real scoping decision, not a silent
drop.

---

## Item 4 — skill supply-chain allowlist visibility

**Synthetic fixtures:** a scratch `.claude/skills/` with framework-owned
skills plus one custom skill (`custom-tool`).

| Scenario | Expected | Result |
|---|---|---|
| Empty allowlist table | `custom-tool` flagged `UNREGISTERED` | PASS |
| Allowlist has a filled row for `custom-tool` | `OK (registered)`, no flag | PASS |

**PCC validation (read-only):** ran against PCC's real
`.claude/skills/`, which contains a genuine, currently-unregistered
custom skill, `analyze-stock`, against PCC's real allowlist table
(the same empty `| | | | | |` row as this framework's own copy). The
checker correctly flagged it:

```
UNREGISTERED SKILL: analyze-stock (present in .claude/skills, no row in ai-engineering/policies/skill-supply-chain.md's allowlist)
```

A true positive on live, real data — not a synthetic one. The synthetic
"properly registered" fixture above covers the branch PCC's own data
can't exercise (nothing in PCC's table is filled in), so both branches
are validated between the two runs, not just the failure case.

---

## Summary

| Item | Synthetic fixtures | Real-target (PCC) result | Bugs found & fixed |
|---|---|---|---|
| 1 — evidence linting | 7/7 pass (both implementations) | Correctly reports zero matches, doesn't crash | `set -e` silent-abort bug |
| 2 — protected-path detection | 3/3 pass (both implementations) | 10 real tokens extracted; real historical detection confirmed | none |
| 3 — CI regression gate | 6/6 pass (both implementations) | Count (219) matches PCC's own recorded history exactly | multi-digit concatenation bug |
| 4 — skill allowlist visibility | 2/2 pass (both implementations) | True positive on PCC's real unregistered `analyze-stock` skill | none |

Two real bugs surfaced by testing against realistic and real data that
none of the initial synthetic fixtures caught on their own — the
value of the real-target validation step the plan called for, not a
formality.
