---
description: Orient in a story case after a break — report where it stands and what comes next. Read-only.
argument-hint: "[case-id]"
---

# /story-resume

The fresh-session entry point. Tells you where a case stands and which command comes next. It
**never advances the flow** and writes nothing.

Argument (optional): `$ARGUMENTS` — a case ID or its short name. Omitted, it resolves to the most
recently modified case home.

## Run this

1. **Load `story-context-home`** for case resolution and the meaning of the status line.
2. **Resolve the case.** With an argument, glob `~/.claude/plans/*/*<arg>*` for a directory
   containing `plan.md`; several matches → list them and ask. Without one, take the most recently
   modified case home under `~/.claude/plans/*/*/`. Flat `*.md` plan files are not cases — skip
   them.
3. **Read `plan.md`.** The `## Workflow status` line tells you the state and the next command;
   that is what this command exists to surface.
4. **Report**, in this order:
   - the case ID and its case home path,
   - the status line: state, next command, when it was last updated,
   - scope in one line — what is being built,
   - anything unanswered in `## Open Questions`,
   - the `## Build record` or `## Divergence Log` if the case has reached them,
   - **the next command, spelled out**, e.g. ``run `/story-tdd-red 2026-08-04_add-queue-selection` ``.
5. **Pre-read that step's inputs** so the next command starts warm — for `/story-tdd-red`, the
   acceptance criteria and the commands table; for `/story-build`, the plan and the red tests;
   for `/story-check`, nothing beyond the plan (the divergence agent must read the code cold).
6. **Stop.** Hand back. Do not run the next command, and do not offer to run it — say what it is
   and let the user type it.

## If several cases are live

List every case home whose status line is not `done`, most recently modified first, with its
state and next command. Then ask which one. Do not pick for the user.

## If the case looks finished

A status line of `checked` means the loop is complete and the remaining step is the user's:
build it and test it by hand. Say that, and mention that marking the line `done` is theirs to do.

## This command never

- Writes to `plan.md`, `diagrams.md`, the project repo, or git. It is strictly read-only —
  including the status line, which it reports but never updates.
- Runs the next step, or any part of it.
- Creates a case home.
