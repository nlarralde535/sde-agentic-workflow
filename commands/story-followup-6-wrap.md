---
description: Close a follow-up — wiki, flip the parent's row, drop the transients, commit, then merge into the parent branch
argument-hint: "[case-id]"
---

# /story-followup-6-wrap

Step f6 of the follow-up flow, and the only place in the whole system that merges anything.

Argument (optional): `$ARGUMENTS` — a case ID or its short name. Omitted, it resolves to the most
recently modified live case.

## Run this

1. **Load `story-context-home`, `story-wrap`, and `story-followup`.** Resolve the case; confirm
   `workflow: "followup"`; name the parent and the branch.
2. **Check `STATE.json.current_step`** — `checked` or `reviewed`. Otherwise say so and ask.
3. **Part A, in the worktree:**
   - write the wiki entry per `story-wrap` — extend the **parent's** entry rather than creating a
     second one, unless this follow-up is genuinely its own feature,
   - **flip the parent's `## Follow-ups` row** to `wrapped`,
   - **delete the transients**: `STATE.json`, `STATUS.md`, every `STATUS-<agent>.md`, `MODEL.md`,
     and — here, unlike the standard flow — **`RESEARCH.md`**, whose content is already distilled
     into `PLAN.md`'s self-contained "Builds on parent" section,
   - **commit**, `Case: <parent-id> > <followup-id>`, never pushed. `PLAN.md` is now the only
     durable artifact this case leaves behind.
4. **Part B, the merge** — from the checkout the parent branch lives in, not the worktree:
   - **If the parent branch is `main`, `master`, or `develop`: refuse.** Stop and tell the user to
     open a **pull request**. Integrating into a shared branch is a reviewed, remote operation,
     not a local merge. Part A still stands; say that the wrap completed and only the merge was
     declined.
   - Otherwise `git merge --no-ff` the follow-up branch into the parent story branch.
   - **Conflicts:** in the parent's `## Follow-ups` table keep **every** row from both sides —
     that is the only conflict resolved automatically. **Any code conflict stops the merge** and
     goes to the user with the conflicting paths named.
5. **Leave the worktree and the branch in place** for the user to remove. Never push.
6. **End with the `What's next` block** — what was merged where, and that another round in the
   same checkout starts with `/story-followup-1-start`.

## This command holds no logic

The wiki write-up, the deletion list, and the merge policy live in the `story-wrap` and
`story-followup` skills.

## This command never

- Merges into `main`, `master`, or `develop`.
- Resolves a code conflict on the user's behalf.
- Removes a worktree or deletes a branch.
- Pushes.
- Deletes the follow-up's `PLAN.md`, or anything of the parent's beyond flipping its row.
