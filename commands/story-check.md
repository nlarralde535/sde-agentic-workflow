---
description: Launch the story-divergence agent to refresh the diagrams and log divergences, stop at Gate 3
argument-hint: "[case-id]"
---

# /story-check

Step 4 of the `/story-*` loop. Hands the case to the **`story-divergence`** agent, which
re-derives the change's shape from the code, refreshes `diagrams.md` in place, and writes the
`## Divergence Log`. Stops at **Gate 3**.

Argument (optional): `$ARGUMENTS` — a case ID or its short name. Omitted, it resolves to the most
recently modified case home.

## Run this

1. **Load `story-context-home`** and resolve the case. Name the case you resolved to.
2. **Check the status line.** It should read `built`. If it does not, say so and ask — there is
   nothing to check against until the build has committed.
3. **Launch the agent** with `subagent_type: story-divergence`, passing the case ID and case home
   path. **Do not summarize the build for it.** Its isolation is the point: it must re-derive the
   shape from the code, and anything you tell it about what the builder did biases that.
4. **Gate 3** — present, then stop:
   - the divergence log in full,
   - which parts of the diagrams changed and how much,
   - anything the agent could not resolve from the code.

   Then hand back with: *read the divergences — for each one, was it intentional?* Do not offer
   to fix anything yet.

## When the user rules on a divergence

- **Intentional** — nothing to do; it is logged, which is the whole point.
- **Not intentional** — the fix is a **rebuild**: correct the plan or the tests as needed with
  `/story-tdd-red`, then re-run `/story-build`, then `/story-check` again. Never edit the plan's
  scope, phases, or criteria to agree with the code, and never redraw the diagram back to the
  planned shape without changing the code.

Questions raised here append to `## Open Questions`.

## This command holds no logic

The comparison, the diagram refresh, the log format, and the docs-only commit all live in the
`story-divergence` agent and the `story-diagrams` / `story-context-home` skills.

## This command never

- Reviews code quality or hunts for bugs — this is a divergence check. `/code-review` and
  `/security-review` remain available to run by hand.
- Edits the plan to match the code.
- Commits — the agent owns the docs-only commit.
- Advances anywhere. After Gate 3 the next actor is the user: build it and test it by hand.
