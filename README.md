# skills

Agent skills for [Claude Code](https://claude.com/claude-code), built for visual and low-noise collaboration.

| Skill | Invoke | What it does |
|---|---|---|
| [**bm**](skills/bm/SKILL.md): brief me | `/bm [topic]` | A visual, hierarchical briefing (one-liner, map, diagrams, drill-down, "needs you"). With no topic, it briefs on what was done since your last message. |
| [**sr**](skills/sr/SKILL.md): sitrep | `/sr` | A situation report on the current task in 15 lines or fewer: status, progress line, now / blocked / next / needs you. |
| [**sc**](skills/sc/SKILL.md): scope | `/sc <task>` | Understands the codebase and infrastructure before deciding anything. Reuses what exists, asks instead of assuming, puts stop-gaps where decisions are open, and never marks a task done while a decision is still open. |
| [**bs**](skills/bs/SKILL.md): brainstorm | `/bs <problem>` | Breaks a problem apart, discusses every trade-off back and forth, then reassembles a solution. Writes no code until you explicitly ask. |
| [**hc**](skills/hc/SKILL.md): hill climb | `/hc <objective>` | Measured optimization loop: approach, implement, benchmark, regression-test, then the next step. It reverts changes that don't help and searches widely when progress stalls. |
| [**ct**](skills/ct/SKILL.md): critical thinking | `/ct` | Critical-thinking mode, on until you explicitly end it. Zooms out from local fixes to the whole system, finds root causes, backs every claim with code, commands or logs, checks for bias, stays pragmatic, and pushes back on bad decisions. |
| [**zo**](skills/zo/SKILL.md): zoom out | `/zo [topic]` | Moves the problem one level of abstraction **up** (code → module → component → system → ecosystem → purpose) and shows what becomes visible from there. |
| [**zi**](skills/zi/SKILL.md): zoom in | `/zi [thing]` | Moves the problem one level of abstraction **down** (purpose → … → code → runtime) and shows the internals and exactly where the problem lives, with evidence. |

## How they fit together

```
/bs ──▶ /sc ──▶ build ──▶ /hc (optimize)
decide   ground in   ▲
         codebase    │ explicit "build it"

anytime:  /sr       (where are we?)
          /bm       (explain it to me)
          /zo /zi   (move up or down one level of abstraction)
          /ct       (critical-thinking layer on top of everything, until you exit it)
```

### Abstraction ladder used by `/zo` and `/zi`

```
L6 Purpose › L5 Ecosystem › L4 System › L3 Component › L2 Module › L1 Code › L0 Runtime
              ◀── /zo (one level up)        /zi (one level down) ──▶
```

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/angrybayblade/skills/main/install.sh | bash
```

To install only some skills:

```bash
curl -fsSL https://raw.githubusercontent.com/angrybayblade/skills/main/install.sh | bash -s -- sr sc
```

**If the repo is private**, `raw.githubusercontent.com` needs a token too. With the GitHub CLI logged in:

```bash
curl -fsSL -H "Authorization: Bearer $(gh auth token)" \
  https://raw.githubusercontent.com/angrybayblade/skills/main/install.sh | bash
```

The script picks up `GITHUB_TOKEN`, `GH_TOKEN`, or `gh auth token` automatically when it downloads the skills.

### What it does

- Copies each skill into `~/.agents/skills/<name>`, a store shared with other agents.
- Symlinks `~/.claude/skills/<name>` to that copy so Claude Code finds it.
- Replaces older installs of the same skills. A non-symlink folder already at the link path is moved aside to `<name>.bak.<timestamp>`.

Claude Code picks the skills up right away. If one is missing, run `/reload-skills` or start a new session.

### Options

| Env var | Default | Purpose |
|---|---|---|
| `SKILLS_DIR` | `~/.agents/skills` | where skills are stored |
| `CLAUDE_SKILLS_DIR` | `~/.claude/skills` | where Claude Code looks for skills |
| `SKILLS_REF` | `main` | branch, tag or commit to install |
| `GITHUB_TOKEN` | (none) | token for a private repo |

### Update / uninstall

- **Update:** re-run the install command.
- **Uninstall:** `rm -rf ~/.agents/skills/<name> ~/.claude/skills/<name>`
- **Renamed skills:** `brief-me`, `sitrep`, `scope`, `brainstorm` and `hill-climb` are now `bm`, `sr`, `sc`, `bs` and `hc`. The installer doesn't remove the old names, so uninstall those by hand if you have them.

## Layout

```
skills/<name>/SKILL.md   one folder per skill (frontmatter: name, description)
install.sh               curl installer
```
