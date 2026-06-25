# Senior Engineer Mode

**Make your AI coding assistant act like a careful senior engineer — instead of a fast, sloppy junior.**

---

## What is this? (in plain words)

When you ask an AI to write code, it tends to *rush*. It makes big messy changes, sweeps errors
under the rug so it can look finished, and says **"done!"** when it actually isn't.

Senior Engineer Mode is a small set of rules and a couple of **automatic guardrails** that make
your AI slow down and work the way a careful senior engineer would.

The best part: **you don't have to remember anything.** Once it's set up, it just happens in the
background.

---

## The five steps (the "spine")

Every code change goes through five moves, in order:

1. **SCOPE** — look before you leap. Understand the code *first*.
2. **BUILD** — make the *smallest* change that works. No giant rewrites.
3. **VERIFY** — actually run it and prove it works. No "looks done."
4. **REVIEW** — a second set of eyes checks the change.
5. **SHIP** — only finish when it truly passes, and explain what changed.

Easy way to remember it: **look → change a little → prove it → double-check → hand off clean.**

---

## What you actually get

**Two automatic guardrails** (these run by themselves — you do nothing):

- 🛑 **No hiding errors.** If your AI tries to sweep a problem under the rug to look done, it gets
  stopped and has to fix the real thing.

- ✅ **No fake "done."** When your AI says it's finished, the code's checks have to *actually pass*
  first. If they don't, it keeps working until they do.

**Five spoken commands** (say these any time):

- `/lets-hack` — run the whole flow on a task
- `/scope` · `/build` · `/verify` · `/review` · `/ship` — do just one step

And every time you start coding, your AI gets a little reminder of the five steps at the top of the
chat — so the good habits are always in front of it.

---

## Install it — the easy way

You don't need to know how any of this works. Just:

1. **Download this folder** (green "Code" button → Download ZIP, then unzip it).
2. **Open the folder in Claude Code.**
3. **Type this and hit enter:**

   > Read CLAUDE.md and set this up for me.

That's it. Your AI reads the instructions, installs everything safely, and tells you when it's done.
Then open a fresh chat in any coding project and you'll see the five steps appear. 🎉

---

## Install it — by hand (only if you like tinkering)

1. Copy this folder to `~/.claude/senior-engineer-mode/`.
2. Make the guardrail scripts runnable: `chmod +x ~/.claude/senior-engineer-mode/hooks/*.sh`
3. Add this line to your `~/.claude/CLAUDE.md` (create the file if it isn't there):
   `@senior-engineer-mode/rules/AGENTS.md`
4. Merge the `hooks` block from [`install/settings.snippet.json`](install/settings.snippet.json)
   into your `~/.claude/settings.json` (don't replace the file — just add the `hooks` part).
5. Link the commands and reviewer so Claude Code can find them:
   - `agents/skeptic.md` → `~/.claude/agents/`
   - `skills/lets-hack`, `skills/scope`, `skills/build`, `skills/ship` → `~/.claude/skills/`

(Honestly, just let the AI do it. See above.)

---

## Turn it off or tune it

It only ever runs in real coding projects — never on your writing, notes, or other work.

To change it for one project, add a file named **`.senior-mode.json`** in that project:

```json
{ "enabled": false }
```

- `{ "enabled": false }` — turn it completely off for this project
- `{ "block_on_tests": true }` — also run your tests (not just type/lint checks) when you say "done"

---

## Why it works (the one idea behind it)

Rules written in a document get **ignored** the moment things get busy — that's just how AI memory
works. Guardrails that run *automatically* don't get ignored. So Senior Engineer Mode puts the
important stuff on autopilot, and leaves you with one simple five-word habit:

**look → change a little → prove it → double-check → hand off clean.**

---

*MIT licensed. Built by [Lilly Field](https://github.com/lilly-builds).*
