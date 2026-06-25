#!/usr/bin/env bash
# senior-engineer-mode — SessionStart hook.
# Greets each CODE session with the 5-verb spine + live-guardrail status, so the
# workflow is in front of you without you remembering to load it. Advisory only —
# the PreToolUse/Stop hooks do the enforcing. Silent in non-code sessions.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

cat >/dev/null   # consume hook stdin

sm_disabled && exit 0
sm_is_code_repo || exit 0   # don't pollute writing / ads / video / notes sessions

read -r -d '' SPINE <<'EOF' || true
[senior-engineer-mode active] Work the spine, in order:
SCOPE → BUILD → VERIFY → REVIEW → SHIP
  SCOPE   understand before editing — plan + Explore, smallest change, ask up front
  BUILD   smallest correct diff; match existing patterns; isolate risky work
  VERIFY  prove it through the real path; show evidence, not claims
  REVIEW  fresh eyes on the diff — /code-review or the `skeptic` agent (correctness only)
  SHIP    gate on green checks; honest report; people/data/money decisions go to a human
Guardrails live: error-hiding suppressions are blocked in code; when you claim "done",
typecheck + lint must pass on changed code.
Drive it deliberately with /lets-hack (or /lets-hack <verb> to jump to a step).
Full SOP: ~/.claude/senior-engineer-mode/THE-SPINE.md
EOF

# Prefer the structured context-injection contract; fall back to plain stdout.
if command -v jq >/dev/null 2>&1; then
  jq -nc --arg c "$SPINE" \
    '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$c}}'
else
  printf '%s\n' "$SPINE"
fi
exit 0
