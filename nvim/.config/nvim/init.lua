vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.g.mapleader = " "

require("config.lazy")

-- initializing colortheme
vim.cmd.colorscheme "catppuccin-mocha"

-- initializing telescope
local builtin = require('telescope.builtin')

-- setting up shortcuts for telescope
vim.keymap.set('n', '<C-p>', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})

