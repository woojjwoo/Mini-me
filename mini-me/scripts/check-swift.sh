#!/usr/bin/env bash
# PostToolUse hook: syntax-checks a Swift file immediately after Edit/Write.
# Receives Claude Code tool event as JSON on stdin.
set -euo pipefail

INPUT=$(cat)

FILE=$(python3 -c "
import sys, json
try:
    d = json.loads(sys.stdin.read())
    ti = d.get('tool_input', {})
    print(ti.get('file_path', ''))
except Exception:
    print('')
" <<< "$INPUT" 2>/dev/null)

[[ "$FILE" == *.swift && -f "$FILE" ]] || exit 0

echo "⚡ Swift syntax: $(basename "$FILE")"
if swiftc -parse "$FILE" 2>&1; then
    echo "✅ Syntax OK"
else
    echo "❌ Syntax errors — fix before proceeding"
    exit 1
fi
