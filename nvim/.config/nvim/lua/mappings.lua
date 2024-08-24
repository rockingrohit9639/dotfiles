local keymap = vim.keymap
local opts = { noremap = true, silent = true }

vim.g.mapleader = " "

-- Save file
keymap.set("n", "<C-s>", ":w<CR>", opts)
keymap.set("i", "<C-s>", ":w<CR>", opts)
keymap.set("v", "<C-s>", ":w<CR>", opts)

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- Split window
keymap.set("n", "ss", ":split<Return>", opts)
keymap.set("n", "sv", ":vsplit<Return>", opts)

-- Move window
keymap.set("n", "sh", "<C-w>h")
keymap.set("n", "sk", "<C-w>k")
keymap.set("n", "sj", "<C-w>j")
keymap.set("n", "sl", "<C-w>l")

-- Resize window
keymap.set("n", "<C-S-h>", "<C-w><")
keymap.set("n", "<C-S-l>", "<C-w>>")
keymap.set("n", "<C-S-k>", "<C-w>+")
keymap.set("n", "<C-S-j>", "<C-w>-")
