#!/usr/bin/env bash
# senior-engineer-mode — shared hook guards.
# Sourced by the hook scripts. Side-effect free; defines functions only.
# These guards exist so the hooks NEVER fire on non-code work (writing, ads,
# video, notes). A hook with no real code repo + code changes must no-op.

# Project manifests that mark a directory as a "code repo" worth gating.
SM_MANIFESTS=(package.json pyproject.toml setup.py go.mod Cargo.toml pom.xml build.gradle Gemfile composer.json)

# Source-file extensions that count as "code changed".
SM_CODE_EXT='ts|tsx|js|jsx|mjs|cjs|py|go|rs|java|rb|php|c|h|cpp|cc|hpp|cs|swift|kt|scala|sql|vue|svelte'

sm_git_root() {
  git rev-parse --show-toplevel 2>/dev/null
}

# Return 0 if cwd is in a git repo that has a recognized manifest (repo root or cwd).
sm_is_code_repo() {
  local root; root="$(sm_git_root)" || return 1
  [ -n "$root" ] || return 1
  local m
  for m in "${SM_MANIFESTS[@]}"; do
    [ -f "$root/$m" ] && return 0
    [ -f "./$m" ] && return 0
  done
  return 1
}

# Print changed source files (staged + unstaged + untracked). Return 0 if any, 1 if none.
sm_changed_code_files() {
  local files
  files="$(git status --porcelain 2>/dev/null | sed 's/^...//' | grep -Ei "\.($SM_CODE_EXT)\$")"
  [ -n "$files" ] || return 1
  printf '%s\n' "$files"
  return 0
}

# Echo a field from .senior-mode.json (repo root or cwd), or nothing.
sm_config() {
  local key="$1" root; root="$(sm_git_root 2>/dev/null)"
  local cfg="$root/.senior-mode.json"
  [ -f "$cfg" ] || cfg="./.senior-mode.json"
  [ -f "$cfg" ] || return 1
  command -v jq >/dev/null 2>&1 || return 1
  # NB: use has()/else — `.[$k] // empty` wrongly drops a boolean `false` (jq's // skips false).
  jq -r --arg k "$key" 'if has($k) then .[$k] else empty end' "$cfg" 2>/dev/null
}

# Return 0 if senior-mode is explicitly disabled for this repo.
sm_disabled() {
  [ "$(sm_config enabled 2>/dev/null)" = "false" ]
}

# Echo the text of the most recent assistant message in a transcript .jsonl file.
sm_last_assistant_text() {
  local tp="$1"
  [ -n "$tp" ] && [ -f "$tp" ] || return 1
  command -v jq >/dev/null 2>&1 || return 1
  # Claude Code transcript = one JSON object per line. Assistant turns carry
  # message.role == "assistant" with content[] entries of type "text".
  jq -rs '
    map(select(.message.role == "assistant")) | last
    | (.message.content // []) | map(select(.type == "text") | .text) | join("\n")
  ' "$tp" 2>/dev/null
}

# Return 0 if the given text reads like a completion / "it's done" claim.
# This is the trigger for the verify gate: run the checks when work is CLAIMED done,
# not on every pause or question. Use the tool when the tool is needed.
#
# Precision matters more than recall here: a false positive runs the checks on a
# question or an aside ("is it finished?", "here's the complete list") and annoys.
# So we judge only the FINAL non-empty line, skip trailing questions, skip a
# negation sitting next to a completion word, and require a genuine completion
# phrase — never a bare keyword like "complete" / "finished" / "works".
sm_text_claims_done() {
  [ -n "${1:-}" ] || return 1

  # The claim, if any, lands at the end of the message — not buried mid-prose.
  local line
  line="$(printf '%s\n' "$1" | grep -v '^[[:space:]]*$' | tail -n 1)"
  [ -n "$line" ] || return 1

  # A question is never a completion claim — catch both the trailing "?"
  # ("is it finished?") and interrogative/modal openers that omit it
  # ("Did the tests pass", "Should I mark this done", "Want me to verify").
  case "$line" in *'?') return 1 ;; esac
  printf '%s' "$line" | grep -qiE \
    '^[[:space:]]*(is|are|was|were|do|does|did|should|shall|can|could|would|will|want|have|has|am)\b' \
    && return 1

  # A negation near a completion word kills the claim:
  #   "I have not fixed it yet", "tests didn't pass", "I don't think the lint passes".
  # Proximity (<=5 words) catches ordinary negations while keeping an honest-report
  # aside from misfiring — in "All done … I didn't touch the auth flow" the negator
  # sits AFTER the keyword, so the neg->keyword clause never matches it.
  local neg='not|never|cannot|can.t|won.t|don.t|doesn.t|didn.t|isn.t|aren.t|wasn.t|weren.t|hasn.t|haven.t|hadn.t|no longer'
  local kw='done|finished|fixed|resolved|implemented|shipped|complete|completed|ready|pass|passes|passed|passing|working|works'
  if printf '%s' "$line" | grep -qiE "\b(${neg})\b([[:space:]]+[a-z'-]+){0,5}[[:space:]]+(${kw})\b"; then
    return 1
  fi
  if printf '%s' "$line" | grep -qiE "\b(${kw})\b([[:space:]]+[a-z'-]+){0,5}[[:space:]]+(yet|not yet)\b"; then
    return 1
  fi

  # Require a deliberate completion phrase, not a bare keyword used in passing.
  printf '%s' "$line" | grep -qiE \
    "\ball (done|set|finished|good)\b|\bdone[[:space:]]*[.!]|^[[:space:]]*(fixed|resolved|implemented|shipped)\b|\b(fixed|resolved|implemented|shipped) it\b|\b(typecheck|type-check|lint|tests?|checks?|build|ci)\b[^.!?]{0,40}\b(pass|passes|passed|passing|green|succeed|succeeds|succeeded)\b|\bready to (ship|merge|go)\b|\bgood to go\b|\ball green\b|✅"
}
