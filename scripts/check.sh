#!/bin/bash
# The check every pull request runs (and anyone can run before pushing): bash scripts/check.sh
# Needs bash, perl and python3. The hook tests need a Mac, so CI runs on macOS.

cd "$(dirname "$0")/.." || exit 1
FAILS=0
ok()   { printf 'ok    %s\n' "$1"; }
bad()  { printf 'FAIL  %s\n' "$1"; FAILS=$((FAILS + 1)); }

PLUGIN=plugins/draft
SESSION_CAP=1200      # characters in the session-start note
SKILL_CAP=4000        # characters in each SKILL.md and agent file
LISTING_CAP=1536      # characters Claude Code shows of a skill's description

# Every file in the repository, tracked or new, except git's own.
FILES="$(git ls-files --cached --others --exclude-standard | sort -u)"

# --- JSON -------------------------------------------------------------------------------------------------------
for f in $(printf '%s\n' "$FILES" | grep '\.json$'); do
  if python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$f" 2>/dev/null; then ok "parses: $f"; else bad "not valid JSON: $f"; fi
done

# --- scripts ----------------------------------------------------------------------------------------------------
for f in $(printf '%s\n' "$FILES" | grep '\.sh$'); do
  if bash -n "$f"; then ok "bash -n: $f"; else bad "bash syntax: $f"; fi
done
if [ -n "$CHECK_STATIC_ONLY" ]; then
  ok "CHECK_STATIC_ONLY: skipped the hook tests"
elif [ "$(uname -s)" = "Darwin" ]; then
  for t in tests/*.test.sh; do
    if bash "$t" > /tmp/hook-test.$$ 2>&1; then ok "$t ($(tail -1 /tmp/hook-test.$$))"
    else cat /tmp/hook-test.$$; bad "$t"; fi
  done
  rm -f /tmp/hook-test.$$
else
  bad "the hook tests need macOS (osascript); run this check on a Mac"
fi

# --- what runs on a laptop, and where it connects -----------------------------------------------------------------
# Every hook is a command that runs a script inside the plugin, and nothing else.
HOOKCMDS="$(python3 - "$PLUGIN" <<'EOF'
import json, os, re, sys
root = sys.argv[1]
cfg = json.load(open(os.path.join(root, "hooks/hooks.json")))
pat = re.compile(r'^bash "\$\{CLAUDE_PLUGIN_ROOT\}/(hooks/[A-Za-z0-9_-]+\.sh)"$')
for event, groups in cfg["hooks"].items():
    for g in groups:
        for h in g["hooks"]:
            m = pat.match(h.get("command", "")) if h.get("type") == "command" else None
            if not m or not os.path.isfile(os.path.join(root, m.group(1))):
                print(f"{event}: {h.get('type')} {h.get('command', '')!r}")
EOF
)"
if [ -z "$HOOKCMDS" ]; then ok "every hook runs a script inside the plugin"; else printf '%s\n' "$HOOKCMDS"; bad "a hook runs something other than a script inside the plugin"; fi

# hooks.json, .mcp.json and every script name no host but the brain and Draft OS.
HOSTS="$(printf '%s\n' "$FILES" | grep -E '(^|/)(hooks\.json|\.mcp\.json)$|\.(sh|js)$' | xargs perl -ne '
  while (/\b((?:[a-z0-9-]+\.)+(?:com|net|org|io|ai|dev|app|co|finance|xyz|me|cloud|so|link|site|info))\b/gi) {
    my $h = lc $1;
    print "$ARGV:$.: $h\n" unless $h =~ /^(brain|admin)\.draft[.]finance$/;
  }
  print "$ARGV:$.: an IP address\n" if /\b\d{1,3}(\.\d{1,3}){3}\b/;
  close ARGV if eof')"
if [ -z "$HOSTS" ]; then ok "hooks, scripts and .mcp.json name only the brain and Draft OS"; else printf '%s\n' "$HOSTS"; bad "a host other than the brain or Draft OS"; fi

# --- no em or en dashes (or their cousins) -----------------------------------------------------------------------
DASHES="$(printf '%s\n' "$FILES" | xargs perl -CSD -ne 'print "$ARGV:$.: $_" if /[\x{2012}-\x{2015}]/; close ARGV if eof' 2>/dev/null)"
if [ -z "$DASHES" ]; then ok "no em or en dashes"; else printf '%s\n' "$DASHES"; bad "em or en dashes found"; fi

# --- sizes ------------------------------------------------------------------------------------------------------
chars() { perl -CSD -0777 -ne 'print length' "$1"; }
n="$(chars "$PLUGIN/hooks/session-start.md")"
if [ "$n" -lt "$SESSION_CAP" ]; then ok "session-start note: $n characters (cap $SESSION_CAP)"; else bad "session-start note is $n characters, over $SESSION_CAP"; fi
for f in $PLUGIN/skills/*/SKILL.md $PLUGIN/agents/*.md; do
  n="$(chars "$f")"
  if [ "$n" -lt "$SKILL_CAP" ]; then ok "$f: $n characters (cap $SKILL_CAP)"; else bad "$f is $n characters, over $SKILL_CAP"; fi
done

# --- skill frontmatter ------------------------------------------------------------------------------------------
for f in $PLUGIN/skills/*/SKILL.md; do
  dir="$(basename "$(dirname "$f")")"
  name="$(perl -ne 'if (/^---/) { $n++; next } print $1 if $n == 1 && /^name:\s*"?([^"\n]+)"?/' "$f")"
  desc="$(perl -CSD -ne 'if (/^---/) { $n++; next } print $1 if $n == 1 && /^description:\s*"?(.*?)"?\s*$/' "$f")"
  if [ "$name" = "$dir" ]; then ok "$dir: name matches its folder"; else bad "$f: name '$name' should be '$dir'"; fi
  dn="$(printf '%s' "$desc" | perl -CSD -0777 -ne 'print length')"
  if [ "$dn" -gt 0 ] && [ "$dn" -le "$LISTING_CAP" ]; then ok "$dir: description $dn characters"; else bad "$f: description missing or over $LISTING_CAP characters"; fi
done

# --- version ----------------------------------------------------------------------------------------------------
VERSION="$(python3 -c 'import json; print(json.load(open("plugins/draft/.claude-plugin/plugin.json"))["version"])')"
if grep -q "^## $VERSION\$" CHANGELOG.md; then ok "CHANGELOG has an entry for $VERSION"; else bad "CHANGELOG.md has no '## $VERSION' entry"; fi
if [ -n "$BASE_REF" ]; then
  OLD="$(git show "origin/$BASE_REF:plugins/draft/.claude-plugin/plugin.json" 2>/dev/null | python3 -c 'import json,sys; print(json.load(sys.stdin)["version"])' 2>/dev/null)"
  if [ -n "$OLD" ] && [ "$OLD" = "$VERSION" ]; then bad "version is still $OLD, as on $BASE_REF: bump it or nobody gets this change"
  else ok "version $VERSION differs from $BASE_REF (${OLD:-none})"; fi
fi

# --- no company facts -------------------------------------------------------------------------------------------
SCAN="$(printf '%s\n' "$FILES" | grep -v -x -e scripts/deny-patterns.txt -e scripts/allowed-urls.txt)"
HITS="$(printf '%s\n' "$SCAN" | xargs perl -CSD -e '
  open(my $p, "<:encoding(UTF-8)", "scripts/deny-patterns.txt") or die;
  my @pats = grep { length && !/^#/ } map { chomp; s/\s+$//r } <$p>;
  open(my $u, "<:encoding(UTF-8)", "scripts/allowed-urls.txt") or die;
  my @urls = grep { length && !/^#/ } map { chomp; s/\s+$//r } <$u>;
  for my $f (@ARGV) {
    open(my $fh, "<:encoding(UTF-8)", $f) or next;
    while (my $line = <$fh>) {
      for my $re (@pats) { print "$f:$.: matches /$re/\n" if $line =~ /$re/ }
      my $rest = $line;
      # An allowed address counts only where it ends: at the end of the line, a space, a quote, a bracket, a
      # comma or a full stop that ends a sentence. Anything longer is a different address.
      for my $url (@urls) { $rest =~ s/\Q$url\E(?=$|[\s"\x27\x60<>()\[\],;]|\.(?:\s|$))//g }
      print "$f:$.: an address not in allowed-urls.txt\n" if $rest =~ m{https?:/{2}|draft[.]finance};
    }
  }')"
if [ -z "$HITS" ]; then ok "no company facts, keys, addresses or other URLs"; else printf '%s\n' "$HITS"; bad "deny-list or URL matches"; fi

# How Draft words its product is a company fact, so the money-copy skill only points at the brain: short, it names
# the brain search, and it carries no rules (no numbered or bulleted list, no quoted example copy).
MC="$PLUGIN/skills/draft-money-copy/SKILL.md"
MCBAD="$(perl -CSD -0777 -ne '
  my ($body) = /\A---\n.*?\n---\n(.*)\z/s; $body //= $_;
  print "over 1200 characters\n" if length($body) > 1200;
  print "does not send the model to the brain for the money copy rules\n" unless /money copy rules/;
  print "has a list of rules\n" if $body =~ /^\s*(\d+\.|[-*])\s/m;
  print "quotes example copy\n" if $body =~ /"(?!money copy rules")[^"\n]{3,}"/;
' "$MC")"
if [ -z "$MCBAD" ]; then ok "draft-money-copy points at the brain and holds no rules"
else printf '%s\n' "$MCBAD"; bad "draft-money-copy must only point at the brain's money copy rules"; fi

# --- Claude Code's own validator, where it's installed ----------------------------------------------------------
if [ -n "$CHECK_STATIC_ONLY" ]; then
  ok "CHECK_STATIC_ONLY: skipped claude plugin validate"
elif command -v claude >/dev/null 2>&1; then
  for target in . "$PLUGIN"; do
    if out="$(claude plugin validate --strict "$target" 2>&1)"; then ok "claude plugin validate --strict $target"
    else printf '%s\n' "$out"; bad "claude plugin validate --strict $target"; fi
  done
else
  ok "claude not installed here: skipped claude plugin validate"
fi

echo
if [ "$FAILS" = 0 ]; then echo "All checks passed."; else echo "$FAILS check(s) failed."; exit 1; fi
