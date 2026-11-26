---
name: today
description: "What the person owes, today's meetings, the next fortnight and what waits for their yes, from Draft's brain."
disable-model-invocation: true
---

Call the brain's `today` once. If it carries `behind.says`, say that first, in one sentence.

Then give the person a short page, skipping any empty section:

- **Overdue**, oldest first.
- **You owe**, with due dates.
- **Meetings today**, with times.
- **Coming up** in the next fortnight.
- **Waiting for your yes**: proposals they decide, best-sourced first.
- **Changed in your areas** by someone else.

One line per item, each with its record id. Where a list shows a total larger than what's listed, say how many more there are. Don't fetch every record; fetch one only if the person asks about it.

If `$ARGUMENTS` names a date, pass it as `since` and list only what changed after it.

End with at most one line on what looks most urgent, and why.
