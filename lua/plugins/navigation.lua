-- NeoJoy: Fuzzy finding, file navigation, keybinding discovery

return {

    -- Fuzzy finder over everything
    {
        "nvim-telescope/telescope.nvim",
        cmd          = "Telescope",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>",  desc = "Find files" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>",   desc = "Live grep" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>",     desc = "Buffers" },
            { "<leader>fh", "<cmd>Telescope help_tags<cr>",   desc = "Help tags" },
            { "<leader>fr", "<cmd>Telescope oldfiles<cr>",    desc = "Recent files" },
            { "<leader>fc", "<cmd>Telescope commands<cr>",    desc = "Commands" },
        },
        opts = {
            defaults = {
                prompt_prefix   = "  ",
                selection_caret = " ",
                path_display    = { "smart" },
                mappings = {
                    i = { ["<C-k>"] = "move_selection_previous",
                          ["<C-j>"] = "move_selection_next" },
                },
            },
        },
    },

    -- Native FZF sorter — significantly faster on large repos
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build        = "make",
        dependencies = { "nvim-telescope/telescope.nvim" },
        config = function()
            require("telescope").load_extension("fzf")
        end,
    },

    -- Keybinding popup: press any prefix and see what's available
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts  = {
            plugins = { spelling = { enabled = true } },
        },
        config = function(_, opts)
            local wk = require("which-key")
            wk.setup(opts)
            wk.add({
                { "<leader>f", group = "find" },
                { "<leader>g", group = "git" },
                { "<leader>d", group = "debug" },
            })
        end,
    },

}
