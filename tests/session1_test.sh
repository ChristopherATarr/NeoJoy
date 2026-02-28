#!/usr/bin/env bash
# NeoJoy — Session 1 Tests
# Run from anywhere: bash tests/session1_test.sh

PASS=0
FAIL=0
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NVIM_APPNAME="neojoy"
LAZY_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/${NVIM_APPNAME}/lazy/lazy.nvim"

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

echo ""
echo "=== NeoJoy Session 1: Foundation ==="
echo ""

# --- Structure Tests ---
echo "-- Directory Structure --"
run_check "init.lua exists"          test -f "$PROJECT_ROOT/init.lua"
run_check "lua/core/lazy.lua exists" test -f "$PROJECT_ROOT/lua/core/lazy.lua"
run_check "lua/core/ exists"         test -d "$PROJECT_ROOT/lua/core"
run_check "lua/plugins/ exists"      test -d "$PROJECT_ROOT/lua/plugins"
run_check "lua/config/ exists"       test -d "$PROJECT_ROOT/lua/config"
echo ""

# --- Bootstrap Test ---
echo "-- Bootstrap --"
NVIM_APPNAME="$NVIM_APPNAME" nvim --headless +qa 2>/tmp/neojoy_boot.log
check "init.lua loads without error (headless)" $?

run_check "lazy.nvim bootstrapped to data dir" test -d "$LAZY_PATH"
echo ""

# --- Startup Time Test ---
echo "-- Performance --"
STARTUP_LOG=$(mktemp /tmp/neojoy_startup.XXXXXX)
NVIM_APPNAME="$NVIM_APPNAME" nvim --headless --startuptime "$STARTUP_LOG" +qa 2>/dev/null
STARTUP_MS=$(grep "NVIM STARTED" "$STARTUP_LOG" 2>/dev/null | awk '{print $1}' | cut -d. -f1)
rm -f "$STARTUP_LOG"
STARTUP_MS="${STARTUP_MS:-999}"
echo "  Startup time: ${STARTUP_MS}ms"
[ "$STARTUP_MS" -lt 50 ]
check "Startup time < 50ms" $?
echo ""

# --- Summary ---
TOTAL=$((PASS + FAIL))
echo "Results: $PASS/$TOTAL passed"
echo ""
[ "$FAIL" -eq 0 ]
