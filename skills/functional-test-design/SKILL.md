---
name: functional-test-design
description: Design a set of functional tests by state-based path coverage — enumerate the initial states the unit under test can start in, the terminal states worth reaching, the paths between them, choose the paths worth testing by an explicit coverage rule, and write one path test per chosen path. Produces a compact path inventory. Use before writing tests for a feature or change; loaded by story-tdd as the DESIGN stage of /story-3-tdd-red, and usable on its own outside a story case.
---

# Functional test design — states and paths

Two coverage techniques underpin this skill (*Lessons Learned in Software Testing*, ch. 3):
**state-based testing** walks a program through a series of state transitions and checks the
result of each one; **path testing** exercises the steps that get the program to a given state.
Put together, they give a system for designing a set of functional tests that covers as many
paths as makes sense:

1. determine all of the **initial states** the program can be in,
2. determine as many **terminal states** as makes sense,
3. elaborate as many **paths** between the initial and terminal states as makes sense,
4. write a **path test** for each of those paths.

This skill makes "as makes sense" concrete enough to stop on.

## States are runtime, not structure

A **state** here is a condition of *running* code at a snapshot in time — empty or populated,
logged in or out, configured or not, mid-transaction or settled. It is **not** an implementation
layer: layers describe the static structure of the code as written, and they belong to the
`test-suite-analysis--diagnostic-capability` skill. Any one test sits on both axes — this skill
decides *which behaviors* to test; that one checks *at what layer* each test runs and *how much its
failure tells you*. Keep the two apart and neither skill duplicates the other.

## The procedure

### 1. Pick the unit

Name the system whose states you are enumerating: the feature, component, or module under change
— never "the application". Without a boundary the enumeration does not terminate. If the change
genuinely spans two units, design each separately.

### 2. Initial states

List every distinct starting condition **that changes the unit's behavior**. Typical axes: the
data present (none, one, many, malformed), the actor (anonymous, ordinary, privileged), the
configuration (default, overridden, missing), and prior history (first run, repeat, interrupted).

**Merge states the code cannot tell apart.** Two starting conditions that take identical paths
everywhere are one state with two examples.

### 3. Terminal states

List the outcomes that matter — the success outcomes **and** the failure outcomes worth having.
Every terminal state must be **observable**: a return value, a persisted record, an emitted event,
a rendered message, an error. A terminal state a test cannot assert is not a terminal state for
this purpose; note it and leave it to manual testing.

### 4. Paths

For each (initial, terminal) pair, either write the path between them as a short sequence of
transitions (`empty → add entry → one-entry queue`) or mark the pair **unreachable**. Include the
happy path and the failure paths. A pair you expected to be reachable but cannot route is a
finding in its own right — say so.

### 5. Choose

The stopping rule, applied in order:

1. **Keep** every path an acceptance criterion or stated requirement depends on.
2. **Keep** a path that exercises a transition no already-kept path exercises.
3. **Drop** a path whose transitions are all covered by kept paths.
4. **Drop** a path only a person can drive (pure rendering, timing a human perceives, hardware) —
   it belongs to the manual procedure, not the suite.

Every dropped path gets a reason of a word or two (`covered by P2`, `manual only`). A path dropped
without a reason is a path nobody decided about.

### 6. Map to requirements

Each kept path cites the requirement(s) it proves. Two findings come out of this step and must be
reported, never absorbed silently:

- **A requirement with no path** — it cannot be tested as stated; it needs rewording, or it is a
  manual-only check.
- **A path no requirement covers** — the design has found behavior nobody specified. That is a
  scope question for whoever owns the requirements.

## The output — a path inventory

Compact, and capped at **about 10 lines** when it is presented to a person:

```
Unit: rereading queue selector
Initial:  I1 empty queue · I2 unread entries · I3 everything read today
Terminal: T1 one entry selected · T2 nothing selected, notice shown · T3 entry rejected
P1  I1 → add entry → select            → T1   AC1   kept
P2  I2 → select oldest unread          → T1   AC2   kept
P3  I3 → select                        → T2   AC3   kept
P4  I2 → re-add entry read today       → T3   AC2   kept
P5  I2 → select twice                  → T1   —     dropped: covered by P2
```

## Writing the path tests

- **One path, one test.** Its name (or its `describe` block) states the path:
  `from an empty queue, adding an entry ends with that entry selected`. The inventory should be
  readable back out of the test file alone.
- **Arrange the initial state, act out the transitions, assert the terminal state.** The setup
  establishes exactly the initial state named in the inventory; the assertion checks exactly the
  terminal state.
- Follow the project's test framework and conventions — this skill imposes none of its own.

## When loaded from story-tdd

This is the **DESIGN** stage of `/story-3-tdd-red`, run before any test is written.

- **Inputs:** `PLAN.md`'s `## Acceptance criteria` are the requirements of step 6.
  `ARCHITECTURE.md`'s `## Sequence` gives the happy path and the failure mode that matters, and its
  optional `## State` diagram, when present, is a ready-made starting point for steps 2–4. **Read
  those diagrams; never redraw them** — `ARCHITECTURE.md` stays the one set.
- **Every AC gets at least one path test**, and the test names both its path and its AC.
- **A path no AC covers** goes through the red step's existing route: a wording gap is amended into
  `PLAN.md`; a scope gap stops the step and sends the user back to `/story-2-plan`.
- **A manual-only path** is reported at Gate 2 under "anything a criterion could not express as a
  test" — `MANUAL_TESTING.md` already carries the procedure.
- On a **follow-up**, design only the delta: the paths that `PLAN.md`'s `## Test changes` list adds
  or changes, against the parent's states.
- **The inventory is presented at Gate 2**, and the user may ask for it to be changed — a path
  added, dropped, or rerouted. Change the tests to match, re-run, and present again. **No file in
  the case home records it**: once approved, the inventory is written into the **body of the
  baseline commit message** (see `story-tdd`), and the path-named tests carry it from then on.
