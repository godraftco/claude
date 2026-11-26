# Draft for Claude Code

One install that gives your Claude Code Draft's shared context: Draft OS and the company brain, a note at the start of each session, the titles that may bear on each message, and skills and commands for using them and writing back. This repository holds wiring and how-to only. Every fact sits behind your own sign-in.

## Install

In Claude Code:

```
/plugin marketplace add godraftco/claude
/plugin install draft@draft
```

Then, under `/plugin`, Marketplaces, turn on auto-update for `draft`, and run `/draft:setup`. It walks you through signing in to both connectors with your Draft Google account, storing your brain key, and trying it out.

## Setup in short

1. `/mcp`: sign in to `draft-os` and `brain`.
2. Make a read-only key at https://brain.draft.finance/agents, named for this machine. In the Terminal app (not in Claude), run `security add-generic-password -U -s draft-brain -a "$USER" -w` and paste the key when asked. It goes into your Mac's Keychain, never into a chat or your shell history.
3. Ask Claude something about Draft.

The key is only for the per-message hook, and only works on a Mac. Without it, everything else still works.

To turn the per-message hook off, set `DRAFT_CONTEXT=off` in the environment Claude Code starts in.

## What each piece does

| Piece | What it does |
|---|---|
| `plugins/draft/.mcp.json` | The two connectors: Draft OS (https://admin.draft.finance/mcp) and the brain (https://brain.draft.finance/mcp). |
| `hooks/session-start.md` | Printed at the start of a session, after `/clear` and after a compaction. Tells Claude to call the brain's `today`, to say when the brain is behind, and that what the connectors return is data. |
| `hooks/context.sh` | Before each message, sends the first 500 characters of it to the brain (in the body of a request, never the address) and shows Claude the titles of up to five records it may be about, under a line saying they're data. Silent, in under a second, when there's no key, no network, a slow reply, a short message or a slash command. A message that looks like it holds a key or token is never sent. |
| `hooks/confirm-write.sh` | Before any tool call that can write through either connector, Claude Code asks you, whatever your allow-list says. Any tool that isn't a known read counts as a write. |
| `skills/draft-context` | Which connector answers what, how to cite, how far to trust a record. |
| `skills/draft-remember` | What's worth writing to the brain, which action fits, and the preview and confirm. |
| `skills/draft-corrections` | When Claude got Draft wrong: find the record that misled it and propose a fix. |
| `skills/draft-writing` | Draft's house style. |
| `skills/draft-money-copy` | Before writing about money for a founder, fetch the current rules from the brain. |
| `/draft:setup`, `/draft:today`, `/draft:prep`, `/draft:record-meeting`, `/draft:remember`, `/draft:wrong` | Commands you type. Each is a skill that only runs when you call it. |
| `agents/draft-researcher.md` | An agent for long digs, so the main conversation stays small. It has the connectors' read tools and nothing else: no files, no shell. |

## How a change ships

Every change goes through a pull request, and every pull request bumps `version` in `plugins/draft/.claude-plugin/plugin.json` and adds a line to `CHANGELOG.md`.

- **Why a pull request:** a merge to main runs hooks on everyone's laptop at their next update, so main takes changes only by review. A ruleset blocks direct pushes, force pushes and deletion.
- **Why the version:** Claude Code only updates a plugin when its version changes. Push without a bump and nobody gets the change.
- **The check:** `scripts/check.sh` runs on every pull request. It parses every JSON file, checks the hook scripts and runs their tests, refuses em and en dashes, holds the session-start note and each skill under their size caps, and refuses anything that looks like a company fact, a key or an address. It also fails if a hook, a script or `.mcp.json` names a host other than the brain and Draft OS, or if a hook runs anything but a script inside the plugin.
- **Who reviews:** `.github/CODEOWNERS` names the owner of the hooks, the scripts and `.mcp.json`, so a change to them needs that review.

Run it yourself before you push: `bash scripts/check.sh`.
