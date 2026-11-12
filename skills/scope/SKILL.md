---
name: scope
description: Scope a task before building it. Map the existing codebase and infrastructure (design patterns, coding standards, existing functions, tooling, upstream and downstream dependencies), reuse existing building blocks instead of inventing new ones, ask instead of assuming, put clearly marked stop-gaps where decisions are open, and never mark the task complete while a decision is still open. Use when the user invokes /scope with a task, or asks to scope, plan, or "figure out how to do" a change in an existing codebase.
---

# Scope

**Learn what exists before deciding what can be done and what must be built.**

The job: understand the ground thoroughly, build on what's already there, make every open decision visible, and never pass off a guess as a decision.

## Phase 1: Recon (no code changes yet)

Investigate before proposing anything. Cover every item below and write down what you found, with `file:line` references.

| Area | What to find | Where to look |
|---|---|---|
| **Conventions** | coding standards, naming, error handling, logging, test style | `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING*`, lint/format configs, 2–3 nearby files of the same kind |
| **Design patterns** | how similar features are already built (layering, DI, repositories, handlers, config) | the closest existing feature to this task: read it end to end |
| **Building blocks** | existing functions, utils, clients, types, components that already do part of the job | search by behaviour, not just by name; check `utils/`, `lib/`, `shared/`, `common/`, internal packages |
| **Dependencies** | libraries already installed that cover the need | `package.json` / `pyproject.toml` / `go.mod` / lockfiles |
| **Tooling** | build, test, lint, codegen, migrations, scripts, CI checks | `Makefile`, `package.json` scripts, `scripts/`, CI workflows |
| **Infrastructure** | how it runs and deploys: env vars, config, queues, DBs, feature flags, IaC | `docker-compose*`, IaC, `.env.example`, deploy configs |
| **Upstream** | what the code being changed calls or depends on | definitions, imports, API clients |
| **Downstream** | who calls or consumes it (other modules, services, repos, clients, data consumers) | find-references, generated clients, API schemas, other repos in the workspace |

- Use language-server tools (such as Lemma `references`, `implementations`, `check`) for usages and cross-repo impact when they're available. Text search misses aliases and matches comments and strings.
- Run the existing tests and build once so you know the baseline before changing anything.

## Phase 2: Decide what exists, what can be done, what must be built

Sort everything into three lists before writing code:

- **Exists:** building blocks that already solve part of the task (with `file:line`).
- **Can:** ways to meet the need by composing or extending what exists.
- **Must:** what is genuinely missing and has to be built new. Each item needs a one-line reason why nothing existing fits.

### Reuse ladder: take the first rung that works
1. Existing function or module in this repo, used as-is
2. Existing code in this repo, extended along its current design
3. Shared or internal library already used in the workspace
4. A dependency already installed
5. The standard library
6. A **new** dependency: ask first
7. New code: only for what's on the **Must** list

### Hard rules
- **Don't reinvent the wheel.** If a helper, client, validator or pattern exists, use it, even if you'd have written it differently.
- **No arbitrary or auxiliary functions.** Don't add one-off wrappers, `helpers.ts`, thin re-exports, or "utils" that duplicate or barely wrap existing code. New code goes where the codebase's existing structure says it belongs.
- **Match the local conventions**, even where they differ from your defaults.
- **Don't touch neighbouring code** (refactors, renames, reformatting) unless the task requires it.

## Phase 3: Questions, not assumptions

When the task, the codebase or the infrastructure leaves a choice open, **ask**. Don't pick silently.

- Send questions in **one batch**, numbered `D1, D2, …`, each with:
  - the question
  - what you found that raised it (`file:line`)
  - the options, with your **recommendation** and what each option changes
- Only ask about real decisions. Facts you can check in the code or docs, look up yourself.

## Phase 4: Handling ambiguity, with stop-gaps instead of stalling or guessing

When a decision is open but work can continue, build a **stop-gap** so the POC can run and be iterated on:

- Keep it **minimal and isolated**, behind the seam where the real decision will land (one function, config value, adapter or flag), so swapping it later changes one place.
- **Mark it in code** with the decision ID:
  `// STOPGAP(D2): hardcoded to "us-east-1" until region strategy is decided`
- Prefer something obviously provisional (a fixed value, an in-memory version, a no-op behind the real interface) over something that quietly looks finished.
- Iterate on the POC with the user; when a decision is made, replace the stop-gap and close the decision.

**Do NOT stop-gap; stop and ask instead** when the choice is hard to undo or reaches outside the POC: data model or schema migrations, public API or contract changes, deleting data, auth or security behaviour, new infrastructure, deploys, or anything touching shared or production environments.

## Decision log and the definition of done

Keep a running decision log and show it whenever you report progress:

```
| ID | Decision                 | Status    | Stop-gap location       |
|----|--------------------------|-----------|-------------------------|
| D1 | reuse RetryClient?       | ✅ yes     | n/a                     |
| D2 | region strategy          | ❓ open    | src/config/region.ts:12 |
| D3 | add zod dependency?      | ❌ no, use existing validator | n/a      |
```

- **The task is not complete while any decision is ❓ open or any `STOPGAP(` marker remains.** Report it as `POC: N decisions open`, never as "done".
- Before claiming completion, search the codebase for `STOPGAP(` and confirm the count is zero.

## Scope report (end of Phases 1–3, before building)

1. **Task:** one line, restated in your words.
2. **Exists / Can / Must** lists, with `file:line`.
3. **Impact map:** a tree or box diagram of upstream → change → downstream.
4. **Plan:** ordered steps, each naming the existing building block it uses.
5. **Decisions:** the `D1…Dn` questions plus the decision log.

Then wait for answers on anything you can't stop-gap before building.
