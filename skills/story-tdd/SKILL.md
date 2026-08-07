---
name: story-tdd
description: The red phase of test-driven development for a story case — turn the plan's acceptance criteria into failing tests that encode intended behavior, comment every setup step and assertion for a junior reader, run them, and confirm they fail for the right reason. Scoped to red only; the same pass never writes tests and product code. Load it from /story-tdd-red.
---

# Story TDD — the red phase

The tests are **the contract the build must satisfy**. They are written before any product code
and are untouchable afterward: the `story-builder` agent may not edit, delete, skip, or relax
them. That is what gives them force — so they have to be right, and the user has to have read
them.

This skill covers the **red phase only**. Load `story-context-home` alongside it for the case
home layout and the `## Commands` table.

## The one hard rule

**The same pass never writes tests and product code.** Not "tests first, then code in the same
turn" — the red phase ends with failing tests and control back at the user. A pass that writes
both produces tests shaped around the implementation that happened to appear, which are green
and meaningless. If you find yourself reaching for the product file to "make it importable",
stop: that is the build's job, and the import error *is* the red.

## What to test

Read `## Acceptance criteria` in `plan.md`. Each criterion becomes at least one test. The mapping
should be obvious enough that a reader can point at a test and name the criterion it encodes —
name tests after the behavior (`rejects a queue entry already read today`), never after the
implementation (`test_selectQueue_branch_2`).

**Test intended behavior, not the plan's prose.** A test that asserts the shape of a helper the
plan happened to mention is a test of the plan; a test that asserts the observable outcome
survives the build choosing a different helper.

### Where to draw the line

Be realistic about coverage rather than exhaustive:

- **Do TDD the logic** — validation, transforms, state machines, reducers, hooks, ordering and
  selection rules, error paths. This is where a wrong assumption is cheap to catch and expensive
  to find later.
- **Leave pure rendering to the manual test** in step 5 of the loop. A test that asserts a div
  exists costs more to maintain than it catches, and the user is going to look at the page anyway.
- **One failure mode that matters** gets a test. Not every failure mode.

If a criterion cannot be tested at this level, say so at the gate and let the user decide whether
to reword the criterion or accept it as manual — do not quietly skip it.

## How to write them

- **Comment every setup step and every assertion**, addressed to a junior reader who does not
  know this codebase: what this fixture represents, and what this assertion proves. The comments
  are half of why the gate works.
- Follow the project's existing test conventions — framework, file location, naming, fixture
  style. Read a neighbouring test file first. This workflow imposes no test framework of its own.
- **Write tests into the project repo**, never into the case home. The case home holds `plan.md`
  and `diagrams.md` and nothing else.
- Keep each test to one behavior. A test asserting four things fails ambiguously.

## Running them

Run the **narrow** command from `plan.md`'s `## Commands` — the one that runs just this case's
test files — from the directory it records. Run it verbatim; do not improvise flags.

Then check *how* they failed. A red test is only useful if it is red **for the right reason**:

| Failure | Verdict |
|---|---|
| `not implemented`, module/export not found, function undefined | **Right reason** — the behavior genuinely does not exist yet |
| Assertion mismatch against a partial implementation that already exists | **Wrong reason** — investigate; the behavior may be half-built, and the test may be asserting against an accident |
| Syntax error, bad import path, fixture blow-up, framework misconfiguration | **Wrong reason** — the test is broken, not the code. Fix it and re-run |

Never present a suite as red without having read the actual failure output. Never claim a result
you did not run.

## What the gate presents

The test files (or their diff), the **real** red output, and the criterion each test encodes. No
product code has been written. Control returns to the user.
