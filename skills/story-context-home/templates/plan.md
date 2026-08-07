# <YYYY-MM-DD_descriptive-short-name>

## Workflow status

planned · next `/story-tdd-red` · updated <YYYY-MM-DD>

## Context

<Two to five lines: what the user wants, why now, and what in the current code makes this
non-trivial. Prose, not bullets. No code.>

**Repo:** `<absolute path to the project repo>`
**Branch:** `<the working branch the user created>`

## Scope

**Building:**
- <observable change 1>
- <observable change 2>

**Not building:**
- <the adjacent thing this case deliberately leaves alone, and why in half a line>

## Phases

Each phase is independently validatable. 2–4 of them.

1. **<Phase name>** — <what changes>. *Validation:* <what proves it works>.
2. **<Phase name>** — <what changes>. *Validation:* <what proves it works>.

## Acceptance criteria

Observable behaviors, phrased so a test can encode each one directly. These are canonical — the
phases above point at them rather than restating them.

- **AC1** — <given X, when Y, then Z>
- **AC2** — <given X, when Y, then Z>
- **AC3** — <given X, when Y, then Z>

## Commands

Established during intake, run verbatim by `/story-tdd-red` and the `story-builder` agent.

| Purpose | Command | Run from |
|---|---|---|
| Test (whole suite) | `<command>` | `<path>` |
| Test (this case's files) | `<command>` | `<path>` |
| Build | `<command>` | `<path>` |

## Open Questions

Answered inline by the user. Never edited by any command — only appended to. Exempt from the
line budget.

- **Q:** <question raised at a gate>
  **A:**
