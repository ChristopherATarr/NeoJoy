-- NeoJoy: Visual layer — colorscheme, statusline, icons

return {

    -- Colorscheme: catppuccin mocha
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

    -- Statusline
    {
        "nvim-lualine/lualine.nvim",
        event        = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                theme                = "catppuccin",
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
