---
name: story-intake
description: Gather the context a story case needs before research and planning — what the user wants to build, which ~/.claude/plans/<PROJECT> it belongs under, the target repo path and working branch, and the exact commands used to test and build that project — then hand a research brief to the story-researcher agent. Conversational, never inferred. Used by /story-1-start to open a case, and in its delta form by /story-followup-1-start.
---

# Story intake

Intake is a **conversation**, not a form and not a guess. Its output is two things: the opening
sections of `PLAN.md` — `## Context` and `## Commands` — and the **research brief** that
`/story-1-start` hands to the `story-researcher` agent.

Load the `story-context-home` skill first; it owns the path convention and the artifact shapes
this skill fills in.

## The one hard rule

**Never guess `<PROJECT>`. Never invent a case ID.** Both come from the user, explicitly, in this
conversation. A case home created under the wrong project is invisible to the wiki rules and to
`/story-resume`, and the date in its name is permanent.

Everything else in this skill may be *proposed* — you can offer a name, read a `package.json` and
suggest a test command — as long as the user confirms it before it is written.

## What to gather

Ask in this order. Batch related questions; do not interrogate one line at a time. Skip anything
the user has already told you in this session, and say that you are taking it as given.

### 1. The change

> What are you building, and what makes it non-trivial?

You want enough to write `## Context` (2–5 lines of prose) and to tell the researcher where to
look. Push gently on the boundary — the **Not building** half of scope is the one people skip,
and it is what keeps the case from growing during the build. Scope itself is written by the
planner at step 2; intake's job is to surface the boundary, not to finalize it.

If the answer is large enough to need more than 4 phases, say so and propose splitting it into
two cases.

### 2. Where it lives

> Which project does this belong under — `CurrentEvents`, `ReReading`, or a new one?

List the existing directories under `~/.claude/plans/` as the options. If the user names a new
project, confirm the exact spelling before creating it, and mention that the LLM Wiki's hard rule
means a new `~/.claude/plans/<Project>/` directory is also what a future wiki project would hang
off of.

> Where is the project repo, and what branch are you on?

Record the absolute path and the branch. **Check the branch**
(`git -C <repo> branch --show-current`) and, if it is `main`/`master`, say so plainly — the
workflow never switches branches, so the user decides whether to go make one before continuing.
Confirm the tree is clean enough that a later `git diff` will be about this case and nothing else.

### 3. The name

Propose a `<descriptive-short-name>`: kebab-case, 2–6 words, in the user's vocabulary for the
change. Show the full case home path it produces and get an explicit yes:

> `~/.claude/plans/ReReading/2026-08-20_add-rereading-queue-selection/` — good?

### 4. How the project is tested and built

> How do you run the tests, and how do you build it?

Ask; do not detect. If the user is unsure, read the project's `package.json` / `Makefile` /
`pyproject.toml` and **propose** the commands you find — then confirm. You need three things,
each with the directory it runs from:

- the whole-suite test command,
- the narrower command that runs just this case's test files (this is the one `/story-3-tdd-red`
  and the builder use in their loop — the whole suite is for the final verdict),
- the build command.

These go into `## Commands` in `PLAN.md` and are then run **verbatim** by later steps. There is
no per-project config file and no framework detection anywhere in this workflow — this table is
the whole mechanism.

**If the project has no test runner at all**, stop and say so. `/story-3-tdd-red` is a hard gate;
standing up a runner is its own piece of work and should be its own case (or a decision the user
makes deliberately before this one continues).

### 5. Prior art

If the project matches one tracked in the LLM Wiki, tell the researcher to consult it. Intake
itself never writes to the wiki, and the researcher's use of it is read-only.

## The research brief

Intake ends by composing the brief `/story-1-start` passes to the `story-researcher` agent. Keep
it short — the agent has code tools and is expected to go look:

- the change, in the user's words,
- the repo path and branch,
- the areas, files, or features the user named as involved,
- the boundary the user drew (what this is *not*),
- the project name, for the wiki lookup,
- anything the user was unsure about, so research can try to settle it.

**Do not brief the agent with conclusions.** If you already suspect which module changes, say
"the user mentioned X" — not "change X". The researcher's value is that it looks.

## The follow-up form — `/story-followup-1-start`

A follow-up's intake is the **delta only**, and most of it is already known:

- the parent case ID (given as an argument, never inferred) and its home,
- what went wrong or what the review asked for, in the user's words,
- the worktree and branch the session **finds itself in** — recorded, never created,
- the commands table, **inherited from the parent's `PLAN.md`** unless the user says otherwise.

Do not re-ask the project, the repo, or the test commands: read them from the parent. Ask only
what the parent cannot answer.

## What intake writes

Nothing to the project repo and nothing to git. `/story-1-start` creates the case home and writes
`## Context` and `## Commands` into `PLAN.md` from intake's result; the rest of `PLAN.md` is the
planner's at step 2. Anything the user raised that intake could not settle goes into
`## Open Questions` verbatim, not into a summary of itself.

## What intake never does

- Never creates a `<PROJECT>` directory the user did not name.
- Never writes to the project repo, the LLM Wiki, or git.
- Never creates, switches, or merges a branch, and never creates a worktree.
- Never writes a config file into the project.
