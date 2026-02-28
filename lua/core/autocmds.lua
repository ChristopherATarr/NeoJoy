-- NeoJoy: autocommands

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight yanked text briefly
local yank_group = augroup("NeoJoyYankHighlight", { clear = true })
autocmd("TextYankPost", {
    group    = yank_group,
    desc     = "Highlight yanked text",
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
    end,
})

-- Restore cursor position on file open
local cursor_group = augroup("NeoJoyCursorRestore", { clear = true })
autocmd("BufReadPost", {
    group    = cursor_group,
    desc     = "Restore cursor position",
    callback = function()
        local mark   = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Equalize splits when the terminal window is resized
local resize_group = augroup("NeoJoyAutoResize", { clear = true })
autocmd("VimResized", {
    group    = resize_group,
    desc     = "Equalize splits on resize",
    callback = function()
        vim.cmd("tabdo wincmd =")
    end,
})

-- Remove trailing whitespace on save for code files
local trim_group = augroup("NeoJoyTrimWhitespace", { clear = true })
autocmd("BufWritePre", {
    group   = trim_group,
    pattern = { "*.lua", "*.py", "*.js", "*.ts", "*.go", "*.rs", "*.c", "*.cpp", "*.h" },
    desc    = "Remove trailing whitespace",
    callback = function()
        local cursor = vim.fn.getpos(".")
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.setpos(".", cursor)
    end,
})
