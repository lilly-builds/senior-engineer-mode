#!/usr/bin/env bash
# senior-engineer-mode — Stop hook ("verify before done").
#
# Runs the repo's fast checks (typecheck, lint) ONLY when the agent's final message
# claims the work is done — then blocks the turn from ending if those checks fail.
# Principle: use the tool when the tool is needed. No tax on pauses or questions;
# the gate runs exactly when someone says "done / fixed / works".
#
# ON by default in any JS/TS git repo with changed code — no opt-in file required.
# Per-repo control via .senior-mode.json:
#   { "enabled": false }          # turn senior-mode hooks off for this repo
#   { "block_on_tests": true }    # also run the test suite on a done-claim
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

input="$(cat)"

sm_disabled && exit 0
sm_is_code_repo || exit 0
sm_changed_code_files >/dev/null || exit 0

# The trigger: only engage when the latest assistant message claims completion.
transcript="$(printf '%s' "$input" | jq -r '.transcript_path // empty' 2>/dev/null)"
sm_text_claims_done "$(sm_last_assistant_text "$transcript")" || exit 0

root="$(sm_git_root)"
pkg="$root/package.json"
[ -f "$pkg" ] || exit 0                          # v1 gates JS/TS repos only
command -v jq  >/dev/null 2>&1 || exit 0
command -v npm >/dev/null 2>&1 || exit 0

# Pick the first script that exists in each group.
pick_script() {
  local s
  for s in "$@"; do
    if jq -e --arg s "$s" '.scripts[$s] // empty' "$pkg" >/dev/null 2>&1; then printf '%s' "$s"; return 0; fi
  done
  return 1
}
typecheck_script="$(pick_script typecheck type-check tsc)"
lint_script="$(pick_script lint eslint)"

failures=""
run_check() {
  local name="$1" out
  if ! out="$(cd "$root" && npm run "$name" --silent 2>&1)"; then
    failures+="### npm run $name FAILED"$'\n'"$(printf '%s\n' "$out" | tail -n 40)"$'\n\n'
  fi
}

[ -n "$typecheck_script" ] && run_check "$typecheck_script"
[ -n "$lint_script" ]      && run_check "$lint_script"
if [ "$(sm_config block_on_tests 2>/dev/null)" = "true" ] && jq -e '.scripts.test // empty' "$pkg" >/dev/null 2>&1; then
  run_check test
fi

if [ -n "$failures" ]; then
  {
    echo "BLOCKED by senior-engineer-mode (VERIFY): you claimed done, but checks fail on changed code."
    echo "Fix these before finishing — do not suppress them:"
    echo
    printf '%s' "$failures"
    echo "(Disable for this repo via .senior-mode.json: {\"enabled\":false}.)"
  } >&2
  exit 2
fi
exit 0
