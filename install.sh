#!/usr/bin/env bash
# Install skills from angrybayblade/skills for Claude Code (and other agents).
#
#   curl -fsSL https://raw.githubusercontent.com/angrybayblade/skills/main/install.sh | bash
#   curl -fsSL .../install.sh | bash -s -- sitrep scope     # only some skills
#
# Env:
#   SKILLS_DIR         where skills are stored     (default: ~/.agents/skills)
#   CLAUDE_SKILLS_DIR  where Claude Code finds them (default: ~/.claude/skills)
#   SKILLS_REF         branch, tag or commit        (default: main)
#   GITHUB_TOKEN       token for a private repo     (falls back to GH_TOKEN, then `gh auth token`)
set -euo pipefail

REPO="angrybayblade/skills"
REF="${SKILLS_REF:-main}"
DEST="${SKILLS_DIR:-$HOME/.agents/skills}"
LINK_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

say() { printf '%s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

command -v curl >/dev/null || die "curl is required"
command -v tar  >/dev/null || die "tar is required"

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

mkdir -p "$DEST" "$LINK_DIR"
ts="$(date +%Y%m%d%H%M%S)"

for name in "${names[@]}"; do
  src="$tmp/skills/$name"
  [ -f "$src/SKILL.md" ] || die "unknown skill: $name"

  rm -rf "${DEST:?}/$name"
  cp -R "$src" "$DEST/$name"

  link="$LINK_DIR/$name"
  if [ -L "$link" ]; then
    rm "$link"
  elif [ -e "$link" ]; then
    mv "$link" "$link.bak.$ts"
    say "  backed up existing $link -> $link.bak.$ts"
  fi
  ln -s "$DEST/$name" "$link"
  say "  ✓ $name"
done

say "Installed ${#names[@]} skill(s) to $DEST (linked in $LINK_DIR)."
say "Start a new Claude Code session to pick them up."
