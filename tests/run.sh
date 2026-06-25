#!/usr/bin/env bash
# senior-engineer-mode — hook tests.
# stdin -> exit-code assertions for the two enforcing guards. No network, no repo
# state required. Run from anywhere:  bash tests/run.sh
# Exits non-zero if any assertion fails, with a clear pass/fail summary.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOKS="$REPO/hooks"
# shellcheck source=../hooks/lib/common.sh
source "$HOOKS/lib/common.sh"

if ! command -v jq >/dev/null 2>&1; then
  echo "tests need 'jq' on PATH — install it and re-run." >&2
  exit 2
fi

pass=0; fail=0
ok()  { pass=$((pass+1)); printf '  ok    %s\n' "$1"; }
bad() { fail=$((fail+1)); printf '  FAIL  %s\n' "$1"; }

# ---------------------------------------------------------------------------
# block-suppressions: feed a tool-call JSON on stdin, assert the exit code.
#   exit 0 = allowed, exit 2 = blocked.
# ---------------------------------------------------------------------------
edit_json() { jq -nc --arg f "$1" --arg s "$2" '{tool_name:"Edit",tool_input:{file_path:$f,new_string:$s}}'; }

expect_block() { # desc, want_exit, json
  local desc="$1" want="$2" json="$3" got
  printf '%s' "$json" | "$HOOKS/block-suppressions.sh" >/dev/null 2>&1
  got=$?
  if [ "$got" = "$want" ]; then ok "$desc (exit=$got)"; else bad "$desc (want $want, got $got)"; fi
}

echo "block-suppressions:"
expect_block "as any in .ts is blocked"               2 "$(edit_json /tmp/x.ts 'const x = data as any;')"
expect_block "// senior-mode: allow override passes"  0 "$(edit_json /tmp/x.ts 'const x = data as any; // senior-mode: allow — vendor type is wrong')"
expect_block "@ts-ignore is blocked"                  2 "$(edit_json /tmp/x.ts '// @ts-ignore
const y = z;')"
expect_block "eslint-disable is blocked"              2 "$(edit_json /tmp/x.ts '/* eslint-disable */
const y = z;')"
expect_block "# type: ignore in .py is blocked"       2 "$(edit_json /tmp/x.py 'x = y  # type: ignore')"
expect_block ".md is exempt (docs may mention as any)" 0 "$(edit_json /tmp/readme.md 'Use `as any` to silence the checker.')"
expect_block ".sh is exempt"                          0 "$(edit_json /tmp/run.sh 'echo "as any"')"
expect_block ".json is exempt"                        0 "$(edit_json /tmp/x.json '{"note": "as any"}')"
expect_block "clean .ts code is allowed"              0 "$(edit_json /tmp/x.ts 'const x: number = 1;')"

# ---------------------------------------------------------------------------
# done-detector: call the function directly; assert trigger / no-trigger.
# ---------------------------------------------------------------------------
expect_done() { # desc, want(yes|no), text
  local desc="$1" want="$2" text="$3" got
  if sm_text_claims_done "$text"; then got=yes; else got=no; fi
  if [ "$got" = "$want" ]; then ok "$desc -> $got"; else bad "$desc (want $want, got $got)"; fi
}

echo "done-detector (false positives that must NOT trigger):"
expect_done "question 'is it finished?'"        no  "is it finished?"
expect_done "negation 'not fixed it yet'"       no  "I have not fixed it yet"
expect_done "aside 'the complete list'"         no  "here's the complete list"
expect_done "bare 'works' in passing"           no  "this is how it works"
expect_done "mid-work 'done with scoping'"      no  "Done with scoping; now building."
expect_done "negated 'tests didn't pass'"       no  "The tests didn't pass."
expect_done "question w/o '?': 'Did the tests pass'" no "Did the tests pass"
expect_done "question 'Should I mark this done'" no  "Should I mark this done"
expect_done "far negation 'don't think it passes'" no "I don't think the lint passes."
expect_done "far negation 'not sure tests pass'" no  "I'm not sure the tests pass."

echo "done-detector (real claims that MUST trigger):"
expect_done "'All done, typecheck passes'"      yes "All done, typecheck passes"
expect_done "'Fixed it.'"                        yes "Fixed it."
expect_done "'Ready to ship.'"                   yes "Ready to ship."
expect_done "honest report w/ 'didn't' aside"   yes "All done — typecheck passes; I didn't touch the auth flow."
expect_done "'Done.' alone"                      yes "Done."

echo
echo "passed: $pass   failed: $fail"
[ "$fail" -eq 0 ]
