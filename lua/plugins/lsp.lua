-- NeoJoy: Mason + LSP plugin specs

return {

    -- Mason: LSP server installer and manager
    {
        "williamboman/mason.nvim",
        cmd  = "Mason",
        opts = {
            ui = {
                icons = {
                    package_installed   = "✓",
                    package_pending     = "➜",
                    package_uninstalled = "✗",
                },
            },
        },
    },

    -- Bridge between Mason and nvim-lspconfig
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            -- Servers to ensure are installed.
            -- Add more here or via lua/config/overrides.lua
            ensure_installed = { "lua_ls" },
            automatic_installation = false,
        },
    },

    -- LSP configuration
    {
        "neovim/nvim-lspconfig",
        event        = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local lsp_cfg   = require("config.lsp")
            local lspconfig = require("lspconfig")

            -- Extend capabilities with nvim-cmp completions if available
            local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
            if ok then
                lsp_cfg.capabilities = vim.tbl_deep_extend(
                    "force",
                    lsp_cfg.capabilities,
                    cmp_lsp.default_capabilities()
                )
            end

            for server, config in pairs(lsp_cfg.servers) do
                config.on_attach    = lsp_cfg.on_attach
                config.capabilities = lsp_cfg.capabilities
                lspconfig[server].setup(config)
            end
        end,
    },

}
