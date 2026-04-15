#!/bin/bash
# Scope Checker — Verify changed files match task scope
# Usage: bash skills/scope-checker/check_scope.sh [file1 file2 ...]
# Or: Enter scope files line by line when prompted

set -e

echo "=== Scope Checker ==="
echo ""

# Get changed files
CHANGED=$(git diff --name-only HEAD 2>/dev/null || git diff --name-only)
if [ -z "$CHANGED" ]; then
    CHANGED=$(git diff --cached --name-only)
fi

if [ -z "$CHANGED" ]; then
    echo "[!] No changes detected. Have you staged or modified files?"
    exit 1
fi

echo "Changed files:"
echo "$CHANGED" | while read f; do echo "  - $f"; done
echo ""

# Get scope from args or interactive
if [ $# -gt 0 ]; then
    SCOPE=("$@")
else
    echo "Enter scope files (one per line, empty line to finish):"
    SCOPE=()
    while IFS= read -r line; do
        [ -z "$line" ] && break
        SCOPE+=("$line")
    done
fi

if [ ${#SCOPE[@]} -eq 0 ]; then
    echo "[!] No scope provided. Cannot verify."
    exit 1
fi

echo "Expected scope:"
for f in "${SCOPE[@]}"; do echo "  - $f"; done
echo ""

# Verify each changed file
VIOLATIONS=()
for file in $CHANGED; do
    IN_SCOPE=false
    for scope_file in "${SCOPE[@]}"; do
        if [ "$file" = "$scope_file" ]; then
            IN_SCOPE=true
            break
        fi
    done

    if [ "$IN_SCOPE" = false ]; then
        VIOLATIONS+=("$file")
    fi
done

echo "=== Verification ==="
if [ ${#VIOLATIONS[@]} -eq 0 ]; then
    echo "[PASS] All changed files are within scope"
    exit 0
else
    echo "[FAIL] Scope violations detected:"
    for v in "${VIOLATIONS[@]}"; do echo "  - $v"; done
    echo ""
    echo "[ACTION REQUIRED] Report to COO immediately"
    exit 1
fi
