-- NeoJoy: LSP on_attach, capabilities, and server configuration
-- Separated from plugin specs so on_attach can be tested independently

local M = {}

-- Keymaps and behavior applied whenever an LSP server attaches to a buffer
M.on_attach = function(client, bufnr)
    local map = function(lhs, rhs, opts)
        opts = vim.tbl_extend("force", { silent = true, buffer = bufnr }, opts or {})
        vim.keymap.set("n", lhs, rhs, opts)
    end

    -- Navigation
    map("gd", vim.lsp.buf.definition,      { desc = "Go to definition" })
    map("gD", vim.lsp.buf.declaration,     { desc = "Go to declaration" })
    map("gr", vim.lsp.buf.references,      { desc = "Go to references" })
    map("gi", vim.lsp.buf.implementation,  { desc = "Go to implementation" })
    map("gt", vim.lsp.buf.type_definition, { desc = "Go to type definition" })

    -- Documentation
    map("K",     vim.lsp.buf.hover,           { desc = "Hover documentation" })
    map("<C-s>", vim.lsp.buf.signature_help,  { desc = "Signature help" })

    -- Actions
    map("<leader>rn", vim.lsp.buf.rename,      { desc = "Rename symbol" })
    map("<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
    map("<leader>f",  function()
        vim.lsp.buf.format({ async = true })
    end, { desc = "Format buffer" })

    -- Diagnostics (<leader>d namespace belongs to DAP; diagnostics use subkeys)
    map("<leader>dd", vim.diagnostic.open_float, { desc = "Show diagnostic float" })
    map("[d",         vim.diagnostic.goto_prev,  { desc = "Prev diagnostic" })
    map("]d",         vim.diagnostic.goto_next,  { desc = "Next diagnostic" })
    map("<leader>dq", vim.diagnostic.setloclist, { desc = "Diagnostic quickfix list" })

    -- Format on save (only when client supports it)
    if client and client.supports_method("textDocument/formatting") then
        local fmt_group = vim.api.nvim_create_augroup("NeoJoyLspFormat_" .. bufnr, { clear = true })
        vim.api.nvim_create_autocmd("BufWritePre", {
            group    = fmt_group,
            buffer   = bufnr,
            desc     = "LSP format on save",
            callback = function()
                vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 2000 })
            end,
        })
    end
end

-- Base capabilities (extended by nvim-cmp in Session 4)
M.capabilities = vim.lsp.protocol.make_client_capabilities()

-- Diagnostic display
M.setup_diagnostics = function()
    vim.diagnostic.config({
        virtual_text     = true,
        signs            = true,
        underline        = true,
        update_in_insert = false,
        severity_sort    = true,
    })
end

-- Per-server configuration
-- Users can extend this via lua/config/overrides.lua
M.servers = {
    lua_ls = {
        settings = {
            Lua = {
                diagnostics = { globals = { "vim" } },
                workspace   = { checkThirdParty = false },
                telemetry   = { enable = false },
            },
        },
    },
    pyright = {},
}

return M
