---
name: remember
description: "Propose a fact for Draft's brain, with its source, after checking it's worth keeping and showing a preview."
argument-hint: "<the fact, and how you know it>"
disable-model-invocation: true
---

The person wants Draft's brain to remember: $ARGUMENTS

Use the draft-remember skill.

1. **Test it.** Check the four-part test. If it fails, say which part and why in one line, and stop unless the person insists.
2. **Search first.** If a record already says it, show that record and stop. If a record says something different, this is a correction: use draft-corrections instead.
3. **Find the source.** Ask how they know, if they haven't said: a meeting, an email, a document, or they were told. Use `person` as the source kind when they told you, with their words as the quote.
4. **Pick the action** from draft-remember's table. A plain fact is `capture_fact`. Mark anything you concluded rather than heard with `basis: "inferred"`. Link the records it's about.
5. **Preview.** Call it without `confirm` and show the person what it would write, in plain words, with any breaches.
6. **Confirm.** Only after they say yes, send exactly the same parameters with the `confirm` token.

Then tell them who it goes to: a proposed fact waits for the owner of its area to say yes, and shows in their `today`.

If the action isn't in the brain's tool list for this person, say it isn't built yet, and stop.
