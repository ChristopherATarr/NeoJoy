#!/usr/bin/env bash
# NeoJoy — Session 4 Tests: Completion + Treesitter
# Run from anywhere: bash tests/session4_test.sh

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
echo "=== NeoJoy Session 4: Completion + Treesitter ==="
echo ""

# --- File Structure ---
echo "-- File Structure --"
run_check "lua/plugins/completion.lua exists"  test -f "$PROJECT_ROOT/lua/plugins/completion.lua"
run_check "lua/plugins/treesitter.lua exists"  test -f "$PROJECT_ROOT/lua/plugins/treesitter.lua"
echo ""

# --- Bootstrap ---
echo "-- Bootstrap --"
NVIM_APPNAME="$NVIM_APPNAME" nvim --headless +qa 2>/tmp/neojoy_s4_boot.log
check "Config loads without error (headless)" $?
echo ""

# --- Plugin Registry ---
echo "-- Plugin Registry (lazy.nvim) --"
nvim_lua "nvim-cmp registered"         "require('lazy.core.config').plugins['nvim-cmp'] ~= nil"
nvim_lua "LuaSnip registered"          "require('lazy.core.config').plugins['LuaSnip'] ~= nil"
nvim_lua "cmp-nvim-lsp registered"     "require('lazy.core.config').plugins['cmp-nvim-lsp'] ~= nil"
nvim_lua "cmp-buffer registered"       "require('lazy.core.config').plugins['cmp-buffer'] ~= nil"
nvim_lua "cmp-path registered"         "require('lazy.core.config').plugins['cmp-path'] ~= nil"
nvim_lua "nvim-treesitter registered"  "require('lazy.core.config').plugins['nvim-treesitter'] ~= nil"
echo ""

# --- Treesitter ensure_installed ---
echo "-- Treesitter Parser List --"
PARSERS_SCRIPT=$(mktemp /tmp/neojoy_parsers_test.XXXXXX.lua)
cat > "$PARSERS_SCRIPT" << 'EOF'
local spec = require("lazy.core.config").plugins["nvim-treesitter"]
if not spec then vim.cmd("cq 1") end
local opts = spec.opts or {}
local ei   = opts.ensure_installed or {}
local required = { "lua", "vim", "python", "bash", "json" }
local missing  = {}
for _, lang in ipairs(required) do
    local found = false
    for _, installed in ipairs(ei) do
        if installed == lang then found = true; break end
    end
    if not found then table.insert(missing, lang) end
end
if #missing > 0 then
    io.stderr:write("Missing parsers: " .. table.concat(missing, ", ") .. "\n")
    vim.cmd("cq 1")
end
EOF
nvim_script "ensure_installed includes core parsers (lua, vim, python, bash, json)" "$PARSERS_SCRIPT"
rm -f "$PARSERS_SCRIPT"
echo ""

# --- Format on Save ---
echo "-- Format on Save --"
FORMAT_SCRIPT=$(mktemp /tmp/neojoy_format_test.XXXXXX.lua)
cat > "$FORMAT_SCRIPT" << 'EOF'
local lsp_cfg     = require("config.lsp")
local bufnr       = vim.api.nvim_create_buf(false, true)
local mock_client = { supports_method = function() return true end }
vim.api.nvim_set_current_buf(bufnr)
lsp_cfg.on_attach(mock_client, bufnr)
local autocmds = vim.api.nvim_get_autocmds({ event = "BufWritePre", buffer = bufnr })
if #autocmds == 0 then
    io.stderr:write("No BufWritePre autocmd registered for buffer\n")
    vim.cmd("cq 1")
end
EOF
nvim_script "on_attach registers BufWritePre (format on save)" "$FORMAT_SCRIPT"
rm -f "$FORMAT_SCRIPT"
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
