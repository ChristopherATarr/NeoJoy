-- NeoJoy: Git workflow + terminal integration

return {

    -- Floating/split terminal with lazygit support
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        keys    = { "<C-\\>" },
        opts    = {
            open_mapping = [[<C-\>]],
            direction    = "float",
            float_opts   = { border = "curved" },
            size = function(term)
                if term.direction == "horizontal" then
                    return 15
                elseif term.direction == "vertical" then
                    return math.floor(vim.o.columns * 0.4)
                end
            end,
        },
    },

    -- Lazygit inside Neovim
    {
        "kdheepak/lazygit.nvim",
        cmd          = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile" },
        dependencies = { "nvim-lua/plenary.nvim" },
        keys         = {
            { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
        },
    },

    -- Git signs in the gutter + hunk actions
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts  = {
            signs = {
                add          = { text = "│" },
                change       = { text = "│" },
                delete       = { text = "󰍵" },
                topdelete    = { text = "‾" },
                changedelete = { text = "~" },
                untracked    = { text = "│" },
            },
            on_attach = function(bufnr)
                local gs  = package.loaded.gitsigns
                local map = function(mode, lhs, rhs, opts)
                    opts = vim.tbl_extend("force", { silent = true, buffer = bufnr }, opts or {})
                    vim.keymap.set(mode, lhs, rhs, opts)
                end

                -- Hunk navigation (respects diff mode)
                map("n", "]c", function()
                    if vim.wo.diff then return "]c" end
                    vim.schedule(function() gs.next_hunk() end)
                    return "<Ignore>"
                end, { expr = true, desc = "Next hunk" })
                map("n", "[c", function()
                    if vim.wo.diff then return "[c" end
                    vim.schedule(function() gs.prev_hunk() end)
                    return "<Ignore>"
                end, { expr = true, desc = "Prev hunk" })

                -- Hunk actions
                map("n", "<leader>gs", gs.stage_hunk,                        { desc = "Stage hunk" })
                map("n", "<leader>gr", gs.reset_hunk,                        { desc = "Reset hunk" })
                map("n", "<leader>gS", gs.stage_buffer,                      { desc = "Stage buffer" })
                map("n", "<leader>gR", gs.reset_buffer,                      { desc = "Reset buffer" })
                map("n", "<leader>gp", gs.preview_hunk,                      { desc = "Preview hunk" })
                map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, { desc = "Blame line" })
                map("n", "<leader>gd", gs.diffthis,                          { desc = "Diff this" })
            end,
        },
    },

}
