---
description: Write failing tests that encode the case's numbered criteria, stop at Gate 2, then commit them as the test baseline
argument-hint: "[case-id]"
---

# /story-3-tdd-red

Step 3 of the `/story-*` loop. Turns the numbered acceptance criteria into failing tests, stops at
**Gate 2**, and — only after approval — commits them as the build's **test baseline**. No product
code is written here.

Argument (optional): `$ARGUMENTS` — a case ID or its short name. Omitted, it resolves to the most
recently modified live case.

## Run this

1. **Load the skills.** `story-context-home` (case resolution, `STATE.json`, commit format), then
   `story-tdd` (the red phase itself). On a follow-up (`workflow: "followup"`), also
   `story-followup`.
2. **Resolve the case** and name it in your first line of output. Read `PLAN.md` —
   `## Acceptance criteria` and `## Commands` are what you need; `ARCHITECTURE.md` if the shape is
   unclear; `## Test changes` if this is a follow-up.
3. **Check `STATE.json`.** `current_step` should be `modeled`. If it is not, say what state the
   case is in and ask before proceeding.
4. **Write the tests** into the project repo per the `story-tdd` skill — never into the case home.
   Each numbered criterion gets at least one test that names it.
5. **Run them** with the narrow test command from `## Commands`, verbatim, from the directory it
   records. Confirm they fail *for the right reason*; if they do not, fix the tests and re-run
   before presenting anything.
6. **Amend `PLAN.md`** with whatever writing the tests turned up. If what it turned up changes
   **scope or shape** rather than wording, stop and send the user back to `/story-2-plan` —
   set `current_step` back to `planned` and say why.
7. **Gate 2** — present, then stop:
   - the test files or their diff, with the criterion each test encodes,
   - the real red output,
   - the amendment to `PLAN.md`, if any,
   - anything a criterion could not express as a test, and why.

   Hand back with: *read the tests — they are the contract the build is measured against.*
8. **On approval, commit the baseline.** Stage the test files and `PLAN.md`, nothing else. Commit
   per `story-context-home`. Record the hash in `STATE.json` as `test_baseline_commit_hash`, set
   `current_step: "tested-red"`, `next_command: "/story-4-tdd-green"`, and update `STATUS.md`.
9. **End with the `What's next` block.**

## When the user comes back with changes

Amend the tests, re-run, re-present the real red output, and stop at Gate 2 again. Commit only
once, after the approval that sticks. Questions raised here append to `## Open Questions` in the
user's words.

## This command never

- Writes product code — that is `/story-4-tdd-green`'s only job, and mixing the two produces
  green-but-meaningless tests.
- Commits before the user has approved the tests.
- Writes into the case home beyond `PLAN.md`'s amendment, the status line, and `## Open Questions`.
- Advances to `/story-4-tdd-green` on its own.
