#!/usr/bin/env bash
# senior-engineer-mode — PreToolUse hook (matcher: Edit|Write|MultiEdit)
# Blocks edits that HIDE errors instead of fixing them (any / @ts-ignore / eslint-disable / …).
# Escape hatch: put a justification on the same line —  // senior-mode: allow — <why>
# Fails OPEN (exit 0) on any parsing problem; only exit 2 (block) on a real, unjustified hit.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

input="$(cat)"

# Per-repo opt-out, or no jq to parse the payload → don't block.
sm_disabled && exit 0
command -v jq >/dev/null 2>&1 || exit 0

file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"

# Text this edit/write is INTRODUCING (Edit.new_string, Write.content, MultiEdit.edits[].new_string).
added="$(printf '%s' "$input" | jq -r '
  [ .tool_input.new_string?,
    .tool_input.content?,
    ( .tool_input.edits[]?.new_string ) ]
  | map(select(. != null)) | join("\n")
' 2>/dev/null)"

[ -n "$added" ] || exit 0

ext="${file_path##*.}"

# Only gate real code files. Markdown / shell / JSON / text may legitimately mention
# these tokens (docs, examples, this pack itself) without hiding any error.
case "$ext" in
  ts|tsx|js|jsx|mjs|cjs|vue|svelte)
    patterns='@ts-ignore|@ts-nocheck|eslint-disable|(^|[^[:alnum:]])as any([^[:alnum:]]|$)|:[[:space:]]*any([^[:alnum:]]|$)|<any>' ;;
  py)
    patterns='#[[:space:]]*type:[[:space:]]*ignore|#[[:space:]]*noqa' ;;
  *)
    exit 0 ;;
esac

# Offending lines that do NOT carry a justified override marker.
offending="$(printf '%s\n' "$added" \
  | grep -nE "$patterns" 2>/dev/null \
  | grep -viE 'senior-mode:[[:space:]]*allow' 2>/dev/null || true)"

if [ -n "$offending" ]; then
  {
    echo "BLOCKED by senior-engineer-mode: this edit hides an error instead of fixing it."
    echo "File: ${file_path:-<unknown>}"
    echo "Offending line(s):"
    printf '%s\n' "$offending" | sed 's/^/  /'
    echo
    echo "Fix the underlying type/lint error. If a suppression is genuinely unavoidable,"
    echo "justify it on the same line, e.g.:   // senior-mode: allow — <why this is safe>"
  } >&2
  exit 2
fi
exit 0
