#!/usr/bin/env bash
# NeoJoy — Session 6 Tests: Navigation + UI
# Run from anywhere: bash tests/session6_test.sh

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
echo "=== NeoJoy Session 6: Navigation + UI ==="
echo ""

# --- File Structure ---
echo "-- File Structure --"
run_check "lua/plugins/navigation.lua exists" test -f "$PROJECT_ROOT/lua/plugins/navigation.lua"
run_check "lua/plugins/ui.lua exists"         test -f "$PROJECT_ROOT/lua/plugins/ui.lua"
echo ""

# --- Bootstrap ---
echo "-- Bootstrap --"
NVIM_APPNAME="$NVIM_APPNAME" nvim --headless +qa 2>/tmp/neojoy_s6_boot.log
check "Config loads without error (headless)" $?
echo ""

# --- Plugin Registry ---
echo "-- Plugin Registry (lazy.nvim) --"
nvim_lua "telescope.nvim registered"              "require('lazy.core.config').plugins['telescope.nvim'] ~= nil"
nvim_lua "telescope-fzf-native.nvim registered"   "require('lazy.core.config').plugins['telescope-fzf-native.nvim'] ~= nil"
nvim_lua "which-key.nvim registered"              "require('lazy.core.config').plugins['which-key.nvim'] ~= nil"
nvim_lua "catppuccin registered"                  "require('lazy.core.config').plugins['catppuccin'] ~= nil"
nvim_lua "lualine.nvim registered"                "require('lazy.core.config').plugins['lualine.nvim'] ~= nil"
nvim_lua "nvim-web-devicons registered"           "require('lazy.core.config').plugins['nvim-web-devicons'] ~= nil"
echo ""

# --- Colorscheme ---
# catppuccin is lazy=false / priority=1000, so it loads on every boot including headless
echo "-- Colorscheme --"
nvim_lua "colorscheme is catppuccin-mocha" "vim.g.colors_name == 'catppuccin-mocha'"
echo ""

# --- Telescope Key Triggers ---
# lazy.nvim registers stub keymaps for keys-spec entries immediately
echo "-- Telescope Key Triggers --"
nvim_lua "<leader>ff mapped (find files)"  "vim.fn.maparg('<leader>ff', 'n') ~= ''"
nvim_lua "<leader>fg mapped (live grep)"   "vim.fn.maparg('<leader>fg', 'n') ~= ''"
nvim_lua "<leader>fb mapped (buffers)"     "vim.fn.maparg('<leader>fb', 'n') ~= ''"
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
