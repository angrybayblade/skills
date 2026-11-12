# skills

Agent skills for [Claude Code](https://claude.com/claude-code), built for visual and low-noise collaboration.

| Skill | Invoke | What it does |
|---|---|---|
| [**brief-me**](skills/brief-me/SKILL.md) | `/brief-me [topic]` | A visual, hierarchical briefing (one-liner, map, diagrams, drill-down, "needs you"). With no topic, it briefs on what was done since your last message. |
| [**sitrep**](skills/sitrep/SKILL.md) | `/sitrep` | A situation report on the current task in 15 lines or fewer: status, progress line, now / blocked / next / needs you. |
| [**scope**](skills/scope/SKILL.md) | `/scope <task>` | Understands the codebase and infrastructure before deciding anything. Reuses what exists, asks instead of assuming, puts stop-gaps where decisions are open, and never marks a task done while a decision is still open. |
| [**brainstorm**](skills/brainstorm/SKILL.md) | `/brainstorm <problem>` | Breaks a problem apart, discusses every trade-off back and forth, then reassembles a solution. Writes no code until you explicitly ask. |
| [**hill-climb**](skills/hill-climb/SKILL.md) | `/hill-climb <objective>` | Measured optimization loop: approach, implement, benchmark, regression-test, then the next step. It reverts changes that don't help and searches widely when progress stalls. |

## How they fit together

```
/brainstorm ──▶ /scope ──▶ build ──▶ /hill-climb (optimize)
  decide         ground in    ▲
                 codebase     │ explicit "build it"

anytime:  /sitrep   (where are we?)
          /brief-me (explain it to me)
```

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/angrybayblade/skills/main/install.sh | bash
```

To install only some skills:

```bash
curl -fsSL https://raw.githubusercontent.com/angrybayblade/skills/main/install.sh | bash -s -- sitrep scope
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

Start a new Claude Code session afterwards to load the skills.

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

## Layout

```
skills/<name>/SKILL.md   one folder per skill (frontmatter: name, description)
install.sh               curl installer
```
