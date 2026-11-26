---
name: wrong
description: "Tell Claude it got something about Draft wrong: it finds the brain record that misled it and proposes a correction."
argument-hint: "<what was wrong, and what's right>"
disable-model-invocation: true
---

The person says something Claude said about Draft is wrong: $ARGUMENTS

Use the draft-corrections skill.

1. If they haven't said what is right, or how they know, ask. One question.
2. Find the record that said the wrong thing: the ids you cited, fetched again, or a `search` for the claim.
3. If no record said it, or you misread one, say it was your mistake, give the right answer with its citation, and write nothing.
4. If the record was true once and has changed since, record the change instead (draft-remember).
5. Otherwise call `propose_correction` against that record, without `confirm`: what was wrong, what is right, why, and the person as the source. Show them the preview.
6. Only after they say yes, send the same parameters with the `confirm` token.

Tell them the record's owner decides, and that it will show in the owner's `today`.
