---
name: test-suite-analysis--diagnostic-capability
description: Analyze a suite of tests for diagnostic capability — whether a failing test tells you where the fault is, what was predicted, and what the failure state is. Derives the code's implementation layers by static analysis, maps each test to its layer, finds layers with no tests and failures that do not localize, fixes or recommends fixes, and proposes a lowest-layer-first run order ("zooming out from the smoke test"). Loaded by story-tdd as the DIAGNOSE stage of /story-3-tdd-red, and usable on its own outside a story case.
---

# Test suite analysis — diagnostic capability

**One purpose a test must serve to be useful is helping diagnose a problem.** When a test fails,
the failure should tell you something meaningful about the software under test:

- **where** did the failure occur?
- **what was predicted** before the failure?
- **what is the failure state?**

The first matters most. A good test makes it easy to **localize** the problem, or at least to
narrow the problem domain. The counter-example is an OBD-II trouble code: the check fails, a code
is produced, and the root cause is still somewhere in the car.

## Zooming out from the smoke test

The electronic smoke test answers one question: *can power be supplied to the board?* When it
fails, smoke pours out of a part of the board — so even the failure localizes: start
troubleshooting where the smoke is. When it passes, all you can say is that power was applied.
Like a movement screen, it signals the presence or absence of a minimum capability, nothing more.

To learn more than that, a tester has to:

1. **understand the implementation layers** of the software under test,
2. **build tests specific to each layer**,
3. **run them one layer at a time, starting from the lowest.**

Run that way, the first failing layer is where to look — every layer below it is known to work.

## Layers are static structure, not runtime state

An **implementation layer** is a property of the code *as written* — inert, before compile time:
modules, packages, and the direction their dependencies point. It is **not** a runtime state;
states (empty, logged in, mid-transaction) belong to the `functional-test-design` skill. Any one
test sits on both axes; this skill is about the layer axis and the quality of the failure.

## The procedure

### 1. Derive the layers

Read the code, not a template. Use module and package boundaries and the dependency direction: a
lower layer is one the others depend on and that depends on none of them. A common shape is pure
domain logic → data access and adapters → service or API → UI and end-to-end, but **derive the
project's own layers and name them in its own terms**. Two to five layers is typical; if you find
more, you are probably listing modules, not layers.

### 2. Map each test to a layer

For each test: the **lowest layer whose failure it can detect**, and every layer it crosses. A
unit test of a pure function sits on one layer. An end-to-end test crosses all of them and
localizes nothing on its own.

### 3. Score each test's failure

Imagine it failing, and ask the three questions:

| Question | Diagnostic | Not diagnostic |
|---|---|---|
| **Where** | fails only when one layer or unit is wrong | fails for a fault in any of several layers |
| **Predicted** | the assertion or its message states the expected value or condition | `assert ok` |
| **Failure state** | the output shows the actual value or state | `expected true, got false` |

### 4. Find the gaps

- **An untested layer.** A fault there only surfaces higher up, unlocalized — the OBD-II problem.
- **A multi-layer test with no lower-layer counterpart.** When it fails, nothing narrows it down.
- **A test that asserts behavior of several layers at once.** It fails ambiguously.
- **A bare assertion** (`expect(x).toBeTruthy()`, `assert result`). It loses *predicted* and
  *failure state* both.

### 5. Fix, or recommend

The fixes, cheapest first: use a more specific matcher (`toEqual(expected)` over `toBeTruthy()`);
add an assertion message that names the expectation; split a test that asserts several layers;
add a lower-layer test beneath a multi-layer one. Apply the fixes that touch only the tests in
scope; **report the rest** as recommendations.

### 6. Propose a layer run order

Express the lowest-first order in the project's own test-runner terms — directories, tags, named
projects, markers — one command per layer, lowest first. Running them in that order and stopping at
the first failure is how the suite zooms out from the smoke test. If the project's layout cannot
select a layer with a command, say so; that is itself a finding.

## The output — a layer map

Capped at **about 10 lines** when presented to a person:

```
L1 domain (queue rules)      6 tests        — runs: npm test -- test/domain
L2 storage adapter           0 tests  GAP   — a bad read surfaces only at L3
L3 queue API                 3 tests        — runs: npm test -- test/api
Fixed:       2 bare assertions → toEqual; split "selects and persists" into L1 + L3
Recommended: add an L2 test for the read-back of a marked entry
```

## When loaded from story-tdd

This is the **DIAGNOSE** stage of `/story-3-tdd-red`, run after WRITE and before FACTOR — it may
split tests or add lower-layer ones, and factoring should run once, on the final set.

- **Inputs:** this pass's tests, the code they exercise, and `ARCHITECTURE.md`'s `## Components`,
  which already names the boundaries the change crosses. **Read it; never redraw it.**
- **Scope of fixes:** apply fixes to **this pass's tests** only — adding a lower-layer test for this
  case's behavior counts. Pre-existing tests are reported, not edited.
- **Every new test still names its AC and its path.** A lower-layer test added here encodes the
  same criterion at a lower layer.
- **The layer run order is proposed at Gate 2.** If the user accepts it, it is amended into
  `PLAN.md`'s `## Commands` as optional `Test (layer: <name>)` rows, **lowest layer first**, each
  with its run-from path. The builder and the checker then run those rows lowest-first, before the
  whole-suite command, and report the first failing layer. If the user declines, `## Commands`
  stays as it was.
- The layer map is presented at Gate 2 under its 10-line cap.
