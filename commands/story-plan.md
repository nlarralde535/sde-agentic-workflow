---
description: Open a story case — intake, then write plan.md and diagrams.md, then stop at Gate 1
argument-hint: "[short description of what you want to build]"
---

# /story-plan

Step 1 of the `/story-*` loop. Opens a case: gathers context, creates the case home, writes both
documents, and stops at **Gate 1**.

Argument (optional): `$ARGUMENTS` — a first sketch of the change. Treat it as the opening line of
intake, not as a specification.

## Run this

1. **Load the skills.** `story-context-home` (path convention, document shape, budgets, status
   line), then `story-intake` (the conversation), then `story-diagrams` (PLANNED mode).
2. **Run intake** per the `story-intake` skill. It ends when you have: the change, the `<PARENT>`,
   the repo path and branch, an approved `<descriptive-short-name>`, and the three commands.
   **Nothing is written to disk before the user has approved the case home path.**
3. **Create the case home** at `~/.claude/plans/<PARENT>/<YYYY-MM-DD>_<short-name>/`, using
   today's date from the session environment.
4. **Write `plan.md`** from `story-context-home/templates/plan.md`. Scope states what is being
   built *and* what is not; 2–4 phases each with its own validation; acceptance criteria as
   observable behaviors, because they become the red tests verbatim in the next step. Hold the
   ≤ 80-line budget.
5. **Write `diagrams.md`** in PLANNED mode per the `story-diagrams` skill.
6. **Set the status line:** `planned · next `/story-tdd-red` · updated <today>`.
7. **Gate 1** — present, then stop:
   - the case home path,
   - scope (building / not building), the phases, the acceptance criteria,
   - both diagrams, rendered inline in your reply,
   - any open questions.

   Then hand back with: *read the plan and the diagrams, and ask questions until you could defend
   them.* Do not run the next command, and do not offer to.

## When the user comes back with answers

Amend **in place** — the same `plan.md` and the same `diagrams.md`, never a new file and never an
appended revision. Answers change the section they bear on: scope, phases, criteria, or the
diagrams. Append the exchange to `## Open Questions` in the user's own words; that section is
never edited or summarized.

Re-present the changed parts only, and stop at Gate 1 again.

## This command never

- Guesses `<PARENT>` or invents a case ID — both come from the user (`story-intake`).
- Writes anything into the project repo.
- Creates, switches, or merges a branch.
- Commits. Nothing is committed until `/story-build`.
- Advances to `/story-tdd-red` on its own.
