---
name: build
description: BUILD step of the senior-engineer spine — the smallest correct change. Keep the diff small and reversible, match existing patterns, isolate risky work, add nothing extra. Use while implementing, or say /build. One verb of /lets-hack.
---

# Build (/build)

Make the change small, focused, and reversible. Match the patterns already in the code; do exactly
what was asked — no "while I'm here" extras.

- Isolate risky or parallel work in its own git worktree so changes can't collide.
- Keep the diff tight; reuse existing utilities and conventions instead of inventing new ones.
- For any config/env/settings map, fetch-merge-write the whole thing — a partial write silently *replaces*.
- The block-suppressions guard is live: fix real type/lint errors, don't reach for a suppression.

Heuristic — *Smallest diff that's actually correct.* Big rewrites hide that you didn't understand the system.

Run the whole flow with **/lets-hack**.
