#!/usr/bin/env bash
# NeoJoy — Session 3 Tests: Mason + LSP Attach
# Run from anywhere: bash tests/session3_test.sh

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

# Run a multi-line lua script file via headless nvim
nvim_script() {
    local desc="$1"
    local script="$2"
    NVIM_APPNAME="$NVIM_APPNAME" nvim --headless \
        -c "luafile $script" \
        +qa 2>/dev/null
    check "$desc" $?
}

echo ""
echo "=== NeoJoy Session 3: Mason + LSP Attach ==="
echo ""

# --- File Structure ---
echo "-- File Structure --"
run_check "lua/plugins/lsp.lua exists"  test -f "$PROJECT_ROOT/lua/plugins/lsp.lua"
run_check "lua/config/lsp.lua exists"   test -f "$PROJECT_ROOT/lua/config/lsp.lua"
echo ""

# --- Bootstrap ---
echo "-- Bootstrap --"
NVIM_APPNAME="$NVIM_APPNAME" nvim --headless +qa 2>/tmp/neojoy_s3_boot.log
check "Config loads without error (headless)" $?
echo ""

# --- Plugin Registry ---
echo "-- Plugin Registry (lazy.nvim) --"
nvim_lua "mason.nvim registered" \
    "require('lazy.core.config').plugins['mason.nvim'] ~= nil"
nvim_lua "mason-lspconfig.nvim registered" \
    "require('lazy.core.config').plugins['mason-lspconfig.nvim'] ~= nil"
nvim_lua "nvim-lspconfig registered" \
    "require('lazy.core.config').plugins['nvim-lspconfig'] ~= nil"
echo ""

# --- on_attach Keymaps ---
# config.lsp exposes on_attach so we can test it without a running LSP server
echo "-- on_attach Keymaps (called on scratch buffer) --"
ATTACH_SCRIPT=$(mktemp /tmp/neojoy_attach_test.XXXXXX.lua)
cat > "$ATTACH_SCRIPT" << 'EOF'
local lsp_cfg = require("config.lsp")
local bufnr   = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(bufnr)
lsp_cfg.on_attach(nil, bufnr)

local function has_map(lhs)
    local canonical = vim.api.nvim_replace_termcodes(lhs, true, true, true)
    for _, m in ipairs(vim.api.nvim_buf_get_keymap(bufnr, "n")) do
        if vim.api.nvim_replace_termcodes(m.lhs, true, true, true) == canonical then
            return true
        end
    end
    return false
end

local required = { "gd", "gD", "gr", "gi", "gt", "K", "<leader>rn", "<leader>ca", "[d", "]d" }
local missing  = {}
for _, lhs in ipairs(required) do
    if not has_map(lhs) then table.insert(missing, lhs) end
end
if #missing > 0 then
    io.stderr:write("Missing keymaps: " .. table.concat(missing, ", ") .. "\n")
    vim.cmd("cq 1")
end
EOF
nvim_script "on_attach registers expected keymaps" "$ATTACH_SCRIPT"
rm -f "$ATTACH_SCRIPT"
echo ""

# --- Diagnostic Config ---
echo "-- Diagnostic Config --"
nvim_lua "diagnostics: virtual_text enabled" \
    "vim.diagnostic.config().virtual_text ~= false"
nvim_lua "diagnostics: severity_sort enabled" \
    "vim.diagnostic.config().severity_sort == true"
nvim_lua "diagnostics: update_in_insert disabled" \
    "vim.diagnostic.config().update_in_insert == false"
echo ""

# --- Regression: Session 1 + 2 ---
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
