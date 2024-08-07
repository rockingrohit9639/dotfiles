vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.g.mapleader = " "

require("config.lazy")

-- setting up colortheme
vim.cmd.colorscheme "catppuccin-mocha"

-- setting up telescope
local builtin = require('telescope.builtin')

-- setting up shortcuts for telescope
vim.keymap.set('n', '<C-p>', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})

-- setting up treesitter
local configs = require("nvim-treesitter.configs")
configs.setup({
  ensure_installed = { "c", "lua", "vim", "javascript", "typescript", "go", "html" },
  highlight = { enable = true },
  indent = { enable = true },  
})
