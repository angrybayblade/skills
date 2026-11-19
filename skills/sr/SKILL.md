---
name: sr
description: Give a short situation report on the current task, meaning where it stands right now, in a glanceable fixed format of about 15 lines or fewer. Use when the user says "sitrep", "status update", "where are we", "what's the status", "progress?", or invokes /sr. For a fuller visual explanation of a topic, use /bm instead.
---

# /sr: Sitrep

A situation report on the **current task**: where it stands right now. The user has ADHD, so it has to be readable in about 5 seconds. Use the fixed format below and add nothing else.

## Scope

- **Current task** means the task being worked on in this conversation. If the user names a different task, report on that one.
- Report state, not history. Mention past work only when it explains the current state.
- If nothing is in progress, say so in one line and stop.

## Format (exact order, skip any empty line)

Template:

```
**<one-line status>** <✅ on track | ⚠️ at risk | ❌ blocked | 🏁 done>

`[✅ step]──[✅ step]──[⏳ step]──[◻ step]──[◻ step]`

- ⏳ **Now:** <what's happening this moment, ≤ 10 words>
- ❌ **Blocked:** <blocker, ≤ 10 words>
- ➡️ **Next:** <next 1–2 steps>
- 🙋 **You:** <decision or action needed from the user>
```

Write the report as normal markdown, not wrapped in a code block, so the bold text and the list render. Only the progress line goes in code formatting.

Example:

**Auth refactor: 2 tests still failing** ⚠️ at risk

`[✅ plan]──[✅ refactor]──[⏳ tests]──[◻ PR]`

- ⏳ **Now:** fixing the token-refresh test
- ➡️ **Next:** run the full suite, open the PR
- 🙋 **You:** OK to drop the legacy `/v1/login` endpoint?

Details:

- **Progress line:** 3–7 steps, using the labels you'd use when talking about the task. Markers: ✅ done · ⏳ current · ◻ not started · ❌ failed.
- **Blocked** and **You** are left out when there's nothing to report.
- **Optional extra bullets** (at most 3, only when they change the picture): a key number (**4/6** tests passing), a risk (⚠️ migration not reversible), or a pointer (`src/auth.ts:88`).

## Rules

- Keep the whole report at **15 lines or fewer**. No paragraphs, no preamble, no sign-off.
- Lead with numbers and names. Write "**2 files** left", not "a few things remain".
- Report what you actually verified. Unverified items get ❓ and are never presented as done.
- Don't explain. If the user wants depth, they'll ask, or they'll use /bm.
