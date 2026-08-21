---
description: Plan a follow-up against its parent's shape — scope, numbered criteria, the test-change list, then Gate 1
argument-hint: "[case-id]"
---

# /story-followup-2-plan

Step f2 of the follow-up flow. Writes the follow-up's `PLAN.md` and presents it **against the
parent's diagrams** — a follow-up draws none of its own. One pass, one gate.

Argument (optional): `$ARGUMENTS` — a case ID or its short name. Omitted, it resolves to the most
recently modified live case.

## Run this

1. **Load `story-context-home` and `story-followup`.** Resolve the case; confirm
   `workflow: "followup"` and name the parent.
2. **Launch `story-planner` in `plan` mode**, passing the case ID and home. On a follow-up that
   mode also writes:
   - **"Builds on parent"** — the delta research distilled into a **self-contained** section that
     cites the parent's already-mapped files, patterns, and contracts. It must stand on its own,
     because the transient `RESEARCH.md` it came from will not survive the wrap.
   - **`## Test changes`** — the test edits the red step will author, usually to existing files.
   - scope, 1–3 phases, numbered acceptance criteria, `## For the builder`. **≤ 60 lines covers
     everything.**
3. **Present the parent's sequence diagram first**, and name **which arrows this follow-up
   changes**. That framing is what replaces a diagramming pass: the user reads the delta against a
   shape they already know.
4. **Gate 1** — present the plan, the test-change list, and the open questions; hand back with:
   *read it against the parent's diagrams, then approve.* Amendments land **in place**.
5. **On approval**, set `current_step: "planned"`, `next_command: "/story-followup-3-tdd-red"`,
   update `STATUS.md`.
6. **End with the `What's next` block.**

## This command never

- Draws a diagram, or writes an `ARCHITECTURE.md` for the follow-up.
- Writes a `MANUAL_TESTING.md` of its own — the by-hand procedure is appended to the parent's file
  at the check.
- Edits the parent's scope, phases, or acceptance criteria.
- Advances to `/story-followup-3-tdd-red` on its own.
