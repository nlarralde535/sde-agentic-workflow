---
description: Launch the story-builder agent to make the red tests green, then relay its summary
argument-hint: "[case-id]"
---

# /story-build

Step 3 of the `/story-*` loop. Hands the case to the **`story-builder`** agent, which runs in an
isolated context so implementation detail stays out of this session. There is no gate here — the
agent's local commit is the checkpoint.

Argument (optional): `$ARGUMENTS` — a case ID or its short name. Omitted, it resolves to the most
recently modified case home.

## Run this

1. **Load `story-context-home`** and resolve the case. Name the case you resolved to.
2. **Check the status line.** It should read `tested-red`. If it does not, say what state the case
   is in and ask before launching — the builder builds against a contract that may not exist yet.
3. **Launch the agent** with `subagent_type: story-builder`, passing the resolved case ID and its
   case home path. Do not restate the plan to it; it reads `plan.md` itself.
4. **Relay its summary** when it returns — phases completed, the one-line verdict, the commit
   hash and subject, and **any deviation it reported**. Relay the deviation verbatim; do not
   soften it or fold it into a sentence about success.
5. **Point at `/story-check`** as the next step. Do not run it.

## If the agent stopped

If it stopped because a test looks wrong, or because it could not reach green: relay exactly what
it said and stop. Do not re-launch it with instructions to work around the test, and do not fix
the test yourself. A test that needs changing is the user's call, and the change is made by
re-running `/story-tdd-red` — the contract is amended in the open, not during a build.

## This command holds no logic

Everything about how the build is done lives in the `story-builder` agent and the
`story-context-home` skill. This command parses an argument, launches, and relays. If you find
yourself implementing, verifying, or committing here, you are in the wrong file.

## This command never

- Writes product code or tests in the main session.
- Edits a test to unblock the agent.
- Commits — the agent owns the single commit for this step.
- Advances to `/story-check` on its own.
