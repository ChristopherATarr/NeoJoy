-- NeoJoy: global keybindings
-- Plugin-specific keymaps live alongside their plugin configs

local map = function(mode, lhs, rhs, opts)
    opts = vim.tbl_extend("force", { silent = true }, opts or {})
    vim.keymap.set(mode, lhs, rhs, opts)
end

-- Insert mode
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Window navigation (overrides <C-l> screen-redraw — intentional)
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to below window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to above window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Window resizing
map("n", "<C-Up>",    ":resize +2<CR>",          { desc = "Increase window height" })
map("n", "<C-Down>",  ":resize -2<CR>",          { desc = "Decrease window height" })
map("n", "<C-Left>",  ":vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Buffer navigation (overrides H/L screen-top/bottom — intentional)
map("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", ":bnext<CR>",     { desc = "Next buffer" })

-- Search: keep matches centered when jumping
map("n", "n", "nzzzv", { desc = "Next match (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev match (centered)" })

-- Clear search highlight
map("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear search highlight" })

-- Visual mode: indent and keep selection
map("v", "<", "<gv", { desc = "Indent left, keep selection" })
map("v", ">", ">gv", { desc = "Indent right, keep selection" })

-- Move lines (normal and visual)
map("n", "<A-j>", ":m .+1<CR>==",        { desc = "Move line down" })
map("n", "<A-k>", ":m .-2<CR>==",        { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv",   { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv",   { desc = "Move selection up" })

-- File operations
map("n", "<leader>w", ":w<CR>",   { desc = "Save file" })
map("n", "<leader>q", ":q<CR>",   { desc = "Quit" })
map("n", "<leader>Q", ":qa!<CR>", { desc = "Force quit all" })
