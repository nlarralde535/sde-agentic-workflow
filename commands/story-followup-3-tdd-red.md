---
description: Thin wrapper — runs /story-3-tdd-red on a follow-up case
argument-hint: "[case-id]"
---

# /story-followup-3-tdd-red

Step f3 of the follow-up flow. **A thin wrapper with no logic of its own.**

Do exactly what `commands/story-3-tdd-red.md` says, on the resolved follow-up case. Load that
command's file and follow it; `story-tdd` and `story-context-home` already behave correctly when
`STATE.json.workflow` is `"followup"`, and the tests to write are the ones `PLAN.md`'s
`## Test changes` list enumerates — usually edits to existing test files.

The two differences are naming, not behavior:

- the baseline commit's trailer is `Case: <parent-id> > <followup-id>`, and it lands on the
  follow-up branch recorded in `STATE.json`,
- `next_command` becomes `/story-followup-4-tdd-green`.

This wrapper exists so the sequence the user types reads 1→6 and so `next_command` has a name to
point at. **If you are about to write a rule here, it belongs in `/story-3-tdd-red` or in the
`story-followup` skill.**
