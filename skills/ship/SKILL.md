---
name: ship
description: SHIP step of the senior-engineer spine — gate it, then hand it off clean. Commit only on green checks, keep history tight, never discard uncommitted work, and end with an honest report. Use when finishing a change, or say /ship. One verb of /lets-hack.
---

# Ship (/ship)

Land the change only after it's proven, and hand it off so the next person (usually future-you)
sees *why*, not just *what*.

- Commit only after checks are green (the verify-before-done guard enforces this on a "done" claim).
- Open the PR; clean up the branch/worktree as part of merging, not as a later chore.
- Never discard uncommitted work — stash first; confirm before any destructive git op.
- End with the **honest report**: what changed, why it's safe, what you verified, what's still
  risky, what you did **not** touch.
- Decisions about people, data, or money go to a human — surface them, don't auto-act.

Heuristic — *Leave a trail.* "Done" means proven, not hoped; copy is a contract.

Run the whole flow with **/lets-hack**.
