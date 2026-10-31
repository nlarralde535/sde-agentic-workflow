# 2026-10-31 — implement the test philosophy in the red step

## What was asked

> Update the sde-agentic-workflow to include the ideas in the two symlinked notes, by creating
> new skills called as part of the `/story-3-tdd-red` step:
>
> 1. From *System for generating functional tests*:
>    a. `functional-test-design` — the "Chapter 3: Testing Techniques" system
>    b. `test-suite-analysis_test-tasks` — find common test tasks that can be factored out
> 2. From *Zoom out from smoke tests*:
>    a. `test-suite-analysis_diagnostic-capability` — the idea in the "Context" section

This was the **edit plan** for `/story-update-workflow`'s Step 1 gate. It was drafted at the repo
root as `2026-10-31_implement_test_philosophy.md`, answered inline at the gate (the `ANSWER:`
lines under each decision below), and moved here after approval. **What was decided** and
**What changed** are at the end of the file.

## The ideas, restated

These are the ideas the skills have to encode. If any of them is wrong, the skill will be wrong
too.

**Functional test design (Ch. 3, state-based + path testing).**
1. Enumerate every **initial state** the program (or the unit under change) can start in.
2. Enumerate as many **terminal states** as makes sense.
3. Elaborate as many **paths** between initial and terminal states as makes sense.
4. Write a **path test** for each chosen path.

**Test tasks (Ch. 5, task libraries).** Break the use cases into their constituent, conceptually
distinct **tasks**. When the same procedure appears in several tests, move it into a
task-library function and reuse it. This works at a higher level than fixtures: fixtures handle
setup and teardown of state, and tasks are named steps of a user's procedure, like
`logInAs(user)` or `addItemToCart(item)`.

**Diagnostic capability ("Context", building on "The Point").** A test is worth having when its
*failure* tells you something. A failure should answer three questions: **where** it happened,
**what was predicted**, and **what the failure state is**. The most important of the three is
*where*: a good failure localizes the fault or at least narrows it. Doing that well means
understanding the software's **implementation layers**, having tests specific to each layer,
and running them one layer at a time from the lowest up. That is how you "zoom out from the
smoke test".

**The axis distinction (Addendum).** The two notes describe two independent axes. Any one test
sits on both of them:

| Axis | What it describes | When it applies | Skill that owns it |
|---|---|---|---|
| **States / paths** | conditions of *running* code at a moment in time | runtime | `functional-test-design` |
| **Implementation layers** | structure of *inert* code as written | static, pre-compile | `test-suite-analysis_diagnostic-capability` |

The skills should state this distinction plainly so they don't overlap. One designs *which
behaviors* to test, and the other checks *at what layer* each test runs and *how informative*
its failure is.

## Where they slot into the red step

The current red step does this: read ACs, then write tests, then run and confirm red, then
amend PLAN, then Gate 2, then commit the baseline. The new order is:

```
 /story-3-tdd-red
  1. load skills ── story-context-home, story-tdd, + the three new ones
  2. resolve case, read PLAN.md / ARCHITECTURE.md
  3. DESIGN    ── functional-test-design
  │              initial states × terminal states → candidate paths
  │              → choose paths, map each to an AC (uncovered path ⇒ scope question)
  4. WRITE     ── story-tdd: one or more path tests per AC, commented for a junior reader
  5. DIAGNOSE  ── test-suite-analysis_diagnostic-capability
  │              map tests to layers; find layers with no tests, tests that span several
  │              layers, and failure messages that don't say where / predicted / actual
  │              → split tests, sharpen assertion messages, propose a layer run order
  6. FACTOR    ── test-suite-analysis_test-tasks
  │              find repeated procedures → extract task-library functions (test code)
  7. RUN       ── story-tdd: narrow command, confirm red for the RIGHT reason
  8. AMEND PLAN.md, then GATE 2 (presents the design, layer map, and task extractions too)
  9. on approval: commit tests + task library + PLAN.md as the baseline
```

**Why this order:**
- *Design before writing*, because the paths are where the tests come from.
- *Diagnose before factoring*, because diagnosis can split tests or add lower-layer tests, and
  factoring should run once on the final set.
- *Run last*, so the red check covers the code being committed, including the extracted helpers.
  A helper that blows up during setup is a failure for the wrong reason, and the existing
  verdict table already catches that.

## Design of each skill

All three are **general-purpose**: each works on its own against any test suite, without a story
case. Each one has a short `## When loaded from story-tdd` section covering how it behaves inside
the red step. That keeps them reusable, and it keeps them out of the `story-` namespace, which
holds workflow mechanics.

### 1a. `skills/functional-test-design/SKILL.md`

- **Input:** the behavior under change (in the workflow, `PLAN.md`'s ACs plus
  `ARCHITECTURE.md`'s `## Sequence` and optional `## State` diagram) and the code it touches.
- **Procedure:**
  1. **Pick the unit.** Say which system's states you're enumerating: the feature or component
     under change, not the whole application. Without this boundary the enumeration doesn't stop.
  2. **Initial states:** list every distinct starting condition that changes behavior (empty,
     populated, partially configured, logged in or out, and so on). Merge states that the code
     can't tell apart.
  3. **Terminal states:** list the outcomes that matter, both success and the failure modes
     worth having. Each one must be observable, because a test has to assert it.
  4. **Paths:** for each (initial, terminal) pair, write the path between them as a sequence of
     transitions, or mark it unreachable. Include the happy path and the failure paths.
  5. **Choose.** "As many as makes sense" needs an explicit rule. Keep every path that some AC
     depends on. Keep a path that exercises a distinct transition no kept path covers. Drop a path
     that only repeats transitions already covered. Every dropped path gets a one-word reason.
  6. **Map to ACs.** Each kept path cites the AC(s) it proves. A **path that no AC covers** is a
     scope finding, and it goes through the existing mechanism: amend `PLAN.md` for wording, or
     send the user back to `/story-2-plan` for scope. A **path that only manual testing can
     reach** is reported, consistent with story-tdd's "leave pure rendering to the manual test".
- **Output:** a compact **path inventory**: initial states, terminal states, and a table of
  path → AC → kept or dropped (and why). In the workflow it is presented at Gate 2.
- **Test naming:** each path test's name or `describe` block states its path
  (`from an empty queue, adding an entry ends in a one-item queue`). That way the inventory can
  be read back from the test file.
- **Relationship to story-tdd's existing rules:** story-tdd keeps its "be realistic, not
  exhaustive" guard, and *choose* (step 5) is how that guard gets applied. story-tdd's rule
  "each AC gets at least one test" turns into "each AC gets at least one path test".

### 1b. `skills/test-suite-analysis_test-tasks/SKILL.md`

- **Input:** a set of test files. In the workflow, that's the tests written in this pass plus
  the neighbouring test files and existing helpers, read for conventions and reuse.
- **Procedure:**
  1. **Inventory the existing helpers first:** fixtures, page objects, factories, task helpers.
     Reuse what's already there before creating anything.
  2. **Break each test into its tasks:** the named, conceptually distinct steps of its procedure.
  3. **Find repeats:** the same task appearing in two or more tests, or a multi-step procedure
     that a reader would describe in one phrase.
  4. **Decide the layer of abstraction:** setup or teardown of state goes in a **fixture**, using
     the framework's mechanism (for example Playwright fixtures or pytest fixtures). A step of a
     user's procedure goes in a **task**: a plain function named for the user's intent.
  5. **Extract** into the project's existing helper location and style, or propose one if none
     exists. Each task does one thing. It takes parameters, never hidden state. It **does not
     assert** the outcome under test, because assertions stay visible in the test body. Every
     extracted task is commented for a junior reader, the same as story-tdd requires for tests.
  6. **Don't over-factor:** a procedure used exactly once stays inline. A task that's only a
     wrapper around one framework call isn't a task.
- **Output:** a list of extracted tasks: the name, the tests that use it, and the file it lives
  in. In the workflow, this goes to Gate 2.
- **Workflow consequences (these need the changes listed below):**
  - Task-library files are **test code**. They're staged into the baseline commit and they're in
    the paths the green step audits. Otherwise the builder could edit a helper and quietly change
    what a test means.
  - **Scope:** see decision D3.

### 2a. `skills/test-suite-analysis_diagnostic-capability/SKILL.md`

- **Input:** a set of test files plus the code they exercise. In the workflow, also
  `ARCHITECTURE.md`'s `## Components`, which already names the boundaries.
- **Procedure:**
  1. **Derive the implementation layers** with static analysis of the code as written. Use
     module and package boundaries and the dependency direction (for example: pure domain logic,
     then data access / adapters, then service / API, then UI / end-to-end). The skill states
     this as *static structure, not runtime state*, citing the Addendum. Layers are derived from
     the project, never imposed from a template.
  2. **Map each test to its layer:** the lowest layer whose failure it can detect, and the
     layers it crosses.
  3. **Score each test's failure on three questions:**
     - *Where:* would a failure point to one layer or unit, or to "somewhere"?
     - *Predicted:* does the assertion or its message state the expected value or condition?
     - *Failure state:* does the output show the actual value or state, not just `false`?
  4. **Find the gaps:**
     - layers with no tests, which means a failure there only surfaces higher up, unlocalized
       (the "OBDII problem")
     - tests that span several layers *and* have no lower-layer counterpart
     - bare assertions (`assert ok`, `expect(x).toBeTruthy()`)
     - one test asserting several layers' behavior
  5. **Recommend or apply fixes:** add a lower-layer test, split a multi-layer test, or add an
     assertion message or a more specific matcher. Apply the fixes that only touch this pass's
     tests. Report the rest.
  6. **Layer run order:** propose the order the suite should run in to zoom out from the smoke
     test (lowest layer first, stop at the first failing layer), expressed in the project's own
     test-runner terms (paths, tags, projects). Whether it becomes a command is decision D4.
- **Output:** a **layer map** (layer → its tests → gaps) plus the list of fixes made and the list
  of fixes recommended. In the workflow, this goes to Gate 2.
- **The smoke test is the base case.** The skill explains the analogy in a short paragraph: a
  passing smoke test says only that a minimum capability is present, and a failing one says only
  roughly where. The layer tests are how you get above that.

## Files this change touches

**Created**
| File | What |
|---|---|
| `skills/functional-test-design/SKILL.md` | 1a as above |
| `skills/test-suite-analysis_test-tasks/SKILL.md` | 1b as above (name subject to D1) |
| `skills/test-suite-analysis_diagnostic-capability/SKILL.md` | 2a as above (name subject to D1) |

**Edited**
| File | What changes |
|---|---|
| `skills/story-tdd/SKILL.md` | A new `## The red pass, in order` section: design, write, diagnose, factor, run. Each stage loads its skill. "One test per AC" becomes "one path test per AC". Task-library files are test code and belong in the baseline. Gate 2 contents get the path inventory, layer map, and task list, each kept short. On a follow-up, the design covers only the delta in `## Test changes` |
| `commands/story-3-tdd-red.md` | Step 1 loads the three new skills. Steps 4 and 7 name the new stages and Gate 2 outputs in one line each. The rules stay in the skill and the command stays thin |
| `commands/story-4-tdd-green.md` | The audit's "the test paths" explicitly includes task-library and fixture files |
| `agents/story-builder.md` | One line: task-library helpers and fixtures are test files, covered by the don't-touch rule and the `Test changes:` declaration |
| `commands/story-followup-3-tdd-red.md` | **No change.** It's a thin wrapper, and the follow-up behavior lives in story-tdd |

**Mirrors (forced by `/story-update-workflow`)**
| Mirror | Why |
|---|---|
| `commands/story-explain-workflow.md` | Always. The step-3 entry describes the new stages, and "Supporting cast" lists the three skills |
| `workflow_flowchart.md` | The standard-flow node `TA` (and the follow-up `FTA` if it restates it) gains the design, diagnose, and factor stages |
| `README.md` | The step-3 table row and the `skills/` tree in Layout |
| `plan_initial.md` §6 | Three skill directories added to the target layout |
| `STORY-ARTIFACTS.md` | Only if D2 adds a `PLAN.md` section, or D4 adds `## Commands` rows |

**File set changes** because three skills are added, so **re-run `./install.sh`** afterwards. Its
`skills/*/` glob picks them up with no script change. They'll be installed globally under
`~/.claude/skills/`, which suits skills meant to be general-purpose.

## Decisions needed at the gate

**D1 — skill names with underscores.** The Agent Skills spec limits a skill `name` to lowercase
letters, digits, and **hyphens**. A name like `test-suite-analysis_test-tasks` risks failing
validation or not being discovered. **Recommended:** `test-suite-analysis-test-tasks` and
`test-suite-analysis-diagnostic-capability`. If the `_` is meant to separate a family name from
a member name, double hyphens would keep that visually. Before choosing, I'll verify against the
current Claude Code docs whether underscores are accepted.
 - ANSWER: replace the underscore with double hyphens 

**D2 — where the path inventory lives.** The red step currently writes nothing to the case home
except a `PLAN.md` amendment, and `PLAN.md` already has an 80-line budget.
- *(a) Recommended:* present it at Gate 2 and let the tests carry it, with path-named tests and
  `describe` blocks. There's no new artifact and no budget pressure, and the record lives where
  it can't drift.
- *(b)* Add a `## Test design` section to `PLAN.md` of 10 lines or fewer. It's durable and the
  checker can see it, but it uses budget and restates the tests.
- *(c)* A new `TEST_DESIGN.md` artifact. That's an eighth artifact plus changes to the template,
  the budget table, and wrap, which is heavy for what it holds.
	- ANSWER: Option (a), present it at Gate 2, allow for the user to request modification, and then capture the path inventory in the corresponding commit message

**D3 — task-library scope.** Extracting a task out of *existing* tests means editing tests that
already pass, inside a commit labelled as this case's baseline.
- *Recommended:* the factoring skill **extracts from this pass's new tests**, reuses existing
  helpers freely, and **reports** refactors of pre-existing tests at Gate 2 as candidates for
  `## Follow-ups`. They aren't applied.
- *Alternative:* allow edits to existing tests when you approve them at Gate 2. That's more
  useful, but the baseline diff gets noisier.
	- ANSWER: Implement your recommended option

**D4 — layered run commands.** "Run tests one layer at a time, lowest first" works best as a real
command.
- *Recommended:* the skill *proposes* a layer run order at Gate 2. If you accept it, the order is
  recorded as optional extra rows in `## Commands` (`Test (layer: domain)`, …) that the builder
  and checker run lowest-first.
- *Alternative:* report it only and change no commands, which keeps `## Commands` at three rows.
	- ANSWER: Implement your recommended option

**D5 — namespace.** The `story-` prefix is used for workflow mechanics. These three are testing
techniques that are usable outside a case, so they **keep the names you gave them**, without the
prefix (as recommended). Say if you'd rather they sit in the `story-` namespace.
	- ANSWER: yes, keep the names I have given the, subject to the D1 modification. Do no add the `story-` prefix

## Concerns, said once

- **Gate 2 gets heavier.** It used to show the tests and the red output. Now it also shows a path
  inventory, a layer map, and a task list. Mitigation: each skill's gate output gets a hard cap
  of about 10 lines, the same pattern as the artifact budgets, and the tests stay the main thing
  presented.
- **Path enumeration can grow without limit.** "As many as makes sense" needs a stopping rule.
  The *choose* step's coverage rule is that rule, and if it turns out too loose in practice, it's
  the thing to tighten.
- **Overlap with `ARCHITECTURE.md`.** Its `## Components` already has a layer-ish view and its
  `## State` already has a state view. The new skills **read** them as inputs and never redraw
  them, which keeps the "one set, always current" rule intact.

## Order of work (after approval)

1. Settle D1–D5, then check the skill-name rule against the docs.
2. Write the three skills (standalone body, then the `When loaded from story-tdd` section).
3. Edit `story-tdd`, then `story-3-tdd-red`, `story-4-tdd-green`, and `story-builder`.
4. Sync the mirrors: explain-workflow, flowchart, README, and `plan_initial.md` §6 (plus
   `STORY-ARTIFACTS.md` if D2 or D4 calls for it).
5. Run `./install.sh` and `./install.sh --check`, and report the output.
6. Move this file to `workflow-modification-plans/2026-10-31_implement-test-philosophy.md` and
   fill in "What was decided" and "What changed".
7. Make one local commit, `minor(sde-agentic-workflow): …`, per the commit rules. It will not
   include the two symlinked notes, and nothing is pushed.

## What was decided

| Decision | Outcome |
|---|---|
| D1 — names | Double hyphens: `test-suite-analysis--test-tasks`, `test-suite-analysis--diagnostic-capability` |
| D2 — path inventory | Presented at Gate 2, open to change there. Once approved, it is recorded **in the body of the baseline commit message**, with no case-home artifact |
| D3 — task-library scope | Extract from this pass's new tests only. Reuse existing helpers. Refactors of pre-existing tests are reported as candidates for `## Follow-ups` |
| D4 — layered run commands | Proposed at Gate 2. If accepted, recorded as optional `Test (layer: …)` rows in `## Commands`. The builder and checker run them lowest layer first |
| D5 — namespace | No `story-` prefix |

**Spec check on D1, done after the gate.** The open Agent Skills spec (agentskills.io) says a
`name` "must not contain consecutive hyphens (`--`)", and underscores aren't allowed either. Claude
Code's refused-character list includes neither, so a `--` name loads in Claude Code. It wouldn't
pass the spec's `skills-ref validate`, though. The user's choice was kept. After `install.sh`, all three skills showed up in Claude Code's
skill listing, which confirms they load. If the skills ever need
to be portable to other Agent Skills hosts, renaming to single hyphens means changing the
directory, the `name:` field, and the references listed below.

## What changed

**Created**: the skills `functional-test-design`, `test-suite-analysis--test-tasks`, and
`test-suite-analysis--diagnostic-capability`. Each has a standalone procedure plus a
`## When loaded from story-tdd` section.

**Edited**
- `story-tdd`: a new five-stage `## The red pass, in order` section (design, write, diagnose,
  factor, run). "At least one *path* test per AC". The choose rule draws the coverage line.
  Follow-up scoping. Gate 2 shows the inventory, layer map, and task list (each capped at about 10
  lines) and the user can change any of them. Accepted layer rows go into `## Commands`.
  Helpers are staged into the baseline. The path inventory goes in the commit body. New
  never-rule: pre-existing tests are not edited.
- `story-3-tdd-red`: names the stage skills, the stages, and the new Gate 2 items, and states
  what gets staged. The rules stay in the skill.
- `story-4-tdd-green`: the audit's test paths explicitly include task-library helpers, fixtures,
  and test config.
- `story-builder`: task-library helpers count as test code. Layer rows run lowest-first before the
  whole suite.
- `story-checker`: *(not in the plan's file list, but forced by D4)* chains the layer rows
  lowest-first in its background verification run.
- `story-context-home`: the commit-format section says how the baseline commit body carries the
  path inventory.
- `templates/STORY-ARTIFACTS.md`: optional `Test (layer: …)` rows in `## Commands` (D4).

**Mirrors**: `story-explain-workflow` (the step-3 entry and the supporting cast),
`workflow_flowchart.md` (nodes `TA`, `G2`, `TC`, `FTA`, `FTC`), `README.md` (the step-3 row and
the skills tree), and `plan_initial.md` §6 (the three skill directories, with the date bumped).

**Unchanged**: `story-followup-3-tdd-red` (a thin wrapper) and `install.sh` (its glob picks up
the new skills). `install.sh` was re-run: 3 new links, then `--check` reported 30 linked, 0
missing, 0 blocked, 0 stale.
