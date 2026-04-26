#!/usr/bin/env bash
# Syntax-check every Swift file in the project tree.
# Usage: bash mini-me/scripts/typecheck-all.sh [search-root]
# Falls back to App/ + Widget/ when no argument given.
set -euo pipefail

ROOT="${1:-$(dirname "$0")/..}"
FILES=$(find "$ROOT/App" "$ROOT/Widget" -name "*.swift" 2>/dev/null)

if [[ -z "$FILES" ]]; then
    echo "No Swift files found under $ROOT/App or $ROOT/Widget" >&2
    exit 1
fi

ERRORS=0
while IFS= read -r f; do
    RESULT=$(swiftc -parse "$f" 2>&1)
    if [[ -n "$RESULT" ]]; then
        echo "❌  $f"
        echo "$RESULT"
        ((ERRORS++))
    fi
done <<< "$FILES"

COUNT=$(echo "$FILES" | wc -l | tr -d ' ')
if [[ $ERRORS -eq 0 ]]; then
    echo "✅  $COUNT files — all clean"
else
    echo "❌  $ERRORS / $COUNT files have syntax errors"
    exit 1
fi
