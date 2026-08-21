---
description: Launch the story-checker agent to refresh the architecture, verify, and log divergences, stop at Gate 3
argument-hint: "[case-id]"
---

# /story-5-check

Step 5 of the `/story-*` loop. Hands the case to the **`story-checker`** agent, which re-derives
the change's shape from the code, refreshes `ARCHITECTURE.md` in place, reconciles
`MANUAL_TESTING.md`, runs the verification suite, and writes the `## Divergence Log`. Stops at
**Gate 3** — the divergences, then your by-hand pass.

Argument (optional): `$ARGUMENTS` — a case ID or its short name. Omitted, it resolves to the most
recently modified live case.

## Run this

1. **Load `story-context-home`** and resolve the case. Name the case you resolved to.
2. **Check `STATE.json`.** `current_step` should be `built`. If it is not, say so and ask — there
   is nothing to check against until the build has committed.
3. **Launch the agent** with `subagent_type: story-checker`, passing the case ID and case home
   path. **Do not summarize the build for it.** Its isolation is the point: it must re-derive the
   shape from the code, and anything you tell it about what the builder did biases that.
4. **Record the verdict** the agent reports from the verification suite — one line, as it gave it.
   If the suite failed, that is the headline, above the divergences.
5. **Gate 3** — present, then stop:
   - the verification verdict,
   - the divergence log in full,
   - which parts of the architecture changed and how much, and what moved in the manual
     procedures,
   - anything the agent could not resolve from the code.

   Hand back with: *read the divergences — for each one, was it intentional? Then work through
   `MANUAL_TESTING.md` by hand.* Do not offer to fix anything yet.
6. **Record the handoff pair:** `current_step: "checked"`, `next_command: "/story-6-wrap"`, update
   `STATUS.md`.
7. **End with the `What's next` block**, naming `/story-review` and `/story-model` as the side
   doors, and `/story-followup-1-start` as what to run if the by-hand pass turns something up.

## When the user rules on a divergence

- **Intentional** — nothing to do; it is logged, which is the whole point.
- **Not intentional** — the fix is a **rebuild**: correct the plan or the tests as needed with
  `/story-2-plan` or `/story-3-tdd-red`, then `/story-4-tdd-green`, then this command again. Never
  edit the plan's scope, phases, or criteria to agree with the code, and never redraw a diagram
  back to the planned shape without changing the code.
- **A bug found during the by-hand pass** — that is a follow-up: `/story-followup-1-start` with
  this case as the parent.

Questions raised here append to `## Open Questions`.

## This command holds no logic

The comparison, the refresh, the reconciliation, the verification run, the log format, and the
docs-only commit all live in the `story-checker` agent and the `story-architecture-diagram` /
`story-context-home` skills.

## This command never

- Reviews code quality or hunts for bugs — this is a divergence check. `/story-review` is the
  optional side door for that.
- Edits the plan to match the code.
- Commits — the agent owns the docs-only commit.
- Advances to `/story-6-wrap` on its own. The next actor after Gate 3 is the user, testing by hand.
