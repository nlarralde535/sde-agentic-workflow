---
description: Change the /story-* workflow itself — propose an edit plan, then edit and sync every mirror
argument-hint: "<description of the change>"
---

# /story-update-workflow

The command that changes the system. It edits this repo — commands, skills, agents, templates —
and keeps every mirror in sync in the same pass, so the explanation can never drift from the
behavior.

Argument (required): `$ARGUMENTS` — a description of the change. With no argument, ask what to
change and stop.

**This command takes no case and writes nothing to a case home.** Changes to the workflow are not
cases.

## Step 1 — propose the edit plan, then stop

Work out what the change touches and present it before writing anything:

- **the change**, restated in one or two lines so a misunderstanding surfaces now,
- **the files you will edit**, each with a phrase on what changes in it,
- **which mirrors that forces** (see the sync list below),
- **whether the file set changes** — a new or removed command / skill / agent means `install.sh`
  must be re-run,
- **anything you think is a bad idea**, said once and plainly.

Then **stop and wait for approval**. This is the gate. Do not write, do not stage, do not
"prepare" the edits first.

## Step 2 — on approval, edit and sync in one pass

Make the substantive edit, then bring every mirror along **in the same pass and the same commit**:

| Mirror | Update when |
|---|---|
| `commands/story-explain-workflow.md` — the embedded reference | **always.** Any behavior change, gate change, or file-set change |
| `workflow_flowchart.md` — the rendered Mermaid mirror | any change to a flow, a gate, a state transition, or the command set |
| `README.md` — the command tables, the flows, the case-home layout | the command set, a step, a gate, or the layout changed |
| `skills/story-context-home/templates/STORY-ARTIFACTS.md` | an artifact's sections, order, or budgets changed |
| `plan_initial.md` §6 target layout | a file was added or removed |

A behavior change that does not land in the embedded reference is the failure this command
exists to prevent. If you cannot state the change in the reference, you do not understand it well
enough to have made it.

**The diagrams live in exactly one place.** `workflow_flowchart.md` is the only file in this repo
that renders a flow as Mermaid; `story-explain-workflow` carries prose and ASCII sketches
deliberately, so there is never a second rendering to contradict the first. Do not add a Mermaid
fence to the reference or the README to "help" — reconcile the flowchart instead.

Keep the architecture intact while you edit: **commands stay thin** (parse, delegate, relay) and
**logic lives in skills**. If the change wants a command to hold a rule, put the rule in the
skill and have the command load it. That separation is the single thing most worth protecting.
The three follow-up wrappers are the sharpest case: a rule written into one of them is a rule in
the wrong file.

## Step 3 — install, record, commit

1. **Re-run `install.sh`** if a command, skill, or agent file was added or removed, and report
   its output — including anything it pruned. Not needed for edits to existing files; they are
   symlinked, so edits are live immediately.
2. **Save the approved edit plan** to `workflow-modification-plans/YYYY-MM-DD_<short-name>.md` —
   what was asked, what was decided, what was changed. This is the record of why the system
   looks the way it does.
3. **One local commit**, per `~/.claude/rules/nics-rules/commit-messages.md`:
   `<type>(sde-agentic-workflow): <subject>`, a blank line, an 80-column body with no file paths
   or code references, and the `Co-Authored-By` trailer. **No `Case:` trailer** — this is not a
   case. Stage only the files this change touched. **Never push.**

## This command never

- Writes to a case home under `~/.claude/plans/`.
- Edits `~/.claude/llmwiki/CLAUDE.md` or any project repo. If a change to the workflow implies a
  change to the wiki schema, **say so and hand it to the user** — it is theirs to apply.
- Skips the edit-plan gate, even for a one-word change.
- Leaves a mirror stale to be caught up later.
- Pushes.
