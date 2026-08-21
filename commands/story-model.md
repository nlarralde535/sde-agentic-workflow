---
description: Optional, any time — draw the manual-testing flows as user-flow diagrams. Learning only, deleted at wrap.
argument-hint: "[case-id]"
---

# /story-model

**Optional, off-flow, any time after step 2.** Draws `MANUAL_TESTING.md`'s procedures as
user-flow sequence diagrams so you can see the change from the user's seat rather than the
system's. `MODEL.md` is a **learning aid**: transient, read by nothing downstream, deleted by the
wrap.

Argument (optional): `$ARGUMENTS` — a case ID or its short name. Omitted, it resolves to the most
recently modified live case.

## Run this

1. **Load `story-context-home`** and resolve the case. Name it.
2. **Launch `story-planner` in `flows` mode**, passing the case ID and home. It reads
   `MANUAL_TESTING.md` for the procedures and `ARCHITECTURE.md` for vocabulary, and writes
   `MODEL.md`.
3. **Render the diagrams inline** in your reply and offer zoom-ins — those are drawn **in the
   conversation** and never written to a file.
4. **Do not touch `STATE.json`'s `current_step` or `next_command`.** This command advances
   nothing; the flow is exactly where it was.
5. **End with the `What's next` block**, rendering the unchanged `next_command`.

## This command never

- Advances the flow, or changes any state but the existence of `MODEL.md`.
- Redraws the architecture at a second altitude — that is the "one altitude, no tiers" rule, and
  a request that really means "help me understand the components" is answered in conversation.
- Writes into `ARCHITECTURE.md`, `PLAN.md`, or the project repo.
- Commits, or survives the wrap.
