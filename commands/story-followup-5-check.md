---
description: Thin wrapper — runs /story-5-check on a follow-up case, refreshing the parent's architecture
argument-hint: "[case-id]"
---

# /story-followup-5-check

Step f5 of the follow-up flow. **A thin wrapper with no logic of its own.**

Do exactly what `commands/story-5-check.md` says, on the resolved follow-up case. The
`story-checker` agent reads `STATE.json.workflow` itself and lands its work on the parent, because
a follow-up has no diagrams of its own:

- `../ARCHITECTURE.md` is refreshed **in place**,
- the by-hand procedure is reconciled under `../MANUAL_TESTING.md`'s `## Follow-ups`,
- the `## Divergence Log` is written into the **follow-up's** own `PLAN.md`,
- the docs-only commit is made from the worktree recorded in `STATE.json`,
- `next_command` becomes `/story-followup-6-wrap`.

Gate 3 is the same gate: read the divergence log, then work through the parent's `## Follow-ups`
procedure by hand.

**If you are about to write a rule here, it belongs in `/story-5-check`, the `story-checker`
agent, or the `story-followup` skill.**
