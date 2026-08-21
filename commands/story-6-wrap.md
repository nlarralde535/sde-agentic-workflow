---
description: Close the case — record what shipped in the LLM Wiki, delete the transient files, make the close-out commit
argument-hint: "[case-id]"
---

# /story-6-wrap

Step 6 of the `/story-*` loop, and the last one. Records what was actually built in the LLM Wiki,
deletes the case home's transient files, and makes the close-out commit. There is no gate — the
gates were all upstream.

Argument (optional): `$ARGUMENTS` — a case ID or its short name. Omitted, it resolves to the most
recently modified live case.

## Run this

1. **Load `story-context-home`**, then **`story-wrap`** (which owns every rule below). Resolve the
   case and name it.
2. **Check `STATE.json`.** `current_step` should be `checked` or `reviewed`. If it is not, say what
   state the case is in and ask — wrapping deletes the handoff pair, and a case wrapped early has
   to be re-opened by hand.
3. **Confirm the by-hand pass happened.** `MANUAL_TESTING.md` exists so a person exercises the
   change; ask whether that has been done rather than assuming Gate 3 covered it.
4. **Write the wiki entry** per `story-wrap` — the `llm-wiki` skill, describing reality rather
   than plan intent, citing criteria by number, with this case in `plan-refs:` and the case's
   commit hashes in `commits:`. This is the workflow's only wiki write.
5. **Delete the transients:** `STATE.json`, `STATUS.md`, every `STATUS-<agent>.md`, and `MODEL.md`
   if one was drawn. The durable set stays.
6. **Commit** the close-out per `story-context-home`, staging only this case's files. Never push.
7. **End with the `What's next` block.** For a wrapped case that is: the branch is yours to merge
   or open a PR from, and a new case starts with `/story-1-start`. `next_command` no longer comes
   from `STATE.json` — it is gone, and that absence is what marks the case wrapped.

## This command holds no logic

The wiki write-up, the deletion list, and the commit rules live in the `story-wrap` skill. This
command resolves a case, checks the state, delegates, and reports.

## This command never

- Merges anything. `/story-6-wrap` performs no git integration at all; only the follow-up wrap
  merges, and never into a shared branch.
- Pushes.
- Deletes a durable artifact, or the case home itself.
- Edits the plan's scope, phases, or criteria on the way out — the case is what it was.
- Wraps a case the user has not had the chance to test by hand.
