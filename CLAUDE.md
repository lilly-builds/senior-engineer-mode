# Senior Engineer Mode — setup instructions for the AI assistant

**You are the AI assistant, and the user has opened this repo and asked you to set up "Senior
Engineer Mode" for them.** The user is probably not a developer. Do the steps below carefully,
explain each one in *one plain sentence* as you go, and confirm at the end.

> **Be safe: never overwrite the user's existing config. Always merge or append. Make a backup
> first.** If a step is ambiguous or could lose the user's data, stop and ask.

If the user is just browsing and did **not** ask you to install, don't run these steps — ask what
they'd like to do.

## What you're installing
A senior-engineering workflow for coding: a small rules file, three automatic guardrail "hooks", a
"skeptic" reviewer agent, and five `/` commands organized around a 5-verb spine
(**SCOPE → BUILD → VERIFY → REVIEW → SHIP**). Background is in `README.md` and `THE-SPINE.md` here.

## Before you start
1. This repo folder is the **source**. Note its absolute path — call it `REPO` (run `pwd`).
2. The install **target** is the user's Claude Code config folder: `~/.claude` (expand `~` to the
   real home path).
3. **Check for `jq`** (run `command -v jq`). The guardrails parse JSON with `jq`; without it they
   **fail open and silently do nothing**. If it's missing, warn the user plainly and tell them to
   install it (`brew install jq` on macOS, or their package manager on Linux) for the guardrails to
   actually work. You can still finish the install, but say it won't enforce until `jq` is present.
4. **Back up** settings: if `~/.claude/settings.json` exists, copy it to `~/.claude/settings.json.bak`
   and tell the user.
5. If `~/.claude/senior-engineer-mode/` already exists, tell the user it's already installed and ask
   whether to update or stop.

## Steps

### 1 · Put the pack where Claude Code can find it
- Copy from `REPO` into `~/.claude/senior-engineer-mode/`: `THE-SPINE.md`, `rules/`, `hooks/`,
  `agents/`, `skills/`, and `uninstall.sh` (so the user can cleanly reverse this later).
- Make the guardrail scripts runnable: `chmod +x ~/.claude/senior-engineer-mode/hooks/*.sh`

### 2 · Load the rules in every session
- If `~/.claude/CLAUDE.md` does **not** exist, create it with exactly:
  ```
  # Global instructions

  Operate in Senior Engineer Mode. Work code changes through the spine:
  SCOPE → BUILD → VERIFY → REVIEW → SHIP.

  @senior-engineer-mode/rules/AGENTS.md
  ```
- If it **does** exist, append the single line `@senior-engineer-mode/rules/AGENTS.md` on its own
  line. Do **not** rewrite the rest of the file.

### 3 · Turn on the guardrails (hooks) — MERGE, don't overwrite
- Open `REPO/install/settings.snippet.json`; it has a `hooks` object with three events
  (`SessionStart`, `PreToolUse`, `Stop`).
- Open `~/.claude/settings.json` (if missing, treat it as `{}`).
- **Merge** those three events into the file's `hooks` object: keep every existing setting and every
  hook the user already has. In each command path, replace `$HOME` with the user's real absolute home
  path (e.g. `/Users/<name>`), so the path is concrete.
- Write the whole merged object back. Confirm it's still valid JSON.

### 4 · Register the commands and the reviewer
- Make `~/.claude/agents/` if needed. Then symlink (preferred) or copy:
  - `~/.claude/senior-engineer-mode/agents/skeptic.md` → `~/.claude/agents/skeptic.md`
  - each folder under `~/.claude/senior-engineer-mode/skills/` (`lets-hack`, `scope`, `build`,
    `ship`) → `~/.claude/skills/<name>`

### 5 · Verify it actually works (do not skip)
- Confirm the suppression guard blocks a bad edit:
  ```
  printf '%s' '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/x.ts","new_string":"const x = y as any;"}}' \
    | ~/.claude/senior-engineer-mode/hooks/block-suppressions.sh; echo "exit=$?"
  ```
  Expect `exit=2` (blocked). If you get `exit=0`, recheck the path and `chmod`.
- Confirm `~/.claude/settings.json` is still valid JSON and still has the user's original keys.

### 6 · Tell the user, in plain words
- It's installed. They should **start a brand-new chat** in a coding project to see it (the guardrails
  load when a session starts).
- Run the whole flow on a task with **`/lets-hack`**, or one step with `/scope` `/build` `/ship`.
  (For REVIEW, use the `skeptic` agent or the built-in `/code-review`; VERIFY is the automatic
  "done" gate.)
- To turn it off in a project, add a file `.senior-mode.json` containing `{ "enabled": false }`.
- To uninstall later, run `bash ~/.claude/senior-engineer-mode/uninstall.sh` — it surgically removes
  only senior-mode's hooks, lines, links, and folder, backing up `settings.json` first.

## Your safety rules as the installer
- **Never** overwrite `settings.json` or `CLAUDE.md` — merge or append.
- Make the backup (step "Before you start") first.
- The guardrails only act in real code projects; they stay silent during writing/notes work.
- If unsure, stop and ask before changing system files.
