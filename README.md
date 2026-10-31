# sde-agentic-workflow

A personal, human-in-the-loop SDLC workflow for AI-assisted development, built as a set of Claude
Code slash commands. **You stay in the loop at every step** instead of running anything
autonomously.

The whole point: keep your comprehension of an implementation in pace with how fast an AI
generates it. The artifacts do that, and they are **front-loaded** — the cheapest place to fix your
mental model is before anything has been written. You read the **research** at `/story-1-start`,
approve the **plan** and then read the **shape** it produced at `/story-2-plan`, approve the
**contract** (the tests) before any code, and review what **actually shipped** against the plan
afterwards. Two things stop and wait for you before code — the plan and the test contract —
because those are decisions; everything else is handed over for you to read.

There is deliberately **no orchestrator**. You advance by typing the next command.

## The standard flow

One case = one unit of work. All its artifacts live in one context home under
`~/.claude/plans/<PROJECT>/YYYY-MM-DD_<short-name>/`. Each command does one phase and hands back.

| Step | Command | What it does | Your gate |
|---|---|---|---|
| 1 | `/story-1-start [desc]` | Intake in the session — the change, the project, the repo and branch, the test and build commands — then scaffolds the case home (`STATE.json`, `STATUS.md`, `PLAN.md` context) and launches the **`story-researcher`** agent, which sweeps the codebase and reads the LLM Wiki for prior art. The session reads `RESEARCH.md` back and summarizes it. | read `RESEARCH.md`, answer its open questions |
| 2 | `/story-2-plan` | The **`story-planner`** agent in **two passes**: `plan` writes `PLAN.md` (scope, 2–4 phases, **numbered** `AC1…ACn`, open questions, and a `## For the builder` section that *is* the builder's prompt at step 4); then, after your approval, `model` draws `ARCHITECTURE.md` and writes one ≤5-step manual procedure per criterion in `MANUAL_TESTING.md`. | **Gate 1** — approve the plan; then read the diagrams and the manual procedures |
| 3 | `/story-3-tdd-red` | Author failing tests from the numbered criteria (`story-tdd`, red phase only) in five stages: **design** the paths from initial to terminal states (`functional-test-design`), **write** path tests, **diagnose** each test's layer and how informative its failure is (`test-suite-analysis--diagnostic-capability`), **factor** common procedures into task libraries (`test-suite-analysis--test-tasks`), and **run** them to confirm they fail for the right reason. Then **amend `PLAN.md`** with what this turned up, and commit tests + helpers + `PLAN.md` as the build's **baseline**, with the path inventory in the commit body, and record the hash. | **Gate 2** — read and approve the tests, path inventory, layer map, task list and any amendment |
| 4 | `/story-4-tdd-green` | Implement to green in the **`story-builder`** agent, prompted with almost nothing but `PLAN.md` and `ARCHITECTURE.md`; it commits locally. The session then **diffs the test files against the baseline** and surfaces any change the builder did not explain. | rule on any test change the audit finds |
| 5 | `/story-5-check` | The **`story-checker`** agent reads the code first and the plan second: runs the verification suite in the background, refreshes `ARCHITECTURE.md` **in place**, reconciles `MANUAL_TESTING.md`, and logs every divergence. Commits docs. | **Gate 3** — review the divergence log, then test by hand |
| — | `/story-review` | *(optional)* dispatches the built-in `/code-review` and `/security-review` over the branch diff into a `REVIEW.md` findings table | triage each finding |
| 6 | `/story-6-wrap` | Records what shipped in the **LLM Wiki**, deletes the transient files, makes the close-out commit. Never merges anything. | — |
| — | `/story-model` | *(optional, any time)* draws the manual-testing procedures as user-flow diagrams — **learning only, deleted at the wrap** | none — read it, ask for zoom-ins |
| — | `/story-resume` | reads the handoff pair and tells you the next command | fresh-session entry point |
| — | `/story-explain-workflow [cmd]` | explains the whole system, or one command | reference, no side effects |
| — | `/story-update-workflow <desc>` | changes the system itself — edits the pieces and syncs every mirror in one commit | approve the edit plan |

**The numbers are the order, and only the mandatory steps have one.** If a command has no number,
skipping it costs you nothing.

**Every command ends with a `What's next` block** — the one command that follows, any gate still
standing, and the side doors. It renders `STATE.json.next_command`, so the thing you are told to
type and the thing on disk are the same value.

The rendered diagrams of both flows live in **[`workflow_flowchart.md`](workflow_flowchart.md)**,
and only there.

## The follow-up flow

For bugs and review comments spun out of a case, the compressed path below replaces the linear
flow. **Set the worktree up yourself first** — no command creates one or checks for one.

| Step | Command | What it does | Your gate |
|---|---|---|---|
| f1 | `/story-followup-1-start <parent-id> [desc]` | links to the parent, records the checkout it is run in, scaffolds the **nested** home, delta research into a transient `RESEARCH.md` | read the delta |
| f2 | `/story-followup-2-plan` | scope, 1–3 phases, numbered criteria, **plus the `## Test changes` the red step authors from**, presented against the **parent's** diagrams | **approve the plan** |
| f3 | `/story-followup-3-tdd-red` | thin wrapper over `/story-3-tdd-red` | **approve the tests** |
| f4 | `/story-followup-4-tdd-green` | thin wrapper over `/story-4-tdd-green` — same builder, same audit | as above |
| f5 | `/story-followup-5-check` | thin wrapper over `/story-5-check`, but the refresh lands on the **parent's** `ARCHITECTURE.md` | review the divergence log |
| f6 | `/story-followup-6-wrap` | wiki, flip the parent's row, drop the transients, commit — then **merge into the parent story branch** (never `main` — that is a PR) | — |

```bash
git worktree add -b fix-queue-ordering ~/worktrees/fix-queue-ordering add-queue-selection
cd ~/worktrees/fix-queue-ordering
/story-followup-1-start 2026-08-20_add-rereading-queue-selection
```

The parent can be **still in progress or already wrapped** — the wrap leaves the durable artifacts
and the parent's `## Follow-ups` table in place precisely so a follow-up still works months later.
Re-running `/story-followup-1-start` in the same checkout opens another **round**, bumping
`STATE.json.round` instead of re-scaffolding.

Steps f3–f5 are **thin wrappers with no logic of their own** — the standard commands already read
`STATE.json.workflow` and behave correctly on a follow-up. The wrappers exist so the sequence you
type reads 1→6 and so `next_command` has a name to point at.

## The case home

```
~/.claude/plans/<PROJECT>/YYYY-MM-DD_<descriptive-short-name>/
├── STATE.json  STATUS.md  STATUS-<agent>.md   # transient — the wrap deletes these
├── RESEARCH.md          # what the change has to fit into
├── PLAN.md              # scope, phases, numbered criteria, commands, builder brief, divergences
├── ARCHITECTURE.md      # Mermaid: components + sequence (+ state, if it earns its place)
├── MANUAL_TESTING.md    # one ≤5-step by-hand procedure per criterion
├── IMPLEMENTATION.md    # the build's verdict
├── REVIEW.md            # only if /story-review ran
├── MODEL.md             # transient — only if /story-model drew one
└── YYYY-MM-DD_<followup>/   # a follow-up's home, nested inside its parent's
```

- `<PROJECT>` and the short name both come from **you** at intake. Never guessed.
- The date is the creation date and never changes.
- Case homes sit alongside the existing flat `*.md` plan files. Nothing migrates.
- A **follow-up** holds only `STATE.json`, `STATUS.md`, a transient `RESEARCH.md`, and `PLAN.md` —
  the only durable artifact it leaves behind. It leans on the parent for diagrams and manual tests.

**Transient vs durable** is what keeps the footprint honest: the handoff pair and the per-agent
logs are mid-flight scaffolding, and their presence is also what "in progress" *means* —
`/story-resume` finds live cases by globbing for `STATE.json`.

**Line budgets**, because docs that restate the diff crowd out the comprehension the workflow is
for:

| Document | Budget |
|---|---|
| `RESEARCH.md` | ≤ 70 lines (≤ 40 on a follow-up) |
| `PLAN.md` | ≤ 80 lines (≤ 60 on a follow-up), excluding the Divergence Log and Open Questions |
| `ARCHITECTURE.md` | ≤ 3 diagrams |
| `MANUAL_TESTING.md` | ≤ 50 lines |
| `IMPLEMENTATION.md` | ≤ 40 lines |
| `## Divergence Log` | ≤ 3 lines per divergence |

Three rules make them achievable: **state each decision once** (the numbered criteria are
canonical; everything else cites the number), **no code in the docs**, **never let the docs dwarf
the diff**. `## Open Questions` is exempt from every budget and is never edited by any command —
only appended to.

## Why it's structured this way

- **Commands** (`commands/`) are thin — they parse input, delegate, and relay. No logic.
- **Skills** (`skills/`) hold the reusable logic, the conventions, and the templates.
- **Agents** (`agents/`) run the phases that would otherwise flood the main context: the research
  sweep, the planning passes, the build, and the post-build re-derivation.
- **The agents author; the main session gates and hands over.** An agent cannot take your
  approval. **No agent writes `STATUS.md` or `STATE.json`** — it names the step it reached and the
  session records it. The only status file an agent writes is its own `STATUS-<agent>.md` log, so a
  run that dies part-way can be picked up rather than restarted blind.
- **The full suite never runs in your session.** It runs inside `story-builder` at the build and
  `story-checker` at the check.
- **The test contract has an address.** The red step commits the tests you approved and records
  the hash as `test_baseline_commit_hash`; the green step diffs the test files against it. It does
  not *prevent* a build from editing a test — it makes every such edit visible and yours to rule on.
- **One set of diagrams, always current.** `/story-5-check` refreshes `ARCHITECTURE.md` in place
  rather than appending an as-built copy, so the file never doubles and never contradicts itself.
  The comprehension gap is vocabulary and causality, not granularity, so the file carries a
  **Concepts in this story** list and a **Why not the obvious thing** section rather than extra
  diagrams. Depth is generated conversationally and never committed.

## What this workflow does not own

- **Version control is yours**, with one exception. It never creates, switches, or merges branches
  on the standard flow, never creates a worktree, and **never pushes**. The exception is
  `/story-followup-6-wrap`, which merges a follow-up branch into its parent story branch and
  refuses to touch `main`/`master`/`develop`.
- **No per-project config.** No config file, no framework detection. Test and build commands are
  established conversationally at intake and recorded in `PLAN.md`.
- **No orchestration.** Nothing chains the steps for you.

## Layout

```
sde-agentic-workflow/
├── README.md                             # mirror #1 — this file
├── workflow_flowchart.md                 # mirror #2 — the rendered Mermaid: both flows, the
│                                         #   command map, the state machine. The ONE place
│                                         #   diagrams live; /story-explain-workflow has none
├── SDE-story-workflow-explained.md       # the work system this one is adapted from (reference)
├── plan_initial.md                       # the plan the first version of this repo implemented
├── install.sh                            # idempotent symlinker: install / --check / --remove
├── commands/                             # 17 story-* commands: 6 numbered standard steps,
│                                         #   6 story-followup-N (three of them thin wrappers),
│                                         #   story-review, story-model, story-resume, and the
│                                         #   two meta commands
├── skills/
│   ├── story-context-home/               # + templates/STORY-ARTIFACTS.md
│   ├── story-intake/
│   ├── story-architecture-diagram/
│   ├── story-tdd/                        # the red phase; loads the three below as its stages
│   ├── story-wrap/
│   ├── story-followup/
│   ├── functional-test-design/           # red: design — states → paths → path tests
│   ├── test-suite-analysis--diagnostic-capability/  # red: diagnose — layers, localizing failures
│   └── test-suite-analysis--test-tasks/  # red: factor — common procedures → task library
├── agents/                               # 4 authoring agents
│   ├── story-researcher.md               # the codebase sweep; reads the wiki, never writes it
│   ├── story-planner.md                  # plan / model / flows
│   ├── story-builder.md                  # the build
│   └── story-checker.md                  # the post-build verification and refresh
└── workflow-modification-plans/          # the approved edit plan behind each change to the system
```

**Commands are thin** → **skills hold the logic and the templates** → **isolated agents run the
heavy phases**. That separation is the thing most worth protecting; if a command starts holding a
rule, push the rule down into a skill.

## Install

```sh
./install.sh            # symlink commands, skills, and agents into ~/.claude/
./install.sh --check    # report what is linked, missing, stale, or blocked; writes nothing
./install.sh --remove   # remove only the symlinks this script created
```

The script only ever creates, replaces, or deletes a symlink that resolves back into this repo. A
real file or directory at a destination is reported as `BLOCKED` and left alone — which is what
keeps the pre-existing `~/.claude/skills/llm-wiki` safe. It also **prunes its own dangling links**,
the ones left behind when a command, skill, or agent is renamed or deleted upstream (`--check`
reports them as `STALE`). Re-run it after a `git pull`.

## Changing the workflow

Use `/story-update-workflow <description>`. It proposes an edit plan and stops for approval, then
edits the system and syncs every mirror in one commit: the reference embedded in
`story-explain-workflow.md`, `workflow_flowchart.md`, this README, the templates, and
`plan_initial.md`'s layout. Prefer it over hand-editing — a stale mirror misleads.

## Two integrations

**LLM Wiki.** `~/.claude/llmwiki/CLAUDE.md` requires every wiki project to have a matching
`~/.claude/plans/<Project>/` directory. Because case homes *are* created there, a wiki entry's
`plan-refs:` points straight at a case's `PLAN.md` — no copy step. `/story-6-wrap` is the only
thing in the workflow that writes to the wiki; research reads it.

**Commit messages.** Every commit follows `~/.claude/rules/nics-rules/commit-messages.md`. The
project reference ID is the case's `<PROJECT>`; the case ID is a **trailer**, not a prefix:

```
minor(ReReading): add rereading queue selection

Implements the case's three acceptance criteria end to end. The selection
pass now runs before render rather than inside it, which removes the
double-fetch on first paint.

Case: 2026-08-20_add-rereading-queue-selection
Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
```
