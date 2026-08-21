---
description: Explain the /story-* workflow — the whole loop, or one command. Read-only, no repo scan.
argument-hint: "[command-name]"
---

# /story-explain-workflow

Presents the reference **embedded below**. It does not scan the repo, list directories, or read
the command files — the reference is embedded precisely so that explaining the workflow costs one
file read and cannot describe a command that no longer exists.

Argument (optional): `$ARGUMENTS` — a command name (with or without the leading slash). Given
one, present just that command's entry plus the gate that follows it. Given nothing, present the
whole reference. Read a command's own file only if the user asks for detail beyond what is here.

**This is a mirror.** When `/story-update-workflow` changes what a command does, it updates the
reference below in the same pass. A stale explanation misleads; keep them in one commit.

**No Mermaid lives in this file.** The rendered diagrams — both flows, the command-level map, and
the state machine — live in `workflow_flowchart.md`, and only there, so there is never a second
rendering of a flow to contradict the first. The two ASCII sketches below are sketches, not a
second rendering.

---

# The `/story-*` workflow

## The idea in one breath

One case = one unit of work. Everything the workflow writes about it lives in one case home under
`~/.claude/plans/<PROJECT>/YYYY-MM-DD_<short-name>/`. Each command does one step and **hands back
to you** — you advance by typing the next command, because there is deliberately **no
orchestrator**.

The point is to keep your *comprehension* in pace with how fast the AI generates code, and the
artifacts are **front-loaded**: the cheapest place to fix your mental model is before anything has
been written. Two things stop and wait for you, because they are decisions:

1. the **plan** (`/story-2-plan`) — and then you read the **shape** it produced,
2. the **contract** (`/story-3-tdd-red`) — the failing tests, before any product code.

A third gate follows the build: you rule on the **divergences** and test by hand
(`/story-5-check`). Everything else is handed over for you to read.

## The standard flow

```
you: make the branch
  │
  ├─ /story-1-start ──────► RESEARCH.md          → read it, answer open questions
  ├─ /story-2-plan  pass 1► PLAN.md              → GATE 1: approve the plan
  │                 pass 2► ARCHITECTURE.md      → read the shape
  │                         MANUAL_TESTING.md
  ├─ /story-3-tdd-red ────► failing tests        → GATE 2: approve the contract
  │                         ▮ baseline commit
  ├─ /story-4-tdd-green ──► product code ▮       → test-diff audit surfaces any test edit
  │                         IMPLEMENTATION.md
  ├─ /story-5-check ──────► ARCHITECTURE refresh → GATE 3: divergences, then test by hand
  │                         Divergence Log ▮
  ├─ (/story-review) ─────► REVIEW.md            → triage findings
  └─ /story-6-wrap ───────► wiki + delete transients ▮
```

`▮` marks a local commit. Nothing in this workflow ever pushes.

**The numbers are the order, and only the mandatory steps have one.** `/story-review`,
`/story-model`, `/story-resume` and the two meta commands are unnumbered precisely because they
are optional or off-flow — if a command has no number, skipping it costs you nothing.

**Every command ends with a `What's next` block**: the one command that follows, any gate still
standing between you and it, and the side doors. It renders `STATE.json.next_command`, so the
thing you are told to type and the thing on disk are the same value.

## The follow-up flow

A bug the by-hand pass turned up, or a review finding you deferred, becomes a **follow-up** — the
same loop, compressed. It drops the diagramming pass, **never** the separation of tests from code,
so it keeps both gates.

```
you: git worktree add -b <followup> <path> <parent-branch> ; cd into it
  │
  ├─ /story-followup-1-start <parent-id> ► nested home + transient RESEARCH.md
  ├─ /story-followup-2-plan ─────────────► PLAN.md         → GATE 1, read against the
  │                                                            PARENT's diagrams
  ├─ /story-followup-3-tdd-red ──────────► tests ▮         → GATE 2  (wrapper)
  ├─ /story-followup-4-tdd-green ────────► code ▮          (wrapper)
  ├─ /story-followup-5-check ────────────► refreshes the PARENT's ARCHITECTURE ▮  (wrapper)
  └─ /story-followup-6-wrap ─────────────► wiki ▮ + merge into the PARENT branch
```

Steps 3, 4 and 5 are **thin wrappers** — they do exactly what `/story-3-tdd-red`,
`/story-4-tdd-green` and `/story-5-check` do, which already behave correctly on a follow-up. The
wrappers exist so the sequence reads 1→6 and so `next_command` has a name to point at.

Re-running `/story-followup-1-start` in the same checkout opens another **round** — the build →
test-by-hand → find-another-issue → go-again loop — bumping `STATE.json.round` rather than
re-scaffolding.

## The case home

```
~/.claude/plans/<PROJECT>/YYYY-MM-DD_<short-name>/
├── STATE.json  STATUS.md  STATUS-<agent>.md   # transient — the wrap deletes these
├── RESEARCH.md          ≤ 70 lines
├── PLAN.md              ≤ 80 lines
├── ARCHITECTURE.md      ≤ 3 diagrams
├── MANUAL_TESTING.md    ≤ 50 lines — one ≤5-step procedure per criterion
├── IMPLEMENTATION.md    ≤ 40 lines — the verdict, not the transcript
├── REVIEW.md            uncapped findings table, only if /story-review ran
├── MODEL.md             # transient — only if /story-model drew one
└── YYYY-MM-DD_<followup>/   # a follow-up's home, nested inside its parent's
```

`<PROJECT>` and the short name both come from **you** at intake — never guessed. The date is the
creation date and never changes. Case homes sit alongside the existing flat `*.md` plan files;
nothing migrates.

A **follow-up** home holds only `STATE.json`, `STATUS.md`, a transient `RESEARCH.md` (≤ 40), and
`PLAN.md` (≤ 60) — which is the only durable artifact it leaves behind. It leans on the parent:
the check refreshes `../ARCHITECTURE.md`, the by-hand procedure lands in `../MANUAL_TESTING.md`,
and the parent's `PLAN.md` carries a durable `## Follow-ups` table.

**Transient vs durable** is what makes the docs cheap: the handoff pair and the agent logs are
mid-flight scaffolding and the wrap deletes them; their presence is also what "in progress"
*means*, since `/story-resume` finds live cases by globbing for `STATE.json`.

**Three rules make the budgets work:** state each decision once (the acceptance criteria are
canonical and **numbered `AC1…ACn`**; everything else cites the number), keep code out of the docs
(a `path:n-m` pointer *into* the code is fine — that is what the reading order is for — but never
as a way to *describe* a change), and never let the docs dwarf the diff. `## Open Questions` is
exempt from every budget and is **never edited** — you answer inline, and your words stay verbatim.

## Per command

### `/story-1-start [description]` — step 1
- **You:** answer intake, then read `RESEARCH.md` and answer its open questions.
- **AI:** runs `story-intake` (the change, the `<PROJECT>`, the repo and branch, an approved short
  name, the test and build commands), scaffolds the case home with `STATE.json`, `STATUS.md`, and
  a `PLAN.md` holding only `## Context` and `## Commands`, then launches the **`story-researcher`**
  agent, reads its `RESEARCH.md` back, and summarizes it.
- **Gate:** a read, not an approval. **Writes:** the case home, `RESEARCH.md`. No commit.
- **Never:** guesses the project, invents a case ID, plans, or touches the project repo.

### `/story-2-plan [case-id]` — step 2
- **You:** approve the plan at Gate 1; then read the shape it produces.
- **AI:** the **`story-planner`** agent, twice. `plan` mode writes `PLAN.md` — scope, 2–4 phases,
  numbered criteria, and `## For the builder`, which *is* the builder's prompt at step 4. After
  your approval, `model` mode writes `ARCHITECTURE.md` (PLANNED) and one ≤5-step manual procedure
  per criterion in `MANUAL_TESTING.md`.
- **Gate 1** — the plan. The shape that follows is handed over to read.
- **Backward edge:** if drawing the shape exposes a hole, it goes back to pass 1 rather than being
  patched quietly. **Writes:** three artifacts. No commit.

### `/story-3-tdd-red [case-id]` — step 3
- **You:** read and approve the failing tests. They are the contract the build is measured against.
- **AI:** `story-tdd` skill, red phase only — each numbered criterion becomes a test of *intended
  behavior*, every setup step and assertion commented for a junior reader; runs them with the
  narrow command from `## Commands` and confirms they fail **for the right reason**. Amends
  `PLAN.md` with what writing them turned up; a change to *scope* sends you back to step 2.
- **Gate 2** — the contract. The same pass never writes tests *and* product code.
- **Writes:** test files in the project repo. **On approval:** commits tests + `PLAN.md` and
  records `STATE.json.test_baseline_commit_hash`.

### `/story-4-tdd-green [case-id]` — step 4
- **You:** nothing during the run; then rule on any test change the audit surfaces.
- **AI:** launches the **`story-builder`** agent with almost nothing — the plan's
  `## For the builder` section is its prompt, by design. It implements the phases to green, builds
  to the shape in `ARCHITECTURE.md`, runs the real test and build commands, writes
  `IMPLEMENTATION.md` (verdict, not transcript), declares a **`Test changes:`** line, and commits.
- **The audit:** the session diffs the test files against `test_baseline_commit_hash`. Anything
  the builder did not explain is surfaced to you as a finding — **never reverted**. It does not
  *prevent* a build from editing a test; it makes every such edit visible and yours to rule on.
- **Gate:** none, unless the audit finds something. **Writes:** product code, one local commit.

### `/story-5-check [case-id]` — step 5
- **You:** rule on each divergence — intentional or not — then work through `MANUAL_TESTING.md`.
- **AI:** launches the **`story-checker`** agent, isolated so it re-derives the shape from
  `git diff` and the changed files rather than from the builder's account. It starts the
  verification suite in the background, refreshes `ARCHITECTURE.md` **in place**, swaps real
  `file:line` pointers into the reading order, reconciles `MANUAL_TESTING.md` against what
  shipped, and appends `## Divergence Log` — one entry per difference, ≤ 3 lines, saying *what
  changed*, *why*, and *whether it matters*.
- **Gate 3** — divergence, then the by-hand pass. **Writes:** a docs-only local commit.
- **Never:** edits the plan to agree with the code; reviews code quality.

### `/story-6-wrap [case-id]` — step 6
- **You:** confirm you have tested by hand.
- **AI:** `story-wrap` skill — writes an implementation entry in the **LLM Wiki** describing
  reality rather than plan intent, deletes the transients (`STATE.json`, `STATUS.md`, the agent
  logs, `MODEL.md`), and makes the close-out commit.
- **Gate:** none. **Never merges anything, ever.** Deleting `STATE.json` is what "wrapped" means.

### `/story-followup-1-start <parent-id> [description]` — step f1
- **You:** file the work in your head, **create the worktree yourself**, `cd` into it, then run
  this with the parent named explicitly.
- **AI:** resolves the parent (in progress **or already wrapped**), records the checkout and
  branch it finds itself in, scaffolds the **nested** home, registers a row in the parent's
  `## Follow-ups` table, and runs delta research into a transient `RESEARCH.md`.
- **Re-run in the same checkout:** another round, `STATE.json.round + 1`.

### `/story-followup-2-plan` — step f2
- **AI:** `story-planner` in `plan` mode, plus a self-contained "Builds on parent" section and a
  `## Test changes` list. Presents the **parent's** sequence diagram and names which arrows change.
- **Gate 1** — read it against the parent's diagrams, then approve. ≤ 60 lines covers everything.

### `/story-followup-{3-tdd-red, 4-tdd-green, 5-check}` — steps f3–f5
- **Thin wrappers** over the standard commands, which already read `STATE.json.workflow`. Same
  gates, same audit. The check lands on the **parent's** `ARCHITECTURE.md` and `MANUAL_TESTING.md`;
  the divergence log lands in the follow-up's own `PLAN.md`.

### `/story-followup-6-wrap` — step f6
- **AI:** the usual wrap duties in the worktree — wiki, flip the parent's row, delete the
  transients (**including `RESEARCH.md`** here), commit — then **merges the follow-up branch into
  the parent story branch** with `--no-ff`. It **refuses `main`/`master`/`develop`** and tells you
  to open a pull request instead: integrating a shared branch is a reviewed, remote operation. Any
  code conflict stops and comes to you. The worktree and branch are left for you to remove.

### `/story-review [case-id]` — optional
- **You:** triage each finding — fix now, defer to a follow-up, or accept with a reason.
- **AI:** dispatches the built-in `/code-review` and `/security-review` over the branch diff and
  aggregates them into `REVIEW.md`, a findings table. It never fixes a finding itself.
- Not a substitute for `/story-5-check`: a clean review says nothing about whether what shipped is
  what was designed.

### `/story-model [case-id]` — optional, any time
- **AI:** `story-planner` in `flows` mode draws `MANUAL_TESTING.md`'s procedures as user-flow
  diagrams in `MODEL.md`. Learning only — transient, read by nothing, deleted at the wrap.
- **Advances nothing.** Zoom-ins are drawn in conversation and never written to a file.

### `/story-resume [case-id]`
- **You:** the fresh-session entry point; pick which case if several are live.
- **AI:** reads `STATUS.md` and `STATE.json`, reports the step, the scope, the open questions, the
  worktree to `cd` into on a follow-up, any half-finished agent log, and **the next command spelled
  out**, then pre-reads that step's inputs.
- **Gate:** none — orients and hands back. **Never advances.** Strictly read-only.

### `/story-explain-workflow [command-name]`
- **AI:** presents this reference, embedded in the command file. No repo scan, no directory
  listing, no Mermaid. Read-only.

### `/story-update-workflow <description>`
- **You:** describe the change, then **approve the edit plan**.
- **AI:** proposes what it will change and stops. On approval it edits the command, skill, or
  agent, then syncs every mirror in the same pass — this embedded reference,
  `workflow_flowchart.md`, `README.md`, the templates, and `plan_initial.md`'s §6 layout. Re-runs
  `install.sh` when the file set changed, saves the approved plan under
  `workflow-modification-plans/`, and makes one local commit with **no `Case:` trailer**.
- **Gate:** the edit-plan gate, before anything is written.

## Supporting cast (not commands)

- **`story-context-home` skill** — the load-bearing one: the home layout for both flows, the
  artifacts and their budgets, the `STATE.json` schema and the `STATUS.md` handoff pair, the
  `What's next` block, case resolution, the state machine
  (`started → planned → modeled → tested-red → built → checked → reviewed → wrapped`), the
  `## Open Questions` exemption, the templates, and the commit-message format.
- **`story-intake` skill** — the conversational gathering that opens a case and composes the
  research brief. Never guesses the project, never invents a case ID.
- **`story-architecture-diagram` skill** — PLANNED / REFRESH-in-place / FLOWS modes, the section
  order, and the two rules: **one set, always current** and **one altitude, no tiers**.
- **`story-tdd` skill** — the red phase only, plus the baseline commit that makes the audit
  possible.
- **`story-wrap` skill** — the wiki write-up, the deletion list, the merge policy.
- **`story-followup` skill** — the nested home, rounds, what lands on the parent, and the
  never-merge-to-a-shared-branch rule.
- **`story-researcher` agent** — the isolated codebase sweep; reads the wiki, never writes it;
  says what is there, never what to build.
- **`story-planner` agent** — `plan` / `model` / `flows`; authors, never gates.
- **`story-builder` agent** — the isolated build; declares every test it touched; commits locally.
- **`story-checker` agent** — the isolated re-derivation; refreshes the architecture, verifies,
  logs the divergences; not a code review.
- **`llm-wiki` skill** (pre-existing, not part of this repo) — read at research, written once at
  the wrap.

**The agents author; the main session gates and hands over.** An agent cannot take your approval,
and routing your answers back through one is how they would stop being verbatim. **No agent writes
`STATUS.md` or `STATE.json`** — it names the step it reached, and the session records it once the
gate work is done. The only status file an agent writes is its own `STATUS-<agent>.md` log, which
is what lets a run that dies part-way be picked up rather than restarted blind.

**The full suite never runs in your session.** It runs inside `story-builder` at the build and
`story-checker` at the check.

## Version control

Yours, with one exception. The workflow never creates, switches, or merges branches on the
standard flow, never creates a worktree, and **never pushes**. You make the branch before step 1
and the worktree before a follow-up. The single exception is `/story-followup-6-wrap`, which
merges a follow-up branch into its parent story branch and refuses to touch a shared one.

## Installation

Commands, skills, and agents live in `/home/nic/repos/sde-agentic-workflow` and are symlinked
into `~/.claude/` by `install.sh` (`install` / `--check` / `--remove`). The script only ever
touches symlinks that resolve back into that repo, so anything else in `~/.claude/skills/` is
safe, and it prunes its own dangling links when a file is renamed or removed upstream. Re-run it
after a `git pull`.
