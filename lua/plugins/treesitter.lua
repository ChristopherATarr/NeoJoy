-- NeoJoy: Treesitter — syntax highlighting, indentation, text objects

return {
    {
        "nvim-treesitter/nvim-treesitter",
        build  = ":TSUpdate",
        event  = { "BufReadPost", "BufNewFile" },
        -- opts used here (not inline config) so ensure_installed is inspectable in tests
        opts   = {
            ensure_installed = {
                "lua", "vim", "vimdoc",
                "python", "javascript", "typescript",
                "bash", "json", "yaml", "toml", "markdown",
            },
            auto_install = false,  -- security: no silent parser downloads
            highlight = {
                enable                            = true,
                additional_vim_regex_highlighting = false,
            },
            indent = { enable = true },
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
    },
}
