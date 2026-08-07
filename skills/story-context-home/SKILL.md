---
name: story-context-home
description: The conventions for a story case home under ~/.claude/plans/<PARENT>/YYYY-MM-DD_<name>/ — the directory layout, the shape and line budgets of plan.md and diagrams.md, the Workflow status line and its allowed values, the Open Questions exemption, case-ID resolution, and the commit-message format every story command uses. Load this before creating, reading, resolving, updating, or committing anything in a case home; every /story-* command depends on it.
---

# Story context home

A **case** is one unit of work that goes through the `/story-*` loop once. Everything the
workflow writes about a case lives in that case's **case home** — one directory, two files.

This skill is the single source of truth for where that directory is, what goes in it, and how
commits that touch it are written. Commands hold no copy of these rules; they load this skill.

## The case home

```
~/.claude/plans/<PARENT>/YYYY-MM-DD_<descriptive-short-name>/
├── plan.md        # scope, phases, acceptance criteria, commands, build record, divergence log
└── diagrams.md    # Mermaid: component + sequence (+ state, if it earns its place)
```

Example: `~/.claude/plans/CurrentEvents/2026-07-28_add-new-page-to-currentEvents-app/`

Rules, all of them load-bearing:

- **`<PARENT>` comes from the user.** It is an existing directory under `~/.claude/plans/`
  (today: `CurrentEvents`, `ReReading`) or a new one the user names during intake. **Never guess
  it, never infer it from the repo name, never create one without being told to.**
- **The date is the date the case was created** and never changes afterward — not when the plan
  is amended, not when the build lands. It exists so cases sort chronologically.
- **`<descriptive-short-name>` is kebab-case**, 2–6 words, describes the change in the user's
  words (`add-rereading-queue-selection`, not `feature-1` or `fix`). The user approves it during
  intake; **never invent a case ID silently.**
- **Case homes sit alongside the existing flat `*.md` plan files** in the same parent directory.
  Nothing migrates. A flat plan file is not a case and is never touched by this workflow.
- **Both files are durable.** There are no transient artifacts — no `STATUS.md`, no `STATE.json`.
  The `## Workflow status` section in `plan.md` is the only progress record, which is all
  `/story-resume` needs.
- **Nothing else is ever written into a case home.** No test files, no code, no scratch notes,
  no third document. Tests and product code go in the project repo.

### Case IDs and resolution

The **case ID** is the case home's directory name: `YYYY-MM-DD_<descriptive-short-name>`. The
`<descriptive-short-name>` alone is accepted as shorthand wherever a case ID is taken, as long
as exactly one case home matches it.

When a command takes an optional `[case-id]`:

1. **Argument given** — glob `~/.claude/plans/*/*<case-id>*` for a directory containing
   `plan.md`. Exactly one match → use it. Several → list them and ask. None → say so and stop.
2. **No argument** — resolve to the **most recently modified** case home:
   `ls -dt ~/.claude/plans/*/*/ ` filtered to directories containing a `plan.md`. Always name
   the case you resolved to in your first line of output, so a wrong resolution is visible
   immediately.
3. **Never create a case home** as a side effect of resolution. Only `/story-plan` creates one.

## plan.md

Section order is fixed. Sections marked *(appended later)* do not exist when `/story-plan`
writes the file — they are added by the step that owns them.

| # | Section | Written by | Notes |
|---|---|---|---|
| — | `# <case-id>` H1 | `/story-plan` | the directory name, verbatim |
| 1 | `## Workflow status` | every command | exactly one line, see below |
| 2 | `## Context` | `/story-plan` (intake) | what the user wants and why; the target repo path |
| 3 | `## Scope` | `/story-plan` | `**Building:**` / `**Not building:**` — both required |
| 4 | `## Phases` | `/story-plan` | 2–4 phases, each with its own validation line |
| 5 | `## Acceptance criteria` | `/story-plan` | observable behaviors; these become the red tests |
| 6 | `## Commands` | `/story-plan` (intake) | how tests are run, how the project is built |
| 7 | `## Build record` | `/story-build` *(appended later)* | ≤ 10 lines |
| 8 | `## Divergence Log` | `/story-check` *(appended later)* | ≤ 3 lines per divergence |
| 9 | `## Open Questions` | `/story-plan`, appended by any step | never edited, never budgeted |

`## Open Questions` is always last so appending to it never disturbs anything above it.

### Line budgets

| Document | Budget |
|---|---|
| `plan.md` | **≤ 80 lines**, excluding `## Divergence Log` and `## Open Questions` |
| `## Divergence Log` | **≤ 3 lines per divergence** (no cap on the number of divergences) |
| `## Build record` | **≤ 10 lines** |
| `diagrams.md` | **≤ 3 diagrams** |

Three rules make the budgets achievable rather than a squeeze:

1. **State each decision once.** The acceptance criteria are canonical; phases reference them
   rather than restating them.
2. **No code in the docs.** No snippets, no line numbers, no function bodies. Name files and
   behaviors, not implementations. (`## Read the code in this order` in `diagrams.md` is the one
   place `file:line` pointers belong.)
3. **Never let the docs dwarf the diff.** If the plan is longer than the change it describes,
   the plan is wrong, not the budget.

Check the budget by counting lines before you write, and again after amending. If you are over,
cut restatement first — never cut a scope line or an acceptance criterion to fit.

### The Workflow status line

`## Workflow status` holds **exactly one line**, in this format:

```
<state> · next `<command>` · updated YYYY-MM-DD
```

| `<state>` | Set by | `next` |
|---|---|---|
| `planned` | `/story-plan` | `/story-tdd-red` |
| `tested-red` | `/story-tdd-red` | `/story-build` |
| `built` | `/story-build` | `/story-check` |
| `checked` | `/story-check` | manual test — you |
| `done` | you, by hand | — |

Every command **replaces** this line as its last write to `plan.md`; no command appends a second
one. `updated` is today's date from the session environment. `/story-resume` reads this line and
nothing else to work out where the case stands.

### The Open Questions exemption

`## Open Questions` is **exempt from every budget** and is **never edited by any command** —
only appended to. The user answers inline there, in their own words, at any length. When a
command's gate produces answers, those answers amend the *relevant* section in place (scope,
phases, criteria) and the question-and-answer exchange is appended to `## Open Questions`. A
command that rewrites, summarizes, or tidies the user's words there has broken the rule.

## diagrams.md

Owned by the `story-diagrams` skill — load that skill for the section order, the two diagram
rules, and the PLANNED vs REFRESH modes. What belongs here: `diagrams.md` is durable, lives in
the case home beside `plan.md`, and is **edited in place** by `/story-check`, never appended to
with a second as-built copy.

## Templates

`templates/plan.md` and `templates/diagrams.md` in this skill directory are the starting shape.
Copy them into a new case home and fill them in; do not invent a different section order.
Placeholders are written `<like this>` and every one must be replaced or its section deleted —
never leave a `<placeholder>` in a real case home.

## Commit messages

Every commit any story command or agent makes follows
`~/.claude/rules/nics-rules/commit-messages.md`, with the case ID as a **trailer**, not a prefix:

```
minor(ReReading): add rereading queue selection

Implements the case's three acceptance criteria end to end. The selection
pass now runs before render rather than inside it, which removes the
double-fetch on first paint.

Case: 2026-07-28_add-rereading-queue-selection
Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
```

- **Type** — `major` | `minor` | `patch` | `fix`, per the rules file.
- **Project reference ID** — the case's **`<PARENT>`** (`ReReading`, `CurrentEvents`). This is
  the ID the rules file requires in parentheses; it is never the case ID.
- **Subject line** ≤ 72 characters, including the type and parentheses.
- **Body** — required, starts one blank line after the subject, wrapped at 80 columns, describes
  only this commit's changes, and contains **no file paths and no code references**.
- **`Case:` trailer** — the full case ID, in the trailer block after a blank line.
- Commits are **local only. Never push.** (`git push` is denied on this machine anyway.)

Two commits per case, at most: the builder's product-code commit and `/story-check`'s docs-only
commit. Changes to the workflow repo itself are not cases and carry no `Case:` trailer.

## Version control is the user's

The workflow **never** creates, switches, or merges branches, never creates worktrees, and never
pushes. The user sets up the working branch before `/story-plan`. If the target repo is on a
branch that looks wrong for the case (e.g. `main`), say so and let the user decide — do not
switch.
