-- NeoJoy: Visual layer — colorscheme, statusline, icons

return {

    -- Colorscheme: cyberdream (default) — cyberpunk dark
    -- lazy=false + priority=1000: loads before everything else, every boot
    {
        "scottmckendry/cyberdream.nvim",
        lazy     = false,
        priority = 1000,
        opts = {
            transparent  = true,
            italic_comments = true,
            borderless_pickers = false,
        },
        config = function(_, opts)
            require("cyberdream").setup(opts)
            vim.cmd.colorscheme("cyberdream")
        end,
    },

    -- Colorscheme: catppuccin mocha (alternate)
    {
        "catppuccin/nvim",
        name     = "catppuccin",
        lazy     = false,
        priority = 999,
        opts = {
            flavour = "mocha",
            integrations = {
                cmp        = true,
                gitsigns   = true,
                mason      = true,
                telescope  = { enabled = true },
                treesitter = true,
                which_key  = true,
            },
        },
        config = function(_, opts)
            require("catppuccin").setup(opts)
        end,
    },

    -- Colorscheme: solarized dark (alternate)
    {
        "maxmx03/solarized.nvim",
        lazy     = false,
        priority = 998,
        opts = {
            variant     = "dark",
            transparent = { enabled = true },
        },
        config = function(_, opts)
            require("solarized").setup(opts)
        end,
    },

    -- Theme switcher: :Themery or <leader>th
    -- Persists selection to ~/.local/share/neojoy/themery.lua
    {
        "zaldih/themery.nvim",
        cmd = "Themery",
        config = function()
            require("themery").setup({
                themes = {
                    { name = "Cyberdream",       colorscheme = "cyberdream" },
                    { name = "Catppuccin Mocha", colorscheme = "catppuccin" },
                    { name = "Solarized Dark",   colorscheme = "solarized" },
                },
                livePreview = true,
            })
        end,
    },

    -- Statusline
    {
        "nvim-lualine/lualine.nvim",
        event        = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                theme                = "auto",
                globalstatus         = true,
                component_separators = { left = "", right = "" },
                section_separators   = { left = "", right = "" },
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch", "diff", "diagnostics" },
                lualine_c = { { "filename", path = 1 } },
                lualine_x = { "encoding", "fileformat", "filetype" },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
        },
    },

    -- Icons (used by lualine, telescope, etc.)
    {
        "nvim-tree/nvim-web-devicons",
        lazy = true,
    },

}
