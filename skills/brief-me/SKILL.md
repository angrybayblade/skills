---
name: brief-me
description: Brief the user on a topic, task, document, codebase area, PR, diff or incident as a visual, hierarchical summary (maps, trees, flowcharts, state charts) rather than linear prose. Use when the user says "brief me", "catch me up", "what's going on with X", "explain this to me", "what did you do", or invokes /brief-me. With no topic, brief them on everything done since their last message.
---

# Brief Me

The user has ADHD. Linear prose doesn't work for them. They need to **see the shape** of a thing first, then zoom in only where they choose. Every briefing is a map with drill-downs, not an essay.

## Pick the topic

- **Topic given** (a task, file, doc, PR, ticket, concept, incident): investigate it first (read the code, docs and diffs) so the briefing is grounded, then brief.
- **No topic**: brief on what *you* did since the user's last message: files changed, commands run, decisions made, what's still open. If this is a fresh session with no prior work, brief on recent activity in the working directory (`git log`, `git status`, recently modified files) and say that's what you did.

## Output structure (always in this order)

### 1. One-liner
A single bold sentence: the "so what". If they read nothing else, this is enough.

### 2. Map (zoom out)
Show where this topic sits in the bigger picture before any detail. Use a tree:

```
platform
├── api            ← (you are here)
│   ├── auth       ⚠️ changed
│   └── routes
└── worker
```

### 3. Visual model
Pick the diagram that matches the **shape of the information**. Use more than one if needed.

| Shape of info              | Diagram            |
|----------------------------|--------------------|
| steps / process / pipeline | flowchart          |
| status / lifecycle         | state chart        |
| structure / ownership      | tree               |
| who-calls-whom / data flow | box-and-arrow      |
| before vs after            | side-by-side       |
| comparing options          | table              |
| timeline / sequence        | timeline / sequence diagram |

Draw diagrams in fenced code blocks with box-drawing characters so they line up in the terminal. Mermaid doesn't render there.

```
 ┌─────────┐   push   ┌──────┐  pass  ┌────────┐
 │  local  │ ───────▶ │  CI  │ ─────▶ │ deploy │
 └─────────┘          └──┬───┘        └────────┘
                         │ fail
                         ▼
                    ┌─────────┐
                    │  fix ❌ │
                    └─────────┘
```

```
 [draft] ──submit──▶ [review] ──approve──▶ [merged]
                        │  ▲
                 changes│  │push
                        ▼  │
                     [needs work]
```

### 4. Drill-down
Nested sections, broad → specific. Each section:
- starts with a **one-line summary** in bold
- then bullets of ≤ ~12 words each
- links code as `path/to/file.ts:42`

Stop at the depth that matters. Offer to go deeper rather than dumping everything.

### 5. Needs you
End with a short explicit list of decisions, actions or blockers for the user, or `Nothing needs you.` Never bury an ask in the middle.

## Formatting rules

- **No paragraph longer than 2 lines.** Turn it into bullets or a diagram.
- **Bold the key word** in each bullet so it can be skimmed.
- Use status markers the same way every time: ✅ done · ⏳ in progress · ⚠️ risk/changed · ❌ broken/blocked · ❓ unknown.
- Use tables for anything with 3+ attributes per item.
- Put numbers and names up front ("**3 files** changed", not "a few files were changed").
- No preamble, no recap of the question, no closing pleasantries.
- If the briefing would run past about a screen and a half, keep sections 1–3 and 5 complete, shrink section 4 to headlines, and offer to expand.
- Say plainly what you **don't know** (❓). Don't smooth over gaps.
