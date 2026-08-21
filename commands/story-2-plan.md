---
description: Write the plan, stop at Gate 1, then on approval draw the shape and the manual-test procedures
argument-hint: "[case-id]"
---

# /story-2-plan

Step 2 of the `/story-*` loop. Two passes through the **`story-planner`** agent with your approval
between them: `plan` writes `PLAN.md` and stops at **Gate 1**; `model` draws `ARCHITECTURE.md` and
writes `MANUAL_TESTING.md` and hands them over for you to read.

Argument (optional): `$ARGUMENTS` — a case ID or its short name. Omitted, it resolves to the most
recently modified live case.

## Run this

1. **Load `story-context-home`** and resolve the case. Name the case you resolved to.
2. **Check `STATE.json`.** `current_step` should be `started` (first run) or `planned` (re-entry,
   which resumes at pass 2 without rewriting the plan). Anything else — say what state the case
   is in and ask.
3. **Pass 1 — launch `story-planner` in `plan` mode**, passing the case ID and case home path. It
   reads `RESEARCH.md` itself; do not restate it.
4. **Present for Gate 1**, then stop:
   - scope — building and not building,
   - the phases, each with its validation,
   - the acceptance criteria **by number**,
   - `## For the builder`, so the user can see what the builder will actually be told,
   - any open questions, verbatim.

   Hand back with: *answer the open questions and approve the plan.* Record `current_step:
   "planned"` **after** approval, not before.
5. **Pass 2 — on approval, launch `story-planner` in `model` mode.** It writes `ARCHITECTURE.md`
   (PLANNED) and one ≤ 5-step manual procedure per criterion in `MANUAL_TESTING.md`.
6. **Hand the shape over.** Render both diagrams inline in your reply, summarize what the sequence
   shows, and list the manual procedures by criterion number. This is a **read**, not a gate:
   present it and end. Set `current_step: "modeled"`, `next_command: "/story-3-tdd-red"`, update
   `STATUS.md`.
7. **End with the `What's next` block.**

## If the shape exposes a hole in the plan

The planner is told to stop rather than patch the plan quietly. If it does — or if the user reads
the diagrams and finds one — go **back to pass 1** with what was found, and set `current_step`
back to `planned`. That backward edge is the point of splitting the passes; a plan corrected here
costs an hour, and corrected after the build costs the build.

## When the user comes back with answers

Amend **in place** — the same `PLAN.md`, the same `ARCHITECTURE.md`, never a new file and never an
appended revision. Answers change the section they bear on. Append the exchange to
`## Open Questions` in the user's own words. Re-present the changed parts only, and stop at the
same gate again.

## This command holds no logic

How the plan is written, what the sections mean, and how the diagrams are drawn all live in the
`story-planner` agent and the `story-context-home` / `story-architecture-diagram` skills. This
command resolves a case, launches, gates, and records.

## This command never

- Runs both passes without stopping at Gate 1 in between.
- Writes `PLAN.md` or `ARCHITECTURE.md` itself in the main session.
- Writes anything into the project repo, or commits.
- Advances to `/story-3-tdd-red` on its own.
