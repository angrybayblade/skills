---
name: zo
description: Zoom out by moving the current problem or topic exactly one level of abstraction UP (for example code to module, module to component, component to system, system to ecosystem, ecosystem to purpose) and show what becomes visible from there, such as neighbours, upstream and downstream, constraints, and whether the problem even matters at that level. Use when the user invokes /zo, or asks to zoom out, step back, or see the bigger picture. Repeat /zo to keep climbing, and use /zi to come back down.
---

# /zo: Zoom Out

Move **one level of abstraction up** from where the conversation is now, then describe the problem as it looks from that level. One call moves one level, and repeated calls keep climbing.

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

1. **Find the current level.** Use the level the conversation is working at (for example, a specific function means L1). If `/zo <topic>` names a topic, start from that topic's natural level. If it's unclear, pick the most likely level and say so.
2. **Move up exactly one level.** Never skip levels. At L6, say you're at the top and offer a sideways view (a neighbouring goal or product) instead.
3. **Ground it in evidence.** Read what exists at the new level, such as callers, configs, infrastructure, service maps, docs, tickets and `git log`. Use find-references or Lemma for call graphs. Mark each fact ✅ verified (with a source) or ❓ unknown.
4. **Show the view** using the format below.

## Output

```
Ladder:  L6 Purpose › L5 Ecosystem › [L4 System] › L3 Component › L2 Module › L1 Code › L0 Runtime
Moved:   L3 Component (search-api) → L4 System
```

1. **The view at this level:** a diagram of the elements and how they connect, with the focus marked `← here`.
   ```
   [web] ──▶ [gateway] ──▶ [search-api ← here] ──▶ [postgres]
                                  │
                                  └──▶ [indexer] ◀── [queue] ◀── [ingest]
   ```
2. **Newly visible from here** (3–6 bullets): neighbours, upstream causes, downstream impact, shared constraints (SLAs, quotas, ownership), and other places with the same pattern.
3. **Does the problem change?** Is it bigger, smaller, or not really a problem at this level? Is the cause actually up here?
4. **Options that exist only at this level** (if any), such as changing a contract, adding caching at the edge, re-routing, or a process change.
5. **Re-check the plan below:** does the current lower-level approach still make sense from here? Answer yes, no, or adjust, with the reason.

End with one line:
`Now at: L4 System · /zo for L5 Ecosystem · /zi to go back to L3`

## Rules

- **Remember the current level** for the rest of the conversation so later `/zo` and `/zi` calls stay consistent.
- Keep it to about one screen, using diagrams and bullets rather than prose.
- Stay at this level's altitude. Don't drop back into line-level detail.
- Seeing more isn't a reason to build more. Point out options at this level, but don't push them unless the evidence supports it.
