#!/bin/bash
# Before any tool call that can write through either Draft connector: ask the person, whatever their allow-list
# says. hooks.json picks the calls (every brain or Draft OS tool that isn't a known read); this only answers "ask".
cat > /dev/null
printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"This writes to Draft (the brain or Draft OS). Allow it only if Claude has shown you what it will write.","additionalContext":"This call writes to Draft. Before the person allows it, show them exactly what it will write."}}'
exit 0
