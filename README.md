# Draft for Claude Code

Draft's shared context in Claude Code: Draft OS and the company brain, a short brief at the start of each session, and a skill that says which connector answers what. This repository holds wiring and how-to only. Every fact sits behind each person's own sign-in.

## Install

In Claude Code:

```
/plugin marketplace add godraftco/claude
/plugin install draft@draft
```

Then turn on auto-update for the `draft` marketplace under `/plugin` → Marketplaces, and run `/mcp` to sign in to `draft-os` and `brain` with your Draft Google account.

## What's in it

- `plugins/draft/.mcp.json`: the two connectors, admin.draft.finance/mcp and brain.draft.finance/mcp.
- `plugins/draft/hooks/`: a session-start note that tells Claude the connectors are there and to check what's open when you start on Draft work.
- `plugins/draft/skills/draft-context/`: which connector answers what, how to cite, how to write back.
- `plugins/draft/agents/draft-researcher.md`: a subagent for long digs.

Changes reach everyone on their next update, so main takes changes only through a pull request (a ruleset blocks direct pushes, force pushes and deletion), and every change bumps `version` in `plugins/draft/.claude-plugin/plugin.json`, or nobody receives it.
