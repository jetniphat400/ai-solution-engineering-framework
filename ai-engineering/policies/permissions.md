# Permission Profiles

[established practice — least privilege / role-based access control, Saltzer & Schroeder]

## READ_ONLY
Read, search, analyze, and report. No edits or executions that mutate state.

## STANDARD_DEVELOPMENT
Edit source and tests in a working branch; run approved local development checks. Ask before adding dependencies or using network access.

## CONTROLLED_CHANGE
Work only after an approved plan. Protected assets, migrations, infrastructure, and release actions require human approval.

## REVIEW_ONLY
Read-only independent review. No fixes in the same context.

## RELEASE_OPERATOR
Trigger approved pipelines and collect evidence. No self-approval and no direct secret disclosure.

Prohibited by default: reading secrets, bypassing permissions, destructive production actions, or direct production shell access. [established practice — default-deny posture, least privilege]
