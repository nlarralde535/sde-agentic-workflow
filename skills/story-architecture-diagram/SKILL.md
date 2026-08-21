---
name: story-architecture-diagram
description: Write and refresh a story case's ARCHITECTURE.md — the section order (concepts, plain-English model, components, sequence, optional state, why-not, read-the-code-in-this-order), the two governing rules (one set always current, one altitude no tiers), and the PLANNED / REFRESH-in-place / FLOWS modes. Load it in PLANNED mode from the story-planner agent, in REFRESH mode from /story-5-check or the story-checker agent, and in FLOWS mode for /story-model.
---

# Story architecture diagrams

`ARCHITECTURE.md` is the **teaching surface** of a case. Its job is to let a reader who knows the
language but not this codebase understand the change's shape before reading a line of the diff,
and to make a wrong design visible while it is still cheap to change. A misplaced arrow is
visible in a way a wrong line of code is not.

Load `story-context-home` alongside this skill — it owns the case home path and the ≤ 3 diagram
budget.

## The two rules

**1. One set, always current.** There is exactly one `ARCHITECTURE.md` per case, and
`/story-5-check` **edits it in place**. Never append an "as-built" copy, never add a second set of
diagrams below the first, never leave the planned version "for comparison". Two renderings of one
design guarantee that one of them is wrong with no way to tell which. What changed and why lives
in `PLAN.md`'s `## Divergence Log`; git history keeps the earlier revision.

**2. One altitude, no tiers.** No junior/mid/senior versions, no "detailed" companion diagram.
The gap a less experienced reader has is **vocabulary and causality**, not granularity — so the
answer is `## Concepts in this story`, the plain-English model, and `## Why not the obvious thing`,
not more boxes. Zoom-ins are drawn **live in the conversation**, on demand, and are **never
written to a file**. *Tier the conversation, not the artifacts.*

A follow-up case draws **no diagrams of its own**. It reads and, at its check, amends the
**parent's** `ARCHITECTURE.md` — the parent stays the one always-current map of the whole effort.

## Section order

Fixed, and it is a reading order — each section makes the next one legible.

1. **`# <case-id> — architecture`** + a `**Status:**` line (`PLANNED` or `AS BUILT`) and the date.
2. **`## Concepts in this story`** — every term the diagrams use that a newcomer to this codebase
   would not know, one line each. This is the section that replaces a "simpler" second diagram.
3. **`## The model in plain English`** — 3–6 sentences naming the pieces and what causes what.
   Written before the diagrams, because if you cannot write this the diagrams will not save you.
4. **`## Components`** — one Mermaid `flowchart`: what talks to what, across which boundary.
5. **`## Sequence`** — one Mermaid `sequenceDiagram`: the happy path end to end, plus the one
   failure mode that matters. This is the diagram the user narrates back at the shape hand-over.
6. **`## State`** — *optional*. Only if something in the change genuinely has states and
   transitions. Delete the section entirely if it does not earn its place. **Three diagrams is
   the hard cap**, so this one costs you the ability to add any other.
7. **`## Why not the obvious thing`** — the approach a competent reader would expect, and the
   specific reason this case does something else. At most two rejected alternatives, one short
   paragraph each. If nothing obvious was rejected, say that in one line — never invent a
   strawman to fill the section.
8. **`## Read the code in this order`** — entry points in reading order, each with a phrase on
   what to look for.

## Mermaid that renders

- Fence every diagram with ```` ```mermaid ````.
- **Quote every node label**: `A["Queue selector"]`, not `A[Queue selector]`. Parentheses,
  slashes, and dots in an unquoted label break the parse.
- Keep node IDs short and alphanumeric; put the prose in the label.
- Prefer `flowchart TD` for components and `sequenceDiagram` for flows. Do not mix paradigms in
  one fence.
- No styling, no `classDef`, no colors. The diagram carries structure; the prose carries emphasis.
- Re-read what you wrote and check the syntax before saving — a diagram that does not render is
  worse than no diagram, because it looks like it was reviewed.

## PLANNED mode — the `story-planner` agent, `model` pass

Inputs: `RESEARCH.md`, and `PLAN.md`'s `## Context`, `## Scope`, `## Phases`,
`## Acceptance criteria`, plus whatever you read of the target repo while planning.

Write the whole file from `story-context-home/templates/STORY-ARTIFACTS.md` with
`**Status:** PLANNED`. In this mode `## Read the code in this order` names **files and what to
look for** — there are no line numbers yet, because the code does not exist. Say what the reader
should expect to find, not what is there.

The bar for this mode: **the diagrams must be answerable without reading the plan prose.** If
understanding the sequence diagram requires having read `## Phases`, the diagram is
underspecified — fix the diagram, do not cross-reference the plan.

## REFRESH mode — `/story-5-check`, the `story-checker` agent

Inputs: `git diff` on the working branch and the changed files themselves. Re-derive the shape
**from the code**, not from the plan and not from the builder's account of what it did. That
re-derivation is the entire value of the step; reading the plan first will bias you into seeing
what was intended rather than what shipped.

Then:

1. **Edit the existing file in place.** Change the arrows, boxes, and prose that are now wrong.
   Leave correct sections alone — a refresh is not a rewrite, and a rewritten section that says
   the same thing differently hides the real change in the diff.
2. Flip `**Status:**` to `AS BUILT` and update the date.
3. Top up `## Concepts in this story` and `## The model in plain English` with any term the built
   code introduced that the planned version did not name.
4. **Swap real `file:line` pointers into `## Read the code in this order`** — verified against
   the actual files, in reading order. This is the one place in a case home where line numbers
   belong.
5. Revisit `## Why not the obvious thing`: if the build rejected an approach the plan had not
   considered, that belongs here, and it is also a divergence.

**Every edit you make in this mode is a divergence** and must appear in `PLAN.md`'s
`## Divergence Log` with its reason. A silently redrawn arrow is the specific failure this step
exists to prevent — if you changed the picture and did not log why, you have hidden exactly the
information the gate is for.

On a follow-up, all of this happens in the **parent's** `ARCHITECTURE.md`, and the divergence
entries go in the **follow-up's** `PLAN.md`.

## FLOWS mode — `/story-model`

Inputs: `MANUAL_TESTING.md`, plus `ARCHITECTURE.md` for vocabulary.

Draw the by-hand procedures as **user-flow sequence diagrams** — what the person does, what the
system does back — into `MODEL.md`. This is a **learning aid, not a contract**: it is transient,
the wrap deletes it, and nothing downstream reads it. The ≤ 3 diagram cap does not apply, but the
same rendering rules do.

`MODEL.md` never redraws the architecture at a second altitude. If a request for it is really a
request to understand the components better, answer that **in the conversation** instead.

## What this skill never does

- Never writes diagrams anywhere but the case home's `ARCHITECTURE.md` (or `MODEL.md` in FLOWS
  mode).
- Never writes a second, "as-built", "v2", or "detailed" architecture file.
- Never draws a per-follow-up diagram — the parent's file is the one map.
- Never puts code snippets in the file — `file:line` pointers only, and only in REFRESH mode.
- Never exceeds three diagrams in `ARCHITECTURE.md`.
