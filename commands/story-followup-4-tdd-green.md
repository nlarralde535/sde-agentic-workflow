---
description: Thin wrapper — runs /story-4-tdd-green on a follow-up case
argument-hint: "[case-id]"
---

# /story-followup-4-tdd-green

Step f4 of the follow-up flow. **A thin wrapper with no logic of its own.**

Do exactly what `commands/story-4-tdd-green.md` says, on the resolved follow-up case — including
the **test-diff audit** against `test_baseline_commit_hash`, which works identically here. The
`story-builder` agent reads `STATE.json.workflow` itself and adjusts where it records: a
`## Build close-out` section in the follow-up's `PLAN.md` instead of `IMPLEMENTATION.md`, and
special cases appended to the **parent's** `MANUAL_TESTING.md`.

The differences are naming and location, not behavior:

- the build runs and commits in the worktree recorded in `STATE.json`,
- `next_command` becomes `/story-followup-5-check`.

**If you are about to write a rule here, it belongs in `/story-4-tdd-green`, the `story-builder`
agent, or the `story-followup` skill.**
