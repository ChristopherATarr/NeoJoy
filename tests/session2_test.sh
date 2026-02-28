#!/usr/bin/env bash
# NeoJoy — Session 2 Tests: Core Options, Keymaps, Autocmds
# Run from anywhere: bash tests/session2_test.sh

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

# Assert a lua boolean expression is truthy
nvim_lua() {
    local desc="$1"
    local lua="$2"
    NVIM_APPNAME="$NVIM_APPNAME" nvim --headless \
        -c "lua if not ($lua) then vim.cmd('cq 1') end" \
        +qa 2>/dev/null
    check "$desc" $?
}

# Assert a lua statement runs without error (pcall)
nvim_lua_ok() {
    local desc="$1"
    local lua="$2"
    NVIM_APPNAME="$NVIM_APPNAME" nvim --headless \
        -c "lua local ok = pcall(function() $lua end); if not ok then vim.cmd('cq 1') end" \
        +qa 2>/dev/null
    check "$desc" $?
}

echo ""
echo "=== NeoJoy Session 2: Core Options, Keymaps, Autocmds ==="
echo ""

# --- File Structure ---
echo "-- File Structure --"
run_check "lua/core/options.lua exists"  test -f "$PROJECT_ROOT/lua/core/options.lua"
run_check "lua/core/keymaps.lua exists"  test -f "$PROJECT_ROOT/lua/core/keymaps.lua"
run_check "lua/core/autocmds.lua exists" test -f "$PROJECT_ROOT/lua/core/autocmds.lua"
echo ""

# --- Config Loads Without Error ---
echo "-- Bootstrap --"
NVIM_APPNAME="$NVIM_APPNAME" nvim --headless +qa 2>/tmp/neojoy_s2_boot.log
check "Config loads without error (headless)" $?
echo ""

# --- Options ---
echo "-- Options --"
nvim_lua "number = true"         "vim.opt.number:get() == true"
nvim_lua "relativenumber = true" "vim.opt.relativenumber:get() == true"
nvim_lua "expandtab = true"      "vim.opt.expandtab:get() == true"
nvim_lua "shiftwidth = 2"        "vim.opt.shiftwidth:get() == 2"
nvim_lua "signcolumn = 'yes'"    "vim.opt.signcolumn:get() == 'yes'"
nvim_lua "termguicolors = true"  "vim.opt.termguicolors:get() == true"
nvim_lua "splitright = true"     "vim.opt.splitright:get() == true"
nvim_lua "splitbelow = true"     "vim.opt.splitbelow:get() == true"
nvim_lua "undofile = true"       "vim.opt.undofile:get() == true"
nvim_lua "swapfile = false"      "vim.opt.swapfile:get() == false"
echo ""

# --- Keymaps ---
echo "-- Keymaps --"
nvim_lua "leader is <Space>"              "vim.g.mapleader == ' '"
nvim_lua "jk -> Esc (insert mode)"       "vim.fn.maparg('jk', 'i') ~= ''"
nvim_lua "<C-h> mapped (window nav)"     "vim.fn.maparg('<C-h>', 'n') ~= ''"
nvim_lua "<C-j> mapped (window nav)"     "vim.fn.maparg('<C-j>', 'n') ~= ''"
nvim_lua "<C-k> mapped (window nav)"     "vim.fn.maparg('<C-k>', 'n') ~= ''"
nvim_lua "<C-l> mapped (window nav)"     "vim.fn.maparg('<C-l>', 'n') ~= ''"
nvim_lua "< mapped in visual (keep sel)" "vim.fn.maparg('<', 'v') ~= ''"
nvim_lua "> mapped in visual (keep sel)" "vim.fn.maparg('>', 'v') ~= ''"
echo ""

# --- No Conflicts with Core Motions ---
echo "-- No Conflicts with Core Motions --"
nvim_lua "h not remapped in normal" "vim.fn.maparg('h', 'n') == ''"
nvim_lua "j not remapped in normal" "vim.fn.maparg('j', 'n') == ''"
nvim_lua "k not remapped in normal" "vim.fn.maparg('k', 'n') == ''"
nvim_lua "l not remapped in normal" "vim.fn.maparg('l', 'n') == ''"
nvim_lua "w not remapped in normal" "vim.fn.maparg('w', 'n') == ''"
nvim_lua "b not remapped in normal" "vim.fn.maparg('b', 'n') == ''"
echo "  (Note: n/N remapped to nzzzv/Nzzzv — centered search, intentional)"
echo "  (Note: <S-h>/<S-l> remapped to buffer nav — intentional override of H/L)"
echo "  (Note: <C-l> overrides screen-redraw builtin — intentional)"
echo ""

# --- Autocmd Groups ---
echo "-- Autocmd Groups --"
nvim_lua_ok "NeoJoyYankHighlight group exists" \
    "vim.api.nvim_get_autocmds({ group = 'NeoJoyYankHighlight' })"
nvim_lua_ok "NeoJoyCursorRestore group exists" \
    "vim.api.nvim_get_autocmds({ group = 'NeoJoyCursorRestore' })"
nvim_lua_ok "NeoJoyAutoResize group exists" \
    "vim.api.nvim_get_autocmds({ group = 'NeoJoyAutoResize' })"
nvim_lua_ok "NeoJoyTrimWhitespace group exists" \
    "vim.api.nvim_get_autocmds({ group = 'NeoJoyTrimWhitespace' })"
echo ""

# --- Summary ---
TOTAL=$((PASS + FAIL))
echo "Results: $PASS/$TOTAL passed"
echo ""
[ "$FAIL" -eq 0 ]
