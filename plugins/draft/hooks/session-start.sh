#!/bin/bash
# At the start of a session, after /clear and after a compaction: print the note beside this script.
cat > /dev/null
cat "$(dirname "$0")/session-start.md"
exit 0
