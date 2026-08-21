---
name: story-followup
description: The compressed follow-up path for a story case — how a subtask's nested case home is scaffolded under its parent, what it inherits and what it writes back to the parent's artifacts, how rounds work, which standard commands the follow-up commands are thin wrappers around, and the merge policy that refuses to integrate into a shared branch. Load it from any /story-followup-* command.
---

# Story follow-ups

A **follow-up** is a subtask spun out of a case: a bug the manual pass turned up, a review finding
deferred rather than fixed now, a piece of the story that wanted its own contract. It runs the
same loop, compressed — it **drops the diagramming pass, never the separation of tests from
code**, so it keeps both gates.

Load `story-context-home` alongside this skill; it owns the home layout and the commit format.

## The home is nested inside the parent

```
~/.claude/plans/<PROJECT>/YYYY-MM-DD_<parent>/YYYY-MM-DD_<followup>/
├── STATE.json      # "parent", "workflow": "followup", "round", "worktree", "branch"
├── STATUS.md       # links ../
├── RESEARCH.md     # TRANSIENT — the delta only, ≤ 40 lines
└── PLAN.md         # ≤ 60 lines — the only durable artifact it leaves behind
```

Nesting is the point: `../ARCHITECTURE.md` and `../MANUAL_TESTING.md` resolve without a stored
path, and the relationship is visible in the tree rather than only in `STATE.json`. A follow-up
of a follow-up nests one level deeper; it is legal, and if you are about to create a third level,
say so — that is usually a sign the work wanted its own case.

**The parent may be in progress or already wrapped.** Opening a follow-up against a wrapped parent
is a continuation: the wrap left the durable artifacts and the `## Follow-ups` table in place
precisely so this still works months later.

## What it inherits, what it writes back

| Thing | Where it lives |
|---|---|
| Project, repo, commands table | inherited from the parent's `PLAN.md` — do not re-ask |
| Research | its own **transient** `RESEARCH.md`, the delta only |
| Scope, phases, numbered ACs, `## Test changes`, `## For the builder` | its own `PLAN.md` |
| "Builds on parent" section | its own `PLAN.md` — **self-contained**, citing the parent's already-mapped files and contracts, because the `RESEARCH.md` it was distilled from will not survive the wrap |
| Diagrams | **none of its own.** The check refreshes `../ARCHITECTURE.md` in place |
| By-hand procedure | appended to `../MANUAL_TESTING.md` under `## Follow-ups` |
| Build close-out | a `## Build close-out` section (≤ 6 lines) in its own `PLAN.md` — no `IMPLEMENTATION.md` |
| Its existence | a row in the **parent's** `PLAN.md` `## Follow-ups` table, registered at start and flipped to `wrapped` at wrap |

The parent stays the one place to look for how the whole effort is shaped and how to test it.
That is why a follow-up draws nothing of its own — a per-subtask diagram would be a second map.

## The worktree is the user's

Set it up **before** starting; no follow-up command creates one or checks for one:

```bash
git worktree add -b <followup-branch> <path>/<followup-branch> <parent-branch>
cd <path>/<followup-branch>
```

`/story-followup-1-start` **records** the checkout and branch it finds itself in
(`STATE.json.worktree` / `.branch`). That is what a fresh session `cd`s into and what the wrap
merges. Every step of the follow-up runs from that checkout. Working each follow-up in its own
worktree is what lets several run in parallel without stepping on each other — but the workflow
never creates, moves, or removes one.

## Rounds

Re-running `/story-followup-1-start <parent-id> [description]` **in the same checkout, against a
case home that already exists**, opens another **round** — the build → manual-test → find-another-
issue → go-again loop. It bumps `STATE.json.round` and starts the flow again from research; it
does **not** re-scaffold the home, does not reset `PLAN.md`, and does not add a second
`## Follow-ups` row. Each round appends to the same plan.

## The six commands

| Command | What it is |
|---|---|
| `/story-followup-1-start <parent-id> [desc]` | link to the parent, record the checkout, scaffold the nested home, delta research, register the parent row |
| `/story-followup-2-plan` | `PLAN.md` incl. "Builds on parent", numbered ACs, `## Test changes`; presents the **parent's** sequence diagram and names which arrows change. **Gate 1** |
| `/story-followup-3-tdd-red` | **thin wrapper** over `/story-3-tdd-red` |
| `/story-followup-4-tdd-green` | **thin wrapper** over `/story-4-tdd-green` |
| `/story-followup-5-check` | **thin wrapper** over `/story-5-check` |
| `/story-followup-6-wrap` | the wrap, plus the merge |

The three wrappers hold **no logic of their own**. The standard commands already read
`STATE.json.workflow` and behave correctly on a follow-up; the wrappers exist so the sequence the
user types reads 1→6 and so `next_command` has a name to point at. If you find yourself writing a
rule in a wrapper, it belongs in the standard command or in this skill.

## The merge policy

`/story-followup-6-wrap` merges the follow-up branch into the **parent story branch**:

- **Refuse `main`, `master`, `develop`.** If the parent branch is one of these, stop and tell the
  user to open a pull request. Integrating into a shared branch is a reviewed, remote operation.
- Merge with `--no-ff`, from the checkout the parent branch lives in — not from the worktree.
- **Documentation conflicts:** in the parent's `## Follow-ups` table, keep **every** row from both
  sides. That is the only conflict resolved automatically.
- **Any code conflict stops the merge** and goes to the user, with the conflicting paths named.
- Leave the worktree and the branch in place afterward. Never push.

## What a follow-up never does

- Never draws its own diagrams or writes its own `IMPLEMENTATION.md` / `MANUAL_TESTING.md`.
- Never re-researches what the parent already mapped — the delta only.
- Never edits the parent's scope, phases, or acceptance criteria.
- Never creates or removes a worktree or a branch.
- Never merges into a shared branch, and never pushes.
