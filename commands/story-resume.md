---
description: Orient in a story case after a break — report where it stands and what comes next. Read-only.
argument-hint: "[case-id]"
---

# /story-resume

The fresh-session entry point. Tells you where a case stands and which command comes next. It
**never advances the flow** and writes nothing.

Argument (optional): `$ARGUMENTS` — a case ID or its short name. Omitted, it resolves to the most
recently modified live case.

## Run this

1. **Load `story-context-home`** for case resolution and the meaning of `STATE.json`.
2. **Resolve the case.** With an argument, glob `~/.claude/plans/*/*<arg>*` and
   `~/.claude/plans/*/*/*<arg>*` for a directory containing `STATE.json`; several matches → list
   them and ask. Without one, take the most recently modified case home holding a `STATE.json`.
   Flat `*.md` plan files are not cases — skip them. **A case with no `STATE.json` is wrapped**;
   say so rather than treating it as live.
3. **Read `STATUS.md` and `STATE.json`.** That pair is what this command exists to surface; read
   `PLAN.md` only for the one line of scope and anything unanswered in `## Open Questions`.
4. **Report**, in this order:
   - the case ID and its home path — and, on a follow-up, its parent and round,
   - the repo, branch, and — on a follow-up — **the worktree to `cd` into**,
   - `current_step` and when it was last updated,
   - scope in one line,
   - anything unanswered in `## Open Questions`,
   - the latest artifact the case has reached — the divergence log, the build close-out, or the
     research summary, whichever is most recent,
   - **the next command, spelled out**, e.g. ``run `/story-3-tdd-red 2026-08-20_add-queue-selection` ``.
5. **Check for a half-finished agent run.** If a `STATUS-<agent>.md` log is present and its last
   line is not a completion, say which agent stopped where — that log exists so a dead run can be
   picked up rather than restarted blind.
6. **Pre-read that step's inputs** so the next command starts warm — for `/story-3-tdd-red`, the
   acceptance criteria and the commands table; for `/story-4-tdd-green`, the plan and the red
   tests; for `/story-5-check`, nothing beyond the plan (the checker must read the code cold).
7. **End with the `What's next` block**, rendering `next_command` from `STATE.json`. Do not run
   the next command, and do not offer to — say what it is and let the user type it.

## If several cases are live

List every case home holding a `STATE.json`, most recently modified first, with its step, its
next command, and its parent if it has one. Then ask which one. Do not pick for the user.

## This command never

- Writes to any artifact, the project repo, or git. It is strictly read-only — including
  `STATE.json`, which it reports but never updates.
- Runs the next step, or any part of it.
- Creates a case home, or `cd`s into a worktree on the user's behalf.
