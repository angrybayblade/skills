#!/usr/bin/env bash
# Install skills from angrybayblade/skills for any agent that supports Agent Skills
# (https://agentskills.io): a folder per skill with a SKILL.md inside.
#
#   curl -fsSL https://raw.githubusercontent.com/angrybayblade/skills/main/install.sh | bash
#   curl -fsSL .../install.sh | bash -s -- sr sc     # only some skills
#
# Env:
#   SKILLS_DIR         where skills are stored (default: ~/.agents/skills, the shared
#                      location that many agents read directly)
#   AGENT_SKILLS_DIRS  colon-separated skill folders of agents that don't read SKILLS_DIR;
#                      each skill is symlinked into every one of them
#                      (default: ~/.claude/skills if ~/.claude exists, otherwise none)
#   SKILLS_REF         branch, tag or commit (default: main)
#   GITHUB_TOKEN       token for a private repo (falls back to GH_TOKEN, then `gh auth token`)
set -euo pipefail

REPO="angrybayblade/skills"
REF="${SKILLS_REF:-main}"
DEST="${SKILLS_DIR:-$HOME/.agents/skills}"

say() { printf '%s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

command -v curl >/dev/null || die "curl is required"
command -v tar  >/dev/null || die "tar is required"

link_dirs=()
if [ -n "${AGENT_SKILLS_DIRS+set}" ]; then
  IFS=':' read -r -a link_dirs <<< "$AGENT_SKILLS_DIRS"
elif [ -d "$HOME/.claude" ]; then
  link_dirs=("$HOME/.claude/skills")
fi

token="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
if [ -z "$token" ] && command -v gh >/dev/null 2>&1; then
  token="$(gh auth token 2>/dev/null || true)"
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

auth=()
[ -n "$token" ] && auth=(-H "Authorization: Bearer $token")

say "Downloading $REPO@$REF ..."
curl -fsSL ${auth[@]+"${auth[@]}"} \
  "https://api.github.com/repos/$REPO/tarball/$REF" \
  | tar -xz -C "$tmp" --strip-components=1 \
  || die "download failed (private repo? set GITHUB_TOKEN or run 'gh auth login')"

[ -d "$tmp/skills" ] || die "no skills/ directory in $REPO@$REF"

if [ "$#" -gt 0 ]; then
  names=("$@")
else
  names=()
  for d in "$tmp"/skills/*/; do names+=("$(basename "$d")"); done
fi

for name in "${names[@]}"; do
  [ -f "$tmp/skills/$name/SKILL.md" ] || die "unknown skill: $name"
done

mkdir -p "$DEST"
ts="$(date +%Y%m%d%H%M%S)"

for name in "${names[@]}"; do
  rm -rf "${DEST:?}/$name"
  cp -R "$tmp/skills/$name" "$DEST/$name"

  for dir in ${link_dirs[@]+"${link_dirs[@]}"}; do
    [ -n "$dir" ] || continue
    mkdir -p "$dir"
    link="$dir/$name"
    if [ -L "$link" ]; then
      rm "$link"
    elif [ -e "$link" ]; then
      mv "$link" "$link.bak.$ts"
      say "  backed up existing $link -> $link.bak.$ts"
    fi
    ln -s "$DEST/$name" "$link"
  done
  say "  ✓ $name"
done

say "Installed ${#names[@]} skill(s) to $DEST."
for dir in ${link_dirs[@]+"${link_dirs[@]}"}; do
  [ -n "$dir" ] && say "Linked into $dir."
done
say "If your agent doesn't list them, reload its skills or start a new session."
