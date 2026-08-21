---
description: Open a story case — intake, scaffold the case home, run the research agent, stop for you to read RESEARCH.md
argument-hint: "[short description of what you want to build]"
---

# /story-1-start

Step 1 of the `/story-*` loop. Opens a case: gathers context conversationally, scaffolds the case
home, hands the research to an isolated agent, and stops for you to read what it found.

Argument (optional): `$ARGUMENTS` — a first sketch of the change. Treat it as the opening line of
intake, not as a specification.

## Run this

1. **Load the skills.** `story-context-home` (path convention, artifact shapes, `STATE.json`),
   then `story-intake` (the conversation).
2. **Run intake** per the `story-intake` skill. It ends when you have: the change, the
   `<PROJECT>`, the repo path and branch, an approved `<descriptive-short-name>`, the three
   commands, and the research brief. **Nothing is written to disk before the user has approved
   the case home path.**
3. **Scaffold the case home** at `~/.claude/plans/<PROJECT>/<YYYY-MM-DD>_<short-name>/`, using
   today's date from the session environment:
   - `STATE.json` — `current_step: "started"`, `next_command: "/story-2-plan"`, the repo and
     branch, `workflow: "standard"`, `round: 1`,
   - `STATUS.md`,
   - `PLAN.md` holding **only** `## Context` and `## Commands` from intake. The rest is the
     planner's at step 2.
   - **If a case home with this ID already exists, stop.** Say so and let the user choose a
     different name or resume the existing case — never overwrite a scaffold.
4. **Launch the research agent** with `subagent_type: story-researcher`, passing the case ID, the
   case home path, and the research brief. Pass the brief as intake composed it — **do not add
   your own conclusions about what should change.**
5. **Read `RESEARCH.md` back yourself** when the agent returns, and summarize it in your own
   words: what the change has to fit into, the risks, and the open questions **verbatim**.
6. **Record the handoff pair.** Set `current_step: "started"`, `next_command: "/story-2-plan"`,
   `updated: <today>` in `STATE.json`, and write `STATUS.md`.
7. **Stop at the read gate.** Hand back with: *read `RESEARCH.md` and answer anything under
   `## Open Questions`.* Do not run `/story-2-plan`, and do not offer to.
8. **End with the `What's next` block**, rendering `next_command` from `STATE.json`.

## When the user comes back with answers

Append the exchange to `## Open Questions` in the user's own words — that section is never edited
or summarized. If an answer changes what research found, amend the relevant section of
`RESEARCH.md` in place and say what you changed.

## This command never

- Guesses `<PROJECT>` or invents a case ID — both come from the user (`story-intake`).
- Writes anything into the project repo.
- Creates, switches, or merges a branch, or creates a worktree.
- Lets the research agent write `STATUS.md` or `STATE.json` — the handoff pair is the session's.
- Plans. Scope, phases, and acceptance criteria are step 2's, and writing them here would mean
  the plan was drafted before the research was read.
- Advances to `/story-2-plan` on its own.
