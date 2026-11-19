---
name: zi
argument-hint: "[thing]"
description: Zoom in by moving the current problem or topic exactly one level of abstraction DOWN (for example purpose to ecosystem, system to component, component to module, module to code, code to runtime) and show the internals at that level, such as parts, mechanisms, data and exactly where the problem lives, backed by evidence. Use when the user invokes /zi, or asks to zoom in or drill down a level. Repeat /zi to keep descending, and use /zo to go back up.
---

# /zi: Zoom In

Move **one level of abstraction down** from where the conversation is now, then show what's inside. One call moves one level, and repeated calls keep descending.

This is for understanding only: **no code changes**.

## The ladder

```
L6 Purpose    why it exists: business goal, users, outcomes
L5 Ecosystem  products, teams, vendors, external dependencies
L4 System     services, infrastructure, data stores, queues and how they connect
L3 Component  one service or app: modules, APIs, contracts, config
L2 Module     files, classes and functions in one module, and how they interact
L1 Code       one function: logic, data structures, control flow
L0 Runtime    actual execution: values, queries, network calls, logs, timings
```

For problems that aren't about code, use: **Purpose › Context › Whole › Parts › Details › Instances**.

## Steps

1. **Find the current level.** Use the level the conversation is working at. If `/zi <thing>` names something, zoom into that thing. If it's unclear, pick the most likely level and say so.
2. **Pick what to zoom into.** The current level usually contains several parts. Choose the one most relevant to the problem, say why, and list the others as alternatives.
3. **Move down exactly one level.** Never skip levels. At L0, say you're at the bottom and offer to look at a sibling instead.
4. **Ground it in evidence.** Read the actual code, configs and schemas. At L0, reproduce the problem: run it, add temporary logging only if the user agrees, or read existing logs, traces, metrics or query plans. Mark each fact ✅ verified (`file:line`, output, log) or ❓ unknown.
5. **Show the view** using the format below.

## Output

```
Ladder:  L6 Purpose › L5 Ecosystem › L4 System › L3 Component › [L2 Module] › L1 Code › L0 Runtime
Moved:   L3 Component (search-api) → L2 Module (ranking/)   · also could zoom into: auth/, cache/
```

1. **The view at this level:** a diagram of the parts and how data or control flows between them, with the problem marked `← here`.
   ```
   ranking/
   ├── score.ts      ── computes weights ──┐
   ├── boost.ts      ── applies boosts ────┼──▶ rank()  ← here: boosts applied twice
   └── normalize.ts  ── scales 0..1 ───────┘
   ```
2. **Where exactly the problem lives:** the narrowest part you can pin down, with `file:line` or runtime evidence.
3. **Newly visible from here** (3–6 bullets): mechanisms, hidden assumptions, edge cases, actual values, and anything that contradicts what the higher level assumed.
4. **What this means for the level above:** does it confirm the theory up there, or change it?

End with one line:
`Now at: L2 Module (ranking/) · /zi for L1 Code (rank()) · /zo to go back to L3`

## Rules

- **Remember the current level and focus** for the rest of the conversation so later `/zi` and `/zo` calls stay consistent.
- Keep it to about one screen, using diagrams and bullets rather than prose.
- Stay at this level's detail. Don't jump two levels down into individual lines too early.
- Facts beat guesses. If you can't verify something at this level, mark it ❓ and say what would settle it.
