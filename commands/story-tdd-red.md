---
description: Write failing tests that encode the case's acceptance criteria, run them, stop at Gate 2
argument-hint: "[case-id]"
---

# /story-tdd-red

Step 2 of the `/story-*` loop. Turns the acceptance criteria into failing tests and stops at
**Gate 2**. No product code is written here.

Argument (optional): `$ARGUMENTS` — a case ID or its short name. Omitted, it resolves to the most
recently modified case home.

## Run this

1. **Load the skills.** `story-context-home` (case resolution, the status line), then `story-tdd`
   (the red phase itself).
2. **Resolve the case** per `story-context-home`. Name the case you resolved to in your first
   line of output. Read its `plan.md` — `## Acceptance criteria` and `## Commands` are what you
   need; `diagrams.md` if the shape is unclear.
3. **Check the status line.** If it is not `planned`, say what state the case is actually in and
   ask before proceeding.
4. **Write the tests** into the project repo per the `story-tdd` skill — never into the case home.
5. **Run them** with the narrow test command from `## Commands`, verbatim, from the directory it
   records. Confirm they fail *for the right reason*; if they do not, fix the tests and re-run
   before presenting anything.
6. **Set the status line:** `tested-red · next `/story-build` · updated <today>`. This is the only
   edit this command makes to `plan.md`, unless the gate produces open questions.
7. **Gate 2** — present, then stop:
   - the test files, with the acceptance criterion each one encodes,
   - the real red output,
   - anything a criterion could not express as a test, and why.

   Then hand back with: *read the tests — they are the contract the build cannot change.* Do not
   run `/story-build`, and do not offer to.

## When the user comes back with changes

Amend the tests, re-run, re-present the red output, and stop at Gate 2 again. Questions raised
here append to `## Open Questions` in `plan.md`, in the user's words.

## This command never

- Writes product code — that is `/story-build`'s only job, and mixing the two produces
  green-but-meaningless tests.
- Writes into the case home except the one status line (and `## Open Questions`).
- Commits. The tests are committed by the builder, with the code that satisfies them.
- Advances to `/story-build` on its own.
