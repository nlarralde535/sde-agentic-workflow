---
name: story-wrap
description: Close out a story case — record what was actually built in the LLM Wiki via the llm-wiki skill, delete the case home's transient files, make the close-out commit, and (on a follow-up only) merge the follow-up branch into its parent story branch. Load it from /story-6-wrap and /story-followup-6-wrap; it is the only part of the workflow that writes to the wiki or merges anything.
---

# Story wrap

The wrap turns a finished case into something that is still useful in six months, and then takes
the scaffolding away. Three duties on a standard case — **wiki, delete, commit** — and a fourth
on a follow-up: **merge**.

Load `story-context-home` first (the artifact list, what is transient, the commit format). On a
follow-up, load `story-followup` too.

## Before anything: is it actually finished?

`STATE.json.current_step` should be `checked` or `reviewed`. If it is not, say what state the case
is in and ask — wrapping deletes the handoff pair, and a case wrapped early has to be re-opened by
hand. Also confirm the user has done the by-hand pass from `MANUAL_TESTING.md`; the wrap is what
follows that, not a substitute for it.

## 1. The wiki write-up

Load the **`llm-wiki`** skill and write an implementation entry for what was actually built, per
that skill's schema. This is the only wiki write anywhere in the workflow.

- Describe **reality, not plan intent** — what shipped, the divergences the check logged, the
  gotchas the build turned up, current status. Do not paraphrase `PLAN.md`; the wiki's job is the
  part that is not already written down.
- Set `plan-refs:` to this case, and record the case's commit hashes in `commits:`.
- Cite acceptance criteria **by number** (`AC2`) rather than restating them.
- On a follow-up, extend the **parent's** entry rather than creating a second one for a subtask,
  unless the follow-up is genuinely its own feature.

If the project has no wiki project yet, say so and ask before creating one — the wiki's own rules
govern that, not this workflow.

## 2. Delete the transients

Remove from the case home:

- `STATE.json` and `STATUS.md` — the handoff pair,
- every `STATUS-<agent>.md` progress log,
- `MODEL.md`, if `/story-model` drew one,
- on a **follow-up only**, `RESEARCH.md` — its content was distilled into `PLAN.md`'s
  "Builds on parent" section at plan time, and that section is written to be self-contained.

What stays is the durable set: `RESEARCH.md`, `PLAN.md`, `ARCHITECTURE.md`, `MANUAL_TESTING.md`,
`IMPLEMENTATION.md`, and `REVIEW.md` if a review ran. On a follow-up, `PLAN.md` alone.

**Deleting `STATE.json` is what "wrapped" means.** The resume glob matches live cases by that
file, so a case home without one is finished by definition. Nothing writes `current_step:
wrapped` to disk — the absence is the record.

## 3. The close-out commit

One commit, staging **only the case home's changes** (and, on a follow-up, the parent's
`## Follow-ups` row). Type is usually `patch`. Message per `story-context-home`, with the `Case:`
trailer. Never push.

If the case home is under `~/.claude/plans/` and that directory is not a git repository, there is
nothing to commit there — say so plainly and commit only what lives in the project repo. Do not
`git init` anything.

## 4. The merge — follow-up only

`/story-followup-6-wrap` merges the follow-up branch into the **parent story branch**, and this is
the one merge in the whole system. The rules are in the `story-followup` skill; the two that
matter most:

- **Never merge into `main`, `master`, or `develop`.** If the parent branch is one of those, stop
  and tell the user to open a pull request — integrating into a shared branch is a reviewed,
  remote operation, not a local merge.
- **Stop on any code conflict** and hand it to the user. Resolve documentation conflicts only in
  the one case the skill spells out (keeping every `## Follow-ups` row).

`/story-6-wrap` **never merges anything at all.**

## What the wrap presents

Short, and last. What went into the wiki, what was deleted, the commit, and — on a follow-up —
what was merged where. Then the `What's next` block, which for a wrapped standard case is: the
branch is yours to merge or open a PR from, and a new case starts with `/story-1-start`.

## What the wrap never does

- Never pushes, and never merges on the standard flow.
- Never deletes a durable artifact, and never deletes the case home itself.
- Never edits `PLAN.md`'s scope, phases, or criteria on the way out — the case is what it was.
- Never removes a worktree or a branch; those are the user's to clean up.
- Never wraps a case whose `MANUAL_TESTING.md` pass the user has not had a chance to do.
