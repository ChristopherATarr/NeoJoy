#!/usr/bin/env bash
# NeoJoy — Session 5 Tests: Git + Terminal
# Run from anywhere: bash tests/session5_test.sh

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
echo "=== NeoJoy Session 5: Git + Terminal ==="
echo ""

# --- File Structure ---
echo "-- File Structure --"
run_check "lua/plugins/git.lua exists" test -f "$PROJECT_ROOT/lua/plugins/git.lua"
echo ""

# --- Bootstrap ---
echo "-- Bootstrap --"
NVIM_APPNAME="$NVIM_APPNAME" nvim --headless +qa 2>/tmp/neojoy_s5_boot.log
check "Config loads without error (headless)" $?
echo ""

# --- Plugin Registry ---
echo "-- Plugin Registry (lazy.nvim) --"
nvim_lua "toggleterm.nvim registered" \
    "require('lazy.core.config').plugins['toggleterm.nvim'] ~= nil"
nvim_lua "lazygit.nvim registered" \
    "require('lazy.core.config').plugins['lazygit.nvim'] ~= nil"
nvim_lua "gitsigns.nvim registered" \
    "require('lazy.core.config').plugins['gitsigns.nvim'] ~= nil"
nvim_lua "plenary.nvim registered" \
    "require('lazy.core.config').plugins['plenary.nvim'] ~= nil"
echo ""

# --- Spec Checks ---
echo "-- Spec Integrity --"
# gitsigns loads on BufReadPre (attaches on file open in git repo)
nvim_lua "gitsigns event includes BufReadPre" \
    "(function() local e = require('lazy.core.config').plugins['gitsigns.nvim'].event or {}; for _, v in ipairs(e) do if v == 'BufReadPre' then return true end end end)()"
# toggleterm has <C-\> in its keys spec (used for lazy-loading trigger)
nvim_lua "toggleterm has <C-\\\\> key trigger" \
    "(function() local keys = require('lazy.core.config').plugins['toggleterm.nvim'].keys or {}; for _, k in ipairs(keys) do local lhs = type(k) == 'table' and k[1] or k; if lhs == '<C-\\\\>' then return true end end end)()"
echo ""

# --- Regression ---
echo "-- Regression --"
STARTUP_LOG=$(mktemp /tmp/neojoy_startup.XXXXXX)
NVIM_APPNAME="$NVIM_APPNAME" nvim --headless --startuptime "$STARTUP_LOG" +qa 2>/dev/null
STARTUP_MS=$(grep "NVIM STARTED" "$STARTUP_LOG" 2>/dev/null | awk '{print $1}' | cut -d. -f1)
rm -f "$STARTUP_LOG"
STARTUP_MS="${STARTUP_MS:-999}"
echo "  Startup time: ${STARTUP_MS}ms"
[ "$STARTUP_MS" -lt 50 ]
check "Startup time still < 50ms" $?
echo ""

# --- Summary ---
TOTAL=$((PASS + FAIL))
echo "Results: $PASS/$TOTAL passed"
echo ""
[ "$FAIL" -eq 0 ]
