---
description: Launch the story-builder agent to make the red tests green, then audit the test diff against the baseline
argument-hint: "[case-id]"
---

# /story-4-tdd-green

Step 4 of the `/story-*` loop. Hands the case to the **`story-builder`** agent, which runs in an
isolated context so implementation detail stays out of this session. When it returns, this session
**audits the test files against the baseline commit** and surfaces anything the builder did not
explain.

Argument (optional): `$ARGUMENTS` — a case ID or its short name. Omitted, it resolves to the most
recently modified live case.

## Run this

1. **Load `story-context-home`** and resolve the case. Name the case you resolved to.
2. **Check `STATE.json`.** `current_step` should be `tested-red` and `test_baseline_commit_hash`
   should be set. If either is missing, say so and ask — the builder builds against a contract
   that may not exist yet, and without the hash there is nothing to audit against.
3. **Launch the agent** with `subagent_type: story-builder`, passing **only** the case ID and the
   case home path. Do not restate the plan, summarize the research, or describe the design: the
   plan's `## For the builder` section is the prompt, by design. A builder briefed by a chat
   summary builds the summary.
4. **Audit the test diff** when it returns:
   `git -C <repo> diff <test_baseline_commit_hash>..HEAD -- <the test paths>`.
   - No changes → say so in one line.
   - Changes the builder's `Test changes:` line explains → relay both, together.
   - **Changes it did not explain** → surface each one to the user as a finding: which file, what
     changed, and that the builder gave no reason. **Never revert it yourself** and never wave it
     through. This is the whole point of the baseline.
5. **Relay its summary** — phases completed, the one-line verdict, the commit hash and subject,
   the `Test changes:` line, and **any deviation it reported, verbatim.** Do not soften a
   deviation or fold it into a sentence about success.
6. **Record the handoff pair:** `current_step: "built"`, `next_command: "/story-5-check"`, update
   `STATUS.md`.
7. **End with the `What's next` block.**

## If the agent stopped

If it stopped because a test looks wrong, or because it could not reach green: relay exactly what
it said and stop. Do not re-launch it with instructions to work around the test, and do not fix
the test yourself. A test that needs changing is the user's call, and the change is made by
re-running `/story-3-tdd-red` — the contract is amended in the open, not during a build.

## This command holds no logic

Everything about how the build is done lives in the `story-builder` agent and the
`story-context-home` skill. This command resolves a case, launches, audits the diff, and relays.
If you find yourself implementing, verifying, or committing here, you are in the wrong file.

## This command never

- Writes product code or tests in the main session.
- Edits or reverts a test — including one the builder changed without explaining.
- Commits — the agent owns the single commit for this step.
- Skips the diff audit because the builder said it changed nothing.
- Advances to `/story-5-check` on its own.
