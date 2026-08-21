---
description: Open a follow-up case under a parent — record the checkout, scaffold the nested home, run delta research
argument-hint: "<parent-case-id> [short description]"
---

# /story-followup-1-start

Step f1 of the follow-up flow. Opens a subtask against an existing case: links it to the parent,
records the checkout it is run in, scaffolds the **nested** case home, and runs delta research.

Arguments: `$ARGUMENTS` — the **parent case ID** (required, never inferred) followed by an
optional description of what went wrong or what the review asked for.

**Set the worktree up yourself first.** This command creates none and checks for none:

```bash
git worktree add -b <followup-branch> <path>/<followup-branch> <parent-branch>
cd <path>/<followup-branch>
```

## Run this

1. **Load the skills.** `story-context-home`, `story-followup` (the whole compressed path), and
   `story-intake` (its delta form).
2. **Resolve the parent** from the first argument. It may be **in progress or already wrapped** —
   both are fine; a wrapped parent keeps its durable artifacts and its `## Follow-ups` table for
   exactly this. If the argument is missing, ask; never guess a parent.
3. **If a case home for this follow-up already exists in this checkout, this is another round.**
   Bump `STATE.json.round`, leave `PLAN.md` and the parent's `## Follow-ups` row alone, and go
   straight to research. Do not re-scaffold.
4. **Record the checkout.** `git rev-parse --show-toplevel` and `git branch --show-current` — put
   them in `STATE.json` as `worktree` and `branch`. Recorded, never created. If this is the same
   checkout as the parent's, say so plainly and let the user decide whether that is what they want.
5. **Run delta intake** per `story-intake`'s follow-up form: what went wrong, in the user's words,
   and an approved short name. **Inherit** the project, repo, and `## Commands` from the parent's
   `PLAN.md` — do not re-ask.
6. **Scaffold the nested home** at `<parent-home>/<YYYY-MM-DD>_<short-name>/`: `STATE.json`
   (`parent`, `workflow: "followup"`, `round: 1`, `worktree`, `branch`,
   `next_command: "/story-followup-2-plan"`), `STATUS.md` linking `../`, and `PLAN.md` with
   `## Context` only.
7. **Register the row** in the **parent's** `PLAN.md` `## Follow-ups` table — case ID, one line,
   status `open`. Create the section if the parent has none.
8. **Launch `story-researcher`** with the case ID, home path, and delta brief. It reads the
   parent's artifacts first and researches only what is new; its `RESEARCH.md` is **transient**
   and capped at 40 lines.
9. **Read `RESEARCH.md` back**, summarize it, record the handoff pair, and stop for the user to
   read it and answer any open questions.
10. **End with the `What's next` block.**

## This command never

- Creates, moves, or removes a worktree or a branch — it records the one it finds itself in.
- Infers the parent, or creates a follow-up without one.
- Re-scaffolds an existing home; a second run in the same checkout is a **round**.
- Writes into the parent's home beyond the `## Follow-ups` row.
- Advances to `/story-followup-2-plan` on its own.
