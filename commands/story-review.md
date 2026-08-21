---
description: Optional — dispatch code and security review over the case's branch diff, aggregate findings into REVIEW.md
argument-hint: "[case-id]"
---

# /story-review

**Optional, off-flow.** Sits between `/story-5-check` and `/story-6-wrap` on either flow, and
skipping it costs you nothing. The check is a *divergence* check; this is the audit.

Argument (optional): `$ARGUMENTS` — a case ID or its short name. Omitted, it resolves to the most
recently modified live case.

## Run this

1. **Load `story-context-home`** and resolve the case. Name it, and name the branch and the diff
   range you are about to review.
2. **Dispatch the reviews** over the case's branch diff — the built-in **`/code-review`** and
   **`/security-review`** skills. Run them for what they are good at; do not re-implement a
   reviewer here, and do not pre-filter the diff for them.
3. **Aggregate into `REVIEW.md`** in the case home: a findings table, one row per finding —
   number, severity, one-line finding, where, and a blank `Ruling` column. Uncapped, because it
   grows with findings rather than with prose. Record which reviews ran and the date.
4. **Triage with the user** — for each finding, one of three rulings, and the user makes it:
   - **fix now** → back to `/story-4-tdd-green` (via `/story-3-tdd-red` if the fix needs a test
     first, which it usually does),
   - **defer** → `/story-followup-1-start` with this case as the parent,
   - **accepted** → recorded with the reason, and that is the end of it.
   Write each ruling into the table.
5. **Record the handoff pair:** `current_step: "reviewed"`, `next_command: "/story-6-wrap"` (or
   `/story-followup-6-wrap`), update `STATUS.md`.
6. **End with the `What's next` block.**

## What this is not

Not a gate on the mandatory path, and not a substitute for `/story-5-check` — a clean review says
nothing about whether what shipped is what was designed. Run both, in that order.

## This command never

- Fixes a finding itself. Findings are triaged by the user and fixed by the build step, so the
  tests and the divergence check see them like any other change.
- Files a follow-up without being told to.
- Edits `PLAN.md` beyond nothing at all — `REVIEW.md` is its only artifact.
- Commits product code, or pushes.
