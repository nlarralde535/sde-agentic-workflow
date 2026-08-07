---
name: story-diagrams
description: Write and refresh a story case's diagrams.md — the section order (plain-English model, component, sequence, optional state, why-not, read-the-code-in-this-order), the two governing rules (one set always current, one altitude no tiers), and the PLANNED vs REFRESH-in-place modes. Load it in PLANNED mode from /story-plan and in REFRESH mode from /story-check or the story-divergence agent.
---

# Story diagrams

`diagrams.md` is the **teaching surface** of a case. Its job is to let a reader who knows the
language but not this codebase understand the change's shape before reading a line of the diff,
and to make a wrong design visible while it is still cheap to change. A misplaced arrow is
visible in a way a wrong line of code is not.

Load `story-context-home` alongside this skill — it owns the case home path and the ≤ 3 diagram
budget.

## The two rules

**1. One set, always current.** There is exactly one `diagrams.md` per case, and `/story-check`
**edits it in place**. Never append an "as-built" copy, never add a second set of diagrams below
the first, never leave the planned version in place "for comparison". Two renderings of one
design guarantee that one of them is wrong with no way to tell which. What changed and why lives
in `plan.md`'s `## Divergence Log`; git history keeps the earlier revision.

**2. One altitude, no tiers.** No junior/mid/senior versions, no "detailed" companion diagram.
The gap a less experienced reader has is **vocabulary and causality**, not granularity — so the
answer is the plain-English model and the `## Why not the obvious thing` section, not more boxes.
Zoom-ins are drawn **live in the conversation**, on demand, and are **never written to a file**.
*Tier the conversation, not the artifacts.*

## Section order

Fixed, and it is a reading order — each section makes the next one legible.

1. **`# <case-id> — diagrams`** + a `**Status:**` line (`PLANNED` or `AS BUILT`) and the date.
2. **`## The model in plain English`** — 3–6 sentences naming the pieces and what causes what.
   Every term the diagrams use that a newcomer would not know is defined here. Written first,
   because if you cannot write this the diagrams will not save you.
3. **`## Components`** — one Mermaid `flowchart`: what talks to what, across which boundary.
4. **`## Sequence`** — one Mermaid `sequenceDiagram`: the happy path end to end, plus the one
   failure mode that matters. This is the diagram the user narrates back at Gate 1.
5. **`## State`** — *optional*. Only if something in the change genuinely has states and
   transitions. Delete the section entirely if it does not earn its place. **Three diagrams is
   the hard cap**, so this one costs you the ability to add any other.
6. **`## Why not the obvious thing`** — the approach a competent reader would expect, and the
   specific reason this case does something else. At most two rejected alternatives, one short
   paragraph each. If nothing obvious was rejected, say that in one line — never invent a
   strawman to fill the section.
7. **`## Read the code in this order`** — entry points in reading order, each with a phrase on
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

## PLANNED mode — from `/story-plan`

Inputs: `plan.md`'s `## Context`, `## Scope`, `## Phases`, `## Acceptance criteria`, plus
whatever you read of the target repo during planning.

Write the whole file from `story-context-home/templates/diagrams.md` with `**Status:** PLANNED`.
In this mode `## Read the code in this order` names **files and what to look for** — there are no
line numbers yet, because the code does not exist. Say what the reader should expect to find,
not what is there.

The bar for this mode: **the diagrams must be answerable without reading the plan prose.** If
understanding the sequence diagram requires having read `## Phases`, the diagram is underspecified
— fix the diagram, do not cross-reference the plan.

## REFRESH mode — from `/story-check`

Inputs: `git diff` on the working branch and the changed files themselves. Re-derive the shape
**from the code**, not from the plan and not from the builder's account of what it did. That
re-derivation is the entire value of the step; reading the plan first will bias you into seeing
what was intended rather than what shipped.

Then:

1. **Edit the existing file in place.** Change the arrows, boxes, and prose that are now wrong.
   Leave correct sections alone — a refresh is not a rewrite, and a rewritten section that says
   the same thing differently hides the real change in the diff.
2. Flip `**Status:**` to `AS BUILT` and update the date.
3. Top up `## The model in plain English` with any term the built code introduced that the
   planned version did not name.
4. **Swap real `file:line` pointers into `## Read the code in this order`** — verified against
   the actual files, in reading order. This is the one place in the case home where line numbers
   belong.
5. Revisit `## Why not the obvious thing`: if the build rejected an approach the plan had not
   considered, that belongs here, and it is also a divergence.

**Every edit you make in this mode is a divergence** and must appear in `plan.md`'s
`## Divergence Log` with its reason. A silently redrawn arrow is the specific failure this step
exists to prevent — if you changed the picture and did not log why, you have hidden exactly the
information the gate is for.

## What this skill never does

- Never writes diagrams anywhere but the case home's `diagrams.md`.
- Never writes a second, "as-built", "v2", or "detailed" diagram file.
- Never puts code snippets in the file — `file:line` pointers only, and only in REFRESH mode.
- Never exceeds three diagrams.
