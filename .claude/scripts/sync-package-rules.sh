#!/bin/bash
# sync-package-rules.sh
# Scans sibling package repos for .claude/*-rules.md files
# and copies them into this project's .claude/rules/synced/ directory.
# Runs automatically via SessionStart hook.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PARENT_DIR="$(cd "$PROJECT_ROOT/.." && pwd)"
SYNCED_DIR="$PROJECT_ROOT/.claude/rules/synced"

mkdir -p "$SYNCED_DIR"

synced=0

for dir in "$PARENT_DIR"/*/; do
    # Skip our own project
    [ "$(cd "$dir" && pwd)" = "$PROJECT_ROOT" ] && continue

    # Copy any *-rules.md files from .claude/
    for rules_file in "$dir".claude/*-rules.md; do
        [ -f "$rules_file" ] || continue
        cp "$rules_file" "$SYNCED_DIR/$(basename "$rules_file")"
        ((synced++))
    done
done

echo "Package rules sync: $synced rules copied to .claude/rules/synced/"
