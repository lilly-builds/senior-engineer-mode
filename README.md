# Senior Engineer Mode

**Make your AI coding agent work like a senior engineer, not a lazy, hallucinating junior.**

It gives your agents a system for being thorough — scope → build → verify → review → ship — that
results in higher-quality builds. And it puts up real boundaries: automatic hooks that stop two
things cold — errors swept under the rug, and "done" when it isn't. Built so you can drop your
vision, then let the agents rip and run.

---

## What is this? (in plain words)

When you ask an AI to write code, it tends to *rush*. It makes big messy changes, sweeps errors
under the rug so it can look finished, and says **"done!"** when it actually isn't.

Senior Engineer Mode is a small set of rules and a couple of **automatic guardrails** that make
your AI slow down and work the way a careful senior engineer would.

The best part: **you don't have to remember anything.** Once it's set up, it just happens in the
background.

---

## See it work

Watch a guardrail catch the AI in the act. If it tries to sweep an error under the rug — here,
slapping `as any` on a TypeScript line to silence the type checker — the edit is **stopped before it
lands**:

```
BLOCKED by senior-engineer-mode: this edit hides an error instead of fixing it.
File: src/foo.ts
Offending line(s):
  1:const x = data as any;

Fix the underlying type/lint error. If a suppression is genuinely unavoidable,
justify it on the same line, e.g.:   // senior-mode: allow — <why this is safe>
```

That's the whole idea: the important rules don't just sit in a document the AI can forget — a couple
of them are *enforced automatically*.

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

**Three hooks that run by themselves** — two that *enforce*, one that *reminds*:

- 🛑 **No hiding errors** *(enforced).* If your AI tries to sweep a type/lint problem under the rug
  — `as any`, `@ts-ignore`, `eslint-disable`, `# type: ignore`, and friends — to look finished, the
  edit is blocked and it has to fix the real thing. This guard looks at the *file being edited*, so
  it works in any project, but only ever on real code files (never your notes or markdown).

- ✅ **No fake "done"** *(enforced — JS/TS projects).* When your AI claims it's finished, your
  project's checks (typecheck + lint) have to *actually pass* first. If they don't, it keeps working.
  Today this gate runs on JavaScript/TypeScript projects only — it needs `package.json` + npm.

- 📋 **The five-step reminder** *(advisory).* Every time you start coding in a project, your AI gets
  a short reminder of the spine at the top of the chat, so the good habits stay in front of it. This
  one only nudges — it doesn't block anything.

**Four spoken commands** (say these any time):

- `/lets-hack` — run the whole flow on a task
- `/scope` · `/build` · `/ship` — do just one step

For the **REVIEW** step, hand the change to fresh eyes that didn't write it: the bundled **`skeptic`**
reviewer agent, or Claude Code's built-in **`/code-review`**. (The **VERIFY** step is the "No fake
done" gate above — it runs automatically.)

---

## Requirements

- **macOS or Linux.** Windows is not supported.
- **`bash`**, **`git`**, and **`jq`** on your PATH — `jq` does the JSON parsing every guardrail relies on.
- **`node` + `npm`** — only for the "No fake done" check, and only in JS/TS projects.

> **Heads up — the guardrails fail _open_.** If `jq` isn't installed, the hooks quietly do
> **nothing** (they let everything through rather than break your session). So if it ever feels like
> nothing's happening, check `jq` first: run `command -v jq`. No output means it's missing.

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

It stays out of your non-coding work: the five-step reminder and the "No fake done" gate only engage
inside a code project, and the error-hiding guard only inspects edits to actual code files — so your
writing, notes, and markdown are never touched.

To change it for one project, add a file named **`.senior-mode.json`** at that project's root (see
[`.senior-mode.json.example`](.senior-mode.json.example) for the full shape):

```json
{ "enabled": false }
```

- `{ "enabled": false }` — turn it completely off for this project
- `{ "block_on_tests": true }` — also run your tests (not just type/lint checks) when you say "done"

---

## Uninstall

Changed your mind? From this folder, run:

```
bash uninstall.sh
```

It reverses the install **surgically**: it removes only senior-mode's own three hooks from your
`~/.claude/settings.json` (backing the file up first), deletes the one
`@senior-engineer-mode/rules/AGENTS.md` line it added to your `~/.claude/CLAUDE.md`, removes the
command/agent links, and deletes the pack folder. Every other setting, hook, and skill you have is
left exactly as it was.

---

## Run the tests (optional)

Want the guardrails proven before you trust them? From this folder:

```
bash tests/run.sh
```

It feeds sample edits and "done" messages through the hooks and checks each one blocks or passes
exactly as it should — and exits non-zero if anything is off.

---

## Why it works (the one idea behind it)

Rules written in a document get **ignored** the moment things get busy — that's just how AI memory
works. Guardrails that run *automatically* don't get ignored. So Senior Engineer Mode puts the
important stuff on autopilot, and leaves you with one simple five-word habit:

**look → change a little → prove it → double-check → hand off clean.**

---

*MIT licensed. Built by [Lilly Field](https://github.com/lilly-builds).*
