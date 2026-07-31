# Module: context-mapping

AI-maps-context. Fills `AGENTS.md`'s placeholders with evidence
instead of leaving them for a human to fill blind. Callable as a step
from `setup-configure.md` (its step 1/2) and from each `onboard-*.md`
module — this file is the single procedure; those callers only decide
*when* to invoke it, they do not restate how it works.

## Parameters

- `{TargetPath}` — the project whose `AGENTS.md` is being mapped.

## Procedure

1. Open `{TargetPath}/AGENTS.md` and list every placeholder: project
   identity, project state, default risk, technical/business owner,
   conventions, project commands, architecture summary, protected
   paths.
2. For each placeholder, attempt to fill it from the repo itself, and
   attach one of three confidence labels plus the evidence behind it:
   - **`verified`** — directly observed. A command's status is only
     `verified` if it was actually **run** in this session and its
     real output/exit code recorded; a command string found in a
     manifest file is evidence the command *exists*, not that it
     *works* — run it before calling it verified. An absence claim
     (e.g. "no lint config") is only `verified` after a search for
     the alternatives (multiple config filenames, workspace-level
     config, a script alias) — absence proven by search, never
     assumed from one missed file.
   - **`inferred`** — derived from indirect signals (a dependency
     implies a toolchain; a directory layout implies an architecture
     style). State the signal and why it points that way.
   - **`unknown`** — not derivable from the repo. Business-context
     fields (purpose, owners, default risk, conventions) are usually
     `unknown` by default — do not guess these from technical
     evidence alone, even strong evidence; ask.
3. Cross-check human-supplied facts against the repo whenever the
   check is cheap (e.g. a claimed command's manifest entry, a claimed
   absence against a quick search) — do not take a human claim over
   evidence you can verify in the same pass. [design choice —
   pilot-validated: a prior field pilot's human-supplied "no build/lint
   configured" claim was correct for one part of the codebase and
   wrong for another; the module's own "verify with evidence" step
   caught the mismatch before it shipped as an inaccurate contract.
   Treat correcting a human claim against cited evidence as expected
   behavior, not as second-guessing the user — but always show the
   evidence, never silently overwrite the claim.]
4. Record every field with: value, confidence label, evidence
   (file:line, or the command run and its result). Present the full
   table before editing anything.

## Human-approval gate

Humans review only the `inferred` and `unknown` rows — `verified`
rows carry their own evidence and don't need re-litigating. Apply
edits to `AGENTS.md` only after the human confirms the `inferred`
proposals and supplies the `unknown` values. Never silently upgrade
a label (e.g. `inferred` to `verified`) to avoid asking.

## Completion

End with one status:

- `DONE_VERIFIED` — every placeholder has a confidence-labeled value
  and the human has confirmed the `inferred`/`unknown` rows.
- `REQUIREMENT_AMBIGUOUS` — an `unknown` field remains open after
  asking.
- `NEEDS_HUMAN` — a cross-check contradicted a human-supplied fact and
  the human needs to resolve which is correct.
