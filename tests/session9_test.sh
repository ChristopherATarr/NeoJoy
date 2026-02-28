#!/usr/bin/env bash
# NeoJoy — Session 9 Tests: Integration + GitHub Readiness
# Run from anywhere: bash tests/session9_test.sh

PASS=0
FAIL=0
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NVIM_APPNAME="neojoy"

check() {
    local desc="$1"
    local result="${2:-$?}"
    if [ "$result" -eq 0 ]; then
        echo "  PASS: $desc"
        ((PASS++))
    else
        echo "  FAIL: $desc"
        ((FAIL++))
    fi
}

run_check() {
    local desc="$1"
    shift
    "$@" 2>/dev/null
    check "$desc" $?
}

nvim_lua() {
    local desc="$1"
    local lua="$2"
    NVIM_APPNAME="$NVIM_APPNAME" nvim --headless \
        -c "lua if not ($lua) then vim.cmd('cq 1') end" \
        +qa 2>/dev/null
    check "$desc" $?
}

echo ""
echo "=== NeoJoy Session 9: Integration + GitHub Readiness ==="
echo ""

# --- lazy-lock.json ---
echo "-- Lockfile --"
run_check "lazy-lock.json exists" test -f "$PROJECT_ROOT/lazy-lock.json"

# All entries must have 40-char commit hashes (no floating branches)
python3 -c "
import json, sys
with open('$PROJECT_ROOT/lazy-lock.json') as f:
    data = json.load(f)
bad = [k for k, v in data.items() if len(v.get('commit', '')) != 40]
if bad:
    print('  Missing commit pins: ' + ', '.join(bad))
    sys.exit(1)
" 2>/dev/null
check "All plugins pinned to commit hashes" $?
echo ""

# --- Integration: All Sessions ---
echo "-- Integration: All Session Tests --"
for session in 1 2 3 4 5 6 8; do
    result=$(bash "$PROJECT_ROOT/tests/session${session}_test.sh" 2>/dev/null | grep "^Results")
    passed=$(echo "$result" | grep -o "[0-9]*/[0-9]*" | head -1)
    total=$(echo "$passed" | cut -d/ -f2)
    ok=$(echo "$passed" | cut -d/ -f1)
    [ "$ok" = "$total" ]
    check "Session $session: $passed" $?
done
echo ""

# --- Repository Files ---
echo "-- Repository Files --"
run_check "README.md exists"   test -f "$PROJECT_ROOT/README.md"
run_check ".gitignore exists"  test -f "$PROJECT_ROOT/.gitignore"

# README has key sections
run_check "README has 'NeoJoy'"       grep -q "NeoJoy"        "$PROJECT_ROOT/README.md"
run_check "README has Installation"   grep -qi "installation" "$PROJECT_ROOT/README.md"
run_check "README has Requirements"   grep -qi "require"      "$PROJECT_ROOT/README.md"
run_check "README mentions Bill Joy"  grep -q  "Bill Joy"     "$PROJECT_ROOT/README.md"

# .gitignore covers key paths
run_check ".gitignore covers .DS_Store"  grep -q "\.DS_Store" "$PROJECT_ROOT/.gitignore"
run_check ".gitignore covers *.swp"      grep -q "\.swp"      "$PROJECT_ROOT/.gitignore"
echo ""

# --- Git Repository ---
echo "-- Git Repository --"
run_check "Git repo initialized"          git -C "$PROJECT_ROOT" rev-parse HEAD
run_check "lazy-lock.json is tracked"     git -C "$PROJECT_ROOT" ls-files --error-unmatch lazy-lock.json
run_check "init.lua is tracked"           git -C "$PROJECT_ROOT" ls-files --error-unmatch init.lua
run_check "No unstaged Lua source files"  test -z "$(git -C "$PROJECT_ROOT" diff --name-only -- '*.lua' 2>/dev/null)"

# Security: no .env or secret files tracked
run_check "No .env tracked"              bash -c "! git -C '$PROJECT_ROOT' ls-files | grep -q '\.env'"
echo ""

# --- Final Startup Time ---
echo "-- Final Performance --"
STARTUP_LOG=$(mktemp /tmp/neojoy_startup.XXXXXX)
NVIM_APPNAME="$NVIM_APPNAME" nvim --headless --startuptime "$STARTUP_LOG" +qa 2>/dev/null
STARTUP_MS=$(grep "NVIM STARTED" "$STARTUP_LOG" 2>/dev/null | awk '{print $1}' | cut -d. -f1)
rm -f "$STARTUP_LOG"
STARTUP_MS="${STARTUP_MS:-999}"
echo "  Final startup time: ${STARTUP_MS}ms  (target: <50ms)"
[ "$STARTUP_MS" -lt 50 ]
check "Startup time < 50ms" $?
echo ""

# --- Summary ---
TOTAL=$((PASS + FAIL))
echo "Results: $PASS/$TOTAL passed"
echo ""
[ "$FAIL" -eq 0 ]
