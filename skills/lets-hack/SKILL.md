---
name: lets-hack
description: Front door to the senior-engineer dev flow. Drives one code change through SCOPE → BUILD → VERIFY → REVIEW → SHIP, stopping at human gates and handing each step to the best existing tool. Use when starting a coding task or when the user wants to work "the spine." Say /lets-hack, or /lets-hack <verb> to jump to a step (scope | build | verify | review | ship).
---

# Let's Hack (/lets-hack)

The front door to senior-engineer mode. Drive one code change through the five moves, in order.
You don't reinvent tools here — each verb hands off to the best one that already exists. Stop at
every human gate; do exactly what was asked, nothing more.

If the user names a verb (`/lets-hack review`), jump straight to that step. Otherwise start at SCOPE.

## SCOPE — understand before editing
- Enter plan mode. Send an `Explore` scout to find the real entry path and an existing pattern to reuse.
- Decide the SMALLEST change; name the file(s) you'll touch and why. Batch any clarifying questions now.
- **Gate:** present the plan (ExitPlanMode) and get sign-off before editing.

## BUILD — the smallest correct change
- Isolate risky or parallel work in a worktree (`/worktree`).
- Keep the diff small and focused; match existing conventions; add nothing that wasn't asked.
- The block-suppressions guard is live — fix real type/lint errors, don't reach for `any` / `@ts-ignore`.

## VERIFY — prove it through the real path
- Run it through the actual route / button / endpoint / job — not just a helper. Use `/verify` or `/run`.
- When the UI looks wrong, check the data/response shape first. Show the command + output as evidence.

## REVIEW — fresh eyes that didn't write it
- Hand the diff to the `skeptic` subagent (or `/code-review`). Ask for correctness / requirement gaps only.
- Triage: fix the real findings, skip the style nitpicks. Don't gold-plate.

## SHIP — gate it, hand it off clean
- Commit only after checks are green (the verify-before-done guard enforces this on a "done" claim).
- Open the PR; clean up the branch/worktree as part of merging.
- End with the honest report: **what changed, why it's safe, what you verified, what's still risky,
  what you did NOT touch.** Decisions about people, data, or money go to a human — don't auto-act.

## Notes
- The rules (`~/.claude/senior-engineer-mode/rules/AGENTS.md`) already load every session; this skill
  is the *active* walkthrough for when you want to drive the flow deliberately, step by step.
- Full SOP: `~/.claude/senior-engineer-mode/THE-SPINE.md`.
