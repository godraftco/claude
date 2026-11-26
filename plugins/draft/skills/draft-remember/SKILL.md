---
name: draft-remember
description: "Use when something from this session might belong in Draft's brain: the person says remember this, note this, log this or record this; a meeting or call just happened; someone committed to a task or a date; a decision was made; a partner, provider or brand told us something; or the person asks what is worth keeping. Says what passes the bar, which brain action fits, and how the preview and confirm work. Not for the person's own notes or to-dos."
---

# What goes in Draft's brain

The brain is the company's memory, shared by everyone at Draft. Only write what a teammate would be glad to find there.

## The test: all four must hold

1. Someone else will need it, or you will in a later session.
2. It can't be read from a live system (Draft OS, GitHub, the code, a provider) when it's needed.
3. It stays true for more than about a week, or it's a dated event others will ask about.
4. Someone said, decided, agreed or did it. Your own conclusion is marked as one.

**In:** decisions and why; who owes what by when; what a provider, partner or brand told us and when; who a person is and how we know them; agreed terms; corrections; a lesson that has bitten twice.

**Out:** live numbers and states; the session's narration and dead ends; what the code shows; drafts; anything already in a record (link to it instead); secrets; short-lived instructions.

## Which action fits

| What happened | Action |
|---|---|
| A meeting or call | `record_meeting`, once per meeting |
| Someone committed to a task or a date | `add_action`, owner only if the source names them |
| A task was done, or a date moved | `close_action`, `move_date` |
| A decision someone made | `propose_decision`, naming who decides. Never call it decided |
| Something happened with a person, company, brand or workstream | `add_timeline_entry` |
| A fact, with where it came from | `capture_fact` |
| A record is wrong | `propose_correction` (see draft-corrections) |

Use only the tools the brain lists for you. If the one that fits isn't there, tell the person it isn't built yet and stop. Your own inference goes in with `basis: "inferred"`. Every write names its source, with a quote where there is one.

## One fact, one home

Search first. If a record already holds it, link to that record (`about`, `came_from`, `derived_from`) instead of saying it again. Five summaries of one meeting are still one source.

## Never

Secrets, keys or passwords. Bank account or card numbers. An outsider's personal details (home address, personal phone, health, family). If you can't tell whether something is the person's own or the company's, ask them.

## Preview, then confirm

Every write is two calls. Send it once without `confirm`: the brain checks it and returns a preview and a confirm token. Show the person the preview in plain words: what it would write, its trust, any breaches. Only after they say yes, send exactly the same parameters again with `confirm` set to that token. It works once, for ten minutes. Give each write a new `request_id`; resending the same one never writes twice. Offer at most five writes in a session, the best-sourced first.
