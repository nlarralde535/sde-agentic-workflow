---
name: story-tdd
description: The red phase of test-driven development for a story case — design the tests by state-and-path coverage (functional-test-design), write path tests that encode the plan's numbered acceptance criteria with every setup step and assertion commented for a junior reader, check their diagnostic capability layer by layer (test-suite-analysis--diagnostic-capability), factor out common test tasks (test-suite-analysis--test-tasks), run them, confirm they fail for the right reason, then commit them with PLAN.md as the build's test baseline, the approved path inventory in the commit body. Scoped to red only; the same pass never writes tests and product code. Load it from /story-3-tdd-red and /story-followup-3-tdd-red.
---

# Story TDD — the red phase

The tests are **the contract the build must satisfy**. They are written before any product code,
approved by the user, and **committed** — that commit is the baseline the green step diffs
against, so any test the builder touches afterward becomes visible and the user's to rule on.
That is what gives the tests force, so they have to be right and the user has to have read them.

This skill covers the **red phase only**. Load `story-context-home` alongside it for the case
home layout, the `## Commands` table, and the commit format.

## The one hard rule

**The same pass never writes tests and product code.** Not "tests first, then code in the same
turn" — the red phase ends with failing tests and control back at the user. A pass that writes
both produces tests shaped around the implementation that happened to appear, which are green and
meaningless. If you find yourself reaching for the product file to "make it importable", stop:
that is the build's job, and the import error *is* the red.

## The red pass, in order

Five stages, in this order. Three of them are run by their own skill — load each one when you
reach its stage and follow its `## When loaded from story-tdd` section.

| # | Stage | Skill | What it produces |
|---|---|---|---|
| 1 | **Design** | `functional-test-design` | the **path inventory** — initial states, terminal states, the chosen paths, each mapped to an AC |
| 2 | **Write** | this skill | one or more **path tests** per AC, commented for a junior reader |
| 3 | **Diagnose** | `test-suite-analysis--diagnostic-capability` | the **layer map**, sharper failures, any lower-layer tests, a proposed layer run order |
| 4 | **Factor** | `test-suite-analysis--test-tasks` | the **task list** — common procedures extracted into task-library functions |
| 5 | **Run** | this skill | the real red output, failing for the right reason |

Why this order: the paths are where the tests come from, so design comes first. Diagnose can split
tests or add lower-layer ones, so factoring waits for the final set. The red run comes last, so it
exercises exactly what will be committed — extracted helpers included.

The two "where" axes stay apart: **states and paths** describe running code (design);
**implementation layers** describe the code's static structure (diagnose).

## What to test

Read `## Acceptance criteria` in `PLAN.md`. **Each numbered criterion becomes at least one path
test** — a path from the design stage's inventory — and the test names both: a reader should be
able to point at a test and say "that's AC2, from an empty queue to a rejected entry". Name
tests after the behavior (`rejects a queue entry already read today`), never after the
implementation (`test_selectQueue_branch_2`).

**Test intended behavior, not the plan's prose.** A test that asserts the shape of a helper the
plan happened to mention is a test of the plan; a test that asserts the observable outcome
survives the build choosing a different helper.

On a **follow-up**, the tests to write are enumerated in the plan's `## Test changes` list, and
they usually **edit existing test files** rather than add new ones. Work that list; if writing
them turns up something the list missed, add it and say so at the gate. The design stage covers
only the delta — the paths the list adds or changes — and diagnose and factor are scoped to the
tests this pass touched.

### Where to draw the line

Be realistic about coverage rather than exhaustive:

- **Do TDD the logic** — validation, transforms, state machines, reducers, hooks, ordering and
  selection rules, error paths. This is where a wrong assumption is cheap to catch and expensive
  to find later.
- **Leave pure rendering to the manual test.** `MANUAL_TESTING.md` already has a procedure for
  every AC; a test that asserts a div exists costs more to maintain than it catches.
- **One failure mode that matters** gets a test. Not every failure mode.

The design stage's *choose* rule is how this line gets drawn in practice: paths an AC depends on
are kept, paths that add no new transition are dropped, and manual-only paths go to the manual
procedure — each drop with its reason.

If a criterion cannot be tested at this level, say so at the gate and let the user decide whether
to reword the criterion or leave it to the manual procedure — do not quietly skip it.

## How to write them

- **Comment every setup step and every assertion**, addressed to a junior reader who does not
  know this codebase: what this fixture represents, and what this assertion proves. The comments
  are half of why the gate works.
- Follow the project's existing test conventions — framework, file location, naming, fixture
  style. Read a neighbouring test file first. This workflow imposes no test framework of its own.
- **Write tests into the project repo**, never into the case home.
- Keep each test to one behavior. A test asserting four things fails ambiguously.

## Running them

Run the **narrow** command from `PLAN.md`'s `## Commands` — the one that runs just this case's
test files — from the directory it records. Run it verbatim; do not improvise flags.

Then check *how* they failed. A red test is only useful if it is red **for the right reason**:

| Failure | Verdict |
|---|---|
| `not implemented`, module/export not found, function undefined | **Right reason** — the behavior genuinely does not exist yet |
| Assertion mismatch against a partial implementation that already exists | **Wrong reason** — investigate; the behavior may be half-built, and the test may be asserting against an accident |
| Syntax error, bad import path, fixture blow-up, framework misconfiguration | **Wrong reason** — the test is broken, not the code. Fix it and re-run |

Never present a suite as red without having read the actual failure output. Never claim a result
you did not run.

## Amending the plan

Writing the tests is the first time anyone has had to state the behavior precisely, and it
routinely turns something up. When it does, **amend `PLAN.md` in the same pass** — a criterion
that was ambiguous, a phase that has to split, a constraint nobody had written down — and present
the amendment at the gate alongside the tests.

If the amendment changes **scope or shape** rather than wording, that is not an amendment: stop
and send the user back to `/story-2-plan`. Re-planning is cheap here and expensive after the build.

## The gate, then the baseline commit

**Gate:** present, with the tests as the main thing:

- the test files (or their diff), the criterion and path each test encodes, and the **real** red
  output,
- the **path inventory** (design), the **layer map** with the proposed layer run order
  (diagnose), and the **task list** with any candidate refactors of pre-existing tests (factor) —
  **each capped at about 10 lines**,
- any amendment to `PLAN.md`, and anything a criterion could not express as a test.

No product code has been written. Control returns to the user.

The user may ask for **any** of these to change — a path added or dropped, a layer run order
rejected, a task inlined. Change the tests to match, re-run, and present again. If the user
accepts the layer run order, amend it into `PLAN.md`'s `## Commands` as optional
`Test (layer: <name>)` rows, lowest layer first; if they want candidate refactors of pre-existing
tests, add them to `PLAN.md`'s `## Follow-ups`.

**Only after the user approves**, commit — this is the one commit the red step makes:

1. Stage **the test files, any task-library or fixture files this pass created or changed, and
   `PLAN.md`**, nothing else. Helpers are test code: they are part of the contract.
2. Commit per `story-context-home` (type `patch` or `minor`, `Case:` trailer, no push). The body
   carries the **approved path inventory** — the commit is where it is recorded; no case-home file
   holds it.
3. Record the resulting hash in `STATE.json` as `test_baseline_commit_hash`, and set
   `current_step` to `tested-red`.

That hash is the whole mechanism behind the green step's diff audit. A red phase that ends
without it leaves the build unaudited.

## What this skill never does

- Never writes product code, or edits a product file "just enough" to make a test importable.
- Never commits before the user has approved the tests.
- Never writes into the case home beyond `PLAN.md`'s amendment and `## Open Questions`.
- Never edits a pre-existing test to use a new task or to sharpen its failure — those are
  reported as candidates, not applied.
- Never pushes, branches, or merges.
