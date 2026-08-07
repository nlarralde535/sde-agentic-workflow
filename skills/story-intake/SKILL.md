---
name: story-intake
description: Gather the context a story case needs before planning — what the user wants to build, which ~/.claude/plans/<PARENT> it belongs under, the target repo path and working branch, and the exact commands used to test and build that project. Conversational, never inferred. Used by /story-plan to open a case; load it whenever a case home is about to be created.
---

# Story intake

Intake is a **conversation**, not a form and not a guess. Its output is the opening sections of
`plan.md` — `## Context`, `## Scope`, `## Commands` — plus the two facts the case home's path is
made of: the `<PARENT>` and the `<descriptive-short-name>`.

Load the `story-context-home` skill first; it owns the path convention and the document shape
this skill fills in.

## The one hard rule

**Never guess `<PARENT>`. Never invent a case ID.** Both come from the user, explicitly, in this
conversation. A case home created under the wrong parent is invisible to the wiki rules and to
`/story-resume`, and the date in its name is permanent.

Everything else in this skill may be *proposed* — you can offer a name, read a `package.json` and
suggest a test command — as long as the user confirms it before it is written.

## What to gather

Ask in this order. Batch related questions; do not interrogate one line at a time. Skip anything
the user has already told you in this session, and say that you are taking it as given.

### 1. The change

> What are you building, and what makes it non-trivial?

You want enough to write `## Context` (2–5 lines of prose) and to draw the scope boundary. Push
gently on the boundary — the **Not building** list is the half of `## Scope` people skip, and it
is what keeps the case from growing during the build.

If the answer is large enough to need more than 4 phases, say so and propose splitting it into
two cases. A follow-up here is just another case in the same parent directory; there is no
subtask machinery to set up.

### 2. Where it lives

> Which parent does this belong under — `CurrentEvents`, `ReReading`, or a new one?

List the existing directories under `~/.claude/plans/` as the options. If the user names a new
parent, confirm the exact spelling before creating it, and mention that the LLM Wiki's hard rule
means a new `~/.claude/plans/<Parent>/` directory is also what a future wiki project would hang
off of.

> Where is the project repo, and what branch are you on?

Record the absolute path and the branch. **Check the branch** (`git -C <repo> branch --show-current`)
and, if it is `main`/`master`, say so plainly — the workflow never switches branches, so the user
decides whether to go make one before continuing. Confirm the tree is clean enough that a later
`git diff` will be about this case and nothing else.

### 3. The name

Propose a `<descriptive-short-name>`: kebab-case, 2–6 words, in the user's vocabulary for the
change. Show the full case home path it produces and get an explicit yes:

> `~/.claude/plans/ReReading/2026-08-04_add-rereading-queue-selection/` — good?

### 4. How the project is tested and built

> How do you run the tests, and how do you build it?

Ask; do not detect. If the user is unsure, read the project's `package.json` / `Makefile` /
`pyproject.toml` and **propose** the commands you find — then confirm. You need three things,
each with the directory it runs from:

- the whole-suite test command,
- the narrower command that runs just this case's test files (this is the one `/story-tdd-red`
  and the builder use in their loop — the whole suite is for the final verdict),
- the build command.

These go into `## Commands` in `plan.md` and are then run **verbatim** by later steps. There is
no per-project config file and no framework detection anywhere in this workflow — this table is
the whole mechanism.

**If the project has no test runner at all**, stop and say so. `/story-tdd-red` is a hard gate;
standing up a runner is its own piece of work and should be its own case (or a decision the user
makes deliberately before this one continues).

### 5. Prior art (optional)

If the parent matches a project tracked in the LLM Wiki, offer to load the `llm-wiki` skill in
**Reference only** mode and skim `start_here.md` plus the project index for anything that bears
on this change. This is a read, never a write — intake never records anything in the wiki.

## What intake writes

Nothing, directly. Intake hands its result to `/story-plan`, which creates the case home and
writes `plan.md` from the `story-context-home` template. Intake's material lands in:

- `## Context` — the change and why it is non-trivial, plus the repo path and branch
- `## Scope` — building / not building
- `## Commands` — the three commands and their working directories

Anything the user raised that intake could not settle goes into `## Open Questions` verbatim,
not into a summary of itself.

## What intake never does

- Never creates a `<PARENT>` directory the user did not name.
- Never writes to the project repo, the LLM Wiki, or git.
- Never creates, switches, or merges a branch.
- Never writes a config file into the project.
