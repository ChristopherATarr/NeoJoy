#!/usr/bin/env bash
# NeoJoy — Session 7 Tests: DAP Debugger
# Run from anywhere: bash tests/session7_test.sh

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

nvim_script() {
    local desc="$1"
    local script="$2"
    NVIM_APPNAME="$NVIM_APPNAME" nvim --headless \
        -c "luafile $script" \
        +qa 2>/dev/null
    check "$desc" $?
}

echo ""
echo "=== NeoJoy Session 7: DAP Debugger ==="
echo ""

# --- File Structure ---
echo "-- File Structure --"
run_check "lua/plugins/dap.lua exists" test -f "$PROJECT_ROOT/lua/plugins/dap.lua"
echo ""

# --- Bootstrap ---
echo "-- Bootstrap --"
NVIM_APPNAME="$NVIM_APPNAME" nvim --headless +qa 2>/tmp/neojoy_s7_boot.log
check "Config loads without error (headless)" $?
echo ""

# --- Plugin Registry ---
echo "-- Plugin Registry (lazy.nvim) --"
nvim_lua "nvim-dap registered"              "require('lazy.core.config').plugins['nvim-dap'] ~= nil"
nvim_lua "nvim-dap-ui registered"           "require('lazy.core.config').plugins['nvim-dap-ui'] ~= nil"
nvim_lua "mason-nvim-dap.nvim registered"   "require('lazy.core.config').plugins['mason-nvim-dap.nvim'] ~= nil"
nvim_lua "nvim-dap-virtual-text registered" "require('lazy.core.config').plugins['nvim-dap-virtual-text'] ~= nil"
nvim_lua "nvim-nio registered"              "require('lazy.core.config').plugins['nvim-nio'] ~= nil"
echo ""

# --- DAP Signs (defined in plugin init, runs at startup) ---
echo "-- DAP Signs --"
nvim_lua "DapBreakpoint sign defined"  "#vim.fn.sign_getdefined('DapBreakpoint') > 0"
nvim_lua "DapStopped sign defined"     "#vim.fn.sign_getdefined('DapStopped') > 0"
nvim_lua "DapLogPoint sign defined"    "#vim.fn.sign_getdefined('DapLogPoint') > 0"
echo ""

# --- DAP Key Triggers (lazy stub keymaps) ---
echo "-- DAP Key Triggers --"
nvim_lua "<leader>db mapped (toggle breakpoint)" "vim.fn.maparg('<leader>db', 'n') ~= ''"
nvim_lua "<leader>dc mapped (continue)"          "vim.fn.maparg('<leader>dc', 'n') ~= ''"
nvim_lua "<leader>du mapped (DAP UI toggle)"     "vim.fn.maparg('<leader>du', 'n') ~= ''"
nvim_lua "<F5> mapped (continue)"               "vim.fn.maparg('<F5>', 'n') ~= ''"
echo ""

# --- DAP API (force-load nvim-dap and check API surface) ---
echo "-- DAP API --"
DAP_API_SCRIPT=$(mktemp /tmp/neojoy_dap_api.XXXXXX.lua)
cat > "$DAP_API_SCRIPT" << 'EOF'
require("lazy").load({ plugins = { "nvim-dap" } })
local dap = require("dap")
local required_fns = {
    "continue", "step_over", "step_into", "step_out",
    "toggle_breakpoint", "set_breakpoint", "repl",
}
local missing = {}
for _, fn in ipairs(required_fns) do
    if type(dap[fn]) ~= "function" and type(dap[fn]) ~= "table" then
        table.insert(missing, fn)
    end
end
if #missing > 0 then
    io.stderr:write("Missing DAP API: " .. table.concat(missing, ", ") .. "\n")
    vim.cmd("cq 1")
end
EOF
nvim_script "nvim-dap has expected API surface" "$DAP_API_SCRIPT"
rm -f "$DAP_API_SCRIPT"

# --- Breakpoint set/clear ---
BP_SCRIPT=$(mktemp /tmp/neojoy_dap_bp.XXXXXX.lua)
cat > "$BP_SCRIPT" << 'EOF'
require("lazy").load({ plugins = { "nvim-dap" } })
local dap = require("dap")
local bufnr = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "x = 1", "y = 2" })
vim.api.nvim_set_current_buf(bufnr)
vim.api.nvim_win_set_cursor(0, { 1, 0 })
-- Set breakpoint
dap.toggle_breakpoint()
local all_bps = require("dap.breakpoints").get(bufnr)
local bps = all_bps[bufnr] or {}
if #bps == 0 then
    io.stderr:write("Breakpoint not set\n")
    vim.cmd("cq 1")
end
-- Clear breakpoint
dap.toggle_breakpoint()
all_bps = require("dap.breakpoints").get(bufnr)
bps = all_bps[bufnr] or {}
if #bps > 0 then
    io.stderr:write("Breakpoint not cleared\n")
    vim.cmd("cq 1")
end
EOF
nvim_script "Breakpoint set and clear on scratch buffer" "$BP_SCRIPT"
rm -f "$BP_SCRIPT"
echo ""

# --- mason-nvim-dap ensure_installed ---
echo "-- Adapter Configuration --"
nvim_lua "mason-nvim-dap has python adapter" \
    "(function() local s = require('lazy.core.config').plugins['mason-nvim-dap.nvim']; local ei = (s and s.opts and s.opts.ensure_installed) or {}; for _, v in ipairs(ei) do if v == 'python' then return true end end end)()"
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
