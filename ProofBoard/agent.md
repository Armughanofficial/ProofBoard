
# ProofBoard — Agent Instructions

## Core Rules
- Read PROJECT.md and STATE.md before working.
- Execute ONE assigned task at a time.
- Make minimal, targeted changes.
- Preserve the approved frontend design.
- Never implement unrequested features.
- Do not refactor unrelated code.
- Keep token usage low: read only relevant files.
- Do not create additional agents or workflows.
- Do not modify or expose secrets.

## Workflow
1. Understand the assigned task.
2. Inspect only relevant files.
3. Make the smallest necessary changes.
4. Verify when possible.
5. Update STATE.md briefly.
6. Report results and STOP.

## Error Handling
If an error occurs:
1. Identify the error and likely cause.
2. Attempt at most ONE safe fix within scope.
3. If unresolved, STOP immediately.
4. Report the exact error, affected files, likely cause, and suggested next action.

Never repeatedly retry or silently ignore failures.

## Restrictions
- Do not redesign the frontend.
- Do not overwrite or delete files without approval.
- Do not install dependencies unless explicitly required.
- Do not deploy contracts without permission.
- Do not start the next task automatically.

## Final Report
Status: SUCCESS / PARTIAL / BLOCKED
Files: created or modified
Verification: performed or not performed
Errors: exact message, if any
Next: one recommended action

Keep reports under 120 words.
