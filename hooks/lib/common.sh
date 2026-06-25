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
sm_text_claims_done() {
  [ -n "${1:-}" ] || return 1
  printf '%s' "$1" | grep -qiE \
    '\b(done|finished|complete|completed|fixed|resolved|implemented|shipped|works|working|passing|passes|ready to (ship|merge|go)|good to go|all set|verified)\b|✅|✓'
}
