---
name: setup
description: "Set up the Draft plugin: sign in to both connectors, store a brain key for the per-message hook, check it works, and try three questions."
disable-model-invocation: true
---

Walk the person through setting up the Draft plugin, one step at a time. Wait for each step to work before the next. Keep each message short. Never ask them to paste a key, a password or a code into this chat.

## 1. Sign in to both connectors

Ask them to type `/mcp`, pick `plugin:draft:draft-os`, choose to authenticate and sign in with their Draft Google account in the browser, then do the same for `plugin:draft:brain`. When they're back, call the brain's `today` and Draft OS's `me`. If either asks for a sign-in again, repeat this step.

## 2. A key for the per-message hook (Mac only)

Before each message, a hook asks the brain which records the message may be about and shows Claude up to five titles. It needs the person's own read key, kept in their Mac's Keychain. On Linux or Windows, skip this step: the hook stays silent there.

1. Ask them to open https://brain.draft.finance/agents in their browser and make a new key with read access only, named for this machine (its name in System Settings, General, About), so it can be turned off on its own if the laptop goes missing. One key per machine, never shared. Copy it.
2. Ask them to open the Terminal app (not this chat) and run:

   ```
   security add-generic-password -U -s draft-brain -a "$USER" -w
   ```

   It asks for the password twice: paste the key both times. Nothing shows as they paste, and the key never enters the chat or the shell history.
3. Check it's there without showing it, using your Bash tool:

   ```
   security find-generic-password -s draft-brain -a "$USER" >/dev/null 2>&1 && echo stored || echo missing
   ```

Never run a command with `-w` on the find, and never print the key.

## 3. Check it works

- Call the brain's `today` and give them a three-line summary: what they owe, what's coming up, what waits for their yes. If it carries `behind.says`, say so.
- Ask them to send any message about Draft longer than a few words. If the key is stored, a short list of titles from the brain reaches you with it. Tell them what you saw. If nothing came, check the key is stored and that `curl -q -s -o /dev/null -w '%{http_code}\n' https://brain.draft.finance/api/v1/context` reaches the brain: it prints 401 (no key sent) when it does.

## 4. Three questions of their own

Ask what they'd normally ask a colleague about Draft. If they want a start, offer these and let them pick:

- What do I owe this week, and what's overdue?
- What did we last tell a partner or brand they work with, and when?
- Who have we met at a company they name, and what was agreed?

Answer each from the connectors, with record ids. End by telling them about `/draft:today`, `/draft:prep`, `/draft:record-meeting`, `/draft:remember` and `/draft:wrong`.
