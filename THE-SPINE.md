# The Spine — how to make a change like a senior engineer (with an AI)

Five moves, always in this order. Each has a job, a tool, and a one-line rule to remember it by.

The whole point: you don't memorize a pile of skills. You remember **five verbs**.

```
SCOPE  →  BUILD  →  VERIFY  →  REVIEW  →  SHIP
```

---

## 1. SCOPE — understand before you touch anything

Find the real path the feature actually travels, read how the codebase already does this, and
decide the **smallest** change that solves it.

- **Do:** enter plan mode; send an `Explore` scout to map where things live (it reads in a side
  context, so your main window stays sharp); find an existing pattern and plan to reuse it.
- **Don't:** start editing "to see what happens."
- **Heuristic — _Scout, then step._** No edit until you can name the file you'll change and why.

## 2. BUILD — the smallest correct change

Keep the change small, focused, and reversible. Match the patterns already in the code instead of
inventing new ones. Do exactly what was asked — no surprise extras.

- **Do:** work in an isolated branch/worktree; keep the diff tight; preserve the existing architecture.
- **Don't:** rewrite unrelated code; pile on "while I'm here" scope; invent a new pattern when one fits.
- **Heuristic — _Smallest diff that's actually correct._** Big rewrites are how juniors hide that
  they didn't understand the system.

## 3. VERIFY — prove it through the real path

"Looks done" is not done. Run the actual route, button, endpoint, or job the change lives on —
not just the helper function — and show the evidence.

- **Do:** check the data before blaming the UI; run typecheck / lint / tests; paste the real output.
- **Don't:** claim success from reading the code; trust a happy path you only imagined.
- **Heuristic — _Show, don't tell._** A claim with no evidence is a guess.

## 4. REVIEW — fresh eyes that didn't write it

The one who wrote the code is the worst one to catch its bugs. Hand the diff to a reviewer that
never saw your reasoning — a second model, or a fresh-context subagent.

- **Do:** run `/code-review` or the `skeptic` agent on the diff; ask only for correctness /
  requirements gaps.
- **Don't:** let the reviewer gold-plate (style nits dressed up as bugs); grade your own homework.
- **Heuristic — _Two eyes, not one brain._** Different reviewer, ideally a different model — they
  miss different things.

## 5. SHIP — gate it, then hand it off clean

Commit and open the PR only after the gates pass. Keep history tight, never discard uncommitted
work, and tell the human what's safe and what's still risky.

- **Do:** let the hooks gate the commit; end with an honest report — what changed, what you
  verified, what you did **not** touch, what's still risky.
- **Don't:** auto-merge to production; silently discard changes; declare "done" without the
  honest-risk line.
- **Heuristic — _Leave a trail._** The next person (usually future-you) should see *why*, not just *what*.

---

## Why five verbs and not fifty rules

You forget rules. You don't forget a short story. `SCOPE → BUILD → VERIFY → REVIEW → SHIP` is the
story of every safe change: **look, change a little, prove it, get a second opinion, hand it off
clean.** The rules file (`rules/AGENTS.md`) and the hooks make the boring parts automatic — so the
only thing you carry in your head is these five.

> **The one law behind all of it: _prose for taste, machinery for guarantees._**
> Rules in a file are advice and fade as a session fills up. The hooks don't fade — they're the
> floor you can't fall through. Use the verbs to think; trust the machinery to enforce.
