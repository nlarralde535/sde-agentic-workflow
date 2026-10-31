---
name: test-suite-analysis--test-tasks
description: Analyze a suite of tests for common test tasks — conceptually distinct steps of a user's procedure that recur across tests — and factor them out into a reusable task library, distinguishing tasks from setup/teardown fixtures and never hiding assertions. Use when a test suite is being written or reviewed and repeated procedures are making it harder to maintain; loaded by story-tdd as the FACTOR stage of /story-3-tdd-red, and usable on its own outside a story case.
---

# Test suite analysis — test tasks

From *Lessons Learned in Software Testing*, ch. 5, on task libraries: **analyze use cases into
their constituent tasks. Each task should be conceptually distinct. Library functions for those
tasks can then be used across your test scripts.**

A task library is an abstraction over test *procedure*. It builds on the pattern that fixtures
(Playwright fixtures, pytest fixtures, `beforeEach` hooks) establish for test *state*:

| | Fixture | Task |
|---|---|---|
| Holds | setup and teardown of state | one step of a user's procedure |
| Named for | the state it provides (`signedInPage`, `seededQueue`) | the user's intent (`logInAs`, `addEntryToQueue`) |
| Runs | around the test, by the framework | inside the test body, called explicitly |

Factoring common procedures into tasks makes a suite cheaper to maintain: when a procedure
changes, one task changes instead of every test that repeats it.

## The procedure

1. **Inventory what already exists first.** Fixtures, page objects, factories, builders, existing
   task helpers, and where the project keeps them. **Reuse before you create** — a second helper
   that does what an existing one does is a maintenance cost, not a saving.
2. **Break each test into its tasks.** Read each test body as a procedure and name its steps in
   the user's words: *open the queue, add an entry, mark it read, select the next one*. A step is
   conceptually distinct when a reader would describe it in one phrase without saying "and".
3. **Find the repeats.** A candidate task is a step, or a run of steps a reader would name in one
   phrase, that appears in **two or more** tests.
4. **Decide what each repeat is.** Establishing or tearing down state → a **fixture**, using the
   framework's own mechanism. A step of the user's procedure → a **task**: a plain function named
   for the intent.
5. **Extract it**, into the project's existing helper location and style — or, if the project has
   none, propose one at the test root and say so. Each task:
   - does **one** thing, named for the intent, not the mechanics (`addEntryToQueue`, not
     `clickPlusThenType`),
   - takes what it needs as **parameters** — no hidden module state, no reliance on test order,
   - **does not assert the outcome under test.** Assertions stay in the test body, where a reader
     sees what the test proves. A task may guard its own preconditions (fail loudly if the page it
     expects is not there), and that failure message must say which task failed and why,
   - is **commented for a junior reader**: what the task represents and what it leaves behind.
6. **Do not over-factor.**
   - A procedure used **once** stays inline.
   - A task that only wraps a **single framework call** is not a task.
   - Tests should still read top to bottom as a procedure. If a reader has to open three helpers
     to learn what a test does, the factoring has gone too far.

## The output

A short list, capped at **about 10 lines** when presented to a person:

```
Reused:     signedInPage (existing fixture)
Extracted:  addEntryToQueue(entry)   — 4 tests — test/support/queueTasks
Extracted:  markEntryRead(entry)     — 3 tests — test/support/queueTasks
Candidates (not applied): 6 existing tests repeat the add-entry steps inline
```

## When loaded from story-tdd

This is the **FACTOR** stage of `/story-3-tdd-red`, run after DIAGNOSE has settled the final set of
tests and before the red run.

- **Scope: this pass's new tests only.** Extract from tests written in this pass; reuse existing
  helpers freely. **Never edit a pre-existing test** to use a new task — the baseline commit is
  this case's contract, and churning tests that already pass blurs it. Report such refactors at
  Gate 2 as **candidates**; if the user wants them, they become an entry under `PLAN.md`'s
  `## Follow-ups`.
- **Task and fixture files are test code.** Any task-library or fixture file created or changed in
  this pass is **staged into the baseline commit** with the tests, and the green step's audit
  diffs it like any test file. Otherwise a builder could edit a helper and quietly change what a
  test means.
- The extraction list is presented at Gate 2 under its 10-line cap.
