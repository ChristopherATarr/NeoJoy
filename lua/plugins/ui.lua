-- NeoJoy: Visual layer — colorscheme, statusline, icons

return {

    -- Colorscheme: catppuccin mocha (default)
    -- lazy=false + priority=1000: loads before everything else, every boot
    {
        "catppuccin/nvim",
        name     = "catppuccin",
        lazy     = false,
        priority = 1000,
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
            vim.cmd.colorscheme("catppuccin")
        end,
    },

    -- Colorscheme: solarized dark (transparent background)
    -- priority=999: setup runs at boot but catppuccin remains active default
    {
        "maxmx03/solarized.nvim",
        lazy     = false,
        priority = 999,
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
