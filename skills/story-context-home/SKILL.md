---
name: story-context-home
description: The conventions for a story case home under ~/.claude/plans/<PROJECT>/YYYY-MM-DD_<name>/ — the directory layout for standard and nested follow-up cases, the seven artifacts and their line budgets, the STATE.json schema and STATUS.md handoff pair, the What's next block, case-ID resolution, the state machine, the Open Questions exemption, and the commit-message format every story command uses. Load this before creating, reading, resolving, updating, or committing anything in a case home; every /story-* command depends on it.
---

# Story context home

A **case** is one unit of work that goes through the `/story-*` loop once. Everything the
workflow writes about a case lives in that case's **case home** — one directory.

This skill is the single source of truth for where that directory is, what goes in it, how
progress is recorded, and how commits that touch it are written. Commands hold no copy of these
rules; they load this skill.

## The case home

```
~/.claude/plans/<PROJECT>/YYYY-MM-DD_<descriptive-short-name>/
├── STATE.json            # transient — the machine-readable resume pointer
├── STATUS.md             # transient — the handoff file a fresh session reads
├── STATUS-<agent>.md     # transient — one per agent that has run, its own progress log
├── RESEARCH.md           # durable  ≤ 70 lines
├── PLAN.md               # durable  ≤ 80 lines
├── ARCHITECTURE.md       # durable  ≤ 3 diagrams
├── MANUAL_TESTING.md     # durable  ≤ 50 lines
├── IMPLEMENTATION.md     # durable  ≤ 40 lines
├── REVIEW.md             # durable, uncapped — only if /story-review ran
├── MODEL.md              # transient — only if /story-model drew one
└── YYYY-MM-DD_<followup-name>/   # a follow-up case, nested (see below)
```

Example: `~/.claude/plans/CurrentEvents/2026-07-28_add-new-page-to-currentEvents-app/`

Rules, all of them load-bearing:

- **`<PROJECT>` comes from the user.** It is an existing directory under `~/.claude/plans/`
  (today: `CurrentEvents`, `ReReading`) or a new one the user names during intake. **Never guess
  it, never infer it from the repo name, never create one without being told to.** (`<PROJECT>`
  is what the commit-message rules call the project reference ID. The word *parent* is reserved
  for a parent **case**.)
- **The date is the date the case was created** and never changes afterward — not when the plan
  is amended, not when the build lands. It exists so cases sort chronologically.
- **`<descriptive-short-name>` is kebab-case**, 2–6 words, describes the change in the user's
  words (`add-rereading-queue-selection`, not `feature-1` or `fix`). The user approves it during
  intake; **never invent a case ID silently.**
- **Case homes sit alongside the existing flat `*.md` plan files** in the same project directory.
  Nothing migrates. A flat plan file is not a case and is never touched by this workflow.
- **Nothing else is ever written into a case home** — no test files, no product code, no scratch
  notes, no eighth artifact. Tests and code go in the project repo. The one thing that may appear
  inside a case home that is not in the list above is a **nested follow-up case home**.

### The follow-up case home, nested

A follow-up is a subtask spun out of a case — a bug found by hand, a review finding. Its home is
**nested inside its parent's home**, so `../` reaches the parent's artifacts without a stored path:

```
~/.claude/plans/<PROJECT>/YYYY-MM-DD_<parent>/YYYY-MM-DD_<followup>/
├── STATE.json      # "parent", "workflow": "followup", "round", "worktree", "branch"
├── STATUS.md       # links ../
├── RESEARCH.md     # TRANSIENT here — the delta only, ≤ 40 lines
└── PLAN.md         # ≤ 60 lines — the ONLY durable artifact a follow-up leaves behind
```

It has no `ARCHITECTURE.md`, `MANUAL_TESTING.md`, or `IMPLEMENTATION.md` of its own. It **leans on
the parent**: `/story-followup-5-check` refreshes `../ARCHITECTURE.md` in place, the by-hand
procedure is appended to `../MANUAL_TESTING.md` under `## Follow-ups`, and the build close-out is
a `## Build close-out` section (≤ 6 lines) in the follow-up's own `PLAN.md`. The parent's `PLAN.md`
carries a `## Follow-ups` table listing every subtask spun out of it — durable, so a follow-up can
be opened against a parent wrapped months earlier. The `story-followup` skill owns the rest.

### Case IDs and resolution

The **case ID** is the case home's directory name: `YYYY-MM-DD_<descriptive-short-name>`. The
`<descriptive-short-name>` alone is accepted as shorthand wherever a case ID is taken, as long as
exactly one case home matches it.

When a command takes an optional `[case-id]`:

1. **Argument given** — glob `~/.claude/plans/*/*<case-id>*` and
   `~/.claude/plans/*/*/*<case-id>*` for a directory containing `STATE.json` or `PLAN.md`.
   Exactly one match → use it. Several → list them and ask. None → say so and stop.
2. **No argument** — resolve to the **most recently modified live case**: the newest
   `~/.claude/plans/*/*/STATE.json` or `~/.claude/plans/*/*/*/STATE.json`. Always name the case
   you resolved to in your first line of output, so a wrong resolution is visible immediately.
3. **A wrapped case has no `STATE.json`.** To resolve one, glob for `PLAN.md` instead — but say
   plainly that the case is wrapped and ask before doing anything to it.
4. **Never create a case home** as a side effect of resolution. Only `/story-1-start` and
   `/story-followup-1-start` create one.

## The artifacts

| Artifact | Written by | Lifetime | Budget |
|---|---|---|---|
| `STATE.json` | main session only | transient | — |
| `STATUS.md` | main session only | transient | ≤ 25 lines |
| `STATUS-<agent>.md` | that agent only | transient | — |
| `RESEARCH.md` | `story-researcher` | durable (transient on a follow-up) | ≤ 70 lines (≤ 40) |
| `PLAN.md` | `story-planner`, amended at gates | durable | ≤ 80 lines (≤ 60) |
| `ARCHITECTURE.md` | `story-planner`, refreshed by `story-checker` | durable | ≤ 3 diagrams |
| `MANUAL_TESTING.md` | `story-planner`, reconciled by `story-checker` | durable | ≤ 50 lines |
| `IMPLEMENTATION.md` | `story-builder` | durable | ≤ 40 lines |
| `REVIEW.md` | `/story-review` | durable | uncapped — a findings table |
| `MODEL.md` | `story-planner` (`flows` mode) | transient | — |

**Transient means the wrap deletes it.** `/story-6-wrap` and `/story-followup-6-wrap` remove
`STATE.json`, `STATUS.md`, every `STATUS-<agent>.md`, `MODEL.md`, and — on a follow-up only —
`RESEARCH.md`. Their presence is also what "in progress" *means*: the resume glob matches only
live cases.

### PLAN.md

Section order is fixed. Sections marked *(appended later)* do not exist when `/story-2-plan`
writes the file — they are added by the step that owns them.

| # | Section | Written by | Notes |
|---|---|---|---|
| — | `# <case-id>` H1 | `/story-2-plan` | the directory name, verbatim |
| 1 | `## Context` | `/story-1-start` (intake) | what the user wants and why; the repo path and branch |
| 2 | `## Scope` | `/story-2-plan` | `**Building:**` / `**Not building:**` — both required |
| 3 | `## Phases` | `/story-2-plan` | 2–4 phases, each with its own validation line |
| 4 | `## Acceptance criteria` | `/story-2-plan` | **numbered `AC1…ACn`**, observable behaviors |
| 5 | `## Commands` | `/story-1-start` (intake) | how tests are run, how the project is built |
| 6 | `## For the builder` | `/story-2-plan` | *is* the builder's prompt — see below |
| 7 | `## Follow-ups` | `/story-followup-1-start` *(appended later)* | one row per subtask |
| 8 | `## Divergence Log` | `/story-5-check` *(appended later)* | ≤ 3 lines per divergence |
| 9 | `## Open Questions` | any step, appended only | never edited, never budgeted |

`## Open Questions` is always last so appending to it never disturbs anything above it.

**`## For the builder`** is the one section written *at* another actor: 5–10 lines naming the doc
context the builder should read, the constraints it must respect, and the validation command that
decides whether it is done. `/story-4-tdd-green` passes the builder almost nothing else, so
anything the builder needs and this section omits, the builder will not have.

### Line budgets

| Document | Budget |
|---|---|
| `RESEARCH.md` | **≤ 70 lines** (**≤ 40** on a follow-up, where it holds the delta only) |
| `PLAN.md` | **≤ 80 lines** (**≤ 60** on a follow-up), excluding `## Divergence Log` and `## Open Questions` |
| `ARCHITECTURE.md` | **≤ 3 diagrams** |
| `MANUAL_TESTING.md` | **≤ 50 lines** — one ≤ 5-step procedure per AC |
| `IMPLEMENTATION.md` | **≤ 40 lines** — the verdict, not the transcript |
| `## Divergence Log` | **≤ 3 lines per divergence** (no cap on the number of divergences) |
| `## Build close-out` (follow-up) | **≤ 6 lines** |

Three rules make the budgets achievable rather than a squeeze:

1. **State each decision once.** The acceptance criteria are canonical and numbered; scope,
   phases, the tests, the manual-testing procedures, and the wrap's write-up all **cite the
   number** rather than restating the criterion.
2. **No code in the docs.** No snippets, no function bodies. A `path:n-m` reference is allowed as
   a pointer *into* the code — that is what `ARCHITECTURE.md`'s reading order is for — but never
   as a way to *describe* a change: "modify lines 418-432" is wrong the moment anything moves, and
   the symbol name is better anyway.
3. **Never let the docs dwarf the diff.** If the plan is longer than the change it describes, the
   plan is wrong, not the budget.

Count lines before you write and again after amending. If you are over, cut restatement first —
never cut a scope line or an acceptance criterion to fit. If you are still over, say so at the
gate with the count, rather than silently shipping a file over budget.

### The Open Questions exemption

`## Open Questions` is **exempt from every budget** and is **never edited by any command** — only
appended to. The user answers inline there, in their own words, at any length. When a gate
produces answers, those answers amend the *relevant* section in place (scope, phases, criteria)
and the exchange is appended to `## Open Questions` verbatim. A command that rewrites,
summarizes, or tidies the user's words there has broken the rule.

## The handoff pair

`STATUS.md` and `STATE.json` are the mid-flight handoff, and they are **written by the main
session only**. No agent writes either one. An agent *names* the step it reached in the summary it
returns; the session records it once that step's gate work is done. The only status file an agent
writes is its own `STATUS-<agent>.md` log.

### STATE.json

```json
{
  "case_id": "2026-08-20_add-rereading-queue-selection",
  "project": "ReReading",
  "parent": null,
  "workflow": "standard",
  "round": 1,
  "repo": "/home/nic/repos/rereading",
  "branch": "add-queue-selection",
  "worktree": null,
  "current_step": "planned",
  "next_command": "/story-3-tdd-red",
  "test_baseline_commit_hash": null,
  "updated": "2026-08-20"
}
```

- `parent` — `null` on a standard case; the parent's case ID on a follow-up.
- `workflow` — `"standard"` or `"followup"`. This is what `story-builder` reads to know which
  path it is on.
- `round` — bumped by re-running `/story-followup-1-start` in the same checkout; always `1` on a
  standard case.
- `worktree` — the checkout the follow-up runs in, recorded (never created) by
  `/story-followup-1-start`. `null` on a standard case.
- `test_baseline_commit_hash` — recorded by the red step; read by the green step's diff audit.

### current_step and next_command

| `current_step` | Set by | `next_command` |
|---|---|---|
| `started` | `/story-1-start` | `/story-2-plan` |
| `planned` | `/story-2-plan`, pass 1, **after** Gate 1 | `/story-2-plan` (pass 2) |
| `modeled` | `/story-2-plan`, pass 2 | `/story-3-tdd-red` |
| `tested-red` | `/story-3-tdd-red`, **after** Gate 2 and the baseline commit | `/story-4-tdd-green` |
| `built` | `/story-4-tdd-green`, after the diff audit | `/story-5-check` |
| `checked` | `/story-5-check` | `/story-6-wrap` |
| `reviewed` | `/story-review` | `/story-6-wrap` |
| `wrapped` | `/story-6-wrap` | — the pair is deleted |

On a follow-up the same values are used with the `/story-followup-N-*` command names. Backward
transitions are legal and expected: `modeled → planned` when reading the shape exposes a hole in
the plan, `tested-red → planned` when writing the tests changed the scope, `reviewed → built`
when a finding is fixed now.

### STATUS.md

≤ 25 lines. What a fresh session needs and nothing else: the case ID and its home path, the repo
and branch (and worktree, on a follow-up), one line of scope, `current_step`, **the next command
spelled out**, anything unanswered in `## Open Questions`, and — on a follow-up — a link to `../`.

### The What's next block

**Every command ends with one.** It is three things:

```
**What's next**
- `<STATE.json.next_command>` — <what it will do>
- Gate still standing: <the gate between the user and that command, or "none">
- Side doors: <the optional commands that make sense here>
```

Render `next_command` **from `STATE.json`**, not from memory of the flow — so the thing the user
is told to type and the thing on disk are the same value. A command that ends without this block
has left the user to work out where they are.

## ARCHITECTURE.md

Owned by the `story-architecture-diagram` skill — load that skill for the section order, the two
diagram rules, and the PLANNED / REFRESH / FLOWS modes. What belongs here: `ARCHITECTURE.md` is
durable, and it is **edited in place** by `/story-5-check`, never appended to with a second
as-built copy.

## Templates

`templates/STORY-ARTIFACTS.md` in this skill directory holds the skeleton of every artifact.
Copy the section you need into a new case home and fill it in; do not invent a different section
order. Placeholders are written `<like this>` and every one must be replaced or its section
deleted — never leave a `<placeholder>` in a real case home.

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
- **Project reference ID** — the case's **`<PROJECT>`** (`ReReading`, `CurrentEvents`). This is
  the ID the rules file requires in parentheses; it is never the case ID.
- **Subject line** ≤ 72 characters, including the type and parentheses.
- **Body** — required, starts one blank line after the subject, wrapped at 80 columns, describes
  only this commit's changes, and contains **no file paths and no code references**.
- **`Case:` trailer** — the full case ID. On a follow-up: `Case: <parent-id> > <followup-id>`.
- **The red step's baseline commit** carries the **approved path inventory** in its body, after a
  sentence or two summarizing the tests: the unit, its initial and terminal states, and one line
  per kept path with the AC it proves (dropped paths with their reason). It is plain prose wrapped
  at 80 columns — states and paths in words, no test-function names, no file paths. This commit
  body is the inventory's only durable record; no case-home file repeats it.
- Commits are **local only. Never push.**

Four commits per standard case, at most: the red step's test baseline, the builder's product code,
the checker's docs-only commit, and the wrap's close-out. Changes to the workflow repo itself are
not cases and carry no `Case:` trailer.

## Version control

The workflow **never creates, switches, or merges a branch on the standard flow, and never
pushes.** The user sets up the working branch before `/story-1-start`. If the target repo is on a
branch that looks wrong for the case (e.g. `main`), say so and let the user decide — do not switch.

The **one** exception is the follow-up wrap, which merges a follow-up branch into its parent story
branch and **refuses to merge into `main`/`master`/`develop`** — see the `story-followup` skill.
Worktrees are always the user's to create; the workflow only records the one it finds itself in.
