# 2026-08-20 — rebuild to match the updated work design

## What was asked

> Update the workflow to match the following files: `~/Downloads/updated_workflow_flowcharts.md`
> and `~/Downloads/updated_workflow_README`. These two files describe an updated version of the
> `/story-*` workflow.

Those files describe the updated **work** system (`my-workflow`), not this one: Jira research
agents, artifacts in `docs/<CASE-ID>/` inside the project repo, worktrees, a follow-up flow, and
team skills (`engineering-tdd`, `engineering-jira-gathering`, `llmwiki-research`). This repo is
the personal-machine adaptation of the *older* work system (`plan_initial.md` §5), and this
machine has no MCP servers configured and none of those team skills installed.

Two artifacts of the source files, noted and ignored: a `= = = = BOOKMARK = = = =` marker
mid-sentence in the README, and the word "Jira" stripped out of the README in several places
while the flowcharts file uses it freely.

## What was decided

| Question | Decision |
|---|---|
| Fidelity | Adapt to this machine **and** adopt the follow-up flow. Scaffold any missing agent or skill |
| New capabilities | All four: the research step, manual-testing procedures, the test baseline + diff audit, the wrap step |
| Artifact names | The work names — `RESEARCH.md`, `PLAN.md`, `ARCHITECTURE.md`, `MANUAL_TESTING.md`, `IMPLEMENTATION.md`, `REVIEW.md` |
| Diagrams | `workflow_flowchart.md` becomes the one place Mermaid lives; the embedded reference keeps prose + ASCII only |
| `/story-review` | Included, dispatching the built-in `/code-review` and `/security-review` — overturning `plan_initial.md` §2's "no review aggregation" boundary |
| Follow-up homes | **Nested inside the parent case home**, so `../` reaches the parent's artifacts |
| Jira | Dropped entirely. The two tool-split researchers collapse to one `story-researcher`; `story-intake` supplies the context the ticket walk used to |
| Case homes | Stay under `~/.claude/plans/<PROJECT>/`, not `docs/` inside the project repo |

**Concern recorded at the gate:** this roughly triples the system — 7 → 17 commands, 2 → 4
agents, 4 → 6 skills, 2 → 7 artifacts — and reintroduces the transient state files the first
version was proud of not having. The thing that made the earlier version cheap to maintain was
its size; the mirrors are correspondingly more expensive to keep honest from here.

## What changed

**Created** — commands `story-{1-start,2-plan,3-tdd-red,4-tdd-green,5-check,6-wrap}`, the six
`story-followup-N-*`, `story-review`, `story-model`; agents `story-researcher`, `story-planner`,
`story-checker`; skills `story-architecture-diagram`, `story-wrap`, `story-followup`;
`skills/story-context-home/templates/STORY-ARTIFACTS.md`; `workflow_flowchart.md`.

**Rewritten** — `story-context-home` (the new home layout for both flows, the seven artifacts and
their budgets, the `STATE.json` schema, the `STATUS.md` handoff pair, the `What's next` block,
case resolution including nested follow-ups, the state machine); `story-intake` (feeds the
research brief, gains the follow-up form, `<PARENT>` renamed `<PROJECT>` so "parent" means a
parent *case*); `story-tdd` (the baseline commit and hash, the follow-up's `## Test changes`);
`story-builder` (prompted by `## For the builder`, declares a `Test changes:` line, writes
`IMPLEMENTATION.md`, honours `workflow: followup`); `story-resume`, `story-explain-workflow`,
`story-update-workflow`, `README.md`.

**Deleted** — `commands/story-{plan,tdd-red,build,check}.md`, `agents/story-divergence.md`,
`skills/story-diagrams/`, `templates/{plan,diagrams}.md`.

**Amended** — `plan_initial.md`: §6 layout rewritten, and a header note marking §1–§5 and §7–§11
as history of the initial build.

**`install.sh`** gained a prune sweep for its own dangling links, since four renamed commands, a
renamed agent, and a renamed skill would otherwise have left `/story-plan` and friends live in
`~/.claude/`. `--check` reports them as `STALE` and exits non-zero.

## Behavior changes worth naming

- **"The tests are untouchable" is gone**, replaced by baseline-and-audit: the red step commits
  the approved tests and records the hash; the green step diffs against it and surfaces any
  unexplained edit as a finding, never reverting it. Visibility rather than prohibition.
- **The builder is prompted by the plan**, not by the session — `## For the builder` is its brief.
- **The check now verifies**, running the suite in the background while it does the divergence
  work, and reconciles `MANUAL_TESTING.md` as well as the diagrams.
- **The workflow now merges, once**: `/story-followup-6-wrap` into a parent story branch, refusing
  `main`/`master`/`develop`. Everything else still never branches, merges, or pushes.
- **Progress moved** from a single `## Workflow status` line to the transient `STATE.json` +
  `STATUS.md` pair, written only by the main session.

## Verification

`./install.sh --check` reports 27 linked, 0 missing, 0 blocked, 0 stale (17 commands, 6 skills,
4 agents). Every command appears in all three mirrors — the embedded reference, the README, and
the flowchart. The four Mermaid blocks lint clean: fences pair, every node label is quoted, every
`:::class` used is defined in its own block. No live reference to `plan.md`, `diagrams.md`,
`story-diagrams`, `story-divergence`, or `## Workflow status` survives outside the two history
files.

An end-to-end dry run needs the user: intake is conversational, so `/story-1-start` cannot be
exercised without them.

## Left for the user

`~/.claude/llmwiki/CLAUDE.md` still describes a case directory as holding `plan.md` and
`diagrams.md` (lines 56, 65, 67, 121). `/story-update-workflow` may never edit the wiki, so that
edit is the user's to apply.
