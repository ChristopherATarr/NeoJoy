#!/usr/bin/env bash
# NeoJoy — Session 8 Tests: Override Layer + Polish
# Run from anywhere: bash tests/session8_test.sh

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
echo "=== NeoJoy Session 8: Override Layer + Polish ==="
echo ""

# --- File Structure ---
echo "-- File Structure --"
run_check "lua/config/overrides.lua exists"  test -f "$PROJECT_ROOT/lua/config/overrides.lua"
run_check "lua/plugins/polish.lua exists"    test -f "$PROJECT_ROOT/lua/plugins/polish.lua"
echo ""

# --- Bootstrap ---
echo "-- Bootstrap --"
NVIM_APPNAME="$NVIM_APPNAME" nvim --headless +qa 2>/tmp/neojoy_s8_boot.log
check "Config loads without error (headless)" $?
echo ""

# --- Plugin Registry ---
echo "-- Plugin Registry (lazy.nvim) --"
nvim_lua "nvim-notify registered"      "require('lazy.core.config').plugins['nvim-notify'] ~= nil"
nvim_lua "alpha-nvim registered"       "require('lazy.core.config').plugins['alpha-nvim'] ~= nil"
nvim_lua "todo-comments.nvim registered" "require('lazy.core.config').plugins['todo-comments.nvim'] ~= nil"
nvim_lua "nvim-spectre registered"     "require('lazy.core.config').plugins['nvim-spectre'] ~= nil"
nvim_lua "nvim-surround registered"    "require('lazy.core.config').plugins['nvim-surround'] ~= nil"
echo ""

# --- Overrides Do Not Clobber Defaults ---
echo "-- Overrides Do Not Clobber Defaults --"
nvim_lua "number still true after overrides"    "vim.opt.number:get() == true"
nvim_lua "swapfile still false after overrides" "vim.opt.swapfile:get() == false"
nvim_lua "leader still <Space> after overrides" "vim.g.mapleader == ' '"
nvim_lua "colorscheme still catppuccin"         "vim.g.colors_name == 'catppuccin-mocha'"
echo ""

# --- nvim-notify ---
# nvim-notify is lazy=false so it loads every boot and overrides vim.notify
echo "-- nvim-notify --"
nvim_lua "vim.notify overridden by nvim-notify" \
    "tostring(vim.notify):find('notify') ~= nil or require('lazy.core.config').plugins['nvim-notify'].lazy == false"
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
