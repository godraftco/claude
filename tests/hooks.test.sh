#!/bin/bash
# Tests for hooks.json's write guard and the two small hooks. Matchers are JavaScript regular expressions in
# Claude Code, so they are tested with JavaScript (osascript). Run: bash tests/hooks.test.sh (a Mac).

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
H="$ROOT/plugins/draft/hooks"
FAILS=0; PASSES=0
ok()   { PASSES=$((PASSES + 1)); printf 'ok    %s\n' "$1"; }
fail() { FAILS=$((FAILS + 1)); printf 'FAIL  %s\n' "$1"; [ -n "$2" ] && printf '      %s\n' "$2"; }

B=mcp__plugin_draft_brain__
O=mcp__plugin_draft_draft-os__
# Must ask: every write either connector has or may gain, a tool nobody has listed yet, and names that only start like a read.
WRITES="${B}record_meeting ${B}add_action ${B}close_action ${B}move_date ${B}add_note ${B}add_timeline_entry
${B}update_provider_state ${B}capture_unfiled ${B}capture_fact ${B}correct ${B}affirm ${B}propose_decision
${B}propose_correction ${B}propose_merge ${B}propose_person ${B}a_tool_added_later
${O}add_note ${O}soul_propose ${O}draft_memo ${O}draft_ask ${O}run_node ${O}ask_agent ${O}task_step ${O}a_tool_added_later ${B}searchx ${B}fetch_all"
# Must not ask: the reads.
READS="${B}search ${B}context ${B}fetch ${B}related ${B}connection ${B}today ${B}now ${B}primer
${O}me ${O}search ${O}list_brands ${O}get_brand ${O}brand_timeline ${O}tasks ${O}sql_query ${O}lake_query ${O}soul_read"
# Must not match at all: other servers and other tools.
OTHERS="mcp__brain__record_meeting mcp__plugin_other_brain__add_note Bash Write"

RESULT="$(/usr/bin/osascript -l JavaScript - "$H/hooks.json" "$WRITES" "$READS" "$OTHERS" <<'EOF'
ObjC.import("Foundation");
function run(a) {
  var cfg = JSON.parse($.NSString.stringWithContentsOfFileEncodingError(a[0], 4, null).js);
  var guards = cfg.hooks.PreToolUse.filter(function (g) {
    return g.hooks.some(function (h) { return /confirm-write\.sh/.test(h.command); });
  }).map(function (g) { return new RegExp(g.matcher); });
  function asks(name) { return guards.some(function (re) { return re.test(name); }); }
  var out = [];
  a[1].split(/\s+/).filter(String).forEach(function (n) { out.push((asks(n) ? "ok" : "FAIL") + " write asks: " + n); });
  a[2].split(/\s+/).filter(String).forEach(function (n) { out.push((asks(n) ? "FAIL" : "ok") + " read passes: " + n); });
  a[3].split(/\s+/).filter(String).forEach(function (n) { out.push((asks(n) ? "FAIL" : "ok") + " not ours: " + n); });
  return out.join("\n");
}
EOF
)"
while IFS= read -r line; do
  case "$line" in ok\ *) ok "${line#ok }" ;; *) fail "${line#FAIL }" ;; esac
done <<< "$RESULT"
[ -n "$RESULT" ] || fail "matchers could not be read from hooks.json"

OUT="$(printf '{"tool_name":"x"}' | bash "$H/confirm-write.sh")"
DEC="$(/usr/bin/osascript -l JavaScript -e 'function run(a){var o=JSON.parse(a[0]).hookSpecificOutput;return o.hookEventName+" "+o.permissionDecision+" "+(o.permissionDecisionReason?"reason":"")}' "$OUT")"
if [ "$DEC" = "PreToolUse ask reason" ]; then ok "confirm-write answers ask, with a reason"; else fail "confirm-write answers ask, with a reason" "got: $DEC"; fi

if [ "$(printf '{}' | bash "$H/session-start.sh")" = "$(cat "$H/session-start.md")" ]; then ok "session-start prints the note"; else fail "session-start prints the note"; fi

printf '\n%s passed, %s failed\n' "$PASSES" "$FAILS"
[ "$FAILS" = 0 ]
