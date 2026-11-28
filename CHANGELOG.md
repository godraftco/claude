# Changelog

## 0.3.0

- `/draft:post-meeting`: post one of your own Wispr meetings to the team's meetings channel as the Draft Meetings bot, in the house shape, with the summary and transcript in its thread and your name on it, then record it in the brain. It reads the meeting through your own Wispr connector and posts through the brain's `post_meeting` tool, which checks the post, shows you a preview and posts only on your yes. Before any post, Claude Code asks you, as for every other write.

## 0.2.0

- Before each message, a hook shows Claude up to five titles from the brain that may bear on it, using your own key from the Keychain. The message goes in a request body, the key on curl's stdin. Silent when it can't help.
- Before any write through either connector, Claude Code asks you, whatever your allow-list says.
- The `draft-researcher` agent reads through the connectors only: no files, no shell.
- The session-start note also runs after a compaction, and says to call `today` and to say when the brain is behind.
- Commands: `/draft:setup`, `/draft:today`, `/draft:prep`, `/draft:record-meeting`, `/draft:remember`, `/draft:wrong`.
- Skills: `draft-context` rewritten; new `draft-remember`, `draft-corrections`, `draft-money-copy` and `draft-writing`.
- A check on every pull request: JSON, hook tests, no dashes, size caps, and no company facts.
- The per-message hook looks the key up first (Keychain only, under a half-second watchdog) and reads nothing without one, never sends a message that looks like it holds a secret, ignores your curlrc, turns hidden and tag characters, angle brackets and backticks in titles into spaces, and switches off with `DRAFT_CONTEXT=off`. `draft-money-copy` now fetches the rules from the brain instead of carrying them. The check matches allowed addresses exactly and pins `actions/checkout` to a commit.

## 0.1.0

- The two connectors, Draft OS and the brain.
- A session-start note, the `draft-context` skill and the `draft-researcher` agent.
