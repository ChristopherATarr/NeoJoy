-- NeoJoy: Treesitter — parser management for Neovim 0.12+
-- Highlighting and indentation are now handled natively by Neovim.
-- nvim-treesitter manages parser installation only.

return {
    {
        "nvim-treesitter/nvim-treesitter",
        build  = ":TSUpdate",
        event  = { "BufReadPost", "BufNewFile" },
        -- opts kept inspectable for tests (session4_test.sh checks ensure_installed)
        opts   = {
            ensure_installed = {
                "lua", "vim", "vimdoc",
                "python", "javascript", "typescript",
                "bash", "json", "yaml", "toml", "markdown",
            },
        },
        config = function(_, opts)
            local installed = require("nvim-treesitter.config").get_installed()
            local installed_set = {}
            for _, lang in ipairs(installed) do
                installed_set[lang] = true
            end
            local missing = {}
            for _, lang in ipairs(opts.ensure_installed or {}) do
                if not installed_set[lang] then
                    table.insert(missing, lang)
                end
            end
            if #missing > 0 then
                require("nvim-treesitter.install").install(missing, { summary = false })
            end
        end,
    },
}
