#!/usr/bin/env bash
# senior-engineer-mode — uninstaller. Cleanly reverses what the install brief
# (CLAUDE.md) sets up, touching ONLY senior-mode's own entries:
#   1. remove the 3 senior-mode hooks from ~/.claude/settings.json (merge-aware)
#   2. remove the `@senior-engineer-mode/rules/AGENTS.md` line from ~/.claude/CLAUDE.md
#   3. remove the symlinks (skeptic agent + the 4 skills)
#   4. remove the ~/.claude/senior-engineer-mode/ pack folder
#
# Every other hook, setting, skill, and line you have is preserved. settings.json
# is backed up before it is touched. Fails loud, never blunt-overwrites.
#
# Usage:  bash uninstall.sh           # uninstall from ~/.claude
#         CLAUDE_HOME=/path bash uninstall.sh   # target a different config dir (testing)
set -uo pipefail

CLAUDE_DIR="${CLAUDE_HOME:-$HOME/.claude}"
SETTINGS="$CLAUDE_DIR/settings.json"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
PACK="$CLAUDE_DIR/senior-engineer-mode"

say()  { printf '  %s\n' "$1"; }
warn() { printf '  ! %s\n' "$1" >&2; }

echo "Uninstalling senior-engineer-mode from: $CLAUDE_DIR"

# 1 · settings.json — strip only hooks whose command path mentions senior-engineer-mode.
if [ -f "$SETTINGS" ]; then
  if ! command -v jq >/dev/null 2>&1; then
    warn "jq not found — cannot safely edit settings.json. Remove the 3 senior-engineer-mode hook entries by hand."
  else
    bak="$SETTINGS.bak.$(date +%Y%m%d%H%M%S)"
    cp "$SETTINGS" "$bak"
    if jq '
      if (.hooks | type) == "object" then
        .hooks = (
          .hooks
          | to_entries
          | map(
              .value = ( (.value // [])
                | map( .hooks = ((.hooks // []) | map(select((.command // "") | test("senior-engineer-mode") | not))) )
                | map(select((.hooks | length) > 0))
              )
            )
          | map(select((.value | length) > 0))
          | from_entries
        )
        | (if (.hooks | length) == 0 then del(.hooks) else . end)
      else . end
    ' "$bak" > "$SETTINGS.tmp" 2>/dev/null && jq -e . "$SETTINGS.tmp" >/dev/null 2>&1; then
      mv "$SETTINGS.tmp" "$SETTINGS"
      say "settings.json — removed senior-mode hooks (backup: $bak)"
    else
      rm -f "$SETTINGS.tmp"
      warn "settings.json edit failed; left it untouched (backup at $bak)."
    fi
  fi
else
  say "settings.json — not present, skipping"
fi

# 2 · CLAUDE.md — drop only the rules @-reference line; leave everything else.
if [ -f "$CLAUDE_MD" ]; then
  if grep -qE '^[[:space:]]*@senior-engineer-mode/rules/AGENTS\.md[[:space:]]*$' "$CLAUDE_MD"; then
    grep -vE '^[[:space:]]*@senior-engineer-mode/rules/AGENTS\.md[[:space:]]*$' "$CLAUDE_MD" > "$CLAUDE_MD.tmp" \
      && mv "$CLAUDE_MD.tmp" "$CLAUDE_MD" \
      && say "CLAUDE.md — removed the @senior-engineer-mode/rules/AGENTS.md line"
  else
    say "CLAUDE.md — no senior-mode reference found, skipping"
  fi
else
  say "CLAUDE.md — not present, skipping"
fi

# 3 · symlinks (skeptic agent + skills). Only remove if they point into the pack.
remove_link() { # path
  local p="$1"
  if [ -L "$p" ]; then
    case "$(readlink "$p")" in
      *senior-engineer-mode*) rm -f "$p"; say "unlinked $p" ;;
      *) warn "$p is a symlink but not ours — left it." ;;
    esac
  elif [ -e "$p" ]; then
    warn "$p exists but is not a symlink — left it (remove by hand if it's senior-mode's)."
  fi
}
remove_link "$CLAUDE_DIR/agents/skeptic.md"
for s in lets-hack scope build ship; do
  remove_link "$CLAUDE_DIR/skills/$s"
done

# 4 · the pack folder itself.
if [ -d "$PACK" ]; then
  rm -rf "$PACK"
  say "removed $PACK"
else
  say "pack folder not present, skipping"
fi

echo "Done. Start a fresh chat — the spine reminder and guardrails are gone."
echo "(Your settings.json backup is kept; delete it once you're happy.)"
