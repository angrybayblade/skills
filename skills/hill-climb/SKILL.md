---
name: hill-climb
description: Iteratively optimize toward a measurable objective with an approach, implement, measure, regression-test loop. Each round is benchmarked against the current best, changes that don't help are reverted, and when progress stalls it searches widely across approaches to escape local optima. Use when the user invokes /hill-climb with an objective, or asks to optimize, tune, minimize or maximize a metric (latency, throughput, bundle size, memory, cost, accuracy, test pass rate, score).
---

# Hill Climb

Given an objective, search for the best solution one measured step at a time. **Keep only changes that measurably improve the objective without breaking anything else.**

```
objective
  ▶ approach ◀─────────────────────────────────────────────┐
  ▶ implementation ◀───────────────┐                       │
  ▶ benchmark / test / audit       │                       │
      no improvement? ── revert ── new approach            │
  ▶ regression tests (surfaces that overlap the change)    │
      broken? ── fix, or revert ── new approach            │
  ▶ accept as new best ── next step ───────────────────────┘
```

## 0. Set up (before the first climb)

**Make the objective measurable.** Pin these down and confirm them with the user. If any is missing, propose a value and ask:

| Field | Example |
|---|---|
| **Metric** | p95 latency of `GET /search` |
| **Direction** | minimize |
| **Measure command** | `make bench-search` (or a script you write and the user approves) |
| **Noise threshold** | improvement must beat run-to-run variance (e.g. > 3% over the median of 5 runs) |
| **Target / stop** | ≤ 120 ms, or 15 iterations, or 3 rounds in a row with no gain after wider jumps |
| **Guardrails** | things that must not get worse: correctness tests, memory ≤ X, public API unchanged |
| **Scope** | files and systems that may change, and ones that are off-limits |

Then:
1. **Understand the ground.** Read the code under optimization, profile it if you can, and learn the existing tooling and patterns. Reuse existing building blocks (as in `/scope`).
2. **Identify the regression surface.** Find tests and consumers that overlap the code you'll touch: unit and integration tests, downstream callers (use find-references or Lemma `check`), and related benchmarks.
3. **Take a baseline.** Run the measure command several times and record the median and spread. Run the regression suite and record which tests already fail, so you don't blame yourself for them later.
4. **Isolate the work.** Use a dedicated local branch (`hill-climb/<slug>`). Commit each accepted step there and **never push**. Outside git, keep a patch per accepted step.

## 1. Approach

- Keep a **backlog of candidate approaches**, generated widely: profiler hotspots, algorithmic changes, data structures, caching, batching, concurrency, I/O, config and flags, dependency features you're not using yet, removing work entirely.
- Rank them by **expected gain ÷ cost × confidence**. Pick the top one.
- Write a **hypothesis** before touching code: "Memoizing `parseQuery` cuts p95 by ~20% because the profile shows 30% of time in it."

## 2. Implementation

- Make **one idea per iteration**, the smallest change that tests the hypothesis, so the result can be attributed to it.
- Follow the codebase's conventions and reuse what exists. No one-off helpers.

## 3. Benchmark, test, audit

- Use the **same command, inputs and conditions** as the baseline. Run it multiple times and compare medians against the **current best** (not the original baseline).
- **No improvement** (within the noise threshold, or worse): revert, log it with the reason, then pick a **new approach** and go back to implementation.
- **Improvement**: continue to regression testing.

## 4. Regression testing

- Run the regression surface from setup plus every guardrail metric.
- If anything newly broke, fix it inside the same idea or revert it. **Never accept a step that breaks an overlapping surface.**

## 5. Accept and go to the next step

- Commit locally: `hill-climb: <approach> (<metric> <old> → <new>)`.
- This becomes the new **current best**. Re-profile, because hotspots move. Update the backlog and go back to **Approach**.

## Escaping local optima (search widely, not just upward)

Small tweaks plateau. When **2–3 approaches in a row fail**:
1. **Jump bigger:** try a structural or algorithmic change instead of a parameter tweak.
2. **Combine:** stack individually small winners, or re-try reverted ideas that might work on top of the new best.
3. **Re-profile from scratch.** The bottleneck may have moved somewhere you haven't looked.
4. **Question the framing:** is there a way to avoid the work entirely, or change the interface or contract? Ask the user before anything outside scope.

Stop only when a stop condition is met **or** the backlog is genuinely exhausted after widening the search. Say which one it was.

## Experiment ledger

Keep a running ledger and show it at every accepted step and at the end. For long runs, also save it to a file in the scratchpad directory so it survives context compaction.

```
Best: 142 ms (baseline 210 ms, −32%)   Target: ≤ 120 ms   Iter 7/15

| #  | Approach              | Hypothesis              | Result  | Δ vs best | Regress | Verdict     |
|----|-----------------------|-------------------------|---------|-----------|---------|-------------|
| 1  | memoize parseQuery    | 30% time in parse       | 168 ms  | −20%      | ✅       | ✅ kept      |
| 2  | batch DB lookups      | N+1 on facets           | 151 ms  | −10%      | ✅       | ✅ kept      |
| 3  | swap JSON lib         | serialization 8%        | 150 ms  | −0.7%     | n/a     | ↩ noise     |
| 4  | parallel shard fetch  | shards fetched serially | 139 ms  | −8%       | ❌ 2 tests | ↩ reverted |
```

## Integrity rules (never break these)

- **Don't game the metric.** Don't change the benchmark, its inputs, tests or measurement to look better. Don't special-case benchmark inputs, disable checks, or skip or loosen tests.
- If the harness itself must change, **ask first, then re-baseline**. Results from before and after aren't comparable.
- Report noise honestly. An improvement smaller than the noise threshold counts as no improvement.
- Stay local. Don't deploy, push, or touch shared or production environments.

## Final report

1. **Result:** baseline → best, and whether the target was met.
2. **Stop reason:** target met, budget spent, plateau, or backlog exhausted.
3. **Ledger:** full table.
4. **Kept changes:** a list of commits on `hill-climb/<slug>`, each with `file:line` and its contribution.
5. **Left on the table:** untried or promising ideas, and ideas needing out-of-scope or risky changes (for the user to decide).
