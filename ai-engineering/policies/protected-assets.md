# Protected Assets

[established practice — protected-branch / protected-asset governance, standard in regulated change management]

Protected by default:

- Acceptance and security tests
- Golden fixtures and approved snapshots
- CI/CD workflows and quality thresholds
- Deployment safeguards and production configuration
- Migration recovery and rollback procedures
- Credentials, secrets, certificates, and signing keys

Changes require a distinct explanation, independent review, and human approval. [established practice — segregation of duties, change management]

## Protected-path enforcement override (BACKLOG-v1.2 Item 6)

The PreToolUse hook that mechanically enforces AGENTS.md's
"Project-specific protected paths" block can be downgraded from a
block to a visible warning by setting
`AI_ENGINEERING_PROTECTED_PATH_OVERRIDE=1` for the session. Setting
this variable is itself a Controlled-lane action: it must be a
deliberate choice a human makes for a specific, understood reason, not
something a script or agent sets for itself to get past a block it
finds inconvenient. There is no permanent allowlist -- the override
must be set again for each session it is needed in, and the hook
prints a visible notice on every use, naming the matched protected
pattern, so an override is never silent.
