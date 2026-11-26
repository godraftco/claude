#!/bin/bash
# Before each message: ask Draft's brain which records the message may be about, and print at most five titles.
#
# Silent, exit 0, whenever anything is missing or wrong: switched off (DRAFT_CONTEXT=off), no key, not a Mac, no
# network, a slow or failed reply, a short message, a slash command, a message that looks like it holds a secret.
# The key comes from the macOS Keychain only (service draft-brain, account $USER), looked up under a half-second
# watchdog so a Keychain dialog can't hold the message up. It reaches curl on stdin (--config -), never on a command
# line, and is never printed or logged. curl runs with -q, so no curlrc of the person's is read. The message goes
# in a POST body, never in the URL, and only its first 500 characters.
# bash 3.2 and stock macOS tools only: curl, security, perl and osascript (JavaScript). No jq, no python.

exec 2>/dev/null
[ "${DRAFT_CONTEXT:-}" = "off" ] && exit 0
URL="https://brain.draft.finance/api/v1/context"
HERE="$(cd "$(dirname "$0")" && pwd)" || exit 0
JS="$HERE/context.js"

[ "$(uname -s)" = "Darwin" ] || exit 0
command -v curl >/dev/null || exit 0
command -v osascript >/dev/null || exit 0
command -v perl >/dev/null || exit 0
[ -f "$JS" ] || exit 0

# The key first: without one, the message is never read. perl runs security as a child and reads its output; if
# nothing comes back within half a second it kills the child and prints nothing.
KEY="$(perl -MTime::HiRes=alarm -e '
  my $pid = open(my $fh, "-|", @ARGV) or exit 1;
  $SIG{ALRM} = sub { kill 9, $pid; exit 1 };
  alarm 0.5;
  local $/; my $out = <$fh>;
  alarm 0;
  print $out if defined $out;
' security find-generic-password -s draft-brain -a "$USER" -w)"
[ -n "$KEY" ] || exit 0
case "$KEY" in *[!A-Za-z0-9_.-]*) exit 0 ;; esac

TMP="$(mktemp -d "${TMPDIR:-/tmp}/draft-context.XXXXXX")" || exit 0
trap 'rm -rf "$TMP"' EXIT
chmod 700 "$TMP"

# The hook's input is JSON on stdin; the prompt is one field of it. The script writes the request body, or
# nothing when the prompt is too short, a slash command, not there, or looks like it holds a secret.
cat > "$TMP/in.json"
osascript -l JavaScript "$JS" prompt "$TMP/in.json" > "$TMP/body.json" || exit 0
[ -s "$TMP/body.json" ] || exit 0
[ "$(cat "$TMP/body.json")" != "" ] || exit 0

CODE="$(printf 'header = "Authorization: Bearer %s"\n' "$KEY" | curl -q --config - -s -X POST \
  --proto '=https' --connect-timeout 0.5 --max-time 1 \
  -H 'Content-Type: application/json' --data-binary "@$TMP/body.json" \
  -o "$TMP/out.json" -w '%{http_code}' "$URL")"
KEY=""
[ "$CODE" = "200" ] || exit 0

OUT="$(osascript -l JavaScript "$JS" format "$TMP/out.json")" || exit 0
[ -n "$OUT" ] && printf '%s\n' "$OUT"
exit 0
