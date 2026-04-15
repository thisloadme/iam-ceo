#!/bin/bash
# Quality Gate Runner — IAM CEO Framework
# Usage: bash skills/quality-gate/run_checks.sh [scope]
# Scope is optional — defaults to full check if not provided

set -e

SCOPE="${1:-all}"
PASS=true

echo "=== Quality Gate ==="
echo "Scope: $SCOPE"
echo ""

# Detect what to check based on changes
if [ "$SCOPE" == "all" ]; then
    echo "[*] Running full quality gate..."
else
    echo "[*] Running targeted check for: $SCOPE"
fi

# Secrets scan (basic — check for common patterns)
echo ""
echo "=== Secrets Scan ==="
SECRETS_FOUND=$(git diff --cached --name-only | xargs grep -l "password\s*=\s*['\"][^'\"]{8}" 2>/dev/null || true)
if [ -n "$SECRETS_FOUND" ]; then
    echo "[!] WARNING: Potential hardcoded passwords found:"
    echo "$SECRETS_FOUND"
    PASS=false
else
    echo "[OK] No obvious secrets detected"
fi

# Debug code scan
echo ""
echo "=== Debug Code Scan ==="
DEBUG_FOUND=$(git diff --cached --name-only | xargs grep -l "console\.log\|console\.error\|print_r\|var_dump\|fmt\.Println" 2>/dev/null || true)
if [ -n "$DEBUG_FOUND" ]; then
    echo "[!] WARNING: Debug code found:"
    echo "$DEBUG_FOUND"
    PASS=false
else
    echo "[OK] No debug code detected"
fi

# TODO comments check (optional — can be noisy)
echo ""
echo "=== TODO/FIXME Scan ==="
TODO_FOUND=$(git diff --cached --name-only | xargs grep -l "TODO\|FIXME\|XXX" 2>/dev/null || true)
if [ -n "$TODO_FOUND" ]; then
    echo "[!] Note: TODO/FIXME comments found (may need cleanup):"
    echo "$TODO_FOUND"
fi

echo ""
echo "=== Summary ==="
if [ "$PASS" == "true" ]; then
    echo "[PASS] Quality gate passed"
    exit 0
else
    echo "[FAIL] Quality gate failed — fix issues before proceeding"
    exit 1
fi
