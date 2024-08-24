-- Tabs & indentation
vim.opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
vim.opt.shiftwidth = 2 -- 2 spaces for indent width
vim.opt.expandtab = true -- Expand tab to spaces
vim.opt.autoindent = true -- Copy indent from current line when starting new one

vim.opt.relativenumber = true

vim.scriptencoding = "utf-8"
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

vim.opt.title = true
vim.opt.autoindent = true
vim.opt.hlsearch = true
vim.opt.showcmd = true
vim.opt.cmdheight = 0
vim.opt.smarttab = true

-- Backspace
vim.opt.backspace = "indent,eol,start" -- Allow backspace on indent, end of line or insert mode start position

-- Clipboard
vim.opt.clipboard:append("unnamedplus") -- Use system clipboard as default register
