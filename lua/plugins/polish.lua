-- NeoJoy: Polish — notifications, dashboard, QoL editing plugins

return {

    -- Better notification UI (replaces vim.notify)
    -- lazy=false / priority=900: loads just after colorscheme, before anything notifies
    {
        "rcarriga/nvim-notify",
        lazy     = false,
        priority = 900,
        opts = {
            timeout    = 3000,
            max_height = function() return math.floor(vim.o.lines * 0.75) end,
            max_width  = function() return math.floor(vim.o.columns * 0.75) end,
        },
        config = function(_, opts)
            local notify = require("notify")
            notify.setup(opts)
            vim.notify = notify
        end,
    },

    -- Dashboard on empty start
    {
        "goolord/alpha-nvim",
        event        = "VimEnter",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local alpha     = require("alpha")
            local dashboard = require("alpha.themes.dashboard")

            dashboard.section.header.val = {
                "                                                   ",
                " ███╗   ██╗███████╗ ██████╗      ██╗ ██████╗ ██╗ ",
                " ████╗  ██║██╔════╝██╔═══██╗     ██║██╔═══██╗╚██╗",
                " ██╔██╗ ██║█████╗  ██║   ██║     ██║██║   ██║ ╚██╗",
                " ██║╚██╗██║██╔══╝  ██║   ██║██   ██║██║   ██║ ██╔╝",
                " ██║ ╚████║███████╗╚██████╔╝╚█████╔╝╚██████╔╝██╔╝ ",
                " ╚═╝  ╚═══╝╚══════╝ ╚═════╝  ╚════╝  ╚═════╝╚═╝  ",
                "                                                   ",
                "              In honor of Bill Joy                 ",
                "                                                   ",
            }

            dashboard.section.buttons.val = {
                dashboard.button("f", "  Find file",    "<cmd>Telescope find_files<cr>"),
                dashboard.button("r", "  Recent files", "<cmd>Telescope oldfiles<cr>"),
                dashboard.button("g", "  Live grep",    "<cmd>Telescope live_grep<cr>"),
                dashboard.button("q", "  Quit",         "<cmd>qa<cr>"),
            }

            -- Only show dashboard when nvim started with no file arguments
            local alpha_group = vim.api.nvim_create_augroup("NeoJoyAlpha", { clear = true })
            vim.api.nvim_create_autocmd("User", {
                group    = alpha_group,
                pattern  = "AlphaReady",
                callback = function()
                    vim.keymap.set("n", "q", "<cmd>qa<cr>", { buffer = true, silent = true })
                end,
            })

            alpha.setup(dashboard.config)
        end,
    },

    -- TODO/FIXME/HACK/NOTE comment highlighting
    {
        "folke/todo-comments.nvim",
        event        = "BufReadPost",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts         = { signs = false },
    },

    -- Project-wide search and replace
    {
        "nvim-pack/nvim-spectre",
        cmd  = "Spectre",
        keys = {
            { "<leader>S", function() require("spectre").open() end, desc = "Spectre (search/replace)" },
        },
        opts = { open_cmd = "noswapfile vnew" },
    },

    -- Surround: add/change/delete surrounding pairs (ys, cs, ds)
    {
        "kylechui/nvim-surround",
        version = "*",
        event   = "VeryLazy",
        opts    = {},
    },

}
