#!/bin/bash
# Tests for scripts/check.sh's static checks: each runs the check on a copy of this repository with one file
# planted, and expects that file to be refused. Run: bash tests/check.test.sh. CHECK_STATIC_ONLY=1 stops the copy
# running these tests again, and the plugin validator.

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/check-test.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
FAILS=0; PASSES=0
ok()   { PASSES=$((PASSES + 1)); printf 'ok    %s\n' "$1"; }
fail() { FAILS=$((FAILS + 1)); printf 'FAIL  %s\n' "$1"; [ -n "$2" ] && printf '      %s\n' "$2"; }
check() { if eval "$2"; then ok "$1"; else fail "$1" "rc=$RC $(printf '%s\n' "$OUT" | grep '^FAIL' | head -3)"; fi; }

# Addresses built from pieces, so this file passes the very checks it plants against.
HTTPS="https:/""/"; BRAIN="brain.draft"".""finance"; REPO="github"".""com/godraftco/claude"

fresh() { rm -rf "$WORK/repo"; cp -R "$ROOT" "$WORK/repo"; }
plant() { printf '%s\n' "$1" > "$WORK/repo/planted.md"; }
run_check() { OUT="$(cd "$WORK/repo" && CHECK_STATIC_ONLY=1 bash scripts/check.sh 2>&1)"; RC=$?; }

fresh; run_check
check "the repository as it stands passes" '[ "$RC" = 0 ]'

# --- an allowed address with more after it is a different address -------------------------------------------------
fresh; plant "See ${HTTPS}${REPO}-evil for more."; run_check
check "a longer look-alike of an allowed URL fails" '[ "$RC" != 0 ] && printf "%s\n" "$OUT" | grep -q "planted.md:1: an address not in allowed-urls.txt"'
fresh; plant "Keys at ${HTTPS}${BRAIN}/agentsx and ${HTTPS}${BRAIN}/mcp.evil.example"; run_check
check "a URL that only starts like an allowed one fails" '[ "$RC" != 0 ] && printf "%s\n" "$OUT" | grep -q "planted.md:1: an address"'
fresh; plant "Make one at ${HTTPS}${BRAIN}/agents, then see (${HTTPS}${REPO}) and ${HTTPS}${BRAIN}/mcp."; run_check
check "an allowed URL before a comma, a bracket or a full stop passes" '[ "$RC" = 0 ]'

# --- the money-copy skill is a pointer to the brain, never the rules themselves ---------------------------------------
SK="plugins/draft/skills/draft-money-copy/SKILL.md"
fresh; printf '\n## The rules\n\n1. Titles are short.\n2. Show the cost before the commitment.\n' >> "$WORK/repo/$SK"; run_check
check "money-copy skill with a numbered rule list fails" 'printf "%s\n" "$OUT" | grep -q "^FAIL .*draft-money-copy"'
fresh; printf '\nNever write %s or %s to a brand.\n' "factor"" rate" "hold""back" >> "$WORK/repo/$SK"; run_check
check "lending terms fail the fact check" 'printf "%s\n" "$OUT" | grep -q "SKILL.md:[0-9]*: matches"'
fresh; printf -- '---\nname: draft-money-copy\ndescription: "x"\n---\n\nWrite well.\n' > "$WORK/repo/$SK"; run_check
check "money-copy skill that doesn't send the model to the brain fails" 'printf "%s\n" "$OUT" | grep -q "^FAIL .*draft-money-copy"'

# --- a pinned action's commit passes in a workflow's uses line, and nowhere else -------------------------------------
fresh; plant "commit 0123456789abcdef""0123456789abcdef01234567"; run_check
check "a 40-character hex string outside a uses line fails" 'printf "%s\n" "$OUT" | grep -q "planted.md:1: matches"'

printf '\n%s passed, %s failed\n' "$PASSES" "$FAILS"
[ "$FAILS" = 0 ]
